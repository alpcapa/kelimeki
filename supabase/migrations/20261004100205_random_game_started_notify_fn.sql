-- Rastgele Oyuncu — "oyun başladı" push'u (4 Ekim 2026, kullanıcı: bildirim
-- olmadan ilan sahibi oyunun açıldığını bilemez, oyun açık kalır).
--
-- Neden mevcut tetikleyici yetmedi: `_notify_your_turn` yalnızca
-- `online_game_states.current` GÜNCELLENİNCE koşar. Oyun dolunca
-- `init_online_game_state` o satırı INSERT eder → sıra el değiştirmez →
-- ilk sıradaki (ilan sahibi) hiçbir şey almaz.
--
-- Kapsam bilerek DAR: yalnızca koltuklarından biri `via: random` taşıyan
-- oyunlar. Normal davetli oyunun başlangıç davranışı DEĞİŞMEZ.
-- Gövde yalnızca oyun id'si taşır; hedefi/metni `notify-your-turn` canlı
-- durumdan kendisi okur (verify_jwt KAPALI güvenlik simetrisi).
create or replace function public._notify_random_game_started()
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
    where og.id = new.online_game_id
      and og.status = 'active'
      and jsonb_path_exists(og.slots, '$[*] ? (@.via == "random")')
  ) then
    return new;
  end if;

  perform net.http_post(
    url := 'https://xvqlizifakkkoqahaxsg.supabase.co/functions/v1/notify-your-turn',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := jsonb_build_object('online_game_id', new.online_game_id)
  );
  return new;
end;
$function$;

revoke all on function public._notify_random_game_started() from public, anon, authenticated;
