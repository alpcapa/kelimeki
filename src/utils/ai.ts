// Kelimeki — YZ rakip mantığı (çok oyunculu, köşe temelli)
//
// YZ, rafından heceleyebildiği kelimeler arasından, bölge kurallarına uyan
// ve sözlükçe geçerli en yüksek puanlı hamleyi arar. İlk hamlesini kendi
// köşesinden başlatır; sonra mevcut taşları çapa alarak yeni kelimeler kurar.
import { AI_LEVEL_TOP_N, RACK_SIZE, SIZE, cornerCell } from '../game/constants';
import type { AIMove, AiLevel, BonusType, Placement, Player, Tile } from '../game/types';
import { getWordSet } from '../data/wordSetLoader';
import { letterPoints } from '../data/tiles';
import { canSpell, calcScore, computeAllTerritories, freshCorners } from './validator';
import { trLower, trUpper } from './turkish';
import { nextRandom } from './random';
import { getFormedWords, key, tileLetter, type Board } from './board';

// WORD_SET sabit olduğundan (oyun boyunca değişmez), rafa/tahtaya/oyuncuya
// bağlı olmayan bu türetilmiş liste ilk `findAIMove` çağrısında bir kez
// hesaplanıp önbelleğe alınır — önceden her çağrıda baştan yeniden
// üretiliyordu, bu da tahtada çapa harfi arttıkça YZ'nin "düşünme"
// süresini gereksiz yere uzatıyordu. Modül yüklenirken DEĞİL ilk
// kullanımda hesaplanmasının sebebi, WORD_SET'in artık ayrı bir chunk'tan
// (bkz. wordSetLoader.ts) geldiği ve modül değerlendirme anında henüz
// yüklenmemiş olabilmesidir.
const wordPools = new Map<number, readonly string[]>();
function getWordPool(maxLen: number): readonly string[] {
  let pool = wordPools.get(maxLen);
  if (!pool) {
    pool = [...getWordSet()]
      .filter((w) => w.length >= 2 && w.length <= maxLen)
      .map((w) => trUpper(w));
    wordPools.set(maxLen, pool);
  }
  return pool;
}

/** Normal/Kolay'ın kelime havuzu üst sınırı (harf). */
const NORMAL_MAX_WORD_LEN = 7;

/**
 * DENEYSEL — Zor motoru adayları (ROADMAP #23 Faz 5). `findAIMoves`'a
 * verilmezse davranış Normal'le bayt-eş; ölçüm aleti (`simulate-ai-levels`)
 * adayları tek tek ve bileşim hâlinde bu seçeneklerle koşturur.
 */
export interface HardOptions {
  /** Kelime havuzu üst sınırı (Normal 7; 8 = çapa + tam raf = bingo yolu). */
  maxWordLen: number;
  /** Kullanılan joker başına sıralama cezası (puan). 0 = kapalı. */
  jokerPenalty: number;
  /** Raf-kalıntı değerinin yüzde ağırlığı (100 = tablo aynen). 0 = kapalı. */
  leaveWeight: number;
  /** Bölge farkı (kendi kazanç + rakip kaybı) hücre başına santipuan. 0 = kapalı. */
  territoryWeight: number;
  /** Vergili hamleleri, rakibe giden payı da düşerek güvenlilerle birlikte sırala. */
  netDiff: boolean;
  /**
   * Gönüllü değişim: en iyi hamlenin ham puanı bu eşiğin ALTINDAYSA ve torbada
   * en az bir raf dolusu taş varsa liste boş döner (çağıran rafı değiştirir).
   * 0 = kapalı.
   */
  exchangeBelow: number;
  /**
   * Tek katlı ileri bakış: sıradaki rakibin en iyi cevabının ham puanı bu
   * yüzde ağırlıkla düşülür (100 = birebir). 0 = kapalı. Rakip rafı
   * `opponentRacks[i]`den okunur (DENEYSEL — "rafa bakan" üst sınır ölçümü).
   */
  replyWeight: number;
  /**
   * İleri bakış için rakip rafları (oyuncu indeksine göre). Verilmezse rakip
   * için GENEL bir raf (`GENERIC_REPLY_RACK`) varsayılır — rafa bakmayan,
   * yalnızca "hamlem hangi sıcak noktaları açtı" sorusunu ölçen dürüst sürüm.
   */
  opponentRacks?: Tile[][];
  /** Torbada kalan taş — 0'da kalıntı = kalan taşların puanı (oyun sonu düşümü). */
  bagCount: number;
}

