// Kelimeki — "Artık Google Play'de" lansman görsellerini üretir.
//
//   npm run build && npm run generate-play-lansman
//
// Çıktı: marketing/play-store/lansman/
//   kelimeki-google-play-kare-1080.png        — Instagram/Facebook feed (1:1)
//   kelimeki-google-play-story-1080x1920.png  — Instagram/Facebook story (9:16)
//   kelimeki-google-play-dikey-720x1280.png   — dikey banner (Apple setinin "Portrait")
//   kelimeki-google-play-yatay-1280x720.png   — yatay banner (X/YouTube/site kapağı)
//   kelimeki-google-play-link-1200x628.png    — link kartı (LinkedIn/Facebook)
//
// ⚠ `npm run build` ÖNCE koşmuş olmalı (stiller dist CSS'inden gelir) ve
// sayfa `http://` üzerinden açılır — `file://` mutlak asset yollarını
// çözemediğinden puntolar sessizce 16px okunur (play-store/build.mjs ile aynı).
import { createReadStream, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { build as esbuild } from 'esbuild';
import { chromium } from 'playwright';
import sharp from 'sharp';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const DIST = path.join(ROOT, 'dist');
const OUT_DIR = path.join(ROOT, 'marketing', 'play-store', 'lansman');
// Cihazdaki başlatıcı ikonla AYNI kaynak (play-store/build.mjs'teki gerekçe).
const ICON_SRC = path.join(ROOT, 'mobile', 'app', 'assets', 'icon', 'icon-source.png');
// Rozetlerin hangisinin ve hangi sırayla çıktığına `gorsel.tsx` karar verir
// (`visibleStoreBadges`); burası yalnızca `public/`teki iki dosyayı gömer.
const ROZET_DOSYALARI = ['/app-store-badge.svg', '/google-play-badge.svg'];

const DOSYA = {
  kare: 'kelimeki-google-play-kare-1080.png',
  story: 'kelimeki-google-play-story-1080x1920.png',
  dikey: 'kelimeki-google-play-dikey-720x1280.png',
  yatay: 'kelimeki-google-play-yatay-1280x720.png',
  link: 'kelimeki-google-play-link-1200x628.png',
};

const MIME = { '.html':'text/html; charset=utf-8', '.css':'text/css', '.js':'text/javascript',
  '.woff2':'font/woff2', '.png':'image/png', '.svg':'image/svg+xml', '.json':'application/json' };

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  const cssFile = readdirSync(path.join(DIST, 'assets')).find((f) => f.startsWith('index-') && f.endsWith('.css'));
  if (!cssFile) throw new Error('dist/assets/index-*.css yok — önce `npm run build` koş.');

  const outMjs = path.join(ROOT, 'node_modules', '.cache', 'kelimeki', 'play-lansman.mjs');
  await esbuild({
    entryPoints: [path.join(ROOT, 'scripts', 'play-lansman', 'gorsel.tsx')],
    bundle: true, platform: 'node', format: 'esm', jsx: 'automatic',
    external: ['react', 'react-dom', 'react-dom/server'],
    loader: { '.css': 'empty' }, outfile: outMjs, logLevel: 'error',
  });
  const { renderGorselHtml, OLCULER } = await import(`file://${outMjs}?t=${Date.now()}`);

  const ikon = `data:image/png;base64,${(await sharp(ICON_SRC).resize(512, 512).png().toBuffer()).toString('base64')}`;
  const rozet = Object.fromEntries(ROZET_DOSYALARI.map((a) => [a,
    `data:image/svg+xml;base64,${readFileSync(path.join(ROOT, 'public', a)).toString('base64')}`]));

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
  for (const duzen of Object.keys(DOSYA)) {
    const { w, h } = OLCULER[duzen];
    const htmlAd = `play-lansman-${duzen}.html`;
    writeFileSync(path.join(DIST, htmlAd), renderGorselHtml(duzen, `/assets/${cssFile}`, ikon, rozet), 'utf8');
    const page = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 2 });
    await page.goto(`http://127.0.0.1:${server.address().port}/${htmlAd}`, { waitUntil: 'networkidle' });
    await page.evaluate(() => document.fonts.ready);
    const olcum = await page.evaluate(() => {
      const b = document.querySelector('[data-guvenli-kutu]').getBoundingClientRect();
      const de = document.documentElement;
      return { sol: Math.round(b.left), sag: Math.round(b.right), ust: Math.round(b.top), alt: Math.round(b.bottom),
        tasmaX: de.scrollWidth - de.clientWidth, tasmaY: de.scrollHeight - de.clientHeight,
        // Kutunun içindeki en geniş öğe (tahtaya binen metin kutuyu değil öğeyi taşırır).
        rozetler: [...document.querySelectorAll('[data-rozetler] img')].map((e) => {
          const r = e.getBoundingClientRect();
          return { sol: Math.round(r.left), sag: Math.round(r.right), h: Math.round(r.height) };
        }),
        icSag: Math.round(Math.max(...[...document.querySelectorAll('[data-guvenli-kutu] > *')].map((e) => e.getBoundingClientRect().right))),
        tahtalar: [...document.querySelectorAll('[data-tahta] .grid, [data-tahta] > div > *')].slice(0, 1).map((e) => {
          const r = e.getBoundingClientRect();
          return { sol: Math.round(r.left), sag: Math.round(r.right), ust: Math.round(r.top), alt: Math.round(r.bottom) };
        }) };
    });
    // Story: Instagram üstte profil/ilerleme çubuğunu, altta yanıt kutusunu
    // bindiriyor — içerik dikeyde ortadaki güvenli bantta kalmalı (~%14 / %20).
    const payUst = duzen === 'story' ? h * 0.14 : 16;
    const payAlt = duzen === 'story' ? h * 0.2 : 16;
    console.log(`  ${duzen}: kutu x ${olcum.sol}–${olcum.sag}, y ${olcum.ust}–${olcum.alt} (kadraj ${w}×${h})`);
    if (olcum.tasmaX || olcum.tasmaY) hatalar.push(`${duzen}: sayfa taşıyor`);
    // İki rozet (App Store + Google Play) kadrajın içinde ve eşit yükseklikte.
    const rz = olcum.rozetler;
    console.log(`    rozetler: ${rz.map((r) => `x ${r.sol}–${r.sag} h ${r.h}`).join(' · ')}`);
    if (rz.length !== 2) hatalar.push(`${duzen}: ${rz.length} rozet (2 bekleniyordu)`);
    if (rz.some((r) => r.sol < 16 || r.sag > w - 16)) hatalar.push(`${duzen}: rozet kadrajdan taşıyor`);
    if (new Set(rz.map((r) => r.h)).size > 1) hatalar.push(`${duzen}: rozetler eşit yükseklikte değil`);
    // Yan düzenlerde tahta TAMAMEN kadrajda olmalı ve metin tahtaya binmemeli.
    if (['yatay', 'link'].includes(duzen)) {
      const t = olcum.tahtalar[0];
      console.log(`    tahta x ${t.sol}–${t.sag}, y ${t.ust}–${t.alt}; metin sağ kenarı ${olcum.icSag}`);
      if (t.sol < 0 || t.ust < 0 || t.sag > w || t.alt > h) hatalar.push(`${duzen}: tahta kadrajdan taşıyor`);
      if (olcum.icSag > t.sol - 8) hatalar.push(`${duzen}: metin tahtaya biniyor`);
    }
    if (olcum.sol < 16 || olcum.sag > w - 16 || olcum.ust < payUst || olcum.alt > h - payAlt) {
      hatalar.push(`${duzen}: içerik güvenli alanın dışında`);
    }
    const png = await page.screenshot();
    await page.close();
    if (!hatalar.length) {
      const out = path.join(OUT_DIR, DOSYA[duzen]);
      await sharp(png).flatten({ background: '#ffffff' }).png({ compressionLevel: 9 }).toFile(out);
      const m = await sharp(out).metadata();
      console.log(`✓ ${path.relative(ROOT, out)}  ${m.width}×${m.height}`);
    }
  }
  await browser.close();
  server.close();
  if (hatalar.length) { console.error('✗ ' + hatalar.join('; ')); process.exit(1); }
}

main().catch((e) => { console.error(e); process.exit(1); });
