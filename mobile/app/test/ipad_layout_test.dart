// iPad DÜZEN KAPISI — `mobile/TESTING.md` §26; kararın tam kaydı
// `docs/decisions/roadmap-arsiv.md` → §25 (ROADMAP'ten arşive taşındı).
//
// NEDEN BU DOSYA VAR: Apple bundle'ı 90474 ile reddedince `Info.plist`
// iPad için DÖRT yönelimi bildirmek zorunda kaldı (#501), yani uygulama
// iPad'de artık döndürülebilir ve `main.dart`in portre kilidi orada FİİLEN
// ÖLÜ. Manzara böylece "ihtimal" olmaktan çıkıp kullanıcının bir saniyede
// ulaştığı hâle geldi.
//
// KARAR (9 Eylül 2026, kullanıcı — arşiv §25): manzaraya ÖZGÜ bir düzen
// YAPILMAYACAK. Sözleri birebir: *"Eğer Apple açısından sıkıntı yoksa bazı
// ekran tiplerinde alt kısımda boşluk kalması ok. Sonuçta her ekran tipine
// göre ekran design etmek çok maliyetli bir iş olur ve riskli olur."*
// Apple tarafı ölçüldü: 2.4.1'de letterboxing/"ekranı tam kullan" yasağı
// yok, tek sert kapı olan 90474 kapandı.
//
// ⚠ O KARAR BU TESTİN NE SORDUĞUNU BELİRLER. Soru *"iyi mi?"* DEĞİL,
// **"kırılmıyor mu?"**. Kenar/alt boşluğu bir bulgu değil, BİLİNÇLİ KABUL —
// o yüzden burada boşluk ölçülmez. Ölçülen üç şey: taşma yok · tahta ve raf
// ekranın içinde · ana butonlar erişilebilir.
//
// ⚠ NEDEN SİMÜLATÖRDE DEĞİL BURADA (9 Eylül 2026'da ölçüldü ve ELENDİ):
// ölçüm önce `integration_test` + gerçek iPad Pro 13" simülatörüne kuruldu
// (`ios-screenshots.yml`e ikinci bir iş). Simülatör DÖNMEDİ ve sebebini
// iOS'un kendisi söyledi:
//   UISceneErrorDomain Code=101 "The current windowing mode does not allow
//   for programmatic changes to interface orientation."
// Yani çoklu göreve açık bir iPad uygulamasında `setPreferredOrientations`
// İKİ YÖNDE DE geçersiz. Manzara metriklerini kurabilen tek şey
// `tester.view.physicalSize` override'ı — o da platformdan bağımsız, yani
// 14 dakikalık bir macOS işi hiçbir şey eklemiyordu. Kapı buraya indi:
// ücretsiz, saniyeler sürüyor ve her push'ta koşuyor.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/board_widget.dart' show BoardWidget;
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/rack_widget.dart' show RackWidget;
import 'package:kelimeki/src/ui/route_observer.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/online_status.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kelimeki_core/kelimeki_core.dart';

import 'support/test_fonts.dart';

late SetWordSource words;

/// iPad Pro 13" — mağaza setinin de cihazı: 2064×2752 fiziksel, dpr 2.
/// Manzara bunun tersi. Dar pencere, Split View'ın üçte birlik kolonu:
/// manzara GENİŞLİĞİNİN üçte biri × manzara yüksekliği (gerçek Split View
/// jesti simülatörde otomatikleştirilemiyor, ama ürettiği ÖLÇÜ bu).
const Size kPortre = Size(1032, 1376);
const Size kManzara = Size(1376, 1032);
const Size kDarPencere = Size(458, 1032);

Future<void> gorunum(WidgetTester tester, Size boyut) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  addTearDown(tester.view.reset);
  await tester.binding.setSurfaceSize(boyut);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// `pumpAndSettle` BİLEREK kullanılmıyor: ekranda süren bir animasyon varsa
