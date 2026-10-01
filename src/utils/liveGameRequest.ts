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
