-- ═══════════════════════════════════════════════════════════════════════════
-- Rastgele Oyuncu — açık ilanla yabancıyla 2/4 kişilik Canlı oyun (ROADMAP #45)
-- Tasarım: docs/decisions/random-opponent.md (§6 sunucu etkisi, §8-9 kararlar)
--
-- ⚠ ZAMAN DAMGASI YER TUTUCU: canlıya uygulandıktan sonra `list_migrations`
--   ile gerçek versiyonu oku ve dosyayı `git mv` ile yeniden adlandır.
--
-- NE DEĞİŞİR
--   1. online_games.listing (text null, 'random'|'team'; NULL = bugünkü oyunlar)
--      + slots içinde yeni koltuk türü {"type":"open"}.
--   2. Koruma tetikleyicisi: açık koltuklu oyun ASLA 'active' olamaz; listing
--      ve açık koltuk yalnızca bu dosyadaki RPC'lerden yazılabilir (RLS'in
--      `online_games_insert_self` / `online_games_update_creator` politikaları
--      kurucuya doğrudan PostgREST yazımı izni veriyor — kapı onu kapatır).
--   3. Yeni RPC'ler (yalnızca authenticated): create_random_game,
--      accept_random_game, leave_random_game, cancel_random_game,
--      list_random_games, list_my_random_games.
--   4. respond_to_game_invite: İMZA AYNI (create or replace, proacl korunur);
--      oyun kilidi ÖNCE alınır ve "açık koltuk kalmadı" şartı eklenir.
--   5. list_my_online_games: İMZA VE DÖNÜŞ TİPİ AYNI (create or replace);
--      eski istemci koruması — {"type":"open"} koltuğu {"type":"ai","open":true}
--      olarak GÖSTERİLİR (eski web/Dart ayrıştırıcıları "ai"yi tanıyor).
--
-- NE DEĞİŞMEZ
--   create_online_game, check_invite_expiry (listing'den bağımsız: 7 gün dolan
--   pending oyunu zaten 'abandoned' yapıyor, rastgele kabul eden de davet satırı
--   taşıdığı için "taraf" sayılıyor), init_online_game_state, submit_move,
--   _km_*, _finish_online_game_records. Motor DOKUNULMAZ; oyun dolunca bugünkü
--   2/4 kişilik Canlı oyunun aynısı olarak başlar.
--   Yeni TABLO yok → grant işi yok.
--
-- KABUL EDEN İÇİN DAVET SATIRI
--   Rastgele kabul eden kişiye game_invites'ta status='accepted' satırı yazılır.
--   Böylece is_online_game_participant, online_games/online_game_states RLS'i,
--   play-ai-turn (kullanıcı istemcisiyle online_games okuyor), check_invite_expiry
--   ve list_my_online_games onu HİÇBİR DEĞİŞİKLİK olmadan normal katılımcı sayar.
--   Koltuğuna ayrıca "via":"random" işareti konur: leave_random_game yalnızca bu
--   koltukları boşaltır (kurucunun seçtiği arkadaş koltuğu yabancı koltuğa
--   dönüşemez) ve 3'lük sınır bu işaretle sayılır. Eski ayrıştırıcılar fazladan
--   anahtarı yok sayar (TS tip birleşimi, Dart OnlineSlot.fromJson).
--
-- GERİ ALMA (sıra önemli)
--   a) Açık koltuğu kalmış rastgele ilanları kapat (yoksa eski
--      init_online_game_state 'open'ı YZ sanar):
--        update public.online_games set status='abandoned', updated_at=now()
--        where listing is not null and status='pending';
--   b) drop function public.create_random_game(int, jsonb), public.accept_random_game(uuid),
--        public.leave_random_game(uuid), public.cancel_random_game(uuid),
--        public.list_random_games(int, int), public.list_my_random_games(),
--        public._random_take_seat(uuid, uuid), public._random_preflight(uuid),
--        public._random_is_party(uuid, jsonb, uuid), public._random_blocked(uuid, jsonb),
--        public._slots_open_count(jsonb);
--   c) drop trigger online_games_random_guard on public.online_games;
--      drop function public._online_games_random_guard();
--   d) respond_to_game_invite ve list_my_online_games'i önceki gövdelerine döndür
--      (20260803132047_decline_game_invite_abandons_game.sql ve
--       20260905130907_list_my_online_games_lateral.sql — 3 Ekim 2026'da canlıyla
--       karşılaştırıldı, aynı). İkisi de create or replace → proacl korunur.
--   e) (isteğe bağlı) alter table public.online_games drop column listing;
-- ═══════════════════════════════════════════════════════════════════════════


