-- Retention kohort tablosu: SÜREN hafta da dönüyor, `is_partial` ile işaretli
-- (3 Ekim 2026, kullanıcı: "retention grafiğinde son hafta niye yok?" →
-- "süren haftayı soluk renkle göster").
--
-- Öncesi: yalnızca TAMAMLANMIŞ haftalar dönüyordu — yarım bir hafta yapay
-- olarak düşük görünüp tablonun son köşegenini yalancı bir "düşüş" gibi
-- gösterirdi. O gerekçe DURUYOR; çözüm artık hücreyi gizlemek değil
-- işaretlemek: bir hücrenin penceresi başladıysa (başlangıcı <= şimdi) satır
-- döner, penceresi henüz bitmediyse `is_partial = true`. İstemci onu soluk
-- çizer ve CSV'ye KOYMAZ (CSV öncesiyle aynı: yalnızca tamamlanmış hücreler).
-- Böylece yeni kayıt haftası (ör. 28.09 kohortu, 22 üye) hafta bitmeden
-- tabloda görünür.
--
-- Dönüş tipi değiştiği için `create or replace` YETMEZ; kural `drop` +
-- `create` ama araç `drop function`ı yıkıcı sayıp kullanıcı onayı bekliyor
-- (3 Ekim 2026: üç deneme 60 sn'de zaman aşımına uğradı, `lock_timeout`
-- koymak bile değiştirmedi → sebep DB kilidi DEĞİL, araç onayı). Bu yüzden
-- YENİ AD: `admin_retention_cohorts_v2`. Bonus: bayat (önbellekteki) eski web
-- istemcisi eski fonksiyonu çağırmaya devam eder ve süren haftayı hiç görmez
-- — "soluk işaretsiz yarım hafta" penceresi hiç doğmaz.
-- ⚠ ESKİ `admin_retention_cohorts(integer)` canlıda DURUYOR ve artık
-- kullanılmıyor; silmek için bir `drop function` onayı gerekir
-- (ROADMAP'te açık iş).
-- `proacl` (eski): postgres + service_role + authenticated, `anon` YOK —
-- yenisine de aynısı verildi.

create function public.admin_retention_cohorts_v2(p_cohorts integer default 8)
returns table(
  cohort_week date,
  cohort_size bigint,
  week_offset integer,
  active_users bigint,
  is_partial boolean
)
language plpgsql
stable
security definer
set search_path to 'public', 'auth'
as $function$
declare
  v_now timestamp := now() at time zone 'Europe/Istanbul';
  v_first timestamp := date_trunc('week', v_now) - (greatest(p_cohorts, 1) - 1) * interval '1 week';
begin
  if not is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with cohort_members as (
    select
      date_trunc('week', u.created_at at time zone 'Europe/Istanbul') as cw,
      u.id as user_id
    from auth.users u
    where date_trunc('week', u.created_at at time zone 'Europe/Istanbul') >= v_first
  ),
  sizes as (
    select cm.cw, count(*) as n from cohort_members cm group by cm.cw
  ),
  cells as (
    select s.cw, s.n, o.off
    from sizes s
    cross join generate_series(0, greatest(p_cohorts, 1) - 1) as o (off)
    where s.cw + o.off * interval '1 week' <= v_now
  )
  select
    c.cw::date as cohort_week,
    c.n as cohort_size,
    c.off as week_offset,
    (
      select count(distinct a.user_id)
      from public._admin_user_activity a
      join cohort_members cm on cm.user_id = a.user_id and cm.cw = c.cw
      where (a.created_at at time zone 'Europe/Istanbul') >= c.cw + c.off * interval '1 week'
        and (a.created_at at time zone 'Europe/Istanbul') <  c.cw + (c.off + 1) * interval '1 week'
    ) as active_users,
    (c.cw + (c.off + 1) * interval '1 week' > v_now) as is_partial
  from cells c
  order by c.cw, c.off;
end;
$function$;

revoke all on function public.admin_retention_cohorts_v2(integer) from public, anon, authenticated;
grant execute on function public.admin_retention_cohorts_v2(integer) to authenticated, service_role;
