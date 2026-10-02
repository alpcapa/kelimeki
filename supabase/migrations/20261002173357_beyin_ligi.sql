-- Beyin Ligi (2 Ekim 2026, kullanıcı kararı) — k-lig'in ikinci alt ligi.
--
-- k-lig penceresi artık iki sekme taşıyor: "Puan Ligi" (bugünkü k-lig,
-- DEĞİŞMEDİ) ve "Beyin Ligi". Beyin Ligi'nde puan yok: oyuncular yalnızca
-- OHP'ye (ortalama hamle puanı, `leaderboard.avg_move_score` — Skor Kartı'ndaki
-- ve Puan Ligi'nin OHP sütunundaki AYNI sayı) göre sıralanır.
--
-- Kararlar (kullanıcı onayı, 2 Ekim 2026):
--   * Giriş eşiği: hamle verisi olan EN AZ 5 oyun. Eşiksiz liste ölçüldü:
--     ilk iki sıra 1 ve 2 oyunluk hesaplardı (15.23 · 15.21) — tek bir
--     şanslı oyun ligi kazanıyordu. 5 oyunla 26 kişi.
--     ⚠ Eşik ÜÇ yerde: bu dosya (`ohp_games >= 5`), web
--     `src/utils/beyinLigi.ts` (`BEYIN_LIGI_MIN_GAMES`), port
--     `util/beyin_ligi.dart`. `npm run verify-beyin-ligi` üçünü kilitler.
--   * YZ oyunları DAHİL (bugünkü OHP'nin aynısı; yeni bir hesap yok).
--   * Eşitlik: OHP (2 basamak) eşitse OHP'li oyun sayısı çok olan üstte,
--     o da eşitse user_id (sayfalama kararlı kalsın — k_lig_siralama dersi).
--   * Rütbe mührü / ödül YOK — yalnızca sıralama.
--
-- Neden `leaderboard`a sütun EKLENİYOR (ayrı bir toplama yerine):
-- `profiles`in SELECT politikası "yalnızca kendin ya da admin"; ad/avatar'ı
-- herkese açan tek yol `leaderboard` view'ı (sahibin haklarıyla koşar).
-- `k_lig_siralama` da bu yüzden onun üstüne kurulu. Yeni view aynı deseni
-- izliyor: `security_invoker`, yalnızca `authenticated` okur.
-- `create or replace view` sütunu SONA eklediği sürece mevcut grant'leri ve
-- okuyucuları (`fetchRankScores`, portun `rankScores`ı — ikisi de sütun
-- seçerek okuyor) etkilemez.

-- 1) leaderboard + ohp_games (gövde 20260906114252 ile birebir, yalnızca
--    son sütun yeni)
create or replace view public.leaderboard as
 SELECT g.user_id,
    p.username,
    p.first_name,
    p.last_name,
    p.display_name,
    p.avatar_url,
    max(g.player_score) AS best_score,
    (sum(public.league_points_for(g.rank, g.player_count, g.surrendered, g.ai_level))
      + COALESCE(( SELECT sum(r.points) AS sum
           FROM league_rewards r
          WHERE r.user_id = g.user_id), 0::bigint))::integer AS total_score,
    count(*) AS games_played,
    count(*) FILTER (WHERE g.result = 'win'::text) AS wins,
    COALESCE(( SELECT max(r.threshold) AS max
           FROM league_rewards r
          WHERE r.user_id = g.user_id AND r.kind = 'rank_up'::text), 0) AS rank_tier,
    round(sum(g.move_points_sum) FILTER (WHERE g.move_points_sum IS NOT NULL)::numeric / NULLIF(sum(g.move_count) FILTER (WHERE g.move_points_sum IS NOT NULL), 0)::numeric, 2) AS avg_move_score,
    count(*) FILTER (WHERE g.move_points_sum IS NOT NULL) AS ohp_games
   FROM games g
     JOIN profiles p ON p.id = g.user_id
  GROUP BY g.user_id, p.username, p.first_name, p.last_name, p.display_name, p.avatar_url
  ORDER BY ((sum(public.league_points_for(g.rank, g.player_count, g.surrendered, g.ai_level))
      + COALESCE(( SELECT sum(r.points) AS sum
           FROM league_rewards r
          WHERE r.user_id = g.user_id), 0::bigint))::integer) DESC;

-- 2) beyin_ligi_siralama — sıra SUNUCUDA (k_lig_siralama deseni): liste ile
--    "senin sıran" aynı sayıyı ancak böyle gösterir.
create view public.beyin_ligi_siralama
with (security_invoker = true) as
select row_number() over (
         order by l.avg_move_score desc, l.ohp_games desc, l.user_id
       ) as sira,
       l.user_id,
       l.username,
       l.first_name,
       l.last_name,
       l.display_name,
       l.avatar_url,
       l.ohp_games,
       l.avg_move_score
from public.leaderboard l
where l.avg_move_score is not null
  and l.ohp_games >= 5;

revoke all on public.beyin_ligi_siralama from public, anon;
grant select on public.beyin_ligi_siralama to authenticated;
grant select on public.beyin_ligi_siralama to service_role;

-- 3) my_beyin_ligi_rank — eşiğin ALTINDAKİ oyuncu da bir satır alır
--    (rank = null): istemci "N oyun daha" kartını OHP'si ve oyun sayısıyla
--    çizebilsin. Hiç oyun bitirmemiş kullanıcı için satır YOK.
create function public.my_beyin_ligi_rank(p_user_id uuid)
returns table(rank bigint, avg_move_score numeric, ohp_games bigint)
language sql
stable
set search_path to 'public'
as $function$
  select b.sira, l.avg_move_score, l.ohp_games
  from public.leaderboard l
  left join public.beyin_ligi_siralama b on b.user_id = l.user_id
  where l.user_id = p_user_id;
$function$;

revoke execute on function public.my_beyin_ligi_rank(uuid) from public, anon;
grant execute on function public.my_beyin_ligi_rank(uuid) to authenticated, service_role;
