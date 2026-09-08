// "Oynayarak öğren" senaryosu GERÇEK Dart motorunda oynatılır — web
// `scripts/verify-tutorial-script.ts`in port karşılığı (Onboarding Faz 4).
//
// NEDEN VAR: tanıtım ekranda PUAN yazıyor ("6 × 2 = 12", "58 puanın 19'u
// rakibe gitti"). Bu sayılar elle yazıldığından motordaki bir kural
// değişikliği (çarpan, vergi formülü, kelime listesi) onları SESSİZCE
// bayatlatabilir — yanlış puan gösteren bir tanıtım, hiç tanıtım
// olmamasından kötü. Kontroller web betiğiyle aynı numaralarla:
//   1. hedef kareler boş, harfler rafta · 2. hamle geçerli · 3. skor
//   deltaları ve verginin YÖNÜ · 4. çarpan beyanı · 5. oyun ortada
//   bitmiyor · 6. bitiş tahtasındaki her dizilim sözlükte · 7. kapı
//   tablosu · 8. raf düzeni (bitişik blok) · 9. balon hedefi örtmüyor.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/game/game_controller.dart';
import 'package:kelimeki/src/ui/tutorial/tutorial_script.dart';
import 'package:kelimeki/src/util/onboarding.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

late SetWordSource words;
late Set<String> sozluk;

/// Bir hamleyi oynatır ve senaryodaki sayılarla karşılaştırır.
void hamleOynat(GameController c, TutorialMove move, String etiket) {
  final state = c.state;
  final oynayan = state.current;
  final karsi = 1 - oynayan;
  final onceki = [for (final p in state.players) p.score];

  // 1. hedef kareler boş, harfler torbada VE rafta
  for (final cell in move.cells) {
    expect(state.board[cell.r][cell.c], isNull,
        reason: '$etiket: (${cell.r},${cell.c}) zaten dolu');
    expect(tileData.containsKey(cell.letter), isTrue,
        reason: '$etiket: torbada olmayan harf "${cell.letter}"');
  }
  for (final cell in move.cells) {
    final rack = c.state.players[c.state.current].rack;
    final idx = rack.indexWhere((t) => t.letter == cell.letter);
    expect(idx, greaterThanOrEqualTo(0),
        reason: '$etiket: "${cell.letter}" rafta yok (raf: '
            '${rack.map((t) => t.letter).join()}) — torba sırası senaryoyla '
            'uyuşmuyor');
    c.dispatch(PlaceTileAction(r: cell.r, c: cell.c, rackIndex: idx));
  }
  expect(c.state.placed.length, move.cells.length,
      reason: '$etiket: ${move.cells.length} taş konacaktı');

  // 4. çarpan beyanı — tek dürüst kaynak kelime başına x2/x3 bayrakları
  final ham = calcWordRawScores(c.state.board, c.state.placed, c.state.bonuses);
  final x3Var = ham.any((w) => w.x3);
  final x2Var = ham.any((w) => w.x2);
  switch (move.bonus) {
    case 'x3':
      expect(x3Var, isTrue, reason: '$etiket: X3 bekleniyordu');
    case 'x2':
      expect(x2Var, isTrue, reason: '$etiket: ×2 bekleniyordu');
      expect(x3Var, isFalse, reason: '$etiket: ×2 bekleniyordu ama X3 aldı');
    default:
      expect(x2Var || x3Var, isFalse,
          reason: '$etiket: çarpan BEKLENMİYORDU (x2:$x2Var x3:$x3Var)');
  }
  final vergiOncesi = calcScore(c.state.board, c.state.placed, c.state.bonuses);
  expect(vergiOncesi, move.points + move.tax,
      reason: '$etiket: vergi öncesi puan');
  if (move.raw != null) {
    final hamToplam = ham.fold<int>(0, (t, w) => t + w.score);
    expect(hamToplam, move.raw, reason: '$etiket: çarpansız puan');
    expect(move.raw! * 2, vergiOncesi,
        reason: '$etiket: "${move.raw} × 2" cümlesi tutmuyor');
    expect(ham.length, 1,
        reason: '$etiket: "raw × 2" beyanı çok kelimeli hamlede kullanılamaz');
  }

  // 2 + 3. oyna
  c.dispatch(const PlayAction());
  expect(c.state.messageType, isNot(MessageKind.err),
      reason: '$etiket: motor hamleyi reddetti — "${c.state.message}"');
  expect(c.state.placed, isEmpty, reason: '$etiket: hamle onaylanmadı');
  expect(c.state.players[oynayan].score - onceki[oynayan], move.points,
      reason: '$etiket: oynayanın kazancı');
  expect(c.state.players[karsi].score - onceki[karsi], move.tax,
      reason: '$etiket: vergi payı (yön dahil)');

  // 5. tanıtım ortasında oyun bitmemeli
  expect(c.state.isGameOver, isFalse, reason: '$etiket: oyun ortada bitti');
  for (final p in c.state.players) {
    expect(p.rack.length, lessThanOrEqualTo(tutorialRackSize),
        reason: '$etiket: raf tavanı aşıldı');
  }
}

