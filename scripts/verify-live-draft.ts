// Kelimeki — Canlı oyunda TASLAK KURALINI (utils/liveDraft.ts +
// gameReducer.ts SYNC_ONLINE_STATE) ÜRETİM kodunu import ederek doğrular.
//
// KURAL (5 Kasım 2026, kullanıcı): sıra rakipteyken bulunan iyi hamle rakip
// oynayınca ve ekrandan çıkıp girince KAYBOLMASIN. Taslak YALNIZCA bir
// hücresine taş oturduysa ya da taşları sunucudaki rafımda bulunamıyorsa
// atılır; GEÇERSİZ olması atma sebebi DEĞİL.
//
// NEDEN AYRI BİR BETİK: golden vector'lar web ile Dart'ı KARŞILAŞTIRIR; ikisinde
// de aynı olan yanlışı görmezler (`verify-swap-invariants` ile aynı gerekçe).
// Portun ikizi `mobile/app/test/live_draft_test.dart` AYNI vakaları koşar.
//
// Koşum: npm run verify-live-draft
import { gameReducer, createInitialState, type Action } from '../src/game/gameReducer';
import type { GameState, Tile } from '../src/game/types';
import { setRandomSource } from '../src/utils/random';
import {
  clearLiveDraft,
  discardedByOpponent,
  draftConflicts,
  loadLiveDraft,
  rackCoversDraft,
  saveLiveDraft,
  shouldKeepDraft,
  type Draft,
} from '../src/utils/liveDraft';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

let seed = 777;
setRandomSource(() => {
  seed = (seed * 1103515245 + 12345) & 0x7fffffff;
  return seed / 0x7fffffff;
});

const clone = <T,>(x: T): T => JSON.parse(JSON.stringify(x));

/** Ben = slot 0, sıra bende, 7 taşlık raf. */
const start = (): GameState =>
  gameReducer(createInitialState(), {
    type: 'START',
    players: [
      { name: 'Ben', isAI: false },
      { name: 'Rakip', isAI: false },
    ],
  } as Action);

/** Sunucudan gelecek public state (SYNC_ONLINE_STATE girdisi). */
function pubOf(s: GameState, board: (Tile | null)[][], turn: number, current = 0) {
  return {
    board,
    bonuses: s.bonuses,
    players: s.players.map((p) => ({
      name: p.name,
      corners: p.corners,
      colorIndex: p.colorIndex,
      isAI: p.isAI,
      surrendered: p.surrendered,
      rackCount: 7,
      score: p.score,
      bestMoveScore: p.bestMoveScore,
      bestWordScore: p.bestWordScore,
      longestWord: p.longestWord,
      moveCount: p.moveCount,
      moveScoreSum: p.moveScoreSum,
    })),
    current,
    turn_count: turn,
    consecutive_passes: 0,
    is_game_over: false,
    end_reason: null,
    last_move_cells: [],
    bag_count: s.bag.length,
    started_at: s.startedAt,
  };
}

// `base`: sunucu durumunun oyuncu/bonus/torba bilgisini nereden üreteceği (yeni
// açılan ekranın boş `createInitialState`i oyuncu taşımaz).
const sync = (
  s: GameState,
  board: (Tile | null)[][],
  turn: number,
  myRack: Tile[],
  savedDraft?: Draft,
  base: GameState = s,
): GameState =>
  gameReducer(s, {
    type: 'SYNC_ONLINE_STATE',
    publicState: pubOf(base, board, turn, 0) as never,
    myRack,
    mySlotIndex: 0,
    savedDraft,
  });

console.log('\nCanlı oyun taslak kuralı\n');

// Ortak kurulum: ilk senkron yapılmış, iki taş (0,0)-(0,1)'e konmuş taslak.
function kurulum(): { s: GameState; tamRaf: Tile[]; bosTahta: (Tile | null)[][] } {
  let s = start();
  const tamRaf: Tile[] = clone(s.players[0].rack); // sunucudaki ham raf (7 taş)
  const bosTahta = clone(s.board);
  s = sync(s, bosTahta, 0, tamRaf); // ekran yüklendi
  s = gameReducer(s, { type: 'PLACE_TILE', r: 0, c: 0, rackIndex: 0 });
  s = gameReducer(s, { type: 'PLACE_TILE', r: 0, c: 1, rackIndex: 0 });
  return { s, tamRaf, bosTahta };
}

