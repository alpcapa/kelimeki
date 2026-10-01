-- Kelimeki — kendini bot olarak tanıtan ziyaretleri admin SAYIMLARINDAN çıkar
--
-- NEDEN (30 Eylül 2026, kullanıcı kararı: *"Evet, botları sayımdan çıkar"*):
-- 23 Eylül'den beri `visitTracking.ts` kendini bot olarak tanıtan istemcileri
-- (`isBotUserAgent`, açık liste) `os_version = 'bot'` diye İŞARETLİYOR ama
-- sayıyordu: önce ölçmek istendi. Bir haftalık döküm kararı verdi:
-- 27 bot cihaz (16 masaüstü, 7 "Android", 4 "iOS"), SIFIR oyun, 15/16'sı tek
-- ziyaret; üstelik 28 Eylül'de Meta kampanyası kurulurken reklam inceleme
-- botları etiketli linkleri (`meta-kare`, `meta-karusel`, `meta-reel`)
-- ziyaret edip kampanya satırlarını şişirmişti (`meta-reel`: 15 gelenin 3'ü).
--
-- ⚠ SATIRLAR SİLİNMİYOR, yalnızca admin SORGULARI onları saymıyor. Karar geri
-- alınabilir kalsın diye (filtreyi kaldırmak yeter). Aynı bilinçli seçim
-- `funnel_events` yazıcısında İSTEMCİ tarafında yapılmıştı (bot hiç yazmıyor);
-- buradaki tablolar ise zaten dolu olduğundan süzgeç sorguda.
--
-- ⚠ `is distinct from`, `<>` DEĞİL: `os_version` null olabilir (Linux'tan
-- önceki satırlar, iPad) ve `null <> 'bot'` null döner → satır düşerdi.
--
-- ⚠ Kendini TANITMAYAN botlar (Linux kimliğiyle gelenler, Meta'nın Windows
-- gibi görünen inceleme sistemleri) bu süzgeçten GEÇER: onları ayıracak bir
-- işaret yok ve tahmine dayalı süzgeç kullanıcı kararıyla reddedildi.
--
-- Sekiz fonksiyonun da imzası ve dönüş tipi DEĞİŞMİYOR → `create or replace`
-- grant'leri, `security definer`ı ve `search_path`i korur. Gövdeler canlıdan
-- (`pg_get_functiondef`, 30 Eylül 2026) alındı; tek fark bot süzgeci.
-- `admin_source_funnel`, `admin_guest_source_breakdown`,
-- `admin_guest_device_breakdown`, `admin_guest_standalone_breakdown` bugün
-- ekrandan çağrılmıyor ama duruyor — tutarlılık için onlar da süzülüyor.

create or replace function public.admin_device_breakdown(p_days integer default 30)
 returns table(device_type text, visitors bigint)
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
    count(distinct dv.anon_id) as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    and dv.os_version is distinct from 'bot'
  group by 1
  order by visitors desc;
end;
$function$;

create or replace function public.admin_device_model_breakdown(p_days integer default 30)
 returns table(device_type text, device_model text, visitors bigint)
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
    count(distinct dv.anon_id)             as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    and dv.os_version is distinct from 'bot'
  group by 1, 2
  order by visitors desc, 1, 2;
end;
$function$;

create or replace function public.admin_os_version_breakdown(p_days integer default 30)
 returns table(device_type text, os_version text, visitors bigint)
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
    dv.os_version                          as os_version,
    count(distinct dv.anon_id)             as visitors
  from public.device_visits dv
  where dv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    and dv.os_version is distinct from 'bot'
  group by 1, 2
  order by visitors desc, 1, 2;
end;
$function$;

create or replace function public.admin_guest_device_breakdown(p_days integer default 30)
 returns table(device_type text, visitors bigint)
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
    coalesce(gv.device_type, 'bilinmiyor') as device_type,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    -- Bu tablo MİSAFİR WEB trafiğini soruyor; app'in cihaz dağılımı
    -- `device_visits` tabanlı "Cihaz" tablosunun işi.
    and coalesce(gv.utm_source, '') <> 'app'
    and gv.os_version is distinct from 'bot'
  group by 1
  order by visitors desc;
end;
$function$;

create or replace function public.admin_guest_standalone_breakdown(p_days integer default 30)
 returns table(is_standalone boolean, visitors bigint)
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
    coalesce(gv.is_standalone, false) as is_standalone,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    -- Native uygulama "ana ekrana ekledi mi" sorusunun DIŞINDA.
    and coalesce(gv.utm_source, '') <> 'app'
    and gv.os_version is distinct from 'bot'
  group by 1
  order by visitors desc;
end;
$function$;

create or replace function public.admin_guest_source_breakdown(p_days integer default 30)
 returns table(source text, visitors bigint)
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
    coalesce(gv.utm_source, 'direkt') as source,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
    and gv.os_version is distinct from 'bot'
  group by 1
  order by visitors desc;
end;
$function$;

create or replace function public.admin_source_funnel(p_days integer default 30)
 returns table(source text, visitors bigint, starts bigint, starters bigint, signups bigint, finishes bigint, finishers bigint, member_games bigint, players bigint, signup_players bigint)
 language plpgsql
 stable security definer
 set search_path to 'public', 'auth'
as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with v as (
    select coalesce(gv.utm_source, 'direkt') as src,
           count(distinct gv.anon_id) as n
    from public.guest_visits gv
    where gv.created_at >= v_since
      and gv.os_version is distinct from 'bot'
    group by 1
  ),
  st as (
    select coalesce(gs.utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gs.anon_id) as uniq
    from public.game_starts gs
    where gs.created_at >= v_since
      and gs.is_guest is true
    group by 1
  ),
  fi as (
    select coalesce(gf.utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gf.anon_id) as uniq
    from public.game_finishes gf
    where gf.created_at >= v_since
      and gf.user_id is null
    group by 1
  ),
  s as (
    select coalesce(p.signup_utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(*) filter (
             where exists (select 1 from public.games gm where gm.user_id = p.id)
           ) as pl
    from public.profiles p
    where p.created_at >= v_since
    group by 1
  ),
  g as (
    select coalesce(p.signup_utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gm.user_id) as pl
    from public.games gm
    join public.profiles p on p.id = gm.user_id
    where gm.created_at >= v_since
    group by 1
  ),
  k as (
    select src from v
    union select src from st
    union select src from fi
    union select src from s
    union select src from g
  )
  select k.src,
         coalesce(v.n, 0),
         coalesce(st.n, 0),
         coalesce(st.uniq, 0),
         coalesce(s.n, 0),
         coalesce(fi.n, 0),
         coalesce(fi.uniq, 0),
         coalesce(g.n, 0),
         coalesce(g.pl, 0),
         coalesce(s.pl, 0)
  from k
  left join v on v.src = k.src
  left join st on st.src = k.src
  left join fi on fi.src = k.src
  left join s on s.src = k.src
  left join g on g.src = k.src
  order by coalesce(v.n, 0) desc, coalesce(st.n, 0) desc, coalesce(s.n, 0) desc, k.src;
end;
$function$;

create or replace function public.admin_user_activity_series(p_periods integer default 30, p_granularity text default 'day'::text)
 returns table(bucket date, signups bigint, guest_visits bigint)
 language plpgsql
 stable security definer
 set search_path to 'public', 'auth'
as $function$
declare
  v_unit text := case
    when p_granularity = 'year' then 'year'
    when p_granularity = 'month' then 'month'
    when p_granularity = 'week' then 'week'
    else 'day'
  end;
  v_step interval := case
    when v_unit = 'year' then interval '1 year'
    when v_unit = 'month' then interval '1 month'
    when v_unit = 'week' then interval '1 week'
    else interval '1 day'
  end;
  v_end timestamp := date_trunc(v_unit, now() at time zone 'Europe/Istanbul');
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date     as bucket,
    coalesce(u.cnt, 0) as signups,
    coalesce(gv.cnt, 0) as guest_visits
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.bucket = d.bucket
  left join (
    select
      date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket,
      count(distinct anon_id) as cnt
    from public.guest_visits
    where os_version is distinct from 'bot'
    group by 1
  ) gv on gv.bucket = d.bucket
  order by d.bucket;
end;
$function$;
