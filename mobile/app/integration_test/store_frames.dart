// Mağaza karelerinin ORTAK kurulumu — fixture'lar, sahte uçlar, başlık
// şeridi ve ekran kurucuları.
//
// ⚠ **Neden ayrı bir dosya (11 Eylül 2026):** aynı kareleri İKİ yer üretiyor
// ve ikisinin AYNI şeyi çizmesi şart:
//   1. `store_screenshots_test.dart` — GERÇEK iOS simülatöründe, mağazaya
//      giden kare (`flutter drive`, CI).
//   2. `test/store_frames_preview_test.dart` — Linux'ta, saniyeler içinde
//      ÖNİZLEME. Kullanıcı isteği: *"Bu görselleri önce resim olarak yap
//      bana göster ondan sonra ok ise üretime gönderelim. Böyle kaç defa
//      git gel oldu."*
//
// Önizleme mağaza karesi DEĞİL (Skia ≠ Impeller, iOS kabuğu yok) ama
// KOMPOZİSYON sorularını cevaplıyor — ve bir CI turu beklemeden cevaplıyor.
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/board_widget.dart';
import 'package:kelimeki/src/ui/game/board_zoom.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/route_observer.dart';
import 'package:kelimeki/src/ui/setup/setup_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/ui/tokens.dart';
import 'package:kelimeki/src/util/online_status.dart';

// Sahte uçlar TEK KAYNAKTAN: widget testlerinin zaten kullandığı dosya.
// ⚠ `test/support/game_rows.dart` BİLEREK import edilmiyor — o dosya
// `sqflite_common_ffi` (masaüstü) çekiyor ve burası GERÇEK CİHAZDA koşuyor.
import '../test/support/fake_online_gateway.dart';
import 'package:kelimeki_core/kelimeki_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show SupabaseClient, User;

/// Tahtayı dolduran tohum ve hamle sayısı — Linux'ta motoru koşturarak
/// SEÇİLDİ (9 Eylül 2026), rastgele değil. Ölçülen sonuç: 43 taş, skor
/// 114–76 (çekişmeli, oyuncu önde), tahtada bir joker, merkezdeki X2/X3
/// bölgesi kullanılmış, ve oyuncunun rafı `KAOEMLE` — yani ekranda
/// gerçekten oynanabilir bir el duruyor ("KALEM"). Bir mağaza karesinde
/// oyuncunun ezildiği ya da rafın tamamen ünlü olduğu bir kare istemiyoruz;
/// taranan yedi tohumun içinde bu üçünü birden sağlayan tek aday buydu.
const int kSeed = 11;
const int kMoves = 12;

/// 2. karenin (4 KİŞİLİK oyun) tohumu ve hamle sayısı — bu da Linux'ta
/// motoru koşturarak SEÇİLDİ (11 Eylül 2026), 1. kareyle AYNI ölçütlerle:
/// dört bölgenin de büyümüş olması · oyuncunun EZİLMEMESİ · rafın
/// OYNANABİLİR olması · tahtanın dolu görünmesi · skorların çekişmeli
/// olması. 60 tohum × 2 hamle sayısı tarandı, beş aday geçti; bu seçildi.
///
/// Ölçülen sonuç: 71 taş, skorlar **72-68-61-77** (fark 16, çekişmeli),
/// bölgeler **30/24/24/27** (dördü de net okunuyor, oyuncununki en büyük),
/// raf `UAAKLŞI` — 4 ünlü + 3 sessiz, yani ekranda oynanabilir bir el var.
/// ⚠ Elenen aday `26`: skorlar 73-73-73-77'de eşitleniyordu ve karede
/// UYDURMA duruyordu.
const int kSeed4 = 12;
const int kMoves4 = 20;

