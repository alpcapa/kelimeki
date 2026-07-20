// Kelimeki — scripts/proper-nouns.mjs listesini mevcut sözlüğe uygular.
// =====================================================================
// build-dictionary.mjs, GTS kaynağının (gts.json, ~100 MB) indirilmesini
// gerektirir ve repoda tutulmaz. proper-nouns.mjs listesini güncelleyip
// GTS'i yeniden indirmeden uygulamak için bu betik kullanılır: mevcut
// src/data/meanings.json'ı okur, proper-nouns.mjs'teki maddeleri (yalnızca
// henüz sözlükte olmayanları) ekler ve şu çıktıları yeniden üretir:
//
//   src/data/words.ts       — build-dictionary.mjs ile birebir aynı biçimde
//   src/data/meanings.json  —            "
//   supabase/migrations/<damga>_add_proper_nouns.sql
//                           — yalnızca bu çalıştırmada eklenen kelimeler için
//                             yeni bir migration (ana seed dosyası değişmez)
//
// Kullanım:
//   node scripts/augment-dictionary.mjs
//
// GTS kaynağıyla tam yeniden üretim yapıldığında (build-dictionary.mjs),
// proper-nouns.mjs zaten otomatik olarak birleştirilir; bu betik yalnızca
// GTS kaynağı olmadan proper-nouns.mjs güncellemelerini uygulamak içindir.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PROPER_NOUNS } from './proper-nouns.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');

const meaningsPath = path.join(ROOT, 'src/data/meanings.json');
const currentMeanings = JSON.parse(fs.readFileSync(meaningsPath, 'utf8'));

const dict = new Map(); // kelime -> { pos, meanings: string[] }
for (const [word, d] of Object.entries(currentMeanings)) {
  dict.set(word, { pos: d.pos ?? null, meanings: d.meanings });
}

const added = [];
for (const [word, meaning] of Object.entries(PROPER_NOUNS)) {
  if (!dict.has(word)) {
    dict.set(word, { pos: null, meanings: [meaning] });
    added.push(word);
  }
}

if (added.length === 0) {
  console.log('Eklenecek yeni kelime yok (proper-nouns.mjs zaten tamamı sözlükte).');
  process.exit(0);
}

// Türkçe sıralı kelime listesi.
const collator = new Intl.Collator('tr');
const words = [...dict.keys()].sort(collator.compare);

// ── Çıktı: words.ts (build-dictionary.mjs ile aynı biçim) ──────────────────
const PER_LINE = 16;
const wordLines = [];
for (let i = 0; i < words.length; i += PER_LINE) {
  wordLines.push(
    '  ' + words.slice(i, i + PER_LINE).map((w) => JSON.stringify(w)).join(', ') + ',',
  );
}
const wordsTs =
  '// Kelimeki — Türkçe kelime listesi\n' +
  '// TDK Güncel Türkçe Sözlük (12. baskı) kaynaklı oynanabilir maddeler.\n' +
  '// Kaynak: https://github.com/ogun/guncel-turkce-sozluk (MIT)\n' +
  '// ÜRETİLMİŞTİR — elle düzenlemeyin. Yeniden üretmek için:\n' +
  '//   GTS_JSON=./gts.json node scripts/build-dictionary.mjs\n' +
  '\n' +
  `export const WORD_LIST: readonly string[] = [\n${wordLines.join('\n')}\n];\n` +
  '\n' +
  'export const WORD_SET: ReadonlySet<string> = new Set(WORD_LIST);\n';
const wordsPath = path.join(ROOT, 'src/data/words.ts');
fs.writeFileSync(wordsPath, wordsTs);

// ── Çıktı: meanings.json ────────────────────────────────────────────────────
const meaningsOut = {};
for (const w of words) {
  const d = dict.get(w);
  meaningsOut[w] = { pos: d.pos, meanings: d.meanings };
}
fs.writeFileSync(meaningsPath, JSON.stringify(meaningsOut) + '\n');

// ── Çıktı: Supabase migration (yalnızca bu çalıştırmada eklenenler) ─────────
function sqlStr(s) {
  return "'" + String(s).replace(/'/g, "''") + "'";
}

function timestamp() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  return (
    `${d.getUTCFullYear()}${pad(d.getUTCMonth() + 1)}${pad(d.getUTCDate())}` +
    `${pad(d.getUTCHours())}${pad(d.getUTCMinutes())}${pad(d.getUTCSeconds())}`
  );
}

const addedSorted = added.slice().sort(collator.compare);
const BATCH = 500;
const out = [];
out.push('-- Kelimeki — dünya ülkeleri, başkentleri, büyük şehirleri ve diller');
out.push('-- Kaynak: scripts/proper-nouns.mjs (scripts/augment-dictionary.mjs ile üretildi).');
out.push(`-- ${addedSorted.length} yeni madde.`);
out.push('-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).');
out.push('');

for (let i = 0; i < addedSorted.length; i += BATCH) {
  const chunk = addedSorted.slice(i, i + BATCH);
  out.push('insert into public.words (word, len, points, pos, meanings) values');
  const rows = chunk.map((w) => {
    const d = dict.get(w);
    const meaningsJson = JSON.stringify(d.meanings);
    const posSql = d.pos ? sqlStr(d.pos) : 'null';
    return `  (${sqlStr(w)}, char_length(${sqlStr(w)}), public.kelimeki_points(${sqlStr(
      w,
    )}), ${posSql}, ${sqlStr(meaningsJson)}::jsonb)`;
  });
  out.push(rows.join(',\n'));
  out.push(
    'on conflict (word) do update set ' +
      'len = excluded.len, points = excluded.points, ' +
      'pos = excluded.pos, meanings = excluded.meanings;',
  );
  out.push('');
}

const migrationPath = path.join(
  ROOT,
  `supabase/migrations/${timestamp()}_add_proper_nouns.sql`,
);
fs.writeFileSync(migrationPath, out.join('\n'));

console.log(`Sözlükte zaten vardı (dokunulmadı) : ${Object.keys(PROPER_NOUNS).length - added.length}`);
console.log(`Yeni eklenen                       : ${added.length}`);
console.log(`Toplam oynanabilir kelime          : ${words.length}`);
console.log(`Yazıldı: ${path.relative(ROOT, wordsPath)}`);
console.log(`Yazıldı: ${path.relative(ROOT, meaningsPath)}`);
console.log(`Yazıldı: ${path.relative(ROOT, migrationPath)}`);
