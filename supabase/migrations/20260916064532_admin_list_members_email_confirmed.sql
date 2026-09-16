-- Kelimeki — Üyeler tablosuna E-POSTA ONAYI kolonu (16 Eylül 2026, ROADMAP #9)
--
-- Kullanıcı isteği: *"üyeler tablosuna onay kolonu ekleyecektik"*. ROADMAP
-- #9 ("onaylanmamış filtresi") aynı işin öteki yarısı — filtre de bu kolon
-- olmadan kurulamıyordu.
--
-- ⚠ `auth.users.email_confirmed_at` istemciye KAPALI; `admin_list_members`
-- zaten `security definer` + `search_path = public, auth` olduğundan alanı
-- görebiliyor, ama bugüne kadar HİÇ döndürmüyordu.
--
-- ⚠ `create or replace` YETMEZ — dönüş TABLE'ına sütun ekleniyor, önce drop.
-- Grant'ler drop ile birlikte düştüğü için ELLE geri kuruluyor (kayıtlı
-- tuzak: `fix_withdraw_report_wrong_overload`). Canlıdan okunan değerler:
-- `security definer`, `search_path = public, auth`, execute →
-- `authenticated` + `service_role`.
--
-- ⚠⚠ **`revoke ... from public` ANON'U KAPSAMAZ — ayrıca revoke ET.** Bu
-- canlıda ölçüldü: drop+create'ten sonra ACL `{postgres, ANON, authenticated,
-- service_role}` çıktı, oysa öncesinde `anon` YOKTU. Supabase yeni
-- fonksiyonlara varsayılan olarak `anon`a da execute veriyor ve `public`ten
-- revoke etmek DOĞRUDAN verilmiş bir grant'i düşürmüyor. Fonksiyon girişte
-- `is_admin()` kontrol ettiğinden veri sızmazdı, ama bu depo yüzeyi bilerek
-- daraltıyor (`revoke_anon_identity_leak`, 5 Eylül 2026) — dönüş tipi
-- değişen HER fonksiyonda bu satır tekrar gerekir.
--
-- ⚠ Gövdenin geri kalanı BİREBİR korundu (tek ekleme `u.email_confirmed_at`);
-- drop+create bir yeniden yazma fırsatı DEĞİL, aksi halde ilgisiz bir
-- davranış değişikliği bu migration'a sessizce binerdi.
--
-- Canlıda ölçüldü (16 Eylül 2026): 56 hesabın 52'si onaylı, 4'ü onaysız ve
-- dördü de 1 GÜNDEN yeni. Bu tesadüf değil — `sweep-unconfirmed-accounts`
-- 48 saat sonra onaysız hesabı SİLİYOR (bkz. `docs/decisions/friends.md`),
-- yani bu kolon yapısı gereği yalnızca son 48 saatin penceresini gösterir.

drop function if exists public.admin_list_members ();

create function public.admin_list_members ()
returns table (
  id uuid,
  email text,
  email_confirmed_at timestamptz,
  username text,
  first_name text,
  last_name text,
  display_name text,
  gender text,
  birth_date date,
  avatar_url text,
  agreed_to_terms boolean,
  marketing_consent boolean,
  marketing_consent_at timestamptz,
  email_notifications_enabled boolean,
  is_admin boolean,
  signup_channel text,
  signup_utm_source text,
  invited_by_name text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  banned_until timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    u.id,
    u.email::text,
    -- E-posta onayı (16 Eylül 2026, ROADMAP #9). `auth.users` istemciye
    -- KAPALI, yani bu alan yalnızca bu security-definer RPC üzerinden
    -- görülebilir. Zaman damgası dönüyor, bayrak değil: "ne zaman
    -- onayladı" sorusu da bedava geliyor ve istemci `!= null` ile bayrağa
    -- indirebiliyor.
    u.email_confirmed_at,
    p.username,
    p.first_name,
    p.last_name,
    p.display_name,
    p.gender,
    p.birth_date,
    p.avatar_url,
    coalesce(p.agreed_to_terms, false),
    coalesce(p.marketing_consent, false),
    p.marketing_consent_at,
    coalesce(p.email_notifications_enabled, true),
    coalesce(p.is_admin, false),
    coalesce(p.signup_channel, 'direct'),
    p.signup_utm_source,
    -- Daveti gönderen üyenin görünen adı. Herkese açık kısa kimlik kuralı
    -- (nickname → ad) burada BİLEREK kullanılmıyor: bu satır yalnızca
    -- admin'e dönüyor ve "kim davet etti" sorusunun cevabı olarak tam ad
    -- daha kullanışlı.
    nullif(trim(coalesce(pi.display_name, trim(coalesce(pi.first_name, '') || ' ' || coalesce(pi.last_name, '')))), '') as invited_by_name,
    u.created_at,
    u.last_sign_in_at,
    u.banned_until
  from auth.users u
  left join public.profiles p on p.id = u.id
  left join public.profiles pi on pi.id = p.invited_by
  order by u.created_at desc;
end;
$$;

revoke all on function public.admin_list_members () from public;
revoke all on function public.admin_list_members () from anon;
grant execute on function public.admin_list_members () to authenticated, service_role;
