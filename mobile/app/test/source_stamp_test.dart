// Kaynak damgası — huninin DÖRT adımı da app'te dolu mu (22 Eylül 2026).
//
// NEDEN VAR: admin panelinin Kaynak Hunisi'nde app görünmüyordu; kullanıcı
// bildirdi (*"bilinmeyen 1, üye 20… %2000 conversion not possible"*) ve
// asıl işi istedi: *"Kaynak belliyse onun altına girecek, değilse
// 'bilinmiyor'da yazacak (ki bilinmemesi mümkün olmamalı çünkü ya web'den
// direkt gelmiştir ya da app'den)"*. Gerekçenin tamamı `device_stamp.dart`.
//
// ⚠ Bu testler SAHTE uçlarla çalışır — "sunucuya gerçekten doğru satır
// düştü mü" sorusunu CEVAPLAMAZ. Cihaz kontrolü `mobile/TESTING.md`'de.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/device_stamp.dart';
import 'package:kelimeki/src/data/visits_api.dart';
import 'package:kelimeki/src/storage/flags_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeVisitsGateway implements VisitsGateway {
  @override
  bool signedIn = false;

  final inserts = <Map<String, Object?>>[];
  Object? failWith;

  @override
  Future<void> insertGuestVisit({
    required String anonId,
    required String? utmSource,
    required String? deviceType,
  }) async {
    if (failWith != null) throw failWith!;
    inserts.add({
      'anon_id': anonId,
      'utm_source': utmSource,
      'device_type': deviceType,
    });
  }
}

Future<DeviceStamp> _stamp({String? utm}) async {
  SharedPreferences.setMockInitialValues({
    if (utm != null) 'utm_source': utm,
  });
  return DeviceStamp(FlagsStore(await SharedPreferences.getInstance()));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceStamp — kaynak etiketi', () {
    test('damga yoksa app', () async {
      final s = await _stamp();
      expect(s.source, 'app');
      expect(s.source, kAppSource);
    });

    // ⚠ Sıra sözleşme: Instagram'dan gelip uygulamayı kuran kişi Instagram
    // satırında KALMALI. `?? 'app'` yerine sabit 'app' yazmak bunu bozardı.
    test('deep link kaynağı VARSA o kazanır — app EZMEZ', () async {
      final s = await _stamp(utm: 'ig-bio');
      expect(s.source, 'ig-bio');
    });

    test('anonId kalıcı: ikinci çağrı AYNI kodu verir', () async {
      final s = await _stamp();
      final bir = await s.anonId();
      final iki = await s.anonId();
      expect(bir, iki);
      expect(bir, isNotEmpty);
    });
  });

  group('guest_visits pingi', () {
    test('misafirde yazar — kaynak app, cihaz tipi dolu', () async {
      final g = _FakeVisitsGateway();
      final repo = VisitsRepo(g, _stamp(), today: () => '2026-09-22');
      expect(await repo.pingGuestVisit(), isTrue);
      expect(g.inserts.single['utm_source'], 'app');
      expect(g.inserts.single['anon_id'], isNotEmpty);
      // Web'in `getDeviceType()` söz dağarcığı — testte hedef `desktop`.
      expect(g.inserts.single['device_type'],
          anyOf('ios', 'android', 'desktop'));
    });

    // Huni bilinçli olarak misafir-only; sunucu da RLS ile zorluyor, yani
    // girişliyken denemek sessiz bir hata olurdu.
    test('GİRİŞLİYKEN hiç yazmaz', () async {
      final g = _FakeVisitsGateway()..signedIn = true;
      final repo = VisitsRepo(g, _stamp(), today: () => '2026-09-22');
      expect(await repo.pingGuestVisit(), isFalse);
      expect(g.inserts, isEmpty);
    });

    test('günde BİR KEZ — aynı gün ikinci çağrı yazmaz', () async {
      final g = _FakeVisitsGateway();
      final stamp = _stamp();
      final repo = VisitsRepo(g, stamp, today: () => '2026-09-22');
      expect(await repo.pingGuestVisit(), isTrue);
      expect(await repo.pingGuestVisit(), isFalse);
      expect(g.inserts, hasLength(1));
    });

    test('ERTESİ GÜN yeniden yazar', () async {
      final g = _FakeVisitsGateway();
      final stamp = _stamp();
      var gun = '2026-09-22';
      final repo = VisitsRepo(g, stamp, today: () => gun);
      expect(await repo.pingGuestVisit(), isTrue);
      gun = '2026-09-23';
      expect(await repo.pingGuestVisit(), isTrue);
      expect(g.inserts, hasLength(2));
    });

    // Damga YAZMADAN SONRA konuyor: insert düşerse o gün yanmamalı.
    test('insert düşerse gün damgası YANMAZ — yarın tekrar denenir',
        () async {
      final g = _FakeVisitsGateway()..failWith = StateError('ağ');
      final stamp = _stamp();
      var gun = '2026-09-22';
      final repo = VisitsRepo(g, stamp, today: () => gun);
      expect(await repo.pingGuestVisit(), isFalse); // yutuldu
      g.failWith = null;
      expect(await repo.pingGuestVisit(), isTrue); // AYNI gün tekrar denendi
      expect(g.inserts, hasLength(1));
    });
  });

  group('device_type — web söz dağarcığı', () {
    // Ayrışırsa panelin "Cihaz" dökümü aynı cihazı iki satıra böler.
    test('ios/android aynen, bilinmeyen hedef desktop', () {
      expect(deviceTypeForVisit('ios'), 'ios');
      expect(deviceTypeForVisit('android'), 'android');
      // `app-web` portun tarayıcı test hâli — `guest_visits` tanımıyor.
      expect(deviceTypeForVisit('app-web'), 'desktop');
      expect(deviceTypeForVisit(null), 'desktop');
    });
  });
}
