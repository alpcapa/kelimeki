-- Harfik — profiles.first_name / last_name asla boş olamaz.
--
-- Kayıt formu (AuthModal) bunu zaten client tarafında zorunlu tutuyordu, ama
-- veritabanında bir karşılığı yoktu — ör. Hesap Ayarları'ndan bu alanlar
-- boşa çekilebiliyordu. Şimdi DB seviyesinde de garanti altına alınıyor.
alter table public.profiles
  add constraint profiles_first_name_not_blank check (length(trim(first_name)) > 0),
  add constraint profiles_last_name_not_blank check (length(trim(last_name)) > 0);
