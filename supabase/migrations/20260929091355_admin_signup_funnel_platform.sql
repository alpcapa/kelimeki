-- Kayıt Hunisi: kanal yerine PLATFORM satırları (Web · Uygulama) + toplam
-- (29 Eylül 2026).
--
-- Kullanıcı: *"Kayıt hunisi de uzun zamandır 1 duruyor"* → *"Web ve App
-- (ya da ios, android) diye 2 satırda göstersek, altta toplamla birlikte."*
-- Kart yalnızca web'i sayıyordu (`signup_events`'e yalnızca web yazıyor);
-- 21 Eylül'den beri açılan iki hesabın ikisi de uygulamadandı ve kartta
-- hiç görünmüyordu.
--
-- Satırlar:
--   web → Açılış + Tamamlama `signup_events`ten (platform = 'web'), eskisi gibi.
--   app → Açılış `signup_events`ten (platform ios/android). BUGÜN 0: port
--         bu olayları Firebase'e yazıyor, bu tabloya değil. İstemci 0'ı
--         "ölçülmüyor" (—) diye gösterir.
--         Tamamlama `profiles`tan: pencerede açılan hesap, uygulamadan
--         (`signup_utm_source = 'app'`, ya da damgasız + push token'ı var —
--         1.1.0 bazı kayıtları damgasız bırakıyor, 24 Eyl vakası).
-- ⚠ ORTAK BAŞLANGIÇ: pencere en erken `signup_events`in doğduğu an
-- (21 Eylül 2026 12:40 UTC, #600). Aksi hâlde web satırı 8 günü, uygulama
-- satırı 30 günü sayardı (ilk denemede web 0 · uygulama 11 çıktı; web'in
-- 21 Eylül öncesi 6 kaydı sayacın doğmadığı günlerdeydi).
-- ⚠ iOS / Android ayrımı YOK: 30 günde uygulamadan açılan 11 hesabın
-- yalnızca 3'ünde platform izi (push token / oyun) vardı. Doğru ayrım
-- portun `signup_events`e platformuyla yazmasıyla gelir (mobil iş).
--
-- Dönüş tipi değişti → DROP + CREATE; grant'ler öncesiyle aynı
-- (authenticated + service_role, anon YOK).
drop function if exists public.admin_signup_funnel (integer);

create function public.admin_signup_funnel (p_days integer default 30)
  returns table (
    platform    text,
    starts      bigint,
    completions bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
declare
  v_since timestamptz := greatest(
    now() - (greatest(p_days, 1) || ' days')::interval,
    timestamptz '2026-09-21 12:40:00+00'
  );
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select 'web'::text,
         count(*) filter (where se.event = 'started'),
         count(*) filter (where se.event = 'completed')
  from public.signup_events se
  where se.created_at >= v_since
    and coalesce(se.platform, 'web') = 'web'
  union all
  select 'app'::text,
         (select count(*) from public.signup_events se
           where se.created_at >= v_since and se.event = 'started'
             and se.platform in ('ios', 'android')),
         (select count(*) from public.profiles p
           where p.created_at >= v_since
             and (p.signup_utm_source = 'app'
                  or (p.signup_utm_source is null
                      and exists (select 1 from public.push_tokens t where t.user_id = p.id))));
end;
$function$;

revoke all on function public.admin_signup_funnel (integer) from public, anon;
grant execute on function public.admin_signup_funnel (integer) to authenticated, service_role;
