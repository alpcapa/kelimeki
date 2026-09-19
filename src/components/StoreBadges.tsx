import { BADGE_GAP_PX, BADGE_WIDTH_PX, visibleStoreBadges } from '../utils/storeLinks';

/**
 * Mağaza rozeti satırı (ROADMAP #26) — DÖRT yerde: Setup'ın footer'ında
 * (hukuki linklerin üstünde), karşılama katmanının hem kahraman hem son çağrı
 * bölümünde (`src/landing/Landing.tsx`) ve **davet sayfasının footer'ında**
 * (`FriendInvitePage.tsx`, 19 Eylül 2026 — gerekçe orada).
 *
 * ⚠ **Yüzey eklerken bu sayıyı da güncelle.** Aşağıdaki "kaçak" dersi tam da
 * bu yüzden yazıldı ve ikinci kez yaşandı: davet sayfası, davetle gelen bir
 * oyuncunun gördüğü İLK ekran olmasına rağmen dört ay rozetsiz kaldı; kaçak
 * ancak gerçek bir kullanıcının (`platform='web'`, push token yok) izi
 * sürülünce görüldü. Kapı (`verify-store-badges`) yüzeyleri SAYMIYOR, yalnızca
 * rozet kurallarını doğruluyor — yani bu satır tek envanter.
 *
 * ⚠ **Katman 16 Eylül 2026'ya kadar rozeti HİÇ göstermiyordu** ve kaçak tam da
 * en görünür yüzeydeydi: `/` adresi Instagram'dan gelen ziyaretçinin gördüğü
 * ilk (çoğu zaman tek) sayfa, üstelik uygulamaya hiç girmeden okunabiliyor.
 * Ders: "rozeti ekledim" demeden önce rozetin hangi YÜZEYLERDE çizildiğini
 * say — bileşeni yazmak yüzeyleri kapatmıyor.
 *
 * Kurallar ve gerekçeleri `utils/storeLinks.ts`'te; burada yalnızca çizim.
 * Üç şey oradan gelir ve burada ELLE YAZILMAZ: sıra (App Store önce),
 * GENİŞLİK (ikisi eşit) ve aradaki boşluk (yüksek olanın 1/4'ü).
 *
 * ⚠ **Hizalama YÜKSEKLİKTEN değil GENİŞLİKTEN** (15 Eylül 2026). Eşit
 * yükseklik sezgisel olanıydı ama Google'ın "same size or larger" kuralını
 * çiğniyordu: Türkçe App Store rozeti 3.78:1, Play'inki 3.37:1 — eşit
 * yükseklikte Apple daha geniş kalıyor. Ölçüm ve tam gerekçe
 * `storeLinks.ts`'te. Sonuç: Play biraz daha yüksek durur, bu BEKLENEN.
 *
 * ⚠ **Yayında olmayan mağaza HİÇ çizilmez** (`visibleStoreBadges`). Kapı
 * hâlâ yerinde: 15 Eylül 2026 itibarıyla **yalnız App Store** yayında, yani
 * Setup'ta TEK rozet çıkıyor; Play'inki incelemesi bitip URL'si dolunca
 * kendiliğinden yanına gelir. İkisini birden beklemeye gerek yok.
 *
 * ⚠ **`<img>` kullanılıyor, SVG inline EDİLMİYOR** — gerekçe `storeLinks.ts`
 * (Illustrator'ın `.st0` sınıfları sayfa geneline sızıp iki rozetin rengini
 * birbirine karıştırır).
 */
export function StoreBadges() {
  const badges = visibleStoreBadges();
  if (badges.length === 0) return null;

  return (
    <div
      className="flex flex-wrap items-center justify-center"
      style={{ gap: BADGE_GAP_PX }}
    >
      {badges.map((badge) => (
        <a
          key={badge.key}
          href={badge.url}
          target="_blank"
          rel="noopener noreferrer"
          className="active:opacity-70 transition-opacity"
        >
          <img
            src={badge.asset}
            alt={badge.alt}
            // GENİŞLİK sabit, yükseklik oranla — eşit genişlik Google'ın
            // "same size or larger"ını tanım gereği sağlar; Apple'ın tek
            // boyut kuralı (≥40 px yükseklik) kapıda doğrulanıyor.
            style={{ width: BADGE_WIDTH_PX, height: 'auto', display: 'block' }}
          />
        </a>
      ))}
    </div>
  );
}
