-- Ziyaretçi Yolculuğu: "hemen çıkan" sütunu + görünür süre (15 Ekim 2026).
--
-- `visibility_probe` ölçümü (docs/decisions/admin-panel.md → "Yığılmanın
-- kaynağını bulma", ADIM 2 BULGUSU): Android + Meta uygulama-içi tarayıcıda
-- "31-33 sn'de ayrılan" oturumlar gerçekte yüklemeden ~2 sn sonra gizleniyor,
-- ~30 sn sonra webview tarafından yıkılıyor. İstemci o ana kadarki DUVAR SAATİNİ
-- yazdığı için `web_sessions.seconds` ~32 çıkıyordu (son 7 gün, Android Meta:
-- 848 oturumun %35'i 30-35 sn, ortanca 32 sn).
--
-- İKİ parça (kullanıcı kararı, "1 + 2"):
--   1. İSTEMCİ artık GÖRÜNÜR süreyi yazıyor (`src/utils/webJourney.ts`, bu
--      migration'dan bağımsız, sunucuda `record_web_session` DEĞİŞMEDİ —
--      `greatest(eski, yeni)` görünür süreyle de doğru). ⚠ Geçmiş satırlar
--      DÜZELMEZ (görünür süre hiç kaydedilmemişti): admin'in 7/30 günlük
--      penceresi geçiş tarihinden (15 Ekim 2026) sonra karışık veri gösterir.
--   2. Bu fonksiyon yeni `left_fast` sütunu verir: o adımda AYRILAN oturumlardan
--      görünür süresi < v_fast sn olanlar ("hemen çıkan"). Eşik OKUMA anında
--      uygulanır (ham `seconds` saklı), yani 3'ü 5 yapmak yalnızca bu sabiti
--      değiştirmektir ve geçmişe de uygulanır. Eşik veriden seçildi: Android Meta
--      probe'unda girdisiz sayfaların ilk gizlenmesi 1-2 sn'de 38, 3 sn'de 6,
--      4 sn'de 5; dokunmuş (girdili) sayfalar ise 3 sn'den ÖNCE yalnızca 1-2
--      tane → <3 sn etiketinin %97'si dokunmamış sayfa, 5 sn'de bu %84'e düşüyor.
--      ⚠ `web_sessions` dokunma sayısı TUTMAZ; "girdisiz" denemez, tanım yalnızca
--      "görünür süre < v_fast".
--
-- Dönüş tipi DEĞİŞTİ (sütun eklendi) → create or replace YETMEZ: drop + create.
-- ⚠ Drop; security definer, search_path VE grant'leri düşürür — hepsi elle geri
-- kuruldu. Canlıdaki önceki durum: proacl = postgres/authenticated/service_role
-- (anon YOK); Supabase yeni fonksiyona anon'u da verdiği için aşağıda revoke.
--
-- Adım listesi (`v_steps`) DEĞİŞMEDİ; `npm run verify-web-journey` bu dosyayı
-- okur (admin_web_journey'yi EN SON yeniden yazan migration).

drop function if exists public.admin_web_journey(integer, text, text);

create function public.admin_web_journey(
  p_days integer default 30,
  p_device text default null::text,
  p_entry text default null::text
)
returns table(step text, reached bigint, left_here bigint, median_seconds double precision,
              median_scroll double precision, idle bigint, left_fast bigint)
language plpgsql
stable security definer
set search_path to 'public'
as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
  v_steps constant text[] := array[
    'landing', 'landing_cta', 'app', 'tutorial_start', 'tutorial_done',
    'game_start', 'first_move', 'move_5', 'game_finish',
    'signup_form', 'signup_done', 'login', 'store'
  ];
  -- "Hemen çıkan" eşiği (saniye, GÖRÜNÜR süre). Gerekçe yukarıda.
  v_fast constant integer := 3;
  v_idle bigint;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  select count(*) into v_idle
  from public.web_sessions ws
  where ws.created_at >= v_since
    and (p_device is null or ws.device_type = p_device)
    and (p_entry is null or ws.entry = p_entry)
    and ws.updated_at = ws.created_at;

  return query
  with s as (
    select ws.steps, ws.seconds, ws.scroll_pct,
           (select v_steps[max(array_position(v_steps, x))]
              from unnest(ws.steps) as x) as exit_step
    from public.web_sessions ws
    where ws.created_at >= v_since
      and (p_device is null or ws.device_type = p_device)
      and (p_entry is null or ws.entry = p_entry)
      and ws.updated_at > ws.created_at
  ),
  r as (
    select k.step,
           k.ord::numeric as ord,
           (select count(*) from s where k.step = any (s.steps)) as reached,
           (select count(*) from s where s.exit_step = k.step) as left_here,
           (select percentile_cont(0.5) within group (order by s.seconds)
              from s where s.exit_step = k.step) as median_seconds,
           (select percentile_cont(0.5) within group (order by s.scroll_pct)
              from s where s.exit_step = k.step and s.scroll_pct is not null) as median_scroll,
           (select count(*) from s
             where s.exit_step = k.step and s.seconds < v_fast) as left_fast
    from unnest(v_steps) with ordinality as k (step, ord)
    union all
    select 'tutorial_skip',
           array_position(v_steps, 'tutorial_done') + 0.5,
           (select count(*) from s
             where 'tutorial_start' = any (s.steps)
               and not ('tutorial_done' = any (s.steps))
               and 'game_start' = any (s.steps)),
           0::bigint,
           null::double precision,
           null::double precision,
           0::bigint
  )
  select r.step, r.reached, r.left_here, r.median_seconds, r.median_scroll, v_idle, r.left_fast
  from r
  order by r.ord;
end;
$function$;

revoke all on function public.admin_web_journey(integer, text, text) from public, anon;
grant execute on function public.admin_web_journey(integer, text, text) to authenticated, service_role;
