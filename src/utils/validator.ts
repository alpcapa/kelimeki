// Harfik — kelime doğrulama, bölge kuralları ve puanlama
import { BINGO_BONUS, SIZE, cornerBounds, inCorner, isZoneBoundaryCell, regionOf } from '../game/constants';
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
 * Hangi köşelerin "ihlal edildiğini" hesaplar.
 * Kural: Köşe sahibi bölgesinin iç sınır karesine taş koyduğunda bölge ihlal
 * edilmiş sayılır; yalnızca o andan itibaren rakipler bu köşeye girebilir.
 * Hiçbir oyuncuya ait olmayan köşeler baştan ihlal edilmiş (açık) kabul edilir.
 */
export function computeBreachedCorners(board: Board, players: Player[]): boolean[] {
  const breached = [false, false, false, false];
  const owned = new Set(players.map((p) => p.corner));
  for (let i = 0; i < 4; i++) if (!owned.has(i)) breached[i] = true;

  for (let r = 0; r < SIZE; r++) {
    for (let c = 0; c < SIZE; c++) {
      if (!board[r][c]) continue;
      for (let corner = 0; corner < 4; corner++) {
        if (!breached[corner] && isZoneBoundaryCell(corner, r, c)) {
          breached[corner] = true;
        }
      }
    }
  }
  return breached;
}

/** @deprecated Yeni kod computeBreachedCorners kullanmalı. */
export const computeOpenCorners = computeBreachedCorners;

/**
 * Verilen başlangıç hücrelerinden (bu köşe bölgesi içinde kalarak) taşlar
 * üzerinden yayılıp bölgenin iç sınır karesine ulaşılıp ulaşılamadığını
 * kontrol eder. Sadece yeni konan taşın bitişiği değil, o taşa bağlı tüm
 * harf zincirini (yeni + tahtadaki mevcut taşlar) dikkate alır — örn. yeni
 * bir taş, sınıra zaten ulaşmış eski bir kelimeye bağlanıyorsa da geçerlidir.
 */
export function zoneReachesBoundary(
  board: Board,
  placed: Placed,
  zone: number,
  starts: [number, number][],
): boolean {
  const b = cornerBounds(zone);
  const visited = new Set<string>();
  const stack: [number, number][] = [...starts];
  while (stack.length > 0) {
    const [r, c] = stack.pop()!;
    const k = key(r, c);
    if (visited.has(k)) continue;
    visited.add(k);
    if (isZoneBoundaryCell(zone, r, c)) return true;
    const neighbors: [number, number][] = [
      [r - 1, c],
      [r + 1, c],
      [r, c - 1],
      [r, c + 1],
    ];
    for (const [nr, nc] of neighbors) {
      if (nr < b.r0 || nr > b.r1 || nc < b.c0 || nc > b.c1) continue;
      const nk = key(nr, nc);
      if (visited.has(nk)) continue;
      if (placed[nk] || board[nr][nc]) stack.push([nr, nc]);
    }
  }
  return false;
}

/**
 * Sırası gelen oyuncu (r,c) hücresine taş koyabilir mi?
 *  - Merkez hücreler herkese açık.
 *  - Kendi köşen her zaman açık.
 *  - Rakip köşe yalnızca ihlal edilmişse (breached) erişilebilir.
 */
export function cellAllowed(
  ownCorner: number,
  breachedCorners: boolean[],
  r: number,
  c: number,
): boolean {
  const region = regionOf(r, c);
  if (region === -1) return true;
  if (region === ownCorner) return true;
  return breachedCorners[region];
}

/**
 * Yapısal doğrulama — hizalama, bölge kuralları, bağlantı, kelime varlığı;
 * sözlük kontrolü yapılmaz. Geçerliyse oluşan kelimeleri döner.
 * Sunucu doğrulaması yaparken önce bu çağrılır, ardından kelimeler RPC'ye gönderilir.
 */
