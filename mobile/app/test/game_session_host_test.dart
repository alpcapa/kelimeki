// GameSessionHost testleri — "oyun ORTASINDA giriş yapılırsa ne olur"
// sorusunun tamamı. Vaka (15 Eylül 2026, TestFlight 1.1.0/665): misafir
// olarak başlanan oyunun ortasında giriş yapıldı; oyun sonu ekranı hâlâ
// "Misafir" gösterdi ve Setup'ta AYNI oyun, girişin yapıldığı andaki
// skorlarla, bir daha güncellenmeyen bir "Devam Eden Oyun" olarak kaldı.
//
// Web paritesi (kaynak `src/App.tsx`): autosave effect'i `user`a bağlıdır
// (hedef giriş anında localStorage → local_game_saves'e geçer, misafir
// kaydı silinir) ve ayrı bir effect 1. oyuncunun adını hesap adıyla
// günceller (RENAME_PLAYER). Portta ikisi de yoktu.
//
// Gerçek SQLite (ffi, in-memory) + gerçek sözlük + sahte CloudSaveGateway.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/cloud_save_repo.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/game/game_session_host.dart';
import 'package:kelimeki/src/game/local_game_repo.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/fake_cloud_save_gateway.dart';
import 'support/fake_online_gateway.dart' show fakeUser;

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

/// Bekleyen bulut yazmalarının GERÇEKTEN sunucuya inmesini bekler.
/// ⚠ `await cloud.idle` TEK BAŞINA YETMEZ: `Duration.zero` debounce da bir
/// `Timer`dır ve ancak bir sonraki event-loop turunda ateşlenir — yani yazma
/// o ana kadar kuyruğa GİRMEMİŞTİR ve boş kuyruk "iş bitti" gibi görünür.
Future<void> settle(CloudSaveRepo cloud) async {
  await Future<void>.delayed(Duration.zero);
  await cloud.idle;
}

GameController newController() =>
    GameController(words: words, autoPlayAi: false, nowIso: () => '');

