// Kelimeki — `src/utils/adminGroups.ts`in saf kurallarını ÜRETİM kodunu
// import ederek doğrular (admin paneli → Büyüme > Kullanıcı).
//
// NEDEN ÖNEMLİ: `?ref=` etiketlerinin merkezî bir kaydı YOK — pazarlama
// malzemesine elle yazılıyor. Gruplama bu yüzden önek-bazlı ve tek gerçek
// doğrulama CANLIDAN alınmış etiketlerdir. Aşağıdaki değerlerin tamamı
// 16 Eylül 2026'da `guest_visits`/`game_starts`/`profiles`ten çekildi
// (son 60 gün) — uydurulmadı.
//
// ⚠ Yeni bir kanal eklerken buraya da bir vaka ekle: bu betik "yeni etiket
// sessizce Instagram sayıldı" ya da "Diğer'e düşmesi gereken şey yutuldu"
// gibi bir gerilemeyi yakalayan tek şey. `verify-device-labels`in kardeşi.
//
// Koşum: npm run verify-admin-groups
import {
  clientPlatformLabel,
  compareVersionDesc,
  groupPlatformVersions,
  groupSourceFunnel,
  sourceChannel,
} from '../src/utils/adminGroups';

let failures = 0;
const check = (name: string, cond: boolean, detail = '') => {
  if (cond) console.log(`  ✓ ${name}`);
  else { failures++; console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`); }
};

console.log('Kaynak → kanal: canlıdan gelen GERÇEK etiketler (16 Eylül 2026)');
for (const [tag, beklenen] of [
  ['instagram', 'instagram'], ['ig-bio', 'instagram'],
  ['fb', 'facebook'], ['fb-reel', 'facebook'], ['fb-btn', 'facebook'],
  ['arkadas', 'arkadas'],
  ['direkt', 'direkt'],
  // `--sanitized--` canlıda GERÇEKTEN var (1 ziyaret): istemci tarafı
  // temizleme bırakmış. "Diğer" değil "Bilinmiyor" — bir kanal adı değil,
  // kaynağın kaybolduğunun kaydı.
  ['--sanitized--', 'bilinmiyor'],
  ['bilinmiyor', 'bilinmiyor'],
] as const) {
  check(`${tag} → ${beklenen}`, sourceChannel(tag) === beklenen, `gelen=${sourceChannel(tag)}`);
}

console.log('Önek eşleşmesi SINIR arar — yarım kelime yutulmaz');
check('ignore Instagram DEĞİL', sourceChannel('ignore') === 'diger', sourceChannel('ignore'));
check('fbi Facebook DEĞİL', sourceChannel('fbi') === 'diger', sourceChannel('fbi'));
check('ig_story Instagram', sourceChannel('ig_story') === 'instagram');
check('facebook.grup Facebook', sourceChannel('facebook.grup') === 'facebook');
check('tanınmayan kanal UYDURULMAZ → Diğer', sourceChannel('tiktok') === 'diger');
check('null → Bilinmiyor', sourceChannel(null) === 'bilinmiyor');
check('boş dize → Bilinmiyor', sourceChannel('   ') === 'bilinmiyor');
check('BÜYÜK harf de eşleşir', sourceChannel('Instagram') === 'instagram');

console.log('direkt ≠ bilinmiyor (huninin 16 Ağustos 2026 kararı)');
check('ikisi AYRI kanal', sourceChannel('direkt') !== sourceChannel('bilinmiyor'));

{
  console.log('Huni gruplama — kanal toplamı alt satırların TOPLAMI');
  const bos = { starts: 0, starters: 0, signups: 0, finishes: 0, finishers: 0, member_games: 0, players: 0 };
  const gruplar = groupSourceFunnel([
    { source: 'instagram', visitors: 1642, ...bos },
    { source: 'ig-bio', visitors: 5, ...bos },
    { source: 'arkadas', visitors: 50, ...bos },
    { source: 'fb-reel', visitors: 5, ...bos },
    { source: 'fb', visitors: 1, ...bos },
    { source: 'fb-btn', visitors: 1, ...bos },
    { source: '--sanitized--', visitors: 1, ...bos },
  ]);
  const ig = gruplar.find((g) => g.channel === 'instagram');
  const fb = gruplar.find((g) => g.channel === 'facebook');
  check('Instagram = 1642 + 5', ig?.visitors === 1647, `gelen=${ig?.visitors}`);
  check('Facebook = 5 + 1 + 1', fb?.visitors === 7, `gelen=${fb?.visitors}`);
  check('Facebook üç ham etiketi taşır', fb?.sources.length === 3);
  check('en büyük kanal ÖNCE', gruplar[0].channel === 'instagram');
  check('ham etiketler büyükten küçüğe', fb?.sources[0].source === 'fb-reel');
  check('hiçbir satır DÜŞMEZ',
    gruplar.reduce((a, g) => a + g.sources.length, 0) === 7);
  check('genel toplam korunur',
    gruplar.reduce((a, g) => a + g.visitors, 0) === 1705);
}

console.log('Sürüm sıralaması SAYISAL, metin DEĞİL');
check('1.1.0 > 1.0.9', compareVersionDesc('1.1.0', '1.0.9') < 0);
check('1.0.10 > 1.0.9', compareVersionDesc('1.0.10', '1.0.9') < 0);
check('"bilinmiyor" her zaman EN SONDA', compareVersionDesc('bilinmiyor', '1.0.0') > 0);
check('"bilinmiyor" iki yanda da sonda', compareVersionDesc('1.0.0', 'bilinmiyor') < 0);

console.log('İstemci etiketleri — "Cihaz" tablosuyla AYNI kelimeler');
check('ios → iOS', clientPlatformLabel('ios') === 'iOS');
check('android → Android', clientPlatformLabel('android') === 'Android');
check('web → Web', clientPlatformLabel('web') === 'Web');
check('app-web → Uygulama (web)', clientPlatformLabel('app-web') === 'Uygulama (web)');
check('tanınmayan → Bilinmiyor', clientPlatformLabel('symbian') === 'Bilinmiyor');

{
  console.log('Platform gruplama — canlıdan gelen GERÇEK sürüm dağılımı (son 30 gün)');
  const gruplar = groupPlatformVersions([
    { platform: 'web', app_version: 'bilinmiyor', value: 766 },
    { platform: 'android', app_version: '1.1.0', value: 134 },
    { platform: 'android', app_version: '1.0.9', value: 101 },
    { platform: 'android', app_version: '1.0.0', value: 96 },
    { platform: 'ios', app_version: '1.1.0', value: 17 },
    { platform: 'ios', app_version: '1.0.9', value: 2 },
    { platform: 'app-web', app_version: '1.0.0', value: 14 },
  ]);
  const android = gruplar.find((g) => g.platform === 'android');
  check('Android = 134 + 101 + 96', android?.value === 331, `gelen=${android?.value}`);
  check('en büyük istemci ÖNCE (web 766)', gruplar[0].platform === 'web');
  check('sürümler YENİDEN ESKİYE', android?.versions[0].app_version === '1.1.0' &&
    android?.versions[2].app_version === '1.0.0',
    android?.versions.map((v) => v.app_version).join(','));
  check('web tek "bilinmiyor" satırı taşır — ok çizilmemeli',
    gruplar[0].versions.length === 1);
  check('hiçbir satır DÜŞMEZ',
    gruplar.reduce((a, g) => a + g.versions.length, 0) === 7);
  check('genel toplam korunur',
    gruplar.reduce((a, g) => a + g.value, 0) === 1130);
}

console.log(failures === 0 ? '\nTÜMÜ GEÇTİ' : `\n${failures} BAŞARISIZ`);
process.exit(failures === 0 ? 0 : 1);
