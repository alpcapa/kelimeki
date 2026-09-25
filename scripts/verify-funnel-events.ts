// Kelimeki — Huni v2'nin (`src/utils/funnelEvents.ts`) saf karar mantığını
// ÜRETİM kodunu import ederek doğrular + olay/platform listelerinin SQL
// kopyasıyla birebir aynı olduğunu kontrol eder.
//
// NEDEN: mantık duman testiyle sınanamaz (Supabase yapılandırılmamışken hiç
// çalışmıyor, Playwright `navigator.webdriver` taşıdığı için kasten
// SAYILMIYOR) ve olay listesi iki dilde iki yerde yaşıyor — biri yeni olay
// alıp öteki almazsa sunucu o olayı SESSİZCE yok sayar. Port (PR 2) bir
// üçüncü kopya olacak ve adları bu dosyadan okuyacak.
//
// Koşum: npm run verify-funnel-events
import { readFileSync } from 'node:fs';
import {
  decideLandChannel,
  FUNNEL_EVENTS,
  FUNNEL_EXISTING_CHANNEL,
  FUNNEL_MEMBER_EVENTS_ENABLED,
  FUNNEL_PLATFORMS,
  funnelEventAllowed,
  hasPriorTrace,
  istanbulDay,
  normalizeFunnelChannel,
  planLand,
  shouldSendVisit,
} from '../src/utils/funnelEvents';
import { groupFunnelV2 } from '../src/utils/adminGroups';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

console.log('funnelEvents — Huni v2');

// 1 — land kanalı: eski cihaz "mevcut", yeni cihaz etiket ya da "direkt".
check('izi olan cihaz → mevcut', decideLandChannel(true, 'ig-bio') === FUNNEL_EXISTING_CHANNEL);
check('yeni cihaz + etiket → etiket', decideLandChannel(false, 'ig-bio') === 'ig-bio');
check('yeni cihaz, etiket yok → direkt', decideLandChannel(false, null) === 'direkt');
check('boş etiket → direkt', decideLandChannel(false, '   ') === 'direkt');
check('etiket küçük harf + 40 ile sınırlı', normalizeFunnelChannel(` FB-${'x'.repeat(60)} `)?.length === 40);
check('etiket küçültülüyor', normalizeFunnelChannel('IG') === 'ig');

// 2 — önceki iz taraması.
check('boş depo → iz yok', !hasPriorTrace([]));
check('anonim kod → iz', hasPriorTrace(['kelimeki:anon-id']));
check('seen-intro → iz', hasPriorTrace(['kelimeki:seen-intro']));
check('Supabase oturumu → iz', hasPriorTrace(['sb-abcdef-auth-token']));
check('ilgisiz anahtar → iz yok', !hasPriorTrace(['foo', 'sb-abc-other']));
check(
  "Huni v2'nin kendi anahtarları iz DEĞİL (yarım kalan land 'mevcut'a dönmesin)",
  !hasPriorTrace(['funnel-v2:land', 'funnel-v2:visit-day']),
);

// 3 — land planı: kanal ilk kararda DONAR, başarıya kadar tekrar denenir.
{
  const ilk = planLand(null, false, 'fb');
  check('ilk açılış: gönder, kanal fb', ilk.send && ilk.state.channel === 'fb' && !ilk.state.sent);
  // Gönderim düştü; ikinci yüklemede artık anonim kod var (iz = true).
  const ikinci = planLand(ilk.state, true, 'fb');
  check('düşen gönderim tekrar deneniyor, kanal DEĞİŞMİYOR', ikinci.send && ikinci.state.channel === 'fb');
  const bitti = planLand({ channel: 'fb', sent: true }, true, 'fb');
  check('gönderilmiş land tekrar gönderilmiyor', !bitti.send);
}

// 4 — ziyaret günü (Istanbul, UTC+3).
{
  const utc2230 = Date.UTC(2026, 8, 24, 22, 30); // İstanbul: 25 Eylül 01:30
  check('UTC 22:30 → İstanbul ertesi gün', istanbulDay(utc2230) === '2026-09-25', istanbulDay(utc2230));
  const utc2059 = Date.UTC(2026, 8, 24, 20, 59); // İstanbul: 24 Eylül 23:59
  check('UTC 20:59 → İstanbul aynı gün', istanbulDay(utc2059) === '2026-09-24', istanbulDay(utc2059));
  check('aynı gün ikinci ziyaret gönderilmiyor', !shouldSendVisit('2026-09-24', '2026-09-24'));
  check('yeni gün ziyareti gönderiliyor', shouldSendVisit('2026-09-24', '2026-09-25'));
  check('ilk ziyaret gönderiliyor', shouldSendVisit(null, '2026-09-24'));
}

