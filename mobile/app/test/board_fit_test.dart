// Tahtanın YÜKSEKLİK bütçesi — web `tests/board-fit.spec.ts` + parite
// kapısı (ROADMAP #38, port ikizi). Gerekçe ve ölçümler: `board_fit.dart`.
//
// ⚠ BU TESTİN ÖLÇTÜĞÜ ŞEY BİR SAYI DEĞİL, BİR DAVRANIŞ: "alt şerit (raf +
// butonlar) görünür alanın içinde mi". Sabitler web'den birebir geliyor ve
// portun krom farkını (başlık +25 px) web formülünün kendi payı yutuyor —
// ama yalnızca 3 px kalıyor. Başlık ya da alt şerit uzarsa bu test düşer.
//
// İKİ YARI:
//  1. PARİTE — üç sabit ve üç punto oranı web KAYNAĞINDAN okunur
//     (`src/utils/boardFit.ts`, `src/index.css`). Bulunamazsa DÜŞER.
//  2. DÜZEN — gerçek `GameScreen` web'in üç "geniş ama kısa" görünümünde +
//     iki görünümde bütçenin HİÇ bağlamadığı kanıtı (dikey telefon, iPad).
//     Canlı ekranın eşi `online_game_screen_test.dart`ta (yardımcıları orada).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/board_fit.dart';
import 'package:kelimeki/src/ui/game/board_widget.dart'
    show BoardWidget, kBoardPad;
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/game/rack_widget.dart' show RackWidget;
import 'package:kelimeki/src/ui/game/tile_widget.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import 'support/test_fonts.dart';
import 'support/test_view.dart';
import 'support/web_source.dart';

late SetWordSource words;

double _webConst(String src, String name) => double.parse(pick(
    src,
    RegExp('export const $name = (\\d+);'),
    'src/utils/boardFit.ts içinde $name'));

double _webCqw(String css, String selector) => double.parse(pick(
    css,
    RegExp('${RegExp.escape(selector)}\\s*\\{\\s*font-size:\\s*min\\([^;]*?,\\s*([\\d.]+)cqw\\);'),
    'src/index.css içinde $selector cqw tavanı'));

