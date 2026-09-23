// Kelimeki — tahtanın YÜKSEKLİK bütçesi.
//
// 22 Eylül 2026, kullanıcı bildirdi: *"Kelimeki'yi Samsung katlanabilir
// telefonda denedim, tahta yatay iPad gibi görünüyordu, raf ve butonlar
// ekranın altında kalıyordu. Görmek için aşağı kaydırmak gerekiyor, oynamak
// imkânsız."*
//
// TEŞHİS (üretim derlemesinde, gerçek tarayıcıda ölçüldü): tahta YALNIZCA
// genişlikten boyutlanıyordu — `Board.tsx`te `max-w-[680px]` + `aspect-square`,
// ve layout'un hiçbir yerinde "ne kadar boyum kaldı" sorusu yoktu. Viewport
// genişliği ~700px'i geçince tahta 656px'te doyuyor ve sütunun TAMAMI sabit
// 975px oluyordu; yani **975 CSS px'ten kısa her viewport** alt şeridi (raf +
// Oyna/Pas Geç/Değiştir) ekranın altına itiyordu.
//
//   açık Fold yatay 1104×768 → 195px aşağıda
//   yatay iPad      1180×820 → 143px
//   dizüstü         1440×800 → 163px
//
// ⚠ Yani bu KATLANABİLİRE ÖZEL DEĞİL: yatay tablet ve 800px yüksekliğindeki
// sıradan bir dizüstü tarayıcısı da aynı durumdaydı. Katlanabilirde göze
// batmasının sebebi, açılınca viewport'un bir anda "geniş ama kısa" olması.
//
// ⚠ ÇÖZÜM NEDEN CSS-ONLY: katlanıp açılmak CANLI bir resize. `dvh` tabanlı bir
// sınır hiçbir dinleyici olmadan doğru davranır; `resize` olayına bağlanan bir
// JS çözümü katlanma anında bir kare geç kalır ve (bu depoda tekrarlanan hata)
// bir değeri "ilk ölçümde" dondurma riskini taşır.

/**
 * Tahta kartının DIŞINDA kalan her şeyin yüksekliği: `GameHeader`, skor
 * kutuları, mesaj satırı, raf ve buton şeridi — artı kartın kendi dikey
 * dolgusu.
 *
 * ⚠ ÖLÇÜLMÜŞ bir sayı, tahmin değil (22 Eylül 2026, üretim derlemesi):
 * sütunun tamamı 975px, tahta karesi 656px, kartın dikey dolgusu 18px →
 * 975 − 656 − 18 = 301.
 *
 * ⚠ DAR ekranda bu sayı BÜYÜR (skor/buton şeridi sarıyor: dikey iPhone'da
 * ölçüldü, 483). Burada bilerek DAR değil GENİŞ ekranın değeri duruyor, çünkü
 * sınırın işi yalnızca "geniş ama kısa" viewport'u kurtarmak: dar ekranda
 * bağlayıcı kısıt zaten GENİŞLİK ve bu sınır hiç devreye girmiyor (dikey
 * iPhone'da 852 − 301 = 551 > genişliğin verdiği 369).
 *
 * ⚠ **CANLI oyun ekranı için +7px PAY var ve bu ölçülerek eklendi**
 * (22 Eylül 2026): yukarıdaki 301 YEREL oyun ekranında ölçüldü, ama
 * `OnlineGameScreen` aynı `Board`u kendi kabuğuyla kullanıyor ve başlığı
 * daha uzun — kullanıcının ekran görüntüsünde (iPhone yatay, 844×390 CSS px)
 * kartın üstü **63px**, aynı viewport'ta yerel ekranda **57px**. Fark 6px,
 * pay 7px.
 *
 * ⚠ Canlı ekranın kromunun TAMAMI ölçülemedi: iki gerçek oturum + gerçek
 * Supabase gerektiriyor, yani otomatik testle kapatılamaz (bkz. `TESTING.md`
 * — Canlı oyun elle koşulan listede). Ölçülen tek fark başlık; alt şeritte
 * de bir fark çıkarsa bu pay yetmez ve `TESTING.md`deki kontrol onu
 * yakalamalı.
 *
 * Değiştirirsen `tests/board-fit.spec.ts` düşer — o test bu sayının hâlâ
 * doğru olduğunu gerçek layout'ta ölçüyor.
 */
