// "Engelle" onayı — web `BlockConfirmModal.tsx` portu. Arkadaşlık isteği
// kartı, oyun daveti kartı ve arkadaşın ⋯ menüsü AYNI pencereyi kullanır
// (web 4-5 Ekim 2026, kullanıcı kararı: istek/davet kartında yalnızca
// "Engelle"; şikayet YOK — şikayet yalnızca oyunun sohbetinden yapılır).
//
// Engelleme geri alınabilir ("Engellediklerim"), ama sonuçları büyük (davet,
// istek ve rastgele eşleşme kapanır) olduğundan tek dokunuşta YAPILMAZ.
// `onConfirm` hata fırlatırsa pencere AÇIK kalır ve hatayı gösterir; sessizce
// yutulup "engellendi" sanılması en kötü sonuç olurdu.
//
// Metin web'le BİREBİR — `block_test.dart` web kaynağını okur.
import 'package:flutter/material.dart';

import '../../util/error_message.dart';
import '../game/modal_shell.dart';
import '../game/neo_button.dart';
import '../tokens.dart';

const String kBlockTitle = 'Kişiyi Engelle';
const String kBlockSure = 'Emin misiniz?';
const String kBlockConfirmLabel = 'Engelle';
const String kBlockCancelLabel = 'Vazgeç';
const String kBlockBodyAfterName =
    ' kullanıcısını engellemek istediğinize emin misiniz? Bu kişi size '
    'oyun daveti ya da arkadaşlık isteği gönderemez ve rastgele eşleşmede '
    'karşınıza çıkmaz. Engeli istediğiniz zaman Arkadaşlar ekranındaki '
    '"Engellediklerim" listesinden kaldırabilirsiniz.';

/// Başarıyla biterse `true` döner (pencere kapanır); vazgeçilirse `false`.
Future<bool> showBlockConfirm(
  BuildContext context, {
  required String name,
  required Future<void> Function() onConfirm,
}) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => _BlockConfirmSheet(name: name, onConfirm: onConfirm),
  );
  return done ?? false;
}

class _BlockConfirmSheet extends StatefulWidget {
  final String name;
  final Future<void> Function() onConfirm;

  const _BlockConfirmSheet({required this.name, required this.onConfirm});

  @override
  State<_BlockConfirmSheet> createState() => _BlockConfirmSheetState();
}

class _BlockConfirmSheetState extends State<_BlockConfirmSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyErrorMessage(e,
            surface: 'engelle', fallback: 'İşlem başarısız oldu.');
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KModal(
      title: kBlockTitle,
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(kBlockSure,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: widget.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: kBlockBodyAfterName),
            ]),
            style: const TextStyle(fontSize: 14, color: kText, height: 1.5),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: kRed)),
          ],
          const SizedBox(height: 12),
          // Kabul butonu SOLDA (Parça 25 kuralı).
          Row(children: [
            Expanded(
              child: NeoButton(
                variant: NeoButtonVariant.accent,
                label: _busy ? '...' : kBlockConfirmLabel,
                onPressed: _busy ? null : _run,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoButton(
                label: kBlockCancelLabel,
                variant: NeoButtonVariant.neutral,
                onPressed:
                    _busy ? null : () => Navigator.of(context).pop(false),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
