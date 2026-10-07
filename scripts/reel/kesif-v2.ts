// Video 2 ölçümü: gerçek (YZ↔YZ) oyun ortalarında "yüksek puanlı VERGİLİ" ↔ "düşük puanlı VERGİSİZ" ikilemi arar.
import { preloadWordSet } from '../../src/data/wordSetLoader';
import { gameReducer, createInitialState, type Action } from '../../src/game/gameReducer';
import { findAIMoves } from '../../src/utils/ai';
import { computeInvasionSplit } from '../../src/utils/validator';
import { setRandomSource } from '../../src/utils/random';
import { AI_LEVEL_SEARCH } from '../../src/game/constants';
import type { GameState } from '../../src/game/types';

function mulberry32(a: number) {
  return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
async function main() {
  await preloadWordSet();
  const out: any[] = [];
  const seeds = Number(process.argv[2] ?? 30);
  for (let seed = 1; seed <= seeds; seed++) {
    setRandomSource(mulberry32(seed));
    let st: GameState = createInitialState();
    const d = (a: Action) => { st = gameReducer(st, a); };
    d({ type: 'START', players: [{ name: 'Sen', isAI: true }, { name: 'Yapay Zeka', isAI: true }] });
    // insan koltuğunu da YZ gibi oynat
    let g = 0;
    while (!st.isGameOver && g++ < 40) {
      if (st.turnCount >= 8 && st.current === 0 && st.bag.length > 20) {
        const me = st.players[0];
        const ghost = st.players.map((p) => ({ ...p, surrendered: true }));
        const mv = findAIMoves(st.board, me.rack, st.bonuses, 0, me.corners, false, ghost, 300, AI_LEVEL_SEARCH.zor)
          .filter((m) => !m.placements.some((p) => p.tile.wild));
        const rows = mv.map((m) => {
          const sp = computeInvasionSplit(m.placements.map((p) => [p.r, p.c] as [number, number]), 0, st.players, m.score, st.board);
          const opp = sp.shares.reduce((a, s) => a + s.amount, 0);
          return { m, brut: m.score, net: sp.pts, opp, tax: m.score - sp.pts };
        });
        const A = rows.filter((r) => r.tax > 0).sort((a, b) => b.brut - a.brut)[0];
        const B = rows.filter((r) => r.tax === 0).sort((a, b) => b.brut - a.brut)[0];
        if (A && B && A.net > B.brut && A.net - A.opp < B.brut && A.m.placements.length <= 4 && B.m.placements.length <= 4) {
          out.push({ seed, turn: st.turnCount, rack: me.rack.map((t) => t.letter).join(''),
            A: [A.m.word, A.brut, A.net, A.opp, A.m.placements.length], B: [B.m.word, B.brut, B.m.placements.length],
            skorlar: st.players.map((p) => p.score), fark: (A.net - A.opp) - B.brut });
        }
      }
      d({ type: 'AI_PLAY' });
    }
  }
  out.sort((a, b) => a.fark - b.fark);
  for (const o of out.slice(0, 12)) console.log(JSON.stringify(o));
  console.error('bulunan', out.length);
}
main();
