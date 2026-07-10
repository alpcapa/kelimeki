-- Harfik — Setup ekranında isim yanında gösterilen "toplam puan", oyun
-- içi ham skorların toplamı değil, klasik lig puanlaması olmalı: galibiyet
-- 2 puan, beraberlik 1 puan, mağlubiyet 0 puan (4 kişilikte sadece rank=1
-- galibiyet sayılır, result zaten buna göre 'win' olarak kaydediliyor).
-- player_stats.total_score bu puanlamaya göre yeniden tanımlanır.
--
-- Sütun sırası önemli: create or replace view yalnızca sona ekleme yapabilir.

create or replace view public.player_stats
with (security_invoker = true) as
select
  g.user_id,
  g.player_count,
  count(*)                              as games_played,
  count(*) filter (where g.result = 'win')  as wins,
  count(*) filter (where g.result = 'lose') as losses,
  count(*) filter (where g.result = 'tie')  as ties,
  max(g.player_score)                   as best_score,
  round(avg(g.player_score))::int       as avg_score,
  max(g.best_move_score)                as best_move_score,
  (
    select g2.longest_word
    from public.games g2
    where g2.user_id = g.user_id
      and g2.player_count = g.player_count
      and g2.longest_word is not null
    order by char_length(g2.longest_word) desc
    limit 1
  )                                     as longest_word,
  round(
    sum(g.move_points_sum) filter (where g.move_points_sum is not null)::numeric
    / nullif(sum(g.move_count) filter (where g.move_points_sum is not null), 0)
  )::int                                as avg_move_score,
  (
    select g2.best_word
    from public.games g2
    where g2.user_id = g.user_id
      and g2.player_count = g.player_count
      and g2.best_word is not null
      and g2.best_word_score is not null
    order by g2.best_word_score desc
    limit 1
  )                                     as best_word,
  max(g.best_word_score)                as best_word_score,
  count(*) filter (where g.rank = 1)    as first_places,
  count(*) filter (where g.rank = 2)    as second_places,
  sum(
    case
      when g.result = 'win' then 2
      when g.result = 'tie' then 1
      else 0
    end
  )::int                                as total_score
from public.games g
where g.user_id is not null
group by g.user_id, g.player_count;
