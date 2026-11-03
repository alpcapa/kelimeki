// Kelimeki — "Hamle Avı" saf mantığı (3 Kasım 2026, ROADMAP #48).
//
// Bulmaca = önceden ÜRETİLMİŞ banka pozisyonu (`src/data/hamleAviBank.json`,
// üretici: `scripts/generate-hamle-avi-bank.ts`). İstemci çözücü ÇALIŞTIRMAZ;
// yalnızca oyuncunun hamlesini GERÇEK reducer'dan geçirip skor farkına bakar.
// Bölge vergisi dahil — `PLAY` zaten net puanı skora yazar.
//
// ⚠ Motora DOKUNMAZ: yeni action/alan YOK. Pozisyon, `RESUME_SAVED` ile kendi
// `useReducer`'ına yüklenen sıradan bir `GameState`'tir (tanıtımla aynı yalıtım:
// kayıt, bulut kaydı, k-lig, istatistik ve terk cezası ÇALIŞMAZ).
import type { GameState, Tile } from '../game/types';
import { createInitialState, gameReducer } from '../game/gameReducer';
import { letterPoints } from '../data/tiles';

/** Bir bulmaca için süre (sn). Kullanıcı kararı 3 Kasım 2026: 3 dk (başlangıçta 5 dk'ydı). */
export const HAMLE_AVI_SECONDS = 3 * 60;
/** Son bu kadar saniyede geri sayım kırmızıya döner. */
export const HAMLE_AVI_WARN_SECONDS = 30;

/** Bankadaki tek pozisyon (sıkıştırılmış). */
export interface HamleAviPosition {
  /** Üretim tohumu — kararlı, bulmaca kimliği ("görülenler" listesi bunu tutar). */
  id: number;
  /** Sıra sahibinin indeksi (0 ya da 1; 2 kişilik oyun). */
  o: number;
  /** Tahtadaki taşlar: [satır, sütun, harf, sahip, joker?(1)]. Jokerde harf = seçilen harf. */
  t: [number, number, string, number, number?][];
  /** Raf, 7 harf; '?' = joker. */
  r: string;
  /** Anahtar: en iyi hamlenin VERGİ DAHİL net puanı. */
  k: number;
  /** En iyi hamlenin ana kelimesi ("Üzgünüz" penceresinde gösterilir). */
  w: string;
}

export function tileFromLetter(letter: string): Tile {
  return letter === '?' ? { letter: '?', pts: 0 } : { letter, pts: letterPoints(letter) };
}

/** Pozisyonu oynanabilir `GameState`e çevirir (iki insan koltuğu, sıra `o`da). */
export function positionToState(pos: HamleAviPosition, myName: string): GameState {
  const base = gameReducer(createInitialState(), {
    type: 'START',
    players: [
      { name: pos.o === 0 ? myName : 'Rakip', isAI: false },
      { name: pos.o === 1 ? myName : 'Rakip', isAI: false },
    ],
  });
  const board = base.board.map((row) => row.slice());
  for (const [r, c, letter, owner, wild] of pos.t) {
    board[r][c] = wild
      ? { letter: '?', pts: 0, wild: true, wildLetter: letter, owner }
      : { ...tileFromLetter(letter), owner };
  }
  const players = base.players.map((p, i) =>
    i === pos.o
      ? { ...p, rack: [...pos.r].map(tileFromLetter) }
      // Rakibin rafı/torba DOLGU: boş olsaydı bingo'lu bir hamle oyunu BİTİRİR ve
      // `endGame` raf düşümüyle net puanı bozardı (skor farkı anahtardan sapar).
      : { ...p, rack: Array.from({ length: 7 }, () => tileFromLetter('E')) },
  );
  return {
    ...base,
    board,
    players,
    current: pos.o,
    turnCount: 10, // ilk hamle değil (`isFirstMove` tahtadan bakar; sayaç yalnızca gösterim)
    bag: Array.from({ length: 20 }, () => tileFromLetter('E')),
    message: '',
    messageType: '',
  };
}

/** Oyuncunun bu bulmacadaki NET kazancı (PLAY sonrası skor farkı, vergi dahil). */
export function netGain(before: GameState, after: GameState): number {
  return after.players[before.current].score - before.players[before.current].score;
}

/**
 * Doğru mu? Net puan anahtara ULAŞIYORSA (eşit ya da YÜKSEK — çözücü ≤8 harfle
 * sınırlı, oyuncu daha iyisini bulabilir) doğru sayılır.
 */
export function isCorrect(net: number, pos: HamleAviPosition): boolean {
  return net >= pos.k;
}

// ── Görülenler ──────────────────────────────────────────────────────────────

/** Görülmemiş pozisyonlardan rastgele biri; hepsi görüldüyse null (banka bitti). */
export function pickNext(
  bank: readonly HamleAviPosition[],
  seen: ReadonlySet<number>,
  rand: () => number = Math.random,
): HamleAviPosition | null {
  const rest = bank.filter((p) => !seen.has(p.id));
  if (rest.length === 0) return null;
  return rest[Math.floor(rand() * rest.length)];
}

/** İki görülenler listesinin birleşimi (cihaz ↔ sunucu eşitlemesi). */
export function mergeSeen(a: readonly number[], b: readonly number[]): number[] {
  return [...new Set([...a, ...b])].sort((x, y) => x - y);
}

// ── Seri / rekor ────────────────────────────────────────────────────────────

export interface StreakState {
  /** Şu anki seri — her girişte 0'dan başlar, kalıcı DEĞİL. */
  streak: number;
  /** Kalıcı rekor (hesapta DB, misafirde cihaz). */
  best: number;
}

/** Bulundu: seri +1, rekor gerekirse yükselir. */
export function onFound(s: StreakState): StreakState {
  const streak = s.streak + 1;
  return { streak, best: Math.max(s.best, streak) };
}

/** Bulunamadı / vazgeçildi: seri sıfırlanır, rekor korunur. */
export function onMissed(s: StreakState): StreakState {
  return { streak: 0, best: s.best };
}

/** Çıkış/vazgeçme uyarısı gösterilmeli mi? Sıfırlanacak bir seri varsa. */
export function shouldWarnOnLeave(s: StreakState): boolean {
  return s.streak > 0;
}

/** Sunucuya gönderilebilecek en yüksek makul rekor (RPC ile AYNI sayı olmalı). */
export const MAX_PLAUSIBLE_STREAK = 5000;