export function validatePlacementStructural(
  board: Board,
  placed: Placed,
  ownCorner: number,
  openCorners: boolean[],
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

  // Bölge kuralı: her yeni taş izinli bir hücreye konmalı.
  for (const [r, c] of coords) {
    if (!cellAllowed(ownCorner, openCorners, r, c)) {
      return {
        valid: false,
        reason: 'Bu köşe henüz ihlal edilmedi — sahip sınır karesine oynamadan girilemiyor.',
      };
    }
  }

  // Rakip köşeye giriş kuralı: yeni taşın bulunduğu rakip bölgede, o taşa
  // bağlı harf zinciri (yeni + tahtadaki mevcut taşlar, her yönde) bölgenin
  // iç sınır karesine ulaşmalıdır. Zincir zaten sınıra ulaşmışsa (örn. daha
  // önce ihlal edilmiş bir kelimeye bağlanılıyorsa) tekrar sınıra değmek
  // gerekmez — tüm bağlı harfler dikkate alınır, yalnızca yeni taşın
  // bitişiği değil.
  const foreignZoneCoords = coords.filter(([r, c]) => {
    const region = regionOf(r, c);
    return region !== -1 && region !== ownCorner;
  });
  if (foreignZoneCoords.length > 0) {
    const foreignZones = new Set(foreignZoneCoords.map(([r, c]) => regionOf(r, c) as number));
    for (const zone of foreignZones) {
      const starts = foreignZoneCoords.filter(([r, c]) => regionOf(r, c) === zone);
      if (!zoneReachesBoundary(board, placed, zone, starts)) {
        return {
          valid: false,
          reason: 'Rakip köşesine girerken sınır karesindeki bir taşa değmelisin.',
        };
      }
    }
  }

  if (isFirstMove) {
    const startsHome = coords.some(([r, c]) => inCorner(ownCorner, r, c));
    if (!startsHome) {
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
    if (!connects) {
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
  ownCorner: number,
  openCorners: boolean[],
  isFirstMove: boolean,
): ValidationResult {
  const structural = validatePlacementStructural(board, placed, ownCorner, openCorners, isFirstMove);
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
 * Verilen hücrelerin girdiği, oynayana ait olmayan köşelerin sahiplerini
 * (oyuncu indeksi) tekrarsız ve sırayla döndürür. Bir kelime iki farklı
 * rakip köşesine birden girebilir (örn. üst sıradaki uzun bir kelime hem
 * sol-üst hem sağ-üst köşeye değebilir).
 */
export function computeInvadedOwners(
  coords: [number, number][],
  ownCorner: number,
  players: Player[],
): number[] {
  const idxs: number[] = [];
  const seen = new Set<number>();
  for (const [r, c] of coords) {
    const region = regionOf(r, c);
    if (region === -1 || region === ownCorner) continue;
    const idx = players.findIndex((p) => p.corner === region);
    if (idx >= 0 && !seen.has(idx)) {
      seen.add(idx);
      idxs.push(idx);
    }
  }
  return idxs;
}

/**
 * Rakip köşe(ler)ine giren bir hamlenin puanını paylaştırır: puan, saldırgan
 * ve girilen her köşe sahibi arasında eşit bölünür (1 köşe → yarı yarıya,
 * 2 köşe → üçe bölünür). Sahip sayısı 0 ise tüm puan saldırgana kalır.
 */
export function splitInvasionScore(
  basePts: number,
  ownerCount: number,
): { attackerPts: number; ownerShare: number } {
  if (ownerCount === 0) return { attackerPts: basePts, ownerShare: 0 };
  const parties = ownerCount + 1;
  const ownerShare = Math.round(basePts / parties);
  return { attackerPts: basePts - ownerShare * ownerCount, ownerShare };
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
    total += sum * wordMult;
  }
  if (Object.keys(placed).length >= 7) total += BINGO_BONUS;
  return total;
}
