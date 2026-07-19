-- Harfik — eski 2 parametreli admin_game_activity_series aşırı yüklemesini temizle
--
-- Bir önceki migration CREATE OR REPLACE yerine yeni bir 4 parametreli imza
-- eklediği için eski (periods, granularity) 2 parametreli sürüm PostgreSQL'de
-- ayrı bir fonksiyon olarak kalmıştı (overload) — bu, production'da doğrudan
-- (bu dosya yazılmadan) tespit edilip düşürülmüştü; repo ile production'ın
-- migration geçmişini birebir eşleştirmek için burada da kayda geçiriliyor.

drop function if exists public.admin_game_activity_series (integer, text);