-- ── 1. Şema ────────────────────────────────────────────────────────────────

alter table public.online_games add column if not exists listing text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.online_games'::regclass
      and conname = 'online_games_listing_check'
  ) then
    alter table public.online_games
      add constraint online_games_listing_check
      check (listing is null or listing in ('random', 'team'));
  end if;
end $$;

comment on column public.online_games.listing is
  'Açık ilan türü: NULL = arkadaş daveti (bugünkü oyun), random = Rastgele Oyuncu '
  '(random-opponent.md), team = Takım Ligi (team-league.md). Açık koltuk: '
  'slots içinde {"type":"open"}; yalnızca create/accept/leave_random_game yazar.';

-- Şerit sorgusu (list_random_games) ve "önce var olan ilana katıl" araması.
create index if not exists online_games_open_listing_idx
  on public.online_games (listing, player_count, created_at desc)
  where status = 'pending' and listing is not null;


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

drop trigger if exists online_games_random_guard on public.online_games;
create trigger online_games_random_guard
  before insert or update on public.online_games
  for each row execute function public._online_games_random_guard();


-- ── 4. create_random_game ─────────────────────────────────────────────────
-- p_slots: create_online_game ile aynı biçim + {"type":"open"}.
--   koltuk 0 : çağıranın kendisi (human)
--   2 kişilik: koltuk 1 = arkadaş | open
--   4 kişilik: koltuk 1,2 = arkadaş | open ; koltuk 3 = arkadaş | open | ai
--   En az bir koltuk open olmalı (yoksa create_online_game kullanılır).
-- Kadro YALNIZCA açık koltuklardan oluşuyorsa (arkadaş yok, YZ yok) ve aynı
-- oyuncu sayısında uygun bir başkası ilanı varsa, yeni ilan açmak yerine onu
-- atomik kabul eder (öneri §9.1). Seçim: EN ESKİ uygun ilan (en uzun bekleyen
-- önce dolar), kilitli olanlar atlanır (skip locked).
-- Dönüş: {"joined": bool, "game_id": uuid, "started": bool[, "seat": int]}
-- ⚠ Arkadaş koltuğu varsa istemci, mevcut notify-game-invite'ı çağırmalı
--   (kurucu çağırır, yalnızca pending davetlilere gider — bugünkü akış).

