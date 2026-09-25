-- Kelimeki — bildirim izni veren kişilerin sürüm dökümü: platform düzeyi +
-- dürüst TOPLAM (16 Eylül 2026)
--
-- Kullanıcı isteği: tablo platform ana kategorisi altında açılır olsun
-- ("Cihaz"/"Cihaz Markası" tablolarındaki desenin aynısı).
--
-- ⚠ Bunu istemcide TOPLAYAMAZDIK ve mesele estetik değil DOĞRULUK: satırların
-- değeri `count(distinct user_id)`. İki iPhone'u olan biri iki sürüm satırında
-- birden görünür; o satırları toplamak o kişiyi İKİ KEZ sayar. Platform ve
-- genel toplamın kendi `distinct`i olmak zorunda — `grouping sets` tam olarak
-- bunu veriyor.
--
-- Canlıda ölçüldü (16 Eylül 2026): bugün hiç kimse iki gruba birden düşmüyor,
-- yani eski TOPLAM tesadüfen doğruydu. Kural tesadüfe değil sorguya yazılıyor.
--
-- `level` sütunu satırın hangi düzeyde olduğunu söyler:
--   'surum'    → (platform, sürüm) yaprağı
--   'platform' → o platformun toplamı (benzersiz kişi)
--   'toplam'   → genel toplam (benzersiz kişi)
--
-- ⚠ `create or replace` YETMEZ — dönüş TABLE'ına sütun ekleniyor, önce drop.

drop function if exists public.admin_push_version_breakdown (integer);

create function public.admin_push_version_breakdown (p_days integer default 30)
returns table (
  level text,
  platform text,
  app_version text,
  kisi bigint,
  cihaz bigint,
  last_seen timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with t as (
    select
      coalesce(pt.platform, 'bilinmiyor') as plat,
      coalesce(pt.app_version, 'bilinmiyor') as ver,
      pt.user_id,
      pt.updated_at
    from public.push_tokens pt
    where pt.updated_at >= v_since
  )
  select
    (case
      when grouping(t.plat) = 1 then 'toplam'
      when grouping(t.ver) = 1 then 'platform'
      else 'surum'
    end)::text,
    coalesce(t.plat, '')::text,
    coalesce(t.ver, '')::text,
    count(distinct t.user_id)::bigint,
    -- ⚠ "cihaz" DEĞİL, token SATIRI: uygulama yeniden kurulunca/token
    -- yenilenince yeni satır açılır. Canlıda ölçüldü — tek bir iPhone 30
    -- günde 5 satır üretmişti. Hiçbir ekranda gösterilmiyor; adı
    -- `AdminPushVersionRow`de bu notla birlikte duruyor.
    count(*)::bigint,
    max(t.updated_at)
  from t
  group by grouping sets ((t.plat, t.ver), (t.plat), ())
  -- Ağaç sırası: her platform, kendi başlık satırı önce, sürümleri sonra;
  -- genel toplam en sonda. İstemci yine de `level`e göre ayıklıyor — sıralama
  -- bir sözleşme değil, okunabilirlik.
  order by
    grouping(t.plat),
    coalesce(t.plat, ''),
    grouping(t.ver) desc,
    coalesce(t.ver, '');
end;
$$;

revoke all on function public.admin_push_version_breakdown (integer) from public;
grant execute on function public.admin_push_version_breakdown (integer) to authenticated, service_role;
