// Kelimeki — misafir (girişsiz) ziyaretçi sayımı için istemci tarafı anonim kimlik.
//
// Hiçbir kişisel veri taşımaz: yalnızca cihazda üretilen rastgele bir uuid
// (localStorage'da saklanır) ve günde bir kez sunucuya "bugün buradaydım"
// pingi. Admin panelindeki Büyüme > Kullanıcı grafiğinde "Ziyaret" serisi
// bunların bucket başına DISTINCT sayısını gösterir — kayıt olmadan gelip
// oyun oynayan (ya da hiç oynamadan bakıp giden) benzersiz tarayıcı
// oturumlarının kabaca kaç farklı ziyaretçi olduğunu görmek için.
// localStorage cihaza/tarayıcıya özel olduğundan gerçek benzersiz insan
// sayısından çok "farklı tarayıcı" sayısına yakındır (biri gizli sekme
// kullanırsa ya da önbelleği temizlerse yeniden sayılır) — tam bir çözüm
// değil ama yönlü bir sinyal.
const ANON_ID_KEY = 'kelimeki:anon-id';
const LAST_VISIT_KEY = 'kelimeki:anon-visit-date';
const UTM_SOURCE_KEY = 'kelimeki:utm-source';

/** Bu cihaz için kalıcı, rastgele bir kimlik döner — yoksa üretip saklar. */
export function getOrCreateAnonId(): string | null {
  try {
    const existing = localStorage.getItem(ANON_ID_KEY);
    if (existing) return existing;
    const id = crypto.randomUUID();
    localStorage.setItem(ANON_ID_KEY, id);
    return id;
  } catch {
    return null;
  }
}

/** Bugün (yerel tarih) için ziyaret zaten bildirildi mi? */
export function visitAlreadyLoggedToday(): boolean {
  try {
    const today = new Date().toISOString().slice(0, 10);
    return localStorage.getItem(LAST_VISIT_KEY) === today;
  } catch {
    return true; // localStorage okunamıyorsa tekrar denemeye gerek yok
  }
}

/** Bugünün (yerel tarih) ziyareti bildirildi olarak işaretler. */
export function markVisitLoggedToday(): void {
  try {
    const today = new Date().toISOString().slice(0, 10);
    localStorage.setItem(LAST_VISIT_KEY, today);
  } catch {
    // yoksay
  }
}

/**
 * Sayfa yüklenirken URL'deki `?ref=` parametresini (ör. `?ref=tiktok`) okuyup
 * cihazda kalıcı olarak saklar — sosyal medya/tanıtım linklerinin hangi
 * kanaldan geldiğini `logGuestVisit`'e etiketleyebilmek için. İlk temas
 * (first-touch) modeli: cihazda zaten bir kaynak kayıtlıysa üzerine
 * yazılmaz, böylece kullanıcı sonradan farklı bir linkle gelse bile onu
 * buraya ilk getiren kanal saklı kalır. `?ref=` hiç olmadan gelinen
 * ziyaretler kaynaksız (null) sayılır.
 */
export function captureUtmSource(): void {
  try {
    const ref = new URLSearchParams(window.location.search).get('ref');
    if (ref && !localStorage.getItem(UTM_SOURCE_KEY)) {
      localStorage.setItem(UTM_SOURCE_KEY, ref.trim().toLowerCase().slice(0, 40));
    }
  } catch {
    // yoksay
  }
}

/** Cihaz için önceden kaydedilmiş kaynak etiketini döner, yoksa null. */
export function getStoredUtmSource(): string | null {
  try {
    return localStorage.getItem(UTM_SOURCE_KEY);
  } catch {
    return null;
  }
}

/**
 * Ziyaretin mobil mi masaüstü mü olduğunu kaba biçimde ayırt eder —
 * dokunmatik/kalın işaretçi (`pointer: coarse`) mobil/tablet cihazlarda
 * doğru, fare kullanan masaüstünde yanlış döner. Tam kesin değildir (ör.
 * dokunmatik ekranlı bir dizüstü mobil sayılabilir) ama admin panelindeki
 * "Cihaz" dökümü için yeterli bir sinyal.
 */
export function getDeviceType(): 'mobile' | 'desktop' {
  try {
    return window.matchMedia('(pointer: coarse)').matches ? 'mobile' : 'desktop';
  } catch {
    return 'desktop';
  }
}

/**
 * Sayfa şu anda ana ekrana eklenip bağımsız (standalone) modda mı açık,
 * yoksa normal bir tarayıcı sekmesinde mi çalışıyor. iOS Safari
 * `navigator.standalone`, diğerleri `display-mode: standalone` media
 * query'siyle raporlar. `AddToHomeScreen` banner'ının gösterilip
 * gösterilmeyeceğine karar vermek ve misafir ziyaretlerine bu bilgiyi
 * etiketlemek (`logGuestVisit`) için ortak kullanılır.
 */
export function isStandaloneDisplay(): boolean {
  try {
    return (
      ('standalone' in navigator && (navigator as { standalone?: boolean }).standalone === true) ||
      window.matchMedia('(display-mode: standalone)').matches
    );
  } catch {
    return false;
  }
}
