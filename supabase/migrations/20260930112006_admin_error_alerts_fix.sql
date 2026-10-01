-- Düzeltme (30 Eylül 2026, aynı gün): `admin_alert_scan` ilk çağrıda
-- 42702 verdi — `on conflict (alert_key)`taki ad hem dönüş sütunu (OUT
-- parametresi) hem tablo sütunu, PL/pgSQL hangisi olduğunu bilemiyor.
-- Kısıt adıyla yazıldı; gövdenin geri kalanı AYNI.
create or replace function public.admin_alert_scan()
returns table(alert_key text, category text, kind text, signature text,
              platforms text, hits bigint, devices bigint)
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  return query
  with son as (
    select ce.kind as k, left(ce.message, 160) as sig, ce.platform, ce.anon_id
    from public.client_errors ce
    where ce.created_at >= now() - interval '1 hour'
  ),
  g as (
    select son.k, son.sig,
           string_agg(distinct son.platform, ', ') as plats,
           count(*) as n,
           count(distinct son.anon_id) as d
    from son
    group by son.k, son.sig
  ),
  aday as (
    select case
             when g.sig like '%auth null fırtınası%' or g.sig like '%depo=dolu%' then 'auth'
             when g.k in ('boundary', 'uncaught') and g.d >= 3 then 'crash'
             when g.d >= 10 then 'spike'
           end as cat,
           g.*
    from g
  ),
  iddia as (
    insert into public.admin_alerts as a (alert_key, category, sent_at)
    select aday.cat || ':' || aday.k || '|' || aday.sig, aday.cat, now()
    from aday
    where aday.cat is not null
    on conflict on constraint admin_alerts_pkey do update
      set sent_at = now()
      where a.sent_at < now() - interval '24 hours'
    returning a.alert_key, a.category
  )
  select iddia.alert_key, iddia.category, aday.k, aday.sig, aday.plats, aday.n, aday.d
  from iddia
  join aday on iddia.alert_key = aday.cat || ':' || aday.k || '|' || aday.sig;
end;
$function$;