/// Gerçek oyun ekranı, dolu tahtayla — `ipad_layout_test`in deseni.
Future<void> _oyunEkrani(WidgetTester tester, Size view) async {
  await setPhoneViewSize(tester, view);
  final engine =
      GameEngine(words: words, rng: Mulberry32(11), nowIso: () => '');
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
  s = s.copyWith(players: [
    s.players[0].copyWith(name: 'Ironman', isAI: false),
    s.players[1],
  ]);
  final controller =
      GameController(words: words, autoPlayAi: false, nowIso: () => '');
  controller.dispatch(ResumeSavedAction(s));
  addTearDown(controller.dispose);
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    home: GameScreen(
        controller: controller, words: words, auth: AuthService.fake()),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Rect _pasGec(WidgetTester tester) => tester.getRect(find
    .ancestor(
        of: find.text('PAS GEÇ').first, matching: find.byType(GestureDetector))
    .first);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadAppFonts();
    words = SetWordSource(const LineSplitter()
        .convert(File('assets/dictionary/words_tr.txt').readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  group('parite — web kaynağı', () {
    test('üç sabit `boardFit.ts` ile BİREBİR', () {
      final src = readRepoFile('src/utils/boardFit.ts');
      expect(kBoardChromePx, _webConst(src, 'BOARD_CHROME_PX'));
      expect(kBoardMaxPx, _webConst(src, 'BOARD_MAX_PX'));
      expect(kBoardMinPx, _webConst(src, 'BOARD_MIN_PX'));
    });

    test('taş harfi/puanı ve X3 tavan oranları `index.css` ile BİREBİR', () {
      final css = readRepoFile('src/index.css');
      expect(kTileLetterPerGrid * 100, closeTo(_webCqw(css, '.tile-board-letter'), 1e-9));
      expect(kTilePtsPerGrid * 100, closeTo(_webCqw(css, '.tile-board-pts'), 1e-9));
      expect(kX3LabelPerGrid * 100,
          closeTo(_webCqw(css, '[data-board-grid] .board-x3-label'), 1e-9));
    });

    test('formül: min(680, max(324, boy − 308 − port payı 16))', () {
      expect(boardMaxWidth(2000), 680);
      expect(boardMaxWidth(768), 444);
      expect(boardMaxWidth(400), 324);
    });
  });

  group('düzen — gerçek GameScreen', () {
    // Web `board-fit.spec.ts`in üç görünümü; bu değişiklikten önce portta
    // PAS GEÇ'in altı üçünde de 985'ti (217 · 165 · 185 px taşma).
    for (final view in const [
      Size(1104, 768), // açık katlanabilir, yatay
      Size(1180, 820), // yatay iPad
      Size(1440, 800), // dizüstü boyu
    ]) {
      testWidgets(
          'geniş ama kısa ${view.width.toInt()}×${view.height.toInt()}: '
          'raf ve butonlar ekranın İÇİNDE', (tester) async {
        await _oyunEkrani(tester, view);
        expect(tester.takeException(), isNull);
        expect(tester.getRect(find.byType(RackWidget)).bottom,
            lessThanOrEqualTo(view.height));
        final pas = _pasGec(tester);
        expect(pas.bottom, lessThanOrEqualTo(view.height),
            reason: 'alt şerit taşıyor: ${pas.bottom}');
        // Tahta oynanabilir kalmalı — web ile AYNI boyda: sarmalayıcı
        // `boy − 308`, kart ondan 2×12 dar.
        final kart = tester.getRect(find.byType(BoardWidget)).width;
        expect(kart, view.height - kBoardChromePx - kBoardPortPadPx - 24);
        // Port payı (1 Ekim 2026): alt şeridin altında en az 16 px boşluk —
        // cihazın güvenli alanı/metin metrikleri yiyebilsin diye.
        expect(view.height - pas.bottom, greaterThanOrEqualTo(16),
            reason: 'pay tükendi: ${view.height - pas.bottom}');
        expect(kart, greaterThanOrEqualTo(kBoardMinPx - 24));
      });
    }

    // Bütçenin BAĞLAMADIĞI iki görünüm — davranış bu değişiklikten önceyle
    // piksel piksel aynı olmalı (ölçüldü: dikey iPhone 366, iPad 656).
    for (final (view, kart) in const [
      (Size(390, 844), 366.0),
      (Size(1376, 1032), 656.0),
    ]) {
      testWidgets(
          '${view.width.toInt()}×${view.height.toInt()}: bütçe bağlamaz, '
          'tahta eski boyunda ($kart)', (tester) async {
        await _oyunEkrani(tester, view);
        expect(tester.getRect(find.byType(BoardWidget)).width, kart);
      });
    }
  });

  group('taş puntosu tahtaya göre tavanlı', () {
    double harf(WidgetTester tester) {
      final t = find
          .descendant(of: find.byType(TileWidget), matching: find.byType(Text))
          .first;
      return tester.widget<Text>(t).style!.fontSize!;
    }

    testWidgets('1104×768: vw tavanı 24 BAĞLAMAZ, harf ızgaranın %5,08i',
        (tester) async {
      await _oyunEkrani(tester, const Size(1104, 768));
      final kart = tester.getRect(find.byType(BoardWidget)).width;
      final izgara = kart - 2 * kBoardPad;
      expect(harf(tester), closeTo(izgara * kTileLetterPerGrid, 1e-9));
      expect(harf(tester), lessThan(24));
    });

    testWidgets('390×844 (dikey iPhone): tavan bağlamaz, punto vw ile aynı',
        (tester) async {
      await _oyunEkrani(tester, const Size(390, 844));
      expect(harf(tester), closeTo(390 * 3.8 / 100, 1e-9));
    });
  });
}
