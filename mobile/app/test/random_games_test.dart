// Rastgele Oyuncu (açık ilan) — SAF kurallar ve web ↔ port paritesi
// (3 Ekim 2026; web ikizi `src/utils/randomGames.ts` +
// `scripts/verify-random-games.ts`).
//
// Bu dosya widget çizmez: bu kuralların kırılma biçimi SESSİZ (bir oyun
// yanlış sekmede görünür, bir rozet şişer, açık koltuk "Yapay Zeka" diye
// yazılır) ve ekrandan önce kural düzeyinde kilitlenmeli. Ekran davranışı
// `random_games_ui_test.dart`ta.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/online_games_api.dart';
import 'package:kelimeki/src/util/random_games.dart';

import 'support/fake_online_gateway.dart';
import 'support/web_source.dart';

MyRandomGame mine(String id,
        {String role = 'creator',
        String status = 'pending',
        int playerCount = 2,
        List<Map<String, Object?>>? slots}) =>
    MyRandomGame.fromJson(myRandomRow(
        id: id,
        myRole: role,
        status: status,
        playerCount: playerCount,
        slots: slots));

RandomListing listing(String id,
        {String creator = 'kurucu', int open = 1, int playerCount = 2}) =>
    RandomListing.fromJson(randomListingRow(
        id: id,
        creatorId: creator,
        playerCount: playerCount,
        seats: [
          'creator',
          for (var i = 1; i < playerCount; i++) i <= open ? 'open' : 'filled',
        ]));

