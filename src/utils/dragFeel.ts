// Kelimeki — sürükleme jestinin "HİSSİ": eşikler, kaldırma payı, hayalet
// taşın görseli.
//
// NEDEN AYRI DOSYA (7 Eylül 2026): bu sabitler `App.tsx` ile
// `OnlineGameScreen.tsx`te İKİ KOPYA hâlinde duruyordu ve tanıtım ekranı
// (`TutorialGame.tsx`) üçüncü kopyayı gerektirecekti. Bu depoda iki kopyanın
// sessizce ayrışması en sık tekrarlayan hata sınıfı; üstelik buradaki her
// sayı ELLE ÖLÇÜLMÜŞ bir kullanıcı şikâyetinin cevabı — birinde düzeltilip
// ötekinde unutulması, düzeltmenin yarısını canlıda bırakmak demek.
//
// ⚠ Burada YALNIZCA "his" var: jestin mantığı (neyin nereye bırakılabildiği,
// taslak taşın geri alınması, ıskalama kurtarma, zoom) her ekranın kendi
// işidir ve BİLEREK burada değil.
import type { CSSProperties } from 'react';

// Sürüklemenin "tıklama" değil gerçek bir sürükleme sayılması için gereken
// minimum işaretçi hareketi (piksel). FARE ile PARMAK aynı değeri
// KULLANAMAZ: 22 Ağustos 2026'da ölçüldü — 6px'lik tek eşik altında, parmak
// 6px oynayan bir dokunuş "sürükleme" sayılıp aynı hücrede bittiğinden
// HİÇBİR ŞEY yapmıyordu (raf taşı seçilmiyor, konmuş taş geri alınmıyor,
// joker penceresi açılmıyor) — kullanıcıya "dokunuşum işlemedi" olarak
// görünen sessiz bir kayıp. Platform normları 6'nın üstünde: Android/Chrome
// touch slop 8px, iOS ~10pt, Flutter kTouchSlop 18. Fare tarafı bilerek
// DEĞİŞMEDİ (imleç titremez, 6px orada doğru his).
export const DRAG_THRESHOLD_MOUSE = 6;
export const DRAG_THRESHOLD_TOUCH = 10;

/** Jestin kaynağına göre eşik — fare 6, parmak/kalem 10. */
export const dragThresholdFor = (pointerType: string): number =>
  pointerType === 'mouse' ? DRAG_THRESHOLD_MOUSE : DRAG_THRESHOLD_TOUCH;

/// BIRAKMA anındaki karar eşiği — yukarıdaki hayalet eşiğinden AYRI.
///
/// NEDEN VAR (27 Ağustos 2026, kullanıcı uygulamada İKİNCİ kez bildirdi:
/// *"Hâlâ tahtaya koyulan taşı her zaman alamıyorum. 1-2 denemeden sonra
/// alabiliyorum."*): 10 px (Android touch slop) hayaleti GÖSTERMEK için
/// doğru bir sınır ama BIRAKMA kararı için fazla dar — parmak o kadarını
/// istemeden aşıyor ve dokunuş sürükleme sayılıp sessizce kayboluyordu.
///
/// Portta ölçüldü (taslak taşa dokunup bırakma): 6 px kayma → geri alındı;
/// **12 px ve 20 px kayma → HİÇBİR ŞEY olmadı**. Raf tarafı da aynı:
/// titreşimli dokunuşta taş seçilemiyordu bile.
///
/// 24, tahta hücresinin (~26 px) hemen altında: bir hücreden az giden bir
/// jest zaten bir hedef ifade edemiyor.
export const TAP_SLOP_ON_RELEASE = 24;

// Sürüklenen taşın görseli, parmağın altında kalıp görüşü engellememesi için
// işaretçinin bu kadar üzerinde çizilir.
export const DRAG_LIFT = 30;

/**
 * Sürüklenen taş, parmağın `DRAG_LIFT` kadar üzerinde çizilir (görüşü
 * engellemesin diye). Tahtanın en üst satırı ekranın üst kısmına (başlığa)
 * yakınsa bu kaldırma, işaretçinin hedef noktasını tahtanın dışına
 * (başlığın üzerine) taşıyabilir — özellikle bir oyuncunun ilk hamlede
 * değmesi gereken köşe hücresi tam üst satırdaysa, bu hücreye asla
 * bırakılamaz hâle gelirdi. Kaldırılmış noktayı tahtanın üst kenarının
 * altında tutmak için kırpılır; görsel taş ve bırakma hedefi hep aynı
 * (kırpılmış) noktayı kullanır, ikisi asla ayrışmaz.
 */
export function liftedPoint(clientY: number): number {
  // En üst satırın (r=0) hücresi, kaldırılmış noktanın hâlâ bir
  // `[data-cell]` içinde kalması için kullanılır — tahtanın kendi kap
  // elemanının üst kenarı iç dolgu (padding) içerdiğinden, o kenara göre
  // kırpmak noktayı hücre olmayan bir bölgeye düşürebilirdi.
  const topRowEl = document.querySelector('[data-cell="0,0"]') as HTMLElement | null;
  const minY = topRowEl ? topRowEl.getBoundingClientRect().top + 1 : -Infinity;
  return Math.max(clientY - DRAG_LIFT, minY);
}

/**
 * Parmağın altındaki hayalet taşın kutusu — hafif büyütülmüş ve gölgeli,
 * yani "havada" duruyor. `left`/`top` çağıranda (işaretçinin konumu).
 */
export const GHOST_TILE_STYLE: CSSProperties = {
  width: 46,
  height: 46,
  transform: 'translate(-50%, -50%) scale(1.1)',
  filter: 'drop-shadow(0 10px 16px rgba(0,0,0,0.35))',
};
