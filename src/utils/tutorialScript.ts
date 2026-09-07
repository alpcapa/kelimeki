// Kelimeki — "Oynayarak öğren" tanıtımının senaryosu (7 Eylül 2026)
//
// NEDEN VAR: ilk oyunda açılan Hızlı Başlangıç penceresi 9 maddelik bir
// METİNDİ ve kapatmanın bedeli tek dokunuştu — okumayan oyuncu tahtaya
// bakınca ne yapacağını bilmiyordu. Aynı ders bu depoda bir kez daha
// alınmıştı: "Buradan başla" balonu (26 Ağustos 2026) tam da kapalı testte
// insanların KURALI değil İLK HAMLEYİ bulamadığı görüldüğü için eklendi.
// Bu dosya o metnin yerine geçen 60 saniyelik mini oyunun senaryosudur.
//
// ⚠ TASARIM KISITI — MOTOR DEĞİŞMEZ: tanıtım `gameReducer`'ın kendisiyle
// oynanır (puanı, geçerliliği, bölge vergisini, merkez çarpanını hesaplayan
// aynı kod), ama yeni bir action ya da yeni bir `GameState` alanı EKLENMEDEN.
// Sebebi bu depoya özgü: motorun DÖRT kopyası var (src, Dart portu, Edge
// `_game/`, SQL aynası) ve motora dokunan her değişiklik dördünü birden
// bakım işine çeviriyor. Tanıtım bir UI işidir, motor işi değil.
//
// ⚠ SENARYO ELLE YAZILIR AMA ELLE DOĞRULANMAZ: koordinatlar, kelimeler ve
// EKRANDA YAZAN PUANLAR `npm run verify-tutorial-script` ile gerçek motorda
// oynatılarak kilitlenir. Buradaki bir sayıyı değiştirmek isteyen önce o
// betiği koşsun — yanlış puan gösteren bir tanıtım, hiç tanıtım olmamasından
// kötüdür (oyuncu kuralı yanlış öğrenir).
import { PLAYER_COLORS, RACK_SIZE, buildInitialBonuses, cornersFor } from '../game/constants';
import type { GameState, Player, Tile } from '../game/types';
import { TILE_DATA } from '../data/tiles';
import { createEmptyBoard } from './board';

/** Tanıtımdaki rakibin adı — ekranda ve mesajlarda geçer. */
export const TUTORIAL_OPPONENT_NAME = 'Rakip';

/** Girişsiz oyuncu için tanıtımda kullanılan ad. */
export const TUTORIAL_PLAYER_NAME = 'Sen';

/** Tek bir taşın konacağı yer. */
export interface TutorialPlacement {
  r: number;
  c: number;
  /** Raftan seçilecek harf — indeks DEĞİL: raf her hamlede kayıyor. */
  letter: string;
}

/** Bir hamle (oyuncunun ya da rakibin). */
export interface TutorialMove {
  /** Kurulan ana kelime — metinlerde ve doğrulayıcıda kullanılır. */
  word: string;
  /** Bu turda konan taşlar (tahtadaki mevcut harfler listede YOKTUR). */
  cells: TutorialPlacement[];
  /** Oynayanın skoruna EKLENEN puan: çarpan uygulanmış, vergi düşülmüş. */
  points: number;
  /** Bu hamlenin KARŞI tarafa aktardığı bölge vergisi payı (yoksa 0). */
  tax: number;
  /**
   * Kelimenin ÇARPANSIZ harf toplamı — YALNIZCA merkez bölgeye düşen (yani
   * ×2 alan) hamlelerde dolu, başka hiçbir yerde. Bu alan iki iş birden
   * yapıyor: ekrandaki "6 × 2 = 12" cümlesi buradan kuruluyor (metin ile
   * motor tek kaynaktan besleniyor) VE doğrulayıcı için "bu hamle çarpan
   * ALMALI" beyanıdır — `raw * 2 === points + tax` eşitliği kilitlenir
   * (`points` vergi düşülmüş hâlidir, çarpan vergiden ÖNCE uygulanır).
   */
  raw?: number;
}

