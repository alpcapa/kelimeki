// Kayıt Hunisi sayacı (`signup_events`, ROADMAP #35) + tanıtım olayının
// cihaz kodu (`tutorial_events.anon_id`, ROADMAP #30).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/config/env.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/games_api.dart';
import 'package:kelimeki/src/data/signup_events.dart';
import 'package:kelimeki/src/ui/auth/auth_modal.dart';
import 'package:kelimeki/src/ui/theme.dart';

import 'support/test_view.dart';

class _Sink implements SignupEventsSink {
  final rows = <Map<String, Object?>>[];
  Object? failWith;

  @override
  Future<void> insert(Map<String, Object?> row) async {
    final f = failWith;
    if (f != null) throw f;
    rows.add(row);
  }
}

void main() {
  late _Sink sink;
  setUp(() {
    sink = _Sink();
    signupEvents.configure(sink);
  });
  tearDown(signupEvents.reset);

  group('SignupEvents', () {
    test('satır: olay + kanal + platform + sürüm, KİMLİK YOK', () {
      signupEvents.log(kSignupStarted, 'direct');
      final row = sink.rows.single;
      expect(row['event'], 'started');
      expect(row['channel'], 'direct');
      expect(row['app_version'], appVersion);
      expect(row.containsKey('platform'), isTrue);
      // Gizlilik: tablo bilerek kimliksiz (migration başlığı).
      expect(row.containsKey('anon_id'), isFalse);
      expect(row.containsKey('user_id'), isFalse);
    });

    test('sunucu kümesi dışındaki kanal null gider (satır düşmesin)', () {
      signupEvents.log(kSignupCompleted, 'uydurma');
      expect(sink.rows.single['channel'], isNull);
    });

    test('yapılandırılmamışsa sessiz no-op', () {
      signupEvents.reset();
      signupEvents.log(kSignupStarted, 'direct');
      expect(sink.rows, isEmpty);
    });

    test('yazma hatası FIRLATILMAZ (kayıt akışı bozulmaz)', () async {
      sink.failWith = Exception('ağ yok');
      expect(() => signupEvents.log(kSignupStarted, 'direct'), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('AuthModal → signup_events', () {
    Future<void> pump(WidgetTester tester, Widget modal) async {
      await setPhoneViewSize(tester, const Size(420, 900));
      await tester.pumpWidget(MaterialApp(
          theme: kelimekiTheme(), home: Scaffold(body: modal)));
      await tester.pump();
    }

    testWidgets('girişten "Kayıt ol"a geçiş started/direct yazar',
        (tester) async {
      await pump(tester, AuthModal(auth: AuthService.fake()));
      expect(sink.rows, isEmpty); // giriş formu kayıt sayılmaz
      await tester.tap(find.textContaining('Kayıt ol', findRichText: true));
      await tester.pump();
      expect(sink.rows.single['event'], 'started');
      expect(sink.rows.single['channel'], 'direct');
    });

    testWidgets('doğrudan kayıt modunda açılış (Görüş Bildir) started/form',
        (tester) async {
      await pump(
          tester,
          AuthModal(
              auth: AuthService.fake(),
              startInSignup: true,
              signupChannel: 'form'));
      expect(sink.rows.single['event'], 'started');
      expect(sink.rows.single['channel'], 'form');
    });
  });

  test('tutorial_events satırı cihaz kodunu TAŞIYOR (ROADMAP #30)', () {
    final row = SupabaseGamesGateway.tutorialEventRow(
        anonId: 'cihaz-1', event: 'skip', source: 'auto', step: 2);
    expect(row['anon_id'], 'cihaz-1');
    expect(row['event'], 'skip');
    expect(row['step'], 2);
    expect(row['source'], 'auto');
    expect(row['app_version'], appVersion);
    expect(row.containsKey('user_id'), isFalse);
  });
}