void main() {
  setUpAll(() {
    final f = File('assets/dictionary/words_tr.txt');
    final lines = const LineSplitter()
        .convert(f.readAsStringSync())
        .where((w) => w.isNotEmpty)
        .toList();
    words = SetWordSource(lines);
    sozluk = {for (final w in lines) trLower(w)};
    expect(sozluk.contains('büyü'), isTrue);
  });

  test('senaryo gerçek motorla birebir tutuyor (dört sahne + dört cevap)', () {
    final c = GameController(words: words, autoPlayAi: false)
      ..restore(createTutorialState('Sen'));

    for (final step in tutorialSteps) {
      expect(c.state.current, 0, reason: '${step.id}: sıra oyuncuda değil');

      // 9. balon hedef kareleri örtmüyor mu (balon iki satıra sarabilir,
      //    komşu İKİ satırı kapatabilir); 0. satırda 'ust' olmaz.
      final b = step.bubble;
      final kapali = b.yon == 'ust' ? [b.r - 1, b.r - 2] : [b.r + 1, b.r + 2];
      final ortulen = [
        for (final h in step.move.cells)
          if (kapali.contains(h.r)) '(${h.r},${h.c})'
      ];
      expect(ortulen, isEmpty,
          reason: '${step.id}: balon (${b.r},${b.c}, ${b.yon}) hedef '
              'kareleri örtüyor — ${ortulen.join(', ')}');
      expect(b.yon == 'ust' && b.r == 0, isFalse,
          reason: '${step.id}: 0. satırda \'ust\' balon tahtadan taşar');
      expect(b.r >= 0 && b.r < boardSize && b.c >= 0 && b.c < boardSize, isTrue,
          reason: '${step.id}: balon çapası tahtanın dışında');

      // 8. sahnenin harfleri rafta yan yana ve sırayla mı
      final raf = [for (final t in c.state.players[0].rack) t.letter];
      final gereken = [for (final h in step.move.cells) h.letter];
      var bitisik = false;
      for (var bas = 0; bas + gereken.length <= raf.length; bas++) {
        var ok = true;
        for (var i = 0; i < gereken.length; i++) {
          if (raf[bas + i] != gereken[i]) ok = false;
        }
        if (ok) bitisik = true;
      }
      expect(bitisik, isTrue,
          reason: '${step.id}: "${gereken.join()}" rafta yan yana ve sırayla '
              'DEĞİL (raf: ${raf.join()}) — ekrandaki vurgu yanlış taşa düşer');

      hamleOynat(c, step.move, '${step.id} · ${step.move.word}');
      expect(c.state.current, 1, reason: '${step.id}: rakibe sıra geçmedi');
      hamleOynat(c, step.reply, '${step.id} · rakip · ${step.reply.word}');

      // Sahnenin ÖĞRETTİĞİ şey gerçekten oluyor mu.
      if (step.id == 'x3vergi') {
        expect(step.move.bonus, 'x3');
        expect(step.move.tax, greaterThan(0));
      }
      if (step.id == 'merkez') expect(step.move.tax, 0);
    }

    // 6. bitiş tahtasındaki her ≥2 dizilim sözlükte
    final board = c.state.board;
    final bulunan = <String>[];
    void tara(String? Function(int i) oku, String ad) {
      var birikim = '';
      for (var i = 0; i <= boardSize; i++) {
        final harf = i < boardSize ? oku(i) : null;
        if (harf != null) {
          birikim += harf;
        } else {
          if (birikim.length >= 2) {
            bulunan.add(birikim);
            expect(sozluk.contains(trLower(birikim)), isTrue,
                reason: '$ad: "$birikim" sözlükte yok');
          }
          birikim = '';
        }
      }
    }

    for (var r = 0; r < boardSize; r++) {
      tara((cc) => board[r][cc]?.letter, 'satır $r');
    }
    for (var cc = 0; cc < boardSize; cc++) {
      tara((r) => board[r][cc]?.letter, 'sütun $cc');
    }
    expect(bulunan, isNotEmpty);

    // Özet: bitiş skorları senaryodan türeyen toplamlarla aynı.
    final beklenenSen =
        tutorialSteps.fold<int>(0, (s, x) => s + x.move.points + x.reply.tax);
    final beklenenRakip =
        tutorialSteps.fold<int>(0, (s, x) => s + x.reply.points + x.move.tax);
    expect(c.state.players[0].score, beklenenSen);
    expect(c.state.players[1].score, beklenenRakip);
    c.dispose();
  });

  test('torba: çekilme sırası ters yazılır (drawTiles sondan çeker)', () {
    final s = createTutorialState('Sen');
    final ilkCekilen = drawTiles([...s.bag], 4).map((t) => t.letter).toList();
    expect(ilkCekilen, tutorialDrawOrder.take(4).toList(),
        reason: 'torba sırası web ile aynı yönde kurulmalı');
    expect(s.players[0].rack.map((t) => t.letter).join(), 'BÜYÜZEN');
    expect(s.players[1].rack.map((t) => t.letter).join(), 'KUYUTAB');
    expect(s.players[0].name, 'Sen');
    expect(createTutorialState('  ').players[0].name, tutorialPlayerName);
    expect(createTutorialState('Ironman').players[0].name, 'Ironman');
    expect(s.players[1].name, tutorialOpponentName);
    expect(s.players.every((p) => !p.isAI), isTrue,
        reason: 'rakip YZ DEĞİL — hamleleri senaryoda yazılı');
  });

  test('kapı: tanıtım kime gösteriliyor (web tablosuyla aynı yedi vaka)', () {
    const temiz = TutorialGateInput(
      seenTutorial: false,
      seenLegacyQuickStart: false,
      hasPlayed: false,
      accountCreatedAt: null,
    );
    final yeniHesap = DateTime.parse(tutorialLaunchAt)
        .add(const Duration(hours: 1))
        .toIso8601String();
    final vakalar = <(String, TutorialGateInput, bool)>[
      ('yeni misafir — tertemiz cihaz', temiz, true),
      (
        'tanıtımı zaten görmüş cihaz',
        const TutorialGateInput(
            seenTutorial: true,
            seenLegacyQuickStart: false,
            hasPlayed: false,
            accountCreatedAt: null),
        false
      ),
      (
        'eski Hızlı Başlangıç’ı görmüş cihaz (mevcut oyuncu)',
        const TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: true,
            hasPlayed: false,
            accountCreatedAt: null),
        false
      ),
      (
        'misafir — devam eden yerel oyunu var',
        const TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: false,
            hasPlayed: true,
            accountCreatedAt: null),
        false
      ),
      (
        'girişli — hesap tanıtımdan ESKİ, cihaz tertemiz',
        const TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: false,
            hasPlayed: false,
            accountCreatedAt: '2026-08-01T10:00:00.000Z'),
        false
      ),
      (
        'girişli — hesap tanıtımdan YENİ, cihaz tertemiz',
        TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: false,
            hasPlayed: false,
            accountCreatedAt: yeniHesap),
        true
      ),
      (
        'girişli — okunamayan hesap tarihi (varsayılan: gösterme)',
        const TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: false,
            hasPlayed: false,
            accountCreatedAt: 'bozuk-tarih'),
        false
      ),
    ];
    for (final (ad, girdi, beklenen) in vakalar) {
      expect(shouldShowTutorial(girdi), beklenen, reason: 'kapı "$ad"');
    }
    // Supabase `User.createdAt` biçimi (saat dilimi Z'siz olabilir) de
    // okunabilmeli — okunamasaydı kapı sessizce hep kapalı kalırdı.
    expect(
        shouldShowTutorial(const TutorialGateInput(
            seenTutorial: false,
            seenLegacyQuickStart: false,
            hasPlayed: false,
            accountCreatedAt: '2026-09-08T10:00:00.123456+00:00')),
        isTrue);
  });

  // ── 10. Bağlamsal ipuçları (Onboarding Faz 2) ──────────────────────────
  // Web `verify-tutorial-script`in aynı numaralı bölümünün eşi. En kolay
  // kaçırılan iki kural: (a) aynı hamlede birden fazla ipucu hak edilirse
  // SIRA sabittir (ekranda tek balon), (b) tavana çarpan bir ipucu
  // ötekileri SUSTURMAZ.
  test('bağlamsal ipuçları: sıra sabit, tavan ipucu BAŞINA', () {
    const yok = OnboardingHintInput(
        paidTax: false, gotMultiplier: false, territoryOutsideCorner: false);
    const hepsi = OnboardingHintInput(
        paidTax: true, gotMultiplier: true, territoryOutsideCorner: true);
    const sifir = <OnboardingHintId, int>{
      OnboardingHintId.vergi: 0,
      OnboardingHintId.carpan: 0,
      OnboardingHintId.bolge: 0,
    };
    final vakalar = <(String, OnboardingHintInput, Map<OnboardingHintId, int>,
        OnboardingHintId?)>[
      ('mekanik yaşanmadı', yok, sifir, null),
      (
        'yalnızca vergi ödendi',
        const OnboardingHintInput(
            paidTax: true,
            gotMultiplier: false,
            territoryOutsideCorner: false),
        sifir,
        OnboardingHintId.vergi
      ),
      (
        'yalnızca çarpan alındı',
        const OnboardingHintInput(
            paidTax: false,
            gotMultiplier: true,
            territoryOutsideCorner: false),
        sifir,
        OnboardingHintId.carpan
      ),
      (
        'yalnızca bölge büyüdü',
        const OnboardingHintInput(
            paidTax: false,
            gotMultiplier: false,
            territoryOutsideCorner: true),
        sifir,
        OnboardingHintId.bolge
      ),
      // Tanıtımın 4. sahnesi TAM OLARAK böyle: hem ×3 hem vergi.
      ('üçü birden — sıra sabit, vergi kazanır', hepsi, sifir,
          OnboardingHintId.vergi),
      (
        'vergi tavanda — sıradaki hak edilmiş ipucu gösterilir',
        hepsi,
        {...sifir, OnboardingHintId.vergi: onboardingHintMaxShows},
        OnboardingHintId.carpan
      ),
      (
        'hepsi tavanda — hiçbiri gösterilmez',
        hepsi,
        {
          for (final id in OnboardingHintId.values) id: onboardingHintMaxShows
        },
        null
      ),
    ];
    for (final (ad, girdi, sayac, beklenen) in vakalar) {
      expect(pickOnboardingHint(girdi, sayac), beklenen, reason: 'ipucu "$ad"');
    }
    // Metinler TEK cümle ve terim `bölge` (bkz. kök CLAUDE.md → Terminoloji).
    for (final id in OnboardingHintId.values) {
      final metin = onboardingHintTexts[id]!;
      expect('.'.allMatches(metin).length, 1, reason: '$id tek cümle olmalı');
      expect(metin.toLowerCase().contains('sınır'), isFalse,
          reason: '$id "sınır" diyor — verginin/alanın adı "bölge"');
    }
  });
}
