// `rematchSlots` (online_games_api.dart) — "Tekrar Oyna" kadro kuralı.
//
// Vakalar web ikizinin doğrulama betiğiyle BİREBİR aynı
// (`npm run verify-rematch-slots` → `src/utils/rematchSlots.ts`); iki taraf
// aynı kuralı okumak zorunda.
//
// NEDEN ÖNEMLİ: sıralama kozmetik DEĞİL, `create_online_game`in üç
// kısıtının karşılığı — (1) ilk koltuk çağıran, (2) 4 kişilikte YZ yalnız
// son koltukta, (3) 2 kişilikte YZ zaten olamaz. Kural sessizce bozulursa
// RPC reddeder ve hata ancak "Tekrar Oyna çalışmıyor" olarak kullanıcıda
// görünür.
//
// 4 Eylül 2026'da imza `OnlineGame` yerine KOLTUK LİSTESİ almaya çevrildi:
// oyun geçmişindeki "Tekrar Oyna" elinde bir `OnlineGame` değil, biten
// oyunun ayrıca okunmuş `slots` dizisi tutuyor.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/util/rematch_slots.dart';

OnlineSlot _human(String id, {String? name}) =>
    OnlineSlot.human(userId: id, name: name);
const _ai = OnlineSlot.ai();

/// Kadroyu okunur bir dizgeye indirger — beklentiler böyle daha net.
String _ozet(List<NewGameSlot> slots) =>
    slots.map((s) => s.humanUserId == null ? 'YZ' : s.humanUserId!).join(',');

void main() {
  group('rematchSlots', () {
    test('kuran bensem sıra korunur', () {
      expect(_ozet(rematchSlots([_human('ben'), _human('rakip')], 'ben')),
          'ben,rakip');
    });

    test('kuran BEN DEĞİLSEM kendimi başa alırım', () {
      // Biten oyunu rakip kurmuş olabilir; rövanşı ben açıyorsam ilk koltuk
      // benim olmak ZORUNDA (create_online_game kısıtı 1).
      expect(_ozet(rematchSlots([_human('rakip'), _human('ben')], 'ben')),
          'ben,rakip');
    });

    test('YZ ortadayken sona taşınır, insanların sırası korunur', () {
      expect(
        _ozet(rematchSlots(
            [_human('a'), _ai, _human('ben'), _human('b')], 'ben')),
        'ben,a,b,YZ',
      );
    });

    test('iki YZ de sonda ve SAYISI korunur', () {
      expect(
        _ozet(rematchSlots([_ai, _human('ben'), _ai, _human('a')], 'ben')),
        'ben,a,YZ,YZ',
      );
    });

    test('koltuk sayısı hiçbir koşulda değişmez', () {
      // RPC oyuncu sayısını AYRICA alıyor; kadro ondan kısa/uzun gelirse
      // sessizce reddedilir.
      final vakalar = <List<OnlineSlot>>[
        [_human('ben'), _human('a')],
        [_human('ben'), _human('a'), _human('b'), _human('c')],
        [_human('ben'), _human('a'), _ai, _ai],
      ];
      for (final slots in vakalar) {
        expect(rematchSlots(slots, 'ben').length, slots.length);
      }
    });

    test('görüntü alanları RPC yüküne sızmaz', () {
      // `NewGameSlot.toJson` yalnız type + user_id yazmalı: name/avatar
      // yalnızca listeleme RPC'sinin eklediği alanlar.
      final json = rematchSlots(
              [_human('ben', name: 'Ben'), _human('a', name: 'Ali')], 'ben')
          .map((s) => s.toJson())
          .toList();
      expect(json[0].keys.toList()..sort(), ['type', 'user_id']);
      expect(json[0]['user_id'], 'ben');
      expect(json[1]['user_id'], 'a');
    });

    test('YZ koltuğu json olarak yalnız type taşır', () {
      final json = rematchSlots([_human('ben'), _ai], 'ben')
          .map((s) => s.toJson())
          .toList();
      expect(json[1], {'type': 'ai'});
    });
  });

  // ── Engellediğim rakip (13 Ekim 2026, kullanıcı kararı) ──────────────────
  // Vakalar web `verify-rematch-slots` (6) ve (7) bölümleriyle BİREBİR aynı.
  group('rematchBlockedOpponents', () {
    ({String userId, String name}) engelli1(String id) =>
        (userId: id, name: id.toUpperCase());
    List<({String userId, String name})> engelli(List<String> ids) =>
        [for (final id in ids) engelli1(id)];

    test('engelli rakip yok → boş', () {
      expect(rematchBlockedOpponents([_human('ben'), _human('a')], 'ben', []),
          isEmpty);
    });

    test('2 kişilik: engellediğim rakip → adı döner', () {
      expect(
          rematchBlockedOpponents(
              [_human('ben'), _human('a')], 'ben', engelli(['a'])),
          ['A']);
    });

    test('kendim engelli listesinde olsam da sayılmam', () {
      expect(
          rematchBlockedOpponents(
              [_human('ben'), _human('a')], 'ben', engelli(['ben'])),
          isEmpty);
    });

    test('kadroda OLMAYAN engelli sayılmaz', () {
      expect(
          rematchBlockedOpponents(
              [_human('ben'), _human('a')], 'ben', engelli(['z'])),
          isEmpty);
    });

    test('4 kişilik: iki engelli, KOLTUK sırasıyla (listenin sırasıyla değil)',
        () {
      expect(
          rematchBlockedOpponents(
              [_human('ben'), _human('c'), _human('a'), _human('b')],
              'ben',
              engelli(['a', 'c'])),
          ['C', 'A']);
    });

    test('YZ koltuğu engelli sayılmaz', () {
      expect(
          rematchBlockedOpponents(
              [_human('ben'), _human('a'), _ai, _ai], 'ben', engelli(['a'])),
          ['A']);
    });
  });

  group('rematchBlockedMessage', () {
    test('tekil', () {
      expect(rematchBlockedMessage(['Ali']),
          'Ali kullanıcısını engellediğiniz için önce engeli kaldırmanız gerekiyor.');
    });

    test('iki kişi', () {
      expect(rematchBlockedMessage(['Ali', 'Veli']),
          'Ali ve Veli kullanıcılarını engellediğiniz için önce engeli kaldırmanız gerekiyor.');
    });

    test('üç kişi', () {
      expect(rematchBlockedMessage(['Ali', 'Veli', 'Can']),
          'Ali, Veli ve Can kullanıcılarını engellediğiniz için önce engeli kaldırmanız gerekiyor.');
    });
  });
}
