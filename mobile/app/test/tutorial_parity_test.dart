// "Oynayarak öğren" tanıtımı — web ↔ port paritesi (Onboarding Faz 4).
//
// NEDEN VAR: senaryo (dört sahnenin koordinatları, harfleri, puanları),
// balon/mesaj metinleri, kapanış kartı, torba sırası, kapı tarihi ve rakip
// animasyonunun süreleri web'de `src/utils/tutorialScript.ts` +
// `TutorialGame.tsx` + `utils/onboarding.ts`te, portta
// `ui/tutorial/tutorial_script.dart` + `tutorial_game.dart` +
// `util/onboarding.dart`ta ELLE senkron duruyor — derleyici görmez. Web
// tek doğruluk kaynağı: bir metin/sayı orada değişip burada unutulursa
// BU TEST düşer. Desen `ai_level_parity_test.dart` / `web_source.dart`:
// aranan şey bulunamazsa test DÜŞER, sessizce yeşil kalmaz.
//
// ⚠ Bu test `mobile/` DIŞINDAN dosya okuyor — `web-ci.yml`in `paths`
// listesinde `src/**` zaten var (kök CLAUDE.md, "Web CI mobil testleri de
// koşuyor").
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/tutorial/tutorial_game.dart';
import 'package:kelimeki/src/ui/tutorial/tutorial_script.dart';
import 'package:kelimeki/src/util/onboarding.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trUpper;

import 'support/web_source.dart';

/// Satır yorumları atılmış web kaynağı — yorumlar `points`/`raw` gibi
/// alan adlarını ve kesme işaretlerini içerebiliyor, ayrıştırıcı onları
/// görmemeli. (Dize içinde `//` geçen bir metin yok; olursa bu satır önce
/// güncellenmeli.)
String _stripComments(String src) => src.replaceAll(RegExp(r'//[^\n]*'), '');

List<(int, int, String)> _cells(String block) => [
      for (final m in RegExp(r"\{\s*r:\s*(\d+),\s*c:\s*(\d+),\s*letter:\s*'([^']+)'\s*\}")
          .allMatches(block))
        (int.parse(m.group(1)!), int.parse(m.group(2)!), m.group(3)!)
    ];

String? _opt(String block, RegExp re) => re.firstMatch(block)?.group(1);