// ── 1. Rakip ÇAKIŞMAYAN bir hamle yaptı → taslak KALIR ───────────────────────
{
  const { s, tamRaf, bosTahta } = kurulum();
  check('senaryo: iki taş taslakta', Object.keys(s.placed).length === 2);
  const board = clone(bosTahta);
  board[6][6] = { letter: 'K', pts: 5, owner: 1 };
  const t = sync(s, board, s.turnCount + 1, tamRaf);
  check('tur ilerledi (senaryo anlamlı)', t.turnCount === s.turnCount + 1);
  check('çakışma yok → taslak KORUNDU', Object.keys(t.placed).length === 2);
  check('raf taslak taşlarını düşmüş (5 taş)', t.players[0].rack.length === 5);
  check('tahtada rakibin taşı var', !!t.board[6][6]);
}

// ── 2. Rakip taslağın bir hücresine oynadı → taslak ATILIR, taşlar rafa ───────
{
  const { s, tamRaf, bosTahta } = kurulum();
  const board = clone(bosTahta);
  board[0][1] = { letter: 'A', pts: 1, owner: 1 };
  const t = sync(s, board, s.turnCount + 1, tamRaf);
  check('hücre çakıştı → taslak atıldı', Object.keys(t.placed).length === 0);
  check('taşlar rafa döndü (7 taş)', t.players[0].rack.length === 7);
  check('atma sebebi RAKİP (bilgi satırı çıkar)', discardedByOpponent(s.placed, board, 0));
}

// ── 3. Kendi hamlem sonrası (taşlarım artık tahtada) → sessizce temizlenir ───
{
  const { s, tamRaf, bosTahta } = kurulum();
  const board = clone(bosTahta);
  for (const k of Object.keys(s.placed)) {
    const [r, c] = k.split(',').map(Number);
    board[r][c] = { ...s.placed[k], owner: 0 };
  }
  const yeniRaf = clone(tamRaf);
  yeniRaf.splice(0, 2); // oynadığım taşlar gitti (yenileri çekildi diye varsayalım)
  const t = sync(s, board, s.turnCount + 1, yeniRaf);
  check('kendi hamlemden sonra taslak temizlendi', Object.keys(t.placed).length === 0);
  check('bilgi satırı ÇIKMAZ (kendi taşlarım)', !discardedByOpponent(s.placed, board, 0));
}

// ── 4. Raf uyuşmazlığı (başka cihazdan taş değiştirdim) → atılır, sessiz ─────
{
  const { s, bosTahta } = kurulum();
  const baskaRaf: Tile[] = Array.from({ length: 7 }, () => ({ letter: 'Z', pts: 4 }));
  const t = sync(s, bosTahta, s.turnCount + 1, baskaRaf);
  check('raf taslağı karşılamıyor → atıldı', Object.keys(t.placed).length === 0);
  check('raf uyuşmazlığında bilgi satırı çıkmaz', !discardedByOpponent(s.placed, bosTahta, 0));
}

// ── 5. Tur ilerlemedi (sekme odağa döndü) → taslak aynen korunur (gerileme) ───
{
  const { s, tamRaf, bosTahta } = kurulum();
  const t = sync(s, bosTahta, s.turnCount, tamRaf);
  check('tur aynı → taslak korundu', Object.keys(t.placed).length === 2);
  check('raf 5 taş', t.players[0].rack.length === 5);
}

// ── 6. İlk senkronda KAYITLI taslak geri yüklenir ────────────────────────────
{
  const s0 = start();
  const tamRaf: Tile[] = clone(s0.players[0].rack);
  const bos = clone(s0.board);
  const kayit: Draft = {
    '0,0': { ...tamRaf[0], owner: 0 },
    '0,1': { ...tamRaf[1], owner: 0 },
  };
  const fresh = createInitialState(); // ekran yeni açıldı, placed boş
  const t = sync(fresh, bos, 3, tamRaf, kayit, s0);
  check('kayıtlı taslak geri yüklendi (2 taş)', Object.keys(t.placed).length === 2);
  check('raf buna göre 5 taş', t.players[0].rack.length === 5);

  const cakisanBoard = clone(bos);
  cakisanBoard[0][0] = { letter: 'M', pts: 2, owner: 1 };
  const t2 = sync(createInitialState(), cakisanBoard, 3, tamRaf, kayit, s0);
  check('kayıtlı taslak çakışıyor → geri YÜKLENMEDİ', Object.keys(t2.placed).length === 0);
  check('geri yükleme atıldığında bilgi satırı çıkar', discardedByOpponent(kayit, cakisanBoard, 0));

  const baskaRaf: Tile[] = Array.from({ length: 7 }, () => ({ letter: 'Z', pts: 4 }));
  const t3 = sync(createInitialState(), bos, 3, baskaRaf, kayit, s0);
  check('kayıtlı taslak rafı karşılamıyor → geri YÜKLENMEDİ', Object.keys(t3.placed).length === 0);

  // Ekranda zaten taslak varsa kayıt onu EZMEZ.
  const { s: mevcut, tamRaf: r2, bosTahta: b2 } = kurulum();
  const t4 = sync(mevcut, b2, mevcut.turnCount, r2, { '5,5': { letter: 'X', pts: 9, owner: 0 } });
  check('ekrandaki taslak kayıtla EZİLMEZ', Object.keys(t4.placed).length === 2 && !t4.placed['5,5']);
}

