import { test, expect } from '@playwright/test';

// Kelimeki — kritik yol duman testleri. Amaç kapsamlı bir test paketi değil,
// "uygulama açılıyor, bir oyun başlatılabiliyor, YZ hamle yapabiliyor"
// düzeyinde bir güven: launch öncesi/deploy sonrası hızlı bir sağlık kontrolü.

test('Setup ekranı açılır, 2 kişilik oyun başlar, YZ hamle yapar', async ({ page }) => {
  // Pas geçme, native window.confirm() ile onay istiyor (App.tsx handlePass) —
  // Playwright varsayılan olarak dialog'ları reddeder, burada kabul ediyoruz.
  page.on('dialog', (dialog) => dialog.accept());

  await page.goto('/');
  await expect(page).toHaveTitle(/Kelimeki/);

  await page.getByText('OYUNU BAŞLAT').click();

  // Misafir girişi onay modalı — her zaman çıkmayabilir.
  const devamButton = page.getByRole('button', { name: 'Devam', exact: true });
  if (await devamButton.isVisible().catch(() => false)) {
    await devamButton.click();
  }

  // İlk ziyarette otomatik açılan "Hızlı Başlangıç" modalı. Sayfada
  // aria-label="Kapat" başka bir yerde de var (AddToHomeScreen banner'ı),
  // o yüzden yalnızca bu modal gerçekten açıksa ve onun içindeki kapat
  // butonunu (son eklenen portal — .last()) hedefleyerek kapatıyoruz.
  const quickstartHeading = page.getByRole('heading', { name: /hızlı başlangıç/i });
  if (await quickstartHeading.isVisible().catch(() => false)) {
    await page.locator('button[aria-label="Kapat"]').last().click();
  }

  const oynaButton = page.getByRole('button', { name: 'OYNA' });
  await expect(oynaButton).toBeVisible();

  const pasGecButton = page.getByRole('button', { name: 'PAS GEÇ' });
  await expect(pasGecButton).toBeEnabled();
  await pasGecButton.click();

  // Sıra YZ'ye geçince kontroller devre dışı kalır (App.tsx `canAct`).
  await expect(pasGecButton).toBeDisabled();

  // YZ hamlesini tamamlayıp sırayı geri verince kontroller tekrar aktif olur.
  await expect(pasGecButton).toBeEnabled({ timeout: 20_000 });

  // Bu noktaya ulaşmak, reducer/YZ/skor/bölge hesaplama zincirinin ucuna
  // kadar hatasız çalıştığı anlamına gelir — ErrorBoundary devreye girmedi.
  await expect(page.getByText('Bir şeyler ters gitti')).toHaveCount(0);
});

test('Bilinmeyen bir path da uygulamayı normal açar (SPA fallback)', async ({ page }) => {
  await page.goto('/bu-path-hic-yok');
  await expect(page.getByText('OYUNU BAŞLAT')).toBeVisible();
});
