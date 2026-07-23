// Kelimeki — sosyal paylaşım önizleme görselini (public/og-image.png) üretir.
// Setup.tsx'teki wordmark/tagline ile aynı üslubu, Tile.tsx'e benzer taş
// görünümüyle birleştirip 1200×630 sabit boyutta (index.html og:image
// etiketleriyle eşleşen) tek bir PNG'e render eder.
import { chromium } from 'playwright';
import sharp from 'sharp';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

function fontDataUri(relPath) {
  const abs = join(__dirname, '../node_modules/@fontsource', relPath);
  return `data:font/woff2;base64,${readFileSync(abs).toString('base64')}`;
}

const caveat700 = fontDataUri('caveat/files/caveat-latin-700-normal.woff2');
const grotesk700 = fontDataUri('space-grotesk/files/space-grotesk-latin-700-normal.woff2');
const mono400 = fontDataUri('space-mono/files/space-mono-latin-400-normal.woff2');
const mono700 = fontDataUri('space-mono/files/space-mono-latin-700-normal.woff2');
const nunito800 = fontDataUri('nunito/files/nunito-latin-800-normal.woff2');
const nunito800ext = fontDataUri('nunito/files/nunito-latin-ext-800-normal.woff2');

// Oyun tahtasındaki 4 köşe rengi (src/game/constants.ts PLAYER_COLORS ile birebir).
const CORNERS = [
  { base: '#0891B2', zone: '#E7F6FA' },
  { base: '#DC2626', zone: '#FDEFEF' },
  { base: '#16A34A', zone: '#EDFAF1' },
  { base: '#7C3AED', zone: '#F3ECFE' },
];

// "kelimeki" harflerinin puanları (src/data/tiles.ts Türkçe dağılımıyla aynı).
const TILES = [
  { l: 'K', p: 1 }, { l: 'E', p: 1 }, { l: 'L', p: 1 }, { l: 'İ', p: 1 },
  { l: 'M', p: 2 }, { l: 'E', p: 1 }, { l: 'K', p: 1 }, { l: 'İ', p: 1 },
];

const W = 1200;
const H = 630;
const SCALE = 2;

const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<style>
  @font-face { font-family: 'Caveat'; font-weight: 700; src: url('${caveat700}') format('woff2'); }
  @font-face { font-family: 'Space Grotesk'; font-weight: 700; src: url('${grotesk700}') format('woff2'); }
  @font-face { font-family: 'Space Mono'; font-weight: 400; src: url('${mono400}') format('woff2'); }
  @font-face { font-family: 'Space Mono'; font-weight: 700; src: url('${mono700}') format('woff2'); }
  @font-face {
    font-family: 'Nunito'; font-weight: 800; src: url('${nunito800}') format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+2000-206F;
  }
  @font-face {
    font-family: 'Nunito'; font-weight: 800; src: url('${nunito800ext}') format('woff2');
    unicode-range: U+0100-02BA, U+1E00-1E9F;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    width: ${W}px; height: ${H}px; position: relative; overflow: hidden;
    background:
      radial-gradient(circle, #E8EBEF 1.5px, transparent 1.5px);
    background-size: 28px 28px;
    background-color: #ffffff;
    display: flex; align-items: center; justify-content: center;
  }
  .corner {
    position: absolute; width: 84px; height: 84px; border-radius: 20px;
    border-width: 3.5px; border-style: solid;
  }
  .content { display: flex; flex-direction: column; align-items: center; gap: 8px; }
  .wordmark {
    font-family: 'Caveat', cursive; font-size: 108px; font-weight: 700;
    color: #2563EB; letter-spacing: 4px; line-height: 1; padding-left: 6px;
  }
  h1 {
    font-family: 'Space Grotesk', sans-serif; font-weight: 700; font-size: 34px;
    color: #1B2430; margin-top: 14px;
  }
  p {
    font-family: 'Space Mono', monospace; font-size: 17px; color: #8A93A2;
    margin-top: 10px; max-width: 620px; text-align: center; line-height: 1.5;
  }
  .tiles { display: flex; gap: 12px; margin-top: 28px; }
  .tile {
    position: relative; width: 62px; height: 62px; border-radius: 10px;
    background: #FFFFFF; border: 1.5px solid #C7D0DC;
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 2px 5px rgba(27,36,48,0.08);
  }
  .tile .letter {
    font-family: 'Nunito', sans-serif; font-weight: 800; font-size: 28px; color: #1B2430;
  }
  .tile .pts {
    position: absolute; top: 4px; right: 6px;
    font-family: 'Space Mono', monospace; font-weight: 700; font-size: 10px; color: #2563EB;
  }
</style>
</head>
<body>
  <div class="corner" style="top:34px; left:34px; background:${CORNERS[0].zone}; border-color:${CORNERS[0].base};"></div>
  <div class="corner" style="top:34px; right:34px; background:${CORNERS[1].zone}; border-color:${CORNERS[1].base};"></div>
  <div class="corner" style="bottom:34px; left:34px; background:${CORNERS[2].zone}; border-color:${CORNERS[2].base};"></div>
  <div class="corner" style="bottom:34px; right:34px; background:${CORNERS[3].zone}; border-color:${CORNERS[3].base};"></div>

  <div class="content">
    <div class="wordmark">kelimeki</div>
    <svg width="220" height="14" viewBox="0 0 220 14" fill="none">
      <path d="M8 7 Q55 1 110 7 Q165 13 212 7" stroke="#2563EB" stroke-width="3.5" stroke-linecap="round" fill="none"/>
    </svg>
    <h1>Stratejik Türkçe Kelime Oyunu</h1>
    <p>2 ya da 4 kişilik, köşelerden başlayan stratejik kelime oyunu</p>
    <div class="tiles">
      ${TILES.map((t) => `<div class="tile"><span class="letter">${t.l}</span><span class="pts">${t.p}</span></div>`).join('\n      ')}
    </div>
  </div>
</body>
</html>`;

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const context = await browser.newContext({ viewport: { width: W, height: H }, deviceScaleFactor: SCALE });
const page = await context.newPage();
await page.setContent(html, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(200);
const shot = await page.screenshot({ type: 'png' });
await browser.close();

await sharp(shot)
  .resize(W, H, { kernel: 'lanczos3' })
  .png()
  .toFile(join(__dirname, '../public/og-image.png'));

console.log('✓ og-image.png (1200×630)');
