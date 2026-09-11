// Mağaza ekran görüntüsü üreticisi — App Store FAZ C 24.5.
//
// NEDEN BU DOSYA VAR: mağazaya giden kare, uygulamanın GERÇEK görüntüsü
// olmak zorunda. `marketing/play-store/metin.md`'deki yazılı karar farklı
// bir yüzeyden (emülatör/web) alınan görseli *yanıltıcı ekran görüntüsü*
// sayıyor; `marketing/app-store/console-formlari.md` §13 aynı gerekçeyle
// widget testinden çizmeyi de eledi (aynı Dart ağacı, ama iOS çalışma
// zamanı değil). Kalan tek doğru kaynak: iOS SİMÜLATÖRÜ — gerçek iOS,
// gerçek uygulama ikilisi, Xcode'un kendi yolu.
//
// NASIL KOŞAR: `flutter drive` ile, `test_driver/integration_test.dart`
// sürücüsüne karşı. Kareyi sürücü yazar (`onScreenshot`), boyutu cihazın
// fiziksel pikseli belirler — iPhone 6.9" 1320×2868, iPad 13" 2064×2752,
// yani Apple'ın istediği ölçü KIRPMADAN çıkar. ⚠ Play refleksiyle kırpma:
// App Store tam ölçü istiyor, kırpmak kareyi GEÇERSİZ yapar.
// Komut CI'da: `.github/workflows/ios-screenshots.yml`.
//
// ⚠ FIXTURE DEPOYA GİRMEZ. Tahta, gerçek motorla ve tohumlu rastgelelikle
// KOŞMA ANINDA üretiliyor (`Mulberry32`) — golden JSON'u asset olarak
// paketlemek onu mağazaya giden uygulama ikilisine de sokardı.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/dictionary_loader.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/meaning_entry.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/meaning_modal.dart';
import 'package:kelimeki/src/ui/route_observer.dart';
import 'package:kelimeki/src/ui/score/score_card_modal.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/ui/tokens.dart';
import 'package:kelimeki/src/util/online_status.dart';

// Sahte uçlar TEK KAYNAKTAN: widget testlerinin zaten kullandığı dosya.
// ⚠ `test/support/game_rows.dart` BİLEREK import edilmiyor — o dosya
// `sqflite_common_ffi` (masaüstü) çekiyor ve burası GERÇEK CİHAZDA koşuyor.
import '../test/support/fake_online_gateway.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient, User;

/// Tahtayı dolduran tohum ve hamle sayısı — Linux'ta motoru koşturarak
/// SEÇİLDİ (9 Eylül 2026), rastgele değil. Ölçülen sonuç: 43 taş, skor
/// 114–76 (çekişmeli, oyuncu önde), tahtada bir joker, merkezdeki X2/X3
/// bölgesi kullanılmış, ve oyuncunun rafı `KAOEMLE` — yani ekranda
/// gerçekten oynanabilir bir el duruyor ("KALEM"). Bir mağaza karesinde
/// oyuncunun ezildiği ya da rafın tamamen ünlü olduğu bir kare istemiyoruz;
/// taranan yedi tohumun içinde bu üçünü birden sağlayan tek aday buydu.
const int _kSeed = 11;
const int _kMoves = 12;

/// Ekranda görünen ad. Gerçek bir kişinin adı ya da e-postası KARE'ye
/// giremez (Play turunun yazılı gizlilik kuralı); `Ironman` bu depoda
/// zaten bilinen bir test kimliği.
const String _kPlayerName = 'Ironman';

