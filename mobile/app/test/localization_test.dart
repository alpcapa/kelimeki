// Yerelleştirme kapısı (15 Eylül 2026, Parça 209) — İKİ ayrı şey ölçülüyor
// ve ikisi birbirinin yerine geçmez:
//
// 1. **Uygulama İÇİ:** Flutter'ın kendi widget metinleri (metin seçme menüsü,
//    semantik etiketler, tarih/saat seçici). Kaynağı `MaterialApp`in
//    `localizationsDelegates`/`supportedLocales`ı. Bunlar konmadan
//    `DefaultMaterialLocalizations` (İngilizce) devreye giriyordu; uygulamanın
//    kendi metinlerinin tamamı Türkçe olduğundan ekranda karışık dil çıkıyordu.
// 2. **Mağaza etiketi:** App Store ürün sayfasındaki "LANGUAGE" satırı
//    `ios/Runner/Info.plist`teki `CFBundleLocalizations`tan okunuyor
//    (Parça 208). Kullanıcı sayfada "EN English" gördüğü için bu tur başladı.
//
// Test ikisini de kilitliyor, çünkü ikisi de derleyicinin GÖREMEYECEĞİ türden:
// delegeler düşerse hiçbir şey kırılmaz, metinler sessizce İngilizceye döner.
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/ui/app.dart';
import 'package:kelimeki/src/util/online_status.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

AppServices testServices() => AppServices(
      onlineStatus: OnlineStatus.fake(),
      dictionary: Future.value(SetWordSource(const ['ab'])),
      meanings: MeaningStore(bundle: rootBundle),
      auth: AuthService(null),
      supabase: null,
      versionGate: VersionGateStatus.ok,
    );

void main() {
  testWidgets('Flutter\'ın KENDİ metinleri Türkçe (Material + Cupertino)',
      (tester) async {
    await tester.pumpWidget(KelimekiApp(services: testServices()));
    final ctx = tester.element(find.byType(Navigator).first);

    // Material: metin seçme menüsü + genel etiketler.
    final m = MaterialLocalizations.of(ctx);
    expect(m.pasteButtonLabel, 'Yapıştır');
    expect(m.copyButtonLabel, 'Kopyala');
    expect(m.cancelButtonLabel, 'İptal');

    // ⚠ Cupertino AYRI bir delege: iOS'ta metin seçme araç çubuğunu O
    // çiziyor. Yalnız Material delegesi konulsaydı bu satır İngilizce
    // kalırdı ve hata yalnızca iPhone'da görünürdü.
    expect(CupertinoLocalizations.of(ctx).pasteButtonLabel, 'Yapıştır');

    // Widgets delegesi: metin yönü/semantik altyapısı.
    expect(Localizations.localeOf(ctx), const Locale('tr'));
  });

  testWidgets('cihaz dili desteklenmese bile Türkçeye düşülür', (tester) async {
    // Kullanıcının iPad'i İngilizceydi; "cihaz Türkçe olmadığı için" diye
    // yanlış teşhis edilmesin diye bu dal ayrıca sınanıyor. `locale`
    // sabitlenmediğinden güvence Flutter'ın çözümleyicisinde: eşleşme yoksa
    // `supportedLocales.first` (= tr).
    tester.platformDispatcher.localesTestValue = const [
      Locale('en', 'US'),
      Locale('de'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(KelimekiApp(services: testServices()));
    final ctx = tester.element(find.byType(Navigator).first);
    expect(Localizations.localeOf(ctx), const Locale('tr'));
    expect(MaterialLocalizations.of(ctx).pasteButtonLabel, 'Yapıştır');
  });

  test('iOS paketi kendini TÜRKÇE ilan eder (App Store "LANGUAGE" satırı)',
      () {
    // Apple ürün sayfasındaki dili Connect'ten DEĞİL paketten okuyor: önce
    // CFBundleLocalizations, yoksa CFBundleDevelopmentRegion. 15 Eylül
    // 2026'ya kadar birincisi hiç yoktu, ikincisi `$(DEVELOPMENT_LANGUAGE)`
    // → pbxproj'deki `developmentRegion = en` idi; sayfa "EN English"
    // diyordu. Bu iddia plist'i METİN olarak okuyor (plist ayrıştırıcısı
    // yok, bağımlılık eklemeye değmez).
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final region = RegExp(
            r'<key>CFBundleDevelopmentRegion</key>\s*<string>([^<]*)</string>')
        .firstMatch(plist);
    expect(region?.group(1), 'tr',
        reason: 'CFBundleDevelopmentRegion `tr` olmalı');

    final locs = RegExp(
            r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
            dotAll: true)
        .firstMatch(plist);
    expect(locs, isNotNull,
        reason: 'CFBundleLocalizations anahtarı bulunmalı');
    expect(locs!.group(1), contains('<string>tr</string>'));

    // Xcode projesi de aynı şeyi söylemeli — ikisi ayrışırsa hangisinin
    // kazandığı derlemeye/araca göre değişir, yani sessiz bir tuzak olur.
    final pbx =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(pbx, contains('developmentRegion = tr;'));
  });
}
