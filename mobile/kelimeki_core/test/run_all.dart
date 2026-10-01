// Kelimeki core — golden vector parite testleri.
//
// Fixture'lar web'in ÜRETİM motorundan üretilir
// (scripts/generate-golden-vectors.ts, repo kökünde); bu dosya aynı
// action'ları Dart motorunda aynı tohumla yeniden oynatıp state'leri derin
// karşılaştırır. Koşturma: `dart run test/run_all.dart` (kelimeki_core
// dizininden; önce `dart pub get`).
import 'dart:convert';
import 'dart:io';

import 'package:kelimeki_core/kelimeki_core.dart';

import 'support/action_codec.dart';
import 'support/mini_test.dart';

late final SetWordSource words;

Map<String, Object?> loadGolden(String name) {
  final f = File('test/goldens/$name.json');
  return (jsonDecode(f.readAsStringSync()) as Map).cast<String, Object?>();
}

void testTurkish() {
  final g = loadGolden('turkish');
  for (final row in g['lower'] as List) {
    final input = (row as List)[0] as String;
    final expected = row[1] as String;
    check(trLower(input) == expected,
        () => 'turkish.lower("$input"): "${trLower(input)}" != "$expected"');
  }
  for (final row in g['upper'] as List) {
    final input = (row as List)[0] as String;
    final expected = row[1] as String;
    check(trUpper(input) == expected,
        () => 'turkish.upper("$input"): "${trUpper(input)}" != "$expected"');
  }
  for (final row in g['compare'] as List) {
    final a = (row as List)[0] as String;
    final b = row[1] as String;
    final expected = row[2] as int;
    final got = trCompare(a, b);
    final sign = got > 0 ? 1 : (got < 0 ? -1 : 0);
    check(sign == expected, () => 'turkish.compare("$a","$b"): $sign != $expected');
  }
}

/// Bölge (fetih zinciri) paritesi. 24 Ağustos 2026'da eklendi: o gün gelen
/// "kendi bloğundaki DESTEKSİZ rakip taşı zinciri kesmez, İLETKENdir" kuralı
/// mevcut fixture'ların hiçbirinde geçmiyordu — golden'lar yeniden üretilince
/// SIFIR fark çıkmıştı, yani iki motor bu kuralda sessizce ayrışabilirdi.
/// Vakalar elle kurgulandı; `destekli_rakip_tasi_keser` kuralın NEGATİF
/// dalını tutuyor (rakip bölgesini gerçekten oraya taşımışsa hücre onundur).
void testTerritory() {
  final g = loadGolden('territory');
  for (final raw in g['cases'] as List) {
    final c = (raw as Map).cast<String, Object?>();
    final name = c['name'] as String;

    final board = List.generate(
        boardSize, (_) => List<Tile?>.filled(boardSize, null),
        growable: false);
    for (final rc in c['cells'] as List) {
      final cell = (rc as Map).cast<String, Object?>();
      board[cell['r'] as int][cell['c'] as int] =
          Tile(letter: 'A', pts: 1, owner: cell['owner'] as int);
    }

    final players = <Player>[];
    final specs = c['players'] as List;
    for (var i = 0; i < specs.length; i++) {
      final sp = (specs[i] as Map).cast<String, Object?>();
      players.add(Player(
        name: 'P$i',
        corners: (sp['corners'] as List).cast<int>(),
        colorIndex: i,
        isAI: false,
        surrendered: sp['surrendered'] as bool,
        rack: const [],
        score: 0,
        bestMoveScore: 0,
        bestWordScore: 0,
        longestWord: '',
        moveCount: 0,
        moveScoreSum: 0,
      ));
    }

    final got = computeAllTerritories(board, players);
    final expected = (c['territories'] as List)
        .map((t) => (t as List).cast<String>().toList()..sort())
        .toList();
    check(got.length == expected.length,
        () => 'territory[$name]: oyuncu sayısı ${got.length} != ${expected.length}');
    for (var i = 0; i < got.length; i++) {
      final mine = got[i].toList()..sort();
      check(mine.length == expected[i].length && mine.join(' ') == expected[i].join(' '),
          () => 'territory[$name] P$i:\n  got      ${mine.join(" ")}\n  expected ${expected[i].join(" ")}');
    }
    // DEĞİŞMEZ: bir hücre en fazla TEK oyuncunun bölgesinde olabilir.
    final sayac = <String, int>{};
    for (final t in got) {
      for (final k in t) {
        sayac[k] = (sayac[k] ?? 0) + 1;
      }
    }
    final cakisan = sayac.entries.where((e) => e.value > 1).map((e) => e.key).toList();
    check(cakisan.isEmpty,
        () => 'territory[$name]: iki bölgede birden görünen hücre: ${cakisan.join(" ")}');
  }
}

