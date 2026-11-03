// Kelimeki — Hamle Avı cihaz deposu (3 Kasım 2026, ROADMAP #48).
//
// Cihazda tutulanlar: rekor + görülen bulmaca kimlikleri (misafirin TEK kaynağı,
// üyenin çevrimdışı tamponu), "YENİ" balonunun kalkma bayrağı ve tanıtım
// penceresinin "bir daha gösterme" tercihi (YALNIZCA cihazda — sunucuya gitmez).
// Her okuma/yazma try/catch içinde: özel pencerede/engelli depoda ekran yine çalışır.
import { mergeSeen } from './hamleAvi';

const KEY = 'kelimeki:hamle-avi:v1';

export interface HamleAviLocal {
  best: number;
  seen: number[];
  /** Hamle Avı en az bir kez açıldı → "YENİ" balonu kalkar. */
  opened: boolean;
  /** Tanıtım penceresinde "Bir daha gösterme" işaretlendi. */
  introHidden: boolean;
}

const EMPTY: HamleAviLocal = { best: 0, seen: [], opened: false, introHidden: false };

export function loadHamleAvi(): HamleAviLocal {
  try {
    const raw = globalThis.localStorage?.getItem(KEY);
    if (!raw) return { ...EMPTY };
    const j = JSON.parse(raw) as Partial<HamleAviLocal>;
    return {
      best: Number.isFinite(j.best) ? Math.max(0, Number(j.best)) : 0,
      seen: Array.isArray(j.seen) ? j.seen.filter((n) => Number.isInteger(n)) : [],
      opened: !!j.opened,
      introHidden: !!j.introHidden,
    };
  } catch {
    return { ...EMPTY };
  }
}

export function saveHamleAvi(patch: Partial<HamleAviLocal>): HamleAviLocal {
  const next = { ...loadHamleAvi(), ...patch };
  try {
    globalThis.localStorage?.setItem(KEY, JSON.stringify(next));
  } catch {
    // Depo yazılamıyor: ekran bellekteki değerle sürer.
  }
  return next;
}

/** Sunucu değerleriyle cihazı birleştirir (rekor: büyüğü, görülenler: birleşim). */
export function mergeWithServer(server: { best: number; seen: number[] }): HamleAviLocal {
  const l = loadHamleAvi();
  return saveHamleAvi({
    best: Math.max(l.best, server.best),
    seen: mergeSeen(l.seen, server.seen),
  });
}

/** Setup'taki "YENİ" balonu gösterilsin mi? */
export function shouldShowNewBadge(): boolean {
  return !loadHamleAvi().opened;
}
