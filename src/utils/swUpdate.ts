/**
 * Service worker güncellemesi — YENİDEN YÜKLEME DÖNGÜSÜ KAPISI
 * (19 Eylül 2026, oturum döngüsünün BEŞİNCİ turu ve gerçek kök sebebi).
 *
 * ## Vaka
 *
 * Kullanıcı uygulamayı **ana ekran ikonundan** (iOS standalone PWA) açınca
 * ekran "deli gibi" yenilenip duruyordu; bazen bir açılış temiz geçiyor,
 * bir sonraki yine döngüye giriyordu. Sunucu tarafında ölçülen şey saniyede
 * ~2 tam veri turuydu (~20 istek/sn) ve her turda `fetchMyProfile` baştan
 * koşuyordu.
 *
 * ⚠ **Bu üç tur boyunca auth katmanında arandı ve orada DEĞİLDİ.** Üç
 * düzeltme (`sameAuthUser`, olay adı filtresi, depo doğrulaması) yayına
 * çıktı, üçü de döngüyü durdurmadı — çünkü oturumun `null`a düşmesi bir
 * SEBEP değil, BELİRTİ idi: sayfa her seferinde sıfırdan açılıyordu.
 *
 * ⚠ **"Sayfa yenileniyor" hipotezi bir kez YANLIŞ gerekçeyle elendi**
 * (üçüncü tur): *"bir iPhone saniyede iki kez 400 KB paketi indirip React'i
 * kuramaz"*. Doğru görünüyordu ve yanlıştı — ana ekrandan açılan bir PWA'da
 * HTML, JS ve fontların tamamı service worker ÖNBELLEĞİNDEN gelir, ağdan
 * hiçbir şey inmez. Saniyede iki açılış o koşulda gayet mümkün. Hipotezi
 * eleyen gerekçenin kendisi sınanmamıştı. **Kullanıcının tek cümlesi
 * ("bunu add to home screen ikonuyla yapıyorum") teşhisi açtı.**
 *
 * ## Döngünün mekaniği (`lib/pwa.ts`)
 *
 * ```
 * pageshow → checkForUpdate() → registration.update()
 *          → bekleyen SW hâlâ orada → onNeedRefresh() → updateSW(true)
 *          → skipWaiting → controllerchange → location.reload()
 *          → pageshow → (baştan)
 * ```
 *
 * `pwa.ts`in `applyUpdate = null` koruması YALNIZCA tek bir sayfa ömrü
 * içinde çalışır; `reload` o ömrü bitirdiği için döngüyü hiç görmez.
 * Bekleyen SW bir sebeple etkinleşemezse (iOS standalone'da
 * `skipWaiting`/`controllerchange` zinciri güvenilmez) döngü sonsuzdur ve
 * yalnızca uygulamayı tamamen kapatmak kırar — kullanıcının tarifi birebir
 * buydu.
 *
 * ## Kural
 *
 * **Bir uygulama oturumunda güncelleme EN FAZLA BİR KEZ uygulanır** ve
 * ikinci deneme yalnızca DERLEME GERÇEKTEN DEĞİŞTİYSE serbesttir.
 *
 * Kapı derleme kimliğine bakıyor (`__KELIMEKI_BUILD__`, zaten yayınlanıyor —
 * bkz. kök `CLAUDE.md`, "Deploy Doğrulaması"): yeniden yükleme sonrası
 * derleme kimliği AYNI kaldıysa, o yükleme hiçbir şeyi değiştirmemiştir ve
 * tekrar denemek tanım gereği sonsuz döngüdür.
 *
 * ⚠ Kayıt `sessionStorage`da: yeniden yüklemeleri AŞAR (aynı bağlam) ama
 * uygulamayı kapatıp açmak onu sıfırlar — yani gerçek bir güncelleme bir
 * sonraki açılışta normal şekilde uygulanır, kalıcı olarak bloklanmaz.
 */

/** `sessionStorage` anahtarı — yeniden yüklemeyi aşar, yeni açılışta sıfırlanır. */
export const SW_UPDATE_KEY = 'kelimeki-sw-guncelleme';

export interface SwUpdateKaydi {
  /** Güncelleme uygulandığı ANDA çalışan derlemenin kimliği. */
  build: string;
  /** Epoch ms — yalnızca teşhis için; karar zamana BAKMAZ. */
  at: number;
}

/**
 * Bu yeniden yükleme yapılmalı mı?
 *
 * - kayıt YOK → bu oturumda ilk deneme, **uygula**
 * - kayıttaki derleme ŞİMDİKİNDEN farklı → önceki güncelleme tuttu, sonradan
 *   yeni bir sürüm çıkmış, **uygula**
 * - kayıttaki derleme ŞİMDİKİYLE aynı → önceki yeniden yükleme hiçbir şeyi
 *   değiştirmedi, **UYGULAMA** (döngü tam burada kırılıyor)
 */
export function shouldApplySwUpdate(
  kayit: SwUpdateKaydi | null,
  simdikiBuild: string,
): boolean {
  if (!kayit) return true;
  return kayit.build !== simdikiBuild;
}

/** Kayıt okunur; depo kapalıysa (gizli sekme vb.) `null` döner. */
export function readSwUpdateKaydi(): SwUpdateKaydi | null {
  try {
    const ham = sessionStorage.getItem(SW_UPDATE_KEY);
    if (!ham) return null;
    const v = JSON.parse(ham) as Partial<SwUpdateKaydi>;
    return typeof v?.build === 'string' && typeof v?.at === 'number'
      ? { build: v.build, at: v.at }
      : null;
  } catch {
    return null;
  }
}

/** Yeniden yüklemeden HEMEN ÖNCE çağrılır — yazamazsak sessizce geçilir. */
export function writeSwUpdateKaydi(build: string, simdi: number): void {
  try {
    sessionStorage.setItem(SW_UPDATE_KEY, JSON.stringify({ build, at: simdi }));
  } catch {
    // Depo kapalıysa döngü koruması olmadan bugünkü davranışa düşeriz.
  }
}