/// YZ seviye kadranları: `aiLevelTopN` ↔ web `AI_LEVEL_TOP_N` ve
/// `aiLevelSearch` ↔ web `AI_LEVEL_SEARCH` (golden `ai_level.json`). Kolay'ın
/// ve Zor'un DAVRANIŞI ayrıca `reducer_ai2_kolay` / `reducer_ai2_zor`
/// senaryolarıyla kanıtlanır; bu test yalnızca sabitlerin ayrışmadığını
/// kilitler.
void testAiLevel() {
  final g = loadGolden('ai_level');
  final topN = (g['topN'] as Map).cast<String, Object?>();
  for (final level in AiLevel.values) {
    final expected = topN[level.json];
    check(expected == aiLevelTopN[level],
        () => 'ai_level.topN[${level.json}]: ${aiLevelTopN[level]} != $expected');
  }
  check(topN.length == AiLevel.values.length,
      () => 'ai_level.topN: ${topN.length} seviye, Dart ${AiLevel.values.length}');
  final search = (g['search'] as Map).cast<String, Object?>();
  for (final level in AiLevel.values) {
    final expected = (search[level.json] as Map).cast<String, Object?>();
    final got = aiLevelSearch[level]!;
    check(expected['wide'] == got.wide && expected['maxWordLen'] == got.maxWordLen,
        () => 'ai_level.search[${level.json}]: Dart wide=${got.wide}/maxWordLen=${got.maxWordLen} != $expected');
  }
  check(search.length == AiLevel.values.length,
      () => 'ai_level.search: ${search.length} seviye, Dart ${AiLevel.values.length}');
}

void testInvasionFormula() {
  final g = loadGolden('invasion_formula');
  final maxBase = g['maxBase'] as int;
  final shares = (g['shares'] as Map).cast<String, Object?>();
  for (final n in [1, 2, 3]) {
    final expected = (shares['$n'] as List).cast<int>();
    for (var base = 0; base <= maxBase; base++) {
      final got = invasionShare(base, n);
      check(got == expected[base],
          () => 'invasionShare($base, $n): $got != ${expected[base]}');
    }
  }
}

Player _stubPlayer(int score, bool surrendered) => Player(
      name: '',
      corners: const [0],
      colorIndex: 0,
      isAI: false,
      surrendered: surrendered,
      rack: const [],
      score: score,
      bestMoveScore: 0,
      bestWordScore: 0,
      longestWord: '',
      moveCount: 0,
      moveScoreSum: 0,
    );

void testRanking() {
  final g = loadGolden('ranking');
  var ci = 0;
  for (final c in g['cases'] as List) {
    final m = (c as Map).cast<String, Object?>();
    final specs = [
      for (final p in m['players'] as List)
        (
          score: (p as Map)['score'] as int,
          surrendered: p['surrendered'] as bool,
        ),
    ];
    final players = [for (final s in specs) _stubPlayer(s.score, s.surrendered)];

    final ranked = rankPlayers(players);
    final expectedRanked = [
      for (final r in m['ranked'] as List)
        (index: (r as Map)['index'] as int, rank: r['rank'] as int),
    ];
    check(ranked.length == expectedRanked.length,
        () => 'ranking[$ci]: uzunluk ${ranked.length}');
    for (var i = 0; i < ranked.length && i < expectedRanked.length; i++) {
      check(
          ranked[i].index == expectedRanked[i].index &&
              ranked[i].rank == expectedRanked[i].rank,
          () =>
              'ranking[$ci][$i]: (${ranked[i].index},${ranked[i].rank}) != (${expectedRanked[i].index},${expectedRanked[i].rank})');
    }

    final snapshots = [
      for (final s in specs)
        PlayerSnapshot(score: s.score, surrendered: s.surrendered),
    ];
    final ranks = computeRanks(snapshots);
    final expectedRanks = (m['ranks'] as List).cast<int>();
    check(jsonDiff(expectedRanks, ranks) == null,
        () => 'ranking[$ci].computeRanks: $ranks != $expectedRanks');

    final expectedLeague = (m['league'] as List).cast<int>();
    for (var i = 0; i < specs.length; i++) {
      final got = leaguePoints(ranks[i], specs.length,
          surrendered: specs[i].surrendered);
      check(got == expectedLeague[i],
          () => 'ranking[$ci].league[$i]: $got != ${expectedLeague[i]}');
    }
    ci++;
  }
}

