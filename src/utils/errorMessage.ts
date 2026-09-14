/**
 * Kullanıcıya gösterilecek hata metninin son kapısı.
 *
 * ## Neden var (13 Eylül 2026)
 *
 * Kullanıcı App Store için ekran kaydı çekerken giriş penceresinde şunu
 * gördü ve fotoğrafladı:
 *
 *     {"message":"Gateway Timeout"}
 *
 * Ham bir HTTP 504 gövdesi, Türkçe bir uygulamada, giriş formunun altında.
 * İkinci denemede giriş çalıştı — yani arıza geçiciydi, ama kullanıcının
 * gördüğü şey bunu SÖYLEMİYORDU.
 *
 * Bu tek bir unutulmuş satır değil, bir POLİTİKANIN sonucuydu.
 * `friendlyAuthMessage` (4 Ağustos 2026) ve `isNetworkError` ikisi de
 * bilerek *"eşleşmeyen hata HAM hâliyle geçsin"* diyordu; gerekçe de
 * sağlamdı: *"bilinmeyen bir hatayı uydurma bir Türkçe cümleyle gizlemek,
 * hata ayıklamayı imkânsız kılardı."*
 *
 * O gerekçe artık geçerli DEĞİL, çünkü arada `client_errors` telemetrisi
 * var (`utils/errorReporting.ts`, 30 Ağustos 2026). Ham metni kullanıcıya
 * BASMAK ile onu KAYBETMEK aynı şey değil: burası ham metni telemetriye
 * yazar, ekrana Türkçe bir cümle koyar. Hata ayıklama kabiliyeti artıyor —
 * çünkü eskiden yalnızca ekranı gören kişi biliyordu.
 *
 * ## Üç dal (repoda zaten vardı, burada tekleşti)
 *
 * Desenin kendisi yeni değil: `inviteAcceptErrorText`
 * (`mobile/app/lib/src/data/friends_api.dart`, 25 Ağustos 2026) tam bunu
 * yapıyordu, ama yalnızca TEK uçta. Genelleştirilmiş hâli:
 *
 * 1. **Sunucunun KENDİ reddi → olduğu gibi göster.** plpgsql'in
 *    `raise exception`'ı SQLSTATE **`P0001`** üretir ve bu projedeki o
 *    metinler (`submit_move` → "Sıra sende değil.", `accept_friend_invite`
 *    → "Kendi linkinle arkadaş olamazsın.") KULLANICIYA GÖSTERİLMEK üzere
 *    Türkçe yazılmıştır. Koda bakılır, METNE değil — metin değişebilir.
 * 2. **Geçici sunucu arızası → "birkaç saniye sonra tekrar dene".** 502/503/
 *    504, zaman aşımı, soket/el sıkışma hataları. Vakanın kendisi bu dal.
 * 3. **Makine metni → jenerik Türkçe cümle.** JSON/HTML gövdesi, PostgREST/
 *    GoTrue İngilizcesi, Dart/JS istisna dökümü, SQLSTATE dökümü.
 * 4. **Geri kalan → olduğu gibi.** Kendi Türkçe doğrulama mesajlarımız
 *    (`throw new Error('Ad zorunludur.')`) buradan geçer.
 *
 * ⚠ **Sıra davranışın parçası, üç yerde birden:**
 * · 1 her şeyden önce — `P0001` taşıyan bir mesaj makine kalıbına benzese
 *   bile gösterilir, sunucu onu bilerek yazdı.
 * · 2 mutlaka 3'ten önce — ekranda görülen `Gateway Timeout` düz METİN
 *   olarak da gelebiliyor (JSON gövdesi olmadan) ve o hâliyle hiçbir makine
 *   kalıbına takılmaz; sıra ters olsaydı 4. dala düşüp yine ham görünürdü.
 * · 2 ve 3 telemetriye YAZAR, 4 yazmaz — 4 zaten bizim metnimiz.
 *
 * ⚠ **`code` ancak taşınırsa işe yarar.** 13 Eylül 2026'ya kadar
 * `src/lib/api.ts` 45 yerde `throw new Error(error.message)` diyordu, yani
 * SQLSTATE yolda DÜŞÜYORDU ve 1. dal hiçbir zaman çalışamazdı. Aynı PR'da
 * hepsi `rethrowSupabase()`e çevrildi; yeni bir uç yazarken `code`'u
 * düşürme.
 *
 * ⚠ **Admin paneli bilerek DIŞARIDA.** `AdminDashboard`/`MemberMessageModal`
 * ham metni göstermeye devam eder: oranın tek kullanıcısı geliştiricinin
 * kendisi ve ham hata orada bir ARAÇ, arıza değil.
 *
 * Port ikizi: `mobile/app/lib/src/util/error_message.dart` — metinler ve
 * kalıplar BİREBİR aynı, `error_message_parity_test.dart` bu dosyayı okuyup
 * karşılaştırır.
 *
 * ⚠ **İkisi AYRI günlerde `main`'e girdi** (web 14 Eylül, port sonrası):
 * 1.1.0 (665) kodu donduruğu ve iki mağaza da incelediği için web yarısı
 * tek başına yayınlandı, port yarısı inceleme kapanana kadar bekletildi.
 * Yani `client_errors`ta 14 Eylül ile port sürümünün yayını arasındaki
 * pencerede `hata-metni:*` kayıtları YALNIZCA web'den gelir — mobil
 * sessizliği "mobilde hata yok" diye okunmamalı.
 */

