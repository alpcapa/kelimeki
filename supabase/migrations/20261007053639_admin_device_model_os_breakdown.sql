-- Admin > Büyüme > Kullanıcı > "Cihaz" ağacı: Platform > Marka > Model > İşletim sistemi sürümü.
-- Mevcut iki RPC (`admin_device_model_breakdown`, `admin_os_version_breakdown`) AYRI sorular soruyor;
-- model × sürüm ÇAPRAZI yalnızca tek satırda (`device_visits`) mümkün. Salt-okunur, admin kapılı.
-- Aynı süzgeçler: pencere + bot dışı (`os_version is distinct from 'bot'`).
create or replace function public.admin_device_model_os_breakdown(p_days integer default 30)
 returns table(device_type text, device_model text, os_version text, visitors bigint)
 language plpgsql
 stable security definer
 set search_path to 'public', 'auth'
as $function$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    coalesce(dv.device_type, 'bilinmiyor') as device_type,
    dv.device_model                        as device_model,
    dv.os_version                          as os_version,
    count(distinct dv.anon_id)             as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    and dv.os_version is distinct from 'bot'
  group by 1, 2, 3
  order by visitors desc, 1, 2, 3;
end;
$function$;

revoke all on function public.admin_device_model_os_breakdown (integer) from public, anon;
grant execute on function public.admin_device_model_os_breakdown (integer) to authenticated;
