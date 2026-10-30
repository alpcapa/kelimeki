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
import { performance } from 'node:perf_hooks';
import { writeFileSync } from 'node:fs';
import type { AIMove, GameState } from '../src/game/types';
import { gameReducer, createInitialState, isFirstMove, type Action } from '../src/game/gameReducer';
import { preloadWordSet } from '../src/data/wordSetLoader';
import { findAIMoves } from '../src/utils/ai';
import { computeInvasionSplit } from '../src/utils/validator';
import { AI_LEVEL_SEARCH } from '../src/game/constants';
import { setRandomSource } from '../src/utils/random';

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

// Golden üreticisi ve simulate-ai-levels ile aynı mulberry32.
function mulberry32(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** İki oyunculu YZ↔YZ oyununu `targetTurn`e kadar oynatır; oyun erken bitmişse null. */
function playUntil(seed: number, targetTurn: number): GameState | null {
  setRandomSource(mulberry32(seed));
  let state: GameState = createInitialState();
  const d = (a: Action) => {
    state = gameReducer(state, a);
  };
  d({
    type: 'START',
    players: [
      { name: 'Normal', isAI: true },
      { name: 'Normal', isAI: true },
    ],
  });
  let guard = 0;
  while (!state.isGameOver && state.turnCount < targetTurn && guard++ < 400) d({ type: 'AI_PLAY' });
  if (state.isGameOver || state.turnCount < targetTurn) return null;
  return state;
}

interface Solved {
  best: AIMove | null;
  /** Seviye değerleri (net puan), büyükten küçüğe, TEKİL. */
  levels: number[];
  bestWord: string;
  bestRaw: number;
  bestNet: number;
  /** En iyi net hamle vergili mi (net < ham)? */
  bestTaxed: boolean;
  /** En yüksek HAM puanlı hamle, net en iyiden düşük mü (vergi tuzağı)? */
  trap: boolean;
  valid: number;
  /** Liste dolu ve en küçük ham puan 3. seviyeye eşit/büyük → hamle kaçmış olabilir. */
  incomplete: boolean;
  ms: number;
}

function sig(m: AIMove): string {
  return m.placements
    .map((p) => `${p.r},${p.c},${p.tile.wild ? '?' + (p.tile.wildLetter ?? '') : p.tile.letter}`)
    .sort()
    .join('|');
}

function solve(state: GameState, listN: number): Solved {
  const owner = state.current;
  const me = state.players[owner];
  // Rakipleri "teslim olmuş" say → bölgeleri boş → liste ham puana göre sıralı.
  const noTax = state.players.map((p, i) => (i === owner ? p : { ...p, surrendered: true }));
  const t0 = performance.now();
  const raw = findAIMoves(
    state.board, me.rack, state.bonuses, owner, me.corners, isFirstMove(state), noTax, listN,
    AI_LEVEL_SEARCH.zor,
  );
  const seen = new Set<string>();
  const scored: { move: AIMove; net: number }[] = [];
  for (const m of raw) {
    const s = sig(m);
    if (seen.has(s)) continue;
    seen.add(s);
    const coords = m.placements.map((p) => [p.r, p.c] as [number, number]);
    const net = computeInvasionSplit(coords, owner, state.players, m.score, state.board).pts;
    scored.push({ move: m, net });
  }
  const ms = performance.now() - t0;
  scored.sort((a, b) => b.net - a.net);
  const levels = [...new Set(scored.map((x) => x.net))];
  const best = scored[0];
  const minRaw = raw.length > 0 ? raw[raw.length - 1].score : 0;
  const full = raw.length >= listN;
  const l3 = levels[2];
  const incomplete = full && (l3 === undefined || minRaw >= l3);
  const topRaw = raw.length > 0 ? raw[0].score : 0;
  return {
    best: best ? best.move : null,
    levels,
    bestWord: best ? best.move.word : '-',
    bestRaw: best ? best.move.score : 0,
    bestNet: best ? best.net : 0,
    bestTaxed: best ? best.net < best.move.score : false,
    trap: best ? topRaw > best.net : false,
    valid: scored.length,
    incomplete,
    ms,
  };
}

/**
 * Doğrulama: en iyi hamleyi GERÇEK reducer'dan (PLACE_TILE + PLAY) geçirir ve
 * sıra sahibinin skor farkını döndürür. Bu, "ham puandan vergi düşme"
 * hesabının oyunun gerçek kuralıyla aynı sonucu verdiğinin kanıtı.
 */
function replayDelta(state: GameState, move: AIMove): number | null {
  const owner = state.current;
  let st = state;
  for (const p of move.placements) {
    const rack = st.players[owner].rack;
    const idx = p.tile.wild
      ? rack.findIndex((t) => t.letter === '?')
      : rack.findIndex((t) => t.letter === p.tile.letter);
    if (idx < 0) return null;
    st = gameReducer(
      st,
      p.tile.wild
        ? { type: 'PLACE_TILE', r: p.r, c: p.c, rackIndex: idx, wildLetter: p.tile.wildLetter }
        : { type: 'PLACE_TILE', r: p.r, c: p.c, rackIndex: idx },
    );
  }
  const before = st.turnCount;
  st = gameReducer(st, { type: 'PLAY' });
  if (st.turnCount === before) return null;
  return st.players[owner].score - state.players[owner].score;
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
