-- Kelimeki — Onboarding Faz 5: tanıtım turunun ölçümü (`tutorial_events`)
--
-- NEDEN VAR: "Oynayarak öğren" tanıtımı (7 Eylül 2026) ilk oyunda açılan
-- metin penceresinin yerini aldı ve gerekçesi ölçülebilir bir iddiaydı —
-- *"çoğu kişi okumuyor, ne yapacağını bilmediği için sıkılıp çıkıyor"*.
-- Bugüne kadar bu iddianın DOĞRULANACAĞI hiçbir sayı yoktu: tanıtım bilerek
-- bir "oyun" sayılmıyor (`logGameStart` çağrılmıyor, `games` satırı
-- açılmıyor), yani huninin hiçbir adımında görünmüyordu. Bu tablo tek bir
-- soruyu cevaplıyor: tanıtımı açanların yüzde kaçı BİTİRİYOR, atlayanlar
-- HANGİ sahnede bırakıyor.
--
-- ⚠ `user_id` YOK ve bilinçli olarak eklenmedi — `game_starts`taki aynı
-- gizlilik kararı: `PrivacyModal` bölüm 6 anonim cihaz kodu için
-- "hesabınızla ASLA eşleştirilmez" diyor, `anon_id` ile `user_id`'yi aynı
-- satıra koymak tam olarak o eşleştirmeyi yapardı.

create table if not exists public.tutorial_events (
  id          uuid primary key default gen_random_uuid (),
  anon_id     uuid,
  -- 'start'  → tanıtım ekrana geldi (karşılama penceresiyle birlikte)
  -- 'finish' → dört sahne tamamlandı, kapanış kartı açıldı
  -- 'skip'   → "Atla" ile çıkıldı; `step` hangi sahnede bırakıldığını söyler
  event       text not null check (event in ('start', 'finish', 'skip')),
  -- 1..4 — yalnızca 'skip'te dolu. 'start'/'finish' için null.
  step        integer check (step is null or (step >= 1 and step <= 20)),
  -- 'auto'   → ilk oyunda kapı açtı (`shouldShowTutorial`)
  -- 'replay' → kullanıcı "Nasıl oynanır?" penceresinden kendi başlattı (Faz 3)
  source      text not null check (source in ('auto', 'replay')),
  platform    text,
  app_version text,
  created_at  timestamptz not null default now()
);

comment on table public.tutorial_events is 'Tanıtım turunun anonim ölçümü (başladı/bitti/atlandı + hangi sahnede bırakıldı) — admin panelindeki "Tanıtım Turu" kartı için. anon_id istemcide üretilen rastgele bir uuid''dir, hiçbir hesapla ilişkilendirilmez (game_starts ile aynı gizlilik kararı).';

create index if not exists tutorial_events_created_at_idx on public.tutorial_events (created_at desc);
create index if not exists tutorial_events_event_idx on public.tutorial_events (event);

alter table public.tutorial_events enable row level security;

-- Yazma iki istemci rolüne de açık (tanıtımı misafir de girişli de görebilir),
-- OKUMA hiçbirine açık değil: select politikası YOK, tabloyu yalnızca aşağıdaki
-- security definer admin RPC'si okuyabiliyor (`game_starts` ile aynı duruş).
drop policy if exists tutorial_events_insert_anon on public.tutorial_events;
create policy tutorial_events_insert_anon on public.tutorial_events
  for insert
  to anon
  with check (true);

drop policy if exists tutorial_events_insert_authenticated on public.tutorial_events;
create policy tutorial_events_insert_authenticated on public.tutorial_events
  for insert
  to authenticated
  with check (true);

-- ── ADMIN: tanıtım hunisi ───────────────────────────────────────────────────
-- Tek satırlık bir özet DEĞİL, kaynak (`auto`/`replay`) başına bir satır:
-- ikisinin bitirme oranı aynı sayıya karışırsa kart yanlış okunur — kendi
-- isteğiyle tekrar izleyen biri tanım gereği daha meraklıdır.
--
-- `starters`/`finishers` BENZERSİZ CİHAZ sayar, `starts`/`finishes` ADET:
-- `Kaynak Hunisi`'ndeki aynı ayrım ve aynı gerekçe (bir cihaz tanıtımı iki
-- kez açabilir). `anon_id` null gelen satırlar (depolama kapalı) adette
-- sayılır, benzersizde sayılmaz.
--
-- `skip_steps`: hangi sahnede kaç kişi bıraktı — `{"1": 4, "3": 1}` biçiminde
-- jsonb. Kartın asıl sorusu bu: tanıtım BAŞTA mı kaybediyor (metin/hız
-- sorunu) yoksa SONDA mı (uzun geliyor).
drop function if exists public.admin_tutorial_funnel (integer);

create function public.admin_tutorial_funnel (p_days integer default 30)
  returns table (
    source     text,
    starts     bigint,
    starters   bigint,
    finishes   bigint,
    finishers  bigint,
    skips      bigint,
    skip_steps jsonb
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
  select te.source,
         count(*) filter (where te.event = 'start'),
         count(distinct te.anon_id) filter (where te.event = 'start'),
         count(*) filter (where te.event = 'finish'),
         count(distinct te.anon_id) filter (where te.event = 'finish'),
         count(*) filter (where te.event = 'skip'),
         coalesce(
           (select jsonb_object_agg(x.step::text, x.n)
            from (
              select s.step, count(*) as n
              from public.tutorial_events s
              where s.created_at >= v_since
                and s.event = 'skip'
                and s.source = te.source
                and s.step is not null
              group by s.step
            ) x),
           '{}'::jsonb)
  from public.tutorial_events te
  where te.created_at >= v_since
  group by te.source
  order by count(*) filter (where te.event = 'start') desc, te.source;
end;
$function$;

revoke all on function public.admin_tutorial_funnel (integer) from public, anon;
grant execute on function public.admin_tutorial_funnel (integer) to authenticated, service_role;
