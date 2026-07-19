-- Harfik — oyun büyümesi grafiğine oyuncu sayısı ve kayıtlı/misafir filtresi
--
-- admin_game_activity_series'e iki opsiyonel parametre eklendi:
--   - p_scope: 'total' (varsayılan), 'registered' (yalnızca girişli) ya da
--     'guest' (yalnızca misafir) satırlarını sayar.
--   - p_player_count: verilirse yalnızca o oyuncu sayısındaki oyunları sayar.

create or replace function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null
)
  returns table (
    bucket          date,
    game_starts     bigint,
    games_finished  bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
declare
  v_unit text := case
    when p_granularity = 'month' then 'month'
    when p_granularity = 'week' then 'week'
    else 'day'
  end;
  v_step interval := case
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
    d.bucket::date       as bucket,
    coalesce(gs.cnt, 0)  as game_starts,
    coalesce(gf.cnt, 0)  as games_finished
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
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
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
