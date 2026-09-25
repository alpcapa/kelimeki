-- Kelimeki — "Oyun Sayısı" grafiğine platform kırılımı (16 Eylül 2026)
--
-- Kullanıcı isteği: *"Oyun sayısına genel, ios, android, web kırılımı
-- ekleyebilir miyiz? Terk genel olarak kalsın."*
--
-- Dört yeni sütun HER ZAMAN `games_finished`e TAM olarak toplanır — kırılımın
-- tek anlamlı okuması bu. `games_surrendered` bilerek kırılmadı (kullanıcı
-- kararı): terk, bir platformun değil 7 günlük/48 saatlik pencerenin sonucu.
--
-- ── Platform nereden geliyor ──────────────────────────────────────────────
-- YEREL oyun  → `game_finishes.platform` (16 Eylül 2026'da eklendi ve
--               `games`ten geriye dolduruldu; bkz. o migration).
-- CANLI oyun  → `online_game_clients`: oyunun TÜM istemcileri aynı platformsa
--               o platform, değilse "Diğer". Karma bir oyunu tek bir platforma
--               yazmak uydurma olurdu — canlıda ölçüldü, Canlı oyunların
--               %40'ı karma (34/85).
--
-- `games_finished_other` ("Diğer") ÜÇ farklı şeyi toplar ve bu bilinçli:
--   · misafir yerel oyun    → `games` satırı hiç açılmadığından bilinemez
--   · 17 Ağu 2026 öncesi    → kolon yoktu
--   · karma Canlı oyun      → tek bir platforma atfedilemez
-- Üçünü ayrı seri yapmak grafiği yedi çizgiye çıkarırdı; ayrım `?` metninde.
--
-- ⚠ `create or replace` YETMEZ — dönüş TABLE'ına sütun ekleniyor, önce drop.

drop function if exists public.admin_game_activity_series (integer, text, text, integer, text);

create function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null,
  p_source text default 'total'
)
returns table (
  bucket date,
  games_finished bigint,
  games_finished_same_session bigint,
  games_finished_multi_session bigint,
  games_surrendered bigint,
  games_finished_web bigint,
  games_finished_ios bigint,
  games_finished_android bigint,
  games_finished_other bigint,
  med_duration_seconds numeric,
  med_duration_same_session_seconds numeric,
  med_duration_multi_session_seconds numeric,
  p90_duration_seconds numeric
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
  with local_agg as (
    select
      date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket,
      count(*) filter (where not ended_by_surrender) as cnt_done,
      count(*) filter (where not ended_by_surrender and not multi_session) as cnt_done_same,
      count(*) filter (where not ended_by_surrender and multi_session) as cnt_done_multi,
      count(*) filter (where ended_by_surrender) as cnt_surrendered,
      count(*) filter (where not ended_by_surrender and platform = 'web') as cnt_web,
      count(*) filter (where not ended_by_surrender and platform = 'ios') as cnt_ios,
      count(*) filter (where not ended_by_surrender and platform = 'android') as cnt_android,
      count(*) filter (
        where not ended_by_surrender
          and (platform is null or platform = 'app-web')
      ) as cnt_other
    from public.game_finishes
    where p_source in ('total', 'local')
      and (
        p_scope = 'total'
        or (p_scope = 'registered' and user_id is not null)
        or (p_scope = 'guest' and user_id is null)
      )
      and (p_player_count is null or player_count = p_player_count)
    group by 1
  ),
  online_games_agg as (
    select
      g.online_game_id,
      max(g.created_at) as finished_at,
      min(ogs.started_at) as started_at,
      bool_or(g.surrendered) as any_surrendered,
      max(g.player_count) as player_count,
      -- Tüm istemciler aynı platformdaysa o platform, değilse NULL ("Diğer").
      (select case when count(distinct c.platform) = 1 then min(c.platform) end
         from public.online_game_clients c
        where c.online_game_id = g.online_game_id) as platform
    from public.games g
    join public.online_game_states ogs on ogs.online_game_id = g.online_game_id
    where g.online_game_id is not null
    group by g.online_game_id
  ),
  online_agg as (
    select
      date_trunc(v_unit, finished_at at time zone 'Europe/Istanbul') as bucket,
      count(*) filter (where not any_surrendered) as cnt_done,
      count(*) filter (where any_surrendered) as cnt_surrendered,
      count(*) filter (where not any_surrendered and platform = 'web') as cnt_web,
      count(*) filter (where not any_surrendered and platform = 'ios') as cnt_ios,
      count(*) filter (where not any_surrendered and platform = 'android') as cnt_android,
      count(*) filter (
        where not any_surrendered
          and (platform is null or platform = 'app-web')
      ) as cnt_other
    from online_games_agg
    where p_source in ('total', 'online')
      and p_scope <> 'guest'
      and (p_player_count is null or player_count = p_player_count)
    group by 1
  ),
  durations as (
    select
      date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket,
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
    union all
    select
      date_trunc(v_unit, finished_at at time zone 'Europe/Istanbul'),
      extract(epoch from (finished_at - started_at))::numeric,
      true
    from online_games_agg
    where p_source in ('total', 'online')
      and p_scope <> 'guest'
      and not any_surrendered
      and (p_player_count is null or player_count = p_player_count)
  ),
  dur_agg as (
    select
      dd.bucket as bucket,
      (percentile_cont(0.5) within group (order by dd.dur))::numeric as med_all,
      (percentile_cont(0.5) within group (order by dd.dur)
        filter (where not dd.is_multi))::numeric as med_same,
      (percentile_cont(0.5) within group (order by dd.dur)
        filter (where dd.is_multi))::numeric as med_multi,
      (percentile_cont(0.9) within group (order by dd.dur))::numeric as p90_all
    from durations dd
    group by dd.bucket
  )
  select
    d.bucket::date as bucket,
    coalesce(l.cnt_done, 0) + coalesce(o.cnt_done, 0) as games_finished,
    coalesce(l.cnt_done_same, 0) as games_finished_same_session,
    coalesce(l.cnt_done_multi, 0) + coalesce(o.cnt_done, 0) as games_finished_multi_session,
    coalesce(l.cnt_surrendered, 0) + coalesce(o.cnt_surrendered, 0) as games_surrendered,
    coalesce(l.cnt_web, 0) + coalesce(o.cnt_web, 0) as games_finished_web,
    coalesce(l.cnt_ios, 0) + coalesce(o.cnt_ios, 0) as games_finished_ios,
    coalesce(l.cnt_android, 0) + coalesce(o.cnt_android, 0) as games_finished_android,
    coalesce(l.cnt_other, 0) + coalesce(o.cnt_other, 0) as games_finished_other,
    da.med_all as med_duration_seconds,
    da.med_same as med_duration_same_session_seconds,
    da.med_multi as med_duration_multi_session_seconds,
    da.p90_all as p90_duration_seconds
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join local_agg l on l.bucket = d.bucket
  left join online_agg o on o.bucket = d.bucket
  left join dur_agg da on da.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_game_activity_series (integer, text, text, integer, text) from public;
grant execute on function public.admin_game_activity_series (integer, text, text, integer, text) to authenticated, service_role;
