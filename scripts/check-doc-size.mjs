// Kelimeki — doküman boyutu bütçesi.
//
// NEDEN VAR (kullanıcı isteği, 24 Ağustos 2026): *"md dosyalarının
// büyümesinden dolayı sürekli hata alıyor ve senin işlerin takılıyordu.
// Dosyaları böldük ve düzeldi. Bundan sonra tekrar aynı şeyin yaşanmaması
// için gerekli kontrolleri koyup ona göre zamanında önlem alalım."*
//
// O gün iki kez öğrenildi: (1) `CLAUDE.md` ~200K token'a çıkıp her turu
// yiyordu — bölündü; (2) bölünme sorunu ÇÖZMEDİ, YER DEĞİŞTİRDİ:
// `mobile/docs/parca-log.md` 714 KB'a (eski CLAUDE.md'nin 7 katı) ulaştı.
// Yani "bir gün fark ederiz" işe yaramıyor; ölçüm otomatik olmalı.
//
// DÖRT SINIF, çünkü maliyetleri farklı:
//   • AUTO  — her turda bağlama YÜKLENİR (CLAUDE.md'ler). Maliyeti
//             kaçınılmaz, bütçesi en dar.
//   • ACTIVE— BAŞTAN SONA okunan, büyümeye devam eden dosyalar: kontrol
//             listeleri (TESTING*), README, ROADMAP. Sınıra gelince yeni bir
//             "cilt" açılır ya da bölünür.
//   • REFERENCE — yalnızca GREP'lenen başvuru dokümanları
//             (docs/decisions/*, parça günlüğünün aktif cildi). Tavanı geniş
//             çünkü maliyet dosya boyutunda DEĞİL, onu baştan sona okumakta.
//   • FROZEN— dondurulmuş arşiv. Okuması opt-in, o yüzden büyük olabilir;
//             tek kural BÜYÜMEMESİ.
//
// ⚠ REFERENCE 29 Ağustos 2026'da EKLENDİ, kullanıcı sorusuyla: *"Büyüyen md
// dosyalarını bölme işini tüm md'lerde yapıyor muyuz? Gerek var mı?"*
// Ölçüm: repoda 43 `.md`, 2.3 MB. `active` bütçesi ÖDENMEYEN bir maliyeti
// vekaleten ölçüyordu — o dosyalar isteğe bağlı ve çoğunlukla `grep`'le
// okunuyor; parça günlüğünün kendi başlığı bile "bir cildi BAŞTAN SONA
// OKUMA, grep ile ara" diyor. Bölmenin ise gerçek bir bedeli var ve bu repo
// onu ödedi: `docs/decisions/` 22 dosyaya çıktı ve doğru dosyayı bulmak için
// kök CLAUDE.md'de bir indeks tablosu tutuluyor (eski atıflar bölünmeyle
// kırıldı). Yani kural kaldırılmadı, DARALTILDI: bölme refleksi artık
// yalnızca baştan sona okunan dosyalar için.
//
// Bir dosya uyarı bandına girdiğinde ilk soru "nasıl bölerim" DEĞİL,
// "bunu baştan sona okuyan var mı?" — cevabı hayırsa çare bölmek değil,
// bayat anlatıyı budamak ya da bir cilt dondurmak. Yeni giriş aktif cilde yazılır.
//
// Koşum: npm run check-doc-size   (CI: .github/workflows/docs-size.yml)
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const ROOT = new URL('..', import.meta.url).pathname.replace(/\/$/, '');
const SKIP = new Set(['node_modules', '.git', 'build', 'dist', '.dart_tool', 'ios', 'android']);

const KB = 1000;
const BUTCE = {
  auto: { uyar: 80 * KB, sinir: 120 * KB },
  active: { uyar: 120 * KB, sinir: 200 * KB },
  // Grep'lenen başvuru dokümanları: tavan geniş ama SONSUZ değil — 400 KB'ı
  // aşan bir dosya artık dondurulup ciltlenmeli, yoksa baştan sona okumak
  // gereken nadir durumda (ör. bir bölümü yeniden yazarken) bağlamı yakar.
  //
  // ⚠ 15 Eylül 2026'da 200/300'den 260/400'e ÇIKARILDI (kullanıcı sorusu:
  // *"bir daha aktif kullanılmayacak dosyaların limitlerini arttırmaya ne
  // diyorsun? 200 kb biraz az sanki"*). Ölçüm haklı çıkardı: bu sınıf
  // grep'leniyor, yani okunan şey DOSYA değil BÖLÜM. `roadmap-arsiv.md`
  // 235 KB ama 29 bölüme dağılmış, ORTANCA bölüm 5 KB (~1,3K token) —
  // "uyarı" demek burada gerçek bir maliyeti değil, vekil bir sayıyı
  // ölçüyordu. 400 KB ≈ 100K token: tamamını okumak gereken nadir durumda
  // bile çalışılabilir bir pencere kalır.
  //
  // ⚠ Bu gevşetme TEK BAŞINA yapılmadı ve yapılmamalıydı — sınıra çarpınca
  // sınırı yükseltmek kontrolü süse çevirir. Karşılığında aşağıdaki BÖLÜM
  // ölçüsü eklendi: asıl riski (grep'in seni 100 KB'lık tek bir bloğun
  // içine düşürmesi) ilk kez o ölçüyor.
  reference: { uyar: 260 * KB, sinir: 400 * KB },
};

