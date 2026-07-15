-- Harfik — games tablosuna final sıralamasındaki oyuncu/puan listesini
-- saklamak için players jsonb sütunu eklenir. buildGameRecord (App.tsx)
-- bunu final sıralamasına göre {name, score, is_ai}[] ile doldurur;
-- GameHistoryModal bu sütun sayesinde geçmiş oyunlarda tüm oyuncuların
-- final sıralamasını gösterebilir.

alter table public.games
  add column if not exists players jsonb;
