// Kelimeki — FCM yükünün ŞEKLİ doğrulaması (`_shared/push.ts` →
// `buildFcmMessage`).
//
// Neden var (31 Ağustos 2026): bir kullanıcı, uygulama simgesindeki "9"
// rozetinin bildirime dokunduktan sonra da kalmasını bildirdi. Kök sebep
// yükün ETİKETSİZ olmasıydı — Samsung One UI rozeti panelde DURAN
// bildirimlerden sayıyor ve etiket olmayınca aynı oyunun her "sıra sende"si
// yeni bir satır açıyordu. Düzeltme `android.notification.tag` (+ iOS
// `apns-collapse-id`) eklemek.
//
// Bu betiğin varlık sebebi tam da o düzeltmenin SESSİZCE yanlış olabilmesi:
// `tag` yanlış seviyeye (örneğin `message.tag` ya da `message.notification.
// tag`) yazılırsa FCM 400 DÖNDÜRMEZ, bilinmeyen alanı yok sayar ve hata
// ancak "rozet hâlâ birikiyor" olarak, haftalar sonra fark edilir. Ayrıca
// önek şeması (`sira:` / `davet:` / `sure:` / `sure-yerel:` / `arkadas:`)
// tek bir düz isim alanını paylaşıyor: önek unutulursa aynı oyunun daveti
// ile "sıra sende"si birbirini siler.
//
// Bu ortamdan Deno indirilemiyor (proxy 403), yani `_shared/push_test.ts`
// burada koşamıyor — bu betik onun Node'da koşabilen tamamlayıcısı.
// Çalıştırma: `npm run verify-push-payload`.
import {
  buildFcmMessage,
  rozetTasir,
  surumEnAz,
} from '../supabase/functions/_shared/push.ts';

let pass = 0;
const fails: string[] = [];
function check(ok: boolean, msg: string): void {
  if (ok) pass++;
  else fails.push(msg);
}

const OYUN = '11111111-2222-3333-4444-555555555555';

// ── 1) Etiket VERİLİNCE: Android `tag` + iOS `apns-collapse-id` ───────────
{
  const m = buildFcmMessage({
    token: 'tok',
    title: 'Sıra sende!',
    body: 'Ali hamlesini yaptı.',
    link: `kelimeki://oyun/${OYUN}`,
    tag: `sira:${OYUN}`,
  }) as any;

  check(m.android?.notification?.tag === `sira:${OYUN}`,
    'Android etiketi `android.notification.tag` altında olmalı');
  check(m.apns?.headers?.['apns-collapse-id'] === `sira:${OYUN}`,
    'iOS çakıştırma anahtarı `apns.headers["apns-collapse-id"]` olmalı');

  // Etiket YANLIŞ seviyelere SIZMAMALI — FCM bunları sessizce yok sayardı.
  check(m.tag === undefined, '`message.tag` diye bir alan OLMAMALI');
  check(m.notification?.tag === undefined,
    '`message.notification.tag` diye bir alan OLMAMALI');

  // Etiket eklemek eski alanların hiçbirini bozmamalı.
  check(m.android?.notification?.channel_id === 'kelimeki_oyun',
    'kanal kimliği korunmalı — düşerse bildirim varsayılan kanala kaçar');
  check(m.android?.priority === 'high', 'öncelik korunmalı');
  check(m.notification?.title === 'Sıra sende!', 'başlık korunmalı');
  check(m.notification?.body === 'Ali hamlesini yaptı.', 'gövde korunmalı');
  check(m.data?.link === `kelimeki://oyun/${OYUN}`,
    'derin bağlantı `data.link` olarak korunmalı (dokunma yönlendirmesi buna bakıyor)');
  check(m.token === 'tok', 'token korunmalı');

  // Yük FCM'e JSON olarak gidiyor; serileşebildiği de kanıtlanmalı.
  check(typeof JSON.stringify({ message: m }) === 'string', 'yük serileşmeli');
}

// ── 2) Etiket VERİLMEYİNCE: eski davranış birebir korunur ─────────────────
// Bu dalın önemi: `sendPush`i etiketsiz çağıran bir yol kalırsa (ya da
// ileride biri eklerse) yükte BOŞ bir `tag`/`apns` bloğu oluşmamalı — FCM
// boş `apns-collapse-id` başlığını reddedebilir.
{
  const m = buildFcmMessage({ token: 'tok', title: 'T', body: 'B' }) as any;
  check(m.android?.notification?.tag === undefined,
    'etiket verilmediyse `tag` alanı HİÇ yazılmamalı');
  check(m.apns === undefined, 'etiket verilmediyse `apns` bloğu HİÇ yazılmamalı');
  check(m.data === undefined, 'link verilmediyse `data` bloğu HİÇ yazılmamalı');
  check(m.android?.notification?.channel_id === 'kelimeki_oyun',
    'etiketsiz yolda da kanal kimliği durmalı');
}

// ── 3) Önek şeması: aynı oyunun farklı bildirimleri BİRBİRİNİ SİLMEMELİ ───
// Etiket alanı düz bir isim alanı. Önek unutulursa "sıra sende" ile aynı
// oyunun daveti ve süre uyarısı tek bir satıra çöker — kullanıcı üç ayrı
// olaydan yalnızca sonuncusunu görür.
{
  const etiket = (t: string) =>
    (buildFcmMessage({ token: 't', title: 'T', body: 'B', tag: t }) as any)
      .android.notification.tag as string;

  const hepsi = [
    etiket(`sira:${OYUN}`),
    etiket(`davet:${OYUN}`),
    etiket(`sure:${OYUN}`),
    etiket(`sure-yerel:${OYUN}`),
    etiket(`arkadas:${OYUN}`),
  ];
  check(new Set(hepsi).size === hepsi.length,
    'aynı id için üretilen beş etiket birbirinden FARKLI olmalı');

  // iOS `apns-collapse-id` 64 BAYT ile sınırlı — aşarsa APNs isteği reddeder.
  for (const t of hepsi) {
    check(new TextEncoder().encode(t).length <= 64,
      `etiket 64 baytı aşıyor (apns-collapse-id sınırı): ${t}`);
  }
}

