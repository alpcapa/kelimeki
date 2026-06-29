import sharp from 'sharp';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Embed Caveat Bold font as base64 so librsvg can render it
const fontPath = join(__dirname, '../node_modules/@fontsource/caveat/files/caveat-latin-700-normal.woff');
const fontB64 = readFileSync(fontPath).toString('base64');

function buildSvg(size) {
  // Scale all measurements relative to 512 base
  const s = size / 512;
  const fs = Math.round(360 * s);       // font-size
  const cy = Math.round(392 * s);       // baseline y of "h"
  // Curved line centred under "h", ~260px wide at 512
  const lw = Math.round(260 * s);
  const lx = Math.round((size - lw) / 2);
  const ly = Math.round(430 * s);       // y of curve midpoint
  const amp = Math.round(7 * s);        // curve amplitude
  const sw = Math.max(2, Math.round(5 * s)); // stroke-width

  // Scale the logo's exact S-curve path (viewBox 0 0 100 8) to lw wide,
  // with quarter-point control nodes matching the original design.
  const scaleX = lw / 92; // original spans x=4..96 → 92 units
  const x0  = lx + Math.round(0  * scaleX);   // start  (original x=4)
  const cp1 = lx + Math.round(21 * scaleX);   // ctrl1  (original x=25)
  const mid = lx + Math.round(46 * scaleX);   // mid    (original x=50)
  const cp2 = lx + Math.round(71 * scaleX);   // ctrl2  (original x=75)
  const x3  = lx + lw;                         // end    (original x=96)

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  <defs>
    <style>
      @font-face {
        font-family: 'Caveat';
        font-style: normal;
        font-weight: 700;
        src: url('data:font/woff;base64,${fontB64}') format('woff');
      }
    </style>
  </defs>
  <rect width="${size}" height="${size}" fill="#FFFFFF"/>
  <text
    x="${size / 2}"
    y="${cy}"
    font-family="Caveat, sans-serif"
    font-size="${fs}"
    font-weight="700"
    fill="#2563EB"
    text-anchor="middle"
    dominant-baseline="auto">h</text>
  <path
    d="M${x0} ${ly} Q${cp1} ${ly - amp} ${mid} ${ly} Q${cp2} ${ly + amp} ${x3} ${ly}"
    stroke="#2563EB"
    stroke-width="${sw}"
    stroke-linecap="round"
    fill="none"/>
</svg>`;
}

const targets = [
  { size: 512, name: 'icon-512.png' },
  { size: 192, name: 'icon-192.png' },
  { size: 180, name: 'apple-touch-icon.png' },
];

for (const { size, name } of targets) {
  const svg = Buffer.from(buildSvg(size));
  await sharp(svg).png().toFile(join(__dirname, '../public', name));
  console.log(`✓ ${name} (${size}×${size})`);
}
