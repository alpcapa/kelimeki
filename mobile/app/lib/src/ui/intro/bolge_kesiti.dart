// Karşılamanın ilk ekranındaki 7×5 tahta kesiti — web `src/landing/
// BolgeKesiti.tsx` + `ilkEkranKesiti.ts` portu (ROADMAP #41 karar 1 + 14;
// port 1 Ekim 2026).
//
// Oyunun TEK fikrini anlatır: senin bölgen (camgöbeği), rakibin bölgesi
// (kırmızı) ve rakibin sınırına değen bir hamle (SAAT'in T'si → vergi).
//
// ⚠ Veri web'den ELLE kopya — `intro_screen_test.dart` → "kesit verisi web
// ile birebir" `ilkEkranKesiti.ts`i okuyup karşılaştırır. Harflerin kelime
// olduğunu web'in `npm run verify-demo-board`u sınıyor (aynı veri).
//
// Görsel dil oyunun kendisinden: renkler `playerColors`, dış hat oyunun
// `buildRoundedOutlinePath`i (aynı yarıçap 0.16, kalınlık 2.5), puanlar
// `tileData`, boş/bölge hücre gölgeleri `board_widget.dart`teki dallarla aynı.
import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show tileData;

import '../game/neo_box.dart';
import '../game/outline.dart';
import '../game/player_colors.dart';
import '../tokens.dart';

/// Web `KESIT_SUTUN`.
const int kKesitSutun = 7;

/// Web `KESIT_HARITA` — `c` senin bölgen (boş) · `r` rakibin bölgesi (boş) ·
/// `.` tarafsız · BÜYÜK harf = senin taşın · `kKesitRakipHarfleri`ndeki hücre
/// = rakibin taşı.
const List<String> kKesitHarita = [
  'FAc....',
  'cSAAT..',
  'c...rrr',
  '....rrr',
  '....rrr',
];

/// Web `KESIT_RAKIP_HARFLERI` — `"satır,sütun"` → harf.
const Map<String, String> kKesitRakipHarfleri = {
  '2,4': 'A',
  '2,5': 'K',
  '3,5': 'U',
  '4,5': 'L',
  '3,6': 'S',
  '4,6': 'E',
};

/// Web `KESIT_HAMLE` — bu turda oluşan kelimeler (SAAT ve TA). Düz listede T
/// İKİ kez geçer; rozet puanı da öyle sayar (oyundaki `calcScore` gibi her
/// kelime ayrı).
const List<List<(int, int)>> kKesitHamle = [
  [(1, 1), (1, 2), (1, 3), (1, 4)],
  [(1, 4), (2, 4)],
];

/// Web `KESIT_ACIK_KENARLAR` — rakip bölgesi kesitin sağ ve alt kenarında
/// AÇIK (kadrajın dışına sürüyor okunsun diye).
const bool kKesitAcikSag = true;
const bool kKesitAcikAlt = true;

/// Web metni — `intro_screen_test` `BolgeKesiti.tsx`te arar.
const String kKesitVergiEtiketi = "Vergi: puanın 1/3'ü rakibe";

enum _Kim { sen, rakip }

class _Hucre {
  final bool tas;
  final _Kim? kim;
  final String? harf;
  const _Hucre({required this.tas, this.kim, this.harf});
}

List<List<_Hucre>> _hucreler() => [
      for (var r = 0; r < kKesitHarita.length; r++)
        [
          for (var c = 0; c < kKesitSutun; c++)
            () {
              final rakip = kKesitRakipHarfleri['$r,$c'];
              if (rakip != null) {
                return _Hucre(tas: true, kim: _Kim.rakip, harf: rakip);
              }
              final ch = kKesitHarita[r][c];
              return switch (ch) {
                'c' => const _Hucre(tas: false, kim: _Kim.sen),
                'r' => const _Hucre(tas: false, kim: _Kim.rakip),
                '.' => const _Hucre(tas: false),
                _ => _Hucre(tas: true, kim: _Kim.sen, harf: ch),
              };
            }(),
        ],
    ];

/// Rozet puanı — web'deki `hamlePuani` (T iki kelimede de sayılır).
int kesitHamlePuani() {
  final h = _hucreler();
  var t = 0;
  for (final kelime in kKesitHamle) {
    for (final (r, c) in kelime) {
      final harf = h[r][c].harf;
      if (harf != null) t += tileData[harf]?.pts ?? 0;
    }
  }
  return t;
}

// Oyundaki "Oyna" öncesi geçerlilik çerçevesi/rozet rengi (web `GECERLI`).
const Color _gecerli = Color(0xFF1FA05C);
const Color _zemin = Color(0xFFDDE4EE);
const double _bosluk = 3;

class BolgeKesiti extends StatelessWidget {
  const BolgeKesiti({super.key});

