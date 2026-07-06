// Harfik — tahta boyutu, bölgeler, oyuncu renkleri, bonus yerleşimi
import type { BonusType, CellKey } from './types';

/** Tahta 13x13. */
export const SIZE = 13;

/** Köşe bölgelerinin kenar uzunluğu (5x5). */
export const CORNER = 5;

/** Tüm oyuncular üst üste bu kadar tur pas geçtiğinde oyun biter. */
export const MAX_PASS_ROUNDS = 2;

/** Tüm rafı kullanan hamleye verilen bonus puan. */
export const BINGO_BONUS = 50;

/** Rafta tutulan taş sayısı. */
export const RACK_SIZE = 7;

/**
 * Oyunu bitiren hamlede (raf + torba tamamen boşalırsa) oynanan taşlar
 * arasında joker varsa verilen ekstra bonus: 1 joker +50, 2 joker +150.
 */
export function jokerFinishBonus(jokerCount: number): number {
  if (jokerCount >= 2) return 150;
  if (jokerCount === 1) return 50;
  return 0;
}

/** Bonus kare kısa etiketleri (K3 = üç kat kelime vb.). */
export const BONUS_LABELS: Record<BonusType, string> = {
  tw: 'K3',
  dw: 'K2',
  tl: 'H3',
  dl: 'H2',
};

// ── Oyuncu renkleri ──────────────────────────────────────────────────────────
// Beyaz zemin üzerinde okunur, birbirinden net ayrılan renkler. Her oyuncu
// kendi köşesini bu renge göre tanır.

export interface PlayerColor {
  /** Ana çizgi/çerçeve rengi. */
  base: string;
  /** Köşe bölgesi ve taş arka planı için açık ton. */
  tint: string;
  /** Bölge vurgusu için daha da soluk ton. */
  zone: string;
  /** Renk üzerinde okunan koyu metin. */
  text: string;
}

export const PLAYER_COLORS: PlayerColor[] = [
  { base: '#2563EB', tint: '#AABFFF', zone: '#EEF3FF', text: '#11317A' }, // mavi
  { base: '#DC2626', tint: '#FBDADA', zone: '#FDEFEF', text: '#7A1414' }, // kırmızı
  { base: '#16A34A', tint: '#D6F3E1', zone: '#EDFAF1', text: '#0B5128' }, // yeşil
  { base: '#D97706', tint: '#FCEAD0', zone: '#FEF6EA', text: '#7A4408' }, // turuncu
];

// ── Köşe bölgeleri ───────────────────────────────────────────────────────────
// 0 = sol-üst, 1 = sağ-üst, 2 = sol-alt, 3 = sağ-alt. Her biri CORNER×CORNER.

/** Köşe indeksinin satır/sütun aralığını döndürür. */
export function cornerBounds(corner: number): {
  r0: number;
  r1: number;
  c0: number;
  c1: number;
} {
  const top = corner === 0 || corner === 1;
  const left = corner === 0 || corner === 2;
  return {
    r0: top ? 0 : SIZE - CORNER,
    r1: top ? CORNER - 1 : SIZE - 1,
    c0: left ? 0 : SIZE - CORNER,
    c1: left ? CORNER - 1 : SIZE - 1,
  };
}

/** Bir hücrenin hangi köşe bölgesinde olduğunu döndürür; merkez için -1. */
export function regionOf(r: number, c: number): number {
  for (let i = 0; i < 4; i++) {
    const b = cornerBounds(i);
    if (r >= b.r0 && r <= b.r1 && c >= b.c0 && c <= b.c1) return i;
  }
  return -1;
}

/** Verilen hücre, bu köşe bölgesinin içinde mi? */
export function inCorner(corner: number, r: number, c: number): boolean {
  const b = cornerBounds(corner);
  return r >= b.r0 && r <= b.r1 && c >= b.c0 && c <= b.c1;
}

/**
 * Verilen hücre, köşe bölgesinin "iç sınır" karesinde mi?
 * İç sınır = merkeze bakan kenar satırı/sütunu (5×5'in iç çevresi).
 * Sahip burada oynayınca bölge "ihlal edilmiş" sayılır.
 */
