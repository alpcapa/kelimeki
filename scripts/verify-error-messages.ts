// Kelimeki — `src/utils/errorMessage.ts`'in saf karar mantığını ÜRETİM kodunu
// import ederek doğrular.
//
// NEDEN AYRI BİR BETİK: web'de birim test çatısı yok (`npm run test`
// Playwright duman testleri) ve bu mantık duman testiyle SINANAMAZ — tetiklemek
// için sunucunun 504 dönmesi ya da RLS'in reddetmesi gerekiyor.
// `verify-away-return`in aynı deseni (esbuild + node).
//
// KAPININ İŞİ: ekrana ham makine metni düşmediğini kanıtlamak. Vaka 13 Eylül
// 2026'da yaşandı — App Store ekran kaydı çekilirken giriş penceresinde
// `{"message":"Gateway Timeout"}` göründü.
//
// Koşum: npm run verify-error-messages
import {
  GENERIC_ERROR_NOTICE,
  TEMPORARY_ERROR_NOTICE,
  friendlyErrorMessage,
  isMachineMessage,
  isServerRejection,
  isTemporaryServerError,
  rawErrorMessage,
} from '../src/utils/errorMessage';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) {
    console.log(`  ✓ ${name}`);
  } else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

/** Telemetri bu ortamda kurulu değil; `report:false` ile yan etkiyi kapatıyoruz. */
const goster = (err: unknown, fallback?: string) =>
  friendlyErrorMessage(err, { report: false, ...(fallback ? { fallback } : {}) });

/** SQLSTATE taşıyan hata — `rethrowSupabase`in ürettiği şekil. */
function kodlu(message: string, code: string): Error & { code?: string } {
  const e = new Error(message) as Error & { code?: string };
  e.code = code;
  return e;
}

console.log('errorMessage — kullanıcıya gösterilen hata metni');

// ── 1. VAKANIN KENDİSİ ──────────────────────────────────────────────────────
// Ekranda görülen tam metin. Bu satır düşerse hata geri gelmiş demektir.
{
  const ekran = goster(new Error('{"message":"Gateway Timeout"}'));
  check('504 JSON gövdesi ekrana ÇIKMAZ', !ekran.includes('Gateway'), ekran);
  check('504 → geçici arıza metni', ekran === TEMPORARY_ERROR_NOTICE, ekran);
}

// Aynı arıza JSON'suz, düz metin olarak da geliyor — makine kalıplarının
// HİÇBİRİNE takılmaz, yakalayan tek şey geçici-arıza testinin ÖNCE koşması.
{
  const ekran = goster(new Error('Gateway Timeout'));
  check('düz "Gateway Timeout" da yakalanır', ekran === TEMPORARY_ERROR_NOTICE, ekran);
}

// ── 2. SUNUCUNUN KENDİ REDDİ (P0001) OLDUĞU GİBİ GÖSTERİLİR ────────────────
// Bu dal olmazsa oyunun Türkçe iş kuralı mesajları jenerikleşir — düzeltmenin
// yaratabileceği EN BÜYÜK regresyon bu.
{
  check(
    'P0001 "Sıra sende değil." korunur',
    goster(kodlu('Sıra sende değil.', 'P0001')) === 'Sıra sende değil.',
  );
  check(
    'P0001 "Kendi linkinle arkadaş olamazsın." korunur',
    goster(kodlu('Kendi linkinle arkadaş olamazsın.', 'P0001')) ===
      'Kendi linkinle arkadaş olamazsın.',
  );
  // Sıra kuralı: P0001 makine kalıbına benzese bile gösterilir.
  check(
    'P0001 makine testini EZER',
    goster(kodlu('{"message":"özel ret"}', 'P0001')) === '{"message":"özel ret"}',
  );
  check('isServerRejection yalnızca P0001', isServerRejection(kodlu('x', 'P0001')));
  check('isServerRejection 23505 için false', !isServerRejection(kodlu('x', '23505')));
}

// ── 3. KENDİ TÜRKÇE MESAJLARIMIZ GEÇER ─────────────────────────────────────
// Hepsi ASCII — "Türkçe karakter var mı" diye bakan bir beyaz liste bunları
// elerdi, kara listenin sebebi bu.
{
  for (const msg of [
    'Ad zorunludur.',
    'Oturum açık değil.',
    'Supabase yapılandırılmadı.',
    'Mesaj 1-200 karakter arasında olmalı.',
    'Bu takma isim zaten kullanılıyor. Farklı bir tane dene.',
    'Şifre çok zayıf. En az 6 karakter kullan.',
  ]) {
    check(`kendi mesajımız geçer: "${msg}"`, goster(new Error(msg)) === msg);
  }
}

