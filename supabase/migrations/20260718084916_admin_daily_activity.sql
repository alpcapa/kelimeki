-- Harfik — admin paneli: günlük büyüme/aktivite grafiği için RPC
--
-- Kayıt (auth.users), oyun başlatma (game_starts) ve oyun bitirme (games)
-- sayılarını son N gün için günlük kovalara ayırır; kaydı olmayan günler 0
-- ile doldurulur (generate_series). Admin panelindeki büyüme grafiği bu
-- RPC'yi kullanır.

create or replace function public.admin_daily_activity (p_days integer default 30)
  returns table (
    day             date,
    signups         bigint,
    game_starts     bigint,
    games_finished  bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.day::date         as day,
    coalesce(u.cnt, 0)  as signups,
    coalesce(gs.cnt, 0) as game_starts,
    coalesce(g.cnt, 0)  as games_finished
  from generate_series(
    (current_date - (greatest(p_days, 1) - 1))::timestamp,
    current_date::timestamp,
    interval '1 day'
  ) as d (day)
  left join (
    select created_at::date as day, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.day = d.day::date
  left join (
    select created_at::date as day, count(*) as cnt
    from public.game_starts
    group by 1
  ) gs on gs.day = d.day::date
  left join (
    select created_at::date as day, count(*) as cnt
    from public.games
    group by 1
  ) g on g.day = d.day::date
  order by d.day;
end;
$$;

revoke all on function public.admin_daily_activity (integer) from public, anon;
grant execute on function public.admin_daily_activity (integer) to authenticated;
