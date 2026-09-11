// Mağaza karelerinin YEREL ÖNİZLEMESİ — Linux'ta, saniyeler içinde PNG.
//
// NEDEN VAR (kullanıcı isteği, 11 Eylül 2026): *"Bu görselleri önce resim
// olarak yap bana göster ondan sonra ok ise üretime gönderelim. Böyle kaç
// defa git gel oldu."* Haklıydı: kompozisyon hataları (debug bandı, şeridin
// boşluğu doldurmaması, 1-2 karelerinin aynı olması, modalların havada
// durması) ancak KAREYE BAKILINCA görülüyordu ve her bakış bir CI turu
// (~14 dk) + artefakt indirme gerektiriyordu.
//
// ⚠ **Bu kareler MAĞAZAYA GİTMEZ.** Skia ≠ Impeller, iOS kabuğu yok, gerçek
// cihaz ölçüsü yok. Mağazaya giden kare hâlâ `integration_test/` +
// `flutter drive` (gerçek simülatör). Buranın işi tek: KOMPOZİSYON sorusunu
// CI beklemeden cevaplamak. Kurulum ortak (`store_frames.dart`), yani iki
// yol aynı fixture'ı çiziyor.
//
// KOŞUM: `npm run preview-store-frames` (kök dizinden).
// Çıktı: `build/frame-preview/*.png` — repoya GİRMEZ (`build/` gitignore'da).
//
// ⚠ Normal `flutter test` koşusunda ATLANIR: PNG yazmak ve fontları
// yüklemek saniyeler alıyor ve takımın geri kalanını yavaşlatmasının bir
// anlamı yok. Kapı: `KARE_ONIZLEME=1` ortam değişkeni.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/meaning_entry.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/meaning_modal.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';
import 'package:kelimeki/src/ui/score/score_card_modal.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import '../integration_test/store_frames.dart';

/// İKİ cihaz, mağaza karesiyle AYNI mantıksal ölçü ve piksel oranı —
/// `ios-screenshots.yml`in matrisinin birebir karşılığı (iPhone 6.9"
/// 1320×2868, iPad Pro 13" 2064×2752). Aynı yedi kare İKİ ölçüde birden
/// çiziliyor: mağaza her iki slotu da istiyor ve düzen iPad'de gerçekten
/// farklı akıyor (daha geniş, daha kısa) — yani "iPhone'da iyi görünüyor"
/// iPad için kanıt DEĞİL (ölçüldü: şerit oranı iPad'de ayrı bir yükseklik
/// tavanı gerektirdi, bkz. console-formlari.md §13).
/// Seçim `KARE_CIHAZ` ile: `iphone` (varsayılan) ya da `ipad`.
final bool _ipad = Platform.environment['KARE_CIHAZ'] == 'ipad';
final Size _kEkran = _ipad ? const Size(1032, 1376) : const Size(440, 956);
final double _kPiksel = _ipad ? 2.0 : 3.0;

final String _kCikti = _ipad ? 'build/frame-preview/ipad' : 'build/frame-preview';

final _kok = GlobalKey();

Future<void> _yaz(WidgetTester tester, String ad) async {
  // ⚠ `runAsync`: `toImage` gerçek bir async — testin sahte zaman
  // bölgesinde çözülmüyor.
  await tester.runAsync(() async {
    final boundary =
        _kok.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: _kPiksel);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_kCikti).createSync(recursive: true);
    File('$_kCikti/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('kare yazıldı: $_kCikti/$ad.png');
  });
}

Future<void> _ciz(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(RepaintBoundary(key: _kok, child: app));
  await settle(tester);
}

