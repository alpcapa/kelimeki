// Kelimeki — Hamle Avı doğrulayıcısı (3 Kasım 2026, ROADMAP #48).
//
// 1) Saf mantık: seri/rekor kuralları, "görülenler" seçimi (tekrar YOK), birleşim.
// 2) BANKA TAZELİĞİ: bankadan örnek pozisyonlar motorla YENİDEN çözülür ve
//    anahtar (`k`) tutmalı — puan/vergi/bölge kuralı değişirse banka sessizce
//    bayatlardı (bu proje o sınıf hatayı birkaç kez yaşadı). Bankayı
//    `npm run generate-hamle-avi-bank` ile yeniden üret.
// 3) Biçim: 7 harflik raf, tahta sınırları, tekil kimlik.
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { preloadWordSet } from '../src/data/wordSetLoader';
import { gameReducer } from '../src/game/gameReducer';
import {
  HAMLE_AVI_SECONDS, isCorrect, mergeSeen, netGain, onFound, onMissed, pickNext,
  positionToState, shouldWarnOnLeave, type HamleAviPosition,
} from '../src/utils/hamleAvi';
import { solve, replayDelta } from './lib/hamle-avi-solver';

let fail = 0;
const ok = (c: boolean, m: string) => { if (!c) { fail++; console.log('✗ ' + m); } };

const bank: HamleAviPosition[] = JSON.parse(readFileSync(resolve(process.cwd(), 'src/data/hamleAviBank.json'), 'utf8'));
ok(bank.length > 0, 'banka boş');
ok(HAMLE_AVI_SECONDS === 180, 'süre 3 dk olmalı (kullanıcı kararı 3 Kas 2026)');

// 3) biçim
ok(new Set(bank.map((p) => p.id)).size === bank.length, 'kimlikler tekil değil');
for (const p of bank) {
  ok(p.r.length === 7, `#${p.id}: raf 7 değil`);
  ok(p.o === 0 || p.o === 1, `#${p.id}: sahip 0/1 değil`);
  ok(p.t.every(([r, c]) => r >= 0 && r < 13 && c >= 0 && c < 13), `#${p.id}: tahta dışı taş`);
  ok(p.k >= 10 && p.w.length >= 3, `#${p.id}: kalite filtresi ihlali`);
}

// 1) saf mantık
let s = { streak: 0, best: 4 };
s = onFound(s); s = onFound(s);
ok(s.streak === 2 && s.best === 4, 'seri 2, rekor 4 kalmalı');
ok(shouldWarnOnLeave(s), 'seri varken çıkış uyarısı gerekir');
for (let i = 0; i < 3; i++) s = onFound(s);
ok(s.best === 5, 'rekor yükselmeli');
s = onMissed(s);
ok(s.streak === 0 && s.best === 5, 'kaçırınca seri 0, rekor korunur');
ok(!shouldWarnOnLeave(s), 'seri 0 iken uyarı gereksiz');

const seen = new Set<number>();
const rnd = (() => { let a = 7; return () => ((a = (a * 1664525 + 1013904223) >>> 0) / 4294967296); })();
for (let i = 0; i < bank.length; i++) {
  const p = pickNext(bank, seen, rnd);
  ok(!!p && !seen.has(p.id), 'görülen bulmaca tekrar çıktı');
  if (p) seen.add(p.id);
}
ok(pickNext(bank, seen, rnd) === null, 'banka bitince null dönmeli');
ok(JSON.stringify(mergeSeen([3, 1], [2, 3])) === '[1,2,3]', 'birleşim sıralı ve tekil olmalı');

// 2) tazelik
async function main() {
  await preloadWordSet();
  const sample = bank.filter((_, i) => i % Math.max(1, Math.floor(bank.length / 25)) === 0).slice(0, 25);
  for (const p of sample) {
    const st = positionToState(p, 'Sen');
    const sol = solve(st, 300);
    ok(sol.bestNet === p.k, `#${p.id}: bayat banka — anahtar ${p.k}, motor ${sol.bestNet}`);
    if (sol.best) {
      const d = replayDelta(st, sol.best);
      ok(d === p.k, `#${p.id}: reducer farkı ${d} ≠ anahtar ${p.k}`);
      ok(isCorrect(d ?? -1, p), `#${p.id}: en iyi hamle "doğru" sayılmadı`);
    }
    ok(!isCorrect(p.k - 1, p), `#${p.id}: anahtarın altı doğru sayıldı`);
  }
  // PLAY yolu: pas geçmek skor farkı 0 → doğru değil
  const st0 = positionToState(sample[0], 'Sen');
  ok(netGain(st0, gameReducer(st0, { type: 'PASS' })) === 0, 'pas net 0 olmalı');
  console.log(fail === 0 ? `✓ hamle-avi: ${bank.length} pozisyon, ${sample.length} yeniden çözüldü` : `✗ ${fail} hata`);
  process.exit(fail === 0 ? 0 : 1);
}
main();
