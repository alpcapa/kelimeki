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
import '@fontsource/caveat/latin-700.css';
import '@fontsource/caveat/latin-ext-700.css';
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
