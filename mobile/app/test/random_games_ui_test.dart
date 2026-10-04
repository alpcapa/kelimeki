// Rastgele Oyuncu (açık ilan) — EKRAN davranışı (3 Ekim 2026; web ikizi
// `RandomGamesStrip.tsx` + `LiveGamesTab.tsx` + `LiveGameCreateForm.tsx`).
// Saf kurallar ve web parite okumaları `random_games_test.dart`ta; burada
// widget'ın o kuralları GERÇEKTEN kullandığı kanıtlanıyor: şerit, "Bekliyor
// n/N" satırı, dört kova, açık koltuk ≠ Yapay Zeka, yoklama, esnek kadro.
//
// Gerçek RPC'ler cihazda doğrulanır (`mobile/TESTING.md` →
// `docs/testing-rastgele.md`'ye atıf).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/bootstrap.dart';
import 'package:kelimeki/src/config/version_gate.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/meaning_store.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/ui/game/neo_button.dart';
import 'package:kelimeki/src/ui/live/live_game_create_form.dart';
import 'package:kelimeki/src/ui/live/live_games_tab.dart';
import 'package:kelimeki/src/ui/live/random_games_strip.dart';
import 'package:kelimeki/src/ui/open_seat_avatar.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/util/online_status.dart';
import 'package:kelimeki/src/util/random_games.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show SetWordSource;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'support/fake_online_gateway.dart';
import 'support/test_fonts.dart';
import 'support/test_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  setUp(resetLiveGamesCaches);

  // Ağ hatası yeniden denemesi gerçek bekleme yapmasın.
  OnlineGamesRepo repoOf(FakeOnlineGamesGateway gw) =>
      OnlineGamesRepo(gw, delay: (_) async {});

  AppServices servis(String userId, FakeOnlineGamesGateway gw,
          {bool online = true}) =>
      AppServices(
        onlineStatus: OnlineStatus.fake(online: online),
        dictionary: Future.value(SetWordSource(const [])),
        meanings: MeaningStore(bundle: rootBundle),
        auth: AuthService.fake(user: fakeUser(userId)),
        supabase: null,
        versionGate: VersionGateStatus.ok,
        onlineGames: repoOf(gw),
        friends: FriendsRepo(FakeFriendsGateway(currentUserId: userId)),
      );

  Future<void> pumpTab(WidgetTester tester, AppServices s,
      {Size size = const Size(420, 900)}) async {
    await setPhoneViewSize(tester, size);
    await tester.pumpWidget(MaterialApp(
      theme: kelimekiTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: LiveGamesTab(services: s, onFinishesSeen: () {}),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> bitir(WidgetTester tester) async {
    // Asılı zamanlayıcı kalmasın (yoklama + otomatik yeniden deneme).
    await tester.pumpWidget(const SizedBox.shrink());
  }

  Finder kart(String id) => find.byKey(ValueKey('ilan-$id'));

  group('şerit', () {
    testWidgets(
        'karışık 2/4 kişilik ilanlar: başlık sayısı, kart içeriği, '
        'SABİT yükseklik, kendi ilanım YOK', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [
          randomListingRow(id: 'a', creatorName: 'Ayşe'),
          randomListingRow(
              id: 'b',
              creatorId: 'can',
              creatorName: 'Can',
              playerCount: 4,
              seats: ['creator', 'filled', 'open', 'open']),
          // Kendi ilanım: şeritte olmamalı (altta "Bekliyor" satırı).
          randomListingRow(
              id: 'benim', creatorId: 'serit1', creatorName: 'Ben'),
        ];
      await pumpTab(tester, servis('serit1', gw));

      expect(find.text('RASTGELE OYUNLAR · 2'), findsOneWidget);
      expect(find.text('Rastgele oyun aç'), findsOneWidget);
      expect(kart('a'), findsOneWidget);
      expect(kart('b'), findsOneWidget);
      expect(kart('benim'), findsNothing);
      expect(find.text('Ayşe'), findsOneWidget);
      expect(find.text('Can'), findsOneWidget);
      expect(find.text('2 kişi'), findsOneWidget);
      expect(find.text('4 kişi'), findsOneWidget);
      // "N koltuk kaldı" — saat/gün YOK.
      expect(find.text('1 koltuk kaldı'), findsOneWidget);
      expect(find.text('2 koltuk kaldı'), findsOneWidget);
      expect(find.textContaining('saat'), findsNothing);
      // Koltuk noktaları: 2 kişilikte 1 dolu + 1 boş; 4 kişilikte 2 dolu + 2 boş.
      expect(
          find.descendant(
              of: kart('a'),
              matching: find.byWidgetPredicate((w) =>
                  w.key is ValueKey &&
                  (w.key! as ValueKey).value.toString().endsWith('-dolu'))),
          findsNWidgets(1));
      expect(
          find.descendant(
              of: kart('b'),
              matching: find.byWidgetPredicate((w) =>
                  w.key is ValueKey &&
                  (w.key! as ValueKey).value.toString().endsWith('-bos'))),
          findsNWidgets(2));
      // Sabit yükseklik: ilan sayısı kaç olursa olsun sayfa uzamaz.
      final h = tester.getSize(find.byKey(const Key('random-strip-list')));
      expect(h.height, kRandomCardHeight);
      // 3 kart yan yana değil, en az 2 sığıyor ve kenar ipucu için genişlik
      // (listWidth-16)/3.4: yan yana iki kartın SOLU ortak satırda.
      expect(tester.getTopLeft(kart('a')).dy, tester.getTopLeft(kart('b')).dy);
      await bitir(tester);
    });

    testWidgets(
        'liste BOŞSA şerit TAMAMEN gizli (başlık da yok); "Yeni Oyun '
        'Başlat" kalır', (tester) async {
      final gw = FakeOnlineGamesGateway();
      await pumpTab(tester, servis('serit-bos', gw));
      expect(find.textContaining('RASTGELE OYUNLAR'), findsNothing);
      expect(find.text('Rastgele oyun aç'), findsNothing);
      expect(find.byKey(const Key('random-strip-list')), findsNothing);
      expect(find.text('YENİ OYUN BAŞLAT'), findsOneWidget);
      // Ama yoklama için widget BAĞLI: ilk yükleme yapıldı.
      expect(gw.randomListCalls, 1);
      await bitir(tester);
    });

    testWidgets('liste ALINAMADI (null) şeridi KALDIRMAZ: eldeki korunur',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'a')];
      var t = DateTime.utc(2026, 10, 4, 12).millisecondsSinceEpoch;
      await setPhoneViewSize(tester, const Size(420, 900));
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: RandomGamesStrip(
              repo: repoOf(gw),
              onlineStatus: OnlineStatus.fake(),
              userId: 'me',
              myGameIds: const [],
              onOpenCreate: () {},
              onAccepted: (_) {},
              onNotice: (_) {},
              nowMs: () => t,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(kart('a'), findsOneWidget);
      // Sonraki yoklama düşer → şerit yerinde kalır.
      gw.randomListFails = true;
      t += 41000;
      await tester.pump(kRandomStripPoll);
      await tester.pump();
      expect(kart('a'), findsOneWidget,
          reason: 'null = bilmiyoruz; boşla ezmek şeridi sessizce kaldırırdı');
      // Sunucu gerçekten boş derse şerit kalkar.
      gw
        ..randomListFails = false
        ..randomRows = [];
      t += 41000;
      await tester.pump(kRandomStripPoll);
      await tester.pump();
      expect(kart('a'), findsNothing);
      await bitir(tester);
    });

    testWidgets('başlıktaki "Rastgele oyun aç" kurulum ekranını açar',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'a')];
      await pumpTab(tester, servis('serit-ac', gw));
      await tester.tap(find.text('Rastgele oyun aç'));
      await tester.pumpAndSettle();
      expect(find.byType(LiveGameCreateForm), findsOneWidget);
      await bitir(tester);
    });

    testWidgets(
        'KABUL: onay sorulmaz, ileti sonuca göre; ilan şeritten '
        'hemen kalkar', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'a'), randomListingRow(id: 'b')];
      gw.onAcceptRandom =
          (id) => gw.randomRows.removeWhere((r) => r['id'] == id);
      await pumpTab(tester, servis('kabul1', gw));
      await tester.tap(find.descendant(
          of: kart('a'), matching: find.widgetWithText(NeoButton, 'KABUL')));
      await tester.pumpAndSettle();
      expect(gw.acceptedRandom, ['a']);
      expect(find.text('Kabul ettin. Diğer oyuncular bekleniyor.'),
          findsOneWidget);
      expect(kart('a'), findsNothing);
      expect(kart('b'), findsOneWidget);

      // Oyun doluysa (2 kişilik): "Oyun başladı."
      gw.acceptRandomResult = {
        'joined': true,
        'game_id': 'b',
        'started': true,
        'seat': 1,
      };
      await tester.tap(find.descendant(
          of: kart('b'), matching: find.widgetWithText(NeoButton, 'KABUL')));
      await tester.pumpAndSettle();
      expect(find.text('Kabul ettin. Oyun başladı.'), findsOneWidget);
      await bitir(tester);
    });

    testWidgets(
        'KABUL reddi (ör. "Bu oyun doldu."): sunucunun Türkçe metni '
        'olduğu gibi, ham hata YOK; şerit tazelenir', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'a')]
        ..acceptRandomError =
            const PostgrestException(message: 'Bu oyun doldu.', code: 'P0001');
      await pumpTab(tester, servis('kabul-red', gw));
      final once = gw.randomListCalls;
      await tester.tap(find.descendant(
          of: kart('a'), matching: find.widgetWithText(NeoButton, 'KABUL')));
      await tester.pumpAndSettle();
      expect(find.text('Bu oyun doldu.'), findsOneWidget);
      expect(find.textContaining('PostgrestException'), findsNothing);
      expect(gw.randomListCalls, greaterThan(once),
          reason: 'başarısızlıkta da şerit tazelenmeli');
      await bitir(tester);
    });

    testWidgets('ham sunucu hatası ekrana DÜŞMEZ (friendlyErrorMessage)',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'a')]
        ..acceptRandomError = const PostgrestException(
            message: '{"message":"Gateway Timeout"}', code: '504');
      await pumpTab(tester, servis('kabul-504', gw));
      await tester.tap(find.descendant(
          of: kart('a'), matching: find.widgetWithText(NeoButton, 'KABUL')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Gateway Timeout'), findsNothing);
      expect(
          find.textContaining('Sunucuya şu anda ulaşılamıyor'), findsOneWidget);
      await bitir(tester);
    });

    testWidgets('benim ilanlarımın id\'si şeritte tekrar gösterilmez',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..randomRows = [randomListingRow(id: 'x', creatorId: 'baska')]
        ..myRandomRows = [
          myRandomRow(id: 'x', myRole: 'random', playerCount: 4)
        ];
      await pumpTab(tester, servis('serit-benim', gw));
      expect(kart('x'), findsNothing);
      await bitir(tester);
    });
  });

  group('yoklama (Realtime YOK — RLS)', () {
    Future<void> pumpStrip(WidgetTester tester, FakeOnlineGamesGateway gw,
        {required int Function() nowMs, bool online = true}) async {
      await setPhoneViewSize(tester, const Size(420, 900));
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: RandomGamesStrip(
              repo: repoOf(gw),
              onlineStatus: OnlineStatus.fake(online: online),
              userId: 'me',
              myGameIds: const [],
              onOpenCreate: () {},
              onAccepted: (_) {},
              onNotice: (_) {},
              nowMs: nowMs,
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets(
        '~40 sn\'de bir yoklar; arka plandayken İSTEK ATILMAZ, öne '
        'dönünce bir kez', (tester) async {
      addTearDown(() => tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      var t = DateTime.utc(2026, 10, 4, 12).millisecondsSinceEpoch;
      final gw = FakeOnlineGamesGateway();
      await pumpStrip(tester, gw, nowMs: () => t);
      expect(gw.randomListCalls, 1, reason: 'açılışta bir yükleme');

      t += 41000;
      await tester.pump(kRandomStripPoll);
      expect(gw.randomListCalls, 2, reason: '40 sn dolunca yoklar');

      // Arka plan: zamanlayıcı çalışsa da istek ATILMAZ.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t += 41000;
      await tester.pump(kRandomStripPoll);
      expect(gw.randomListCalls, 2,
          reason: 'ekran görünür değilken istek atılmamalı');

      // Öne dönüş: bir kez yoklar.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(gw.randomListCalls, 3);

      // En az 8 sn aralık: hemen ardından tekrar dönüş yoklamaz.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(gw.randomListCalls, 3,
          reason: 'alt aralık (8 sn) dolmadan tekrar yoklamamalı');
      await bitir(tester);
    });

    testWidgets('çevrimdışıyken yoklanmaz', (tester) async {
      final gw = FakeOnlineGamesGateway();
      var t = DateTime.utc(2026, 10, 4, 12).millisecondsSinceEpoch;
      await pumpStrip(tester, gw, nowMs: () => t, online: false);
      t += 41000;
      await tester.pump(kRandomStripPoll);
      expect(gw.randomListCalls, 0);
      await bitir(tester);
    });
  });

  group('"Bekliyor n/N" satırları + dört kova', () {
    testWidgets(
        'kurucu: Devam Edenler\'de "Bekliyor 1/2" + "İlanı iptal et"; açık '
        'koltuk "?" kesikli çerçeve, ASLA "Yapay Zeka"; Oyun Davetleri\'nde '
        'AYNI oyun GÖRÜNMEZ', (tester) async {
      final maskeliSlots = [
        slotHuman('kurucu1', name: 'Ironman', relation: 'self'),
        slotOpenMasked,
      ];
      final gw = FakeOnlineGamesGateway()
        ..rows = [
          gameRow(
              id: 'k1',
              myId: 'kurucu1',
              createdBy: 'kurucu1',
              status: 'pending',
              myRole: 'creator',
              slots: maskeliSlots),
        ]
        ..myRandomRows = [
          myRandomRow(id: 'k1', slots: [
            slotHuman('kurucu1', name: 'Ironman', relation: 'self'),
            slotOpen,
          ]),
        ];
      await pumpTab(tester, servis('kurucu1', gw));

      expect(find.text('DEVAM EDEN OYUNLAR'), findsOneWidget);
      expect(find.text('BEKLİYOR 1/2'), findsOneWidget);
      expect(find.text('Rastgele oyuncu bekleniyor'), findsOneWidget);
      expect(find.text('İlanı iptal et'), findsOneWidget);
      expect(find.byType(OpenSeatAvatar), findsOneWidget);
      expect(find.textContaining('Yapay Zeka'), findsNothing);
      expect(find.text('Devam eden bir Canlı oyunun yok.'), findsNothing);

      // Oyun Davetleri sekmesi: aynı oyun YOK (dört kova dersi).
      await tester.tap(find.text('OYUN DAVETLERİ'));
      await tester.pump();
      expect(find.text('Bekleyen bir davet ya da oyunun yok.'), findsOneWidget);
      expect(find.text('BEKLEYEN OYUNLAR'), findsNothing);
      await bitir(tester);
    });

    testWidgets('"İlanı iptal et": cancel_random_game, ileti, liste tazelenir',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..myRandomRows = [myRandomRow(id: 'k1')];
      gw.onCancelRandom = (id) => gw.myRandomRows.clear();
      await pumpTab(tester, servis('iptal1', gw));
      expect(find.text('BEKLİYOR 1/2'), findsOneWidget);
      await tester.tap(find.text('İlanı iptal et'));
      await tester.pumpAndSettle();
      expect(gw.cancelledRandom, ['k1']);
      expect(gw.leftRandom, isEmpty);
      expect(find.text('İlan iptal edildi.'), findsOneWidget);
      expect(find.text('BEKLİYOR 1/2'), findsNothing);
      await bitir(tester);
    });

    testWidgets(
        'kabul eden: "Bekliyor 2/4" + "Ayrıl" → leave_random_game '
        '(ceza yok), "Kabul Ettin" kovasında GÖRÜNMEZ', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..rows = [
          gameRow(
              id: 'r1',
              myId: 'kabul2',
              createdBy: 'baska',
              playerCount: 4,
              status: 'pending',
              myRole: 'invitee',
              myInviteStatus: 'accepted',
              myInviteId: 'i-r1',
              slots: [
                slotHuman('baska', name: 'Baska', relation: 'accepted'),
                slotHuman('kabul2',
                    name: 'Ironman',
                    relation: 'self',
                    inviteStatus: 'accepted'),
                slotOpenMasked,
                slotOpenMasked,
              ]),
        ]
        ..myRandomRows = [
          myRandomRow(id: 'r1', myRole: 'random', playerCount: 4, slots: [
            slotHuman('baska', name: 'Baska', relation: 'accepted'),
            {
              ...slotHuman('kabul2', name: 'Ironman', relation: 'self'),
              'via': 'random'
            },
            slotOpen,
            slotOpen,
          ]),
        ];
      gw.onLeaveRandom = (id) => gw.myRandomRows.clear();
      await pumpTab(tester, servis('kabul2', gw));
      expect(find.text('BEKLİYOR 2/4'), findsOneWidget);
      expect(find.text('Ayrıl'), findsOneWidget);
      expect(find.byType(OpenSeatAvatar), findsNWidgets(2));
      await tester.tap(find.text('OYUN DAVETLERİ'));
      await tester.pump();
      expect(find.textContaining('KABUL ETTİN'), findsNothing);
      await tester.tap(find.text('DEVAM EDENLER'));
      await tester.pump();
      await tester.tap(find.text('Ayrıl'));
      await tester.pumpAndSettle();
      expect(gw.leftRandom, ['r1']);
      expect(find.text('Ayrıldın. Koltuk yeniden açıldı.'), findsOneWidget);
      await bitir(tester);
    });

    testWidgets('sunucu reddi (ayrılırken): Türkçe metin, liste yine tazelenir',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..myRandomRows = [myRandomRow(id: 'r1', myRole: 'random')]
        ..leaveRandomError = const PostgrestException(
            message: 'Oyun başladı, ayrılamazsın.', code: 'P0001');
      await pumpTab(tester, servis('ayril-red', gw));
      final once = gw.myRandomCalls;
      await tester.tap(find.text('Ayrıl'));
      await tester.pumpAndSettle();
      expect(find.text('Oyun başladı, ayrılamazsın.'), findsOneWidget);
      expect(gw.myRandomCalls, greaterThan(once));
      await bitir(tester);
    });

    testWidgets(
        'KARMA kadro: arkadaş daveti BUGÜNKÜ davet akışında kalır ("?" satırı '
        '"Rastgele oyuncu bekleniyor", "Yapay Zeka" yalnız GERÇEK YZ için); '
        'Bekliyor satırı YOK', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..rows = [
          gameRow(
              id: 'f1',
              myId: 'karma1',
              createdBy: 'kurucu',
              playerCount: 4,
              status: 'pending',
              myRole: 'invitee',
              myInviteStatus: 'pending',
              myInviteId: 'i-f1',
              slots: [
                slotHuman('kurucu', name: 'Kurucu', relation: 'accepted'),
                slotHuman('karma1',
                    name: 'Ironman', relation: 'self', inviteStatus: 'pending'),
                slotOpenMasked,
                slotAi,
              ]),
        ]
        ..myRandomRows = [
          myRandomRow(id: 'f1', myRole: 'friend', playerCount: 4),
        ];
      await pumpTab(tester, servis('karma1', gw));
      // Varsayılan alt sekme: bekleyen davet varsa "Oyun Davetleri".
      // (Dart `toUpperCase` Türkçe i/İ'yi bilmez — literal yazıldı.)
      expect(find.text('DAVET BEKLİYOR'), findsOneWidget);
      expect(find.text('Rastgele oyuncu bekleniyor'), findsOneWidget);
      // Yapay Zeka satırı tek ve GERÇEK koltuk için.
      expect(find.text('Yapay Zeka'), findsOneWidget);
      expect(find.byType(OpenSeatAvatar), findsOneWidget);
      // Kabul/Reddet bugünkü gibi.
      expect(find.text('KABUL ET'), findsOneWidget);
      await tester.tap(find.text('DEVAM EDENLER'));
      await tester.pump();
      expect(find.textContaining('BEKLİYOR'), findsNothing);
      await bitir(tester);
    });

    testWidgets(
        'ilan listesi ALINAMADI (null): açık koltuklu kurucu oyunu yine de '
        '"Bekleyen Oyunlar"a düşmez; liste bilgisi yoksa davet kaybolmaz',
        (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..myRandomNetFailFirst = 999
        ..rows = [
          gameRow(
              id: 'k1',
              myId: 'null1',
              createdBy: 'null1',
              status: 'pending',
              myRole: 'creator',
              slots: [
                slotHuman('null1', name: 'Ironman', relation: 'self'),
                slotOpenMasked,
              ]),
          // Açık koltuksuz kurucu oyunu: bugünkü "Bekleyen Oyunlar".
          gameRow(
              id: 'w1',
              myId: 'null1',
              createdBy: 'null1',
              status: 'pending',
              myRole: 'creator',
              slots: [
                slotHuman('null1', name: 'Ironman', relation: 'self'),
                slotHuman('arkadas', name: 'Arkadaş', inviteStatus: 'pending'),
              ]),
        ];
      await pumpTab(tester, servis('null1', gw));
      await tester.tap(find.text('OYUN DAVETLERİ'));
      await tester.pump();
      expect(find.text('BEKLEYEN OYUNLAR'), findsOneWidget);
      expect(find.byKey(const ValueKey('w-w1')), findsOneWidget);
      expect(find.byKey(const ValueKey('w-k1')), findsNothing,
          reason: 'açık koltuklu oyunu yalnız ilan RPC\'si açar → KESİN');
      await bitir(tester);
    });

    testWidgets(
        'biten/dolup başlayan oyun normal oyun gibi "Devam Eden '
        'Oyunlar"da (çift satır yok)', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..rows = [gameRow(id: 'a1', myId: 'dolu1', status: 'active')]
        ..turnRows = [
          {'online_game_id': 'a1', 'current': 1}
        ]
        ..myRandomRows = [
          myRandomRow(id: 'a1', status: 'active'),
        ];
      await pumpTab(tester, servis('dolu1', gw));
      expect(find.text('DEVAM EDEN OYUNLAR'), findsOneWidget);
      expect(find.textContaining('BEKLİYOR'), findsNothing);
      expect(find.textContaining('SIRA SENDE'), findsOneWidget);
      await bitir(tester);
    });

    testWidgets(
        'süresi dolmuş ilan (expires_at geçmiş) check_invite_expiry '
        'ile süpürülür', (tester) async {
      final gw = FakeOnlineGamesGateway()
        ..myRandomRows = [
          myRandomRow(
              id: 'eski',
              expiresAt: DateTime.now()
                  .toUtc()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String()),
        ];
      gw.onCheckInviteExpiry = (id) => gw.myRandomRows.clear();
      await pumpTab(tester, servis('suresi1', gw));
      expect(gw.inviteExpiryChecks, contains('eski'));
      expect(find.text('BEKLİYOR 1/2'), findsNothing);
      await bitir(tester);
    });
  });

  group('kurulum formu — Rastgele Oyuncu', () {
    Future<
            ({
              FakeOnlineGamesGateway gw,
              List<bool> created,
            })>
        pumpForm(WidgetTester tester,
            {List<Map<String, Object?>>? friendsRows}) async {
      await setPhoneViewSize(tester, const Size(420, 900));
      final gw = FakeOnlineGamesGateway();
      final fgw = FakeFriendsGateway(currentUserId: 'me')
        ..friendsRows = friendsRows ??
            [
              {'friend_id': 'f1', 'name': 'Bobola', 'avatar_url': null},
              {'friend_id': 'f2', 'name': 'Esiner', 'avatar_url': null},
            ];
      final created = <bool>[];
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LiveGameCreateForm(
              auth: AuthService.fake(user: fakeUser('me')),
              friends: FriendsRepo(fgw),
              onlineGames: repoOf(gw),
              onCancel: () {},
              onCreated: () => created.add(true),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      return (gw: gw, created: created);
    }

    final satir = find.byKey(const ValueKey('rastgele-satir'));
    Finder koltuk(int i) => find.byKey(ValueKey('koltuk-rastgele-$i'));

    testWidgets(
        'satır arkadaş listesinin İÇİNDE, ilk satır (ayrı bölüm DEĞİL); '
        'alt yazı ve "?" avatarı', (tester) async {
      await pumpForm(tester);
      expect(satir, findsOneWidget);
      expect(find.text('Rastgele Oyuncu'), findsOneWidget);
      expect(
          find.text('Bunu seçerseniz rasgele oyun açarsınız.'), findsOneWidget);
      expect(find.descendant(of: satir, matching: find.byType(OpenSeatAvatar)),
          findsOneWidget);
      // Kullanıcı (4 Ekim 2026): "diğer arkadaşlar gibi listenin en üstüne,
      // ayrı bir bölümde değil" → arama kutusunun ALTINDA, kaydırılan listenin
      // ilk satırı; arkadaş satırlarıyla AYNI kaydırma alanında.
      expect(tester.getTopLeft(satir).dy,
          greaterThan(tester.getTopLeft(find.byType(TextField)).dy));
      final friend1 = find.byKey(const ValueKey('friend-f1'));
      expect(
          tester.getTopLeft(satir).dy, lessThan(tester.getTopLeft(friend1).dy));
      expect(
          find.ancestor(
              of: satir, matching: find.byType(SingleChildScrollView)),
          findsWidgets);
      expect(
          find.ancestor(
              of: friend1, matching: find.byType(SingleChildScrollView)),
          findsWidgets);
    });

    testWidgets(
        'arama kutusuna yazınca satır KAYBOLMAZ; "Tüm oyuncular" '
        've hiç arkadaşı olmayan hesapta da görünür', (tester) async {
      await pumpForm(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(satir, findsOneWidget);
      await tester.tap(find.text(kLiveFormToAll));
      await tester.pumpAndSettle();
      expect(satir, findsOneWidget);
    });

    testWidgets('hiç arkadaşı olmayan hesapta satır görünür', (tester) async {
      await pumpForm(tester, friendsRows: const []);
      expect(satir, findsOneWidget);
      expect(find.text('Henüz hiç arkadaşın yok.'), findsOneWidget);
    });

    testWidgets(
        '2 kişi: dokun → "?" koltuğu; ikinci dokunuş GERİ ALIR; arkadaş '
        '"?" yerine geçer; koltuğa dokunmak boşaltır', (tester) async {
      await pumpForm(tester);
      await tester.tap(satir);
      await tester.pump();
      expect(koltuk(0), findsOneWidget);
      expect(find.text('Rastgele oyuncu'), findsOneWidget);
      expect(find.byKey(const ValueKey('rastgele-adet')), findsOneWidget);
      expect(find.text('×1'), findsOneWidget);
      await tester.tap(satir);
      await tester.pump();
      expect(koltuk(0), findsNothing,
          reason: '"?" seçiliyken tekrar dokunuş geri alır');
      expect(find.text('×1'), findsNothing);
      await tester.tap(satir);
      await tester.pump();
      expect(koltuk(0), findsOneWidget);
      // Arkadaşa dokun → "?" yerine arkadaş.
      await tester.tap(find.byKey(const ValueKey('friend-f1')));
      await tester.pump();
      expect(koltuk(0), findsNothing);
      expect(find.byKey(const ValueKey('koltuk-dolu-0')), findsOneWidget);
      // Tekrar "?" → arkadaşın yerine "?".
      await tester.tap(satir);
      await tester.pump();
      expect(koltuk(0), findsOneWidget);
      expect(find.byKey(const ValueKey('koltuk-dolu-0')), findsNothing);
      // "?" koltuk kartına dokun → seçim kalkar.
      await tester.tap(koltuk(0));
      await tester.pump();
      expect(koltuk(0), findsNothing);
      expect(find.byKey(const ValueKey('rastgele-adet')), findsNothing);
    });

    testWidgets(
        '4 kişi: her dokunuş bir koltuk (×N), ×3 sonrası dokunuş geri alır; tek seçimde gönder '
        'KAPALI, tam 2 seçimde 3. koltuk "Yapay Zeka", 3 seçimde YZ YOK',
        (tester) async {
      final h = await pumpForm(tester);
      await tester.tap(find.text('4 KİŞİ'));
      await tester.pump();
      await tester.tap(satir);
      await tester.pump();
      NeoButton gonder() => tester
          .widget<NeoButton>(find.widgetWithText(NeoButton, 'DAVET GÖNDER'));
      expect(gonder().onPressed, isNull, reason: 'tek seçim: kapalı');
      await tester.tap(satir);
      await tester.pump();
      expect(find.text('×2'), findsOneWidget);
      expect(gonder().onPressed, isNotNull);
      expect(find.text(kLiveFormAiSeat), findsOneWidget,
          reason: 'tam 2 seçimde boş 4. koltuk Yapay Zeka');
      await tester.tap(satir);
      await tester.pump();
      expect(find.text('×3'), findsOneWidget);
      expect(find.text(kLiveFormAiSeat), findsNothing);
      // Dördüncü dokunuş: boş koltuk kalmadı → tüm "?" geri alınır (4 Ekim 2026).
      await tester.tap(satir);
      await tester.pump();
      expect(find.text('×3'), findsNothing);
      expect(find.text('×1'), findsNothing);
      expect(gonder().onPressed, isNull, reason: 'seçim boşaldı: kapalı');
      expect(h.gw.createdRandom, isEmpty);
    });

    testWidgets(
        '"Biri kabul edince" ipucu YALNIZ "?" varken; yoksa '
        '"Arkadaşın"', (tester) async {
      await pumpForm(tester);
      expect(find.textContaining('Arkadaşın kabul edince'), findsOneWidget);
      await tester.tap(satir);
      await tester.pump();
      expect(find.textContaining('Biri kabul edince'), findsWidgets);
      expect(find.textContaining('Arkadaşın kabul edince'), findsNothing);
    });

    testWidgets(
        'DAVET GÖNDER (4 kişi, 2×"?"): create_random_game, slotlar '
        'doğru, "İlanın yayında" ekranı; create_online_game ÇAĞRILMAZ',
        (tester) async {
      final h = await pumpForm(tester);
      await tester.tap(find.text('4 KİŞİ'));
      await tester.pump();
      await tester.tap(satir);
      await tester.tap(satir);
      await tester.pump();
      await tester.tap(find.text('DAVET GÖNDER'));
      await tester.pumpAndSettle();
      expect(h.gw.createdCounts, isEmpty,
          reason: 'create_online_game açık koltuk KABUL ETMEZ');
      expect(h.gw.createdRandom.single.$1, 4);
      expect(h.gw.createdRandom.single.$2, [
        {'type': 'human', 'user_id': 'me'},
        {'type': 'open'},
        {'type': 'open'},
        {'type': 'ai'},
      ]);
      expect(find.text('İlanın yayında'), findsOneWidget);
      expect(find.textContaining('7 gün içinde dolmazsa kendiliğinden kalkar'),
          findsOneWidget);
      expect(find.textContaining('4. koltuk Yapay Zeka.'), findsOneWidget);
      expect(find.text(kLiveFormSentTitle), findsNothing);
      // Yalnız "?" + YZ: davetlisi yok → bildirim YOK.
      expect(h.gw.notified, isEmpty);
      await tester.tap(find.text('OYUNLARIMA GİT'));
      await tester.pump();
      expect(h.created, [true]);
    });

    testWidgets('uygun ilan vardı: "Oyuna katıldın" (joined), bildirim YOK',
        (tester) async {
      final h = await pumpForm(tester);
      h.gw.createRandomResult = {
        'joined': true,
        'game_id': 'var-olan',
        'started': true,
      };
      await tester.tap(satir);
      await tester.pump();
      await tester.tap(find.text('DAVET GÖNDER'));
      await tester.pumpAndSettle();
      expect(find.text('Oyuna katıldın'), findsOneWidget);
      expect(find.text('Uygun bir ilan vardı, ona katıldın. Oyun başladı.'),
          findsOneWidget);
      expect(h.gw.notified, isEmpty);
    });

    testWidgets(
        'karma kadro (arkadaş + "?" + YZ): davet bildirimi gider, '
        'ekranda davet gönderilen isim', (tester) async {
      final h = await pumpForm(tester);
      await tester.tap(find.text('4 KİŞİ'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('friend-f1')));
      await tester.tap(satir);
      await tester.pump();
      await tester.tap(find.text('DAVET GÖNDER'));
      await tester.pumpAndSettle();
      expect(h.gw.createdRandom.single.$2, [
        {'type': 'human', 'user_id': 'me'},
        {'type': 'human', 'user_id': 'f1'},
        {'type': 'open'},
        {'type': 'ai'},
      ]);
      expect(h.gw.notified, ['ilan-1']);
      expect(find.textContaining('Davet gönderilen: Bobola.'), findsOneWidget);
    });

    testWidgets(
        '"?" YOKKEN akış bugünküyle AYNI (create_online_game, '
        '"Davetin gönderildi")', (tester) async {
      final h = await pumpForm(tester);
      await tester.tap(find.byKey(const ValueKey('friend-f1')));
      await tester.pump();
      await tester.tap(find.text('DAVET GÖNDER'));
      await tester.pumpAndSettle();
      expect(h.gw.createdRandom, isEmpty);
      expect(h.gw.createdCounts, [2]);
      expect(find.text(kLiveFormSentTitle), findsOneWidget);
      expect(find.text(kLiveFormSentNote), findsOneWidget);
    });

    testWidgets(
        'sunucunun Türkçe reddi (3 sınırı / önce bir oyun bitir) '
        'formda görünür, ham hata değil', (tester) async {
      final h = await pumpForm(tester);
      h.gw.createRandomError = const PostgrestException(
          message: 'En fazla 3 rastgele oyunun olabilir.', code: 'P0001');
      await tester.tap(satir);
      await tester.pump();
      await tester.tap(find.text('DAVET GÖNDER'));
      await tester.pumpAndSettle();
      expect(find.text('En fazla 3 rastgele oyunun olabilir.'), findsOneWidget);
      expect(find.text('İlanın yayında'), findsNothing);
    });
  });
}