/** Sıralama anahtarı santipuan: `score * RANK_SCALE + düzeltmeler`. */
const RANK_SCALE = 100;

/** Bölge yeniden sıralamasına giren aday sayısı. */
const TERRITORY_RERANK_WIDTH = 10;

/** İleri bakışa giren aday sayısı (her biri tam bir rakip araması). */
const LOOKAHEAD_WIDTH = 8;

/** Rafa bakmayan ileri bakışta rakibe varsayılan raf (sık harfler + joker). */
const GENERIC_REPLY_LETTERS = ['A', 'E', 'İ', 'K', 'L', 'R', '?'];

/** Sıradaki (teslim olmamış) rakip — reducer'ın `nextActiveIndex`iyle aynı. */
function nextOpponent(players: Player[], from: number): number {
  let i = from;
  for (let step = 0; step < players.length; step++) {
    i = (i + 1) % players.length;
    if (!players[i].surrendered) return i;
  }
  return from;
}

/** Oyuncunun tahtada hiç taşı yoksa ilk hamlesi (reducer `isFirstMove`). */
function hasNoTiles(board: Board, owner: number): boolean {
  for (const row of board) for (const t of row) if (t && t.owner === owner) return false;
  return true;
}

const VOWELS = new Set(['A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü']);

/** Rafta KALAN harfin santipuan değeri (oynanabilirlik sezgiseli). */
const LEAVE_VALUE: Record<string, number> = {
  A: 100, E: 150, İ: 100, I: 0, K: 100, L: 100, N: 100, R: 150, T: 50, M: 50, S: 50,
  D: 0, U: 0, O: 0, Y: 0, B: 0, Ç: -50, Ş: -50, Ü: -50, Z: -100, C: -100, P: -100,
  G: -150, H: -100, F: -200, V: -200, Ö: -200, Ğ: -300, J: -300, '?': 0,
};

/** Hamleden sonra rafta kalan harflerin değeri (santipuan, tam sayı). */
function leaveValue(leave: string[], bagCount: number): number {
  if (bagCount === 0) {
    let pts = 0;
    for (const L of leave) pts += letterPoints(L);
    return -pts * RANK_SCALE;
  }
  let v = 0;
  const seen = new Map<string, number>();
  let vowels = 0;
  let consonants = 0;
  for (const L of leave) {
    v += LEAVE_VALUE[L] ?? 0;
    const c = (seen.get(L) ?? 0) + 1;
    seen.set(L, c);
    if (c === 2) v -= 150;
    else if (c > 2) v -= 300;
    if (L === '?') continue;
    if (VOWELS.has(L)) vowels++;
    else consonants++;
  }
  const imbalance = Math.abs(vowels - consonants);
  if (imbalance > 1) v -= (imbalance - 1) * 100;
  if (vowels === 0 && leave.length >= 3) v -= 200;
  return v;
}

/** Zor düzeltmesi: joker cezası + raf-kalıntı (santipuan). */
function hardAdjust(placements: Placement[], rackLetters: string[], hard: HardOptions): number {
  const leave = [...rackLetters];
  let wilds = 0;
  for (const p of placements) {
    const L = p.tile.wild ? '?' : p.tile.letter;
    if (p.tile.wild) wilds++;
    const i = leave.indexOf(L);
    if (i >= 0) leave.splice(i, 1);
  }
  let adj = -hard.jokerPenalty * wilds * RANK_SCALE;
  if (hard.leaveWeight > 0) {
    adj += Math.trunc((hard.leaveWeight * leaveValue(leave, hard.bagCount)) / 100);
  }
  return adj;
}

