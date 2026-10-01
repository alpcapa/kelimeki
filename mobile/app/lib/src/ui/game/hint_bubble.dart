// Arayüz öğesine çapalı eğitim balonu (1 Ekim 2026) — web
// `src/components/HintBubble.tsx` ikizi.
//
// Menü (avatar), "Hamleler", "Torba" ve "Mesajlaşma" balonları bunu kullanır;
// tahtaya çapalı iki balon (anlam · zoom) `BoardWidget`in kendi `coach` /
// `zoomHint` geometrisinde kalıyor. Görsel dil o ikisiyle AYNI (mavi zemin,
// beyaz kalın metin, 9 px köşe, aynı gölge).
//
// Balon `OverlayPortal` ile ÜST katmanda çiziliyor, hedefe
// `CompositedTransformFollower` ile bağlı: hedefin atası (`ClipRRect`'li
// tahta kartı, kaydırılan gövde) balonu KIRPMAZ ve balon dokunuşu YUTMAZ
// (`IgnorePointer`) — web'deki `pointer-events-none`.
import 'package:flutter/material.dart';

import '../tokens.dart';

enum HintBubbleYon { ust, alt }

enum HintBubbleHiza { bas, orta, son }

class HintAnchor extends StatefulWidget {
  /// Balon şu an görünsün mü — kararı ekran veriyor (`pickOnboardingHint`).
  final bool show;
  final String text;
  final HintBubbleYon yon;
  final HintBubbleHiza hiza;
  final Widget child;

  const HintAnchor({
    super.key,
    required this.show,
    required this.text,
    required this.yon,
    required this.hiza,
    required this.child,
  });

  @override
  State<HintAnchor> createState() => _HintAnchorState();
}

class _HintAnchorState extends State<HintAnchor> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    // Portal bir kez, ilk kareden SONRA açılır ve açık kalır; balonun
    // görünürlüğü aşağıdaki `overlayChildBuilder`da `show`a bakar.
    // ⚠ `show()`/`hide()` build sırasında ÇAĞRILAMAZ (assert) — `show`
    // değişince `didUpdateWidget`ta portalı açıp kapamak o yüzden olmuyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ust = widget.yon == HintBubbleYon.ust;
    final (Alignment hedef, Alignment balon) = switch (widget.hiza) {
      HintBubbleHiza.bas => ust
          ? (Alignment.topLeft, Alignment.bottomLeft)
          : (Alignment.bottomLeft, Alignment.topLeft),
      HintBubbleHiza.orta => ust
          ? (Alignment.topCenter, Alignment.bottomCenter)
          : (Alignment.bottomCenter, Alignment.topCenter),
      HintBubbleHiza.son => ust
          ? (Alignment.topRight, Alignment.bottomRight)
          : (Alignment.bottomRight, Alignment.topRight),
    };
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => !widget.show
          ? const SizedBox.shrink()
          : Positioned(
              left: 0,
              top: 0,
              child: CompositedTransformFollower(
                link: _link,
                targetAnchor: hedef,
                followerAnchor: balon,
                offset: Offset(0, ust ? -2 : 2),
                child: IgnorePointer(
                  child: _Balon(
                    key: const ValueKey('hint-bubble'),
                    text: widget.text,
                    yon: widget.yon,
                    hiza: widget.hiza,
                  ),
                ),
              ),
            ),
      child: CompositedTransformTarget(link: _link, child: widget.child),
    );
  }
}

class _Balon extends StatelessWidget {
  final String text;
  final HintBubbleYon yon;
  final HintBubbleHiza hiza;
  const _Balon({
    super.key,
    required this.text,
    required this.yon,
    required this.hiza,
  });

  // Web `#2563EB` — tahtadaki zoom/anlam balonlarıyla aynı token.
  static const _mavi = kAccent;

  @override
  Widget build(BuildContext context) {
    final genislik = MediaQuery.sizeOf(context).width;
    // Web `clamp(11px, 3.2vw, 16px)`.
    final punto = (genislik * 0.032).clamp(11.0, 16.0);
    final kutu = ConstrainedBox(
      // Web `max-width: min(260px, 70vw)`.
      constraints:
          BoxConstraints(maxWidth: genislik * 0.7 < 260 ? genislik * 0.7 : 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _mavi,
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
                color: Color(0x470F172A), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: punto,
              height: 1.375,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
    // Kuyruk hedefin kenarına bakar; hizaya göre balonun başında/ortasında/
    // sonunda (hedef dar bir düğme olduğundan onun ortasına yakın düşer).
    final kuyruk = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: CustomPaint(
        size: const Size(12, 7),
        painter: _Kuyruk(asagi: yon == HintBubbleYon.ust, renk: _mavi),
      ),
    );
    final hizalama = switch (hiza) {
      HintBubbleHiza.bas => CrossAxisAlignment.start,
      HintBubbleHiza.orta => CrossAxisAlignment.center,
      HintBubbleHiza.son => CrossAxisAlignment.end,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: hizalama,
      children: yon == HintBubbleYon.ust ? [kutu, kuyruk] : [kuyruk, kutu],
    );
  }
}

class _Kuyruk extends CustomPainter {
  final bool asagi;
  final Color renk;
  const _Kuyruk({required this.asagi, required this.renk});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    if (asagi) {
      p
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    } else {
      p
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, 0);
    }
    canvas.drawPath(p..close(), Paint()..color = renk);
  }

  @override
  bool shouldRepaint(_Kuyruk old) => old.asagi != asagi || old.renk != renk;
}
