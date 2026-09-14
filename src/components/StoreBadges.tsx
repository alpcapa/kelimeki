import { BADGE_GAP_PX, BADGE_HEIGHT_PX, visibleStoreBadges } from '../utils/storeLinks';

/**
 * Mağaza rozeti satırı (ROADMAP #26) — Setup'ın footer'ında, hukuki
 * linklerin ÜSTÜNDE.
 *
 * Kurallar ve gerekçeleri `utils/storeLinks.ts`'te; burada yalnızca çizim.
 * Üç şey oradan gelir ve burada ELLE YAZILMAZ: sıra (App Store önce),
 * yükseklik (≥40 px) ve aradaki boşluk (yüksekliğin 1/4'ü).
 *
 * ⚠ **Hiçbir mağaza yayında değilken `null` döner** — yani bugün Setup'ta
 * hiçbir görsel değişiklik yok. Bir mağaza açıldığında `storeLinks.ts`'teki
 * `null` gerçek adresle değişir ve o rozet tek başına çıkar; ikisini birden
 * beklemeye gerek yok.
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
            // Yükseklik SABİT, genişlik oranla — iki rozetin aynı yükseklikte
            // durması hem Apple'ın hem Google'ın kuralının karşılığı.
            style={{ height: BADGE_HEIGHT_PX, width: 'auto', display: 'block' }}
          />
        </a>
      ))}
    </div>
  );
}
