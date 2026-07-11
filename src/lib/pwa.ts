import { registerSW } from 'virtual:pwa-register';

// Service worker "autoUpdate" modunda yeni bir sürüm etkinleştiğinde sayfayı
// kendiliğinden yeniler — fakat tarayıcı service worker dosyasını normalde
// günde en fazla bir kez kontrol eder. Bu yüzden bir deploy'dan hemen sonra
// "aşağı çekip yenile" yapılsa bile çoğunlukla eski, önbelleğe alınmış sürüm
// gösterilmeye devam eder. Uygulama ön plana her döndüğünde (pull-to-refresh,
// sekme/uygulama değişimi, arka plandan dönüş) güncellemeyi elle kontrol
// ederek yeni sürümün mümkün olduğunca hızlı devreye girmesini sağlıyoruz.
export function setupPwaUpdates(): void {
  if (!('serviceWorker' in navigator)) return;

  let registration: ServiceWorkerRegistration | undefined;

  registerSW({
    immediate: true,
    onRegisteredSW(_swUrl, reg) {
      registration = reg;
    },
  });

  const checkForUpdate = () => {
    registration?.update().catch(() => {});
  };

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') checkForUpdate();
  });
  window.addEventListener('focus', checkForUpdate);
  window.addEventListener('pageshow', checkForUpdate);
  setInterval(checkForUpdate, 60 * 60 * 1000);
}