/** Rakibin cevabı — hamle + tanıtımın kırmızı şeridinde yazan not. */
export interface TutorialReply extends TutorialMove {
  /** Rakip oynarken mesaj şeridinde görünen tek cümle. */
  note: string;
}

/** Bir sahne: oyuncunun hamlesi + rakibin cevabı. */
export interface TutorialStep {
  id: 'ev' | 'buyume' | 'merkez' | 'vergi';
  /** Balondaki TEK cümle (en fazla 6 kelime — metin bütçesi). */
  say: string;
  /**
   * Balonun işaret ettiği kare. YÖN YOK: balon "Buradan başla" ile aynı
   * kuralı izler — karenin yanında, tahtanın içine doğru uzar (sütun < 6.5
   * ise sağa, değilse sola). Kenar karelerinde taşmayan tek yerleşim bu.
   */
  bubble: { r: number; c: number };
  move: TutorialMove;
  /** Hamle oynandıktan sonra mesaj şeridinde yazan kısa sonuç. */
  done: string;
  reply: TutorialReply;
}

/**
 * Sahneler. Sıra kullanıcı kararıdır (7 Eylül 2026): ev → sınır → MERKEZ →
 * rakip teması. Merkez dersi vergiden ÖNCE geliyor çünkü oyuncunun zinciri
 * yukarıdan aşağı ilerliyor: önce ortadaki altın bölgeye varıyor, rakibin
 * kırmızı sınırına ancak ondan sonra komşu oluyor. Ters sırada senaryo
 * tahtayı "ileri sarmak" zorunda kalıyordu.
 *
 * Her hamleden sonra rakip GERÇEKTEN oynar (aynı reducer, kendi rafından) —
 * yine kullanıcı kararı: "gerçek simülasyon olsun". Bunun iki bedava
 * kazancı var: rakip 3. hamlesinde merkezi kullanıp ×2 alır (merkez dersi
 * tek cümle harcamadan tekrar eder) ve 4. hamlesinde OYUNCUNUN sınırına
 * değip ona vergi öder (verginin iki yönlü olduğu görünür).
 */
