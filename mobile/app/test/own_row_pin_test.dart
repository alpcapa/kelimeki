// Sabit "senin sıran" satırı kararı — web `ownRowPin.ts` ikizi (16 Ekim
// 2026). Web vakaları `scripts/verify-own-row-pin.ts` ile AYNI.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/score/own_row_pin.dart';

import 'support/web_source.dart';

void main() {
  test('web paritesi: eşik oranı aynı', () {
    final web = readRepoFile('src/utils/ownRowPin.ts');
    final m = RegExp(r'ROW_IN_VIEW_RATIO = ([0-9.]+);').firstMatch(web);
    expect(m, isNotNull);
    expect(kRowInViewRatio, double.parse(m!.group(1)!));
  });

  group('shouldPinOwnRow (web verify-own-row-pin vakalarıyla birebir)', () {
    test('sırası yok → satır yok', () {
      expect(shouldPinOwnRow(hasRank: false, inList: false, inView: false),
          isFalse);
      expect(shouldPinOwnRow(hasRank: false, inList: true, inView: false),
          isFalse);
    });
    test('yüklü değil → hep göster', () {
      expect(
          shouldPinOwnRow(hasRank: true, inList: false, inView: null), isTrue);
      expect(
          shouldPinOwnRow(hasRank: true, inList: false, inView: true), isTrue);
    });
    test('yüklü + görünür → gizle', () {
      expect(
          shouldPinOwnRow(hasRank: true, inList: true, inView: true), isFalse);
    });
    test('yüklü + görünmez (10. sıra vakası) → göster', () {
      expect(
          shouldPinOwnRow(hasRank: true, inList: true, inView: false), isTrue);
    });
    test('yüklü + henüz ölçülmedi → gizli (yanıp sönme yok)', () {
      expect(
          shouldPinOwnRow(hasRank: true, inList: true, inView: null), isFalse);
    });
  });

  group('rowMostlyInView', () {
    bool v(double top, double bottom) => rowMostlyInView(
        rowTop: top, rowBottom: bottom, viewTop: 0, viewBottom: 200);
    test('tamamen içinde', () => expect(v(20, 60), isTrue));
    test('tamamen aşağıda', () => expect(v(220, 260), isFalse));
    test('tamamen yukarıda', () => expect(v(-60, -20), isFalse));
    test('yarısı kesik → görünmez', () => expect(v(180, 220), isFalse));
    test('%90 içinde → görünür', () => expect(v(164, 204), isTrue));
    test('sıfır yükseklik → görünmez', () => expect(v(50, 50), isFalse));
  });
}
