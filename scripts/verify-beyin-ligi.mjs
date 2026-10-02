// Kelimeki — Beyin Ligi giriş eşiğinin SQL ↔ TS paritesi (2 Ekim 2026).
//
// Eşik ("hamle verisi olan en az N oyun") iki tarafta elle yazılı: sunucuda
// `beyin_ligi_siralama` view'ının `ohp_games >= N` koşulu, web'de
// `src/utils/beyinLigi.ts`in `BEYIN_LIGI_MIN_GAMES`ı. İstemci bu sayıyla
// "N oyun daha" kartını ve tanıtım metnini çiziyor — sunucu başka bir
// eşikle listeliyorsa kart yalan söyler (5 oyunu doldurmuş oyuncuya
// "listeye gir" der ama oyuncu listede yoktur). Derleyici ikisini göremez.
//
// Portun kopyası (`mobile/app/lib/src/util/beyin_ligi.dart`) varsa o da
// kilitlenir; port yarısı ayrı bir sürüm treni PR'ında geliyor.
//
// ⚠ Kapsam: "migration dosyası ↔ kaynak". Canlı veritabanı ↔ dosya yarısı
// migration disiplinine dayanıyor (verify-league-tiers ile aynı sınır).
//
// Koşum: npm run verify-beyin-ligi
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import path from 'node:path';

let failures = 0;
const check = (name, cond, detail = '') => {
  if (cond) console.log(`  ✓ ${name}`);
  else { failures++; console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`); }
};

// 1) View'ı tanımlayan EN YENİ migration (ada göre sıralama = uygulama sırası).
const DIR = 'supabase/migrations';
const tanimlayan = readdirSync(DIR)
  .filter((f) => f.endsWith('.sql'))
  .sort()
  .filter((f) =>
    /create (or replace )?view public\.beyin_ligi_siralama/.test(readFileSync(path.join(DIR, f), 'utf8')),
  );
check('view\'ı tanımlayan bir migration var', tanimlayan.length > 0);
const son = tanimlayan.at(-1);
let sqlN = null;
if (son) {
  const sql = readFileSync(path.join(DIR, son), 'utf8');
  const govde = sql.slice(sql.search(/create (or replace )?view public\.beyin_ligi_siralama/));
  const m = govde.match(/ohp_games\s*>=\s*(\d+)/);
  sqlN = m ? Number(m[1]) : null;
  check(`SQL eşiği okundu (${son})`, sqlN != null);
}

// 2) Web sabiti.
const ts = readFileSync('src/utils/beyinLigi.ts', 'utf8');
const tsM = ts.match(/export const BEYIN_LIGI_MIN_GAMES\s*=\s*(\d+)/);
const tsN = tsM ? Number(tsM[1]) : null;
check('web sabiti okundu (BEYIN_LIGI_MIN_GAMES)', tsN != null);
check(`SQL (${sqlN}) == web (${tsN})`, sqlN != null && sqlN === tsN);

// 3) Port sabiti (varsa).
const DART = 'mobile/app/lib/src/util/beyin_ligi.dart';
if (existsSync(DART)) {
  const dm = readFileSync(DART, 'utf8').match(/const int kBeyinLigiMinGames\s*=\s*(\d+)/);
  const dN = dm ? Number(dm[1]) : null;
  check(`web (${tsN}) == port (${dN})`, dN != null && dN === tsN);
} else {
  console.log(`  · port dosyası yok (${DART}) — port PR'ı girene kadar atlanıyor`);
}

if (failures) {
  console.log(`\n✗ ${failures} kontrol düştü`);
  process.exit(1);
}
console.log('\n✓ Beyin Ligi eşiği SQL ↔ istemci senkron');
