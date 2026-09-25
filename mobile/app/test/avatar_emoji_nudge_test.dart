// YZ robot avatarının ortalanması (15 Eylül 2026, Parça 210).
//
// Kullanıcı bildirdi: *"YZ robot avatarı iPhone ve iPad'de ortalı değil."*
// Ölçüm kullanıcının 1170×2532 iPhone ekran görüntüsünden yapıldı (daire
// maskesi, mühür testinin yöntemi): iki ayrı kartta iki yalıtık robot, dördü
// de birebir **yatay −0,131 em · dikey +0,083 em**. Aynı ölçüm Linux/Noto
// Color Emoji'de 0,00 em → sapma APPLE fontuna özgü.
//
// ⚠ **BU TESTİN SINIRI, açıkça:** Apple Color Emoji bu ortamda YOK; test
// pikselleri ölçemez, yalnızca düzeltmenin DOĞRU PLATFORMDA ve DOĞRU
// BÜYÜKLÜKTE uygulandığını kilitler. Mürekkebin gerçekten ortalandığı
// cihazda doğrulanır (`mobile/TESTING.md` §29). Kapının işi, sabitlerin
// sessizce silinmesini/sürüklenmesini engellemek.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/game/player_avatar_row.dart';

/// Robotun `Text`ini saran `Transform`un kaydırması.
Offset nudgeOf(WidgetTester tester) {
  final t = tester.widget<Transform>(find.ancestor(
    of: find.text('🤖'),
    matching: find.byType(Transform),
  ));
  return Offset(t.transform.getTranslation().x, t.transform.getTranslation().y);
}

Future<void> pumpRow(WidgetTester tester, {double size = 26}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: PlayerAvatarRow(
            players: const [AvatarRowPlayer(name: 'Yapay Zeka 2', isAi: true)],
            size: size,
          ),
        ),
      ),
    ));

void main() {
  testWidgets('iOS: ölçülen düzeltme uygulanır (em cinsinden, font boyutuyla ölçekli)',
      (tester) async {
    // ⚠ `addTearDown` ÇOK GEÇ: foundation'ın "debug değişkeni sıfırlandı mı"
    // kontrolü test GÖVDESİ biter bitmez, tearDown'dan ÖNCE koşuyor
    // (`real_io.dart`taki bekleyen-timer dersinin aynısı).
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await pumpRow(tester);
    // 26 pt daire → font 14 pt (0,55 × 26, yuvarlanmış).
    const fs = 14.0;
    final d = nudgeOf(tester);
    expect(d.dx, closeTo(kAppleEmojiNudgeXEm * fs, 0.001));
    expect(d.dy, closeTo(kAppleEmojiNudgeYEm * fs, 0.001));
    // Yön, ölçümün tersi olmalı: mürekkep sola+aşağı kaçıyordu.
    expect(d.dx, greaterThan(0), reason: 'sağa itmeli');
    expect(d.dy, lessThan(0), reason: 'yukarı itmeli');

    // Ve düzeltme em tabanlı: daire büyüyünce kaydırma da büyür.
    await pumpRow(tester, size: 52); // font 29 pt (0,55 × 52 = 28,6 → 29)
    final big = nudgeOf(tester);
    expect(big.dx, closeTo(kAppleEmojiNudgeXEm * 29, 0.001));
    expect(big.dy, closeTo(kAppleEmojiNudgeYEm * 29, 0.001));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android: düzeltme YOK — Noto Color Emoji zaten ortalı',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await pumpRow(tester);
    expect(nudgeOf(tester), Offset.zero,
        reason: 'koşulsuz kaydırma Android/Noto tarafını BOZAR (ölçüldü: '
            '300 px kutuda sapma 1 px)');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('düzeltme LAYOUT\'A dokunmaz — daire ve satır adımı aynı kalır',
      (tester) async {
    // Transform yalnızca boyar; puan sütunu (`scoreCellWidth`) ve avatarın
    // kutusu iki platformda da bitine kadar aynı olmalı.
    final sizes = <TargetPlatform, Size>{};
    for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
      debugDefaultTargetPlatformOverride = p;
      await pumpRow(tester);
      sizes[p] = tester.getSize(find.byType(PlayerAvatarRow));
    }
    debugDefaultTargetPlatformOverride = null;
    expect(sizes[TargetPlatform.iOS], sizes[TargetPlatform.android]);
  });
}
