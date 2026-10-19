// Kelimeki — ziyaretçi yolculuğunun (`src/utils/webJourney.ts`) saf karar
// mantığını ÜRETİM kodunu import ederek doğrular + adım listesinin SQL
// kopyasıyla birebir aynı olduğunu kontrol eder.
//
// NEDEN: mantık duman testiyle sınanamaz (Supabase yapılandırılmamışken hiç
// çalışmıyor, Playwright ayrıca `navigator.webdriver` taşıdığı için kasten
// SAYILMIYOR) ve adım listesi iki dilde iki yerde yaşıyor — biri yeni adım
// alıp öteki almazsa sunucu o adımı SESSİZCE yok sayar.
//
// Koşum: npm run verify-web-journey
import { readFileSync } from 'node:fs';
import {
  JOURNEY_STEPS,
  journeyAnonId,
  reduceJourney,
  type JourneyEvent,
  type JourneySession,
  type JourneyStep,
} from '../src/utils/webJourney';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

/** Olayları sırayla uygular; gönderilen adımları (null = adımsız) toplar. */
function run(events: JourneyEvent[], startMs = 1_000_000) {
  let s: JourneySession | null = null;
  const steps: (JourneyStep | null)[] = [];
  const pings = [];
  let t = startMs;
  let n = 0;
  for (const ev of events) {
    const r = reduceJourney(s, ev, t, () => `id-${++n}`);
    s = r.session;
    for (const p of r.pings) {
      steps.push(p.step);
      pings.push(p);
    }
    t += 1000;
  }
  return { s, steps, pings, ids: n };
}

console.log('webJourney — ziyaretçi yolculuğu');

// 1 — tipik misafir: karşılama → geçiş → uygulama → oyun → hamleler → bitiş.
{
  const { steps, s, ids } = run([
    { type: 'start', entry: 'landing', member: false },
    { type: 'scroll', pct: 40 },
    { type: 'step', step: 'landing_cta' },
    { type: 'start', entry: 'app', member: false },
    { type: 'step', step: 'game_start' },
    { type: 'moves', count: 1 },
    { type: 'moves', count: 5 },
    { type: 'moves', count: 6 },
    { type: 'step', step: 'game_finish' },
  ]);
  check(
    'misafir yolu sırasıyla yazılıyor',
    JSON.stringify(steps) ===
      JSON.stringify(['landing', 'landing_cta', 'app', 'game_start', 'first_move', 'move_5', 'game_finish']),
    JSON.stringify(steps),
  );
  check('tek oturum kodu üretildi', ids === 1);
  check('kaydırma derinliği saklandı', s?.scrollPct === 40);
}

// 2 — girişli başlayan oturum HİÇ yazmaz.
{
  const { steps } = run([
    { type: 'start', entry: 'app', member: true },
    { type: 'step', step: 'game_start' },
    { type: 'moves', count: 3 },
    { type: 'step', step: 'signup_form' },
    { type: 'hide' },
  ]);
  check('girişli oturum hiçbir ping üretmiyor', steps.length === 0, JSON.stringify(steps));
}

// 3 — yeniden yükleme: 'app' ikinci kez gönderilmez (last_step'i geri almasın).
{
  const { steps } = run([
    { type: 'start', entry: 'app', member: false },
    { type: 'step', step: 'game_start' },
    { type: 'start', entry: 'app', member: false },
  ]);
  check('yeniden yüklemede app tekrar edilmiyor', JSON.stringify(steps) === JSON.stringify(['app', 'game_start']));
}

// 4 — auth olayı AuthModal'dan ÖNCE gelirse kapanış adımı yine geçer.
{
  const { steps } = run([
    { type: 'start', entry: 'app', member: false },
    { type: 'step', step: 'signup_form' },
    { type: 'start', entry: 'app', member: true },
    { type: 'step', step: 'game_start' },
    { type: 'step', step: 'signup_done' },
    { type: 'step', step: 'login' },
    { type: 'hide' },
  ]);
  check(
    'üyelik sonrası yalnızca kapanış adımı geçiyor, sonra oturum kapanıyor',
    JSON.stringify(steps) === JSON.stringify(['app', 'signup_form', 'signup_done']),
    JSON.stringify(steps),
  );
}

