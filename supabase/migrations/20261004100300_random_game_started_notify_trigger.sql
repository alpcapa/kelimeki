-- Rastgele Oyuncu "oyun başladı" push'u — TETİKLEYİCİ (fonksiyon bir önceki
-- migration'da). Tek migration olarak 60 sn araç zaman aşımına uğradığı için
-- ayrıldı; `create trigger` `execute_sql` ile uygulandı, kayıt elle eklendi.
create trigger online_game_states_notify_random_start
  after insert on public.online_game_states
  for each row execute function public._notify_random_game_started();