/// ── Başlık şeridi (mağaza kompozisyonu, 11 Eylül 2026) ──────────────────
///
/// KARAR: kareler **başlıklı** çıkıyor (kullanıcı, 11 Eylül 2026). Gerekçe
/// `marketing/app-store/console-formlari.md` §13'te: App Store kareleri önce
/// küçük küçük yan yana gösteriyor ve başlıksız bir tahta karesi o boyutta
/// "bir oyun tahtası"ndan fazlasını anlatmıyor. Üstelik kareler **sürüme
/// kilitli** — onaylandıktan sonra değiştirmek yeni bir gönderim ister,
/// yani ilk turda doğru olmak zorunda (promotional text gibi serbest değil).
///
/// ⚠ Şerit uygulamanın ÜSTÜNE binmiyor, ALTINA konuyor: uygulama `Expanded`
/// içinde, biraz daha kısa bir görünüm alanında GERÇEKTEN çiziliyor —
/// hiçbir içerik örtülmüyor, hiçbir arayüz öğesi taklit edilmiyor (düz
/// zemin + tek satır metin). §13'ün *"kare gerçek uygulama görüntüsü
/// olmalı"* kuralı bu yüzden korunuyor.
///
/// ⚠ **Son işlem (ImageMagick/`sharp`) YOK ve olmamalı.** Şerit Flutter
/// ağacının içinde çizildiğinden kare yine cihazın fiziksel pikselinde
/// çıkıyor (1320×2868 / 2064×2752) ve `ios-screenshots.yml`in piksel ölçüm
/// adımı DEĞİŞMEDEN geçiyor; CI'a yeni bir araç/bağımlılık girmiyor.
const Map<String, String> _kBasliklar = {
  '01-oyun-ekrani': 'Köşenden başla, bölgeni büyüt',
  '02-kurulmus-hamle': 'Kelimeni kur, puanını gör',
  '03-arkadasinla': 'Arkadaşınla sırayla oyna',
  '04-skor-karti': 'İstatistiklerini takip et',
  '05-kelime-anlami': 'Kelimenin anlamı bir dokunuş',
  '06-nasil-oynanir': 'Kuralları üç dakikada öğren',
  '07-klig-siralamasi': "k-lig'de sıranı yükselt",
};

/// Punto ekran GENİŞLİĞİNE oranlı — sabit bir punto verilseydi iPad
/// karesinde yarı boyda kalırdı. iPhone 6.9" mantıksal 440 geniş (×3 =
/// 1320), iPad 13" 1032 (×2 = 2064).
const double _kBantPuntoOran = 0.055;

/// ⚠ Yükseklik TAVANI — yalnızca genişliğe oranlamak yetmiyor (ölçüldü,
/// 11 Eylül 2026): iPad karesi iPhone'a göre çok daha geniş ama aynı oranda
/// uzun değil (1032×1376 ↔ 440×956), yani %5,5'lik punto şeridi iPad'de
/// yüksekliğin **%11,6**'sına çıkarıyordu. Tavanla ikisi de ~%7-9 bandında
/// kalıyor: iPhone 24,2 punto (şerit yüksekliğin %7,1'i) · iPad 44,0
/// (%8,9). Kare başına ölçüm: `_kBasliklar`ın en uzunu bu puntoda
/// kullanılabilir genişliğin %90'ı (iPhone) / %71'i (iPad), yani hiçbir
/// başlık `scaleDown` ile küçülmüyor — hepsi tek satır.
const double _kBantPuntoYukseklikTavani = 0.032;

/// Şerit yüksekliği = punto × bu. 2,8 tek satırlık başlığa üstten/alttan
/// yaklaşık birer satır boşluk bırakıyor; iPhone karesinde şerit, 01/02'de
/// zaten boş duran alt ~%20'nin içinde kalıyor.
const double _kBantYukseklikCarpani = 2.8;

/// `MaterialApp.builder`a takılan sarmalayıcı. `builder` Navigator'ın ÜSTÜNÜ
/// sardığından pencereler de (05'in anlam penceresi) şeridin üstünde kalır —
/// her kare için ayrı bir düzen kurmaya gerek yok.
TransitionBuilder _bantli(String kareAdi) {
  final baslik = _kBasliklar[kareAdi];
  if (baslik == null) throw StateError('$kareAdi icin baslik tanimli degil');
  return (context, child) => _BaslikSeridi(baslik: baslik, child: child!);
}

class _BaslikSeridi extends StatelessWidget {
  const _BaslikSeridi({required this.baslik, required this.child});

