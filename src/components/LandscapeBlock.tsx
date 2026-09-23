import { useEffect, useState } from 'react';
import { LogoMark } from './LogoMark';
import { BOTTOM_STRIP_MIN_HEIGHT_PX } from '../utils/boardFit';

/**
 * "Telefonunuzu dikeye çevirin" — TAM EKRAN, KAPATILAMAZ blok.
 *
 * 22 Eylül 2026, kullanıcı kararı, sözleri birebir: *"Telefonda web'in yatay
 * çalışması gerekmiyor. Her durumda sadece dikey konuma getirin demek
 * yeterli. Ama boş ekranda, arka planda bozuk görüntü vb olmadan. Eskiden
 * böyleydi."*
 *
 * ## Bu bileşen İKİ KEZ yön değiştirdi — tarihçe burada ÖNEMLİ
 *
 * 1. **Başlangıçta sert bir bloktu** (`index.html`/`index.css`'te
 *    `#landscape-block`, `#root`u tamamen gizliyordu).
 * 2. **Kapatılabilir bir banner'a indirildi** çünkü iPad'de YANLIŞ
 *    tetikleniyordu: iPadOS `pointer`/`any-pointer` media feature'larını
 *    güvenilmez raporluyor (WebKit bug 212580/209292), trackpad'li klavye
 *    kılıfı takılıyken de `coarse` diyor — yani klavyeyle çalışan biri yatay
 *    modda uygulamayı hiç açamıyordu.
 * 3. **Şimdi yine sert blok** — ama ÖLÇÜT DEĞİŞTİ ve (2)'deki tuzak bu
 *    yüzden geri gelmiyor: kapı artık `(orientation: landscape)` DEĞİL,
 *    **yetersiz YÜKSEKLİK**. iPad yatayda 820px boy var (eşik 632), yani
 *    trackpad'li ya da trackpad'siz, iPad HİÇBİR ZAMAN bloklanmaz. Blok
 *    yalnızca alt şeridin (raf + butonlar) gerçekten sığmadığı yerde çıkar
 *    ve orada uygulama zaten oynanamaz durumdadır.
 * 4. **"iPad hiçbir zaman bloklanmaz" YANLIŞ ÇIKTI (23 Eylül 2026).** 820px
 *    ekranın boyu, SAYFANIN boyu değil: Safari'de adres çubuğu + sekme
 *    çubuğu + mağaza bandı (Smart App Banner, `apple-itunes-app`) birlikte
 *    ~200px yiyor. Kullanıcının ekran görüntüsünden ölçüldü (iPad 1180×820,
 *    sayfa ≈ 619px < 632) — iPad'de Safari yatayda HER açılışta blok
 *    çıkıyordu. Kapıya üçüncü koşul eklendi: cihaz bir TELEFON olmalı
 *    (ekranın kısa kenarı < 600px). Kural zaten telefon içindi (kullanıcı
 *    kararı *"Telefonda web'in yatay çalışması gerekmiyor"*); tablet ve açık
 *    katlanabilir artık hiçbir koşulda bloklanmaz, orada kısa sayfada tahta
 *    tabanına iner ve gerekirse birkaç piksel kaydırılır.
 *
 * ## Neden banner YETMEDİ
 *
 * Banner, arkasında BOZUK düzeni görünür bırakıyordu: tahta ekranı dolduruyor,
 * raf ve butonlar altta kalıyordu (kullanıcının 22 Eylül ekran görüntüsü).
 * Blok, arkada hiçbir şey göstermeyerek "burada oynanmaz, çevir" mesajını
 * tek başına veriyor.
 *
 * ## Değişmezler
 *
 * - **KAPATILAMAZ.** Kapatılabilseydi geriye yine bozuk düzen kalırdı —
 *   yani kullanıcının şikâyet ettiği şeyin ta kendisi. Çıkış tek: çevirmek.
 *   (Eski `sessionStorage` "kapatıldı" anahtarı bu yüzden KALDIRILDI.)
 * - **Kaplayıcı, sökücü DEĞİL.** Uygulama ağacı arkada mount kalır (`fixed
 *   inset-0` + opak zemin), yani oyun durumu/odak kaybolmaz ve çevirince
 *   kaldığın yerden devam edersin.
 * - **YAZARKEN ASLA ÇIKMAZ.** Ekran klavyesi açılınca layout viewport'u
 *   kısalıyor (Android Chrome varsayılan olarak içeriği yeniden boyutlar) —
 *   yani DİKEY bir telefonda Canlı oyun sohbetine mesaj yazan biri 844px'ten
 *   ~450px'e düşer ve eşiğin altına iner. Kapı yalnızca yüksekliğe baksaydı
 *   ekran tam yazarken "çevirin" derdi. Bu yüzden bir metin alanı (input /
 *   textarea / contenteditable) ODAKTAYKEN blok bastırılır.
 *   Kullanıcı bunu bildirdi (22 Eylül 2026): *"Ama iPad'da klavye varsa,
 *   yatay olmadan mesaj yazılamıyor. Bu durumu da düşün."*
 *   ⚠ iPad'in KENDİSİ zaten güvende (telefon değil, bkz. tarihçe #4), ama aynı
 *   kök sebep telefon dikeyde gerçek bir arızaydı.
 * - **TEK MOUNT NOKTASI `boot.tsx`.** `App.tsx`in İÇİNE konmaz: orada Canlı
 *   oyun `<OnlineGameScreen/>` ile ERKEN DÖNÜYOR ve banner'ın iki mount
 *   noktası da o dönüşün altındaydı — sonuç, Canlı oyunda uyarının HİÇ
 *   çıkmaması (22 Eylül 2026'da kullanıcı bildirdi). `boot.tsx` üç route
 *   dalının da tek ortak giriş noktası, yani dördüncü bir route eklense bile
 *   kendiliğinden kapsanır.
 */
