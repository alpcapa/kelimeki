// Hamle Avı cihaz deposu — web `src/utils/hamleAviStore.ts` portu.
//
// Cihazda tutulanlar: rekor + görülen bulmaca kimlikleri (misafirin TEK
// kaynağı, üyenin çevrimdışı tamponu) ve tanıtım penceresinin "bir daha
// gösterme" tercihi (YALNIZCA cihazda, sunucuya gitmez). Tek JSON, tek anahtar
// (FlagsStore'un "küçük sabit anahtarlı değerler" kuralına uyuyor). Okuma/yazma
// asla fırlatmaz: bozuk/okunamayan kayıt boş sayılır, ekran yine çalışır.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../util/hamle_avi.dart';

const String kHamleAviStoreKey = 'hamle_avi_v1';

class HamleAviLocal {
  final int best;
  final List<int> seen;

  /// ÇÖZÜLEN bulmaca kimlikleri — `seen`in alt kümesi (ROADMAP #51 ön adımı,
  /// 1.1.8; web `solved`). Sayı DEĞİL kimlik KÜMESİ: sunucu raporu
  /// çevrimdışı kuyruktan tekrar gelebildiğinden "+1" şişerdi, küme birleşimi
  /// tekrarda aynı sonucu verir.
  final List<int> solved;
  final bool introHidden;
  const HamleAviLocal(
      {this.best = 0,
      this.seen = const [],
      this.solved = const [],
      this.introHidden = false});

  HamleAviLocal copyWith(
          {int? best,
          List<int>? seen,
          List<int>? solved,
          bool? introHidden}) =>
      HamleAviLocal(
        best: best ?? this.best,
        seen: seen ?? this.seen,
        solved: solved ?? this.solved,
        introHidden: introHidden ?? this.introHidden,
      );
}

class HamleAviStore {
  final SharedPreferences prefs;
  HamleAviStore(this.prefs);

  HamleAviLocal load() {
    try {
      final raw = prefs.getString(kHamleAviStoreKey);
      if (raw == null) return const HamleAviLocal();
      final j = jsonDecode(raw) as Map<String, Object?>;
      final best = j['best'];
      final seen = j['seen'];
      final solved = j['solved'];
      return HamleAviLocal(
        best: best is num && best.isFinite ? best.toInt().clamp(0, 1 << 30) : 0,
        seen: seen is List
            ? [
                for (final e in seen)
                  if (e is int) e
              ]
            : const [],
        solved: solved is List
            ? [
                for (final e in solved)
                  if (e is int) e
              ]
            : const [],
        introHidden: j['introHidden'] == true,
      );
    } catch (_) {
      return const HamleAviLocal();
    }
  }

  /// Yamayı birleştirip yazar; yazılamazsa bellekteki değerle sürer.
  Future<HamleAviLocal> save(
      {int? best,
      List<int>? seen,
      List<int>? solved,
      bool? introHidden}) async {
    final next = load().copyWith(
        best: best, seen: seen, solved: solved, introHidden: introHidden);
    try {
      await prefs.setString(
          kHamleAviStoreKey,
          jsonEncode({
            'best': next.best,
            'seen': next.seen,
            'solved': next.solved,
            'introHidden': next.introHidden,
          }));
    } catch (_) {}
    return next;
  }

  /// Sunucu değerleriyle birleştirir (rekor: büyüğü, görülenler ve çözülenler:
  /// birleşim).
  Future<HamleAviLocal> mergeWithServer(
      int best, List<int> seen, List<int> solved) {
    final l = load();
    return save(
      best: l.best > best ? l.best : best,
      seen: hamleAviMergeSeen(l.seen, seen),
      solved: hamleAviMergeSeen(l.solved, solved),
    );
  }
}
