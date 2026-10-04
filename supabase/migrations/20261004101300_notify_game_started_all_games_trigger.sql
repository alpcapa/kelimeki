-- Tetikleyici: `_notify_game_started` (bir önceki migration). Aracın DROP
-- ifadeleri onayda takılıp 60 sn zaman aşımına uğradığı için canlıda ESKİ
-- tetikleyici düşürülmedi, DEVRE DIŞI bırakıldı (çift bildirim olmasın);
-- sıfırdan oynatmada ikisi de temiz düşer.
create trigger online_game_states_notify_started
  after insert on public.online_game_states
  for each row execute function public._notify_game_started();

drop trigger if exists online_game_states_notify_random_start on public.online_game_states;
drop function if exists public._notify_random_game_started();
