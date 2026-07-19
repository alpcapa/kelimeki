// Harfik — bitmiş oyun kayıtları için offline kuyruk.
//
// `saveGame` (lib/api.ts) çevrimdışıyken ya da ağ hatası nedeniyle
// başarısız olursa kayıt burada localStorage'a kuyruklanır; uygulama tekrar
// çevrimiçi olduğunda (veya oturum yeniden geçerli hale geldiğinde)
// `flushPendingGames` ile tekrar denenir. Böylece örn. uçakta internetsiz
// başlayıp bitirilen bir oyunun sonucu, bağlantı geri gelince otomatik
// olarak skor kartına/lig'e yansır.
import type { NewGame } from '../lib/database.types';
import { saveGame } from '../lib/api';
import { supabase, isSupabaseConfigured } from '../lib/supabase';

const PENDING_KEY = 'harfik:pending-games';

function readQueue(): NewGame[] {
  try {
    const raw = localStorage.getItem(PENDING_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function writeQueue(queue: NewGame[]): void {
  try {
    if (queue.length === 0) localStorage.removeItem(PENDING_KEY);
    else localStorage.setItem(PENDING_KEY, JSON.stringify(queue));
  } catch {
    // localStorage dolu/erişilemez olabilir — bir sonraki flush'ta tekrar denenir.
  }
}

async function trySave(game: NewGame): Promise<boolean> {
  if (!navigator.onLine) return false;
  try {
    return (await saveGame(game)) !== null;
  } catch {
    return false;
  }
}

/**
 * Bir oyun kaydını hemen göndermeyi dener; başarısız olursa (offline/ağ
 * hatası) bağlantı geri gelince tekrar denenmek üzere kuyruğa eklenir.
 * `game.id` her çağrıda dolu olmalı (crypto.randomUUID()) — hem kuyruktaki
 * yinelenenleri ayıklamak hem de sunucu tarafında olası çift kaydı
 * `saveGame`'in 23505 kısayoluyla engellemek için.
 *
 * Yerel (localStorage'daki, ağ gerektirmeyen) oturum yoksa hiç kuyruklanmaz
 * — misafir (girişsiz) oynanan oyunlar zaten kaydedilmiyor, bu davranış
 * korunur.
 */
export async function saveGameDurable(game: NewGame): Promise<void> {
  if (!isSupabaseConfigured || !supabase) return;
  const { data } = await supabase.auth.getSession();
  if (!data.session?.user) return;

  const ok = await trySave(game);
  if (ok) return;
  const queue = readQueue();
  if (queue.some((g) => g.id === game.id)) return;
  queue.push(game);
  writeQueue(queue);
}

let flushing = false;

/** Kuyruktaki bekleyen oyun kayıtlarını tekrar göndermeyi dener. */
export async function flushPendingGames(): Promise<void> {
  if (flushing) return;
  const queue = readQueue();
  if (queue.length === 0) return;
  flushing = true;
  try {
    const remaining: NewGame[] = [];
    for (const game of queue) {
      const ok = await trySave(game);
      if (!ok) remaining.push(game);
    }
    writeQueue(remaining);
  } finally {
    flushing = false;
  }
}
