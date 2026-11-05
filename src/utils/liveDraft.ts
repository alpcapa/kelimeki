// Kelimeki — Canlı oyunda DENEME TAŞLARI (taslak) kararı ve yerel kaydı.
//
// Amaç (kullanıcı, 5 Kasım 2026): sıra rakipteyken denemeler yapıp iyi bir
// hamle bulan oyuncu, ekrandan çıkıp girince ya da rakip oynayınca onu
// KAYBETMESİN. Kural tek cümle: taslak YALNIZCA (1) bir hücresine rakibin
// gerçek bir taşı oturduysa ya da (2) taşları sunucudaki rafımda
// bulunamıyorsa atılır; GEÇERSİZ olması ya da puanının/vergisinin değişmesi
// atma sebebi DEĞİL (mesaj satırı canlı türetildiği için durumu zaten
// söylüyor; sözlük tembel yüklendiğinden "geçerli mi" kararı da güvenilmez).
//
// Taslak YALNIZCA bu cihazda tutulur (sunucuya yazılmaz): gizlilik/hile
// (rakibe sızma) ve yazma maliyeti açısından DB bilinçli dışarıda.
//
// Bu dosya SAF karar fonksiyonları + localStorage sarmalayıcısı. Karar
// `gameReducer.ts`'in `SYNC_ONLINE_STATE`'inde kullanılır; port ikizi
// `mobile/app/lib/src/util/live_draft.dart` (BİREBİR aynı kural).
import type { CellKey, Tile } from '../game/types';

export type Draft = Record<CellKey, Tile>;

/** Taslağın raftan düşen harf imzası — `subtractPlacedFromRack` ile aynı anahtar. */
const tileKey = (t: Tile): string => `${t.wild ? '?' : t.letter}:${t.pts}`;

/** Taslaktaki hücrelerden şu an tahtada DOLU olanlar ("r,c" anahtarları). */
export function draftConflicts(placed: Draft, board: (Tile | null)[][]): CellKey[] {
  const out: CellKey[] = [];
  for (const k of Object.keys(placed)) {
    const [r, c] = k.split(',').map(Number);
    if (Number.isInteger(r) && Number.isInteger(c) && board[r]?.[c]) out.push(k);
  }
  return out;
}

/** Taslaktaki her taş için raftan (çoklu küme olarak) bir karşılık bulunuyor mu? */
export function rackCoversDraft(rack: Tile[], placed: Draft): boolean {
  const counts = new Map<string, number>();
  for (const t of rack) counts.set(tileKey(t), (counts.get(tileKey(t)) ?? 0) + 1);
  for (const t of Object.values(placed)) {
    const k = tileKey(t);
    const n = counts.get(k) ?? 0;
    if (n <= 0) return false;
    counts.set(k, n - 1);
  }
  return true;
}

/** Taslak (şu anki tahta + sunucudaki ham raf'a karşı) korunmalı mı? Boş taslak → true. */
export function shouldKeepDraft(placed: Draft, board: (Tile | null)[][], rack: Tile[]): boolean {
  if (Object.keys(placed).length === 0) return true;
  return draftConflicts(placed, board).length === 0 && rackCoversDraft(rack, placed);
}

/**
 * Taslak ATILDIYSA kullanıcıya "neden" söylenmeli mi? Yalnızca bir HÜCREYE
 * RAKİBİN taşı oturduysa (`owner !== mySlot`). Kendi hamlemin ardından
 * (taşlar artık tahtada, `owner === mySlot`) ya da raf uyuşmazlığında
 * (başka cihaz) sessiz kalınır: orada bilgi satırı yanıltıcı olurdu.
 */
export function discardedByOpponent(
  placed: Draft,
  board: (Tile | null)[][],
  mySlot: number,
): boolean {
  return draftConflicts(placed, board).some((k) => {
    const [r, c] = k.split(',').map(Number);
    const t = board[r]?.[c];
    return !!t && t.owner !== mySlot;
  });
}

// ─── Yerel kayıt ───────────────────────────────────────────────────────

const PREFIX = 'kelimeki:live-draft:';
const storageKey = (userId: string, gameId: string): string => `${PREFIX}${userId}:${gameId}`;

interface StoredDraft {
  v: 1;
  cells: { k: CellKey; letter: string; pts: number; wild?: boolean; wildLetter?: string; owner?: number }[];
}

/** Taslağı kaydeder; boşsa kaydı SİLER. localStorage kapalı/dolu olabilir — sessiz yok sayılır. */
export function saveLiveDraft(userId: string, gameId: string, placed: Draft): void {
  try {
    const keys = Object.keys(placed);
    if (keys.length === 0) {
      localStorage.removeItem(storageKey(userId, gameId));
      return;
    }
    const payload: StoredDraft = {
      v: 1,
      cells: keys.map((k) => {
        const t = placed[k];
        return { k, letter: t.letter, pts: t.pts, wild: t.wild, wildLetter: t.wildLetter, owner: t.owner };
      }),
    };
    localStorage.setItem(storageKey(userId, gameId), JSON.stringify(payload));
  } catch {
    /* sessiz */
  }
}

/** Kayıtlı taslağı okur; yok/bozuksa `null`. Şekil doğrulanır — bozuk kayıt ASLA uygulanmaz. */
export function loadLiveDraft(userId: string, gameId: string): Draft | null {
  try {
    const raw = localStorage.getItem(storageKey(userId, gameId));
    if (!raw) return null;
    const p = JSON.parse(raw) as Partial<StoredDraft>;
    if (p.v !== 1 || !Array.isArray(p.cells) || p.cells.length === 0) return null;
    const out: Draft = {};
    for (const c of p.cells) {
      if (
        typeof c?.k !== 'string' ||
        !/^\d+,\d+$/.test(c.k) ||
        typeof c.letter !== 'string' ||
        typeof c.pts !== 'number'
      ) {
        return null;
      }
      out[c.k] = {
        letter: c.letter,
        pts: c.pts,
        ...(c.wild ? { wild: true } : {}),
        ...(typeof c.wildLetter === 'string' ? { wildLetter: c.wildLetter } : {}),
        ...(typeof c.owner === 'number' ? { owner: c.owner } : {}),
      };
    }
    return out;
  } catch {
    return null;
  }
}

/** Kaydı siler (oyun bitti / hamle gönderildi). */
export function clearLiveDraft(userId: string, gameId: string): void {
  try {
    localStorage.removeItem(storageKey(userId, gameId));
  } catch {
    /* sessiz */
  }
}
