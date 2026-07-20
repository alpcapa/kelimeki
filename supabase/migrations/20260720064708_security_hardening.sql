-- Harfik — canlıya çıkış öncesi güvenlik sıkılaştırması (Supabase advisor bulguları)
--
-- 1) set_updated_at / harfik_points: search_path sabitlenmemişti (mutable search_path
--    açığı) — ikisine de `set search_path to 'public'` eklendi.
-- 2) handle_new_user: yalnızca `on_auth_user_created` trigger'ı tarafından çağrılması
--    gereken bir fonksiyon, ama public/anon/authenticated ondan EXECUTE alıyordu; yani
--    /rest/v1/rpc/handle_new_user ile dışarıdan doğrudan çağrılabiliyordu. Trigger
--    çalıştırması bu revoke'dan etkilenmez (Postgres trigger fonksiyonlarını çağıran
--    rolün EXECUTE hakkını kontrol etmez).
-- 3) harfik_points: yalnızca migration/seed zamanında SQL içinden çağrılıyor, client hiç
--    rpc() ile çağırmıyor (src/lib/api.ts'de yok) — anon/authenticated'den kaldırıldı.
-- 4) is_admin: yalnızca diğer SECURITY DEFINER admin_* fonksiyonların içinden çağrılıyor
--    (onlar zaten kendi search_path'i altında fonksiyon sahibi olarak çalışıp is_admin'i
--    çağırabilir); client hiç doğrudan çağırmıyor — anon/authenticated'den kaldırıldı.
-- 5) avatars storage bucket'ı zaten public (storage.buckets.public = true), yani objeler
--    /storage/v1/object/public/avatars/... üzerinden RLS'e hiç takılmadan servis ediliyor
--    (src/lib/api.ts yalnızca upload + getPublicUrl kullanıyor, hiç .list() çağırmıyor).
--    avatars_public_read SELECT politikası objeye erişim için gereksizdi, yalnızca
--    bucket'taki TÜM dosya adlarının (storage list endpoint'i ile) dışarıdan
--    listelenmesine izin veriyordu — kaldırıldı.

create or replace function public.set_updated_at ()
  returns trigger
  language plpgsql
  set search_path to 'public'
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.harfik_points (p text)
  returns integer
  language sql
  immutable
  set search_path to 'public'
as $$
  select coalesce(sum(case ch
    when 'a' then 1  when 'b' then 3  when 'c' then 4  when 'ç' then 3
    when 'd' then 3  when 'e' then 1  when 'f' then 7  when 'g' then 5
    when 'ğ' then 8  when 'h' then 5  when 'ı' then 2  when 'i' then 1
    when 'j' then 10 when 'k' then 1  when 'l' then 1  when 'm' then 2
    when 'n' then 1  when 'o' then 2  when 'ö' then 7  when 'p' then 5
    when 'r' then 1  when 's' then 2  when 'ş' then 4  when 't' then 1
    when 'u' then 2  when 'ü' then 3  when 'v' then 7  when 'y' then 3
    when 'z' then 4  else 0 end), 0)::int
  from regexp_split_to_table(lower(p), '') as ch;
$$;

revoke execute on function public.handle_new_user () from public, anon, authenticated;
revoke execute on function public.harfik_points (text) from public, anon, authenticated;
revoke execute on function public.is_admin () from public, anon, authenticated;

drop policy if exists "avatars_public_read" on storage.objects;
