-- Kritik hata uyarısı — admine push + e-posta (30 Eylül 2026).
--
-- Kullanıcı: *"ben bunlara bakmazsam sorunu zamanında görmek zor. Kritik bir
-- sorun olduğunda bana email veya başka şekilde bir uyarı gelse iyi olur."*
-- Kararlar (aynı gün, kullanıcı seçti): kanal PUSH + E-POSTA; kritik =
-- (1) çökme/yakalanmamış hata ≥3 cihaz/saat, (2) herhangi bir hata ≥10
-- cihaz/saat, (3) oturum fırtınası (`auth-null-burst` ya da `depo=dolu`,
-- tek cihazda bile); artı her sabah günlük özet.
--
-- Karar SQL'de, gönderim Edge Function'da (`notify-admin-alerts`). Neden:
-- "aynı uyarı 24 saatte bir kez" iddiası ATOMİK olmalı — cron 15 dakikada
-- bir, uç herkese açık (`verify_jwt:false`); iki eşzamanlı çağrı aynı
-- uyarıyı iki kez göndermesin. `insert … on conflict do update … where`
-- satırı yalnızca kazanan çağrıya döndürür.
--
-- İmza = `kind` + mesajın ilk 160 karakteri — Hatalar sekmesinin
-- (`admin_client_errors`) gruplamasıyla AYNI, uyarıdaki metin panelde
-- bulunabilsin diye.

create table if not exists public.admin_alerts (
  alert_key  text primary key,
  category   text not null check (category in ('crash', 'spike', 'auth', 'daily')),
  sent_at    timestamptz not null default now()
);
alter table public.admin_alerts enable row level security;
-- Yalnızca sunucu okur/yazar; istemci bu tabloyu HİÇ görmez (politika yok,
-- anon/authenticated'a grant yok).
revoke all on public.admin_alerts from anon, authenticated;
grant select, insert, update, delete on public.admin_alerts to service_role;

-- Tarama: son 1 saatte eşiği aşan ve son 24 saatte uyarılmamış imzalar.
-- Döndürülen her satır İDDİA EDİLMİŞTİR (admin_alerts'a yazıldı); gönderim
-- düşerse o imza 24 saat susar — kaçan uyarıyı günlük özet yakalar.
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
    on conflict (alert_key) do update
      set sent_at = now()
      where a.sent_at < now() - interval '24 hours'
    returning a.alert_key, a.category
  )
  select iddia.alert_key, iddia.category, aday.k, aday.sig, aday.plats, aday.n, aday.d
  from iddia
  join aday on iddia.alert_key = aday.cat || ':' || aday.k || '|' || aday.sig;
end;
$function$;

-- Günlük özet: son 24 saatin en çok cihaz etkileyen imzaları. İstanbul günü
-- başına BİR kez (aynı gün ikinci çağrı boş döner).
create or replace function public.admin_alert_daily(p_limit integer default 5)
returns table(signature text, kind text, platforms text, hits bigint, devices bigint,
              total_hits bigint, total_devices bigint)
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_key text := 'daily:' || to_char(now() at time zone 'Europe/Istanbul', 'YYYY-MM-DD');
  v_claimed text;
begin
  insert into public.admin_alerts (alert_key, category)
  values (v_key, 'daily')
  on conflict (alert_key) do nothing
  returning alert_key into v_claimed;
  if v_claimed is null then
    return;
  end if;

  return query
  with son as (
    select ce.kind as k, left(ce.message, 160) as sig, ce.platform, ce.anon_id
    from public.client_errors ce
    where ce.created_at >= now() - interval '24 hours'
  ),
  t as (select count(*) as th, count(distinct son.anon_id) as td from son),
  g as (
    select son.sig, son.k,
           string_agg(distinct son.platform, ', ') as plats,
           count(*) as n, count(distinct son.anon_id) as d
    from son group by son.sig, son.k
  )
  -- Hiç hata yoksa da TEK satır döner (toplamlar 0): "sessiz gün" de haber.
  select g.sig, g.k, g.plats, g.n, g.d, t.th, t.td
  from t left join g on true
  order by g.d desc nulls last, g.n desc nulls last
  limit greatest(p_limit, 1);
end;
$function$;

revoke all on function public.admin_alert_scan() from public, anon, authenticated;
revoke all on function public.admin_alert_daily(integer) from public, anon, authenticated;
grant execute on function public.admin_alert_scan() to service_role;
grant execute on function public.admin_alert_daily(integer) to service_role;

-- Zamanlama: tarama 15 dakikada bir (notify-deadline-warnings'le aynı
-- desen: pg_net, JWT'siz — fonksiyon `verify_jwt:false`), günlük özet
-- 06:00 UTC = 09:00 İstanbul.
select cron.schedule(
  'notify-admin-alerts-scan',
  '*/15 * * * *',
  $$
  select net.http_post(
    url := 'https://xvqlizifakkkoqahaxsg.supabase.co/functions/v1/notify-admin-alerts',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := '{"mode": "scan"}'::jsonb
  );
  $$
);
select cron.schedule(
  'notify-admin-alerts-daily',
  '0 6 * * *',
  $$
  select net.http_post(
    url := 'https://xvqlizifakkkoqahaxsg.supabase.co/functions/v1/notify-admin-alerts',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := '{"mode": "daily"}'::jsonb
  );
  $$
);
