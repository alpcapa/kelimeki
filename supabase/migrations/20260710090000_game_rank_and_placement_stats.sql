-- Harfik — oyuncunun bitiş sırasını (1., 2., 3., 4.) kaydetmek için games
-- tablosuna rank eklenir; player_stats görünümü artık toplam birincilik ve
-- ikincilik sayılarını da döner (skor kartındaki yeni yer/percentage
-- istatistikleri için).
--
-- Eski kayıtlarda tüm oyuncuların skorları tutulmadığından gerçek sıra
-- (özellikle 4 oyunculu oyunlarda 2./3./4. ayrımı) geriye dönük olarak tam
-- hesaplanamaz. Bu yüzden geri dolum yalnızca kesin bilinen durumları
-- kapsar: result='win' → rank 1 (kaç oyuncu olursa olsun, en iyisini
-- geçmiş demektir); 2 oyunculu result='lose' → rank 2; 2 oyunculu
-- result='tie' → rank 1 (kimse geçilmemiş). Diğerleri (eski 4 oyunculu
-- kayıp/berabere) NULL kalır.

alter table public.games
  add column if not exists rank integer;

update public.games
set rank = case
  when result = 'win' then 1
  when player_count = 2 and result = 'lose' then 2
  when player_count = 2 and result = 'tie' then 1
  else null
end
where rank is null;

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
  count(*) filter (where g.rank = 2)    as second_places
from public.games g
where g.user_id is not null
group by g.user_id, g.player_count;
