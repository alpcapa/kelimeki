// Kelimeki — Meta "teaser" kampanyası, Aşama 1 (kanca testi) görselleri.
// Karar kaydı: marketing/meta-reklam/kampanya-teaser-ekim-2026.md
//
// Aşama 1'de YALNIZCA metin değişir: aynı sade tipografi düzeni, üç kanca.
// Tahta/rozet/ikon YOK — önceki `kare` reklamı (29 Eylül) kalabalık ve
// logosu büyük olduğu için mağazaya gönderemedi; burada tek cümle + küçük
// logo. Reklamın "İndir" düğmesi mağaza işini yapıyor.
//
// Ölçüler CSS px, 2× çekilir: feed 540×675 → 1080×1350 (4:5), story
// 540×960 → 1080×1920 (9:16). Tailwind SINIFI YOK (scripts/ content'te değil).
import { renderToStaticMarkup } from 'react-dom/server';
import { LandingLogo, LandingLogoDefs } from '../../src/landing/LandingLogo';
import { GameBoardPreview } from '../../src/components/GameBoardPreview';
import { DEMO_TILES_4 } from '../../src/landing/demoBoard';
import { BolgeKesiti } from '../../src/landing/BolgeKesiti';

const SANS = '"Space Grotesk", sans-serif';
const ACCENT = '#2563EB';
const BOARD_BASE_W = 680;

export type Duzen = 'feed' | 'story';
export type Kanca = 'h1' | 'h2' | 'h3';

export const OLCULER: Record<Duzen, { w: number; h: number }> = {
  feed: { w: 540, h: 675 },
  story: { w: 540, h: 960 },
};

/** Metinler kullanıcının onayladığı üç kanca (7 Ekim 2026). `vurgu` mavi çizilir. */
const KANCALAR: Record<Kanca, { onu: string; vurgu: string }> = {
  h1: { onu: 'Bu alıştığınız kelime oyunlarından ', vurgu: 'değil.' },
  h2: { onu: 'Klasik kelime oyunlarından ', vurgu: 'sıkıldınız mı?' },
  h3: { onu: 'Değişik bir kelime oyunu arıyorsanız ', vurgu: "Kelimeki'ye gelin." },
};

/** Sağ alta TAŞAN dolu tahta (4 kişilik demo, üretimdeki `GameBoardPreview`).
 *  Metin sol/üstte kalır; tahta kadrajdan taşar, yani kesit görünür. */
function AltTahta({ duzen }: { duzen: Duzen }) {
  const kenar = duzen === 'story' ? 400 : 360;
  const tasma = duzen === 'story' ? 110 : 100;
  return (
    <div data-tahta="" style={{ position: 'absolute', right: -tasma, bottom: -tasma, width: kenar, height: kenar,
      overflow: 'hidden', borderRadius: 16, boxShadow: '0 12px 36px rgba(27,36,48,0.18)' }}>
      <div style={{ width: BOARD_BASE_W, transform: `scale(${kenar / BOARD_BASE_W})`, transformOrigin: 'top left' }}>
        <GameBoardPreview snapshot={DEMO_TILES_4} playerCount={4} compact={false}
          players={Array.from({ length: 4 }, (_, i) => ({ name: '', score: 0, is_ai: false, colorIndex: i }))} />
      </div>
    </div>
  );
}

function Gorsel({ duzen, kanca, tahta }: { duzen: Duzen; kanca: Kanca; tahta: boolean }) {
  const { w, h } = OLCULER[duzen];
  const story = duzen === 'story';
  // Story'de Instagram üstte profil çubuğunu (~%14), altta yanıt kutusunu (~%20) bindirir.
  const ust = story ? h * 0.14 : 0;
  const alt = story ? h * 0.2 : 0;
  const k = KANCALAR[kanca];
  const punto = story ? 54 : 50;
  return (
    <div style={{ width: w, height: h, position: 'relative', overflow: 'hidden', background: '#FFFFFF', fontFamily: SANS, color: '#1B2430' }}>
      <LandingLogoDefs />
      {tahta && <AltTahta duzen={duzen} />}
      <div style={{ position: 'absolute', left: 0, right: 0, top: ust, bottom: alt, display: 'flex', alignItems: tahta ? 'flex-start' : 'center', justifyContent: 'center', paddingTop: tahta ? (story ? 36 : 56) : 0 }}>
        <div data-guvenli-kutu="" style={{ width: w * 0.8, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: story ? 40 : 34 }}>
          <div style={{ width: 56, height: 6, borderRadius: 3, background: ACCENT }} />
          <p style={{ margin: 0, fontSize: punto, lineHeight: 1.12, fontWeight: 700, letterSpacing: -1 }}>
            {k.onu}<span style={{ color: ACCENT }}>{k.vurgu}</span>
          </p>
          <div style={{ marginTop: story ? 28 : 24 }}><LandingLogo height={story ? 46 : 42} /></div>
        </div>
      </div>
    </div>
  );
}

