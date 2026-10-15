// Kelimeki — "bu arkadaşla oyun kur" isteği (27 Eylül 2026, ROADMAP #41:
// Arkadaşlar penceresinin OYNA düğmesi). Pencere uygulamanın üç yerinden
// açılabiliyor (Setup'taki hesap menüsü, oyun ekranının başlığı, canlı oyun
// formu); istek burada bekler, dinleyenler (App → kurulum ekranına dön +
// Arkadaşınla; LiveGamesTab → formu o arkadaş seçili aç) OKUYUP TÜKETİR.
// Kuyruk + olay birlikte: LiveGamesTab o an takılı değilse (oyun ekranı)
// takıldığında `take` ile kuyruktan alır; takılıysa olayı dinler.
export interface LiveGameRequest {
  friendId: string;
  playerCount: 2 | 4;
}

export const LIVE_GAME_REQUEST_EVENT = 'kelimeki:canli-oyun-kur';

let bekleyen: LiveGameRequest | null = null;

export function requestLiveGameWith(req: LiveGameRequest): void {
  bekleyen = req;
  window.dispatchEvent(new CustomEvent(LIVE_GAME_REQUEST_EVENT));
}

/** Bekleyen isteği döner ve kuyruğu boşaltır. */
export function takeLiveGameRequest(): LiveGameRequest | null {
  const r = bekleyen;
  bekleyen = null;
  return r;
}

// --- "Rastgele oyun aç" bağlantısı (13 Ekim 2026) ------------------------
// `kelimeki.com/?rastgele=1` (hatırlatma e-postasındaki düğme): Canlı sekmesi
// açılır, oyun kurma formu Rastgele Oyuncu SEÇİLİ gelir — şeritteki "Rastgele
// oyun aç"ın AYNI eylemi. İstek burada bekler; `LiveGamesTab` OTURUM VARSA
// okuyup tüketir (girişsiz gelen biri giriş yapınca formu görür, istek
// düşmez). Arkadaş isteğinden (yukarısı) ayrı kuyruk: o bir arkadaş ister.
export const RANDOM_OPEN_EVENT = 'kelimeki:rastgele-ac';

let rastgeleBekliyor = false;

export function requestRandomGameOpen(): void {
  rastgeleBekliyor = true;
  window.dispatchEvent(new CustomEvent(RANDOM_OPEN_EVENT));
}

/** Bekleyen "rastgele aç" isteği varsa true döner ve kuyruğu boşaltır. */
export function takeRandomGameOpen(): boolean {
  const r = rastgeleBekliyor;
  rastgeleBekliyor = false;
  return r;
}

/** Yalnızca bakar, tüketmez (girişsizken isteği korumak için). */
export function hasRandomGameOpen(): boolean {
  return rastgeleBekliyor;
}