/**
 * Ham metni nereye yazacağımız — DIŞARIDAN verilir.
 *
 * ⚠ Doğrudan `reportClientError` import EDİLMEZ (13 Eylül 2026'da denendi ve
 * geri alındı): o modül Supabase istemcisini çekiyor, istemci de
 * `import.meta.env` okuyor — yani bu dosyayı node'da import eden doğrulama
 * betiği (`npm run verify-error-messages`) daha ilk satırda düşüyordu.
 * Enjeksiyon hem saflığı hem kapıyı koruyor; deponun `ClientErrorSink`
 * deseninin aynısı.
 *
 * Bağlanmazsa sessizce hiçbir şey yazılmaz — metin kararı yine de doğrudur.
 */
type HataRaporlayici = (err: unknown, context: string) => void;
let raporla: HataRaporlayici | null = null;

/** `boot.tsx` açılışta bağlar (`installGlobalErrorReporting`'in yanında). */
export function setErrorMessageReporter(fn: HataRaporlayici | null): void {
  raporla = fn;
}

/** Bilinmeyen/makine kaynaklı hata — kullanıcı ne yapacağını bilsin. */
export const GENERIC_ERROR_NOTICE = 'Bir sorun oluştu. Lütfen tekrar dene.';

/**
 * Sunucu ayakta değil ya da zaman aşımına uğradı — GEÇİCİ olduğu söylenmeli.
 *
 * Ayrı bir metin olmasının sebebi doğrudan vakanın kendisi: kullanıcı ikinci
 * denemede giriş yapabildi. "Bir sorun oluştu" doğru ama eksik; burada
 * yapılacak somut bir şey var ve o da beklemek.
 */
export const TEMPORARY_ERROR_NOTICE =
  'Sunucuya şu anda ulaşılamıyor. Birkaç saniye sonra tekrar dene.';

/** Sunucunun bilerek yazdığı, kullanıcıya gösterilebilir ret (SQLSTATE P0001). */
export function isServerRejection(err: unknown): boolean {
  return (err as { code?: string } | null)?.code === 'P0001';
}

/**
 * Ağ geçidi / zaman aşımı / "sunucu ayakta değil" sınıfı.
 *
 * `isNetworkError`'dan (offlineNotice.ts) AYRI: orası "isteği hiç
 * gönderemedik" (cihaz çevrimdışı), burası "gönderdik ama sunucu tarafı
 * düştü". Kullanıcı için ikisi de beklemeyi gerektiriyor, ama metin farklı:
 * biri bağlantını kontrol et der, öteki birkaç saniye bekle.
 */
const GECICI_KALIPLAR: RegExp[] = [
  /gateway\s*time-?out/i,
  /bad\s*gateway/i,
  /service\s*unavailable/i,
  /internal\s*server\s*error/i,
  /\b(502|503|504)\b/,
  /statement\s*timeout|canceling\s*statement/i,
  /\btimed?\s*out\b|\btimeout\b/i,
  /upstream\s*(connect|request|error)/i,
  /ECONNRESET|ETIMEDOUT|EAI_AGAIN|ENOTFOUND/,
  /TimeoutException|SocketException|HandshakeException/,
];

