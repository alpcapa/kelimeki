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
import 'package:kelimeki/src/data/device_info.dart';
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
    String? osVersion,
    String? deviceModel,
  }) async {
    if (failWith != null) throw failWith!;
    inserts.add({
      'anon_id': anonId,
      'utm_source': utmSource,
      'device_type': deviceType,
      'os_version': osVersion,
      'device_model': deviceModel,
    });
  }

  final deviceInserts = <Map<String, Object?>>[];

  @override
  Future<void> insertDeviceVisit({
    required String anonId,
    required String deviceType,
    String? osVersion,
    String? deviceModel,
  }) async {
    if (failWith != null) throw failWith!;
    deviceInserts.add({
      'anon_id': anonId,
      'device_type': deviceType,
      'os_version': osVersion,
      'device_model': deviceModel,
    });
  }
}

Future<DeviceDetails> _details() async => (osVersion: '14', model: 'SM-G991B');

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
      final repo =
          VisitsRepo(g, _stamp(), today: () => '2026-09-22', details: _details);
      expect(await repo.pingGuestVisit(), isTrue);
      expect(g.inserts.single['utm_source'], 'app');
      expect(g.inserts.single['anon_id'], isNotEmpty);
      // Web'in `getDeviceType()` söz dağarcığı — testte hedef `desktop`.
      expect(
          g.inserts.single['device_type'], anyOf('ios', 'android', 'desktop'));
    });

    // Huni bilinçli olarak misafir-only; sunucu da RLS ile zorluyor, yani
    // girişliyken denemek sessiz bir hata olurdu.
    test('GİRİŞLİYKEN hiç yazmaz', () async {
      final g = _FakeVisitsGateway()..signedIn = true;
      final repo =
          VisitsRepo(g, _stamp(), today: () => '2026-09-22', details: _details);
      expect(await repo.pingGuestVisit(), isFalse);
      expect(g.inserts, isEmpty);
    });

    test('günde BİR KEZ — aynı gün ikinci çağrı yazmaz', () async {
      final g = _FakeVisitsGateway();
      final stamp = _stamp();
      final repo =
          VisitsRepo(g, stamp, today: () => '2026-09-22', details: _details);
      expect(await repo.pingGuestVisit(), isTrue);
      expect(await repo.pingGuestVisit(), isFalse);
      expect(g.inserts, hasLength(1));
    });

    test('ERTESİ GÜN yeniden yazar', () async {
      final g = _FakeVisitsGateway();
      final stamp = _stamp();
      var gun = '2026-09-22';
      final repo = VisitsRepo(g, stamp, today: () => gun, details: _details);
      expect(await repo.pingGuestVisit(), isTrue);
      gun = '2026-09-23';
      expect(await repo.pingGuestVisit(), isTrue);
      expect(g.inserts, hasLength(2));
    });

    // Damga YAZMADAN SONRA konuyor: insert düşerse o gün yanmamalı.
    test('insert düşerse gün damgası YANMAZ — yarın tekrar denenir', () async {
      final g = _FakeVisitsGateway()..failWith = StateError('ağ');
      final stamp = _stamp();
      var gun = '2026-09-22';
      final repo = VisitsRepo(g, stamp, today: () => gun, details: _details);
      expect(await repo.pingGuestVisit(), isFalse); // yutuldu
      g.failWith = null;
      expect(await repo.pingGuestVisit(), isTrue); // AYNI gün tekrar denendi
      expect(g.inserts, hasLength(1));
    });
  });

  // ROADMAP #40 (27 Eylül 2026): admin "Cihaz"/"Cihaz Markası" kartları
  // `device_visits`ten besleniyor ve port oraya hiç yazmıyordu.
  group('device_visits pingi', () {
    test('GİRİŞLİYKEN DE yazar — sürüm + model dolu, user_id yok', () async {
      final g = _FakeVisitsGateway()..signedIn = true;
      final repo =
          VisitsRepo(g, _stamp(), today: () => '2026-09-27', details: _details);
      expect(await repo.pingDeviceVisit(), isTrue);
      expect(g.deviceInserts.single['os_version'], '14');
      expect(g.deviceInserts.single['device_model'], 'SM-G991B');
      expect(g.deviceInserts.single.containsKey('user_id'), isFalse);
      // Misafir pingi girişliyken yine YAZMAZ (huni misafir-only).
      expect(await repo.pingGuestVisit(), isFalse);
    });

    test('günde bir — ve misafir pingiyle damga PAYLAŞMAZ', () async {
      final g = _FakeVisitsGateway();
      final repo =
          VisitsRepo(g, _stamp(), today: () => '2026-09-27', details: _details);
      expect(await repo.pingGuestVisit(), isTrue);
      expect(await repo.pingDeviceVisit(), isTrue,
          reason: 'misafir pingi cihaz pingini bastırmamalı');
      expect(await repo.pingDeviceVisit(), isFalse);
      expect(g.deviceInserts, hasLength(1));
      // guest_visits de artık sürüm/model taşıyor.
      expect(g.inserts.single['os_version'], '14');
    });

    test('insert düşerse damga YANMAZ', () async {
      final g = _FakeVisitsGateway()..failWith = Exception('ağ');
      final repo =
          VisitsRepo(g, _stamp(), today: () => '2026-09-27', details: _details);
      expect(await repo.pingDeviceVisit(), isFalse);
      g.failWith = null;
      expect(await repo.pingDeviceVisit(), isTrue);
    });
  });

  group('cihaz bilgisi — web söz dağarcığı (visitTracking.ts)', () {
    test('iOS: makine kodu → genel kategori (web satırlarıyla aynı)', () {
      expect(
          iosModelCategory(machine: 'iPhone15,2', model: 'iPhone'), 'iPhone');
      expect(iosModelCategory(machine: 'iPad13,4', model: 'iPad'), 'iPad');
      // Simülatör: makine kodu mimari adı, `model`e düşülür.
      expect(iosModelCategory(machine: 'arm64', model: 'iPad'), 'iPad');
      expect(iosModelCategory(machine: null, model: null), isNull);
    });

    test('Android modeli 60 karakterle kırpılır, boş → null', () {
      expect(androidModel(' SM-G991B '), 'SM-G991B');
      expect(androidModel('x' * 80), hasLength(60));
      expect(androidModel(''), isNull);
      expect(osVersionOrNull(' '), isNull);
      expect(osVersionOrNull('18.1'), '18.1');
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
