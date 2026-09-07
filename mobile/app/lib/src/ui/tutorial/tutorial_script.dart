// "Oynayarak öğren" tanıtımının senaryosu — web `src/utils/tutorialScript.ts`
// portu (Onboarding Faz 4, 7 Eylül 2026). WEB TEK DOĞRULUK KAYNAĞI:
// sahneler, metinler, koordinatlar, puanlar ve torba sırası oradan birebir
// kopyalanır; `tutorial_parity_test.dart` bu dosyayı web kaynağına karşı
// kilitler (bir metin/sayı ayrışırsa test düşer), `tutorial_script_test.dart`
// ise senaryoyu GERÇEK Dart motorunda oynatır (web'in
// `verify-tutorial-script`inin karşılığı — ekranda puan yazıyor, kural
// değişince metin sessizce bayatlamasın).
//
// ⚠ TASARIM KISITI — MOTOR DEĞİŞMEZ (kök CLAUDE.md, "İlk Oyun: Tanıtım
// Ekranı", kural 1): tanıtım `kelimeki_core`un kendi reducer'ıyla oynanır,
// ama yeni bir `GameAction` ya da yeni bir `GameState` alanı EKLENMEDEN.
// Başlangıç durumu `StartAction`dan geçmeden DOĞRUDAN kurulur (o action
// torbayı karıştırır); ekran onu `GameController.restore` ile yükler.
import 'package:kelimeki_core/kelimeki_core.dart';

/// Tanıtımdaki rakibin adı — ekranda ve mesajlarda geçer.
const String tutorialOpponentName = 'Rakip';

/// Girişsiz oyuncu için tanıtımda kullanılan ad.
const String tutorialPlayerName = 'Sen';

/// Tek bir taşın konacağı yer. Harf İNDEKS DEĞİL — raf her hamlede kayıyor.
class TutorialPlacement {
  final int r;
  final int c;
  final String letter;
  const TutorialPlacement(this.r, this.c, this.letter);
}

/// Bir hamle (oyuncunun ya da rakibin). Alanların anlamı web ile aynı:
/// `points` çarpan uygulanmış VERGİ DÜŞÜLMÜŞ kazanç, `tax` karşı tarafa
/// geçen pay, `bonus` beklenen çarpan (yoksa hiçbir kelime çarpan almamalı),
/// `raw` yalnızca ekranda "6 × 2 = 12" yazan TEK kelimeli hamlelerde dolu.
class TutorialMove {
  final String word;
  final List<TutorialPlacement> cells;
  final int points;
  final int tax;
  final String? bonus; // 'x2' | 'x3' | null
  final int? raw;
  const TutorialMove({
    required this.word,
    required this.cells,
    required this.points,
    required this.tax,
    this.bonus,
    this.raw,
  });
}

/// Rakibin cevabı — hamle + tanıtımın mesaj şeridinde yazan not.
class TutorialReply extends TutorialMove {
  final String note;
  const TutorialReply({
    required super.word,
    required super.cells,
    required super.points,
    required super.tax,
    super.bonus,
    super.raw,
    required this.note,
  });
}

/// Balonun işaret ettiği kare ve yönü: `ust` = balon karenin ÜSTÜNDE
/// (kuyruk aşağı), `alt` = ALTINDA (kuyruk yukarı). Balon çapanın 1-2
/// satır üstünü/altını KAPATIR; hangi sahnenin hangi yönü kullandığı
/// senaryoda yazılı ve `tutorial_script_test` örtüşmeyi kontrol eder.
class TutorialBubble {
  final int r;
  final int c;
  final String yon; // 'ust' | 'alt'
  const TutorialBubble(this.r, this.c, this.yon);
}

/// Bir sahne: oyuncunun hamlesi + rakibin cevabı.
class TutorialStep {
  final String id;
  final String say;
  final TutorialBubble bubble;
  final TutorialMove move;
  final String done;
  final TutorialReply reply;
  const TutorialStep({
    required this.id,
    required this.say,
    required this.bubble,
    required this.move,
    required this.done,
    required this.reply,
  });
}

