-- Supabase varsayılan yetkileri `anon`/`authenticated`a tam tablo yetkisi verdi
-- (canlıda ölçüldü). RLS açık + politika yok → fiilen erişilemez, ama niyet
-- "yalnızca RPC": açıkça kapatılıyor. İlk migration SIFIRDAN oynatılırsa bu
-- dosya da ardından çalışır.
revoke all on public.hamle_avi_stats from anon, authenticated;