  final String baslik;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final olcu = MediaQuery.sizeOf(context);
    final genislik = olcu.width;
    final punto = (genislik * _kBantPuntoOran)
        .clamp(0.0, olcu.height * _kBantPuntoYukseklikTavani);
    return Column(
      children: [
        // ⚠ `removeBottom`: uygulama ALT güvenli alan boşluğunu (home
        // göstergesi) ayırmaya devam ederse içerikle şerit arasında ölü bir
        // bant kalır — o boşluğun savunduğu alan artık ekranın dibinde değil.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        Material(
          color: kText,
          child: SizedBox(
            width: double.infinity,
            height: punto * _kBantYukseklikCarpani,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: genislik * 0.06),
                // ⚠ `scaleDown`: başlık uzarsa KIRPILMASIN, küçülsün. Kare
                // sessizce yarım bir cümleyle mağazaya gitmesin diye.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    baslik,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // ⚠ Aile AÇIKÇA veriliyor: şerit Scaffold'un dışında
                      // ve `MaterialApp.builder` seviyesinde `DefaultTextStyle`
                      // temanın değil, WidgetsApp'in hata stili.
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: punto,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kareler GİRİŞLİ çekilir — Play turunun yazılı kuralı *"test hesabıyla
/// çek"* diyor, ve misafir hâlde başlıkta `GİRİŞ` butonu duruyor. Sahte
/// oturum bunu ağa çıkmadan çözüyor: başlıkta avatar/ad çizilir, hiçbir
/// secret ya da gerçek hesap gerekmez.
///
/// ⚠ `email` BİLEREK BOŞ. `test/account_button_test.dart`in yardımcısı
/// geliştiricinin kişisel adresini taşıyor; o kimlik buraya kopyalanamaz —
/// Play'in çekim kuralı *"e-posta geçen ekran yok"* diyor.
AuthService _screenshotAuth() => AuthService.fake(
      user: User(
        id: 'u-kelimeki-store',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
      profile: const KProfile(id: 'u-kelimeki-store', displayName: _kPlayerName),
    );

/// Oyuncunun rafından TAHTAYA kurulmuş ama henüz onaylanmamış bir hamle
/// bırakır — 2. karenin konusu bu (yeşil dış hat + puan rozeti).
///
/// Hamle elle KODLANMIYOR, motorun kendi arama fonksiyonundan seçiliyor:
/// önce geniş arama adayları alınır, sonra **en çok taş kullanan** aday
/// (eşitlikte yüksek puan, sonra `trCompare`) seçilir. Sebep: en yüksek
/// puanlı hamle çoğu zaman 2 taşlık sıkışık bir hamle oluyor ve mağaza
/// karesinde mekaniği ANLATMIYOR; 4 taşlık, mevcut bir taşın üstünden geçen
/// dikey bir kelime hem kuralı hem yeşil dış hattı gösteriyor.
void _stageBestMove(GameController controller) {
  final s = controller.state;
  final me = s.players[0];
  final adaylar = findAIMoves(s.board, me.rack, s.bonuses, 0, me.corners,
      isFirstMove(s), s.players, _words, 40,
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
GameController _oyunKontrolcusu() {
  final controller = GameController(
    words: _words,
    autoPlayAi: false, // kare sabit kalsın; YZ araya girip tahtayı değiştirmesin
    nowIso: () => '',
    rng: Mulberry32(_kSeed),
  );
  controller.dispatch(ResumeSavedAction(_midGameState()));
  return controller;
}

Widget _oyunEkrani(GameController controller, String kareAdi) => MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli(kareAdi),
      // `storage` VERİLMİYOR: zoom tanıtım balonu yalnızca o varken çıkıyor
      // ve mağaza karesinde bir öğretici balonu istemiyoruz.
      home: GameScreen(
        controller: controller,
        words: _words,
        auth: _screenshotAuth(),
      ),
    );

late SetWordSource _words;

/// 5. karenin kelimesi. Tahtada GERÇEKTEN duruyor (oyuncunun köşe açılışı)
/// ve `meanings.db`'de birden çok anlamı var — yani pencere tek satırlık
/// değil, özelliği anlatan bir liste gösteriyor.
const String _kMeaningWord = 'SAZ';

/// Anlam penceresi üretim yolundan (bir dialog olarak) açılıyor; o yol bir
/// `BuildContext` istiyor.
final _navKey = GlobalKey<NavigatorState>();

/// Oyunun ortasındaki tahtayı GERÇEK motorla üretir.
///
/// İki YZ oynatılır (reducer yalnızca sırası gelen oyuncu YZ ise hamle
/// yapıyor — `_aiPlay`), sonra 0. koltuk sunum için insana çevrilir. Böylece
/// tahta motorun kendi kurallarıyla oluşmuş, kurallara uygun ve tekrar
/// üretilebilir olur; elle "güzel" bir tahta uydurulmuş olmaz.
GameState _midGameState() {
  final engine =
      GameEngine(words: _words, rng: Mulberry32(_kSeed), nowIso: () => '');
  var s = engine.reduce(
    createInitialState(),
    const StartAction([
      PlayerSetup(name: '', isAI: true),
      PlayerSetup(name: '', isAI: true),
    ]),
  );
  for (var i = 0; i < _kMoves && !s.isGameOver; i++) {
    s = engine.reduce(s, const AiPlayAction());
  }
  return s.copyWith(players: [
    s.players[0].copyWith(name: _kPlayerName, isAI: false),
    s.players[1],
  ]);
}

/// Sabit sayıda kare çizer. `pumpAndSettle` BİLEREK kullanılmıyor: ekranda
/// süren bir animasyon varsa (nömorfik geçişler, balonlar) sonsuza kadar
/// bekler ve koşu sessizce zaman aşımına düşer.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Cihazda sözlük asset'ten okunur — testlerdeki `File(...)` yolu burada
    // ÇALIŞMAZ, uygulama paketinin içindeyiz.
    _words = await loadDictionary(rootBundle);
  });

  testWidgets('01 — oyun ekranı, oyunun ortası', (tester) async {
    final controller = _oyunKontrolcusu();
    await tester.pumpWidget(_oyunEkrani(controller, '01-oyun-ekrani'));
    await _settle(tester);

    await binding.takeScreenshot('01-oyun-ekrani');
    controller.dispose();
  });

  testWidgets('02 — kurulmuş hamle (yeşil dış hat + puan rozeti)',
      (tester) async {
    final controller = _oyunKontrolcusu();
    _stageBestMove(controller);
    await tester.pumpWidget(_oyunEkrani(controller, '02-kurulmus-hamle'));
    await _settle(tester);

    await binding.takeScreenshot('02-kurulmus-hamle');
    controller.dispose();
  });

  testWidgets('03 — kurulum ekranı, "Arkadaşınla" sekmesi', (tester) async {
    // Üretimdeki `navigatorObservers` ile AYNI olmak zorunda: Setup'ın
    // "bir ekrandan dönüldü" tazelemesi `RouteAware.didPopNext`ten geliyor.
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli('03-arkadasinla'),
      navigatorObservers: [kRouteObserver],
      home: SetupScreen(services: _setupServisleri()),
    ));
    await _settle(tester);
    // Ekran "Yapay Zeka ile" sekmesiyle açılıyor; kare Canlı oyunu
    // anlatacak, o yüzden sekme DEĞİŞTİRİLİYOR (gerçek dokunuşla).
    await tester.tap(find.text('ARKADAŞINLA'));
    await _settle(tester);

    await binding.takeScreenshot('03-arkadasinla');
  });

