// Rastgele Oyuncu (açık ilan) için SAF kurallar — web
// `src/utils/randomGames.ts` portu (3 Ekim 2026; tasarım:
// `docs/decisions/random-opponent.md`). **İki taraf ELLE SENKRON**: biri
// değişirse öteki de; metinleri `random_games_test.dart` web dosyasından
// OKUYUP karşılaştırır (web CI'ın `parite` işi), kuralları ise bu dosyanın
// kendi testleri kilitler.
//
// Neden ayrı saf dosya: bu kuralların kırılma biçimi SESSİZ — bir oyun
// yanlış sekmede görünür, bir rozet şişer, açık koltuk "Yapay Zeka" diye
// yazılır — ve widget içinde sınanamaz.
//
// ⚠ Rozet zinciri BU DOSYADA YOK, bilerek: açık ilan HABERDİR, bekleyen iş
// DEĞİL. `PendingLiveGameCounts` / `decideInitialMainView` / uygulama ikonu
// rozeti ilanı SAYMAZ (kuralın kilidi: `random_games_test.dart`).
import '../data/online_games_api.dart';

// ── Koltuk türleri ──────────────────────────────────────────────────────────

/// Koltuk AÇIK mı (Rastgele Oyuncu bekleniyor)? Web `isOpenSeat`.
///
/// ⚠ İki biçim var: ham `{type:'open'}` ve eski istemci maskesi
/// `{type:'ai', open:true}` — `OnlineSlot.fromJson` ikisini de `isOpen`
/// yapar. Koltuğu çizen her yer buradan (ya da `slot.isOpen`ten) geçmeli;
/// `slot.isAi` GERÇEK Yapay Zeka demektir.
bool isOpenSeat(OnlineSlot slot) => slot.isOpen;

/// GERÇEK Yapay Zeka koltuğu (açık koltuk maskesi DEĞİL). Web `isRealAiSeat`.
bool isRealAiSeat(OnlineSlot slot) => slot.isAi;

/// "Bekliyor n/N" için DOLU koltuk sayısı. Yapay Zeka dolu sayılır (oyunu
/// beklemiyor); açık koltuk ve henüz yanıtlamamış arkadaş davetlisi (kurucu
/// hariç) dolu SAYILMAZ. Web `filledSeatCount`.
int filledSeatCount(List<OnlineSlot> slots) => slots.where((s) {
      if (s.isOpen) return false;
      if (s.isHuman) return s.inviteStatus != 'pending';
      return true;
    }).length;

// ── Kova sınıflandırması (LiveGamesTab) ─────────────────────────────────────

/// Rastgele ilanın KURUCUSU / ilandan KABUL EDENİ olduğum oyunların id'leri —
/// bunlar yalnızca "Devam Edenler"de ("Bekliyor n/N") görünür, davet
/// kovalarına (`waiting` = Bekleyen Oyunlar, `acceptedWaiting` = Kabul
/// Ettin) GİRMEZ. Web `randomManagedIds`.
///
/// ⚠ DÖRT KOVA DERSİ (live-game.md, 4 Ağustos 2026): `list_my_online_games`
/// bu oyunları AYRICA döndürür — kurucu `my_role='creator'`, kabul eden
/// `my_role='invitee' + 'accepted'` olarak. Süzmezsek aynı oyun iki sekmede
/// birden görünür.
///
/// ⚠ `'friend'` GİRMEZ: karma kadroda arkadaş olarak davet edilen kişi için
/// bugünkü davet/kabul akışı AYNEN geçerli. `list_my_random_games` onu da
/// döndürüyor; id'ye körü körüne bakmak onun davetini kaybettirirdi.
///
/// `myRandom == null` = liste ALINAMADI. O durumda yalnızca KESİN olanı
/// saklıyoruz: açık koltuğu olan ve kurucusu ben olduğum oyun (açık
/// koltuklu oyunu yalnızca ilan RPC'si açabilir). Kabul edenin satırı
/// geçici olarak "Kabul Ettin"de görünebilir — arkadaş davetlisini
/// yanlışlıkla gizlemekten iyi.
Set<String> randomManagedIds(
    List<MyRandomGame>? myRandom, List<OnlineGame> rows) {
  final ids = <String>{};
  if (myRandom != null) {
    for (final r in myRandom) {
      if (r.myRole == 'creator' || r.myRole == 'random') ids.add(r.id);
    }
  }
  for (final g in rows) {
    if (g.myRole == 'creator' &&
        g.status == OnlineGameStatus.pending &&
        g.slots.any(isOpenSeat)) {
      ids.add(g.id);
    }
  }
  return ids;
}

/// `LiveGamesTab`'in dört kovası (web `LiveGameBuckets`) — her biri kendi
/// sıralamasıyla (`inviteBucket` & kardeşleri).
class LiveGameBuckets {
  final List<OnlineGame> invites;
  final List<OnlineGame> active;
  final List<OnlineGame> waiting;
  final List<OnlineGame> acceptedWaiting;
  const LiveGameBuckets({
    required this.invites,
    required this.active,
    required this.waiting,
    required this.acceptedWaiting,
  });
}

