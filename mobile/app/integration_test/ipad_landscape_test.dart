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
// ⚠ BU BİR KAPI DEĞİL, BİR ÖLÇÜ ALETİ — ve bu ayrım ilk koşuda BEDELİNİ
// ödetti. §25 açıkça *"ölçmeden tasarım yapılmayacak"* diyor; ilk sürüm
// yine de dönüşü bir `expect` ile zorunlu kılmıştı ve koşu #6'da altı
// testin ALTISI da o satırda düştü: `view.physicalSize` portrede
// (2064×2752) kaldı, yani `SystemChrome.setPreferredOrientations` iPad'de
// YOK SAYILDI. Ders: bir ölçüm turunda "beklediğim olmadı" bir HATA değil,
// BULGUNUN KENDİSİ — ve düşen iş, o bulgunun geri kalanını (kareler, taşma
// raporu) da beraberinde götürüyor.
//
// ⚠ ÖLÇÜLEN İKİ AÇIKLAMA VAR, biri diğerini dışlar — bu koşu onları AYIRT
// ETMEK için kurgulandı:
//   (a) iOS isteği gerçekten yok saydı. §25'in kendi notu bunun ters
//       yönünü zaten yazıyor: çoklu göreve açık bir iPad uygulamasında
//       `setPreferredOrientations([portraitUp])` de tutmuyor. Kural iki
//       yönlüyse ekran döndürmek yalnızca CİHAZIN fiziksel yönelimiyle
//       mümkün demektir ve simülatörde bunun CLI karşılığı YOK.
//   (b) Dönüş oldu ama `tester.view` onu göstermedi (test bağlayıcısının
//       görünüm ölçüsü bayat).
// AYIRT EDİCİ ÖLÇÜ: kare. Dönüş olduysa PNG 2752×2064 çıkar, olmadıysa
// 2064×2752. Bu yüzden dönüş artık ZORUNLU değil, RAPORLANIYOR — ve kare
// her hâlükârda çekiliyor; iş akışının ölçüm adımı da ölçüyü yazıyor ama
// DÜŞMÜYOR.
//
// NASIL KOŞAR: `flutter drive` ile, iPad Pro 13" simülatöründe.
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
Future<bool> manzarayaCevir(WidgetTester tester) async {
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  return _bekle(tester, () {
    final b = tester.view.physicalSize;
    return b.width > b.height;
  });
}

Future<bool> _bekle(WidgetTester tester, bool Function() kosul,
    {Duration tavan = const Duration(seconds: 6)}) async {
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
void rapor(WidgetTester tester, String ekran,
    {bool? dondu, List<String> ekler = const []}) {
  final v = tester.view;
  final mantiksal = v.physicalSize / v.devicePixelRatio;
  final hata = tester.takeException();
  // ignore: avoid_print
  print('[MANZARA] $ekran · ${mantiksal.width.toInt()}×${mantiksal.height.toInt()} dp '
      '· dönüş: ${dondu == null ? '—' : (dondu ? 'OLDU' : 'OLMADI')}'
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
    final dondu = await manzarayaCevir(tester);
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await binding.takeScreenshot('L1-oyun-manzara');
    rapor(tester, 'oyun ekranı', dondu: dondu, ekler: [
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
      kutuRaporu(tester, 'OYNA', find.text('OYNA')),
      kutuRaporu(tester, 'PAS GEÇ', find.text('PAS GEÇ')),
    ]);
    controller.dispose();
  });

  testWidgets('L2 — kurulum ekranı (manzara)', (tester) async {
    final dondu = await manzarayaCevir(tester);
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      navigatorObservers: [kRouteObserver],
      home: SetupScreen(services: setupServisleri()),
    ));
    await settle(tester);

    await binding.takeScreenshot('L2-kurulum-manzara');
    rapor(tester, 'kurulum', dondu: dondu, ekler: [
      kutuRaporu(tester, 'OYUNU BAŞLAT', find.text('OYUNU BAŞLAT')),
    ]);
  });

  testWidgets('L3 — skor kartı (manzara)', (tester) async {
    final dondu = await manzarayaCevir(tester);
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
    rapor(tester, 'skor kartı', dondu: dondu);
  });

  testWidgets('L4 — nasıl oynanır (manzara)', (tester) async {
    final dondu = await manzarayaCevir(tester);
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: const HelpModal(),
    ));
    await settle(tester);

    await binding.takeScreenshot('L4-nasil-oynanir-manzara');
    rapor(tester, 'nasıl oynanır', dondu: dondu);
  });

  // Split View'ın kendisi simülatörde otomatikleştirilemiyor (ikinci bir
  // uygulama + jest gerekir), ama ONUN ÜRETTİĞİ ŞEY ölçülebilir: uygulamanın
  // penceresi manzara yüksekliğinde ama ÜÇTE BİR genişlikte kalıyor.
  // `physicalSize` bunu birebir kurar — kare çekilmiyor (pencere ölçüsü
  // cihazınkiyle uyuşmaz, `sips` adımı haklı olarak düşerdi), yalnızca
  // taşma/kutu raporu alınıyor.
  testWidgets('L5 — Split View benzeri dar pencere (1/3)', (tester) async {
    final dondu = await manzarayaCevir(tester);
    // ⚠ Dönüşe GÜVENME: cihaz dönmemiş olabilir (koşu #6). Manzara
    // penceresi uzun kenardan geniş, kısa kenardan yüksektir — ölçüyü
    // yönelimden değil kenarların KENDİSİNDEN türet, yoksa dönmeyen bir
    // cihazda "dar pencere" diye portre-dar bir kutu ölçülür.
    final tam = tester.view.physicalSize;
    final uzun = tam.longestSide;
    final kisa = tam.shortestSide;
    tester.view.physicalSize = Size(uzun / 3, kisa);
    addTearDown(tester.view.resetPhysicalSize);

    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    rapor(tester, 'oyun ekranı / dar pencere', dondu: dondu, ekler: [
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
      kutuRaporu(tester, 'OYNA', find.text('OYNA')),
    ]);
    controller.dispose();
  });

  // Son test: portreye dönüş. Kare ÇEKİLMEZ — ölçüsü manzara karelerinin
  // tersi olurdu ve iş akışının `sips` adımı onu haklı olarak reddederdi.
  testWidgets('L6 — portreye dönüş bozulma bırakmıyor', (tester) async {
    final dondu = await manzarayaCevir(tester);
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller));
    await settle(tester);

    await SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp]);
    final portreyeDondu = await _bekle(tester, () {
      final b = tester.view.physicalSize;
      return b.height > b.width;
    });
    await settle(tester);

    rapor(tester, 'portreye dönüş', dondu: dondu, ekler: [
      'portrede mi: ${portreyeDondu ? 'EVET' : 'HAYIR'}',
      kutuRaporu(tester, 'tahta', find.byType(BoardWidget)),
      kutuRaporu(tester, 'raf', find.byType(RackWidget)),
    ]);
    controller.dispose();
  });
}
