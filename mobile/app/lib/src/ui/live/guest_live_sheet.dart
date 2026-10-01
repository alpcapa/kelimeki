// Girişsiz kullanıcı "Arkadaşınla"yı seçince alttan açılan pencere — web
// `LiveGamesTab.tsx` → `GuestLiveSheet` portu (ROADMAP #41 karar 9; web 27
// Eylül 2026, port 1 Ekim 2026).
//
// Misafir o noktada zaten bir şey SEÇMİŞ oluyor; cevap bir karar anı: Üye Ol
// · Giriş Yap · Yapay Zekayla devam et. Kapatmak (zemine dokunmak, aşağı
// sürüklemek, geri tuşu) "Yapay Zekayla devam et" ile AYNI — misafiri boş bir
// sekmede bırakmıyoruz. Giriş penceresi vazgeçilerek kapanırsa bu pencere
// geri gelir (web: `guestSheetOpen && !showAuthModal`).
//
// Metinler web'le BİREBİR (`guest_live_sheet_test.dart` web kaynağını okur).
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/feedback_api.dart';
import '../auth/auth_modal.dart';
import '../game/neo_button.dart';
import '../tokens.dart';

const String kGuestLiveTitle = 'Arkadaşınla oynamak için giriş yap';
const String kGuestLiveBody =
    'Oyunların istatistikleri, k-lig ve arkadaşınla canlı oyun için lütfen '
    'giriş yapın. Üyelik ücretsiz.';
const String kGuestLiveSignup = 'Üye Ol';
const String kGuestLiveLogin = 'Giriş Yap';
const String kGuestLiveToAi = 'Yapay Zekayla devam et';

enum _Choice { signup, login }

/// Pencereyi açar; misafir giriş yapana ya da Yapay Zeka'ya dönene kadar
/// döngüde kalır. Yapay Zeka'ya dönüşte `onSwitchToAi` çağrılır.
Future<void> showGuestLiveSheet(
  BuildContext context, {
  required AuthService auth,
  FeedbackRepo? feedback,
  required VoidCallback onSwitchToAi,
}) async {
  while (auth.user == null) {
    if (!context.mounted) return;
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      backgroundColor: Colors.transparent,
      // Web `max-w-[460px]`; panel içeriği kadar yüksek, üstü zemin (dokunuş
      // kapatır).
      constraints: const BoxConstraints(maxWidth: 460),
      // Web `bg-[rgba(15,23,42,0.45)]`.
      barrierColor: const Color(0x730F172A),
      builder: (sheetContext) => const _GuestLiveSheet(),
    );
    if (!context.mounted) return;
    if (choice == null) {
      onSwitchToAi();
      return;
    }
    if (!context.mounted) return;
    await showLoginModal(context, auth,
        feedback: feedback, startInSignup: choice == _Choice.signup);
  }
}

class _GuestLiveSheet extends StatelessWidget {
  const _GuestLiveSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
              color: Color(0x590F172A), offset: Offset(0, -20), blurRadius: 45),
        ],
      ),
      // Web `px-5 pt-3` + alt `1.75rem + safe-area`.
      padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFC7D0DC),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Web `gap-3.5` (14) + başlığın `margin-top: 4px`.
          const SizedBox(height: 18),
          const Text(
            kGuestLiveTitle,
            style: TextStyle(
              fontSize: 20,
              height: 1.375,
              fontWeight: FontWeight.bold,
              color: kText,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            kGuestLiveBody,
            style: TextStyle(fontSize: 14, height: 1.625, color: kText),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: NeoButton(
                  label: 'ÜYE OL',
                  variant: NeoButtonVariant.accent,
                  fontSize: 13,
                  letterSpacing: 1,
                  onPressed: () => Navigator.of(context).pop(_Choice.signup),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: NeoButton(
                  label: 'GİRİŞ YAP',
                  variant: NeoButtonVariant.neutral,
                  fontSize: 13,
                  letterSpacing: 1,
                  onPressed: () => Navigator.of(context).pop(_Choice.login),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: const Center(
                  widthFactor: 1,
                  child: Text(
                    'YAPAY ZEKAYLA DEVAM ET',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: kMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
