-- "Oyun başladı" push'unu TÜM canlı oyunlara genişlet (4 Ekim 2026, kullanıcı:
-- "canlı oyun davetinde kabul edilince bana aynı mesaj gelmiyor mu? Hayır ise
-- orada da aynı problem var"). Ölçüldü: game_invites/online_games üzerinde
-- başlangıcı haber veren HİÇBİR tetikleyici yoktu → davetçi oyunun açıldığını
-- ancak Devam Edenler'e girince görüyordu.
--
-- Önceki `_notify_random_game_started` (yalnızca via=random) bunun yerine geçer.
-- Gövdeye `started: true` konur: Edge Function metni bu bayrağa göre seçer
-- (hamlesiz bir zaman aşımı devri "başladı" demesin). Hedef YİNE gövdeden
-- değil canlı durumdan okunur.
create or replace function public._notify_game_started()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if new.is_game_over then
    return new;
  end if;
  if not exists (
    select 1 from public.online_games og
    where og.id = new.online_game_id and og.status = 'active'
  ) then
    return new;
  end if;

  perform net.http_post(
    url := 'https://xvqlizifakkkoqahaxsg.supabase.co/functions/v1/notify-your-turn',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := jsonb_build_object('online_game_id', new.online_game_id, 'started', true)
  );
  return new;
end;
$function$;

revoke all on function public._notify_game_started() from public, anon, authenticated;
