/**
 * "Sayfa ekranda en az bir kez GÖRÜNDÜ mü" kapısı — web telemetrisinin
 * (Ziyaretçi Yolculuğu + Huni v2 `land`/`visit`) ortak eşiği.
 *
 * Neden (2 Ekim 2026, canlıdan ölçüldü): karşılamada "ayrılan" Android
 * oturumlarının 133'ü TAM 31-33. saniyede, hiç kaydırılmadan kapanmıştı
 * (30. saniyede sıfır, 31-32'de 124). Neredeyse hepsi Meta/Instagram
 * reklamından ve kampanyanın başladığı 28 Eylül'den itibaren. Açıklama
 * adayı: uygulama içi tarayıcı reklamın sayfasını kullanıcı tıklamadan önce
 * ARKA PLANDA yüklüyor, açılmazsa ~30 sn sonra atıyor — o yükleme bizim için
 * hem bir "ziyaret" hem bir "ayrılma" oluyordu. Arka planda yüklenen sayfa
 * `visibilityState === 'hidden'` ile başlar; görünmeden kapanırsa hiçbir şey
 * gönderilmez. ⚠ Bu bir HİPOTEZ: 31-33 sn yığılması yeni verilerde kaybolursa
 * doğrulanmış olur (bkz. docs/decisions/admin-panel.md → "Görünmeyen sayfa").
 *
 * Görünürlük API'si yoksa (çok eski tarayıcı) sayfa görünür sayılır —
 * eşiğin varsayılanı ÖLÇMEK, susmak değil.
 */
let visibleOnce = false;
let waiting: Array<() => void> | null = null;

function isVisibleNow(): boolean {
  try {
    return typeof document === 'undefined' || document.visibilityState !== 'hidden';
  } catch {
    return true;
  }
}

function onVisibilityChange(): void {
  if (!isVisibleNow()) return;
  document.removeEventListener('visibilitychange', onVisibilityChange);
  visibleOnce = true;
  const fns = waiting ?? [];
  waiting = null;
  for (const fn of fns) fn();
}

/** Sayfa şu ana kadar en az bir kez görünür olduysa `true`. */
export function pageWasVisible(): boolean {
  if (!visibleOnce && isVisibleNow()) visibleOnce = true;
  return visibleOnce;
}

/**
 * `fn`'i sayfa görünürse hemen, değilse İLK görünür olduğu anda (bir kez)
 * çalıştırır. Sayfa hiç görünmeden kapanırsa `fn` hiç çalışmaz.
 */
export function whenPageVisible(fn: () => void): void {
  if (pageWasVisible()) {
    fn();
    return;
  }
  if (!waiting) {
    waiting = [];
    document.addEventListener('visibilitychange', onVisibilityChange);
  }
  waiting.push(fn);
}
