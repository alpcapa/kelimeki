import { defineConfig, devices } from '@playwright/test';

// Kelimeki — smoke test config. Dev sunucusunu otomatik başlatır (webServer),
// zaten çalışıyorsa (reuseExistingServer) yeniden başlatmaz.
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    launchOptions: {
      // Bu ortamda tarayıcı burada önceden kurulu — `playwright install` çalıştırmaya gerek yok.
      executablePath: '/opt/pw-browsers/chromium',
    },
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