export const TUTORIAL_STEPS: TutorialStep[] = [
  {
    id: 'ev',
    say: 'Kendi köşenden başla.',
    bubble: { r: 1, c: 1 },
    move: {
      word: 'BÜYÜ',
      cells: [
        { r: 0, c: 0, letter: 'B' },
        { r: 0, c: 1, letter: 'Ü' },
        { r: 0, c: 2, letter: 'Y' },
        { r: 0, c: 3, letter: 'Ü' },
      ],
      points: 12,
      tax: 0,
    },
    done: 'İlk kelimen: +12 puan.',
    reply: {
      word: 'KUYU',
      cells: [
        { r: 9, c: 12, letter: 'K' },
        { r: 10, c: 12, letter: 'U' },
        { r: 11, c: 12, letter: 'Y' },
        { r: 12, c: 12, letter: 'U' },
      ],
      points: 8,
      tax: 0,
      note: 'Rakip de kendi ev karesinden başladı: +8.',
    },
  },
  {
    id: 'buyume',
    say: 'Kelime kurdukça sınırın büyür.',
    bubble: { r: 5, c: 2 },
    move: {
      word: 'ÜZENGİ',
      cells: [
        { r: 1, c: 3, letter: 'Z' },
        { r: 2, c: 3, letter: 'E' },
        { r: 3, c: 3, letter: 'N' },
        { r: 4, c: 3, letter: 'G' },
        { r: 5, c: 3, letter: 'İ' },
      ],
      points: 15,
      tax: 0,
    },
    done: '+15 puan — sınırın köşenin dışına taştı.',
    reply: {
      word: 'TABAK',
      cells: [
        { r: 9, c: 8, letter: 'T' },
        { r: 9, c: 9, letter: 'A' },
        { r: 9, c: 10, letter: 'B' },
        { r: 9, c: 11, letter: 'A' },
      ],
      points: 7,
      tax: 0,
      note: 'Rakip merkeze doğru ilerliyor: +7.',
    },
  },
  {
    id: 'merkez',
    say: 'Burada puan iki katı.',
    bubble: { r: 5, c: 6 },
    move: {
      word: 'İNSAN',
      cells: [
        { r: 5, c: 4, letter: 'N' },
        { r: 5, c: 5, letter: 'S' },
        { r: 5, c: 6, letter: 'A' },
        { r: 5, c: 7, letter: 'N' },
      ],
      points: 12,
      raw: 6,
      tax: 0,
    },
    done: '6 × 2 = 12 puan!',
    reply: {
      word: 'SAAT',
      cells: [
        { r: 6, c: 8, letter: 'S' },
        { r: 7, c: 8, letter: 'A' },
        { r: 8, c: 8, letter: 'A' },
      ],
      points: 10,
      raw: 5,
      tax: 0,
      note: 'Rakip de merkeze girdi ve o da ikiye katladı: +10.',
    },
  },
  {
    id: 'vergi',
    say: 'Rakibin sınırına değdin.',
    bubble: { r: 6, c: 10 },
    move: {
      // Rakibin SAAT'inin S'sine ekleniyor — "rakibin harfine de
      // bağlanabilirsin" kuralı burada bedava öğreniliyor. Konan iki taş
      // altın bölgenin DIŞINDA (sütun 9-10), yani bu sahne çarpan almıyor:
      // ders karışmasın.
      word: 'SAP',
      cells: [
        { r: 6, c: 9, letter: 'A' },
        { r: 6, c: 10, letter: 'P' },
      ],
      points: 5,
      tax: 3,
    },
    done: '8 puanın 3’ü rakibe gitti: +5.',
    reply: {
      word: 'NAR',
      cells: [
        { r: 6, c: 4, letter: 'A' },
        { r: 7, c: 4, letter: 'R' },
      ],
      // Rakibin bu son hamlesi altın bölgeye düşüyor (6,4 · 7,4), yani o da
      // ×2 alıyor: 3 → 6, sonra 2'si vergi olarak OYUNCUYA geçiyor.
      points: 4,
      raw: 3,
      tax: 2,
      note: 'Şimdi tersi oldu: rakip senin sınırına değdi, 2 puanı sana geçti.',
    },
  },
];

/** Kapanış sahnesinin metni — X3'ü bilerek CEVAPSIZ bırakır. */
export const TUTORIAL_FINISH_TITLE = 'Hazırsın!';
export const TUTORIAL_FINISH_TEXT =
  'Ortadaki kare üç katı — onu gerçek oyunda dene.';

/**
 * Rafların TAM olarak hangi sırayla dolacağı. `drawTiles` torbanın SONUNDAN
 * çeker (`pop`), yani buradaki sıra "çekilme sırası"dır ve torba kurulurken
 * tersine çevrilir.
 *
 * ⚠ Bu liste senaryonun sessiz ön koşuludur: bir sahnenin harfi rafta yoksa
 * tanıtım oyuncunun elinde kilitlenir. `verify-tutorial-script` her sahnede
 * gereken harfin rafta bulunduğunu ayrıca kontrol eder.
 *
 * Sıra (çeken → adet): Sen 4, Rakip 4, Sen 5, Rakip 4, Sen 4, Rakip 3.
 */
