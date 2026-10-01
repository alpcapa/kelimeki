// "Oynayarak öğren" tanıtımının kapısı — web `src/utils/onboarding.ts`
// (`shouldShowTutorial`, `TUTORIAL_LAUNCH_AT`) portu. Saf fonksiyon; bayrak
// okuma/yazma `FlagsStore`ta, sinyalleri toplayan `setup_screen.dart`.
//
// Kullanıcı isteği (7 Eylül 2026): *"Sadece yeni gelenlere bir kere
// gösterilecek. Mevcut gelmiş ve oynamış kişilere gösterilmeyecek."* Karar
// TEK bir cihaz bayrağına bakmıyor — cihaz değiştiren ya da bugüne kadar
// yalnızca Canlı oyun oynamış bir kullanıcı o bayrağı taşımaz ve tanıtıma
// sokulurdu. Dört sinyal birden okunur; varsayılan bilerek GÖSTERME
// tarafında. `tutorial_parity_test.dart` tarihi ve vaka tablosunu web
// kaynağına karşı kilitler.

/// Tanıtımın WEB'DE yayına girdiği an. Bu andan ÖNCE açılmış bir hesap =
/// MEVCUT oyuncu → tanıtım gösterilmez, cihazı yeni olsa bile.
///
/// ⚠ Port için YENİDEN TARİHLENMEDİ (bilinçli): anlamı "web yayınından önce
/// hesap açan = mevcut oyuncu"dur; ayrı bir tarih iki platformun farklı
/// kişilere göstermesi demek olurdu. Değiştirmek bir ürün kararıdır,
/// kullanıcıya sorulur.
const String tutorialLaunchAt = '2026-09-07T00:00:00.000Z';

/// `shouldShowTutorial`ın okuduğu sinyaller — hepsi çağıranda hazır.
class TutorialGateInput {
  /// Tanıtım bu cihazda zaten gösterildi mi (`FlagsStore.seenTutorial`).
  final bool seenTutorial;

  /// Cihaz eski Hızlı Başlangıç penceresini gördü mü
  /// (`FlagsStore.seenQuickstart`, salt okunur miras).
  final bool seenLegacyQuickStart;

  /// Bu cihazda/hesapta devam eden bir oyun var mı — "zaten oynamış" sinyali.
  final bool hasPlayed;

  /// Girişli kullanıcının hesap açılış zamanı (ISO 8601); misafirde `null`.
  final String? accountCreatedAt;

  const TutorialGateInput({
    required this.seenTutorial,
    required this.seenLegacyQuickStart,
    required this.hasPlayed,
    required this.accountCreatedAt,
  });
}

/// Tanıtım bu açılışta gösterilsin mi? Dört sinyalin HEPSİ "hayır" derse
/// gösterilir; herhangi biri "bu kişi yeni değil" derse gösterilmez.
/// Okunamayan bir hesap tarihinde de gösterilmez — kapının varsayılanı bu
/// yönde (mevcut bir oyuncuyu tanıtıma sokmak, yeni bir oyuncunun tanıtımı
/// kaçırmasından daha kötü; kullanıcı kararı).
///
/// ⚠ SINIR — misafirde cihaz dışına bakacak bir şey YOK: uygulamayı silip
/// yeniden kuran ya da yeni bir cihazdan gelen eski bir MİSAFİR "yeni"
/// görünür ve tanıtımı bir kez daha görür. Girişlide bu delik hesap yaşıyla
/// kapalı.
bool shouldShowTutorial(TutorialGateInput input) {
  if (input.seenTutorial) return false;
  if (input.seenLegacyQuickStart) return false;
  if (input.hasPlayed) return false;
  final created = input.accountCreatedAt;
  if (created != null) {
    final acilis = DateTime.tryParse(created);
    if (acilis == null) return false;
    if (acilis.isBefore(DateTime.parse(tutorialLaunchAt))) return false;
  }
  return true;
}

