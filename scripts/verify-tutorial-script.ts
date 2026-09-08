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
//   7. KAPI: tanıtım kimlere gösteriliyor (`shouldShowTutorial`). Kullanıcı
//      isteği net — "sadece yeni gelenlere bir kere, mevcut oynamış kişilere
//      gösterilmeyecek" — ve bu karar TEK bir bayrağa bakmıyor; tablo aşağıda.
//   9. BALON YERİ: sahnenin balonu hedef kareleri örtmüyor mu (uzun bir
//      metin balonu genişletip "şuraya koy" denen kareleri kapatabiliyor —
//      7 Eylül 2026'da 3. sahnede oldu).
//   8. RAF DÜZENİ: sahnenin harfleri oyuncunun rafında YAN YANA ve kelime
//      sırasında duruyor mu. Kullanıcı isteği (cihaz testi): "Rafta taşıması
//      gereken taşları yanyana koy ve highlight et." Ekran bu bitişik bloğu
//      arıyor; blok dağılırsa vurgu yanlış taşa düşer ve tanıtım kilitlenir
//      (7 Eylül 2026'da tam bu oldu: rafta iki "A" varken üçüncü hedef için
//      baştaki artık "A" işaretlendi).
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
import {
  ONBOARDING_HINT_MAX_SHOWS,
  ONBOARDING_HINT_ORDER,
  ONBOARDING_HINT_TEXTS,
  TUTORIAL_LAUNCH_AT,
  pickOnboardingHint,
  shouldShowTutorial,
  type OnboardingHintId,
  type OnboardingHintInput,
} from '../src/utils/onboarding';

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

  // ── 4. Çarpan beyanı tutuyor mu ────────────────────────────────────────
  // ⚠ `calcScore(..., {})` ile karşılaştırmak İŞE YARAMAZ: `bonuses` haritası
  // yalnızca tam ortadaki X3 karesini taşır, 5×5'lik ×2 bölgesi ise
  // `inBonusZone`'dan gelir — iki çağrı da aynı sayıyı döndürür. Çarpanın
  // tek dürüst kaynağı kelime başına dönen `x2`/`x3` bayrakları.
  const hamSkorlar = calcWordRawScores(s.board, s.placed, s.bonuses);
  const x3Var = hamSkorlar.some((w) => w.x3);
  const x2Var = hamSkorlar.some((w) => w.x2);
  if (move.bonus === 'x3' && !x3Var) {
    bildir(`${etiket}: X3 bekleniyordu, hiçbir kelime merkez kareye değmemiş`);
  }
  if (move.bonus === 'x2' && !x2Var) {
    bildir(`${etiket}: ×2 bekleniyordu, hiçbir kelime altın bölgeye düşmemiş`);
  }
  if (move.bonus === 'x2' && x3Var) {
    bildir(`${etiket}: ×2 bekleniyordu ama kelime X3 karesine değmiş`);
  }
  if (move.bonus === undefined && (x2Var || x3Var)) {
    bildir(`${etiket}: çarpan BEKLENMİYORDU ama hamle çarpan aldı (x2:${x2Var} x3:${x3Var})`);
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
    if (hamSkorlar.length !== 1) {
      // `raw × 2` cümlesi ancak TEK kelime kuran bir hamlede dürüst olur.
      bildir(`${etiket}: "raw × 2" beyanı ${hamSkorlar.length} kelimeli hamlede kullanılamaz`);
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

  // ── 9. Balon hedef kareleri örtmüyor mu ────────────────────────────────
  // Balon çapanın ÜSTÜNDE ('ust') ya da ALTINDA ('alt') durur ve tahtanın
  // neredeyse tam genişliğini kullanır (bkz. `Board.coach`). İki satıra
  // sarabildiğinden komşu İKİ satırı kapatabilir: oyuncuya "şuraya koy"
  // derken oranın üstünü kapatmak tam ters etki yapar.
  const { r: br, c: bc, yon } = step.bubble;
  // Balon ÜÇ komşu satıra kadar kapatabilir (7 Eylül 2026 akşamı punto
  // büyüdü ve uzun cümleler iki satıra kırılıyor — kutu yükseldi). Kontrol
  // buna göre GENİŞLETİLDİ: dar tutmak, örtüşmeyi gözden kaçırmak demek.
  const kapali =
    yon === 'ust' ? [br - 1, br - 2, br - 3] : [br + 1, br + 2, br + 3];
  const ortulen = step.move.cells.filter((h) => kapali.includes(h.r));
  if (ortulen.length > 0) {
    bildir(
      `${step.id}: balon (${br},${bc}, ${yon}) hedef kareleri örtüyor — ` +
        ortulen.map((h) => `(${h.r},${h.c})`).join(', '),
    );
  }
  // Üstte yer yoksa balon tahtadan taşar (0. satırın üstü ekran dışı).
  if (yon === 'ust' && br === 0) {
    bildir(`${step.id}: 0. satırda 'ust' balon tahtadan taşar — 'alt' olmalı`);
  }
  if (bc < 0 || bc >= SIZE || br < 0 || br >= SIZE) {
    bildir(`${step.id}: balon çapası tahtanın dışında (${br},${bc})`);
  }

  // ── 8. Sahnenin harfleri rafta yan yana ve sırayla mı ───────────────────
  const rafHarfleri = state.players[0].rack.map((t) => t.letter);
  const gereken = step.move.cells.map((c) => c.letter);
  const bitisik = rafHarfleri.some((_, bas) =>
    bas + gereken.length <= rafHarfleri.length &&
    gereken.every((l, i) => rafHarfleri[bas + i] === l),
  );
  if (!bitisik) {
    bildir(
      `${step.id}: "${gereken.join('')}" rafta yan yana ve sırayla DEĞİL ` +
        `(raf: ${rafHarfleri.join('')}) — ekrandaki vurgu yanlış taşa düşer`,
    );
  }
  state = hamleOynat(state, step.move, `${step.id} · ${step.move.word}`);
  if (state.current !== 1) bildir(`${step.id}: rakibe sıra geçmedi`);
  // Rakibin 3. cevabı (SAAT) ve 4. cevabı (NAR) bilerek merkezi kullanıyor:
  // merkez dersi oyuncuya iki kez daha, cümle harcamadan tekrar eder.
  state = hamleOynat(state, step.reply, `${step.id} · rakip · ${step.reply.word}`);
  // Sahnenin ÖĞRETTİĞİ şey gerçekten oluyor mu — senaryo kaydığında sessizce
  // "dersi olmayan bir sahne" kalmasın diye.
  if (step.id === 'x3vergi' && (step.move.bonus !== 'x3' || step.move.tax === 0)) {
    bildir('x3vergi sahnesi hem X3 hem vergi İÇERMELİ (kullanıcı kararı, 7 Eylül 2026)');
  }
  if (step.id === 'merkez' && step.move.tax !== 0) {
    bildir('merkez sahnesi vergi ÖDEMEMELİ — iki ders tek hamlede karışmasın');
  }
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

// ── 7. Kapı: tanıtım kime gösteriliyor ───────────────────────────────────
// Varsayılan bilerek GÖSTERME tarafında: mevcut bir oyuncuyu tanıtıma
// sokmak, yeni bir oyuncunun tanıtımı kaçırmasından daha kötü.
const TEMIZ = {
  seenTutorial: false,
  seenLegacyQuickStart: false,
  hasPlayed: false,
  accountCreatedAt: null as string | null,
};
const ESKI_HESAP = '2026-08-01T10:00:00.000Z';
const YENI_HESAP = new Date(Date.parse(TUTORIAL_LAUNCH_AT) + 3_600_000).toISOString();

const kapiVakalari: { ad: string; girdi: typeof TEMIZ; beklenen: boolean }[] = [
  { ad: 'yeni misafir — tertemiz cihaz', girdi: { ...TEMIZ }, beklenen: true },
  { ad: 'tanıtımı zaten görmüş cihaz', girdi: { ...TEMIZ, seenTutorial: true }, beklenen: false },
  {
    ad: 'eski Hızlı Başlangıç’ı görmüş cihaz (mevcut oyuncu)',
    girdi: { ...TEMIZ, seenLegacyQuickStart: true },
    beklenen: false,
  },
  { ad: 'misafir — devam eden yerel oyunu var', girdi: { ...TEMIZ, hasPlayed: true }, beklenen: false },
  {
    ad: 'girişli — hesap tanıtımdan ESKİ, cihaz tertemiz (cihaz değiştirmiş)',
    girdi: { ...TEMIZ, accountCreatedAt: ESKI_HESAP },
    beklenen: false,
  },
  {
    ad: 'girişli — hesap tanıtımdan YENİ, cihaz tertemiz',
    girdi: { ...TEMIZ, accountCreatedAt: YENI_HESAP },
    beklenen: true,
  },
  {
    ad: 'girişli — okunamayan hesap tarihi (varsayılan: gösterme)',
    girdi: { ...TEMIZ, accountCreatedAt: 'bozuk-tarih' },
    beklenen: false,
  },
];

console.log('\nKapı — tanıtım kime gösteriliyor');
for (const vaka of kapiVakalari) {
  const sonuc = shouldShowTutorial(vaka.girdi);
  if (sonuc !== vaka.beklenen) {
    bildir(`kapı "${vaka.ad}": beklenen ${vaka.beklenen}, gerçek ${sonuc}`);
  } else {
    ok(`${sonuc ? 'GÖSTER' : 'gösterme'} — ${vaka.ad}`);
  }
}

// ── 10. Bağlamsal ipuçları (Onboarding Faz 2) ────────────────────────────
// Kapının tablosuyla aynı gerekçe: karar SAF bir fonksiyonda ve üç sayaç
// birden okunuyor. En kolay kaçırılan iki kural burada kilitleniyor —
// (a) aynı hamlede birden fazla ipucu hak edilirse SIRA sabittir (ekranda
// aynı anda tek balon olabilir), (b) tavana çarpan bir ipucu ötekileri
// SUSTURMAZ, sıradaki hak edilmiş ipucu gösterilir.
const IPUCU_YOK = { paidTax: false, gotMultiplier: false, territoryOutsideCorner: false };
const SIFIR: Record<OnboardingHintId, number> = { vergi: 0, carpan: 0, bolge: 0 };
const TAVAN = ONBOARDING_HINT_MAX_SHOWS;

const ipucuVakalari: {
  ad: string;
  girdi: OnboardingHintInput;
  sayac: Record<OnboardingHintId, number>;
  beklenen: OnboardingHintId | null;
}[] = [
  { ad: 'mekanik yaşanmadı', girdi: IPUCU_YOK, sayac: SIFIR, beklenen: null },
  {
    ad: 'yalnızca vergi ödendi',
    girdi: { ...IPUCU_YOK, paidTax: true },
    sayac: SIFIR,
    beklenen: 'vergi',
  },
  {
    ad: 'yalnızca çarpan alındı',
    girdi: { ...IPUCU_YOK, gotMultiplier: true },
    sayac: SIFIR,
    beklenen: 'carpan',
  },
  {
    ad: 'yalnızca bölge büyüdü',
    girdi: { ...IPUCU_YOK, territoryOutsideCorner: true },
    sayac: SIFIR,
    beklenen: 'bolge',
  },
  {
    // Tanıtımın 4. sahnesi TAM OLARAK böyle: hem ×3 hem vergi.
    ad: 'üçü birden — sıra sabit, vergi kazanır',
    girdi: { paidTax: true, gotMultiplier: true, territoryOutsideCorner: true },
    sayac: SIFIR,
    beklenen: 'vergi',
  },
  {
    ad: 'vergi tavanda — sıradaki hak edilmiş ipucu gösterilir',
    girdi: { paidTax: true, gotMultiplier: true, territoryOutsideCorner: true },
    sayac: { ...SIFIR, vergi: TAVAN },
    beklenen: 'carpan',
  },
  {
    ad: 'hepsi tavanda — hiçbiri gösterilmez',
    girdi: { paidTax: true, gotMultiplier: true, territoryOutsideCorner: true },
    sayac: { vergi: TAVAN, carpan: TAVAN, bolge: TAVAN },
    beklenen: null,
  },
];

console.log('\nBağlamsal ipuçları — hangi hamlede hangi balon');
for (const vaka of ipucuVakalari) {
  const sonuc = pickOnboardingHint(vaka.girdi, vaka.sayac);
  if (sonuc !== vaka.beklenen) {
    bildir(`ipucu "${vaka.ad}": beklenen ${vaka.beklenen ?? 'yok'}, gerçek ${sonuc ?? 'yok'}`);
  } else {
    ok(`${sonuc ?? 'balon yok'} — ${vaka.ad}`);
  }
}

// Metinler TEK cümle olmalı (tanıtımın "tek cümle bütçesi" kuralı) ve
// terim `sınır` DEĞİL `bölge` (bkz. kök CLAUDE.md → "Terminoloji").
for (const id of ONBOARDING_HINT_ORDER) {
  const metin = ONBOARDING_HINT_TEXTS[id];
  if ((metin.match(/[.!?]/g) ?? []).length !== 1 || !metin.trim().endsWith('.')) {
    bildir(`ipucu metni "${id}" tek cümle değil: ${metin}`);
  }
  if (/sınır/i.test(metin)) {
    bildir(`ipucu metni "${id}" "sınır" diyor — verginin/alanın adı "bölge": ${metin}`);
  }
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
