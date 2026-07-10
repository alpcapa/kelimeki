// Harfik — kelime doğrulama, bölge kuralları ve puanlama
import { BINGO_BONUS, SIZE, cornerBounds, cornerCell, inBonusZone } from '../game/constants';
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
 * ("taze") olanları döner. Her oyuncunun tek bir köşesi olduğundan, bu
 * yalnızca ilk hamleden önce (o köşe hâlâ boşken) doludur; bir kez
 * oynandıktan sonra oyuncunun tüm sonraki kelimeleri mevcut taşlara
 * bağlanmak zorundadır.
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

  const fresh = freshCorners(board, ownCorners, owner);
  const startsFreshCorner = coords.some(([r, c]) =>
    fresh.some((corner) => {
      const [cr, cc] = cornerCell(corner);
      return r === cr && c === cc;
    }),
  );

  if (isFirstMove) {
    if (!startsFreshCorner) {
      return { valid: false, reason: 'İlk kelimen kendi köşe karesine değmeli.' };
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
 * Bir oyuncunun bölgesini hesaplar: kendi köşe kare(ler)i + oradan yalnızca
 * kendi taşları üzerinden ortogonal olarak bağlı tüm hücreler. Genişleme
 * sadece oyuncunun kendi bölgesinden mümkündür — bir hücre, oyuncunun
 * köşesine kendi taşlarıyla kesintisiz bağlıysa bölgeye katılır; boş
 * hücreler ya da başka bir oyuncunun taşları zinciri kesmez ama genişletmez.
 */
export function computeTerritory(board: Board, ownCorners: number[], owner: number): Set<string> {
  const territory = new Set<string>();
  const stack: [number, number][] = [];
  for (const corner of ownCorners) {
    const b = cornerBounds(corner);
    for (let r = b.r0; r <= b.r1; r++) {
      for (let c = b.c0; c <= b.c1; c++) {
        const k = key(r, c);
        if (!territory.has(k)) {
          territory.add(k);
          stack.push([r, c]);
        }
      }
    }
  }
  while (stack.length > 0) {
    const [r, c] = stack.pop()!;
    const neighbors: [number, number][] = [
      [r - 1, c],
      [r + 1, c],
      [r, c - 1],
      [r, c + 1],
    ];
    for (const [nr, nc] of neighbors) {
      if (nr < 0 || nr >= SIZE || nc < 0 || nc >= SIZE) continue;
      const k = key(nr, nc);
      if (territory.has(k)) continue;
      if (board[nr][nc]?.owner === owner) {
        territory.add(k);
        stack.push([nr, nc]);
      }
    }
  }
  return territory;
}

/** Tüm oyuncuların bölgelerini (indekslerine göre) hesaplar. */
export function computeAllTerritories(board: Board, players: Player[]): Set<string>[] {
  return players.map((p, i) => computeTerritory(board, p.corners, i));
}

/**
 * Rakip bölge(ler)ine sınır vergisini hesaplar. Bu tur konan taşlardan biri
 * bir rakip bölgesinin içine düşüyorsa (girme) ya da dışarıdan sınırına
 * bitişikse (değme), kazanılan puan ikiye bölünür (yarısı bölge sahibine).
 * Bölge artık sabit 5x5 köşe değil, `computeTerritory` ile hesaplanan —
 * oyuncunun kendi taşlarıyla köşesinden genişlettiği— dinamik alandır.
 * Rakip bölgesine girmek için hiçbir ön koşul yok — her zaman serbest.
 * Aynı anda iki farklı rakip bölgesine giriliyor/değiliyorsa puan üç kişi
 * arasında (saldırgan + iki bölge sahibi) eşit paylaşılır. Yuvarlama farkı
 * saldırganda kalır, böylece toplam puan her zaman korunur.
 */
export function computeInvasionSplit(
  coords: [number, number][],
  ownerIndex: number,
  players: Player[],
  basePts: number,
  board: Board,
): { pts: number; shares: { index: number; amount: number }[] } {
  const territories = computeAllTerritories(board, players);
  const touchedIdx = new Set<number>();
  const addIfForeign = (r: number, c: number) => {
    const k = key(r, c);
    for (let i = 0; i < territories.length; i++) {
      if (i !== ownerIndex && territories[i].has(k)) touchedIdx.add(i);
    }
  };
  for (const [r, c] of coords) {
    addIfForeign(r, c);
    const neighbors: [number, number][] = [
      [r - 1, c],
      [r + 1, c],
      [r, c - 1],
      [r, c + 1],
    ];
    for (const [nr, nc] of neighbors) {
      if (nr < 0 || nr >= SIZE || nc < 0 || nc >= SIZE) continue;
      addIfForeign(nr, nc);
    }
  }
  if (touchedIdx.size === 0) return { pts: basePts, shares: [] };
  const share = Math.round(basePts / (touchedIdx.size + 1));
  const shares = [...touchedIdx].map((index) => ({ index, amount: share }));
  const pts = basePts - share * touchedIdx.size;
  return { pts, shares };
}

/**
 * Tek bir kelimenin puanını hesaplar. Tahtanın tam ortasındaki tek X3
 * hücresine bu turda yeni bir taş konursa kelime puanı üçe katlanır (klasik
 * bonus kare gibi — yalnızca yeni taşta). Ayrıca kelimenin herhangi bir
 * hücresi (yeni ya da önceden tahtada duran) merkezdeki 5×5 bonus bölgesine
 * düşüyorsa puan ayrıca ikiye katlanır — bu, alanı yalnızca ilk kullanana
 * değil, oraya her uğrayan kelimeye uygulanır.
 */
function wordPoints(
  coords: [number, number][],
  board: Board,
  placed: Placed,
  bonuses: Record<string, BonusType>,
): number {
  let sum = 0;
  let wordMult = 1;
  let touchesZone = false;
  for (const [r, c] of coords) {
    const k = key(r, c);
    const newTile = placed[k];
    const pts = newTile?.pts ?? board[r][c]?.pts ?? 0;
    if (newTile && bonuses[k] === 'tw') wordMult *= 3;
    sum += pts;
    if (inBonusZone(r, c)) touchesZone = true;
  }
  if (touchesZone) wordMult *= 2;
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