void main() {
  final scriptTs = _stripComments(readRepoFile('src/utils/tutorialScript.ts'));
  final gameTsx = readRepoFile('src/components/TutorialGame.tsx');
  final onboardingTs = readRepoFile('src/utils/onboarding.ts');

  test('dört sahne: id · say · bubble · hamle · done · rakip cevabı birebir', () {
    final arr = scriptTs.substring(
        scriptTs.indexOf('TUTORIAL_STEPS: TutorialStep[] = ['),
        scriptTs.indexOf('export const TUTORIAL_FINISH_TITLE'));
    final parts = arr.split(RegExp(r"\{\s*id:\s*'")).skip(1).toList();
    expect(parts.length, tutorialSteps.length,
        reason: 'web sahne sayısı port ile farklı');

    for (var i = 0; i < parts.length; i++) {
      final p = parts[i];
      final step = tutorialSteps[i];
      final id = p.substring(0, p.indexOf("'"));
      expect(step.id, id, reason: 'sahne $i id');
      expect(step.say, pick(p, RegExp(r"say:\s*'([^']*)'"), '$id say'));
      expect(
          [step.bubble.r, step.bubble.c, step.bubble.yon],
          [
            int.parse(pick(p, RegExp(r'bubble:\s*\{\s*r:\s*(\d+)'), '$id bubble r')),
            int.parse(pick(p, RegExp(r'bubble:\s*\{\s*r:\s*\d+,\s*c:\s*(\d+)'),
                '$id bubble c')),
            pick(p, RegExp(r"yon:\s*'(\w+)'"), '$id bubble yon'),
          ],
          reason: '$id balon çapası/yönü');
      expect(step.done, pick(p, RegExp(r"done:\s*'([^']*)'"), '$id done'));

      final moveBlock = p.substring(p.indexOf('move: {'), p.indexOf('done:'));
      final replyBlock = p.substring(p.indexOf('reply: {'));
      for (final (ad, block, move) in [
        ('hamle', moveBlock, step.move),
        ('rakip', replyBlock, step.reply),
      ]) {
        expect(move.word, pick(block, RegExp(r"word:\s*'([^']+)'"), '$id $ad word'));
        expect([for (final c in move.cells) (c.r, c.c, c.letter)], _cells(block),
            reason: '$id $ad taşlar');
        expect(move.points,
            int.parse(pick(block, RegExp(r'points:\s*(\d+)'), '$id $ad points')));
        expect(move.tax, int.parse(pick(block, RegExp(r'tax:\s*(\d+)'), '$id $ad tax')));
        expect(move.bonus, _opt(block, RegExp(r"bonus:\s*'(x\d)'")),
            reason: '$id $ad bonus');
        final raw = _opt(block, RegExp(r'raw:\s*(\d+)'));
        expect(move.raw, raw == null ? null : int.parse(raw), reason: '$id $ad raw');
      }
      expect(step.reply.note,
          pick(replyBlock, RegExp(r"note:\s*'([^']*)'"), '$id rakip note'));
    }
  });

  test('kapanış kartı, adlar, torba sırası ve başlangıç rafları birebir', () {
    expect(tutorialFinishTitle,
        pick(scriptTs, RegExp(r"TUTORIAL_FINISH_TITLE = '([^']*)'"), 'FINISH_TITLE'));
    final textStmt = pick(
        scriptTs,
        RegExp(r'TUTORIAL_FINISH_TEXT =([\s\S]*?);', multiLine: true),
        'FINISH_TEXT');
    expect(tutorialFinishText,
        RegExp(r"'([^']*)'").allMatches(textStmt).map((m) => m.group(1)!).join());
    expect(tutorialOpponentName,
        pick(scriptTs, RegExp(r"TUTORIAL_OPPONENT_NAME = '([^']*)'"), 'OPPONENT'));
    expect(tutorialPlayerName,
        pick(scriptTs, RegExp(r"TUTORIAL_PLAYER_NAME = '([^']*)'"), 'PLAYER'));

    List<String> letters(String name) {
      final block = pick(scriptTs,
          RegExp('const $name: string\\[\\] = \\[([\\s\\S]*?)\\];'), name);
      return pickAll(block, RegExp(r"'([^']+)'"), '$name harfleri');
    }

    expect(tutorialDrawOrder, letters('DRAW_ORDER'));
    expect(tutorialBagFiller, letters('BAG_FILLER'));
    final racks = pick(scriptTs,
        RegExp(r'const START_RACKS: string\[\]\[\] = \[([\s\S]*?)\];'), 'START_RACKS');
    final webRacks = [
      for (final m in RegExp(r'\[([^\[\]]+)\]').allMatches(racks))
        pickAll(m.group(1)!, RegExp(r"'([^']+)'"), 'START_RACKS satırı')
    ];
    expect(tutorialStartRacks, webRacks);
  });

  test('karşılama penceresi: başlık · metin · buton birebir', () {
    expect(tutorialIntroTitle,
        pick(scriptTs, RegExp(r"TUTORIAL_INTRO_TITLE = '([^']*)'"), 'INTRO_TITLE'));
    final textStmt = pick(
        scriptTs,
        RegExp(r'TUTORIAL_INTRO_TEXT =([\s\S]*?);', multiLine: true),
        'INTRO_TEXT');
    expect(tutorialIntroText,
        RegExp(r"'([^']*)'").allMatches(textStmt).map((m) => m.group(1)!).join());
    expect(tutorialIntroButton,
        pick(scriptTs, RegExp(r"TUTORIAL_INTRO_BUTTON = '([^']*)'"), 'INTRO_BUTTON'));
    // Pencere GERÇEKTEN çiziliyor mu (sabit tanımlanıp kullanılmamış olmasın).
    expect(gameTsx.contains('TUTORIAL_INTRO_TITLE'), isTrue);
    expect(gameTsx.contains('TUTORIAL_INTRO_BUTTON'), isTrue);
  });

  test('balon tipografisi: punto ve genişlik kapağı iki tarafta AYNI', () {
    // 7 Eylül 2026 akşamı, kullanıcı: *"Balon fontlarını da biraz
    // büyütelim. Tek satır uzun olanları 2 satıra bölelim."* İkisi BİRLİKTE
    // ayarlanır: kapak daraltılmasa büyüyen punto balonu uzatır, punto
    // büyütülmese kapak cümleyi gereksiz kırar. Bu test ikisinin de iki
    // platformda aynı sayı olduğunu kilitler.
    final boardTsx = readRepoFile('src/components/Board.tsx');
    final dartBoard =
        readRepoFile('mobile/app/lib/src/ui/game/board_widget.dart');
    final dartTutorial =
        readRepoFile('mobile/app/lib/src/ui/tutorial/tutorial_game.dart');

    // Web `clamp(min, Nvw, max)` ↔ Dart `fluidSize(w, min, 0, N, max)`.
    // `pick` tek grup döndürdüğünden üç sayı ayrı ayrı okunuyor; eşleşme
    // yoksa test DÜŞER (web'in stili yeniden yazıldıysa ayrıştırıcı da
    // güncellenmeli — sessizce yeşil kalmasın).
    String clampParcasi(String src, int grup, String ne) {
      final m = RegExp(r"fontSize: 'clamp\((\d+)px, ([\d.]+)vw, (\d+)px\)'")
          .firstMatch(src);
      expect(m, isNotNull, reason: '$ne bulunamadı — ayrıştırıcıyı güncelle');
      return m!.group(grup)!;
    }

    for (final (webSrc, dartSrc, ad) in [
      (boardTsx.substring(boardTsx.indexOf('data-coach')), dartBoard,
          'tahta balonu'),
      (gameTsx.substring(gameTsx.indexOf('function Balon')), dartTutorial,
          'raf balonu'),
    ]) {
      final min = clampParcasi(webSrc, 1, '$ad web punto min');
      final vw = clampParcasi(webSrc, 2, '$ad web punto vw');
      final max = clampParcasi(webSrc, 3, '$ad web punto max');
      expect(
          dartSrc.contains('fluidSize(screenWidth, $min, 0, $vw, $max)'), isTrue,
          reason: '$ad puntosu ayrıştı: web clamp($min, ${vw}vw, $max), '
              'port `fluidSize(screenWidth, $min, 0, $vw, $max)` yazmıyor');
    }

    // Genişlik kapakları: web yüzde/vw, port oran.
    expect(
        pick(boardTsx.substring(boardTsx.indexOf('data-coach')),
            RegExp(r"maxWidth: '(\d+)%'"), 'tahta balonu web genişlik kapağı'),
        '72');
    expect(dartBoard.contains('maxWidthFactor: 0.72'), isTrue,
        reason: 'tahta balonunun genişlik kapağı ayrıştı (web %72)');
    expect(
        pick(gameTsx.substring(gameTsx.indexOf('function Balon')),
            RegExp(r"maxWidth: '(\d+)vw'"), 'raf balonu web genişlik kapağı'),
        '58');
    expect(dartTutorial.contains('screenWidth * 0.58'), isTrue,
        reason: 'raf balonunun genişlik kapağı ayrıştı (web 58vw)');

    // ÜÇ BALON TEK ÖLÇÜDE (7 Eylül 2026 akşamı, kullanıcı: *"zoom mesaj
    // fontunu da diğer balonlar kadar büyüt. Buradan başla balon yazısını da
    // aynı şekilde."*): tanıtım balonu · zoom ipucu · "Buradan başla".
    // `Board.tsx`teki HER balon puntosu aynı clamp olmalı; biri unutulursa
    // ekranda gözle fark edilir ama hiçbir test yakalamazdı.
    // Filigranlar (köşe numarası, X2) da `clamp` kullanıyor ama onlar balon
    // DEĞİL — 80/32vw/220 gibi dev değerler. Balonları tabanına göre ayırıyoruz.
    final boardClamps = RegExp(r"fontSize: 'clamp\((\d+)px, ([\d.]+)vw, (\d+)px\)'")
        .allMatches(boardTsx)
        .where((m) => int.parse(m.group(1)!) <= 20)
        .map((m) => '${m.group(1)}/${m.group(2)}/${m.group(3)}')
        .toList();
    expect(boardClamps.length, 3,
        reason: 'Board.tsx uc balon puntosu tasimali (tanitim, zoom, '
            '"Buradan basla"); sayi degistiyse bu testi de guncelle');
    expect(boardClamps.toSet(), {'11/3.2/16'},
        reason: 'üç balonun puntosu AYNI olmalı, ayrışmış: $boardClamps');
    expect(
        RegExp(r'fluidSize\(screenWidth, 11, 0, 3\.2, 16\)')
            .allMatches(dartBoard)
            .length,
        2,
        reason: 'port tarafında iki balon (ortak `_coachBubble` + '
            '"Buradan başla") aynı puntoyu kullanmalı');
    expect(dartBoard.contains('fluidSize(screenWidth, 9, 0, 2.4, 13)'), isFalse,
        reason: 'eski (küçük) balon puntosu portta kalmış');
  });

  test('ekran: süreler ve balon/mesaj metinleri TutorialGame.tsx ile birebir', () {
    expect(kTutorialRakipTasArasi,
        int.parse(pick(gameTsx, RegExp(r'RAKIP_TAS_ARASI = (\d+);'), 'RAKIP_TAS_ARASI')));
    expect(kTutorialSonucOkuma,
        int.parse(pick(gameTsx, RegExp(r'SONUC_OKUMA = (\d+);'), 'SONUC_OKUMA')));
    expect(kTutorialRakipOkuma,
        int.parse(pick(gameTsx, RegExp(r'RAKIP_OKUMA = (\d+);'), 'RAKIP_OKUMA')));

    expect(kTutorialRakipYaptiText,
        pick(gameTsx, RegExp(r"text: '(Rakip hamlesini[^']*)'"), 'rakip balonu'));
    expect(kTutorialRakipOynuyorText,
        pick(gameTsx, RegExp(r"\? '(Rakip oynuyor[^']*)'"), 'rakip oynuyor'));
    expect(kTutorialHarfiAlText,
        pick(gameTsx, RegExp(r"\? '(Harfi raftan al[^']*)'"), 'harfi al'));
    // Şablon dizesi: `Şimdi ${step.move.word} kelimesini taşı`
    final tasi = pick(gameTsx, RegExp(r'text=\{`([^`]*)`\}'), 'taşı balonu');
    expect(kTutorialTasiBalonuText('BÜYÜ'),
        tasi.replaceAll(r'${step.move.word}', 'BÜYÜ'));
    expect(kTutorialOynaBalonuText,
        pick(gameTsx, RegExp(r'text="(Hamleni tamamlamak[^"]*)"'), 'OYNA balonu'));
    expect(kTutorialInvasionNote,
        pick(gameTsx, RegExp(r'>\s*(Rakibin bölgesine girmen[^<]*?)\s*<'),
            'vergi penceresi notu'));
    // Kapanış butonu: web `uppercase` sınıfıyla büyütüyor, port etiketi
    // büyük harfle yazıyor — Türkçe büyütmeyle aynı olmalı.
    final btn = pick(gameTsx, RegExp(r'>\s*(Gerçek oyuna başla)\s*<'), 'kapanış butonu');
    expect(trUpper(btn), 'GERÇEK OYUNA BAŞLA');
    // Sahne sayacı ve Atla
    expect(gameTsx.contains('TANITIM · '), isTrue);
    expect(gameTsx.contains('ATLA →'), isTrue);
  });

  test('kapı tarihi: TUTORIAL_LAUNCH_AT port için yeniden tarihlenmedi', () {
    expect(tutorialLaunchAt,
        pick(onboardingTs, RegExp(r"TUTORIAL_LAUNCH_AT = '([^']+)'"), 'LAUNCH_AT'),
        reason: 'anlamı "web yayınından önce hesap açan = mevcut oyuncu"; '
            'ayrı bir tarih iki platformun farklı kişilere göstermesi demek');
    // Dört sinyal de web arayüzünde var (yeni bir sinyal eklenirse port da).
    for (final alan in [
      'seenTutorial',
      'seenLegacyQuickStart',
      'hasPlayed',
      'accountCreatedAt'
    ]) {
      expect(onboardingTs.contains('$alan:'), isTrue, reason: 'web sinyali $alan');
    }
    expect(RegExp(r'^\s+(\w+): [\w| ]+;', multiLine: true)
        .allMatches(onboardingTs.substring(
            onboardingTs.indexOf('interface TutorialGateInput'),
            onboardingTs.indexOf('export function shouldShowTutorial')))
        .length, 4, reason: 'web TutorialGateInput alan sayısı değişti — port da');
  });
}
