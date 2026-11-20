// İşletim sisteminin kendi puan penceresi (iOS SKStoreReviewController ·
// Android Play In-App Review) — ROADMAP #42. Pencereyi OS çizer; gösterip
// göstermeyeceğine de OS karar verir (iOS yılda en fazla 3), sonucu bize
// BİLDİRMEZ. Bu yüzden "verdi mi?" diye bir arayüz kurulamaz.
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import '../storage/flags_store.dart';
import '../util/review_prompt.dart';

abstract class StoreReview {
  Future<void> request();
}

class OsStoreReview implements StoreReview {
  @override
  Future<void> request() async {
    if (kIsWeb) return;
    final api = InAppReview.instance;
    if (await api.isAvailable()) await api.requestReview();
  }
}

/// Oyun bittiğinde çağrılır: sayacı artırır, kural izin veriyorsa pencereyi
/// ister. Hata YUTULUR — puan penceresi hiçbir zaman oyunu bozmamalı.
Future<void> maybeAskStoreReview({
  required FlagsStore flags,
  required bool won,
  required bool celebrationShown,
  StoreReview? review,
  int Function()? nowMs,
}) async {
  try {
    await flags.bumpReviewGamesFinished();
    final now = (nowMs ?? () => DateTime.now().millisecondsSinceEpoch)();
    final ok = shouldRequestReview(ReviewPromptInput(
      won: won,
      finishedGames: flags.reviewGamesFinished,
      celebrationShown: celebrationShown,
      asksSoFar: flags.reviewAskCount,
      lastAskedAtMs: flags.reviewLastAskedMs,
      nowMs: now,
    ));
    if (!ok) return;
    // İşaret ÖNCE: OS çağrısı asılı kalsa/düşse de aynı oyunda ikinci kez
    // istenmez.
    await flags.markReviewAsked(now);
    await (review ?? OsStoreReview()).request();
  } catch (_) {}
}
