-- Harfik — eski 2 parametreli admin_game_activity_series aşırı yüklemesini temizle
--
-- Bir önceki migration create or replace yerine yeni bir 4 parametreli
-- imza eklediği için eski (periods, granularity) 2 parametreli sürüm PostgreSQL'de
-- ayrı bir fonksiyon olarak kalmıştı (overload). PostgREST bu belirsizlikte
-- hangi aşırı yüklemeyi çağıracağını bilemediğinden RPC çağrıları hataya
-- düşüyordu — eski aşırı yükleme kaldırılıyor.

drop function if exists public.admin_game_activity_series (integer, text);
