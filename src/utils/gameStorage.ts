// Harfik — devam eden oyunu (phase==='play') localStorage'a otomatik kaydeder.
// Tarayıcı/uygulama kapatılıp yeniden açıldığında kaldığı yerden devam
// edilebilsin diye: aksi halde biri kaybetmek üzereyken sekmeyi kapatıp
// "teslim ol"un -2 cezasından kaçabilirdi (bkz. proje notları).
import type { GameState } from '../game/types';

const STORAGE_KEY = 'harfik:game-state';
// Kaydedilen state'in şekli değişirse (yeni zorunlu alan vb.) eski
// kayıtları sessizce geçersiz saymak için.
const STORAGE_VERSION = 1;

interface StoredPayload {
  version: number;
  state: GameState;
}

/** Devam eden oyunu kaydeder. localStorage kapalı/dolu olabilir — sessizce yok sayılır. */
export function saveGameState(state: GameState): void {
  try {
    const payload: StoredPayload = { version: STORAGE_VERSION, state };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
  } catch {
    // yoksay
  }
}

export function clearGameState(): void {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch {
    // yoksay
  }
}

/** Bitmemiş bir oyun varsa geri yükler; yoksa, bittiyse ya da bozuksa null döner. */
export function loadGameState(): GameState | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as StoredPayload;
    if (parsed.version !== STORAGE_VERSION) return null;
    const state = parsed.state;
    if (
      !state ||
      state.phase !== 'play' ||
      state.isGameOver ||
      !Array.isArray(state.players) ||
      state.players.length === 0
    ) {
      return null;
    }
    // Bu alanlar eklenmeden önce kaydedilmiş bir state'te olmayabilir.
    state.players = state.players.map((p) => ({ ...p, surrendered: p.surrendered ?? false }));
    state.startedAt = state.startedAt || new Date().toISOString();
    // Bu state localStorage'dan geri yüklendi — yani oyun en az bir tarayıcı
    // sekmesi kapat-aç'ı atlattı, çok-oturumlu sayılır (bkz. types.ts).
    state.multiSession = true;
    return state;
  } catch {
    return null;
  }
}