// 5 — AuthModal adımı auth olayından ÖNCE gelirse de oturum kapanır.
{
  const { steps } = run([
    { type: 'start', entry: 'landing', member: false },
    { type: 'step', step: 'login' },
    { type: 'start', entry: 'app', member: true },
    { type: 'step', step: 'game_start' },
    { type: 'hide' },
  ]);
  check('girişten sonra hiçbir şey yazılmıyor', JSON.stringify(steps) === JSON.stringify(['landing', 'login']));
}

// 6 — hamle sayısı geriye gitmez, eşik atlanırsa iki adım birden yazılır.
{
  const { steps, s } = run([
    { type: 'start', entry: 'app', member: false },
    { type: 'moves', count: 7 },
    { type: 'moves', count: 2 },
  ]);
  check('7 hamle tek olayda → first_move + move_5', JSON.stringify(steps) === JSON.stringify(['app', 'first_move', 'move_5']));
  check('hamle sayısı düşmüyor', s?.moves === 7);
}

// 7 — tekrarlanabilir adımlar tekrar yazılır (ikinci oyun = son adım yeniden game_start).
{
  const { steps } = run([
    { type: 'start', entry: 'app', member: false },
    { type: 'step', step: 'game_start' },
    { type: 'step', step: 'game_finish' },
    { type: 'step', step: 'game_start' },
  ]);
  check('ikinci oyun başlangıcı yazılıyor', steps.filter((x) => x === 'game_start').length === 2);
}

// 8 — hide (sekme gizlendi / pagehide) adımsızdır, görünür süreyi taşır; kaydırma ping ÜRETMEZ.
{
  const { pings } = run([
    { type: 'start', entry: 'landing', member: false },
    { type: 'scroll', pct: 20 },
    { type: 'scroll', pct: 150 },
    { type: 'scroll', pct: 10 },
    { type: 'hide' },
  ]);
  const son = pings[pings.length - 1];
  check('kaydırma ping üretmiyor', pings.length === 2);
  check('hide adımsız', son?.step === null);
  check('hide görünür süreyi taşıyor', son?.seconds === 4, String(son?.seconds));
  check('kaydırma %100 ile sınırlı ve geriye gitmiyor', son?.scrollPct === 100, String(son?.scrollPct));
}

