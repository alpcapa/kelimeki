// Canlı oyunda TASLAK (deneme taşları) yerel kaydı — web `utils/liveDraft.ts`in
// `saveLiveDraft`/`loadLiveDraft`/`clearLiveDraft` üçlüsünün SQLite karşılığı
// (5 Kasım 2026). KARAR (hangi taslak geri yüklenir/atılır) burada DEĞİL,
// `kelimeki_core`un `engine/live_draft.dart`ında; bu dosya yalnızca saklar.
//
// Kural: yalnız BU cihaz; sunucuya yazılmaz. Başka cihazda sıfırlanır
// (kullanıcı kararı). Taslak boşalınca satır SİLİNİR; oyun bitince/hamle
// gönderilince/çakışmada ekran siler.
import 'dart:convert';

import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:sqflite/sqflite.dart';

class LiveDraftStore {
  final Database db;
  final int Function() _now;
  LiveDraftStore(this.db, this._now);

  static const _version = 1;

  /// Taslağı kaydeder; boşsa kaydı SİLER.
  Future<void> save(String userId, String gameId, Placed placed) async {
    if (placed.isEmpty) {
      await clear(userId, gameId);
      return;
    }
    final payload = jsonEncode({
      'v': _version,
      'cells': {for (final e in placed.entries) e.key: e.value.toJson()},
    });
    await db.insert(
      'live_drafts',
      {
        'user_id': userId,
        'game_id': gameId,
        'payload': payload,
        'updated_at': _now(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Kayıtlı taslağı okur; yok/bozuksa `null`. Şekil doğrulanır — bozuk kayıt
  /// ASLA uygulanmaz (ve silinir, her açılışta tekrar denenmesin).
  Future<Placed?> load(String userId, String gameId) async {
    final rows = await db.query(
      'live_drafts',
      where: 'user_id = ? and game_id = ?',
      whereArgs: [userId, gameId],
    );
    if (rows.isEmpty) return null;
    try {
      final j = jsonDecode(rows.first['payload'] as String) as Map;
      if (j['v'] != _version) throw const FormatException('sürüm');
      final cells = (j['cells'] as Map).cast<String, Object?>();
      if (cells.isEmpty) throw const FormatException('boş');
      final out = <String, Tile>{};
      for (final e in cells.entries) {
        if (!RegExp(r'^\d+,\d+$').hasMatch(e.key)) {
          throw const FormatException('hücre anahtarı');
        }
        out[e.key] = Tile.fromJson((e.value as Map).cast<String, Object?>());
      }
      return out;
    } catch (_) {
      await clear(userId, gameId);
      return null;
    }
  }

  Future<void> clear(String userId, String gameId) async {
    await db.delete(
      'live_drafts',
      where: 'user_id = ? and game_id = ?',
      whereArgs: [userId, gameId],
    );
  }
}
