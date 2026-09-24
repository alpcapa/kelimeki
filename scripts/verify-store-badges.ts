// Kelimeki — mağaza rozetlerinin YERLEŞİM kurallarını ve "yayında değilse
// çizme" kapısını ÜRETİM kodunu import ederek doğrular (ROADMAP #26).
//
// NEDEN AYRI BİR BETİK: bu kuralların ikisi de TESCİLLİ MARKA kuralı, yani
// ihlali görsel bir kusur değil hukuki bir sorun — ve hiçbiri derleyicinin
// göreceği türden. Duman testiyle sınanmıyor: rozetlerin sırası ve boyu
// saf veriden geliyor, tarayıcı gerekmez. `verify-away-return`in aynı
// deseni (esbuild + node).
//
// KURALLARIN KAYNAĞI (14 Eylül 2026'da ikisi de doğrulandı):
//   Apple  — developer.apple.com/app-store/marketing/guidelines/ (sayfa bu
//            ortamdan çekilip metni okundu)
//   Google — partnermarketinghub.withgoogle.com → Google Play → "Lockups,
//            icons, & badges" (kullanıcı ekrandan okudu; bu ortamdan
//            erişilemiyor, `play.google.com` da `000` dönüyor)
//
// Koşum: npm run verify-store-badges
import { readFileSync } from 'node:fs';

import {
  APPLE_APP_ID,
  decideAppPromo,
  storeForDevice,
  appleSmartAppBannerMeta,
  BADGE_GAP_PX,
  BADGE_MIN_HEIGHT_PX,
  BADGE_WIDTH_PX,
  STORE_BADGES,
  visibleStoreBadges,
  type StoreBadge,
} from '../src/utils/storeLinks';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

console.log('storeLinks — mağaza rozetleri');

// ── 1. SIRA — Apple'ın YAZILI kuralı ───────────────────────────────────────
// *"Place the App Store badge first in the lineup of badges."*
//
// ⚠ Google'ın kılavuzundaki örnek görsel Play'i SOLDA gösteriyor ama bu bir
// ÖRNEK; Google'ın metni sıra hakkında hiçbir şey söylemiyor. Apple'ınki
// açık bir kural, o yüzden sıra ona göre. Bu testin işi, birinin görsele
// bakıp sırayı "düzeltmesini" engellemek.
{
  check(
    'App Store ÖNCE (Apple: "first in the lineup")',
    STORE_BADGES[0]?.key === 'appStore',
    STORE_BADGES.map((b) => b.key).join(' → '),
  );
  check('Google Play ikinci', STORE_BADGES[1]?.key === 'googlePlay');
  check('başka rozet yok', STORE_BADGES.length === 2);
}

