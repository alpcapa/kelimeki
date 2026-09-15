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
 * ⚠ **EŞİT YÜKSEKLİK KURALI ÇİĞNİYORDU — 15 Eylül 2026'da ÖLÇÜLDÜ ve
 * düzeltildi.** Bu satır eskiden *"eşit yükseklik iki kuralı birden
 * karşılıyor, çünkü Play daha geniş (3.37:1 ↔ Apple ~3.0:1)"* diyordu.
 * O `~3.0` bir VARSAYIMDI: Apple'ın dosyası o tarihte repoda yoktu, oran
 * İngilizce rozetten tahmin edilmişti. Gerçek dosya gelince ölçüldü —
 * **Türkçe rozet 3.78:1** ("App Store'dan İndirin" İngilizcesinden uzun).
 * Yani eşit yükseklikte Apple DAHA GENİŞ kalıyordu (44 px'te 166 ↔ 148) ve
 * Google'ın *"same size or larger"* kuralı ÇİĞNENİYORDU.
 *
 * **Çözüm: hizalama yükseklikten GENİŞLİĞE çevrildi.** İkisi de aynı
 * genişlikte çizilir (`BADGE_WIDTH_PX`), yükseklik orandan gelir. Sonuç:
 * Play biraz daha YÜKSEK durur (~50 px ↔ Apple ~44 px) — bu bir kusur
 * değil, Google'ın kuralının ta kendisi. Apple'ın tek boyut kuralı
 * "≥ 40 px yükseklik" ve o da sağlanıyor.
 *
 * ⚠ **Ders: iki rozeti KARŞILAŞTIRAN bir kural, iki dosya da elde olmadan
 * kanıtlanamaz.** Kapı (`verify-store-badges`) eskiden yalnızca Play'in
 * oranına bakıyordu (`≥ 3.0`) ve Apple'ın gerçek oranını hiç görmüyordu;
 * artık İKİ SVG'yi de okuyup çizilen genişlikleri doğrudan karşılaştırıyor.
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

/** Apple'ın ekran alt sınırı — App Store rozeti bundan kısa çizilemez. */
export const BADGE_MIN_HEIGHT_PX = 40;

/**
 * Rozetlerin ekranda çizileceği GENİŞLİK (px); yükseklik orandan gelir.
 *
 * ⚠ Hizalama bilerek genişlikten yapılıyor — gerekçe yukarıdaki ölçümde.
 * Eşit genişlik, Google'ın "same size or larger"ını tanım gereği sağlar.
 * Değer, Apple rozetinin yüksekliğini 40'ın altına DÜŞÜRMEYECEK kadar
 * büyük olmalı: 166 / 3.78 ≈ 43.9 px. Kapı bunu her koşuda doğruluyor.
 */
export const BADGE_WIDTH_PX = 166;

/**
 * Rozetler arası boşluk (px) — clear space kuralının karşılığı.
 *
 * İki kılavuz da "yüksekliğin 1/4'ü" diyor. İki rozet artık AYNI yükseklikte
 * olmadığından ölçüt YÜKSEK OLANI (Play, ~50 px): 50/4 ≈ 13.
 * ⚠ Elle yazılmış görünüyor ama denetimsiz DEĞİL — `verify-store-badges`
 * bu sayıyı gerçek SVG'lerden hesaplayıp karşılaştırıyor; rozet dosyası
 * ya da genişlik değişirse kapı düşer.
 */
export const BADGE_GAP_PX = 13;

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
    // ✅ 15 Eylül 2026: 1.1.0 (665) onaylandı, yayın başlatıldı ve Apple'ın
    // Marketing Tools akışı bu uygulama için ARTIK İLERLİYOR — 10 Eylül'de
    // ilerlemiyordu (yayında olmayan uygulamada duruyor), yani akışın kendisi
    // vitrinin açıldığının kanıtı. Rozet dosyası da oradan indirildi
    // (Türkçe SİYAH; künye `..._Badge_TR_blk_...`).
    //
    // ⚠ Adres bilerek ÜLKESİZ (`/app/`, `/tr/app/` değil): Apple ziyaretçiyi
    // kendi ülke vitrinine yönlendirir, uygulama tüm ülkelerde yayında.
    // ⚠ Marketing Tools'un verdiği `?itscg=…&itsct=apps_box_link&…` izleme
    // kuyruğu BİLEREK atıldı — o token aracın kendi bağlamı için üretildi,
    // sitedeki kalıcı bir rozetin bağlamı değil (kullanıcı kararı).
    url: 'https://apps.apple.com/app/kelimeki-t%C3%BCrk%C3%A7e-kelime-oyunu/id6809809788',
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
