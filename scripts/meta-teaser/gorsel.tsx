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

const SANS = '"Space Grotesk", sans-serif';
const ACCENT = '#2563EB';

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

function Gorsel({ duzen, kanca }: { duzen: Duzen; kanca: Kanca }) {
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
      <div style={{ position: 'absolute', left: 0, right: 0, top: ust, bottom: alt, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
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

export function renderGorselHtml(duzen: Duzen, kanca: Kanca, cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki teaser ${kanca} ${duzen}</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<Gorsel duzen={duzen} kanca={kanca} />)}</body></html>`;
}
