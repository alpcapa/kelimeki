// Huni v2 mobil yarısı (`data/funnel_api.dart`) — web + SQL paritesi ve
// davranış (27 Eylül 2026, `docs/decisions/funnel-v2.md` → "PR 2").
//
// Web kaynağını (`src/utils/funnelEvents.ts`) ve sunucu fonksiyonunu
// (`log_funnel_event`) OKUR — olay/platform adı ya da `mevcut` kanalı
// ayrışırsa DÜŞER (sunucu bilinmeyen olayı SESSİZCE reddediyor, yani ayrışma
// hiçbir hata basmadan satır kaybettirirdi).
//
// ⚠ Bu testler SAHTE uçla çalışır — "sunucuya gerçekten doğru satır düştü
// mü" sorusunu CEVAPLAMAZ. Cihaz kontrolü `mobile/TESTING.md`'de.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/device_stamp.dart';
import 'package:kelimeki/src/data/funnel_api.dart';
import 'package:kelimeki/src/storage/flags_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/web_source.dart';

List<String> _tsArray(String src, String name) {
  final m = RegExp('export const $name = \\[([^\\]]*)\\]').firstMatch(src);
  expect(m, isNotNull, reason: '$name web kaynağında bulunamadı');
  return [
    for (final x in RegExp("'([a-z_]+)'").allMatches(m!.group(1)!)) x.group(1)!
  ];
}

List<String> _sqlArray(String sql, String name) {
  final m = RegExp('$name constant text\\[\\] := array\\[([^\\]]*)\\]')
      .firstMatch(sql);
  expect(m, isNotNull, reason: '$name SQL\'de bulunamadı');
  return [
    for (final x in RegExp("'([a-z_]+)'").allMatches(m!.group(1)!)) x.group(1)!
  ];
}

class _FakeGateway implements FunnelGateway {
  final calls = <Map<String, Object?>>[];
  Object? failWith;

  @override
  Future<void> logFunnelEvent({
    required String anonId,
    required String platform,
    required String event,
    String? channel,
    String? appVersion,
  }) async {
    if (failWith != null) throw failWith!;
    calls.add({
      'anon_id': anonId,
      'platform': platform,
      'event': event,
      'channel': channel,
      'app_version': appVersion,
    });
  }
}

Future<FlagsStore> _flags([Map<String, Object> init = const {}]) async {
  SharedPreferences.setMockInitialValues(init);
  return FlagsStore(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('web + SQL paritesi', () {
    final web = readRepoFile('src/utils/funnelEvents.ts');
    final sql =
        readRepoFile('supabase/migrations/20260924141953_funnel_events.sql');

    test('olay adları web ve SQL ile BİREBİR (sıra dahil)', () {
      expect(kFunnelEvents, _tsArray(web, 'FUNNEL_EVENTS'));
      expect(kFunnelEvents, _sqlArray(sql, 'v_events'));
    });

    test('platformlar web ve SQL ile birebir', () {
      expect(kFunnelPlatforms, _tsArray(web, 'FUNNEL_PLATFORMS'));
      expect(kFunnelPlatforms, _sqlArray(sql, 'v_platforms'));
    });

    test('"mevcut" kanalı ve üye olayları bayrağı web ile aynı', () {
      expect(
          web, contains("FUNNEL_EXISTING_CHANNEL = '$kFunnelExistingChannel'"));
      expect(
          web,
          contains(
              'FUNNEL_MEMBER_EVENTS_ENABLED: boolean = $kFunnelMemberEventsEnabled'));
    });

    test('İstanbul günü: 00:30 İstanbul (21:30 UTC) YENİ güne sayılır', () {
      expect(istanbulDay(DateTime.utc(2026, 9, 26, 21, 30)), '2026-09-27');
      expect(istanbulDay(DateTime.utc(2026, 9, 26, 20, 59)), '2026-09-26');
    });
  });

  group('FunnelRepo', () {
    test('yeni kurulum: land kanalı "app", sonra günün visit\'i', () async {
      final flags = await _flags();
      final g = _FakeGateway();
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'android',
          appVersion: '1.1.2',
          now: () => DateTime.utc(2026, 10, 5, 9))!;
      expect(await repo.open(), ['land', 'visit']);
      expect(g.calls.first['channel'], 'app');
      expect(g.calls.first['platform'], 'android');
      expect(g.calls.first['app_version'], '1.1.2');
      // Aynı gün ikinci açılış hiçbir şey göndermez.
      expect(await repo.open(), isEmpty);
    });

    test('eski kullanıcı (tanıtımı görmüş) → "mevcut"', () async {
      final flags = await _flags({'seen_intro': true});
      final g = _FakeGateway();
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'ios')!;
      await repo.open();
      expect(g.calls.first['channel'], kFunnelExistingChannel);
    });

    test(
        'iz OLUŞTURMA ANINDA donar — sonradan üretilen anonim kod '
        'yeni cihazı "mevcut"a çevirmez', () async {
      final flags = await _flags();
      final g = _FakeGateway();
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'ios')!;
      // Açılışta errorReporter / guest pingi kodu üretir (bootstrap sırası).
      await flags.anonId();
      await repo.open();
      expect(g.calls.first['channel'], 'app');
    });

    test(
        'land düşerse kanal DONMUŞ kalır, sonraki açılış aynı kanalla '
        'yeniden dener', () async {
      final flags = await _flags();
      final g = _FakeGateway()..failWith = Exception('ağ');
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'android')!;
      expect(await repo.open(), isEmpty);
      // İkinci açılış: artık iz var (anonim kod üretildi) ama kanal donmuş.
      g.failWith = null;
      final repo2 = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'android')!;
      expect(await repo2.open(), ['land', 'visit']);
      expect(g.calls.first['channel'], 'app');
    });

    test('ertesi İstanbul günü yeniden visit', () async {
      final flags = await _flags();
      final g = _FakeGateway();
      var now = DateTime.utc(2026, 10, 5, 9);
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: false,
          platform: 'android',
          now: () => now)!;
      await repo.open();
      now = DateTime.utc(2026, 10, 6, 9);
      expect(await repo.open(), ['visit']);
    });

    test('platform iOS/Android değilse repo YOK (app-web yazılmaz)', () async {
      final flags = await _flags();
      expect(
          FunnelRepo.create(
              gateway: _FakeGateway(),
              stamp: DeviceStamp(flags),
              signedIn: false,
              platform: 'app-web'),
          isNull);
    });

    test('olaylar: game_start / signup / üye game_finish gider', () async {
      final flags = await _flags();
      final g = _FakeGateway();
      final repo = FunnelRepo.create(
          gateway: g,
          stamp: DeviceStamp(flags),
          signedIn: true,
          platform: 'ios')!;
      expect(await repo.event('game_start', isGuest: false), isTrue);
      expect(await repo.event('game_finish', isGuest: false), isTrue);
      expect(await repo.event('signup', isGuest: true), isTrue);
      expect([for (final c in g.calls) c['event']],
          ['game_start', 'game_finish', 'signup']);
      // Kanal YALNIZCA land satırında (web sözleşmesi).
      expect(g.calls.every((c) => c['channel'] == null), isTrue);
    });
  });
}