/// Misafir + YZ kadrosuyla başlayıp oyunu GERÇEKTEN başlatır (turnCount>=2 —
/// autosave'in kendi eşiği; altında ne misafir slotu ne bulut satırı yazılır).
void startAndPlay(GameController c) {
  c.dispatch(const StartAction([
    PlayerSetup(name: 'Misafir', isAI: false),
    PlayerSetup(name: 'Yapay Zeka 2', isAI: true),
  ]));
  c.dispatch(const PassAction());
  c.dispatch(const AiPlayAction());
  expect(c.state.turnCount, greaterThanOrEqualTo(2));
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

  setUp(() {
    clock = DateTime.utc(2026, 9, 15).millisecondsSinceEpoch;
  });

  test(
      'oyun ortasında giriş: kayıt buluta DEVREDİLİR, isim düzelir, '
      'oyun bitince HAYALET satır kalmaz', () async {
    final storage = await openTestStorage();
    final guestRepo = LocalGameRepo(storage);
    final gw = FakeSaveGateway(nowMs: () => clock);
    final cloud = CloudSaveRepo(gw, nowMs: () => clock);
    // Profil hazır ama oturum YOK — kullanıcı misafir olarak oynuyor.
    final auth = AuthService.fake(
        profile: const KProfile(id: 'u1', displayName: 'Ironman'));
    final controller = newController();
    final host = GameSessionHost(
      controller: controller,
      auth: auth,
      guestRepo: guestRepo,
      cloud: cloud,
      cloudDebounce: Duration.zero,
    );

    startAndPlay(controller);
    expect(host.isGuestSession, isTrue);
    expect(await guestRepo.hasSave(), isTrue);
    expect(gw.rows, isEmpty);

    // ——— OYUN ORTASINDA GİRİŞ ———
    auth.debugSetUser(fakeUser('u1'));
    await settle(cloud);

    // 1. Ad artık hesabın adı (vaka: oyun sonu ekranı "Misafir" diyordu).
    expect(controller.state.players[0].name, 'Ironman');
    expect(controller.state.players[1].name, 'Yapay Zeka 2'); // YZ dokunulmaz

    // 2. Kayıt hedefi devredildi: misafir slotu boş, bulutta TEK satır var ve
    //    içindeki state CANLI oyunun state'i (girişin donmuş kopyası değil).
    expect(host.isGuestSession, isFalse);
    expect(await guestRepo.hasSave(), isFalse);
    expect(gw.rows, hasLength(1));
    expect(gw.onlyState.turnCount, controller.state.turnCount);
    expect(gw.onlyState.players[0].name, 'Ironman');

    // 3. Girişten SONRAKİ hamleler AYNI satırı günceller — bayat kalmaz.
    final id = host.cloudSaveId;
    expect(id, isNotNull);
    controller.dispatch(const PassAction());
    controller.dispatch(const AiPlayAction());
    await settle(cloud);
    expect(gw.rows.keys.single, id);
    expect(gw.onlyState.turnCount, controller.state.turnCount);
    expect(await guestRepo.hasSave(), isFalse); // misafir slotuna dönülmez

    // 4. Oyun bitince satır SİLİNİR. Vakanın can alıcı yeri: eskiden bulut
    //    satırını kimse silmiyordu ve oyun "Devam Eden Oyunlar"da hayalet
    //    olarak kalıyordu.
    controller.dispatch(const SurrenderAction(0));
    expect(controller.state.isGameOver, isTrue);
    await host.end();
    expect(gw.rows, isEmpty);
    expect(await guestRepo.hasSave(), isFalse);
    await storage.close();
  });

  test('aynı hesabın tekrar bildirimi (token/profil tazelenmesi) YENİ satır açmaz',
      () async {
    final storage = await openTestStorage();
    final gw = FakeSaveGateway(nowMs: () => clock);
    final cloud = CloudSaveRepo(gw, nowMs: () => clock);
    final auth = AuthService.fake(
        profile: const KProfile(id: 'u1', displayName: 'Ironman'));
    final controller = newController();
    final host = GameSessionHost(
      controller: controller,
      auth: auth,
      guestRepo: LocalGameRepo(storage),
      cloud: cloud,
      cloudDebounce: Duration.zero,
    );
    startAndPlay(controller);
    auth.debugSetUser(fakeUser('u1'));
    await settle(cloud);
    final id = host.cloudSaveId;

    // `onAuthStateChange` aynı hesap için saatte bir TAZE User nesnesi
    // yayınlıyor (PORT_BRIEF §7 / AccountScope dersi): oturum id'si
    // değişmediği sürece kayıt oturumu DEĞİŞMEMELİ.
    auth.debugSetUser(fakeUser('u1'));
    await settle(cloud);
    expect(host.cloudSaveId, id);
    expect(gw.rows, hasLength(1));
    await host.end();
    await storage.close();
  });

  test('çıkış: oyun misafir slotundan devam eder, bulut satırına DOKUNULMAZ',
      () async {
    final storage = await openTestStorage();
    final guestRepo = LocalGameRepo(storage);
    final gw = FakeSaveGateway(nowMs: () => clock);
    final cloud = CloudSaveRepo(gw, nowMs: () => clock);
    final auth = AuthService.fake(
        user: fakeUser('u1'),
        profile: const KProfile(id: 'u1', displayName: 'Ironman'));
    final controller = newController();
    final host = GameSessionHost(
      controller: controller,
      auth: auth,
      guestRepo: guestRepo,
      cloud: cloud,
      cloudDebounce: Duration.zero,
    );
    startAndPlay(controller);
    await settle(cloud);
    expect(gw.rows, hasLength(1));
    expect(await guestRepo.hasSave(), isFalse);

    auth.debugSetUser(null);
    controller.dispatch(const PassAction());
    controller.dispatch(const AiPlayAction());
    await settle(cloud);

    expect(host.isGuestSession, isTrue);
    expect(await guestRepo.hasSave(), isTrue);
    // Web'de de çıkış bulut satırını silmez: "Devam Eden Oyunlar"da kalır ve
    // 7 günlük süpürmeye tabidir.
    expect(gw.rows, hasLength(1));
    await host.end();
    await storage.close();
  });

  test('giriş turnCount<2 iken ÖNCEKİ misafir kaydını SİLMEZ', () async {
    final storage = await openTestStorage();
    final guestRepo = LocalGameRepo(storage);
    final gw = FakeSaveGateway(nowMs: () => clock);
    final cloud = CloudSaveRepo(gw, nowMs: () => clock);
    final auth = AuthService.fake(
        profile: const KProfile(id: 'u1', displayName: 'Ironman'));

    // Misafirin slotunda GERÇEK bir kayıt var (önceki oyun).
    final eski = newController();
    final eskiSession = guestRepo.attach(eski);
    startAndPlay(eski);
    await eskiSession.end();
    expect(await guestRepo.hasSave(), isTrue);

    // Yeni bir oyun açılıyor ama daha hiç oynanmadı (turnCount<2): slot hâlâ
    // ESKİ oyunundur, devirde silinmemeli.
    final controller = newController();
    final host = GameSessionHost(
      controller: controller,
      auth: auth,
      guestRepo: guestRepo,
      cloud: cloud,
      cloudDebounce: Duration.zero,
    );
    controller.dispatch(const StartAction([
      PlayerSetup(name: 'Misafir', isAI: false),
      PlayerSetup(name: 'Yapay Zeka 2', isAI: true),
    ]));
    auth.debugSetUser(fakeUser('u1'));
    await settle(cloud);

    expect(await guestRepo.hasSave(), isTrue); // eski kayıt DURUYOR
    expect(gw.rows, isEmpty); // turnCount<2 → bulut satırı da açılmaz
    await host.end();
    await storage.close();
  });

  test('buluttan devam edilen BAYAT "Misafir" kaydının adı ilk karede düzelir',
      () async {
    final storage = await openTestStorage();
    final gw = FakeSaveGateway(nowMs: () => clock);
    final cloud = CloudSaveRepo(gw, nowMs: () => clock);
    final auth = AuthService.fake(
        user: fakeUser('u1'),
        profile: const KProfile(id: 'u1', displayName: 'Ironman'));

    // Düzeltmeden ÖNCE yazılmış bir satır: girişli hesabın kaydı ama adı
    // hâlâ "Misafir" (bu hatanın sahadaki kalıntısı).
    final onceki = newController();
    startAndPlay(onceki);
    expect(onceki.state.players[0].name, 'Misafir');

    final controller = newController();
    controller.restore(onceki.state);
    final host = GameSessionHost(
      controller: controller,
      auth: auth,
      guestRepo: LocalGameRepo(storage),
      cloud: cloud,
      cloudDebounce: Duration.zero,
    );
    expect(controller.state.players[0].name, 'Ironman');
    await host.end();
    await storage.close();
  });
}
