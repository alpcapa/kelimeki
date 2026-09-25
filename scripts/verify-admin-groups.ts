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
  groupMemberQuality,
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
  // LinkedIn lansmanı (16 Eylül 2026) — ilk üçü canlıda GERÇEKTEN var,
  // `li-buton` ve `li-deneyim` aynı turda sayfaya/profile girildi.
  ['li-sayfa', 'linkedin'], ['li-profil', 'linkedin'], ['li-hakkinda', 'linkedin'],
  ['li-buton', 'linkedin'], ['li-deneyim', 'linkedin'], ['linkedin', 'linkedin'],
  ['arkadas', 'arkadas'],
  ['direkt', 'direkt'],
  // Mobilden açılan hesabın kayıt etiketi (`backfill_app_source_history`).
  ['app', 'uygulama'],
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
// `li` yalnızca İKİ harf: sınır kuralı olmasa bu üçü de LinkedIn sayılırdı.
check('link LinkedIn DEĞİL', sourceChannel('link') === 'diger', sourceChannel('link'));
check('lig LinkedIn DEĞİL', sourceChannel('lig') === 'diger', sourceChannel('lig'));
check('liste LinkedIn DEĞİL', sourceChannel('liste') === 'diger', sourceChannel('liste'));
check('li_post LinkedIn', sourceChannel('li_post') === 'linkedin');
check('ig_story Instagram', sourceChannel('ig_story') === 'instagram');
check('facebook.grup Facebook', sourceChannel('facebook.grup') === 'facebook');
check('tanınmayan kanal UYDURULMAZ → Diğer', sourceChannel('tiktok') === 'diger');
check('app TAM eşleşme: apple Uygulama DEĞİL', sourceChannel('apple') === 'diger');
check('app TAM eşleşme: app-store Uygulama DEĞİL', sourceChannel('app-store') === 'diger');
check('null → Bilinmiyor', sourceChannel(null) === 'bilinmiyor');
check('boş dize → Bilinmiyor', sourceChannel('   ') === 'bilinmiyor');
check('BÜYÜK harf de eşleşir', sourceChannel('Instagram') === 'instagram');

console.log('direkt ≠ bilinmiyor (huninin 16 Ağustos 2026 kararı)');
check('ikisi AYRI kanal', sourceChannel('direkt') !== sourceChannel('bilinmiyor'));

{
  console.log('Üye Kalitesi gruplama — kanal toplamı alt satırların TOPLAMI');
  // Sayılar canlıdan (24 Eylül 2026, son 90 gün) — uydurulmadı.
  const gruplar = groupMemberQuality([
    { source: 'arkadas', members: 26, players: 17, players_7d: 17, returning_players: 15, games: 1352 },
    { source: 'app', members: 20, players: 10, players_7d: 9, returning_players: 8, games: 85 },
    { source: 'instagram', members: 9, players: 3, players_7d: 3, returning_players: 1, games: 165 },
    { source: 'ig-bio', members: 2, players: 1, players_7d: 1, returning_players: 0, games: 4 },
    { source: 'direkt', members: 7, players: 5, players_7d: 4, returning_players: 3, games: 298 },
    { source: 'li-profil', members: 1, players: 1, players_7d: 1, returning_players: 0, games: 2 },
  ]);
  const ig = gruplar.find((g) => g.channel === 'instagram');
  check('Instagram = 9 + 2 üye', ig?.members === 11, `gelen=${ig?.members}`);
  check('Instagram oyunları da toplanır', ig?.games === 169 && ig.players === 4);
  check('Instagram iki ham etiketi taşır', ig?.sources.length === 2);
  check('ham etiketler büyükten küçüğe', ig?.sources[0].source === 'instagram');
  check('app → Mobil Uygulama grubu', gruplar.find((g) => g.channel === 'uygulama')?.label === 'Mobil Uygulama');
  check('en büyük kanal ÖNCE', gruplar[0].channel === 'arkadas');
  check('hiçbir satır DÜŞMEZ', gruplar.reduce((a, g) => a + g.sources.length, 0) === 6);
  const fb = gruplar.find((g) => g.channel === 'facebook');
  check('üye getirmeyen Facebook 0 ile GÖRÜNÜR', fb?.members === 0 && fb.sources.length === 0);
  check('sıfır satırlar EN SONDA', gruplar[gruplar.length - 1].members === 0);
  check('Diğer/Bilinmiyor veri yoksa ÇIKMAZ', !gruplar.some((g) => g.channel === 'diger' || g.channel === 'bilinmiyor'));
  check('genel toplam korunur', gruplar.reduce((a, g) => a + g.members, 0) === 65);
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
