// Tanıtım ekranı — dört sahne dokunarak ve sürükleyerek oynanır, ekrandaki
// puanlar/vergi penceresi/kapanış kartı iddia edilir (web `tests/smoke.spec.ts`
// "Tanıtım: dört sahne oynanır…" testinin port karşılığı). Sözlük gerçek
// asset dosyasından; senaryonun kendisi `tutorial_script_test.dart`ta.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/game/dialog_shell.dart' show KDialogCard;
import 'package:kelimeki/src/ui/game/drag_feel.dart';
import 'package:kelimeki/src/ui/game/game_screen.dart' show GameScreen;
import 'package:kelimeki/src/ui/game/neo_button.dart';
import 'package:kelimeki/src/ui/game/tile_widget.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/ui/tutorial/tutorial_game.dart';
import 'package:kelimeki/src/ui/tutorial/tutorial_script.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import 'support/test_fonts.dart';
import 'support/test_view.dart';

late SetWordSource words;

Finder rackTile(int i) => find.byKey(ValueKey('rack-$i'));
Finder rackHighlight(int i) => find.byKey(ValueKey('rack-highlight-$i'));
Finder boardCell(int r, int c) => find.byKey(ValueKey('cell-$r-$c'));
Finder cellTile(int r, int c) =>
    find.descendant(of: boardCell(r, c), matching: find.byType(TileWidget));
Finder mesaj() => find.byKey(const ValueKey('tutorial-message'));

/// Raftaki vurgulu taşlardan İLKİ — sıradaki harf (senaryo bloğu kelime
/// sırasında, yani ilk vurgu her zaman sıradaki hedefin harfi).
int ilkVurguluIndeks(WidgetTester tester) {
  for (var i = 0; i < 7; i++) {
    if (tester.any(rackHighlight(i))) return i;
  }
  fail('rafta vurgulu taş yok');
}

Future<({bool finished, bool skipped})> pumpTutorial(WidgetTester tester,
    {String name = 'Sen'}) async {
  var finished = false, skipped = false;
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    home: TutorialGame(
      playerName: name,
      words: words,
      onFinish: () => finished = true,
      onSkip: () => skipped = true,
    ),
  ));
  await tester.pump();
  return (finished: finished, skipped: skipped);
}

/// Bir sahneyi dokunarak oynar: her hedef için sıradaki vurgulu taşa dokun,
/// sonra hedef kareye dokun.
Future<void> sahneyiDiz(WidgetTester tester, TutorialStep step) async {
  for (final cell in step.move.cells) {
    final i = ilkVurguluIndeks(tester);
    await tester.tap(rackTile(i));
    await tester.pump();
    await tester.tap(boardCell(cell.r, cell.c));
    await tester.pump();
    expect(cellTile(cell.r, cell.c), findsOneWidget,
        reason: '${step.id}: (${cell.r},${cell.c}) taşı konmadı');
  }
}