// Her turda bağlama yüklenen dosyalar.
const AUTO = new Set(['CLAUDE.md', 'mobile/CLAUDE.md']);

// Dondurulmuş arşivler: `max` = bugünkü boyutun biraz üstü. BÜYÜRSE düşer —
// bu, "yanlışlıkla arşive yazdım" hatasının tek yakalayıcısı.
const FROZEN = {
  'mobile/docs/parca-log-1-48.md': 300 * KB,
  'mobile/docs/parca-log-49-109.md': 290 * KB,
  // 26 Ağustos 2026: aktif cilt 151 KB'a çıkınca Parça 110-138 donduruldu.
  // Tavan bugünkü boyutun biraz üstünde — tek kural BÜYÜMEMESİ.
  'mobile/docs/parca-log-110-138.md': 150 * KB,
  // 7 Eylül 2026: aktif cilt 200 KB'a (reference uyarı bandı) çıkınca
  // Parça 139-174 donduruldu.
  'mobile/docs/parca-log-139-174.md': 135 * KB,
};

// Yalnızca GREP'lenen başvuru dokümanları. Kural DOSYA ADINA değil, dosyanın
// nasıl OKUNDUĞUNA bakıyor:
//   • docs/decisions/*        — "neden böyle yapıldı" kayıtları; bir konuda
//                               çalışırken tek bir madde aranır.
//   • mobile/docs/parca-log*  — parça günlüğü; dosyanın kendi başlığı baştan
//                               sona okumayı açıkça YASAKLIYOR.
// TESTING* dosyaları BİLEREK dışarıda: onlar baştan sona koşulan kontrol
// listeleri, yani gerçekten okunuyorlar → `active` kalırlar.
function isReference(rel) {
  if (/TESTING/i.test(rel) || /\btesting-/.test(rel)) return false;
  return rel.startsWith('docs/decisions/') || /^mobile\/docs\/parca-log/.test(rel);
}

function walk(dir, out = []) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const p = join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.name.endsWith('.md')) out.push(p);
  }
  return out;
}

// ── BÖLÜM ölçüsü (15 Eylül 2026) ──────────────────────────────────────────
// `reference` dosyalarında dosya boyutu VEKİL bir sayı: kimse baştan sona
// okumuyor, grep bir bölüme düşürüyor ve okunan o bölüm oluyor. Asıl maliyet
// bu yüzden "en büyük `##` bölümü". Ölçüldü (15 Eylül 2026):
//
//   roadmap-arsiv.md  235 KB · 29 bölüm · ortanca  5 KB · en büyük  39 KB
//   admin-panel.md    123 KB ·  6 bölüm · ortanca  3 KB · en büyük 108 KB  ←
//   live-game.md      109 KB · 12 bölüm · ortanca  3 KB · en büyük  50 KB  ←
//
// Yani "bütçe içinde" görünen `admin-panel.md` tek bir 108 KB'lık bloktan
// ibaret ve bir grep isabeti seni 27K token'ın içine bırakıyor; 235 KB'lık
// arşiv ise 5 KB'lık parçalar hâlinde okunuyor. Kontrol ikisini de dosya
// boyutuna göre yargılıyordu ve ikisinde de yanılıyordu.
//
// ⚠ Bu ölçü UYARI, kapı DEĞİL (bilerek): CI'ı düşürseydi bugün iki dosyayı
// birden kırmızıya çevirir ve ilgisiz her PR'ı bir doküman ameliyatına
// rehin alırdı. İlacı da bölmek değil: bloğa ALT BAŞLIK koymak yeter —
// dosya aynı kalır, grep'in düştüğü parça küçülür.
//
// ⚠ `frozen` DIŞARIDA: o ciltlerin kendi başlığı baştan sona okumayı zaten
// yasaklıyor (parca-log-1-48.md tek bir 284 KB'lık bölüm — orada uyarı
// gürültüden başka bir şey değil).
const BOLUM_UYAR = 40 * KB;

