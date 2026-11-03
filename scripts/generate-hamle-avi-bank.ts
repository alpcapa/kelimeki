// Kelimeki — "Hamle Avı" pozisyon bankası üreticisi (3 Kasım 2026, ROADMAP #48).
//
// YZ↔YZ oyunlarından tur kesitleri alır, vergi DAHİL en iyi net hamleyi çözer
// (`scripts/lib/hamle-avi-solver.ts`), kalite filtresinden geçenleri
// `src/data/hamleAviBank.json`'a yazar. Çözücü ≤8 harf (Zor arama); anahtar
// bu yüzden "oyuncu eşik olarak ulaşırsa doğru" (bkz. `isCorrect`).
//
// Kalite filtresi (ölçüm: docs/decisions/product-backlog.md → "En iyi hamleyi bul"):
//   • en iyi kelime ≥3 harf VE sözlükte anlamı var ("cevap NÜ idi" hayal kırıklığı),
//   • anahtarı AŞAN/ULAŞAN hamle sayısı ≤3 (tek cevaba yakın, 20/19/18 yığılması değil),
//   • anahtar ≥10 puan, liste eksik değil, tam raf (7 taş).
//
// Koşum:  npm run generate-hamle-avi-bank -- --n 1000 --tohum 1
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { preloadWordSet } from '../src/data/wordSetLoader';
import { trLower } from '../src/utils/turkish';
import { mulberry32, playUntil, solve, replayDelta } from './lib/hamle-avi-solver';
import type { HamleAviPosition } from '../src/utils/hamleAvi';

const argv = process.argv.slice(2);
const arg = (name: string, def: number) => {
  const i = argv.indexOf(name);
  return i >= 0 ? Number(argv[i + 1]) : def;
};
const N = arg('--n', 1000);
const SEED = arg('--tohum', 1);
const OUT = resolve(process.cwd(), 'src/data/hamleAviBank.json');

async function main() {
  await preloadWordSet();
  const meanings: Record<string, unknown> = JSON.parse(
    readFileSync(resolve(process.cwd(), 'src/data/meanings.json'), 'utf8'),
  );
  const bank: HamleAviPosition[] = [];
  const sigs = new Set<string>();
  let attempt = 0;
  let rej = { short: 0, meaning: 0, count: 0, key: 0, incomplete: 0, rack: 0, dead: 0, replay: 0, dup: 0 };
  const t0 = Date.now();
  while (bank.length < N && attempt < N * 40) {
    const seed = SEED * 100000 + attempt++;
    const r = mulberry32(seed ^ 0x9e3779b9);
    const target = 6 + Math.floor(r() * 31);
    const state = playUntil(seed, target);
    if (!state) { rej.dead++; continue; }
    const me = state.players[state.current];
    if (me.rack.length < 7) { rej.rack++; continue; }
    const s = solve(state, 300);
    if (!s.best) { rej.dead++; continue; }
    if (s.incomplete) { rej.incomplete++; continue; }
    if (s.bestNet < 10) { rej.key++; continue; }
    if (s.bestWord.length < 3) { rej.short++; continue; }
    if (!(trLower(s.bestWord) in meanings)) { rej.meaning++; continue; }
    // Anahtara ulaşan hamle sayısı: yalnızca TEKİL seviyeler tutulduğundan
    // çözücüden ayrıca sayılamaz → en iyi ile ikinci seviye açıklığı ≥2 şartı.
    if (s.levels.length < 2 || s.levels[0] - s.levels[1] < 2) { rej.count++; continue; }
    if (replayDelta(state, s.best) !== s.bestNet) { rej.replay++; continue; }
    const t: HamleAviPosition['t'] = [];
    state.board.forEach((row, rr) =>
      row.forEach((c, cc) => {
        if (!c) return;
        t.push(c.wild
          ? [rr, cc, c.wildLetter ?? 'A', c.owner ?? 0, 1]
          : [rr, cc, c.letter, c.owner ?? 0]);
      }),
    );
    const rack = me.rack.map((x) => x.letter).join('');
    const sig = JSON.stringify([t, rack, state.current]);
    if (sigs.has(sig)) { rej.dup++; continue; }
    sigs.add(sig);
    bank.push({ id: seed, o: state.current, t, r: rack, k: s.bestNet, w: s.bestWord });
    if (bank.length % 50 === 0) console.log(`${bank.length}/${N} (${attempt} deneme, ${Math.round((Date.now() - t0) / 1000)} sn)`);
  }
  writeFileSync(OUT, JSON.stringify(bank));
  console.log(`\n${bank.length} pozisyon → ${OUT} (${(JSON.stringify(bank).length / 1024).toFixed(0)} KB)`);
  console.log('elenen:', JSON.stringify(rej));
  const keys = bank.map((b) => b.k).sort((a, b) => a - b);
  console.log(`anahtar: en az ${keys[0]} · medyan ${keys[keys.length >> 1]} · en çok ${keys[keys.length - 1]}`);
}
main().catch((e) => { console.error(e); process.exit(1); });
