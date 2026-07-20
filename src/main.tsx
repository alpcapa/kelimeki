import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import { AuthProvider } from './hooks/useAuth';
import { ErrorBoundary } from './components/ErrorBoundary';

// Kendi sunucumuzdan servis edilen yazı tipleri (Google'a gidip gelmek yok).
// Türkçe için yalnızca latin + latin-ext alt kümeleri yüklenir.
import '@fontsource/space-grotesk/latin-400.css';
import '@fontsource/space-grotesk/latin-ext-400.css';
import '@fontsource/space-grotesk/latin-500.css';
import '@fontsource/space-grotesk/latin-ext-500.css';
import '@fontsource/space-grotesk/latin-600.css';
import '@fontsource/space-grotesk/latin-ext-600.css';
import '@fontsource/space-grotesk/latin-700.css';
import '@fontsource/space-grotesk/latin-ext-700.css';
import '@fontsource/space-mono/latin-400.css';
import '@fontsource/space-mono/latin-ext-400.css';
import '@fontsource/space-mono/latin-700.css';
import '@fontsource/space-mono/latin-ext-700.css';
// Caveat, @fontsource/caveat/latin(-ext)-700.css yerine kendi
// font-face'imizden (font-display: optional, bkz. dosya içi yorum)
// yükleniyor — logodaki font geçişinin (swap) mobilde yarattığı kaymayı
// önlemek için. Not: aynı unicode-range'i kapsayan iki @font-face rule'ü
// (biri swap, biri optional) aynı anda import edip "sonraki override eder"
// varsayımıyla ikisini birden tutmak İŞE YARAMIYOR — Chromium bu durumda
// kaskaddaki SONRAKİ değil, İLK tanımlanan @font-face'i kullanıyor (font
// seçim algoritması normal CSS "son kural kazanır" kaskadına uymuyor).
// Bu yüzden fontsource'un swap import'ları burada hiç yer almıyor.
import './fonts/caveat-logo.css';
import './fonts/nunito-tile.css';

import './index.css';

import { setupPwaUpdates } from './lib/pwa';

setupPwaUpdates();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ErrorBoundary>
      <AuthProvider>
        <App />
      </AuthProvider>
    </ErrorBoundary>
  </StrictMode>,
);
