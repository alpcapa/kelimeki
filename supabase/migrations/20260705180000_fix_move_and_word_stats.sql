-- Harfik — skor kartındaki 3 hatalı istatistiği düzeltir:
--
-- 1) "En İyi Hamle Puanı": bestMoveScore, köşe vergisi kesintisinden SONRAKİ
--    net puanla (pts) kıyaslanıyordu; rakip köşesine giren yüksek puanlı bir
--    hamle, paylaşım sonrası düşük göründüğü için "en iyi" sayılmıyordu.
--    Artık köşe vergisinden ÖNCEKİ brüt puanla (basePts / move.score)
--    kıyaslanıyor — bkz. gameReducer.ts PLAY/AI_PLAY.
-- 2) "Ortalama Hamle Puanı": sum(player_score)/sum(move_count) kullanıyordu;
--    player_score rakip köşesine giren başkalarından kazanılan pay ve
--    oyun sonu raf düşümünü de içerdiği için hamle başına ortalamayı
--    anlamsızca şişiriyordu (en iyi hamleden bile yüksek çıkabiliyordu).
--    Yeni move_points_sum sütunu yalnızca oyuncunun kendi hamlelerinin brüt
--    toplamını tutar; ortalama artık sum(move_points_sum)/sum(move_count).
-- 3) "En Yüksek Kelime Puanı": ScoreCard.tsx içinde yanlışlıkla
--    best_move_score ile aynı alanı gösteriyordu. Yeni best_word_score
--    sütunu, bir hamlede oluşan kelimelerin (bingo bonusu hariç, o hamlenin
--    tamamına ait olduğu için) en yükseğini ayrı tutar.
--
-- Not: Mevcut satırlarda best_word_score ve move_points_sum boş (null)
-- kalır — geçmiş oyunlar için bu granülerlikte veri hiç tutulmamıştı ve
-- geriye dönük hesaplanamaz. Yeni oynanan oyunlarla birlikte doğru
-- değerlerle dolmaya başlar; ortalama hesap da yalnızca bu yeni sütunu
-- dolu olan satırları kullanır.

alter table public.games
  add column if not exists best_word_score integer,
  add column if not exists move_points_sum integer;

-- Sütun sırası önemli: create or replace view, var olan sütunların
-- pozisyonunu/adını değiştirmeye izin vermez, yalnızca sona ekleme yapılabilir.
-- Bu yüzden best_word (var olan, artık best_word_score'a göre seçiliyor)
-- yerini koruyor; best_word_score en sona ekleniyor.
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
  round(
    sum(g.move_points_sum) filter (where g.move_points_sum is not null)::numeric
    / nullif(sum(g.move_count) filter (where g.move_points_sum is not null), 0)
  )::int                                as avg_move_score,
  (
    select g2.best_word
    from public.games g2
    where g2.user_id = g.user_id
      and g2.best_word is not null
      and g2.best_word_score is not null
    order by g2.best_word_score desc
    limit 1
  )                                     as best_word,
  max(g.best_word_score)                as best_word_score
from public.games g
where g.user_id is not null
group by g.user_id;
