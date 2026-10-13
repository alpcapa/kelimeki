// "Tekrar Oyna" — ENGELLEDİĞİM rakip kuralı (web `src/utils/rematchSlots.ts`
// → `rematchBlockedOpponents` / `rematchBlockedMessage`'ın ikizi).
//
// KARAR (13 Ekim 2026, kullanıcı): engellediğim biriyle rövanşa basılırsa oyun
// KURULMAZ, önce engeli kaldırmam istenir (Engel Ayarları → engel kalkınca
// rövanş devam eder). Sunucu yalnızca "karşı taraf beni engelledi mi" diye
// baktığından (`_assert_invite_allowed`) engelleyen kendi engellediğine davet
// atabiliyordu; kullanıcı bunu istemedi. ⚠ ENGELLENEN taraf için DEĞİŞMEDİ:
// istemci başkasının engel listesini okuyamaz, düğme açık kalır ve sunucunun
// "sizi engelledi" mesajı çıkar (devre dışı düğme "beni engelledi" demek olurdu).
//
// Vakalar web ikizinin doğrulama betiğiyle BİREBİR aynı
// (`npm run verify-rematch-slots`); test: `test/rematch_slots_test.dart`.
// Kadro kurma kuralı (`rematchSlots`) bilerek `data/online_games_api.dart`ta
// KALDI (4 Eylül 2026 kararı) — burada yalnızca engel kuralı.
import '../data/online_games_api.dart' show OnlineSlot;

/// ÇAĞIRANIN engellediği kişilerden, kadrodaki İNSAN rakiplerin adları
/// (KOLTUK sırasıyla — engel listesinin sırasıyla değil). Boş = engelli yok.
///
/// `blocked`: `ChatRepo.blockedUsers()` çıktısı (engel + sohbet engeli + açık
/// şikayet birleşimi); yalnızca kimlik ve ad okunur.
List<String> rematchBlockedOpponents(
  List<OnlineSlot> slots,
  String myUserId,
  Iterable<({String userId, String name})> blocked,
) {
  final names = {for (final b in blocked) b.userId: b.name};
  return [
    for (final s in slots)
      if (s.isHuman && s.userId != null && s.userId != myUserId)
        if (names[s.userId] != null) names[s.userId]!,
  ];
}

/// "A kullanıcısını …" / "A ve B kullanıcılarını …" /
/// "A, B ve C kullanıcılarını …" (web `rematchBlockedMessage` ile birebir).
String rematchBlockedMessage(List<String> names) {
  final list = names.length <= 1
      ? (names.isEmpty ? '' : names.first)
      : '${names.sublist(0, names.length - 1).join(', ')} ve ${names.last}';
  final noun = names.length > 1 ? 'kullanıcılarını' : 'kullanıcısını';
  return '$list $noun engellediğiniz için önce engeli kaldırmanız gerekiyor.';
}
