import { test, expect, type Page } from '@playwright/test';
import { tanitimiAtla } from './gameOverFixture';
import { BOARD_MIN_PX, BOTTOM_STRIP_MIN_HEIGHT_PX } from '../src/utils/boardFit';

// Kelimeki — tahtanın YÜKSEKLİK bütçesi kapısı.
//
// 22 Eylül 2026, kullanıcı bildirdi: *"Samsung katlanabilirde tahta yatay
// iPad gibi görünüyordu, raf ve butonlar ekranın altında kalıyordu, oynamak
// imkânsız."* Sebep: tahta yalnızca GENİŞLİKTEN boyutlanıyordu, layout'un
// hiçbir yerinde "ne kadar boyum kaldı" sorusu yoktu.
//
// ⚠ BU TESTİN ÖLÇTÜĞÜ ŞEY BİR SAYI DEĞİL, BİR DAVRANIŞ: "alt şerit (raf +
// butonlar) görünür alanın içinde mi". `boardFit.ts`teki `BOARD_CHROME_PX`
// ölçülmüş bir sabittir ve başlık/raf/buton şeridi değişirse BAYATLAR —
// o bayatlamayı yakalayan tek şey bu test.
//
// ⚠ Neden `smoke.spec.ts`e eklenmedi: orası TEK bir viewport'ta kritik yolu
// koşuyor; burada aynı akış DÖRT viewport'ta tekrarlanıyor ve testin konusu
// tamamen farklı (düzen, kural değil).

const SEEN_INTRO_KEY = 'kelimeki:seen-intro';

async function oyunaGir(page: Page): Promise<void> {
  await page.addInitScript((key) => {
    try {
      localStorage.setItem(key as string, '1');
    } catch {
      // depolama kapalıysa kapı katmanı gösterir; bu test onu ölçmüyor
    }
  }, SEEN_INTRO_KEY);
  await page.goto('/');
  await page.getByText('OYUNU BAŞLAT').click();
  const devam = page
    .getByLabel('Giriş uyarısı')
    .getByRole('button', { name: 'Oyna', exact: true });
  if (await devam.isVisible().catch(() => false)) {
    await devam.click();
  }
  await tanitimiAtla(page);
  await expect(page.getByRole('button', { name: 'Pas Geç' }).first()).toBeVisible();
}

// "Geniş ama KISA" viewport'lar — hatanın çıktığı sınıfın tamamı. Üçü de
// 975px'lik eski sabit sütundan kısa; ölçülen taşmalar sırasıyla 195 · 143 ·
// 163 px idi.
const GENIS_AMA_KISA = [
  { ad: 'açık katlanabilir, yatay', w: 1104, h: 768 },
  { ad: 'yatay iPad', w: 1180, h: 820 },
  { ad: 'dizüstü 1440×800', w: 1440, h: 800 },
];

for (const c of GENIS_AMA_KISA) {
  test(`${c.ad}: raf ve butonlar ekranın İÇİNDE`, async ({ page }) => {
    await page.setViewportSize({ width: c.w, height: c.h });
    await oyunaGir(page);

    // Alt şeridin en altındaki buton — bunun altı görünür alanı aşarsa
    // oyuncu her hamlede kaydırmak zorunda kalır (bildirilen hata).
    const pasGec = page.getByRole('button', { name: 'Pas Geç' }).first();
    const kutu = await pasGec.boundingBox();
    expect(kutu, 'Pas Geç butonu bulunamadı').not.toBeNull();
    expect(
      Math.round(kutu!.y + kutu!.height),
      `alt şerit ${c.w}×${c.h} görünümünde ekranın altına taşıyor`,
    ).toBeLessThanOrEqual(c.h);

    // Tahta yine de OYNANABİLİR kalmalı — sığdırmak uğruna minicik bir
    // tahta, kırpmadan daha iyi değildir.
    const tahta = await page.locator('[data-board-viewport]').boundingBox();
    expect(tahta!.height, 'tahta oynanamayacak kadar küçüldü').toBeGreaterThanOrEqual(
      BOARD_MIN_PX - 24,
    );

    // Bu görünümlerde YER VAR, yani "dikeye dön" önerisi ÇIKMAMALI.
    expect(c.h).toBeGreaterThanOrEqual(BOTTOM_STRIP_MIN_HEIGHT_PX);
    await expect(page.getByText('Dikey konumda daha iyi bir deneyim yaşarsınız')).toBeHidden();
  });
}

test('dikey telefon: düzen DEĞİŞMEDİ (yükseklik sınırı hiç devreye girmiyor)', async ({
  page,
}) => {
  // Regresyon kapısı: sınırın bağlayıcı olduğu tek yer "geniş ama kısa"
  // viewport. Dar ekranda kısıt hâlâ GENİŞLİK olmalı — 22 Eylül 2026'da
  // ölçülen 369px tahta değişmemeli.
  await page.setViewportSize({ width: 393, height: 852 });
  await oyunaGir(page);
  const tahta = await page.locator('[data-board-viewport]').boundingBox();
  expect(Math.round(tahta!.width)).toBe(369);
  await expect(page.getByText('Dikey konumda daha iyi bir deneyim yaşarsınız')).toBeHidden();
});
