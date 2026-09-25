-- Kelimeki — "Oyun Dağılımı": biten oyunların İKİ kırılımı (Büyüme > Oyun)
-- 22 Eylül 2026, kullanıcı isteği: *"Admin Oyun altına 2 pie chart yanyana.
-- 1. Yapay zeka vs Arkadaşınla  2. 2 player vs 4 player (biten count)"*
--
-- ⚠ TEK RPC, İKİ PASTA — bilerek: ikisi de AYNI popülasyonu (pencerede biten
-- oyun) bölüyor, yani toplamları birbirini TUTMAK ZORUNDA. İki ayrı RPC
-- olsaydı pencereler sessizce ayrışabilir ve yan yana duran iki pasta iki
-- farklı toplam gösterirdi — `admin_active_hours` ↔ `admin_active_days` için
-- yazılmış kuralın aynısı, burada daha da bağlayıcı çünkü iki pasta tek bir
-- satırda, yan yana duruyor.
--
-- ⚠ "BİTEN" TANIMI `admin_game_activity_series`in `games_finished`iyle
-- BİREBİR AYNI olmak zorunda — ikisi de aynı sekmede, birkaç satır arayla
-- duruyor:
--   · yerel ("Yapay Zeka ile") = `game_finishes`, `not ended_by_surrender`
--   · canlı ("Arkadaşınla")    = `games`ten `online_game_id` BAŞINA
--                                tekilleştirilmiş, `not bool_or(surrendered)`
-- Teslimle biten oyun hiçbir pastada sayılmaz (o grafikte de ayrı bir seri).
--
-- ⚠ `online_game_states` JOIN'İ SÜS DEĞİL: seri RPC'si canlı oyunları o
-- join'in İÇİNDEN sayıyor. Buradan düşürülürse state satırı olmayan bir canlı
-- oyun pastada görünür, grafikte görünmez — ve fark "biten oyun" sayısında
-- sessiz bir sapma olarak kalır.
--
-- ⚠ "Arkadaşınla" OYUN TİPİDİR (Setup'ın sekmesinin adı), "rakip insandı"
-- DEĞİL: canlı bir oyunun boş koltuğu YZ ile doldurulabiliyor — 22 Eylül
-- 2026'da canlıda ölçüldü, 4 kişilik 8 canlı oyunun 5'inde bir `{"type":"ai"}`
-- koltuğu var. Ayrım, kullanıcının oyunu HANGİ SEKMEDEN başlattığıdır.
-- "Rakiplerin kaçı insandı" başka bir soru ve başka bir kırılım
-- (`online_games.slots`) gerektirir; bu RPC onu YANITLAMAZ.
--
-- ⚠ ÜÇÜNCÜ SÜTUN (`finished_total`) ÖLÇÜM DEĞİL, SAĞLAMA: `game_finishes`te
-- `player_count` CHECK'i YOK (`games`/`online_games`te var — 2 ya da 4), yani
-- bir gün 3 kişilik bir satır düşerse ikinci pasta onu sessizce yutardı.
-- Toplam ayrıca döndüğünden `2 + 4 <> toplam` ekranda GÖRÜNÜR hale geliyor.
--
-- PENCERE: sabit `p_days` (varsayılan 30) — `admin_active_hours`/`_days` ile
-- aynı gerekçe: pastalar sekmenin kaynak/oyuncu sayısı kombolarına BAĞLANAMAZ.
-- Bağlansaydı "Canlı" seçili bir pencerede birinci pasta %100 tek dilim,
-- "2 kişilik" seçiliyken ikinci pasta %100 tek dilim olurdu — yani filtre,
-- grafiğin ölçtüğü şeyi yok ederdi.
create or replace function public.admin_game_mix (p_days integer default 30) returns table (
  ai_finished bigint,
  friend_finished bigint,
  p2_finished bigint,
  p4_finished bigint,
  finished_total bigint
) language plpgsql stable security definer
set
  search_path to 'public', 'auth' as $$
declare
  v_days integer := greatest(coalesce(p_days, 30), 1);
  v_since timestamptz := now() - make_interval(days => v_days);
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with yerel as (
    select gf.player_count
    from public.game_finishes gf
    where gf.created_at >= v_since
      and not gf.ended_by_surrender
  ),
  canli_ham as (
    -- Tekilleştirme `online_game_id` başına: bir canlı oyun her oyuncusu için
    -- BİR `games` satırı yazıyor, ham sayım 2 kişilik oyunu iki kez sayardı.
    select
      g.online_game_id,
      max(g.created_at) as finished_at,
      bool_or(g.surrendered) as any_surrendered,
      max(g.player_count) as player_count
    from public.games g
    join public.online_game_states ogs on ogs.online_game_id = g.online_game_id
    where g.online_game_id is not null
    group by g.online_game_id
  ),
  canli as (
    select c.player_count
    from canli_ham c
    where c.finished_at >= v_since
      and not c.any_surrendered
  ),
  hepsi as (
    select 'ai'::text as mod, y.player_count from yerel y
    union all
    select 'friend'::text, c.player_count from canli c
  )
  select
    count(*) filter (where h.mod = 'ai')::bigint,
    count(*) filter (where h.mod = 'friend')::bigint,
    count(*) filter (where h.player_count = 2)::bigint,
    count(*) filter (where h.player_count = 4)::bigint,
    count(*)::bigint
  from hepsi h;
end;
$$;

-- `admin_active_days` ile aynı grant deseni: `anon` AÇIKÇA düşürülüyor
-- (Supabase yeni fonksiyona varsayılan execute veriyor), gerçek kapı yine
-- gövdedeki `is_admin()`.
revoke all on function public.admin_game_mix (integer) from public, anon;

grant execute on function public.admin_game_mix (integer) to authenticated;
