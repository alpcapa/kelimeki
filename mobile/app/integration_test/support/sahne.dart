// Ekran görüntüsü/ölçüm sahnesi — İKİ integration_test dosyasının ORTAK
// kaynağı: `store_screenshots_test.dart` (mağaza kareleri, App Store 24.5)
// ve `ipad_landscape_test.dart` (iPad manzara ölçümü, ROADMAP §25).
//
// NEDEN AYRI DOSYA: sahte oturum, sahte istatistik ucu ve Setup'ın sahte
// servisleri "temsili kare" kurallarının kendisini taşıyor (gerçek isim/
// e-posta/avatar kareye giremez; `services.supabase == null` iken ekran
// *"offline mod"* yazıp üstünde canlı oyun listeliyor — böyle bir ekran
// gerçekte hiç oluşmaz). İkinci bir çekim dosyası bunları KOPYALASAYDI iki
// kopya sessizce ayrışır ve kurallar yalnızca birinde geçerli kalırdı.
//
// ⚠ Dosya adı `_test.dart` ile BİTMİYOR — `flutter drive --target` yalnızca
// gerçek çekim dosyalarını hedefler, bu dosya tek başına koşmaz.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/dictionary_loader.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/online_status.dart';

// Sahte uçlar TEK KAYNAKTAN: widget testlerinin zaten kullandığı dosya.
// ⚠ `test/support/game_rows.dart` BİLEREK import edilmiyor — o dosya
// `sqflite_common_ffi` (masaüstü) çekiyor ve burası GERÇEK CİHAZDA koşuyor.
import '../../test/support/fake_online_gateway.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient, User;

/// Tahtayı dolduran tohum ve hamle sayısı — Linux'ta motoru koşturarak
/// SEÇİLDİ (9 Eylül 2026), rastgele değil. Ölçülen sonuç: 43 taş, skor
/// 114–76 (çekişmeli, oyuncu önde), tahtada bir joker, merkezdeki X2/X3
/// bölgesi kullanılmış, ve oyuncunun rafı `KAOEMLE` — yani ekranda
/// gerçekten oynanabilir bir el duruyor ("KALEM"). Bir mağaza karesinde
/// oyuncunun ezildiği ya da rafın tamamen ünlü olduğu bir kare istemiyoruz;
/// taranan yedi tohumun içinde bu üçünü birden sağlayan tek aday buydu.
const int kSeed = 11;
const int kMoves = 12;

/// Ekranda görünen ad. Gerçek bir kişinin adı ya da e-postası KARE'ye
/// giremez (Play turunun yazılı gizlilik kuralı); `Ironman` bu depoda
/// zaten bilinen bir test kimliği.
const String kPlayerName = 'Ironman';

/// Anlam penceresinin kelimesi. Tahtada GERÇEKTEN duruyor (oyuncunun köşe
/// açılışı) ve `meanings.db`'de birden çok anlamı var — yani pencere tek
/// satırlık değil, özelliği anlatan bir liste gösteriyor.
const String kMeaningWord = 'SAZ';

/// Anlam penceresi üretim yolundan (bir dialog olarak) açılıyor; o yol bir
/// `BuildContext` istiyor.
final navKey = GlobalKey<NavigatorState>();

/// Sözlük — `sozlukYukle()` ile bir kez doldurulur.
late SetWordSource sahneSozlugu;

/// Cihazda sözlük asset'ten okunur — testlerdeki `File(...)` yolu burada
/// ÇALIŞMAZ, uygulama paketinin içindeyiz.
Future<void> sozlukYukle() async {
  sahneSozlugu = await loadDictionary(rootBundle);
}

