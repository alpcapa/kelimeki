// k-lig penceresinin YERLEŞİMİ: "senin sıran" satırı her zaman pencerenin
// İÇİNDE görünür.
//
// Vaka (2 Ekim 2026, Android'de ekran görüntüsü): 31. sıradaki kullanıcının
// "senin sıran" satırının yalnızca üst yarısı görünüyordu. Liste ekranın
// SABİT %50'sini alıyordu, pencere %85'le sınırlıydı ve gövde
// kaydırılıyordu. Açıklama metni uzayınca satır pencerenin altına itildi.
// Düzeltme: `KModal.fillBody`. Gövde artık kaydırılmıyor, liste pencerede
// KALAN alana sığıyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import 'support/test_fonts.dart';
import 'support/test_view.dart';

/// 40 oyunculu bir lig; giriş yapan kullanıcı 31. sırada (ilk sayfada yok).
class _Gateway implements StatsGateway {
  static final _puan = [
    for (var i = 1; i <= 40; i++)
      {
        'sira': i,
        'user_id': i == 31 ? 'u-me' : 'u-$i',
        'display_name': 'Oyuncu$i',
        'total_score': 1000 - i * 10,
        'avg_move_score': 13.04,
      },
  ];
  static final _beyin = [
    for (var i = 1; i <= 40; i++)
      {
        'sira': i,
        'user_id': i == 31 ? 'u-me' : 'u-$i',
        'display_name': 'Oyuncu$i',
        'ohp_games': 20,
        'avg_move_score': 16 - i / 10,
      },
  ];

  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async =>
      _puan.skip(offset).take(limit).toList();

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async =>
      {'rank': 31, 'total_score': 690, 'avg_move_score': 13.04};

  @override
  Future<List<Map<String, Object?>>> beyinLigi(int limit, int offset) async =>
      _beyin.skip(offset).take(limit).toList();

  @override
  Future<Map<String, Object?>?> myBeyinLigiRank(String userId) async =>
      {'rank': 31, 'avg_move_score': 12.9, 'ohp_games': 20};

  @override
  Future<Map<String, Object?>?> playerStats(
          String userId, int? playerCount) async =>
      null;

  @override
  Future<List<Map<String, Object?>>> rankScores(List<String> userIds) async =>
      const [];

  @override
  Future<Map<String, Object?>?> profileAgeGender(String userId) async => null;

  @override
  Future<Map<String, Object?>?> headToHead(String otherUserId) async => null;
}

User _user() => User(
      id: 'u-me',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    );

Future<void> _pump(WidgetTester tester, Size size, double scale) async {
  await setPhoneViewSize(tester, size);
  await tester.pumpWidget(MaterialApp(
    theme: kelimekiTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: LeaderboardModal(
        auth: AuthService.fake(user: _user()),
        stats: StatsRepo(_Gateway()),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// "Sen" satırı pencerenin (Dialog) içinde TAMAMEN görünür mü?
void _expectMyRowInside(WidgetTester tester) {
  final dialog = tester.getRect(find.byType(Dialog));
  final sen = find.text('Sen');
  expect(sen, findsOneWidget, reason: '"senin sıran" satırı çizilmedi');
  final row = tester.getRect(sen);
  expect(row.bottom, lessThanOrEqualTo(dialog.bottom),
      reason: '"Sen" satırı pencerenin altına taşıyor: $row ↔ $dialog');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  // Ekran görüntüsündeki telefon ve daha kötüsü: küçük ekran + büyük yazı.
  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(360, 740), 1.0),
    (const Size(360, 640), 1.3),
  ]) {
    final label = '${size.width.toInt()}×${size.height.toInt()} @$scale';

    testWidgets('Puan Ligi: "senin sıran" pencerenin içinde ($label)',
        (tester) async {
      await _pump(tester, size, scale);
      expect(find.text('SENİN SIRAN'), findsOneWidget);
      _expectMyRowInside(tester);
    });

    testWidgets('Beyin Ligi: "senin sıran" pencerenin içinde ($label)',
        (tester) async {
      await _pump(tester, size, scale);
      await tester.tap(find.text('Beyin Ligi'));
      await tester.pumpAndSettle();
      expect(find.text('SENİN SIRAN'), findsOneWidget);
      _expectMyRowInside(tester);
    });
  }

  testWidgets('kullanıcının satırı listeye yüklenince kısayol kalkar',
      (tester) async {
    await _pump(tester, const Size(390, 844), 1.0);
    expect(find.text('SENİN SIRAN'), findsOneWidget);
    // Kaydırdıkça 20'şer yükleniyor; 31. sıra ikinci sayfayla gelir.
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(find.text('SENİN SIRAN'), findsNothing);
  });
}
