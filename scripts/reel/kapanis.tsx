// Kelimeki — reel'in kapanış karesi (540×960 CSS px, 2× ile 1080×1920).
// Poster setiyle aynı ilke: logo `LandingLogo`, renkler/gölge derlenmiş
// uygulama CSS'inden. Tailwind SINIFI KULLANILMIYOR (bu dosya `scripts/`
// altında, tailwind content'i burayı taramıyor) — tek istisna, `src/`te
// zaten geçtiği için derlenmiş CSS'te bulunan `btn-raised`.
import { renderToStaticMarkup } from 'react-dom/server';
import { LandingLogo, LandingLogoDefs } from '../../src/landing/LandingLogo';
import { visibleStoreBadges } from '../../src/utils/storeLinks';

const MONO = '"Space Mono", monospace';
const SANS = '"Space Grotesk", sans-serif';

/**
 * Mağaza rozetleri — 28 Eylül 2026 (Meta kampanyası, reklam iOS + Android'e
 * birlikte gidiyor). Sıra ve hangi rozetin çıktığı `visibleStoreBadges`ten
 * (App Store ÖNCE); dosyalar `public/`ten, `dist` köküne kopyalanmış hâliyle
 * aynı origin'den iniyor. EŞİT YÜKSEKLİK, aradaki boşluk yüksekliğin 1/4'ü
 * (`storeLinks.ts`teki kurallar).
 */
function Rozetler({ yukseklik }: { yukseklik: number }) {
  return (
    <div data-rozetler="" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: Math.round(yukseklik / 4) }}>
      {visibleStoreBadges().map((b) => (
        <img key={b.key} src={b.asset} alt={b.alt} style={{ height: yukseklik, width: 'auto', display: 'block' }} />
      ))}
    </div>
  );
}

function Kapanis() {
  return (
    <div
      style={{
        // Kaydın viewport'u değişebiliyor (bant hesabı yüzünden 832) — sabit
        // 960 yazmak kartı alttan kırpardı.
        width: '100vw',
        height: '100vh',
        boxSizing: 'border-box',
        background: '#FFFFFF',
        color: '#1B2430',
        fontFamily: SANS,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 26,
        padding: '0 44px',
        textAlign: 'center',
      }}
    >
      <LandingLogoDefs />
      <LandingLogo height={104} />
      <p style={{ margin: 0, fontSize: 30, lineHeight: 1.25, fontWeight: 700, letterSpacing: -0.5 }}>
        Kelime bul, bölgeni büyüt,
        <br />
        tahtayı ele geçir.
      </p>
      {/* 28 Eylül 2026: mavi `kelimeki.com` düğmesi kalktı; mağaza rozetleri
          alt bantta (`Bant`) HER karede duruyor, kapanışa ikinci bir rozet
          satırı koymak aynı karede iki kez gösterirdi (denendi). Eski dip
          satırı ("Kurulum yok") uygulama mağazalara çıkınca yanlış olmuştu. */}
      <span style={{ fontFamily: MONO, fontSize: 18, color: '#3A4652', lineHeight: 1.5 }}>
        App Store ve Google Play'de
      </span>
      <span style={{ fontFamily: MONO, fontSize: 15, color: '#5A6673' }}>
        Ücretsiz · Reklamsız · Tarayıcıda da oynanır
      </span>
    </div>
  );
}

/**
 * Alt bant — kaydın 9:16'ya doldurulurken altta kalan şeride oturur.
 * 28 Eylül 2026: logo + adres yerine İKİ ROZET + adres (Meta kampanyası;
 * videoyu sonuna kadar izlemeyen de mağazaları görsün).
 * Uygulama içeriği 540 px genişlikte 819 px sürüyor, kare ise 960; artan yeri
 * boş beyaz bırakmak yerine kalıcı bir adres şeridi yapıyoruz (reel'in amacı
 * trafik; izleyici videoyu sonuna kadar izlemese de adresi görüyor).
 */
function Bant() {
  return (
    <div
      style={{
        width: 540,
        height: 108,
        boxSizing: 'border-box',
        background: '#FFFFFF',
        borderTop: '2px solid #DCE2EA',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        fontFamily: SANS,
      }}
    >
      <Rozetler yukseklik={46} />
      <span style={{ fontFamily: MONO, fontSize: 15, fontWeight: 700, color: '#2563EB' }}>
        kelimeki.com
      </span>
    </div>
  );
}

export function renderBantHtml(cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<Bant />)}</body></html>`;
}

export function renderKapanisHtml(cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<Kapanis />)}</body></html>`;
}
