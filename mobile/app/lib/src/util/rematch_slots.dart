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
import '../data/online_games_api.dart'
    show NewGameSlot, OnlineSlot, rematchSlots;
import 'random_games.dart' show createdNotice;

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

// ── Yabancılı rövanş (S2, 13 Ekim 2026, kullanıcı kararı) ───────────────────
//
// Web `buildRematchPlan`/`rematchConfirmText`/`rematchSentNotice`'in ikizi;
// vakalar `verify-rematch-slots` ile BİREBİR (`rematch_slots_test.dart`).
// Arkadaş olmayan bir insan rakip `create_online_game`da "Yalnızca arkadaşlarını
// davet edebilirsin" ile düşer. Karar: yabancı koltukları RASTGELE (açık)
// koltuğa döner, arkadaşlar davetli kalır, YZ yalnızca eski oyunda varsa son
// koltukta kalır (kendiliğinden YZ EKLENMEZ). Sunucu bunu zaten kabul ediyor:
// `create_random_game` (arkadaş + açık koltuk + 4 kişilikte son koltukta YZ).

class RematchPlan {
  /// false = bugünkü akış (`create_online_game`); true = açık koltuklu ilan
  /// (`create_random_game`).
  final bool random;

  /// Sunucuya gidecek koltuklar — çağıran başta, YZ sonda.
  final List<NewGameSlot> slots;

  /// Davet edilecek (arkadaş) rakiplerin adları, koltuk sırasıyla.
  final List<String> friendNames;

  /// Rastgele (açık) koltuk sayısı; arkadaş planında 0.
  final int openCount;

  const RematchPlan({
    required this.random,
    required this.slots,
    required this.friendNames,
    required this.openCount,
  });

  /// Oyun GEÇMİŞİNDE ham kadro isim taşımaz; arkadaş planının cümlesi geçmiş
  /// kartındaki isimlerle kurulur (bugünkü metin BİREBİR korunur).
  RematchPlan withFriendNames(List<String> names) => RematchPlan(
        random: random,
        slots: slots,
        friendNames: names,
        openCount: openCount,
      );
}

/// [friends]: arkadaş kimliği → ad. `null` = liste OKUNAMADI: bugünkü akış
/// (sunucu kendi kapısını uyguluyor) — hata "hiç arkadaşım yok" diye OKUNMAZ,
/// yoksa ağ hatası herkesi yabancı yapardı (`FriendsRepo.friends()` hatada
/// `null` döner, boş liste DEĞİL).
RematchPlan buildRematchPlan(
  List<OnlineSlot> slots,
  String myUserId,
  Map<String, String>? friends,
) {
  final humans = [
    for (final s in slots)
      if (s.isHuman && s.userId != null && s.userId != myUserId) s,
  ];
  final strangers = friends == null
      ? const <OnlineSlot>[]
      : [
          for (final s in humans)
            if (!friends.containsKey(s.userId)) s
        ];
  if (friends == null || strangers.isEmpty) {
    return RematchPlan(
      random: false,
      slots: rematchSlots(slots, myUserId),
      // Ad önceliği: arkadaş listesi (kesin) → koltuktaki ad → yer tutucu.
      friendNames: [
        for (final s in humans) friends?[s.userId] ?? s.name ?? 'Bir arkadaşın',
      ],
      openCount: 0,
    );
  }
  final aiCount = slots.where((s) => s.isAi).length;
  final kept = [
    for (final s in humans)
      if (friends.containsKey(s.userId)) s
  ];
  return RematchPlan(
    random: true,
    slots: [
      NewGameSlot.human(myUserId),
      for (final s in kept) NewGameSlot.human(s.userId!),
      for (var i = 0; i < strangers.length; i++) const NewGameSlot.open(),
      for (var i = 0; i < aiCount; i++) const NewGameSlot.ai(),
    ],
    friendNames: [for (final s in kept) friends[s.userId] ?? 'Bir arkadaşın'],
    openCount: strangers.length,
  );
}

/// Onay penceresinin metni. Arkadaş planı bugünkü cümleyle BİREBİR aynı.
String rematchConfirmText(RematchPlan plan, {required bool hasAi}) {
  final ai = hasAi ? ' 4. koltuk yine Yapay Zeka olacak.' : '';
  if (!plan.random) {
    return '${plan.friendNames.join(', ')} ile aynı kadroda yeni bir oyun '
        'açılacak ve davet gönderilecek.$ai Emin misin?';
  }
  final who = plan.openCount == 1 ? 'oyuncunun' : 'oyuncuların';
  final what = plan.openCount == 1
      ? 'rastgele bir oyuncu'
      : '${plan.openCount} rastgele oyuncu';
  final head = plan.friendNames.isNotEmpty
      ? '${plan.friendNames.join(', ')} davet edilecek; arkadaşınız olmayan '
          '$who yerine $what aranacak.'
      : 'Arkadaşınız olmayan $who yerine $what aranacak.';
  return '$head$ai Emin misin?';
}

/// Gönderim sonrası başlık + gövde (rastgele plan). `joined` = sunucu yeni ilan
/// açmak yerine uygun bir ilana KATILDI; iki durum ayrı metin alır.
({String title, String body}) rematchSentNotice(
  RematchPlan plan, {
  required bool joined,
  required bool started,
}) {
  final base = createdNotice(joined: joined, started: started);
  if (joined || plan.friendNames.isEmpty) return base;
  return (
    title: base.title,
    body: '${base.body} ${plan.friendNames.join(', ')} davet edildi.',
  );
}
