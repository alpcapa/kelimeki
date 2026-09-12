// Kelimeki — `src/utils/deviceLabels.ts`in saf kurallarını ÜRETİM kodunu
// import ederek doğrular (admin paneli → Büyüme > Kullanıcı).
//
// NEDEN ÖNEMLİ: marka, model KODUNDAN önekle okunuyor. Önek listesi
// "kapsamlı" değil GÖRÜLENE dayanıyor, yani tek gerçek doğrulama canlıdan
// alınmış gerçek kodlardır. Aşağıdaki vakaların TAMAMI 11 Eylül 2026'da
// `device_visits`ten çekildi (son 90 gün) — uydurulmadı.
//
// ⚠ Bir kural eklerken/değiştirirken buraya da bir vaka ekle: bu betik
// "Diğer'e düşmesi gereken kod Samsung sayıldı" gibi sessiz bir gerilemeyi
// yakalayan tek şey.
//
// Koşum: npm run verify-device-labels
import {
  brandBreakdown,
  compareOsVersionDesc,
  deviceBrand,
  deviceModelLabel,
  osBreakdown,
  osVersionLabel,
  platformLabel,
} from '../src/utils/deviceLabels';

let failures = 0;
const check = (name: string, cond: boolean, detail = '') => {
  if (cond) console.log(`  ✓ ${name}`);
  else { failures++; console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`); }
};

console.log('Marka — canlıdan gelen GERÇEK kodlar (11 Eylül 2026)');
for (const [model, beklenen] of [
  ['SM-A176B', 'Samsung'], ['SM-A346E', 'Samsung'], ['SM-G950F', 'Samsung'],
  ['SM-M346B2', 'Samsung'], ['SM-A705FN', 'Samsung'],
  ['24116RACCG', 'Xiaomi'], ['2312DRA50G', 'Xiaomi'],
  ['M2004J19C', 'Xiaomi'], ['M2101K6G', 'Xiaomi'], ['Mi 9 SE', 'Xiaomi'],
  ['CLT-L09', 'Huawei'], ['JNY-LX1', 'Huawei'], ['DBY2-W09', 'Huawei'],
  ['HEY3-W00', 'Huawei'], ['DNP-NX9', 'Huawei'],
  ['Nexus 5X', 'Google'],
  ['LG-H930', 'LG'], ['LG-P870/P87020d', 'LG'],
  ['CTR-LX1', 'Huawei'],
  // Tanınmayanlar — UYDURMA marka atanmamalı. İkisi de canlıdaki 1'er
  // ziyaretçilik uzun kuyruktan; hangi üretici oldukları KODDAN
  // anlaşılmıyor, o yüzden `Diğer`de kalmaları DOĞRU davranış.
  ['G301', 'Diğer'], ['G702', 'Diğer'],
] as const) {
  check(`${model} → ${beklenen}`, deviceBrand('android', model) === beklenen,
    `gelen=${deviceBrand('android', model)}`);
}

console.log('Apple — device_type belirleyici, model kodu değil');
check('ios + iPhone → Apple', deviceBrand('ios', 'iPhone') === 'Apple');
check('ios + iPad → Apple', deviceBrand('ios', 'iPad') === 'Apple');
check('ios + model YOK → yine Apple', deviceBrand('ios', null) === 'Apple');

console.log('Model bilinmeyen satırlar');
check('masaüstü → Bilinmiyor', deviceBrand('desktop', null) === 'Bilinmiyor');
check('android + null → Bilinmiyor', deviceBrand('android', null) === 'Bilinmiyor');
check('boş dize null gibi', deviceBrand('android', '   ') === 'Bilinmiyor');

console.log('Etiketler');
check('model etiketi markayı öne alır',
  deviceModelLabel('android', 'SM-A176B') === 'Samsung · SM-A176B',
  deviceModelLabel('android', 'SM-A176B'));
check('iOS modeli TEKRARLANMAZ ("Apple · iPhone" değil)',
  deviceModelLabel('ios', 'iPhone') === 'iPhone', deviceModelLabel('ios', 'iPhone'));
check('tanınmayan kod ham kalır',
  deviceModelLabel('android', 'G301') === 'G301', deviceModelLabel('android', 'G301'));
check('modelsiz satır gizlenmez',
  deviceModelLabel('desktop', null) === 'Masaüstü · model bildirmiyor',
  deviceModelLabel('desktop', null));
check('OS etiketi platformu HER ZAMAN yazar',
  osVersionLabel('android', '16') === 'Android 16');
check('yanıltıcı macOS dizesi platformuyla birlikte görünür',
  osVersionLabel('ios', '10.15.7') === 'iOS 10.15.7');
check('sürümsüz satır', osVersionLabel('android', null) === 'Android · sürüm yok');
check('platformLabel bilinmeyen değer', platformLabel('app-web') === 'Bilinmiyor');

console.log('Marka gruplaması — sayılar korunur, modeller altta');
{
  // Canlıdaki gerçek dağılımın küçük bir kesiti.
  const rows = [
    { device_type: 'android', device_model: 'SM-A176B', visitors: 47 },
    { device_type: 'android', device_model: 'SM-A346E', visitors: 46 },
    { device_type: 'android', device_model: '24116RACCG', visitors: 14 },
    { device_type: 'ios', device_model: 'iPhone', visitors: 62 },
    { device_type: 'desktop', device_model: null, visitors: 131 },
    { device_type: 'android', device_model: 'G301', visitors: 1 },
  ];
  const b = brandBreakdown(rows);
  const toplam = b.reduce((a, r) => a + r.visitors, 0);
  check('toplam ziyaretçi korunur', toplam === 301, `toplam=${toplam}`);
  check('en büyük satır Bilinmiyor (masaüstü 131)', b[0].brand === 'Bilinmiyor',
    `ilk=${b[0].brand}`);
  const samsung = b.find((r) => r.brand === 'Samsung');
  check('Samsung satırları toplanır (47+46=93)', samsung?.visitors === 93,
    `gelen=${samsung?.visitors}`);
  check('Diğer ayrı satır', b.find((r) => r.brand === 'Diğer')?.visitors === 1);

  // Açılır kırılım — marka satırının ALTINDA duran modeller.
  check('Samsung altında İKİ model var', samsung?.models.length === 2,
    `gelen=${samsung?.models.length}`);
  check('modeller çoktan aza sıralı',
    samsung?.models[0].deviceModel === 'SM-A176B' &&
      samsung?.models[1].deviceModel === 'SM-A346E',
    samsung?.models.map((m) => m.deviceModel).join(','));
  check('alt satırların toplamı marka satırına EŞİT',
    (samsung?.models.reduce((a, m) => a + m.visitors, 0) ?? 0) === samsung?.visitors);
  const bilinmiyor = b.find((r) => r.brand === 'Bilinmiyor');
  check('modelsiz satır da kırılımda görünür (gizlenmiyor)',
    bilinmiyor?.models.length === 1 && bilinmiyor?.models[0].deviceModel === null);
}

console.log('Sürüm sıralaması — SAYISAL, yeniden eskiye');
check('9, 18.7den SONRA gelir (düz metin sırası ters olurdu)',
  compareOsVersionDesc('18.7', '9') < 0);
check('16 > 13', compareOsVersionDesc('16', '13') < 0);
check('26.6.1 > 26.5.2', compareOsVersionDesc('26.6.1', '26.5.2') < 0);
check('eksik parça 0 sayılır (18 ↔ 18.0)', compareOsVersionDesc('18', '18.0') === 0);
check('sürümsüz satır EN SONDA', compareOsVersionDesc(null, '9') > 0 &&
  compareOsVersionDesc('9', null) < 0);
check('sayıya çevrilemeyen dize alfabetiğe düşer, patlamaz',
  compareOsVersionDesc('beta', '16') !== 0);

console.log('Cihaz + işletim sistemi ağacı (12 Eylül 2026)');
{
  // Canlıdan alınmış GERÇEK dağılımın kesiti (son 90 gün, 12 Eylül 2026):
  // android 568 · masaüstü 132 · iOS 91 — ve iOS'un alt toplamı 92, çünkü
  // tek bir cihaz pencere içinde 26.5.2 → 26.6.1 güncellemiş.
  const devices = [
    { device_type: 'android', visitors: 568 },
    { device_type: 'desktop', visitors: 132 },
    { device_type: 'ios', visitors: 91 },
  ];
  const osRows = [
    { device_type: 'android', os_version: '16', visitors: 273 },
    { device_type: 'android', os_version: '13', visitors: 64 },
    { device_type: 'android', os_version: '9', visitors: 12 },
    { device_type: 'android', os_version: null, visitors: 219 },
    { device_type: 'desktop', os_version: '10.15.7', visitors: 132 },
    { device_type: 'ios', os_version: '18.7', visitors: 28 },
    { device_type: 'ios', os_version: '26.6.1', visitors: 32 },
    { device_type: 'ios', os_version: '26.5.2', visitors: 32 },
  ];
  const g = osBreakdown(devices, osRows);
  check('gruplar çoktan aza', g.map((x) => x.deviceType).join(',') === 'android,desktop,ios',
    g.map((x) => x.deviceType).join(','));
  const android = g.find((x) => x.deviceType === 'android');
  check('üst satır "Cihaz" RPC\'sinin sayısı (568)', android?.visitors === 568,
    `gelen=${android?.visitors}`);
  check('sürümler çoktan aza, eşitlikte yeniden eskiye',
    android?.versions.map((v) => v.osVersion ?? '(yok)').join(',') === '16,(yok),13,9',
    android?.versions.map((v) => v.osVersion ?? '(yok)').join(','));
  const ios = g.find((x) => x.deviceType === 'ios');
  check('üst satır alt toplamdan KÜÇÜK kalabilir (91 ↔ 92) — şişirilmiyor',
    ios?.visitors === 91 &&
      (ios?.versions.reduce((a, v) => a + v.visitors, 0) ?? 0) === 92);
  check('eşit ziyaretçide YENİ sürüm önce (26.6.1 → 26.5.2)',
    ios?.versions[0].osVersion === '26.6.1' && ios?.versions[1].osVersion === '26.5.2',
    ios?.versions.map((v) => v.osVersion).join(','));
  check('tablo toplamı "Cihaz" tablosununkiyle AYNI (791)',
    g.reduce((a, x) => a + x.visitors, 0) === 791);

  // Üst satırı olmayan bir cihaz tipi DÜŞÜRÜLMEZ — iki RPC aynı pencereyi
  // okuduğu için beklenmez, ama olursa sayı kaybolmamalı.
  const ekstra = osBreakdown(devices, [
    ...osRows,
    { device_type: 'bilinmiyor', os_version: null, visitors: 7 },
  ]);
  const b = ekstra.find((x) => x.deviceType === 'bilinmiyor');
  check('üst satırsız cihaz tipi kendi grubunu açar', b?.visitors === 7 &&
    b?.versions.length === 1, `gelen=${b?.visitors}`);
  check('boş sürüm listesi de sorun değil (OS satırı hiç yoksa)',
    osBreakdown(devices, []).every((x) => x.versions.length === 0));
}

console.log(failures === 0 ? '\nTÜMÜ GEÇTİ' : `\n${failures} BAŞARISIZ`);
process.exit(failures === 0 ? 0 : 1);