/// Oyuncunun hamlesi + rakibin cevabı için zamanlayıcıları ilerletir.
Future<void> rakibiBekle(WidgetTester tester, TutorialStep step) async {
  await tester.pump(const Duration(milliseconds: kTutorialSonucOkuma));
  await tester.pump();
  for (var i = 0; i < step.reply.cells.length; i++) {
    await tester.pump(const Duration(milliseconds: kTutorialRakipTasArasi));
  }
  await tester.pump();
  expect(find.text(step.reply.note), findsOneWidget,
      reason: '${step.id}: rakibin notu görünmedi');
  expect(find.text(kTutorialRakipYaptiText), findsOneWidget);
  await tester.pump(const Duration(milliseconds: kTutorialRakipOkuma));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadRobotoIfAvailable();
    final f = File('assets/dictionary/words_tr.txt');
    words = SetWordSource(const LineSplitter()
        .convert(f.readAsStringSync())
        .where((w) => w.isNotEmpty));
  });

  testWidgets('dört sahne dokunarak oynanır: puanlar, vergi penceresi, kapanış',
      (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    var finished = false;
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: TutorialGame(
        playerName: 'Sen',
        words: words,
        onFinish: () => finished = true,
        onSkip: () {},
      ),
    ));
    await tester.pump();

    expect(find.text('TANITIM · 1/4'), findsOneWidget);
    expect(find.text('ATLA →'), findsOneWidget);
    expect(find.text('Kendi köşenden başla.'), findsOneWidget);
    expect(find.text(kTutorialTasiBalonuText('BÜYÜ')), findsOneWidget);
    expect(find.text(kTutorialHarfiAlText), findsOneWidget);
    // "Buradan başla" balonu bastırılıyor: ekranda TEK balon.
    expect(find.text('Buradan başla'), findsNothing);
    // OYNA hamle tamamlanmadan kapalı.
    expect(
        tester.widget<NeoButton>(find.widgetWithText(NeoButton, 'OYNA')).onPressed,
        isNull);

    for (var s = 0; s < tutorialSteps.length; s++) {
      final step = tutorialSteps[s];
      expect(find.text('TANITIM · ${s + 1}/4'), findsOneWidget);
      expect(find.text(step.say), findsOneWidget, reason: '${step.id} balonu');
      await sahneyiDiz(tester, step);

      // Hamle tamamlandı: dersin balonu KAYBOLDU, OYNA balonu geldi.
      expect(find.text(step.say), findsNothing,
          reason: '${step.id}: iki balon aynı anda durmamalı');
      expect(find.text(kTutorialOynaBalonuText), findsOneWidget);
      await tester.tap(find.widgetWithText(NeoButton, 'OYNA'));
      await tester.pump();

      if (step.move.tax > 0) {
        // Vergi sahnesi: gerçek oyundaki onay penceresi, sayılar senaryodan.
        expect(find.text('Sınır İhlali!'), findsOneWidget);
        expect(find.textContaining('${step.move.points + step.move.tax}'),
            findsWidgets);
        expect(find.text(kTutorialInvasionNote), findsOneWidget);
        await tester.tap(find.descendant(
            of: find.byType(KDialogCard),
            matching: find.widgetWithText(NeoButton, 'OYNA')));
        await tester.pump();
        await tester.pump();
      }
      expect(find.text(step.done), findsOneWidget,
          reason: '${step.id}: sonuç mesajı ("${step.done}")');
      await rakibiBekle(tester, step);
    }

    // Kapanış kartı — kapatmak gerçek oyunu başlatır.
    expect(find.text(tutorialFinishTitle), findsOneWidget);
    expect(find.text(tutorialFinishText), findsOneWidget);
    expect(finished, isFalse);
    await tester.tap(find.text('GERÇEK OYUNA BAŞLA'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
  });

  testWidgets('sürükleyerek yerleştirme: taş parmağın üstünde, hedefe iner ve '
      'YERİNDE kalır; vurgusuz taş sürüklenemez', (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    await pumpTutorial(tester);

    // Raf: B Ü Y Ü Z E N — ilk sahne BÜYÜ, yani 0-3 vurgulu, 4-6 değil.
    for (var i = 0; i < 4; i++) {
      expect(rackHighlight(i), findsOneWidget, reason: 'raf $i vurgulu olmalı');
    }
    for (var i = 4; i < 7; i++) {
      expect(rackHighlight(i), findsNothing, reason: 'raf $i vurgusuz olmalı');
    }

    Future<void> surukle(int i, int r, int c) async {
      final from = tester.getCenter(rackTile(i));
      // Bırakma noktası parmağın `kDragLift` ÜSTÜ — parmak hedefin o kadar
      // altında durmalı.
      final to = tester.getCenter(boardCell(r, c)) + const Offset(0, kDragLift);
      final g = await tester.startGesture(from);
      await g.moveBy(const Offset(0, -40)); // eşik aşılır, hayalet çıkar
      await tester.pump();
      await g.moveTo(to);
      await tester.pump();
      await g.up();
      await tester.pump();
    }

    await surukle(0, 0, 0);
    expect(cellTile(0, 0), findsOneWidget, reason: 'B (0,0)\'a inmeli');
    // Konan taş bir sonraki karede de yerinde (hayalet tık sınıfı yok ama
    // seçim/geri alma yolu yanlışlıkla tetiklenmemeli).
    await tester.pump(const Duration(milliseconds: 350));
    expect(cellTile(0, 0), findsOneWidget);

    // Yanlış kareye bırakılan taş rafa döner (ray). Raf artık 6 taş
    // (Ü Y Ü Z E N): yanlış bırakış sayıyı değiştirmez.
    await surukle(1, 3, 3);
    expect(cellTile(3, 3), findsNothing);
    expect(rackTile(5), findsOneWidget, reason: 'raf 6 taşlı kalmalı');
    expect(rackTile(6), findsNothing);

    // Vurgusuz taş (Z, artık indeks 3) sürüklenemez: hedef kareye bile inmez.
    final z = tester.getCenter(rackTile(3));
    final g = await tester.startGesture(z);
    await g.moveTo(tester.getCenter(boardCell(0, 1)) + const Offset(0, kDragLift));
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(cellTile(0, 1), findsNothing);

    // Konan taşa dokunmak geri alır, kare yeniden hedef olur.
    await tester.tap(boardCell(0, 0));
    await tester.pump();
    expect(cellTile(0, 0), findsNothing);
    expect(rackHighlight(0), findsOneWidget);
  });

  testWidgets('ray: hedef dışı kare ve harf seçmeden kareye dokunuş SESSİZ',
      (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    await pumpTutorial(tester);

    // Harf seçmeden hedef kareye dokunmak taş GETİRMEZ.
    await tester.tap(boardCell(0, 0));
    await tester.pump();
    expect(cellTile(0, 0), findsNothing);
    expect(find.text('Önce bir harf seç.'), findsNothing);

    // Doğru harf seçili, yanlış (hedef dışı) kare: sessiz.
    await tester.tap(rackTile(0));
    await tester.pump();
    await tester.tap(boardCell(6, 6));
    await tester.pump();
    expect(cellTile(6, 6), findsNothing);
    expect(find.text(kTutorialHarfiAlText), findsOneWidget);

    // Vurgusuz taşa (Z, indeks 4) dokunmak seçimi DEĞİŞTİRMEZ: B seçili
    // kalır ve hedef kareye o iner — Z değil.
    await tester.tap(rackTile(4));
    await tester.pump();
    await tester.tap(boardCell(0, 0));
    await tester.pump();
    expect(cellTile(0, 0), findsOneWidget);
    expect(tester.widget<TileWidget>(cellTile(0, 0)).tile.letter, 'B');
    expect(rackTile(5), findsOneWidget);
    expect(rackTile(6), findsNothing);
  });

  testWidgets('ATLA → onSkip; oyun bittiğinde GameScreen açılmaz (yalıtım)',
      (tester) async {
    await setPhoneViewSize(tester, const Size(420, 900));
    var skipped = 0;
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: TutorialGame(
        playerName: 'Ironman',
        words: words,
        onFinish: () {},
        onSkip: () => skipped++,
      ),
    ));
    await tester.pump();
    expect(find.text('Ironman'), findsWidgets); // raf başlığı + skor kutusu
    await tester.tap(find.text('ATLA →'));
    await tester.pump();
    expect(skipped, 1);
    expect(find.byType(GameScreen), findsNothing);
  });
}
