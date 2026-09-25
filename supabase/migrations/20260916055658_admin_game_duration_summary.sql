-- Kelimeki — oyun süresi: grafik yerine PENCERE ÖZETİ (16 Eylül 2026)
--
-- Kullanıcı isteği: *"Oyun süresi grafiğini kaldır. YZ dengesi gibi kutulara
-- koyalım."*
--
-- ⚠ Bu RPC olmadan istek yapılamazdı ve sebebi istatistik: `admin_game_
-- activity_series` KOVA BAŞINA medyan döndürüyor, **medyanlar toplanamaz**.
-- Kova medyanlarının medyanını almak ya da son kovayı göstermek pencerenin
-- gerçek medyanı DEĞİLDİR. (Aynı gerekçeyle 16 Ağustos 2026'da ortalamadan
-- medyana geçilirken de seriler tek bir `union`da birleştirilmişti.)
--
-- Filtreler ve kapsam `admin_game_activity_series` ile BİREBİR aynı olmak
-- ZORUNDA — iki sayı aynı ekranda yan yana duruyor. Gövde oradan kopyalandı;
-- biri değişirse öteki de değişmeli.

create or replace function public.admin_game_duration_summary (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null,
  p_source text default 'total'
)
returns table (
  med_duration_seconds numeric,
  med_duration_same_session_seconds numeric,
  med_duration_multi_session_seconds numeric,
  p90_duration_seconds numeric,
  finished_games bigint
)
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_unit text := case
    when p_granularity = 'year' then 'year'
    when p_granularity = 'month' then 'month'
    when p_granularity = 'week' then 'week'
    else 'day'
  end;
  v_step interval := case
    when v_unit = 'year' then interval '1 year'
    when v_unit = 'month' then interval '1 month'
    when v_unit = 'week' then interval '1 week'
    else interval '1 day'
  end;
  v_end timestamp := date_trunc(v_unit, now() at time zone 'Europe/Istanbul');
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with online_games_agg as (
    select
      g.online_game_id,
      max(g.created_at) as finished_at,
      min(ogs.started_at) as started_at,
      bool_or(g.surrendered) as any_surrendered,
      max(g.player_count) as player_count
    from public.games g
    join public.online_game_states ogs on ogs.online_game_id = g.online_game_id
    where g.online_game_id is not null
    group by g.online_game_id
  ),
  durations as (
    select
      duration_seconds::numeric as dur,
      multi_session as is_multi
    from public.game_finishes
    where p_source in ('total', 'local')
      and not ended_by_surrender
      and (
        p_scope = 'total'
        or (p_scope = 'registered' and user_id is not null)
        or (p_scope = 'guest' and user_id is null)
      )
      and (p_player_count is null or player_count = p_player_count)
      -- ⚠ Seride pencere `generate_series` ile kuruluyordu; burada AÇIKÇA
      -- yazılmak zorunda, yoksa özet TÜM geçmişi ölçer ve ekrandaki
      -- "Son N gün" başlığıyla çelişir.
      and (created_at at time zone 'Europe/Istanbul') >= v_start
      and (created_at at time zone 'Europe/Istanbul') < v_end + v_step
    union all
    select
      extract(epoch from (finished_at - started_at))::numeric,
      true
    from online_games_agg
    where p_source in ('total', 'online')
      and p_scope <> 'guest'
      and not any_surrendered
      and (p_player_count is null or player_count = p_player_count)
      and (finished_at at time zone 'Europe/Istanbul') >= v_start
      and (finished_at at time zone 'Europe/Istanbul') < v_end + v_step
  )
  select
    (percentile_cont(0.5) within group (order by dur))::numeric,
    (percentile_cont(0.5) within group (order by dur)
      filter (where not is_multi))::numeric,
    (percentile_cont(0.5) within group (order by dur)
      filter (where is_multi))::numeric,
    (percentile_cont(0.9) within group (order by dur))::numeric,
    count(*)::bigint
  from durations;
end;
$$;

revoke all on function public.admin_game_duration_summary (integer, text, text, integer, text) from public;
grant execute on function public.admin_game_duration_summary (integer, text, text, integer, text) to authenticated, service_role;