/** Bölge farkına göre yeniden sıralar (deterministik, `insertBounded` ile). */
function rerankByTerritory(
  list: Ranked[],
  board: Board,
  players: Player[],
  owner: number,
  territories: Set<string>[],
  weight: number,
  n: number,
): Ranked[] {
  const out: Ranked[] = [];
  for (const item of list) {
    const nb = board.map((row) => [...row]);
    for (const p of item.move.placements) nb[p.r][p.c] = p.tile;
    const t = computeAllTerritories(nb, players);
    let delta = t[owner].size - territories[owner].size;
    for (let i = 0; i < players.length; i++) {
      if (i !== owner) delta += territories[i].size - t[i].size;
    }
    insertBounded(out, { move: item.move, rank: item.rank + weight * delta }, n);
  }
  return out;
}

/**
 * Verilen pozisyon/harf listesi için rafı tüketerek taşları üretir. Tam harf
 * yoksa joker ('?') kullanılır ve taş wild olarak işaretlenir. Raf yetmezse null.
 */
function consumeRack(
  letters: string[],
  rackLetters: string[],
  owner: number,
): Tile[] | null {
  const avail = [...rackLetters];
  const tiles: Tile[] = [];
  for (const L of letters) {
    const i = avail.indexOf(L);
    if (i >= 0) {
      avail.splice(i, 1);
      tiles.push({ letter: L, pts: letterPoints(L), owner });
    } else {
      const wi = avail.indexOf('?');
      if (wi < 0) return null;
      avail.splice(wi, 1);
      tiles.push({ letter: '?', pts: 0, wild: true, wildLetter: L, owner });
    }
  }
  return tiles;
}

/** Sınırlı en-iyi listesinin bir satırı. */
interface Ranked {
  move: AIMove;
  /** Sıralama anahtarı: güvenli listede ham puan, vergili listede YZ'ye kalan. */
  rank: number;
}

/**
 * Azalan `rank` sırasıyla, eşitte SONA (yani ilk bulunan önde) ekler; listeyi
 * `n` boyutunda tutar. Bu, eski tek-en-iyi `if (score > best.score)`
 * karşılaştırmasının (kesin `>`: eşit puanda İLK bulunan kazanır) liste
 * karşılığıdır — `sort` bilerek YOK: kararlılık garantisi olmayan bir sıralama
 * eşit puanlı adayların sırasını değiştirip Dart portuyla pariteyi sessizce
 * kırardı (ROADMAP 23.4). n=1'de liste başı, eski `bestSafe`/`bestAny` ile
 * birebir aynı hamledir (golden vector'lar sıfır farkla kanıtladı).
 */
function insertBounded(list: Ranked[], item: Ranked, n: number): void {
  let i = 0;
  while (i < list.length && list[i].rank >= item.rank) i++;
  if (i >= n) return;
  list.splice(i, 0, item);
  if (list.length > n) list.length = n;
}

/**
 * Sırası gelen YZ oyuncusu için en iyi `n` hamleyi, iyiden kötüye sıralı
 * döndürür (boş liste → pas). `corners` YZ'nin köşeleri, `isFirstMove` bu
 * oyuncunun ilk hamlesi mi. Hiçbir rakip bölgesiyle etkileşmeyen (vergisiz)
 * en az bir hamle varsa liste YALNIZCA onlardan oluşur; yoksa vergili
 * hamlelerden, YZ'ye paylaşım sonrası kalacak puana göre sıralı. Rastgele
 * değer TÜKETMEZ — seçim `pickTopMove`/`findAIMove`'un işi.
 */
