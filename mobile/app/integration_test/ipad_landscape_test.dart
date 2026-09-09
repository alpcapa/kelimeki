// iPad MANZARA ölçümü — ROADMAP §25, `mobile/TESTING.md` §26.
//
// NEDEN BU DOSYA VAR: App Store yüklemesi bundle'ı 90474 ile reddetti —
// iPad'i destekleyen bir uygulama DÖRT yönelimi birden bildirmek zorunda.
// `Info.plist` düzeltildi, sonucu şu: uygulama iPad'de artık DÖNDÜRÜLEBİLİR
// ve `main.dart`in `setPreferredOrientations([portraitUp])` kilidi çoklu
// göreve açık bir iPad uygulamasında iOS tarafından YOK SAYILIYOR. Yani
// manzara "ihtimal" değil, kullanıcının bir saniyede ulaştığı hâl — ve
// bugüne kadar HİÇ bakılmamış bir yüzey (web'in `LandscapeHint`inin
// karşılığı porta hiç girmedi).
//
// ⚠ BU BİR KAPI DEĞİL, BİR ÖLÇÜ ALETİ. §25 açıkça *"ölçmeden tasarım
// yapılmayacak"* diyor, ve bugün manzaraya özgü bir düzen YOK — yani
// "taşma varsa kırmızı" diyen bir test, ölçüm turunun daha ilk adımında
// kendi bulgusuyla düşerdi. Bulgular bu yüzden `[MANZARA]` önekiyle
// LOG'a yazılır; iş yalnızca ALTYAPI arızasında düşer (cihaz dönmedi,
// kare üretilemedi). Manzara düzeni kararı verildikten SONRA buradaki
// raporlama bir iddiaya çevrilebilir.
//
// NASIL KOŞAR: `flutter drive` ile, iPad Pro 13" simülatöründe.
// Kare ölçüsü PORTRENİN TERSİ olmak zorunda (2752×2064) — iş akışındaki
// `sips` adımı tam da bunu doğruluyor, yani "cihaz gerçekten döndü mü"
// sorusunun kanıtı ayrıca aranmıyor, ölçüm adımının kendisi.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/game/board_widget.dart' show BoardWidget;
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/rack_widget.dart' show RackWidget;
import 'package:kelimeki/src/ui/route_observer.dart';
import 'package:kelimeki/src/ui/score/score_card_modal.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';

import 'support/sahne.dart';

/// Cihazı manzaraya çevirir ve GERÇEKTEN döndüğünü doğrular.
///
/// ⚠ Bekleme şart: `setPreferredOrientations` bir platform İSTEĞİ, senkron
/// bir atama değil — iOS dönüşü kendi animasyonuyla yapıyor ve `view`in
/// fiziksel ölçüsü ancak o bittiğinde değişiyor. Beklemeden ölçmek, kareyi
/// dönüşün ORTASINDA yakalar.
Future<void> manzarayaCevir(WidgetTester tester) async {
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final oldu = await _bekle(tester, () {
    final b = tester.view.physicalSize;
    return b.width > b.height;
  });
  // Altyapı arızası: ölçüm yapılamaz, iş DÜŞMELİ (bkz. dosya başlığı —
  // düşen tek durum bu).
  expect(oldu, isTrue,
      reason: 'Cihaz manzaraya DÖNMEDİ: ${tester.view.physicalSize}. '
          'Info.plist yönelimleri ya da simülatör dönüş desteği kontrol edilmeli.');
}

Future<bool> _bekle(WidgetTester tester, bool Function() kosul,
    {Duration tavan = const Duration(seconds: 12)}) async {
  final bitis = DateTime.now().add(tavan);
  while (DateTime.now().isBefore(bitis)) {
    if (kosul()) return true;
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
  }
  return kosul();
}

/// Bulguyu LOG'a yazar — bu turun ÇIKTISI bu satırlar.
void rapor(WidgetTester tester, String ekran, {List<String> ekler = const []}) {
  final v = tester.view;
  final mantiksal = v.physicalSize / v.devicePixelRatio;
  final hata = tester.takeException();
  // ignore: avoid_print
  print('[MANZARA] $ekran · ${mantiksal.width.toInt()}×${mantiksal.height.toInt()} dp '
      '· taşma/hata: ${hata == null ? 'YOK' : hata.toString().split('\n').first}');
  for (final e in ekler) {
    // ignore: avoid_print
    print('[MANZARA]   $e');
  }
}

