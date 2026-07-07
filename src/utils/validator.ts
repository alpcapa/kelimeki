// Harfik — kelime doğrulama, bölge kuralları ve puanlama
import { BINGO_BONUS, SIZE, cornerBounds, inCorner, regionOf } from '../game/constants';
import type { BonusType, Player, ValidationResult } from '../game/types';
import { WORD_SET } from '../data/words';
import { trLower } from './turkish';
import {
  getFormedWords,
  key,
  type Board,
  type Placed,
} from './board';

/** Verilen harf havuzuyla kelime hecelenebilir mi? Joker ('?') jokeri sayar. */
export function canSpell(word: string, rack: string[]): boolean {
  const avail = [...rack];
  for (const ch of word) {
    const i = avail.indexOf(ch);
    if (i >= 0) {
      avail.splice(i, 1);
    } else {
      const wi = avail.indexOf('?');
      if (wi >= 0) avail.splice(wi, 1);
      else return false;
    }
  }
  return true;
}

/**
 * Oyuncunun sahip olduğu köşelerden, henüz hiç kendi taşının bulunmadığı
 * ("taze") olanları döner. 2 oyunculu oyunda her oyuncunun iki köşesi
 * olduğundan, bir köşeden kelimeye başladıktan sonra diğer (taze) köşesinden
 * de bağımsız bir kelimeyle başlayabilmesi için kullanılır.
 */
export function freshCorners(board: Board, ownCorners: number[], owner: number): number[] {
  return ownCorners.filter((corner) => {
    const b = cornerBounds(corner);
    for (let r = b.r0; r <= b.r1; r++) {
      for (let c = b.c0; c <= b.c1; c++) {
        if (board[r][c]?.owner === owner) return false;
      }
    }
    return true;
  });
}

/**
 * Sırası gelen oyuncu (r,c) hücresine taş koyabilir mi?
 *  - Tarafsız (merkez) hücreler herkese açık.
 *  - Kendi köşen her zaman açık.
 *  - Bir rakibin köşesine hiçbir zaman taş konamaz — köşeler her zaman
 *    yalnızca sahibine aittir. Rakip bölgelerle etkileşim yalnızca dışarıdan
 *    sınıra değerek olur (bkz. computeInvasionSplit).
 */
export function cellAllowed(
  ownCorners: number[],
  r: number,
  c: number,
): boolean {
  const region = regionOf(r, c);
  if (region === -1) return true;
  return ownCorners.includes(region);
}

/**
 * Yapısal doğrulama — hizalama, bölge kuralları, bağlantı, kelime varlığı;
 * sözlük kontrolü yapılmaz. Geçerliyse oluşan kelimeleri döner.
 * Sunucu doğrulaması yaparken önce bu çağrılır, ardından kelimeler RPC'ye gönderilir.
 */
export function validatePlacementStructural(
  board: Board,
  placed: Placed,
  owner: number,
  ownCorners: number[],
  isFirstMove: boolean,
): ValidationResult {
  const keys = Object.keys(placed);
  if (keys.length === 0) {
    return { valid: false, reason: 'Harf yerleştirilmedi.' };
  }

  const coords = keys.map((k) => k.split(',').map(Number) as [number, number]);
  const rows = [...new Set(coords.map((p) => p[0]))];
  const cols = [...new Set(coords.map((p) => p[1]))];
  const horiz = rows.length === 1;
  const vert = cols.length === 1;
  if (!horiz && !vert) {
    return { valid: false, reason: 'Harfler aynı satır ya da sütunda olmalı.' };
  }

  // Süreklilik kuralı: yerleştirilen taşlar arasında, tahtada zaten bir taş
  // bulunmayan boş hücre olamaz — aradaki her hücre ya bu turda konmuş ya da
  // önceden tahtada olmalı.
  if (horiz) {
    const r = rows[0];
    const minC = Math.min(...cols);
    const maxC = Math.max(...cols);
    for (let c = minC; c <= maxC; c++) {
      if (!placed[key(r, c)] && !board[r][c]) {
        return { valid: false, reason: 'Harfler arasında boşluk bırakılamaz.' };
      }
    }
  } else {
    const c = cols[0];
    const minR = Math.min(...rows);
    const maxR = Math.max(...rows);
    for (let r = minR; r <= maxR; r++) {
      if (!placed[key(r, c)] && !board[r][c]) {
        return { valid: false, reason: 'Harfler arasında boşluk bırakılamaz.' };
      }
    }
  }

  // Bölge kuralı: her yeni taş kendi köşende ya da tarafsız alanda olmalı —
  // bir rakibin köşesine hiç taş konamaz.
  for (const [r, c] of coords) {
    if (!cellAllowed(ownCorners, r, c)) {
      return {
        valid: false,
        reason: 'Burası bir rakibin köşesi — oraya oynayamazsın.',
      };
    }
  }

  const fresh = freshCorners(board, ownCorners, owner);
  const startsFreshCorner = coords.some(([r, c]) =>
    fresh.some((corner) => inCorner(corner, r, c)),
  );

  if (isFirstMove) {
    if (!startsFreshCorner) {
      return { valid: false, reason: 'İlk kelimen kendi köşenden başlamalı.' };
    }
  } else {
    const connects = coords.some(([r, c]) =>
      [
        [r - 1, c],
        [r + 1, c],
        [r, c - 1],
        [r, c + 1],
      ].some(
        ([nr, nc]) =>
          nr >= 0 && nr < SIZE && nc >= 0 && nc < SIZE && board[nr][nc],
      ),
    );
    // Bağlanmıyorsa, oyuncunun henüz kullanmadığı bir köşesinden bağımsız
    // yeni bir kelimeyle başlaması da (ilk hamledeki gibi) geçerlidir.
    if (!connects && !startsFreshCorner) {
      return { valid: false, reason: 'Kelime mevcut harflere bağlanmalı.' };
    }
  }

  const formed = getFormedWords(board, placed);
  if (formed.length === 0) {
    return { valid: false, reason: 'Geçerli kelime oluşmadı.' };
  }

  return { valid: true, words: formed.map((f) => f.word) };
}

