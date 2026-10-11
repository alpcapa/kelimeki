// `reminder_events` (11 Ekim 2026) — Dart sabitleri ↔ migration'daki check'ler.
//
// Sunucu bilinmeyen bir olayı check'iyle REDDEDER ve istemci bunu bilerek
// yutar (fire-and-forget), yani ayrışma hiçbir hata basmadan satır kaybettirir.
// `supabase/migrations/**` web-ci'ın `paths` listesinde, yani yalnızca
// migration değişen bir PR da bu testi koşturur.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/reminder_events.dart';

import 'support/web_source.dart';

List<String> _sqlList(String sql, String column) {
  final m = RegExp(
          '$column\\s+text[^\\n]*?check \\(${column == 'event' ? 'event' : '(?:$column is null or $column)'} in \\(([^)]*)\\)')
      .firstMatch(sql);
  expect(m, isNotNull, reason: '$column check\'i migration\'da bulunamadı');
  return [
    for (final x in RegExp("'([a-z_]+)'").allMatches(m!.group(1)!)) x.group(1)!
  ];
}

void main() {
  final sql =
      readRepoFile('supabase/migrations/20261011155133_reminder_events.sql');

  test('olay adları migration check\'iyle BİREBİR (sıra dahil)', () {
    expect(kReminderEvents, _sqlList(sql, 'event'));
  });

  test('kart adları migration check\'iyle BİREBİR', () {
    expect(kReminderCards, _sqlList(sql, 'card'));
  });

  test('istemci kimlik göndermiyor (tabloda da kimlik kolonu yok)', () {
    final row = ReminderEvents.row(kReminderSet, null);
    expect(row.containsKey('anon_id'), isFalse);
    expect(row.containsKey('user_id'), isFalse);
  });
}
