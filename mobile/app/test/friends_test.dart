// Arkadaşlık sistemi parçası — FriendsRepo (sahte gateway), davet linki
// çözümleme/kuyruklama (FriendInviteInbox + gerçek SQLite ffi), FriendsModal
// sekmeleri/varsayılan-sekme kuralı/ilişki yamaları, AccountButton rozeti ve
// PlayerScoreCard arkadaşlık simgesi. Gerçek RPC'ler/RLS cihazda
// doğrulanacak (mobile/TESTING.md, "Arkadaşlar").
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/auth_service.dart';
import 'package:kelimeki/src/data/chat_api.dart';
import 'package:kelimeki/src/ui/theme.dart';
import 'package:kelimeki/src/ui/tokens.dart';
import 'package:kelimeki/src/data/friend_invite_inbox.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/rank/rank_seal.dart';
import 'package:kelimeki/src/storage/app_storage.dart';
import 'package:kelimeki/src/storage/pending_event_store.dart';
import 'package:kelimeki/src/util/offline_notice.dart' show isNetworkError;
import 'package:kelimeki/src/ui/auth/account_button.dart';
import 'package:kelimeki/src/ui/auth/k_avatar.dart';
import 'package:kelimeki/src/ui/friends/friends_modal.dart';
import 'package:kelimeki/src/ui/game/dialog_shell.dart';
import 'package:kelimeki/src/util/friend_since.dart';
import 'package:kelimeki/src/util/live_game_request.dart';
import 'package:kelimeki/src/ui/friends/relation_icons.dart';
import 'package:kelimeki/src/ui/score/player_score_card_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show User, PostgrestException;

import 'package:kelimeki/src/data/analytics.dart';
import 'support/fake_analytics.dart';
import 'support/fake_online_gateway.dart';
import 'support/test_fonts.dart';
import 'support/test_view.dart';

int _dbSeq = 0;

/// feedback_test'teki aynı izolasyon kararı: benzersiz temp dosya yolu —
/// inMemoryDatabasePath açık kaldıkça testler arasında paylaşılır.
Future<AppStorage> openTestStorage() async {
  SharedPreferences.setMockInitialValues({});
  final dir = Directory.systemTemp.createTempSync('kelimeki-fr-test');
  return AppStorage.open(
    factory: databaseFactoryFfi,
    path: '${dir.path}/t${_dbSeq++}.db',
    prefs: await SharedPreferences.getInstance(),
    nowMs: () => DateTime.now().millisecondsSinceEpoch,
  );
}

class FakeFriendsGateway implements FriendsGateway {
  @override
  String? currentUserId = 'me';

  List<Map<String, Object?>> friendsRows = [];
  List<Map<String, Object?>> requestRows = [];
  List<Map<String, Object?>> userRows = [];
  Map<String, Object?>? relation;
  String sendResult = 'pending';
  final notified = <String>[];
  final accepted = <String>[];
  final deleted = <String>[];
  final acceptedInvites = <String>[];
  Object? failWith;

  void _maybeFail() {
    final f = failWith;
    if (f != null) throw f;
  }

  @override
  Future<List<Map<String, Object?>>> searchUsers(String query) async {
    _maybeFail();
    return userRows;
  }

  @override
  Future<List<Map<String, Object?>>> listUsers(int offset, int limit) async {
    _maybeFail();
    return userRows.skip(offset).take(limit).toList();
  }

  @override
  Future<String> sendRequest(String targetId) async {
    _maybeFail();
    return sendResult;
  }

  @override
  Future<void> notifyFriendRequest(String friendId) async {
    notified.add(friendId);
  }

  @override
  Future<void> acceptRequest(String requesterId) async {
    _maybeFail();
    accepted.add(requesterId);
  }

  @override
  Future<void> deleteRelation(String otherId) async {
    _maybeFail();
    deleted.add(otherId);
  }

  @override
  Future<List<Map<String, Object?>>> listFriends() async {
    _maybeFail();
    return friendsRows;
  }

  @override
  Future<List<Map<String, Object?>>> listIncomingRequests() async {
    _maybeFail();
    return requestRows;
  }

  @override
  Future<Map<String, Object?>?> relationRow(String targetId) async {
    _maybeFail();
    return relation;
  }

  @override
  Future<String?> createInviteToken() async {
    _maybeFail();
    return 'tok-123';
  }

  @override
  Future<String?> inviteInfo(String token) async {
    _maybeFail();
    return 'Ironman';
  }

  @override
  Future<String?> acceptInvite(String token) async {
    _maybeFail();
    acceptedInvites.add(token);
    return 'Ironman';
  }

  @override
  Future<List<String>> frequentOpponents(int limit) async => const [];

  List<Map<String, Object?>> outgoingRows = [];
  @override
  Future<List<Map<String, Object?>>> listOutgoingRequests() async {
    _maybeFail();
    return outgoingRows;
  }
}

