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
    { type: 'flush' },
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
    { type: 'flush' },
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
    { type: 'flush' },
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

// 8 — flush adımsızdır, süreyi taşır; kaydırma ping ÜRETMEZ.
{
  const { pings } = run([
    { type: 'start', entry: 'landing', member: false },
    { type: 'scroll', pct: 20 },
    { type: 'scroll', pct: 150 },
    { type: 'scroll', pct: 10 },
    { type: 'flush' },
  ]);
  const son = pings[pings.length - 1];
  check('kaydırma ping üretmiyor', pings.length === 2);
  check('flush adımsız', son?.step === null);
  check('flush süreyi taşıyor', son?.seconds === 4, String(son?.seconds));
  check('kaydırma %100 ile sınırlı ve geriye gitmiyor', son?.scrollPct === 100, String(son?.scrollPct));
}

// 9 — oturum yokken adım/hamle/flush hiçbir şey yazmaz (Supabase yokken App başlatmıyor).
{
  const { steps, ids } = run([
    { type: 'step', step: 'game_start' },
    { type: 'moves', count: 3 },
    { type: 'flush' },
  ]);
  check('oturumsuz olaylar sessiz', steps.length === 0 && ids === 0);
}

// 10 — adım listesi SQL ile birebir (iki fonksiyonun ikisi de).
{
  const sql = readFileSync('supabase/migrations/20260923103044_web_sessions_journey.sql', 'utf8');
  const diziler = [...sql.matchAll(/v_steps constant text\[\] := array\[([\s\S]*?)\];/g)].map((m) =>
    [...m[1].matchAll(/'([a-z_0-9]+)'/g)].map((x) => x[1]),
  );
  check('SQL\'de iki adım dizisi bulundu', diziler.length === 2, String(diziler.length));
  for (const [i, d] of diziler.entries()) {
    check(
      `SQL dizisi ${i + 1} ↔ JOURNEY_STEPS (sıra dahil)`,
      JSON.stringify(d) === JSON.stringify(JOURNEY_STEPS),
      JSON.stringify(d),
    );
  }
}

if (failures > 0) {
  console.log(`\n${failures} kontrol BAŞARISIZ`);
  process.exit(1);
}
console.log('\nTüm kontroller geçti.');
