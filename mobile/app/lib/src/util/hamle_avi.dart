// "Hamle Avı" saf mantığı — web `src/utils/hamleAvi.ts` + `hamleAviSolve.ts`
// portu (ROADMAP #48, 3 Kasım 2026). `hamle_avi_parity_test.dart` sabitleri,
// banka şeklini ve çözücünün bankayla AYNI anahtarı verdiğini kilitler.
//
// Motora DOKUNMAZ (kök CLAUDE.md, tanıtımla aynı yalıtım): yeni action/alan
// yok. Pozisyon `createTutorialState` gibi doğrudan kurulan sıradan bir
// `GameState`'tir; hamle gerçek `PlayAction`ından geçer (vergi dahil net puan
// = skor farkı).
import 'dart:convert';
import 'dart:math';

import 'package:kelimeki_core/kelimeki_core.dart';

/// Bir bulmaca için süre (sn). Web `HAMLE_AVI_SECONDS`.
const int kHamleAviSeconds = 3 * 60;

/// Son bu kadar saniyede geri sayım kırmızıya döner.
const int kHamleAviWarnSeconds = 30;

/// Sunucuya gönderilebilecek en yüksek makul rekor (RPC ile AYNI sayı).
const int kMaxPlausibleStreak = 5000;

/// Tanıtım penceresindeki üç madde — web `HAMLE_AVI_INTRO_POINTS`.
const List<String> kHamleAviIntroPoints = [
  'Bölge vergisi puana dahildir.',
  'Bulursan sıradakine geç, istediğin kadar devam et.',
  'k-lig puanını etkilemez.',
];

/// Bankadaki tek pozisyon (sıkıştırılmış JSON).
class HamleAviPosition {
  final int id;

  /// Sıra sahibinin indeksi (0 ya da 1).
  final int o;

  /// Tahtadaki taşlar: (satır, sütun, harf, sahip, joker mi).
  final List<({int r, int c, String letter, int owner, bool wild})> tiles;

  /// Raf — 7 harf, '?' = joker.
  final String rack;

  /// Anahtar: en iyi hamlenin VERGİ DAHİL net puanı.
  final int k;

  /// En iyi hamlenin ana kelimesi.
  final String w;

  const HamleAviPosition({
    required this.id,
    required this.o,
    required this.tiles,
    required this.rack,
    required this.k,
    required this.w,
  });

  factory HamleAviPosition.fromJson(Map<String, Object?> j) {
    final raw = j['t']! as List<Object?>;
    return HamleAviPosition(
      id: j['id']! as int,
      o: j['o']! as int,
      tiles: [
        for (final item in raw) _tileFromRow(item! as List<Object?>),
      ],
      rack: j['r']! as String,
      k: j['k']! as int,
      w: j['w']! as String,
    );
  }
}

({int r, int c, String letter, int owner, bool wild}) _tileFromRow(
        List<Object?> e) =>
    (
      r: e[0]! as int,
      c: e[1]! as int,
      letter: e[2]! as String,
      owner: e[3]! as int,
      wild: e.length > 4 && e[4] == 1,
    );

/// Banka JSON'unu (`assets/hamle_avi/bank.json`) ayrıştırır.
List<HamleAviPosition> parseHamleAviBank(String raw) => [
      for (final j in jsonDecode(raw) as List<Object?>)
        HamleAviPosition.fromJson((j! as Map).cast<String, Object?>()),
    ];

Tile _tileFromLetter(String letter) => letter == '?'
    ? const Tile(letter: '?', pts: 0)
    : Tile(letter: letter, pts: letterPoints(letter));

