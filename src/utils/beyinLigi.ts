// Beyin Ligi (2 Ekim 2026) — k-lig'in OHP'ye göre sıralanan alt ligi.
//
// ⚠ Eşik ÜÇ yerde: burası, sunucu (`beyin_ligi_siralama` view'ı,
// `ohp_games >= 5`, migration 20261002173357) ve port
// (`mobile/app/lib/src/util/beyin_ligi.dart`). `npm run verify-beyin-ligi`
// üçünü kilitler — biri değişirse ekrandaki "N oyun daha" metni sunucunun
// listesiyle ayrışır.

/** Beyin Ligi'ne girmek için gereken, hamle verisi olan en az oyun sayısı. */
export const BEYIN_LIGI_MIN_GAMES = 5;

/** Eşiğe kaç oyun kaldı (eşikteyse/üstündeyse 0). */
export function gamesUntilBeyinLigi(ohpGames: number): number {
  return Math.max(0, BEYIN_LIGI_MIN_GAMES - Math.max(0, Math.floor(ohpGames)));
}

export type KLigTab = 'puan' | 'beyin';
