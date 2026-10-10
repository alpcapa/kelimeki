// Video 3 ölçümü: torba boş, raf = 2 joker → çift jokerli bitiş (+50). Gerçek bir YZ↔YZ oyununun sonundan.
import { preloadWordSet } from '../../src/data/wordSetLoader';
import { gameReducer, createInitialState, type Action } from '../../src/game/gameReducer';
import { findAIMoves } from '../../src/utils/ai';
import { setRandomSource } from '../../src/utils/random';
import { AI_LEVEL_SEARCH } from '../../src/game/constants';
import type { GameState } from '../../src/game/types';

function mulberry32(a: number) {
  return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
async function main() {
  await preloadWordSet();
  const a = Number(process.argv[2] ?? 1), b = Number(process.argv[3] ?? 20);
  for (let seed = a; seed <= b; seed++) {
    setRandomSource(mulberry32(seed));
    let st: GameState = createInitialState();
    const d = (x: Action) => { st = gameReducer(st, x); };
    d({ type: 'START', players: [{ name: 'Sen', isAI: true }, { name: 'Yapay Zeka', isAI: true }] });
    let g = 0;
    while (!st.isGameOver && g++ < 120) {
      if (st.bag.length === 0 && st.current === 0 && st.players[1].rack.length >= 2 && st.players[1].rack.length <= 4) {
        const me = st.players[0];
        const jk = [{ letter: '?', pts: 0 }, { letter: '?', pts: 0 }];
        const mv = findAIMoves(st.board, jk, st.bonuses, 0, me.corners, false, st.players, 20, AI_LEVEL_SEARCH.zor)
          .filter((m) => m.placements.length === 2);
        mv.sort((x, y) => y.score - x.score);
        const oppPts = st.players[1].rack.reduce((s, t) => s + t.pts, 0);
        if (mv[0]) console.log(JSON.stringify({ seed, tur: st.turnCount, tahtaTas: st.board.flat().filter(Boolean).length,
          sen: me.score, rakip: st.players[1].score, rakipRaf: st.players[1].rack.map((t) => t.letter).join(''), rakipRafPuan: oppPts,
          hamle: mv.slice(0, 3).map((m) => [m.word, m.score, m.placements.map((p) => `${p.r},${p.c}=${p.tile.wildLetter}`).join(' ')]) }));
        break;
      }
      d({ type: 'AI_PLAY' });
    }
  }
}
main();
