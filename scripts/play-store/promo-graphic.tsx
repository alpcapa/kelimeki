// Kelimeki — Google Play "Promotional content" (LiveOps) kart görseli, 16:9.
// 960×540 CSS px, 2× çekilir → 1920×1080.
//
// Feature graphic'ten (feature-graphic.tsx) farkı: Play bu kartın BAŞLIĞINI
// ve açıklamasını görselin ÜSTÜNE, alt kısma bir karartma ile kendisi
// bindiriyor ve kart yüzeye göre farklı oranlarda kırpılıyor. Bu yüzden
// görselde METİN ve LOGO YOK — söylenecek her şey Console'daki başlık/
// açıklama alanlarında. Ana tahta üst-ortada, bindirmenin düştüğü alt bant
// bilerek boş dekor.
//
// Tahtalar üretimdeki `GameBoardPreview`→`Board` (ikinci bir tanıtım çizimi
// sessiz ayrışma üretir). Tailwind SINIFI YOK — bu dosya `scripts/` altında
// ve tailwind content'i burayı taramıyor, yalnızca inline `style` uygulanır.
import { renderToStaticMarkup } from 'react-dom/server';
import { GameBoardPreview } from '../../src/components/GameBoardPreview';
import { DEMO_TILES_2, DEMO_TILES_4 } from '../../src/landing/demoBoard';

export const PROMO_W = 960;
export const PROMO_H = 540;
/** `Board`un kendi `max-w` değeri — ölçek hesabının paydası. */
const BOARD_BASE_W = 680;

function Tahta({
  tiles, sayi, olcek, stil,
}: {
  tiles: typeof DEMO_TILES_2;
  sayi: number;
  olcek: number;
  stil: React.CSSProperties;
}) {
  const kenar = BOARD_BASE_W * olcek;
  return (
    <div style={{ position: 'absolute', width: kenar, height: kenar, overflow: 'hidden', ...stil }}>
      <div style={{ width: BOARD_BASE_W, transform: `scale(${olcek})`, transformOrigin: 'top left' }}>
        <GameBoardPreview
          snapshot={tiles}
          playerCount={sayi}
          compact={false}
          players={Array.from({ length: sayi }, (_, i) => ({
            name: '', score: 0, is_ai: false, colorIndex: i,
          }))}
        />
      </div>
    </div>
  );
}

function PromoGraphic() {
  const ANA = 0.66;
  const anaKenar = BOARD_BASE_W * ANA;
  return (
    <div
      style={{
        width: PROMO_W,
        height: PROMO_H,
        position: 'relative',
        overflow: 'hidden',
        background: 'linear-gradient(160deg, #F4F7FC 0%, #DCE6F5 100%)',
      }}
    >
      {/* Dekor: iki yanda kadrajdan taşan 4 kişilik tahtalar. */}
      <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={0.62} stil={{ left: -250, top: 40, opacity: 0.3 }} />
      <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={0.62} stil={{ right: -250, top: 40, opacity: 0.3 }} />

      {/* Ana tahta — tam opak, üst-orta. */}
      <div
        data-guvenli-kutu=""
        style={{
          position: 'absolute',
          left: (PROMO_W - anaKenar) / 2,
          top: 22,
          width: anaKenar,
          height: anaKenar,
          borderRadius: 14,
          boxShadow: '0 18px 48px rgba(27,36,48,0.22)',
        }}
      >
        <Tahta tiles={DEMO_TILES_2} sayi={2} olcek={ANA} stil={{ left: 0, top: 0, borderRadius: 14 }} />
      </div>
    </div>
  );
}

export function renderPromoGraphicHtml(cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki promotional content</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<PromoGraphic />)}</body></html>`;
}
