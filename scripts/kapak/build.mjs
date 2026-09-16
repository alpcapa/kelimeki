// Kelimeki — Facebook sayfa kapağını üretir.
//
//   npm run build && node scripts/kapak/build.mjs
//
// ⚠ `npm run build` ÖNCE koşmuş olmalı (stiller dist CSS'inden gelir) ve
// sayfa `http://` üzerinden açılır — `file://` mutlak asset yollarını
// çözemediğinden tüm puntoları sessizce 16px okur.
import { createReadStream, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { build as esbuild } from 'esbuild';
import { chromium } from 'playwright';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const DIST = path.join(ROOT, 'dist');
// İki kapak, TEK boru hattı: `--linkedin` LinkedIn kişisel profil kapağını
// üretir (4:1), bayraksız hâli Facebook sayfa kapağını (2.63:1). Ayrı
// dosya olmalarının sebebi kırpma kurallarının farkı — `linkedin.tsx`'in
// başındaki nota bak.
const LINKEDIN = process.argv.includes('--linkedin');

const OUT = LINKEDIN
  ? path.join(ROOT, 'marketing', 'app-store', 'kelimeki-linkedin-kapak.png')
  : path.join(ROOT, 'marketing', 'sponsored-2026-08', 'kelimeki-fb-kapak.png');
const W = LINKEDIN ? 792 : 820;
const H = LINKEDIN ? 198 : 312;
/** Telefon kırpmasının gösterdiği orta şeridin genişliği (CSS px). */
const MOBIL_W = LINKEDIN ? 560 : 640;

const MIME = { '.html':'text/html; charset=utf-8', '.css':'text/css', '.js':'text/javascript',
  '.woff2':'font/woff2', '.png':'image/png', '.svg':'image/svg+xml', '.json':'application/json' };

async function main() {
  const cssFile = readdirSync(path.join(DIST, 'assets')).find(
    (f) => f.startsWith('index-') && f.endsWith('.css'),
  );
  if (!cssFile) throw new Error('dist/assets/index-*.css yok — önce `npm run build` koş.');

  const outMjs = path.join(ROOT, 'node_modules', '.cache', 'kelimeki', 'kapak.mjs');
  await esbuild({
    entryPoints: [path.join(ROOT, 'scripts', 'kapak', LINKEDIN ? 'linkedin.tsx' : 'kapak.tsx')],
    bundle: true, platform: 'node', format: 'esm', jsx: 'automatic',
    external: ['react', 'react-dom', 'react-dom/server'],
    loader: { '.css': 'empty' }, outfile: outMjs, logLevel: 'error',
  });
  const mod = await import(`file://${outMjs}?t=${Date.now()}`);
  const render = LINKEDIN ? mod.renderLinkedInKapakHtml : mod.renderKapakHtml;
  writeFileSync(path.join(DIST, 'kapak.html'), render(`/assets/${cssFile}`), 'utf8');

  const server = createServer(async (req, res) => {
    const f = path.join(DIST, decodeURIComponent((req.url ?? '/').split('?')[0]));
    try {
      const s = await stat(f);
      if (!s.isFile()) throw new Error('dir');
      res.writeHead(200, { 'content-type': MIME[path.extname(f)] ?? 'application/octet-stream' });
      createReadStream(f).pipe(res);
    } catch {
      res.writeHead(404).end('yok');
    }
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));

  const browser = await chromium.launch({
    executablePath: process.env.CI ? undefined : '/opt/pw-browsers/chromium',
  });
  const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 2 });
  await page.goto(`http://127.0.0.1:${server.address().port}/kapak.html`, { waitUntil: 'networkidle' });
  await page.evaluate(() => document.fonts.ready);

  mkdirSync(path.dirname(OUT), { recursive: true });
  await page.screenshot({ path: OUT });

  // Güvenli kutu gerçekten telefon kırpmasının içinde mi? (mobil ~640/820'lik
  // orta şerit) — ölçmeden "sığdı" denemez.
  const olcum = await page.evaluate(() => {
    const kutu = document.querySelector('[data-guvenli-kutu]');
    const b = kutu.getBoundingClientRect();
    return { sol: Math.round(b.left), sag: Math.round(b.right), ust: Math.round(b.top), alt: Math.round(b.bottom) };
  });
  const mobilSol = (W - MOBIL_W) / 2;
  const mobilSag = W - mobilSol;
  // LinkedIn'e özgü İKİNCİ ölçüm: profil fotoğrafı kapağın SOL ALT köşesini
  // örtüyor. Kaba ama muhafazakâr kutu — kapağın sol %22'si ve alt %45'i.
  const avatarSag = LINKEDIN ? W * 0.22 : 0;
  const avatarUst = LINKEDIN ? H * 0.55 : H;
  console.log(`  güvenli kutu: x ${olcum.sol}–${olcum.sag}, y ${olcum.ust}–${olcum.alt}`);
  console.log(`  telefon kırpması: x ${mobilSol}–${mobilSag}  →  ${olcum.sol >= mobilSol && olcum.sag <= mobilSag ? 'İÇERİDE ✓' : 'TAŞIYOR ✗'}`);
  if (LINKEDIN) {
    const cakisma = olcum.sol < avatarSag && olcum.alt > avatarUst;
    console.log(`  avatar bölgesi: x < ${Math.round(avatarSag)} ve y > ${Math.round(avatarUst)}  →  ${cakisma ? 'ÇAKIŞIYOR ✗' : 'UZAKTA ✓'}`);
  }

  await browser.close();
  server.close();
  console.log(`\n✓ ${path.relative(ROOT, OUT)}  ${W * 2}×${H * 2} px`);
}

main().catch((e) => { console.error(e); process.exit(1); });