const DRAW_ORDER: string[] = [
  // Sen — ÜZENGİ'nin G ve İ'si (Z, E, N zaten rafta) + iki dolgu
  'G', 'İ', 'A', 'T',
  // Rakip — TABAK'ın ikinci A'sı + üç dolgu
  'A', 'E', 'L', 'M',
  // Sen — İNSAN'ın N, S, A, N'ı + bir dolgu
  'N', 'S', 'A', 'N', 'K',
  // Rakip — SAAT'in S, A, A'sı + bir dolgu
  'S', 'A', 'A', 'R',
  // Sen — SAP'ın A ve P'si + iki dolgu
  'A', 'P', 'E', 'M',
  // Rakip — NAR'ın A'sı (R rafta) + iki dolgu
  'A', 'K', 'L',
];

/**
 * Torbanın DİBİNDE bekleyen, hiç çekilmeyen taşlar. Boş bir torba + boşalan
 * bir raf `endGame`'i tetikler (bkz. `applyPlacement` → `finishesGame`);
 * tanıtım oyunun sonuna gelmeden bitmeli, bu yüzden torba hep dolu kalır.
 */
const BAG_FILLER: string[] = ['E', 'L', 'M', 'R', 'T', 'K', 'A', 'N', 'O', 'S'];

/** Başlangıç rafları — senaryodaki ilk hamlelerin harfleri. */
const START_RACKS: string[][] = [
  ['B', 'Ü', 'Y', 'Ü', 'Z', 'E', 'N'],
  ['K', 'U', 'Y', 'U', 'T', 'A', 'B'],
];

function tile(letter: string): Tile {
  return { letter, pts: TILE_DATA[letter]?.pts ?? 0 };
}

/**
 * Tanıtımın başlangıç durumu — `startGame`'in (gameReducer) yaptığının
 * senaryolu eşdeğeri: aynı alanlar, ama torba ve raflar RASTGELE DEĞİL.
 *
 * `START` action'ı kullanılmıyor çünkü o torbayı karıştırır; bunun yerine
 * durum doğrudan kurulup `TutorialGame` kendi `useReducer`'ına başlangıç
 * değeri olarak verir. Reducer'a yeni bir action eklemek motorun dört
 * kopyasını birden ilgilendirirdi (bkz. dosya başı).
 */
export function createTutorialState(playerName: string): GameState {
  const corners = cornersFor(2);
  const names = [playerName.trim() || TUTORIAL_PLAYER_NAME, TUTORIAL_OPPONENT_NAME];
  const players: Player[] = names.map((name, i) => ({
    name,
    corners: corners[i],
    colorIndex: i % PLAYER_COLORS.length,
    // Rakip `isAI` DEĞİL: bayrak yalnızca "YZ araması bu koltuğu oynasın"
    // demek olurdu ve tanıtımda arama yok — hamleleri senaryoda yazılı.
    // (`TutorialGame` zaten App'in YZ effect'ini hiç çalıştırmıyor.)
    isAI: false,
    surrendered: false,
    rack: START_RACKS[i].map(tile),
    score: 0,
    bestMoveScore: 0,
    bestWordScore: 0,
    longestWord: '',
    moveCount: 0,
    moveScoreSum: 0,
  }));

  return {
    phase: 'play',
    startedAt: new Date().toISOString(),
    multiSession: false,
    endReason: 'normal',
    board: createEmptyBoard(),
    // Çekilme sırası tersine: `drawTiles` sondan `pop` ediyor.
    bag: [...BAG_FILLER, ...[...DRAW_ORDER].reverse()].map(tile),
    bonuses: buildInitialBonuses(),
    placed: {},
    players,
    current: 0,
    selectedTile: null,
    swapMode: false,
    swapSelection: [],
    turnCount: 0,
    consecutivePasses: 0,
    isGameOver: false,
    message: '',
    messageType: '',
    lastMoveCells: [],
    moveHistory: [],
  };
}

/** Raf en fazla bu kadar taş taşır — senaryo kurulurken sağlaması yapılır. */
export const TUTORIAL_RACK_SIZE = RACK_SIZE;