// ⚠ 16 Eylül 2026 — ÖLÇÜ DÜZELTİLDİ: yalnızca `## ` sayılıyordu.
// Betiğin kendi reçetesi "ilaç bölmek değil ALT BAŞLIK" diyordu, ama ölçü
// `###`/`####` başlıklarını HİÇ görmediğinden alt başlık eklemek yazdırdığı
// sayıyı bir bayt bile değiştirmiyordu. Yani uyarıyı temizleyecek tek eylem,
// kuralın açıkça yasakladığı şeydi (bölmek) — uyarı bu yüzden sürekliydi ve
// sekiz dosyalık sabit bir gürültü duvarına dönüşmüştü (kullanıcı, 16 Eylül
// 2026: *"Sürekli dosya bölme uyarısı mantıklı değil"*).
//
// Doğrusu YAPRAK bölüm: grep bir isabette seni EN YAKIN başlıktan sonraki
// parçaya bırakır, o başlık hangi seviyede olursa olsun. Ölçü artık `##`'den
// `######`'ya kadar her seviyede kesiyor. Düzeltme tek başına iki yanlış
// pozitifi temizledi (live-game.md 52 → 24 KB, local-game-persistence.md
// 41 → 38 KB — ikisinde alt başlık ZATEN vardı, ölçü onları görmüyordu).
//
// ⚠ Kod çiti (```) içindeki `# ...` satırı başlık DEĞİL, kabuk yorumudur —
// eski ölçü de bunu gözden kaçırıyordu. Çit takibi bu yüzden zorunlu.
function enBuyukBolum(mutlakYol) {
  const metin = readFileSync(mutlakYol, 'utf8');
  const parcalar = [];
  let cur = [];
  let cit = null; // açık kod çitinin karakteri (` ya da ~)
  for (const satir of metin.split('\n')) {
    const c = satir.match(/^ {0,3}(`{3,}|~{3,})/);
    if (c) {
      if (!cit) cit = c[1][0];
      else if (satir.trimStart().startsWith(cit)) cit = null;
    }
    if (!cit && /^#{2,6}\s/.test(satir)) {
      parcalar.push(cur.join('\n'));
      cur = [satir];
    } else {
      cur.push(satir);
    }
  }
  parcalar.push(cur.join('\n'));
  return parcalar.reduce((enb, p) => Math.max(enb, Buffer.byteLength(p, 'utf8')), 0);
}

const tok = (b) => `~${Math.round(b / 4 / 1000)}K token`;
const kb = (b) => `${(b / KB).toFixed(0)} KB`;

const rows = walk(ROOT)
  .map((p) => {
    const rel = relative(ROOT, p);
    const size = statSync(p).size;
    const sinif = AUTO.has(rel)
      ? 'auto'
      : rel in FROZEN
        ? 'frozen'
        : isReference(rel)
          ? 'reference'
          : 'active';
    const sinir = sinif === 'frozen' ? FROZEN[rel] : BUTCE[sinif].sinir;
    const uyar = sinif === 'frozen' ? Infinity : BUTCE[sinif].uyar;
    const bolum = sinif === 'reference' ? enBuyukBolum(p) : 0;
    return { rel, size, sinif, sinir, uyar, bolum };
  })
  .sort((a, b) => b.size - a.size);

const dusenler = rows.filter((r) => r.size > r.sinir);
const uyarilar = rows.filter((r) => r.size <= r.sinir && r.size > r.uyar);

// ── Alt sınır: BOŞALMIŞ doküman (7 Eylül 2026) ────────────────────────────
// Bütçe yalnızca "çok büyüdü"yü ölçüyordu. O gün ROADMAP.md bir düzenleme
// betiğinin `open(p, 'w')` satırıyla 0 bayta indi, commit'lendi, CI (bu
// betik dahil) yeşil kaldı ve dosya BOŞ hâliyle main'e girdi — "0 KB bütçe
// içinde"dir. Kural: hiçbir .md 0 bayt olamaz; baştan sona okunan büyük
// dosyaların da bir TABANI var — altına düşmek "bölündü" değil "silindi"
// demektir (bölme her zaman bir üst kural/indeksle birlikte yapılır ve
// dosya ana hatlarını korur).
const TABAN = {
  'ROADMAP.md': 40 * KB,
  'CLAUDE.md': 30 * KB,
  'mobile/CLAUDE.md': 30 * KB,
  'README.md': 8 * KB,
  'TESTING.md': 30 * KB,
  'mobile/TESTING.md': 30 * KB,
};
const bosalanlar = rows.filter(
  (r) => r.size === 0 || (r.rel in TABAN && r.size < TABAN[r.rel]),
);

console.log('\nDoküman boyutu bütçesi\n');
for (const r of rows.slice(0, 12)) {
  const durum = r.size > r.sinir ? 'SINIR AŞILDI' : r.size > r.uyar ? 'uyarı' : '';
  console.log(
    `  ${r.rel.padEnd(42)} ${kb(r.size).padStart(7)}  ${tok(r.size).padStart(12)}` +
      `  [${r.sinif}]${durum ? '  ← ' + durum : ''}`,
  );
}

if (uyarilar.length) {
  console.log('\nUYARI — sınıra yaklaşıyor:');
  for (const r of uyarilar) {
    const ne = r.sinif === 'reference'
      ? 'bayat anlatıyı buda ya da cilt dondur'
      : 'bir sonraki dokunuşta böl';
    console.log(`  • ${r.rel} — ${kb(r.size)} / ${kb(r.sinir)} [${r.sinif}] → ${ne}`);
  }
}

const bolumUyarilari = rows
  .filter((r) => r.bolum > BOLUM_UYAR)
  .sort((a, b) => b.bolum - a.bolum);
if (bolumUyarilari.length) {
  console.log(
    '\nBÖLÜM UYARISI — grep bu dosyalarda BÜYÜK bir bloğa düşürüyor' +
      ' (kapı DEĞİL; ilaç bölmek değil ALT BAŞLIK):',
  );
  for (const r of bolumUyarilari.slice(0, 5)) {
    console.log(`  • ${r.rel} — en büyük bölüm ${kb(r.bolum)} (${tok(r.bolum)})`);
  }
  if (bolumUyarilari.length > 5) {
    console.log(`    … ve ${bolumUyarilari.length - 5} dosya daha (eşik ${kb(BOLUM_UYAR)}).`);
  }
}

if (bosalanlar.length) {
  console.log('\nBOŞALMIŞ DOKÜMAN:\n');
  for (const r of bosalanlar) {
    const taban = r.rel in TABAN ? ` (taban ${kb(TABAN[r.rel])})` : ' (0 bayt)';
    console.log(`  ✗ ${r.rel} — ${kb(r.size)}${taban}`);
  }
  console.log(
    '    Bir doküman büyüyerek değil KÜÇÜLEREK bozuldu: içerik silinmiş ya da\n' +
      '    yazan betik dosyayı okumadan önce yazma modunda açmış olabilir\n' +
      '    (7 Eylül 2026, ROADMAP.md). `git show <önceki>:<dosya>` ile geri al.\n',
  );
  process.exit(1);
}

if (dusenler.length) {
  console.log('\nSINIR AŞILDI:\n');
  for (const r of dusenler) {
    console.log(`  ✗ ${r.rel} — ${kb(r.size)} > ${kb(r.sinir)} (${r.sinif})`);
    if (r.sinif === 'auto') {
      console.log(
        '    Bu dosya HER TURDA yükleniyor. Tarihli "neden böyle" anlatılarını\n' +
          '    ilgili docs/decisions/*.md ya da mobile/docs/*.md dosyasına taşı;\n' +
          '    burada yalnızca her yerde geçerli kural/değişmez kalsın.',
      );
    } else if (r.sinif === 'frozen') {
      console.log(
        '    Bu bir ARŞİV — büyümemeliydi. Yeni girişi AKTİF cilde yaz\n' +
          '    (parça günlüğünde: mobile/docs/parca-log.md).',
      );
    } else if (r.sinif === 'reference') {
      console.log(
        '    Bu dosya grep\'leniyor, baştan sona okunmuyor — yani bölmek çoğu\n' +
          '    zaman baytı yer değiştirmekten ibaret. ÖNCE bayat/aşılmış\n' +
          '    anlatıyı buda; hâlâ büyükse bir CİLT dondur (FROZEN listesi).\n' +
          '    docs/decisions/ zaten 22 dosya — yeni dosya açmadan önce\n' +
          '    kök CLAUDE.md\'deki indeks tablosunun büyüme bedelini hesaba kat.',
      );
    } else {
      console.log(
        '    Bu dosya BAŞTAN SONA okunuyor (kontrol listesi/plan), yani boyut\n' +
          '    gerçek bir maliyet. Bir bölüm sınırından kes; kesme noktası\n' +
          '    boyut değil İÇERİĞİN TÜRÜ olsun (tek oturum ↔ iki oturum,\n' +
          '    normal kullanıcı ↔ admin — örnek: TESTING.md → docs/testing-admin.md).',
      );
    }
  }
  console.log('');
  process.exit(1);
}

console.log('\nTüm dosyalar bütçe içinde.');
