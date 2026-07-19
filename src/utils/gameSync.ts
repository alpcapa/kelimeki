// Harfik — bitmiş oyun kayıtları için offline/misafir kuyruğu.
//
// `saveGame` (lib/api.ts) hemen gönderilemezse — çevrimdışıyken, ağ
// hatasıyla, ya da hiç giriş yapılmamışken (misafir) — kayıt burada
// localStorage'a kuyruklanır. Kuyruk yalnızca BU cihazda tutulur ve bu
// cihazda bir oturum belirdiğinde (bağlantı geri gelince ya da kullanıcı bu
// cihazda giriş/kayıt yapınca) `flushPendingGames` ile gönderilir. Her kayıt
// gerçek bitiş anını taşıyan bir `created_at` içerir, böylece günler sonra
// senkronlansa bile oyun geçmişinde doğru kronolojik yere yerleşir.
import type { NewGame } from '../lib/database.types';
import { saveGame } from '../lib/api';
import { supabase, isSupabaseConfigured } from '../lib/supabase';

const PENDING_KEY = 'harfik:pending-games';
// Hiç kayıt olmadan uzun süre oynayan bir misafirin kuyruğu sınırsız
// büyümesin diye üst sınır — aşılırsa en eski kayıtlar düşürülür.
const MAX_PENDING_GAMES = 300;

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

/** Ağ gerektirmez — yalnızca bu cihazda daha önce kaydedilmiş bir oturum var mı bakar. */
async function hasLocalSession(): Promise<boolean> {
  if (!isSupabaseConfigured || !supabase) return false;
  const { data } = await supabase.auth.getSession();
  return !!data.session?.user;
}

async function trySave(game: NewGame): Promise<boolean> {
  if (!navigator.onLine) return false;
  try {
    return (await saveGame(game)) !== null;
  } catch {
    return false;
  }
}

function enqueue(game: NewGame): void {
  const queue = readQueue();
  if (queue.some((g) => g.id === game.id)) return;
  queue.push(game);
  if (queue.length > MAX_PENDING_GAMES) queue.splice(0, queue.length - MAX_PENDING_GAMES);
  writeQueue(queue);
}

/**
 * Bir oyun kaydını hemen göndermeyi dener; başarısız olursa (offline, ağ
 * hatası, ya da bu cihazda henüz giriş yapılmamış) bir sonraki fırsatta
 * tekrar denenmek üzere kuyruğa eklenir. `game.id` ve `game.created_at`
 * her çağrıda dolu olmalı: `id` sunucuda olası çift kaydı `saveGame`'in
 * 23505 kısayoluyla engeller, `created_at` gerçek bitiş anını korur.
 *
 * Misafir (girişsiz) oynanan oyunlar da kuyruklanır — kişi ileride bu
 * cihazda giriş/kayıt yaparsa `flushPendingGames` hepsini o hesaba aktarır.
 */
export async function saveGameDurable(game: NewGame): Promise<void> {
  const ok = (await hasLocalSession()) && (await trySave(game));
  if (!ok) enqueue(game);
}

let flushing = false;

/**
 * Kuyruktaki bekleyen oyun kayıtlarını tekrar göndermeyi dener. Bu cihazda
 * henüz hiç oturum yoksa (saf misafir kullanım) ağ isteği yapmadan hemen
 * çıkar — kuyruk, kişi giriş/kayıt yapana kadar sessizce bekler.
 */
export async function flushPendingGames(): Promise<void> {
  if (flushing) return;
  const queue = readQueue();
  if (queue.length === 0) return;
  if (!(await hasLocalSession())) return;

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
