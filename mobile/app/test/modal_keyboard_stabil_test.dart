// KModal: iPad'de e-posta yazarken (QuickType öneri şeridi açılıp kapanırken)
// pencere İÇERİĞİ oynuyor mu? (9 Kasım 2026, 1.1.6 TestFlight turu)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/game/modal_shell.dart';

// Giriş penceresi gibi: klavye açılınca kalan yüksekliği AŞAN uzun gövde.
Widget _app() => MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: KModal(
          title: 'Giriş',
          child: Column(
            children: [
              const SizedBox(height: 240),
              const TextField(key: Key('eposta')),
              const SizedBox(height: 16),
              const TextField(key: Key('sifre')),
              const SizedBox(height: 240),
            ],
          ),
        ),
      ),
    );

double _y(WidgetTester t, String k) => t.getTopLeft(find.byKey(Key(k))).dy;
double _panelYuk(WidgetTester t) => t
    .getSize(find
        .descendant(of: find.byType(Dialog), matching: find.byType(Material))
        .first)
    .height;

void main() {
  void ipad(WidgetTester tester) {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(2048, 1536); // iPad yatay 1024×768
    addTearDown(tester.view.reset);
  }

  testWidgets(
      'öneri şeridi açılıp kapanıp dururken (350 ↔ 385 pt) alanlar ve panel '
      'boyu OYNAMAZ — yalnızca İLK büyüme izlenir', (tester) async {
    ipad(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 700); // 350 pt
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // İlk büyüme (şerit ilk kez açıldı): izlenir, bu bir kez oynayabilir.
    tester.view.viewInsets = const FakeViewPadding(bottom: 770); // 385 pt
    await tester.pumpAndSettle();
    final y0 = _y(tester, 'eposta');
    final h0 = _panelYuk(tester);

    // Sonrasında şerit her kapanıp açıldığında HİÇBİR ŞEY kımıldamaz.
    for (var i = 0; i < 3; i++) {
      tester.view.viewInsets = const FakeViewPadding(bottom: 700);
      await tester.pumpAndSettle();
      expect(_panelYuk(tester), h0,
          reason: 'şerit küçülünce panel boyu oynadı (e-postada titreme)');
      expect(_y(tester, 'eposta'), y0, reason: 'e-posta alanı kaydı');
      tester.view.viewInsets = const FakeViewPadding(bottom: 770);
      await tester.pumpAndSettle();
      expect(_panelYuk(tester), h0, reason: 'şerit büyüyünce panel boyu oynadı');
      expect(_y(tester, 'eposta'), y0);
    }
  });

  testWidgets('klavye GERÇEKTEN kapanınca sıfırlanır ve yeniden açılınca '
      'ilk değere göre oturur', (tester) async {
    ipad(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 770);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final acikBoy = _panelYuk(tester);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    expect(_panelYuk(tester), greaterThan(acikBoy),
        reason: 'klavye kapanınca pencere tam boya dönmeli');

    tester.view.viewInsets = const FakeViewPadding(bottom: 700);
    await tester.pumpAndSettle();
    // Eski (büyük) değer KALMAMALI: yeni açılış 350 pt'e göre ölçülür.
    expect(_panelYuk(tester), greaterThan(acikBoy),
        reason: 'kapanıştan sonra eski klavye değeri sızdı');
  });

  testWidgets('klavye gerçekten küçülürse (≥150 pt, ör. bölünmüş klavye) '
      'izlenir', (tester) async {
    ipad(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 770); // 385 pt
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final h385 = _panelYuk(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 360); // 180 pt
    await tester.pumpAndSettle();
    expect(_panelYuk(tester), greaterThan(h385));
  });
}
