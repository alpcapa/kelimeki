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
