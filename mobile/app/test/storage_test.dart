// Depolama katmanı testleri — sqflite_common_ffi ile masaüstü VM'de gerçek
// SQLite. Saat enjekte edildiğinden 7 günlük terk/TTL senaryoları gerçek
// bekleme olmadan koşulur.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/storage/local_save_store.dart';
import 'package:kelimeki/src/storage/pending_event_store.dart';
import 'package:kelimeki/src/storage/pending_queue_store.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late SetWordSource words;
late int clock; // enjekte saat — testler ileri sarar

Future<AppStorage> openTestStorage() async {
  SharedPreferences.setMockInitialValues({});
  return AppStorage.open(
    factory: databaseFactoryFfi,
    path: inMemoryDatabasePath,
    prefs: await SharedPreferences.getInstance(),
    nowMs: () => clock,
  );
}

/// Motor + gerçek sözlükle birkaç hamlelik GERÇEK bir oyun durumu üretir —
/// roundtrip testi sahte/boş state'le değil dolu tahta/raf/geçmişle koşsun.
GameState buildMidGameState() {
  final engine = GameEngine(words: words, rng: Mulberry32(3), nowIso: () => '');
  var state = createInitialState();
  state = engine.reduce(
      state,
      StartAction(const [
        PlayerSetup(name: 'Ayşe', isAI: true),
        PlayerSetup(name: '', isAI: true),
      ]));
  for (var i = 0; i < 6 && !state.isGameOver; i++) {
    state = engine.reduce(state, const AiPlayAction());
  }
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  setUpAll(() {
    final f = File('assets/dictionary/words_tr.txt');
    words = SetWordSource(const LineSplitter()
        .convert(f.readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  late AppStorage storage;
  setUp(() async {
    clock = DateTime.utc(2026, 8, 6).millisecondsSinceEpoch;
    storage = await openTestStorage();
  });
  tearDown(() => storage.close());

  group('LocalSaveStore', () {
    test('roundtrip: dolu oyun durumu birebir döner + multiSession işaretlenir',
        () async {
      final state = buildMidGameState();
      expect(state.moveHistory, isNotEmpty);
      await storage.saves.save(guestSaveSlot, state);
      final loaded = await storage.saves.load(guestSaveSlot);
      expect(loaded, isNotNull);
      expect(loaded!.multiSession, isTrue); // web loadGameState parity
      // multiSession dışında her alan birebir aynı olmalı.
      final expected = gameStateToJson(state.copyWith(multiSession: true));
      expect(gameStateToJson(loaded), expected);
    });

    test('bozuk payload karantinaya taşınır, SİLİNMEZ; çökme döngüsü imkânsız',
        () async {
      await storage.saves.save(guestSaveSlot, buildMidGameState());
      await storage.db.update('local_saves', {'payload': '{"phase": bozuk!'});
      final loaded = await storage.saves.load(guestSaveSlot);
      expect(loaded, isNull); // temiz başlangıç
      expect(await storage.saves.exists(guestSaveSlot), isFalse);
      expect(await storage.saves.quarantineCount(), 1); // veri durur
      // İkinci yükleme de sorunsuz null — aynı bozuk kayıt bir daha okunamaz.
      expect(await storage.saves.load(guestSaveSlot), isNull);
    });

    test('gelecekten (bilinmeyen sürümlü) kayıt tahmin edilmez, karantina',
        () async {
      await storage.saves.save(guestSaveSlot, buildMidGameState());
      await storage.db.update('local_saves', {'payload_version': 99});
      expect(await storage.saves.load(guestSaveSlot), isNull);
      expect(await storage.saves.quarantineCount(), 1);
      final q = await storage.db.query('quarantined_saves');
      expect(q.first['reason'], contains('99'));
    });

    test('7 gün dolunca kayıt terk olayına dönüşür (web ABANDON_TIMEOUT)',
        () async {
      final state = buildMidGameState();
      await storage.saves.save(guestSaveSlot, state);
      clock += abandonTimeout.inMilliseconds + 1000; // 7 gün + 1sn ileri sar
      expect(await storage.saves.load(guestSaveSlot), isNull);
      expect(await storage.saves.exists(guestSaveSlot), isFalse);
      // Olay TEK SEFERLİK: ilk take dolu, ikincisi boş (atomik oku-temizle).
      final events = await storage.events.takeAll(abandonedGameKind);
      expect(events, hasLength(1));
      final inner = (jsonDecode(events.first['state'] as String) as Map)
          .cast<String, Object?>();
      expect(gameStateFromJson(inner).turnCount, state.turnCount);
      expect(await storage.events.takeAll(abandonedGameKind), isEmpty);
    });
  });

  group('PendingQueueStore', () {
    test('aynı id ikinci kez eklenirse ilk kayıt kalır (dedup)', () async {
      await storage.queue
          .enqueue(kind: finishedGameKind, id: 'g1', payload: {'n': 1});
      await storage.queue
          .enqueue(kind: finishedGameKind, id: 'g1', payload: {'n': 2});
      final all = await storage.queue.readAll(finishedGameKind);
      expect(all, hasLength(1));
      expect(all.first.payload['n'], 1);
    });

    test('tür başına 300 sınırı: en eskiler düşer', () async {
      for (var i = 0; i < kMaxPendingPerKind + 5; i++) {
        await storage.queue.enqueue(
            kind: finishedGameKind,
            id: 'g$i',
            payload: {'i': i},
            createdAt: clock + i);
      }
      expect(await storage.queue.count(finishedGameKind), kMaxPendingPerKind);
      final all = await storage.queue.readAll(finishedGameKind);
      expect(all.first.payload['i'], 5); // 0..4 düştü
      expect(all.last.payload['i'], kMaxPendingPerKind + 4);
    });

    test('7 günlük TTL okuma anında süpürülür; türler birbirine karışmaz',
        () async {
      await storage.queue
          .enqueue(kind: finishedGameKind, id: 'eski', payload: {});
      await storage.queue.enqueue(kind: feedbackKind, id: 'fb', payload: {});
      clock += pendingExpiry.inMilliseconds + 1000;
      await storage.queue
          .enqueue(kind: finishedGameKind, id: 'taze', payload: {});
      final games = await storage.queue.readAll(finishedGameKind);
      expect([for (final e in games) e.id], ['taze']);
      expect(await storage.queue.readAll(feedbackKind), isEmpty); // o da eskidi
      await storage.queue.remove('taze');
      expect(await storage.queue.count(finishedGameKind), 0);
    });
  });

  group('ChatReadStore', () {
    test('damga yaz/oku/güncelle/sil', () async {
      expect(await storage.chatRead.lastReadAt('oyun-1'), isNull);
      await storage.chatRead.markRead('oyun-1', 1000);
      await storage.chatRead.markRead('oyun-1', 2000); // replace
      expect(await storage.chatRead.lastReadAt('oyun-1'), 2000);
      await storage.chatRead.remove('oyun-1');
      expect(await storage.chatRead.lastReadAt('oyun-1'), isNull);
    });
  });

  group('LiveDraftStore', () {
    Placed draft() => {
          '4,4': const Tile(letter: 'K', pts: 5, owner: 0),
          '4,5': const Tile(
              letter: '?', pts: 0, wild: true, wildLetter: 'Ş', owner: 0),
        };

    test('kaydet → yükle gidiş-dönüş (joker harfi dahil)', () async {
      await storage.liveDrafts.save('u1', 'g1', draft());
      final geri = await storage.liveDrafts.load('u1', 'g1');
      expect(geri, isNotNull);
      expect({for (final e in geri!.entries) e.key: e.value.toJson()},
          {for (final e in draft().entries) e.key: e.value.toJson()});
    });

    test('hesap ve oyun anahtarın PARÇASI: başkasının taslağı gelmez',
        () async {
      await storage.liveDrafts.save('u1', 'g1', draft());
      expect(await storage.liveDrafts.load('u2', 'g1'), isNull);
      expect(await storage.liveDrafts.load('u1', 'g2'), isNull);
    });

    test('aynı oyuna ikinci kayıt ÜSTÜNE yazar (tek satır)', () async {
      await storage.liveDrafts.save('u1', 'g1', draft());
      await storage.liveDrafts.save(
          'u1', 'g1', {'1,1': const Tile(letter: 'A', pts: 1, owner: 0)});
      final geri = await storage.liveDrafts.load('u1', 'g1');
      expect(geri!.keys, ['1,1']);
      expect(await storage.db.query('live_drafts'), hasLength(1));
    });

    test('boş taslak kaydı SİLER; clear de siler', () async {
      await storage.liveDrafts.save('u1', 'g1', draft());
      await storage.liveDrafts.save('u1', 'g1', <String, Tile>{});
      expect(await storage.liveDrafts.load('u1', 'g1'), isNull);

      await storage.liveDrafts.save('u1', 'g1', draft());
      await storage.liveDrafts.clear('u1', 'g1');
      expect(await storage.liveDrafts.load('u1', 'g1'), isNull);
    });

    test('BOZUK kayıt asla uygulanmaz ve silinir (her açılışta denenmesin)',
        () async {
      for (final bozuk in [
        '{bozuk',
        jsonEncode({'v': 99, 'cells': {'1,1': const Tile(letter: 'A', pts: 1).toJson()}}),
        jsonEncode({'v': 1, 'cells': <String, Object?>{}}),
        jsonEncode({'v': 1, 'cells': {'x,y': const Tile(letter: 'A', pts: 1).toJson()}}),
      ]) {
        await storage.db.insert(
          'live_drafts',
          {'user_id': 'u1', 'game_id': 'gb', 'payload': bozuk, 'updated_at': 0},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        expect(await storage.liveDrafts.load('u1', 'gb'), isNull,
            reason: 'bozuk kayıt uygulandı: $bozuk');
        expect(await storage.db.query('live_drafts', where: "game_id = 'gb'"),
            isEmpty,
            reason: 'bozuk kayıt silinmedi: $bozuk');
      }
    });

    test('taze depoda tablo var ve komşu tabloları etkilemez', () async {
      // ⚠ Bu bir 4 → 5 YÜKSELTME testi DEĞİL (taze depo açıyor): migrasyon
      // `_migrations[5]`, ekleyici bir `create table`; gerçek yükseltme yolu
      // `mobile/TESTING.md`'de cihazda (eski sürümün üstüne kurulum) doğrulanır.
      await storage.chatRead.markRead('g9', 123);
      expect(await storage.chatRead.lastReadAt('g9'), 123);
      expect(await storage.db.query('live_drafts'), isEmpty);
    });
  });

  group('FlagsStore', () {
    test('anonId bir kez üretilir; utm first-touch üzerine yazılmaz', () async {
      final id1 = await storage.flags.anonId();
      final id2 = await storage.flags.anonId();
      expect(id1, id2);
      // Eski Hızlı Başlangıç bayrağı SALT OKUNUR miras (yazıcısı yok);
      // tanıtımın kendi bayrağı ayrı (Onboarding Faz 4).
      expect(storage.flags.seenQuickstart, isFalse);
      expect(storage.flags.seenTutorial, isFalse);
      await storage.flags.markTutorialSeen();
      expect(storage.flags.seenTutorial, isTrue);
      expect(storage.flags.seenQuickstart, isFalse);
      await storage.flags.captureUtmSource('tiktok');
      await storage.flags.captureUtmSource('instagram'); // yok sayılır
      expect(storage.flags.utmSource, 'tiktok');
    });
  });
}