// ── 7. Saf yardımcılar ───────────────────────────────────────────────────────
{
  const bos = clone(start().board);
  const joker: Draft = { '3,3': { letter: '?', pts: 0, wild: true, wildLetter: 'E', owner: 0 } };
  check('joker taslağı: raftaki "?" karşılar', rackCoversDraft([{ letter: '?', pts: 0 }], joker));
  check('joker taslağı: "E" harfi jokerin yerini TUTMAZ', !rackCoversDraft([{ letter: 'E', pts: 1 }], joker));
  check(
    'çoklu küme: iki "A" gerekir, raf tek "A" taşıyor',
    !rackCoversDraft(
      [{ letter: 'A', pts: 1 }],
      { '1,1': { letter: 'A', pts: 1 }, '1,2': { letter: 'A', pts: 1 } },
    ),
  );
  check('boş taslak her zaman korunur', shouldKeepDraft({}, bos, []));
  const b2 = clone(bos);
  b2[2][2] = { letter: 'T', pts: 1, owner: 1 };
  check(
    'draftConflicts yalnızca dolu hücreyi bulur',
    JSON.stringify(draftConflicts({ '2,2': { letter: 'A', pts: 1 }, '2,3': { letter: 'B', pts: 3 } }, b2)) ===
      JSON.stringify(['2,2']),
  );
}

// ── 8. Yerel kayıt: gidiş-dönüş, bozuk kayıt, silme ─────────────────────────
{
  const store = new Map<string, string>();
  (globalThis as unknown as { localStorage: Storage }).localStorage = {
    getItem: (k: string) => store.get(k) ?? null,
    setItem: (k: string, v: string) => void store.set(k, v),
    removeItem: (k: string) => void store.delete(k),
  } as Storage;
  const d: Draft = {
    '4,4': { letter: 'K', pts: 5, owner: 0 },
    '4,5': { letter: '?', pts: 0, wild: true, wildLetter: 'Ş', owner: 0 },
  };
  saveLiveDraft('u1', 'g1', d);
  const geri = loadLiveDraft('u1', 'g1');
  check('kaydet → yükle gidiş-dönüş (joker harfi dahil)', JSON.stringify(geri) === JSON.stringify(d));
  check('başka kullanıcının taslağı gelmez', loadLiveDraft('u2', 'g1') === null);
  check('başka oyunun taslağı gelmez', loadLiveDraft('u1', 'g2') === null);
  store.set('kelimeki:live-draft:u1:g3', '{bozuk');
  check('bozuk JSON → null', loadLiveDraft('u1', 'g3') === null);
  store.set('kelimeki:live-draft:u1:g4', JSON.stringify({ v: 1, cells: [{ k: 'x,y', letter: 'A', pts: 1 }] }));
  check('hatalı hücre anahtarı → null (uygulanmaz)', loadLiveDraft('u1', 'g4') === null);
  saveLiveDraft('u1', 'g1', {});
  check('boş taslak kaydı SİLER', loadLiveDraft('u1', 'g1') === null);
  saveLiveDraft('u1', 'g1', d);
  clearLiveDraft('u1', 'g1');
  check('clearLiveDraft siler', loadLiveDraft('u1', 'g1') === null);
}

console.log('');
if (failures > 0) {
  console.log(`✗ ${failures} kontrol başarısız`);
  process.exit(1);
}
console.log('Tüm kontroller geçti.');