// ── 2. BOYUT — İKİ DOSYA DA OKUNARAK ───────────────────────────────────────
//
// ⚠ Bu bölüm 15 Eylül 2026'da yeniden yazıldı. Eskisi Apple'ın oranını
// VARSAYIYORDU (`~3.0`, yorumda) ve yalnız Play'in oranına `≥ 3.0` diye
// bakıyordu. Gerçek dosya gelince varsayım çöktü: Türkçe App Store rozeti
// **3.78:1**. Yani eski kapı yeşil kalırken Google'ın kuralı çiğneniyordu.
// Ders: iki rozeti KARŞILAŞTIRAN bir kural, iki dosyayı da okumadan
// kanıtlanamaz.
{
  const olc = (yol: string): { w: number; h: number; oran: number } | null => {
    let svg: string;
    try {
      svg = readFileSync(yol, 'utf8');
    } catch {
      return null;
    }
    const vb = /viewBox="([\d.\s-]+)"/.exec(svg);
    if (!vb) return null;
    const [, , w, h] = vb[1].trim().split(/\s+/).map(Number);
    if (!(w > 0 && h > 0)) return null;
    return { w, h, oran: w / h };
  };

  const apple = olc('public/app-store-badge.svg');
  const play = olc('public/google-play-badge.svg');

  if (apple && play) {
    // İkisi de AYNI genişlikte çiziliyor → yükseklik orandan geliyor.
    const appleY = BADGE_WIDTH_PX / apple.oran;
    const playY = BADGE_WIDTH_PX / play.oran;

    check(
      `App Store yüksekliği ≥ ${BADGE_MIN_HEIGHT_PX} px (Apple'ın ekran alt sınırı)`,
      appleY >= BADGE_MIN_HEIGHT_PX,
      `${BADGE_WIDTH_PX} px genişlikte ${appleY.toFixed(1)} px`,
    );

    // Google: "same size or larger than the other badges". Eşit GENİŞLİK bunu
    // tanım gereği sağlar; yine de açıkça ölçülüyor ki biri bileşeni
    // yüksekliğe geri çevirirse kapı düşsün.
    check(
      'Play rozeti App Store\'unkinden dar DEĞİL (Google: "same size or larger")',
      BADGE_WIDTH_PX >= BADGE_WIDTH_PX && playY >= appleY,
      `Play ${BADGE_WIDTH_PX}×${playY.toFixed(1)} ↔ App Store ${BADGE_WIDTH_PX}×${appleY.toFixed(1)}`,
    );

    // Clear space ölçütü YÜKSEK olan rozet (artık ikisi eşit yükseklikte değil).
    const enYuksek = Math.max(appleY, playY);
    check(
      'clear space = YÜKSEK olanın 1/4\'ü (İKİ kılavuz da aynı sayıyı veriyor)',
      BADGE_GAP_PX === Math.ceil(enYuksek / 4),
      `${BADGE_GAP_PX} ↔ ${Math.ceil(enYuksek / 4)} (en yüksek ${enYuksek.toFixed(1)} px)`,
    );
  } else {
    // Dosyalardan biri yoksa oran karşılaştırması YAPILAMAZ. Sessizce
    // geçmek bu kapının tam olarak kaçırdığı şeydi — açıkça söylüyoruz.
    check(
      'iki rozet dosyası da okunabiliyor (oran karşılaştırması için ŞART)',
      false,
      `apple=${apple ? 'ok' : 'YOK/bozuk'} play=${play ? 'ok' : 'YOK/bozuk'}`,
    );
  }

  check('boşluk pozitif', BADGE_GAP_PX > 0);
}

// ── 3. KAPI — yayında olmayan mağaza HİÇ çizilmez ──────────────────────────
// §26'nın tüm tasarımı buna dayanıyor: yayın geldiğinde tek satır değişecek.
{
  const hicbiri: StoreBadge[] = STORE_BADGES.map((b) => ({ ...b, url: null }));
  check('iki URL de null → hiçbir rozet yok', visibleStoreBadges(hicbiri).length === 0);

  // ⚠ Senaryo fixture'ları GERÇEK durumdan bağımsız kurulmalı: bu satır
  // eskiden App Store'un `url`unun null OLMASINA güveniyordu ve 15 Eylül'de
  // o alan dolunca düştü. Artık her rozetin URL'si açıkça yazılıyor.
  const yalnizPlay: StoreBadge[] = STORE_BADGES.map((b) =>
    b.key === 'googlePlay'
      ? { ...b, url: 'https://play.google.com/store/apps/details?id=x' }
      : { ...b, url: null },
  );
  const g = visibleStoreBadges(yalnizPlay);
  check('yalnız Play yayında → TEK rozet çıkar', g.length === 1 && g[0].key === 'googlePlay');

  const ikisi: StoreBadge[] = STORE_BADGES.map((b) => ({ ...b, url: `https://ornek/${b.key}` }));
  const i = visibleStoreBadges(ikisi);
  check('ikisi yayında → SIRA korunur (App Store önce)', i[0]?.key === 'appStore');

  // BUGÜNKÜ durum (24 Eylül 2026): İKİ mağaza da yayında (App Store 15 Eyl,
  // Play production 24 Eyl — vitrin oturum açmadan ölçüldü). Bu satır bir
  // ÖLÇÜM: bir URL bilerek `null`a çekilirse (ör. mağazadan kaldırılma)
  // düşer ve bakanı uyarır. 15-24 Eylül arası "yalnız App Store" diyordu.
  const bugun = visibleStoreBadges();
  check(
    'bugün İKİ rozet çiziliyor, App Store önce (ikisi de yayında)',
    bugun.length === 2 && bugun[0].key === 'appStore' && bugun[1].key === 'googlePlay',
    bugun.map((b) => b.key).join(', ') || 'hiçbiri',
  );
}

