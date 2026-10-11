// Kelimeki — kısa videoların kabuğu (540×960 CSS px → 1080×1920): üstte altyazı alanı, ortada
// uygulamanın KENDİSİ (iframe), altta adres şeridi, en sonda kapanış kartı (#end, gizli başlar).
// Tailwind sınıfı kullanılmıyor (scripts/ altı taranmıyor); renkler derlenmiş uygulama CSS'inden.
import { renderToStaticMarkup } from 'react-dom/server';
import { LandingLogo, LandingLogoDefs } from '../../src/landing/LandingLogo';
import { visibleStoreBadges } from '../../src/utils/storeLinks';

const MONO = '"Space Mono", monospace';
const SANS = '"Space Grotesk", sans-serif';
export const CAP_H = 108;
export const FOOT_H = 36;

function Kapanis({ slogan, alt }: { slogan: [string, string]; alt: string }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#fff', color: '#1B2430', fontFamily: SANS, display: 'flex',
      flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 28, padding: '0 40px', textAlign: 'center' }}>
      <LandingLogoDefs />
      <LandingLogo height={96} />
      <p style={{ margin: 0, fontSize: 44, lineHeight: 1.15, fontWeight: 700, letterSpacing: -1 }}>
        {slogan[0]}<br /><span style={{ color: '#2563EB' }}>{slogan[1]}</span>
      </p>
      <span style={{ fontFamily: MONO, fontSize: 22, fontWeight: 700, color: '#fff', background: '#2563EB', borderRadius: 999, padding: '10px 26px' }}>
        {alt}
      </span>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12 }}>
        {visibleStoreBadges().map((b) => (
          <img key={b.key} src={b.asset} alt={b.alt} style={{ height: 52, width: 'auto', display: 'block' }} />
        ))}
      </div>
      <span style={{ fontFamily: MONO, fontSize: 15, color: '#5A6673' }}>Ücretsiz · Reklamsız · Tarayıcıda da oynanır</span>
    </div>
  );
}

export function renderSarmalHtml(cssHref: string, slogan: [string, string], alt: string): string {
  const kapanis = renderToStaticMarkup(<Kapanis slogan={slogan} alt={alt} />);
  return `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><title>Kelimeki</title>
<link rel="stylesheet" href="${cssHref}">
<style>
html,body{margin:0;padding:0;background:#fff;overflow:hidden}
#k{position:relative;width:540px;height:960px;background:#fff;font-family:${SANS}}
#cap{position:absolute;left:0;top:0;width:540px;height:${CAP_H}px;box-sizing:border-box;padding:0 28px;display:flex;align-items:center;justify-content:center;text-align:center;
  font-size:31px;line-height:1.15;font-weight:700;letter-spacing:-.5px;color:#1B2430;border-bottom:2px solid #DCE2EA;background:#fff}
#cap b,#cap i,#cap u{white-space:nowrap}#cap b{color:#2563EB}#cap i{font-style:normal;color:#DC2626}#cap u{text-decoration:none;color:#16A34A}
#app{position:absolute;left:0;top:${CAP_H}px;width:540px;height:${960 - CAP_H - FOOT_H}px;border:0;background:#fff}
#foot{position:absolute;left:0;bottom:0;width:540px;height:${FOOT_H}px;border-top:2px solid #DCE2EA;display:flex;align-items:center;justify-content:center;
  font-family:${MONO};font-size:15px;font-weight:700;color:#2563EB;background:#fff}
#pop{position:absolute;left:0;right:0;top:${CAP_H + 300}px;display:none;align-items:center;justify-content:center;pointer-events:none}
#pop span{font-size:96px;font-weight:700;color:#fff;background:rgba(37,99,235,.92);border-radius:28px;padding:8px 34px;letter-spacing:-2px;box-shadow:0 14px 40px rgba(15,23,42,.45)}
#pop.sm span{font-size:34px;padding:12px 26px;border-radius:18px;letter-spacing:-.5px;line-height:1.2;text-align:center}
#end{position:absolute;inset:0;display:none}
</style></head><body>
<div id="k">
  <div id="cap"></div>
  <iframe id="app" src="/"></iframe>
  <div id="foot">kelimeki.com</div>
  <div id="pop"><span></span></div>
  <div id="end">${kapanis}</div>
</div></body></html>`;
}
