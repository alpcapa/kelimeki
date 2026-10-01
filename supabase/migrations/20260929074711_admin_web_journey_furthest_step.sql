-- Ziyaretçi Yolculuğu: "Ayrılan" artık oturumun EN İLERİ adımına göre
-- sayılıyor, en son KAYDEDİLEN adıma göre değil (29 Eylül 2026).
--
-- Vaka: li-profil oturumu tanıtımı + oyunu bitirdi, ama adımlar
-- `... first_move, game_finish, move_5` sırasıyla geldi (hamle sayacı oyun
-- bitişinden SONRA işlendi) → `last_step = move_5`. Kart "5. hamle —
-- Ayrılan 1 — %100" diye kırmızı yazıyordu, "Oyun bitti"de ise ayrılan 0.
-- `last_step` ağ sırasına bağlı; en ileri adım değil.
--
-- Yeni tanım: çıkış adımı = `steps` içindeki, `v_steps` sırasında EN SONDA
-- duran adım. Tarihsel satırlar da düzelir (hesap okuma anında).
-- Bilinen sonucu: `store` sırada en sonda; mağazaya gidip dönen ve oynayan
-- oturum "Mağazaya gitti"de sayılır (başarı satırı, ✓).
--
-- İmza ve dönüş tipi AYNI → create or replace; grant'ler, security definer
-- ve search_path korunur. `record_web_session`a dokunulmadı.
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
  )
  select k.step,
         (select count(*) from s where k.step = any (s.steps)),
         (select count(*) from s where s.exit_step = k.step),
         (select percentile_cont(0.5) within group (order by s.seconds)
            from s where s.exit_step = k.step),
         (select percentile_cont(0.5) within group (order by s.scroll_pct)
            from s where s.exit_step = k.step and s.scroll_pct is not null),
         v_idle
  from unnest(v_steps) with ordinality as k (step, ord)
  order by k.ord;
end;
$function$;