// ── 4. MAKİNE METİNLERİ ELENİR ─────────────────────────────────────────────
{
  const makine: [string, string][] = [
    ['JSON gövdesi', '{"code":"PGRST301","message":"JWT expired"}'],
    ['HTML sayfası', '<!DOCTYPE html><html><body>504</body></html>'],
    ['PostgrestException dökümü', 'PostgrestException(message: x, code: 42501, details: Bad Request)'],
    ['AuthApiException', 'AuthApiException(message: bad, statusCode: 400)'],
    ['SQLSTATE dökümü', 'code: 23505, details: duplicate'],
    ['benzersizlik ihlali', 'duplicate key value violates unique constraint "profiles_pkey"'],
    ['RLS reddi', 'permission denied for table profiles'],
    ['eksik kolon', 'column "foo" does not exist'],
    ['JS istisna öneki', 'TypeError: Cannot read properties of null'],
    ['fetch hatası', 'TypeError: Failed to fetch'],
  ];
  for (const [ad, msg] of makine) {
    check(`${ad} elenir`, isMachineMessage(msg), msg);
    const ekran = goster(new Error(msg));
    check(
      `${ad} → Türkçe metin`,
      ekran === GENERIC_ERROR_NOTICE || ekran === TEMPORARY_ERROR_NOTICE,
      ekran,
    );
  }
}

// ── 5. GEÇİCİ ARIZA SINIFI ─────────────────────────────────────────────────
{
  for (const msg of [
    'Bad Gateway',
    'Service Unavailable',
    'Internal Server Error',
    '503 upstream connect error',
    'canceling statement due to statement timeout',
    'Connection timed out',
    'TimeoutException after 0:00:30.000000',
    'SocketException: Connection reset by peer',
  ]) {
    check(`geçici: "${msg}"`, isTemporaryServerError(msg));
    check(`geçici → bekleme metni: "${msg}"`, goster(new Error(msg)) === TEMPORARY_ERROR_NOTICE);
  }
  // Geçici DEĞİL: kendi mesajımızda "zaman aşımı" Türkçe yazılıyor.
  check('Türkçe "zaman aşımı" geçiciye takılmaz', !isTemporaryServerError('Süre zaman aşımına uğradı.'));
}

// ── 6. BOŞ / GARİP GİRDİLER ────────────────────────────────────────────────
{
  check('boş mesaj → fallback', goster(new Error('')) === GENERIC_ERROR_NOTICE);
  check('yalnızca boşluk → fallback', goster(new Error('   ')) === GENERIC_ERROR_NOTICE);
  check('null → fallback', goster(null) === GENERIC_ERROR_NOTICE);
  check('undefined → fallback', goster(undefined) === GENERIC_ERROR_NOTICE);
  check('düz nesne → fallback', goster({}) === GENERIC_ERROR_NOTICE);
  check('"[object Object]" ekrana çıkmaz', !goster({}).includes('object'));
  check('çağırana özel fallback kullanılır', goster({}, 'Hamle gönderilemedi.') === 'Hamle gönderilemedi.');
  check('rawErrorMessage düz nesnede boş döner', rawErrorMessage({}) === '');
  check('rawErrorMessage string message okur', rawErrorMessage({ message: 'x' }) === 'x');
}

// ── 7. METİNLERİN KENDİSİ ──────────────────────────────────────────────────
// Kullanıcıya gösterilen her metin Türkçe ve eyleme dönük olmalı.
{
  for (const [ad, metin] of [
    ['GENERIC_ERROR_NOTICE', GENERIC_ERROR_NOTICE],
    ['TEMPORARY_ERROR_NOTICE', TEMPORARY_ERROR_NOTICE],
  ] as const) {
    check(`${ad} boş değil`, metin.trim().length > 0);
    check(`${ad} makine metni değil`, !isMachineMessage(metin), metin);
    check(`${ad} "tekrar dene" diyor`, /tekrar dene/i.test(metin), metin);
  }
}

console.log('');
if (failures > 0) {
  console.log(`${failures} kontrol DÜŞTÜ`);
  process.exit(1);
}
console.log('Tüm kontroller geçti.');
