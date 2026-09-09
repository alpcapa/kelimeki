-- Aktivasyon paneli: "İlk Oyuna Medyan Süre" kutusu yerine "İlk Saatte Aktive"
-- sayısı (9 Eylül 2026, kullanıcı sorusu: *"ilk oyuna medyan süre hep 2,3 saat"*).
--
-- NEDEN: medyan donmuş değildi, GERÇEKTEN 2,3 saatti — ama hiçbir kullanıcı
-- 2,3 saat sürmemişti. Canlıdan ölçüldü (30 aktive üye): 15 kişi ilk 1 saatte
-- (0,00–0,87 sa), sonraki en küçük değer 3,68 sa. Yani dağılım ÇİFT TEPELİ ve
-- `percentile_cont` çift sayıda gözlemde 15. ve 16. değeri interpolasyonla
-- ortalıyor — (0,87 + 3,68) / 2 = 2,27 → aradaki BOŞLUĞA düşüyor. Sayı ancak
-- yeni bir aktivasyon o boşluğa denk gelirse kıpırdıyor, o yüzden "hep aynı"
-- görünüyordu.
--
-- Medyan silinMEDİ (dağılım satırında duruyor, tanımı da `?` popup'ında); ama
-- kutuda artık gözlenmiş bir sayı var: kaç üye ilk SAATTE aktive oldu. Bu eşik
-- ürünün gerçek sorusunu soruyor — "kaydolduğu oturumda oynadı mı".
--
-- ⚠ `create or replace` YETMEZ: dönüş tipine kolon eklemek Postgres'te
-- "cannot change return type of existing function" verir; önce drop.

drop function if exists public.admin_activation_stats();

create or replace function public.admin_activation_stats()
returns table(
  total_users bigint,
  activated_users bigint,
  never_activated bigint,
  activated_within_1h bigint,
  activated_same_day bigint,
  activated_within_3_days bigint,
  activated_later bigint,
  median_hours_to_first_game numeric
)
language plpgsql
stable
security definer
set search_path to 'public', 'auth'
as $$
begin
  if not is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with firsts as (
    select
      u.created_at as signed_up,
      (select min(g.created_at) from public.games g where g.user_id = u.id) as first_game
    from auth.users u
  ),
  gaps as (
    select
      f.first_game is not null as activated,
      greatest(f.first_game - f.signed_up, interval '0') as gap
    from firsts f
  )
  select
    count(*)::bigint,
    count(*) filter (where activated)::bigint,
    count(*) filter (where not activated)::bigint,
    -- "İlk saatte" ile "aynı gün" KÜMÜLATİF ve iç içe (1 sa ⊂ 24 sa) — üçlü
    -- dağılım satırı (aynı gün / 1-3 gün / sonra) ise ayrık kalıyor, toplamı
    -- hâlâ `activated_users`. İki kutu bir huni okuyor, satır bir dağılım.
    count(*) filter (where activated and gap < interval '1 hour')::bigint,
    count(*) filter (where activated and gap < interval '1 day')::bigint,
    count(*) filter (where activated and gap >= interval '1 day' and gap < interval '3 days')::bigint,
    count(*) filter (where activated and gap >= interval '3 days')::bigint,
    round(
      percentile_cont(0.5) within group (
        order by (case when activated then extract(epoch from gap) / 3600.0 end)::double precision
      )::numeric,
      1
    )
  from gaps;
end;
$$;

revoke all on function public.admin_activation_stats() from public, anon, authenticated;
grant execute on function public.admin_activation_stats() to authenticated;

comment on function public.admin_activation_stats() is
  'Admin — aktivasyon oranı, hiç oyun bitirmemiş üye sayısı, ilk oyuna kadar '
  'geçen sürenin medyanı ve dağılımı. `activated_within_1h` ve `activated_same_day` '
  'kümülatif (iç içe); `activated_same_day`/`activated_within_3_days`/`activated_later` '
  'üçlüsü ayrık ve toplamı `activated_users`.';
