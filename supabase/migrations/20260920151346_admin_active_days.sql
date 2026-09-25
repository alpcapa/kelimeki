-- Kelimeki — "Aktif Günler": oyun bitişlerinin HAFTANIN GÜNLERİNE dağılımı
-- (20 Eylül 2026, kullanıcı isteği: *"Admin oyunda saatler gibi Aktif Günler
-- bar chartı da koyabilir miyiz?"*)
--
-- `admin_active_hours`ın (20260918101432) ikizi: AYNI kaynak, AYNI pencere,
-- AYNI saat dilimi, AYNI platform kovaları, AYNI teslim kuralı. Tek fark
-- kovanın kendisi — saat dilimi yerine haftanın günü. İki grafik aynı
-- sekmede yan yana duruyor, bu yüzden kurallardan biri değişirse İKİSİ
-- BİRLİKTE değişmeli; ayrışırlarsa aynı popülasyonu iki farklı sayıyla
-- anlatırlar.
--
-- KAYNAK: `game_finishes` — MİSAFİR oyunlarını da kapsayan tek bitiş tablosu
-- (`games` satırı yalnızca girişli kullanıcı için açılıyor).
--
-- SAAT DİLİMİ: `Europe/Istanbul` — deponun tamamının kuralı. Gün kovasında
-- bu saatten de KRİTİK: UTC ile okunsa 00:00–03:00 arasındaki her bitiş bir
-- ÖNCEKİ güne düşer ve hafta sonu/hafta içi ayrımı sessizce kayar.
--
-- ⚠ HAFTA PAZARTESİ BAŞLAR — `isodow` (1=Pzt … 7=Paz), `dow` DEĞİL.
-- Postgres'in `dow`u 0=Pazar ile başlar; onunla çizilen grafik Türkçe bir
-- panelde haftayı Pazar'dan açar ve hafta sonu çubukları grafiğin iki
-- ucuna dağılır (Pazar en solda, Cumartesi en sağda) — desen okunamaz.
-- `isodow` ile Cmt+Paz yan yana, sağ uçta duruyor.
--
-- PENCERE: sabit `p_days` (varsayılan 30) — `admin_active_hours` ile AYNI,
-- bilerek. İki grafik aynı popülasyonu betimliyor; pencereler ayrışsa
-- toplamları birbirini tutmaz ve "neden farklı" sorusu her seferinde
-- yeniden sorulur. 30 gün her güne ~4 örnek ama ~170 bitiş düşürüyor
-- (son 30 günde 1199 bitiş ölçüldü, 18 Eylül 2026) — hacim yeterli.
--
-- ⚠ TESLİM SATIRLARI DIŞARIDA (`not ended_by_surrender`) ve bu kovada
-- gerekçe SAAT kovasındakinden DAHA GÜÇLÜ: teslim, 7 günlük terk-edilme ya
-- da 48 saatlik sıra zaman aşımının DOLDUĞU anı taşır. Yedi günlük bir
-- gecikme haftanın gününü KORUR, yani her teslim satırı terk edildiği günün
-- kovasına düşer ve dağılıma insan davranışıyla ilgisi olmayan bir ikinci
-- desen bindirir. Son 30 günde 152 teslim / 1199 bitirilen = %11.
--
-- "Diğer" kovasının tanımı `admin_active_hours` ve
-- `admin_game_activity_series` ile BİREBİR aynı:
-- `platform is null or platform = 'app-web'`.
--
-- ⚠ PLATFORM KIRILIMI BUGÜN YARIM — `admin_active_hours`takiyle aynı,
-- geçici durum: `game_finishes.platform`ı yalnızca WEB istemcisi yazıyor,
-- portun aynı satırı (`games_api.dart`) inceleme dondurması yüzünden ayrı
-- bir PR'da bekliyor. O merge edilip yeni mağaza paketi dağılana kadar
-- app'ten biten oyunlar "Diğer"e düşer.
--
-- DEĞİŞMEZ: web + ios + android + other HER ZAMAN finished'a TAM toplanır —
-- grafiğin YIĞILMIŞ çubukları buna dayanıyor.

create or replace function public.admin_active_days (
  p_days integer default 30
) returns table (
  dow smallint,
  finished bigint,
  finished_web bigint,
  finished_ios bigint,
  finished_android bigint,
  finished_other bigint
) language plpgsql stable security definer
set search_path = public, auth
as $$
declare
  v_days integer := greatest(coalesce(p_days, 30), 1);
  v_since timestamptz := now() - make_interval(days => v_days);
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  -- 7 gün HER ZAMAN döner (bitişi olmayan gün dahil) — grafik eksiği
  -- "veri yok" diye değil "sıfır" diye çizmeli, yoksa çubuklar kayar.
  with gunler as (
    select g::smallint as dow from generate_series(1, 7) as g
  ),
  bitisler as (
    select
      extract(isodow from (gf.created_at at time zone 'Europe/Istanbul'))::smallint as dow,
      gf.platform
    from public.game_finishes gf
    where gf.created_at >= v_since
      and not gf.ended_by_surrender
  )
  select
    d.dow,
    -- ⚠ `count(b.dow)`, `count(*)` DEĞİL: left join'de eşleşme olmayan gün
    -- için `count(*)` 1 döndürür ve boş gün 1 görünür.
    count(b.dow)::bigint,
    count(*) filter (where b.platform = 'web')::bigint,
    count(*) filter (where b.platform = 'ios')::bigint,
    count(*) filter (where b.platform = 'android')::bigint,
    -- Aynı tuzağın ikinci yüzü: `b.dow is not null` şartı OLMADAN,
    -- eşleşmeyen günde `b.platform is null` doğru çıkıp boş günü
    -- "Diğer"de 1 gösterirdi.
    count(*) filter (
      where b.dow is not null
        and (b.platform is null or b.platform = 'app-web')
    )::bigint
  from gunler d
  left join bitisler b on b.dow = d.dow
  group by d.dow
  order by d.dow;
end;
$$;

comment on function public.admin_active_days (integer) is
  'Admin: oyun bitişlerinin haftanın günlerine dağılımı (isodow, 1=Pazartesi; Europe/Istanbul), platform kırılımıyla. Teslim satırları hariç.';

revoke all on function public.admin_active_days (integer) from public, anon;
grant execute on function public.admin_active_days (integer) to authenticated;
