-- Kelimeki — Ölçüm v2: tek olay tablosu, tüm platformlar (`funnel_events`)
--
-- NEDEN VAR (24 Eylül 2026, kullanıcı kararı: *"Kendi tablomuz ve (a),
-- planı yaz. Ayrıca tabloda revisit de görmek istiyorum."*): Kaynak Hunisi
-- (`admin_source_funnel`) dört ayrı tablodan besleniyordu, her biri "kişi"yi
-- farklı tanımlıyordu, farklı tarihlerde başlamıştı ve mobili yarım
-- görüyordu. Aynı gün üç yama turundan sonra rakamlara hâlâ güvenilmiyordu.
-- Plan ve ölçülen hatalar: `docs/decisions/funnel-v2.md`.
--
-- ŞEKİL: KOHORT. Admin tablosunun bütün sütunları AYNI cihaz kümesini sayar
-- (pencerede `land` edenler), yani oranlar tanım gereği ≤ %100.
--
-- ⚠ HESAP KİMLİĞİ YOK: `user_id` kolonu bilerek yok. Gizlilik 6. bölüm:
-- anonim kod "hesabınızla asla eşleştirilmez".
-- ⚠ SAAT YOK, yalnızca GÜN (Europe/Istanbul): `signup` satırının saati
-- `profiles.created_at` ile eşleştirilebilseydi cihaz kodu hesaba
-- bağlanabilirdi. Aynı gerekçeyle birincil anahtar SIRALI DEĞİL (uuid):
-- artan bir sayı gün içindeki sırayı, dolayısıyla eşleştirmeyi geri getirirdi.
--
-- ⚠ OLAY / PLATFORM LİSTESİ İKİ YERDE: `log_funnel_event`in `v_events` /
-- `v_platforms` dizileri ↔ `src/utils/funnelEvents.ts` (`FUNNEL_EVENTS` /
-- `FUNNEL_PLATFORMS`). `npm run verify-funnel-events` karşılaştırır.
-- Port (PR 2) aynı adları web kaynağından okuyarak test edecek.

create table if not exists public.funnel_events (
  id          uuid primary key default gen_random_uuid (),
  -- Cihazda duran rastgele anonim kod (web: `kelimeki:anon-id`,
  -- uygulama: `FlagsStore.anonId()`).
  anon_id     uuid not null,
  platform    text not null check (platform in ('web', 'ios', 'android')),
  -- land        → cihazın İLK görülüşü (cihaz başına TEK satır)
  -- visit       → cihazın o gün açılışı (cihaz × gün başına TEK satır)
  -- signup      → bu cihazdan hesap açıldı
  -- game_start  → bu cihazdan oyun başladı
  -- game_finish → bu cihazdan oyun bitti
  event       text not null check (event in ('land', 'visit', 'signup', 'game_start', 'game_finish')),
  -- Kanal YALNIZCA `land` satırında durur (tek kaynak); öteki olaylar kanala
  -- `anon_id` üzerinden land satırından bağlanır. `mevcut` = ölçüm v2'den
  -- ÖNCE de bu cihazda iz vardı (eski kullanıcı) → rapor kohorttan çıkarır.
  channel     text check (
    (event = 'land' and channel is not null and char_length(channel) between 1 and 40)
    or (event <> 'land' and channel is null)
  ),
  day         date not null default ((now() at time zone 'Europe/Istanbul')::date),
  app_version text check (app_version is null or char_length(app_version) <= 32)
);

comment on table public.funnel_events is 'Ölçüm v2 (Huni v2) — cihaz başına anonim olaylar, tüm platformlar. user_id YOK, saat YOK (yalnızca Europe/Istanbul günü), sıralı anahtar YOK: kayıt bir hesapla eşleştirilemesin diye (bkz. migration başlığı ve docs/decisions/funnel-v2.md).';

create unique index if not exists funnel_events_land_uq
  on public.funnel_events (anon_id) where event = 'land';
create unique index if not exists funnel_events_visit_uq
  on public.funnel_events (anon_id, day) where event = 'visit';
create index if not exists funnel_events_anon_day_idx
  on public.funnel_events (anon_id, day);
create index if not exists funnel_events_event_day_idx
  on public.funnel_events (event, day);

-- İstemci tabloya DOĞRUDAN erişmez: yazma aşağıdaki security definer RPC'den,
-- okuma yalnızca admin RPC'sinden. RLS açık, politika YOK.
alter table public.funnel_events enable row level security;
revoke all on table public.funnel_events from anon, authenticated;
-- 30 Ekim 2026'dan sonra yeni tablolara otomatik grant gelmiyor (CLAUDE.md →
-- "Migration'lar"). İstemci rolleri bilerek dışarıda.
grant select, insert, update, delete on public.funnel_events to service_role;