// ── 4. VARLIK DOSYALARI ────────────────────────────────────────────────────
// Rozet ÇİZİLMEZ, resmî dosya indirilir. Burada dosyanın var olup olmadığına
// değil, VAR OLANIN sağlamlığına bakılıyor: eksik dosya zaten `null` URL
// yüzünden hiç istenmiyor.
{
  for (const badge of STORE_BADGES) {
    let svg: string | null = null;
    try {
      svg = readFileSync(`public${badge.asset}`, 'utf8');
    } catch {
      svg = null;
    }

    if (svg === null) {
      // Dosya yoksa URL'si de null OLMALI — aksi halde kırık görsel çizerdik.
      check(
        `${badge.key}: dosya yok ama URL de null (kırık görsel imkânsız)`,
        badge.url === null,
        `${badge.asset} yok ama url dolu`,
      );
      continue;
    }

    check(`${badge.key}: SVG`, svg.includes('<svg'));
    // Font bağımlılığı olmamalı — `<text>` taşıyan bir rozet, fontu olmayan
    // ortamda yanlış render eder.
    check(`${badge.key}: <text> YOK (path'e çevrilmiş)`, !svg.includes('<text'));

    const vb = /viewBox="([\d.\s-]+)"/.exec(svg);
    check(`${badge.key}: viewBox var`, vb !== null);
    if (vb) {
      const [, , w, h] = vb[1].trim().split(/\s+/).map(Number);
      check(`${badge.key}: viewBox ölçülebilir`, w > 0 && h > 0, vb[1]);
      // ⚠ Burada TEK rozetin oranına bakan bir kontrol YOK, bilerek: iki
      // rozeti karşılaştıran kural yukarıda, İKİ dosya birden okunarak
      // ölçülüyor. Eski `≥ 3.0` eşiği tam da bu yüzden yanıltıcıydı —
      // Play'i tek başına ölçüp Apple'ınkini varsayıyordu.
    }
  }
}

// ── 5. METİNLER ────────────────────────────────────────────────────────────
// Uygulama Türkçe-only; rozetlerin `alt` metni de Türkçe olmalı.
{
  for (const badge of STORE_BADGES) {
    check(`${badge.key}: alt metni dolu`, badge.alt.trim().length > 0);
    check(
      `${badge.key}: alt metni Türkçe ("indirin" geçiyor)`,
      /indirin/i.test(badge.alt),
      badge.alt,
    );
  }
}

// ── 6. SMART APP BANNER (`apple-itunes-app`) ───────────────────────────────
// Safari'nin kendi üst şeridi. 19 Eylül 2026'da kullanıcı bildirdi: banner
// `index.html`de vardı ama statik sayfalarda YOKTU — o dört sayfa kendi
// HTML'ini ürettiğinden kapsam dışında kalmıştı.
//
// Sayı İKİ statik HTML'de elle duruyor (`index.html` import edemez), bu
// yüzden kapı onları kaynakla karşılaştırıyor — "iki kopya sessizce ayrışır"
// bu projenin en sık tekrarlayan hata sınıfı.
{
  const bannerVar = appleSmartAppBannerMeta() !== null;
  const indexHtml = readFileSync('index.html', 'utf8');
  const indexAppId = indexHtml.match(/name="apple-itunes-app"\s+content="app-id=(\d+)"/)?.[1] ?? null;

  if (bannerVar) {
    check('index.html Smart App Banner taşıyor', indexAppId !== null);
    check(
      `index.html app-id'si storeLinks ile AYNI (${APPLE_APP_ID})`,
      indexAppId === APPLE_APP_ID,
      indexAppId ?? 'yok',
    );
    check(
      'statik sayfa üreticisi banner\'ı basıyor (render.tsx)',
      readFileSync('src/legal/render.tsx', 'utf8').includes('appleSmartAppBannerMeta()'),
    );
  } else {
    // App Store yayında değilse banner da OLMAMALI — rozetlerle aynı kapı.
    check('App Store yayında değil → index.html banner TAŞIMAMALI', indexAppId === null);
  }
}

