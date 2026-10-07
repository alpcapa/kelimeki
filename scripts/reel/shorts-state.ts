// Kelimeki — kısa video (Reels/Shorts/TikTok) sahneleri. Üç senaryo da GERÇEK motordan ÖLÇÜLÜR:
// hamleler `findAIMoves` ile bulunur (sözlük/bitişiklik/puan motorun kendisinden), vergi payı
// `computeInvasionSplit`ten gelir. Elle "şu kelimeyi şuraya koyayım" YOK.
//
//  1 · enYuksek — tanıtım tahtası + sabit raf; rafın en yüksek puanlı hamlesi (merkez X3).
//  2 · vergi    — YZ↔YZ gerçek oyundan bir tur; yüksek puanlı VERGİLİ ↔ düşük puanlı VERGİSİZ.
//  3 · cift     — YZ↔YZ gerçek oyunun sonu (torba boş); 40 geride, rafta 2 joker → +50 bitiş.
//
// ⚠ Seçim ölçütleri `kesif*.ts`te; buradaki sabitler (tohum/tur) o ölçümlerin çıktısı.
import { preloadWordSet } from '../../src/data/wordSetLoader';
import { buildSnapshotGameState } from '../../src/utils/boardSnapshot';
import { DEMO_TILES_2 } from '../../src/landing/demoBoard';
import { buildBag } from '../../src/utils/bag';
import { letterPoints } from '../../src/data/tiles';
import { gameReducer, createInitialState, type Action } from '../../src/game/gameReducer';
import { findAIMoves } from '../../src/utils/ai';
import { computeInvasionSplit } from '../../src/utils/validator';
import { setRandomSource } from '../../src/utils/random';
import { AI_LEVEL_SEARCH, jokerFinishBonus } from '../../src/game/constants';
import type { AIMove, GameState, Tile } from '../../src/game/types';

export interface Adim { rafHarfi: string; r: number; c: number; joker?: string }
export interface Hamle { kelime: string; brut: number; net: number; rakipPayi: number; adimlar: Adim[] }

