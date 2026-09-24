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
/**
 * App Store uygulama kimliği — **tek kaynak**.
 *
 * İKİ yerde kullanılıyor: aşağıdaki vitrin adresi ve Safari'nin kendi
 * "Smart App Banner"ı (`<meta name="apple-itunes-app">`). Banner statik
 * HTML'e yazıldığından (`index.html` ve `src/legal/render.tsx`) sayı orada
 * elle duruyor; `npm run verify-store-badges` ikisinin de buradaki değerle
 * eşleştiğini kilitliyor — bu projede "iki kopya sessizce ayrışır" en sık
 * tekrarlayan hata sınıfı.
 */
export const APPLE_APP_ID = '6809809788';

/**
 * Safari'nin Smart App Banner `<meta>` etiketi — yayında DEĞİLSE `null`.
 *
 * Rozetlerle AYNI kapıya bağlı (`url === null` → hiç render etme): yayında
 * olmayan bir uygulamaya banner koymak kullanıcıyı boş bir App Store
 * sayfasına yollar.
 *
 * ⚠ Banner YALNIZCA Safari'de çıkar — uygulama içi tarayıcılarda
 * (Instagram/Facebook) ve Chrome'da görünmez, bu yüzden mağaza rozetlerinin
 * YERİNİ TUTMAZ, onlara ek bir katmandır.
 */
export function appleSmartAppBannerMeta(): string | null {
  const appStore = STORE_BADGES.find((b) => b.key === 'appStore');
  if (!appStore?.url) return null;
  return `<meta name="apple-itunes-app" content="app-id=${APPLE_APP_ID}" />`;
}

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
    url: `https://apps.apple.com/app/kelimeki-t%C3%BCrk%C3%A7e-kelime-oyunu/id${APPLE_APP_ID}`,
    asset: '/app-store-badge.svg',
    alt: "App Store'dan indirin",
  },
  {
    key: 'googlePlay',
    // ✅ 24 Eylül 2026: production gönderimi #19 (1.1.0/665) 17:44'te yayında;
    // vitrin OTURUM AÇMADAN (gizli sekme) açılıyor ve "Erken Erişim" etiketi
    // YOK — kullanıcı ölçtü (bu ortamın vekili play.google.com'u engelliyor).
    // ⚠ Adres bilerek `hl=` parametresiz: Play dili ziyaretçiye göre seçer.
    url: 'https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki',
    asset: '/google-play-badge.svg',
    alt: "Google Play'den indirin",
  },
];

/**
 * Bu CİHAZIN mağazası — yayında değilse (ya da masaüstüyse) `null`.
 *
 * `AppStoreStrip` (standalone moddaki kendi şeridimiz) bunu kullanıyor:
 * iOS'ta App Store, Android'de Play. **Masaüstünde `null`** — orada kurulacak
 * yerel bir uygulama yok, kurulu PWA zaten son hâli.
 *
 * Play'in URL'si 24 Eylül 2026'ya kadar `null`dı ve şerit Android'de hiç
 * çizilmiyordu; URL dolunca kendiliğinden belirdi (rozetlerle AYNI kapı).
 *
 * ⚠ Cihaz tespiti `getDeviceType()`ten gelir, KENDİ UA testİNİ YAZMA —
 * iPadOS 13+ Safari kendini `Macintosh` diye tanıtıyor ve elle yazılan bir
 * `/iPhone|iPad/` testi iPad'i KAÇIRIYOR (vaka: silinen `AddToHomeScreen`in
 * başlığı, 14 Eylül 2026 — bkz. docs/decisions/components.md).
 */
export function storeForDevice(cihaz: 'ios' | 'android' | 'desktop'): StoreBadge | null {
  if (cihaz === 'desktop') return null;
  const key: StoreKey = cihaz === 'ios' ? 'appStore' : 'googlePlay';
  const badge = STORE_BADGES.find((b) => b.key === key);
  return badge?.url ? badge : null;
}

