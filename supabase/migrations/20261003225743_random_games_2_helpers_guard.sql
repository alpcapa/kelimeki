-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 2. Yardımcılar (istemciye KAPALI) ─────────────────────────────────────

create or replace function public._slots_open_count(p_slots jsonb)
returns int
language sql
immutable
set search_path = public
as $$
  select count(*)::int
  from jsonb_array_elements(coalesce(p_slots, '[]'::jsonb)) as e(slot)
  where e.slot ->> 'type' = 'open';
$$;

-- Çağıran bu oyunun tarafı mı? (koltukta oturuyor ya da HERHANGİ durumda davet
-- satırı var — reddetmiş bir arkadaş aynı oyuna yabancı olarak geri giremez).
create or replace function public._random_is_party(p_game_id uuid, p_slots jsonb, p_uid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
      select 1 from jsonb_array_elements(p_slots) as e(slot)
      where e.slot ->> 'user_id' = p_uid::text
    )
    or exists (
      select 1 from public.game_invites gi
      where gi.online_game_id = p_game_id and gi.invitee_id = p_uid
    );
$$;

-- Çağıran, ilandaki oturan insanlardan birini sessize almış ya da (geri
-- çekilmemiş) şikayet etmiş mi? Moderasyon KİŞİ bazlı (chat-moderation.md,
-- 3 Ağustos 2026): satırın online_game_id'si yalnızca provenance, bakılmaz.
create or replace function public._random_blocked(p_uid uuid, p_slots jsonb)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from jsonb_array_elements(p_slots) as e(slot)
    where e.slot ->> 'type' = 'human'
      and (
        exists (
          select 1 from public.online_game_message_mutes m
          where m.muter_user_id = p_uid
            and m.muted_user_id = (e.slot ->> 'user_id')::uuid
        )
        or exists (
          select 1 from public.online_game_chat_reports r
          where r.reporter_user_id = p_uid
            and r.reported_user_id = (e.slot ->> 'user_id')::uuid
            and r.withdrawn_at is null
        )
      )
  );
$$;

