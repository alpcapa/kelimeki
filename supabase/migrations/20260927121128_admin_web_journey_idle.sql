-- Kelimeki — Ziyaretçi Yolculuğu: ETKİLEŞİMSİZ oturumlar ayrı sayılır
-- (`admin_web_journey`'e `idle` sütunu)
--
-- NEDEN (27 Eylül 2026): kart "Yeni" süzgeciyle 20 oturumdan 19'unun
-- karşılamada, medyan "0 sn"de ayrıldığını söylüyordu. Canlıda satır satır
-- okundu: 20'nin 14'ü hiç ikinci ping göndermemişti — süre 0, kaydırma
-- yok, kaynak yok, neredeyse hepsi "masaüstü" ve çoğu İKİŞER İKİŞER aynı
-- milisaniyede açılmış (ör. 24 Eyl 05:33:09.7438 / .7441). Gerçek bir
-- ziyaretçi sekmeyi kapatınca ya da arka plana alınca `webJourney.ts`
-- (`visibilitychange`/`pagehide` → `flush`) süre ve kaydırmayı taşıyan bir
-- ping daha gönderir; tarayıcıyı bu olaylar olmadan kapatan şey önizleme/
-- tarama botlarıdır. `navigator.webdriver` süzgeci (istemcide) bunları
-- görmüyor, çünkü kendilerini otomasyon olarak bildirmiyorlar.
--
-- ÖLÇÜT: `updated_at = created_at` → oturuma YALNIZCA ilk ping ulaştı
-- (`record_web_session` her güncellemede `updated_at = now()` yazıyor).
-- Bu oturumlar adım satırlarından DÜŞÜLÜR ve `idle` sütununda ayrıca
-- sayılır (her satırda aynı değer) — kart onları "etkileşimsiz" diye
-- gösterir, gizlemez.
-- ⚠ Bedeli: kapanış pingini kaybeden gerçek bir ziyaretçi (ör. iOS'ta
-- sekme öldürülürse `pagehide` gelmeyebilir) de buraya düşer. Kabul edildi:
-- o kişi zaten "hiç etkileşmeden ayrılan" sınıfta, oranı bot gürültüsünden
-- korumanın bedeli bu.
--
-- Dönüş tipi değiştiği için DROP + CREATE (`create or replace` yetmez);
-- drop grant'leri de düşürür, aşağıda ELLE kuruluyor ve `proacl` merge
-- öncesiyle karşılaştırılıyor (öncesi: authenticated + service_role, anon YOK).
-- ⚠ Adım listesi (`v_steps`) `src/utils/webJourney.ts` → `JOURNEY_STEPS` ile
-- BİREBİR aynı kalmalı; `npm run verify-web-journey` bu dosyayı da okur.

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
    median_scroll  double precision,
    idle           bigint
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
    select ws.steps, ws.last_step, ws.seconds, ws.scroll_pct
    from public.web_sessions ws
    where ws.created_at >= v_since
      and (p_device is null or ws.device_type = p_device)
      and (p_entry is null or ws.entry = p_entry)
      and ws.updated_at > ws.created_at
  )
  select k.step,
         (select count(*) from s where k.step = any (s.steps)),
         (select count(*) from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.seconds)
            from s where s.last_step = k.step),
         (select percentile_cont(0.5) within group (order by s.scroll_pct)
            from s where s.last_step = k.step and s.scroll_pct is not null),
         v_idle
  from unnest(v_steps) with ordinality as k (step, ord)
  order by k.ord;
end;
$function$;

revoke all on function public.admin_web_journey (integer, text, text) from public, anon;
grant execute on function public.admin_web_journey (integer, text, text) to authenticated, service_role;