export function renderGorselHtml(duzen: Duzen, kanca: Kanca, cssHref: string, tahta = false): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki teaser ${kanca} ${duzen}</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<Gorsel duzen={duzen} kanca={kanca} tahta={tahta} />)}</body></html>`;
}

// ─── Aşama 2 · teaser KARUSEL (kart 1 = h3 kancası, kalan kartlar kuralı kanıtlar) ───
// 1:1, 4 kart. Metinler Aşama 1'in onaylı reklam metniyle AYNI iddialar (rakip adı yok,
// üstünlük iddiası yok). Tahta/kesit üretimdeki bileşenlerden gelir (kural değişince
// görsel de değişir): `GameBoardPreview` ve karşılamanın `BolgeKesiti`si.
export const KARUSEL_KART_SAYISI = 4;
export const KARUSEL_OLCU = { w: 540, h: 540 };

function KartGovde({ kart }: { kart: number }) {
  const metin = (onu: string, vurgu: string, punto = 40) => (
    <p style={{ margin: 0, fontSize: punto, lineHeight: 1.14, fontWeight: 700, letterSpacing: -0.8 }}>
      {onu}<span style={{ color: ACCENT }}>{vurgu}</span>
    </p>
  );
  if (kart === 1) {
    return (<>
      <div style={{ width: 56, height: 6, borderRadius: 3, background: ACCENT }} />
      {metin(KANCALAR.h3.onu, KANCALAR.h3.vurgu, 52)}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%', marginTop: 12 }}>
        <LandingLogo height={42} />
        <span style={{ fontSize: 22, fontWeight: 700, color: ACCENT }}>Kaydır →</span>
      </div>
    </>);
  }
  if (kart === 2) {
    const kenar = 360;
    return (<>
      {metin('Kelime kur, ', 'bölgeni büyüt.')}
      <div style={{ alignSelf: 'center', width: kenar, height: kenar, overflow: 'hidden', borderRadius: 14, boxShadow: '0 10px 30px rgba(27,36,48,0.16)' }}>
        <div style={{ width: BOARD_BASE_W, transform: `scale(${kenar / BOARD_BASE_W})`, transformOrigin: 'top left' }}>
          <GameBoardPreview snapshot={DEMO_TILES_4} playerCount={4} compact={false}
            players={Array.from({ length: 4 }, (_, i) => ({ name: '', score: 0, is_ai: false, colorIndex: i }))} />
        </div>
      </div>
    </>);
  }
  if (kart === 3) {
    return (<>
      {metin('Rakibin bölgesine girersen ', 'vergisini ödersin.')}
      <div style={{ alignSelf: 'center', width: 340, transform: 'scale(1.22)', transformOrigin: 'top center', marginBottom: 62 }}>
        <BolgeKesiti />
      </div>
    </>);
  }
  return (<>
    <div style={{ width: 56, height: 6, borderRadius: 3, background: ACCENT }} />
    {metin('Yapay zekaya karşı ya da ', 'arkadaşlarınla.', 44)}
    <p style={{ margin: 0, fontSize: 28, lineHeight: 1.35, fontWeight: 500, color: '#475467' }}>
      Ücretsiz · reklamsız<br />Satın alma yok<br />İnternetsiz de oynanır
    </p>
    <div style={{ marginTop: 10 }}><LandingLogo height={42} /></div>
  </>);
}

export function renderKarusel(kart: number, cssHref: string): string {
  const { w, h } = KARUSEL_OLCU;
  const govde = (
    <div style={{ width: w, height: h, position: 'relative', overflow: 'hidden', background: '#FFFFFF', fontFamily: SANS, color: '#1B2430', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <LandingLogoDefs />
      <div data-guvenli-kutu="" style={{ width: w * 0.84, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 26 }}>
        <KartGovde kart={kart} />
      </div>
    </div>
  );
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki teaser karusel ${kart}</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(govde)}</body></html>`;
}