/// Web `classifyLiveGames`. `invites` ve `active` `pendingCounts` ile AYNI
/// süzgeç; [managed] yalnızca bekleyen iki kovayı (`waiting`/
/// `acceptedWaiting`) daraltır — `active` ve `invites` ETKİLENMEZ: oyun dolup
/// başlayınca normal bir oyun gibi görünmeli, karma kadrodaki arkadaşın
/// bekleyen daveti bugünkü gibi sayılmalı.
LiveGameBuckets classifyLiveGames(
  List<OnlineGame> rows,
  Set<String> managed, {
  Map<String, int> turns = const {},
  Map<String, String?> deadlines = const {},
}) =>
    LiveGameBuckets(
      invites: inviteBucket(rows),
      active: activeBucket(rows, turns, deadlines: deadlines),
      waiting: waitingBucket(rows, managed: managed),
      acceptedWaiting: acceptedWaitingBucket(rows, managed: managed),
    );

/// "Devam Edenler"de "Bekliyor n/N" satırı olarak görünecek benim ilanlarım:
/// kurucu olduğum ya da ilandan kabul ettiğim, HÂLÂ bekleyen oyunlar. Dolup
/// başlamış olan `active` kovasında zaten görünür (çift satır olmasın).
/// `'friend'` burada YOK (davet akışında). Web `myWaitingRandomGames`.
List<MyRandomGame> myWaitingRandomGames(List<MyRandomGame>? myRandom) => [
      for (final g in myRandom ?? const <MyRandomGame>[])
        if (g.status == OnlineGameStatus.pending &&
            (g.myRole == 'creator' || g.myRole == 'random'))
          g
    ];

// ── Şerit ───────────────────────────────────────────────────────────────────

/// Şeridin gösterebileceği ilanlar: id ile TEKİLLEŞTİR (offset sayfalaması
/// kayar, sunucu aynı satırı iki kez verebilir), kendi ilanımı ve zaten
/// içinde olduğum oyunları ÇIKAR (sunucu zaten eler; ikinci emniyet), sırayı
/// koru (sunucu: en yeni önce). Web `visibleListings`.
List<RandomListing> visibleListings(
  List<RandomListing> listings,
  String? myUserId,
  Set<String> myGameIds,
) {
  final seen = <String>{};
  final out = <RandomListing>[];
  for (final l in listings) {
    if (!seen.add(l.id)) continue;
    if (myUserId != null && l.creatorId == myUserId) continue;
    if (myGameIds.contains(l.id)) continue;
    out.add(l);
  }
  return out;
}

/// Şerit kartındaki "N koltuk kaldı" — zaman/yaş bilgisi KONMAZ.
String seatsLeftLabel(int open) =>
    open == 1 ? '1 koltuk kaldı' : '$open koltuk kaldı';

/// Şerit kartındaki nokta: dolu (yeşil) mü, boş (içi boş halka) mı?
/// Web `SeatDots`: 'creator' | 'filled' | 'ai' dolu; 'open'/'invited' boş.
bool seatDotFilled(String seat) =>
    seat == 'creator' || seat == 'filled' || seat == 'ai';

// ── Kurulum formu: esnek kadro ──────────────────────────────────────────────

/// Seçili koltuklardaki "Rastgele Oyuncu" işareti. Gerçek bir kullanıcı
/// kimliği (uuid) ile ÇAKIŞAMAZ.
const String kRandomSeat = '?';

/// Rastgele satırına dokunuş (kullanıcı, 4 Ekim 2026: "seçildikten sonra tekrar
/// üstüne basınca geri alsın"): boş bir koltuğu "?" yapar. Boş koltuk
/// KALMADIYSA ve seçimde "?" varsa dokunuş TÜM "?" koltuklarını geri alır
/// (2 kişide ikinci dokunuş; 4 kişide ×3'ten sonraki dokunuş). Dolu ve "?"
/// yoksa: 2 kişide dolu arkadaş koltuğu DEĞİŞTİRİLİR, 4 kişide etkisiz.
/// Web `addRandomSeat`.
List<String> addRandomSeat(List<String> selected, int playerCount) {
  if (selected.length < playerCount - 1) return [...selected, kRandomSeat];
  if (selected.contains(kRandomSeat)) {
    return [
      for (final s in selected)
        if (s != kRandomSeat) s
    ];
  }
  if (playerCount == 2) return const [kRandomSeat];
  return [...selected];
}

/// Arkadaş satırına dokunuş (eski `toggleFriend` ile AYNI kural; "?"
/// koltukları korunur). Web `toggleFriendSeat`.
List<String> toggleFriendSeat(
    List<String> selected, String friendId, int playerCount) {
  if (playerCount == 2) {
    return selected.contains(friendId) ? const [] : [friendId];
  }
  if (selected.contains(friendId)) {
    return [
      for (final id in selected)
        if (id != friendId) id
    ];
  }
  if (selected.length >= 3) return [...selected];
  return [...selected, friendId];
}

