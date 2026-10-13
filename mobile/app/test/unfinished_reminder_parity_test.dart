// Yarım kalan oyun hatırlatması kanalı — Dart ↔ Kotlin ↔ Swift paritesi
// (1 Ekim 2026). `notification_shade_parity_test.dart` ile aynı ders: kanal ve
// metot adları üç dilde ELLE yazılı ve Dart tarafı `MissingPluginException`ı
// BİLEREK yutuyor (web/test ortamında kanal yok) — yani yanlış bir ad hiçbir
// hata göstermez, yalnızca hatırlatma hiç kurulmaz ve kimse fark etmez.
//
// Kaynak TARAMASI yapıyor; Kotlin/Swift bu test çatısından koşturulamaz.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/unfinished_game_reminder.dart';

File _repo(String rel) => File('../../$rel');

/// Yorumları söker — adlar dokümantasyon yorumlarında da geçiyor, kontrol
/// yorumdan beslenirse yalan söyler (notification_shade_parity_test dersi).
String _yorumsuz(String kaynak) => kaynak
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .replaceAll(RegExp(r'//.*'), '');

void main() {
  const kotlinYol =
      'mobile/app/android/app/src/main/kotlin/com/kelimeki/kelimeki/MainActivity.kt';
  const alarmYol =
      'mobile/app/android/app/src/main/kotlin/com/kelimeki/kelimeki/YarimOyunHatirlatmasi.kt';
  const swiftYol = 'mobile/app/ios/Runner/AppDelegate.swift';
  const manifestYol = 'mobile/app/android/app/src/main/AndroidManifest.xml';

  late String kotlin;
  late String alarm;
  late String swift;
  late String manifest;

  setUpAll(() {
    for (final y in [kotlinYol, alarmYol, swiftYol, manifestYol]) {
      expect(_repo(y).existsSync(), isTrue, reason: '$y bulunamadı');
    }
    kotlin = _yorumsuz(_repo(kotlinYol).readAsStringSync());
    alarm = _yorumsuz(_repo(alarmYol).readAsStringSync());
    swift = _yorumsuz(_repo(swiftYol).readAsStringSync());
    manifest = _repo(manifestYol).readAsStringSync();
  });

  final kanal = PlatformHatirlatmaZamanlayici.kanal.name;
  const kur = PlatformHatirlatmaZamanlayici.kurMetot;
  const iptal = PlatformHatirlatmaZamanlayici.iptalMetot;
  const ayar = PlatformHatirlatmaZamanlayici.ayarMetot;

  test('kanal adı Kotlin ve Swift\'te BİREBİR aynı', () {
    expect(kotlin, contains('"$kanal"'),
        reason: 'MainActivity "$kanal" kanalını kurmuyor');
    expect(swift, contains('name: "$kanal"'),
        reason: 'AppDelegate "$kanal" kanalını kurmuyor');
  });

  test('metot adları iki platformda da tanınıyor', () {
    for (final m in [kur, iptal, ayar]) {
      expect(kotlin, contains('"$m" ->'), reason: 'Kotlin `when` "$m" yok');
      expect(swift, contains('case "$m":'), reason: 'Swift `switch` "$m" yok');
    }
  });

  test('argüman anahtarları (zamanMs/baslik/govde) iki platformda aynı', () {
    for (final a in ['zamanMs', 'baslik', 'govde']) {
      expect(kotlin, contains('argument<'),
          reason: 'Kotlin argümanları okumuyor');
      expect(kotlin, contains('"$a"'), reason: 'Kotlin "$a" okumuyor');
      expect(swift, contains('arg["$a"]'), reason: 'Swift "$a" okumuyor');
    }
  });

  test('Android: İŞİ yapıyor (alarm + iptal + bildirim) ve alıcı manifestte',
      () {
    expect(alarm, contains('setAndAllowWhileIdle('));
    expect(alarm, contains('.cancel('));
    expect(alarm, contains('.notify('));
    // Push'larla AYNI kanal — MainActivity'nin yarattığı tek kanal.
    expect(alarm, contains('"kelimeki_oyun"'));
    expect(manifest, contains('android:name=".YarimOyunAlicisi"'),
        reason: 'Alıcı manifestte yoksa alarm çalar, bildirim ÇIKMAZ');
    // Tam zamanlı alarm izni İSTENMİYOR (bilinçli — Play beyanı gerektirir).
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
  });

  test('iOS: İŞİ yapıyor (istek ekle + bekleyeni kaldır)', () {
    expect(swift, contains('UNTimeIntervalNotificationTrigger('));
    expect(swift, contains('removePendingNotificationRequests('));
  });

  test('"Bildirimler kapalı" kartı: iki platform da UYGULAMANIN bildirim '
      'ayarını açıyor', () {
    expect(kotlin, contains('Settings.ACTION_APP_NOTIFICATION_SETTINGS'));
    expect(kotlin, contains('Settings.EXTRA_APP_PACKAGE'));
    expect(swift, contains('UIApplication.openNotificationSettingsURLString'));
    expect(swift, contains('UIApplication.openSettingsURLString'),
        reason: 'iOS 16 altı için genel Ayarlar yedeği');
  });
}
