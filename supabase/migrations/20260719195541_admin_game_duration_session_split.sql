-- Harfik — oyun süresi ve tek-oturum/çok-oturum kırılımı
--
-- game_finishes'e oyunun ne kadar sürdüğü (duration_seconds) ve tarayıcı
-- sekmesi kapat-aç (localStorage'dan devam) ile birden fazla oturuma
-- yayılıp yayılmadığı (multi_session) eklendi. admin_game_activity_series
-- artık ortalama süreyi toplamda ve bu iki kırılımda ayrı ayrı dönüyor.

alter table public.game_finishes
  add column if not exists duration_seconds integer not null,
  add column if not exists multi_session boolean not null default false;

create or replace function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null
)
  returns table (
    bucket                              date,
    game_starts                         bigint,
    games_finished                      bigint,
    avg_duration_seconds                numeric,
    avg_duration_same_session_seconds   numeric,
    avg_duration_multi_session_seconds  numeric
  )
  language plpgsql
  stable
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
  v_end timestamp := date_trunc(v_unit, now());
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date        as bucket,
    coalesce(gs.cnt, 0)   as game_starts,
    coalesce(gf.cnt, 0)   as games_finished,
    gf.avg_duration       as avg_duration_seconds,
    gf.avg_duration_same  as avg_duration_same_session_seconds,
    gf.avg_duration_multi as avg_duration_multi_session_seconds
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.game_starts
    where (
      p_scope = 'total'
      or (p_scope = 'registered' and user_id is not null)
      or (p_scope = 'guest' and user_id is null)
    )
    and (p_player_count is null or player_count = p_player_count)
    group by 1
  ) gs on gs.bucket = d.bucket
  left join (
    select
      date_trunc(v_unit, created_at) as bucket,
      count(*) as cnt,
      avg(duration_seconds) as avg_duration,
      avg(duration_seconds) filter (where not multi_session) as avg_duration_same,
      avg(duration_seconds) filter (where multi_session) as avg_duration_multi
    from public.game_finishes
    where (
      p_scope = 'total'
      or (p_scope = 'registered' and user_id is not null)
      or (p_scope = 'guest' and user_id is null)
    )
    and (p_player_count is null or player_count = p_player_count)
    group by 1
  ) gf on gf.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_game_activity_series (integer, text, text, integer) from public, anon;
grant execute on function public.admin_game_activity_series (integer, text, text, integer) to authenticated;
