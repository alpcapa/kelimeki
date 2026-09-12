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
// NEDEN VAR: tanıtım yalnızca YENİ gelene ve yalnızca BİR KEZ açılıyor,
// üstelik her sahnesinde "ATLA →" duruyor. Atlayan — ya da hiç göremeyen —
// oyuncu üç mekaniği hiç öğrenmeden oynuyordu; bu ipuçları o boşluğu GERÇEK
// oyunda, mekanik YAŞANDIĞI anda kapatır.
//
// Desen zoom balonunun birebir aynısı: cihaz yerel sayaç, ipucu BAŞINA tavan,
// "gösterim" balonun EKRANA GELMESİDİR, depolama yoksa varsayılan GÖSTERME
// tarafında (`FlagsStore` yoksa ekran hiç sormaz).
enum OnboardingHintId { vergi, carpan, bolge }

/// Bir ipucunun görüneceği en fazla hamle sayısı (ipucu BAŞINA).
///
/// ⚠ **2 → 1 (12 Eylül 2026, kullanıcı kararı):** üç ipucu × tavan 2 =
/// oyuncunun görebileceği 6 balondu ve bu ilk oyunda fazlaydı; artık üçü de
/// bir kez (en fazla 3). Web ikizi `ONBOARDING_HINT_MAX_SHOWS` — değer
/// `tutorial_parity_test.dart` ile kilitli.
const int onboardingHintMaxShows = 1;

/// Balonun ekranda kalma süresi — web `ONBOARDING_HINT_MS`.
const Duration onboardingHintDuration = Duration(milliseconds: 4000);

/// Aynı hamlede birden fazla ipucu hak edilebilir; ekranda AYNI ANDA TEK
/// BALON olduğundan sıra sabit: en şaşırtıcı olan önce (web ile birebir).
const List<OnboardingHintId> onboardingHintOrder = [
  OnboardingHintId.vergi,
  OnboardingHintId.carpan,
  OnboardingHintId.bolge,
];

/// ⚠ Terim `bölge`, `sınır` DEĞİL (bkz. kök CLAUDE.md → "Terminoloji").
const Map<OnboardingHintId, String> onboardingHintTexts = {
  OnboardingHintId.vergi:
      'Rakibin bölgesine değdin — bu yüzden puanının bir kısmı ona gitti.',
  OnboardingHintId.carpan:
      'Sarı bölgede kelime puanı 2 katı, tam ortadaki karede 3 katı olur.',
  OnboardingHintId.bolge:
      'Bölgen büyüdü — kendi taşlarınla ilerledikçe köşenin dışına taşar.',
};

/// Bir hamlenin HANGİ mekanikleri yaşattığı — çağıran motordan türetir.
class OnboardingHintInput {
  /// Bu hamlede bir ya da daha fazla rakip bölgesine vergi ödendi mi.
  final bool paidTax;

  /// Bu hamlede kurulan kelimelerden biri ×2 ya da ×3 aldı mı.
  final bool gotMultiplier;

  /// Hamleden SONRA oyuncunun bölgesi kendi 4×4 köşe bloğunun DIŞINA taşıyor mu.
  final bool territoryOutsideCorner;

  const OnboardingHintInput({
    required this.paidTax,
    required this.gotMultiplier,
    required this.territoryOutsideCorner,
  });
}

/// Bu hamlede hangi ipucu gösterilsin? Saf fonksiyon — sayaçlar çağırandan
/// (`FlagsStore`) geliyor. `null` = gösterilecek ipucu yok.
OnboardingHintId? pickOnboardingHint(
  OnboardingHintInput input,
  Map<OnboardingHintId, int> shown,
) {
  final hakEdilen = <OnboardingHintId, bool>{
    OnboardingHintId.vergi: input.paidTax,
    OnboardingHintId.carpan: input.gotMultiplier,
    OnboardingHintId.bolge: input.territoryOutsideCorner,
  };
  for (final id in onboardingHintOrder) {
    if ((hakEdilen[id] ?? false) && (shown[id] ?? 0) < onboardingHintMaxShows) {
      return id;
    }
  }
  return null;
}