/// Sahneler — sıra kullanıcı kararı: ev → sınır → MERKEZ → rakip teması.
/// Her hamleden sonra rakip GERÇEKTEN oynar (aynı reducer, kendi rafından).
/// Gerekçeler web kaynağında (`tutorialScript.ts`), burada tekrar edilmiyor.
const List<TutorialStep> tutorialSteps = [
  TutorialStep(
    id: 'ev',
    say: 'Kendi köşenden başla.',
    bubble: TutorialBubble(0, 1, 'alt'),
    move: TutorialMove(
      word: 'BÜYÜ',
      cells: [
        TutorialPlacement(0, 0, 'B'),
        TutorialPlacement(0, 1, 'Ü'),
        TutorialPlacement(0, 2, 'Y'),
        TutorialPlacement(0, 3, 'Ü'),
      ],
      points: 12,
      tax: 0,
    ),
    done: 'İlk kelimen: +12 puan.',
    reply: TutorialReply(
      word: 'KUYU',
      cells: [
        TutorialPlacement(9, 12, 'K'),
        TutorialPlacement(10, 12, 'U'),
        TutorialPlacement(11, 12, 'Y'),
        TutorialPlacement(12, 12, 'U'),
      ],
      points: 8,
      tax: 0,
      note: 'Rakip de kendi ev karesinden başladı: +8.',
    ),
  ),
  TutorialStep(
    id: 'buyume',
    say: 'Kelime kurdukça sınırın büyür.',
    bubble: TutorialBubble(5, 3, 'alt'),
    move: TutorialMove(
      word: 'ÜZENGİ',
      cells: [
        TutorialPlacement(1, 3, 'Z'),
        TutorialPlacement(2, 3, 'E'),
        TutorialPlacement(3, 3, 'N'),
        TutorialPlacement(4, 3, 'G'),
        TutorialPlacement(5, 3, 'İ'),
      ],
      points: 15,
      tax: 0,
    ),
    done: '+15 puan — sınırın köşenin dışına taştı.',
    reply: TutorialReply(
      word: 'TABAK',
      cells: [
        TutorialPlacement(9, 8, 'T'),
        TutorialPlacement(9, 9, 'A'),
        TutorialPlacement(9, 10, 'B'),
        TutorialPlacement(9, 11, 'A'),
      ],
      points: 7,
      tax: 0,
      note: 'Rakip merkeze doğru ilerliyor: +7.',
    ),
  ),
  TutorialStep(
    id: 'merkez',
    say: 'Sarı bölge içinde kelime puanının 2 katını alırsın',
    bubble: TutorialBubble(5, 4, 'ust'),
    move: TutorialMove(
      word: 'İNSAN',
      cells: [
        TutorialPlacement(5, 4, 'N'),
        TutorialPlacement(5, 5, 'S'),
        TutorialPlacement(5, 6, 'A'),
        TutorialPlacement(5, 7, 'N'),
      ],
      points: 12,
      bonus: 'x2',
      raw: 6,
      tax: 0,
    ),
    done: '6 × 2 = 12 puan!',
    reply: TutorialReply(
      word: 'SAAT',
      cells: [
        TutorialPlacement(6, 8, 'S'),
        TutorialPlacement(7, 8, 'A'),
        TutorialPlacement(8, 8, 'A'),
      ],
      points: 10,
      bonus: 'x2',
      raw: 5,
      tax: 0,
      note: 'Rakip de merkeze girdi ve o da ikiye katladı: +10.',
    ),
  ),
  TutorialStep(
    id: 'x3vergi',
    say: 'Ortadaki kare üç katı!',
    bubble: TutorialBubble(6, 6, 'ust'),
    move: TutorialMove(
      word: 'FES',
      cells: [
        TutorialPlacement(6, 6, 'F'),
        TutorialPlacement(6, 7, 'E'),
      ],
      points: 39,
      bonus: 'x3',
      tax: 19,
    ),
    done: '58 puanın 19’u rakibe gitti: +39.',
    reply: TutorialReply(
      word: 'NAR',
      cells: [
        TutorialPlacement(6, 4, 'A'),
        TutorialPlacement(7, 4, 'R'),
      ],
      points: 4,
      bonus: 'x2',
      raw: 3,
      tax: 2,
      note: 'Şimdi tersi oldu: rakip senin sınırına değdi, 2 puanı sana geçti.',
    ),
  ),
];

/// Kapanış kartı (metin kullanıcı kararı, 7 Eylül 2026).
const String tutorialFinishTitle = 'Hazırsın!';
const String tutorialFinishText =
    'Koyduğun kelime kadar nereye koyduğun da çok önemli. Hem bölgeni '
    'büyüterek daha çok vergi topla, hem de rakibin hareket alanını '
    'daraltarak büyümesini engelle.';

