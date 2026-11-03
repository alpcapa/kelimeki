// Kelimeki — Hamle Avı: pozisyonun EN İYİ hamlesini cihazda bulur (3 Kasım 2026).
//
// Banka yalnızca anahtarı (`k`) ve kelimeyi (`w`) taşır, hamlenin kendisini DEĞİL
// (bankayı bunun için yeniden üretmek ~45 dk + ~2× boyut). Süre bitince "doğru
// hamle şuydu" tahtada gösterilsin diye çözücü burada, yalnızca o an çalışır.
// Mantık `scripts/lib/hamle-avi-solver.ts` → `solve`un birebir çekirdeği (bankayı
// üreten çözücü); `verify-hamle-avi` ikisinin aynı anahtarı verdiğini kilitler.
//
// Motora DOKUNMAZ: rakipler "teslim olmuş" kopyalanır (bölgeleri boş → `findAIMoves`
// vergisiz, ham puana göre sıralı liste verir), her aday gerçek `computeInvasionSplit`
// ile NET puana çevrilir ve en yükseği seçilir.
import type { AIMove, GameState } from '../game/types';
import { isFirstMove } from '../game/gameReducer';
import { AI_LEVEL_SEARCH } from '../game/constants';
import { findAIMoves } from './ai';
import { computeInvasionSplit } from './validator';

export interface BestMove {
  move: AIMove;
  /** Vergi DAHİL net puan (= `HamleAviPosition.k`). */
  net: number;
}

export function findBestNetMove(state: GameState, listN = 300): BestMove | null {
  const owner = state.current;
  const me = state.players[owner];
  const noTax = state.players.map((p, i) => (i === owner ? p : { ...p, surrendered: true }));
  const raw = findAIMoves(
    state.board, me.rack, state.bonuses, owner, me.corners, isFirstMove(state), noTax, listN,
    AI_LEVEL_SEARCH.zor,
  );
  let best: BestMove | null = null;
  for (const m of raw) {
    const coords = m.placements.map((p) => [p.r, p.c] as [number, number]);
    const net = computeInvasionSplit(coords, owner, state.players, m.score, state.board).pts;
    if (!best || net > best.net) best = { move: m, net };
  }
  return best;
}
