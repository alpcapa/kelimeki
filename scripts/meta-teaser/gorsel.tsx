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
          <LandingLogo height={story ? 30 : 28} />
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