/** Bu kısa kenarın altı TELEFON sayılır (bkz. tarihçe #4). */
export const PHONE_MAX_SHORT_SIDE_PX = 600;

export function LandscapeBlock() {
  const [blocked, setBlocked] = useState(false);

  useEffect(() => {
    // İki koşul da ŞART:
    //   coarse → masaüstünde kısa bir pencere bloklanmasın (orada düzen
    //            zaten sığıyor ve kullanıcı pencereyi kendi büyütebilir).
    //   short  → yer VARSA bloklama (iPad yatay, açık katlanabilir).
    const coarse = window.matchMedia('(pointer: coarse)');
    const short = window.matchMedia(`(max-height: ${BOTTOM_STRIP_MIN_HEIGHT_PX - 1}px)`);

    /** Ekran klavyesi açık mı — dolaylı ama güvenilir ölçüt: odaktaki alan. */
    const yaziliyor = () => {
      const el = document.activeElement as HTMLElement | null;
      if (!el) return false;
      return el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable;
    };

    /** Telefon mu — ekranın KISA kenarı (yönelimden bağımsız; iOS
     *  `screen`i hep dikey verir, Android o anki yönelimle). Telefonlar
     *  320–440, en küçük iPad (mini) 744, açık katlanabilir ~880. */
    const telefon = () => Math.min(window.screen.width, window.screen.height) < PHONE_MAX_SHORT_SIDE_PX;

    const update = () =>
      setBlocked(coarse.matches && short.matches && telefon() && !yaziliyor());
    update();

    // ⚠ `focusout` GECİKMELİ, `focusin` DEĞİL. Odak kaybında klavye kapanma
    // animasyonu sürerken viewport hâlâ kısa; hemen ölçersek dikey telefonda
    // blok bir an parlayıp kaybolur. 500 ms, klavyenin kapanmasını bekler.
    // (Medya sorgusu `change` olayı tek başına yetmez: gerçekten yatay bir
    // telefonda yükseklik zaten kısa KALIYOR, yani "değişiklik" hiç olmuyor
    // ve blok geri gelmezdi.)
    let gecikme: ReturnType<typeof setTimeout> | undefined;
    const odakAyrildi = () => {
      clearTimeout(gecikme);
      gecikme = setTimeout(update, 500);
    };

    coarse.addEventListener('change', update);
    short.addEventListener('change', update);
    document.addEventListener('focusin', update);
    document.addEventListener('focusout', odakAyrildi);
    return () => {
      clearTimeout(gecikme);
      coarse.removeEventListener('change', update);
      short.removeEventListener('change', update);
      document.removeEventListener('focusin', update);
      document.removeEventListener('focusout', odakAyrildi);
    };
  }, []);

  if (!blocked) return null;

  return (
    <div
      // ⚠ z-400: paneldeki en yüksek katman 300 (pencereler/ActionSheet).
      // Blok HER ŞEYİN üstünde olmalı — altında açık kalmış bir modal
      // "boş ekran" vaadini bozar.
      data-landscape-block=""
      className="fixed inset-0 z-[400] bg-bg flex flex-col items-center justify-center gap-5 px-6 text-center"
      role="status"
    >
      <LogoMark height={44} />

      {/* Dikey telefon + dönüş oku — `LandscapeHint`ten devralındı, aynı
          görsel dil (2.5 kalınlık, accent rengi). */}
      <svg width="64" height="64" viewBox="0 0 48 48" fill="none" className="text-accent" aria-hidden>
        <rect x="6" y="12" width="24" height="36" rx="4" stroke="currentColor" strokeWidth="2.5" fill="none" />
        <path d="M36 8 Q44 16 36 24" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" fill="none" />
        <polyline
          points="33,20 36,24 40,21"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </svg>

      <p className="text-base font-bold text-text font-sans leading-snug max-w-[280px]">
        Telefonunuzu dikeye çevirin
      </p>
      <p className="text-xs font-mono text-muted leading-snug max-w-[280px]">
        Kelimeki 13×13'lük bir tahtayla oynanıyor; yatay konumda tahta ve raf
        aynı ekrana sığmıyor.
      </p>
    </div>
  );
}