function mulberry32(a: number) {
  return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
const tas = (l: string): Tile => ({ letter: l, pts: l === '?' ? 0 : letterPoints(l) });

function hamleOf(st: GameState, m: AIMove, owner = 0): Hamle {
  const sp = computeInvasionSplit(m.placements.map((p) => [p.r, p.c] as [number, number]), owner, st.players, m.score, st.board);
  return {
    kelime: m.word, brut: m.score, net: sp.pts, rakipPayi: sp.shares.reduce((a, s) => a + s.amount, 0),
    adimlar: m.placements.map((p) => ({ rafHarfi: p.tile.wild ? '?' : p.tile.letter, r: p.r, c: p.c, joker: p.tile.wild ? p.tile.wildLetter : undefined })),
  };
}
/** Vergi paylaşımı olmadan (YZ'nin "güvenli hamle" tercihi devre dışı) BÜTÜN hamleler. */
function tumHamleler(st: GameState, rack: Tile[], n = 300): AIMove[] {
  const ghost = st.players.map((p) => ({ ...p, surrendered: true }));
  return findAIMoves(st.board, rack, st.bonuses, 0, st.players[0].corners, false, ghost, n, AI_LEVEL_SEARCH.zor);
}
function hazirla(st: GameState): GameState {
  const s: GameState = JSON.parse(JSON.stringify(st));
  s.players[0].isAI = false;
  s.players[0].name = 'Sen';
  s.players[1].name = 'Yapay Zeka';
  s.isGameOver = false; s.current = 0; s.placed = {};
  s.message = 'Sıra sende.'; s.messageType = '';
  return s;
}
function oynaYZ(seed: number, dur: (st: GameState) => boolean): GameState {
  setRandomSource(mulberry32(seed));
  let st: GameState = createInitialState();
  const d = (a: Action) => { st = gameReducer(st, a); };
  d({ type: 'START', players: [{ name: 'Sen', isAI: true }, { name: 'Yapay Zeka', isAI: true }] });
  let g = 0;
  while (!st.isGameOver && g++ < 200) { if (dur(st)) return st; d({ type: 'AI_PLAY' }); }
  throw new Error(`senaryo durumu bulunamadı (tohum ${seed})`);
}

export async function senaryolar() {
  await preloadWordSet();

  // ── 1 · en yüksek puanlı hamle ─────────────────────────────────────────
  const s1 = buildSnapshotGameState(DEMO_TILES_2, 2, [
    { name: 'Sen', score: 148, is_ai: false, colorIndex: 0 },
    { name: 'Yapay Zeka', score: 132, is_ai: true, colorIndex: 1 },
  ]);
  const raf1 = Array.from('ÇÖVÜZÜI').map(tas);
  const yz1 = Array.from('ELMİTON').map(tas);
  const kalan = buildBag();
  for (const row of s1.board) for (const c of row) if (c) { const i = kalan.findIndex((t) => t.letter === (c.wild ? '?' : c.letter)); if (i >= 0) kalan.splice(i, 1); }
  for (const t of [...raf1, ...yz1]) { const i = kalan.findIndex((x) => x.letter === t.letter); if (i >= 0) kalan.splice(i, 1); }
  kalan.length = Math.min(kalan.length, Math.max(0, 100 - s1.board.flat().filter(Boolean).length - 14));
  s1.players[0].rack = raf1; s1.players[1].rack = yz1; s1.bag = kalan;
  s1.turnCount = 24; s1.startedAt = new Date(0).toISOString();
  const durum1 = hazirla(s1);
  const m1 = tumHamleler(durum1, raf1).sort((a, b) => b.score - a.score)[0];
  const e1 = hamleOf(durum1, m1);

  // ── 2 · vergili ↔ vergisiz ─────────────────────────────────────────────
  const s2 = oynaYZ(21, (s) => s.turnCount === 14 && s.current === 0);
  const durum2 = hazirla(s2);
  const hepsi2 = tumHamleler(durum2, durum2.players[0].rack).filter((m) => !m.placements.some((p) => p.tile.wild)).map((m) => hamleOf(durum2, m));
  const A = hepsi2.filter((h) => h.brut !== h.net).sort((a, b) => b.brut - a.brut)[0];
  const B = hepsi2.filter((h) => h.brut === h.net).sort((a, b) => b.brut - a.brut)[0];

  // ── 3 · çift joker bitişi ──────────────────────────────────────────────
  const s3 = oynaYZ(4, (s) => s.bag.length === 0 && s.current === 0 && s.players[1].rack.length >= 2 && s.players[1].rack.length <= 4);
  const durum3 = hazirla(s3);
  durum3.players[0].rack = [tas('?'), tas('?')];
  durum3.players[0].score = durum3.players[1].score - 40; // örnek: 40 puan geride
  const m3 = findAIMoves(durum3.board, durum3.players[0].rack, durum3.bonuses, 0, durum3.players[0].corners, false, durum3.players, 20, AI_LEVEL_SEARCH.zor)
    .filter((m) => m.placements.length === 2).sort((a, b) => b.score - a.score || Number(b.word === 'DAĞCI') - Number(a.word === 'DAĞCI'))[0];
  const e3 = hamleOf(durum3, m3);
  const rakipRaf = durum3.players[1].rack.reduce((s, t) => s + t.pts, 0);
  const sen = durum3.players[0].score + e3.net + jokerFinishBonus(2);
  const rak = durum3.players[1].score - rakipRaf;

  return {
    enYuksek: { durum: durum1, hamle: e1 },
    vergi: { durum: durum2, A, B },
    cift: { durum: durum3, hamle: e3, bonus: jokerFinishBonus(2), onceki: [durum3.players[0].score, durum3.players[1].score], sonuc: [sen, rak], rakipRaf },
  };
}