create or replace function public.create_random_game(p_player_count int, p_slots jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_slot jsonb;
  v_type text;
  v_user uuid;
  v_seen uuid[] := array[]::uuid[];
  v_clean jsonb := '[]'::jsonb;
  v_open int := 0;
  v_friends int := 0;
  v_ai int := 0;
  v_target uuid;
  v_game_id uuid;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;
  if p_player_count is null or p_player_count not in (2, 4) then
    raise exception 'Geçersiz oyuncu sayısı.';
  end if;
  if p_slots is null or jsonb_typeof(p_slots) <> 'array'
     or jsonb_array_length(p_slots) <> p_player_count then
    raise exception 'Koltuk sayısı oyuncu sayısıyla eşleşmiyor.';
  end if;

  v_slot := p_slots -> 0;
  if (v_slot ->> 'type') is distinct from 'human'
     or (v_slot ->> 'user_id') is distinct from v_uid::text then
    raise exception 'İlk koltuk oyunu kuran kişi olmalı.';
  end if;
  v_seen := array[v_uid];
  v_clean := jsonb_build_array(jsonb_build_object('type', 'human', 'user_id', v_uid));

  for i in 1 .. p_player_count - 1 loop
    v_slot := p_slots -> i;
    v_type := v_slot ->> 'type';

    if v_type = 'open' then
      v_open := v_open + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'open'));

    elsif v_type = 'ai' then
      if not (p_player_count = 4 and i = 3) then
        raise exception 'Yapay Zeka yalnızca 4 kişilik oyunun son koltuğunda olabilir.';
      end if;
      v_ai := v_ai + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'ai'));

    elsif v_type = 'human' then
      begin
        v_user := (v_slot ->> 'user_id')::uuid;
      exception when others then
        raise exception 'İnsan koltuğunda user_id eksik.';
      end;
      if v_user is null then
        raise exception 'İnsan koltuğunda user_id eksik.';
      end if;
      if v_user = any (v_seen) then
        raise exception 'Aynı kullanıcı birden fazla koltukta olamaz.';
      end if;
      if not exists (
        select 1 from public.friend_requests fr
        where fr.status = 'accepted'
          and ((fr.user_id = v_uid and fr.friend_id = v_user)
            or (fr.user_id = v_user and fr.friend_id = v_uid))
      ) then
        raise exception 'Yalnızca arkadaşlarını davet edebilirsin.';
      end if;
      v_seen := v_seen || v_user;
      v_friends := v_friends + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'human', 'user_id', v_user));

    else
      raise exception 'Geçersiz koltuk türü.';
    end if;
  end loop;

  if v_open = 0 then
    raise exception 'En az bir koltuk Rastgele Oyuncu olmalı.';
  end if;

  perform public._random_preflight(v_uid);

  -- Önce var olan ilana katıl (yalnızca saf rastgele kadroda).
  if v_friends = 0 and v_ai = 0 then
    select og.id into v_target
    from public.online_games og
    where og.listing = 'random'
      and og.status = 'pending'
      and og.player_count = p_player_count
      and now() - og.created_at <= interval '7 days'
      and og.created_by is not null
      and og.created_by <> v_uid
      and public._slots_open_count(og.slots) > 0
      and not public._random_is_party(og.id, og.slots, v_uid)
      and not public._random_blocked(v_uid, og.slots)
    order by og.created_at asc, og.id asc
    limit 1
    for update skip locked;

    if v_target is not null then
      return public._random_take_seat(v_target, v_uid)
             || jsonb_build_object('joined', true);
    end if;
  end if;

  perform set_config('kelimeki.random_rpc', 'on', true);
  insert into public.online_games (created_by, player_count, slots, listing)
  values (v_uid, p_player_count, v_clean, 'random')
  returning id into v_game_id;
  perform set_config('kelimeki.random_rpc', '', true);

  for i in 1 .. p_player_count - 1 loop
    v_slot := v_clean -> i;
    if v_slot ->> 'type' = 'human' then
      insert into public.game_invites (online_game_id, invitee_id)
      values (v_game_id, (v_slot ->> 'user_id')::uuid);
    end if;
  end loop;

  return jsonb_build_object('joined', false, 'game_id', v_game_id, 'started', false);
end;
$$;


-- ── 5. accept_random_game ─────────────────────────────────────────────────
-- Şeritteki "Kabul". `for update` kilidi: iki eşzamanlı kabulde ikincisi
-- birincinin işlemi bitene dek bekler, sonra güncel satırı görür; son koltuk
-- gittiyse "Bu oyun doldu." alır.
-- Dönüş: {"joined": true, "game_id": uuid, "seat": int, "started": bool}

