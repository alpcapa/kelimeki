-- Kelimeki — misafir ziyaretlerine cihaz tipi ve ana ekrana ekleme (standalone) etiketi
--
-- Ziyaret rakamlarının mobil/masaüstü ve "ana ekrana eklenmiş mi" diye
-- ayrıştırılabilmesi için — guest_visits şimdiye kadar bu bilgileri
-- tutmuyordu. device_type istemci tarafında `(pointer: coarse)` media
-- query'sinden ("mobile"/"desktop"), is_standalone ise `display-mode:
-- standalone`/`navigator.standalone`'dan (bkz. src/utils/visitTracking.ts,
-- getDeviceType/isStandaloneDisplay) okunuyor.

alter table public.guest_visits
  add column if not exists device_type text,
  add column if not exists is_standalone boolean;

comment on column public.guest_visits.device_type is 'İstemci tarafında (pointer: coarse) media query''sinden okunan kaba cihaz tipi: "mobile" ya da "desktop". Eski kayıtlarda (bu sütun eklenmeden önce) null.';
comment on column public.guest_visits.is_standalone is 'Ziyaret anında sayfanın ana ekrana eklenip bağımsız (standalone) modda mı, yoksa normal tarayıcıda mı açık olduğu. Eski kayıtlarda (bu sütun eklenmeden önce) null.';

-- Büyüme > Kullanıcı: cihaz tipi başına benzersiz misafir ziyaretçi sayısı
-- (admin_guest_source_breakdown ile aynı basit toplam döküm deseni).
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
  group by 1
  order by visitors desc;
end;
$$;

revoke all on function public.admin_guest_device_breakdown (integer) from public, anon;
grant execute on function public.admin_guest_device_breakdown (integer) to authenticated;

-- Büyüme > Kullanıcı: ana ekrana eklenmiş (standalone) mi diye benzersiz
-- misafir ziyaretçi sayısı.
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
  group by 1
  order by visitors desc;
end;
$$;

revoke all on function public.admin_guest_standalone_breakdown (integer) from public, anon;
grant execute on function public.admin_guest_standalone_breakdown (integer) to authenticated;
