-- games.games_insert_self politikası yalnızca auth.uid()=user_id kontrol
-- ediyor, skor/rank alanlarının gerçekçi olup olmadığını değil. Bu, tam bir
-- anti-cheat değil (oyun mantığı hâlâ istemci tarafında hesaplanıyor), ama
-- en bariz sahte kayıtları (negatif skor, olmayan rank, geçersiz oyuncu
-- sayısı) veritabanı seviyesinde engeller. Mevcut 47 satırın tamamı bu
-- sınırlara zaten uyuyor (uygulama öncesi doğrulandı).
alter table public.games
  add constraint games_player_count_valid check (player_count in (2, 4)),
  add constraint games_rank_valid check (rank between 1 and player_count),
  add constraint games_player_score_nonneg check (player_score >= 0),
  add constraint games_ai_score_nonneg check (ai_score >= 0),
  add constraint games_turn_count_nonneg check (turn_count >= 0),
  add constraint games_best_move_score_nonneg check (best_move_score >= 0),
  add constraint games_move_count_nonneg check (move_count >= 0),
  add constraint games_move_points_sum_nonneg check (move_points_sum >= 0),
  add constraint games_result_valid check (result in ('win', 'lose', 'tie'));
