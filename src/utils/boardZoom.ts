// Kelimeki — tahta yakınlaştırmasının SAF mantığı (web).
//
// Port ikizi: `mobile/app/lib/src/ui/game/board_zoom.dart`. Karar/gerekçe
// orada yazılı; burada YALNIZCA web'e özgü farklar not edilir. Kullanıcı
// kararı (1 Eylül 2026): *"web'e de uygulama kararı aldım. Her yerde aynı
// deneyim olsun."* — yani bu bir port farkı DEĞİL artık, iki yüzeyde de
// aynı davranış.
//
// Davranış (ikisinde de aynı):
//   • Boş kareye çift dokunuş → 2× yakınlaş (dokunulan noktaya odaklı),
//     tekrar çift dokunuş → eski hâl.
//   • Tek dokunuşlar GECİKMEZ ve değişmez: dokunuş-1 normal işini yapar
//     (taş konur ve KONDUĞU YERDE KALIR), pencere içinde gelen dokunuş-2
//     yalnızca yutulur ve zoom'u değiştirir.
//   • Çift, yalnızca BOŞ kareye/boşluğa/çerçeveye dokunuşla başlar; taşa
//     dokunuş (geri alma, anlam penceresi) çift BAŞLATAMAZ ama ikinci
//     dokunuş olarak yutulabilir.
//   • Zoom açıkken tahta tek parmakla kaydırılır (pan).
//
// WEB'E ÖZGÜ İKİ FARK (ikisi de web'i KOLAYLAŞTIRIYOR):
//   1. Hücre bulma `document.elementFromPoint` ile — tarayıcı hit-test'i
//      CSS transform'u kendisi tersine çevirdiğinden portun stride
//      matematiğinde gereken "görünür kare kapısı" burada gerekmez.
//   2. Dış hat `vectorEffect="non-scaling-stroke"` çizildiğinden zoom'da
//      KALINLAŞMAZ; portta stroke ölçekle büyüyor.
//      ⚠ Bu madde 2 Eylül 2026'ya kadar "kırpma payı bu yüzden web'de daha
//      küçük yeter" diye bitiyordu ve artık YANLIŞ: web'de pay hiç YOK
//      (aşağıdaki iki kaldırma notu). Stroke farkı duruyor, paya gerekçe
//      olması bitti — ölçüldü ki dış hat zaten dolgunun 10 px'i içinde.

import { CORNER, SIZE } from '../game/constants';

/** Yakınlaştırma oranı — port `kBoardZoomScale` ile AYNI olmalı. */
export const BOARD_ZOOM_SCALE = 2;

/** Çift dokunuş penceresi/yarıçapı — port `kDoubleTapWindow`/`Radius`. */
export const DOUBLE_TAP_WINDOW_MS = 300;
export const DOUBLE_TAP_RADIUS = 40;

/** Aç/kapa animasyonu; pan sırasında animasyon YOK (parmak gecikmesiz
 *  takip edilmeli) — port `kZoomAnimDuration`. */
export const ZOOM_ANIM_MS = 180;

/**
 * Tanıtım balonunun KENDİ KENDİNE kapanma süresi (16 Eylül 2026, kullanıcı
 * isteği; bir oyuncu bildirdi: *"tanıtımdan sonra zoom özelliği için sürekli
 * kalan uyarı mesajı oyun oynamayı zorlaştırıyor... 3-5 saniye sonra gidecek
 * şekle getirelim. İnsanlar okumuyor."*). Öncesinde balon YALNIZCA zoom
 * denenince kapanıyordu — yani denemeyen kullanıcıda oyun boyunca duruyordu.
 *
 * ⚠ **Kendi kendine kapanma "denedi" SAYILMAZ.** `markZoomTried` çağrılmaz ve
 * gösterim sayacı da artmaz (o zaten karar anında arttı), yani kural
 * değişmiyor: hiç denemeyen kullanıcı balonu ikinci oyun açılışında bir kez
 * daha görür (`shouldShowZoomHint`, tavan 2).
 *
 * Port `kZoomHintAutoHide` ile AYNI olmalı.
 */
export const ZOOM_HINT_AUTO_HIDE_MS = 4000;

