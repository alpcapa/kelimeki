// Kelimeki — "Artık Google Play'de" lansman görselleri (Instagram / Facebook /
// LinkedIn). Apple'ın Marketing Tools'u App Store için bu seti HAZIR
// üretiyor; Google'ın Partner Marketing Hub'ında karşılığı YOK (26 Eylül
// 2026'da Tools sayfası okundu: yalnızca "Device art" + "Legal line"), bu
// yüzden set burada üretiliyor.
//
// Ölçüler CSS px, 2× çekilir: kare 540 → 1080, story 540×960 → 1080×1920,
// link kartı 600×314 → 1200×628.
//
// Rozet `public/google-play-badge.svg` — sitede kullanılan RESMÎ dosya;
// ÇİZİLMEZ, oranı/rengi değiştirilmez. Tahtalar üretimdeki
// `GameBoardPreview`, logo `LandingLogo` (ikinci bir çizim sessiz ayrışır).
// Tailwind SINIFI YOK — `scripts/` tailwind content'inde değil.
import { renderToStaticMarkup } from 'react-dom/server';
import { LandingLogo, LandingLogoDefs } from '../../src/landing/LandingLogo';
import { GameBoardPreview } from '../../src/components/GameBoardPreview';
import { DEMO_TILES_2, DEMO_TILES_4 } from '../../src/landing/demoBoard';

const BOARD_BASE_W = 680;
const MONO = '"Space Mono", monospace';
const SANS = '"Space Grotesk", sans-serif';
const ACCENT = '#2563EB';
/** Resmî rozetin viewBox oranı (238.96 × 70.87). */
const ROZET_ORAN = 238.96 / 70.87;

export type Duzen = 'kare' | 'story' | 'dikey' | 'yatay' | 'link';

/** Apple Marketing Tools'un beş boyu (2× çekilince): 1080² · 1080×1920 ·
 *  720×1280 · 1280×720 · 1200×628. */
export const OLCULER: Record<Duzen, { w: number; h: number }> = {
  kare: { w: 540, h: 540 },
  story: { w: 540, h: 960 },
  dikey: { w: 360, h: 640 },
  yatay: { w: 640, h: 360 },
  link: { w: 600, h: 314 },
};

/** Yan yana düzenler: solda metin, sağda 4 kişilik tahta TAMAMEN görünür
 *  (ilk taslakta kenardan taşıyordu — kullanıcı istemedi, 26 Eylül 2026). */
const YAN: Duzen[] = ['yatay', 'link'];

function Tahta({ tiles, sayi, olcek, stil }: {
  tiles: typeof DEMO_TILES_2; sayi: number; olcek: number; stil: React.CSSProperties;
}) {
  const kenar = BOARD_BASE_W * olcek;
  return (
    <div data-tahta="" style={{ position: 'absolute', width: kenar, height: kenar, overflow: 'hidden', ...stil }}>
      <div style={{ width: BOARD_BASE_W, transform: `scale(${olcek})`, transformOrigin: 'top left' }}>
        <GameBoardPreview
          snapshot={tiles}
          playerCount={sayi}
          compact={false}
          players={Array.from({ length: sayi }, (_, i) => ({ name: '', score: 0, is_ai: false, colorIndex: i }))}
        />
      </div>
    </div>
  );
}

/** Düzene göre tipografi/boyut tablosu — tek yerde, üç düzen yan yana. */
const OLCU = {
  kare: { ikon: 136, logo: 0, baslik: 46, alt: 20, rozet: 60, dip: 13, bosluk: 20 },
  story: { ikon: 168, logo: 0, baslik: 56, alt: 23, rozet: 68, dip: 14, bosluk: 26 },
  dikey: { ikon: 112, logo: 0, baslik: 37, alt: 16, rozet: 46, dip: 10, bosluk: 17 },
  yatay: { ikon: 0, logo: 46, baslik: 34, alt: 16, rozet: 50, dip: 11, bosluk: 14 },
  link: { ikon: 0, logo: 40, baslik: 33, alt: 14, rozet: 42, dip: 11, bosluk: 11 },
} as const;