/**
 * Oyuncunun bu turdaki yerleştirmesini doğrular: hizalama, bölge kuralları,
 * bağlantı ve yerel sözlük. Geçerliyse oluşan kelimeleri döndürür.
 */
export function validatePlacement(
  board: Board,
  placed: Placed,
  owner: number,
  ownCorners: number[],
  isFirstMove: boolean,
): ValidationResult {
  const structural = validatePlacementStructural(board, placed, owner, ownCorners, isFirstMove);
  if (!structural.valid) return structural;

  const formed = getFormedWords(board, placed);
  for (const { word } of formed) {
    if (!WORD_SET.has(trLower(word))) {
      return { valid: false, reason: `"${word}" geçerli bir kelime değil.` };
    }
  }
  return structural;
}

/**
 * Rakip köşe(ler)ine sınır vergisini hesaplar. Bu tur konan taşlardan biri
 * (taşın kendisi bölgenin dışında kalsa bile) bir rakip köşesinin sınırına
 * bitişikse, kazanılan puan ikiye bölünür (yarısı köşe sahibine). Aynı anda
 * iki farklı rakip köşesine değiliyorsa puan üç kişi arasında (saldırgan +
 * iki köşe sahibi) eşit paylaşılır. Yuvarlama farkı saldırganda kalır, böylece
 * toplam puan her zaman korunur.
 */
export function computeInvasionSplit(
  coords: [number, number][],
  ownCorners: number[],
  players: Player[],
  basePts: number,
): { pts: number; shares: { index: number; amount: number }[] } {
  const touchedIdx = new Set<number>();
  for (const [r, c] of coords) {
    const neighbors: [number, number][] = [
      [r - 1, c],
      [r + 1, c],
      [r, c - 1],
      [r, c + 1],
    ];
    for (const [nr, nc] of neighbors) {
      if (nr < 0 || nr >= SIZE || nc < 0 || nc >= SIZE) continue;
      const region = regionOf(nr, nc);
      if (region === -1 || ownCorners.includes(region)) continue;
      const idx = players.findIndex((p) => p.corners.includes(region));
      if (idx >= 0) touchedIdx.add(idx);
    }
  }
  if (touchedIdx.size === 0) return { pts: basePts, shares: [] };
  const share = Math.round(basePts / (touchedIdx.size + 1));
  const shares = [...touchedIdx].map((index) => ({ index, amount: share }));
  const pts = basePts - share * touchedIdx.size;
  return { pts, shares };
}

/** Tek bir kelimenin (harf/kelime çarpanları dahil) puanını hesaplar. */
function wordPoints(
  coords: [number, number][],
  board: Board,
  placed: Placed,
  bonuses: Record<string, BonusType>,
): number {
  let sum = 0;
  let wordMult = 1;
  for (const [r, c] of coords) {
    const k = key(r, c);
    const newTile = placed[k];
    const pts = newTile?.pts ?? board[r][c]?.pts ?? 0;
    const b = newTile ? bonuses[k] : undefined; // bonus yalnızca yeni taşta
    if (b === 'dl') sum += pts * 2;
    else if (b === 'tl') sum += pts * 3;
    else if (b === 'dw') {
      wordMult *= 2;
      sum += pts;
    } else if (b === 'tw') {
      wordMult *= 3;
      sum += pts;
    } else {
      sum += pts;
    }
  }
  return sum * wordMult;
}

/**
 * Bu turda oluşan tüm kelimelerin toplam puanını hesaplar. Bonuslar yalnızca
 * bu turda yeni konan taşlara uygulanır. Tüm raf kullanılırsa bingo bonusu.
 */
export function calcScore(
  board: Board,
  placed: Placed,
  bonuses: Record<string, BonusType>,
): number {
  let total = 0;
  for (const { coords } of getFormedWords(board, placed)) {
    total += wordPoints(coords, board, placed, bonuses);
  }
  if (Object.keys(placed).length >= 7) total += BINGO_BONUS;
  return total;
}

/**
 * Bu turda oluşan her kelimenin kendi puanını ayrı ayrı döner (bingo bonusu
 * hariç — o tek bir kelimeye değil hamlenin tamamına ait). "En yüksek kelime
 * puanı" istatistiği için, hamlenin toplam puanından bağımsız olarak.
 */
export function calcWordScores(
  board: Board,
  placed: Placed,
  bonuses: Record<string, BonusType>,
): { word: string; score: number }[] {
  return getFormedWords(board, placed).map(({ word, coords }) => ({
    word,
    score: wordPoints(coords, board, placed, bonuses),
  }));
}
