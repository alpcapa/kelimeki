// Kelimeki — "Hamle Avı" (en iyi hamleyi bul) fizibilite ölçümü (30 Ekim 2026).
//
// NE ÖLÇER: YZ↔YZ oyunlarından rastgele bir tur kesiti alıp o pozisyondaki
// sıra sahibi için TÜM geçerli hamleleri VERGİ DAHİL net puana göre sıralar
// (kullanıcı kararı: bölge vergisi bulmacaya dahil, gerçek oyunla uyumlu).
// Çıktı: 1./2./3. puan SEVİYELERİ arasındaki açıklık, vergi tuzağı oranı
// ("en yüksek ham puanlı hamle vergi yüzünden en iyi değil"), çözücü süresi.
//
// MOTORA DOKUNMAZ. `findAIMoves` vergisiz hamle varsa listeyi YALNIZCA
// onlardan kurar (ai.ts, `safe` ↔ `any`), yani vergili-ama-net-yüksek bir
// hamleyi göstermez. Bunu motoru değiştirmeden aşmak için rakipler "teslim
// olmuş" kopyalanır (`computeAllTerritories` teslim olanı boş sayar → hiçbir
// hamle vergili görünmez → liste HAM puana göre sıralı), sonra her aday için
// gerçek `computeInvasionSplit` ile net puan hesaplanır. net ≤ ham olduğundan
// tamlık koşulu: liste dolu ise EN KÜÇÜK ham puan, üçüncü net seviyeden KESİN
// küçük olmalı — değilse o pozisyon "eksik" sayılır (listeden kaçan bir hamle
// 3. seviyeyi değiştirebilir).
//
// ⚠ Çözücünün sınırı: Zor arama kelime havuzu ≤ 8 harf (AI_LEVEL_SEARCH.zor).
// Oyuncu daha uzun/başka bir hamle bulursa anahtarı aşabilir → üretimde puan
// SIRAYLA değil EŞİKLE verilmeli (docs/decisions/product-backlog.md).
//
// Koşum (repo kökünden):
//   npm run measure-hamle-avi                       # 50 pozisyon, tohum 1
//   npm run measure-hamle-avi -- --n 100 --tohum 7 --liste 400
//   npm run measure-hamle-avi -- --json /yol/pozisyonlar.json   # pozisyonları da yaz
import { writeFileSync } from 'node:fs';
import { gameReducer } from '../src/game/gameReducer';
import { preloadWordSet } from '../src/data/wordSetLoader';
import { mulberry32, playUntil, solve, replayDelta } from './lib/hamle-avi-solver';

interface Args {
  count: number;
  seed: number;
  /** findAIMoves'a verilen n — ham puana göre en iyi bu kadar hamle. */
  list: number;
  json?: string;
}

function parseArgs(argv: string[]): Args {
  const a: Args = { count: 50, seed: 1, list: 300 };
  for (let i = 0; i < argv.length; i++) {
    const flag = argv[i];
    const val = argv[i + 1];
    const need = (): string => {
      if (val === undefined) throw new Error(`${flag} bir değer ister`);
      i++;
      return val;
    };
    switch (flag) {
      case '--n':
        a.count = Number(need());
        break;
      case '--tohum':
        a.seed = Number(need());
        break;
      case '--liste':
        a.list = Number(need());
        break;
      case '--json':
        a.json = need();
        break;
      default:
        throw new Error(`bilinmeyen argüman: ${flag}`);
    }
  }
  if (!Number.isFinite(a.count) || a.count < 1) throw new Error('--n ≥ 1 olmalı');
  if (!Number.isFinite(a.list) || a.list < 10) throw new Error('--liste ≥ 10 olmalı');
  return a;
}

