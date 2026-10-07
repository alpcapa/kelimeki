// Kelimeki — Meta teaser kampanyası Aşama 1 görsellerini üretir.
//
//   npm run build && npm run generate-meta-teaser
//
// Çıktı: marketing/meta-reklam/teaser/kelimeki-teaser-{h1,h2,h3}-{feed-1080x1350,story-1080x1920}.png
//
// ⚠ `npm run build` ÖNCE koşmuş olmalı (stiller dist CSS'inden gelir) ve sayfa
// `http://` üzerinden açılır — `file://` mutlak asset yollarını çözemediğinden
// puntolar sessizce 16px okunur (play-lansman/build.mjs ile aynı).
import { createReadStream, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { build as esbuild } from 'esbuild';
import { chromium } from 'playwright';
import sharp from 'sharp';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const DIST = path.join(ROOT, 'dist');
const OUT_DIR = path.join(ROOT, 'marketing', 'meta-reklam', 'teaser');
const KANCALAR = ['h1', 'h2', 'h3'];
const DOSYA = { feed: 'feed-1080x1350', story: 'story-1080x1920' };

const MIME = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript',
  '.woff2': 'font/woff2', '.png': 'image/png', '.svg': 'image/svg+xml', '.json': 'application/json' };

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  const cssFile = readdirSync(path.join(DIST, 'assets')).find((f) => f.startsWith('index-') && f.endsWith('.css'));
  if (!cssFile) throw new Error('dist/assets/index-*.css yok — önce `npm run build` koş.');

  const outMjs = path.join(ROOT, 'node_modules', '.cache', 'kelimeki', 'meta-teaser.mjs');
  await esbuild({
    entryPoints: [path.join(ROOT, 'scripts', 'meta-teaser', 'gorsel.tsx')],
    bundle: true, platform: 'node', format: 'esm', jsx: 'automatic',
    external: ['react', 'react-dom', 'react-dom/server'],
    loader: { '.css': 'empty' }, outfile: outMjs, logLevel: 'error',
  });
  const { renderGorselHtml, OLCULER } = await import(`file://${outMjs}?t=${Date.now()}`);

  const server = createServer(async (req, res) => {
    const f = path.join(DIST, decodeURIComponent((req.url ?? '/').split('?')[0]));
    try {
      const s = await stat(f);
      if (!s.isFile()) throw new Error('dir');
      res.writeHead(200, { 'content-type': MIME[path.extname(f)] ?? 'application/octet-stream' });
      createReadStream(f).pipe(res);
    } catch { res.writeHead(404).end('yok'); }
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  const browser = await chromium.launch({ executablePath: process.env.CI ? undefined : '/opt/pw-browsers/chromium' });

  const hatalar = [];
  for (const kanca of KANCALAR) {
    for (const duzen of Object.keys(DOSYA)) {
      const { w, h } = OLCULER[duzen];
      const htmlAd = `meta-teaser-${kanca}-${duzen}.html`;
      writeFileSync(path.join(DIST, htmlAd), renderGorselHtml(duzen, kanca, `/assets/${cssFile}`), 'utf8');
      const page = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 2 });
      await page.goto(`http://127.0.0.1:${server.address().port}/${htmlAd}`, { waitUntil: 'networkidle' });
      await page.evaluate(() => document.fonts.ready);
      const olcum = await page.evaluate(() => {
        const b = document.querySelector('[data-guvenli-kutu]').getBoundingClientRect();
        const de = document.documentElement;
        return { sol: Math.round(b.left), sag: Math.round(b.right), ust: Math.round(b.top), alt: Math.round(b.bottom),
          tasmaX: de.scrollWidth - de.clientWidth, tasmaY: de.scrollHeight - de.clientHeight,
          // Başlık gerçekten Space Grotesk ile mi çizildi (font yüklenmezse sessizce sans-serif'e düşer).
          font: document.fonts.check('700 20px "Space Grotesk"') };
      });
      // Story: Instagram üstte ~%14, altta ~%20'yi bindiriyor — içerik ortadaki bantta kalmalı.
      const payUst = duzen === 'story' ? h * 0.14 : 16;
      const payAlt = duzen === 'story' ? h * 0.2 : 16;
      console.log(`  ${kanca}/${duzen}: kutu x ${olcum.sol}–${olcum.sag}, y ${olcum.ust}–${olcum.alt} (kadraj ${w}×${h})`);
      if (olcum.tasmaX || olcum.tasmaY) hatalar.push(`${kanca}/${duzen}: sayfa taşıyor`);
      if (!olcum.font) hatalar.push(`${kanca}/${duzen}: Space Grotesk yüklenmedi`);
      if (olcum.sol < 16 || olcum.sag > w - 16 || olcum.ust < payUst || olcum.alt > h - payAlt) {
        hatalar.push(`${kanca}/${duzen}: içerik güvenli alanın dışında`);
      }
      const png = await page.screenshot();
      await page.close();
      if (!hatalar.length) {
        const out = path.join(OUT_DIR, `kelimeki-teaser-${kanca}-${DOSYA[duzen]}.png`);
        await sharp(png).flatten({ background: '#ffffff' }).png({ compressionLevel: 9 }).toFile(out);
        const m = await sharp(out).metadata();
        console.log(`✓ ${path.relative(ROOT, out)}  ${m.width}×${m.height}`);
      }
    }
  }
  await browser.close();
  server.close();
  if (hatalar.length) { console.error('✗ ' + hatalar.join('; ')); process.exit(1); }
}

main().catch((e) => { console.error(e); process.exit(1); });
