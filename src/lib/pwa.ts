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
// dönüyorsa) ve bu sayfa bir auth-redirect (ör. şifre sıfırlama) ile
// açılmamışsa uyguluyoruz; hazır bekleyen güncelleme, o durum ortadan
// kalkınca (oyun biter/sayfa normal şekilde tekrar açılır) bir sonraki
// kontrolde devreye girer.
export function setupPwaUpdates(): void {
  if (!('serviceWorker' in navigator)) return;

  // Şifre sıfırlama/magic link gibi implicit-akış bağlantıları access_token'ı
  // URL hash'inde taşır; Supabase istemcisi bunu işleyip PASSWORD_RECOVERY
  // olayını tetikledikten sonra hash'i temizler. Bu satır sayfa yüklenir
  // yüklenmez, o işlemden önce senkron olarak okunur. Böyle bir bağlantıyla
  // açılmışsa bu sayfa görüntülemesi boyunca güncellemeyi otomatik
  // uygulamıyoruz — aksi halde, tam Supabase oturumu/PASSWORD_RECOVERY'yi
  // işleyip "yeni şifre belirle" ekranını gösterdiği sırada gelen "yeni sürüm
  // hazır" reload'u sayfayı sıfırlıyor, kullanıcı ekranı bir anlığına görüp
  // hemen normal girişe düşüyordu.
  const isAuthRedirect = window.location.hash.includes('access_token=');

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
    if (!applyUpdate || isAuthRedirect || loadGameState()) return;
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
