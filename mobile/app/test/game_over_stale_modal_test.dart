// Oyun sonu modalı BAYAT durumla açılmasın (11 Ekim 2026, kullanıcı raporu
// — Asnmzr: "TEKRAR OYNA ile yeni oyun açtım, Değiştir'e bastım, YZ
// oynamadan BERABERE modalı çıktı; kapatınca oyun devam etti").
//
// Sebep: modal, oyun bitince `_ilkKutlama` (girişli kullanıcıda AĞ isteği:
// oyuncu istatistikleri) beklendikten SONRA açılıyor ve o an `state`
// GETTER'ına bakıyordu — yani CANLI duruma. İstek yavaşken kullanıcı TEKRAR
// OYNA'ya basarsa modal yeni oyunun (0-0, kalan taşlar) durumuyla "BERABERE"
// diye açılıyordu.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/dialog_shell.dart' show KDialogCard;
import 'package:kelimeki/src/ui/game/game_over_modal.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/game/neo_button.dart' show NeoButton;
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import 'support/test_fonts.dart';
import 'support/test_view.dart';

/// `playerStats` çağrısı, test serbest bırakana kadar bekler (yavaş ağ).
class _YavasStats implements StatsGateway {
  final gate = Completer<void>();

  @override
  Future<Map<String, Object?>?> playerStats(
      String userId, int? playerCount) async {
    await gate.future;
    return null;
  }

  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async =>
      const [];
  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async => null;
  @override
  Future<List<Map<String, Object?>>> rankScores(List<String> userIds) async =>
      const [];
  @override
  Future<Map<String, Object?>?> profileAgeGender(String userId) async => null;
  @override
  Future<Map<String, Object?>?> headToHead(String otherUserId) async => null;
}

User _user() => User(
      id: 'u-test',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
      email: 'a@b.c',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SetWordSource words;
  setUpAll(() async {
    await loadRobotoIfAvailable();
    words = SetWordSource(const LineSplitter()
        .convert(File('assets/dictionary/words_tr.txt').readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  testWidgets(
      'istatistik beklenirken TEKRAR OYNA: eski oyunun modalı YENİ oyunda açılmaz',
      (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    final controller =
        GameController(words: words, autoPlayAi: false, nowIso: () => '');
    controller.dispatch(const StartAction([
      PlayerSetup(name: 'Asnmzr', isAI: false),
      PlayerSetup(name: 'Yapay Zeka 2', isAI: true),
    ], aiLevel: AiLevel.zor));
    final stats = _YavasStats();
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: GameScreen(
        controller: controller,
        words: words,
        auth: AuthService.fake(user: _user()),
        stats: StatsRepo(stats),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));

    // Oyun biter; modal istatistik cevabını bekliyor (henüz AÇILMADI).
    controller.dispatch(const SurrenderAction(0));
    await tester.pump();
    await tester.pump();
    expect(find.byType(GameOverModal), findsNothing,
        reason: 'istatistik gelmeden modal açılmamalı (senaryo kurulumu)');

    // Kullanıcı beklemeden TEKRAR OYNA'ya basar.
    await tester.tap(find.text('TEKRAR OYNA'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(KDialogCard),
        matching: find.widgetWithText(NeoButton, 'TEKRAR OYNA')));
    await tester.pumpAndSettle();
    expect(controller.state.isGameOver, isFalse);

    // Yavaş ağ cevabı şimdi gelir.
    stats.gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(GameOverModal), findsNothing,
        reason: 'devam eden yeni oyunda BERABERE modalı çıkmamalı');
    expect(controller.state.isGameOver, isFalse);
  });
}