// ── 7. `AppStoreStrip` — standalone moddaki kendi şeridimiz ────────────────
// Apple'ın Smart App Banner'ı standalone modda hiç çıkmadığından, ana
// ekrandan açan kullanıcıya yerel uygulamayı duyuran TEK yüzey bu.
{
  // Cihaz kapısı rozetlerle aynı kaynaktan beslenmeli.
  check('masaüstünde şerit YOK (kurulacak yerel uygulama yok)', storeForDevice('desktop') === null);
  const ios = storeForDevice('ios');
  const android = storeForDevice('android');
  const appStore = STORE_BADGES.find((b) => b.key === 'appStore');
  const play = STORE_BADGES.find((b) => b.key === 'googlePlay');
  check(
    'iOS şeridi App Store YAYINDAYKEN (ve yalnızca o zaman) var',
    appStore?.url ? ios?.key === 'appStore' : ios === null,
  );
  check(
    'Android şeridi Play YAYINDAYKEN (ve yalnızca o zaman) var',
    play?.url ? android?.key === 'googlePlay' : android === null,
  );

  const stripHam = readFileSync('src/components/AppStoreStrip.tsx', 'utf8');
  // ⚠ YORUMLARI AT: dosya kuralın KENDİSİNİ yorumda anlatıyor
  // ("`localStorage` KULLANMA"), ham metinde arama yapmak onu kod sanar
  // (ölçüldü: kapı ilk koşuda tam bu yüzden düştü).
  const strip = stripHam
    .split('\n')
    .filter((r) => {
      const t = r.trimStart();
      return !t.startsWith('*') && !t.startsWith('//') && !t.startsWith('/*');
    })
    .join('\n');
  // ⚠ Kullanıcı kararı: "X olmalı ama her seferinde çıksın ki app'e gitsin
  // sonunda." localStorage'a geçmek bu kararı sessizce tersine çevirir.
  check('kapatma `sessionStorage`da (her açılışta yeniden çıkar)', strip.includes('sessionStorage'));
  check('kapatma `localStorage`a YAZILMIYOR', !strip.includes('localStorage'));
  // ⚠ `fixed` üstteki bir katman bu uygulamada içeriği HER ZAMAN örter
  // (body: position fixed + overflow hidden) — önizlemede logoyu örtmüştü.
  check('şerit AKIŞTA (`fixed` konumlandırma yok)', !/className="fixed/.test(strip));
  // ⚠ Türkçe eki türetilemez: "Google Play'da" YANLIŞ, "Play'de" doğru.
  check("Play ifadesi 'Play\'de' (ek türetilmiyor)", strip.includes("Google Play'de"));
  check("App Store ifadesi 'App Store\'da'", strip.includes("App Store'da"));
  // Şerit ↔ PWA kutusu: tek karar, iki bileşen de onu okur.
  const karar = (b: StoreBadge[]) => (c: 'ios' | 'android' | 'desktop', s: boolean) => decideAppPromo(c, s, b);
  const ikisi = karar(STORE_BADGES.map((b) => ({ ...b, url: b.url ?? 'https://x' })));
  const hicbiri = karar(STORE_BADGES.map((b) => ({ ...b, url: null })));
  check('masaüstü tarayıcı → PWA kutusu, standalone → hiçbiri', ikisi('desktop', false) === 'pwa-install' && ikisi('desktop', true) === null);
  check('iOS tarayıcı → PWA kutusu (Safari banner\'ı zaten var)', ikisi('ios', false) === 'pwa-install');
  check('Android tarayıcı + Play yayında → mağaza şeridi, PWA kutusu YOK', ikisi('android', false) === 'store-strip');
  check('Android tarayıcı + Play yok → PWA kutusu', hicbiri('android', false) === 'pwa-install');
  check('standalone + mağaza yayında → şerit', ikisi('ios', true) === 'store-strip' && ikisi('android', true) === 'store-strip');
  check('standalone + mağaza yok → hiçbiri', hicbiri('ios', true) === null && hicbiri('android', true) === null);
  check('şerit kararı `decideAppPromo`dan', strip.includes("decideAppPromo(getDeviceType(), isStandaloneDisplay()) !== 'store-strip'"));
  const a2hs = readFileSync('src/components/AddToHomeScreen.tsx', 'utf8');
  check('PWA kutusu kararı `decideAppPromo`dan', a2hs.includes("decideAppPromo(getDeviceType(), isStandaloneDisplay()) !== 'pwa-install'"));
  check(
    'cihaz tespiti `getDeviceType()`ten (kendi UA testi YOK — iPadOS `Macintosh` der)',
    strip.includes('getDeviceType()') && !/iPhone\|iPad/.test(strip),
  );
}

console.log('');
if (failures > 0) {
  console.log(`${failures} kontrol DÜŞTÜ`);
  process.exit(1);
}
console.log('Tüm kontroller geçti.');
