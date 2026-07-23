import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import { AuthProvider } from './hooks/useAuth';
import { ErrorBoundary } from './components/ErrorBoundary';

// Kendi sunucumuzdan servis edilen yazı tipleri (Google'a gidip gelmek yok).
// Türkçe için yalnızca latin + latin-ext alt kümeleri yüklenir.
//
// Caveat artık bir web fontu DEĞİL — logo ("kelimeki") tamamen statik SVG
// glyph path'lerine (LogoMark.tsx, bkz. scripts/generate-logo-paths.mjs)
// dönüştürüldü, çünkü font-display: swap + gerçek .woff2 dosyasına geçiş
// (23 Temmuz 2026) logoyu her açılışta yedek fonttan gerçek Caveat'e
// görünür biçimde sıçratıyordu (FOUT) — hatta PWA service worker'ın
// arka planda güncelleme uyguladığı her deploy sonrası ilk açılışta bu
// tekrar yaşanıyordu (bu uygulama sık deploy edildiğinden bu, nadir değil
// sürekli tekrar eden bir sorundu). Vektör path'ler hiçbir fonta veya ağ
// isteğine bağlı olmadığından bu sorunu kökten çözüyor.
import './fonts/space-grotesk-inline.css';
import './fonts/space-mono-inline.css';
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
