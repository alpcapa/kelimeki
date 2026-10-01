-- Kelimeki — ziyaretçi yolculuğuna `store` adımı: mağaza rozetine/şeridine dokundu.
--
-- NEDEN (28 Eylül 2026): Meta reklamı Trafik kampanyasında mağaza linkine
-- izin vermiyor (#1487810), reklam bu yüzden `kelimeki.com/?ref=meta-…`e
-- gidiyor ve mağazaya sitedeki rozetten geçiliyor. Bu adım olmadan "reklamdan
-- gelen kaç kişi mağazaya gitti" sorusunun cevabı hiçbir tabloda yoktu.
-- Kampanya planı: `marketing/meta-reklam/kampanya-ekim-2026.md`.
--
-- DEĞİŞEN TEK ŞEY iki fonksiyondaki `v_steps` dizisi: sona `store` eklendi.
-- Gövdeler canlıdaki tanımdan (`pg_get_functiondef`, 28 Eylül 2026) birebir
-- alındı; imza ve dönüş tipi aynı olduğu için `create or replace` yeterli,
-- grant'ler ve `security definer` korunuyor (drop YOK).
--
-- ⚠ Adım listesi `src/utils/webJourney.ts` → `JOURNEY_STEPS` ile BİREBİR
-- aynı kalmalı; `npm run verify-web-journey` bu dosyayı okur (iki dizi).

create or replace function public.record_web_session (
  p_id          uuid,
  p_entry       text,
  p_step        text default null,
  p_device_type text default null,
  p_utm_source  text default null,
  p_moves       integer default null,
  p_seconds     integer default null,
  p_scroll_pct  integer default null
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
    (id, entry, device_type, utm_source, steps, last_step, moves, seconds, scroll_pct)
  values (
    p_id,
    p_entry,
    case when p_device_type in ('ios', 'android', 'desktop') then p_device_type end,
    left(p_utm_source, 64),
    case when p_step is null then '{}'::text[] else array[p_step] end,
    p_step,
    least(greatest(coalesce(p_moves, 0), 0), 1000),
    least(greatest(coalesce(p_seconds, 0), 0), 86400),
    case when p_scroll_pct is not null then least(greatest(p_scroll_pct, 0), 100) end
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
    updated_at = now()
  where w.created_at > now() - interval '1 day';
end;
$function$;

create or replace function public.admin_web_journey (
  p_days   integer default 30,
  p_device text default null,
  p_entry  text default null
)
  returns table (
    step           text,
    reached        bigint,
    left_here      bigint,
    median_seconds double precision,
    median_scroll  double precision,
    idle           bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
  v_steps constant text[] := array[
    'landing', 'landing_cta', 'app', 'tutorial_start', 'tutorial_done',
    'game_start', 'first_move', 'move_5', 'game_finish',
    'signup_form', 'signup_done', 'login', 'store'
  ];
  v_idle bigint;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  select count(*) into v_idle
  from public.web_sessions ws
  where ws.created_at >= v_since
    and (p_device is null or ws.device_type = p_device)
    and (p_entry is null or ws.entry = p_entry)
    and ws.updated_at = ws.created_at;

  return query
  with s as (
    select ws.steps, ws.last_step, ws.seconds, ws.scroll_pct
    from public.web_sessions ws
    where ws.created_at >= v_since
      and (p_device is null or ws.device_type = p_device)
      and (p_entry is null or ws.entry = p_entry)
      and ws.updated_at > ws.created_at
  )
  select k.step,
         (select count(*) from s where k.step = any (s.steps)),
         (select count(*) from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.seconds)
            from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.scroll_pct)
            from s where s.last_step = k.step and s.scroll_pct is not null),
         v_idle
  from unnest(v_steps) with ordinality as k (step, ord)
  order by k.ord;
end;
$function$;