/// Kareler GİRİŞLİ çekilir — Play turunun yazılı kuralı *"test hesabıyla
/// çek"* diyor, ve misafir hâlde başlıkta `GİRİŞ` butonu duruyor. Sahte
/// oturum bunu ağa çıkmadan çözüyor: başlıkta avatar/ad çizilir, hiçbir
/// secret ya da gerçek hesap gerekmez.
///
/// ⚠ `email` BİLEREK BOŞ. `test/account_button_test.dart`in yardımcısı
/// geliştiricinin kişisel adresini taşıyor; o kimlik buraya kopyalanamaz —
/// Play'in çekim kuralı *"e-posta geçen ekran yok"* diyor.
AuthService sahneAuth() => AuthService.fake(
      user: User(
        id: 'u-kelimeki-store',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
      profile: const KProfile(id: 'u-kelimeki-store', displayName: kPlayerName),
    );

/// Oyuncunun rafından TAHTAYA kurulmuş ama henüz onaylanmamış bir hamle
/// bırakır — mağaza setinin 2. karesinin konusu bu (yeşil dış hat + puan
/// rozeti).
///
/// Hamle elle KODLANMIYOR, motorun kendi arama fonksiyonundan seçiliyor:
/// önce geniş arama adayları alınır, sonra **en çok taş kullanan** aday
/// (eşitlikte yüksek puan, sonra `trCompare`) seçilir. Sebep: en yüksek
/// puanlı hamle çoğu zaman 2 taşlık sıkışık bir hamle oluyor ve mağaza
/// karesinde mekaniği ANLATMIYOR; 4 taşlık, mevcut bir taşın üstünden geçen
/// dikey bir kelime hem kuralı hem yeşil dış hattı gösteriyor.
void stageBestMove(GameController controller) {
  final s = controller.state;
  final me = s.players[0];
  final adaylar = findAIMoves(s.board, me.rack, s.bonuses, 0, me.corners,
      isFirstMove(s), s.players, sahneSozlugu, 40,
      search: const AiSearch(wide: true, maxWordLen: 8));
  if (adaylar.isEmpty) return;
  final sirali = [...adaylar]..sort((a, b) {
      final t = b.placements.length.compareTo(a.placements.length);
      if (t != 0) return t;
      final p = b.score.compareTo(a.score);
      if (p != 0) return p;
      return trCompare(a.word, b.word);
    });
  for (final p in sirali.first.placements) {
    // ⚠ Raf her yerleştirmede KÜÇÜLÜYOR (`_placeTile` indeksi çıkarıyor),
    // yani indeksler önceden hesaplanamaz — her adımda GÜNCEL raftan
    // bakılmalı. Önceden hesaplanınca son taş sessizce düşüyordu (ölçüldü).
    final rack = controller.state.players[0].rack;
    var idx = rack.indexWhere((t) => !t.wild && t.letter == p.tile.letter);
    if (idx < 0) idx = rack.indexWhere((t) => t.letter == '?');
    if (idx < 0) return;
    controller.dispatch(PlaceTileAction(
      r: p.r,
      c: p.c,
      rackIndex: idx,
      wildLetter: rack[idx].letter == '?' ? p.tile.letter : null,
    ));
  }
}

/// Kareleri çeken ekranların ortak kurulumu.
GameController oyunKontrolcusu() {
  final controller = GameController(
    words: sahneSozlugu,
    autoPlayAi: false, // kare sabit kalsın; YZ araya girip tahtayı değiştirmesin
    nowIso: () => '',
    rng: Mulberry32(kSeed),
  );
  controller.dispatch(ResumeSavedAction(midGameState()));
  return controller;
}

Widget oyunEkrani(GameController controller) => MaterialApp(
      theme: kelimekiTheme(),
      // `storage` VERİLMİYOR: zoom tanıtım balonu yalnızca o varken çıkıyor
      // ve mağaza karesinde bir öğretici balonu istemiyoruz.
      home: GameScreen(
        controller: controller,
        words: sahneSozlugu,
        auth: sahneAuth(),
      ),
    );

/// Oyunun ortasındaki tahtayı GERÇEK motorla üretir.
///
/// İki YZ oynatılır (reducer yalnızca sırası gelen oyuncu YZ ise hamle
/// yapıyor — `_aiPlay`), sonra 0. koltuk sunum için insana çevrilir. Böylece
/// tahta motorun kendi kurallarıyla oluşmuş, kurallara uygun ve tekrar
/// üretilebilir olur; elle "güzel" bir tahta uydurulmuş olmaz.
GameState midGameState() {
  final engine =
      GameEngine(words: sahneSozlugu, rng: Mulberry32(kSeed), nowIso: () => '');
  var s = engine.reduce(
    createInitialState(),
    const StartAction([
      PlayerSetup(name: '', isAI: true),
      PlayerSetup(name: '', isAI: true),
    ]),
  );
  for (var i = 0; i < kMoves && !s.isGameOver; i++) {
    s = engine.reduce(s, const AiPlayAction());
  }
  return s.copyWith(players: [
    s.players[0].copyWith(name: kPlayerName, isAI: false),
    s.players[1],
  ]);
}

/// Sabit sayıda kare çizer. `pumpAndSettle` BİLEREK kullanılmıyor: ekranda
/// süren bir animasyon varsa (nömorfik geçişler, balonlar) sonsuza kadar
/// bekler ve koşu sessizce zaman aşımına düşer.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Skor kartının sahte ucu. Rakamlar UYDURMA ama TUTARLI: mağaza karesinde
/// gerçek bir hesabın istatistiği gösterilemez (Play turunun gizlilik
/// kuralı) ve boş bir kart da özelliği anlatmaz.
class SahteStatsGateway implements StatsGateway {
  static Map<String, Object?> _satir({
    int games = 34,
    int local = 21,
    int online = 13,
    int first = 19,
    int second = 8,
    int surrendered = 1,
    int bestScore = 412,
    int bestMove = 63,
    int bestWord = 48,
    double avgMove = 21.4,
    String longest = 'KELİMELİK',
    int total = 57,
  }) =>
      {
        'games_played': games,
        'local_games_played': local,
        'online_games_played': online,
        'first_places': first,
        'second_places': second,
        'surrendered_count': surrendered,
        'best_score': bestScore,
        'best_move_score': bestMove,
        'best_word_score': bestWord,
        'avg_move_score': avgMove,
        'longest_word': longest,
        'total_score': total,
      };

  @override
  Future<Map<String, Object?>?> playerStats(String userId, int? playerCount) async =>
      switch (playerCount) {
        null => _satir(),
        2 => _satir(games: 26, local: 15, online: 11, first: 15, total: 44),
        _ => _satir(games: 8, local: 6, online: 2, first: 4, second: 3, total: 13),
      };

  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async => const [];

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async =>
      const {'rank': 4, 'total_score': 57};

  @override
  Future<List<Map<String, Object?>>> rankScores(List<String> userIds) async => const [];

  @override
  Future<Map<String, Object?>?> profileAgeGender(String userId) async => null;

  @override
  Future<Map<String, Object?>?> headToHead(String otherUserId) async => null;
}

/// Setup'ın teşhis satırındaki *"sunucu bağlı"* etiketi için.
///
/// ⚠ **Neden gerçek bir istemci DEĞİL:** `SupabaseClient` kurmak bir
/// `HttpClient` ve bekleyen zamanlayıcı yaratıyor (ölçüldü — testi
/// düşürüyor), üstelik bu iş akışının tüm önermesi *"ağa çıkma, secret
/// isteme"*. `services.supabase` üretimde TEK bir yerde okunuyor
/// (`setup_screen.dart` → `!= null ? 'sunucu bağlı' : 'offline mod'`),
/// yani bu nesnenin üzerine hiçbir çağrı düşmüyor.
///
/// ⚠ **Neden `null` bırakılamadı:** teşhis satırı üretimde HER ZAMAN
/// görünüyor (bilinçli — bkz. `mobile/CLAUDE.md`, "Derleme kimliği"), ve
/// `null` ile kare *"offline mod"* yazarken ÜSTÜNDE canlı oyunlar
/// listeleniyordu. Böyle bir ekran gerçekte hiç oluşmaz, yani kare
/// uygulamayı YANLIŞ temsil ederdi — Apple'ın tam olarak yasakladığı şey.
class SahteSupabase implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

/// Setup ekranının servisleri. Ağ YOK; listeler sahte uçlardan geliyor ve
/// isimler UYDURMA — Play turunun yazılı kuralı: gerçek arkadaş adı/avatarı
/// kareye giremez. Burada sahtelik bir taviz değil, kuralın ta kendisi.
AppServices setupServisleri() {
  const ben = 'u-kelimeki-store';
  Map<String, Object?> satir(String id, String rakipAd, String rakipId) =>
      gameRow(
        id: id,
        myId: ben,
        status: 'active',
        slots: [
          slotHuman(rakipId, name: rakipAd, relation: 'accepted'),
          slotHuman(ben, name: kPlayerName, relation: 'self'),
        ],
      );
  // Üç oyun, İKİ farklı sıra durumu: tek satırlık bir liste özelliği
  // anlatmıyordu; "SIRA SENDE" (yeşil) ↔ "SIRA RAKİPTE" (kırmızı) ayrımı
  // ekranın ne işe yaradığını tek bakışta gösteriyor.
  final og = FakeOnlineGamesGateway()
    ..rows = [
      satir('g1', 'Esiner', 'u-esiner'),
      satir('g2', 'Kaptan', 'u-kaptan'),
      satir('g3', 'Zeynep', 'u-zeynep'),
    ]
    ..turnRows = [
      {'online_game_id': 'g1', 'current': 1},
      {'online_game_id': 'g2', 'current': 0},
      {'online_game_id': 'g3', 'current': 1},
    ];
  return AppServices(
    onlineStatus: OnlineStatus.fake(),
    dictionary: Future.value(sahneSozlugu),
    meanings: MeaningStore(bundle: rootBundle),
    auth: sahneAuth(),
    supabase: SahteSupabase(),
    versionGate: VersionGateStatus.ok,
    onlineGames: OnlineGamesRepo(og),
    friends: FriendsRepo(FakeFriendsGateway()),
  );
}