export function findAIMoves(
  board: Board,
  rack: Tile[],
  bonuses: Record<string, BonusType>,
  owner: number,
  corners: number[],
  isFirstMove: boolean,
  players: Player[],
  n: number,
  hard?: HardOptions,
): AIMove[] {
  const rackLetters = rack.map((t) => t.letter);
  // Yerel değişken bilerek `pool` adını taşıyor — modül seviyesindeki
  // `wordPools` önbelleğiyle (yukarı) aynı adı taşımak okunabilirliği
  // düşürüyordu (fonksiyonel bir hata yoktu, isim gölgelemesiydi).
  const pool = getWordPool(hard ? hard.maxWordLen : NORMAL_MAX_WORD_LEN);
  // Bölge yeniden sıralaması açıksa arama daha geniş bir liste tutar.
  let width = n;
  if (hard && hard.territoryWeight > 0) width = Math.max(width, TERRITORY_RERANK_WIDTH);
  if (hard && hard.replyWeight > 0) width = Math.max(width, LOOKAHEAD_WIDTH);
  // tryCornerStart dışında hiç kullanılmıyor — bu da yalnızca isFirstMove
  // (ya da nadir freshCorners) dallarında tetikleniyor. Her normal hamlede
  // onbinlerce kelimeyi boşuna filtrelememek için tembel/önbellekli hesap.
  let candidatesCache: string[] | undefined;
  const candidates = (): string[] => {
    if (!candidatesCache) {
      candidatesCache = pool.filter((w) => canSpell(w, rackLetters));
    }
    return candidatesCache;
  };

  // Çapalı hamlelerde kelimenin bir harfi tahtada zaten var olabilir (çapa).
  // O harfi rafta aramaya gerek yok — rafa + çapa harfine göre gevşetilmiş
  // aday listesi, harfe göre önbelleklenir (bu çağrı için — rafın kendisi
  // her hamlede değiştiğinden bu seviyedeki cache modül seviyesine taşınamaz).
  const anchoredCandidatesCache = new Map<string, string[]>();
  const candidatesForAnchor = (letter: string): string[] => {
    let cached = anchoredCandidatesCache.get(letter);
    if (!cached) {
      cached = pool.filter(
        (w) => w.includes(letter) && canSpell(w, [...rackLetters, letter]),
      );
      anchoredCandidatesCache.set(letter, cached);
    }
    return cached;
  };

  // Bir rakip köşesine girilen ya da sınırına dışarıdan değinilen hamlede
  // puan paylaşılır (bkz. computeInvasionSplit) — girmek için artık hiçbir
  // ön koşul yok, her zaman serbest. YZ, mecbur kalmadıkça (böyle bir
  // paylaşım gerektirmeyen geçerli bir hamlesi varken) paylaşım yapmamalı.
  // Bu yüzden iki ayrı sınırlı liste tutulur: `safe` yalnızca hiçbir rakip
  // bölgesiyle etkileşmeyen hamleler için, `any` (paylaşım sonrası kendisine
  // kalacak puana göre sıralanan) tüm hamleler için. `safe` boş değilse her
  // zaman o tercih edilir. (Faz 2'ye kadar iki TEK en-iyi tutuluyordu —
  // `bestSafe`/`bestAny`; n=1 aynı sonucu verir, bkz. insertBounded.)
  const safe: Ranked[] = [];
  const any: Ranked[] = [];

  // Rakiplerin bölgeleri (kendi köşelerinden, kendi taşlarıyla genişleyen
  // dinamik alan) — arama boyunca tahta sabit olduğundan bir kez hesaplanır.
  const territories = computeAllTerritories(board, players);

  const consider = (placements: Placement[], word: string) => {
    const placed: Record<string, Tile> = {};
    for (const p of placements) placed[key(p.r, p.c)] = p.tile;
    // Oluşan tüm kelimeler (çapraz dahil) sözlükte olmalı.
    for (const fw of getFormedWords(board, placed)) {
      if (!getWordSet().has(trLower(fw.word))) return;
    }
    // Yeni taşlardan biri bir rakip bölgesinin içine düşüyorsa (girme) ya da
    // dışarıdan sınırına bitişikse (değme), o bölgeyle puan paylaşılır.
    const touchedIdx = new Set<number>();
    const addIfForeign = (r: number, c: number) => {
      const k = key(r, c);
      for (let i = 0; i < territories.length; i++) {
        if (i !== owner && territories[i].has(k)) touchedIdx.add(i);
      }
    };
    for (const p of placements) {
      addIfForeign(p.r, p.c);
      const neighbors: [number, number][] = [
        [p.r - 1, p.c],
        [p.r + 1, p.c],
        [p.r, p.c - 1],
        [p.r, p.c + 1],
      ];
      for (const [nr, nc] of neighbors) {
        if (nr < 0 || nr >= SIZE || nc < 0 || nc >= SIZE) continue;
        addIfForeign(nr, nc);
      }
    }
    const score = calcScore(board, placed, bonuses);
    const move: AIMove = { word, score, placements };
    const adj = hard ? hardAdjust(placements, rackLetters, hard) : 0;
    if (touchedIdx.size === 0) {
      const rank = score * RANK_SCALE + adj;
      insertBounded(safe, { move, rank }, width);
      insertBounded(any, { move, rank }, width);
      return;
    }
    // Paylaşım sonrası YZ'ye kalacak gerçek puan — validator.ts'teki
    // `computeInvasionSplit`'in AYNI formülü (`round(basePts*(n+1)/(6n))`),
    // burada `territories`nin zaten önbelleğe alınmış olmasından
    // yararlanmak için elle tekrarlanıyor (computeInvasionSplit'in
    // kendisini çağırmak, aday hamle başına computeAllTerritories'i
    // yeniden hesaplayıp arama performansını ciddi biçimde düşürürdü).
    // Önceki hâli n=2/3'te yanlış bir bölen kullanıyordu (bkz. kod
    // incelemesi) — bu, YZ'nin kârlı çoklu-bölge hamlelerini olduğundan
    // az kazançlı sanmasına yol açıyordu.
    const k = touchedIdx.size;
    const share = Math.round((score * (k + 1)) / (6 * k));
    if (hard && hard.netDiff) {
      // Net fark: kendi kaybı + rakibe giden pay birlikte düşülür, hamle
      // güvenlilerle aynı listede yarışır.
      const rank = (score - 2 * share * k) * RANK_SCALE + adj;
      insertBounded(safe, { move, rank }, width);
      insertBounded(any, { move, rank }, width);
      return;
    }
    insertBounded(any, { move, rank: (score - share * k) * RANK_SCALE + adj }, width);
  };

  const finish = (list: Ranked[]): AIMove[] => {
    const ranked =
      hard && hard.territoryWeight > 0
        ? rerankByTerritory(list, board, players, owner, territories, hard.territoryWeight, n)
        : list;
    if (hard && hard.replyWeight > 0) {
      const opp = nextOpponent(players, owner);
      const oppRack: Tile[] | undefined = hard.opponentRacks
        ? hard.opponentRacks[opp]
        : GENERIC_REPLY_LETTERS.map((L) => ({ letter: L, pts: letterPoints(L), owner: opp }));
      if (opp !== owner && oppRack) {
        const out: Ranked[] = [];
        for (const item of ranked.slice(0, LOOKAHEAD_WIDTH)) {
          const nb = board.map((row) => [...row]);
          for (const p of item.move.placements) nb[p.r][p.c] = p.tile;
          const reply = findAIMoves(
            nb, oppRack, bonuses, opp, players[opp].corners, hasNoTiles(nb, opp), players, 1,
          );
          const replyScore = reply.length > 0 ? reply[0].score : 0;
          insertBounded(
            out,
            { move: item.move, rank: item.rank - Math.trunc((hard.replyWeight * replyScore * RANK_SCALE) / 100) },
            n,
          );
        }
        return out.map((x) => x.move);
      }
    }
    if (
      hard &&
      hard.exchangeBelow > 0 &&
      !isFirstMove &&
      hard.bagCount >= RACK_SIZE &&
      ranked.length > 0 &&
      ranked[0].move.score < hard.exchangeBelow
    ) {
      return [];
    }
    return ranked.slice(0, n).map((x) => x.move);
  };

  // Verilen köşeden, tahtadaki mevcut taşlardan bağımsız yeni bir kelimeyle
  // başlayan tüm yerleşimleri dener (yalnızca ilk hamle — her oyuncunun tek
  // köşesi olduğundan bu, o köşe hiç kullanılmamışken geçerli tek durumdur).
  //
  // Kuralın tamamı `validatePlacement`'ta yazılı: ilk hamlenin TEK şartı,
  // konan hücrelerden birinin ev karesi (`cornerCell`) olması — yön ya da
  // "4x4 bloğun içinde başla" şartı YOK. Bu yüzden numaralandırma `tryPlace`
  // ile aynı deseni izler: kelimenin HANGİ harfinin (`idx`) ev karesine
  // denk geleceği tek tek denenir, yani kelime evden her iki yöne de uzayabilir.
  //
  // Önceki hâli başlangıç hücresini kelimenin İLK harfi varsayıp yalnızca
  // sağa/aşağı uzatıyordu (ve başlangıcı 4x4 bloğa hapsediyordu). Bu, oyunun
  // kuralı değil o döngünün kendi kısıtıydı ve sağ-alt köşeyi (ev 12,12)
  // yapısal olarak cezalandırıyordu: eve VARAN bir kelimenin 6. satır/sütundan
  // başlaması gerekir, orası blok dışı olduğundan hiç denenmiyordu — o köşedeki
  // YZ açılışta en fazla 4 taş koyabiliyordu (2 kişilik oyunda YZ her zaman o
  // köşede, yani her oyunda dezavantajlı başlıyordu).
  const tryCornerStart = (homeCorner: number) => {
    const [homeR, homeC] = cornerCell(homeCorner);
    for (const W of candidates()) {
      for (let idx = 0; idx < W.length; idx++) {
        for (const horiz of [true, false]) {
          // W[idx] ev karesine oturur; kelime oradan geriye ve ileriye uzar.
          const sr = horiz ? homeR : homeR - idx;
          const sc = horiz ? homeC - idx : homeC;
          if (sr < 0 || sc < 0) continue;
          const er = horiz ? sr : sr + W.length - 1;
          const ec = horiz ? sc + W.length - 1 : sc;
          if (er >= SIZE || ec >= SIZE) continue;
          let ok = true;
          const positions: [number, number][] = [];
          for (let i = 0; i < W.length; i++) {
            const rr = horiz ? sr : sr + i;
            const cc = horiz ? sc + i : sc;
            if (board[rr][cc]) {
              ok = false;
              break;
            }
            positions.push([rr, cc]);
          }
          if (!ok) continue;
          const tiles = consumeRack(W.split(''), rackLetters, owner);
          if (!tiles) continue;
          consider(
            positions.map(([pr, pc], i) => ({ r: pr, c: pc, tile: tiles[i] })),
            W,
          );
        }
      }
    }
  };

  // ── İlk hamle: kendi köşelerinden birinden başla ────────────────────────────
  if (isFirstMove) {
    for (const homeCorner of corners) tryCornerStart(homeCorner);
    return finish(safe);
  }

  // ── Çapalı hamleler: tahtadaki her taşı eksen alarak dene ────────────────────
  const tryPlace = (
    W: string,
    r: number,
    c: number,
    idx: number,
    horiz: boolean,
  ) => {
    const sr = horiz ? r : r - idx;
    const sc = horiz ? c - idx : c;
    if (horiz) {
      if (sc < 0 || sc + W.length > SIZE) return;
      if (
        !(
          (sc === 0 || !board[r][sc - 1]) &&
          (sc + W.length === SIZE || !board[r][sc + W.length])
        )
      )
        return;
    } else {
      if (sr < 0 || sr + W.length > SIZE) return;
      if (
        !(
          (sr === 0 || !board[sr - 1]?.[c]) &&
          (sr + W.length === SIZE || !board[sr + W.length]?.[c])
        )
      )
        return;
    }

    const newLetters: string[] = [];
    const newPositions: [number, number][] = [];
    for (let i = 0; i < W.length; i++) {
      const rr = horiz ? r : sr + i;
      const cc = horiz ? sc + i : c;
      const existing = board[rr][cc];
      if (existing) {
        if (tileLetter(existing) !== W[i]) return; // mevcut taşla uyuşmuyor
      } else {
        newLetters.push(W[i]);
        newPositions.push([rr, cc]);
      }
    }
    if (newLetters.length === 0) return; // en az bir yeni taş konmalı
    if (newLetters.length > rackLetters.length) return;
    const tiles = consumeRack(newLetters, rackLetters, owner);
    if (!tiles) return;
    consider(
      newPositions.map(([pr, pc], i) => ({ r: pr, c: pc, tile: tiles[i] })),
      W,
    );
  };

  for (let r = 0; r < SIZE; r++) {
    for (let c = 0; c < SIZE; c++) {
      const anchorTile = board[r][c];
      if (!anchorTile) continue;
      const anchor = tileLetter(anchorTile);
      for (const W of candidatesForAnchor(anchor)) {
        let idx = W.indexOf(anchor);
        while (idx >= 0) {
          tryPlace(W, r, c, idx, true);
          tryPlace(W, r, c, idx, false);
          idx = W.indexOf(anchor, idx + 1);
        }
      }
    }
  }

  // Her oyuncunun tek köşesi olduğundan (bkz. cornersFor, constants.ts) bu
  // döngü pratikte hiç tetiklenmez — isFirstMove true iken zaten yukarıdaki
  // dal çalışıyor, o hamleden sonra tek köşe artık "taze" olmaktan çıkıyor.
  // `freshCorners` genel bir yardımcı olduğundan burada da bilgi amaçlı
  // çağrılıyor; oyuncu başına birden fazla köşe atanırsa devreye girer.
  for (const homeCorner of freshCorners(board, corners, owner)) {
    tryCornerStart(homeCorner);
  }

  // Hiçbir rakip köşeyle etkileşmeyen geçerli bir hamle varsa, puanı
  // paylaşmak zorunda kalmamak için o hamleler her zaman tercih edilir.
  // Yalnızca hiç güvenli hamle yoksa (mecburen) rakip köşeye girilir/sınırına
  // değilir — bu durumda da paylaşım sonrası kendisine kalacak puana göre
  // sıralı seçenekler kullanılır.
  return finish(safe.length > 0 ? safe : any);
}

