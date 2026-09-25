-- Kelimeki — masaüstü kipindeki iPad'lerin sahte "10.15.7" sürümünü düzelt
--
-- NEDEN (23 Eylül 2026, kullanıcı fark etti: *"Admin Cihaz ios altında
-- 10.15.7 gözüken 27 kişi var. Bu masaüstünde de olan bir versiyon."*):
-- iPadOS 13+ Safari varsayılan olarak "masaüstü sitesi" kipinde açılıyor ve
-- User-Agent'ı bir Mac'inkiyle birebir aynı (`Macintosh; Intel Mac OS X
-- 10_15_7`). `getDeviceType` bu cihazları dokunmatik olduklarından DOĞRU
-- biçimde `ios`a ayırıyordu, ama `getOsVersion` `Mac OS X` dalına düşüp
-- Apple'ın bütün Mac'lerde SABİTLEDİĞİ `10.15.7`yi yazıyordu ve
-- `getDeviceModel` boş dönüyordu. Gerçek iPadOS sürümü bu kipte hiç
-- gönderilmiyor. İstemci düzeltmesi aynı PR'da (`src/utils/visitTracking.ts`
-- → `isDesktopModeIPad`): sürüm artık null, model 'iPad'.
--
-- Bu migration GEÇMİŞİ aynı kurala getiriyor. Eşleşme kesin: `ios` + `10.15`
-- ile başlayan sürüm yalnızca bu kipten gelebilir (gerçek bir iOS sürümü
-- 10.15 hiç olmadı; iOS 10'un son sürümü 10.3.4). Canlıda eşleşen bütün
-- satırlarda model zaten boştu.
--
-- İki tablo da düzeltiliyor çünkü iki yazıcı AYNI yardımcıları kullanıyor:
-- `device_visits` ("Cihaz" tablosu, herkes) ve `guest_visits` (misafir).

update public.device_visits
set os_version = null,
    device_model = coalesce(device_model, 'iPad')
where device_type = 'ios'
  and os_version like '10.15%';

update public.guest_visits
set os_version = null,
    device_model = coalesce(device_model, 'iPad')
where device_type = 'ios'
  and os_version like '10.15%';
