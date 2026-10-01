// Eğitim balonu SIRASININ sayacı — iki oyun ekranı için (1 Ekim 2026).
//
// Web ikizi `src/hooks/useOnboardingHints.ts`. Karar saf fonksiyonda
// (`pickOnboardingHint`, `util/onboarding.dart`); bu sınıf yalnızca
// "ekran açıldı / yeni hamle geldi" olaylarını sayar ve gösterilen balonun
// sayacını artırır. `game_screen.dart` ile `online_game_screen.dart` aynı
// deseni iki kez yazıp sessizce ayrışmasın diye tek yerde.
import '../../storage/flags_store.dart';
import '../../util/onboarding.dart';

class OnboardingHintScheduler {
  bool _armed = false;
  int _base = 0;
  int _seen = 0;
  int? _lastShownAt;

  /// Ekran (ya da aynı ekranda yeni oyun) açıldı: o anki geçmiş "az önce
  /// oynanmış" SAYILMAZ — kayıttan devamda dolu bir geçmiş balon uydururdu.
  void arm(int moves) {
    _armed = true;
    _base = moves;
    _seen = moves;
    _lastShownAt = null;
  }

  /// Oyun bitti / ekran gizlendi — bir sonraki `onMoves` yeniden kurar.
  void disarm() => _armed = false;

  bool get armed => _armed;

  /// Hamle sayısı değişti. Gösterilecek balon varsa sayacını ARTIRIR ve
  /// döndürür (`zoom` dahil — onu tahta çizer). `moves` vergi satırı HARİÇ.
  Future<OnboardingHintId?> onMoves({
    required int moves,
    required int playerCount,
    required bool wordPlaced,
    required Set<OnboardingHintId> available,
    required FlagsStore flags,
  }) async {
    if (!_armed) {
      arm(moves);
      return null;
    }
    // Geçmiş KISALDI: aynı ekranda yeni oyun/rövanş başladı — yeniden kur.
    if (moves < _seen) {
      arm(moves);
      return null;
    }
    if (moves == _seen) return null;
    _seen = moves;
    final movesSinceOpen = moves - _base;
    final secilen = pickOnboardingHint(
      OnboardingHintInput(
        movesSinceOpen: movesSinceOpen,
        playerCount: playerCount,
        lastShownAt: _lastShownAt,
        wordPlaced: wordPlaced,
        available: available,
      ),
      flags.onboardingHintShownCounts,
    );
    if (secilen == null) return null;
    _lastShownAt = movesSinceOpen;
    await flags.bumpOnboardingHintShown(secilen);
    return secilen;
  }
}