void testScoring() {
  final g = loadGolden('scoring');
  var ci = 0;
  for (final c in g['cases'] as List) {
    final m = (c as Map).cast<String, Object?>();
    final board = createEmptyBoard();
    for (final bc in m['board'] as List) {
      final b = (bc as Map).cast<String, Object?>();
      board[b['r'] as int][b['c'] as int] =
          Tile.fromJson((b['tile'] as Map).cast<String, Object?>());
    }
    final placed = <String, Tile>{
      for (final e in (m['placed'] as Map).entries)
        e.key as String: Tile.fromJson((e.value as Map).cast<String, Object?>()),
    };
    final bonuses = {'6,6': BonusType.tw};
    final total = calcScore(board, placed, bonuses);
    check(total == m['total'] as int,
        () => 'scoring[$ci].total: $total != ${m['total']}');
    final wordsGot = [for (final w in calcWordRawScores(board, placed, bonuses)) w.toJson()];
    final d = jsonDiff(m['words'], wordsGot);
    check(d == null, () => 'scoring[$ci].words: fark $d');
    ci++;
  }
}

/// "Kalan Taşlar" (TORBA) dökümü paritesi — `remainingTiles`.
///
/// Bu fonksiyonun 18 Ağustos 2026'ya kadar hiç parite kapsaması yoktu; tam o
/// gün iki tarafta birden aynı hata bulundu (bekleyen `placed` taşlar
/// "dışarıda" sayılıyordu). Vektörler bekleyen taşlı ve jokerli durumları
/// içeriyor.
void testRemainingTiles() {
  final g = loadGolden('remaining_tiles');
  Tile decode(String shown, bool wild) => wild
      ? Tile(letter: '?', pts: 0, wild: true, wildLetter: shown)
      : Tile(letter: shown, pts: tileData[shown]!.pts);

  var ci = 0;
  for (final c in g['cases'] as List) {
    final m = (c as Map).cast<String, Object?>();
    final board = <List<Tile?>>[
      for (var r = 0; r < 13; r++) List<Tile?>.filled(13, null)
    ];
    for (final e in m['board'] as List) {
      final row = e as List;
      board[row[0] as int][row[1] as int] =
          decode(row[2] as String, row[3] as bool);
    }
    final rack = [
      for (final e in m['rack'] as List)
        decode((e as List)[0] as String, e[1] as bool)
    ];
    final placed = [
      for (final e in m['placed'] as List)
        decode((e as List)[0] as String, e[1] as bool)
    ];
    final got = [
      for (final r in remainingTiles(board, rack, placed))
        [r.letter, r.pts, r.count]
    ];
    final d = jsonDiff(m['rows'], jsonDecode(jsonEncode(got)));
    check(d == null, () => 'remaining_tiles[$ci]: fark $d');
    ci++;
  }
}

