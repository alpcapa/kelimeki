// Kelimeki — kısa videoların müziği: SENTEZLENMİŞ, özgün bir döngü (telif/lisans sorunu YOK).
// C – Am – F – G, 112 BPM; pentatonik arpej (pluck) + bas + vuruş. İnternetten ses indirmiyoruz:
// hem ortam dışarıya kapalı hem de her platformun telif tarayıcısı için temiz kalması gerekiyor.
import { writeFileSync } from 'node:fs';

const SR = 44100, BPM = 112, GRID = 60 / BPM / 2; // 8'lik nota
const AKOR = [
  { kok: 130.81, notalar: [261.63, 329.63, 392.0, 523.25] }, // C
  { kok: 110.0,  notalar: [220.0, 261.63, 329.63, 440.0] },  // Am
  { kok: 87.31,  notalar: [174.61, 261.63, 349.23, 440.0] }, // F
  { kok: 98.0,   notalar: [196.0, 246.94, 392.0, 493.88] },  // G
];
const ARPEJ = [0, 1, 2, 3, 2, 1, 2, 1, 0, 1, 2, 3, 3, 2, 1, 2]; // bar başına 8 nota × 2 (iki bar akor)

export function muzikYaz(dosya, sn) {
  const n = Math.ceil(sn * SR);
  const L = new Float32Array(n), R = new Float32Array(n);
  let seed = 7;
  const rnd = () => ((seed = (seed * 1664525 + 1013904223) >>> 0) / 4294967296) * 2 - 1;
  const ekle = (t0, sure, f) => {
    const i0 = Math.floor(t0 * SR), len = Math.floor(sure * SR);
    for (let i = 0; i < len && i0 + i < n; i++) { const v = f(i / SR, i / len); L[i0 + i] += v; R[i0 + i] += v; }
  };
  const adim = Math.floor(sn / GRID);
  for (let k = 0; k < adim; k++) {
    const t = k * GRID, bar = Math.floor(k / 8), akor = AKOR[bar % 4], vurus = k % 8;
    // arpej (pluck): temel + 2. + 3. harmonik, hızlı sönüm
    const f = akor.notalar[ARPEJ[k % 16] % 4] * (Math.floor(k / 32) % 2 ? 2 : 1);
    ekle(t, 0.45, (s) => Math.exp(-s * 9) * 0.16 * (Math.sin(2 * Math.PI * f * s) + 0.35 * Math.sin(4 * Math.PI * f * s) + 0.12 * Math.sin(6 * Math.PI * f * s)));
    // bas: 1. ve 5. sekizlikte
    if (vurus === 0 || vurus === 4) ekle(t, 0.5, (s) => Math.exp(-s * 5) * 0.34 * Math.sin(2 * Math.PI * akor.kok * s));
    // vuruş (kick): 1-3. çeyrek
    if (vurus % 4 === 0) ekle(t, 0.22, (s) => Math.exp(-s * 20) * 0.5 * Math.sin(2 * Math.PI * (48 + 90 * Math.exp(-s * 40)) * s));
    // hi-hat: ara sekizlikler
    if (vurus % 2 === 1) ekle(t, 0.05, (s) => Math.exp(-s * 90) * 0.07 * rnd());
    // yumuşak pad: her akorda iki bar
    if (vurus === 0 && bar % 2 === 0) ekle(t, GRID * 16, (s, p) => 0.05 * Math.sin(Math.PI * Math.min(1, p * 8, (1 - p) * 4)) * akor.notalar.slice(0, 3).reduce((a, nf) => a + Math.sin(2 * Math.PI * nf * s), 0));
  }
  const buf = Buffer.alloc(n * 4);
  for (let i = 0; i < n; i++) {
    buf.writeInt16LE(Math.round(Math.tanh(L[i] * 1.4) * 0.8 * 32767), i * 4);
    buf.writeInt16LE(Math.round(Math.tanh(R[i] * 1.4) * 0.8 * 32767), i * 4 + 2);
  }
  const h = Buffer.alloc(44);
  h.write('RIFF', 0); h.writeUInt32LE(36 + buf.length, 4); h.write('WAVEfmt ', 8); h.writeUInt32LE(16, 16);
  h.writeUInt16LE(1, 20); h.writeUInt16LE(2, 22); h.writeUInt32LE(SR, 24); h.writeUInt32LE(SR * 4, 28);
  h.writeUInt16LE(4, 32); h.writeUInt16LE(16, 34); h.write('data', 36); h.writeUInt32LE(buf.length, 40);
  writeFileSync(dosya, Buffer.concat([h, buf]));
}
