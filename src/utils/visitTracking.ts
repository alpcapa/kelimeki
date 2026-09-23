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
const DEVICE_VISIT_KEY = 'kelimeki:device-visit-date';

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
 * Bugün (yerel tarih) için cihaz/OS pingi (`device_visits`, bkz.
 * `logDeviceVisit`, `src/lib/api.ts`) zaten bildirildi mi.
 *
 * `visitAlreadyLoggedToday`'in damgasıyla BİLEREK AYRI: o yalnızca misafir
 * (girişsiz) ziyaretleri sayıp Kaynak Hunisi'ni besliyor, bu ise girişli/
 * girişsiz TÜM ziyaretleri sayıp yalnızca "Cihaz" dökümünü besliyor. Aynı
 * damgayı paylaşsalar biri ötekini bastırabilirdi — ör. bir kullanıcı
 * GİRİŞLİYKEN cihaz pingi atınca misafir damgası da dolar ve o gün
 * sonradan gerçekleşen girişsiz bir ziyaret hiç sayılmazdı (huniyi
 * sessizce eksik bırakırdı).
 */
export function deviceVisitAlreadyLoggedToday(): boolean {
  try {
    const today = new Date().toISOString().slice(0, 10);
    return localStorage.getItem(DEVICE_VISIT_KEY) === today;
  } catch {
    return true; // localStorage okunamıyorsa tekrar denemeye gerek yok
  }
}

