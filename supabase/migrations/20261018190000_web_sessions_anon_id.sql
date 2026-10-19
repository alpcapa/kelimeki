-- Kelimeki — `web_sessions`e anonim cihaz kodu (`anon_id`) + admin Huni v2 "Mağaza (cihaz)".
--
-- NEDEN (18 Ekim 2026, kullanıcı: Admin Huni v2'de Instagram satırı 18 land /
-- 41 mağaza gösterdi): "Mağaza" sütunu `web_sessions` OTURUMU sayıyor, "Land"
-- ise kanalı İLK DOKUNUŞTA donan CİHAZI sayıyor. `web_sessions`te cihaz kodu
-- olmadığından oturum land kohortuna bağlanamıyor → mağaza ÷ land oran
-- olarak okunamıyor (aynı kişi üç günde üç kez mağazaya gidebilir, land'de
-- bir kez görünür; ilk dokunuşu başka kanal olan kişi Instagram bağlantısıyla
-- dönünce kendi land'i başka satırdadır). Okuma ve sayılar:
-- `docs/decisions/funnel-v2.md` → "Okuma: Instagram satırı 18 land / 41 mağaza".
-- Karar kaydı: ROADMAP #47.
--
-- DEĞİŞEN:
--   1. `web_sessions.anon_id uuid` (nullable; ESKİ satırlar null kalır).
--   2. `record_web_session` 9. parametre `p_anon_id uuid default null` →
--      İMZA DEĞİŞTİ: eski 8 parametreli imza DROP (create or replace YETMEZ,
--      iki imza yan yana kalır ve çağrı "function is not unique" 42725 verir).
--      `anon_id` yalnızca İLK yazımda atanır (`coalesce`); sonraki pingler
--      onu değiştirmez. Eski istemci (9. parametreyi hiç göndermeyen önbellekli
--      paket) varsayılan null ile çalışmaya devam eder.
--   3. `admin_funnel` dönüşüne `store_devices` (DROP + CREATE): pencerede
--      land eden cihazlardan, o pencerede `store` adımlı bir `web_sessions`
--      oturumu OLANLARIN sayısı — yani kohort cihazı, taban Land'e göre oran
--      ARTIK ≤ %100. Eski `store` (oturum, `utm_source` üzerinden) AYNEN
--      duruyor; `anon_id`siz geçmiş oturumlar yalnızca onda görünür.
--
-- ⚠ GİZLİLİK: Gizlilik metni anonim kodun sunucuya gittiği durumları SAYIYOR
-- (yedi madde). `web_sessions` 23 Eylül 2026'dan beri bilerek KİMLİKSİZDİ
-- (*"Gizlilik metnine dokunmadan başla"*); bu migration o kararı DEĞİŞTİRİR:
-- misafir ziyaretçinin yolculuk adımları (karşılamada ayrıldı, mağazaya gitti…)
-- artık aynı anonim kodla birlikte tutulur → SEKİZİNCİ durum, metin ve
-- portun kopyası (`legal_modals.dart`) AYNI turda güncellenmeli. İstemci
-- (`webJourney.ts`) metin yayına girmeden `anon_id` GÖNDERMEMELİ — bu dosyanın
-- kendisi zararsız (sütun/parametre isteğe bağlı) ama canlıya uygulanması
-- istemci+metin teslimiyle koordine edilir.
-- ⚠ Hesap kimliği YOK, `user_id` yok: girişli oturum zaten hiç yazılmaz.
--
-- Grant'ler öncesiyle aynı: `record_web_session` → anon + authenticated +
-- service_role; `admin_funnel` → authenticated + service_role (anon YOK).
-- `proacl` merge ÖNCESİ/SONRASI karşılaştırıldı (CLAUDE.md → RPC dönüş tipi).

alter table public.web_sessions add column if not exists anon_id uuid;

comment on column public.web_sessions.anon_id is 'Cihazdaki kalıcı anonim kod (funnel_events.anon_id ile AYNI) — 18 Ekim 2026''dan beri; eski satırlarda null. Yalnızca ilk yazımda atanır. Hesap kimliği değildir.';

create index if not exists web_sessions_anon_id_idx
  on public.web_sessions (anon_id) where anon_id is not null;

-- ── İSTEMCİ ────────────────────────────────────────────────────────────────
drop function if exists public.record_web_session (uuid, text, text, text, text, integer, integer, integer);

create function public.record_web_session (
  p_id          uuid,
  p_entry       text,
  p_step        text default null,
  p_device_type text default null,
  p_utm_source  text default null,
  p_moves       integer default null,
  p_seconds     integer default null,
  p_scroll_pct  integer default null,
  p_anon_id     uuid default null
)
  returns void
  language plpgsql
  security definer
  set search_path to 'public'
  as $function$
declare
  v_steps constant text[] := array[
    'landing', 'landing_cta', 'app', 'tutorial_start', 'tutorial_done',
    'game_start', 'first_move', 'move_5', 'game_finish',
    'signup_form', 'signup_done', 'login', 'store'
  ];
begin
  if p_id is null or p_entry is null or p_entry not in ('landing', 'app') then
    return;
  end if;
  if p_step is not null and not (p_step = any (v_steps)) then
    return;
  end if;

  insert into public.web_sessions as w
    (id, entry, device_type, utm_source, steps, last_step, moves, seconds, scroll_pct, anon_id)
  values (
    p_id,
    p_entry,
    case when p_device_type in ('ios', 'android', 'desktop') then p_device_type end,
    left(p_utm_source, 64),
    case when p_step is null then '{}'::text[] else array[p_step] end,
    p_step,
    least(greatest(coalesce(p_moves, 0), 0), 1000),
    least(greatest(coalesce(p_seconds, 0), 0), 86400),
    case when p_scroll_pct is not null then least(greatest(p_scroll_pct, 0), 100) end,
    p_anon_id
  )
  on conflict (id) do update set
    steps = case
      when excluded.last_step is null or excluded.last_step = any (w.steps) then w.steps
      else w.steps || excluded.last_step
    end,
    last_step  = coalesce(excluded.last_step, w.last_step),
    moves      = greatest(w.moves, excluded.moves),
    seconds    = greatest(w.seconds, excluded.seconds),
    scroll_pct = greatest(w.scroll_pct, excluded.scroll_pct),
    -- Kod yalnızca İLK yazımda atanır; sonraki ping (farklı bir kodla bile)
    -- oturumun cihazını DEĞİŞTİRMEZ.
    anon_id    = coalesce(w.anon_id, excluded.anon_id),
    updated_at = now()
  where w.created_at > now() - interval '1 day';
end;
$function$;

revoke all on function public.record_web_session (uuid, text, text, text, text, integer, integer, integer, uuid) from public;
grant execute on function public.record_web_session (uuid, text, text, text, text, integer, integer, integer, uuid) to anon, authenticated, service_role;

-- ── ADMİN: Huni v2 ─────────────────────────────────────────────────────────
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
    games_finished bigint,
    store          bigint,
    store_devices  bigint
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
  -- Mağazaya giden CİHAZLAR: `anon_id`li oturumlar (18 Ekim 2026'dan beri).
  sd as (
    select distinct ws.anon_id
    from public.web_sessions ws
    where ws.anon_id is not null
      and ws.created_at >= (v_since::timestamp at time zone 'Europe/Istanbul')
      and 'store' = any (ws.steps)
  ),
  e as (
    select c.anon_id,
           coalesce(bool_or(f.event = 'visit' and f.day > c.day), false) as ret,
           coalesce(bool_or(f.event = 'signup'), false)                    as su,
           count(f.anon_id) filter (where f.event = 'game_start')          as gs,
           count(f.anon_id) filter (where f.event = 'game_finish')         as gf,
           (c.anon_id in (select s.anon_id from sd s))                     as st
    from c
    left join public.funnel_events f
      on f.anon_id = c.anon_id and f.event <> 'land'
    group by c.anon_id
  ),
  m as (
    select coalesce(nullif(lower(btrim(ws.utm_source)), ''), 'direkt') as ch,
           count(*)::bigint as n
    from public.web_sessions ws
    where ws.created_at >= (v_since::timestamp at time zone 'Europe/Istanbul')
      and 'store' = any (ws.steps)
    group by 1
  )
  select c.platform,
         c.channel,
         count(*)::bigint,
         count(*) filter (where e.ret)::bigint,
         count(*) filter (where e.su)::bigint,
         count(*) filter (where e.gs > 0)::bigint,
         count(*) filter (where e.gf > 0)::bigint,
         coalesce(sum(e.gs), 0)::bigint,
         coalesce(sum(e.gf), 0)::bigint,
         coalesce(max(m.n), 0)::bigint,
         count(*) filter (where e.st)::bigint
  from c
  join e on e.anon_id = c.anon_id
  left join m on c.platform = 'web' and m.ch = c.channel
  group by c.platform, c.channel
  order by count(*) desc, c.platform, c.channel;
end;
$function$;

revoke all on function public.admin_funnel (integer, text) from public, anon;
grant execute on function public.admin_funnel (integer, text) to authenticated, service_role;
