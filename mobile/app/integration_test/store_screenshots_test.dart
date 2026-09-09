// Mağaza ekran görüntüsü üreticisi — App Store FAZ C 24.5.
//
// NEDEN BU DOSYA VAR: mağazaya giden kare, uygulamanın GERÇEK görüntüsü
// olmak zorunda. `marketing/play-store/metin.md`'deki yazılı karar farklı
// bir yüzeyden (emülatör/web) alınan görseli *yanıltıcı ekran görüntüsü*
// sayıyor; `marketing/app-store/console-formlari.md` §13 aynı gerekçeyle
// widget testinden çizmeyi de eledi (aynı Dart ağacı, ama iOS çalışma
// zamanı değil). Kalan tek doğru kaynak: iOS SİMÜLATÖRÜ — gerçek iOS,
// gerçek uygulama ikilisi, Xcode'un kendi yolu.
//
// NASIL KOŞAR: `flutter drive` ile, `test_driver/integration_test.dart`
// sürücüsüne karşı. Kareyi sürücü yazar (`onScreenshot`), boyutu cihazın
// fiziksel pikseli belirler — iPhone 6.9" 1320×2868, iPad 13" 2064×2752,
// yani Apple'ın istediği ölçü KIRPMADAN çıkar. ⚠ Play refleksiyle kırpma:
// App Store tam ölçü istiyor, kırpmak kareyi GEÇERSİZ yapar.
// Komut CI'da: `.github/workflows/ios-screenshots.yml`.
//
// ⚠ FIXTURE DEPOYA GİRMEZ. Tahta, gerçek motorla ve tohumlu rastgelelikle
// KOŞMA ANINDA üretiliyor (`Mulberry32`) — golden JSON'u asset olarak
// paketlemek onu mağazaya giden uygulama ikilisine de sokardı.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kelimeki/src/data/meaning_entry.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/meaning_modal.dart';
import 'package:kelimeki/src/ui/route_observer.dart';
import 'package:kelimeki/src/ui/score/score_card_modal.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';

// Sahne (sahte oturum/servisler, tohumlu tahta, `settle`) İKİ çekim
// dosyasının ORTAK kaynağında — kopyalanırsa "temsili kare" kuralları
// sessizce ayrışır. Bkz. o dosyanın başlığı.
import 'support/sahne.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(sozlukYukle);

  testWidgets('01 — oyun ekranı, oyunun ortası', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await binding.takeScreenshot('01-oyun-ekrani');
    controller.dispose();
  });

  testWidgets('02 — kurulmuş hamle (yeşil dış hat + puan rozeti)',
      (tester) async {
    final controller = oyunKontrolcusu();
    stageBestMove(controller);
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await binding.takeScreenshot('02-kurulmus-hamle');
    controller.dispose();
  });

  testWidgets('03 — kurulum ekranı, "Arkadaşınla" sekmesi', (tester) async {
    // Üretimdeki `navigatorObservers` ile AYNI olmak zorunda: Setup'ın
    // "bir ekrandan dönüldü" tazelemesi `RouteAware.didPopNext`ten geliyor.
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      navigatorObservers: [kRouteObserver],
      home: SetupScreen(services: setupServisleri()),
    ));
    await settle(tester);
    // Ekran "Yapay Zeka ile" sekmesiyle açılıyor; kare Canlı oyunu
    // anlatacak, o yüzden sekme DEĞİŞTİRİLİYOR (gerçek dokunuşla).
    await tester.tap(find.text('ARKADAŞINLA'));
    await settle(tester);

    await binding.takeScreenshot('03-arkadasinla');
  });

  testWidgets('04 — skor kartı', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: Scaffold(
        body: ScoreCardModal(
          auth: sahneAuth(),
          stats: StatsRepo(SahteStatsGateway()),
        ),
      ),
    ));
    await settle(tester);

    await binding.takeScreenshot('04-skor-karti');
  });

  testWidgets('05 — kelime anlamı (TDK penceresi)', (tester) async {
    // Anlam GERÇEK asset'ten okunuyor (`meanings.db`), metin UYDURULMUYOR.
    // ⚠ `runAsync` ŞART: `MeaningStore` gerçek sqflite async'i kullanıyor ve
    // testin sahte zaman bölgesinde çözülmüyor (widget testlerinin bu
    // yüzden hiç deneyemediği yol — burada gerçek cihazdayız).
    final store = MeaningStore(bundle: rootBundle);
    MeaningEntry? kayit;
    await tester.runAsync(() async {
      kayit = await store.lookup(kMeaningWord);
    });

    final controller = oyunKontrolcusu();
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      navigatorKey: navKey,
      home: GameScreen(
        controller: controller,
        words: sahneSozlugu,
        auth: sahneAuth(),
      ),
    ));
    await settle(tester);

    // Pencereyi üretim yolundan aç — tahtadaki bir taşa dokunulduğunda
    // çağrılan fonksiyonun ta kendisi.
    unawaited(showMeaningModal(
      navKey.currentContext!,
      (_) async => kayit,
      const [kMeaningWord],
    ));
    await settle(tester);

    await binding.takeScreenshot('05-kelime-anlami');
    controller.dispose();
  });

  testWidgets('06 — nasıl oynanır', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: const HelpModal(),
    ));
    await settle(tester);

    await binding.takeScreenshot('06-nasil-oynanir');
  });
}
