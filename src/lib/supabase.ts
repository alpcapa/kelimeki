// Kelimeki — Supabase istemcisi
//
// Ortam değişkenleri ayarlı değilse istemci null olur ve oyun çevrimdışı
// (yerel) çalışmaya devam eder. Anahtarları `.env` dosyasına ekleyin:
//   VITE_SUPABASE_URL=https://xvqlizifakkkoqahaxsg.supabase.co
//   VITE_SUPABASE_ANON_KEY=sb_publishable_...
import { createClient, type SupabaseClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

/** Supabase anahtarları yapılandırıldı mı? */
export const isSupabaseConfigured = Boolean(url && anonKey);

/** Yapılandırılmışsa Supabase istemcisi, değilse null. */
export const supabase: SupabaseClient | null = isSupabaseConfigured
  ? createClient(url!, anonKey!, {
      auth: { persistSession: true, autoRefreshToken: true },
    })
  : null;

if (!isSupabaseConfigured && import.meta.env.DEV) {
  // Geliştirme sırasında uyarı; üretimde sessiz.
  console.info(
    '[Kelimeki] Supabase yapılandırılmadı — çevrimiçi özellikler kapalı. .env ekleyin.',
  );
}