/**
 * Sıralı en-iyi listesinden oynanacak hamleyi seçer — RASTGELELİK SÖZLEŞMESİ
 * (golden vector'lar ve Dart portu buna dayanır): liste boşsa null, tek
 * elemanlıysa o eleman ve `nextRandom()` ÇAĞRILMAZ; birden fazla elemanlıysa
 * TEK `nextRandom()` çağrısı, `floor(r * length)`. Normal (N=1) bu yüzden
 * hiç rastgele değer tüketmez ve eski davranışla bayt-eş kalır; Kolay
 * yalnızca gerçekten seçenek varken tüketir (Faz 0'ın ölçüm aletiyle aynı).
 */
export function pickTopMove(list: AIMove[]): AIMove | null {
  if (list.length === 0) return null;
  if (list.length === 1) return list[0];
  return list[Math.floor(nextRandom() * list.length)];
}

/**
 * Sırası gelen YZ oyuncusu için oynanacak hamle (yoksa null → pas/değişim).
 * `level` kadranı `AI_LEVEL_TOP_N` üzerinden N'e çevrilir: Normal = en iyi
 * hamle (bugüne kadarki davranış), Kolay = en iyi 4'ten rastgele biri, Zor =
 * Faz 5'e kadar Normal. Seviye kuralı `pickTopMove`'un sözleşmesinde.
 */
export function findAIMove(
  board: Board,
  rack: Tile[],
  bonuses: Record<string, BonusType>,
  owner: number,
  corners: number[],
  isFirstMove: boolean,
  players: Player[],
  level: AiLevel = 'normal',
): AIMove | null {
  return pickTopMove(
    findAIMoves(board, rack, bonuses, owner, corners, isFirstMove, players, AI_LEVEL_TOP_N[level]),
  );
}
