// Hamle Avı sunucu uçları — web `src/lib/hamleAviApi.ts` portu (3 Kasım 2026).
//
// Tablo `hamle_avi_stats`e istemci DOĞRUDAN erişmez: yalnızca iki RPC
// (`hamle_avi_get` / `hamle_avi_report`, migration 20261103111854). Hata
// yutulur (`null`): rekor/görülenler cihazda zaten tutuluyor, ağ hatası
// oyunu engellemez; bir sonraki başarılı çağrı birleştirir (idempotent).
// Hata metni kullanıcıya GÖSTERİLMEDİĞİNDEN `friendlyErrorMessage` gerekmez.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../util/hamle_avi.dart';
import '../util/platform.dart';

/// Hamle Avı'nın SUNUCUYA veri gönderen tüm yolları bu bayrakla açılır —
/// web `HAMLE_AVI_SERVER_ENABLED` ile AYNI değer (`hamle_avi_parity_test`
/// web kaynağından okur). Gizlilik metni bu veriyi 1.1.6 yayınlanana kadar
/// anlatmıyor (bilinçli geçici istisna, ROADMAP #48).
const bool kHamleAviServerEnabled = true;

class HamleAviServer {
  final int best;
  final List<int> seen;
  const HamleAviServer(this.best, this.seen);
}

abstract class HamleAviGateway {
  Future<HamleAviServer?> fetch();
  Future<HamleAviServer?> report(int best, List<int> seen);
  Future<void> logEvent({
    required String? anonId,
    required int puzzleId,
    required String result,
    required int seconds,
    required int streakBefore,
  });
}

class SupabaseHamleAviGateway implements HamleAviGateway {
  final SupabaseClient client;
  SupabaseHamleAviGateway(this.client);

  HamleAviServer? _row(Object? data) {
    if (data is! List || data.isEmpty) return null;
    final r = data.first as Map;
    return HamleAviServer(
      (r['best_streak'] as num?)?.toInt() ?? 0,
      [
        for (final e in (r['seen_ids'] as List? ?? const [])) (e as num).toInt()
      ],
    );
  }

  @override
  Future<HamleAviServer?> fetch() async {
    if (!kHamleAviServerEnabled) return null;
    try {
      return _row(await client.rpc('hamle_avi_get'));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HamleAviServer?> report(int best, List<int> seen) async {
    if (!kHamleAviServerEnabled) return null;
    try {
      return _row(await client.rpc('hamle_avi_report', params: {
        'p_best_streak': best,
        'p_seen_ids': seen,
      }));
    } catch (_) {
      return null;
    }
  }

  /// Bulmaca sonucunun ANONİM ölçümü (`hamle_avi_events`). ⚠ Hesap kimliği
  /// YAZILMAZ: yalnızca cihazın anonim kodu (tutorial_events/game_starts ile
  /// aynı gizlilik kararı). `source`: yalnızca release derleme 'prod'.
  @override
  Future<void> logEvent({
    required String? anonId,
    required int puzzleId,
    required String result,
    required int seconds,
    required int streakBefore,
  }) async {
    if (!kHamleAviServerEnabled) return;
    try {
      await client.from('hamle_avi_events').insert(hamleAviEventRow(
            anonId: anonId,
            puzzleId: puzzleId,
            result: result,
            seconds: seconds,
            streakBefore: streakBefore,
          ));
    } catch (_) {
      // Telemetri akışı asla bozmaz.
    }
  }
}

/// `hamle_avi_events` satırı — saf, Supabase'siz sınanabilir.
@visibleForTesting
Map<String, Object?> hamleAviEventRow({
  required String? anonId,
  required int puzzleId,
  required String result,
  required int seconds,
  required int streakBefore,
}) =>
    {
      'anon_id': anonId,
      'puzzle_id': puzzleId,
      'result': result,
      'seconds': seconds.clamp(0, 300),
      'streak_before': streakBefore.clamp(0, kMaxPlausibleStreak),
      'source': kReleaseMode ? 'prod' : 'preview',
      'platform': currentPlatform,
      'app_version': appVersion,
    };