/**
 * Tanıtım balonunun metni — port `kZoomHintText` ile BİREBİR aynı olmalı
 * (27 Eylül 2026, kullanıcı: *"mesaj çok uzun... Boş kareye çift tık tahtayı
 * büyütür. Şimdi Dene!"*). Önceki metin: "Boş kareye veya çerçevesine çift
 * tıklama tahtayı büyütür. Hemen dene!".
 */
// ⚠ `\n` bilinçli: iki cümle iki satır. Serbest sarmada ikinci cümle
// "Şimdi / Dene!" diye ortadan kırılıyordu (390 px'te ölçüldü). Web
// `whitespace-pre-line` ile, port `Text` doğrudan uyguluyor.
export const ZOOM_HINT_TEXT = 'Boş kareye çift tık tahtayı büyütür.\nŞimdi Dene!';

/**
 * Balonun işaret ettiği kare: SOL-ALT köşe bloğunun (köşe 2, satır 9-12 ×
 * sütun 0-3) ortasına en yakın BOŞ kare. Uzaklık eşitse önce üstteki satır,
 * sonra soldaki sütun — yani boş bir tahtada (10,1).
 *
 * Neden burası (27 Eylül 2026, kullanıcı: *"X3 üzerine göstermesi kafa
 * karıştırıyor. Sol alt bölümün ortasına beyaz boş kareyi gösteren bir mesaj
 * balonu olsun"*): balon önceden merkez kareyi (6,6) gösteriyordu, o da X3 —
 * oyuncu balonu çarpan hakkında sanıyordu.
 *
 * Balon oyun ORTASINDA da açılabildiği için (tavan 2 açılış) kare dolu
 * olabilir; o zaman bloğun bir sonraki boş karesi seçilir. Bloğun TAMAMI
 * doluysa `null` → balon çizilmez (dolu bir kareyi "boş kare" diye
 * göstermektense hiç göstermemek).
 *
 * Port ikizi `zoomHintTarget` (`board_zoom.dart`) — sıra ikisinde de aynı.
 */
export function zoomHintTarget(
  isEmpty: (r: number, c: number) => boolean,
): [number, number] | null {
  const mr = SIZE - CORNER / 2 - 0.5; // 10.5
  const mc = CORNER / 2 - 0.5; // 1.5
  const adaylar: [number, number][] = [];
  for (let r = SIZE - CORNER; r < SIZE; r++) {
    for (let c = 0; c < CORNER; c++) adaylar.push([r, c]);
  }
  const d = ([r, c]: [number, number]) => (r - mr) ** 2 + (c - mc) ** 2;
  adaylar.sort((a, b) => d(a) - d(b) || a[0] - b[0] || a[1] - b[1]);
  return adaylar.find(([r, c]) => isEmpty(r, c)) ?? null;
}

/** Pan'in ARTIĞI olan click'i yutma penceresi (port'takiyle aynı gerekçe:
 *  10-18 px'lik bir pan tarayıcının tap eşiğinin altında kalıp ayrıca bir
 *  `click` üretir). */
export const PAN_SWALLOW_MS = 120;

/**
 * ⚠ Eski `BOARD_CLIP_SLACK` (4 px) 2 Eylül 2026'da KALDIRILDI. Görünür kare
 * artık kartın dışına hiç taşmıyor, kırpması da kare değil kartın üst
 * köşelerinin yuvarlağını taşıyor (`Board.tsx`). Gerekçe ölçüldü: pay
 * dış hattın stroke taşması için konmuştu ama zoom'da dış hat ızgaranın
 * 10 px dolgusunun içinde, yani 2×'te kenardan ≥20 px içeride — kırpma
 * sınırına hiç yaklaşmıyor. Pay yalnızca kartın yuvarlak köşesini
 * doldurup kullanıcıya "tahta taşıyor" olarak görünüyordu.
 */

/**
 * ⚠ `BOARD_BADGE_CLIP_SLACK` (14 px) 2 Eylül 2026'da KALDIRILDI. Rozet
 * katmanı artık ızgarayla BİREBİR aynı kırpmayı kullanıyor: pay yok, şekil
 * kartın üst köşelerinin yuvarlağı (`Board.tsx`). Pay "kenardaki rozet
 * kesilmesin" diye konmuştu ama kullanıcının gördüğü taşmanın kendisiydi
 * (ölçüldü: kartın dışına 126 piksel). Karar: rozet kartın İÇİNDE kalır,
 * gerekirse kesilir — taşların kenarda kesilmesiyle aynı davranış.
 */

