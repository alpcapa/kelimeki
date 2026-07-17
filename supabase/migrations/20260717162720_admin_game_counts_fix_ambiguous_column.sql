-- Harfik — admin_game_counts düzeltmesi: returns table'daki player_count OUT
-- parametresi, sorgu içindeki aynı adlı sütunlarla PL/pgSQL'de belirsizlik
-- hatasına yol açıyordu ("column reference player_count is ambiguous").
-- İç sorgularda "pcount" takma adı kullanılarak bare "player_count" referansı
-- tamamen kaldırıldı.
create or replace function public.admin_game_counts ()
  returns table (
    player_count integer,
    started      bigint,
    finished     bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    pc.pcount,
    coalesce(s.started, 0)  as started,
    coalesce(f.finished, 0) as finished
  from (
    select gs.player_count as pcount from public.game_starts gs
    union
    select g.player_count as pcount from public.games g
  ) pc
  left join (
    select gs.player_count as pcount, count(*) as started
    from public.game_starts gs
    group by gs.player_count
  ) s on s.pcount = pc.pcount
  left join (
    select g.player_count as pcount, count(*) as finished
    from public.games g
    group by g.player_count
  ) f on f.pcount = pc.pcount
  order by pc.pcount;
end;
$$;

revoke all on function public.admin_game_counts () from public, anon;
grant execute on function public.admin_game_counts () to authenticated;