/**
 * Bu sayfa iOS'un GERÇEK Safari'sinde mi açık — yani Apple'ın Smart App
 * Banner'ının (`<meta name="apple-itunes-app">`) çıkacağı tek yer mi?
 *
 * 24 Eylül 2026, kullanıcı: *"Apple'ın kendi banner'ı ile ikisi birlikte
 * fazla olacak… İkisi de aynı şeyi söylüyor."* Banner tarayıcının kendi
 * parçası, sayfa onu GÖREMEZ; ama nerede çıktığı belli: yalnızca iOS
 * Safari'de. Ana ekrandan açılışta (standalone), Chrome/Firefox/Edge/
 * Opera/Google uygulamasında ve uygulama-içi tarayıcılarda (Instagram,
 * Facebook… — bunlar WKWebView, UA'larında `Safari/` bile YOK) çıkmaz.
 *
 * ⚠ **İki bilinen kör nokta, ikisi de "uyarı YOK" yönünde:** (1) bazı
 * uygulamalar linki `SFSafariViewController`da açıyor; UA'sı Safari'yle
 * BİREBİR aynı, ama Smart App Banner orada çıkmayabilir. (2) Apple'ın
 * banner'ını ✕ ile kapatana Apple onu bir süre göstermiyor; biz de. Kullanıcı
 * "fazla uyarı"yı "eksik uyarı"dan kötü saydı.
 * ⚠ iPadOS 13+ Safari kendini `Macintosh` diye tanıtır — o yüzden cihaz
 * `getDeviceType()`ten gelir, burada ayrıca iPhone/iPad ARANMAZ.
 */
export function isIosSafari(cihaz: 'ios' | 'android' | 'desktop', standalone: boolean, ua: string): boolean {
  if (cihaz !== 'ios' || standalone) return false;
  if (!/Safari\//.test(ua)) return false; // WKWebView (uygulama-içi tarayıcı)
  return !/CriOS|FxiOS|EdgiOS|OPiOS|OPT\/|GSA\/|FBAN|FBAV|FB_IAB|Instagram|Line\/|Twitter|Snapchat|LinkedInApp|Pinterest|TikTok|musical_ly|Bytedance/.test(ua);
}

/**
 * Mağaza şeridi (`AppStoreStrip`) gösterilsin mi — tek karar, saf.
 * `hasAppInstall`: girişli kullanıcının `push_tokens`ta satırı var mı
 * (`null` = bilinmiyor/misafir → yüklü DEĞİL sayılır).
 */
export function shouldShowStoreStrip(opts: {
  cihaz: 'ios' | 'android' | 'desktop';
  standalone: boolean;
  ua: string;
  hasAppInstall: boolean | null;
  badges?: StoreBadge[];
}): boolean {
  const key: StoreKey | null = opts.cihaz === 'ios' ? 'appStore' : opts.cihaz === 'android' ? 'googlePlay' : null;
  if (!key || !(opts.badges ?? STORE_BADGES).find((b) => b.key === key)?.url) return false;
  if (isIosSafari(opts.cihaz, opts.standalone, opts.ua)) return false; // Apple'ınki zaten orada
  if (opts.hasAppInstall === true) return false; // uygulama bu hesapta en az bir cihazda kurulu
  return true;
}

/**
 * Yayındaki mağazaların Türkçe adı, bulunma ekiyle — "App Store'da",
 * "Google Play'de", "App Store ve Google Play'de"; hiçbiri yayında değilse
 * `null`.
 *
 * ⚠ **Metin yazan her yüzey bunu ÇAĞIRSIN, cümleyi elle yazmasın.** Gerekçe
 * 16 Eylül 2026'da ölçüldü: karşılama katmanının SSS'i *"uygulamalarımız …
 * inceleme sürecinde, çok yakında mağazalarda olacaklar"* diyordu — App Store
 * yayınının üstünden bir gün geçmişti ve o cümle yalnızca ekranda değil,
 * `render.tsx`in ürettiği `FAQPage` JSON-LD'sinde, yani ARAMA SONUCUNDA da
 * duruyordu. Rozet kapısı (`visibleStoreBadges`) doğru çalışıyordu; bayatlayan
 * şey onun yanındaki düz metindi.
 *
 * ⚠ Ek harfi mağazaya göre değişiyor (Store'**da** ↔ Play'**de**), o yüzden
 * çağıran taraf `${ad}'da` diye birleştiremez — cümleyi buradan alsın.
 */
export function visibleStoreNamesTr(
  badges: StoreBadge[] = STORE_BADGES,
): string | null {
  const adlar = visibleStoreBadges(badges).map((b) =>
    b.key === 'appStore' ? "App Store" : "Google Play",
  );
  if (adlar.length === 0) return null;
  if (adlar.length === 1) return adlar[0] === 'App Store' ? "App Store'da" : "Google Play'de";
  // İkisi birden: ek YALNIZCA sondakine gelir ("App Store ve Google Play'de").
  return `${adlar.slice(0, -1).join(', ')} ve ${adlar[adlar.length - 1]}'de`;
}

/** Bugün gösterilebilecek rozetler — URL'si olmayan HİÇ çıkmaz. */
export function visibleStoreBadges(
  badges: StoreBadge[] = STORE_BADGES,
): (StoreBadge & { url: string })[] {
  return badges.filter((b): b is StoreBadge & { url: string } => Boolean(b.url));
}
