import { useEffect, useState } from 'react';
import { getDeviceType } from '../utils/visitTracking';
import { storeForDevice } from '../utils/storeLinks';

/**
 * Ana ekrandan açılan uygulamada (standalone PWA) üstte çıkan "yerel uygulama
 * mağazada" şeridi — 19 Eylül 2026, kullanıcı isteği.
 *
 * ## Neden var: Apple'ın banner'ı TAM BURADA susuyor
 *
 * Safari'nin Smart App Banner'ı (`<meta name="apple-itunes-app">`,
 * `index.html` + `legal/render.tsx`) **standalone modda hiç çıkmaz** — Apple
 * "bu kullanıcı zaten uygulamada" varsayıyor. Ama bizim durumumuzda o kişi
 * WEB uygulamasında; App Store'da gerçek bir uygulama olduğunu hiç
 * bilmeyebilir. Kullanıcının sözleriyle: *"Apple bunu yapanlara
 * göstermemekle aslında app store'da gerçek app'in olduğunu bilmeyenlere
 * 'sen web'den devam et' demiş oluyor."*
 *
 * Mağaza rozetleri (`StoreBadges`) bu boşluğu KAPATMIYOR: Setup'ta footer'da
 * duruyorlar, yani kaydırmayan görmüyor — davet sayfasında ölçülen aynı
 * sorunun (y=1153 px) bir başka yüzü.
 *
 * ## Üç kural
 *
 * 1. **Telefonda HER YERDE — tarayıcıda da, ana ekrandan açılışta da**
 *    (24 Eylül 2026, kullanıcı kararı: *"Ios'da da çıkmamalı, sadece app
 *    store çıkmalı… Web'den de gelse herkesin cep telefonu var, gidip
 *    indirebilir."*). Aynı gün "ana ekrana ekle" kutusu (`AddToHomeScreen`)
 *    TAMAMEN kaldırıldı, masaüstü dahil; şerit telefondaki TEK uygulama
 *    çağrısı. İlk sürümde yalnızca standalone'daydı, çünkü iOS Safari'de
 *    Apple'ın kendi Smart App Banner'ı var — ikisi artık üst üste
 *    görünebilir, ama ikisi de AYNI yere (App Store) gönderiyor, çelişki
 *    yok; Apple'ınki uygulama-içi tarayıcılarda (WhatsApp/Instagram)
 *    çizilmiyor, davet linkleri de tam oradan açılıyor.
 * 2. **Yalnızca o cihazın mağazası YAYINDAYSA** (`storeForDevice`). Play
 *    yayına girene kadar Android'de hiç çizilmez; URL dolunca kendiliğinden
 *    belirir. Masaüstünde hiç çıkmaz — kurulacak yerel uygulama yok.
 * 3. **AKIŞTA durur, `fixed` DEĞİL.** İlk sürüm `fixed top-0` idi ve
 *    önizlemede görüldü: şerit Setup'ın LOGOSUNU örtüyordu. Apple'ın kendi
 *    banner'ı da sayfanın akışındadır (içeriği aşağı iter, kaydırınca yukarı
 *    kayar) — bu yüzden şerit kurulum kabuğunun İLK çocuğu olarak render
 *    ediliyor. ⚠ `fixed`e geri çevirme: bu uygulamada `body` zaten
 *    `position: fixed; overflow: hidden` (bkz. index.css), yani üstte duran
 *    bir katman içeriği HER ZAMAN örter.
 * 4. **✕ KALICI DEĞİL** (kullanıcı kararı: *"X olmalı ama her seferinde
 *    çıksın ki app'e gitsin sonunda"*). Kapatma `sessionStorage`da tutuluyor:
 *    o açılış boyunca bir daha görünmez, uygulama kapanıp açılınca yeniden
 *    çıkar. ⚠ `localStorage` KULLANMA — silinen `AddToHomeScreen` onu
 *    kullanıyordu (orada bir kez "hayır" demek kalıcı bir karardı), burada
 *    tam tersi isteniyor.
 */
const DISMISSED_KEY = 'kelimeki_app_strip_dismissed';

/** Kapatıldı mı — depo kapalıysa (gizli sekme) "hayır" sayılır. */
function dismissedThisSession(): boolean {
  try {
    return sessionStorage.getItem(DISMISSED_KEY) === '1';
  } catch {
    return false;
  }
}

export function AppStoreStrip() {
  const [visible, setVisible] = useState(false);
  const [store] = useState(() => storeForDevice(getDeviceType()));

  useEffect(() => {
    if (!store || dismissedThisSession()) return;
    // İlk boyamada sıçramasın diye kısa gecikme; açılışta zaten
    // sözlük/oturum yükleniyor.
    const t = setTimeout(() => setVisible(true), 900);
    return () => clearTimeout(t);
  }, [store]);

  const dismiss = () => {
    setVisible(false);
    try {
      sessionStorage.setItem(DISMISSED_KEY, '1');
    } catch {
      // Depo kapalıysa şerit bu açılışta tekrar çıkabilir — kabul edilebilir.
    }
  };

  if (!visible || !store) return null;
  // ⚠ EK TÜRETİLMEZ, YAZILIR. İlk sürüm `{magazaAdi}'da` diyordu ve Play için
  // **"Google Play'da"** üretiyordu — Türkçe ünlü uyumu gereği doğrusu
  // "Play'de". Ek, adın son hecesinin OKUNUŞUNA bağlı ("pley"), yazılışına
  // değil; hiçbir kural bunu güvenilir biçimde türetemez.
  const magazaIfade = store.key === 'appStore' ? "App Store'da" : "Google Play'de";

  return (
    <div className="w-full max-w-[460px] px-2 pt-2">
      <style>{`
        @keyframes stripDown {
          from { transform: translateY(-110%); opacity: 0; }
          to   { transform: translateY(0);     opacity: 1; }
        }
      `}</style>
      <div
        data-kelimeki-app-strip=""
        className="w-full bg-panel border border-[#B8C2D1] rounded-xl shadow-[0_6px_18px_rgba(15,23,42,0.18)] pl-2.5 pr-1.5 py-2 flex items-center gap-2.5"
        style={{ animation: 'stripDown 0.35s cubic-bezier(0.16,1,0.3,1) both' }}
      >
        <img
          src="/apple-touch-icon.png"
          alt=""
          width={36}
          height={36}
          className="shrink-0 rounded-lg border border-border"
          aria-hidden
        />
        <div className="flex-1 min-w-0">
          <p className="text-xs font-bold text-text font-sans leading-snug m-0">Kelimeki</p>
          {/* ⚠ KISA TUTULMALI: 390 px'te buton + ✕ ile birlikte tek satıra
              sığmayan metin kesiliyor (ilk önizlemede "— ü..." çıktı). */}
          <p className="text-[10px] text-muted font-mono leading-relaxed m-0 mt-0.5 truncate">
            {magazaIfade} — ücretsiz
          </p>
        </div>
        <a
          href={store.url ?? '#'}
          target="_blank"
          rel="noopener noreferrer"
          className="shrink-0 btn-raised bg-accent text-white rounded-md px-3 py-1.5 text-[10px] font-bold uppercase tracking-[1px] no-underline"
        >
          İndir
        </a>
        <button
          onClick={dismiss}
          aria-label="Kapat"
          className="tap-expand shrink-0 w-6 h-6 flex items-center justify-center rounded-full text-muted"
        >
          <svg width="12" height="12" viewBox="0 0 14 14" fill="none" aria-hidden>
            <path d="M2 2l10 10M12 2L2 12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
          </svg>
        </button>
      </div>
    </div>
  );
}