/// Ekranda görünen ad. Gerçek bir kişinin adı ya da e-postası KARE'ye
/// giremez (Play turunun yazılı gizlilik kuralı).
///
/// ⚠ Bu ad bir dönem **`Ironman`**'di ve iki kuralı birden çiğniyordu
/// (kullanıcı kararı, 11 Eylül 2026): (1) *"Iron Man"* başkasının tescilli
/// markası — `KELİMELİK` vakasıyla AYNI sınıf, bkz. `SahteStatsGateway`;
/// (2) `Ironman` bu projede **gerçek bir hesabın** takma adı (`ROADMAP.md`:
/// *"hiçbir koşulda silinmez"*), yani gizlilik kuralının da kapsamında.
/// Yerine nötr bir ad. ⚠ `test/` altındaki birim testleri BİLEREK
/// dokunulmadı — onlar mağazaya gitmiyor.
const String kPlayerName = 'Ege';

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
const Map<String, String> kBasliklar = {
  '01-oyun-ekrani': 'Köşenden başla, bölgeni büyüt',
  '02-dort-kisilik': 'Dört oyuncu, dört bölge',
  '03-arkadasinla': 'Arkadaşınla sırayla oyna',
  '04-skor-karti': 'İstatistiklerini takip et',
  '06-nasil-oynanir': 'Kuralları üç dakikada öğren',
  '07-klig-siralamasi': "k-lig'de sıranı yükselt",
  '08-rutbeler': 'Rütbe atladıkça ödül kazan',
  '09-zoom': 'Çift dokunuşla tahtayı büyüt',
};

/// Punto ekran GENİŞLİĞİNE oranlı — sabit bir punto verilseydi iPad
/// karesinde yarı boyda kalırdı. iPhone 6.9" mantıksal 440 geniş (×3 =
/// 1320), iPad 13" 1032 (×2 = 2064).
const double kBantPuntoOran = 0.055;

/// ⚠ Yükseklik TAVANI — yalnızca genişliğe oranlamak yetmiyor (ölçüldü,
/// 11 Eylül 2026): iPad karesi iPhone'a göre çok daha geniş ama aynı oranda
/// uzun değil (1032×1376 ↔ 440×956), yani %5,5'lik punto şeridi iPad'de
/// yüksekliğin **%11,6**'sına çıkarıyordu. Tavanla ikisi de ~%7-9 bandında
/// kalıyor: iPhone 24,2 punto (şerit yüksekliğin %7,1'i) · iPad 44,0
/// (%8,9). Kare başına ölçüm: `kBasliklar`ın en uzunu bu puntoda
/// kullanılabilir genişliğin %90'ı (iPhone) / %71'i (iPad), yani hiçbir
/// başlık `scaleDown` ile küçülmüyor — hepsi tek satır.
const double kBantPuntoYukseklikTavani = 0.032;

/// Şerit yüksekliği = punto × bu. 2,8 tek satırlık başlığa üstten/alttan
/// yaklaşık birer satır boşluk bırakıyor; iPhone karesinde şerit, 01/02'de
/// zaten boş duran alt ~%20'nin içinde kalıyor.
const double kBantYukseklikCarpani = 2.8;

/// `MaterialApp.builder`a takılan sarmalayıcı. `builder` Navigator'ın ÜSTÜNÜ
/// sardığından pencereler de (05'in anlam penceresi) şeridin üstünde kalır —
/// her kare için ayrı bir düzen kurmaya gerek yok.
TransitionBuilder bantli(String kareAdi) {
  final baslik = kBasliklar[kareAdi];
  if (baslik == null) throw StateError('$kareAdi icin baslik tanimli degil');
  return (context, child) => BaslikSeridi(baslik: baslik, child: child!);
}

class BaslikSeridi extends StatelessWidget {
  const BaslikSeridi({super.key, required this.baslik, required this.child});

