// Sahte `CloudSaveGateway` — `local_game_saves` ucunun bellek içi ikizi.
// `cloud_save_test.dart`in kendi (daha zengin: offline/yavaş silme/hata
// enjeksiyonu) sahte ucundan BİLEREK ayrı: buradaki iki testin (kayıt
// oturumu devri + migrasyon kapısı) sorduğu tek soru "kaç satır var ve
// içinde ne yazıyor".
import 'package:kelimeki/src/data/cloud_save_repo.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

class FakeSaveGateway implements CloudSaveGateway {
  final rows = <String, Map<String, Object?>>{};

  /// `updated_at` damgasının kaynağı — testin kendi saatini geçirebilmesi
  /// için (varsayılan gerçek saat; sıralamaya bakmayan testler için yeter).
  final int Function() nowMs;

  FakeSaveGateway({int Function()? nowMs})
      : nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  @override
  Future<List<Map<String, Object?>>> list() async => rows.entries
      .map((e) => <String, Object?>{
            'id': e.key,
            'state': e.value['state'],
            'updated_at': e.value['updated_at'],
          })
      .toList();

  @override
  Future<void> upsert(String id, String userId, Map<String, Object?> stateJson,
      int playerCount) async {
    rows[id] = {
      'state': stateJson,
      'user_id': userId,
      'player_count': playerCount,
      'updated_at': DateTime.fromMillisecondsSinceEpoch(nowMs(), isUtc: true)
          .toIso8601String(),
    };
  }

  @override
  Future<void> delete(String id) async => rows.remove(id);

  @override
  Future<Map<String, Object?>?> claimAbandoned(
          String id, String cutoffIso) async =>
      null;

  /// Tek satırın state'i — hayalet satır iddiaları bunu okur.
  GameState get onlyState => gameStateFromJson(
      (rows.values.single['state'] as Map).cast<String, Object?>());
}
