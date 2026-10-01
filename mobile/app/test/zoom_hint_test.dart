// Zoom tanıtım balonu (1 Eylül 2026, kullanıcı isteği).
//
// ⚠ 1 Ekim 2026'dan beri balon AÇILIŞTA değil, eğitim balonu SIRASININ
// üçüncü halkası olarak çıkıyor (menü → anlam → zoom → …; ilki 2. turdan
// sonra) ve BİR KEZ (kullanıcı: *"hepsi 1 kere gösterim"*). Sıranın kendisi
// `tutorial_script_test`te; burası ekranın gerçekten çizdiğini sınar. Testler
// `anlam`ı "gösterildi" tohumlayıp (misafirde menü zaten atlanır) zoom'u
// sıranın başına alıyor, iki turu da geçmişe dört pas ekleyerek geçiyor.
// Hâlâ geçerli: "Deneyip büyütenlere bir daha gösterme", "Deneme gösterimi
// bitirir". Web ikizi: `tests/smoke.spec.ts` → "tahta zoom".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/ui/game/board_zoom.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:kelimeki/src/util/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'board_zoom_test.dart' show doubleTapAt, isZoomedIn;
import 'game_screen_test.dart' show craftedState, boardCell;
import 'support/real_io.dart';
import 'support/web_source.dart';
import 'support/test_view.dart';

const _metin = kZoomHintText;

Future<AppStorage> _storage(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppStorage.open(
    factory: databaseFactoryFfi,
    path: inMemoryDatabasePath,
    prefs: await SharedPreferences.getInstance(),
  );
}

/// Sıranın başında zoom olsun: misafirde menü atlanır, anlam "gösterildi".
const _zoomSirada = <String, Object>{'hint_shown_anlam': 1};

/// İki tur geç (2 kişide dört hamle): geçmişe dört PAS satırı eklenir.
/// Gerçek pas dört kez arka arkaya oyunu BİTİRİRDİ (`maxPassRounds`); burada
/// yalnızca sayaç ilerlemeli, `phase` oyunda kalmalı.
Future<void> _ikiTur(WidgetTester tester, GameController c) async {
  final s = c.state;
  c.dispatch(ResumeSavedAction(s.copyWith(moveHistory: [
    ...s.moveHistory,
    for (var i = 0; i < 4; i++)
      HistoryEntry(
          turn: s.turnCount + i,
          player: i % 2,
          words: const [],
          points: 0,
          action: 'pass'),
  ])));
  await drainRealIo(tester);
}

