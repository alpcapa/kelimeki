-- Harfik — Setup ekranında isim yanında gösterilecek, oyuncunun kazandığı
-- toplam puanı döndürmek için player_stats görünümüne total_score eklenir.
--
-- Bu ham oyun içi skorların toplamı değil, sıraya (rank) dayalı bir lig
-- puanıdır: 1.=2, 2.=1, 3./4.=0. Beraber bitiren oyuncular grubun en iyi
-- sırasının puanını paylaşır — games.rank zaten bu mantıkla kaydediliyor
-- (App.tsx: scoresDesc.indexOf(score)+1, eşit skorlar aynı, en iyi sırayı
-- paylaşır), yani 2 kişilik tam beraberlikte ikisi de rank=1 olur ve
-- ikisi de 2 puan alır; 4 kişilikte hepsi berabere olursa da aynı şekilde
-- herkes 2 puan alır.
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
      when g.rank = 1 then 2
      when g.rank = 2 then 1
      else 0
    end
  )::int                                as total_score
from public.games g
where g.user_id is not null
group by g.user_id, g.player_count;