/// Koltuk kartına dokunuş: o koltuğu boşaltır. Web `removeSeatAt`.
List<String> removeSeatAt(List<String> selected, int index) => [
      for (var i = 0; i < selected.length; i++)
        if (i != index) selected[i]
    ];

int randomSeatCount(List<String> selected) =>
    selected.where((s) => s == kRandomSeat).length;

/// En az bir "?" varsa kadro bir İLAN (`create_random_game`), yoksa bugünkü
/// davet yolu. Web `usesRandomSeat`.
bool usesRandomSeat(List<String> selected) => randomSeatCount(selected) > 0;

/// 2 kişide 1, 4 kişide en az 2 (ortadaki iki koltuk dolmalı). Web
/// `canSubmitSeats`.
bool canSubmitSeats(List<String> selected, int playerCount) =>
    playerCount == 2 ? selected.length == 1 : selected.length >= 2;

/// 4 kişide tam 2 seçim → 4. koltuk Yapay Zeka (bugünkü kural; rastgele
/// kadroda da, karar B). Web `aiLastSeat`.
bool aiLastSeat(List<String> selected, int playerCount) =>
    playerCount == 4 && selected.length == 2;

/// `create_random_game`'e giden koltuklar: koltuk 0 çağıran, sonra seçimler
/// (arkadaş → insan, "?" → açık), 4 kişide tam 2 seçimde sondaki YZ. Web
/// `buildRandomSlots`.
List<NewGameSlot> buildRandomSlots(
    String userId, List<String> selected, int playerCount) {
  return [
    NewGameSlot.human(userId),
    for (final s in selected)
      s == kRandomSeat ? const NewGameSlot.open() : NewGameSlot.human(s),
    if (aiLastSeat(selected, playerCount)) const NewGameSlot.ai(),
  ];
}

// ── Metinler (web ile BİREBİR — random_games_test.dart okur) ───────────────

/// Kabul sonrası ileti. Web `acceptNotice`.
String acceptNotice({required bool started}) => started
    ? 'Kabul ettin. Oyun başladı.'
    : 'Kabul ettin. Diğer oyuncular bekleniyor.';

/// "Davet Gönder" sonrası başlık + açıklama (onay ekranı). Web
/// `createdNotice`.
({String title, String body}) createdNotice(
    {required bool joined, required bool started}) {
  if (joined) {
    return (
      title: 'Oyuna katıldın',
      body: started
          ? 'Uygun bir ilan vardı, ona katıldın. Oyun başladı.'
          : 'Uygun bir ilan vardı, ona katıldın. Diğer oyuncular bekleniyor.',
    );
  }
  return (
    title: 'İlanın yayında',
    body:
        'İlanın yayında. Biri kabul edince oyun başlar. 7 gün içinde dolmazsa kendiliğinden kalkar, ceza yok.',
  );
}

/// Şeridin ve kartların sabit yoklama aralığı — Realtime RLS yüzünden şerit
/// olayla beslenemez (web `RANDOM_STRIP_POLL_MS`).
const Duration kRandomStripPoll = Duration(seconds: 40);

/// Öne dönüş/odak yoklamasının en sık tekrar aralığı (web
/// `RANDOM_STRIP_MIN_GAP_MS`).
const Duration kRandomStripMinGap = Duration(seconds: 8);

/// Şerit yalnızca ilk sayfayı çeker (web `RANDOM_STRIP_LIMIT`).
const int kRandomStripLimit = 20;

// Ekran metinleri — web bileşenleriyle aynı dizeler.
const String kRandomRowTitle = 'Rastgele Oyuncu';
const String kRandomRowSub = 'Bunu seçerseniz rasgele oyun açarsınız.';
const String kRandomSeatLabel2 = 'Rastgele oyuncu';
const String kRandomSeatLabel4 = 'Rastgele';
const String kRandomStripTitle = 'Rastgele Oyunlar';
const String kRandomStripCreate = 'Rastgele oyun aç';
const String kRandomAcceptLabel = 'Kabul';
const String kRandomWaitingSeat = 'Rastgele oyuncu bekleniyor';
const String kRandomWaitingFriend = 'Arkadaş yanıtı bekleniyor';
const String kRandomWaitingStarting = 'Oyun başlıyor';
const String kRandomCancelLabel = 'İlanı iptal et';
const String kRandomLeaveLabel = 'Ayrıl';
const String kRandomCancelledNotice = 'İlan iptal edildi.';
const String kRandomLeftNotice = 'Ayrıldın. Koltuk yeniden açıldı.';
const String kRandomLeaveFallback = 'İşlem tamamlanamadı.';
const String kRandomAcceptFallback = 'Kabul edilemedi.';
