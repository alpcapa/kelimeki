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
// flowType: 'implicit' — PKCE (varsayılan) şifre sıfırlama bağlantısını
// isteği başlatan sekmenin localStorage'ına yazdığı bir code_verifier'a
// bağımlı kılar; bağlantı başka bir tarayıcı/depolama bağlamında açılırsa
// (ör. ana ekrana eklenmiş PWA'da isteyip Mail uygulamasının kendi
// tarayıcısında açmak) code_verifier bulunamaz, Supabase sessizce o
// bağlamdaki eski oturumu geri yükler — kullanıcı yeni şifre ekranı yerine
// doğrudan (eski hesabıyla) giriş yapmış gibi görünür. Uygulamada OAuth
// kullanılmadığından (yalnızca e-posta/şifre) PKCE'nin faydası yok; implicit
// akışta kurtarma token'ı URL'in kendisinde taşındığından bu bağımlılık ortadan kalkar.
export const supabase: SupabaseClient | null = isSupabaseConfigured
  ? createClient(url!, anonKey!, {
      auth: { persistSession: true, autoRefreshToken: true, flowType: 'implicit' },
    })
  : null;

if (!isSupabaseConfigured && import.meta.env.DEV) {
  // Geliştirme sırasında uyarı; üretimde sessiz.
  console.info(
    '[Kelimeki] Supabase yapılandırılmadı — çevrimiçi özellikler kapalı. .env ekleyin.',
  );
}