User fakeUser() => User(
      id: 'me',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
      email: 'alp.capa@hotmail.com',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  setUpAll(loadAppFonts);

  group('parseInviteToken', () {
    test('iki geçerli biçim + negatifler', () {
      expect(parseInviteToken(Uri.parse('kelimeki://davet/abc123')), 'abc123');
      expect(parseInviteToken(Uri.parse('https://kelimeki.com/davet/abc123')),
          'abc123');
      expect(parseInviteToken(Uri.parse('http://kelimeki.com/davet/t')), 't');
      // Auth callback'leri ve alakasız yollar davet DEĞİL.
      expect(parseInviteToken(Uri.parse('kelimeki://reset?code=xyz')), isNull);
      expect(
          parseInviteToken(Uri.parse('https://kelimeki.com/game/abc')), isNull);
      expect(
          parseInviteToken(Uri.parse('https://ornek.com/davet/abc')), isNull);
      expect(parseInviteToken(Uri.parse('kelimeki://davet/')), isNull);
      expect(parseInviteToken(Uri.parse('kelimeki://davet/a/b')), isNull);
    });

    test('buildInviteUrl web biçimiyle birebir — `?ref=arkadas` DAHİL', () {
      // Etiket ZORUNLU (21 Ağustos 2026, ROADMAP #7): olmadan davetle gelip
      // üye olan herkes admin panelindeki Kaynak Hunisi'nde `direkt` satırına
      // düşüyor ve gerçek doğrudan trafiği şişiriyor. Web'in
      // `FriendsModal.tsx`'indeki aynı fonksiyonla birebir olmak zorunda.
      expect(
          buildInviteUrl('tok'), 'https://kelimeki.com/davet/tok?ref=arkadas');
      // Etiketli link uygulamaya düşerse token yine doğru çözülmeli —
      // `uri.pathSegments` sorgu dizesini içermez.
      expect(parseInviteToken(Uri.parse(buildInviteUrl('tok'))), 'tok');
    });
  });

  group('FriendInviteInbox', () {
    test('davet URI kuyruklanır + haber verilir; alakasız URI yok sayılır',
        () async {
      final storage = openTestStorage();
      final inbox = FriendInviteInbox(storage);
      var notified = 0;
      inbox.addListener(() => notified++);

      // handleUri doğrudan await edilir (stream dinleyicisi aynı metoda
      // delege ediyor; gerçek dosya IO'lu storage açılışını sabit bir
      // gecikmeyle beklemek uçucu çıkmıştı).
      await inbox.handleUri(Uri.parse('kelimeki://reset?code=x')); // auth
      await inbox.handleUri(Uri.parse('kelimeki://davet/tok-1'));

      expect(notified, 1);
      expect(inbox.lastToken, 'tok-1');
      final s = await storage;
      final events = await s.events.takeAll(friendInviteTokenKind);
      expect(events, hasLength(1));
      expect(events.single['token'], 'tok-1');
      inbox.dispose();
    });
  });

  group('FriendsRepo', () {
    test('listeler trCompare ile sıralanır; hata null döner', () async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'çiğdem', 'avatar_url': null},
          {'friend_id': 'b', 'name': 'Ali', 'avatar_url': null},
          {'friend_id': 'c', 'name': 'ümit', 'avatar_url': null},
        ];
      final repo = FriendsRepo(gw);
      final friends = await repo.friends();
      expect([for (final f in friends!) f.name], ['Ali', 'çiğdem', 'ümit']);

      gw.failWith = Exception('ağ');
      expect(await repo.friends(), isNull);
      expect(await repo.search('ab'), isNull);
      expect(await repo.incomingRequests(), isNull);
    });

    test('sendRequest: pending → bildirim; accepted → bildirim YOK', () async {
      final gw = FakeFriendsGateway()..sendResult = 'pending';
      final repo = FriendsRepo(gw);
      expect(await repo.sendRequest('u1'), FriendRelation.pendingOutgoing);
      await Future<void>.delayed(Duration.zero);
      expect(gw.notified, ['u1']);

      gw.sendResult = 'accepted';
      expect(await repo.sendRequest('u2'), FriendRelation.accepted);
      await Future<void>.delayed(Duration.zero);
      expect(gw.notified, ['u1']); // u2 için bildirim gitmedi
    });

    test('relationWith: yön doğru çözülür; kendi kartında null', () async {
      final gw = FakeFriendsGateway();
      final repo = FriendsRepo(gw);
      expect(await repo.relationWith('me'), isNull); // kendisi

      gw.relation = {'user_id': 'me', 'status': 'pending'};
      expect(await repo.relationWith('u1'), FriendRelation.pendingOutgoing);
      gw.relation = {'user_id': 'u1', 'status': 'pending'};
      expect(await repo.relationWith('u1'), FriendRelation.pendingIncoming);
      gw.relation = {'user_id': 'u1', 'status': 'accepted'};
      expect(await repo.relationWith('u1'), FriendRelation.accepted);
      gw.relation = null;
      expect(await repo.relationWith('u1'), isNull);
    });
  });

  // 1 Ekim 2026 — TEK EKRAN (ROADMAP #41 karar 22-24, web 27 Eylül). Sekme,
  // varsayılan-sekme kuralı ve ekle/kabul/reddet/iptal onayları KALKTI;
  // yalnızca "Arkadaşlıktan çıkar" onay soruyor.
  group('FriendsModal', () {
    setUp(liveGameRequests.reset);

    /// Pencere GERÇEK bir diyalog olarak açılır — OYNA onu `pop` ediyor.
    Future<FakeFriendsGateway> pumpModal(
      WidgetTester tester, {
      FakeFriendsGateway? gateway,
      FriendsTab? initialTab,
      Future<void> Function(String)? sharer,
      bool withStats = false,
      FakeChatGateway? chat,
      Size size = const Size(420, 900),
    }) async {
      await setPhoneViewSize(tester, size);
      final gw = gateway ?? FakeFriendsGateway();
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showFriendsModal(
                  ctx,
                  friends: FriendsRepo(gw),
                  auth: AuthService.fake(user: fakeUser()),
                  // stats yoksa isim/avatara dokunuş pasif (offline dalı).
                  stats: withStats ? StatsRepo(_NullStatsGateway()) : null,
                  // chat yoksa moderasyon durumu HİÇ çizilmez.
                  chat: chat == null ? null : ChatRepo(chat),
                  initialTab: initialTab,
                  sharer: sharer,
                ),
                child: const Text('aç'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('aç'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return gw;
    }

    Finder satirda(String key, Finder f) =>
        find.descendant(of: find.byKey(ValueKey(key)), matching: f);

    testWidgets('gelen istek kartı EN ÜSTTE; KABUL ET onaysız', (tester) async {
      final gw = FakeFriendsGateway()
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Esiner', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw);
      expect(find.text('İSTEKLER · 1'), findsOneWidget);
      expect(find.text(kFriendsIncomingMeta), findsOneWidget);
      // Davet düğmesinin ALTINDA, liste başlığının ÜSTÜNDE.
      expect(tester.getTopLeft(find.text('İSTEKLER · 1')).dy,
          greaterThan(tester.getTopLeft(find.text(kFriendsInviteCaption)).dy));
      expect(tester.getTopLeft(find.text('İSTEKLER · 1')).dy,
          lessThan(tester.getTopLeft(find.text('ARKADAŞLARIN')).dy));
      await tester.tap(satirda('request-r1', find.text('KABUL ET')));
      await tester.pumpAndSettle();
      expect(find.byType(KDialogCard), findsNothing, reason: 'onay YOK');
      expect(gw.accepted, ['r1']);
    });

    testWidgets('REDDET onaysız silme', (tester) async {
      final gw = FakeFriendsGateway()
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Esiner', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw);
      await tester.tap(find.text('REDDET'));
      await tester.pumpAndSettle();
      expect(find.byType(KDialogCard), findsNothing);
      expect(gw.deleted, ['r1']);
    });

    testWidgets('gönderdiğin istekler gelenlerin ALTINDA; GERİ AL onaysız',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Esiner', 'avatar_url': null},
        ]
        ..outgoingRows = [
          {'friend_id': 'o1', 'name': 'Tuna', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw);
      expect(find.text('GÖNDERDİĞİN İSTEKLER · 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('GÖNDERDİĞİN İSTEKLER · 1')).dy,
          greaterThan(tester.getTopLeft(find.text('İSTEKLER · 1')).dy));
      expect(
          satirda('sent-o1', find.text(kFriendsOutgoingMeta)), findsOneWidget);
      await tester.tap(satirda('sent-o1', find.text('GERİ AL')));
      await tester.pumpAndSettle();
      expect(gw.deleted, ['o1']);
      expect(find.text('GÖNDERDİĞİN İSTEKLER · 1'), findsNothing);
    });

    testWidgets(
        'arkadaş satırı: sayı başlıkta, "N haftadır", OYNA → pencere '
        'kapanır + 2 kişilik istek kuyruğa', (tester) async {
      final ucHaftaOnce = DateTime.now()
          .subtract(const Duration(days: 22))
          .toUtc()
          .toIso8601String();
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {
            'friend_id': 'a',
            'name': 'Bobola',
            'avatar_url': null,
            'since': ucHaftaOnce
          },
          {'friend_id': 'b', 'name': 'Esiner', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw);
      expect(find.text('ARKADAŞLARIN · 2'), findsOneWidget);
      expect(satirda('friend-a', find.text('3 haftadır')), findsOneWidget);
      await tester.tap(satirda('friend-a', find.text('OYNA')));
      await tester.pumpAndSettle();
      expect(find.byType(FriendsModal), findsNothing);
      final r = liveGameRequests.take();
      expect((r?.friendId, r?.playerCount), ('a', 2));
    });

    testWidgets('⋯ menüsü: 4 kişilik oyun kur → istek(4); çıkar → onay → silme',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Bobola', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw);
      await tester.tap(find.byKey(const ValueKey('more-a')));
      await tester.pumpAndSettle();
      for (final t in const [
        kFriendsMenuCard,
        kFriendsMenuPlay2,
        kFriendsMenuPlay4,
        kFriendsMenuRemove,
      ]) {
        expect(find.text(t), findsOneWidget);
      }
      // chat yok → moderasyon maddesi YOK.
      expect(find.text(kFriendsMenuModeration), findsNothing);

      // Çıkar: onay sorar; VAZGEÇ hiçbir şey yapmaz.
      await tester.tap(find.text(kFriendsMenuRemove));
      await tester.pumpAndSettle();
      expect(find.textContaining('Arkadaşlıktan çıkmak mı'), findsOneWidget);
      await tester.tap(find.text('VAZGEÇ'));
      await tester.pumpAndSettle();
      expect(gw.deleted, isEmpty);

      await tester.tap(find.byKey(const ValueKey('more-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kFriendsMenuRemove));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ÇIKAR').last);
      await tester.pumpAndSettle();
      expect(gw.deleted, ['a']);

      await tester.tap(find.byKey(const ValueKey('more-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kFriendsMenuPlay4));
      await tester.pumpAndSettle();
      expect(find.byType(FriendsModal), findsNothing);
      final r = liveGameRequests.take();
      expect((r?.friendId, r?.playerCount), ('a', 4));
    });

    testWidgets('boş liste: "Henüz arkadaşın yok" + açıklama', (tester) async {
      await pumpModal(tester);
      expect(find.text(kFriendsEmptyTitle), findsOneWidget);
      expect(find.text(kFriendsEmptyBody), findsOneWidget);
      expect(find.text('ARKADAŞLARIN'), findsOneWidget); // sayı yok
    });

    testWidgets(
        '"Tüm oyuncular →": başlıkta SAYI YOK; EKLE → İSTEK GİTTİ, '
        'KABUL ET → OYNA', (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'u2', 'name': 'Ali', 'avatar_url': null},
        ]
        ..userRows = [
          {'id': 'u1', 'name': 'Bobola', 'avatar_url': null, 'relation': null},
          {
            'id': 'u2',
            'name': 'Ali',
            'avatar_url': null,
            'relation': 'accepted'
          },
          {
            'id': 'u3',
            'name': 'Esiner',
            'avatar_url': null,
            'relation': 'pending_incoming'
          },
        ];
      await pumpModal(tester, gateway: gw);
      await tester.tap(find.text('Tüm oyuncular →'));
      await tester.pumpAndSettle();
      expect(find.text('TÜM OYUNCULAR'), findsOneWidget);
      expect(find.text('← Arkadaşlar'), findsOneWidget);
      // Arkadaş da listede (web: arkadaş olan/olmayan herkes) — OYNA ile.
      expect(satirda('user-u2', find.text('OYNA')), findsOneWidget);
      expect(satirda('user-u2', find.text('Arkadaşın')), findsOneWidget);

      await tester.tap(satirda('user-u1', find.text('EKLE')));
      await tester.pumpAndSettle();
      expect(find.byType(KDialogCard), findsNothing, reason: 'onay YOK');
      expect(gw.notified, ['u1']);
      expect(satirda('user-u1', find.text('İSTEK GİTTİ')), findsOneWidget);

      await tester.tap(satirda('user-u3', find.text('KABUL ET')));
      await tester.pumpAndSettle();
      expect(gw.accepted, ['u3']);
      expect(satirda('user-u3', find.text('OYNA')), findsOneWidget);
    });

    testWidgets('arama: sonuç sayısı satırı + boş sonuç metni', (tester) async {
      final gw = FakeFriendsGateway()
        ..userRows = [
          {'id': 'u1', 'name': 'Bobola', 'avatar_url': null, 'relation': null},
        ];
      await pumpModal(tester, gateway: gw);
      await tester.enterText(find.byType(TextField), 'bob');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.text('"bob" için 1 oyuncu'), findsOneWidget);
      gw.userRows = [];
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.text(kFriendsNobody), findsOneWidget);
    });

    testWidgets('isim/avatara dokunmak skor kartını açar (istek kartı dahil)',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Bobola', 'avatar_url': null},
        ]
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Esiner', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw, withStats: true);
      await tester.tap(find.text('Bobola'));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerScoreCardModal), findsOneWidget);
      await tester.tap(find.byTooltip('Kapat').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esiner'));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerScoreCardModal), findsOneWidget);
    });

    testWidgets('isimlerin yanında rütbe mührü — 16px, ismin SAĞINDA',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'f1', 'name': 'Bobola', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw, withStats: true);
      await tester.pump(const Duration(milliseconds: 50));
      final seals = tester.widgetList<RankSeal>(find.byType(RankSeal)).toList();
      expect(seals, isNotEmpty, reason: 'isim yanında mühür çizilmemiş');
      expect(seals.first.size, 16);
      expect(tester.getTopLeft(find.byType(RankSeal).first).dx,
          greaterThanOrEqualTo(tester.getTopRight(find.text('Bobola')).dx));
    });

    testWidgets('davet butonu: link + metin paylaş ucuna gider + görüntü',
        (tester) async {
      // GA4 `invite_link_shared` {source: friends_modal}.
      final fakeAnalytics = FakeAnalytics();
      analytics.configure(fakeAnalytics);
      addTearDown(analytics.reset);
      final shared = <String>[];
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Bobola', 'avatar_url': null},
          {'friend_id': 'b', 'name': 'Esiner', 'avatar_url': null},
        ]
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Tuna', 'avatar_url': null},
        ]
        ..outgoingRows = [
          {'friend_id': 'o1', 'name': 'Aszmer', 'avatar_url': null},
        ];
      await pumpModal(tester, gateway: gw, sharer: (t) async => shared.add(t));
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(find
            .ancestor(
                of: find.byType(FriendsModal),
                matching: find.byType(RepaintBoundary))
            .first);
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final out = File('build/screenshots/friends_modal.png');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.tap(find.text('+  ARKADAŞINI DAVET ET'));
      await tester.pumpAndSettle();
      expect(shared.single,
          '$inviteShareText\nhttps://kelimeki.com/davet/tok-123?ref=arkadas');
      expect(fakeAnalytics.names, ['invite_link_shared']);
      expect(fakeAnalytics.events.single.$2, {'source': 'friends_modal'});
    });

    // 14 Ağustos 2026'dan beri sessize alma/şikayet KİŞİ bazlı geri
    // alınabiliyor. Tek ekranda giriş noktası ⋯ menüsü; durum adın yanında.
    testWidgets('yalnızca moderasyon durumu OLAN satırda 🚫/🚩 + menü maddesi',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Esiner', 'avatar_url': null},
          {'friend_id': 'b', 'name': 'Ironman', 'avatar_url': null},
          {'friend_id': 'c', 'name': 'Temiz', 'avatar_url': null},
        ];
      final chat = FakeChatGateway()
        ..moderationMuted = const {'a': 'g1'}
        ..moderationReported = const {'b': 'g2'};
      await pumpModal(tester, gateway: gw, chat: chat);
      await tester.pumpAndSettle();
      expect(satirda('friend-a', find.text('🚫')), findsOneWidget);
      expect(satirda('friend-b', find.text('🚩')), findsOneWidget);
      expect(satirda('friend-c', find.text('🚫')), findsNothing);
      expect(satirda('friend-c', find.text('🚩')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('more-c')));
      await tester.pumpAndSettle();
      expect(find.text(kFriendsMenuModeration), findsNothing);
    });

    testWidgets('⋯ → ayarlar → şikayeti geri çek → 🚩 KAYBOLUR',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Esiner', 'avatar_url': null},
        ];
      final chat = FakeChatGateway()..moderationReported = const {'a': 'g1'};
      await pumpModal(tester, gateway: gw, chat: chat);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('more-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kFriendsMenuModeration));
      await tester.pumpAndSettle();
      expect(find.text('Bu kişiyi şikayet ettiniz.'), findsOneWidget);
      await tester.tap(find.text('Şikayeti Geri Çek'));
      await tester.pumpAndSettle();
      // Onay adımı ATLANMAZ — kazara dokunuş bir şikayeti düşürmemeli.
      expect(find.text('Emin misiniz?'), findsOneWidget);
      await tester.tap(find.text('Geri Çek'));
      await tester.pumpAndSettle();
      expect(chat.withdrawnCalls, ['a']);
      chat.moderationReported = const {};
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(find.text('🚩'), findsNothing);
    });

    testWidgets('sessizden çıkarma, kaydın geldiği oyun id\'siyle çağrılır',
        (tester) async {
      final gw = FakeFriendsGateway()
        ..friendsRows = [
          {'friend_id': 'a', 'name': 'Esiner', 'avatar_url': null},
        ];
      final chat = FakeChatGateway()..moderationMuted = const {'a': 'g7'};
      await pumpModal(tester, gateway: gw, chat: chat);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('more-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kFriendsMenuModeration));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sessizden Çıkar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sessizden Çıkar').last);
      await tester.pumpAndSettle();
      expect(chat.mutedCalls, [('g7', 'a', false)]);
    });

    // 27 Ağustos 2026 vakası (kaydırma takılıyordu): modalda TEK
    // kaydırılabilir. Tek ekranda "Tüm oyuncular" da gövdeyle kayar.
    testWidgets(
        'Tüm oyuncular: parmak listenin ÜZERİNDEYKEN son üyeye kadar '
        'kaydırılabilir (modalda tek kaydırılabilir)', (tester) async {
      final gw = FakeFriendsGateway()
        ..userRows = [
          for (var i = 1; i <= 46; i++)
            {
              'id': 'u$i',
              'name': 'Uye${i.toString().padLeft(2, '0')}',
              'avatar_url': null,
              'relation': null,
            },
        ];
      await pumpModal(tester, gateway: gw, size: const Size(420, 560));
      await tester.tap(find.text('Tüm oyuncular →'));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsNothing);
      expect(
          find.descendant(
              of: find.byType(FriendsModal),
              matching: find.byType(SingleChildScrollView)),
          findsOneWidget);
      final govde = tester.getRect(find.descendant(
          of: find.byType(FriendsModal),
          matching: find.byType(SingleChildScrollView)));
      final tutamak = tester.getRect(find.text('Uye03')).center;
      for (var i = 0; i < 60; i++) {
        await tester.dragFrom(tutamak, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      final son = find.text('Uye46');
      expect(son, findsOneWidget);
      final sonRect = tester.getRect(son);
      expect(sonRect.top, greaterThanOrEqualTo(govde.top));
      expect(sonRect.bottom, lessThanOrEqualTo(govde.bottom));
    });

    test('metinler web `FriendsModal.tsx` ile BİREBİR', () {
      final web =
          File('../../src/components/FriendsModal.tsx').readAsStringSync();
      for (final t in [
        kFriendsInviteCaption,
        kFriendsIncomingMeta,
        kFriendsOutgoingMeta,
        kFriendsSearchHint,
        kFriendsNobody,
        kFriendsEmptyTitle,
        kFriendsNoMorePlayers,
        kFriendsMenuCard,
        kFriendsMenuPlay2,
        kFriendsMenuPlay4,
        kFriendsMenuModeration,
        kFriendsMenuRemove,
        'Gönderdiğin istekler',
        'Tüm oyuncular →',
        '← Arkadaşlar',
      ]) {
        expect(web.contains(t), isTrue, reason: 'web metni ayrıştı: "$t"');
      }
      // Gövde metni JSX'te iki satıra bölünmüş — boşlukları sıkıştırıp ara.
      final sikistir = web.replaceAll(RegExp(r'\s+'), ' ');
      expect(sikistir.contains(kFriendsEmptyBody), isTrue);
    });
  });

  group('friendSinceLabel (web ile aynı eşikler)', () {
    final now = DateTime.utc(2026, 10, 1, 12);
    String gunOnce(int g) => now.subtract(Duration(days: g)).toIso8601String();
    test('kısa ve uzun hâl', () {
      expect(friendSinceLabel(null), isNull);
      expect(friendSinceLabel('bozuk'), isNull);
      expect(
          friendSinceLabel(gunOnce(0), kisa: true, now: now), 'Bugün eklendi');
      expect(friendSinceLabel(gunOnce(0), now: now), 'Bugün arkadaş oldunuz');
      expect(friendSinceLabel(gunOnce(1), kisa: true, now: now), 'Dün eklendi');
      expect(friendSinceLabel(gunOnce(5), kisa: true, now: now), '5 gündür');
      expect(friendSinceLabel(gunOnce(22), kisa: true, now: now), '3 haftadır');
      expect(friendSinceLabel(gunOnce(65), now: now), '2 aydır arkadaşsınız');
      expect(friendSinceLabel(gunOnce(800), kisa: true, now: now), '2 yıldır');
    });
  });

  group('AccountButton + PlayerScoreCard', () {
    testWidgets('menüde Arkadaşlar satırı + rozet; avatarda da AYNI sayı',
        (tester) async {
      await setPhoneViewSize(tester, const Size(420, 900));
      final gw = FakeFriendsGateway()
        ..requestRows = [
          {'requester_id': 'r1', 'name': 'Esiner', 'avatar_url': null},
          {'requester_id': 'r2', 'name': 'Bobola', 'avatar_url': null},
        ];
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: Center(
            child: AccountButton(
              auth: AuthService.fake(
                  user: fakeUser(),
                  profile: const KProfile(id: 'me', displayName: 'Ironman')),
              friends: FriendsRepo(gw),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(AccountButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('Arkadaşlar'), findsOneWidget);
      // 16 Ağustos 2026: avatardaki sayısız kırmızı nokta da `CountBadge`e
      // çevrildi, yani "2" artık İKİ yerde yazıyor — menü satırında ve
      // avatarın üstünde. Bunu `findsNWidgets(2)` ile geçiştirmek zayıf
      // olurdu (hangisinin hangisi olduğunu söylemez); ikisi ayrı ayrı
      // ölçülüyor. Avatar rozeti web'de arkadaşlık isteği + admin bekleyen
      // işinin TOPLAMI; portta admin paneli olmadığından tek kaynak istek.
      expect(
        find.descendant(of: find.byType(KAvatar), matching: find.text('2')),
        findsOneWidget,
        reason: 'avatar rozeti bekleyen istek sayısını göstermeli',
      );
      expect(find.text('2'), findsNWidgets(2)); // menü satırı + avatar
    });

    testWidgets(
        'PlayerScoreCard: arkadaşsa yeşil how_to_reg → çıkar onayı; değilse EKLE hapı',
        (tester) async {
      await setPhoneViewSize(tester, const Size(420, 900));
      final gw = FakeFriendsGateway()
        ..relation = {'user_id': 'me', 'status': 'accepted'};
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: PlayerScoreCardModal(
            stats: StatsRepo(_NullStatsGateway()),
            userId: 'u9',
            name: 'Bobola',
            friends: FriendsRepo(gw),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      // Skor kartında arkadaş durumu BİLİNÇLİ olarak listelerin kırmızı
      // person_remove'u değil yeşil how_to_reg (kullanıcı kararı, 11 Ağustos
      // 2026) — dokunuş yine de çıkarma onayını açıyor.
      expect(find.byIcon(Icons.person_remove), findsNothing);
      final relIcon = tester.widget<Icon>(find.byIcon(Icons.how_to_reg));
      expect(relIcon.color, const Color(0xFF16A34A));

      await tester.tap(find.byIcon(Icons.how_to_reg));
      await tester.pumpAndSettle();
      expect(find.textContaining('Arkadaşlıktan çıkmak mı'), findsOneWidget);
      await tester.tap(find.text('ÇIKAR'));
      await tester.pumpAndSettle();
      expect(gw.deleted, ['u9']);
      // regresyon (9 Ağustos 2026): web'in `resultMsg`i — işlem sonrası bir
      // "Tamam" sonuç diyaloğu çıkmalıydı, önceden HİÇBİRİ çıkmıyordu.
      expect(find.text('Arkadaşlıktan çıkarıldı.'), findsOneWidget);
      await tester.tap(find.text('TAMAM'));
      await tester.pumpAndSettle();
      // Simge artık "EKLE" hapına döner (29 Eylül 2026'dan beri ikon değil).
      expect(find.text('EKLE'), findsOneWidget);
    });

    // ⚠ REGRESYON (30 Ağustos 2026, kullanıcı bildirdi): *"Arkadaşlık daveti
    // beklemede olan kişinin skor kartına girince isminin yanında arkadaş
    // ekle işareti çıkıyor. Halbuki aynı kişiye Arkadaşlar → Ara & Ekle
    // bölümünden bakınca yanında kum saati çıkıyor."*
    //
    // Kök sebep: skor kartı İKİ dala ayrılmıştı (`accepted` ↔ diğer her
    // şey), oysa onay diyaloğu baştan beri DÖRDÜNÜ ayırıyordu — kart "ekle"
    // diyor, dokununca "İsteği İptal Et" çıkıyordu. Bu test dört dalın
    // dördünü de çiviliyor; ikiye dönülürse ilk iki `expect` düşer.
    //
    // `glyph` null ise beklenen ikon elle çizilmiş `PersonPendingIcon`;
    // doluysa o Material glyph'i O RENKTE çizilmiş olmalı. Glyph'i de
    // ölçmek şart: "bana istek geldi" ile "ilişki yok" AYNI rengi (accent)
    // kullanıyor, yalnızca renge bakan bir test ikisini ayırt edemezdi.
    //
    // 29 Eylül 2026: EYLEM dalları (ilişki yok, gelen istek) artık yazılı hap
    // ("EKLE" / "KABUL ET", web `Pill` ile aynı) — `hap` doluysa o metin
    // çizilmeli ve HİÇBİR ilişki ikonu çizilmemeli. DURUM dalları (⌛, ✓)
    // ikon kaldı.
    for (final (
          String ad,
          Map<String, Object?>? satir,
          IconData? glyph,
          Color? renk,
          String? hap
        ) in <(String, Map<String, Object?>?, IconData?, Color?, String?)>[
      (
        'istek gönderdim',
        {'user_id': 'me', 'status': 'pending'},
        null,
        kMuted,
        null
      ),
      (
        'bana istek geldi',
        {'user_id': 'u9', 'status': 'pending'},
        null,
        null,
        'KABUL ET'
      ),
      (
        'arkadaşız',
        {'user_id': 'me', 'status': 'accepted'},
        Icons.how_to_reg,
        kGreen,
        null
      ),
      ('ilişki yok', null, null, null, 'EKLE'),
    ]) {
      testWidgets('PlayerScoreCard ilişki simgesi — $ad', (tester) async {
        await setPhoneViewSize(tester, const Size(420, 900));
        final gw = FakeFriendsGateway()..relation = satir;
        await tester.pumpWidget(MaterialApp(
          theme: kelimekiTheme(),
          home: Scaffold(
            body: PlayerScoreCardModal(
              stats: StatsRepo(_NullStatsGateway()),
              userId: 'u9',
              name: 'Bobola',
              friends: FriendsRepo(gw),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump();

        if (hap != null) {
          expect(find.text(hap), findsOneWidget);
          expect(find.byType(PersonPendingIcon), findsNothing);
          expect(find.byIcon(Icons.how_to_reg), findsNothing);
          expect(find.byIcon(Icons.person_add_alt_1), findsNothing);
        } else if (glyph == null) {
          final ikon =
              tester.widget<PersonPendingIcon>(find.byType(PersonPendingIcon));
          expect(ikon.color, renk);
          // "Ekle" ASLA aynı anda çizilmemeli — 30 Ağustos hatasının kendisi.
          expect(find.text('EKLE'), findsNothing);
        } else {
          expect(find.byType(PersonPendingIcon), findsNothing);
          expect(tester.widget<Icon>(find.byIcon(glyph)).color, renk);
          expect(find.text('EKLE'), findsNothing);
        }
      });
    }

    // ⚠ REGRESYON (28 Eylül 2026, kullanıcı bildirdi): kendi skor kartında
    // "arkadaş ekle" simgesi çıkıyordu, dokununca kişiye kendine davet
    // göndermeyi teklif ediyordu. `relationWith` kendisi için null döner,
    // kart null'ı "ilişki yok" diye çiziyordu. Misafirde de (oturum yok)
    // simge çizilmez — web'in `!!user && user.id !== member.id` koşulu.
    for (final (String ad, String? ben) in <(String, String?)>[
      ('kendi kartı', 'u9'),
      ('misafir', null),
    ]) {
      testWidgets('PlayerScoreCard ilişki simgesi YOK — $ad', (tester) async {
        await setPhoneViewSize(tester, const Size(420, 900));
        final gw = FakeFriendsGateway()..currentUserId = ben;
        await tester.pumpWidget(MaterialApp(
          theme: kelimekiTheme(),
          home: Scaffold(
            body: PlayerScoreCardModal(
              stats: StatsRepo(_NullStatsGateway()),
              userId: 'u9',
              name: 'Bobola',
              friends: FriendsRepo(gw),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump();
        expect(find.byIcon(Icons.person_add_alt_1), findsNothing);
        expect(find.byIcon(Icons.how_to_reg), findsNothing);
        expect(find.byType(PersonPendingIcon), findsNothing);
      });
    }

    testWidgets(
        'regresyon (9 Ağustos 2026): PlayerScoreCard\'ta arkadaş isteği '
        'gönderince "iletilmiştir" sonuç diyaloğu çıkar + onay diyaloğu '
        'geniş ekranda taşmaz (web max-w-sm paritesi)', (tester) async {
      await setPhoneViewSize(tester, const Size(1200, 900));
      final gw = FakeFriendsGateway()..sendResult = 'pending';
      await tester.pumpWidget(MaterialApp(
        theme: kelimekiTheme(),
        home: Scaffold(
          body: PlayerScoreCardModal(
            stats: StatsRepo(_NullStatsGateway()),
            userId: 'u9',
            name: 'Bobola',
            friends: FriendsRepo(gw),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(find.text('EKLE'), findsOneWidget);

      await tester.tap(find.text('EKLE'));
      await tester.pumpAndSettle();
      expect(find.text('Arkadaş Ekle'), findsOneWidget);
      // Onay diyaloğunun kendi `constraints.maxWidth`i web'in max-w-sm'ine
      // (384px) yakın kalmalı — önceden Flutter Dialog'un varsayılan üst
      // sınırsızlığı (`BoxConstraints(minWidth: 280)`, üst sınır YOK)
      // yüzünden geniş ekranlarda neredeyse tam genişliğe yayılıyordu.
      // (`tester.getSize(Dialog)` yerine widget'ın kendi `constraints`
      // alanı okunuyor — `Dialog`'un RENDER boyutu `Align`in kapladığı
      // TÜM alan, iç `Material` kartının değil; piksel ölçümü yanıltıcı.)
      final confirmDialog = tester
          .widgetList<Dialog>(find.byType(Dialog))
          .firstWhere((d) => d.constraints?.maxWidth == 384);
      expect(confirmDialog.constraints?.maxWidth, 384);
      // Gerçek render boyutu da (Dialog'un içindeki ConstrainedBox) genişlik
      // sınırını GERÇEKTEN uyguladığını kanıtlıyor.
      final renderedWidth = tester
          .getSize(find
              .byWidgetPredicate(
                  (w) => w is ConstrainedBox && w.constraints.maxWidth == 384)
              .first)
          .width;
      expect(renderedWidth, lessThanOrEqualTo(384));

      // 11 Ağustos 2026: onay metni web `friendDialogCopy` ile hizalandı —
      // "Gönder" değil "Ekle" (FriendsModal'ın aynı diyaloğuyla da tek dil).
      // Onay diyaloğunun düğmesi; ilk "EKLE" kartın hapı (29 Eylül 2026).
      await tester.tap(find.text('EKLE').last);
      await tester.pumpAndSettle();
      // regresyon: gönderince web'in "Arkadaşlık isteğiniz iletilmiştir."
      // sonucu görünmeliydi, önceden HİÇBİR ŞEY çıkmıyordu.
      expect(find.text('Arkadaşlık davetiniz iletilmiştir.'), findsOneWidget);
    });
  });

  group('Setup davet kuyruğu işleme', () {
    // 26 Ağustos 2026 — ROADMAP madde 1'in "portta davet kabulü SESSİZCE
    // düşüyor" maddesi. `setup_screen.dart` yalnızca `debugPrint`liyordu;
    // artık kullanıcıya bir şey söyleniyor ve NE söyleneceği burada
    // sınanıyor (web `FriendInvitePage`'in P0001 kuralının portu).
    //
    // Negatif eş: `inviteAcceptErrorText`ten P0001 dalı kaldırılırsa ilk
    // expect düşer (sunucunun kendi mesajı jenerik metne dönüşür).
    // 26 Ağustos 2026, kullanıcı kararı: `takeAll` YIKICI olduğundan ağ
    // hatasında token kayboluyordu (davet ne kuruluyor ne de kuyrukta
    // kalıyordu). Artık YALNIZCA ağ hatasında geri konuyor. Burada
    // `_processInvites`'in veri katmanı sözleşmesi sınanıyor — widget
    // akışı değil (dosyadaki mevcut desen).
    //
    // Negatif eş: geri koyma satırı silinirse ilk expect düşer; koşul
    // `isNetworkError`dan geniş bir şeye çevrilirse ikinci expect düşer
    // (P0001 geri konarsa her açılışta aynı diyalog çıkardı).
    test('ağ hatasında token kuyruğa GERİ konur, kalıcı ret KONMAZ', () async {
      final storage = await openTestStorage();
      final gw = FakeFriendsGateway();
      final repo = FriendsRepo(gw);

      Future<void> isle(Object hata) async {
        await storage.events.add(friendInviteTokenKind, {'token': 't1'});
        final events = inviteTokensFromEvents(
            await storage.events.takeAll(friendInviteTokenKind));
        for (final token in events) {
          try {
            gw.failWith = hata;
            await repo.acceptInvite(token);
          } catch (err) {
            if (isNetworkError(err)) {
              await storage.events.add(friendInviteTokenKind, {'token': token});
            }
          } finally {
            gw.failWith = null;
          }
        }
      }

      // 1) Ağ hatası → token DURUYOR, bağlantı dönünce yeniden denenebilir.
      await isle(Exception('SocketException: Failed host lookup'));
      expect(
          inviteTokensFromEvents(
              await storage.events.takeAll(friendInviteTokenKind)),
          ['t1'],
          reason: 'ağ hatasında davet kaybolmamalı');

      // 2) Kalıcı ret → token GİTMELİ; aksi halde her açılışta aynı
      //    "Kendi linkinle arkadaş olamazsın." diyaloğu çıkardı.
      await isle(PostgrestException(
          message: 'Kendi linkinle arkadaş olamazsın.', code: 'P0001'));
      expect(await storage.events.takeAll(friendInviteTokenKind), isEmpty,
          reason: 'kalıcı ret ölümsüz kayıt üretmemeli');
    });

    test('inviteAcceptErrorText: P0001 sunucu mesajını OLDUĞU GİBİ gösterir',
        () {
      final ret = PostgrestException(
          message: 'Kendi linkinle arkadaş olamazsın.', code: 'P0001');
      expect(inviteAcceptErrorText(ret), 'Kendi linkinle arkadaş olamazsın.');
      expect(inviteAcceptKaliciRet(ret), isTrue,
          reason:
              'kalıcı ret → tekrar denemek anlamsız, telemetriye de gitmez');
    });

    test('inviteAcceptErrorText: ağ hatası ile bilinmeyen hata AYRI konuşur',
        () {
      // `isNetworkError`a düşen gerçek bir kalıp (util/offline_notice.dart).
      final ag = Exception('ClientException: Failed host lookup: kelimeki.com');
      expect(inviteAcceptErrorText(ag), contains('bağlantını kontrol'));
      expect(inviteAcceptKaliciRet(ag), isFalse);

      // Sunucunun BAŞKA bir hatası (P0001 değil): teşhis uydurulmuyor.
      final bilinmeyen =
          PostgrestException(message: 'deadlock detected', code: '40P01');
      final metin = inviteAcceptErrorText(bilinmeyen);
      expect(metin, 'Davet kabul edilemedi. Biraz sonra tekrar dene.');
      expect(metin, isNot(contains('deadlock')),
          reason: 'ham sunucu hatası kullanıcıya gösterilmez');
      expect(inviteAcceptKaliciRet(bilinmeyen), isFalse,
          reason: 'geçici olabilir → telemetriye düşmeli');
    });

    test('girişliyken takeAll → acceptInvite; hata token düşürür', () async {
      // Setup'ın _processInvites'inin veri katmanı sözleşmesi burada repo +
      // store seviyesinde sınanır (widget akışı: kuyruk → kabul → boşalır).
      final storage = await openTestStorage();
      await storage.events.add(friendInviteTokenKind, {'token': 't1'});
      await storage.events.add(friendInviteTokenKind, {'token': 't2'});
      final gw = FakeFriendsGateway();
      final repo = FriendsRepo(gw);

      final events = await storage.events.takeAll(friendInviteTokenKind);
      expect(events, hasLength(2));
      for (final e in events) {
        await repo.acceptInvite(e['token'] as String);
      }
      expect(gw.acceptedInvites, ['t1', 't2']);
      // takeAll atomik tüketti — ikinci okuma boş.
      expect(await storage.events.takeAll(friendInviteTokenKind), isEmpty);
    });

    // Parça 87 — soğuk başlangıçta AYNI token iki kez kuyruğa girebiliyor:
    // `pending_events`in dedup'ı yok (`PendingEventStore.add` düz insert) ve
    // link hem `uriLinkStream`den hem `getInitialLink()` kurtarmasından
    // düşebiliyor. Dedup olmadan kullanıcı üst üste iki "artık arkadaşsınız"
    // diyaloğu görür ve ikinci bir gereksiz RPC atılır.
    test('parti içinde mükerrer token bir kez işlenir, bozuk kayıt elenir', () {
      expect(
        inviteTokensFromEvents([
          {'token': 'tok-1'},
          {'token': 'tok-1'}, // soğuk başlangıç: akış + getInitialLink
          {'token': 'tok-2'},
          {'token': ''}, // bozuk
          {'token': 42}, // bozuk
          <String, Object?>{}, // bozuk
        ]),
        ['tok-1', 'tok-2'],
      );
      // Dedup PARTİ bazında: kalıcı bir "görüldü" listesi TUTULMUYOR, yani
      // bir sonraki oturumda aynı linke yeniden dokunmak hâlâ çalışır.
      expect(
          inviteTokensFromEvents([
            {'token': 'tok-1'}
          ]),
          ['tok-1']);
    });
  });
}

class _NullStatsGateway implements StatsGateway {
  @override
  Future<List<Map<String, Object?>>> leaderboard(int limit, int offset) async =>
      [];

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) async => null;

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