  testWidgets('04 — skor kartı', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli('04-skor-karti'),
      home: Scaffold(
        body: ScoreCardModal(
          auth: _screenshotAuth(),
          stats: StatsRepo(_SahteStatsGateway()),
        ),
      ),
    ));
    await _settle(tester);

    await binding.takeScreenshot('04-skor-karti');
  });

  testWidgets('05 — kelime anlamı (TDK penceresi)', (tester) async {
    // Anlam GERÇEK asset'ten okunuyor (`meanings.db`), metin UYDURULMUYOR.
    // ⚠ `runAsync` ŞART: `MeaningStore` gerçek sqflite async'i kullanıyor ve
    // testin sahte zaman bölgesinde çözülmüyor (widget testlerinin bu
    // yüzden hiç deneyemediği yol — burada gerçek cihazdayız).
    final store = MeaningStore(bundle: rootBundle);
    MeaningEntry? kayit;
    await tester.runAsync(() async {
      kayit = await store.lookup(_kMeaningWord);
    });

    final controller = _oyunKontrolcusu();
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli('05-kelime-anlami'),
      navigatorKey: _navKey,
      home: GameScreen(
        controller: controller,
        words: _words,
        auth: _screenshotAuth(),
      ),
    ));
    await _settle(tester);

    // Pencereyi üretim yolundan aç — tahtadaki bir taşa dokunulduğunda
    // çağrılan fonksiyonun ta kendisi.
    unawaited(showMeaningModal(
      _navKey.currentContext!,
      (_) async => kayit,
      const [_kMeaningWord],
    ));
    await _settle(tester);

    await binding.takeScreenshot('05-kelime-anlami');
    controller.dispose();
  });

  testWidgets('06 — nasıl oynanır', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli('06-nasil-oynanir'),
      home: const HelpModal(),
    ));
    await _settle(tester);

    await binding.takeScreenshot('06-nasil-oynanir');
  });

  // 7. kare çekim listesinde "opsiyonel" işaretliydi; 11 Eylül 2026'da
  // kullanıcı eklenmesine karar verdi. Gerekçe: k-lig oyunun ayırt edici
  // tarafı ve ilk altı karenin hiçbirinde GÖRÜNMÜYOR (04'te yalnızca kendi
  // sıran bir satır olarak geçiyor, yarışmanın kendisi değil).
  testWidgets('07 — k-lig sıralaması', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      builder: _bantli('07-klig-siralamasi'),
      home: Scaffold(
        body: LeaderboardModal(
          auth: _screenshotAuth(),
          stats: StatsRepo(_SahteStatsGateway()),
        ),
      ),
    ));
    await _settle(tester);

    await binding.takeScreenshot('07-klig-siralamasi');
  });
}

