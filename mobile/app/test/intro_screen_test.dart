// İlk açılış tanıtımı (`IntroScreen`) + kapısı (`app.dart`'taki _HomeGate).
//
// Ölçülen sözleşme üç parça:
//  1) ekranın kendisi — 1 Ekim 2026'dan beri TEK ekran (ROADMAP #41 karar
//     14; eskiden beş slayt): web'in ilk ekranıyla aynı metinler ve kesit,
//     ekranın TEK çıkışı HEMEN OYNA, telefonda kaydırmadan sığar;
//  2) kapı — bayrak YOKKEN tanıtım, VARKEN doğrudan Setup;
//  3) bayrak GERÇEKTEN yazılıyor (yoksa tanıtım her açılışta çıkardı).
//
// Kapı testleri GERÇEK `AppStorage` kullanıyor (sqflite ffi): bayrağın
// yazıldığını sahte bir depo üzerinden "kanıtlamak" hiçbir şey kanıtlamaz.
// Gerçek I/O testWidgets'ın sahte zaman bölgesinde ilerlemediğinden her
// testin sonunda `drainRealIo` şart (Parça 11/13/64/74'ün dersi).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/ui/app.dart';
import 'package:kelimeki/src/ui/game/logo_mark.dart';
import 'package:kelimeki/src/ui/intro/bolge_kesiti.dart';
import 'package:kelimeki/src/ui/intro/intro_screen.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/online_status.dart';
import 'support/test_fonts.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/real_io.dart';
import 'package:kelimeki/src/data/analytics.dart';
import 'support/fake_analytics.dart';
import 'support/test_view.dart';
import 'support/web_source.dart';

/// Gerçek depo — `AppStorage.open` gerçek I/O olduğundan `runAsync` köprüsü
/// şart (pump'tan ÖNCE açılıyor ki kapının beklediği Future zaten çözülmüş
/// olsun; aksi halde sahte zamanda hiç tamamlanmaz).
Future<AppStorage> newStorage(WidgetTester tester,
    {bool seenIntro = false}) async {
  late AppStorage storage;
  await tester.runAsync(() async {
    SharedPreferences.setMockInitialValues(
        seenIntro ? {'seen_intro': true} : {});
    storage = await AppStorage.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
      prefs: await SharedPreferences.getInstance(),
      nowMs: () => DateTime.now().millisecondsSinceEpoch,
    );
  });
  return storage;
}