export const BOARD_CHROME_PX = 308;

/** Tahta kartının bugünkü üst sınırı (`Board.tsx`teki `max-w-[680px]`). */
export const BOARD_MAX_PX = 680;

/**
 * Kartın inebileceği EN KÜÇÜK boy.
 *
 * ⚠ Taban olmasaydı telefon YATAYDA tahta 56–111px'e inerdi (ölçüldü: iPhone
 * SE 56 · iPhone 15 74 · 15 Pro Max 111) — yani 13 hücreye 4–9px, taşın harfi
 * bile çizilmez. Orada hiçbir sınır değeri oyunu oynanabilir yapmaz: krom tek
 * başına 301px ve viewport 375–430. Doğru davranış tahtayı yok etmek değil,
 * makul bir tabanda durup `LandscapeBlock`un TAM EKRAN "dikeye çevirin"
 * bloğunu göstermek — telefon yatay zaten baştan beri önerilmeyen mod.
 *
 * ⚠ 22 Eylül 2026'dan beri taban zaten GÖRÜNMEZ: o boyda blok devrede
 * olduğundan tahta hiç çizilmiyor. Taban yine de duruyor çünkü blokla tabanı
 * AYNI eşik yönetiyor (`BOTTOM_STRIP_MIN_HEIGHT_PX`); biri gevşerse öteki
 * tek başına anlamlı kalmalı.
 */
export const BOARD_MIN_PX = 324;

/**
 * Tahta kartının `max-width`i — CSS ifadesi olarak (`dvh` çalışma anında
 * çözülsün diye string döner, sayı DEĞİL).
 *
 * `min(680px, max(324px, 100dvh - 301px))`
 *
 * ⚠ YALNIZCA OYUN EKRANLARINDA (`Board`un `fitHeight` prop'u, varsayılan
 * `true`). Çıkarılan 308px tahtanın ALTINDAKİ şeridin yüksekliği; o şeridin
 * olmadığı yerlerde bütçenin karşılığı yok ve zarar veriyor — karşılama
 * katmanının vitrin tahtası 23 Eylül 2026'da iPad Safari yatayda (sayfa
 * ~619px) tabana, 324px'e indi. Vaka ve ölçüm:
 * `docs/decisions/landing-page.md` → "Vitrin tahtası".
 */
export function boardMaxWidthCss(): string {
  return `min(${BOARD_MAX_PX}px, max(${BOARD_MIN_PX}px, calc(100dvh - ${BOARD_CHROME_PX}px)))`;
}

/**
 * Alt şeridin (raf + butonlar) ekrana sığması için gereken EN KÜÇÜK viewport
 * yüksekliği — yani tahta tabanına inmiş hâliyle sütunun tamamı.
 *
 * `LandscapeBlock`un kapısı buna bağlı ve kuralın kendisi 22 Eylül 2026'da
 * `(orientation: landscape)`ten BURAYA taşındı. Eski kural açık bir
 * katlanabilirde de tetikleniyordu ve orada "dikeye dön" YANLIŞ tavsiyeydi:
 * açık Fold'da yer VAR (yatayda tahtaya 443px kalıyor, dikey iPhone'un
 * 369px'inden fazla).
 *
 * ⚠ Yükseklik ölçütü, bloğun SERT olabilmesinin tek sebebi: eski sert blok
 * (`#landscape-block`) iPad'de trackpad varken yanlış tetiklendiği için
 * kaldırılmıştı. ⚠ "iPad yatayda 820px boy var, yani hiç bloklanmaz"
 * varsayımı YANLIŞ çıktı (23 Eylül 2026): Safari'nin çubukları + mağaza bandı
 * sayfayı ~619px'e indiriyor. Yükseklik tek başına yetmiyor; blok artık
 * ayrıca TELEFON şartı arıyor (`LandscapeBlock` → `PHONE_MAX_SHORT_SIDE_PX`).
 *
 * ⚠ TEK KAYNAK: hem banner'ın `max-height` sorgusu hem `board-fit.spec.ts`
 * bu sayıdan türer. İkisinde ayrı ayrı toplanırsa biri sessizce bayatlar.
 */
export const BOTTOM_STRIP_MIN_HEIGHT_PX = BOARD_MIN_PX + BOARD_CHROME_PX;
