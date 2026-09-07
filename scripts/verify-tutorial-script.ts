// Kelimeki — "Oynayarak öğren" tanıtımının senaryosunu GERÇEK motorda oynatır
// (`src/utils/tutorialScript.ts`). Koşum: npm run verify-tutorial-script
//
// NEDEN VAR: tanıtım ekranda PUAN yazıyor ("6 × 2 = 12", "8 puanın 3'ü
// rakibe gitti"). Bu sayılar elle yazıldığı için, motordaki bir kural
// değişikliği (çarpan, vergi formülü, kelime listesi) onları SESSİZCE
// bayatlatabilir — ve yanlış puan gösteren bir tanıtım, hiç tanıtım
// olmamasından kötüdür: oyuncu kuralı yanlış öğrenir. Bu depoda aynı sınıf
// bir koruma karşılama tahtası için zaten var (`verify-demo-board`); orada
// bedel yalnızca "sahte görünmek", burada "yanlış öğretmek".
//
// NE KONTROL EDİLİYOR:
//   1. Her sahnede hedef kareler BOŞ ve gereken harfler RAFTA (senaryonun
//      sessiz ön koşulu: torba sırası — bkz. `DRAW_ORDER`).
//   2. Her hamle motorca GEÇERLİ (`PLAY` bir hata mesajı döndürmüyor).
//   3. Skor deltaları senaryodaki `points` ile birebir; verginin gittiği
//      taraf `tax` ile birebir (yön dahil: sahne 4'te rakibe, rakibin son
//      cevabında OYUNCUYA).
//   4. Merkez sahnesi ×2 ALIYOR, vergi sahnesi çarpan ALMIYOR — iki ders
//      tek hamlede birbirine karışmasın (tasarım kararı).
//   5. Tanıtım ortasında oyun BİTMİYOR (torba/raf tükenmiyor).
//   6. Bitiş tahtasındaki ≥2 uzunluktaki HER yatay/dikey dizilim sözlükte —
//      kesişimlerin ürettiği "kaza kelimeleri" gözle kaçırılır.
import { WORD_LIST } from '../src/data/words';
import { preloadWordSet } from '../src/data/wordSetLoader';
import { TILE_DATA, letterPoints } from '../src/data/tiles';
import { trLower } from '../src/utils/turkish';
import { SIZE } from '../src/game/constants';
import { gameReducer } from '../src/game/gameReducer';
import type { GameState } from '../src/game/types';
import { calcScore, calcWordRawScores } from '../src/utils/validator';
import {
  TUTORIAL_RACK_SIZE,
  TUTORIAL_STEPS,
  createTutorialState,
  type TutorialMove,
} from '../src/utils/tutorialScript';

const SOZLUK = new Set(WORD_LIST.map((w) => trLower(w)));
let hata = 0;

function bildir(mesaj: string): void {
  hata++;
  console.log(`  ✗ ${mesaj}`);
}

function ok(mesaj: string): void {
  console.log(`  ✓ ${mesaj}`);
}

/**
 * Bir hamleyi oynatır ve senaryodaki sayılarla karşılaştırır.
 * `oynayan` = hamleyi yapan koltuk, `karsi` = öteki koltuk.
 */
