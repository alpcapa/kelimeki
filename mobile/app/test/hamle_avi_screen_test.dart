// Hamle Avı ekranı — web `tests/smoke.spec.ts` Hamle Avı akışlarının port
// karşılığı (ROADMAP #48, 3 Kasım 2026): tanıtım, doğru hamle → Tebrikler,
// süre bitimi → Üzgünüz → doğru hamle tahtada (review), çıkış/vazgeç ölçümü.
// Sözlük ve banka GERÇEK asset dosyalarından; çözücü Dart motoru.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/hamle_avi_api.dart';
import 'package:kelimeki/src/storage/hamle_avi_store.dart';
import 'package:kelimeki/src/ui/game/tile_widget.dart';
import 'package:kelimeki/src/ui/hamle_avi/hamle_avi_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/hamle_avi.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_fonts.dart';
import 'support/test_view.dart';

late SetWordSource words;
late List<HamleAviPosition> bank;

class _FakeGateway implements HamleAviGateway {
  final events = <Map<String, Object?>>[];
  final reports = <(int, List<int>)>[];
  @override
  Future<HamleAviServer?> fetch() async => null;
  @override
  Future<HamleAviServer?> report(int best, List<int> seen) async {
    reports.add((best, seen));
    return null;
  }

  @override
  Future<void> logEvent({
    required String? anonId,
    required int puzzleId,
    required String result,
    required int seconds,
    required int streakBefore,
  }) async {
    events.add({
      'anon': anonId,
      'id': puzzleId,
      'result': result,
      'seconds': seconds,
      'before': streakBefore,
    });
  }
}

/// Rafında joker OLMAYAN, çözümü joker kullanmayan ilk pozisyon: ekrandaki
/// dokunuşla dizilebilsin diye (joker akışı ayrı bir pencere).
HamleAviPosition _jokersiz() {
  for (final p in bank) {
    if (p.rack.contains('?')) continue;
    final best =
        hamleAviFindBestNetMove(hamleAviPositionToState(p, 'Sen'), words);
    if (best != null &&
        best.net == p.k &&
        best.move.placements.every((x) => !x.tile.wild)) {
      return p;
    }
  }
  fail('jokersiz pozisyon yok');
}

Future<({bool Function() exited, _FakeGateway gw, HamleAviStore store})>
    pumpScreen(WidgetTester tester, HamleAviPosition pos,
        {int best = 0, bool introHidden = false}) async {
  await setPhoneViewSize(tester, const Size(390, 844));
  SharedPreferences.setMockInitialValues({
    if (best > 0 || introHidden)
      kHamleAviStoreKey: jsonEncode(
          {'best': best, 'seen': <int>[], 'introHidden': introHidden}),
  });
  final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
  final store = HamleAviStore(prefs);
  final gw = _FakeGateway();
  var exited = false;
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    home: HamleAviScreen(
      playerName: 'Sen',
      words: Future.value(words),
      store: store,
      gateway: gw,
      anonId: () async => 'anon-1',
      loadBank: () async => [pos],
      onExit: () => exited = true,
      rng: null,
    ),
  ));
  // Sözlük + banka + (SharedPreferences) yüklemesi.
  for (var i = 0; i < 6; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  return (exited: () => exited, gw: gw, store: store);
}

Finder sureMetni() => find.byKey(const ValueKey('hamle-avi-sure'));

void main() {
  setUpAll(() async {
    await loadAppFonts();
    final lines = const LineSplitter()
        .convert(File('assets/dictionary/words_tr.txt').readAsStringSync())
        .where((w) => w.isNotEmpty)
        .toList();
    words = SetWordSource(lines);
    bank = parseHamleAviBank(
        File('assets/hamle_avi/bank.json').readAsStringSync());
  });

  testWidgets('tanıtım: 3 madde + Vazgeç bulmacayı YAKMAZ', (tester) async {
    final pos = bank.first;
    final h = await pumpScreen(tester, pos);
    expect(find.text('Bir daha gösterme'), findsOneWidget);
    for (final t in kHamleAviIntroPoints) {
      expect(find.textContaining(t), findsOneWidget);
    }
    // Süre "Başla"ya kadar DURUR.
    expect(find.text('3:00'), findsOneWidget);
    await tester.tap(find.text('VAZGEÇ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(h.exited(), isTrue);
    expect(h.store.load().seen, isEmpty,
        reason: 'vazgeçilen bulmaca görülenlerden çıkarılmalı');
  });

  testWidgets('doğru hamle → Tebrikler, seri 1, rekor yazılır', (tester) async {
    final pos = _jokersiz();
    final h = await pumpScreen(tester, pos, introHidden: true);
    // Bulmaca doğrudan başlar (tanıtım gizli), görüldü sayılır.
    expect(h.store.load().seen, contains(pos.id));

    final state = hamleAviPositionToState(pos, 'Sen');
    final best = hamleAviFindBestNetMove(state, words)!;
    final rack = [for (final t in state.players[pos.o].rack) t.letter];
    for (final p in best.move.placements) {
      final idx = rack.indexOf(p.tile.letter);
      rack.removeAt(idx);
      await tester.tap(find.byKey(ValueKey('rack-$idx')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('cell-${p.r}-${p.c}')));
      await tester.pump();
      expect(
          find.descendant(
              of: find.byKey(ValueKey('cell-${p.r}-${p.c}')),
              matching: find.byType(TileWidget)),
          findsOneWidget);
    }
    await tester.tap(find.text('OYNA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tebrikler! 🎯'), findsOneWidget);
    expect(find.textContaining('En iyi hamleyi buldun'), findsOneWidget);
    expect(h.store.load().best, 1);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(h.gw.events.single['result'], 'found');
    expect(h.gw.events.single['before'], 0);
  });

  testWidgets('süre biter → Üzgünüz → Kapat → doğru hamle tahtada (review)',
      (tester) async {
    final pos = _jokersiz();
    final h = await pumpScreen(tester, pos, best: 3, introHidden: true);
    await tester.pump(const Duration(seconds: 100));
    expect(sureMetni(), findsOneWidget);
    await tester.pump(const Duration(seconds: 90)); // 190 sn > 180
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Üzgünüz, bulamadınız'), findsOneWidget);
    expect(find.textContaining('${pos.k}'), findsWidgets);
    expect(find.textContaining(pos.w), findsWidgets);
    expect(h.store.load().best, 3, reason: 'rekor korunur');

    // Çözücü senkron koşar (~0,1-0,5 sn gerçek zaman).
    await tester.tap(find.text('KAPAT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('hamle-avi-sonraki')), findsOneWidget);
    expect(find.textContaining('Doğru hamle: '), findsOneWidget);
    expect(find.textContaining('vergi dahil toplam ${pos.k} puan'),
        findsOneWidget);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(h.gw.events.single['result'], 'missed');
    expect(h.gw.events.single['seconds'], kHamleAviSeconds);
  });

  testWidgets('seri yokken ÇIK uyarısız çıkar ve "left" ölçülür',
      (tester) async {
    final pos = _jokersiz();
    final h = await pumpScreen(tester, pos, introHidden: true);
    await tester.pump(const Duration(seconds: 7));
    await tester.tap(find.byKey(const ValueKey('hamle-avi-cik')));
    await tester.pump();
    expect(find.text('Çıkmak istiyor musun?'), findsNothing);
    expect(h.exited(), isTrue);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(h.gw.events.single['result'], 'left');
    expect(h.gw.events.single['seconds'], inInclusiveRange(6, 8));
  });
}
