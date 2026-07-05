-- Harfik — games tablosuna hamle sayısı eklenir; player_stats görünümü
-- ortalama hamle puanını ve en iyi hamledeki kelimeyi de hesaplar.
-- Not: yeni sütunlar mevcut view'ın sonuna eklenir (create or replace view
-- var olan sütunların sırasını değiştiremez).

alter table public.games
  add column if not exists move_count integer;

create or replace view public.player_stats
with (security_invoker = true) as
select
  g.user_id,
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
      and g2.longest_word is not null
    order by char_length(g2.longest_word) desc
    limit 1
  )                                     as longest_word,
  round(sum(g.player_score)::numeric / nullif(sum(g.move_count), 0))::int as avg_move_score,
  (
    select g2.best_word
    from public.games g2
    where g2.user_id = g.user_id
      and g2.best_word is not null
    order by g2.best_move_score desc
    limit 1
  )                                     as best_word
from public.games g
where g.user_id is not null
group by g.user_id;
