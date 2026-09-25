-- Kelimeki — `guest_visits`e ARTIK UYGULAMA DA YAZIYOR; web'e özgü iki
-- döküm bu satırları DIŞARIDA bırakır.
--
-- BAĞLAM (22 Eylül 2026, kullanıcı isteği): Kaynak Hunisi'nde app hiç
-- görünmüyordu — portun dört adımın hiçbirinde damgası yoktu ve app
-- kayıtları `bilinmiyor` satırına düşüyordu (panel bir gün "Üye %2000,0"
-- yazdı). Karar: *"app'i huniye TAM sok"*. Port artık `guest_visits`e de
-- yazıyor (`utm_source = 'app'`, ya da deep link'ten gelen gerçek `?ref=`).
--
-- SORUN: `guest_visits`i huniden BAŞKA iki fonksiyon daha okuyor ve ikisi de
-- WEB'E ÖZGÜ bir soru soruyor. Yeni satır sınıfı eklenince ikisinin de
-- ANLAMI sessizce değişirdi:
--
--   1. `admin_guest_standalone_breakdown` — "ziyaretçilerin kaçı sayfayı ANA
--      EKRANA EKLEDİ (PWA)". Port `is_standalone`ı null yazıyor (native
--      uygulama bu sorunun DIŞINDA — bir tarayıcı sekmesi değil), fonksiyon
--      ise `coalesce(..., false)` yapıyor: yani her app açılışı "eklememiş"
--      sayılır ve PWA benimseme oranı SEYRELİRDİ.
--   2. `admin_guest_device_breakdown` — "MİSAFİR ziyaretçiler hangi
--      cihazdan". Burada da payda web trafiğiydi; app'i katmak bu tabloyu
--      `device_visits` tabanlı "Cihaz" tablosunun kötü bir kopyasına
--      çevirirdi (o zaten girişli+girişsiz HERKESİ sayıyor, 24 Ağustos
--      2026 kararı).
--
-- ÇÖZÜM: iki fonksiyon da `utm_source = 'app'` satırlarını eler. Huni
-- (`admin_source_funnel`) DOKUNULMADI — app'i GÖRMESİ gereken tek yer orası.
--
-- ⚠ BUGÜN BU MIGRATION BİR NO-OP: portun damgalayan sürümü daha sahaya
-- inmedi, yani `utm_source = 'app'` olan tek bir satır bile yok (uygulamadan
-- önce ölçüldü: 0). Bilerek ÖNCE uygulanıyor — sonra uygulanırsa iki tablo
-- port sürümünün sahada olduğu sürece yanlış sayar.
--
-- ⚠ `drop + create` DEĞİL `create or replace`: imza birebir aynı
-- (`(integer)`), yani bu kod tabanının bildiği "sessiz ikinci overload"
-- tuzağı burada oluşamaz — ve `create or replace` grant'leri KORUR, drop
-- ise `security definer`/`search_path`/grant'lerin hepsini düşürür ve
-- Supabase yeni fonksiyona `anon`a da execute verebiliyor (16 Eylül 2026'da
-- `admin_list_members`te canlıda ölçüldü). Burada korumak daha güvenli.
--
-- ⚠ Filtre `= 'app'` (TAM eşleşme), `like 'app%'` DEĞİL: `appstore` gibi bir
-- pazarlama etiketi gerçek bir web kampanyası olabilir ve elenmemeli
-- (istemci tarafı da aynı kuralı uyguluyor — `sourceChannel`, önek değil tam
-- eşleşme arıyor; `npm run verify-admin-groups` ölçüyor).

create or replace function public.admin_guest_standalone_breakdown (
  p_days integer default 30
)
  returns table (
    is_standalone  boolean,
    visitors       bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    coalesce(gv.is_standalone, false) as is_standalone,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    -- Native uygulama "ana ekrana ekledi mi" sorusunun DIŞINDA.
    and coalesce(gv.utm_source, '') <> 'app'
  group by 1
  order by visitors desc;
end;
$$;

create or replace function public.admin_guest_device_breakdown (
  p_days integer default 30
)
  returns table (
    device_type  text,
    visitors     bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    coalesce(gv.device_type, 'bilinmiyor') as device_type,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    -- Bu tablo MİSAFİR WEB trafiğini soruyor; app'in cihaz dağılımı
    -- `device_visits` tabanlı "Cihaz" tablosunun işi.
    and coalesce(gv.utm_source, '') <> 'app'
  group by 1
  order by visitors desc;
end;
$$;
