// KModal klavye açıkken ÜSTE yaslanır (3 Kasım 2026, iPad titremesi).
//
// iPad'e takılı klavyede alttaki kısayol/öneri şeridi yazarken boy
// değiştiriyor → `viewInsets.bottom` oynuyor. Ortalanmış `Dialog` her
// değişimde yarı fark kadar kayıyordu. Bu test, klavye yüksekliği değişse de
// pencerenin ÜST kenarının yerinde kaldığını ve klavye kapalıyken pencerenin
// eskisi gibi ortada durduğunu kilitler.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/game/modal_shell.dart';

Widget _app() => const MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: KModal(
          title: 'Giriş',
          child: SizedBox(key: Key('govde'), height: 200, child: TextField()),
        ),
      ),
    );

// `Dialog` kutusunun KENDİSİ ekranı kaplar (Align + dolgu); panelin yeri
// içindeki Material'dan okunur.
Finder _panel() => find
    .descendant(of: find.byType(Dialog), matching: find.byType(Material))
    .first;
double _ustKenar(WidgetTester t) => t.getTopLeft(_panel()).dy;

void main() {
  testWidgets('klavye yüksekliği değişince pencere YERİNDE kalır',
      (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(2048, 1536); // iPad yatay, 1024×768
    addTearDown(tester.view.reset);

    tester.view.viewInsets = const FakeViewPadding(bottom: 110); // 55 pt şerit
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final ilk = _ustKenar(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 180); // 90 pt şerit
    await tester.pumpAndSettle();
    expect(_ustKenar(tester), ilk,
        reason: 'öneri şeridi büyüyünce pencere kaydı — iPad titremesi geri '
            'geldi (pencere yine kalan alanın ortasına yerleşiyor)');
  });

  testWidgets('klavye kapalıyken pencere ORTADA (web items-center)',
      (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(2048, 1536);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final r = tester.getRect(find.byType(Dialog));
    // Dialog kutusu ekranı kaplar; paneli (Material) ölç.
    final panel = tester.getRect(_panel());
    expect((panel.center.dy - r.center.dy).abs(), lessThan(1.0));
  });
}
