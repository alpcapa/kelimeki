-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 11. respond_to_game_invite — başlatma koruması (İMZA AYNI) ───────────
-- Canlı gövdeden (3 Ekim 2026, pg_get_functiondef) iki fark:
--   (1) Oyun satırı daveti güncellemeden ÖNCE `for update` ile kilitlenir —
--       accept_random_game ile AYNI kilit sırası (önce online_games). Eskiden
--       kilit yoktu; rastgele kabulle yarışta "açık koltuk kaldı mı" eski
--       slots'tan okunabilirdi.
--   (2) Oyun YALNIZCA "bekleyen davet yok" VE "açık koltuk yok" ise active
--       olur. Karma kadroda arkadaş kabul etti ama rastgele koltuk boşsa oyun
--       pending kalır; son koltuğu accept_random_game doldurunca başlar.
-- Ret dalı DEĞİŞMEDİ (oyunu abandoned yapar — karma kadroda arkadaşın reddi,
-- katılmış yabancıların ilanını da kapatır; bkz. rapor/açık soru).
-- create or replace → proacl korunur (canlı: authenticated + service_role, anon YOK).

create or replace function public.respond_to_game_invite(p_invite_id uuid, p_accept boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game_id uuid;
  v_remaining_pending int;
  v_open int;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select online_game_id into v_game_id
  from public.game_invites
  where id = p_invite_id and invitee_id = v_uid and status = 'pending';

  if v_game_id is null then
    raise exception 'Davet bulunamadı ya da zaten yanıtlanmış.';
  end if;

  -- (1) Kilit sırası: önce oyun.
  select public._slots_open_count(og.slots) into v_open
  from public.online_games og
  where og.id = v_game_id
  for update;

  update public.game_invites
    set status = case when p_accept then 'accepted' else 'declined' end,
        responded_at = now()
    where id = p_invite_id;

  if p_accept then
    select count(*) into v_remaining_pending
    from public.game_invites
    where online_game_id = v_game_id and status = 'pending';

    -- (2) Başlatma koruması.
    if v_remaining_pending = 0 and coalesce(v_open, 0) = 0 then
      update public.online_games
        set status = 'active', updated_at = now()
        where id = v_game_id and status = 'pending';

      if found then
        perform public.init_online_game_state(v_game_id);
      end if;
    end if;
  else
    -- Ret: oyun bir daha asla başlayamaz, hemen sonlandır.
    update public.online_games
      set status = 'abandoned', updated_at = now()
      where id = v_game_id and status = 'pending';
  end if;
end;
$$;

-- ── 12. list_my_online_games — eski istemci koruması (İMZA/DÖNÜŞ AYNI) ───
-- Canlı gövdeden TEK fark: {"type":"open"} koltuğu {"type":"ai","open":true}
-- olarak döner. Doğrulanan ayrıştırıcılar (3 Ekim 2026):
--   • Dart OnlineSlot.fromJson: 'ai' DIŞINDAKİ her türü human sayıyor →
--     maskesiz 'open', user_id'si NULL bir "insan" olurdu (koltuk satırı,
--     aday listesi; online_game_screen.dart'ta `userId!` var — pending oyunda
--     o ekran açılmıyor ama risk gereksiz). 'ai' yolu sahada test edilmiş.
--   • Web OnlineGameSlot: 'human' | 'ai'; PendingGameCard/PlayerAvatarRow
--     human olmayanı YZ çiziyor — maske web'de zaten bugünkü davranış.
-- Fazladan "open": true anahtarını eski ayrıştırıcılar yok sayar; YENİ
-- istemci onu okuyup koltuğu "?" çizer. Koltuk SAYISI değişmez
-- (slot_count_mismatch nöbetçisi etkilenmez). Oyun dolup active olunca
-- slots'ta open kalmaz, maske kendiliğinden devre dışı.
-- create or replace → proacl korunur.

create or replace function public.list_my_online_games()
returns table (
  id uuid,
  created_by uuid,
  player_count integer,
  status text,
  slots jsonb,
  created_at timestamp with time zone,
  my_role text,
  my_invite_status text,
  my_invite_id uuid
)
language sql
stable
security definer
set search_path = public
as $$
  select
    og.id,
    og.created_by,
    og.player_count,
    og.status,
    (
      select jsonb_agg(
        case
          when (elem.slot ->> 'type') = 'human' then
            elem.slot || jsonb_build_object(
              'name', pr.ad,
              'avatar_url', pr.avatar_url,
              'relation', case
                when (elem.slot ->> 'user_id')::uuid = auth.uid() then 'self'
                when fr.kabul then 'accepted'
                when fr.giden then 'pending_outgoing'
                when fr.gelen then 'pending_incoming'
                else null
              end,
              'invite_status', inv.status
            )
          when (elem.slot ->> 'type') = 'open' then
            jsonb_build_object('type', 'ai', 'open', true)
          else elem.slot
        end
        order by elem.ord
      )
      from jsonb_array_elements(og.slots) with ordinality as elem(slot, ord)
      left join lateral (
        select coalesce(p.display_name, p.first_name) as ad, p.avatar_url
        from public.profiles p
        where p.id = (elem.slot ->> 'user_id')::uuid
      ) pr on true
      left join lateral (
        select
          bool_or(f.status = 'accepted') as kabul,
          bool_or(f.user_id = auth.uid()) as giden,
          bool_or(f.friend_id = auth.uid()) as gelen
        from public.friend_requests f
        where (f.user_id = auth.uid() and f.friend_id = (elem.slot ->> 'user_id')::uuid)
           or (f.user_id = (elem.slot ->> 'user_id')::uuid and f.friend_id = auth.uid())
      ) fr on true
      left join lateral (
        select gi_slot.status
        from public.game_invites gi_slot
        where gi_slot.online_game_id = og.id
          and gi_slot.invitee_id = (elem.slot ->> 'user_id')::uuid
        order by gi_slot.created_at desc
        limit 1
      ) inv on true
    ) as slots,
    og.created_at,
    case when og.created_by = auth.uid() then 'creator' else 'invitee' end as my_role,
    mine.status as my_invite_status,
    mine.id as my_invite_id
  from public.online_games og
  left join lateral (
    select gi.id, gi.status
    from public.game_invites gi
    where gi.online_game_id = og.id and gi.invitee_id = auth.uid()
    order by gi.created_at desc
    limit 1
  ) mine on true
  where og.created_by = auth.uid()
     or exists (
       select 1 from public.game_invites gi2
       where gi2.online_game_id = og.id and gi2.invitee_id = auth.uid()
     )
  order by og.created_at desc;
$$;
