-- Ziyaretçi Yolculuğu: türetilmiş "Tanıtımı atladı" satırı (30 Eylül 2026).
--
-- Kullanıcı sorusu: *"Tanıtımı açtı 24, bitirdi 13 — 11 kişi atladı mı?"*
-- Canlı veri (Yeni, son 30 gün): 11'in 6'sı tanıtımı ATLAYIP oyuna geçmişti
-- (oyun başlatan 19 = 13 bitiren + 6 atlayan), 5'i tanıtımda ayrılmıştı.
-- Kart bu 6'yı hiçbir satırda göstermiyordu.
--
-- `tutorial_skip` bir ADIM DEĞİL — istemci onu hiç göndermez, `v_steps`e
-- girmez (`record_web_session` ve `JOURNEY_STEPS` DEĞİŞMEDİ). Okuma anında
-- türetilir: `tutorial_start` VAR, `tutorial_done` YOK, `game_start` VAR.
-- `left_here` = 0 (atlayan oyuna DEVAM etti; çıkışı en ileri adımında
-- sayılıyor), medyanlar null → toplam oturum sayısı (`sum(left_here)`)
-- değişmez. Satır `tutorial_done`un hemen ALTINA yerleşir.
--
-- İmza ve dönüş tipi AYNI → create or replace; grant'ler, security definer
-- ve search_path korunur.
create or replace function public.admin_web_journey(
  p_days integer default 30,
  p_device text default null::text,
  p_entry text default null::text
)
returns table(step text, reached bigint, left_here bigint, median_seconds double precision,
              median_scroll double precision, idle bigint)
language plpgsql
stable security definer
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
    select ws.steps, ws.seconds, ws.scroll_pct,
           (select v_steps[max(array_position(v_steps, x))]
              from unnest(ws.steps) as x) as exit_step
    from public.web_sessions ws
    where ws.created_at >= v_since
      and (p_device is null or ws.device_type = p_device)
      and (p_entry is null or ws.entry = p_entry)
      and ws.updated_at > ws.created_at
  ),
  r as (
    select k.step,
           k.ord::numeric as ord,
           (select count(*) from s where k.step = any (s.steps)) as reached,
           (select count(*) from s where s.exit_step = k.step) as left_here,
           (select percentile_cont(0.5) within group (order by s.seconds)
              from s where s.exit_step = k.step) as median_seconds,
           (select percentile_cont(0.5) within group (order by s.scroll_pct)
              from s where s.exit_step = k.step and s.scroll_pct is not null) as median_scroll
    from unnest(v_steps) with ordinality as k (step, ord)
    union all
    select 'tutorial_skip',
           array_position(v_steps, 'tutorial_done') + 0.5,
           (select count(*) from s
             where 'tutorial_start' = any (s.steps)
               and not ('tutorial_done' = any (s.steps))
               and 'game_start' = any (s.steps)),
           0::bigint,
           null::double precision,
           null::double precision
  )
  select r.step, r.reached, r.left_here, r.median_seconds, r.median_scroll, v_idle
  from r
  order by r.ord;
end;
$function$;