function hamleOynat(state: GameState, move: TutorialMove, etiket: string): GameState {
  // Çarpan beklentisi VERİDEN gelir: `raw` yalnızca merkez bölgeye düşen
  // hamlelerde doludur (bkz. `TutorialMove.raw`).
  const carpanBekleniyor = move.raw !== undefined;
  const oynayan = state.current;
  const karsi = 1 - oynayan;
  const oncekiSkor = state.players.map((p) => p.score);

  // ── 1. Hedef kareler boş mu, harfler rafta mı ───────────────────────────
  for (const cell of move.cells) {
    if (state.board[cell.r][cell.c]) {
      bildir(`${etiket}: (${cell.r},${cell.c}) zaten dolu — ray imkânsız kareyi işaret ediyor`);
    }
    if (!(cell.letter in TILE_DATA)) {
      bildir(`${etiket}: torbada olmayan harf "${cell.letter}"`);
    }
  }

  let s = state;
  for (const cell of move.cells) {
    const idx = s.players[s.current].rack.findIndex((t) => t.letter === cell.letter);
    if (idx < 0) {
      bildir(
        `${etiket}: "${cell.letter}" rafta yok (raf: ${s.players[s.current].rack
          .map((t) => t.letter)
          .join('')}) — torba sırası senaryoyla uyuşmuyor`,
      );
      return s;
    }
    s = gameReducer(s, { type: 'PLACE_TILE', r: cell.r, c: cell.c, rackIndex: idx });
  }

  if (Object.keys(s.placed).length !== move.cells.length) {
    bildir(`${etiket}: ${move.cells.length} taş konacaktı, ${Object.keys(s.placed).length} kondu`);
  }

  // ── 4. Çarpan var mı ───────────────────────────────────────────────────
  // ⚠ `calcScore(..., {})` ile karşılaştırmak İŞE YARAMAZ: `bonuses` haritası
  // yalnızca tam ortadaki X3 karesini taşır, 5×5'lik ×2 bölgesi ise
  // `inBonusZone`'dan gelir — iki çağrı da aynı sayıyı döndürür. Çarpanın
  // tek dürüst kaynağı kelime başına dönen `x2`/`x3` bayrakları.
  const hamSkorlar = calcWordRawScores(s.board, s.placed, s.bonuses);
  const carpanVar = hamSkorlar.some((w) => w.x2 || w.x3);
  if (carpanVar !== carpanBekleniyor) {
    bildir(
      `${etiket}: çarpan beklentisi tutmadı (beklenen ${carpanBekleniyor ? 'VAR' : 'YOK'}, ` +
        `gerçek ${carpanVar ? 'VAR' : 'YOK'})`,
    );
  }
  // Hamlenin vergi ÖNCESİ puanı: `points + tax`. Çarpanlı sahnelerde bu
  // sayının "raw × 2" olduğu da kilitleniyor — ekranda o cümle yazıyor.
  const vergiOncesi = calcScore(s.board, s.placed, s.bonuses);
  if (vergiOncesi !== move.points + move.tax) {
    bildir(`${etiket}: vergi öncesi puan ${vergiOncesi}, senaryo ${move.points}+${move.tax} diyor`);
  }
  if (move.raw !== undefined) {
    const hamToplam = hamSkorlar.reduce((t, w) => t + w.score, 0);
    if (hamToplam !== move.raw) {
      bildir(`${etiket}: çarpansız puan beklenen ${move.raw}, gerçek ${hamToplam}`);
    }
    if (move.raw * 2 !== vergiOncesi) {
      bildir(`${etiket}: "${move.raw} × 2" cümlesi hamlenin puanıyla tutmuyor`);
    }
  }

  // ── 2 + 3. Oyna ────────────────────────────────────────────────────────
  s = gameReducer(s, { type: 'PLAY' });
  if (s.messageType === 'err') {
    bildir(`${etiket}: motor hamleyi reddetti — "${s.message}"`);
    return s;
  }
  if (Object.keys(s.placed).length > 0) {
    bildir(`${etiket}: hamle onaylanmadı, taslak taşlar duruyor`);
    return s;
  }

  const kazanc = s.players[oynayan].score - oncekiSkor[oynayan];
  const karsiKazanc = s.players[karsi].score - oncekiSkor[karsi];
  if (kazanc !== move.points) {
    bildir(`${etiket}: beklenen +${move.points}, gerçek +${kazanc}`);
  }
  if (karsiKazanc !== move.tax) {
    bildir(`${etiket}: vergi payı beklenen ${move.tax}, gerçek ${karsiKazanc}`);
  }

  // ── 5. Tanıtım ortasında oyun bitmemeli ────────────────────────────────
  if (s.isGameOver) bildir(`${etiket}: oyun tanıtımın ortasında bitti`);
  for (const p of s.players) {
    if (p.rack.length > TUTORIAL_RACK_SIZE) {
      bildir(`${etiket}: raf ${p.rack.length} taşa çıktı (tavan ${TUTORIAL_RACK_SIZE})`);
    }
  }
  return s;
}

