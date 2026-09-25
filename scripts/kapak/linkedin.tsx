// Kelimeki — LinkedIn KİŞİSEL profil kapağı (792×198 CSS px, 2× ile 1584×396).
//
// ⚠ FACEBOOK KAPAĞIYLA AYNI DOSYA DEĞİL, çünkü kırpma kuralları başka:
// LinkedIn kapağı 4:1 (FB'ninki 2.63:1) ve profil fotoğrafı kapağın SOL
// ALT köşesini örtüyor — FB'de de sol alt örtülüyor ama orada oran yüksek
// olduğu için metin rahatça ortalanabiliyordu. Burada yükseklik 198 px:
// metni dikeyde ortalarsan avatarın örttüğü banda giriyor.
//
// Üç kısıt birden:
//   1. Avatar SOL ALT'ı örter → okunacak hiçbir şey sol alt çeyrekte olmaz.
//   2. Telefonda kapak yanlardan kırpılır → güvenli kutu ortada ~440 px.
//   3. Ad kartı kapağın hemen ALTINDA başlar → alt kenara yapışma.
// Çözüm: güvenli kutu ORTADA ve dikeyde hafif YUKARIDA; dekor tahtalar
// iki yandan taşar, kırpılmaları bilgi kaybettirmez.
import { renderToStaticMarkup } from 'react-dom/server';
import { LandingLogo, LandingLogoDefs } from '../../src/landing/LandingLogo';
import { visibleStoreNamesTr } from '../../src/utils/storeLinks';
import { GameBoardPreview } from '../../src/components/GameBoardPreview';
import { DEMO_TILES_2, DEMO_TILES_4 } from '../../src/landing/demoBoard';

export const LINKEDIN_W = 792;
export const LINKEDIN_H = 198;

/** `Board`un kendi `max-w` değeri — ölçek hesabının paydası. */
const BOARD_BASE_W = 680;
const OLCEK = 0.5;
const TAHTA = BOARD_BASE_W * OLCEK;

const MONO = '"Space Mono", monospace';
const SANS = '"Space Grotesk", sans-serif';
const ACCENT = '#2563EB';

/**
 * Mağaza cümlesi KAPIDAN türer (`storeLinks.ts`) — elle yazılmaz.
 * 16 Eylül 2026'nın dersi: mağaza durumu değişince elle yazılmış metin
 * sessizce bayatlıyor. Play yayına girdiğinde bu kapak yeniden üretilirse
 * satır kendiliğinden "App Store ve Google Play'de" olur.
 */
const MAGAZA = visibleStoreNamesTr();

function Tahta({ tiles, sayi, stil }: { tiles: typeof DEMO_TILES_2; sayi: number; stil: React.CSSProperties }) {
  return (
    <div style={{ position: 'absolute', width: TAHTA, height: TAHTA, overflow: 'hidden', opacity: 0.38, ...stil }}>
      <div style={{ width: BOARD_BASE_W, transform: `scale(${OLCEK})`, transformOrigin: 'top left' }}>
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

export function LinkedInKapak() {
  return (
    <div
      style={{
        width: LINKEDIN_W,
        height: LINKEDIN_H,
        position: 'relative',
        overflow: 'hidden',
        background: '#FFFFFF',
        fontFamily: SANS,
        color: '#1B2430',
      }}
    >
      <LandingLogoDefs />

      {/* Dekor: iki tahta, iki kenardan taşıyor. Sol taş yukarı kaydırıldı —
          sol alt köşe avatarın altında kalıyor, oraya desen koymanın anlamı yok. */}
      <Tahta tiles={DEMO_TILES_2} sayi={2} stil={{ left: -72, top: -86 }} />
      <Tahta tiles={DEMO_TILES_4} sayi={4} stil={{ right: -72, top: -52 }} />

      {/* Metnin arkasına yumuşak beyaz perde — tahtalar okunurluğu bozmasın. */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'radial-gradient(ellipse 280px 130px at 50% 45%, rgba(255,255,255,0.98) 55%, rgba(255,255,255,0) 100%)',
        }}
      />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          // Dikeyde hafif yukarı: alt bant avatarın ve ad kartının bölgesi.
          paddingBottom: 26,
        }}
      >
        {/* Güvenli kutu: 440 px — telefonun dar kırpmasında da tamamen içeride. */}
        <div
          data-guvenli-kutu=""
          style={{ width: 440, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 9 }}
        >
          <LandingLogo height={44} />
          <p style={{ margin: 0, fontSize: 17, lineHeight: 1.25, fontWeight: 700, letterSpacing: -0.2 }}>
            Kelime bul, bölgeni büyüt, tahtayı ele geçir.
          </p>
          <span style={{ fontFamily: MONO, fontSize: 12, fontWeight: 700, color: ACCENT, letterSpacing: 0.5 }}>
            {MAGAZA ? `kelimeki.com · ${MAGAZA}` : 'kelimeki.com'}
          </span>
        </div>
      </div>
    </div>
  );
}

/* ─────────────────── LinkedIn ŞİRKET SAYFASI kapağı ─────────────────── */
//
// 1128×191 (≈5.9:1) — kişisel kapaktan bile alçak ve çok daha geniş, o
// yüzden dikey yığın yerine YATAY dizilim: solda marka, sağda cümle.
// Sayfa logosu kapağın SOL ALT köşesine oturuyor, bu yüzden içerik sağa
// kaydırıldı. 2× ile 2256×382 basılır (LinkedIn oranı koruyup küçültür,
// büyük dosya daha net görünür).
export const SAYFA_W = 1128;
export const SAYFA_H = 191;

export function LinkedInSayfaKapak() {
  return (
    <div
      style={{
        width: SAYFA_W,
        height: SAYFA_H,
        position: 'relative',
        overflow: 'hidden',
        background: '#FFFFFF',
        fontFamily: SANS,
        color: '#1B2430',
      }}
    >
      <LandingLogoDefs />

      <Tahta tiles={DEMO_TILES_2} sayi={2} stil={{ left: -104, top: -96 }} />
      <Tahta tiles={DEMO_TILES_4} sayi={4} stil={{ right: -104, top: -62 }} />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'radial-gradient(ellipse 340px 120px at 56% 50%, rgba(255,255,255,0.98) 55%, rgba(255,255,255,0) 100%)',
        }}
      />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          // Sayfa logosu sol alta oturuyor → içerik sağa kaydırıldı.
          paddingLeft: 150,
        }}
      >
        <div data-guvenli-kutu="" style={{ display: 'flex', alignItems: 'center', gap: 26 }}>
          <LandingLogo height={46} />
          <span style={{ width: 1, height: 52, background: '#D8DEE6' }} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
            <p style={{ margin: 0, fontSize: 19, lineHeight: 1.2, fontWeight: 700, letterSpacing: -0.2 }}>
              Kelime bul, bölgeni büyüt, tahtayı ele geçir.
            </p>
            <span style={{ fontFamily: MONO, fontSize: 12.5, fontWeight: 700, color: ACCENT, letterSpacing: 0.4 }}>
              {MAGAZA ? `kelimeki.com · ${MAGAZA}` : 'kelimeki.com'}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

export function renderLinkedInSayfaKapakHtml(cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki LinkedIn sayfa kapağı</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<LinkedInSayfaKapak />)}</body></html>`;
}

export function renderLinkedInKapakHtml(cssHref: string): string {
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki LinkedIn kapak</title>
<link rel="stylesheet" href="${cssHref}">
<style>html,body{margin:0;padding:0;background:#fff}</style>
</head><body>${renderToStaticMarkup(<LinkedInKapak />)}</body></html>`;
}