Future<(GameController, AppStorage)> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = _zoomSirada,
  bool oyna = true,
  AuthService? auth,
}) async {
  await setPhoneViewSize(tester, const Size(420, 900));
  // ⚠ `testWidgets` İÇİNDE gerçek I/O `runAsync` ister — sahte zonda
  // beklenen bir sqflite açılışı hiç tamamlanmaz ve test asılır (bu
  // projenin kayıtlı tuzağı: mobile/CLAUDE.md → "await newRepo(" taraması).
  final storage = (await tester.runAsync(() => _storage(prefs)))!;
  final words = SetWordSource(const ['ab', 'aba']);
  final controller =
      GameController(words: words, autoPlayAi: false, nowIso: () => '');
  controller.dispatch(ResumeSavedAction(craftedState()));
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    home: GameScreen(
      controller: controller,
      words: words,
      auth: auth ?? AuthService.fake(),
      storage: Future.value(storage),
    ),
  ));
  await drainRealIo(tester);
  if (oyna) await _ikiTur(tester, controller);
  return (controller, storage);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  testWidgets('açılışta balon YOK; 2. turdan sonra ÇIKAR, sayaç 1 olur',
      (tester) async {
    final (c, storage) = await _pump(tester, oyna: false);
    expect(find.text(_metin), findsNothing);
    expect(storage.flags.zoomHintShown, 0);
    await _ikiTur(tester, c);
    expect(find.text(_metin), findsOneWidget);
    expect(storage.flags.zoomHintShown, 1);
    expect(storage.flags.zoomTried, isFalse);
  });

  testWidgets('bir kez gösterildiyse bir daha ÇIKMAZ — sıra hamlelere geçer',
      (tester) async {
    final (_, storage) = await _pump(tester,
        prefs: {..._zoomSirada, 'zoom_hint_shown': 1});
    expect(find.text(_metin), findsNothing);
    expect(storage.flags.zoomHintShown, 1, reason: 'sayaç boşuna artmamalı');
    expect(find.text('Buradan tüm hamleleri görebilirsin.'), findsOneWidget);
  });

  // Öğeye çapalı balonlar (1 Ekim 2026): hedefin hemen ÜSTÜNDE/ALTINDA,
  // overlay'de (kart kırpmasın) ve 4 sn sonra kendi kapanır.
  testWidgets('torba balonu TORBA düğmesinin ÜSTÜNDE çıkar ve kapanır',
      (tester) async {
    final (_, storage) = await _pump(tester, prefs: {
      'hint_shown_anlam': 1,
      'zoom_hint_shown': 1,
      'hint_shown_hamleler': 1,
    });
    const metin = 'Dışarıda kalan taşlar burada.';
    expect(find.text(metin), findsOneWidget);
    expect(storage.flags.hintShown(OnboardingHintId.torba), 1);
    final balon = tester.getRect(find.byKey(const ValueKey('hint-bubble')));
    final torba = tester.getRect(find.textContaining('TORBA'));
    expect(balon.bottom, lessThanOrEqualTo(torba.top));
    expect(balon.bottom, greaterThan(torba.top - 30));
    await tester.pump(onboardingHintDuration + const Duration(milliseconds: 50));
    expect(find.text(metin), findsNothing);
  });

  testWidgets('girişliye ilk balon MENÜ — avatarın ALTINDA', (tester) async {
    await _pump(tester,
        prefs: const {},
        auth: AuthService.fake(
            user: User(
          id: 'me',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: '2026-01-01T00:00:00Z',
        )));
    expect(find.text('Kullanıcı menüsü için tıkla.'), findsOneWidget);
    final balon = tester.getRect(find.byKey(const ValueKey('hint-bubble')));
    // Avatar sağ üstte; balon onun altında ve sağa yaslı.
    expect(balon.top, lessThan(200));
    expect(balon.right, greaterThan(300));
  });

  testWidgets('DENEYEN kullanıcıya bir daha ASLA çıkmaz (sayaç 0 olsa bile)',
      (tester) async {
    final (_, storage) =
        await _pump(tester, prefs: {..._zoomSirada, 'zoom_tried': true});
    expect(find.text(_metin), findsNothing);
    expect(storage.flags.zoomHintShown, 0);
  });

  testWidgets('zoom DENENİNCE balon anında kapanır ve bayrak kalıcı yazılır',
      (tester) async {
    final (_, storage) = await _pump(tester);
    expect(find.text(_metin), findsOneWidget);

    await doubleTapAt(tester, tester.getCenter(boardCell(6, 6)));
    expect(isZoomedIn(tester), isTrue);
    expect(find.text(_metin), findsNothing,
        reason: 'kullanıcı isteği: "Deneme gösterimi bitirir"');

    await drainRealIo(tester);
    expect(storage.flags.zoomTried, isTrue);
  });

  // 16 Eylül 2026 — oyuncu bildirdi: *"tanıtımdan sonra zoom özelliği için
  // sürekli kalan uyarı mesajı oyun oynamayı zorlaştırıyor... 3-5 saniye
  // sonra gidecek şekle getirelim. İnsanlar okumuyor."* Web ikizi:
  // `tests/smoke.spec.ts` → "balon kendi kendine kapanır".
  testWidgets('balon KENDİ KENDİNE kapanır — ve bu "denedi" SAYILMAZ',
      (tester) async {
    final (_, storage) = await _pump(tester);
    expect(find.text(_metin), findsOneWidget);

    // Süre dolmadan HÂLÂ ekranda: erken kapanma da bir arıza.
    await tester.pump(kZoomHintAutoHide - const Duration(milliseconds: 500));
    expect(find.text(_metin), findsOneWidget);

    // Hiçbir dokunuş yok: yalnızca zaman geçiyor.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(_metin), findsNothing);

    // Kendi kendine kapanma "denendi" yazmaz ve sayacı ayrıca artırmaz.
    await drainRealIo(tester);
    expect(storage.flags.zoomTried, isFalse);
    expect(storage.flags.zoomHintShown, 1);
  });

  // 27 Eylül 2026, kullanıcı: *"X3 üzerine göstermesi kafa karıştırıyor. Sol
  // alt bölümün ortasına beyaz boş kareyi gösteren bir mesaj balonu olsun.
  // Mesaj: Boş kareye çift tık tahtayı büyütür. Şimdi Dene!"*
  test('metin web ZOOM_HINT_TEXT ile BİREBİR aynı', () {
    final web = pick(readRepoFile('src/utils/boardZoom.ts'),
        RegExp(r"export const ZOOM_HINT_TEXT = '([^']*)';"), 'ZOOM_HINT_TEXT');
    expect(web.replaceAll(r'\n', '\n'), kZoomHintText);
    expect(kZoomHintText, 'Boş kareye çift tık tahtayı büyütür.\nŞimdi Dene!',
        reason: 'kullanıcının verdiği metin');
  });

  test('hedef: sol-alt bloğun ortasındaki BOŞ kare; doluysa sıradaki', () {
    expect(zoomHintTarget((r, c) => true), (10, 1));
    expect(zoomHintTarget((r, c) => !(r == 10 && c == 1)), (10, 2));
    // Ortadaki dört kare doluysa bloğun kenarına kayar, bloktan ÇIKMAZ.
    final orta = {(10, 1), (10, 2), (11, 1), (11, 2)};
    final h = zoomHintTarget((r, c) => !orta.contains((r, c)))!;
    expect(h.$1, inInclusiveRange(9, 12));
    expect(h.$2, inInclusiveRange(0, 3));
    // Blok tamamen doluysa balon YOK.
    expect(zoomHintTarget((r, c) => !(r >= 9 && c <= 3)), isNull);
  });

  testWidgets('balon (10,1)in hemen ÜSTÜNDE — X3 (6,6) karesini ÖRTMEZ',
      (tester) async {
    await _pump(tester);
    final balon = tester.getRect(find.text(_metin));
    final hedef = tester.getRect(boardCell(10, 1));
    final x3 = tester.getRect(boardCell(6, 6));
    expect(balon.bottom, lessThanOrEqualTo(hedef.top));
    expect(balon.bottom, greaterThan(hedef.top - 30));
    expect(balon.top, greaterThan(x3.bottom));
    // Sola yaslı: balon tahtanın sol yarısında başlar.
    expect(balon.left, lessThan(hedef.right));
  });

  testWidgets('storage verilmezse balon HİÇ çıkmaz (testler/önizlemeler)',
      (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    final words = SetWordSource(const ['ab', 'aba']);
    final controller =
        GameController(words: words, autoPlayAi: false, nowIso: () => '');
    controller.dispatch(ResumeSavedAction(craftedState()));
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: GameScreen(
          controller: controller, words: words, auth: AuthService.fake()),
    ));
    await tester.pump();
    await _ikiTur(tester, controller);
    expect(find.text(_metin), findsNothing);
  });
}
