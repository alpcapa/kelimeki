// Kullanıcıya gösterilecek hata metninin son kapısı — web
// `src/utils/errorMessage.ts` portu.
//
// NEDEN (13 Eylül 2026): kullanıcı App Store için ekran kaydı çekerken giriş
// penceresinde `{"message":"Gateway Timeout"}` gördü — ham bir HTTP 504
// gövdesi, Türkçe bir uygulamada. İkinci denemede giriş çalıştı, yani arıza
// geçiciydi ama ekrandaki metin bunu söylemiyordu.
//
// **METİNLER VE KALIPLAR İKİ PLATFORMDA AYNI OLMAK ZORUNDA** — biri
// değişirse öteki de. `test/error_message_parity_test.dart` web dosyasını
// OKUYUP karşılaştırır (bulamazsa düşer).
//
// Dört dal, SIRASI davranışın parçası:
//   1. Sunucunun KENDİ reddi (SQLSTATE `P0001`) → olduğu gibi göster.
//      `submit_move` → "Sıra sende değil.", `accept_friend_invite` →
//      "Kendi linkinle arkadaş olamazsın." Bunlar KULLANICIYA gösterilmek
//      üzere yazılmış Türkçe metinler; koda bakılır, METNE değil.
//   2. Geçici sunucu arızası → "birkaç saniye sonra tekrar dene".
//      ⚠ 3'ten ÖNCE: "Gateway Timeout" düz metin olarak da geliyor ve o
//      hâliyle hiçbir makine kalıbına takılmaz — vaka tam olarak bu.
//   3. Makine metni → jenerik Türkçe cümle.
//   4. Geri kalan → olduğu gibi (kendi Türkçe doğrulama mesajlarımız).
//
// ⚠ Ağ (cihaz çevrimdışı) dalı BİLEREK burada değil: çağıranların kendi
// bağlam metinleri var (`kOfflineMoveNotice` gibi) ve o ayrım `isNetworkError`
// ile çağıranda yapılıyor.

/// Bilinmeyen/makine kaynaklı hata — kullanıcı ne yapacağını bilsin.
const kGenericErrorNotice = 'Bir sorun oluştu. Lütfen tekrar dene.';

/// Sunucu ayakta değil ya da zaman aşımına uğradı — GEÇİCİ olduğu söylenmeli.
///
/// Ayrı bir metin olmasının sebebi doğrudan vakanın kendisi: kullanıcı ikinci
/// denemede giriş yapabildi. "Bir sorun oluştu" doğru ama eksik; burada
/// yapılacak somut bir şey var ve o da beklemek.
const kTemporaryErrorNotice =
    'Sunucuya şu anda ulaşılamıyor. Birkaç saniye sonra tekrar dene.';

/// Ham metni nereye yazacağımız — DIŞARIDAN verilir (web'deki ile aynı
/// gerekçe: bu dosya saf kalsın, testler Supabase çekmesin).
typedef ErrorMessageReporter = void Function(Object? err, String context);
ErrorMessageReporter? _raporla;

/// Uygulama açılışında bağlanır; bağlanmazsa sessizce hiçbir şey yazılmaz.
void setErrorMessageReporter(ErrorMessageReporter? fn) => _raporla = fn;

final List<RegExp> _geciciKaliplar = [
  RegExp(r'gateway\s*time-?out', caseSensitive: false),
  RegExp(r'bad\s*gateway', caseSensitive: false),
  RegExp(r'service\s*unavailable', caseSensitive: false),
  RegExp(r'internal\s*server\s*error', caseSensitive: false),
  RegExp(r'\b(502|503|504)\b'),
  RegExp(r'statement\s*timeout|canceling\s*statement', caseSensitive: false),
  RegExp(r'\btimed?\s*out\b|\btimeout\b', caseSensitive: false),
  RegExp(r'upstream\s*(connect|request|error)', caseSensitive: false),
  RegExp(r'ECONNRESET|ETIMEDOUT|EAI_AGAIN|ENOTFOUND'),
  RegExp(r'TimeoutException|SocketException|HandshakeException'),
];