/// Pozisyonu oynanabilir `GameState`e çevirir (iki insan koltuğu, sıra `o`da).
GameState hamleAviPositionToState(HamleAviPosition pos, String myName) {
  final corners = cornersFor(2);
  final board = createEmptyBoard();
  for (final t in pos.tiles) {
    board[t.r][t.c] = t.wild
        ? Tile(
            letter: '?',
            pts: 0,
            wild: true,
            wildLetter: t.letter,
            owner: t.owner)
        : _tileFromLetter(t.letter).copyWith(owner: t.owner);
  }
  final names = [
    pos.o == 0 ? myName : 'Rakip',
    pos.o == 1 ? myName : 'Rakip',
  ];
  final players = [
    for (var i = 0; i < 2; i++)
      Player(
        name: names[i],
        corners: corners[i],
        colorIndex: i % playerColorCount,
        isAI: false,
        surrendered: false,
        // Rakibin rafı/torba DOLGU: boş olsaydı bingo'lu bir hamle oyunu
        // BİTİRİR ve `endGame` raf düşümü net puanı bozardı.
        rack: i == pos.o
            ? [for (final ch in pos.rack.split('')) _tileFromLetter(ch)]
            : [for (var n = 0; n < 7; n++) _tileFromLetter('E')],
        score: 0,
        bestMoveScore: 0,
        bestWordScore: 0,
        longestWord: '',
        moveCount: 0,
        moveScoreSum: 0,
      ),
  ];
  return GameState(
    phase: GamePhase.play,
    startedAt: DateTime.now().toUtc().toIso8601String(),
    multiSession: false,
    endReason: EndReason.normal,
    board: board,
    bag: [for (var n = 0; n < 20; n++) _tileFromLetter('E')],
    bonuses: buildInitialBonuses(),
    placed: const {},
    players: players,
    current: pos.o,
    selectedTile: null,
    swapMode: false,
    swapSelection: const [],
    turnCount: 10, // ilk hamle değil; sayaç yalnızca gösterim
    consecutivePasses: 0,
    isGameOver: false,
    message: '',
    messageType: MessageKind.none,
    lastMoveCells: const [],
    moveHistory: const [],
  );
}

/// Oyuncunun bu bulmacadaki NET kazancı (PLAY sonrası skor farkı).
int hamleAviNetGain(GameState before, GameState after) =>
    after.players[before.current].score - before.players[before.current].score;

/// Net puan anahtara ULAŞIYORSA (eşit ya da yüksek) doğru.
bool hamleAviIsCorrect(int net, HamleAviPosition pos) => net >= pos.k;

/// Görülmemiş pozisyonlardan rastgele biri; hepsi görüldüyse null.
HamleAviPosition? hamleAviPickNext(
  List<HamleAviPosition> bank,
  Set<int> seen,
  Random rng,
) {
  final rest = [
    for (final p in bank)
      if (!seen.contains(p.id)) p
  ];
  if (rest.isEmpty) return null;
  return rest[rng.nextInt(rest.length)];
}

/// İki görülenler listesinin birleşimi (cihaz ↔ sunucu), artan sıralı.
List<int> hamleAviMergeSeen(List<int> a, List<int> b) =>
    ({...a, ...b}.toList()..sort());

/// Seri/rekor durumu.
class HamleAviStreak {
  final int streak;
  final int best;
  const HamleAviStreak(this.streak, this.best);
}

HamleAviStreak hamleAviOnFound(HamleAviStreak s) {
  final streak = s.streak + 1;
  return HamleAviStreak(streak, max(s.best, streak));
}

HamleAviStreak hamleAviOnMissed(HamleAviStreak s) => HamleAviStreak(0, s.best);

bool hamleAviShouldWarnOnLeave(HamleAviStreak s) => s.streak > 0;

// ── Çözücü (süre bitince doğru hamle) ─────────────────────────────────────

class HamleAviBestMove {
  final AIMove move;

  /// Vergi DAHİL net puan (= `HamleAviPosition.k`).
  final int net;
  const HamleAviBestMove(this.move, this.net);
}

/// Pozisyonun en iyi NET hamlesi — web `findBestNetMove`. Rakipler "teslim
/// olmuş" kopyalanır (bölgeleri boş → `findAIMoves` vergisiz, ham puana göre
/// sıralı liste verir); her aday gerçek `computeInvasionSplit` ile NET puana
/// çevrilir.
HamleAviBestMove? hamleAviFindBestNetMove(GameState state, WordSource words,
    {int listN = 300}) {
  final owner = state.current;
  final me = state.players[owner];
  final noTax = [
    for (var i = 0; i < state.players.length; i++)
      i == owner
          ? state.players[i]
          : state.players[i].copyWith(surrendered: true),
  ];
  final raw = findAIMoves(
    state.board,
    me.rack,
    state.bonuses,
    owner,
    me.corners,
    isFirstMove(state),
    noTax,
    words,
    listN,
    search: aiLevelSearch[AiLevel.zor]!,
  );
  HamleAviBestMove? best;
  for (final m in raw) {
    final coords = [for (final p in m.placements) (p.r, p.c)];
    final net =
        computeInvasionSplit(coords, owner, state.players, m.score, state.board)
            .pts;
    if (best == null || net > best.net) best = HamleAviBestMove(m, net);
  }
  return best;
}
