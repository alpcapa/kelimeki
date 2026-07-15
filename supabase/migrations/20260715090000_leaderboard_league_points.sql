-- Harfik — Sanal Lig sıralaması artık ham oyun içi skor toplamı
-- (sum(player_score), binlerce puana çıkabiliyordu) yerine player_stats
-- ile aynı lig puanı formülünü kullanıyor: surrendered → -2, rank=1 → +2,
-- rank=2 (yalnızca player_count<>2) → +1, diğerleri 0. Hem leaderboard
-- view'ı hem my_leaderboard_rank RPC'si bu formüle göre güncellendi.

drop view if exists public.leaderboard;
create view public.leaderboard
with (security_invoker = true) as
select
  g.user_id,
  p.username,
  p.first_name,
  p.last_name,
  p.display_name,
  p.avatar_url,
  max(g.player_score)                       as best_score,
  sum(
    case
      when g.surrendered then -2
      when g.rank = 1 then 2
      when g.rank = 2 and g.player_count <> 2 then 1
      else 0
    end
  )::int                                    as total_score,
  count(*)                                  as games_played,
  count(*) filter (where g.result = 'win')  as wins
from public.games g
inner join public.profiles p on p.id = g.user_id
group by g.user_id, p.username, p.first_name, p.last_name, p.display_name, p.avatar_url
order by total_score desc;

create or replace function public.my_leaderboard_rank (p_user_id uuid)
  returns table (rank bigint, total_score bigint)
  language sql
  stable
  security invoker
  set search_path = public
  as $$
  select ranked.rank, ranked.total_score
  from (
    select
      g.user_id,
      sum(
        case
          when g.surrendered then -2
          when g.rank = 1 then 2
          when g.rank = 2 and g.player_count <> 2 then 1
          else 0
        end
      ) as total_score,
      rank() over (
        order by sum(
          case
            when g.surrendered then -2
            when g.rank = 1 then 2
            when g.rank = 2 and g.player_count <> 2 then 1
            else 0
          end
        ) desc
      ) as rank
    from public.games g
    where g.user_id is not null
    group by g.user_id
  ) ranked
  where ranked.user_id = p_user_id;
$$;