/// ⚠ KARA liste, bilinçli. Beyaz liste ("Türkçe mi?") denenemez: kendi
/// mesajlarımızın çoğu ASCII ("Ad zorunludur."), yani Türkçe karaktere bakan
/// bir test onları da elerdi. Kara liste yanılırsa hata GÜVENLİ tarafta olur.
final List<RegExp> _makineKaliplari = [
  RegExp(r'^\s*[\[{<]'),
  RegExp(r'"(message|error|code|hint|details)"\s*:', caseSensitive: false),
  RegExp(r'^(Error|Exception|TypeError|RangeError):'),
  RegExp(
      r'(Postgrest|Auth(Api|Retryable|Session|Weak)?|Storage|Functions?(Http|Relay))[A-Za-z]*Exception'),
  RegExp(r'\bPGRST\d+\b'),
  RegExp(r'\b[0-9A-Z]{5}\b\s*(?:,|:)?\s*details:', caseSensitive: false),
  RegExp(
      r'duplicate key|violates (unique|foreign key|check|not-null) constraint|null value in column',
      caseSensitive: false),
  RegExp(r'\bJWT\b|jwt (expired|malformed)|invalid claim',
      caseSensitive: false),
  RegExp(r'permission denied for (table|relation|schema|function)',
      caseSensitive: false),
  RegExp(r'relation ".*" does not exist|column ".*" does not exist',
      caseSensitive: false),
  RegExp(r'^\s*<!DOCTYPE', caseSensitive: false),
  // ⚠ Web'in kalıbının ÜST KÜMESİ: ilk beşi tarayıcının fetch metinleri,
  // gerisi Dart'ın (`dart:io`/`package:http`) taşıma metinleri — web'de hiç
  // oluşmazlar, bu yüzden web'e eklenmedi. Kalıp SAYISI parite testi için
  // aynı tutuldu (tek regex'e eklendi). 26 Eylül 2026, 1.1.1 cihaz turu:
  // uçak modunda Canlı oyun mesajı ekrana ham
  // "Failed host lookup: 'xvq….supabase.co'" bastı — `ClientException`in
  // `message` alanı sınıf adını TAŞIMIYOR, yani `SocketException` kalıbı
  // (`toString()`e bakan) onu göremiyordu.
  RegExp(
      r'Failed to fetch|Load failed|NetworkError|fetch failed|network request failed'
      r'|Failed host lookup|Connection (refused|reset|closed|timed out)'
      r'|Network is unreachable|No address associated|OS Error',
      caseSensitive: false),
];

/// Sunucunun bilerek yazdığı, kullanıcıya gösterilebilir ret (SQLSTATE P0001).
///
/// `ServerRejection`, `PostgrestException` ve `AuthException` üçü de `code`
/// alanı taşıyor ama ortak bir üst tipleri yok — bu yüzden `dynamic` okunuyor.
bool isServerRejection(Object? err) {
  if (err == null) return false;
  try {
    final dynamic d = err;
    return d.code == 'P0001';
  } catch (_) {
    return false;
  }
}

/// Metnin kendisi makine çıktısı mı (kullanıcıya gösterilemez mi)?
bool isMachineMessage(String message) {
  final msg = message.trim();
  if (msg.isEmpty) return true;
  return _makineKaliplari.any((re) => re.hasMatch(msg));
}

/// Geçici sunucu arızası mı (bekleyip tekrar denemek işe yarar mı)?
bool isTemporaryServerError(String message) =>
    _geciciKaliplar.any((re) => re.hasMatch(message));

/// Hatadan ham mesaj metnini çıkarır.
///
/// ⚠ `toString()` son çare: Dart'ta o çoğu zaman `PostgrestException(message:
/// …, code: …, details: …)` dökümünü verir — 3. dal onu zaten eler.
String rawErrorMessage(Object? err) {
  if (err == null) return '';
  try {
    final dynamic d = err;
    final m = d.message;
    if (m is String) return m;
  } catch (_) {
    // `message` alanı yok — aşağıdaki toString()'e düş.
  }
  return err.toString();
}

/// Kullanıcıya gösterilecek metni döndürür — ham makine çıktısını asla
/// geçirmez, ham metni telemetriye yazar.
String friendlyErrorMessage(
  Object? err, {
  String fallback = kGenericErrorNotice,
  String? surface,
  bool report = true,
}) {
  final raw = rawErrorMessage(err);

  // 1. Sunucunun kendi reddi — metin ne olursa olsun gösterilir.
  if (isServerRejection(err) && raw.trim().isNotEmpty) return raw.trim();

  void bildir() {
    final r = _raporla;
    if (report && r != null) {
      r(err, surface == null ? 'hata-metni' : 'hata-metni:$surface');
    }
  }

  // 2. Geçici sunucu arızası. ⚠ Makine testinden ÖNCE.
  if (isTemporaryServerError(raw)) {
    bildir();
    return kTemporaryErrorNotice;
  }

  // 3. Makine metni — kullanıcıya Türkçe, telemetriye ham.
  if (isMachineMessage(raw)) {
    bildir();
    return fallback;
  }

  // 4. Kendi Türkçe mesajımız.
  return raw.trim();
}
