/**
 * Mağaza rozetleri — URL'ler, sıra ve yerleşim kuralları (ROADMAP #26).
 *
 * ## Kapı: `null` = "henüz yayında değil"
 *
 * Bir mağazanın URL'si `null` olduğu sürece O ROZET HİÇ RENDER EDİLMEZ.
 * Yayın geldiğinde tek yapılacak şey buradaki `null`u gerçek adresle
 * değiştirmek — §26 tamamen web işi, mobil pakete binmez, `main`'e merge
 * olur olmaz Vercel'den canlıya çıkar.
 *
 * ⚠ **Bir URL'yi yayın ÖLÇÜLMEDEN doldurma.** Ölçüt "onay e-postası geldi"
 * ya da "Console 'Active' diyor" DEĞİL, vitrin adresinin 404 vermeyi
 * bırakmasıdır. Play tarafında bu iki kez yanlış okundu (13 Eylül 2026):
 * production ERİŞİMİ onaylanmak vitrini açmıyor, ve geliştiricinin kendi
 * Play hesabı testçi listesinde olduğu için ona her hâlükârda bir liste
 * gösteriyor — *(Erken Erişim)* etiketiyle. Doğru ölçüm OTURUM AÇMADAN:
 * gizli sekme ya da testçi olmayan biri. Vaka:
 * `marketing/play-store/console-formlari.md` §7.5.
 *
 * ## Yerleşim kuralları — İKİSİ DE tescilli marka, ikisinin de kendi kuralı var
 *
 * 14 Eylül 2026'da her iki kaynaktan da DOĞRULANDI (Apple'ın sayfası bu
 * ortamdan çekilebiliyor; Google'ınkini kullanıcı ekrandan okudu):
 *
 * | Kural | Kaynak |
 * |---|---|
 * | App Store rozeti **ilk** (solda) | Apple: *"Place the App Store badge first in the lineup of badges."* |
 * | Play rozeti **aynı boy ya da daha büyük** | Google: *"make sure the Google Play badge is the same size or larger than the other badges"* |
 * | Clear space = yüksekliğin **1/4**'ü | İKİSİ DE aynı sayıyı veriyor |
 * | Ekranda min **40 px** yükseklik | Apple |
 * | Öteki platform rozetiyle birlikteyken **siyah** sürüm | Apple |
 *
 * ⚠ **Görünürdeki çelişki gerçek DEĞİL.** Google'ın kılavuz sayfasındaki
 * örnek görselde Play SOLDA duruyor; bu bir ÖRNEK, kural değil — Google'ın
 * metni sıra hakkında hiçbir şey söylemiyor, yalnızca boyut diyor. Apple'ınki
 * ise açık yazılı bir kural. Bu yüzden sıra Apple'a göre belirlendi.
 *
 * ⚠ **Eşit yükseklik İKİ kuralı birden karşılıyor:** Play rozeti eşit
 * yükseklikte zaten daha geniş (oran 3.37:1 ↔ Apple ~3.0:1), yani "aynı boy
 * ya da daha büyük" sağlanıyor.
 *
 * ## Rozet dosyaları ÇİZİLMEZ
 *
 * İkisi de tescilli marka; yeniden çizmek, rengini/oranını değiştirmek,
 * kırpmak yasak. Apple'ın gri kenarlığı bile artwork'ün parçası. Dosyalar
 * resmî kaynaktan indirilip `public/`'e olduğu gibi konur.
 *
 * ⚠ **Rozet SVG'lerini DOM'a INLINE ETME, `<img>` kullan.** Illustrator
 * ihracatları `<style>` bloğunda `.st0`, `.st1`… gibi jenerik sınıf adları
 * taşıyor (elimizdeki Play dosyasında da var) ve inline SVG'nin CSS'i sayfa
 * geneline sızıyor — iki rozet de aynı adları kullandığında renkleri
 * birbirini ezer. `<img src>` bunu tamamen izole eder, ayrıca dosyayı JS
 * paketinin dışında tutar.
 */

/** Rozetin ekranda çizileceği yükseklik (px). Apple'ın alt sınırı 40. */
export const BADGE_HEIGHT_PX = 44;

/**
 * Rozetler arası boşluk (px) — clear space kuralının karşılığı.
 *
 * İki kılavuz da "yüksekliğin 1/4'ü" diyor. Burada TÜRETİLİYOR, elle
 * yazılmıyor: yükseklik değişirse boşluk da değişsin.
 */
export const BADGE_GAP_PX = Math.ceil(BADGE_HEIGHT_PX / 4);

export type StoreKey = 'appStore' | 'googlePlay';

export type StoreBadge = {
  key: StoreKey;
  /** Yayındaki vitrin adresi; `null` = henüz yayında değil → HİÇ render edilmez. */
  url: string | null;
  /** `public/` altındaki resmî rozet dosyası. */
  asset: string;
  /** `alt` metni — Türkçe, çünkü uygulama Türkçe-only. */
  alt: string;
};

/**
 * Rozetler — **SIRA ANLAMLI**, dizinin sırası ekrandaki sıradır.
 *
 * ⚠ App Store ÖNCE. Bu Apple'ın yazılı kuralı; yeniden sıralama.
 */
export const STORE_BADGES: StoreBadge[] = [
  {
    key: 'appStore',
    // Sayısal App ID elde (6809809788) ama uygulama HENÜZ YAYINDA DEĞİL.
    // ⚠ Rozet dosyası da yok: Apple'ın Marketing Tools akışı rozeti vermeden
    // önce uygulamayı arattırıyor ve yayında olmayan uygulamada ilerlemiyor
    // (10 Eylül 2026'da denendi). Yedek yol: kılavuz sayfasındaki
    // "Download Artwork" arşivi (336 MB) — içinden yalnızca Türkçe SİYAH
    // dosya alınır, gerisi repoya GİRMEZ.
    url: null,
    asset: '/app-store-badge.svg',
    alt: "App Store'dan indirin",
  },
  {
    key: 'googlePlay',
    // Play production sürümü incelemede (13 Eylül 2026'da gönderildi).
    url: null,
    asset: '/google-play-badge.svg',
    alt: "Google Play'den indirin",
  },
];

/** Bugün gösterilebilecek rozetler — URL'si olmayan HİÇ çıkmaz. */
export function visibleStoreBadges(
  badges: StoreBadge[] = STORE_BADGES,
): (StoreBadge & { url: string })[] {
  return badges.filter((b): b is StoreBadge & { url: string } => Boolean(b.url));
}