/** Bugünün (yerel tarih) cihaz/OS pinginin bildirildiğini işaretler. */
export function markDeviceVisitLoggedToday(): void {
  try {
    const today = new Date().toISOString().slice(0, 10);
    localStorage.setItem(DEVICE_VISIT_KEY, today);
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
 * Ziyaretçinin işletim sistemini kaba biçimde ayırt eder — 24 Ağustos
 * 2026'ya kadar burada dokunmatik/fare (`pointer: coarse`) ayrımı vardı,
 * ama admin panelindeki "Cihaz" tablosunun asıl sorusu "iOS mu Android mi
 * masaüstü mü" olduğundan `navigator.userAgent`'a geçildi. iPad'in
 * iPadOS 13+'ta kendini Mac gibi tanıtması (`Macintosh` + dokunmatik)
 * ayrıca ele alınıyor, aksi halde masaüstü sayılırdı.
 *
 * Bu, "app mi web mi" sorusuna cevap VERMİYOR — bir Android telefonda
 * Chrome'da gezinen biri de "android" döner (bkz. `src/utils/platform.ts`,
 * o soru ayrı bir mekanizma).
 */
/**
 * iPadOS 13+ Safari'nin varsayılan "masaüstü sitesi" kipi: User-Agent bir
 * Mac'inkiyle birebir aynı (`Macintosh; Intel Mac OS X 10_15_7`), iPad'i
 * ayıran tek şey dokunmatik. ⚠ Bu kipte User-Agent'taki `10_15_7` iPad'in
 * sürümü DEĞİL — Apple'ın bütün Mac'lerde sabitlediği değer; gerçek iPadOS
 * sürümü hiç gönderilmiyor (23 Eylül 2026: admin "Cihaz" tablosunda iOS
 * altında 27 cihazlık bir `10.15.7` satırı vardı, hepsi modelsizdi).
 */
function isDesktopModeIPad(ua: string): boolean {
  return /Macintosh/.test(ua) && navigator.maxTouchPoints > 1;
}

/**
 * Tarayıcı kimliğinde KENDİNİ bot olarak tanıtan istemciler (arama motoru,
 * önizleme, SEO ve performans araçları). Bunlar SAYILMAYA devam ediyor,
 * yalnızca `os_version`a `'bot'` olarak işaretleniyor (23 Eylül 2026,
 * kullanıcı kararı: tahmine göre süzmeden önce ÖLÇ). Admin "Cihaz"
 * tablosundaki masaüstü "sürüm yok" kovasında tek seferlik, oyunsuz,
 * kaynaksız 115 cihaz vardı; kaçının bot, kaçının Linux/ChromeOS kullanıcısı
 * olduğu bilinemiyordu.
 *
 * ⚠ Açık liste, `/bot/` DEĞİL: `bot` alt dizesi gerçek bir Android markasında
 * (`CUBOT`) geçiyor. ⚠ Bu kontrol işletim sistemi okumadan ÖNCE yapılmalı:
 * Googlebot'un telefon tarayıcısı kendini `Linux; Android …` olarak tanıtıyor.
 */
const BOT_UA =
  /Googlebot|Google-InspectionTool|AdsBot|Storebot|bingbot|BingPreview|Applebot|YandexBot|Baiduspider|DuckDuckBot|AhrefsBot|SemrushBot|MJ12bot|DotBot|PetalBot|Bytespider|GPTBot|ClaudeBot|facebookexternalhit|Twitterbot|LinkedInBot|Slackbot|Discordbot|TelegramBot|WhatsApp|HeadlessChrome|Lighthouse|crawler|spider/i;

export function isBotUserAgent(ua: string): boolean {
  return BOT_UA.test(ua);
}

export function getDeviceType(): 'ios' | 'android' | 'desktop' {
  try {
    const ua = navigator.userAgent || '';
    const isIOS = /iPhone|iPad|iPod/.test(ua) || isDesktopModeIPad(ua);
    if (isIOS) return 'ios';
    if (/Android/.test(ua)) return 'android';
    return 'desktop';
  } catch {
    return 'desktop';
  }
}

/**
 * İyi niyetle (best-effort) `navigator.userAgent`'tan işletim sistemi
 * sürümünü okur — kesin değil, yalnızca elde edilebiliyorsa. Üç özel değer
 * sürüm DEĞİL, sınıftır: `'bot'` (kendini bot olarak tanıtan istemci),
 * `'Linux'`, `'ChromeOS'` (sürüm göndermeyen masaüstü aileleri). Şimdilik
 * hiçbir ekranda gösterilmiyor, yalnızca `guest_visits.os_version`'a VE
 * (24 Ağustos 2026'dan beri) `device_visits.os_version`'a kaydediliyor
 * (bkz. ilgili sütunların migration yorumları).
 */
export function getOsVersion(): string | null {
  try {
    const ua = navigator.userAgent || '';
    if (isBotUserAgent(ua)) return 'bot';
    const ios = ua.match(/OS (\d+)_(\d+)(?:_(\d+))?/);
    if (ios) return `${ios[1]}.${ios[2]}${ios[3] ? `.${ios[3]}` : ''}`;
    const android = ua.match(/Android (\d+(?:\.\d+)?)/);
    if (android) return android[1];
    // Masaüstü kipindeki iPad: aşağıdaki `Mac OS X` dalı ona sahte bir
    // macOS sürümü yazardı. Bilinmeyen sürüm, yanlış sürümden iyidir.
    if (isDesktopModeIPad(ua)) return null;
    const mac = ua.match(/Mac OS X (\d+)[_.](\d+)(?:[_.](\d+))?/);
    if (mac) return `${mac[1]}.${mac[2]}${mac[3] ? `.${mac[3]}` : ''}`;
    const win = ua.match(/Windows NT (\d+\.\d+)/);
    if (win) return win[1];
    // Sürüm değil AİLE: Linux ve ChromeOS tarayıcıları sürüm göndermiyor,
    // ama "sürüm yok" kovasını gerçek kullanıcıyla tanımsız trafikten
    // ayırmanın tek yolu bu (23 Eylül 2026).
    if (/CrOS/.test(ua)) return 'ChromeOS';
    if (/Linux/.test(ua)) return 'Linux';
    return null;
  } catch {
    return null;
  }
}

/**
 * İyi niyetle (best-effort) `navigator.userAgent`'tan cihaz bilgisini okur.
 * iOS Safari gerçek model numarasını HİÇ vermez — yalnızca "iPhone"/"iPad"
 * genel kategorisi döner. Android'de tarayıcının User-Agent'ı henüz
 * "reduce" edilmemişse model kodu (ör. "SM-G991B") yakalanabilir, aksi
 * halde null — bu beklenen bir durum, ayrıştırma hatası değil. Masaüstünde
 * her zaman null. Şimdilik hiçbir ekranda gösterilmiyor, yalnızca
 * `guest_visits.device_model`'e VE (24 Ağustos 2026'dan beri)
 * `device_visits.device_model`'e kaydediliyor.
 */
export function getDeviceModel(): string | null {
  try {
    const ua = navigator.userAgent || '';
    // Botun iddia ettiği cihaz (Googlebot telefonu `Nexus 5X` der) gerçek değil.
    if (isBotUserAgent(ua)) return null;
    const androidModel = ua.match(/;\s*([^;)]+?)\s*Build\//);
    if (androidModel) return androidModel[1].trim().slice(0, 60);
    if (/iPad/.test(ua) || isDesktopModeIPad(ua)) return 'iPad';
    if (/iPhone/.test(ua)) return 'iPhone';
    if (/iPod/.test(ua)) return 'iPod';
    return null;
  } catch {
    return null;
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
