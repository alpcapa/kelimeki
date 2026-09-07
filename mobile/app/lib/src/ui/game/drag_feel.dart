// Sürükleme jestinin "HİSSİ": eşikler, kaldırma payı, hayalet taşın ölçüsü —
// web `src/utils/dragFeel.ts`in birebir ikizi.
//
// NEDEN AYRI DOSYA (7 Eylül 2026, Onboarding Faz 4): bu sabitler
// `game_screen.dart` ile `online_game_screen.dart`ta İKİ KOPYA hâlinde
// duruyordu ve tanıtım ekranı (`tutorial_game.dart`) üçüncüsünü
// gerektirecekti. Web aynı gün aynı gerekçeyle `dragFeel.ts`e çıkardı; port
// da aynısını yapıyor — `layout_parity_test.dart` artık değeri TEK Dart
// kaynağından okuyor ve üç ekranın da onu pointer TÜRÜNE göre kullandığını
// ayrıca arıyor (yerel kopya geri gelirse test düşer).
//
// ⚠ Burada YALNIZCA "his" var: jestin mantığı (neyin nereye bırakılabildiği,
// taslak taşın geri alınması, ıskalama kurtarma, zoom) her ekranın kendi
// işidir ve BİLEREK burada değil (mobile/CLAUDE.md → "İKİ oyun ekranı aynı
// deseni paylaşıyor" — artık üç).
import 'package:flutter/gestures.dart' show PointerDeviceKind;

/// Sürüklemenin "dokunuş" değil gerçek bir sürükleme sayılması için gereken
/// minimum işaretçi hareketi (px). FARE ile PARMAK aynı değeri KULLANAMAZ
/// (22 Ağustos 2026 ölçümü, gerekçe `src/utils/dragFeel.ts`te): 6px'lik tek
/// eşik altında parmak 6px oynayan bir dokunuş "sürükleme" sayılıp aynı
/// hücrede bittiğinden HİÇBİR ŞEY yapmıyordu. Platform normları 6'nın
/// üstünde (Android touch slop 8, iOS ~10pt, Flutter kTouchSlop 18).
const double kDragThresholdMouse = 6; // web DRAG_THRESHOLD_MOUSE
const double kDragThresholdTouch = 10; // web DRAG_THRESHOLD_TOUCH

/// Jestin kaynağına göre eşik — fare 6, parmak/kalem 10 (web
/// `dragThresholdFor(pointerType)`).
double dragThresholdFor(PointerDeviceKind kind) =>
    kind == PointerDeviceKind.mouse ? kDragThresholdMouse : kDragThresholdTouch;

/// BIRAKMA anındaki karar eşiği — yukarıdaki hayalet eşiğinden AYRI.
///
/// NEDEN VAR (27 Ağustos 2026, kullanıcı İKİNCİ kez bildirdi: *"Hâlâ
/// tahtaya koyulan taşı her zaman alamıyorum. 1-2 denemeden sonra
/// alabiliyorum."*): 10 px hayaleti GÖSTERMEK için doğru bir sınır ama
/// BIRAKMA kararı için fazla dar — parmak o kadarını istemeden aşıyor ve
/// dokunuş sürükleme sayılıp sessizce kayboluyordu. Ölçüldü (420×900,
/// taslak taşa dokunup bırakma): 6 px kayma → geri alındı; **12 px ve
/// 20 px kayma → HİÇBİR ŞEY olmadı**. 24, tahta hücresinin (~26 px) hemen
/// altında: bir hücreden az giden bir jest zaten bir hedef ifade edemiyor.
const double kTapSlopOnRelease = 24; // web TAP_SLOP_ON_RELEASE

/// Sürüklenen taşın görseli, parmağın altında kalıp görüşü engellememesi
/// için işaretçinin bu kadar ÜZERİNDE çizilir — ve bırakma hedefi DE aynı
/// noktadan hesaplanır (görsel ile hedef asla ayrışmaz).
const double kDragLift = 30; // web DRAG_LIFT

/// Hayalet taşın kutusu (web `GHOST_TILE_STYLE`: 46px, `scale(1.1)`,
/// merkezlenmiş). Ek gölge YOK (kullanıcı web karşılaştırması): sürüklenen
/// taş yalnızca kendi taş görünümünü taşır, hedef kesikli çerçeveyle
/// gösterilir.
const double kGhostTileSize = 46;
const double kGhostTileScale = 1.1;
