-- profiles/games'in yeni SELECT politikaları RLS USING ifadesinde is_admin()
-- çağırıyor. is_admin() EXECUTE izni önceden yalnızca authenticated'e
-- verilmişti (bkz. security_hardening migration'ı) — anon rolünün de bu
-- politikaları değerlendirebilmesi (auth.uid() null olduğundan hep false
-- dönecek, güvenlik açısından zararsız) için anon'a da execute veriliyor.
-- Aksi halde girişsiz bir REST isteği "boş sonuç" yerine
-- "permission denied for function is_admin" hatası alıyordu.
grant execute on function public.is_admin() to anon;
