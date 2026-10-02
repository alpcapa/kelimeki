-- Beyin Ligi: `beyin_ligi_siralama`ya Supabase'in varsayılan ACL'si
-- `authenticated`a YAZMA izinlerini de (arwdDxtm) vermişti — bir önceki
-- migration'daki `grant select` bunları silmiyor. `k_lig_siralama` ile aynı
-- hâle (`authenticated=r`) daraltıldı. Canlıda ölçüldü, 2 Ekim 2026.
revoke all on public.beyin_ligi_siralama from authenticated;
grant select on public.beyin_ligi_siralama to authenticated;