// 8b — GÖRÜNÜR SÜRE (15 Ekim 2026). Android Meta uygulama-içi tarayıcıda
// reklama dokunup ~2 sn'de dönen kişinin sayfası arka planda ~30 sn yaşıyor ve
// `pagehide` o ana kadarki DUVAR SAATİNİ yazıyordu ("32 sn kaldı" yığılması).
// Düzeltme: süre yalnızca sekme görünürken birikir.
{
  // `run` her olay arasında 1 sn ilerletir; burada saati elle sürüyoruz.
  const adim = (ev: JourneyEvent, t: number, s: JourneySession | null) => reduceJourney(s, ev, t, () => 'id-1');
  let t = 1_000_000;
  let r = adim({ type: 'start', entry: 'landing', member: false }, t, null);
  t += 2_000; // 2 sn görünür
  r = adim({ type: 'hide' }, t, r.session);
  check('2 sn sonra gizlendi → 2 sn yazılıyor', r.pings[0]?.seconds === 2, String(r.pings[0]?.seconds));
  t += 30_000; // 30 sn gizli bekledi, sonra webview sayfayı yıktı
  r = adim({ type: 'hide' }, t, r.session); // pagehide
  check(
    'gizliyken gelen ikinci hide (pagehide) süreyi ARTIRMAZ (32 sn yığılmasının düzeltmesi)',
    r.pings[0]?.seconds === 2,
    String(r.pings[0]?.seconds),
  );
  // Geri gelirse biriktirmeye devam eder: 2 + (60 sn başka uygulamada) + 5 sn = 7.
  let u = adim({ type: 'start', entry: 'landing', member: false }, 2_000_000, null);
  u = adim({ type: 'hide' }, 2_002_000, u.session);
  u = adim({ type: 'show' }, 2_062_000, u.session);
  check('show ping ÜRETMEZ', u.pings.length === 0);
  u = adim({ type: 'hide' }, 2_067_000, u.session);
  check('gizli kalınan 60 sn sayılmaz, dönünce görünür süre sürer (2+5=7)', u.pings[0]?.seconds === 7, String(u.pings[0]?.seconds));
  // Adım pingi de görünür süreyi taşır.
  let a = adim({ type: 'start', entry: 'landing', member: false }, 3_000_000, null);
  a = adim({ type: 'hide' }, 3_001_000, a.session);
  a = adim({ type: 'show' }, 3_091_000, a.session); // 90 sn sonra döndü
  a = adim({ type: 'step', step: 'landing_cta' }, 3_094_000, a.session);
  check('adım pingi görünür süreyi taşıyor (1+3=4, 90 sn gizli sayılmaz)', a.pings[0]?.seconds === 4, String(a.pings[0]?.seconds));
  // Sayfa yeniden yüklendi: mevcut oturum, yeni görünür aralık; ölü zaman sayılmaz.
  let y = adim({ type: 'start', entry: 'landing', member: false }, 4_000_000, null);
  y = adim({ type: 'hide' }, 4_003_000, y.session); // 3 sn; pagehide
  y = adim({ type: 'start', entry: 'app', member: false }, 4_500_000, y.session); // 497 sn sonra yeni sayfa
  y = adim({ type: 'hide' }, 4_502_000, y.session);
  check('yeniden yüklemede aradaki ölü zaman sayılmıyor (3+2=5)', y.pings[0]?.seconds === 5, String(y.pings[0]?.seconds));
  // Eski sürümden kalma oturum (görünür-süre alanları YOK) çökmez, eski anlamıyla sürer.
  const eski: JourneySession = {
    id: 'eski',
    entry: 'landing',
    guest: true,
    member: false,
    closed: false,
    startMs: 5_000_000,
    moves: 0,
    scrollPct: null,
    sent: ['landing'],
  };
  const e = adim({ type: 'hide' }, 5_010_000, eski);
  check('alanları olmayan eski oturum çökmeden sürer (10 sn)', e.pings[0]?.seconds === 10, String(e.pings[0]?.seconds));
  const e2 = adim({ type: 'hide' }, 5_100_000, e.session);
  check('…ve artık gizliyken ARTMAZ', e2.pings[0]?.seconds === 10, String(e2.pings[0]?.seconds));
}

// 9 — oturum yokken adım/hamle/hide hiçbir şey yazmaz (Supabase yokken App başlatmıyor).
{
  const { steps, ids } = run([
    { type: 'step', step: 'game_start' },
    { type: 'moves', count: 3 },
    { type: 'hide' },
  ]);
  check('oturumsuz olaylar sessiz', steps.length === 0 && ids === 0);
}

// 9b — `store` (mağaza rozeti, 28 Eylül 2026): oturum başına bir kez, oturumu
// KAPATMAZ — kişi mağazaya bakıp dönüp tarayıcıda oynayabilir.
{
  const { steps, s } = run([
    { type: 'start', entry: 'landing', member: false },
    { type: 'step', step: 'store' },
    { type: 'step', step: 'store' },
    { type: 'step', step: 'landing_cta' },
    { type: 'start', entry: 'app', member: false },
    { type: 'step', step: 'game_start' },
  ]);
  check(
    'store bir kez yazılıyor ve oturumu kapatmıyor',
    JSON.stringify(steps) === JSON.stringify(['landing', 'store', 'landing_cta', 'app', 'game_start']),
    JSON.stringify(steps),
  );
  check('store sonrası oturum açık', s?.closed === false);
}

