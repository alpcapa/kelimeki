// k-lig listelerinde sabit "senin sıran" satırının kararı — web
// `src/utils/ownRowPin.ts` + `useRowInView.ts` portu (16 Ekim 2026).
//
// Eskiden yalnızca "satır yüklenen satırlar arasında mı" diye bakılıyordu;
// ilk sayfa 10 satır ve pencere 8 satır gösterdiğinde 9.-10. sıradaki
// oyuncunun satırı YÜKLÜ ama görünmez, sabit satır da gizli kalıyordu
// (kullanıcı bildirdi). Kural artık "ekranda mı".
import 'package:flutter/widgets.dart';

/// Web `ROW_IN_VIEW_RATIO` — satırın en az bu kadarı görünürken "görünür"
/// sayılır (yarım kesik satırı oyuncu okuyamıyor).
const double kRowInViewRatio = 0.9;

/// Sabit "senin sıran" satırı gösterilsin mi? Web `shouldPinOwnRow` ile
/// birebir. `inView == null` = henüz ölçülmedi → yüklüyse gizli (yanıp
/// sönme olmasın).
bool shouldPinOwnRow({
  required bool hasRank,
  required bool inList,
  required bool? inView,
}) {
  if (!hasRank) return false;
  if (!inList) return true;
  return inView == false;
}

/// Saf geometri: [rowTop, rowBottom] aralığının [viewTop, viewBottom]
/// içinde kalan payı en az [kRowInViewRatio] mı?
bool rowMostlyInView({
  required double rowTop,
  required double rowBottom,
  required double viewTop,
  required double viewBottom,
}) {
  final h = rowBottom - rowTop;
  if (h <= 0) return false;
  final overlap = (rowBottom < viewBottom ? rowBottom : viewBottom) -
      (rowTop > viewTop ? rowTop : viewTop);
  return overlap / h >= kRowInViewRatio;
}

/// Kendi satırının kaydırılan görünüm içindeki durumunu ölçer. State'in
/// `build`inde satıra [rowKey] (örn. `KeyedSubtree`), listeye [viewKey]
/// verilir; kaydırmada ve her karede [measure] çağrılır, `true` dönerse
/// `setState` gerekir.
class OwnRowTracker {
  final rowKey = GlobalKey();
  final viewKey = GlobalKey();

  /// `null` = ölçülemedi (satır ya da görünüm henüz yok).
  bool? inView;

  bool measure() {
    final next = _read();
    if (next == inView) return false;
    inView = next;
    return true;
  }

  bool? _read() {
    final view = viewKey.currentContext?.findRenderObject();
    if (view is! RenderBox || !view.attached || !view.hasSize) return null;
    // Görünüm var ama satırın widget'ı HİÇ inşa edilmemiş: `ListView`
    // tembel — görünür alan + önbellek payının ötesindeki satırlar yok.
    // Bu "ölçülemedi" değil, kesin "görünmüyor" demek. `null` dönseydi
    // sabit satır gizlenir → liste uzar → satır inşa edilir → görünmez
    // → satır geri gelir: sonsuz titreşim (ilk sürümde `pumpAndSettle`
    // zaman aşımına uğradı).
    final rowCtx = rowKey.currentContext;
    if (rowCtx == null) return false;
    final row = rowCtx.findRenderObject();
    if (row is! RenderBox || !row.attached || !row.hasSize) return null;
    final rowTop = row.localToGlobal(Offset.zero).dy;
    final viewTop = view.localToGlobal(Offset.zero).dy;
    return rowMostlyInView(
      rowTop: rowTop,
      rowBottom: rowTop + row.size.height,
      viewTop: viewTop,
      viewBottom: viewTop + view.size.height,
    );
  }
}
