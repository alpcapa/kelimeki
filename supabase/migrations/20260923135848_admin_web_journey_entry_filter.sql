-- Kelimeki — Ziyaretçi Yolculuğu: YENİ ↔ DÖNEN süzgeci (`admin_web_journey`'e `p_entry`)
--
-- NEDEN (23 Eylül 2026): karta düşen İLK gerçek satır, 22 Ağustos'tan beri
-- 205 oyun başlatmış, hesapsız oynayan düzenli bir Android misafirinindi
-- (kullanıcı fark etti: Android uygulaması henüz Play'de yok, düzenli
-- oyuncular web'den misafir olarak oynuyor). "Nerede bounce ediyor?"
-- sorusu YENİ ziyaretçi hakkında; dönen misafirler uzun oyunlarıyla "oyun
-- bitti" payını şişirip yeni gelenin kaybını gizliyor.
--
-- Ayrım için veri ZATEN var: `web_sessions.entry`. Karşılama sayfası
-- yalnızca ilk kez gelene gösterildiği için:
--   'landing' → yeni ziyaretçi (karşılama sayfasıyla başladı)
--   'app'     → karşılama atlandı. ⚠ Bu, "dönen" ile birebir AYNI DEĞİL:
--               kapı (`scripts/landing-plugin.js` → `kapiScript`) karşılamayı
--               şunlarda da atlıyor: `/` dışındaki her yol (paylaşılan oyun
--               `/game/:id`, davet `/davet/:token` — yani linkle gelen YENİ
--               ziyaretçi de burada) ve ana ekrana eklenmiş PWA. Kartın `?`
--               metni bunu söylüyor.
--
-- `p_entry` null → hepsi (önceki davranış). Parametre EKLENDİĞİ için eski
-- imza DROP ediliyor (`create or replace` iki imzayı yan yana bırakır ve
-- çağrı "function is not unique" verirdi — CLAUDE.md, RPC'ye parametre ekleme).
-- ⚠ Adım listesi (`v_steps`) `src/utils/webJourney.ts` → `JOURNEY_STEPS` ile
-- BİREBİR aynı kalmalı; `npm run verify-web-journey` bu dosyayı da okur.

drop function if exists public.admin_web_journey (integer, text);
drop function if exists public.admin_web_journey (integer, text, text);

create function public.admin_web_journey (
  p_days   integer default 30,
  p_device text default null,
  p_entry  text default null
)
  returns table (
    step           text,
    reached        bigint,
    left_here      bigint,
    median_seconds double precision,
    median_scroll  double precision
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
  v_steps constant text[] := array[
    'landing', 'landing_cta', 'app', 'tutorial_start', 'tutorial_done',
    'game_start', 'first_move', 'move_5', 'game_finish',
    'signup_form', 'signup_done', 'login'
  ];
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with s as (
    select ws.steps, ws.last_step, ws.seconds, ws.scroll_pct
    from public.web_sessions ws
    where ws.created_at >= v_since
      and (p_device is null or ws.device_type = p_device)
      and (p_entry is null or ws.entry = p_entry)
  )
  select k.step,
         (select count(*) from s where k.step = any (s.steps)),
         (select count(*) from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.seconds)
            from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.scroll_pct)
            from s where s.last_step = k.step and s.scroll_pct is not null)
  from unnest(v_steps) with ordinality as k (step, ord)
  order by k.ord;
end;
$function$;

revoke all on function public.admin_web_journey (integer, text, text) from public, anon;
grant execute on function public.admin_web_journey (integer, text, text) to authenticated, service_role;
