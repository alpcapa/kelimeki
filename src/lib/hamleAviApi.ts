// Kelimeki — Hamle Avı sunucu uçları (3 Kasım 2026). Tablo `hamle_avi_stats`,
// istemci ona DOĞRUDAN erişmez: yalnızca iki RPC (migration 20261103111854).
// Hata yutulur (`null`): rekor/görülenler cihazda zaten tutuluyor, ağ hatası
// oyunu engellemez; bir sonraki başarılı çağrı birleştirir (idempotent).
import { supabase } from './supabase';

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
  if (!supabase) return null;
  try {
    const { data, error } = await supabase.rpc('hamle_avi_get');
    if (error) return null;
    return toServer((data as Row[] | null)?.[0]);
  } catch {
    return null;
  }
}

export async function reportHamleAvi(best: number, seen: number[]): Promise<HamleAviServer | null> {
  if (!supabase) return null;
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
