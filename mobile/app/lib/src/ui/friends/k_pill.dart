// Arkadaşlık hapı — web `FriendsModal.tsx` → `Pill` portu (27-29 Eylül 2026,
// ROADMAP #41). Canlı oyun formunun "Tüm oyuncular" görünümü ve Arkadaşlar
// penceresi aynı biçimi kullanır: görünen hap 26 px, dokunma alanı 36 px.
//
// Etiketler ve renkler web `PILL` tablosuyla BİREBİR (`k_pill_test.dart` web
// kaynağını okur).
import 'package:flutter/material.dart';

import '../tap_target.dart';
import '../tokens.dart';

enum KPillKind { oyna, ekle, gonderildi, kabul, geriAl }

/// Web `PILL[kind].label` — `uppercase` CSS'i burada elle (Türkçe İ).
const Map<KPillKind, String> kPillLabel = {
  KPillKind.oyna: 'OYNA',
  KPillKind.ekle: 'EKLE',
  KPillKind.gonderildi: 'İSTEK GİTTİ',
  KPillKind.kabul: 'KABUL ET',
  KPillKind.geriAl: 'GERİ AL',
};

/// Web'deki büyük-küçük harfli kaynak etiketler (parite testi bunları arar).
const Map<KPillKind, String> kPillWebLabel = {
  KPillKind.oyna: 'Oyna',
  KPillKind.ekle: 'Ekle',
  KPillKind.gonderildi: 'İstek gitti',
  KPillKind.kabul: 'Kabul et',
  KPillKind.geriAl: 'Geri al',
};

({Color bg, Color border, Color text}) _renk(KPillKind k) => switch (k) {
      KPillKind.oyna => (bg: kAccent, border: kAccent, text: Colors.white),
      KPillKind.ekle => (
          bg: const Color(0xFFEEF4FF),
          border: kAccent,
          text: kAccent
        ),
      KPillKind.gonderildi => (bg: kPanel, border: kBorder, text: kMuted),
      KPillKind.kabul => (bg: kOrange, border: kOrange, text: Colors.white),
      KPillKind.geriAl => (bg: kPanel, border: kBorder, text: kText),
    };

class KPill extends StatelessWidget {
  final KPillKind kind;
  final VoidCallback? onTap;

  /// Ekran okuyucu etiketi — web `aria-label` ("X — arkadaş ekle" gibi).
  final String semanticLabel;

  const KPill({
    super.key,
    required this.kind,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final r = _renk(kind);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        // Web `disabled:opacity-40`.
        opacity: onTap == null ? 0.4 : 1,
        child: TapTarget(
          onTap: onTap,
          minHeight: 36,
          child: Container(
            constraints: const BoxConstraints(minHeight: 26),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: r.bg,
              border: Border.all(color: r.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              kPillLabel[kind]!,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: r.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
