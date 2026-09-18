-- Kelimeki — "Aktif Saatler": oyun bitişlerinin 2 saatlik dilimlere dağılımı
-- (18 Eylül 2026, kullanıcı isteği: *"Admin oyun sayfasına Aktif Saatler bar
-- grafiği eklemek istiyorum. 2 saatlik dilimler olsun. Web, ios ve android
-- kırılımları olursa iyi olur. Oyun bitişleri baz alalım."*)
--
-- KAYNAK: `game_finishes` — MİSAFİR oyunlarını da kapsayan tek bitiş tablosu
-- (`games` satırı yalnızca girişli kullanıcı için açılıyor, yani oradan
-- okunsa grafiğin misafir kolu tamamen kör kalırdı).
--
-- SAAT DİLİMİ: `Europe/Istanbul`. Bu bir tercih değil, deponun tamamının
-- kuralı (bkz. 20260722190455_admin_game_istanbul_tz_and_surrender_split).
-- "Aktif saatler" sorusunda UTC kullanmak dağılımı 3 saat kaydırıp grafiği
-- sessizce yanlış okuturdu — burada saat dilimi süs değil, metriğin kendisi.
--
-- PENCERE: sabit `p_days` (varsayılan 30). Grafik, sekmedeki kaynak/kapsam/
-- oyuncu sayısı kombolarına BİLEREK bağlı DEĞİL (kullanıcı kararı, 18 Eylül
-- 2026) — kendi başına duran bir günlük ritim dağılımı.
--
-- ⚠ TESLİM SATIRLARI DIŞARIDA (`not ended_by_surrender`). Bu grafiğin özel
-- gerekçesi var, mevcut "Oyun Sayısı" grafiğininkinden farklı: teslim satırı
-- 7 günlük/48 saatlik zaman aşımının DOLDUĞU anı taşır, bir insanın oyun
-- bitirdiği anı değil. Dahil edilseydi dağılıma insan davranışıyla ilgisi
-- olmayan bir saat deseni karışırdı. Son 30 günde 152 teslim / 1199
-- bitirilen (canlıda ölçüldü, 18 Eylül 2026) — yani %11, yuvarlama hatası
-- değil. Platform kırılımının `not ended_by_surrender` ile sınırlı olması
-- ayrıca `admin_game_activity_series` ile de tutarlı.
--
-- ⚠ PLATFORM KIRILIMI BUGÜN YARIM — ve bu BEKLENEN, geçici bir durum:
-- `game_finishes.platform`ı yalnızca WEB istemcisi yazıyor; portun aynı
-- satırı (`games_api.dart`) inceleme dondurması yüzünden AYRI bir PR'da
-- bekliyor (`api.ts` → `logGameFinish` aynı uyarıyı taşıyor). O merge edilip
-- yeni bir mağaza paketi dağılana kadar app'ten biten oyunlar "Diğer"e
-- düşer. Canlıda ölçüldü (18 Eylül 2026): 17 Eylül'ün 89 bitişinden 54'ü
-- platformsuz, android/ios 16 Eylül'de sıfırlandı. Öncesindeki android/ios
-- satırları CANLI VERİ DEĞİL — 20260916054513'ün `games`ten geriye
-- doldurduğu satırlar.
--
-- "Diğer" kovasının tanımı `admin_game_activity_series` ile BİREBİR aynı
-- tutuldu: `platform is null or platform = 'app-web'`. İki grafik aynı
-- sekmede yan yana duruyor, kovaların anlamı ayrışırsa sayılar birbirini
-- tutmaz.
--
-- DEĞİŞMEZ: web + ios + android + other HER ZAMAN finished'a TAM toplanır —
-- grafiğin YIĞILMIŞ çubukları buna dayanıyor.

create or replace function public.admin_active_hours (
  p_days integer default 30
) returns table (
  hour_start smallint,
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
  -- 12 dilim HER ZAMAN döner (gece 02-04 gibi boş saatler dahil) — grafik
  -- eksiği "veri yok" diye değil "sıfır" diye çizmeli, yoksa çubuklar kayar.
  with dilimler as (
    select g::smallint as hour_start from generate_series(0, 22, 2) as g
  ),
  bitisler as (
    select
      (((extract(hour from (gf.created_at at time zone 'Europe/Istanbul'))::integer / 2) * 2))::smallint
        as hour_start,
      gf.platform
    from public.game_finishes gf
    where gf.created_at >= v_since
      and not gf.ended_by_surrender
  )
  select
    d.hour_start,
    -- ⚠ `count(b.hour_start)`, `count(*)` DEĞİL: left join'de eşleşme
    -- olmayan dilim için `count(*)` 1 döndürür ve boş saatler 1 görünür.
    count(b.hour_start)::bigint,
    count(*) filter (where b.platform = 'web')::bigint,
    count(*) filter (where b.platform = 'ios')::bigint,
    count(*) filter (where b.platform = 'android')::bigint,
    -- Aynı tuzağın ikinci yüzü: `b.hour_start is not null` şartı OLMADAN,
    -- eşleşmeyen dilimde `b.platform is null` doğru çıkıp boş saati
    -- "Diğer"de 1 gösterirdi.
    count(*) filter (
      where b.hour_start is not null
        and (b.platform is null or b.platform = 'app-web')
    )::bigint
  from dilimler d
  left join bitisler b on b.hour_start = d.hour_start
  group by d.hour_start
  order by d.hour_start;
end;
$$;

comment on function public.admin_active_hours (integer) is
  'Admin: oyun bitişlerinin 2 saatlik dilimlere dağılımı (Europe/Istanbul), platform kırılımıyla. Teslim satırları hariç.';

revoke all on function public.admin_active_hours (integer) from public, anon;
grant execute on function public.admin_active_hours (integer) to authenticated;
