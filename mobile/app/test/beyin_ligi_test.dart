// Beyin Ligi (2 Ekim 2026) — k-lig'in OHP alt ligi.
//
// İki kapı:
// 1) PARİTE: metinler, sekme etiketleri/ikonları ve giriş eşiği web
//    kaynağıyla BİREBİR (`src/utils/beyinLigi.ts`, `BeyinLigiList.tsx`,
//    `Leaderboard.tsx`). Eşiğin SQL yarısını `npm run verify-beyin-ligi`
//    kilitliyor.
// 2) DAVRANIŞ: pencere Puan Ligi ile açılır; Beyin Ligi sekmesi OHP
//    listesini (puan/mühür YOK) çizer; eşiğin altındaki kullanıcı
//    "N oyun daha" kartını görür; sekmeler arası gidip gelmek listeyi
//    yeniden İSTEMEZ.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/rank/rank_seal.dart';
import 'package:kelimeki/src/ui/score/beyin_ligi_list.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/beyin_ligi.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import 'support/test_fonts.dart';
import 'support/test_view.dart';
import 'support/web_source.dart';

class _Gateway implements StatsGateway {
  final List<Map<String, Object?>> beyinRows;
  final Map<String, Object?>? mine;
  final beyinRequests = <({int limit, int offset})>[];

  _Gateway({this.beyinRows = const [], this.mine});

  @override
  Future<List<Map<String, Object?>>> beyinLigi(int limit, int offset) async {
    beyinRequests.add((limit: limit, offset: offset));
    return beyinRows.skip(offset).take(limit).toList();
  }

  @override
  Future<Map<String, Object?>?> myBeyinLigiRank(String userId) async => mine;

  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async =>
      offset > 0
          ? const []
          : const [
              {
                'sira': 1,
                'user_id': 'u-1',
                'display_name': 'Puancı',
                'total_score': 120,
                'avg_move_score': 12.5,
              },
            ];

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async => null;

  @override
  Future<Map<String, Object?>?> playerStats(
          String userId, int? playerCount) async =>
      null;

  @override
  Future<List<Map<String, Object?>>> rankScores(List<String> userIds) async =>
      const [];

  @override
  Future<Map<String, Object?>?> profileAgeGender(String userId) async => null;

  @override
  Future<Map<String, Object?>?> headToHead(String otherUserId) async => null;
}

User _user() => User(
      id: 'u-me',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    );

const _beyinRows = [
  {
    'sira': 1,
    'user_id': 'u-a',
    'display_name': 'Mert',
    'ohp_games': 55,
    'avg_move_score': 15.17,
  },
  {
    'sira': 2,
    'user_id': 'u-b',
    'display_name': 'Selin',
    'ohp_games': 23,
    'avg_move_score': 15.11,
  },
];

