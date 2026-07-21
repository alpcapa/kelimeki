import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import { AuthProvider } from './hooks/useAuth';
import { ErrorBoundary } from './components/ErrorBoundary';

// Kendi sunucumuzdan servis edilen yazı tipleri (Google'a gidip gelmek yok).
// Türkçe için yalnızca latin + latin-ext alt kümeleri yüklenir.
//
// Space Grotesk, Space Mono ve Caveat, @fontsource'un ayrı woff2
// dosyaları yerine kendi base64-gömülü font-face'lerimizden yükleniyor
// (bkz. ilgili dosya içi yorumlar) — ayrı bir ağ isteği/FOUT/kayma
// riski olmadan.
import './fonts/space-grotesk-inline.css';
import './fonts/space-mono-inline.css';
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