  final String baslik;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final olcu = MediaQuery.sizeOf(context);
    final genislik = olcu.width;
    final punto = (genislik * kBantPuntoOran)
        .clamp(0.0, olcu.height * kBantPuntoYukseklikTavani);
    return Stack(
      children: [
        Positioned.fill(child: child),
        // ⚠ ŞERİT UYGULAMANIN ÜSTÜNE BİNİYOR, ALTINA EKLENMİYOR
        // (kullanıcı kararı, 11 Eylül 2026). İlk uygulama `Column`du:
        // uygulama `Expanded`ta, şerit altında. Kullanıcı kareyi GÖZLE
        // inceleyince ortaya çıktı ki o düzen kararın gerekçesini
        // BOŞA ÇIKARIYOR — oyun ekranının alt boşluğu yerinde duruyor,
        // şerit onun ALTINA biniyordu, yani ölü alan değerlenmiyordu.
        // Bindirme o boşluğu gerçekten dolduruyor.
        //
        // ⚠ Bedeli: uygulamanın alt ~%7'sini ÖRTÜYOR. Oyun ekranında
        // (01/02) orası zaten boş; modal karelerinde (04/05/06) pencerenin
        // alt kenarına denk gelebilir — bu yüzden yeni bir kare eklendiğinde
        // ya da modal düzeni değiştiğinde kareye GÖZLE bakmak şart
        // (§13'ün "kareye bakan bir insan olmadan onaylanamaz" dersi).
        //
        // ⚠ `removePadding` ARTIK YOK: `Column`da uygulamanın alt güvenli
        // alan payı içerikle şerit arasında ölü bir bant bırakıyordu.
        // Bindirmede tersi geçerli — o pay içeriği şeridin altına
        // girmekten KORUYOR, yani kalması gerekiyor.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: bant(context, genislik, punto),
        ),
      ],
    );
  }

  Widget bant(BuildContext context, double genislik, double punto) {
    return Material(
      // Uygulamanın KENDİ vurgu mavisi (logo · OYNA · skor · k-lig markası)
      // — kullanıcı kararı, 11 Eylül 2026. Önceki zemin kText (koyu
      // lacivert) idi; mağaza galerisinde şerit artık uygulamayla aynı
      // rengi konuşuyor. Yazı beyaz kaldı.
      color: kAccent,
      child: SizedBox(
        width: double.infinity,
        height: punto * kBantYukseklikCarpani,
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
AuthService screenshotAuth() => AuthService.fake(
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
/// bırakır — 2. karenin konusu bu (yeşil dış hat + puan rozeti).
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
      isFirstMove(s), s.players, words, 40,
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
GameController oyunKontrolcusu({int oyuncu = 2}) {
  final controller = GameController(
    words: words,
    autoPlayAi:
        false, // kare sabit kalsın; YZ araya girip tahtayı değiştirmesin
    nowIso: () => '',
    rng: Mulberry32(oyuncu == 4 ? kSeed4 : kSeed),
  );
  controller.dispatch(ResumeSavedAction(midGameState(oyuncu: oyuncu)));
  return controller;
}

/// Sözlük — `setUpAll`te bir kez yüklenir (cihazda asset'ten, önizlemede
/// dosyadan).
late SetWordSource words;

/// Pencereler ÜRETİM yolundan (bir dialog olarak) açılıyor; o yollar bir
/// `BuildContext` istiyor.
final navKey = GlobalKey<NavigatorState>();

/// Kurulum ekranı — 3. karenin zemini.
///
/// ⚠ `navigatorObservers` ÜRETİMDEKİYLE AYNI olmak zorunda: Setup'ın "bir
/// ekrandan dönüldü" tazelemesi `RouteAware.didPopNext`ten geliyor.
Widget kurulumEkrani(String kareAdi) => MaterialApp(
      theme: kelimekiTheme(),
      debugShowCheckedModeBanner: false,
      builder: bantli(kareAdi),
      navigatorObservers: [kRouteObserver],
      // ⚠ Teşhis satırı KAPALI (kullanıcı isteği, 11 Eylül 2026): mağaza
      // vitrininde `Derleme … · Sürüm … · Sözlük 63905 kelime · depo ok`
      // okunacak bir bilgi değil ve karenin altını dolduruyordu. Satır
      // üretimde DURUYOR — bayrak yalnızca burada `false`.
      home: SetupScreen(services: setupServisleri(), showDiagnostics: false),
    );

/// Oyun ekranı — mağaza karelerinin ORTAK zemini.
///
/// ⚠ **`navigatorKey` ŞART:** modal kareleri (04/05/06/07) pencereyi ÜRETİM
/// yolundan (`showScoreCard`/`showMeaningModal`/`showHelpModal`/
/// `showLeaderboard`) açıyor ve o yollar bir `BuildContext` istiyor.
Widget oyunEkrani(GameController controller, String kareAdi) => MaterialApp(
      theme: kelimekiTheme(),
      debugShowCheckedModeBanner: false,
      builder: bantli(kareAdi),
      navigatorKey: navKey,
      // `storage` VERİLMİYOR: zoom tanıtım balonu yalnızca o varken çıkıyor
      // ve mağaza karesinde bir öğretici balonu istemiyoruz.
      home: GameScreen(
        controller: controller,
        words: words,
        auth: screenshotAuth(),
      ),
    );

GameState midGameState({int oyuncu = 2, int? tohum, int? hamle}) {
  assert(oyuncu == 2 || oyuncu == 4, 'oyun 2 ya da 4 kişilik');
  final engine = GameEngine(
    words: words,
    rng: Mulberry32(tohum ?? (oyuncu == 4 ? kSeed4 : kSeed)),
    nowIso: () => '',
  );
  var s = engine.reduce(
    createInitialState(),
    StartAction([
      for (var i = 0; i < oyuncu; i++) const PlayerSetup(name: '', isAI: true),
    ]),
  );
  final tavan = hamle ?? (oyuncu == 4 ? kMoves4 : kMoves);
  for (var i = 0; i < tavan && !s.isGameOver; i++) {
    s = engine.reduce(s, const AiPlayAction());
  }
  return s.copyWith(players: [
    s.players[0].copyWith(name: kPlayerName, isAI: false),
    ...s.players.skip(1),
  ]);
}

/// Kareyi diske yazar — ÖNCE debug bandının olmadığını İDDİA EDER.
///
/// NEDEN BİR İDDİA (11 Eylül 2026): `flutter drive` debug modda derliyor,
/// yani `MaterialApp` varsayılan olarak sağ üst köşeye kırmızı bir "DEBUG"
/// şeridi çiziyor. Yedi karenin yedisi de bu şeritle üretildi ve arıza
/// ancak KULLANICI artefaktı indirip PNG'ye baktığında görüldü — ne piksel
/// ölçümü, ne alfa kapısı, ne de kare sayımı bunu görebilirdi (üçü de
/// dosyanın ŞEKLİNE bakıyor, İÇERİĞİNE değil).
///
/// ⚠ Bu yüzden her kare TEK bu fonksiyondan geçiyor: yeni bir kare eklerken
/// `binding.takeScreenshot`i doğrudan çağırma, iddia atlanır.
Future<void> kareCek(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String ad,
) async {
  expect(
    find.byType(CheckedModeBanner),
    findsNothing,
    reason: '$ad: debug bandı açık — MaterialApp\'te '
        'debugShowCheckedModeBanner: false eksik. Mağaza karesine giremez.',
  );
  await binding.takeScreenshot(ad);
}

/// Açılan pencereyi EKRANDA GÖRÜNENE KADAR bekler ve göremezse DÜŞER.
///
/// NEDEN VAR (11 Eylül 2026 — dördüncü "şekil kapıları içeriği göremez"
/// vakası): iPad koşusunda 06. kare yardım penceresi AÇILMADAN çekildi ve
/// kare 01'in aynısı oldu. Dört kapı da (kare sayısı · piksel ölçüsü ·
/// alfa · debug bandı) yeşil kaldı, çünkü üçü de dosyanın ŞEKLİNE bakıyor;
/// arızayı ancak KULLANICI artefaktı indirip PNG'lere bakınca gördü. Aynı
/// tur iPhone'da sorunsuzdu, yani sabit sayıda `pump` cihazdan cihaza
/// güvenilir değil.
///
/// ⚠ `settle()`nin sabit üç `pump`ı YETMİYOR — burada pencere BULUNANA
/// kadar pump ediliyor, sonra oturması için birkaç kare daha. Bulunamazsa
/// `expect` düşer: kare artık SESSİZCE yanlış çıkamaz, koşu kırmızıya döner.
Future<void> pencereyiBekle(
  WidgetTester tester,
  Finder pencere,
  String ad, {
  Duration tavan = const Duration(seconds: 10),
}) async {
  final adim = const Duration(milliseconds: 100);
  var gecen = Duration.zero;
  while (gecen < tavan) {
    await tester.pump(adim);
    gecen += adim;
    if (pencere.evaluate().isNotEmpty) break;
  }
  expect(
    pencere,
    findsOneWidget,
    reason: '$ad: pencere ${tavan.inSeconds} sn içinde ekrana gelmedi — '
        'kare arka plandaki ekranın kopyası olurdu. Mağaza karesine giremez.',
  );
  // Açılış animasyonu (fade/scale) bitsin: bulunmak ≠ tam opak çizilmek.
  await settle(tester);
}

/// Tahtanın GERÇEKTEN yakınlaştığını doğrular — 09. karenin kapısı.
///
/// NEDEN VAR: 09 bir JESTİN sonucunu gösteriyor (boş çerçeveye çift
/// dokunuş). Jest tutmazsa kare sessizce 01'in aynısı olur — yani tam
/// olarak iPad'de 06'nın başına gelen şey. `pencereyiBekle` bir pencere
/// arıyor, burada aranacak pencere YOK; onun yerine zoom matrisinin
/// ölçeği okunuyor.
///
/// ⚠ Zoom kapalıyken `BoardWidget` matrisi `null` geçiyor ve o `Transform`
/// hiç kurulmuyor (`board_widget.dart` → `katmanla`), yani "2.0 ölçekli bir
/// Transform var mı" sorusu zoom'un açık olmasıyla birebir örtüşüyor.
void zoomKapisi(WidgetTester tester, String ad) {
  final olcekler = tester
      .widgetList<Transform>(find.descendant(
        of: find.byType(BoardWidget),
        matching: find.byType(Transform),
      ))
      .map((t) => t.transform.getMaxScaleOnAxis())
      .toList();
  expect(
    olcekler.any((o) => (o - kBoardZoomScale).abs() < 0.01),
    isTrue,
    reason: '$ad: tahta yakınlaşmamış (bulunan ölçekler: $olcekler) — '
        'çift dokunuş çifte sayılmadı ve kare 01\'in kopyası olurdu. '
        'Mağaza karesine giremez.',
  );
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
///
/// ⚠ **Sahte veri RAKİP BİR ÜRÜNÜN ADINI TAŞIYAMAZ.** `longest` bir dönem
/// `KELİMELİK` yazıyordu — Kelimelik rakip bir Türkçe kelime oyununun adı
/// ve kare onu "en uzun kelimem" diye mağaza vitrininde gösteriyordu
/// (kullanıcı yakaladı, 11 Eylül 2026; kareler henüz Console'a
/// yüklenmemişti). Gizlilik kuralının kardeşi bir kural: sahte veri
/// seçerken **gerçek bir kişi adı** kadar **başka bir markanın adı** da
/// elenir. Yerine `ÇALIŞKAN` — sözlükte var (`src/data/words.ts`) ve
/// 8 harf, yani rafın 7 taşı + bir çapayla kurallara uygun.
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
  Future<Map<String, Object?>?> playerStats(
          String userId, int? playerCount) async =>
      switch (playerCount) {
        null => _satir(),
        2 => _satir(games: 26, local: 15, online: 11, first: 15, total: 44),
        _ =>
          _satir(games: 8, local: 6, online: 2, first: 4, second: 3, total: 13),
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
    (4, 'u-kelimeki-store', kPlayerName, 57, 21.40),
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
  Future<List<Map<String, Object?>>> rankScores(List<String> userIds) async =>
      const [];

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
  // YEDİ oyun, İKİ farklı sıra durumu: **4 "SIRA SENDE" (yeşil) + 3 "SIRA
  // RAKİPTE" (kırmızı)** — kullanıcı kararı, 11 Eylül 2026. Önce üç satırdı
  // ve karenin alt ~%30'u boş kalıyordu; liste uzayınca hem ölü alan
  // kapandı hem de ekranın asıl vaadi ("aynı anda birden çok arkadaşınla,
  // sırayla") tek bakışta okunuyor.
  // ⚠ İsimler UYDURMA ve k-lig karesindeki (`_lig`) listeyle AYNI kadro —
  // iki kare yan yana görüldüğünde aynı dünyayı anlatsın diye.
  // ⚠ `current` = SIRASI GELEN koltuğun indisi; `ben` 1. koltukta, yani
  // 1 → "SIRA SENDE", 0 → "SIRA RAKİPTE".
  final og = FakeOnlineGamesGateway()
    ..rows = [
      satir('g1', 'Esiner', 'u-esiner'),
      satir('g2', 'Kaptan', 'u-kaptan'),
      satir('g3', 'Zeynep', 'u-zeynep'),
      satir('g4', 'Mürekkep', 'u-murekkep'),
      satir('g5', 'Harfçi', 'u-harfci'),
      satir('g6', 'Bilgehan', 'u-bilgehan'),
      satir('g7', 'Sözcük', 'u-sozcuk'),
    ]
    ..turnRows = [
      {'online_game_id': 'g1', 'current': 1},
      {'online_game_id': 'g2', 'current': 1},
      {'online_game_id': 'g3', 'current': 1},
      {'online_game_id': 'g4', 'current': 1},
      {'online_game_id': 'g5', 'current': 0},
      {'online_game_id': 'g6', 'current': 0},
      {'online_game_id': 'g7', 'current': 0},
    ];
  return AppServices(
    onlineStatus: OnlineStatus.fake(),
    dictionary: Future.value(words),
    meanings: MeaningStore(bundle: rootBundle),
    auth: screenshotAuth(),
    supabase: SahteSupabase(),
    versionGate: VersionGateStatus.ok,
    onlineGames: OnlineGamesRepo(og),
    friends: FriendsRepo(FakeFriendsGateway()),
  );
}
