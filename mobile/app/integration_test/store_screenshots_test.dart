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
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/dictionary_loader.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

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

late SetWordSource _words;

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
    final controller = GameController(
      words: _words,
      autoPlayAi: false, // kare sabit kalsın; YZ araya girip tahtayı değiştirmesin
      nowIso: () => '',
      rng: Mulberry32(_kSeed),
    );
    controller.dispatch(ResumeSavedAction(_midGameState()));

    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      // `storage` VERİLMİYOR: zoom tanıtım balonu yalnızca o varken çıkıyor
      // ve mağaza karesinde bir öğretici balonu istemiyoruz.
      home: GameScreen(
        controller: controller,
        words: _words,
        auth: AuthService.fake(),
      ),
    ));
    await _settle(tester);

    await binding.takeScreenshot('01-oyun-ekrani');
    controller.dispose();
  });
}
