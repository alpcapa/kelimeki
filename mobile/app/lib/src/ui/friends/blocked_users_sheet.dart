// "Engellediklerim" — web `BlockedUsersModal.tsx` portu: engellediğim /
// sohbette engellediğim / şikayet ettiğim HERKES, arkadaş olsun olmasın.
//
// NEDEN VAR: "Engelle" artık arkadaşlık isteği ve oyun daveti kartından da
// yapılabiliyor. İsteği gönderen genelde arkadaş DEĞİL; eski geri alma yolları
// (arkadaş ⋯ menüsü, aktif oyunun sohbet ayarları) onu hiç göstermezdi — yani
// arkadaş olmayan birini engelleyince geri almanın yolu yoktu.
//
// KAPSAM bilinçli olarak yalnızca GERİ ALMA: yeni şikayet burada AÇILMAZ
// (şikayet bir konuşmaya bağlı; admin ilgisiz yazışma okumasın diye YALNIZCA
// oyunun sohbetinden yapılır). İki ayrı adım: "Engeli Kaldır" açık şikayete
// DOKUNMAZ; açık şikayet sürdükçe kişi ENGELLİ sayılır, bu yüzden şikayetli
// satırda "Şikayeti Geri Çek" de var.
//
// ⚠ Web'in `max-h-[55vh]` iç kaydırması TAŞINMADI: `KModal` gövdesi zaten
// kaydırılır ve Flutter iç içe kaydırmayı zincirlemez (bkz. `KModal.
// bodyController` yorumu).
//
// Metinler web'le BİREBİR — `block_test.dart` web kaynağını okur.
import 'package:flutter/material.dart';

import '../../data/chat_api.dart';
import '../../util/error_message.dart';
import '../auth/k_avatar.dart';
import '../game/modal_shell.dart';
import '../game/neo_button.dart';
import '../loading_note.dart';
import '../tokens.dart';

const String kBlockedTitle = 'Engellediklerim';
const String kBlockedEmpty = 'Kimseyi engellemedin.';
const String kBlockedIntro =
    'Engellediğin kişiler sana oyun daveti ya da arkadaşlık isteği gönderemez '
    've rastgele eşleşmede karşına çıkmaz.';
const String kBlockedReportedNote =
    'Şikayetiniz açıkken kişi engelli kalır; tamamen serbest bırakmak için '
    'ikisini de uygulayın.';
const String kUnblockConfirmBody =
    ' için engeliniz kalkacak; size tekrar oyun daveti ve arkadaşlık isteği '
    'gönderebilir, rastgele eşleşmede karşınıza çıkabilir.';
const String kWithdrawConfirmBody =
    ' hakkındaki şikayetiniz geri çekilecek. Dilerseniz daha sonra tekrar '
    'şikayet edebilirsiniz.';

/// Bir şey değiştiyse `true` döner — çağıran 🚫/🚩'yi tazelemek için kullanır.
Future<bool> showBlockedUsers(BuildContext context,
    {required ChatRepo chat}) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (_) => _BlockedUsersSheet(chat: chat),
  );
  return changed ?? false;
}

enum _Kind { unblock, withdraw }

class _BlockedUsersSheet extends StatefulWidget {
  final ChatRepo chat;
  const _BlockedUsersSheet({required this.chat});

  @override
  State<_BlockedUsersSheet> createState() => _BlockedUsersSheetState();
}

