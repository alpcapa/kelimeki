// AÇIK koltuğun avatarı — kesik çerçeveli "?" (web `PlayerAvatarRow`un
// `isOpen` dalı ve `LiveGamesTab`/`LiveGameCreateForm`daki aynı daire;
// Rastgele Oyuncu, 3 Ekim 2026).
//
// Açık koltuk Yapay Zeka DEĞİL ve henüz oturmuş biri de değil: Yedek avatar
// ("?") ile AYNI glif ama dolu bir kullanıcı gibi görünmesin diye kesik
// çerçeve ve soluk zemin. TEK yerden çiziliyor — üç ekran aynı daireyi
// kullanır, biri değişirse ayrışmasın.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Web `rounded-full bg-bg border-[1.5px] border-dashed text-muted font-bold`.
///
/// [borderColor]/[textColor] verilmezse `kMuted` (şerit ve listeler); form
/// koltuk kartında oyuncu rengi geçilir.
class OpenSeatAvatar extends StatelessWidget {
  final double size;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  const OpenSeatAvatar({
    super.key,
    required this.size,
    this.borderColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final renk = borderColor ?? kMuted;
    return CustomPaint(
      foregroundPainter: _DashedCirclePainter(color: renk, width: 1.5),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: kBg, shape: BoxShape.circle),
        child: Text(
          '?',
          style: TextStyle(
            fontSize: fontSize ?? (size * 0.55).roundToDouble(),
            height: 1,
            fontWeight: FontWeight.bold,
            color: textColor ?? kMuted,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double width;
  const _DashedCirclePainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    final r = (math.min(size.width, size.height) - width) / 2;
    final path = Path()
      ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: r));
    const dash = 3.0, gap = 2.5;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.width != width;
}