-- Açma/kabul ön kontrolü: (1) kapı — en az 1 BİTMİŞ oyun, (2) kişi başına
-- seri hâle getirme kilidi, (3) çağıranın süresi dolmuş KENDİ ilanlarını
-- süpür, (4) eşzamanlı rastgele sınırı (açtığım + rastgele koltukla kabul
-- edip beklediğim) < 3.
--
-- Kapı ölçütü: public.games (user_id = çağıran). Gerekçe: hesap bağlı tek
-- kalıcı oyun kaydı (yerel YZ + Canlı, k-lig/istatistik aynı tablodan);
-- game_finishes bir telemetri tablosu (anonim satır da alıyor).
-- ⚠ İkisi de istemciden yazılabilir (games_insert_self) → kapı YUMUŞAK bir
-- spam freni, güvenlik sınırı değil.
create or replace function public._random_preflight(p_uid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_open_count int;
begin
  if not exists (select 1 from public.games g where g.user_id = p_uid) then
    raise exception 'Rastgele oyun için önce en az bir oyunu bitirmelisin.';
  end if;

  -- Aynı kullanıcının iki eşzamanlı çağrısı sınırı birlikte aşamasın.
  perform pg_advisory_xact_lock(hashtextextended('kelimeki_random:' || p_uid::text, 0));

  -- Süresi dolmuş kendi ilanlarım (check_invite_expiry ile AYNI kural: 7 gün,
  -- 'abandoned', davet satırlarına dokunulmaz). Kimse uygulamayı açmasa bile
  -- sınırın bayat ilanla dolu kalmaması için.
  update public.online_games
     set status = 'abandoned', updated_at = now()
   where created_by = p_uid
     and listing = 'random'
     and status = 'pending'
     and now() - created_at > interval '7 days';

  select count(*) into v_open_count
  from public.online_games og
  where og.listing = 'random'
    and og.status = 'pending'
    and now() - og.created_at <= interval '7 days'
    and (
      og.created_by = p_uid
      or og.slots @> jsonb_build_array(
           jsonb_build_object('user_id', p_uid::text, 'via', 'random'))
    );

  if v_open_count >= 3 then
    raise exception 'Rastgele oyunların dolu (en çok 3). Biri başlayınca ya da iptal edince yenisini açabilirsin.';
  end if;
end;
$$;

-- Kilitli bir ilanda İLK açık koltuğa oturt. Çağıran satırı `for update` ile
-- KİLİTLEMİŞ olmalı. Son koltuk dolduysa VE bekleyen arkadaş daveti yoksa
-- oyunu başlatır (iki koşul birlikte — başlatma koruması).
create or replace function public._random_take_seat(p_game_id uuid, p_uid uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_slots jsonb;
  v_idx int;
  v_pending int;
  v_started boolean := false;
begin
  select og.slots into v_slots from public.online_games og where og.id = p_game_id;

  select (e.ord - 1)::int into v_idx
  from jsonb_array_elements(v_slots) with ordinality as e(slot, ord)
  where e.slot ->> 'type' = 'open'
  order by e.ord
  limit 1;

  if v_idx is null then
    raise exception 'Bu oyun doldu.';
  end if;

  v_slots := jsonb_set(
    v_slots,
    array[v_idx::text],
    jsonb_build_object('type', 'human', 'user_id', p_uid, 'via', 'random')
  );

  perform set_config('kelimeki.random_rpc', 'on', true);
  update public.online_games
     set slots = v_slots, updated_at = now()
   where id = p_game_id;

  insert into public.game_invites (online_game_id, invitee_id, status, responded_at)
  values (p_game_id, p_uid, 'accepted', now());

  if public._slots_open_count(v_slots) = 0 then
    select count(*) into v_pending
    from public.game_invites
    where online_game_id = p_game_id and status = 'pending';

    if v_pending = 0 then
      update public.online_games
         set status = 'active', updated_at = now()
       where id = p_game_id and status = 'pending';
      if found then
        perform public.init_online_game_state(p_game_id);
        v_started := true;
      end if;
    end if;
  end if;
  perform set_config('kelimeki.random_rpc', '', true);

  return jsonb_build_object('game_id', p_game_id, 'seat', v_idx, 'started', v_started);
end;
$$;

revoke all on function public._slots_open_count(jsonb) from public, anon, authenticated;
revoke all on function public._random_is_party(uuid, jsonb, uuid) from public, anon, authenticated;
revoke all on function public._random_blocked(uuid, jsonb) from public, anon, authenticated;
revoke all on function public._random_preflight(uuid) from public, anon, authenticated;
revoke all on function public._random_take_seat(uuid, uuid) from public, anon, authenticated;

-- ── 3. Koruma tetikleyicisi ────────────────────────────────────────────────
-- (a) Açık koltuklu oyun HİÇBİR yoldan 'active' olamaz — init_online_game_state
--     'human' olmayan her koltuğu YZ sayıyor, yani açık koltuk sessizce YZ'ye
--     dönüşürdü. Bu kural RPC bayrağından bağımsız, HER yazımda geçerli.
-- (b) listing ve açık koltuk yalnızca bu dosyanın RPC'lerinden yazılır
--     (işlem-yerel `kelimeki.random_rpc` bayrağı). PostgREST istemcisi bu
--     ayarı kuramaz (set_config açık bir şemada değil).
--     Mevcut (listing NULL) oyunlarda davranış AYNI: yalnızca listing'e ya da
--     listing'li bir oyunun slots'una dokunan yazım denetlenir.
-- Yardımcı fonksiyon çağrılmıyor: tetikleyici, çağıranın (authenticated)
-- haklarıyla koşabilir ve yardımcılar ona kapalı.

create or replace function public._online_games_random_guard()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_rpc boolean := coalesce(current_setting('kelimeki.random_rpc', true), '') = 'on';
  v_new_open boolean := jsonb_path_exists(new.slots, '$[*] ? (@.type == "open")');
begin
  if new.status = 'active' and v_new_open then
    raise exception 'Açık koltuğu olan oyun başlatılamaz.';
  end if;

  if tg_op = 'INSERT' then
    if (new.listing is not null or v_new_open) and not v_rpc then
      raise exception 'Açık ilan yalnızca uygulama üzerinden açılabilir.';
    end if;
  else
    if not v_rpc and (
      new.listing is distinct from old.listing
      or (coalesce(old.listing, new.listing) is not null
          and new.slots is distinct from old.slots)
      or (v_new_open and new.slots is distinct from old.slots)
    ) then
      raise exception 'Açık ilan yalnızca uygulama üzerinden değiştirilebilir.';
    end if;
  end if;

  return new;
end;
$$;

revoke all on function public._online_games_random_guard() from public, anon, authenticated;

create or replace trigger online_games_random_guard
  before insert or update on public.online_games
  for each row execute function public._online_games_random_guard();
