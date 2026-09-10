// Kalıcılık üst katmanı (LocalGameRepo/GameSession) testleri — gerçek SQLite
// (ffi, in-memory) + gerçek GameController. Web davranış paritesi:
// autosave GERÇEKTEN başlamış (turnCount>=2) oyunun her hamlesinde yazar —
// hiç oynanmamış oyun HİÇ yazılmaz (10 Eylül 2026 kapısı) —, oyun bitince
// slot silinir, 7 günlük terk → drain olayı verir, GamesRepo yalnızca
// turnCount>=2 için -2 cezalı teslim kaydı üretir (misafirde kuyruğa).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/games_api.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/game/local_game_repo.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/storage/pending_queue_store.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/fake_games_gateway.dart';

late SetWordSource words;
late int clock;

Future<AppStorage> openTestStorage() async {
  SharedPreferences.setMockInitialValues({});
  return AppStorage.open(
    factory: databaseFactoryFfi,
    path: inMemoryDatabasePath,
    prefs: await SharedPreferences.getInstance(),
    nowMs: () => clock,
  );
}

/// Deterministik YZ'ye karşı oyun başlatan controller (autoPlayAi kapalı —
/// adım adım sürülür).
GameController newController() =>
    GameController(words: words, autoPlayAi: false, nowIso: () => '');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  setUpAll(() {
    final f = File('assets/dictionary/words_tr.txt');
    words = SetWordSource(const LineSplitter()
        .convert(f.readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  setUp(() {
    clock = 1000000;
  });

  test('autosave: her state değişimi slotu yazar, kayıt geri yüklenir',
      () async {
    final storage = await openTestStorage();
    final repo = LocalGameRepo(storage);
    final controller = newController();
    final session = repo.attach(controller);

    controller.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    await session.end(); // turnCount 0 — bilinçli çıkış izi silmeli
    expect(await repo.hasSave(), isFalse);

    // Yeniden başlat, bu kez oyun "başlamış" olsun (turnCount >= 2).
    final c2 = newController();
    final s2 = repo.attach(c2);
    c2.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    c2.dispatch(const PassAction());
    c2.dispatch(const AiPlayAction());
    expect(c2.state.turnCount, greaterThanOrEqualTo(2));
    await s2.end();
    expect(await repo.hasSave(), isTrue);

    final loaded = await repo.loadSave();
    expect(loaded, isNotNull);
    expect(loaded!.multiSession, isTrue); // web loadGameState paritesi
    expect(loaded.turnCount, c2.state.turnCount);
    expect(gameStateToJson(loaded.copyWith(multiSession: false)),
        gameStateToJson(c2.state));
    await storage.close();
  });

  test('oyun bitince slot silinir', () async {
    final storage = await openTestStorage();
    final repo = LocalGameRepo(storage);
    // Tohumlu tam YZ oyunu — bitene kadar sür.
    final controller = GameController(
        words: words, autoPlayAi: false, nowIso: () => '', rng: Mulberry32(7));
    final session = repo.attach(controller);
    controller.dispatch(StartAction(const [
      PlayerSetup(name: '', isAI: true),
      PlayerSetup(name: '', isAI: true),
    ]));
    var guard = 0;
    while (!controller.state.isGameOver && guard++ < 300) {
      controller.dispatch(const AiPlayAction());
    }
    expect(controller.state.isGameOver, isTrue);
    await session.end();
    expect(await repo.hasSave(), isFalse);
    await storage.close();
  });

  test('7 günlük terk: misafirin cezası kuyruğa girer, <2 HİÇ YAZILMAZ',
      () async {
    final storage = await openTestStorage();
    final repo = LocalGameRepo(storage);
    // Misafir (oturum yok) — GamesRepo kaydı gönderemeyip kuyruklamalı.
    final gamesGw = FakeGamesGateway();
    final games = GamesRepo(gamesGw, storage.queue);

    // Başlamış bir oyun kaydet.
    final c = newController();
    final s = repo.attach(c);
    c.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    c.dispatch(const PassAction());
    c.dispatch(const AiPlayAction());
    await s.end();
    expect(await repo.hasSave(), isTrue);

    // 8 gün ileri sar: load kaydı terk olayına çevirir, drain onu verir,
    // GamesRepo -2 cezalı teslim kaydına çevirip (misafir olduğundan)
    // kuyruklar.
    clock += const Duration(days: 8).inMilliseconds;
    expect(await repo.loadSave(), isNull);
    final events = await repo.drainAbandonedGames();
    expect(events, hasLength(1));
    expect(events.single.state.turnCount, greaterThanOrEqualTo(2));
    for (final e in events) {
      await games.recordAbandoned(e.state, endedAtMs: e.savedAtMs);
    }
    expect(gamesGw.inserted, isEmpty); // misafir — ağa gitmedi
    final queued = await storage.queue.readAll(finishedGameKind);
    expect(queued, hasLength(1));
    expect(queued.first.payload['surrendered'], isTrue);
    expect(queued.first.payload['result'], 'lose');
    expect(queued.first.payload['player_score'], 0);

    // Kişi bu cihazda giriş yaparsa ceza hesabına işlenir (web flush).
    gamesGw.userId = 'u-1';
    expect(await games.flushPending(), 1);
    expect(gamesGw.inserted.single['surrendered'], isTrue);
    expect(await storage.queue.count(finishedGameKind), 0);

    // İkinci tur: hiç oynanmamış (turnCount 0) oyun, uygulama ÖLDÜRÜLMÜŞ
    // gibi — `end()` hiç çağrılmıyor. 10 Eylül 2026'ya kadar autosave onu
    // YAZIYORDU: `end()`teki eşik yalnızca temiz çıkışı kapsadığından bu
    // yolda slot doluyor, 7 gün sonra (cezasız ama) bir terk olayına
    // dönüşüyordu — kullanıcı bunun bulut ikizini cihazda gördü. Artık
    // HİÇ yazılmıyor, yani telafiye gerek kalmıyor.
    final c2 = newController();
    final s2 = repo.attach(c2);
    c2.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    s2.detach(); // end() ÇAĞRILMAZ — kill senaryosu
    await Future<void>.delayed(Duration.zero);
    expect(await repo.hasSave(), isFalse,
        reason: 'hiç oynanmamış oyun kill yolunda da iz bırakmamalı');
    clock += const Duration(days: 8).inMilliseconds;
    expect(await repo.loadSave(), isNull);
    expect(await repo.drainAbandonedGames(), isEmpty,
        reason: 'yazılmayan kayıt terk olayı da üretemez');
    expect(gamesGw.inserted, hasLength(1)); // hâlâ yalnızca ilk oyun
    expect(await storage.queue.count(finishedGameKind), 0);
    await storage.close();
  });

  test('uygulama kapanması (end çağrılmadan) kaydı korur — devam edilir',
      () async {
    final storage = await openTestStorage();
    final repo = LocalGameRepo(storage);
    final c = newController();
    final s = repo.attach(c);
    c.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    c.dispatch(const PassAction());
    c.dispatch(const AiPlayAction()); // autosave eşiği (turnCount>=2)
    s.detach(); // kill — end() yok
    await Future<void>.delayed(Duration.zero);

    final loaded = await repo.loadSave();
    expect(loaded, isNotNull);
    expect(loaded!.turnCount, 2);
    await storage.close();
  });

  test('yazma-okuma yarışı: end() sonrası okuma her zaman taze', () async {
    final storage = await openTestStorage();
    final repo = LocalGameRepo(storage);
    final c = newController();
    final s = repo.attach(c);
    c.dispatch(StartAction(const [
      PlayerSetup(name: 'Sen', isAI: false),
      PlayerSetup(name: '', isAI: true),
    ]));
    // end() beklenmeden hasSave sorulursa bile kuyruk okumadan önce boşalır
    // (PORT_BRIEF §7) — silme uçuştayken bayat "var" cevabı dönemez.
    final endFuture = s.end();
    final has = await repo.hasSave();
    await endFuture;
    expect(has, isFalse);
    await storage.close();
  });
}
