-- Admin panelindeki ayrı "Oyunlar" tab'ı kaldırıldı: yalnızca tüm zamanların
-- toplam biten oyun sayısını gösteriyordu, Büyüme > Oyun grafiği (bitirilen/
-- terk edilen sayıları, oturum kırılımı, ortalama süre — zaman serisi olarak)
-- bunun tam bir üst kümesini zaten sağlıyordu. Artık hiçbir yerden
-- çağrılmayan bu RPC'yi düşürüyoruz.
drop function if exists public.admin_game_counts ();
