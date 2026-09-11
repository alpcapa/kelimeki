-- Kelimeki — admin panelinde CİHAZ MODELİ ve İŞLETİM SİSTEMİ SÜRÜMÜ dökümü
--
-- Kullanıcı isteği (11 Eylül 2026): *"Admin kurulu cihaz da görebiliyor
-- muyuz? Iphone 17, 14, Samsung, vb. Onun için ayrı bir tablo mesela."*
--
-- YENİ VERİ TOPLANMIYOR. `device_visits.device_model` ve `os_version`
-- 24 Ağustos 2026'dan beri zaten yazılıyordu; o migration'ın kendi yorumu
-- ikisini de *"şimdilik hiçbir admin ekranında gösterilmiyor"* diye
-- işaretlemişti. Bu migration yalnızca o iki sütunu OKUYAN RPC'leri ekliyor
-- — tablo, RLS, istemci yazımı ve gizlilik beyanı DEĞİŞMİYOR (yeni bir veri
-- sınıfı toplanmadığı için TermsModal/PrivacyModal'a ve mağaza formlarına
-- dokunulmuyor; toplansaydı dokunmak ZORUNLU olurdu).
--
-- ⚠ İki RPC ayrı, tek bir "detay" RPC'si değil: model ve OS sürümü
-- birbirinden bağımsız iki soru ve tabloları ayrı ayrı sıralanıyor.
-- Tek RPC'de birleştirmek çapraz çarpım üretirdi (model × sürüm).
--
-- Desen `admin_device_breakdown`in birebir aynısı: `is_admin()` kapısı,
-- `security definer`, `search_path` sabit, `anon`dan revoke.

-- Büyüme > Kullanıcı: cihaz modeli başına benzersiz ziyaretçi.
-- `device_model` iOS'ta yalnızca "iPhone"/"iPad" (tarayıcı gerçek modeli
-- vermiyor), masaüstünde her zaman null — bu yüzden `device_type` de
-- dönüyor: istemci markayı ondan türetiyor (src/utils/deviceBrand.ts).
create or replace function public.admin_device_model_breakdown (
  p_days integer default 30
)
  returns table (
    device_type   text,
    device_model  text,
    visitors      bigint
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
    coalesce(dv.device_type, 'bilinmiyor') as device_type,
    dv.device_model                        as device_model,
    count(distinct dv.anon_id)             as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
  group by 1, 2
  order by visitors desc, 1, 2;
end;
$$;

revoke all on function public.admin_device_model_breakdown (integer) from public, anon;
grant execute on function public.admin_device_model_breakdown (integer) to authenticated;

-- Büyüme > Kullanıcı: işletim sistemi sürümü başına benzersiz ziyaretçi.
create or replace function public.admin_os_version_breakdown (
  p_days integer default 30
)
  returns table (
    device_type  text,
    os_version   text,
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
    coalesce(dv.device_type, 'bilinmiyor') as device_type,
    dv.os_version                          as os_version,
    count(distinct dv.anon_id)             as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
  group by 1, 2
  order by visitors desc, 1, 2;
end;
$$;

revoke all on function public.admin_os_version_breakdown (integer) from public, anon;
grant execute on function public.admin_os_version_breakdown (integer) to authenticated;
