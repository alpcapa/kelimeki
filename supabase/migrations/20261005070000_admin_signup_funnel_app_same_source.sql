-- Kayıt Hunisi — Uygulama satırının Tamamlaması da `signup_events`ten
-- (1 Ekim 2026'da hazırlandı, #651 ile birlikte).
--
-- ⛔ CANLIYA HENÜZ UYGULANMADI. Sürüm treninde #651 merge edilirken uygula
-- (MCP `apply_migration`), `execute_sql` ile doğrula, `list_migrations`in
-- verdiği gerçek sürümle bu dosyanın adındaki zaman damgasını eşle
-- (`git mv`). Erken uygulanırsa Uygulama satırının Tamamlaması 1.1.2
-- sahaya inene kadar 0 görünür (bugün `profiles`tan geliyor).
--
-- Neden: #651 ile uygulama (1.1.2+) kayıt formunun açılışını VE hesabın
-- oluşmasını bu kimliksiz sayaca yazıyor. Açılış sayaçtan, Tamamlama
-- `profiles`tan okunmaya devam etseydi pay (TÜM sürümlerin hesapları) ile
-- payda (yalnızca 1.1.2+ açılışları) farklı kitleden gelir, oran geçiş
-- boyunca sahte yüksek çıkardı. Web satırının baştan beri uyduğu ilke:
-- ikisi aynı tablodan.
--
-- Bedeli (bilerek): 1.1.2'ye güncellemeyen cihazların hesapları bu satırda
-- görünmez; kartın `?` metni bunu söylüyor.
--
-- İmza ve dönüş tipi DEĞİŞMEDİ → `create or replace` yeterli, izinler korunur
-- (yine de sonda açıkça yeniden yazıldı; `proacl`i merge öncesiyle karşılaştır).

create or replace function public.admin_signup_funnel(p_days integer default 30)
returns table(platform text, starts bigint, completions bigint)
language plpgsql
stable security definer
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
         count(*) filter (where se.event = 'started'),
         count(*) filter (where se.event = 'completed')
  from public.signup_events se
  where se.created_at >= v_since
    and se.platform in ('ios', 'android');
end;
$function$;

revoke all on function public.admin_signup_funnel (integer) from public, anon;
grant execute on function public.admin_signup_funnel (integer) to authenticated, service_role;
