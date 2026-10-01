// Sohbet Kuralları onay penceresi — web `src/components/ChatRulesModal.tsx`
// portu (25 Eylül 2026). İlk mesaj gönderilmeden önce BİR KEZ çıkar; metin
// ve karar `util/chat_rules.dart`te. `true` → kabul kaydı sunucuya yazıldı.
import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import '../../util/chat_rules.dart';
import '../../util/error_message.dart';
import '../auth/legal_modals.dart';
import '../game/dialog_shell.dart';
import '../game/modal_shell.dart';
import '../game/neo_button.dart';
import '../tokens.dart';

Future<bool> showChatRulesModal(
  BuildContext context, {
  required Future<void> Function() onAccept,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => ChatRulesModal(onAccept: onAccept),
  );
  return ok == true;
}

class ChatRulesModal extends StatefulWidget {
  /// Kabul kaydını yazar; fırlatırsa pencere açık kalır ve hatayı gösterir.
  final Future<void> Function() onAccept;
  const ChatRulesModal({super.key, required this.onAccept});

  @override
  State<ChatRulesModal> createState() => _ChatRulesModalState();
}

class _ChatRulesModalState extends State<ChatRulesModal> {
  bool _busy = false;
  String? _error;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onAccept();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = friendlyErrorMessage(e,
            surface: 'sohbet-kurallari',
            fallback: 'Onay kaydedilemedi, tekrar dene.');
      });
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(
        fontFamily: 'SpaceGrotesk', fontSize: 14, color: kText, height: 1.5);
    return KModal(
      title: kChatRulesTitle,
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(kChatRulesIntro, style: body),
          const SizedBox(height: 12),
          for (final madde in kChatRulesItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: body),
                  Expanded(child: Text(madde, style: body)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => showTermsModal(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 48),
                foregroundColor: kAccent,
              ),
              child: const Text(kChatRulesTermsLink,
                  style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12)),
            ),
          ),
          if (_error != null) ...[
            Text(_error!,
                style: const TextStyle(
                    fontFamily: 'SpaceMono', fontSize: 10, color: kRed)),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              // Kabul SOLDA — web'in düz flex sırası (Parça 25).
              Expanded(
                child: kDialogButton(
                  label: trUpper(kChatRulesAccept),
                  variant: NeoButtonVariant.accent,
                  onPressed: _busy ? null : _accept,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: kDialogButton(
                  label: trUpper(kChatRulesCancel),
                  onPressed:
                      _busy ? null : () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
