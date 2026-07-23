import { chromium } from 'playwright';
import sharp from 'sharp';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Standalone "kelimeki" wordmark logo — vector source of truth for
// logo.svg/.png/.jpg. Mirrors the in-app header logo exactly
// (GameHeader.tsx: Caveat Bold, #2563EB, S-curve underline swash),
// just at export resolution instead of the header's 28px.

const fontPath = join(__dirname, '../node_modules/@fontsource/caveat/files/caveat-latin-700-normal.woff2');
const fontB64 = readFileSync(fontPath).toString('base64');
const fontDataUri = `data:font/woff2;base64,${fontB64}`;

const LOGO_COLOR = '#2563EB';
const FONT_SIZE = 280;
const LETTER_SPACING = 30;
const TEXT_Y = 300;
const CANVAS_WIDTH = 1400;
const CANVAS_HEIGHT = 400;
const UNDERLINE_Y = 330;
const UNDERLINE_WIDTH = 640;
const UNDERLINE_HEIGHT = 60;
const UNDERLINE_PATH = 'M20 30 Q160 10 320 30 Q480 50 620 30';
const UNDERLINE_STROKE_WIDTH = 20;

const logoSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${CANVAS_WIDTH} ${CANVAS_HEIGHT}">
  <defs>
    <style>
      @font-face {
        font-family: 'Caveat';
        font-style: normal;
        font-weight: 700;
        src: url('${fontDataUri}') format('woff2');
      }
    </style>
  </defs>
  <text
    x="${CANVAS_WIDTH / 2}" y="${TEXT_Y}"
    font-family="Caveat, cursive"
    font-size="${FONT_SIZE}"
    font-weight="700"
    letter-spacing="${LETTER_SPACING}"
    fill="${LOGO_COLOR}"
    text-anchor="middle">kelimeki</text>
  <path
    d="${UNDERLINE_PATH}"
    transform="translate(${(CANVAS_WIDTH - UNDERLINE_WIDTH) / 2}, ${UNDERLINE_Y})"
    stroke="${LOGO_COLOR}"
    stroke-width="${UNDERLINE_STROKE_WIDTH}"
    stroke-linecap="round"
    fill="none"/>
</svg>`;

writeFileSync(join(__dirname, '../public/logo.svg'), logoSvg);
console.log('✓ logo.svg (vector, embedded font)');

const RENDER_SCALE = 2;
const html = `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"/><style>* { margin:0; padding:0; } body { width:${CANVAS_WIDTH}px; height:${CANVAS_HEIGHT}px; } svg { width:${CANVAS_WIDTH}px; height:${CANVAS_HEIGHT}px; display:block; }</style></head>
<body>${logoSvg}</body>
</html>`;

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const context = await browser.newContext({
  viewport: { width: CANVAS_WIDTH, height: CANVAS_HEIGHT },
  deviceScaleFactor: RENDER_SCALE,
});
const page = await context.newPage();
await page.setContent(html, { waitUntil: 'networkidle' });
await page.waitForTimeout(200);
const screenshot = await page.screenshot({ type: 'png', omitBackground: true });
await browser.close();

const trimmed = await sharp(screenshot)
  .trim({ threshold: 10 })
  .png()
  .toBuffer();

const PADDING = 40;
const { width, height } = await sharp(trimmed).metadata();

// Materialize the padded PNG to real bytes first — chaining .flatten()
// straight off .extend() within one lazy pipeline silently no-ops (sharp
// still reports an alpha channel afterward), so read it back from a
// buffer to force it before flattening for the JPEG.
const paddedPng = await sharp(trimmed)
  .extend({
    top: PADDING, bottom: PADDING, left: PADDING, right: PADDING,
    background: { r: 0, g: 0, b: 0, alpha: 0 },
  })
  .png()
  .toBuffer();

writeFileSync(join(__dirname, '../public/logo.png'), paddedPng);
console.log(`✓ logo.png (transparent, ${width + PADDING * 2}×${height + PADDING * 2})`);

await sharp(paddedPng)
  .flatten({ background: '#ffffff' })
  .jpeg({ quality: 95 })
  .toFile(join(__dirname, '../public/logo.jpg'));
console.log(`✓ logo.jpg (white background, ${width + PADDING * 2}×${height + PADDING * 2})`);