/// Rafların TAM olarak hangi sırayla dolacağı — "çekilme sırası".
/// `drawTiles` torbanın SONUNDAN çeker (`removeLast`, web `pop`), bu yüzden
/// torba kurulurken tersine çevrilir (aşağıda, `createTutorialState`).
///
/// Sıra (çeken → adet): Sen 4, Rakip 4, Sen 5, Rakip 4, Sen 4, Rakip 3.
const List<String> tutorialDrawOrder = [
  // Sen — ÜZENGİ'nin G ve İ'si (Z, E, N zaten rafta) + iki dolgu
  'G', 'İ', 'A', 'T',
  // Rakip — TABAK'ın ikinci A'sı + üç dolgu
  'A', 'E', 'L', 'M',
  // Sen — İNSAN'ın N, S, A, N'ı + bir dolgu
  'N', 'S', 'A', 'N', 'K',
  // Rakip — SAAT'in S, A, A'sı + bir dolgu
  'S', 'A', 'A', 'R',
  // Sen — FES'in F ve E'si + iki dolgu (F torbadaki TEK F)
  'F', 'E', 'M', 'R',
  // Rakip — NAR'ın A'sı (R rafta) + iki dolgu
  'A', 'K', 'L',
];

/// Torbanın DİBİNDE bekleyen, hiç çekilmeyen taşlar — boş torba + boşalan
/// raf `endGame`i tetiklerdi; tanıtım oyunun sonuna gelmeden bitmeli.
const List<String> tutorialBagFiller = [
  'E', 'L', 'M', 'R', 'T', 'K', 'A', 'N', 'O', 'S',
];

/// Başlangıç rafları — senaryodaki ilk hamlelerin harfleri.
const List<List<String>> tutorialStartRacks = [
  ['B', 'Ü', 'Y', 'Ü', 'Z', 'E', 'N'],
  ['K', 'U', 'Y', 'U', 'T', 'A', 'B'],
];

/// Raf en fazla bu kadar taş taşır — senaryo testi sağlamasını yapar.
const int tutorialRackSize = rackSize;

Tile _tile(String letter) =>
    Tile(letter: letter, pts: tileData[letter]?.pts ?? 0);

/// Tanıtımın başlangıç durumu — reducer'ın `startGame`inin senaryolu
/// eşdeğeri: aynı alanlar, ama torba ve raflar RASTGELE DEĞİL. Rakip
/// `isAI` DEĞİL: bayrak yalnızca "YZ araması bu koltuğu oynasın" demek
/// olurdu ve tanıtımda arama yok — hamleleri senaryoda yazılı
/// (`GameController(autoPlayAi: false)` ayrıca güvence).
GameState createTutorialState(String playerName) {
  final corners = cornersFor(2);
  final names = [
    playerName.trim().isEmpty ? tutorialPlayerName : playerName.trim(),
    tutorialOpponentName,
  ];
  final players = [
    for (var i = 0; i < names.length; i++)
      Player(
        name: names[i],
        corners: corners[i],
        colorIndex: i % playerColorCount,
        isAI: false,
        surrendered: false,
        rack: [for (final l in tutorialStartRacks[i]) _tile(l)],
        score: 0,
        bestMoveScore: 0,
        bestWordScore: 0,
        longestWord: '',
        moveCount: 0,
        moveScoreSum: 0,
      ),
  ];
  return GameState(
    phase: GamePhase.play,
    startedAt: DateTime.now().toUtc().toIso8601String(),
    multiSession: false,
    endReason: EndReason.normal,
    board: createEmptyBoard(),
    // Çekilme sırası tersine: `drawTiles` sondan çeker.
    bag: [
      for (final l in tutorialBagFiller) _tile(l),
      for (final l in tutorialDrawOrder.reversed) _tile(l),
    ],
    bonuses: buildInitialBonuses(),
    placed: const {},
    players: players,
    current: 0,
    selectedTile: null,
    swapMode: false,
    swapSelection: const [],
    turnCount: 0,
    consecutivePasses: 0,
    isGameOver: false,
    message: '',
    messageType: MessageKind.none,
    lastMoveCells: const [],
    moveHistory: const [],
  );
}