create or replace function public.accept_random_game(p_game_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  perform public._random_preflight(v_uid);

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.status = 'active' or v_game.status = 'finished' then
    raise exception 'Bu oyun doldu.';
  end if;
  if v_game.status <> 'pending' or now() - v_game.created_at > interval '7 days' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;
  if v_game.created_by = v_uid then
    raise exception 'Kendi ilanını kabul edemezsin.';
  end if;
  if public._random_is_party(p_game_id, v_game.slots, v_uid) then
    raise exception 'Bu oyuna zaten katıldın.';
  end if;
  if public._random_blocked(v_uid, v_game.slots) then
    raise exception 'Bu ilana katılamazsın.';
  end if;
  if public._slots_open_count(v_game.slots) = 0 then
    raise exception 'Bu oyun doldu.';
  end if;

  return public._random_take_seat(p_game_id, v_uid) || jsonb_build_object('joined', true);
end;
$$;


-- ── 6. leave_random_game ──────────────────────────────────────────────────
-- Rastgele koltukla kabul eden, oyun dolmadan ayrılır: koltuk yeniden open,
-- davet satırı SİLİNİR (yoksa is_online_game_participant onu katılımcı sayar),
-- ceza yok. Kurucu ayrılamaz (cancel_random_game); arkadaş davetlisi
-- ayrılamaz (onun koltuğu kurucunun seçimi; bugünkü ret yolu geçerli).

create or replace function public.leave_random_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
  v_idx int;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.created_by = v_uid then
    raise exception 'İlanı açan ayrılamaz; ilanı iptal edebilirsin.';
  end if;
  if v_game.status = 'active' then
    raise exception 'Oyun başladı; artık ayrılamazsın.';
  end if;
  if v_game.status <> 'pending' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;

  select (e.ord - 1)::int into v_idx
  from jsonb_array_elements(v_game.slots) with ordinality as e(slot, ord)
  where e.slot ->> 'user_id' = v_uid::text
    and e.slot ->> 'via' = 'random'
  limit 1;

  if v_idx is null then
    raise exception 'Bu ilandan ayrılamazsın.';
  end if;

  perform set_config('kelimeki.random_rpc', 'on', true);
  update public.online_games
     set slots = jsonb_set(slots, array[v_idx::text], jsonb_build_object('type', 'open')),
         updated_at = now()
   where id = p_game_id;
  perform set_config('kelimeki.random_rpc', '', true);

  delete from public.game_invites
   where online_game_id = p_game_id and invitee_id = v_uid;
end;
$$;


-- ── 7. cancel_random_game ─────────────────────────────────────────────────
-- Kurucu bekleyen ilanını iptal eder → 'abandoned' (check_invite_expiry ve
-- ret dalıyla AYNI son durum; davet satırları kayıt olarak kalır).

create or replace function public.cancel_random_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.created_by is distinct from v_uid then
    raise exception 'Yalnızca ilanı açan iptal edebilir.';
  end if;
  if v_game.status = 'active' then
    raise exception 'Oyun başladı; ilan iptal edilemez.';
  end if;
  if v_game.status <> 'pending' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;

  update public.online_games
     set status = 'abandoned', updated_at = now()
   where id = p_game_id and status = 'pending';
end;
$$;


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


-- ── 10. Yeni RPC'lerin yetkileri: YALNIZCA authenticated ─────────────────
-- Supabase varsayılan yetkileri yeni fonksiyona anon'a da DOĞRUDAN execute
-- verir; `revoke ... from public` onu düşürmez → anon AÇIKÇA revoke edilir.

revoke all on function public.create_random_game(int, jsonb) from public, anon;
revoke all on function public.accept_random_game(uuid) from public, anon;
revoke all on function public.leave_random_game(uuid) from public, anon;
revoke all on function public.cancel_random_game(uuid) from public, anon;
revoke all on function public.list_random_games(int, int) from public, anon;
revoke all on function public.list_my_random_games() from public, anon;

grant execute on function public.create_random_game(int, jsonb) to authenticated;
grant execute on function public.accept_random_game(uuid) to authenticated;
grant execute on function public.leave_random_game(uuid) to authenticated;
grant execute on function public.cancel_random_game(uuid) to authenticated;
grant execute on function public.list_random_games(int, int) to authenticated;
grant execute on function public.list_my_random_games() to authenticated;


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
