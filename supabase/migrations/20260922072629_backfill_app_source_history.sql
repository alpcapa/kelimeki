-- Kelimeki — GEÇMİŞ damgasız satırlar `'app'`e çevriliyor (22 Eylül 2026).
--
-- BAĞLAM: port 22 Eylül 2026'ya kadar huninin dört adımının hiçbirinde
-- kaynak damgası yazmıyordu, bu yüzden app'ten gelen her şey panelde
-- `bilinmiyor` satırına düşüyordu (kullanıcı bildirdi: *"bilinmeyen 1, üye
-- 20… %2000 conversion not possible"*). Damga aynı gün eklendi; bu migration
-- GEÇMİŞİ hizalıyor, yoksa "Bilinmiyor" satırı aylarca dolu görünecekti.
--
-- ⚠ BU BİR VERİ YENİDEN YAZIMI — kullanıcının açık onayıyla yapıldı.
--
-- DAYANAK: `NULL ⟺ app`. Web İSTEMCİSİ HİÇBİR ZAMAN NULL YAZMAZ, `?ref=`
-- yokken bile açıkça `'direkt'` gönderir — üç çağrı yerinin üçünde de
-- (`src/lib/api.ts`: `signUp` → `getStoredUtmSource() ?? 'direkt'`,
-- `logGameStart` → `utmSource ?? 'direkt'`, `logGameFinish` →
-- `getStoredUtmSource() ?? 'direkt'`). Yani damgalama başladıktan SONRAKİ
-- bir NULL yalnızca damgalamayan istemciden, yani Flutter portundan gelebilir.
--
-- ÖLÇÜLDÜ (uygulamadan önce, canlıda):
--   · `profiles`: 20 damgasız kaydın 8'inin App (iOS/Android) oyunu VAR,
--     **0'ının web oyunu var**, 11'i hiç oynamamış. Tek karşı örnek yok.
--     Damgalı gruplarda ise web oyunu var — desen temiz.
--   · `game_starts`: damgalama 21 Ağustos'ta başladı ve ÖNCESİNDE TEK BİR
--     NULL BİLE YOK → 868 satırın tamamı damgalama sonrası, yani app.
--   · `game_finishes`: damgalama 2026-08-22 15:10:05.39781+00'da başladı.
--     ÖNCESİNDEKİ 310 SATIR BİLEREK DIŞARIDA — onlarda kolon henüz yoktu,
--     yani "app" değil GERÇEKTEN "bilinmiyor". Onları çevirmek uydurma olurdu.
--
-- ⚠ `profiles` için TETİKLEYİCİ GEÇİCİ OLARAK KAPATILIYOR:
-- `trg_keep_signup_utm_source` BEFORE UPDATE'te `new.signup_utm_source :=
-- old.signup_utm_source` yapıyor (kullanıcı kendi kayıt kaynağını
-- değiştiremesin diye). Düz bir `update` bu yüzden SESSİZCE hiçbir şey
-- yapmaz — denenmeden "çalıştı" sanılabilirdi. Kapatma/açma bu migration'ın
-- işlemi içinde; işlem geri alınırsa tetikleyici de geri gelir.

alter table public.profiles disable trigger trg_keep_signup_utm_source;

update public.profiles
   set signup_utm_source = 'app'
 where signup_utm_source is null;

alter table public.profiles enable trigger trg_keep_signup_utm_source;

update public.game_starts
   set utm_source = 'app'
 where utm_source is null;

update public.game_finishes
   set utm_source = 'app'
 where utm_source is null
   -- İlk damgalı bitişin anı; öncesi "kolon yoktu" demek (yukarı bkz.).
   and created_at >= '2026-08-22 15:10:05.39781+00';
