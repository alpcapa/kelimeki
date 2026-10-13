// Kelimeki — kısa video senaryoları için ÖLÇÜM betiği (üretime girmez).
// Motorun kendisini çağırıp hangi hamlelerin gerçekten oynanabilir olduğunu listeler.
import { preloadWordSet } from '../../src/data/wordSetLoader';
import { buildSnapshotGameState } from '../../src/utils/boardSnapshot';
import { DEMO_TILES_2 } from '../../src/landing/demoBoard';
import { findAIMoves } from '../../src/utils/ai';
import { computeInvasionSplit } from '../../src/utils/validator';
import { buildBag } from '../../src/utils/bag';
import { setRandomSource } from '../../src/utils/random';
import { AI_LEVEL_SEARCH, RACK_SIZE } from '../../src/game/constants';
import type { GameState } from '../../src/game/types';

function mulberry32(a: number) {
  return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
function taban(): GameState {
  return buildSnapshotGameState(DEMO_TILES_2, 2, [
    { name: 'Sen', score: 148, is_ai: false, colorIndex: 0 },
    { name: 'Yapay Zeka', score: 132, is_ai: true, colorIndex: 1 },
  ]);
}
function kalanTorba(st: GameState) {
  const bag = buildBag();
  for (const row of st.board) for (const cell of row) if (cell) {
    const i = bag.findIndex((t) => t.letter === (cell.wild ? '?' : cell.letter)); if (i >= 0) bag.splice(i, 1);
  }
  return bag;
}
async function main() {
  await preloadWordSet();
  const mod = process.argv[2] ?? 'v1';
  const rows: any[] = [];
  const nSeeds = Number(process.argv[3] ?? 120);
  for (let seed = 1; seed <= nSeeds; seed++) {
    setRandomSource(mulberry32(seed));
    const st = taban();
    const bag = kalanTorba(st);
    const rack = bag.slice(0, RACK_SIZE);
    const moves = findAIMoves(st.board, rack, st.bonuses, 0, st.players[0].corners, false, mod === 'v2' ? st.players.map((p) => ({ ...p, surrendered: true })) : st.players, 400, AI_LEVEL_SEARCH.zor);
    for (const m of moves) {
      const coords = m.placements.map((p) => [p.r, p.c] as [number, number]);
      const sp = computeInvasionSplit(coords, 0, st.players, m.score, st.board);
      const tax = m.score - sp.pts;
      rows.push({ seed, raf: rack.map((t) => t.letter).join(''), kelime: m.word, brut: m.score, net: sp.pts, tax,
        opp: sp.shares.reduce((a, s) => a + s.amount, 0), n: m.placements.length,
        h: m.placements.map((p) => `${p.r},${p.c}${p.tile.wild ? '?' : ''}`).join(' ') });
    }
  }
  if (mod === 'v1') {
    const uniq = new Map<string, any>(); for (const r of rows) if (!r.h.includes('?')) uniq.set(r.seed + r.kelime + r.h, r);
    const lst = [...uniq.values()].sort((a, b) => b.brut - a.brut);
    for (const r of lst.slice(0, 12)) console.log(JSON.stringify(r));
  } else {
    console.error('hamle', rows.length, 'vergili', rows.filter((r) => r.tax > 0).length);
    // v2: aynı rafta (seed) yüksek vergili hamle vs vergisiz hamle
    const by = new Map<number, any[]>(); for (const r of rows) (by.get(r.seed) ?? by.set(r.seed, []).get(r.seed)!).push(r);
    const out: any[] = [];
    for (const [seed, list] of by) {
      const vergili = list.filter((r) => r.tax > 0 && !r.h.includes('?')).sort((a, b) => b.brut - a.brut)[0];
      const vergisiz = list.filter((r) => r.tax === 0 && !r.h.includes('?')).sort((a, b) => b.brut - a.brut)[0];
      if (vergili && vergisiz && vergili.brut > vergisiz.brut) out.push({ seed, vergili, vergisiz,
        farkV: vergili.net - vergili.opp, farkS: vergisiz.net });
    }
    out.sort((a, b) => (b.farkS - b.farkV) - (a.farkS - a.farkV));
    for (const o of out.slice(0, 8)) console.log(JSON.stringify(o));
  }
}
main();