export type ZoomState = {
  zoomed: boolean;
  /** Ölçeksiz ızgara uzayında öteleme (transform-origin: 0 0). */
  x: number;
  y: number;
  /** Aç/kapa animasyonlu, pan animasyonsuz. */
  animate: boolean;
};

export const ZOOM_OFF: ZoomState = { zoomed: false, x: 0, y: 0, animate: true };

/** Ölçekli içerik görünür kareyi HER ZAMAN tamamen kaplar. */
export function clampZoomOffset(
  x: number,
  y: number,
  width: number,
  height: number,
  scale: number = BOARD_ZOOM_SCALE,
): { x: number; y: number } {
  const minX = width * (1 - scale);
  const minY = height * (1 - scale);
  return {
    x: Math.min(0, Math.max(minX, x)),
    y: Math.min(0, Math.max(minY, y)),
  };
}

/**
 * Çift dokunuş: [focalX, focalY] (kutunun YEREL, ölçeksiz koordinatı)
 * yerinde kalacak şekilde yakınlaş; zaten yakınsa sıfırla.
 * Odak korunumu: p → s·p + o = p ⇒ o = p·(1−s).
 */
export function toggleZoom(
  state: ZoomState,
  focalX: number,
  focalY: number,
  width: number,
  height: number,
): ZoomState {
  if (state.zoomed) return { ...ZOOM_OFF };
  const { x, y } = clampZoomOffset(
    focalX * (1 - BOARD_ZOOM_SCALE),
    focalY * (1 - BOARD_ZOOM_SCALE),
    width,
    height,
  );
  return { zoomed: true, x, y, animate: true };
}

/** Parmak kaydırması (ekran uzayı delta'sı). */
export function panZoom(
  state: ZoomState,
  dx: number,
  dy: number,
  width: number,
  height: number,
): ZoomState {
  if (!state.zoomed) return state;
  const { x, y } = clampZoomOffset(state.x + dx, state.y + dy, width, height);
  if (x === state.x && y === state.y) return state;
  return { zoomed: true, x, y, animate: false };
}

/** `transform` değeri — kapalıyken `none` (eski render'la BİREBİR aynı). */
export function zoomTransform(state: ZoomState): string {
  return state.zoomed
    ? `translate(${state.x}px, ${state.y}px) scale(${BOARD_ZOOM_SCALE})`
    : 'none';
}

/**
 * Çift dokunuş algılayıcısı — tarayıcının `dblclick`i BİLEREK kullanılmıyor:
 * o, ilk `click`i geciktirmez ama YALNIZCA fare/aynı hedef için güvenilir ve
 * dokunmatikte ikinci dokunuşu tek başına ayırt etmiyor; ayrıca hücreler
 * arası boşluk/çerçeve gibi hedefsiz noktalarda hiç doğmuyor. Port da aynı
 * gerekçeyle kendi algılayıcısını yazıyor.
 *
 * Sözleşme (çağıran ekranlar):
 *   1. Her tahta dokunuşunun BAŞINDA `tryCompletePair` sorulur; `true` →
 *      bu dokunuş bir çiftin İKİNCİSİ: hücre işlemi YUTULUR, zoom değişir,
 *      ilk dokunuşun yaptığı iş (koyulan taş dahil) OLDUĞU GİBİ KALIR.
 *   2. `false` ise dokunuş normal işini yapar; ardından boş kareye/boşluğa
 *      düşen dokunuş `registerPairableTap`, taşa düşen `markUnpairable`.
 */
export class DoubleTapDetector {
  private lastAt: number | null = null;
  private lastX = 0;
  private lastY = 0;

  tryCompletePair(x: number, y: number, now: number = Date.now()): boolean {
    const at = this.lastAt;
    if (at === null) return false;
    const pair =
      now - at <= DOUBLE_TAP_WINDOW_MS &&
      Math.hypot(x - this.lastX, y - this.lastY) <= DOUBLE_TAP_RADIUS;
    if (pair) this.reset();
    return pair;
  }

  registerPairableTap(x: number, y: number, now: number = Date.now()): void {
    this.lastAt = now;
    this.lastX = x;
    this.lastY = y;
  }

  /** Taşa dokunuş / raf / gerçek sürükleme / pan — zinciri kırar. */
  markUnpairable(): void {
    this.reset();
  }

  reset(): void {
    this.lastAt = null;
  }
}
