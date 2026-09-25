// Kelimeki — `src/utils/chatRead.ts`in (Canlı oyun sohbetinin okundu kararı)
// saf mantığını ÜRETİM kodunu import ederek doğrular.
//
// NEDEN AYRI BİR BETİK: web'de birim test çatısı yok ve bu mantık duman
// testiyle SINANAMAZ — Canlı oyun iki gerçek oturum + Supabase istiyor.
// `verify-away-return`ün aynı deseni (esbuild + node).
//
// Koşum: npm run verify-chat-read
import { decideChatRead, laterOf } from '../src/utils/chatRead';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

const ME = 'me';
const HIM = 'danyal';
const NOW = '2026-09-23T08:00:00.000Z';
const rows = [
  { sender_user_id: HIM, created_at: '2026-09-22T10:00:00.123456+00:00' },
  { sender_user_id: ME, created_at: '2026-09-22T11:00:00.000000+00:00' },
  { sender_user_id: HIM, created_at: '2026-09-23T07:00:00.000000+00:00' },
  { sender_user_id: HIM, created_at: '2026-09-23T07:30:00.000000+00:00' },
];

console.log('chatRead — okundu kararı');

// 1 — KULLANICININ VAKASI: bu cihazda damga YOK (oyun burada ilk kez
// açılıyor) ama sunucu, başka cihazda 22 Eylül 11:00'e kadar okunduğunu
// biliyor → iki yeni mesaj GÖRÜNMELİ. Eski kod burada 0 diyordu.
{
  const d = decideChatRead({ serverAt: '2026-09-22T11:00:00+00:00', localAt: null, rows, myUserId: ME, nowIso: NOW });
  check('yeni cihaz + sunucu damgası → 2 okunmamış', d.unread === 2, `unread=${d.unread}`);
  check('yeni cihaz sunucuya yetişir (cihaza yazılır)', d.writeLocal === '2026-09-22T11:00:00+00:00');
  check('sunucuya gereksiz yazma yok', d.pushToServer === null);
}

// 2 — İKİNCİ VAKA: bu cihazın eski damgası geride, öteki cihazda hepsi
// okunmuş → hiçbiri "yeni" görünmemeli.
{
  const d = decideChatRead({
    serverAt: '2026-09-23T07:30:00.000000+00:00',
    localAt: '2026-09-22T10:00:00.123456+00:00',
    rows, myUserId: ME, nowIso: NOW,
  });
  check('başka cihazda okunanlar burada yeni değil', d.unread === 0, `unread=${d.unread}`);
  check('geride kalan cihaz damgası güncellenir', d.writeLocal === '2026-09-23T07:30:00.000000+00:00');
}

// 3 — cihaz ilerideyse (çevrimdışı okunmuş / port dönemi damgası) sunucu
// yetişir.
{
  const d = decideChatRead({
    serverAt: '2026-09-22T11:00:00+00:00',
    localAt: '2026-09-23T07:00:00.000000+00:00',
    rows, myUserId: ME, nowIso: NOW,
  });
  check('cihaz ileride → 1 okunmamış', d.unread === 1, `unread=${d.unread}`);
  check('cihaz ileride → sunucuya gönderilir', d.pushToServer === '2026-09-23T07:00:00.000000+00:00');
  check('cihaz ileride → cihaza yazılmaz', d.writeLocal === null);
}

// 4 — hiçbir yerde damga yok, sunucu KESİN boş → eski "ilk ziyaret" tohumu,
// ama artık sunucuya da yazılır.
{
  const d = decideChatRead({ serverAt: null, localAt: null, rows, myUserId: ME, nowIso: NOW });
  check('hiç damga yok → 0 okunmamış (tohum)', d.unread === 0);
  check('tohum = son mesaj', d.writeLocal === '2026-09-23T07:30:00.000000+00:00');
  check('tohum sunucuya da yazılır', d.pushToServer === '2026-09-23T07:30:00.000000+00:00');
}

// 5 — ⚠ sunucu BİLİNMİYOR (istek düştü) ve cihazda damga yok: tohum yalnızca
// cihaza. Sunucuya "hepsi okundu" basmak, gerçek (daha eski) damganın
// üstüne yazmak olurdu — sunucu yalnızca ileri gittiği için GERİ ALINAMAZ.
{
  const d = decideChatRead({ serverAt: undefined, localAt: null, rows, myUserId: ME, nowIso: NOW });
  check('sunucu bilinmiyor → tohum sunucuya YAZILMAZ', d.pushToServer === null);
  check('sunucu bilinmiyor → tohum cihaza yazılır', d.writeLocal !== null);
}

// 6 — sunucu bilinmiyor ama cihazda gerçek bir okuma var → gönderilir
// (zararsız: sunucu yalnızca ileri gider).
{
  const d = decideChatRead({ serverAt: undefined, localAt: '2026-09-23T07:00:00.000000+00:00', rows, myUserId: ME, nowIso: NOW });
  check('sunucu bilinmiyor + cihaz damgası → 1 okunmamış', d.unread === 1);
  check('sunucu bilinmiyor + cihaz damgası → yeniden denenir', d.pushToServer === '2026-09-23T07:00:00.000000+00:00');
}

// 7 — iki kaynak eşit → hiçbir yazma yok (her yüklemede RPC atılmasın).
{
  const at = '2026-09-23T07:30:00.000000+00:00';
  const d = decideChatRead({ serverAt: at, localAt: at, rows, myUserId: ME, nowIso: NOW });
  check('eşit damgalar → yazma yok', d.writeLocal === null && d.pushToServer === null);
}

// 8 — kendi mesajlarım hiç sayılmaz; biçim farkı (Z ↔ +00:00, 3 ↔ 6 hane)
// karşılaştırmayı bozmaz.
{
  const d = decideChatRead({ serverAt: '2026-09-22T09:00:00Z', localAt: null, rows, myUserId: ME, nowIso: NOW });
  check('kendi mesajım sayılmaz (4 mesaj, 3 onun)', d.unread === 3, `unread=${d.unread}`);
  check('laterOf biçimden bağımsız', laterOf('2026-09-23T07:00:00Z', '2026-09-23T07:00:00.500000+00:00') === '2026-09-23T07:00:00.500000+00:00');
}

if (failures > 0) {
  console.error(`\n${failures} kontrol BAŞARISIZ`);
  process.exit(1);
}
console.log('\nTüm kontroller geçti.');