export function isZoneBoundaryCell(corner: number, r: number, c: number): boolean {
  if (!inCorner(corner, r, c)) return false;
  const b = cornerBounds(corner);
  // İç sınır: merkeze en yakın satır VEYA sütun.
  const innerRow = corner <= 1 ? b.r1 : b.r0; // üst köşeler → en alt satır; alt köşeler → en üst satır
  const innerCol = corner === 0 || corner === 2 ? b.c1 : b.c0; // sol köşeler → en sağ sütun; sağ köşeler → en sol sütun
  return r === innerRow || c === innerCol;
}

/**
 * Oyuncu sayısına göre köşe ataması (her oyuncunun sahip olduğu köşe indeksleri).
 *  - 2 oyuncu: dört köşe de kullanılır, her oyuncu kendi çapraz köşe çiftine
 *    sahip olur — 1. oyuncu sol-üst + sağ-alt (0, 3), 2. oyuncu sağ-üst +
 *    sol-alt (1, 2). Böylece köşeler çapraz (X) desende paylaşılır, boş köşe
 *    kalmaz.
 *  - 4 oyuncu: her oyuncu tek bir köşeye sahip olur.
 */
export function cornersFor(playerCount: number): number[][] {
  return playerCount === 2 ? [[0, 3], [1, 2]] : [[0], [1], [2], [3]];
}

// ── Başlangıç bonus yerleşimi ────────────────────────────────────────────────
// Her bonus türü tek bir "tohum" hücreden, tahtanın 8 simetri işlemiyle
// (yatay ayna, dikey ayna, transpoze — ve bunların bileşimleri) türetilir.
// Bu yöntem sayesinde aynı türden iki hücre asla rastlantısal biçimde aynı
// satır/sütunu paylaşmaz: paylaşım varsa tohumun kendisiyle simetriği
// arasındadır ve mesafesi bilinçli seçilmiştir.
//   K2/K3 (kelime çarpanı): aynı satır/sütunda en az 8 hücre mesafe — bir
//   kelimenin iki kelime çarpanına birden basıp puanı 4-9 kat katlaması
//   neredeyse imkânsız.
//   H2/H3 (harf çarpanı): daha sık ama K2/K3'ten uzak durur; en kötü
//   çakışma iki harf çarpanı arasında (katkısı çarpımsal değil, düşük risk).
// Merkez (6,6), dört tahta köşesi ve dört kenar orta noktası ([6,0], [6,12],
// [0,6], [12,6]) K3'tür. Kenar ortası ile merkez arası mesafe sadece 6 —
// tam 7 taşlık bir bingo ikisine birden basıp puanı 9 kat katlayabilir;
// bu, klasik Scrabble düzenine sadakat için bilinçli kabul edilmiş bir
// istisnadır (kuralın geri kalanı hâlâ en az 8 hücre şartını korur).
const TW: [number, number][] = [
  [6, 6], [0, 0], [0, 12], [12, 0], [12, 12],
  [6, 0], [6, 12], [0, 6], [12, 6],
];
const DW: [number, number][] = [
  [2, 1], [2, 11], [10, 1], [10, 11],
  [1, 2], [1, 10], [11, 2], [11, 10],
];
const TL: [number, number][] = [
  [4, 3], [4, 9], [8, 3], [8, 9],
  [3, 4], [3, 8], [9, 4], [9, 8],
  [5, 5], [7, 7],
];
const DL: [number, number][] = [
  [5, 10], [7, 2],
  [2, 7], [10, 5],
];

export function buildInitialBonuses(): Record<CellKey, BonusType> {
  const b: Record<CellKey, BonusType> = {};
  TW.forEach(([r, c]) => (b[`${r},${c}`] = 'tw'));
  TL.forEach(([r, c]) => (b[`${r},${c}`] = 'tl'));
  DL.forEach(([r, c]) => (b[`${r},${c}`] = 'dl'));
  DW.forEach(([r, c]) => (b[`${r},${c}`] = 'dw'));
  return b;
}
