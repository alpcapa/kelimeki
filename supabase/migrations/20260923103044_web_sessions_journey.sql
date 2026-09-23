-- Kelimeki — web ziyaretçi yolculuğu (`web_sessions`): ziyaretçi NEREDE ayrılıyor?
--
-- NEDEN VAR (23 Eylül 2026, kullanıcı isteği: *"Bizim web tarafında bounce
-- rate'leri görmemiz lazım. Ziyaretçiler hangi noktalarda bounce ediyor."*):
-- mevcut tablolar huninin UÇLARINI görüyordu (ziyaret: `guest_visits`,
-- oyun başladı: `game_starts`, bitti: `game_finishes`, kayıt formu:
-- `signup_events`) ama ARASINI görmüyordu. İki kör nokta ölçülerek bulundu
-- (21-23 Eylül, 34 web cihazı): masaüstündeki 14 cihazın hiçbiri oyun
-- başlatmamıştı ama karşılama sayfasında mı yoksa kurulum ekranında mı
-- çıktıkları BİLİNEMİYORDU; 8 başlangıçtan 1'i bitmişti ama öteki 7'nin
-- ilk hamlede mi 15. dakikada mı bıraktığı BİLİNEMİYORDU.
--
-- ŞEKİL: sekme başına TEK satır (oturum). İstemci her yeni adımda ve sekme
-- gizlenirken aynı satırı günceller; `steps` ulaşılan adımların kümesi,
-- `last_step` kronolojik olarak SON adım — yani "burada ayrıldı".
--
-- ⚠ KİMLİK YOK — kullanıcı kararı (23 Eylül 2026): *"Gizlilik metnine
-- dokunmadan başla"*. `anon_id` de `user_id` de YOK. `id` sekmeye özel,
-- `sessionStorage`'da duran ve sekme kapanınca silinen rastgele bir koddur;
-- cihazdaki kalıcı anonim kodla (`kelimeki_anon_id`) HİÇBİR bağı yoktur ve
-- yalnızca aynı satırı güncelleyebilmek için var. Gizlilik metni anonim
-- kodun sunucuya gittiği durumları SAYIYOR; bu tablo o kodu taşımadığı için
-- listeye madde eklemiyor (`signup_events` ile aynı duruş, bkz.
-- `20260921122031_signup_events_funnel.sql`). Bedeli bilinir: ölçü KİŞİ
-- değil OTURUM bazlıdır — ertesi gün dönen ziyaretçi yeni bir oturumdur.
--
-- ⚠ Yalnızca MİSAFİR oturumu yazılır: oturum girişli başlarsa istemci hiç
-- yazmaz; misafir başlayıp giriş yaparsa `login` adımı yazılır ve oturum
-- orada kapanır (üyenin davranışı bu soruyla ilgisiz). Kayıt olan misafir
-- `signup_done` ile kapanır.
--
-- ⚠ ADIM LİSTESİ İKİ YERDE: aşağıdaki iki fonksiyon ↔ `src/utils/webJourney.ts`
-- (`JOURNEY_STEPS`). `npm run verify-web-journey` ikisinin sırasını da
-- birebir karşılaştırır — yeni adım ekleyen İKİSİNİ de güncellemeli.

create table if not exists public.web_sessions (
  id          uuid primary key,
  -- 'landing' → karşılama sayfasıyla başladı; 'app' → doğrudan uygulamayla
  -- (dönen ziyaretçi ya da derin link: karşılama katmanı atlandı).
  entry       text not null check (entry in ('landing', 'app')),
  device_type text check (device_type is null or device_type in ('ios', 'android', 'desktop')),
  utm_source  text check (utm_source is null or char_length(utm_source) <= 64),
  steps       text[] not null default '{}',
  last_step   text,
  -- Bu oturumda BAŞLATILAN oyunda insan oyuncunun yaptığı hamle sayısı
  -- (en büyük değer). Kayıttan devam ettirilen oyun sayılmaz.
  moves       integer not null default 0,
  -- Oturumun başından son pinge kadar geçen süre (saniye, en büyük değer).
  seconds     integer not null default 0,
  -- Karşılama sayfasında ulaşılan en derin kaydırma (%). Uygulamayla
  -- başlayan oturumda null.
  scroll_pct  smallint,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.web_sessions is 'Web ziyaretçi yolculuğu — sekme başına tek satır, misafir oturumları. Admin panelindeki "Ziyaretçi Yolculuğu" kartı için. HİÇBİR kalıcı kimlik taşımaz: id sekmeye özel rastgele koddur, anon_id/user_id bilerek YOK (bkz. migration başlığı).';

create index if not exists web_sessions_created_at_idx on public.web_sessions (created_at desc);

-- Tabloya istemciden DOĞRUDAN erişim yok: RLS açık, hiçbir politika yok.
-- Yazma yalnızca aşağıdaki security definer RPC'den (upsert için select +
-- update yetkisi vermek, herkesin başkasının oturumunu okuyup
-- değiştirebilmesi demek olurdu); okuma yalnızca admin RPC'sinden.
alter table public.web_sessions enable row level security;
revoke all on table public.web_sessions from anon, authenticated;

-- ── İSTEMCİ: oturumu kaydet / güncelle ─────────────────────────────────────
-- Telemetri asla hata fırlatmaz: geçersiz girdi SESSİZCE yok sayılır.
-- Birleştirme kuralları: `steps` küme birleşimi, `last_step` son gelen adım
-- (adımsız "sekme gizlendi" pingi onu DEĞİŞTİRMEZ), sayılar en büyük değer.
-- Bir günden eski satır güncellenmez (sekmeyi günlerce açık tutan tek bir
-- oturum sayıları bozmasın, eski bir kodla yazma da kapansın).
create or replace function public.record_web_session (
  p_id          uuid,
  p_entry       text,
  p_step        text default null,
  p_device_type text default null,
  p_utm_source  text default null,
  p_moves       integer default null,
  p_seconds     integer default null,
  p_scroll_pct  integer default null
)
  returns void
  language plpgsql
  security definer
  set search_path to 'public'
  as $function$
declare
  v_steps constant text[] := array[
    'landing', 'landing_cta', 'app', 'tutorial_start', 'tutorial_done',
    'game_start', 'first_move', 'move_5', 'game_finish',
    'signup_form', 'signup_done', 'login'
  ];
begin
  if p_id is null or p_entry is null or p_entry not in ('landing', 'app') then
    return;
  end if;
  if p_step is not null and not (p_step = any (v_steps)) then
    return;
  end if;

  insert into public.web_sessions as w
    (id, entry, device_type, utm_source, steps, last_step, moves, seconds, scroll_pct)
  values (
    p_id,
    p_entry,
    case when p_device_type in ('ios', 'android', 'desktop') then p_device_type end,
    left(p_utm_source, 64),
    case when p_step is null then '{}'::text[] else array[p_step] end,
    p_step,
    least(greatest(coalesce(p_moves, 0), 0), 1000),
    least(greatest(coalesce(p_seconds, 0), 0), 86400),
    case when p_scroll_pct is not null then least(greatest(p_scroll_pct, 0), 100) end
  )
  on conflict (id) do update set
    steps = case
      when excluded.last_step is null or excluded.last_step = any (w.steps) then w.steps
      else w.steps || excluded.last_step
    end,
    last_step  = coalesce(excluded.last_step, w.last_step),
    moves      = greatest(w.moves, excluded.moves),
    seconds    = greatest(w.seconds, excluded.seconds),
    -- `greatest` NULL'ları yok sayar: uygulama pingi karşılamanın değerini silmez.
    scroll_pct = greatest(w.scroll_pct, excluded.scroll_pct),
    updated_at = now()
  where w.created_at > now() - interval '1 day';
end;
$function$;

revoke all on function public.record_web_session (uuid, text, text, text, text, integer, integer, integer) from public;
grant execute on function public.record_web_session (uuid, text, text, text, text, integer, integer, integer) to anon, authenticated, service_role;

-- ── ADMIN: ziyaretçi yolculuğu ─────────────────────────────────────────────
-- Adım başına bir satır, SABİT sırada:
--   reached   = bu adıma ulaşan oturum sayısı
--   left_here = SON adımı bu olan oturum sayısı ("burada ayrıldı")
--   median_seconds / median_scroll = burada ayrılanların oturum süresi ve
--   karşılamadaki kaydırma derinliği (medyan)
-- `p_device` null → tüm cihazlar; 'ios' | 'android' | 'desktop' → yalnızca o.
drop function if exists public.admin_web_journey (integer, text);

create function public.admin_web_journey (p_days integer default 30, p_device text default null)
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

revoke all on function public.admin_web_journey (integer, text) from public, anon;
grant execute on function public.admin_web_journey (integer, text) to authenticated, service_role;