/// Skor kartının sahte ucu. Rakamlar UYDURMA ama TUTARLI: mağaza karesinde
/// gerçek bir hesabın istatistiği gösterilemez (Play turunun gizlilik
/// kuralı) ve boş bir kart da özelliği anlatmaz.
///
/// ⚠ **Sahte veri RAKİP BİR ÜRÜNÜN ADINI TAŞIYAMAZ.** `longest` bir dönem
/// `KELİMELİK` yazıyordu — Kelimelik rakip bir Türkçe kelime oyununun adı
/// ve kare onu "en uzun kelimem" diye mağaza vitrininde gösteriyordu
/// (kullanıcı yakaladı, 11 Eylül 2026; kareler henüz Console'a
/// yüklenmemişti). Gizlilik kuralının kardeşi bir kural: sahte veri
/// seçerken **gerçek bir kişi adı** kadar **başka bir markanın adı** da
/// elenir. Yerine `ÇALIŞKAN` — sözlükte var (`src/data/words.ts`) ve
/// 8 harf, yani rafın 7 taşı + bir çapayla kurallara uygun.
class _SahteStatsGateway implements StatsGateway {
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
    String longest = 'ÇALIŞKAN',
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

  /// 7. karenin k-lig listesi. İsimler UYDURMA — Play turunun yazılı
  /// gizlilik kuralı gerçek oyuncu adını/avatarını kareye sokmuyor — ve
  /// 03. karedeki adlarla AYNI kümeden seçildi, iki kare yan yana
  /// görüldüğünde tutarlı bir dünya anlatsın diye.
  ///
  /// ⚠ `avatar_url` HER SATIRDA null: dolu olsa `KAvatar` ağa çıkardı, bu
  /// iş akışının tüm önermesi ise *"ağa hiç çıkma"*. Null'da baş harfler
  /// çiziliyor, yani liste yine dolu görünüyor.
  ///
  /// ⚠ Oyuncunun kendi satırı **4.** sırada. Birinci olsaydı kare
  /// "yükselinecek bir yer" anlatmazdı; listenin dışında olsaydı vurgulu
  /// satır hiç görünmez, yerine alttaki kesikli "senin sıran" kısayolu
  /// çıkardı. Sayılar `myLeaderboardRank` ve `playerStats` ile TUTARLI
  /// (sıra 4, puan 57, OHP 21.40) — üç uç aynı karede yan yana okunuyor.
  static const List<(int, String, String, int, double)> _lig = [
    (1, 'u-esiner', 'Esiner', 76, 24.82),
    (2, 'u-kaptan', 'Kaptan', 68, 23.10),
    (3, 'u-zeynep', 'Zeynep', 61, 22.45),
    (4, 'u-kelimeki-store', _kPlayerName, 57, 21.40),
    (5, 'u-murekkep', 'Mürekkep', 54, 20.98),
    (6, 'u-harfci', 'Harfçi', 49, 20.11),
    (7, 'u-bilgehan', 'Bilgehan', 45, 19.76),
    (8, 'u-sozcuk', 'Sözcük', 40, 19.02),
    (9, 'u-anadolu', 'Anadolu', 38, 18.44),
    (10, 'u-deniz', 'Deniz', 33, 17.85),
  ];

  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async =>
      [
        for (final (sira, id, ad, puan, ohp) in _lig.skip(offset).take(limit))
          {
            'sira': sira,
            'user_id': id,
            'display_name': ad,
            'first_name': null,
            'avatar_url': null,
            'total_score': puan,
            'avg_move_score': ohp,
          }
      ];

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async =>
      const {'rank': 4, 'total_score': 57, 'avg_move_score': 21.40};

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
class _SahteSupabase implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

/// Setup ekranının servisleri. Ağ YOK; listeler sahte uçlardan geliyor ve
/// isimler UYDURMA — Play turunun yazılı kuralı: gerçek arkadaş adı/avatarı
/// kareye giremez. Burada sahtelik bir taviz değil, kuralın ta kendisi.
AppServices _setupServisleri() {
  const ben = 'u-kelimeki-store';
  Map<String, Object?> satir(String id, String rakipAd, String rakipId) =>
      gameRow(
        id: id,
        myId: ben,
        status: 'active',
        slots: [
          slotHuman(rakipId, name: rakipAd, relation: 'accepted'),
          slotHuman(ben, name: _kPlayerName, relation: 'self'),
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
    dictionary: Future.value(_words),
    meanings: MeaningStore(bundle: rootBundle),
    auth: _screenshotAuth(),
    supabase: _SahteSupabase(),
    versionGate: VersionGateStatus.ok,
    onlineGames: OnlineGamesRepo(og),
    friends: FriendsRepo(FakeFriendsGateway()),
  );
}