/**
 * Kullanıcıya gösterilmemesi gereken "makine metni" kalıpları.
 *
 * ⚠ Bu bir KARA liste ve öyle olması bilinçli. Beyaz liste ("Türkçe mi?")
 * denenemez: kendi mesajlarımızın çoğu ASCII ("Ad zorunludur.", "Oturum
 * açık değil."), yani Türkçe karaktere bakan bir test onları da elerdi.
 * Kara liste yanılırsa hata GÜVENLİ tarafta olur: tanımadığımız bir metin
 * geçer, ekranda tuhaf ama okunabilir bir şey kalır — sessizce jenerikleşen
 * bir Türkçe mesajdan iyidir.
 */
const MAKINE_KALIPLARI: RegExp[] = [
  /^\s*[[{<]/, // JSON gövdesi ya da HTML sayfası
  /"(message|error|code|hint|details)"\s*:/i, // JSON parçası
  /^(Error|Exception|TypeError|RangeError):/,
  /(Postgrest|Auth(Api|Retryable|Session|Weak)?|Storage|Functions?(Http|Relay))[A-Za-z]*Exception/,
  /\bPGRST\d+\b/,
  /\b[0-9A-Z]{5}\b\s*(?:,|:)?\s*details:/i, // SQLSTATE dökümü
  /duplicate key|violates (unique|foreign key|check|not-null) constraint|null value in column/i,
  /\bJWT\b|jwt (expired|malformed)|invalid claim/i,
  /permission denied for (table|relation|schema|function)/i,
  /relation ".*" does not exist|column ".*" does not exist/i,
  /^\s*<!DOCTYPE/i,
  /Failed to fetch|Load failed|NetworkError|fetch failed|network request failed/i,
];

/** Metnin kendisi makine çıktısı mı (kullanıcıya gösterilemez mi)? */
export function isMachineMessage(message: string): boolean {
  const msg = message.trim();
  if (!msg) return true;
  return MAKINE_KALIPLARI.some((re) => re.test(msg));
}

/** Geçici sunucu arızası mı (bekleyip tekrar denemek işe yarar mı)? */
export function isTemporaryServerError(message: string): boolean {
  return GECICI_KALIPLAR.some((re) => re.test(message));
}

/** Hatadan ham mesaj metnini çıkarır (hata nesnesi olmayabilir). */
export function rawErrorMessage(err: unknown): string {
  if (err instanceof Error) return err.message ?? '';
  const m = (err as { message?: unknown } | null)?.message;
  if (typeof m === 'string') return m;
  if (err == null) return '';
  const s = String(err);
  return s === '[object Object]' ? '' : s;
}

export type FriendlyErrorOptions = {
  /** Makine metni yerine gösterilecek metin. Varsayılan: GENERIC_ERROR_NOTICE. */
  fallback?: string;
  /** Telemetriye yazılırken hangi yüzeyden geldiği (`etiket`). */
  surface?: string;
  /** Telemetriyi atla (testler ve zaten raporlayan çağıranlar için). */
  report?: boolean;
};

/**
 * Kullanıcıya gösterilecek metni döndürür — ham makine çıktısını asla
 * geçirmez, ham metni telemetriye yazar.
 *
 * Ağ (cihaz çevrimdışı) dalı BİLEREK burada değil: çağıranların kendi
 * bağlam metinleri var (`OFFLINE_MOVE_NOTICE`, `OFFLINE_MEANING_NOTICE`),
 * ve o ayrım `isNetworkError` ile çağıranda yapılıyor.
 */
export function friendlyErrorMessage(err: unknown, options: FriendlyErrorOptions = {}): string {
  const { fallback = GENERIC_ERROR_NOTICE, surface, report = true } = options;
  const raw = rawErrorMessage(err);

  // 1. Sunucunun kendi reddi — metin ne olursa olsun gösterilir.
  if (isServerRejection(err) && raw.trim()) return raw.trim();

  const bildir = () => {
    if (report) raporla?.(err, surface ? `hata-metni:${surface}` : 'hata-metni');
  };

  // 2. Geçici sunucu arızası. ⚠ Makine testinden ÖNCE: "Gateway Timeout"
  // düz metin olarak da gelebiliyor (JSON gövdesi olmadan) ve o hâliyle
  // hiçbir makine kalıbına takılmaz — vakanın kendisi bu.
  if (isTemporaryServerError(raw)) {
    bildir();
    return TEMPORARY_ERROR_NOTICE;
  }

  // 3. Makine metni — kullanıcıya Türkçe, telemetriye ham.
  if (isMachineMessage(raw)) {
    bildir();
    return fallback;
  }

  // 4. Kendi Türkçe mesajımız (ya da tanımadığımız ama okunabilir bir metin).
  return raw.trim();
}
