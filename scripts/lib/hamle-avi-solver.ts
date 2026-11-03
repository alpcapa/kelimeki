// Kelimeki — "Hamle Avı" çözücü çekirdeği (3 Kasım 2026). Hem fizibilite ölçümü
// (`measure-hamle-avi.ts`) hem banka üreticisi (`generate-hamle-avi-bank.ts`)
// kullanır; MOTORA DOKUNMAZ (gerekçe: measure-hamle-avi.ts başlığı).
import { performance } from 'node:perf_hooks';
import type { AIMove, GameState } from '../../src/game/types';
import { gameReducer, createInitialState, isFirstMove, type Action } from '../../src/game/gameReducer';
import { findAIMoves } from '../../src/utils/ai';
import { computeInvasionSplit } from '../../src/utils/validator';
import { AI_LEVEL_SEARCH } from '../../src/game/constants';
import { setRandomSource } from '../../src/utils/random';

// Golden üreticisi ve simulate-ai-levels ile aynı mulberry32.
export function mulberry32(seed: number): () => number {
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
export function playUntil(seed: number, targetTurn: number): GameState | null {
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

export interface Solved {
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

export function sig(m: AIMove): string {
  return m.placements
    .map((p) => `${p.r},${p.c},${p.tile.wild ? '?' + (p.tile.wildLetter ?? '') : p.tile.letter}`)
    .sort()
    .join('|');
}

export function solve(state: GameState, listN: number): Solved {
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
export function replayDelta(state: GameState, move: AIMove): number | null {
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

