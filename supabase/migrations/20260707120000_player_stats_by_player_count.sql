-- Harfik — skor kartında 2 ve 4 oyunculu istatistiklerin ayrı gösterilmesi
-- için games tablosuna player_count eklenir; player_stats görünümü artık
-- (user_id, player_count) ikilisine göre gruplanır.
--
-- Mevcut kayıtlar 4 oyunculu mod eklenmeden önce oynandığı için hepsi 2
-- oyunculu kabul edilir (default 2).

alter table public.games
  add column if not exists player_count integer not null default 2;

-- Sütun sırası önemli: create or replace view, var olan sütunların
-- pozisyonunu/adını değiştirmeye izin vermez, yalnızca sona ekleme yapılabilir.
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
  max(g.best_word_score)                as best_word_score
from public.games g
where g.user_id is not null
group by g.user_id, g.player_count;
