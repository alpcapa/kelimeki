-- Kelimeki — kayıt hunisinin KENDİ telemetrisi (`signup_events`)
--
-- NEDEN VAR: ROADMAP #32 ("e-posta onayı bir kullanıcı kaybı kapısı") bir
-- ölçüm boşluğuyla açıldı — kaç kişinin kayıt ekranını açıp TAMAMLAMADAN
-- gittiği hiçbir yerde yazmıyordu. `profiles` yalnızca BAŞARILI kayıtları
-- tutuyor, yani hunin üst ucu görünmüyordu; 20 Eylül'deki saha vakasında
-- huni elle, zaman damgası eşleştirerek kurulmak zorunda kaldı ve sonuç
-- KANIT değil KARİNE oldu.
--
-- Alternatif olarak Firebase/GA4'ü web'e eklemek tartışıldı ve ELENDİ
-- (21 Eylül 2026, kullanıcı kararı): GA4 `_ga` çerezi yazar ve
-- `google-analytics.com`'a istek atar; gizlilik metnimiz ise "HTTP çerezi
-- kullanmaz", "izleme teknolojisi kullanılmamaktadır" ve "tüm statik
-- içerikler kendi sunucularımızdan sağlanır; üçüncü taraf çağrısı yapılmaz"
-- diyor. Üç cümle birden yanlış olurdu, üstüne bir çerez onay bandı gerekirdi.
--
-- ⚠ `anon_id` YOK — ve bu bir eksiklik değil, TASARIM. Gizlilik metni
-- (`src/legal/LegalContent.tsx`) anonim cihaz kodunun sunucuya "DÖRT
-- durumda" gönderildiğini sayıyor; beşinci bir durum eklemek o metni
-- değiştirmeyi, dolayısıyla portun birebir kopyasını
-- (`mobile/app/lib/src/ui/auth/legal_modals.dart`, tazeliği
-- `test/legal_text_test.dart` ile web kaynağına karşı ölçülüyor) aynı PR'da
-- güncellemeyi gerektirirdi — yani `mobile/` dosyası, yani mobil derleme ve
-- sürüm dondurmasının beklenmesi. Kimliksiz sayaç, metne HİÇ dokunmadan
-- aynı soruyu cevaplıyor. Kişi bazlı huni gerekirse dondurma sonrası ayrı
-- bir iş.
-- ⚠ `user_id` de YOK: `game_starts`/`tutorial_events` ile aynı duruş.
--
-- ⚠ OLAY ADLARI PORTLA ORTAK: port `signup_started`/`signup_completed`'ı
-- Firebase Analytics'e yazıyor (`ui/auth/auth_modal.dart`). Buradaki
-- `started`/`completed` onların karşılığı ve anlamları BİREBİR aynı tutuldu
-- (started = kayıt FORMU görüldü, completed = hesap OLUŞTU) ki port bir gün
-- bu tabloya da yazarsa iki taraf tek huniye düşsün.

create table if not exists public.signup_events (
  id          uuid primary key default gen_random_uuid (),
  -- 'started'   → kayıt formu görüldü (pencere kayıt modunda açıldı ya da
  --               giriş sekmesinden kayda geçildi)
  -- 'completed' → hesap oluştu (oturum açıldıysa da, e-posta onayı
  --               bekleniyorsa da: ikisi de "kayıt tamamlandı")
  event       text not null check (event in ('started', 'completed')),
  -- `profiles.signup_channel` ile aynı küme: kaydın hangi kapıdan geldiği.
  -- Null = istemci söylemedi (ileriye dönük tolerans).
  channel     text check (channel is null or channel in ('direct', 'form')),
  platform    text,
  app_version text,
  created_at  timestamptz not null default now()
);

comment on table public.signup_events is 'Kayıt hunisinin anonim sayacı (form görüldü / hesap oluştu) — admin panelindeki "Kayıt Hunisi" kartı için. HİÇBİR kimlik taşımaz: anon_id de user_id de bilerek YOK (bkz. migration başlığı), satırlar yalnızca sayılmak için var.';

create index if not exists signup_events_created_at_idx on public.signup_events (created_at desc);
create index if not exists signup_events_event_idx on public.signup_events (event);

alter table public.signup_events enable row level security;

-- Yazma iki istemci rolüne de açık (kayıt formunu misafir açar, ama oturumu
-- açıkken ikinci bir hesap kurmaya çalışan da olabilir), OKUMA hiçbirine
-- açık değil: select politikası YOK, tabloyu yalnızca aşağıdaki security
-- definer admin RPC'si okuyabiliyor (`tutorial_events` ile aynı duruş).
drop policy if exists signup_events_insert_anon on public.signup_events;
create policy signup_events_insert_anon on public.signup_events
  for insert
  to anon
  with check (true);

drop policy if exists signup_events_insert_authenticated on public.signup_events;
create policy signup_events_insert_authenticated on public.signup_events
  for insert
  to authenticated
  with check (true);

-- ── ADMIN: kayıt hunisi ─────────────────────────────────────────────────────
-- Kanal başına bir satır ('direct' = doğrudan kayıt kapısı, 'form' = Görüş
-- Bildir formundan gelen), çünkü iki kapının terk oranı aynı sayıya
-- karışırsa kart yanlış okunur.
--
-- ⚠ `completions` bu tablodaki 'completed' satırlarını sayar, `profiles`'ı
-- DEĞİL. İkisi bilerek ayrı: tablo yalnızca web'den yazılıyor (port hâlâ
-- Firebase'e yazıyor), `profiles` ise her iki platformu birden tutuyor —
-- oranı `profiles` sayısıyla kurmak paydası web, payı web+mobil olan
-- sahte bir yüzde üretirdi.
drop function if exists public.admin_signup_funnel (integer);

create function public.admin_signup_funnel (p_days integer default 30)
  returns table (
    channel     text,
    starts      bigint,
    completions bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select coalesce(se.channel, 'bilinmiyor'),
         count(*) filter (where se.event = 'started'),
         count(*) filter (where se.event = 'completed')
  from public.signup_events se
  where se.created_at >= v_since
  group by coalesce(se.channel, 'bilinmiyor')
  order by count(*) filter (where se.event = 'started') desc, 1;
end;
$function$;

revoke all on function public.admin_signup_funnel (integer) from public, anon;
grant execute on function public.admin_signup_funnel (integer) to authenticated, service_role;
