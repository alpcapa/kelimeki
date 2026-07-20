-- Admin "Oyunlar" tab'ındaki "Başlatılan" sayacı kaldırıldı: yalnızca
-- gerçekten biten oyun sayısı (games tablosu) önemli, game_starts'a göre
-- karşılaştırma gereksiz görüldü. (game_starts tablosu ve loglaması
-- kaldırılmadı — Büyüme > Oyun grafiğindeki ayrı "Başlatılan" serisi ve
-- Misafir/Kayıtlı ayrımı hâlâ buna dayanıyor.)
--
-- Dönüş tipi (RETURNS TABLE kolonları) değiştiği için CREATE OR REPLACE
-- FUNCTION yetmiyor — fonksiyon önce düşürülüyor.

drop function if exists public.admin_game_counts ();

create or replace function public.admin_game_counts ()
  returns table (
    player_count integer,
    finished     bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    g.player_count,
    count(*) as finished
  from public.games g
  group by g.player_count
  order by g.player_count;
end;
$$;

revoke all on function public.admin_game_counts () from public, anon;
grant execute on function public.admin_game_counts () to authenticated;