/// (nömorfik geçişler, balonlar) sonsuza kadar bekler.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Bir widget'ın ekranın İÇİNDE kalıp kalmadığı — "erişilebilir mi"
/// sorusunun ölçülebilir hâli. Boşluk ölçmez (bkz. başlıktaki karar).
void ekraninIcinde(WidgetTester tester, String ad, Finder f) {
  expect(f, findsWidgets, reason: '$ad bulunamadı');
  final r = tester.getRect(f.first);
  final ekran = Offset.zero & tester.view.physicalSize;
  expect(ekran.contains(r.topLeft) && ekran.contains(r.bottomRight - const Offset(0.01, 0.01)),
      isTrue,
      reason: '$ad ekranın dışına taşıyor: $r (ekran $ekran)');
}

/// Tahtayı GERÇEK motorla, tohumlu olarak doldurur — elle "güzel" bir tahta
/// uydurulmaz. Dolu tahta düzenin ZOR hâli; boş tahta hiçbir şey kanıtlamaz.
GameState doluTahta() {
  final engine = GameEngine(words: words, rng: Mulberry32(11), nowIso: () => '');
  var s = engine.reduce(
    createInitialState(),
    const StartAction([
      PlayerSetup(name: '', isAI: true),
      PlayerSetup(name: '', isAI: true),
    ]),
  );
  for (var i = 0; i < 12 && !s.isGameOver; i++) {
    s = engine.reduce(s, const AiPlayAction());
  }
  return s.copyWith(players: [
    s.players[0].copyWith(name: 'Ironman', isAI: false),
    s.players[1],
  ]);
}

AppServices kurulumServisleri() => AppServices(
      onlineStatus: OnlineStatus.fake(),
      dictionary: Future.value(words),
      meanings: MeaningStore(bundle: rootBundle),
      auth: AuthService(null),
      supabase: null,
      versionGate: VersionGateStatus.ok,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadAppFonts();
    final f = File('assets/dictionary/words_tr.txt');
    words = SetWordSource(const LineSplitter()
        .convert(f.readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  for (final MapEntry(key: ad, value: boyut) in {
    'portre': kPortre,
    'manzara': kManzara,
    'Split View (1/3)': kDarPencere,
  }.entries) {
    testWidgets('oyun ekranı — $ad', (tester) async {
      await gorunum(tester, boyut);
      final controller =
          GameController(words: words, autoPlayAi: false, nowIso: () => '');
      controller.dispatch(ResumeSavedAction(doluTahta()));
      addTearDown(controller.dispose);

      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: GameScreen(
            controller: controller, words: words, auth: AuthService.fake()),
      ));
      await settle(tester);

      expect(tester.takeException(), isNull);
      ekraninIcinde(tester, 'tahta', find.byType(BoardWidget));
      ekraninIcinde(tester, 'raf', find.byType(RackWidget));
      // Oyunun oynanabilmesi için ERİŞİLMESİ ŞART olan iki buton.
      ekraninIcinde(tester, 'OYNA', find.text('OYNA'));
      ekraninIcinde(tester, 'PAS GEÇ', find.text('PAS GEÇ'));
    });

    testWidgets('kurulum ekranı — $ad', (tester) async {
      await gorunum(tester, boyut);
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        navigatorObservers: [kRouteObserver],
        home: SetupScreen(services: kurulumServisleri()),
      ));
      await settle(tester);

      expect(tester.takeException(), isNull);
      ekraninIcinde(tester, 'OYUNU BAŞLAT', find.text('OYUNU BAŞLAT'));
    });

    // Modalın kendisi: `KModal`ın gövdesi kaydırılabilir olduğundan dikey
    // alan daraldığında KESİLMEMELİ, taşmamalı.
    testWidgets('nasıl oynanır penceresi — $ad', (tester) async {
      await gorunum(tester, boyut);
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: const HelpModal(),
      ));
      await settle(tester);

      expect(tester.takeException(), isNull);
    });
  }
}