class _BlockedUsersSheetState extends State<_BlockedUsersSheet> {
  List<BlockedUser>? _users;
  String? _loadError;
  (BlockedUser, _Kind)? _pending;
  bool _busy = false;
  String? _actionError;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _loadError = null);
    widget.chat.blockedUsers().then((l) {
      if (mounted) setState(() => _users = l);
    }).catchError((Object e) {
      if (mounted) {
        setState(() => _loadError = friendlyErrorMessage(e,
            surface: 'engellediklerim', fallback: 'Liste yüklenemedi.'));
      }
    });
  }

  Future<void> _confirm() async {
    final p = _pending;
    if (p == null) return;
    setState(() {
      _busy = true;
      _actionError = null;
    });
    try {
      if (p.$2 == _Kind.unblock) {
        await widget.chat.unblockUser(p.$1.userId);
      } else {
        await widget.chat.withdrawReports(p.$1.userId);
      }
      if (!mounted) return;
      setState(() {
        _changed = true;
        _pending = null;
      });
      _load();
    } catch (e) {
      // Sessizce yutma YOK — gerçekleşmemiş bir sonuç "olmuş" sanılmasın.
      if (mounted) {
        setState(() => _actionError = friendlyErrorMessage(e,
            surface: 'engellediklerim', fallback: 'İşlem başarısız oldu.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KModal(
      title: kBlockedTitle,
      onClose: () => Navigator.of(context).pop(_changed),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _content(),
      ),
    );
  }

  List<Widget> _content() {
    final pending = _pending;
    if (pending != null) return _confirmView(pending.$1, pending.$2);
    if (_loadError != null) {
      return [
        Text(_loadError!,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: kRed)),
        const SizedBox(height: 8),
        NeoButton(
            label: 'Tekrar dene',
            variant: NeoButtonVariant.neutral,
            onPressed: _load),
      ];
    }
    final users = _users;
    if (users == null) return [const KLoadingNote(vertical: 24)];
    if (users.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(kBlockedEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 12, color: kMuted)),
        ),
      ];
    }
    return [
      const Text(kBlockedIntro,
          style: TextStyle(fontSize: 12, color: kMuted, height: 1.5)),
      const SizedBox(height: 12),
      for (final u in users) _row(u),
    ];
  }

  Widget _row(BlockedUser u) => Container(
        key: ValueKey('blocked-${u.userId}'),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kPanel,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              KAvatar(url: u.avatarUrl, name: u.name, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(u.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kText)),
              ),
              if (u.reported)
                Semantics(
                  label: 'Şikayet edildi',
                  child: Text('🚩',
                      style: TextStyle(fontSize: 12, fontFamilyFallback: [
                        'Noto Color Emoji',
                        'Apple Color Emoji'
                      ])),
                ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              if (u.reported) ...[
                Expanded(
                  child: NeoButton(
                    label: 'Şikayeti Geri Çek',
                    variant: NeoButtonVariant.neutral,
                    fontSize: 11,
                    onPressed: () =>
                        setState(() => _pending = (u, _Kind.withdraw)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: NeoButton(
                  label: 'Engeli Kaldır',
                  variant: NeoButtonVariant.neutral,
                  fontSize: 11,
                  onPressed: () =>
                      setState(() => _pending = (u, _Kind.unblock)),
                ),
              ),
            ]),
            if (u.reported) ...[
              const SizedBox(height: 8),
              const Text(kBlockedReportedNote,
                  style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      color: kMuted,
                      height: 1.5)),
            ],
          ],
        ),
      );

  List<Widget> _confirmView(BlockedUser u, _Kind kind) {
    final unblock = kind == _Kind.unblock;
    return [
      Row(children: [
        KAvatar(url: u.avatarUrl, name: u.name, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Text(u.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
        ),
      ]),
      const SizedBox(height: 12),
      const Text('Emin misiniz?',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 8),
      Text(
        '${u.name}${unblock ? kUnblockConfirmBody : kWithdrawConfirmBody}',
        style: const TextStyle(fontSize: 14, color: kText, height: 1.5),
      ),
      if (_actionError != null) ...[
        const SizedBox(height: 8),
        Text(_actionError!,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: kRed)),
      ],
      const SizedBox(height: 12),
      // Kabul butonu SOLDA (Parça 25 kuralı).
      Row(children: [
        Expanded(
          child: NeoButton(
            variant: NeoButtonVariant.accent,
            label: _busy ? '...' : (unblock ? 'Engeli Kaldır' : 'Geri Çek'),
            onPressed: _busy ? null : _confirm,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NeoButton(
            label: 'Vazgeç',
            variant: NeoButtonVariant.neutral,
            onPressed: _busy
                ? null
                : () => setState(() {
                      _pending = null;
                      _actionError = null;
                    }),
          ),
        ),
      ]),
    ];
  }
}