// 10 — adım listesi SQL ile birebir. Canlıda geçerli olan fonksiyonun EN SON
// tanımıdır; o yüzden yalnızca iki fonksiyonu EN SON yeniden yazan migration
// okunur. 28 Eylül 2026'ya kadar dizi taşıyan HER dosya okunuyordu — liste
// hiç değişmediği için işliyordu, `store` adımı eklenince eski dosyalar
// (değiştirilemez, canlıya uygulanmış geçmiş) yanlışlıkla düşerdi.
// ⚠ Yeni bir migration iki fonksiyondan birini yeniden yazarsa buradaki dosya
// o migration'la DEĞİŞTİRİLMELİ.
{
  const dosyalar: [string, number][] = [
    ['supabase/migrations/20261018190000_web_sessions_anon_id.sql', 1], // record_web_session (EN SON yeniden yazan: `p_anon_id`; öncesi `20260928100430_web_journey_store_step.sql` — onun admin_web_journey'si de aşağıdakiyle geçersiz)
    ['supabase/migrations/20261015120000_admin_web_journey_left_fast.sql', 1], // admin_web_journey (EN SON yeniden yazan: `left_fast` sütunu; öncesi en ileri adım + türetilmiş `tutorial_skip`, v_steps'e GİRMEZ)
  ];
  for (const [dosya, beklenen] of dosyalar) {
    const sql = readFileSync(dosya, 'utf8');
    const diziler = [...sql.matchAll(/v_steps constant text\[\] := array\[([\s\S]*?)\];/g)].map((m) =>
      [...m[1].matchAll(/'([a-z_0-9]+)'/g)].map((x) => x[1]),
    );
    const ad = dosya.split('/').pop();
    check(`${ad}: ${beklenen} adım dizisi bulundu`, diziler.length === beklenen, String(diziler.length));
    for (const [i, d] of diziler.entries()) {
      check(
        `${ad}: dizi ${i + 1} ↔ JOURNEY_STEPS (sıra dahil)`,
        JSON.stringify(d) === JSON.stringify(JOURNEY_STEPS),
        JSON.stringify(d),
      );
    }
  }
}

// 18 Ekim 2026 (ROADMAP #47): her ping cihazın anonim kodunu taşır — YALNIZCA
// geçerli bir UUID ise (sunucu parametresi `uuid`: bozuk bir değer RPC'yi
// 400'le düşürür ve ping'in TAMAMI kaybolur).
{
  console.log('Anonim cihaz kodu (journeyAnonId) + migration sözleşmesi');
  const g = globalThis as { localStorage?: unknown };
  const onceki = g.localStorage;
  const depo = (v: string | null) => {
    const kayit = new Map<string, string>();
    if (v !== null) kayit.set('kelimeki:anon-id', v);
    g.localStorage = {
      getItem: (k: string) => kayit.get(k) ?? null,
      setItem: (k: string, x: string) => void kayit.set(k, x),
    };
  };
  const uuid = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';
  depo(uuid);
  check('geçerli UUID aynen gider', journeyAnonId() === uuid, String(journeyAnonId()));
  depo('bozuk-kod');
  check('bozuk kod GÖNDERİLMEZ (null)', journeyAnonId() === null, String(journeyAnonId()));
  depo('');
  check('boş kayıtta yeni UUID üretilir ve geçerlidir', /^[0-9a-f-]{36}$/i.test(String(journeyAnonId())));
  g.localStorage = undefined;
  check('localStorage yoksa null (ping kodsuz gider)', journeyAnonId() === null);
  g.localStorage = onceki;

  const mig = readFileSync('supabase/migrations/20261018190000_web_sessions_anon_id.sql', 'utf8');
  check('migration: eski 8 parametreli imza DROP', /drop function if exists public\.record_web_session \(uuid, text, text, text, text, integer, integer, integer\);/.test(mig));
  check('migration: p_anon_id uuid default null', /p_anon_id\s+uuid default null/.test(mig));
  check('migration: anon_id yalnızca İLK yazımda atanır (coalesce)', /anon_id\s*=\s*coalesce\(w\.anon_id, excluded\.anon_id\)/.test(mig));
  check('migration: admin_funnel anon yetkisi YOK', /revoke all on function public\.admin_funnel \(integer, text\) from public, anon;/.test(mig));
  const ts = readFileSync('src/utils/webJourney.ts', 'utf8');
  check('istemci: RPC gövdesi p_anon_id taşıyor', /p_anon_id:\s*journeyAnonId\(\)/.test(ts));
}

if (failures > 0) {
  console.log(`\n${failures} kontrol BAŞARISIZ`);
  process.exit(1);
}
console.log('\nTüm kontroller geçti.');