void main() {
  if (Platform.environment['KARE_ONIZLEME'] != '1') {
    test('önizleme atlandı (KARE_ONIZLEME=1 ile koşulur)', () {});
    return;
  }

  setUpAll(() async {
    // Gerçek fontlar — Ahem ile çizilen bir önizleme kompozisyon
    // sorusunu cevaplayamaz.
    for (final aile in {
      'SpaceGrotesk': [
        'assets/fonts/SpaceGrotesk-Regular.ttf',
        'assets/fonts/SpaceGrotesk-Medium.ttf',
        'assets/fonts/SpaceGrotesk-SemiBold.ttf',
        'assets/fonts/SpaceGrotesk-Bold.ttf',
      ],
      'SpaceMono': [
        'assets/fonts/SpaceMono-Regular.ttf',
        'assets/fonts/SpaceMono-Bold.ttf',
      ],
      'Nunito': ['assets/fonts/Nunito-ExtraBold.ttf'],
      'MPlusRounded1c': ['assets/fonts/MPLUSRounded1c-ExtraBold-subset.ttf'],
    }.entries) {
      final loader = FontLoader(aile.key);
      for (final yol in aile.value) {
        loader.addFont(
          File(yol).readAsBytes().then((b) => ByteData.view(b.buffer)),
        );
      }
      await loader.load();
    }
    words = SetWordSource(
      File('assets/dictionary/words_tr.txt').readAsLinesSync(),
    );
  });

  setUp(() {
    // Mağaza karesiyle aynı görünüm alanı.
    // ignore: deprecated_member_use
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = _kEkran * _kPiksel;
    view.devicePixelRatio = _kPiksel;
  });

  testWidgets('01 oyun ekranı', (t) async {
    final c = oyunKontrolcusu();
    await _ciz(t, oyunEkrani(c, '01-oyun-ekrani'));
    await _yaz(t, '01-oyun-ekrani');
    c.dispose();
  });

  testWidgets('02 dört kişilik', (t) async {
    final c = oyunKontrolcusu(oyuncu: 4);
    stageBestMove(c);
    await _ciz(t, oyunEkrani(c, '02-dort-kisilik'));
    await _yaz(t, '02-dort-kisilik');
    c.dispose();
  });

  testWidgets('03 arkadaşınla', (t) async {
    await _ciz(t, kurulumEkrani('03-arkadasinla'));
    await t.tap(find.text('ARKADAŞINLA'));
    await settle(t);
    await _yaz(t, '03-arkadasinla');
  });

  testWidgets('04 skor kartı', (t) async {
    final c = oyunKontrolcusu();
    await _ciz(t, oyunEkrani(c, '04-skor-karti'));
    showScoreCard(navKey.currentContext!,
        auth: screenshotAuth(), stats: StatsRepo(SahteStatsGateway()));
    await settle(t);
    await _yaz(t, '04-skor-karti');
    c.dispose();
  });

  testWidgets('05 kelime anlamı', (t) async {
    // ⚠ Önizlemede anlam SABİT: `meanings.db` sqflite istiyor ve widget
    // testinde çözülmüyor (gerçek kare onu asset'ten okuyor — tek fark bu).
    const kayit = MeaningEntry(pos: 'a.', meanings: [
      'Genellikle su kıyılarında, bataklık yerlerde yetişen ince, açık sarı renkli kamış',
      'Bu kamıştan yapılmış',
      '→ çalgı',
      'Türk halk müziğinde bağlama, cura, tar vb. mızraplı çalgıların genel adı',
    ]);
    final c = oyunKontrolcusu();
    await _ciz(t, oyunEkrani(c, '05-kelime-anlami'));
    showMeaningModal(
        navKey.currentContext!, (_) async => kayit, const [kMeaningWord]);
    await settle(t);
    await _yaz(t, '05-kelime-anlami');
    c.dispose();
  });

  testWidgets('06 nasıl oynanır', (t) async {
    final c = oyunKontrolcusu();
    await _ciz(t, oyunEkrani(c, '06-nasil-oynanir'));
    showHelpModal(navKey.currentContext!);
    await settle(t);
    await _yaz(t, '06-nasil-oynanir');
    c.dispose();
  });

  testWidgets('07 k-lig', (t) async {
    final c = oyunKontrolcusu();
    await _ciz(t, oyunEkrani(c, '07-klig-siralamasi'));
    showLeaderboard(navKey.currentContext!,
        auth: screenshotAuth(), stats: StatsRepo(SahteStatsGateway()));
    await settle(t);
    await _yaz(t, '07-klig-siralamasi');
    c.dispose();
  });
}
