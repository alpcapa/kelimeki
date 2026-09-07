// Tailwind `animate-tile-pulse` (`pulse 1s infinite alternate`: opaklık
// 1 ↔ 0.5) eşleniği — tanıtımın hedef kareleri ve raftaki vurgulu taşları
// "nefes alır". Tek yerde, çünkü iki widget (`BoardWidget`, `RackWidget`)
// aynı ritmi paylaşıyor; ritim değişirse ikisi birden değişsin.
import 'package:flutter/material.dart';

class PulseOpacity extends StatefulWidget {
  final Widget child;
  const PulseOpacity({super.key, required this.child});

  @override
  State<PulseOpacity> createState() => _PulseOpacityState();
}

class _PulseOpacityState extends State<PulseOpacity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.5).animate(_c),
      child: widget.child,
    );
  }
}
