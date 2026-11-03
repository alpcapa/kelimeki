// Kelimeki — Hamle Avı sunucu uçları (3 Kasım 2026). Tablo `hamle_avi_stats`,
// istemci ona DOĞRUDAN erişmez: yalnızca iki RPC (migration 20261103111854).
// Hata yutulur (`null`): rekor/görülenler cihazda zaten tutuluyor, ağ hatası
// oyunu engellemez; bir sonraki başarılı çağrı birleştirir (idempotent).
import { supabase } from './supabase';
import { CLIENT_PLATFORM } from '../utils/platform';
import { getOrCreateAnonId } from '../utils/visitTracking';

/**
 * Hamle Avı'nın SUNUCUYA veri gönderen tüm yolları (hesapta rekor/görülenler senkronu + anonim sonuç
 * ölçümü) bu bayrakla açılır.
 *
 * **AÇIK (3 Kasım 2026, kullanıcı kararı):** web yayınıyla birlikte, ama Gizlilik Politikası bu veriyi
 * HENÜZ anlatmıyor. BİLİNÇLİ GEÇİCİ İSTİSNA: metin (§2 rekor maddesi, §5 silme listesi, §6 "dokuz durum"
 * (9) + tarih) web+port İKİZİ olarak **1.1.6 ile birlikte** yayınlanacak (~1 hafta); iOS 1.1.5 In Review
 * olduğundan mobil dosyaya dokunan bir merge şimdi istenmiyor. Kullanıcı riski bilerek kabul etti
 * (anonim sonuç olayı hesap kimliği taşımıyor; hesaba bağlı olan yalnızca rekor sayısı + görülen bulmaca
 * numaraları). ⚠ 1.1.6 kayarsa bu istisna UZAMAZ — metin web'de tek başına yayınlanır ya da bayrak kapanır.
 * Takip: docs/decisions/product-backlog.md → "KARAR (3 Kas 2026) — gizlilik gecikmeli".
 */
export const HAMLE_AVI_SERVER_ENABLED = true;

export interface HamleAviServer {
  best: number;
  seen: number[];
}

interface Row {
  best_streak: number;
  seen_ids: number[];
}

const toServer = (r: Row | undefined): HamleAviServer | null =>
  r ? { best: r.best_streak ?? 0, seen: r.seen_ids ?? [] } : null;

export async function fetchHamleAvi(): Promise<HamleAviServer | null> {
  if (!HAMLE_AVI_SERVER_ENABLED || !supabase) return null;
  try {
    const { data, error } = await supabase.rpc('hamle_avi_get');
    if (error) return null;
    return toServer((data as Row[] | null)?.[0]);
  } catch {
    return null;
  }
}

export async function reportHamleAvi(best: number, seen: number[]): Promise<HamleAviServer | null> {
  if (!HAMLE_AVI_SERVER_ENABLED || !supabase) return null;
  try {
    const { data, error } = await supabase.rpc('hamle_avi_report', {
      p_best_streak: best,
      p_seen_ids: seen,
    });
    if (error) return null;
    return toServer((data as Row[] | null)?.[0]);
  } catch {
    return null;
  }
}

/**
 * Hamle Avı bulmaca sonucunun ANONİM ölçümü (`hamle_avi_events`, admin "Hamle Avı" kartı).
 *
 * ⚠ Hesap kimliği YAZILMAZ (tutorial_events/game_starts ile aynı gizlilik kararı): yalnızca cihazın
 * anonim kodu. "Girişli miydi" bayrağını sunucu kendisi koyar (`is_guest` varsayılanı `auth.uid() is null`).
 * Gizlilik §6 (9). `source`: yalnızca kelimeki.com 'prod' — preview/yerel denemeler 'preview' yazar ve
 * admin RPC'si saymaz. Telemetri asla akışı bozmaz: hata yalnızca konsola yazılır.
 */
export async function logHamleAviEvent(
  puzzleId: number,
  result: 'found' | 'missed' | 'left',
  seconds: number,
  streakBefore: number,
): Promise<void> {
  if (!HAMLE_AVI_SERVER_ENABLED || !supabase) return;
  const host = typeof location !== 'undefined' ? location.hostname : '';
  const source = host === 'kelimeki.com' || host === 'www.kelimeki.com' ? 'prod' : 'preview';
  try {
    const { error } = await supabase.from('hamle_avi_events').insert({
      anon_id: getOrCreateAnonId(),
      puzzle_id: puzzleId,
      result,
      seconds: Math.max(0, Math.min(300, Math.round(seconds))),
      streak_before: Math.max(0, Math.min(5000, Math.round(streakBefore))),
      source,
      platform: CLIENT_PLATFORM,
      app_version: null,
    });
    if (error) console.error('[Kelimeki] logHamleAviEvent hatası:', error.message);
  } catch (err) {
    console.error('[Kelimeki] logHamleAviEvent hatası:', err);
  }
}
