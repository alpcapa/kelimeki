// Uygulama içi puan isteği (ROADMAP #42) — KARAR saf fonksiyonda, bayrak
// okuma/yazma `FlagsStore`ta, işletim sistemi çağrısı `data/store_review.dart`ta.
// Web'de karşılığı YOK (yalnızca port; tarayıcıda mağaza yorumu diye bir şey yok).
//
// Kullanıcı kararı (30 Eylül 2026): puan isteği bir KAZANÇ anında gelir;
// tanıtımda/ilk oyunda ASLA. Ayrıntı ve kural seçimi: ROADMAP #42.
//
// ⚠ "Memnun musun?" ön elemesi YOK — Apple/Google yönergelerine aykırı: pencere
// doğrudan istenir, işletim sistemi gösterip göstermeyeceğine kendisi karar verir.

/// Pencere istenmeden önce bu cihazda BİTMİŞ en az bu kadar oyun olmalı
/// (yerel + Canlı, kazanılan/kaybedilen fark etmez).
const int reviewMinFinishedGames = 3;

/// Bizim kendi tavanımız: toplamda en fazla bu kadar istek. iOS ayrıca yılda 3
/// gösterimle sınırlıyor; bizimki o kotayı tek oturumda yakmamak için.
const int reviewMaxAsks = 3;

/// İki istek arasındaki asgari süre.
const Duration reviewMinGap = Duration(days: 120);

class ReviewPromptInput {
  /// Bu oyunu bu cihazdaki oyuncu KAZANDI mı (1. sıra, teslim olmadan).
  final bool won;

  /// Bu oyun dâhil bu cihazda biten oyun sayısı.
  final int finishedGames;

  /// Bu oyunun sonunda "ilk galibiyet/ilk puan" kutlaması gösterildi mi —
  /// iki pencere üst üste binmesin diye o gün puan istenmez.
  final bool celebrationShown;

  /// Bugüne dek kaç kez istendi.
  final int asksSoFar;

  /// En son istek anı (UTC, ms); hiç istenmediyse `null`.
  final int? lastAskedAtMs;

  final int nowMs;

  const ReviewPromptInput({
    required this.won,
    required this.finishedGames,
    required this.celebrationShown,
    required this.asksSoFar,
    required this.lastAskedAtMs,
    required this.nowMs,
  });
}

/// Bu oyun sonunda işletim sisteminin puan penceresi istensin mi?
bool shouldRequestReview(ReviewPromptInput i) {
  if (!i.won) return false;
  if (i.celebrationShown) return false;
  if (i.finishedGames < reviewMinFinishedGames) return false;
  if (i.asksSoFar >= reviewMaxAsks) return false;
  final last = i.lastAskedAtMs;
  if (last != null && i.nowMs - last < reviewMinGap.inMilliseconds) {
    return false;
  }
  return true;
}