/// Bir widget'ın ekrana göre kutusu — "sığıyor mu" sorusunu SAYIYA çevirir.
String kutuRaporu(WidgetTester tester, String ad, Finder f) {
  if (f.evaluate().isEmpty) return '$ad: BULUNAMADI';
  final r = tester.getRect(f.first);
  final v = tester.view;
  final ekran = Offset.zero & (v.physicalSize / v.devicePixelRatio);
  final icinde = ekran.contains(r.topLeft) && ekran.contains(r.bottomRight - const Offset(0.01, 0.01));
  return '$ad: ${r.left.toInt()},${r.top.toInt()} '
      '${r.width.toInt()}×${r.height.toInt()} · ekranın içinde: ${icinde ? 'EVET' : 'HAYIR'}';
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(sozlukYukle);

  testWidgets('L1 — oyun ekranı (manzara)', (tester) async {
    await manzarayaCevir(tester);
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await binding.takeScreenshot('L1-oyun-manzara');
    rapor(tester, 'oyun ekranı', ekler: [
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
      kutuRaporu(tester, 'OYNA', find.text('OYNA')),
      kutuRaporu(tester, 'PAS GEÇ', find.text('PAS GEÇ')),
    ]);
    controller.dispose();
  });

  testWidgets('L2 — kurulum ekranı (manzara)', (tester) async {
    await manzarayaCevir(tester);
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      navigatorObservers: [kRouteObserver],
      home: SetupScreen(services: setupServisleri()),
    ));
    await settle(tester);

    await binding.takeScreenshot('L2-kurulum-manzara');
    rapor(tester, 'kurulum', ekler: [
      kutuRaporu(tester, 'OYUNU BAŞLAT', find.text('OYUNU BAŞLAT')),
    ]);
  });

  testWidgets('L3 — skor kartı (manzara)', (tester) async {
    await manzarayaCevir(tester);
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

    await binding.takeScreenshot('L3-skor-karti-manzara');
    rapor(tester, 'skor kartı');
  });

  testWidgets('L4 — nasıl oynanır (manzara)', (tester) async {
    await manzarayaCevir(tester);
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: const HelpModal(),
    ));
    await settle(tester);

    await binding.takeScreenshot('L4-nasil-oynanir-manzara');
    rapor(tester, 'nasıl oynanır');
  });

  // Split View'ın kendisi simülatörde otomatikleştirilemiyor (ikinci bir
  // uygulama + jest gerekir), ama ONUN ÜRETTİĞİ ŞEY ölçülebilir: uygulamanın
  // penceresi manzara yüksekliğinde ama ÜÇTE BİR genişlikte kalıyor.
  // `physicalSize` bunu birebir kurar — kare çekilmiyor (pencere ölçüsü
  // cihazınkiyle uyuşmaz, `sips` adımı haklı olarak düşerdi), yalnızca
  // taşma/kutu raporu alınıyor.
  testWidgets('L5 — Split View benzeri dar pencere (1/3)', (tester) async {
    await manzarayaCevir(tester);
    final tam = tester.view.physicalSize;
    tester.view.physicalSize = Size(tam.width / 3, tam.height);
    addTearDown(tester.view.resetPhysicalSize);

    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    rapor(tester, 'oyun ekranı / dar pencere', ekler: [
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
      kutuRaporu(tester, 'OYNA', find.text('OYNA')),
    ]);
    controller.dispose();
  });

  // Son test: portreye dönüş. Kare ÇEKİLMEZ — ölçüsü manzara karelerinin
  // tersi olurdu ve iş akışının `sips` adımı onu haklı olarak reddederdi.
  testWidgets('L6 — portreye dönüş bozulma bırakmıyor', (tester) async {
    await manzarayaCevir(tester);
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp]);
    final dondu = await _bekle(tester, () {
      final b = tester.view.physicalSize;
      return b.height > b.width;
    });
    await settle(tester);

    rapor(tester, 'portreye dönüş', ekler: [
      'dönüş gerçekleşti: ${dondu ? 'EVET' : 'HAYIR'}',
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
    ]);
    controller.dispose();
  });
}