AppServices services({Future<AppStorage>? storage}) => AppServices(
      onlineStatus: OnlineStatus.fake(),
      dictionary: Future.value(SetWordSource(const ['ab', 'aba', 'kelime'])),
      meanings: MeaningStore(bundle: rootBundle),
      auth: AuthService(null),
      supabase: null,
      versionGate: VersionGateStatus.ok,
      storage: storage,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  // GERÇEK FONTLAR ŞART — bu dosya artık GEOMETRİ ölçüyor (slayt kaydırma
  // payı, legend'in yan yana olup olmadığı). `flutter_test` pubspec'teki
  // fontları OTOMATİK YÜKLEMEZ: varsayılan Ahem'de her glyph
  // fontSize×fontSize bir bloktur, yani 27 karakterlik legend metni 11px'te
  // 297px yer kaplar (gerçek Space Grotesk'te 144px — web'de ölçüldü).
  // Ahem'le ölçmek iki testi de UYDURMA bir düzende sınardı: metinler daha
  // çok satıra sarıp slaydı şişirir, legend hiçbir genişlikte yan yana
  // sığmaz. Nitekim ilk sürümde tam bu oldu (CI: 1. slayt 29px taşıyor,
  // legend üstleri 730 ve 750). Ölçüm yapan kardeş testlerin hepsi
  // (`board_render_test`, `game_header_test`, `account_button_test`…)
  // baştan beri bu satırı taşıyor.
  setUpAll(loadAppFonts);

  // 1 Ekim 2026 — ROADMAP #41 karar 14: beş slayt KALKTI, web'in yeni ilk
  // ekranının aynısı tek ekran (kullanıcı kararı).
  group('IntroScreen', () {
    Future<int> pumpIntro(WidgetTester tester,
        {Size size = const Size(390, 844),
        EdgeInsets guvenli = EdgeInsets.zero}) async {
      var done = 0;
      await setPhoneViewSize(tester, size);
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(padding: guvenli, viewPadding: guvenli),
          child: child!,
        ),
        home: IntroScreen(onDone: () => done++),
      ));
      await tester.pump();
      return done;
    }

    testWidgets(
        'tek ekran: logo · metinler · kesit · HEMEN OYNA → onDone; '
        'slayt/DEVAM YOK', (tester) async {
      final fake = FakeAnalytics();
      analytics.configure(fake);
      addTearDown(analytics.reset);
      var done = 0;
      await setPhoneViewSize(tester, const Size(390, 844));
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: IntroScreen(onDone: () => done++),
      ));
      await tester.pump();
      expect(find.byType(LogoMark), findsOneWidget);
      expect(find.text('TÜRKÇE KELİME OYUNU'), findsOneWidget);
      expect(find.text(kIntroBaslik), findsOneWidget);
      expect(find.text(kIntroKural), findsOneWidget);
      expect(find.byType(BolgeKesiti), findsOneWidget);
      expect(find.text(kKesitVergiEtiketi), findsOneWidget);
      expect(find.text('+7'), findsOneWidget);
      expect(find.text(kIntroDuz), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      expect(find.textContaining('DEVAM'), findsNothing);
      // Huni sürekliliği: olay korunuyor, tek kez index 0.
      expect(fake.names, ['intro_slide_viewed']);
      expect(fake.events.single.$2, {'index': 0});
      await tester.tap(find.byKey(const Key('intro-hemen-oyna')));
      await tester.pump();
      expect(done, 1);
    });

    // İlk ekran tek bakışta: kaydırmadan HEMEN OYNA görünür (web'in
    // `min-h` + tavan kararı; telefonda düğme parmağın altında).
    for (final (boy, guvenli) in const [
      (Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
      (Size(375, 812), EdgeInsets.only(top: 44, bottom: 34)),
      (Size(412, 915), EdgeInsets.only(top: 24, bottom: 16)),
    ]) {
      testWidgets(
          'kaydırmadan sığıyor + HEMEN OYNA görünür — '
          '${boy.width.toInt()}×${boy.height.toInt()}', (tester) async {
        await pumpIntro(tester, size: boy, guvenli: guvenli);
        final st = tester.state<ScrollableState>(find.byType(Scrollable));
        expect(st.position.maxScrollExtent, 0, reason: 'ilk ekran kaymamalı');
        final btn = tester.getRect(find.byKey(const Key('intro-hemen-oyna')));
        expect(btn.bottom, lessThanOrEqualTo(boy.height - guvenli.bottom));
        expect(btn.height, 54);
      });
    }

    testWidgets('küçük ekranda (320×568) içerik KAYAR, düğmeye ulaşılır',
        (tester) async {
      final done0 = await pumpIntro(tester, size: const Size(320, 568));
      expect(done0, 0);
      await tester.scrollUntilVisible(
          find.byKey(const Key('intro-hemen-oyna')), 100);
      await tester.tap(find.byKey(const Key('intro-hemen-oyna')));
      await tester.pump();
    });

    testWidgets('"NASIL OYNANIR?" kural penceresini açar', (tester) async {
      await pumpIntro(tester);
      await tester.tap(find.text('NASIL OYNANIR?'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
    });

    test('metinler web `Landing.tsx` ilk ekranıyla BİREBİR', () {
      final web = readRepoFile('src/landing/Landing.tsx');
      final sik = web.replaceAll(RegExp(r'\s+'), ' ');
      for (final t in [
        kIntroUstBaslik,
        kIntroBaslik,
        kIntroKural,
        kIntroDuz,
        'etiket="$kIntroOyna"',
      ]) {
        expect(sik.contains(t), isTrue, reason: 'web metni ayrıştı: "$t"');
      }
      final kesit = readRepoFile('src/landing/BolgeKesiti.tsx');
      expect(kesit.contains(kKesitVergiEtiketi), isTrue);
    });

    test('kesit verisi web `ilkEkranKesiti.ts` ile BİREBİR', () {
      final ts = readRepoFile('src/landing/ilkEkranKesiti.ts');
      expect(RegExp(r'KESIT_SUTUN = (\d+)').firstMatch(ts)!.group(1),
          '$kKesitSutun');
      final harita = RegExp(r'KESIT_HARITA[^=]*= \[([\s\S]*?)\];')
          .firstMatch(ts)!
          .group(1)!;
      expect(
          [for (final m in RegExp(r"'([^']*)'").allMatches(harita)) m.group(1)],
          kKesitHarita);
      final rakip = RegExp(r'KESIT_RAKIP_HARFLERI[^=]*= \{([\s\S]*?)\};')
          .firstMatch(ts)!
          .group(1)!;
      expect({
        for (final m in RegExp(r"'(\d+,\d+)': '([^']+)'").allMatches(rakip))
          m.group(1)!: m.group(2)!
      }, kKesitRakipHarfleri);
      final hamle = RegExp(r'KESIT_HAMLE[^=]*= \[([\s\S]*?)\n\];')
          .firstMatch(ts)!
          .group(1)!;
      final kelimeler = [
        for (final k
            in RegExp(r'\[\s*(\[[\s\S]*?\],?\s*)+\]').allMatches(hamle))
          [
            for (final h
                in RegExp(r'\[(\d+),\s*(\d+)\]').allMatches(k.group(0)!))
              (int.parse(h.group(1)!), int.parse(h.group(2)!))
          ]
      ];
      expect(kelimeler, kKesitHamle);
      expect(
          ts.contains('sag: true, alt: true'), kKesitAcikSag && kKesitAcikAlt);
      // Rozet: SAAT (S1 A1 A1 T1) + TA (T1 A1) = 7 — web aria metniyle aynı.
      expect(kesitHamlePuani(), 7);
    });
  });

  group('kapı (_HomeGate)', () {
    testWidgets(
        'ilk açılış: tanıtım çıkar, bitince Setup açılır ve bayrak '
        'GERÇEKTEN yazılır', (tester) async {
      await setPhoneViewSize(tester, const Size(420, 950));
      final storage = await newStorage(tester);
      expect(storage.flags.seenIntro, isFalse);

      await tester.pumpWidget(
          KelimekiApp(services: services(storage: Future.value(storage))));
      await tester.pumpAndSettle();

      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.byType(SetupScreen), findsNothing);

      // Ekranın TEK çıkışı HEMEN OYNA (atlama yok).
      await tester.tap(find.byKey(const Key('intro-hemen-oyna')));
      await tester.pumpAndSettle();

      expect(find.byType(IntroScreen), findsNothing);
      expect(find.byType(SetupScreen), findsOneWidget);

      await drainRealIo(tester);
      expect(storage.flags.seenIntro, isTrue,
          reason: 'bayrak yazılmazsa tanıtım HER açılışta tekrar çıkar');
    });

    testWidgets('ikinci açılış: tanıtım HİÇ çıkmaz', (tester) async {
      await setPhoneViewSize(tester, const Size(420, 950));
      final storage = await newStorage(tester, seenIntro: true);

      await tester.pumpWidget(
          KelimekiApp(services: services(storage: Future.value(storage))));
      await tester.pumpAndSettle();

      expect(find.byType(IntroScreen), findsNothing);
      expect(find.byType(SetupScreen), findsOneWidget);
      await drainRealIo(tester);
    });

    testWidgets(
        'depo YOKKEN (widget testleri/önizlemeler) kapı devreye '
        'girmez — doğrudan Setup', (tester) async {
      await setPhoneViewSize(tester, const Size(420, 950));
      await tester.pumpWidget(KelimekiApp(services: services()));
      await tester.pump();
      expect(find.byType(IntroScreen), findsNothing);
      expect(find.byType(SetupScreen), findsOneWidget);
    });
  });
}
