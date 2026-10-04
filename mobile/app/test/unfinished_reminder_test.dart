// Yarım kalan oyun hatırlatması — saf kurallar + akış (1 Ekim 2026).
// Platform ucu sahte; adların Kotlin/Swift paritesi ayrı dosyada
// (`unfinished_reminder_parity_test.dart`).
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/push_repo.dart';
import 'package:kelimeki/src/data/unfinished_game_reminder.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/util/unfinished_reminder.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeZamanlayici implements HatirlatmaZamanlayici {
  final kurulanlar = <DateTime>[];
  int iptalSayisi = 0;
  String? baslik;
  String? govde;

  @override
  Future<void> kur(DateTime zaman, String baslik, String govde) async {
    kurulanlar.add(zaman);
    this.baslik = baslik;
    this.govde = govde;
  }

  @override
  Future<void> iptal() async => iptalSayisi += 1;
}

class _FakeMessaging implements PushMessaging {
  PushPermission izin;
  _FakeMessaging(this.izin);

  @override
  Future<PushPermission> permission() async => izin;
  @override
  Future<PushPermission> requestPermission() async => izin;
  @override
  Future<String?> token() async => null;
  @override
  Stream<String> onTokenRefresh() => const Stream.empty();
}

GameState _oyun({
  String startedAt = '2026-10-01T10:00:00.000Z',
  int turnCount = 4,
  bool bitti = false,
  GamePhase phase = GamePhase.play,
}) =>
    createInitialState().copyWith(
      phase: phase,
      startedAt: startedAt,
      turnCount: turnCount,
      isGameOver: bitti,
    );