/// Taş değiştirmenin üst sınırı (14 Eylül 2026, kullanıcı raporu — Asnmzr).
///
/// Golden vector'larla KANITLANAMAZ ve bu bilinçli: fixture'lar web ile
/// Dart'ı karşılaştırır, yani ikisinde BİRDEN var olan bir kuralsızlığa
/// kördür — bu hata tam olarak öyleydi (torbada 4 taş kalmışken 7 taş
/// değiştirilebiliyordu, taş korunumu da bozulmuyordu). Web ikizi:
/// scripts/verify-swap-invariants.ts'in 5. ve 6. bölümleri.
void testSwapLimit() {
  final engine = GameEngine(
    words: words,
    rng: Mulberry32(4242),
    nowIso: () => '',
  );
  GameState basla() => engine.reduce(
        createInitialState(),
        const StartAction([
          PlayerSetup(name: 'Ben', isAI: false),
          PlayerSetup(name: 'Rakip', isAI: false),
        ]),
      );

  // ── Sınır: torba 4 iken 5. taş seçilemez ──────────────────────────────
  {
    var s = basla();
    s = s.copyWith(bag: s.bag.sublist(0, 4));
    s = engine.reduce(s, const ToggleSwapModeAction());
    for (var i = 0; i < 7; i++) {
      s = engine.reduce(s, ToggleSwapTileAction(i));
    }
    check(s.swapSelection.length == 4,
        () => 'swap sınırı: seçili ${s.swapSelection.length}, 4 olmalı');
    check(s.message == swapLimitMessage(4) && s.messageType == MessageKind.err,
        () => 'swap sınırı uyarısı: "${s.message}"');

    final after = engine.reduce(s, const ConfirmSwapAction());
    check(after.moveHistory.last.tileCount == 4,
        () => 'sınıra uyan değişim: ${after.moveHistory.last.tileCount}');
  }

  // ── Sınırın ALTI engellenmemeli (kapı aşırı hevesli olmasın) ──────────
  {
    var s = basla();
    s = s.copyWith(bag: s.bag.sublist(0, 4));
    s = engine.reduce(s, const ToggleSwapModeAction());
    s = engine.reduce(s, const ToggleSwapTileAction(0));
    s = engine.reduce(s, const ToggleSwapTileAction(1));
    check(s.swapSelection.length == 2 && s.messageType != MessageKind.err,
        () => 'sınırın altındaki seçim engellendi: "${s.message}"');
  }

  // ── Sınır UI'ya emanet DEĞİL: reducer kendi kapısını tutuyor ──────────
  // Torba SEÇİMDEN SONRA küçülüyor — UI'nın hiç göremediği sıra.
  {
    var s = basla();
    s = engine.reduce(s, const ToggleSwapModeAction());
    for (var i = 0; i < 7; i++) {
      s = engine.reduce(s, ToggleSwapTileAction(i));
    }
    check(s.swapSelection.length == 7,
        () => 'senaryo kurulamadı: seçili ${s.swapSelection.length}');
    s = s.copyWith(bag: s.bag.sublist(0, 2));
    final onceki = s.current;
    final after = engine.reduce(s, const ConfirmSwapAction());
    check(
        after.messageType == MessageKind.err &&
            after.message == swapLimitMessage(2),
        () => 'reducer sınırı aşan değişimi kabul etti: "${after.message}"');
    check(after.current == onceki, () => 'reddedilen değişimde sıra ilerledi');
  }

  // ── YZ'nin zorunlu değişimi elde KALAN taşları silmemeli (26 Eyl 2026) ──
  // Torba 4 iken hamle bulamayan YZ 4 taş değiştiriyor; raf 7'de kalmalı ve
  // oyundaki toplam taş sayısı değişmemeli. Web ikizi: verify-swap §7.
  {
    var s = engine.reduce(
      createInitialState(),
      const StartAction([
        PlayerSetup(name: 'Ben', isAI: false),
        PlayerSetup(name: 'YZ', isAI: true),
      ]),
    );
    const g = Tile(letter: 'Ğ', pts: 8); // hiçbir kelime kuramayan raf
    s = s.copyWith(
      current: 1,
      bag: s.bag.sublist(0, 4),
      players: [
        s.players[0],
        s.players[1].copyWith(rack: List.filled(7, g)),
      ],
    );
    int toplam(GameState x) =>
        x.bag.length +
        x.players.fold<int>(0, (n, p) => n + p.rack.length) +
        x.board.expand((r) => r).where((t) => t != null).length;
    final once = toplam(s);
    final after = engine.reduce(s, const AiPlayAction());
    check(after.moveHistory.last.action == 'exchange',
        () => 'YZ değişim senaryosu kurulamadı: ${after.moveHistory.last.action}');
    check(after.moveHistory.last.tileCount == 4,
        () => 'YZ değişimi: ${after.moveHistory.last.tileCount} taş, 4 olmalı');
    check(after.players[1].rack.length == 7,
        () => 'YZ rafı ${after.players[1].rack.length} taşa düştü, 7 olmalı');
    check(toplam(after) == once,
        () => 'YZ değişiminde taş kayboldu: $once → ${toplam(after)}');
    check(after.message == 'YZ 4 taş değiştirdi ve sırasını kullandı.',
        () => 'YZ değişim mesajı: "${after.message}"');
  }
}

void testReducerScenario(String name) {
  final g = loadGolden(name);
  final seed = g['seed'] as int;
  final engine = GameEngine(
    words: words,
    rng: Mulberry32(seed),
    nowIso: () => '',
  );
  var state = createInitialState();
  var si = 0;
  for (final step in g['steps'] as List) {
    final m = (step as Map).cast<String, Object?>();
    final action = decodeAction((m['action'] as Map).cast<String, Object?>());
    state = engine.reduce(state, action);
    final expected = m['state'];
    if (expected != null) {
      final actual = gameStateToJson(state);
      final d = jsonDiff(expected, actual);
      check(d == null,
          () => '$name adım $si (${(m['action'] as Map)['type']}): fark $d');
      if (d != null) return; // ayrışan state'ten sonrası anlamsız — kes
    }
    si++;
  }
}

void main() {
  final wordsFile = File('../app/assets/dictionary/words_tr.txt');
  if (!wordsFile.existsSync()) {
    stderr.writeln('words_tr.txt yok — önce `npm run generate-golden-vectors` koş.');
    exit(2);
  }
  words = SetWordSource(
    const LineSplitter().convert(wordsFile.readAsStringSync()).where((w) => w.isNotEmpty),
  );
  stdout.writeln('sözlük: ${words.length} kelime');

  testTurkish();
  testAiLevel();
  testInvasionFormula();
  testTerritory();
  testRanking();
  testScoring();
  testRemainingTiles();
  testSwapLimit();
  for (final name in [
    'reducer_ai2',
    'reducer_ai2_kolay',
    'reducer_ai2_zor',
    'reducer_ai4',
    'reducer_human2',
    'reducer_crafted_finish',
    'reducer_crafted_bingo',
    'reducer_crafted_ai_exchange',
    'reducer_crafted_swap_draft',
    'reducer_sync',
  ]) {
    testReducerScenario(name);
  }
  summarizeAndExit();
}