// `validatePlacement` kelime listesini tembel yüklenen chunk'tan okuyor
// (`wordSetLoader`) — tarayıcıda `main.tsx` tetikliyor, burada elle.
await preloadWordSet();

console.log('Tanıtım senaryosu — gerçek motorda oynatılıyor\n');

let state = createTutorialState('Sen');

for (const step of TUTORIAL_STEPS) {
  console.log(`Sahne "${step.id}"`);
  // Balon oyuncunun sırasındayken çizilir; sıra gerçekten oyuncuda mı?
  if (state.current !== 0) bildir(`${step.id}: sıra oyuncuda değil`);
  state = hamleOynat(state, step.move, `${step.id} · ${step.move.word}`);
  if (state.current !== 1) bildir(`${step.id}: rakibe sıra geçmedi`);
  // Rakibin 3. cevabı (SAAT) ve 4. cevabı (NAR) bilerek merkezi kullanıyor:
  // merkez dersi oyuncuya iki kez daha, cümle harcamadan tekrar eder.
  state = hamleOynat(state, step.reply, `${step.id} · rakip · ${step.reply.word}`);
  if (hata === 0) ok(`${step.move.word} +${step.move.points} · ${step.reply.word} +${step.reply.points}`);
}

// ── 6. Bitiş tahtasındaki her dizilim gerçek bir kelime mi ───────────────
const bulunan: string[] = [];
function dizilimleriTara(oku: (i: number) => string | null, uzunluk: number, ad: string): void {
  let birikim = '';
  for (let i = 0; i <= uzunluk; i++) {
    const harf = i < uzunluk ? oku(i) : null;
    if (harf) {
      birikim += harf;
    } else {
      if (birikim.length >= 2) {
        bulunan.push(birikim);
        if (!SOZLUK.has(trLower(birikim))) bildir(`${ad}: "${birikim}" sözlükte yok`);
      }
      birikim = '';
    }
  }
}
for (let r = 0; r < SIZE; r++) {
  dizilimleriTara((c) => state.board[r][c]?.letter ?? null, SIZE, `satır ${r}`);
}
for (let c = 0; c < SIZE; c++) {
  dizilimleriTara((r) => state.board[r][c]?.letter ?? null, SIZE, `sütun ${c}`);
}

// ── Özet ─────────────────────────────────────────────────────────────────
const beklenenSen = TUTORIAL_STEPS.reduce((s, x) => s + x.move.points + x.reply.tax, 0);
const beklenenRakip = TUTORIAL_STEPS.reduce((s, x) => s + x.reply.points + x.move.tax, 0);
if (state.players[0].score !== beklenenSen) {
  bildir(`bitiş skoru (sen): beklenen ${beklenenSen}, gerçek ${state.players[0].score}`);
}
if (state.players[1].score !== beklenenRakip) {
  bildir(`bitiş skoru (rakip): beklenen ${beklenenRakip}, gerçek ${state.players[1].score}`);
}

console.log(`\nTahtadaki kelimeler: ${bulunan.join(', ')}`);
console.log(`Bitiş skoru: sen ${state.players[0].score} · rakip ${state.players[1].score}`);
// Harf puanları senaryo metinlerinde de geçtiğinden bir kez basılıyor.
console.log(
  `İlk kelime ham puanı: ${TUTORIAL_STEPS[0].move.cells
    .map((c) => `${c.letter}${letterPoints(c.letter)}`)
    .join('+')}`,
);

if (hata > 0) {
  console.log(`\n✗ ${hata} sorun bulundu.`);
  process.exit(1);
}
console.log('\n✓ Tanıtım senaryosu motorla birebir tutuyor.');