void main() {
  group('yarimOyunHatirlatmaZamani', () {
    test('sabah ayrılan → ertesi gün 19:00 (aynı akşam 12 saatten yakın)', () {
      expect(yarimOyunHatirlatmaZamani(DateTime(2026, 10, 1, 10)),
          DateTime(2026, 10, 2, 19));
    });

    test('akşam ayrılan → ertesi gün 19:00', () {
      expect(yarimOyunHatirlatmaZamani(DateTime(2026, 10, 1, 20, 30)),
          DateTime(2026, 10, 2, 19));
    });

    test('gece yarısından sonra ayrılan → AYNI gün 19:00', () {
      expect(yarimOyunHatirlatmaZamani(DateTime(2026, 10, 2, 3)),
          DateTime(2026, 10, 2, 19));
    });

    test('tam 07:00 → aynı gün 19:00 (12 saat sınırı dahil)', () {
      expect(yarimOyunHatirlatmaZamani(DateTime(2026, 10, 2, 7)),
          DateTime(2026, 10, 2, 19));
    });

    test('ay ve yıl taşması', () {
      expect(yarimOyunHatirlatmaZamani(DateTime(2026, 12, 31, 21)),
          DateTime(2027, 1, 1, 19));
    });

    test('her zaman en az 12 saat sonra', () {
      for (var saat = 0; saat < 24; saat++) {
        final ayrilis = DateTime(2026, 10, 1, saat, 17);
        final z = yarimOyunHatirlatmaZamani(ayrilis);
        expect(z.difference(ayrilis) >= kYarimOyunEnKisaBekleme, isTrue,
            reason: '$ayrilis → $z');
        expect(z.hour, kYarimOyunHatirlatmaSaati);
      }
    });
  });

  group('yarimOyunHatirlatmasiKurulmali', () {
    bool karar({
      bool oyunSuruyor = true,
      int turSayisi = 4,
      String oyun = 'a',
      String? hatirlatilan,
      bool izinVar = true,
    }) =>
        yarimOyunHatirlatmasiKurulmali(
          oyunSuruyor: oyunSuruyor,
          turSayisi: turSayisi,
          oyunKimligi: oyun,
          hatirlatilanOyun: hatirlatilan,
          izinVar: izinVar,
        );

    test('yarım oyun + izin → kur', () => expect(karar(), isTrue));
    test('bitmiş oyun → kurma',
        () => expect(karar(oyunSuruyor: false), isFalse));
    test('hiç oynanmamış (turnCount < 2) → kurma',
        () => expect(karar(turSayisi: 1), isFalse));
    test('kimliksiz state → kurma', () => expect(karar(oyun: ''), isFalse));
    test('AYNI oyun zaten hatırlatıldı → kurma',
        () => expect(karar(hatirlatilan: 'a'), isFalse));
    test('başka bir oyun hatırlatılmıştı → kur',
        () => expect(karar(hatirlatilan: 'b'), isTrue));
    test('izin yok → kurma', () => expect(karar(izinVar: false), isFalse));
  });

  group('YarimOyunHatirlatici', () {
    late AppStorage storage;
    late _FakeZamanlayici zamanlayici;
    late _FakeMessaging messaging;
    late DateTime simdi;
    late YarimOyunHatirlatici h;

    setUp(() async {
      sqfliteFfiInit();
      SharedPreferences.setMockInitialValues({});
      storage = await AppStorage.open(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
        prefs: await SharedPreferences.getInstance(),
      );
      zamanlayici = _FakeZamanlayici();
      messaging = _FakeMessaging(PushPermission.granted);
      simdi = DateTime(2026, 10, 1, 10);
      h = YarimOyunHatirlatici(
        storage: Future.value(storage),
        zamanlayici: zamanlayici,
        messaging: messaging,
        saat: () => simdi,
      );
    });

    test('ayrılınca ertesi gün 19:00 kurulur, metin tek kaynaktan', () async {
      await h.oyundanAyrildi(_oyun());
      expect(zamanlayici.kurulanlar, [DateTime(2026, 10, 2, 19)]);
      expect(zamanlayici.baslik, kYarimOyunBaslik);
      expect(zamanlayici.govde, kYarimOyunGovde);
      expect(storage.flags.yarimOyunKurulanOyun, _oyun().startedAt);
    });

    test('izin yoksa hiçbir şey kurulmaz', () async {
      messaging.izin = PushPermission.denied;
      await h.oyundanAyrildi(_oyun());
      expect(zamanlayici.kurulanlar, isEmpty);
      expect(storage.flags.yarimOyunKurulanOyun, isNull);
    });

    test('Firebase yoksa (messaging null) hiçbir şey kurulmaz', () async {
      final hh = YarimOyunHatirlatici(
        storage: Future.value(storage),
        zamanlayici: zamanlayici,
        messaging: null,
        saat: () => simdi,
      );
      await hh.oyundanAyrildi(_oyun());
      expect(zamanlayici.kurulanlar, isEmpty);
    });

    test('erken dönüş: iptal edilir, oyun HATIRLATILMIŞ sayılmaz', () async {
      await h.oyundanAyrildi(_oyun());
      simdi = DateTime(2026, 10, 1, 22); // 19:00'dan (ertesi gün) önce döndü
      await h.uygulamaAcildi();
      expect(zamanlayici.iptalSayisi, 1);
      expect(storage.flags.yarimOyunKurulanOyun, isNull);
      expect(storage.flags.yarimOyunHatirlatilan, isNull);
      // Aynı oyundan yeniden ayrılınca YİNE kurulabilir.
      await h.oyundanAyrildi(_oyun());
      expect(zamanlayici.kurulanlar, hasLength(2));
    });

    test('bildirimden sonra dönüş: aynı oyun bir daha hatırlatılmaz', () async {
      await h.oyundanAyrildi(_oyun());
      simdi = DateTime(2026, 10, 2, 19, 30); // bildirim düştü
      await h.uygulamaAcildi();
      expect(storage.flags.yarimOyunHatirlatilan, _oyun().startedAt);
      await h.oyundanAyrildi(_oyun());
      expect(zamanlayici.kurulanlar, hasLength(1),
          reason: 'aynı yarım oyun için ikinci hatırlatma YOK');
      // Başka bir oyun ise yine hatırlatılır.
      await h.oyundanAyrildi(_oyun(startedAt: '2026-10-02T20:00:00.000Z'));
      expect(zamanlayici.kurulanlar, hasLength(2));
    });

    test('oyun bitince bekleyen hatırlatma iptal edilir', () async {
      await h.oyundanAyrildi(_oyun());
      await h.oyunBitti();
      expect(zamanlayici.iptalSayisi, 1);
      expect(storage.flags.yarimOyunKurulanOyun, isNull);
    });

    test('bekleyen yokken açılış/bitiş platforma DOKUNMAZ', () async {
      await h.uygulamaAcildi();
      await h.oyunBitti();
      expect(zamanlayici.iptalSayisi, 0);
    });

    test('bitmiş ya da hiç oynanmamış oyun kurmaz', () async {
      await h.oyundanAyrildi(_oyun(bitti: true));
      await h.oyundanAyrildi(_oyun(turnCount: 1));
      await h.oyundanAyrildi(_oyun(phase: GamePhase.setup));
      expect(zamanlayici.kurulanlar, isEmpty);
    });
  });
}
