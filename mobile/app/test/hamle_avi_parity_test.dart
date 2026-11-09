// Hamle Avı — web ↔ port paritesi (ROADMAP #48, 3 Kasım 2026).
//
// Kilitlenenler: (1) banka asset'i web dosyasıyla BAYT EŞİT (elle kopya
// ayrışmasın); (2) sabitler (süre, uyarı, tavan, tanıtım maddeleri) web
// kaynağından okunur; (3) banka şekli; (4) Dart çözücüsü bankadaki anahtarı
// (`k`) YENİDEN üretir — puan/vergi kuralı değişirse banka bayatlar, bu test
// düşer (web `verify-hamle-avi` ikizi); (5) seri/rekor ve görülenler.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/hamle_avi_api.dart';
import 'package:kelimeki/src/util/hamle_avi.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import 'support/web_source.dart';

void main() {
  late List<HamleAviPosition> bank;
  late SetWordSource words;

  setUpAll(() {
    final raw = File('assets/hamle_avi/bank.json').readAsStringSync();
    bank = [
      for (final j in jsonDecode(raw) as List<Object?>)
        HamleAviPosition.fromJson((j! as Map).cast<String, Object?>()),
    ];
    final lines = const LineSplitter()
        .convert(File('assets/dictionary/words_tr.txt').readAsStringSync())
        .where((w) => w.isNotEmpty)
        .toList();
    words = SetWordSource(lines);
  });

  test('banka asset\'i web dosyasıyla BAYT EŞİT', () {
    final web = readRepoFile('src/data/hamleAviBank.json');
    final port = File('assets/hamle_avi/bank.json').readAsStringSync();
    expect(port, web,
        reason: 'cp src/data/hamleAviBank.json '
            'mobile/app/assets/hamle_avi/bank.json');
  });

  test('sabitler web kaynağından', () {
    final src = readRepoFile('src/utils/hamleAvi.ts');
    expect(
        int.parse(pick(src, RegExp(r'HAMLE_AVI_SECONDS = (\d+) \* 60'),
                'HAMLE_AVI_SECONDS')) *
            60,
        kHamleAviSeconds);
    expect(
        int.parse(pick(src, RegExp(r'HAMLE_AVI_WARN_SECONDS = (\d+)'),
            'HAMLE_AVI_WARN_SECONDS')),
        kHamleAviWarnSeconds);
    expect(
        int.parse(pick(src, RegExp(r'MAX_PLAUSIBLE_STREAK = (\d+)'),
            'MAX_PLAUSIBLE_STREAK')),
        kMaxPlausibleStreak);
    final tsx = readRepoFile('src/components/HamleAvi.tsx');
    final block = pick(tsx, RegExp(r'HAMLE_AVI_INTRO_POINTS = \[([\s\S]*?)\];'),
        'HAMLE_AVI_INTRO_POINTS');
    final maddeler = [
      for (final m in RegExp(r"'([^']+)'").allMatches(block)) m.group(1)!
    ];
    expect(kHamleAviIntroPoints, maddeler);
  });

  test('sunucu bayrağı + ölçüm satırı sütunları web ile AYNI', () {
    final api = readRepoFile('src/lib/hamleAviApi.ts');
    // Bayrak iki tarafta AYNI olmalı: biri kapanıp öteki açık kalırsa
    // gizlilik metni ↔ davranış istisnası tek platformda sürer.
    expect(
        pick(api, RegExp(r'HAMLE_AVI_SERVER_ENABLED = (true|false)'),
            'HAMLE_AVI_SERVER_ENABLED'),
        '$kHamleAviServerEnabled');
    final block = pick(api,
        RegExp(r"from\('hamle_avi_events'\)\.insert\(\{([\s\S]*?)\}\)"),
        'hamle_avi_events insert');
    final webKeys = {
      for (final m
          in RegExp(r'^\s*(\w+)\s*[:,]', multiLine: true).allMatches(block))
        m.group(1)!
    };
    final row = hamleAviEventRow(
        anonId: 'a', puzzleId: 1, result: 'found', seconds: 5, streakBefore: 0);
    expect(row.keys.toSet(), webKeys);
    // Sunucu kısıtları: seconds 0..300, streak_before 0..5000.
    final big = hamleAviEventRow(
        anonId: null,
        puzzleId: 1,
        result: 'missed',
        seconds: 9999,
        streakBefore: 99999);
    expect(big['seconds'], 300);
    expect(big['streak_before'], kMaxPlausibleStreak);
  });

  test('banka şekli: 7 harflik raf, tekil kimlik, tahta içi', () {
    expect(bank, isNotEmpty);
    expect({for (final p in bank) p.id}.length, bank.length);
    for (final p in bank) {
      expect(p.rack.runes.length, 7, reason: '#${p.id}');
      expect(p.o == 0 || p.o == 1, isTrue);
      for (final t in p.tiles) {
        expect(
            t.r >= 0 && t.r < boardSize && t.c >= 0 && t.c < boardSize, isTrue);
      }
      expect(p.k >= 10 && p.w.length >= 3, isTrue, reason: '#${p.id}');
    }
  });

  test('çözücü bankadaki anahtarı YENİDEN üretir (banka tazeliği)', () {
    final adet = min(8, bank.length);
    final adim = max(1, bank.length ~/ adet);
    for (var i = 0; i < adet; i++) {
      final p = bank[i * adim];
      final st = hamleAviPositionToState(p, 'Ben');
      final best = hamleAviFindBestNetMove(st, words);
      expect(best, isNotNull, reason: '#${p.id}');
      expect(best!.net, p.k, reason: '#${p.id} anahtar ayrıştı');
      // Gerçek reducer'dan geçirince skor farkı = net (vergi dahil).
      final eng = GameEngine(words: words, rng: SystemRng(), nowIso: () => '');
      var s = st;
      final rack = [...s.players[s.current].rack];
      for (final pl in best.move.placements) {
        final idx = rack.indexWhere(
            (t) => pl.tile.wild ? t.letter == '?' : t.letter == pl.tile.letter);
        rack.removeAt(idx);
        s = eng.reduce(
            s,
            pl.tile.wild
                ? PlaceTileAction(
                    r: pl.r,
                    c: pl.c,
                    rackIndex: idx,
                    wildLetter: pl.tile.wildLetter)
                : PlaceTileAction(r: pl.r, c: pl.c, rackIndex: idx));
      }
      s = eng.reduce(s, const PlayAction());
      expect(hamleAviNetGain(st, s), p.k, reason: '#${p.id} reducer farkı');
      expect(hamleAviIsCorrect(hamleAviNetGain(st, s), p), isTrue);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('seri/rekor, görülenler, birleşim', () {
    var s = const HamleAviStreak(0, 4);
    s = hamleAviOnFound(hamleAviOnFound(s));
    expect((s.streak, s.best), (2, 4));
    expect(hamleAviShouldWarnOnLeave(s), isTrue);
    for (var i = 0; i < 3; i++) {
      s = hamleAviOnFound(s);
    }
    expect(s.best, 5);
    s = hamleAviOnMissed(s);
    expect((s.streak, s.best), (0, 5));
    expect(hamleAviShouldWarnOnLeave(s), isFalse);

    final seen = <int>{};
    final rng = Random(7);
    for (var i = 0; i < bank.length; i++) {
      final p = hamleAviPickNext(bank, seen, rng);
      expect(p, isNotNull);
      expect(seen.contains(p!.id), isFalse);
      seen.add(p.id);
    }
    expect(hamleAviPickNext(bank, seen, rng), isNull);
    expect(hamleAviMergeSeen([3, 1], [2, 3]), [1, 2, 3]);
  });
}