  @override
  Widget build(BuildContext context) {
    final hucreler = _hucreler();
    final satir = kKesitHarita.length;
    final sen = playerColors[0], rakip = playerColors[1];

    final senin = <(int, int)>[], rakibin = <(int, int)>[];
    for (var r = 0; r < satir; r++) {
      for (var c = 0; c < kKesitSutun; c++) {
        final k = hucreler[r][c].kim;
        if (k == _Kim.sen) senin.add((r, c));
        if (k == _Kim.rakip) rakibin.add((r, c));
      }
    }
    final hamle = [for (final k in kKesitHamle) ...k];
    final hamleTekil = <(int, int)>{...hamle}.toList();
    final (rozetR, rozetC) = hamle
        .reduce((a, b) => b.$1 < a.$1 || (b.$1 == a.$1 && b.$2 < a.$2) ? b : a);
    final hatlar = <(Path, Color)>[
      (buildRoundedOutlinePath(senin, 0.16), sen.base),
      (
        buildRoundedOutlinePath(rakibin, 0.16,
            extraOpen: (r, c, nr, nc) =>
                (kKesitAcikSag && nc >= kKesitSutun) ||
                (kKesitAcikAlt && nr >= satir)),
        rakip.base
      ),
      (buildRoundedOutlinePath(hamleTekil, 0.16), _gecerli),
    ];

    return Semantics(
      image: true,
      label: "Tahta kesiti: solda senin camgöbeği bölgen; önceki hamlelerin "
          "FA ve AS, AS'nin S'sine bağlanan SAAT kelimen, sağ altta rakibin "
          "kırmızı bölgesi ve KUL, US, LE, SE, AK kelimeleri. SAAT ve rakibin "
          "A'sıyla kurulan TA ${kesitHamlePuani()} puan getiriyor, ama T "
          "rakibin bölgesine değdiği için puanın üçte biri rakibe geçer.",
      excludeSemantics: true,
      child: Center(
        child: ConstrainedBox(
          // Web `max-w-[340px]`.
          constraints: const BoxConstraints(maxWidth: 340),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const ShapeDecorationWithCssShadows(
                  color: _zemin,
                  radius: 18,
                  shadows: kRaisedShadows,
                ),
                child: LayoutBuilder(builder: (context, k) {
                  final w = k.maxWidth;
                  final hucre = (w - _bosluk * (kKesitSutun - 1)) / kKesitSutun;
                  final h = hucre * satir + _bosluk * (satir - 1);
                  return SizedBox(
                    width: w,
                    height: h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var r = 0; r < satir; r++)
                          for (var c = 0; c < kKesitSutun; c++)
                            Positioned(
                              left: c * (hucre + _bosluk),
                              top: r * (hucre + _bosluk),
                              width: hucre,
                              height: hucre,
                              child: _hucre(hucreler[r][c], w),
                            ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                                painter: _HatPainter(hatlar, satir)),
                          ),
                        ),
                        Positioned(
                          left: rozetC / kKesitSutun * w,
                          top: rozetR / satir * h,
                          child: FractionalTranslation(
                            translation: const Offset(-0.35, -0.35),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _gecerli,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x40000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 5),
                                ],
                              ),
                              child: Text('+${kesitHamlePuani()}',
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // Web `absolute -right-1.5 -top-3.5`.
              Positioned(
                right: -6,
                top: -14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kText,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x4D1B2430),
                          offset: Offset(0, 6),
                          blurRadius: 14),
                    ],
                  ),
                  child: const Text(kKesitVergiEtiketi,
                      style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 11,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hucre(_Hucre h, double gridW) {
    final renk = switch (h.kim) {
      _Kim.sen => playerColors[0],
      _Kim.rakip => playerColors[1],
      null => null,
    };
    if (!h.tas) {
      return NeoBox(
        borderRadius: BorderRadius.circular(5),
        color: renk?.tint ?? _zemin,
        insetShadows: renk != null
            ? [
                InsetShadow(
                    color: renk.base.withValues(alpha: 0.133),
                    offset: const Offset(2, 2),
                    blur: 5),
                const InsetShadow(
                    color: Color(0x99FFFFFF), offset: Offset(-1, -1), blur: 3),
              ]
            : const [
                InsetShadow(
                    color: Color(0x99A3B1C6), offset: Offset(3, 3), blur: 6),
                InsetShadow(
                    color: Color(0xCCFFFFFF), offset: Offset(-2, -2), blur: 5),
              ],
        child: const SizedBox.expand(),
      );
    }
    final c = renk!;
    return Container(
      decoration: BoxDecoration(
        color: c.tint,
        border: Border.all(color: c.base),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(children: [
        Center(
          child: Text(h.harf!,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  // Web `8.4cqw` (kesitin kendi genişliği).
                  fontSize: gridW * 0.084,
                  height: 1,
                  color: c.text)),
        ),
        Positioned(
          top: 2,
          right: 3,
          child: Text('${tileData[h.harf!]?.pts ?? ''}',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontWeight: FontWeight.bold,
                  fontSize: gridW * 0.03,
                  height: 1,
                  color: kAccent)),
        ),
      ]),
    );
  }
}

class _HatPainter extends CustomPainter {
  final List<(Path, Color)> hatlar;
  final int satir;
  _HatPainter(this.hatlar, this.satir);

  @override
  void paint(Canvas canvas, Size size) {
    final m = Matrix4.diagonal3Values(
        size.width / kKesitSutun, size.height / satir, 1);
    for (final (p, renk) in hatlar) {
      canvas.drawPath(
          p.transform(m.storage),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = renk);
    }
  }

  @override
  bool shouldRepaint(_HatPainter old) => false;
}
