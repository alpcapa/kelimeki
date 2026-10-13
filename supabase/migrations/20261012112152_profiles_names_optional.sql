-- Ad/soyad isteğe bağlı: sunucu kısıtları kaldırılıyor (12 Ekim 2026).
--
-- 2 Ekim'de (#779) kayıt formunda ad/soyad isteğe bağlı oldu (mobil: 1.1.3,
-- 11 Ekim). Dokümandaki "sunucu değişmedi, boş ad baştan beri kabul
-- ediliyordu" YANLIŞTI: `profiles_name_required` (17 Temmuz) iki CHECK
-- kısıtı koymuştu; `handle_new_user` boş adı `''` yazar, kısıt reddeder,
-- GoTrue işlemi geri alıp istemciye yalnızca genel "Database error saving
-- new user" (500) döndürür. Adı boş bırakan her yeni kullanıcı kayıt
-- olamıyordu (Android 1.1.3'te 11 Ekim'den beri; web'de 3 Ekim `{}`).
-- Kanıt dolaylı: başarısız denemelerin gövdesi işlemle birlikte geri
-- alındığından kayıtlı değil; zamanlama ve kısıt mantığı örtüşüyor.
--
-- Kolonlar `NOT NULL default ''` KALIR; yalnızca "boş olamaz" kısıtları
-- gider. Okuyucular tarandı: tüm Edge Function'lar `display_name ||
-- first_name` (takma isim zorunlu), istemcilerde `first_name[0]` benzeri
-- indeksleme yok.

alter table public.profiles
  drop constraint if exists profiles_first_name_not_blank,
  drop constraint if exists profiles_last_name_not_blank;