// ── Bağlamsal ipuçları (Onboarding Faz 2, 8 Eylül 2026) ─────────────────────
// Web ikizi: `src/utils/onboarding.ts` (aynı adlar, aynı sıra, aynı metinler).
// `tutorial_parity_test.dart` metinleri ve sırayı web kaynağından okuyup
// karşılaştırıyor — biri değişirse öteki AYNI PR'da değişmek zorunda.
//
// NEDEN VAR: tanıtımın ANLATMADIĞI bir etkileşim var — tahtadaki bir
// kelimeye dokununca anlamı açılıyor. Bu ipucu onu GERÇEK oyunda, tahtaya
// ilk kelime oturduğu anda o kelimenin üstünde bir kez söyler.
//
// ⚠ **30 Eylül 2026 — mekanik ipuçları KALDIRILDI (kullanıcı kararı):** eski
// üç balon (`vergi` · `carpan` · `bolge`) fazla bulundu; yerine tek `anlam`
// balonu geldi. Çift tık (zoom) balonu ayrı ve DEĞİŞMEDİ. Eski
// `hint_shown_vergi`… anahtarları cihazda kalabilir, artık okunmuyor.
//
// Desen zoom balonunun birebir aynısı: cihaz yerel sayaç, ipucu BAŞINA tavan,
// "gösterim" balonun EKRANA GELMESİDİR, depolama yoksa varsayılan GÖSTERME
// tarafında (`FlagsStore` yoksa ekran hiç sormaz).
// ⚠ **1 Ekim 2026 — tek balon SIRAYA dönüştü (kullanıcı, 1.1.2 cihaz turu).**
// Web ikizi `src/utils/onboarding.ts` → "Eğitim balonları"; kurallar orada
// yazılı, burada BİREBİR (`tutorial_parity_test.dart` sabitleri, sırayı ve
// metinleri web kaynağından okuyup karşılaştırıyor):
//   • sıra menü → anlam → zoom → hamleler → torba → mesaj; her biri BİR KEZ;
//   • ilki açılıştan 2 TUR, sonrakiler bu ekrandaki son balondan 4 tur sonra;
//   • bu ekranda çizilemeyen balon ATLANIR (Canlı'da anlam, YZ oyununda
//     mesaj, misafirde menü, dolu köşede zoom);
//   • anlam kelime oturmadan ve 6. turdan önce BEKLER.
enum OnboardingHintId { menu, anlam, zoom, hamleler, torba, mesaj }

/// Gösterim sırası — web `ONBOARDING_HINT_ORDER` ile BİREBİR.
const List<OnboardingHintId> onboardingHintOrder = [
  OnboardingHintId.menu,
  OnboardingHintId.anlam,
  OnboardingHintId.zoom,
  OnboardingHintId.hamleler,
  OnboardingHintId.torba,
  OnboardingHintId.mesaj,
];

/// Bir balonun görüneceği en fazla sayı (balon BAŞINA) — web
/// `ONBOARDING_HINT_MAX_SHOWS`.
const int onboardingHintMaxShows = 1;

/// İlk balondan önceki TUR sayısı — web `ONBOARDING_HINT_FIRST_ROUNDS`.
const int onboardingHintFirstRounds = 2;

/// İki balon arasındaki TUR sayısı — web `ONBOARDING_HINT_GAP_ROUNDS`.
const int onboardingHintGapRounds = 4;

/// `anlam`ın açılıştan en erken turu — web `ONBOARDING_HINT_ANLAM_MIN_ROUNDS`
/// (30 Eylül kararı: tahta ortaya doğru dolmuş olsun).
const int onboardingHintAnlamMinRounds = 6;

/// Balonun ÜSTTE yer bulamayacağı satır sayısı — web
/// `ONBOARDING_HINT_ALT_ROWS` (yalnız tahtaya çapalı `anlam` balonu).
const int onboardingHintAltRows = 3;

/// Balon çapanın üstünde mi altında mı — web `onboardingHintYon`.
String onboardingHintYon(int r) => r < onboardingHintAltRows ? 'alt' : 'ust';

/// Balonun ekranda kalma süresi — web `ONBOARDING_HINT_MS`.
const Duration onboardingHintDuration = Duration(milliseconds: 4000);

/// Metinler — web `ONBOARDING_HINT_TEXTS`. Zoom'un metni `kZoomHintText`te
/// (`board_zoom.dart`, tahta balonu).
const Map<OnboardingHintId, String> onboardingHintTexts = {
  OnboardingHintId.menu: 'Kullanıcı menüsü için tıkla.',
  OnboardingHintId.anlam: 'Kelimenin üzerine tıklarsan anlamı gelir.',
  OnboardingHintId.hamleler: 'Buradan tüm hamleleri görebilirsin.',
  OnboardingHintId.torba: 'Dışarıda kalan taşlar burada.',
  OnboardingHintId.mesaj: 'Buradan oyunculara mesaj gönderebilirsin.',
};

/// Bir hamlenin ve ekranın durumu — web `OnboardingHintInput`.
class OnboardingHintInput {
  /// Ekran açıldığından beri oynanan hamle sayısı (vergi satırı HARİÇ).
  final int movesSinceOpen;
  final int playerCount;

  /// Bu ekranda son balonun gösterildiği andaki `movesSinceOpen`; yoksa null.
  final int? lastShownAt;

  /// Bu hamle tahtaya bir KELİME oturttu mu (`anlam`ın koşulu).
  final bool wordPlaced;

  /// Bu ekranda çizilebilen balonlar — listede olmayan ATLANIR.
  final Set<OnboardingHintId> available;

