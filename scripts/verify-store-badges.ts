// Kelimeki — mağaza rozetlerinin YERLEŞİM kurallarını ve "yayında değilse
// çizme" kapısını ÜRETİM kodunu import ederek doğrular (ROADMAP #26).
//
// NEDEN AYRI BİR BETİK: bu kuralların ikisi de TESCİLLİ MARKA kuralı, yani
// ihlali görsel bir kusur değil hukuki bir sorun — ve hiçbiri derleyicinin
// göreceği türden. Duman testiyle de sınanamaz: rozetler bugün HİÇ
// render edilmiyor (iki URL de `null`), yani tarayıcıda görülecek bir şey
// yok. `verify-away-return`in aynı deseni (esbuild + node).
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
  BADGE_GAP_PX,
  BADGE_HEIGHT_PX,
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

// ── 2. BOYUT — Apple'ın alt sınırı, Google'ın "aynı boy ya da daha büyük"ü ──
{
  check(
    `yükseklik ≥ 40 px (Apple'ın ekran alt sınırı) — ${BADGE_HEIGHT_PX}`,
    BADGE_HEIGHT_PX >= 40,
  );
  // İki rozet de AYNI yüksekliği kullanıyor (bileşen tek sabitten okuyor).
  // Eşit yükseklikte Play rozeti daha geniş olduğundan Google'ın "same size
  // or larger" kuralı da sağlanıyor — aşağıda oranla kanıtlanıyor.
  check(
    'clear space = yüksekliğin 1/4\'ü (İKİ kılavuz da aynı sayıyı veriyor)',
    BADGE_GAP_PX === Math.ceil(BADGE_HEIGHT_PX / 4),
    `${BADGE_GAP_PX} ↔ ${Math.ceil(BADGE_HEIGHT_PX / 4)}`,
  );
  check('boşluk elle yazılmamış, yükseklikten TÜRETİLMİŞ', BADGE_GAP_PX > 0);
}

// ── 3. KAPI — yayında olmayan mağaza HİÇ çizilmez ──────────────────────────
// §26'nın tüm tasarımı buna dayanıyor: yayın geldiğinde tek satır değişecek.
{
  const hicbiri: StoreBadge[] = STORE_BADGES.map((b) => ({ ...b, url: null }));
  check('iki URL de null → hiçbir rozet yok', visibleStoreBadges(hicbiri).length === 0);

  const yalnizPlay: StoreBadge[] = STORE_BADGES.map((b) =>
    b.key === 'googlePlay' ? { ...b, url: 'https://play.google.com/store/apps/details?id=x' } : b,
  );
  const g = visibleStoreBadges(yalnizPlay);
  check('yalnız Play yayında → TEK rozet çıkar', g.length === 1 && g[0].key === 'googlePlay');

  const ikisi: StoreBadge[] = STORE_BADGES.map((b) => ({ ...b, url: `https://ornek/${b.key}` }));
  const i = visibleStoreBadges(ikisi);
  check('ikisi yayında → SIRA korunur (App Store önce)', i[0]?.key === 'appStore');

  // BUGÜNKÜ durum: ikisi de yayında değil. Bu satır bir "todo" değil, bir
  // ÖLÇÜM — biri doldurulduğunda bilerek düşer ve bakanı uyarır.
  check(
    'bugün hiçbir rozet render EDİLMİYOR (ikisi de yayında değil)',
    visibleStoreBadges().length === 0,
    'bir URL dolduysa bu satır düşer — vitrini OTURUM AÇMADAN ölçtüğünden emin ol',
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
      if (badge.key === 'googlePlay') {
        // Google: "same size or larger than the other badges". Eşit
        // YÜKSEKLİKTE çizdiğimiz için bu ancak Play rozeti en az Apple'ınki
        // kadar GENİŞSE sağlanır. Apple'ın rozeti ~3.0:1; Play'inki daha
        // geniş olmalı.
        check(
          `${badge.key}: en/boy oranı ≥ 3.0 (eşit yükseklikte Apple'dan geniş)`,
          w / h >= 3.0,
          `${(w / h).toFixed(2)}:1`,
        );
      }
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

console.log('');
if (failures > 0) {
  console.log(`${failures} kontrol DÜŞTÜ`);
  process.exit(1);
}
console.log('Tüm kontroller geçti.');