void main() {
  group('koltuk türleri', () {
    test('açık koltuk İKİ biçimde gelir ve ikisi de YZ DEĞİL', () {
      final ham = OnlineSlot.fromJson(slotOpen);
      final maske = OnlineSlot.fromJson(slotOpenMasked);
      for (final s in [ham, maske]) {
        expect(isOpenSeat(s), isTrue);
        expect(isRealAiSeat(s), isFalse,
            reason: '`type == ai` maskesi "Yapay Zeka" sayılmamalı');
        expect(s.isAi, isFalse);
        expect(s.isHuman, isFalse);
      }
    });

    test('gerçek YZ ve insan koltuğu açık sayılmaz', () {
      final ai = OnlineSlot.fromJson(slotAi);
      expect(isRealAiSeat(ai), isTrue);
      expect(isOpenSeat(ai), isFalse);
      final insan = OnlineSlot.fromJson(
          slotHuman('u1', name: 'Ali', relation: 'accepted'));
      expect(insan.isHuman, isTrue);
      expect(isOpenSeat(insan) || isRealAiSeat(insan), isFalse);
    });

    test('`via: random` koltuğa taşınır (ayrılma yalnız bunu boşaltır)', () {
      final s = OnlineSlot.fromJson({...slotHuman('u2'), 'via': 'random'});
      expect(s.via, 'random');
      expect(OnlineSlot.fromJson(slotHuman('u3')).via, isNull);
    });

    test('açık koltuk mySlotIndex/creatorSlot hesabını BOZMAZ', () {
      final g = game(gameRow(
          id: 'g',
          myId: 'me',
          status: 'pending',
          myRole: 'creator',
          slots: [
            slotHuman('me', name: 'Ironman', relation: 'self'),
            slotOpenMasked,
          ]));
      expect(g.mySlotIndex, 0);
      expect(g.slots[1].isOpen, isTrue);
      // Kurucu null (silinmiş hesap) iken açık koltuk "kurucu" olmamalı.
      final silinmis = game(gameRow(
          id: 'g2',
          myId: 'me',
          createdBy: null,
          status: 'pending',
          slots: [slotOpenMasked, slotHuman('me', relation: 'self')]));
      expect(silinmis.creatorSlot, isNull);
    });

    test('filledSeatCount: YZ dolu, açık ve cevapsız davetli dolu DEĞİL', () {
      List<OnlineSlot> k(List<Map<String, Object?>> l) =>
          [for (final m in l) OnlineSlot.fromJson(m)];
      expect(
          filledSeatCount(k([
            slotHuman('me', relation: 'self'),
            slotOpen,
          ])),
          1);
      expect(
          filledSeatCount(k([
            slotHuman('me', relation: 'self'),
            slotHuman('f', inviteStatus: 'pending'),
            slotOpen,
            slotAi,
          ])),
          2,
          reason: 'kurucu + YZ; cevapsız davetli ve açık koltuk sayılmaz');
      expect(
          filledSeatCount(k([
            slotHuman('me', relation: 'self'),
            slotHuman('f', inviteStatus: 'accepted'),
          ])),
          2);
    });
  });

  group('kova sınıflandırması (dört kova dersi)', () {
    // list_my_online_games satırları — açık koltuk eski istemci maskesiyle.
    final kuruculuk = game(gameRow(
        id: 'k1',
        myId: 'me',
        status: 'pending',
        myRole: 'creator',
        slots: [slotHuman('me', relation: 'self'), slotOpenMasked]));
    final kabulEden = game(gameRow(
        id: 'r1',
        myId: 'me',
        status: 'pending',
        myRole: 'invitee',
        myInviteStatus: 'accepted',
        myInviteId: 'i-r1',
        playerCount: 4,
        slots: [
          slotHuman('baska', relation: 'accepted'),
          slotHuman('me', relation: 'self', inviteStatus: 'accepted'),
          slotOpenMasked,
          slotOpenMasked,
        ]));
    final arkadasDaveti = game(gameRow(
        id: 'f1',
        myId: 'me',
        status: 'pending',
        myRole: 'invitee',
        myInviteStatus: 'pending',
        myInviteId: 'i-f1',
        playerCount: 4,
        slots: [
          slotHuman('kurucu', relation: 'accepted'),
          slotHuman('me', relation: 'self', inviteStatus: 'pending'),
          slotOpenMasked,
          slotAi,
        ]));
    final dolupBasladi = game(gameRow(id: 'a1', myId: 'me', status: 'active'));
    final hepsi = [kuruculuk, kabulEden, arkadasDaveti, dolupBasladi];

    List<String> ids(List<OnlineGame> l) => [for (final g in l) g.id];

    test(
        'kurucu ve kabul eden YALNIZ Devam Edenler\'e: waiting/acceptedWaiting '
        'kovalarına GİRMEZ', () {
      final managed = randomManagedIds(
          [mine('k1'), mine('r1', role: 'random', playerCount: 4)], hepsi);
      expect(managed, {'k1', 'r1'});
      final b = classifyLiveGames(hepsi, managed);
      expect(ids(b.waiting), isEmpty);
      expect(ids(b.acceptedWaiting), isEmpty);
      // Yönetilmeyen davranış (eski): iki kovada da görünürlerdi.
      final eski = classifyLiveGames(hepsi, const {});
      expect(ids(eski.waiting), ['k1']);
      expect(ids(eski.acceptedWaiting), ['r1']);
    });

    test('karma kadrodaki ARKADAŞ: bugünkü davet akışı AYNEN (invites)', () {
      final managed = randomManagedIds([
        mine('k1'),
        mine('r1', role: 'random', playerCount: 4),
        mine('f1', role: 'friend', playerCount: 4),
      ], hepsi);
      expect(managed.contains('f1'), isFalse,
          reason: "'friend' yönetilen sayılırsa daveti kaybolur");
      final b = classifyLiveGames(hepsi, managed);
      expect(ids(b.invites), ['f1']);
    });

    test('dolup başlayan oyun `active`te normal oyun gibi kalır', () {
      final managed = randomManagedIds([mine('a1')], hepsi);
      final b = classifyLiveGames(hepsi, managed, turns: const {'a1': 1});
      expect(ids(b.active), ['a1']);
    });

    test('myRandom == null (liste ALINAMADI): yalnız KESİN olan saklanır', () {
      final managed = randomManagedIds(null, hepsi);
      // Açık koltuklu + kurucusu ben: kesin.
      expect(managed, {'k1'});
      // Kabul eden satırı geçici olarak "Kabul Ettin"de kalabilir —
      // arkadaş davetlisini yanlışlıkla gizlemekten iyi.
      final b = classifyLiveGames(hepsi, managed);
      expect(ids(b.acceptedWaiting), ['r1']);
      expect(ids(b.invites), ['f1']);
    });

    test('açık koltuksuz kurucu oyunu (arkadaş daveti) yönetilmez', () {
      final g = game(
          gameRow(id: 'w1', myId: 'me', status: 'pending', myRole: 'creator'));
      expect(randomManagedIds(null, [g]), isEmpty);
      expect(randomManagedIds([mine('x', role: 'friend')], [g]), isEmpty);
    });

    test(
        'myWaitingRandomGames: bekleyen creator/random; friend, biten ve '
        'null YOK', () {
      final l = myWaitingRandomGames([
        mine('a'),
        mine('b', role: 'random'),
        mine('c', role: 'friend'),
        mine('d', status: 'active'),
        mine('e', status: 'finished'),
      ]);
      expect([for (final g in l) g.id], ['a', 'b']);
      expect(myWaitingRandomGames(null), isEmpty);
    });
  });

  group('şerit', () {
    test(
        'visibleListings: id tekilleştirir, excludeIds\'i çıkarır, sırayı '
        'korur; kurucu BEN olsam da çıkarmaz (§15)', () {
      final out = visibleListings([
        listing('a'),
        listing('b'),
        listing('a'), // offset sayfalaması aynı satırı iki kez verebilir
        listing('benim', creator: 'me'),
        listing('icindeyim'),
        listing('c'),
      ], {
        'icindeyim'
      });
      expect([for (final l in out) l.id], ['a', 'b', 'benim', 'c']);
    });

    test('myRandomToListing: kurucu/ad/avatar slots\'tan, koltuk eşlemesi', () {
      final g = mine('m1', playerCount: 4, slots: [
        slotHuman('me', name: 'Ben', relation: 'self'),
        slotHuman('d1', name: 'D1', inviteStatus: 'pending'),
        slotHuman('d2', name: 'D2', inviteStatus: 'declined'),
        slotHuman('d3', name: 'D3', inviteStatus: 'accepted'),
      ]);
      final l = myRandomToListing(g);
      expect(l.mine, 'creator');
      expect(l.id, 'm1');
      expect(l.creatorName, isNotNull);
      expect(l.seats, ['creator', 'invited', 'invited', 'filled']);
      final k = myRandomToListing(mine('m2', slots: [
        slotHuman('me', name: 'Ben', relation: 'self'),
        slotOpen,
      ]));
      expect(k.seats, ['creator', 'open']);
      final r =
          myRandomToListing(mine('m3', role: 'random', playerCount: 4, slots: [
        slotHuman('me', name: 'Ben'),
        slotOpen,
        slotAi,
        slotHuman('y', name: 'Y'),
      ]));
      expect(r.mine, 'random');
      expect(r.seats, ['creator', 'open', 'ai', 'filled']);
    });

    test(
        'stripListings: benimkiler ÖNCE (en yeni önce), çakışan id\'de benim '
        'kartım kazanır, friend/active görünmez', () {
      MyRandomGame at(String id, String ts,
              {String role = 'creator', String status = 'pending'}) =>
          MyRandomGame.fromJson(
              myRandomRow(id: id, myRole: role, status: status, createdAt: ts));
      final out = stripListings([
        listing('o1'),
        listing('m-yeni'), // sunucu bana da gösteriyor → tekrar OLMAZ
        listing('o2'),
        listing('arkadas'),
      ], [
        at('m-eski', '2026-10-01T10:00:00Z'),
        at('m-yeni', '2026-10-03T10:00:00Z', role: 'random'),
        at('arkadas', '2026-10-04T10:00:00Z', role: 'friend'),
        at('aktif', '2026-10-04T10:00:00Z', status: 'active'),
      ]);
      expect([for (final l in out) l.id], ['m-yeni', 'm-eski', 'o1', 'o2']);
      expect([for (final l in out) l.mine], ['random', 'creator', null, null]);
      expect(stripListings([listing('x')], null), hasLength(1));
      expect(stripListings(const [], [at('a', '2026-10-01T10:00:00Z')]),
          hasLength(1));
    });

    test('seatsLeftLabel: zaman/yaş bilgisi KONMAZ', () {
      expect(seatsLeftLabel(1), '1 koltuk kaldı');
      expect(seatsLeftLabel(3), '3 koltuk kaldı');
      expect(seatsLeftLabel(2), isNot(contains('saat')));
      expect(seatsLeftLabel(2), isNot(contains('gün')));
    });

    test('seatDotFilled: creator/filled/ai dolu; open/invited boş', () {
      expect([
        for (final s in ['creator', 'filled', 'ai', 'open', 'invited'])
          seatDotFilled(s)
      ], [
        true,
        true,
        true,
        false,
        false
      ]);
    });

    test('yoklama sabitleri', () {
      expect(kRandomStripPoll, const Duration(seconds: 40));
      expect(kRandomStripMinGap, const Duration(seconds: 8));
      expect(kRandomStripLimit, 20);
    });
  });

  group('esnek kadro (kurulum formu)', () {
    test('addRandomSeat: boş koltuğu "?" yapar; DOLUYSA ve "?" varsa geri alır',
        () {
      expect(addRandomSeat([], 2), ['?']);
      expect(addRandomSeat(['u1'], 2), ['?'],
          reason: '2 kişide tek rakip: dolu ARKADAŞ koltuğu DEĞİŞTİRİLİR');
      expect(addRandomSeat(['?'], 2), isEmpty,
          reason: '2 kişide "?" seçiliyken tekrar dokunuş GERİ ALIR');
      expect(addRandomSeat([], 4), ['?']);
      expect(addRandomSeat(['?', 'u1'], 4), ['?', 'u1', '?']);
      expect(addRandomSeat(['?', '?'], 4), ['?', '?', '?'],
          reason: '×2: boş koltuk var, üçüncüyü ekler');
      expect(addRandomSeat(['?', '?', '?'], 4), isEmpty,
          reason: '×3 dolu: dokunuş tüm "?" koltuklarını geri alır');
      expect(addRandomSeat(['u1', '?', '?'], 4), ['u1'],
          reason: 'arkadaş korunur, yalnız "?" geri alınır');
      expect(addRandomSeat(['u1', 'u2', 'u3'], 4), ['u1', 'u2', 'u3'],
          reason: 'dolu ve "?" yok: 4 kişide etkisiz');
    });

    test('toggleFriendSeat: "?" koltukları korunur, 3 sınırı', () {
      expect(toggleFriendSeat(['?'], 'u1', 2), ['u1'],
          reason: '2 kişide arkadaş "?"nin yerine geçer');
      expect(toggleFriendSeat(['u1'], 'u1', 2), isEmpty);
      expect(toggleFriendSeat(['?', 'u1'], 'u1', 4), ['?']);
      expect(toggleFriendSeat(['?', 'u1'], 'u2', 4), ['?', 'u1', 'u2']);
      expect(toggleFriendSeat(['?', '?', 'u1'], 'u2', 4), ['?', '?', 'u1']);
    });

    test('removeSeatAt: yalnız o koltuğu boşaltır', () {
      expect(removeSeatAt(['?', 'u1', '?'], 0), ['u1', '?']);
      expect(removeSeatAt(['?', 'u1', '?'], 2), ['?', 'u1']);
    });

    test('canSubmitSeats: 2 kişide 1, 4 kişide en az 2', () {
      expect(canSubmitSeats([], 2), isFalse);
      expect(canSubmitSeats(['?'], 2), isTrue);
      expect(canSubmitSeats(['?'], 4), isFalse);
      expect(canSubmitSeats(['?', '?'], 4), isTrue);
      expect(canSubmitSeats(['?', 'u1', '?'], 4), isTrue);
    });

    test('aiLastSeat: yalnız 4 kişide tam 2 seçimde (rastgele kadroda da)', () {
      expect(aiLastSeat(['?', '?'], 4), isTrue);
      expect(aiLastSeat(['?', 'u1'], 4), isTrue);
      expect(aiLastSeat(['?', '?', '?'], 4), isFalse);
      expect(aiLastSeat(['?'], 2), isFalse);
    });

    test('usesRandomSeat / randomSeatCount', () {
      expect(usesRandomSeat(['u1']), isFalse);
      expect(usesRandomSeat(['u1', '?']), isTrue);
      expect(randomSeatCount(['?', 'u1', '?']), 2);
    });

    test('buildRandomSlots: çağıran önde, "?" → open, 2 seçimde sonda YZ', () {
      List<Map<String, Object?>> j(List<NewGameSlot> l) =>
          [for (final s in l) s.toJson()];
      expect(j(buildRandomSlots('me', ['?'], 2)), [
        {'type': 'human', 'user_id': 'me'},
        {'type': 'open'},
      ]);
      expect(j(buildRandomSlots('me', ['u1', '?'], 4)), [
        {'type': 'human', 'user_id': 'me'},
        {'type': 'human', 'user_id': 'u1'},
        {'type': 'open'},
        {'type': 'ai'},
      ]);
      expect(j(buildRandomSlots('me', ['?', '?', '?'], 4)), [
        {'type': 'human', 'user_id': 'me'},
        {'type': 'open'},
        {'type': 'open'},
        {'type': 'open'},
      ]);
    });
  });

  group('metinler', () {
    test('acceptNotice', () {
      expect(acceptNotice(started: true), 'Kabul ettin. Oyun başladı.');
      expect(acceptNotice(started: false),
          'Kabul ettin. Diğer oyuncular bekleniyor.');
    });

    test('createdNotice: ilan açıldı ↔ var olana katılındı', () {
      final yeni = createdNotice(joined: false, started: false);
      expect(yeni.title, 'İlanın yayında');
      expect(yeni.body, contains('7 gün içinde dolmazsa kendiliğinden kalkar'));
      expect(yeni.body, contains('ceza yok'));
      final katildi = createdNotice(joined: true, started: false);
      expect(katildi.title, 'Oyuna katıldın');
      expect(katildi.body,
          'Uygun bir ilan vardı, ona katıldın. Diğer oyuncular bekleniyor.');
      expect(createdNotice(joined: true, started: true).body,
          'Uygun bir ilan vardı, ona katıldın. Oyun başladı.');
    });
  });

  group('rozet zinciri DEĞİŞMEZ (ilan HABERDİR, bekleyen iş değil)', () {
    test(
        'yalnız ilanı açık/bekleyen kullanıcıda sayaçlar ve giriş kararı '
        'ARTMAZ; ilan listesi sayaç yoluna HİÇ girmez', () async {
      final gw = FakeOnlineGamesGateway()
        ..rows = [
          gameRow(
              id: 'k1',
              myId: 'me',
              status: 'pending',
              myRole: 'creator',
              slots: [slotHuman('me', relation: 'self'), slotOpenMasked]),
          gameRow(
              id: 'r1',
              myId: 'me',
              status: 'pending',
              myRole: 'invitee',
              myInviteStatus: 'accepted',
              playerCount: 4,
              slots: [
                slotHuman('baska', relation: 'accepted'),
                slotHuman('me', relation: 'self', inviteStatus: 'accepted'),
                slotOpenMasked,
                slotOpenMasked,
              ]),
        ]
        ..myRandomRows = [
          myRandomRow(id: 'k1'),
          myRandomRow(id: 'r1', myRole: 'random', playerCount: 4),
        ];
      final repo = OnlineGamesRepo(gw);
      final c = (await repo.pendingCounts())!;
      expect(c.inviteCount, 0);
      expect(c.myTurnCount, 0);
      expect(c.activeCount, 0);
      expect(gw.myRandomCalls, 0,
          reason: 'sayaç yolu list_my_random_games / list_random_games\'i '
              'ÇAĞIRMAMALI — ilan haberdir');
      expect(gw.randomListCalls, 0);
      // Giriş sekmesi ZORLANMAZ.
      expect(decideInitialMainView(c, const []), InitialMainView.local);
    });

    test('karma kadroda arkadaşın bekleyen daveti bugünkü gibi SAYILIR',
        () async {
      final gw = FakeOnlineGamesGateway()
        ..rows = [
          gameRow(
              id: 'f1',
              myId: 'me',
              status: 'pending',
              myRole: 'invitee',
              myInviteStatus: 'pending',
              myInviteId: 'i-f1',
              playerCount: 4,
              slots: [
                slotHuman('kurucu', relation: 'accepted'),
                slotHuman('me', relation: 'self', inviteStatus: 'pending'),
                slotOpenMasked,
                slotAi,
              ]),
        ]
        ..myRandomRows = [myRandomRow(id: 'f1', myRole: 'friend')];
      final c = (await OnlineGamesRepo(gw).pendingCounts())!;
      expect(c.inviteCount, 1);
      expect(decideInitialMainView(c, const []), InitialMainView.live);
    });
  });

  group('web ↔ port parite (readRepoFile)', () {
    final webKurallar = readRepoFile('src/utils/randomGames.ts');
    final webSerit = readRepoFile('src/components/RandomGamesStrip.tsx');
    final webTab = readRepoFile('src/components/LiveGamesTab.tsx');
    final webForm = readRepoFile('src/components/LiveGameCreateForm.tsx');
    final webApi = readRepoFile('src/lib/api.ts');

    test('sabitler: yoklama aralığı, alt aralık, sayfa boyu, "?" işareti', () {
      int sayi(String ad) => int.parse(
          pick(webKurallar, RegExp('export const $ad\\s*=\\s*([0-9_]+)'), ad)
              .replaceAll('_', ''));
      expect(kRandomStripPoll.inMilliseconds, sayi('RANDOM_STRIP_POLL_MS'));
      expect(
          kRandomStripMinGap.inMilliseconds, sayi('RANDOM_STRIP_MIN_GAP_MS'));
      expect(kRandomStripLimit, sayi('RANDOM_STRIP_LIMIT'));
      expect(
          pick(webKurallar, RegExp(r"RANDOM_SEAT\s*=\s*'(.)'"), 'RANDOM_SEAT'),
          kRandomSeat);
    });

    test('metinler web ile BİREBİR', () {
      for (final t in [
        'Kabul ettin. Oyun başladı.',
        'Kabul ettin. Diğer oyuncular bekleniyor.',
        'Oyuna katıldın',
        'Uygun bir ilan vardı, ona katıldın. Oyun başladı.',
        'Uygun bir ilan vardı, ona katıldın. Diğer oyuncular bekleniyor.',
        'İlanın yayında',
        createdNotice(joined: false, started: false).body,
        '1 koltuk kaldı',
        'koltuk kaldı',
      ]) {
        expect(webKurallar.contains(t), isTrue,
            reason: 'web metni ayrıştı: "$t"');
      }
      for (final t in [
        kRandomStripTitle,
        kRandomStripCreate,
        kRandomWaitingSeat,
        kRandomWaitingFriend,
        kRandomWaitingStarting,
        kRandomCancelLabel,
        kRandomLeaveLabel,
      ]) {
        expect(webSerit.contains(t), isTrue,
            reason: 'RandomGamesStrip.tsx metni ayrıştı: "$t"');
      }
      expect(RegExp('>\\s*$kRandomAcceptLabel\\s*<').hasMatch(webSerit), isTrue,
          reason: 'Kabul düğmesi etiketi ayrıştı');
      expect(RegExp('>\\s*$kRandomMineWaiting\\s*<').hasMatch(webSerit), isTrue,
          reason: 'Bekliyor etiketi ayrıştı');
      expect(webSerit.contains("'$kRandomMineCancel'"), isTrue,
          reason: 'İptal etiketi ayrıştı');
      expect(webSerit.contains("'$kRandomLeaveLabel'"), isTrue);
      expect(webSerit.contains('stripListings('), isTrue);
      expect(webSerit.contains('border-accent/30 bg-accent/5'), isTrue,
          reason: 'benim kartımın zemini ayrıştı');
      expect(webSerit.contains(kRandomAcceptFallback), isTrue);
      expect(webSerit.contains("surface: 'rastgele-kabul'"), isTrue);
      for (final t in [
        kRandomCancelledNotice,
        kRandomLeftNotice,
        kRandomLeaveFallback,
        "surface: 'rastgele-ayril'",
      ]) {
        expect(webTab.contains(t), isTrue,
            reason: 'LiveGamesTab.tsx metni ayrıştı: "$t"');
      }
      for (final t in [
        kRandomRowTitle,
        kRandomRowSub,
        "(yatay ? '$kRandomSeatLabel2' : '$kRandomSeatLabel4')",
        "'Biri' : playerCount === 2 ? 'Arkadaşın'",
      ]) {
        expect(webForm.contains(t), isTrue,
            reason: 'LiveGameCreateForm.tsx metni ayrıştı: "$t"');
      }
    });

    test('şerit kartı: "N koltuk kaldı" zaman bilgisi taşımaz (web de)', () {
      expect(webSerit.contains('seatsLeftLabel('), isTrue);
    });

    test('RPC adları ve parametreleri: web api.ts ↔ port gateway', () {
      final dart =
          readRepoFile('mobile/app/lib/src/data/online_games_api.dart');
      // RPC adları iki tarafta da tırnaklı; parametre adları webde nesne
      // anahtarı (tırnaksız), portta harita anahtarı (tırnaklı).
      for (final t in [
        'create_random_game',
        'accept_random_game',
        'leave_random_game',
        'cancel_random_game',
        'list_random_games',
        'list_my_random_games',
      ]) {
        expect(webApi.contains("'$t'"), isTrue, reason: 'web api.ts: $t');
        expect(dart.contains("'$t'"), isTrue, reason: 'port gateway: $t');
      }
      for (final p in [
        'p_player_count',
        'p_slots',
        'p_game_id',
        'p_limit',
        'p_offset',
      ]) {
        expect(webApi.contains('$p:'), isTrue, reason: 'web api.ts: $p');
        expect(dart.contains("'$p'"), isTrue, reason: 'port gateway: $p');
      }
    });
  });
}