-- ── İSTEMCİ: olay yaz ──────────────────────────────────────────────────────
-- Telemetri asla hata fırlatmaz: geçersiz girdi SESSİZCE yok sayılır.
--   land  → idempotent (cihaz başına tek satır; ikinci çağrı no-op)
--   visit → günde bir (cihaz × gün başına tek satır)
--   öteki → her çağrı bir satır. `land`ı olmayan cihazın olayı da kabul
--           edilir (sıra garantisi yok); raporda o cihaz kohortta olmadığı
--           için sayılmaz.
-- Taşma freni: cihaz başına günde 200 satırdan sonrası yazılmaz (anon
-- rolüne açık bir uç; tek bir kodla tabloyu şişirmek pahalı olmasın).
create or replace function public.log_funnel_event (
  p_anon_id     uuid,
  p_platform    text,
  p_event       text,
  p_channel     text default null,
  p_app_version text default null
)
  returns void
  language plpgsql
  security definer
  set search_path to 'public'
  as $function$
declare
  v_day constant date := (now() at time zone 'Europe/Istanbul')::date;
  v_events constant text[] := array['land', 'visit', 'signup', 'game_start', 'game_finish'];
  v_platforms constant text[] := array['web', 'ios', 'android'];
  v_channel text;
begin
  if p_anon_id is null
     or not coalesce(p_event = any (v_events), false)
     or not coalesce(p_platform = any (v_platforms), false) then
    return;
  end if;

  if (select count(*) from public.funnel_events f
       where f.anon_id = p_anon_id and f.day = v_day) >= 200 then
    return;
  end if;

  if p_event = 'land' then
    v_channel := coalesce(nullif(left(lower(btrim(p_channel)), 40), ''), 'bilinmiyor');
  end if;

  insert into public.funnel_events (anon_id, platform, event, channel, day, app_version)
  values (p_anon_id, p_platform, p_event, v_channel, v_day, nullif(left(btrim(p_app_version), 32), ''))
  on conflict do nothing;
end;
$function$;

revoke all on function public.log_funnel_event (uuid, text, text, text, text) from public;
grant execute on function public.log_funnel_event (uuid, text, text, text, text) to anon, authenticated, service_role;

-- ── ADMIN: Huni v2 ─────────────────────────────────────────────────────────
-- Kohort = son `p_days` günde (bugün dahil, Istanbul günü) `land` eden
-- cihazlar. (platform, kanal) başına bir satır:
--   land           = kohorttaki cihaz
--   returned       = land gününden SONRA en az bir başka gün açan ("2+ gün")
--   signed_up      = hesap açan
--   started        = en az bir oyun başlatan
--   finished       = en az bir oyun bitiren
--   games_started / games_finished = aynı cihazların oyun ADETLERİ
-- Olaylar pencere sonuna kadar izlenir (kohort takibi): 29 gün önce gelip
-- dün oynayan cihaz sayılır.
-- `mevcut` kanalı da satır olarak döner; istemci onu kohort TOPLAMINA katmaz,
-- yalnızca "eski cihaz" bilgisi olarak ayrı gösterir.
drop function if exists public.admin_funnel (integer, text);

create function public.admin_funnel (p_days integer default 30, p_platform text default null)
  returns table (
    platform       text,
    channel        text,
    land           bigint,
    returned       bigint,
    signed_up      bigint,
    started        bigint,
    finished       bigint,
    games_started  bigint,
    games_finished bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
#variable_conflict use_column
declare
  v_since constant date :=
    (now() at time zone 'Europe/Istanbul')::date - (greatest(coalesce(p_days, 30), 1) - 1);
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with c as (
    select l.anon_id, l.platform, l.channel, l.day
    from public.funnel_events l
    where l.event = 'land'
      and l.day >= v_since
      and (p_platform is null or l.platform = p_platform)
  ),
  e as (
    select c.anon_id,
           coalesce(bool_or(f.event = 'visit' and f.day > c.day), false) as ret,
           coalesce(bool_or(f.event = 'signup'), false)                    as su,
           count(f.anon_id) filter (where f.event = 'game_start')          as gs,
           count(f.anon_id) filter (where f.event = 'game_finish')         as gf
    from c
    left join public.funnel_events f
      on f.anon_id = c.anon_id and f.event <> 'land'
    group by c.anon_id
  )
  select c.platform,
         c.channel,
         count(*)::bigint,
         count(*) filter (where e.ret)::bigint,
         count(*) filter (where e.su)::bigint,
         count(*) filter (where e.gs > 0)::bigint,
         count(*) filter (where e.gf > 0)::bigint,
         coalesce(sum(e.gs), 0)::bigint,
         coalesce(sum(e.gf), 0)::bigint
  from c
  join e on e.anon_id = c.anon_id
  group by c.platform, c.channel
  order by count(*) desc, c.platform, c.channel;
end;
$function$;

revoke all on function public.admin_funnel (integer, text) from public, anon;
grant execute on function public.admin_funnel (integer, text) to authenticated, service_role;
