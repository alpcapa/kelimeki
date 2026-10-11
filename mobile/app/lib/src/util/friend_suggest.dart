// Oyun SONUNDA "bu oyuncuları arkadaş eklemek ister misin?" önerisinin aday
// listesi (4 Ekim 2026) — web ikizi `src/utils/friendSuggest.ts`. Kapı:
// `test/friend_suggest_test.dart` (web kaynağını da okur).
import '../data/online_games_api.dart';

/// İnsan koltuğu, ben değilim, `relation` accepted/pending_outgoing değil VE
/// güncel arkadaş kimliklerinde yok. ⚠ `relation` oyun yüklendiği ANIN
/// görüntüsü, bayat olabilir. `pending_incoming` ELENMEZ: karşılıklı istek
/// sunucuda otomatik kabul olur.
List<OnlineSlot> friendSuggestCandidates(
  List<OnlineSlot> slots,
  String myUserId,
  Set<String> friendIds,
) {
  final out = <OnlineSlot>[];
  final seen = <String>{};
  for (final s in slots) {
    final id = s.userId;
    if (!s.isHuman || id == null) continue;
    if (id == myUserId || s.relation == 'self') continue;
    if (s.relation == 'accepted' || s.relation == 'pending_outgoing') continue;
    if (friendIds.contains(id) || !seen.add(id)) continue;
    out.add(s);
  }
  return out;
}
