import { registerSW } from 'virtual:pwa-register';
import { loadGameState } from '../utils/gameStorage';

// Tarayıcı service worker dosyasını normalde günde en fazla bir kez kontrol
// eder. Bu yüzden bir deploy'dan hemen sonra bile çoğunlukla eski,
// önbelleğe alınmış sürüm gösterilmeye devam eder. Uygulama ön plana her
// döndüğünde (sekme/uygulama değişimi, arka plandan dönüş) güncellemeyi
// elle kontrol ederek yeni sürümün mümkün olduğunca hızlı devreye girmesini
// sağlıyoruz.
//
// registerType 'prompt' (autoUpdate DEĞİL): yeni sürüm hazır olur olmaz
// sayfayı kendiliğinden yenilemiyoruz — bu, tam oyun sırasında (özellikle
// aşağı çekme hareketinin tetiklediği visibilitychange/pageshow olaylarında)
// devam eden bir oyunu habersizce kesintiye uğratıyordu. Bunun yerine
// güncellemeyi yalnızca ortada bitmemiş bir oyun yokken (loadGameState null
// dönüyorsa) uyguluyoruz; oyun sürerken hazır bekleyen güncelleme, oyun
// bitip bir sonraki kontrolde devreye girer.
export function setupPwaUpdates(): void {
  if (!('serviceWorker' in navigator)) return;

  let registration: ServiceWorkerRegistration | undefined;
  let applyUpdate: (() => void) | null = null;

  const updateSW = registerSW({
    immediate: true,
    onRegisteredSW(_swUrl, reg) {
      registration = reg;
    },
    onNeedRefresh() {
      applyUpdate = () => void updateSW(true);
      tryApplyUpdate();
    },
  });

  const tryApplyUpdate = () => {
    if (!applyUpdate || loadGameState()) return;
    const apply = applyUpdate;
    applyUpdate = null;
    apply();
  };

  const checkForUpdate = () => {
    registration?.update().catch(() => {});
    tryApplyUpdate();
  };

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') checkForUpdate();
  });
  window.addEventListener('focus', checkForUpdate);
  window.addEventListener('pageshow', checkForUpdate);
  setInterval(checkForUpdate, 60 * 60 * 1000);
}
