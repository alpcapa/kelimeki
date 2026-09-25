-- Kelimeki — `game_finishes.platform` + geriye dönük doldurma (16 Eylül 2026)
--
-- NEDEN: admin panelinin "Oyun Sayısı" grafiği bugün platformu HİÇ göremiyor.
-- `games.platform` var ama `games` satırı yalnızca GİRİŞLİ kullanıcı için
-- açılıyor; grafiğin yerel kolu ise `game_finishes`ten besleniyor ve o tabloda
-- platform kolonu yoktu.
--
-- ⚠ Kolonu eklemek TEK BAŞINA yetmezdi: bu depoda "Platform" tablosu 15
-- Ağustos 2026'da tam bu yüzden KALDIRILMIŞTI (337 oyunun 326'sı "Bilinmiyor"
-- görünüyordu). Bu yüzden kolon geriye dönük DOLDURULUYOR — eşleşme
-- `games`ten, (user_id, player_count, ±120 sn) üçlüsüyle.
--
-- Doldurmadan önce canlıda ölçüldü (16 Eylül 2026, 1.468 satır):
--   · 1.037 satır doldurulabiliyor  (çelişkili eşleşme: 0)
--   ·   240 satır misafir           → `games` satırı hiç açılmadığından
--                                     YAPISAL olarak bilinemez
--   ·   191 satır eski              → `games.platform` 17 Ağustos 2026'dan
--                                     önce yazılmıyordu
-- Yani geçmişin %71'i kurtarılıyor, kalanı dürüstçe NULL kalıyor.
--
-- ⚠ Çelişkili eşleşme (aynı pencerede iki FARKLI platform) NULL bırakılır —
-- `n = 1` koşulu tam olarak bunu zorluyor. Bugün sıfır vaka var, ama kural
-- ölçüme değil kısıta yazılıyor.

alter table public.game_finishes
  add column if not exists platform text;

-- Aynı dörtlü: `games.platform` ve `online_game_clients.platform` ile BİREBİR
-- aynı küme (bkz. `src/utils/platform.ts` ↔ `util/platform.dart`).
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'game_finishes_platform_check'
  ) then
    alter table public.game_finishes
      add constraint game_finishes_platform_check
      check (platform is null or platform in ('web', 'ios', 'android', 'app-web'));
  end if;
end $$;

comment on column public.game_finishes.platform is
  'Bitişi yazan istemci (web/ios/android/app-web). NULL = damgasız: misafir '
  '(games satırı açılmaz) ya da 17 Ağustos 2026 öncesi. 16 Eylül 2026''da '
  'games tablosundan geriye dolduruldu.';

-- ── Geriye doldurma ───────────────────────────────────────────────────────
with eslesme as (
  select
    gf.id,
    (select min(g.platform) from public.games g
      where g.user_id = gf.user_id
        and g.player_count = gf.player_count
        and g.online_game_id is null
        and g.platform is not null
        and abs(extract(epoch from (g.created_at - gf.created_at))) < 120) as platform,
    (select count(distinct g.platform) from public.games g
      where g.user_id = gf.user_id
        and g.player_count = gf.player_count
        and g.online_game_id is null
        and g.platform is not null
        and abs(extract(epoch from (g.created_at - gf.created_at))) < 120) as n
  from public.game_finishes gf
  where gf.user_id is not null
    and gf.platform is null
)
update public.game_finishes gf
set platform = e.platform
from eslesme e
where e.id = gf.id
  and e.n = 1;

-- Grafiğin yerel kolu (bucket, platform) üzerinden gruplanıyor.
create index if not exists game_finishes_created_platform_idx
  on public.game_finishes (created_at, platform);
