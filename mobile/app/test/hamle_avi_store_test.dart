// Hamle Avı cihaz deposu — çözülen bulmaca kümesi (ROADMAP #51 ön adımı, 1.1.8).
//
// Kilitlenenler: (1) eski kayıt (`solved` anahtarı YOK) boş küme olarak okunur
// — güncellemeden sonra ilk açılış çökmez/sıfırlanmaz; (2) sunucu birleşimi
// KÜME birleşimidir (tekrar çağrı sayıyı şişirmez); (3) `solved` yazılırken
// öteki alanlar (rekor/görülen/tanıtım tercihi) ezilmez.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/storage/hamle_avi_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<HamleAviStore> _store([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return HamleAviStore(await SharedPreferences.getInstance());
}

void main() {
  test('eski kayıtta `solved` yok → boş küme, diğer alanlar korunur', () async {
    final s = await _store({
      kHamleAviStoreKey: jsonEncode(
          {'best': 4, 'seen': [100001, 100002], 'introHidden': true}),
    });
    final l = s.load();
    expect(l.solved, isEmpty);
    expect(l.best, 4);
    expect(l.seen, [100001, 100002]);
    expect(l.introHidden, isTrue);
  });

  test('solved yazmak rekor/görülen/tanıtım tercihini ezmez', () async {
    final s = await _store({
      kHamleAviStoreKey: jsonEncode(
          {'best': 4, 'seen': [100001, 100002], 'introHidden': true}),
    });
    final next = await s.save(solved: [100002]);
    expect(next.solved, [100002]);
    expect(next.best, 4);
    expect(next.seen, [100001, 100002]);
    expect(next.introHidden, isTrue);
    expect(s.load().solved, [100002], reason: 'diske yazıldı');
  });

  test('sunucu birleşimi KÜME birleşimidir: tekrar çağrı sayıyı şişirmez',
      () async {
    final s = await _store();
    await s.save(solved: [100002]);
    var m = await s.mergeWithServer(2, [100001, 100002], [100001, 100002]);
    expect(m.solved, [100001, 100002]);
    m = await s.mergeWithServer(2, [100001, 100002], [100001, 100002]);
    expect(m.solved, [100001, 100002], reason: 'kuyruk tekrarı aynı sonuç');
    expect(m.best, 2);
  });

  test('bozuk `solved` (liste değil / tamsayı olmayan) yok sayılır', () async {
    final s = await _store({
      kHamleAviStoreKey: jsonEncode({
        'best': 1,
        'seen': [100001],
        'solved': 'yanlış',
      }),
    });
    expect(s.load().solved, isEmpty);
    final s2 = await _store({
      kHamleAviStoreKey: jsonEncode({
        'best': 1,
        'seen': [100001],
        'solved': [100001, 'x', 2.5],
      }),
    });
    expect(s2.load().solved, [100001]);
  });
}
