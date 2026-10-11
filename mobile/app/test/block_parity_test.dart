// Engelle (web #811/#813) port ikizinin METİN paritesi: onay penceresi ve
// "Engellediklerim" metinleri web `BlockConfirmModal.tsx` /
// `BlockedUsersModal.tsx` / `FriendModerationModal.tsx` ile BİREBİR olmak
// zorunda — ayrışırsa web CI'ın `parite` işi düşer. (Davranış testleri
// `friends_test.dart`ta.)
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/friends/block_confirm_sheet.dart';
import 'package:kelimeki/src/ui/friends/blocked_users_sheet.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';

import 'support/web_source.dart';

String _sik(String s) => s.replaceAll(RegExp(r'\s+'), ' ');

void main() {
  test('BlockConfirmModal metinleri web ile BİREBİR', () {
    final web = _sik(readRepoFile('src/components/BlockConfirmModal.tsx'));
    for (final t in [
      kBlockTitle,
      kBlockSure,
      kBlockConfirmLabel,
      kBlockCancelLabel
    ]) {
      expect(web.contains(t), isTrue, reason: 'web metni ayrıştı: "$t"');
    }
    expect(web.contains(kBlockBodyAfterName.trim()), isTrue,
        reason: 'onay gövdesi ayrıştı');
  });

  test('BlockedUsersModal metinleri web ile BİREBİR', () {
    final web = _sik(readRepoFile('src/components/BlockedUsersModal.tsx'));
    for (final t in [
      kBlockedTitle,
      kBlockedEmpty,
      kBlockedIntro,
      kBlockedReportedNote,
      kUnblockConfirmBody.trim(),
      kWithdrawConfirmBody.trim(),
      'Şikayeti Geri Çek',
      'Engeli Kaldır',
    ]) {
      expect(web.contains(t), isTrue, reason: 'web metni ayrıştı: "$t"');
    }
  });

  test('FriendModerationModal: menü metinleri web ile BİREBİR', () {
    final web = _sik(readRepoFile('src/components/FriendModerationModal.tsx'));
    for (final t in [
      'Bu kişiyi şikayet ettiniz ve engellediniz.',
      'Bu kişiyi şikayet ettiniz; şikayetiniz açıkken kişi engelli sayılır.',
      'Bu kişiyi engellediniz.',
      'Engel kaldırıldı.',
      'Şikayetiniz geri çekildi.',
      'Arkadaş olmadığın kişiler için Arkadaşlar ekranındaki "Engellediklerim" listesine bak.',
    ]) {
      expect(web.contains(t), isTrue, reason: 'web metni ayrıştı: "$t"');
    }
  });

  test('Puan Ligi açıklaması + alt not web `Leaderboard.tsx` ile BİREBİR', () {
    final web = _sik(readRepoFile('src/components/Leaderboard.tsx'));
    // JSX/TS dize birleştirmesi `' +` ile bölünmüş — tırnak/artı temizlenir.
    final duz = web.replaceAll(RegExp(r"'\s*\+\s*'"), '');
    expect(duz.contains(kPuanLigiIntro), isTrue);
    expect(duz.contains(kPuanLigiNote), isTrue);
  });
}
