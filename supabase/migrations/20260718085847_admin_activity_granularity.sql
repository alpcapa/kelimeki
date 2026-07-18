-- Harfik — admin paneli büyüme grafiğine günlük/aylık filtre desteği
--
-- admin_daily_activity(integer) sadece günlük kovalama yapıyordu; admin
-- panelinde artık "Günlük" ve "Aylık" filtre seçilebildiğinden bu fonksiyon
-- admin_activity_series(p_periods, p_granularity) ile değiştirildi —
-- p_granularity = 'day' ya da 'month', kovalar date_trunc ile hesaplanır.

drop function if exists public.admin_daily_activity (integer);

create or replace function public.admin_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day'
)
  returns table (
    bucket          date,
    signups         bigint,
    game_starts     bigint,
    games_finished  bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
declare
  v_unit text := case when p_granularity = 'month' then 'month' else 'day' end;
  v_step interval := case when v_unit = 'month' then interval '1 month' else interval '1 day' end;
  v_end timestamp := date_trunc(v_unit, now());
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date      as bucket,
    coalesce(u.cnt, 0)  as signups,
    coalesce(gs.cnt, 0) as game_starts,
    coalesce(g.cnt, 0)  as games_finished
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.bucket = d.bucket
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.game_starts
    group by 1
  ) gs on gs.bucket = d.bucket
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.games
    group by 1
  ) g on g.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_activity_series (integer, text) from public, anon;
grant execute on function public.admin_activity_series (integer, text) to authenticated;
