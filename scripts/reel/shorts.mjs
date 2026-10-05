// Kelimeki — Reels/Shorts/TikTok için üç kısa video (1080×1920, MP4, ses izi sessiz).
//
//   npm run build && node scripts/reel/shorts.mjs [1|2|3 ...]      (npm: generate-shorts)
//
// Video ÜRETİM UYGULAMASININ kendisi sürülerek çekilir (bkz. `build.mjs`: kare kare yakalama,
// sürükleme hedefi +30 px, iframe + kayıtlı oyun). Fark: uygulama bir iframe'in içinde,
// üstte ALTYAZI alanı var; sahneler `shorts-state.ts`te gerçek motordan ölçülüyor.
import { createReadStream, mkdirSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { stat } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import { build as esbuild } from 'esbuild';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const DIST = path.join(ROOT, 'dist');
const CACHE = path.join(ROOT, 'node_modules', '.cache', 'kelimeki');
const OUT_DIR = path.join(ROOT, 'marketing', 'shorts-2026-10');
const W = 540, H = 960, CAP_H = 108, FPS = 30, DRAG_LIFT = 30;
const SLOGAN = ["Kelimeki'ye gel,", 'kendin dene!'];
const ALT = "Link bio'da";

const MIME = { '.html':'text/html; charset=utf-8', '.css':'text/css', '.js':'text/javascript', '.woff2':'font/woff2',
  '.png':'image/png', '.svg':'image/svg+xml', '.json':'application/json', '.webmanifest':'application/manifest+json', '.ico':'image/x-icon' };

async function bundle(entry, out, extra = {}) {
  await esbuild({ entryPoints: [path.join(ROOT, 'scripts', 'reel', entry)], bundle: true, platform: 'node', format: 'esm',
    outfile: path.join(CACHE, out), logLevel: 'error', ...extra });
  return import(`file://${path.join(CACHE, out)}?t=${Date.now()}`);
}

let FRAMES, kareler, sayac;
async function kare(page, sure = 1 / FPS) {
  const dosya = path.join(FRAMES, `f${String(++sayac).padStart(4, '0')}.png`);
  await page.screenshot({ path: dosya });
  kareler.push({ dosya, sure });
}
const bekle = (page, sn) => kare(page, sn);
const cap = (page, html) => page.evaluate((h) => { document.getElementById('cap').innerHTML = '<span>' + h + '</span>'; }, html);
const pop = (page, html, sm = false) => page.evaluate(([h, s]) => {
  const p = document.getElementById('pop'); p.className = s ? 'sm' : ''; p.firstChild.innerHTML = h; p.style.display = 'flex';
}, [html, sm]);
const popKapat = (page) => page.evaluate(() => { document.getElementById('pop').style.display = 'none'; });
const uygulama = (page) => page.frames().find((f) => f !== page.mainFrame());

/** Rafın [harf] taşını bul (joker = ★). Tahtaya konan taş raftan düştüğü için ikinci çağrı sıradakini bulur. */
async function rafTasi(fr, harf) {
  return fr.evaluate((h) => {
    const kutu = document.querySelector('[data-rack]').lastElementChild;
    for (const el of kutu.children) {
      const t = (el.textContent ?? '').trim();
      const eslesir = h === '?' ? t.startsWith('★') || t.startsWith('?') : t.startsWith(h);
      if (eslesir) {
        const b = el.getBoundingClientRect();
        return { x: b.left + b.width / 2, y: b.top + b.height / 2 };
      }
    }
    return null;
  }, harf);
}
async function hucreMerkezi(fr, r, c) {
  return fr.evaluate(([rr, cc]) => {
    const b = document.querySelector(`[data-cell="${rr},${cc}"]`).getBoundingClientRect();
    return { x: b.left + b.width / 2, y: b.top + b.height / 2 };
  }, [r, c]);
}

/** Bir taşı rafından hücreye sürükler (kare kare). Joker ise açılan modalda harfi seçer. */
async function surukle(page, adim) {
  const fr = uygulama(page);
  const k = await rafTasi(fr, adim.rafHarfi);
  if (!k) throw new Error(`Rafta '${adim.rafHarfi}' yok`);
  const h = await hucreMerkezi(fr, adim.r, adim.c);
  const kaynak = { x: k.x, y: k.y + CAP_H };
  const hedef = { x: h.x, y: h.y + CAP_H + DRAG_LIFT };
  await page.mouse.move(kaynak.x, kaynak.y);
  await page.mouse.down();
  const ADIM = 7;
  for (let i = 1; i <= ADIM; i++) {
    await page.mouse.move(kaynak.x + ((hedef.x - kaynak.x) * i) / ADIM, kaynak.y + ((hedef.y - kaynak.y) * i) / ADIM);
    await kare(page);
  }
  await page.mouse.up();
  await kare(page, 0.1);
  if (adim.joker) {
    await fr.getByText('Joker Hangi Harf Olsun?').waitFor({ timeout: 5000 });
    await page.waitForTimeout(200);
    await kare(page, 0.9);
    await fr.evaluate((l) => {
      const hucre = [...document.querySelectorAll('[role=dialog] .grid > div')].find((c) => (c.textContent ?? '').trim().startsWith(l));
      if (!hucre) throw new Error(`Joker penceresinde '${l}' yok`);
      hucre.click();
    }, adim.joker);
    await page.waitForTimeout(250);
    await kare(page, 0.2);
  }
}
async function geriAl(page, adimlar) {
  const fr = uygulama(page);
  for (const a of adimlar) {
    const h = await hucreMerkezi(fr, a.r, a.c);
    await page.mouse.click(h.x, h.y + CAP_H);
    await page.waitForTimeout(120);
    await kare(page, 0.25);
  }
}
async function oyna(page, n = 4) {
  await uygulama(page).getByRole('button', { name: 'Oyna', exact: true }).first().click();
  for (let i = 0; i < n; i++) { await page.waitForTimeout(150); await kare(page, 0.16); }
}

// ── Senaryolar ────────────────────────────────────────────────────────────
async function video1(page, s) {
  const { hamle } = s.enYuksek;
  await cap(page, 'Bu rafla <b>en yüksek puanlı</b> hamle kaç puan?');
  await bekle(page, 1.6);
  for (const n of ['3', '2', '1']) { await pop(page, n); await bekle(page, 0.95); }
  await popKapat(page);
  await cap(page, `İşte cevap: <b>${hamle.kelime}</b>`);
  await kare(page, 0.4);
  for (const a of hamle.adimlar) await surukle(page, a);
  await bekle(page, 1.0);
  await cap(page, `<b>${hamle.kelime}</b> = <u>${hamle.brut} PUAN!</u>`);
  await bekle(page, 2.0);
  await cap(page, 'Merkez <b>×3</b> karesine yerleşti');
  await oyna(page, 4);
  await bekle(page, 1.2);
}
async function video2(page, s) {
  const { A, B } = s.vergi;
  await cap(page, 'Sen hangisini oynardın?');
  await bekle(page, 1.8);
  await cap(page, `<b>A:</b> ${A.kelime} · <u>${A.brut} puan</u>`);
  await bekle(page, 0.6);
  for (const a of A.adimlar) await surukle(page, a);
  await bekle(page, 1.4);
  await uygulama(page).getByRole('button', { name: 'Oyna', exact: true }).first().click();
  await page.waitForTimeout(300);
  await cap(page, `Ama <i>${A.rakipPayi} puan</i> rakibe vergi gidiyor!`);
  await bekle(page, 2.6);
  await uygulama(page).getByRole('button', { name: 'Vazgeç', exact: true }).click();
  await page.waitForTimeout(250);
  await geriAl(page, A.adimlar);
  await cap(page, `<b>B:</b> ${B.kelime} · <u>${B.brut} puan</u> · vergisiz`);
  await bekle(page, 0.8);
  for (const a of B.adimlar) await surukle(page, a);
  await bekle(page, 1.6);
  await cap(page, `A: sende +${A.net}, rakipte +${A.rakipPayi} → <i>fark +${A.net - A.rakipPayi}</i>`);
  await bekle(page, 2.4);
  await cap(page, `B: sende +${B.net}, rakipte 0 → <u>fark +${B.net}</u>`);
  await bekle(page, 2.4);
  await cap(page, 'Yüksek puan her zaman <b>kazandırmaz</b>');
  await bekle(page, 1.8);
}
async function video3(page, s) {
  const { hamle, bonus, onceki, sonuc } = s.cift;
  await cap(page, `<i>${onceki[1] - onceki[0]} puan geride!</i> Torba boş, elinde 2 joker ★★`);
  await bekle(page, 2.6);
  await cap(page, 'Son hamle: <b>iki jokerle</b> bitir');
  await bekle(page, 1.0);
  for (const a of hamle.adimlar) await surukle(page, a);
  await bekle(page, 1.2);
  await cap(page, `<b>${hamle.kelime}</b> + çift joker bitişi <u>+${bonus}</u>`);
  await bekle(page, 1.8);
  await oyna(page, 5);
  await page.waitForTimeout(600);
  await cap(page, `<u>${onceki[1] - onceki[0]} puan geriden</u> galibiyet! <b>${sonuc[0]}–${sonuc[1]}</b>`);
  await bekle(page, 3.2);
}

const VIDEOLAR = [
  { no: 1, ad: 'en-yuksek-puan', fn: video1, key: 'enYuksek' },
  { no: 2, ad: 'hangisini-oynardin', fn: video2, key: 'vergi' },
  { no: 3, ad: 'cift-yildiz-bitis', fn: video3, key: 'cift' },
];

async function main() {
  const secim = process.argv.slice(2).map(Number).filter(Boolean);
  const calisacak = VIDEOLAR.filter((v) => !secim.length || secim.includes(v.no));
  mkdirSync(CACHE, { recursive: true });
  const { senaryolar } = await bundle('shorts-state.ts', 'shorts-state.mjs');
  const S = await senaryolar();

  const cssFile = readdirSync(path.join(DIST, 'assets')).find((f) => f.startsWith('index-') && f.endsWith('.css'));
  if (!cssFile) throw new Error('dist/assets/index-*.css yok — önce `npm run build` koş.');
  const { renderSarmalHtml } = await bundle('shorts-kart.tsx', 'shorts-kart.mjs', {
    jsx: 'automatic', external: ['react', 'react-dom', 'react-dom/server'], loader: { '.css': 'empty' } });
  writeFileSync(path.join(DIST, 'shorts-kabuk.html'), renderSarmalHtml(`/assets/${cssFile}`, SLOGAN, ALT), 'utf8');

  const server = createServer(async (req, res) => {
    const rel = decodeURIComponent((req.url ?? '/').split('?')[0]);
    let f = path.join(DIST, rel === '/' ? 'index.html' : rel);
    try { if (!(await stat(f)).isFile()) throw new Error('dir'); } catch { f = path.join(DIST, 'index.html'); }
    res.writeHead(200, { 'content-type': MIME[path.extname(f)] ?? 'application/octet-stream' });
    createReadStream(f).pipe(res);
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  const port = server.address().port;
  const browser = await chromium.launch({ executablePath: process.env.CI ? undefined : '/opt/pw-browsers/chromium' });
  mkdirSync(OUT_DIR, { recursive: true });

  for (const v of calisacak) {
    FRAMES = path.join(CACHE, `shorts-frames-${v.no}`);
    rmSync(FRAMES, { recursive: true, force: true }); mkdirSync(FRAMES, { recursive: true });
    kareler = []; sayac = 0;
    const payload = JSON.stringify({ version: 1, state: S[v.key].durum, savedAt: Date.now() });
    const ctx = await browser.newContext({ viewport: { width: W, height: H }, deviceScaleFactor: 2, isMobile: false });
    await ctx.addInitScript(([p]) => {
      try {
        localStorage.setItem('kelimeki:seen-intro', '1');
        localStorage.setItem('kelimeki:seen-quickstart', '1');
        localStorage.setItem('kelimeki:game-state', p);
      } catch { /* sahne kurulamazsa betik aşağıda patlar */ }
    }, [payload]);
    const page = await ctx.newPage();
    await page.goto(`http://127.0.0.1:${port}/shorts-kabuk.html`, { waitUntil: 'networkidle' });
    await page.evaluate(() => document.fonts.ready);
    const fr = uygulama(page);
    const satir = fr.getByText(/senin hamlen bekleniyor|SIRA SENDE/i).first();
    await satir.waitFor({ timeout: 15000 });
    await satir.click();
    await fr.locator('[data-cell="0,0"]').waitFor({ timeout: 15000 });
    await page.waitForTimeout(500);

    await v.fn(page, S);

    // Kapanış kartı
    await page.evaluate(() => { document.getElementById('end').style.display = 'block'; });
    await page.waitForTimeout(300);
    await bekle(page, 2.8);
    await ctx.close();

    const liste = kareler.map((k) => `file '${k.dosya}'\nduration ${k.sure.toFixed(4)}`).join('\n');
    const listeDosya = path.join(FRAMES, 'liste.txt');
    writeFileSync(listeDosya, `${liste}\nfile '${kareler[kareler.length - 1].dosya}'\n`, 'utf8');
    const out = path.join(OUT_DIR, `video-${v.no}-${v.ad}.mp4`);
    execFileSync('ffmpeg', ['-y', '-f', 'concat', '-safe', '0', '-i', listeDosya,
      '-f', 'lavfi', '-i', 'anullsrc=channel_layout=stereo:sample_rate=44100',
      '-vf', `fps=${FPS},format=yuv420p`, '-map', '0:v', '-map', '1:a', '-shortest',
      '-c:v', 'libx264', '-preset', 'slow', '-crf', '19', '-c:a', 'aac', '-b:a', '96k', '-movflags', '+faststart', out],
      { stdio: ['ignore', 'ignore', 'pipe'] });
    const sure = kareler.reduce((a, k) => a + k.sure, 0);
    console.log(`✓ ${path.relative(ROOT, out)}  ${kareler.length} kare  ~${sure.toFixed(1)} sn`);
  }
  await browser.close();
  server.close();
}
main().catch((e) => { console.error(e); process.exit(1); });