Future<void> _pump(WidgetTester tester, _Gateway gw) async {
  await setPhoneViewSize(tester, const Size(390, 844));
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    home: Scaffold(
      body: LeaderboardModal(
        auth: AuthService.fake(user: _user()),
        stats: StatsRepo(gw),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  group('web paritesi', () {
    test('giriş eşiği web BEYIN_LIGI_MIN_GAMES ile aynı', () {
      final web = readRepoFile('src/utils/beyinLigi.ts');
      final m =
          RegExp(r'export const BEYIN_LIGI_MIN_GAMES = (\d+);').firstMatch(web);
      expect(m, isNotNull);
      expect(kBeyinLigiMinGames, int.parse(m!.group(1)!));
    });

    test('açıklama ve alt not web metinleriyle BİREBİR', () {
      final web = readRepoFile('src/components/BeyinLigiList.tsx');
      // BEYIN_LIGI_INTRO iki parçadan birleşiyor; ikincisi eşiği
      // `${BEYIN_LIGI_MIN_GAMES}` ile gömüyor.
      final parts =
          RegExp(r'export const BEYIN_LIGI_INTRO =\s*"([^"]+)" \+\s*`([^`]+)`;')
              .firstMatch(web);
      expect(parts, isNotNull, reason: 'BEYIN_LIGI_INTRO biçimi değişti');
      final intro = parts!.group(1)! +
          parts
              .group(2)!
              .replaceAll(r'${BEYIN_LIGI_MIN_GAMES}', '$kBeyinLigiMinGames');
      expect(kBeyinLigiIntro, intro);

      final note = RegExp(r'export const BEYIN_LIGI_NOTE =\s*"([^"]+)";')
          .firstMatch(web);
      expect(note, isNotNull, reason: 'BEYIN_LIGI_NOTE biçimi değişti');
      expect(kBeyinLigiNote, note!.group(1));
    });

    test('sekmeler ve Puan Ligi açıklaması web Leaderboard.tsx ile BİREBİR',
        () {
      final web = readRepoFile('src/components/Leaderboard.tsx');
      final tabs =
          RegExp(r"\{ id: '(\w+)', icon: '([^']+)', label: '([^']+)' \}")
              .allMatches(web)
              .map((m) => (m.group(1), m.group(2), m.group(3)))
              .toList();
      expect(tabs, [
        for (final t in kKLigTabs) (t.id.name, t.icon, t.label),
      ]);

      final puan =
          RegExp(r"export const PUAN_LIGI_INTRO =\s*'([^']+)' \+\s*'([^']+)';")
              .firstMatch(web);
      expect(puan, isNotNull, reason: 'PUAN_LIGI_INTRO biçimi değişti');
      expect(kPuanLigiIntro, puan!.group(1)! + puan.group(2)!);
    });

    test('gamesUntilBeyinLigi web gamesUntilBeyinLigi ile aynı davranır', () {
      expect(gamesUntilBeyinLigi(0), kBeyinLigiMinGames);
      expect(gamesUntilBeyinLigi(3), kBeyinLigiMinGames - 3);
      expect(gamesUntilBeyinLigi(kBeyinLigiMinGames), 0);
      expect(gamesUntilBeyinLigi(99), 0);
      expect(gamesUntilBeyinLigi(-2), kBeyinLigiMinGames);
    });
  });

  testWidgets('pencere Puan Ligi ile açılır; Beyin Ligi istenmez',
      (tester) async {
    final gw = _Gateway(beyinRows: _beyinRows);
    await _pump(tester, gw);

    expect(find.text('Puan Ligi'), findsOneWidget);
    expect(find.text('Beyin Ligi'), findsOneWidget);
    expect(find.text(kPuanLigiIntro), findsOneWidget);
    expect(find.text('Puancı'), findsOneWidget);
    expect(find.byType(BeyinLigiList), findsNothing);
    expect(gw.beyinRequests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Beyin Ligi: OHP listesi, puan ve mühür YOK, alt not var',
      (tester) async {
    final gw = _Gateway(
      beyinRows: _beyinRows,
      mine: const {'rank': 2, 'avg_move_score': 15.11, 'ohp_games': 23},
    );
    await _pump(tester, gw);
    await tester.tap(find.text('Beyin Ligi'));
    await tester.pumpAndSettle();

    expect(find.text(kBeyinLigiIntro), findsOneWidget);
    expect(find.text('Mert'), findsOneWidget);
    expect(find.text('15.17'), findsOneWidget);
    expect(find.text('55'), findsOneWidget);
    expect(find.text('OHP'), findsWidgets);
    expect(find.text('OYUN'), findsOneWidget);
    expect(find.text(kBeyinLigiNote), findsOneWidget);
    // Puan Ligi gizlendi; Beyin Ligi'nde mühür çizilmez.
    expect(find.text('Puancı'), findsNothing);
    expect(
        find.descendant(
            of: find.byType(BeyinLigiList), matching: find.byType(RankSeal)),
        findsNothing);
    expect(gw.beyinRequests.first.limit, 10);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eşiğin altındaki kullanıcı "N oyun daha" kartını görür',
      (tester) async {
    final gw = _Gateway(
      beyinRows: _beyinRows,
      mine: const {'rank': null, 'avg_move_score': 15.21, 'ohp_games': 3},
    );
    await _pump(tester, gw);
    await tester.tap(find.text('Beyin Ligi'));
    await tester.pumpAndSettle();

    expect(find.byType(BeyinLigiGateCard), findsOneWidget);
    expect(find.text('SENİN DURUMUN'), findsOneWidget);
    expect(find.text('3 / $kBeyinLigiMinGames oyun'), findsOneWidget);
    expect(
        find.textContaining('${kBeyinLigiMinGames - 3} oyun',
            findRichText: true),
        findsWidgets);
    expect(find.text('SENİN SIRAN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sekmeler arası gidip gelmek Beyin Ligi\'ni yeniden İSTEMEZ',
      (tester) async {
    final gw = _Gateway(beyinRows: _beyinRows);
    await _pump(tester, gw);
    await tester.tap(find.text('Beyin Ligi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puan Ligi'));
    await tester.pumpAndSettle();
    expect(find.text('Puancı'), findsOneWidget);
    await tester.tap(find.text('Beyin Ligi'));
    await tester.pumpAndSettle();

    expect(gw.beyinRequests, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