// ── 4) Aynı işin İKİ bildirimi AYNI etikete düşmeli ───────────────────────
// Arkadaşlık isteği ve 3 gün sonraki hatırlatıcısı bilinçli olarak aynı
// etiketi taşıyor: hatırlatma, ilk bildirimin yerine geçmeli.
{
  const gonderen = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
  const ilk = (buildFcmMessage({
    token: 't', title: 'Yeni arkadaşlık isteği', body: 'B',
    tag: `arkadas:${gonderen}`,
  }) as any).android.notification.tag;
  const hatirlatma = (buildFcmMessage({
    token: 't', title: 'Bekleyen arkadaşlık isteğin var', body: 'B',
    tag: `arkadas:${gonderen}`,
  }) as any).android.notification.tag;
  check(ilk === hatirlatma,
    'hatırlatma ilk isteğin bildiriminin YERİNE geçmeli — etiketler aynı olmalı');
}

// ── 5) iOS simge rozeti (ROADMAP #25, 26 Eylül 2026) ─────────────────────
// `aps.badge` YANLIŞ seviyeye yazılırsa (ör. `message.badge`,
// `apns.aps.badge`) FCM yine 200 döner ve rozet sessizce hiç çıkmaz —
// #25'in kendisi tam bu belirtiydi.
{
  const m = buildFcmMessage({
    token: 't', title: 'T', body: 'B', tag: `sira:${OYUN}`, badge: 3,
  }) as any;
  check(m.apns?.payload?.aps?.badge === 3,
    'rozet `apns.payload.aps.badge` altında olmalı');
  check(m.apns?.headers?.['apns-collapse-id'] === `sira:${OYUN}`,
    'rozet eklemek çakıştırma başlığını düşürmemeli');
  check(m.apns?.payload?.aps?.alert === undefined,
    '`aps.alert` VERİLMEMELİ — FCM onu `notification`dan üretiyor');
  check(m.badge === undefined && m.notification?.badge === undefined,
    'rozet yanlış seviyelere sızmamalı');
  check(m.android?.notification?.notification_count === undefined,
    'Android\'e sayı GÖNDERİLMEMELİ — One UI rozeti paneldan türetiyor');

  const etiketsiz = buildFcmMessage({ token: 't', title: 'T', body: 'B', badge: 1 }) as any;
  check(etiketsiz.apns?.payload?.aps?.badge === 1,
    'etiketsiz bildirimde de rozet gitmeli');
  check(etiketsiz.apns?.headers === undefined,
    'etiket yoksa BOŞ bir `headers` bloğu yazılmamalı');

  const rozetsiz = buildFcmMessage({ token: 't', title: 'T', body: 'B', tag: 'x:1' }) as any;
  check(rozetsiz.apns?.payload === undefined,
    'rozet verilmediyse `payload` HİÇ yazılmamalı');
}

// ── 6) Rozet KAPISI: yalnızca iOS + sıfırlayabilen sürüm ──────────────────
// Sıfırlayamayan (1.1.1 ve öncesi) bir cihaza sayı gitmesi, simgede asılı
// kalan bir sayı demek. Kapı SAYISAL olmalı: dizgi karşılaştırmasında
// '1.1.10' < '1.1.2' çıkar ve gelecekteki sürümler rozeti kaybeder.
{
  check(surumEnAz('1.1.2', '1.1.2'), '1.1.2 ≥ 1.1.2');
  check(surumEnAz('1.1.10', '1.1.2'), '1.1.10 ≥ 1.1.2 (sayısal karşılaştırma)');
  check(surumEnAz('1.2', '1.1.2'), '1.2 ≥ 1.1.2');
  check(surumEnAz('2.0.0', '1.1.2'), '2.0.0 ≥ 1.1.2');
  check(!surumEnAz('1.1.1', '1.1.2'), '1.1.1 < 1.1.2');
  check(!surumEnAz('1.0.9', '1.1.2'), '1.0.9 < 1.1.2');
  check(!surumEnAz(null, '1.1.2'), 'null sürüm rozet ALMAZ (1.0.4 öncesi satırlar)');
  check(!surumEnAz('', '1.1.2'), 'boş sürüm rozet ALMAZ');
  check(!surumEnAz('abc', '1.1.2'), 'ayrıştırılamayan sürüm rozet ALMAZ');

  check(rozetTasir({ platform: 'ios', app_version: '1.1.2' }), 'iOS 1.1.2 rozet alır');
  check(!rozetTasir({ platform: 'ios', app_version: '1.1.1' }),
    'iOS 1.1.1 rozet ALMAZ — sıfırlayan kod o pakette yok');
  check(!rozetTasir({ platform: 'android', app_version: '9.9.9' }),
    'Android hiçbir sürümde rozet ALMAZ');
}

if (fails.length > 0) {
  console.error(`✗ ${fails.length} kontrol düştü:`);
  for (const f of fails) console.error('  -', f);
  process.exit(1);
}
console.log(`✓ push yükü doğrulandı — ${pass} kontrol geçti`);
