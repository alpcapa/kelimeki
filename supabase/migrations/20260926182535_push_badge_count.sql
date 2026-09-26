-- Kelimeki — iOS simge rozeti sayacı (ROADMAP #25, 26 Eylül 2026)
--
-- SORUN (18 Eylül, kullanıcı): *"Apple uyarılar geliyor ama ikon üzerinde
-- numara çıkmıyor"*. iOS'ta rozet YALNIZCA `aps.badge`den gelir ve
-- `_shared/push.ts` onu hiç göndermiyordu (Android'de One UI sayıyı
-- paneldeki bildirimlerden kendisi türettiği için orada sorun yok).
--
-- SAYININ TANIMI (kullanıcı kararı, 26 Eylül): *"Bildirimlerde ne varsa
-- onlar. Her bildirim sayıyı arttırmalı."* → sayı = uygulama son
-- açıldığından beri bu CİHAZA giden bildirim sayısı.
--
-- CİHAZ başına (token satırında), kullanıcı başına DEĞİL: iPhone'da açılan
-- uygulama iPad'in simgesindeki sayıyı sıfırlamamalı, ve sıfırlanmamış bir
-- cihazın sayacı öteki cihazın açılışıyla 0'a düşüp "5"ten "1"e atlamamalı.
--
-- SIFIRLAMA `register_push_token`da: uygulama onu HER açılışta ve HER öne
-- dönüşte zaten çağırıyor (`pushTokenlariHizala` → `PushRepo.kaydet`), yani
-- yeni bir RPC ya da istemci değişikliği gerekmiyor. Cihazdaki simgeyi
-- `AppDelegate.swift` (`setBadgeCount(0)`) sıfırlıyor.
--
-- ⚠ Rozet yalnızca iOS ≥ 1.1.2 cihazlara GÖNDERİLİYOR (`ROZET_ILK_SURUM`,
-- `_shared/push.ts`) — daha eskisi simgeyi sıfırlayamaz. Sayaç ise herkes
-- için artmaz: `bump_push_badge`ı yalnızca o kapıdan geçen satır için
-- çağırıyoruz.

alter table public.push_tokens
  add column if not exists badge_count integer not null default 0;

comment on column public.push_tokens.badge_count is
  'iOS simge rozeti: uygulama son açıldığından beri bu cihaza giden bildirim sayısı. bump_push_badge artırır, register_push_token sıfırlar.';

-- ── Sıfırlama: gövde değişti, İMZA aynı → `create or replace` yeterli ve
-- mevcut grant'ler (proacl) korunur.
create or replace function public.register_push_token (
  p_token text,
  p_platform text,
  p_app_version text default null
) returns void
  language plpgsql
  security definer
  set search_path to 'public'
  as $function$
begin
  if auth.uid() is null then
    raise exception 'Oturum gerekli.';
  end if;
  if p_token is null or length(p_token) < 20 then
    raise exception 'Geçersiz token.';
  end if;
  if p_platform not in ('android', 'ios') then
    raise exception 'Geçersiz platform: %', p_platform;
  end if;

  insert into public.push_tokens (token, user_id, platform, app_version, badge_count, updated_at)
  values (p_token, auth.uid(), p_platform, left(p_app_version, 32), 0, now())
  on conflict (token) do update
    set user_id = auth.uid(),
        platform = excluded.platform,
        -- ⚠ `coalesce` YOK ve bu bilinçli: eski istemci null gönderirse satır
        -- null'a DÖNMELİ (bkz. 20260831093203_push_token_app_version.sql).
        app_version = excluded.app_version,
        -- Uygulama açıldı/öne döndü → kullanıcı bildirimleri gördü.
        badge_count = 0,
        updated_at = now();
end;
$function$;

-- ── Artırma: yalnızca Edge Function'lar (service_role) çağırır. Atomik
-- (`update ... returning`), çünkü aynı kullanıcıya iki fonksiyon aynı anda
-- bildirim gönderebilir (ör. "sıra sende" + süre uyarısı).
create or replace function public.bump_push_badge (p_token text)
  returns integer
  language sql
  security definer
  set search_path to 'public'
  as $function$
  update public.push_tokens
     set badge_count = badge_count + 1
   where token = p_token
  returning badge_count;
$function$;

-- ⚠ Supabase yeni fonksiyona varsayılan olarak anon/authenticated'a da
-- execute veriyor ve `revoke ... from public` doğrudan verilmiş grant'i
-- DÜŞÜRMÜYOR — üçü de açıkça geri alınıyor.
revoke all on function public.bump_push_badge (text) from public, anon, authenticated;
grant execute on function public.bump_push_badge (text) to service_role;