  const OnboardingHintInput({
    required this.movesSinceOpen,
    required this.playerCount,
    required this.lastShownAt,
    required this.wordPlaced,
    required this.available,
  });
}

/// Bu hamlede hangi balon gösterilsin? Saf fonksiyon — sayaçlar çağırandan
/// (`FlagsStore`) geliyor. `null` = bu hamlede balon yok.
OnboardingHintId? pickOnboardingHint(
  OnboardingHintInput input,
  Map<OnboardingHintId, int> shown,
) {
  final n = input.playerCount < 1 ? 1 : input.playerCount;
  final acilistanTur = input.movesSinceOpen ~/ n;
  final last = input.lastShownAt;
  final tur = last == null ? acilistanTur : (input.movesSinceOpen - last) ~/ n;
  final esik =
      last == null ? onboardingHintFirstRounds : onboardingHintGapRounds;
  if (tur < esik) return null;
  for (final id in onboardingHintOrder) {
    if ((shown[id] ?? 0) >= onboardingHintMaxShows) continue;
    if (!input.available.contains(id)) continue;
    if (id == OnboardingHintId.anlam &&
        (!input.wordPlaced || acilistanTur < onboardingHintAnlamMinRounds)) {
      return null;
    }
    return id;
  }
  return null;
}

// ── Oyun sonu kutlaması — "ilk kazanma" / "ilk puan" (12 Eylül 2026) ──────
//
// Web ikizi: `src/utils/onboarding.ts` → `pickFirstWinCelebration`.
// Kullanıcı kararı iki dalı ayırıyor:
//   • GİRİŞLİ → ölçüt ilk GALİBİYET, kaynağı HESAP (`player_stats_overall
//     .wins`). Cihaz bayrağı yanlış olurdu: telefon değiştiren kişi yıllar
//     sonra yeniden "ilk oyununu kazandın" görürdü.
//   • MİSAFİR → ölçüt ilk PUAN, kaynağı cihaz bayrağı (`FlagsStore`) —
//     misafirin hesabı yok, sunucuda sayılacak bir şey de yok. Mesaj zaten
//     bunu söylüyor: puan kaydedilmiyor, kaydolmaya davet var.
//
// ⚠ İki dal AYNI şeyi ölçmüyor ve bu bilinçli: 2 kişilikte "kazandı" ile
// "puan aldı" aynı şeye denk düşüyor, 4 kişilikte ayrışıyor (2. sıra puan
// alır ama kazanmamıştır).
enum FirstWinCelebrationId { uye, misafir }

/// ⚠ Metinler web ile BİREBİR (`tutorial_parity_test.dart` karşılaştırıyor).
const Map<FirstWinCelebrationId, String> firstWinTexts = {
  FirstWinCelebrationId.uye: 'Tebrikler, ilk oyununu kazandın!',
  FirstWinCelebrationId.misafir:
      'Tebrikler, ilk puanını kazandın. Bu puanı kaybetmemek için hemen giriş yap.',
};

/// Misafir metninin BUTONA dönüşen parçası — çizim cümleyi bundan bölüyor,
/// metni ikinci kez YAZMIYOR. Web `FIRST_WIN_GUEST_CTA`.
const String firstWinGuestCta = 'hemen giriş yap';

class FirstWinCelebrationInput {
  /// Hesapla mı oynanıyor.
  final bool signedIn;

  /// Bu oyunda 1. sırada bitirdi mi (`rankPlayers`).
  final bool won;

  /// Bu oyundan k-lig puanı kazandı mı (`leaguePoints(...) > 0`).
  final bool earnedPoints;

  /// GİRİŞLİ dal: hesabın toplam galibiyeti — **bu oyun DAHİL**. `null` =
  /// okunamadı (offline) → kutlama YOK. Gerekçe web ikizinde uzun uzun
  /// yazılı: sonradan okunan `1`, "kayıt düştü VE ilk galibiyet" demek.
  final int? totalWins;

  /// MİSAFİR dal: bu cihazda kutlama daha önce gösterildi mi.
  final bool guestCelebrated;

  const FirstWinCelebrationInput({
    required this.signedIn,
    required this.won,
    required this.earnedPoints,
    required this.totalWins,
    required this.guestCelebrated,
  });
}

/// Oyun sonu modalında hangi kutlama gösterilsin? Saf fonksiyon —
/// depolama/ağ erişimi çağıranda. `null` = kutlama yok.
FirstWinCelebrationId? pickFirstWinCelebration(FirstWinCelebrationInput input) {
  if (input.signedIn) {
    if (!input.won) return null;
    return input.totalWins == 1 ? FirstWinCelebrationId.uye : null;
  }
  if (!input.earnedPoints || input.guestCelebrated) return null;
  return FirstWinCelebrationId.misafir;
}
