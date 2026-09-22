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

// ⚠ DOSYA GENELİNDE DOKUNMATİK PROFİL. Varsayılan proje `Desktop Chrome`,
// yani `(pointer: coarse)` EŞLEŞMEZ — `LandscapeBlock`un kapısının yarısı
// orada hiç açılmaz ve "blok çıkmalı/çıkmamalı" iddialarının tamamı anlamsız
// olurdu (biri yanlış geçerdi, öteki bedavadan). Ölçülen davranış gerçek
// cihazın davranışı: dokunmatik + verilen viewport.
test.use({ hasTouch: true, isMobile: true });

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

    // ⚠ Bu görünümlerde YER VAR, yani TAM EKRAN blok ÇIKMAMALI. Blok sert
    // (kapatılamaz), o yüzden yanlış tetiklenmesi uygulamayı tamamen
    // kullanılamaz yapardı — eski `#landscape-block`un iPad'de düştüğü tuzak.
    expect(c.h).toBeGreaterThanOrEqual(BOTTOM_STRIP_MIN_HEIGHT_PX);
    await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeHidden();
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
  await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeHidden();
});

// ⚠ Bloğun KENDİSİ — 22 Eylül 2026, kullanıcı kararı: *"Telefonda web'in
// yatay çalışması gerekmiyor. Her durumda sadece dikey konuma getirin demek
// yeterli. Ama boş ekranda, arka planda bozuk görüntü vb olmadan."*
test('telefon YATAY: tam ekran blok çıkar, arkada bozuk düzen GÖRÜNMEZ', async ({ page }) => {
  // ⚠ SIRA GERÇEKÇİ: önce DİKEYDE oyuna gir, sonra çevir. Doğrudan yatayda
  // açmak denendi ve test "OYUNU BAŞLAT"a ulaşamadı — çünkü blok zaten
  // Setup'ın üstünde. Bu bir test zorluğu değil, ürünün doğru davranışı:
  // yatayda hiçbir şey tıklanamaz, tek çıkış çevirmek.
  await page.setViewportSize({ width: 390, height: 844 });
  await oyunaGir(page);
  await expect(page.locator('[data-board-viewport]')).toBeVisible();

  // Kullanıcının bildirdiği viewport (iPhone 12/13/14 Pro yatay; ekran
  // görüntüsü 2532×1170 fiziksel, DPR 3'ten hesaplandı).
  await page.setViewportSize({ width: 844, height: 390 });
  await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeVisible();

  // ⚠ ASIL İDDİA: blok arkayı GERÇEKTEN kapatıyor. `toBeInViewport`
  // KULLANILMAZ — o geometriye bakar, üstü ÖRTÜLÜ olmasına değil; tahta
  // DOM'da ve ekranda kalmaya devam eder (kaplayıcı, sökücü değil — oyun
  // durumu korunsun, çevirince kaldığın yerden devam et). Kullanıcının
  // şikâyeti "arka planda bozuk görüntü" olduğuna göre ölçülecek şey ÖRTME:
  // tam ekran kaplama + opak zemin.
  const blok = page.locator('[data-landscape-block]');
  expect(await blok.boundingBox()).toEqual({ x: 0, y: 0, width: 844, height: 390 });
  const opak = await blok.evaluate((el) => {
    const m = getComputedStyle(el).backgroundColor.match(/rgba?\(([^)]+)\)/);
    const p = m ? m[1].split(',').map((n) => parseFloat(n)) : [];
    return p.length < 4 || p[3] === 1; // alfa yoksa ya da 1 ise opak
  });
  expect(opak, 'blok saydam — arkadaki bozuk düzen görünür').toBe(true);

  // ⚠ KAPATILAMAZ: kapanabilseydi geriye yine bozuk düzen kalırdı.
  await expect(blok.getByRole('button')).toHaveCount(0);

  // Dikeye dönünce blok kalkar ve oyun kaldığı yerden görünür.
  await page.setViewportSize({ width: 390, height: 844 });
  await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeHidden();
  await expect(page.locator('[data-board-viewport]')).toBeVisible();
});

test('YAZARKEN blok çıkmaz — ekran klavyesi viewport\'u kısaltsa bile', async ({ page }) => {
  // Kullanıcı bildirdi (22 Eylül 2026): *"Ama iPad'da klavye varsa, yatay
  // olmadan mesaj yazılamıyor. Bu durumu da düşün."*
  //
  // iPad'in KENDİSİ eşiğin üstünde (yatayda 820px boy > 632), yani hiçbir
  // koşulda bloklanmıyor. Ama aynı kök sebep DİKEY telefonda gerçek bir
  // arıza: Android Chrome ekran klavyesi açılınca layout viewport'unu
  // küçültüyor (844 → ~450). Kapı yalnızca yüksekliğe baksaydı ekran TAM
  // MESAJ YAZARKEN "çevirin" derdi.
  await page.addInitScript((key) => {
    try {
      localStorage.setItem(key as string, '1');
    } catch {
      // depolama kapalıysa kapı katmanı gösterir; bu test onu ölçmüyor
    }
  }, SEEN_INTRO_KEY);
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto('/');

  // ⚠ Metin alanı TESTİN KENDİSİ tarafından ekleniyor ve bu bilinçli: asıl
  // hedef yüzey Canlı oyun sohbeti, o da iki gerçek oturum gerektirdiği için
  // otomatik testte açılamıyor (bkz. TESTING.md); Setup'ın kendi input'ları
  // ise akış durumuna bağlı (misafirde ilk ekranda görünmüyorlar), yani
  // testi ilgisiz bir yüzeyin düzenine bağlardı. Ölçülen kural zaten
  // yüzeyden bağımsız: ODAKTAKİ bir metin alanı bloğu bastırır.
  const alan = page.locator('[data-test-input]');
  await page.evaluate(() => {
    const el = document.createElement('input');
    el.type = 'text';
    el.setAttribute('data-test-input', '');
    el.style.cssText = 'position:fixed;top:0;left:0;z-index:2147483647';
    document.body.appendChild(el);
    el.focus();
  });
  await expect(alan).toBeFocused();

  // Klavyenin açılması = layout viewport'unun kısalması.
  await page.setViewportSize({ width: 390, height: 450 });

  // ⚠ BEKLEMEDEN ÖLÇME — YOKLUK iddiaları yarışa açıktır. `toBeHidden()`
  // ilk denemede geçer, çünkü blok medya sorgusu olayından SONRAKİ React
  // turunda gelir; kapı kaldırılsa bile test yeşil kalırdı (bu tam olarak
  // yaşandı, 22 Eylül 2026). Bekleme, bileşendeki 500 ms'lik
  // `focusout` gecikmesinden de uzun.
  await page.waitForTimeout(800);
  await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeHidden();

  // Odak gidince klavye kapanır ve blok geri gelir — bileşendeki 500 ms'lik
  // gecikmeyi `toBeVisible`ın kendi beklemesi karşılıyor.
  await alan.blur();
  await expect(page.getByText('Telefonunuzu dikey çevirin')).toBeVisible();
});
