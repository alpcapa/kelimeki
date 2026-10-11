// Oyun sonu arkadaş önerisi (4 Ekim 2026) — web ikizi
// `src/utils/friendSuggest.ts` + `FriendSuggestModal.tsx`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/friends_api.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/ui/live/friend_suggest_modal.dart';
import 'package:kelimeki/src/util/friend_suggest.dart';

import 'support/fake_online_gateway.dart';
import 'support/web_source.dart';

OnlineSlot h(String id, [String? relation]) =>
    OnlineSlot.human(userId: id, name: id, relation: relation);

void main() {
  group('friendSuggestCandidates', () {
    final slots = [
      h('me', 'self'),
      h('a', 'accepted'),
      h('b', 'pending_outgoing'),
      h('c', 'pending_incoming'),
      h('d'),
      const OnlineSlot.ai(),
      h('d'),
    ];
    test('yalnız gelen-istek + ilişkisiz, tekrarsız', () {
      expect(friendSuggestCandidates(slots, 'me', {}).map((s) => s.userId),
          ['c', 'd']);
    });
    test('güncel arkadaş listesindeki elenir (relation bayat olabilir)', () {
      expect(friendSuggestCandidates(slots, 'me', {'d'}).map((s) => s.userId),
          ['c']);
    });
    test('açık koltuk / YZ aday olmaz', () {
      expect(
          friendSuggestCandidates(
              [const OnlineSlot.open(), const OnlineSlot.ai()], 'me', {}),
          isEmpty);
    });
    test('web ikiziyle aynı metin ve kural', () {
      final web = readRepoFile('src/components/FriendSuggestModal.tsx');
      expect(
          web, contains('Bu oyuncuları arkadaş olarak eklemek ister misin?'));
      expect(web, contains('Vazgeç'));
      final webRule = readRepoFile('src/utils/friendSuggest.ts');
      expect(webRule, contains("'pending_outgoing'"));
    });
  });

  group('FriendSuggestModal', () {
    Future<void> open(WidgetTester t, FakeFriendsGateway gw) async {
      await t.pumpWidget(MaterialApp(
          home: Builder(
              builder: (c) => TextButton(
                  onPressed: () => showFriendSuggestModal(c,
                          friends: FriendsRepo(gw),
                          candidates: const [
                            SuggestCandidate(userId: 'x', name: 'Bobola')
                          ]),
                  child: const Text('aç')))));
      await t.tap(find.text('aç'));
      await t.pumpAndSettle();
    }

    testWidgets('Vazgeç pencereyi kapatır, istek GİTMEZ', (t) async {
      final gw = FakeFriendsGateway();
      await open(t, gw);
      expect(find.text('Bu oyuncuları arkadaş olarak eklemek ister misin?'),
          findsOneWidget);
      await t.tap(find.text('VAZGEÇ'));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(gw.sentRequests, isEmpty);
    });

    testWidgets('Devam istek yollar ve "iletilmiştir" der', (t) async {
      final gw = FakeFriendsGateway();
      await open(t, gw);
      await t.tap(find.text('DEVAM'));
      await t.pumpAndSettle();
      expect(gw.sentRequests, ['x']);
      expect(find.text('Arkadaşlık davetiniz iletilmiştir.'), findsOneWidget);
    });
  });
}