// 5 — gizlilik metni sınırı.
check('YZ oyunu başlangıcı (misafir) serbest', funnelEventAllowed('game_start', true, false));
check('YZ oyunu başlangıcı (üye) serbest — metin (2) sayıyor', funnelEventAllowed('game_start', false, false));
check('misafir bitişi serbest — metin (4) sayıyor', funnelEventAllowed('game_finish', true, false));
check('üye bitişi bayrak kapalıyken YOK', !funnelEventAllowed('game_finish', false, false));
check('signup bayrak kapalıyken YOK', !funnelEventAllowed('signup', true, false));
check('bayrak açılınca üye bitişi + signup geçiyor', funnelEventAllowed('game_finish', false, true) && funnelEventAllowed('signup', true, true));
{
  // Bayrak ancak gizlilik metni güncellenince açılabilir. Vekil: Gizlilik
  // Politikası'nın "Son güncelleme" tarihi bu kapı yazıldığındakinden farklı
  // olmalı (metin her değiştiğinde tarih de değişiyor — legal_text_test.dart
  // aynı vekili kullanıyor).
  const legal = readFileSync('src/legal/LegalContent.tsx', 'utf8');
  const gizlilik = legal.slice(0, legal.indexOf('export function TermsBody'));
  const tarih = gizlilik.match(/Son güncelleme:\s*([0-9]{1,2}\s+\S+\s+[0-9]{4})/u)?.[1];
  check('Gizlilik "Son güncelleme" tarihi okunabildi', !!tarih);
  check(
    'FUNNEL_MEMBER_EVENTS_ENABLED yalnızca gizlilik metni güncellendiyse açık',
    !FUNNEL_MEMBER_EVENTS_ENABLED || tarih !== '8 Eylül 2026',
    `bayrak açık ama metin hâlâ ${tarih} tarihli`,
  );
}

// 6 — admin gruplaması: mevcut kohort DIŞINDA, toplam alt satırların toplamı.
{
  const z = { returned: 0, signed_up: 0, started: 0, finished: 0, games_started: 0, games_finished: 0 };
  const g = groupFunnelV2(
    [
      { platform: 'web', channel: 'ig', land: 5, ...z, started: 2, games_started: 3 },
      { platform: 'web', channel: 'ig-bio', land: 3, ...z },
      { platform: 'web', channel: 'direkt', land: 10, ...z, returned: 4 },
      { platform: 'android', channel: 'play-organik', land: 2, ...z },
      { platform: 'web', channel: FUNNEL_EXISTING_CHANNEL, land: 40, ...z, returned: 30 },
    ],
    FUNNEL_EXISTING_CHANNEL,
  );
  check('mevcut kohort toplamına girmiyor', g.total.land === 20 && g.total.returned === 4, JSON.stringify(g.total));
  check('mevcut ayrıca sayılıyor', g.existing === 40);
  check('platform sırası web → android', g.platforms.map((p) => p.platform).join(',') === 'web,android');
  const ig = g.platforms[0].channels.find((c) => c.channel === 'instagram');
  check('ig + ig-bio → Instagram grubu, toplamı 8', ig?.land === 8 && ig.sources.length === 2);
  check('web platform toplamı 18', g.platforms[0].land === 18);
}

// 7 — olay/platform listeleri SQL ile birebir (sıra dahil) + tablo kısıtları.
{
  const dosya = 'supabase/migrations/20260924141953_funnel_events.sql';
  const sql = readFileSync(dosya, 'utf8');
  const dizi = (ad: string) =>
    [...(sql.match(new RegExp(`${ad} constant text\\[\\] := array\\[([^\\]]*)\\]`))?.[1] ?? '').matchAll(/'([a-z_]+)'/g)].map(
      (m) => m[1],
    );
  check('v_events ↔ FUNNEL_EVENTS', JSON.stringify(dizi('v_events')) === JSON.stringify(FUNNEL_EVENTS), JSON.stringify(dizi('v_events')));
  check(
    'v_platforms ↔ FUNNEL_PLATFORMS',
    JSON.stringify(dizi('v_platforms')) === JSON.stringify(FUNNEL_PLATFORMS),
    JSON.stringify(dizi('v_platforms')),
  );
  const kisit = (kolon: string) =>
    [...(sql.match(new RegExp(`${kolon}\\s+text not null check \\(${kolon} in \\(([^)]*)\\)\\)`))?.[1] ?? '').matchAll(/'([a-z_]+)'/g)].map(
      (m) => m[1],
    );
  check('event CHECK kısıtı ↔ FUNNEL_EVENTS', JSON.stringify(kisit('event')) === JSON.stringify(FUNNEL_EVENTS));
  check('platform CHECK kısıtı ↔ FUNNEL_PLATFORMS', JSON.stringify(kisit('platform')) === JSON.stringify(FUNNEL_PLATFORMS));
  check('tabloda user_id kolonu YOK', !/\buser_id\b\s+uuid/.test(sql));
}

// 8 — çağrı yeri: land/visit kapı kararından ÖNCE (karşılama + SPA birlikte).
{
  const main = readFileSync('src/main.tsx', 'utf8');
  const cagri = main.indexOf('funnelOpen(captureUtmSource)');
  const kapi = main.indexOf("if (document.documentElement.classList.contains('uygulama-modu'))");
  check('main.tsx funnelOpen çağırıyor', cagri > 0);
  check('funnelOpen kapı kararından ÖNCE', cagri > 0 && kapi > 0 && cagri < kapi);
}

if (failures > 0) {
  console.log(`\n${failures} kontrol BAŞARISIZ`);
  process.exit(1);
}
console.log('\nTüm kontroller geçti.');
