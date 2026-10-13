-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 8. list_random_games (şerit) ──────────────────────────────────────────
-- Yalnızca BAŞKALARININ, açık koltuğu kalmış, süresi dolmamış pending
-- listing='random' ilanları. Hariç: kendi ilanlarım, tarafı olduklarım,
-- oturan insanlardan birini sessize aldığım/şikayet ettiğim ilanlar.
-- Sıra: en yeni önce, eşitlikte id (kararlı). Kimlik yalnızca KURUCUNUN;
-- öteki koltuklar durum olarak döner:
--   seats[i] ∈ 'creator' | 'filled' (kabul etmiş insan) | 'invited'
--              (yanıt bekleyen arkadaş daveti) | 'ai' | 'open'
-- ⚠ offset sayfalaması yeni ilan eklendikçe kayar (tasarım §4: "kaydırılmış
--   şeride yeni ilan araya girmez") — istemci ikinci sayfada id ile tekilleştirmeli.

create or replace function public.list_random_games(p_limit int default 20, p_offset int default 0)
returns table (
  id uuid,
  player_count int,
  created_at timestamptz,
  creator_id uuid,
  creator_name text,
  creator_avatar_url text,
  seats jsonb,
  open_seats int
)
language sql
stable
security definer
set search_path = public
as $$
  select
    og.id,
    og.player_count,
    og.created_at,
    og.created_by,
    (select coalesce(p.display_name, p.first_name) from public.profiles p where p.id = og.created_by),
    (select p.avatar_url from public.profiles p where p.id = og.created_by),
    (
      select jsonb_agg(
        case
          when e.slot ->> 'type' = 'open' then 'open'
          when e.slot ->> 'type' = 'ai' then 'ai'
          when e.slot ->> 'user_id' = og.created_by::text then 'creator'
          when exists (
            select 1 from public.game_invites gi
            where gi.online_game_id = og.id
              and gi.invitee_id = (e.slot ->> 'user_id')::uuid
              and gi.status = 'accepted'
          ) then 'filled'
          else 'invited'
        end
        order by e.ord
      )
      from jsonb_array_elements(og.slots) with ordinality as e(slot, ord)
    ),
    public._slots_open_count(og.slots)
  from public.online_games og
  where auth.uid() is not null
    and og.listing = 'random'
    and og.status = 'pending'
    and now() - og.created_at <= interval '7 days'
    and og.created_by is not null
    and og.created_by <> auth.uid()
    and public._slots_open_count(og.slots) > 0
    and not public._random_is_party(og.id, og.slots, auth.uid())
    and not public._random_blocked(auth.uid(), og.slots)
  order by og.created_at desc, og.id desc
  limit least(greatest(coalesce(p_limit, 20), 1), 50)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

-- ── 9. list_my_random_games ("Bekliyor n/N") ──────────────────────────────
-- Benim açtığım ya da kabul ettiğim (accepted davet satırım olan) bekleyen
-- rastgele oyunlar. Süresi dolmuş ama henüz süpürülmemiş satırlar da döner
-- (expires_at ile) — istemci bugünkü gibi check_invite_expiry'yi tetikler.
-- slots, list_my_online_games ile aynı zenginleştirmeyi taşır (name,
-- avatar_url, relation, invite_status) — open koltuk OLDUĞU GİBİ {"type":"open"}.
-- Join YOK: her alan skaler/aggregate alt sorgudan (koltuk çoğalması dersi,
-- live-game.md 27 Ağustos 2026).
-- filled_seats: kurucu + kabul etmiş insanlar + YZ. my_role: 'creator' |
-- 'random' (rastgele koltukla katıldım) | 'friend' (arkadaş davetiyle).

create or replace function public.list_my_random_games()
returns table (
  id uuid,
  created_by uuid,
  player_count int,
  status text,
  created_at timestamptz,
  expires_at timestamptz,
  slots jsonb,
  filled_seats int,
  open_seats int,
  my_role text,
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
    og.created_at,
    og.created_at + interval '7 days',
    (
      select jsonb_agg(
        case
          when (elem.slot ->> 'type') = 'human' then
            elem.slot || jsonb_build_object(
              'name', (select coalesce(p.display_name, p.first_name)
                         from public.profiles p where p.id = (elem.slot ->> 'user_id')::uuid),
              'avatar_url', (select p.avatar_url
                               from public.profiles p where p.id = (elem.slot ->> 'user_id')::uuid),
              'relation', case
                when (elem.slot ->> 'user_id')::uuid = auth.uid() then 'self'
                when fr.kabul then 'accepted'
                when fr.giden then 'pending_outgoing'
                when fr.gelen then 'pending_incoming'
                else null
              end,
              'invite_status', (
                select gi_slot.status from public.game_invites gi_slot
                where gi_slot.online_game_id = og.id
                  and gi_slot.invitee_id = (elem.slot ->> 'user_id')::uuid
                order by gi_slot.created_at desc
                limit 1
              )
            )
          else elem.slot
        end
        order by elem.ord
      )
      from jsonb_array_elements(og.slots) with ordinality as elem(slot, ord)
      left join lateral (
        -- aggregate → her koltuk için TAM bir satır (çoğalma yok)
        select
          bool_or(f.status = 'accepted') as kabul,
          bool_or(f.user_id = auth.uid()) as giden,
          bool_or(f.friend_id = auth.uid()) as gelen
        from public.friend_requests f
        where (f.user_id = auth.uid() and f.friend_id = (elem.slot ->> 'user_id')::uuid)
           or (f.user_id = (elem.slot ->> 'user_id')::uuid and f.friend_id = auth.uid())
      ) fr on true
    ),
    (
      select count(*)::int
      from jsonb_array_elements(og.slots) as e(slot)
      where e.slot ->> 'type' = 'ai'
         or e.slot ->> 'user_id' = og.created_by::text
         or (e.slot ->> 'type' = 'human' and exists (
               select 1 from public.game_invites gi
               where gi.online_game_id = og.id
                 and gi.invitee_id = (e.slot ->> 'user_id')::uuid
                 and gi.status = 'accepted'))
    ),
    public._slots_open_count(og.slots),
    case
      when og.created_by = auth.uid() then 'creator'
      when og.slots @> jsonb_build_array(
             jsonb_build_object('user_id', auth.uid()::text, 'via', 'random')) then 'random'
      else 'friend'
    end,
    (select gi.id from public.game_invites gi
      where gi.online_game_id = og.id and gi.invitee_id = auth.uid()
      order by gi.created_at desc limit 1)
  from public.online_games og
  where auth.uid() is not null
    and og.listing = 'random'
    and og.status = 'pending'
    and (
      og.created_by = auth.uid()
      or exists (
        select 1 from public.game_invites gi2
        where gi2.online_game_id = og.id
          and gi2.invitee_id = auth.uid()
          and gi2.status = 'accepted'
      )
    )
  order by og.created_at desc, og.id desc;
$$;

revoke all on function public.list_random_games(int, int) from public, anon;
revoke all on function public.list_my_random_games() from public, anon;
grant execute on function public.list_random_games(int, int) to authenticated;
grant execute on function public.list_my_random_games() to authenticated;
