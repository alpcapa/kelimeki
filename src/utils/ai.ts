// Kelimeki — YZ rakip mantığı (çok oyunculu, köşe temelli)
//
// YZ, rafından heceleyebildiği kelimeler arasından, bölge kurallarına uyan
// ve sözlükçe geçerli en yüksek puanlı hamleyi arar. İlk hamlesini kendi
// köşesinden başlatır; sonra mevcut taşları çapa alarak yeni kelimeler kurar.
import { AI_LEVEL_SEARCH, AI_LEVEL_TOP_N, SIZE, cornerCell, type AiSearch } from '../game/constants';
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
//
// Havuz üst sınırına (`AiSearch.maxWordLen`) göre ayrı önbellek: Normal/Kolay
// 7, Zor 8 (bkz. constants.ts, AI_LEVEL_SEARCH).
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
 *
 * `search` aramanın GENİŞLİĞİ (ROADMAP #23 Faz 5): Normal/Kolay yalnızca
 * tahtadaki tek bir taştan (çapa) geçen hattı dener; Zor (`wide`) ayrıca
 * (1) bir taşa komşu boş "kanca" hücresinden başlayan PARALEL dizişleri —
 * tüm taşlar yeni, bağlantı çapraz kelimelerle — ve (2) aynı hattaki birden
 * çok tahta taşından geçen kelimeleri dener. Bu iki sınıf Normal'in hiç
 * görmediği hamleler; kural her zaman izin veriyordu (validatePlacement:
 * "konan taşlardan biri mevcut bir taşa komşu" yeter).
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
  search: AiSearch = AI_LEVEL_SEARCH.normal,
): AIMove[] {
  const rackLetters = rack.map((t) => t.letter);
  // Yerel değişken bilerek `pool` adını taşıyor — modül seviyesindeki
  // `wordPools` önbelleğiyle (yukarı) aynı adı taşımak okunabilirliği
  // düşürüyordu (fonksiyonel bir hata yoktu, isim gölgelemesiydi).
  const pool = getWordPool(search.maxWordLen);
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

  // Geniş arama: hat (satır/sütun) başına aday süzgeci — raf + o hattaki
  // TÜM tahta harfleri (kapsayıcı bir ön eleme; kesin eşleşmeyi tryPlace ve
  // consider doğrular). Çok çapalı kelimeler ancak böyle adaya girer; en
  // fazla 26 hat, her biri bu çağrı için bir kez süzülür.
  const lineCandidatesCache = new Map<string, string[]>();
  const candidatesForLine = (horiz: boolean, index: number): string[] => {
    const cacheKey = (horiz ? 'r' : 'c') + index;
    let cached = lineCandidatesCache.get(cacheKey);
    if (!cached) {
      const avail = [...rackLetters];
      for (let i = 0; i < SIZE; i++) {
        const t = horiz ? board[index][i] : board[i][index];
        if (t) avail.push(tileLetter(t));
      }
      cached = pool.filter((w) => w.length <= avail.length && canSpell(w, avail));
      lineCandidatesCache.set(cacheKey, cached);
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
    if (touchedIdx.size === 0) {
      insertBounded(safe, { move, rank: score }, n);
      insertBounded(any, { move, rank: score }, n);
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
    insertBounded(any, { move, rank: score - share * k }, n);
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
    return safe.map((x) => x.move);
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

  // Kanca hücresi: boş ve dört komşusundan en az biri dolu.
  const hasNeighbor = (r: number, c: number): boolean =>
    (r > 0 && !!board[r - 1][c]) ||
    (r < SIZE - 1 && !!board[r + 1][c]) ||
    (c > 0 && !!board[r][c - 1]) ||
    (c < SIZE - 1 && !!board[r][c + 1]);

  // ⚠ Döngü SIRASI davranışın parçası (consider eşit puanda İLK bulunanı
  // tutar) — Dart `find_move.dart` ve Edge kopyası birebir aynı sırayı izler.
  // Geniş aramada aynı yerleşim birden çok kanca/çapadan yeniden üretilebilir;
  // n=1'de zararsız (ilk bulunan kalır), n>1'de liste aynı hamleyi iki kez
  // taşıyabilir — Zor N=1 olduğundan bilerek ayıklanmıyor.
  for (let r = 0; r < SIZE; r++) {
    for (let c = 0; c < SIZE; c++) {
      const anchorTile = board[r][c];
      if (!anchorTile) {
        // Geniş arama — kanca hücresi: W[idx] buraya (yeni taş) gelir, hattaki
        // mevcut taşlar tryPlace'te eşleşmek zorunda (paralel diziş).
        if (!search.wide || !hasNeighbor(r, c)) continue;
        for (const horiz of [true, false]) {
          for (const W of candidatesForLine(horiz, horiz ? r : c)) {
            for (let idx = 0; idx < W.length; idx++) tryPlace(W, r, c, idx, horiz);
          }
        }
        continue;
      }
      const anchor = tileLetter(anchorTile);
      if (search.wide) {
        // Geniş arama — çapa: aday süzgeci hattın harfleriyle (çok çapa).
        for (const horiz of [true, false]) {
          for (const W of candidatesForLine(horiz, horiz ? r : c)) {
            let idx = W.indexOf(anchor);
            while (idx >= 0) {
              tryPlace(W, r, c, idx, horiz);
              idx = W.indexOf(anchor, idx + 1);
            }
          }
        }
        continue;
      }
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
  return (safe.length > 0 ? safe : any).map((x) => x.move);
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
 * `level` iki kadrana çevrilir: `AI_LEVEL_TOP_N` (Normal = en iyi hamle,
 * Kolay = en iyi 4'ten rastgele biri, Zor = en iyi hamle) ve `AI_LEVEL_SEARCH`
 * (Zor geniş arar, bkz. findAIMoves). Rastgelelik `pickTopMove`'un
 * sözleşmesinde — Zor da Normal gibi hiç rastgele değer tüketmez.
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
    findAIMoves(
      board, rack, bonuses, owner, corners, isFirstMove, players,
      AI_LEVEL_TOP_N[level], AI_LEVEL_SEARCH[level],
    ),
  );
}
