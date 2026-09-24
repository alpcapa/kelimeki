import { BADGE_GAP_PX, BADGE_HEIGHT_PX, visibleStoreBadges } from '../utils/storeLinks';

/**
 * Mağaza rozeti satırı (ROADMAP #26) — DÖRT yerde: Setup'ın footer'ında
 * (hukuki linklerin üstünde), karşılama katmanının hem kahraman hem son çağrı
 * bölümünde (`src/landing/Landing.tsx`) ve **davet sayfasında, davet kartının
 * hemen ALTINDA** (`FriendInvitePage.tsx`, 19 Eylül 2026 — gerekçe orada).
 *
 * ⚠ Davet sayfasındaki yer footer DEĞİL ve bu bilinçli: footer'a konduğunda
 * ölçüldü, rozetin y'si 1153 px çıktı (390×844) — yani "scroll etmeyen
 * göremiyor" sorununun kendisi. Kart altına taşınınca 378'e indi.
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
 * YÜKSEKLİK (ikisi eşit) ve aradaki boşluk (yüksekliğin 1/4'ü).
 *
 * ⚠ **Hizalama YÜKSEKLİKTEN** (24 Eylül 2026, kullanıcı kararı: *"Aynı boy
 * olmaları gerekmiyor mu?"*). 15-24 Eylül arası GENİŞLİKTENDİ ve Play ~%12
 * daha yüksek duruyordu. Oranlar farklı (App Store 3.78:1, Play 3.37:1),
 * yani eşit yükseklikte Apple biraz daha GENİŞ — bu beklenen. Gerekçe ve
 * Google kuralının iki okuması `storeLinks.ts`'te.
 *
 * ⚠ **Yayında olmayan mağaza HİÇ çizilmez** (`visibleStoreBadges`). Kapı
 * hâlâ yerinde: 15-24 Eylül 2026 arası yalnız App Store yayındaydı ve
 * Setup'ta TEK rozet çıkıyordu; 24 Eylül'de Play'in URL'si doldu, ikisi
 * yan yana (App Store önce).
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
            // YÜKSEKLİK sabit (ikisi eşit), genişlik oranla. Apple'ın tek
            // boyut kuralı (≥40 px yükseklik) kapıda doğrulanıyor.
            style={{ height: BADGE_HEIGHT_PX, width: 'auto', display: 'block' }}
          />
        </a>
      ))}
    </div>
  );
}
