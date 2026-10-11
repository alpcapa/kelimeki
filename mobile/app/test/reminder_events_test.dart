// Yarım kalan oyun hatırlatmasının sayacı (`reminder_events`, 11 Ekim 2026):
// satırın şekli, kimliksizlik, no-op ve fırlatmama. Akışlardaki olay sırası
// `unfinished_reminder_test.dart`ta.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/config/env.dart';
import 'package:kelimeki/src/data/reminder_events.dart';

class _Sink implements ReminderEventsSink {
  final rows = <Map<String, Object?>>[];
  Object? failWith;

  @override
  Future<void> insert(Map<String, Object?> row) async {
    final f = failWith;
    if (f != null) throw f;
    rows.add(row);
  }
}

void main() {
  late _Sink sink;
  setUp(() {
    sink = _Sink();
    reminderEvents.configure(sink);
  });
  tearDown(reminderEvents.reset);

  test('satır: olay + kart + platform + sürüm, KİMLİK YOK', () {
    reminderEvents.log(kReminderCardShown, card: kReminderCardIzin);
    final row = sink.rows.single;
    expect(row['event'], 'card_shown');
    expect(row['card'], 'izin');
    expect(row['app_version'], appVersion);
    expect(row.containsKey('platform'), isTrue);
    // Gizlilik: kimliksiz (migration başlığı) — gizlilik metni DEĞİŞMİYOR.
    expect(row.containsKey('anon_id'), isFalse);
    expect(row.containsKey('user_id'), isFalse);
  });

  test("kartsız olay ('set') kartı null yazar", () {
    reminderEvents.log(kReminderSet);
    expect(sink.rows.single['card'], isNull);
  });

  test('sunucu kümesi dışındaki kart null gider (satır düşmesin)', () {
    reminderEvents.log(kReminderCardAccept, card: 'uydurma');
    expect(sink.rows.single['card'], isNull);
  });

  test('bilinmeyen olay HİÇ gönderilmez (sunucu check\'i reddederdi)', () {
    reminderEvents.log('uydurma');
    expect(sink.rows, isEmpty);
  });

  test('yapılandırılmamışsa sessiz no-op', () {
    reminderEvents.reset();
    reminderEvents.log(kReminderSet);
    expect(sink.rows, isEmpty);
  });

  test('yazma hatası FIRLATILMAZ (oyundan çıkış bozulmaz)', () async {
    sink.failWith = Exception('ağ yok');
    expect(() => reminderEvents.log(kReminderSet), returnsNormally);
    await Future<void>.delayed(Duration.zero);
  });
}