function Gorsel({ duzen, ikonSrc, rozetSrc }: { duzen: Duzen; ikonSrc: string; rozetSrc: string }) {
  const { w, h } = OLCULER[duzen];
  const o = OLCU[duzen];
  const yan = YAN.includes(duzen);
  // Yan düzende tahta sağda, dört kenardan eşit payla tamamen kadrajda.
  const pay = Math.round(h * 0.06);
  const tahtaKenar = h - 2 * pay;
  const rozet = (
    <img src={rozetSrc} alt="Google Play'den alın" style={{ height: o.rozet, width: o.rozet * ROZET_ORAN, display: 'block' }} />
  );
  const baslik = (
    <p style={{ margin: 0, fontSize: o.baslik, lineHeight: 1.08, fontWeight: 700, letterSpacing: -0.8 }}>
      Artık{duzen === 'kare' ? ' ' : <br />}<span style={{ color: ACCENT }}>Google Play</span>'de
    </p>
  );
  const alt = (
    <p style={{ margin: 0, fontSize: o.alt, lineHeight: 1.3, fontWeight: 500, color: '#3A4652' }}>
      Kelime bul, bölgeni büyüt,{duzen === 'kare' ? ' ' : <br />}tahtayı ele geçir.
    </p>
  );
  const dip = (
    <span style={{ fontFamily: MONO, fontSize: o.dip, color: '#5A6673', letterSpacing: 0.3 }}>
      Ücretsiz · Reklamsız · İnternetsiz oynanır
    </span>
  );

  return (
    <div style={{ width: w, height: h, position: 'relative', overflow: 'hidden', background: '#FFFFFF', fontFamily: SANS, color: '#1B2430' }}>
      <LandingLogoDefs />

      {duzen === 'kare' && (<>
        <Tahta tiles={DEMO_TILES_2} sayi={2} olcek={0.62} stil={{ left: -150, top: -150, opacity: 0.35 }} />
        <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={0.62} stil={{ right: -200, bottom: -200, opacity: 0.35 }} />
      </>)}
      {duzen === 'story' && (<>
        <Tahta tiles={DEMO_TILES_2} sayi={2} olcek={0.78} stil={{ left: -160, top: -120, opacity: 0.35 }} />
        <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={0.78} stil={{ right: -160, bottom: -120, opacity: 0.35 }} />
      </>)}
      {duzen === 'dikey' && (<>
        <Tahta tiles={DEMO_TILES_2} sayi={2} olcek={0.52} stil={{ left: -110, top: -80, opacity: 0.35 }} />
        <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={0.52} stil={{ right: -150, bottom: -125, opacity: 0.35 }} />
      </>)}
      {yan && (
        <Tahta tiles={DEMO_TILES_4} sayi={4} olcek={tahtaKenar / BOARD_BASE_W} stil={{ right: pay, top: pay, opacity: 1 }} />
      )}

      {!yan && (
        <div style={{ position: 'absolute', inset: 0, background:
          `radial-gradient(ellipse ${w * 0.7}px ${h * 0.42}px at 50% 50%, rgba(255,255,255,0.98) 68%, rgba(255,255,255,0) 100%)` }} />
      )}

      {yan ? (
        <div style={{ position: 'absolute', left: pay * 1.6, top: 0, bottom: 0, width: w - tahtaKenar - pay * 3.2, display: 'flex', alignItems: 'center' }}>
          <div data-guvenli-kutu="" style={{ display: 'flex', flexDirection: 'column', gap: o.bosluk }}>
            <LandingLogo height={o.logo} />
            {baslik}
            {alt}
            {rozet}
          </div>
        </div>
      ) : (
        // Story'de Instagram üstte profil çubuğunu (~%14), altta yanıt kutusunu
        // (~%20) bindiriyor — içerik o bandın ortasına oturuyor.
        <div style={{ position: 'absolute', left: 0, right: 0, top: duzen === 'story' ? h * 0.14 : 0,
          bottom: duzen === 'story' ? h * 0.2 : 0, display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
          <div data-guvenli-kutu="" style={{ width: w * 0.82, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: o.bosluk }}>
            <img src={ikonSrc} alt="" style={{ width: o.ikon, height: o.ikon, borderRadius: o.ikon * 0.22,
              boxShadow: '0 6px 18px rgba(27,36,48,0.18)', display: 'block' }} />
            {/* İkon zaten "kelimeki" yazısını taşıyor — altına ikinci bir
                logo koymak tekrar olurdu (ilk taslakta görüldü). */}
            {baslik}
            {alt}
            <div style={{ height: o.bosluk * 0.3 }} />
            {rozet}
            {dip}
          </div>
        </div>
      )}
    </div>
  );
}

export function renderGorselHtml(duzen: Duzen, cssHref: string, ikonSrc: string, rozetSrc: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki Google Play ${duzen}</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<Gorsel duzen={duzen} ikonSrc={ikonSrc} rozetSrc={rozetSrc} />)}</body></html>`;
}
