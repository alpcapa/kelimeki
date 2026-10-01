// Tahtanın YÜKSEKLİK bütçesi — web `src/utils/boardFit.ts`in port ikizi
// (ROADMAP #38; 26 Eylül 2026'ya kadar #26).
//
// 22 Eylül 2026, kullanıcı bildirdi: *"Kelimeki'yi Samsung katlanabilirde
// denedim, tahta yatay iPad gibi görünüyordu, raf ve butonlar ekranın
// altında kalıyordu. Görmek için aşağı kaydırmak gerekiyor, oynamak
// imkânsız."* Sebep iki platformda da aynıydı: tahta YALNIZCA genişlikten
// boyutlanıyordu (`maxWidth: 680` + `AspectRatio(1)`), düzenin hiçbir
// yerinde "ne kadar boyum kaldı" sorusu yoktu.
//
// ÖLÇÜLDÜ (27 Eylül 2026, `board_fit_test.dart`, yerel oyun ekranı, bu
// değişiklikten ÖNCE): tahta her geniş ekranda 656 px'te doyuyor ve PAS
// GEÇ'in altı 985 px'te — açık Fold yatay (1104×768) 217 px · yatay iPad
// (1180×820) 165 px · dizüstü boyu (1440×800) 185 px ekranın altında.
// Web'de aynı üç ölçü 195 · 143 · 163 idi; fark aşağıdaki başlık farkı.
//
// ⚠ Port neden çoğu cihazda bunu HİÇ görmüyordu: telefonlar portre kilitli
// (`main.dart` + manifest), yani "geniş ama kısa" yalnızca iPad manzarasında
// (çoklu görev kilidi yok sayıyor, `Info.plist`) ve büyük ekranlı Android'de
// (Android 16, hedef SDK 36 olan uygulamada sw ≥ 600 dp'de yönelim
// kilidini yok sayıyor — açık katlanabilir tam bu sınıf; cihazda ÖLÇÜLMEDİ)
// ortaya çıkıyor.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Tahta kartının DIŞINDA kalan her şeyin yüksekliği — web
/// `BOARD_CHROME_PX`, BİREBİR (web'de ölçülmüş 301 + Canlı ekranın 7 px'lik
/// başlık payı). `board_fit_test.dart` bu sayıyı web kaynağından okuyup
/// karşılaştırır; biri değişirse öteki de.
const double kBoardChromePx = 308;

/// Tahta kartının tavanı — web `BOARD_MAX_PX` (`max-w-[680px]`).
const double kBoardMaxPx = 680;

/// Kartın inebileceği en küçük boy — web `BOARD_MIN_PX`. Portta telefon
/// portre kilitli olduğundan tabana yalnızca telefondaki bölünmüş ekran
/// (Android çoklu pencere) iner; orada alt şerit kaydırılarak ulaşılır —
/// web'in tablet davranışıyla aynı ("gerekirse birkaç piksel kaydırılır").
const double kBoardMinPx = 324;

// ⚠ PORTA ÖZEL BİR TERİM YOK — üç sabit web'den BİREBİR ve bu ÖLÇÜLEREK
// yeterli bulundu (27 Eylül 2026, `board_fit_test.dart`). Portun başlığı
// web'inkinden 25 px UZUN (kartın üstü web 63 · port 88; dokunma hedefleri,
// 48 px'lik satırlar — bu maddeden ESKİ bir fark), kartın altı 3 px KISA.
// Ama web formülünün kendisinde ~25 px pay var: bütçe sarmalayıcının
// GENİŞLİĞİNE uygulanıyor (kart + 2×12 yatay dolgu), kromun ölçüldüğü dikey
// dolgu ise 18 — web'de Pas Geç'in altı `yükseklik − 25`e düşüyor. Port o
// payın 22'sini başlıkla yiyor ve Pas Geç `yükseklik − 3`te kalıyor:
//
//   1104×768 → web 743 · port 765     1180×820 → web 795 · port 817
//
// Yani tahta İKİ PLATFORMDA AYNI BOYDA (aynı ekran boyunda aynı kart), alt
// şerit ikisinde de ekranın içinde. ⚠ Portun payı yalnızca 3 px: başlık ya
// da alt şerit birkaç piksel uzarsa `board_fit_test.dart` düşer — o gün
// ya o uzamayı geri al ya da buraya ölçülmüş bir port terimi ekle (ve
// ayrışmayı `ROADMAP.md`ye yaz).

/// Tahta sarmalayıcısının (`Padding(12, 6, 12, 12)` + kart) azami genişliği —
/// web `boardMaxWidthCss()`in sayısal karşılığı:
/// `min(680, max(324, yükseklik − 308))`.
///
/// [viewportHeight] web'in `100dvh`i: güvenli alanın İÇİNDE kalan boy
/// ([boardViewportHeight]).
double boardMaxWidth(double viewportHeight) => math.min(
      kBoardMaxPx,
      math.max(kBoardMinPx, viewportHeight - kBoardChromePx),
    );

/// Web `100dvh`inin port karşılığı: ekran boyu eksi güvenli alan (çentik,
/// durum çubuğu, ana ekran çubuğu). Oyun ekranları `SafeArea` içinde
/// çiziliyor, yani sayfanın kullanabildiği boy bu.
///
/// ⚠ `SafeArea`nın DIŞINDAKİ bir context'le çağrılmalı — içeride dolgu
/// sıfırlanmış olur ve tam ekran boyu döner (tahta şerit kadar büyük çıkar).
///
/// ⚠ Klavye (`viewInsets`) BİLEREK düşülmüyor: sohbet penceresi açılınca
/// tahta küçülüp büyümesin; web'de de iOS'un `dvh`i klavyeyle değişmez.
double boardViewportHeight(BuildContext context) =>
    MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).vertical;

/// Taş harfinin/puanının ve merkezdeki X3 etiketinin TAHTAYA göre tavanı —
/// web `index.css` → `.tile-board-letter` (`5.08cqw`), `.tile-board-pts`
/// (`2.18cqw`), `[data-board-grid] .board-x3-label` (`3.33cqw`). `cqw` =
/// ızgaranın İÇ genişliğinin %1'i (kartın genişliği − 2 × `kBoardPad`).
///
/// Neden gerekli: punto EKRAN genişliğinden geliyor (`fluidSize`, web `vw`).
/// Yükseklik bütçesi tahtayı küçültünce harf ekranın tavanında (24 px)
/// kalıp hücreyi taşardı — web'de iPad Safari'de ölçüldü, hücrenin %128'i.
/// Oranlar en dar telefondan: tahta oradakinden de dar olmadıkça bağlamaz.
const double kTileLetterPerGrid = 0.0508;
const double kTilePtsPerGrid = 0.0218;
const double kX3LabelPerGrid = 0.0333;

/// `fluid` puntosu, ızgara genişliği biliniyorsa `grid × oran`la tavanlı.
double capToGrid(double fluid, double? gridWidth, double perGrid) {
  if (gridWidth == null || !gridWidth.isFinite) return fluid;
  return math.min(fluid, gridWidth * perGrid);
}
