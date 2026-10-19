// Kurulum kaynağı damgası (#46-1, 13 Ekim 2026): referrer → DeviceStamp.source.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/device_stamp.dart';
import 'package:kelimeki/src/data/install_source_stamp.dart';
import 'package:kelimeki/src/storage/flags_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<FlagsStore> _flags([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return FlagsStore(await SharedPreferences.getInstance());
}

void main() {
  test('geçerli etiket damgaya yazılır; DeviceStamp.source onu verir',
      () async {
    final f = await _flags();
    final r = await stampInstallSource(
        flags: f,
        platform: 'android',
        readInstallReferrer: () async => 'utm_source=meta-reel&utm_medium=web');
    expect(r, 'meta-reel');
    expect(DeviceStamp(f).source, 'meta-reel');
    expect(f.installSourceStamped, isTrue);
  });

  test('organik kurulum: etiket yok → source app kalır, bayrak yazılır',
      () async {
    final f = await _flags();
    final r = await stampInstallSource(
        flags: f,
        platform: 'android',
        readInstallReferrer: () async =>
            'utm_source=google-play&utm_medium=organic');
    expect(DeviceStamp(f).source, 'app');
    expect(f.installSourceStamped, isTrue);
    expect(r == null || r.isNotEmpty, isTrue);
  });

  test('bozuk / boş dize: source app kalır', () async {
    for (final raw in ['', '%%%', 'utm_source=', null]) {
      final f = await _flags();
      await stampInstallSource(
          flags: f, platform: 'android', readInstallReferrer: () async => raw);
      expect(DeviceStamp(f).source, 'app', reason: '$raw');
    }
  });

  test('eski cihaz (anon kod var): yine okunur, land kanalına dokunulmaz',
      () async {
    final f = await _flags({'anon_id': 'x'});
    await f.anonId();
    await stampInstallSource(
        flags: f,
        platform: 'android',
        readInstallReferrer: () async => 'utm_source=instagram');
    expect(DeviceStamp(f).source, 'instagram');
    expect(f.funnelLandChannel, isNull);
  });

  test('first-touch: var olan kaynak ezilmez', () async {
    final f = await _flags();
    await f.captureUtmSource('facebook');
    await stampInstallSource(
        flags: f,
        platform: 'android',
        readInstallReferrer: () async => 'utm_source=instagram');
    expect(DeviceStamp(f).source, 'facebook');
  });

  test('bir kez: bayrak varsa yeniden okunmaz', () async {
    final f = await _flags();
    var n = 0;
    Future<String?> read() async {
      n++;
      return 'utm_source=instagram';
    }

    await stampInstallSource(
        flags: f, platform: 'android', readInstallReferrer: read);
    await stampInstallSource(
        flags: f, platform: 'android', readInstallReferrer: read);
    expect(n, 1);
  });

  test('okuma düşerse fırlatmaz, bayrak YAZILMAZ (sonra yeniden dener)',
      () async {
    final f = await _flags();
    final r = await stampInstallSource(
        flags: f,
        platform: 'android',
        readInstallReferrer: () async => throw Exception('play yok'));
    expect(r, isNull);
    expect(f.installSourceStamped, isFalse);
    expect(DeviceStamp(f).source, 'app');
  });

  test('iOS: hiç okunmaz', () async {
    final f = await _flags();
    var n = 0;
    await stampInstallSource(
        flags: f,
        platform: 'ios',
        readInstallReferrer: () async {
          n++;
          return 'utm_source=instagram';
        });
    expect(n, 0);
    expect(DeviceStamp(f).source, 'app');
  });
}