const q = (xs: number[], p: number): number => {
  if (xs.length === 0) return 0;
  const s = [...xs].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor(p * s.length))];
};
const pct = (n: number, d: number) => `%${d === 0 ? 0 : Math.round((n / d) * 100)}`;

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  await preloadWordSet();
  console.log(
    `Hamle Avı ölçümü — ${args.count} pozisyon, temel tohum ${args.seed}, liste ${args.list}, Zor arama (≤8 harf)\n`,
  );

  const rows: { i: number; turn: number; rack: number; s: Solved }[] = [];
  let replayOk = 0;
  let replayBad = 0;
  const replayFail: string[] = [];
  const dump: unknown[] = [];
  let skipped = 0;
  let attempt = 0;
  while (rows.length < args.count && attempt < args.count * 5) {
    const seed = args.seed * 1000 + attempt++;
    const r = mulberry32(seed ^ 0x9e3779b9);
    const target = 6 + Math.floor(r() * 31); // 6..36. tur
    const state = playUntil(seed, target);
    if (!state) {
      skipped++;
      continue;
    }
    const me = state.players[state.current];
    if (me.rack.length < 7) {
      skipped++; // torba bitmiş: bulmaca için tam raf istiyoruz
      continue;
    }
    const s = solve(state, args.list);
    if (s.levels.length === 0) {
      skipped++;
      continue;
    }
    if (s.best) {
      const delta = replayDelta(state, s.best);
      if (delta === s.bestNet) replayOk++;
      else {
        replayBad++;
        replayFail.push(`tohum ${seed}: ${s.best.word} beklenen ${s.bestNet}, reducer ${delta}`);
      }
    }
    rows.push({ i: rows.length + 1, turn: state.turnCount, rack: me.rack.length, s });
    if (args.json) {
      dump.push({
        seed,
        turn: state.turnCount,
        owner: state.current,
        board: state.board,
        bonuses: state.bonuses,
        players: state.players.map((p) => ({ corners: p.corners, score: p.score })),
        rack: me.rack,
        levels: s.levels.slice(0, 3),
        bestWord: s.bestWord,
      });
    }
  }

  console.log('| # | tur | hamle | seviyeler (net) | en iyi kelime | ham→net | tuzak | süre ms |');
  console.log('|---|---|---|---|---|---|---|---|');
  for (const { i, turn, s } of rows) {
    console.log(
      `| ${i} | ${turn} | ${s.valid} | ${s.levels.slice(0, 3).join(' / ')} | ${s.bestWord} | ` +
        `${s.bestRaw}→${s.bestNet}${s.incomplete ? ' ⚠eksik' : ''} | ${s.trap ? 'EVET' : '-'} | ${Math.round(s.ms)} |`,
    );
  }

  const n = rows.length;
  const three = rows.filter((r) => r.s.levels.length >= 3);
  const gap = three.map((r) => r.s.levels[0] - r.s.levels[2]);
  const gap12 = three.map((r) => r.s.levels[0] - r.s.levels[1]);
  const times = rows.map((r) => r.s.ms);
  const lens = rows.map((r) => r.s.bestWord.length);
  console.log('\nÖZET');
  console.log(`- pozisyon: ${n} (atlanan/yeniden denenen: ${skipped})`);
  console.log(`- ≥3 farklı puan seviyesi olan: ${three.length}/${n} (${pct(three.length, n)})`);
  console.log(`- 1.→3. seviye açıklığı (puan): p25 ${q(gap, 0.25)} · medyan ${q(gap, 0.5)} · p75 ${q(gap, 0.75)} · en az ${q(gap, 0)}`);
  console.log(`- 1.→2. seviye açıklığı (puan): p25 ${q(gap12, 0.25)} · medyan ${q(gap12, 0.5)} · p75 ${q(gap12, 0.75)}`);
  console.log(`- 1.→2. açıklık ≥3 olan: ${gap12.filter((g) => g >= 3).length}/${three.length} · ≥5: ${gap12.filter((g) => g >= 5).length}/${three.length}`);
  console.log(`- en iyi kelime 2 harfli: ${lens.filter((l) => l === 2).length}/${n}`);
  console.log(`- DOĞRULAMA (en iyi hamle gerçek reducer'da oynatıldı, skor farkı = net puan): ${replayOk}/${replayOk + replayBad} uyumlu`);
  for (const f of replayFail) console.log(`  ✗ ${f}`);
  console.log(`- açıklık ≥5 olan: ${gap.filter((g) => g >= 5).length}/${three.length} · ≥10: ${gap.filter((g) => g >= 10).length}/${three.length}`);
  console.log(`- en iyi net hamle VERGİLİ: ${rows.filter((r) => r.s.bestTaxed).length}/${n}`);
  console.log(`- vergi TUZAĞI (en yüksek ham puanlı hamle net en iyi değil): ${rows.filter((r) => r.s.trap).length}/${n}`);
  console.log(`- liste yetersiz (⚠eksik): ${rows.filter((r) => r.s.incomplete).length}/${n}`);
  console.log(`- geçerli hamle sayısı: medyan ${q(rows.map((r) => r.s.valid), 0.5)} · en az ${q(rows.map((r) => r.s.valid), 0)}`);
  console.log(`- en iyi kelime uzunluğu: medyan ${q(lens, 0.5)} · ≥8 harf: ${lens.filter((l) => l >= 8).length}/${n}`);
  console.log(`- çözücü süresi ms: medyan ${Math.round(q(times, 0.5))} · p90 ${Math.round(q(times, 0.9))} · en çok ${Math.round(q(times, 1))}`);

  if (args.json) {
    writeFileSync(args.json, JSON.stringify(dump));
    console.log(`\n${dump.length} pozisyon yazıldı → ${args.json}`);
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
