// Yarım kalan oyun hatırlatmasının SAF kararları — Flutter/eklenti
// bağımlılığı YOK (push_rules.dart ile aynı gerekçe: karar bir widget'a
// gömülürse test edilemez).
//
// **NEDEN VAR (1 Ekim 2026, kullanıcı kararı):** Meta kampanyasının kalite
// okumasında (marketing/meta-reklam/kampanya-ekim-2026.md → 1 Eki ~01:00)
// huninin üstü ucuz çıktı ama ertesi gün oyuna dönen yeni cihaz ~%11'de
// kaldı. Mevcut tek hatırlatma (`notify-deadline-warnings`) YALNIZCA üyeye ve
// 7 günlük terk süresinin SON gününde gidiyor; misafirin oyunu yalnızca
// cihazda durduğundan sunucu onu hiç bilmiyor. Bu hatırlatma telefonun
// KENDİSİNE kurulur (sunucu yok), yani misafire de ulaşır.
//
// Kurallar (docs/decisions/product-backlog.md → "Ertelenenler" #1):
//   - Oyun yarım bırakılınca TEK bir yerel bildirim kurulur.
//   - Uygulama o arada açılırsa iptal edilir.
//   - Aynı yarım oyun için en fazla BİR kez TESLİM edilir.
//   - Web karşılığı YOK (tarayıcı kapalıyken zamanlanmış bildirim yok).
library;

/// Hatırlatmanın saati (yerel saat). Akşam: günün oyun oynanan dilimi.
const int kYarimOyunHatirlatmaSaati = 19;

/// Ayrılış ile hatırlatma arasındaki en kısa süre. 19:00'dan hemen önce
/// ayrılan birine aynı akşam bildirim gitmesin — "yarın" hissi korunur.
const Duration kYarimOyunEnKisaBekleme = Duration(hours: 12);

/// Bildirim metni — iki platform da BURADAN alır (Kotlin/Swift metin taşımaz).
const String kYarimOyunBaslik = 'Oyunun yarım kaldı';
const String kYarimOyunGovde =
    'Sıra sende — kaldığın yerden devam etmek için dokun.';

/// Hatırlatmanın kurulacağı an: [ayrilis]tan en az
/// [kYarimOyunEnKisaBekleme] sonraki İLK 19:00 (yerel saat).
///
/// Örnekler: 10:00'da ayrılan → ertesi gün 19:00 (aynı gün 19:00 yalnızca
/// 9 saat sonra); 20:00'de ayrılan → ertesi gün 19:00; 03:00'te ayrılan →
/// aynı gün 19:00 (16 saat sonra).
DateTime yarimOyunHatirlatmaZamani(DateTime ayrilis) {
  final enErken = ayrilis.add(kYarimOyunEnKisaBekleme);
  var aday = DateTime(
      enErken.year, enErken.month, enErken.day, kYarimOyunHatirlatmaSaati);
  if (aday.isBefore(enErken)) {
    // `DateTime(y, m, d + 1, …)` ay/yıl taşmasını kendisi çözer; `add(1 gün)`
    // yaz saati geçişinde saati kaydırırdı.
    aday = DateTime(enErken.year, enErken.month, enErken.day + 1,
        kYarimOyunHatirlatmaSaati);
  }
  return aday;
}

/// Ekrandan ayrılırken hatırlatma kurulmalı mı.
///
/// [oyunSuruyor] — oyun `play` fazında ve bitmemiş.
/// [turSayisi] — `turnCount`. `< 2` ise oyun "Devam Eden Oyun" olarak hiç
///   kaydedilmiyor (`local_game_repo.dart` eşiği) — hatırlatılacak bir şey yok.
/// [oyunKimligi] — oyunun kalıcı kimliği (`startedAt`); boşsa karar
///   verilemez (hiç başlamamış state).
/// [hatirlatilanOyun] — hatırlatması TESLİM edilmiş son oyun. Aynı oyun bir
///   daha hatırlatılmaz.
/// [izinVar] — sistem bildirim izni. Yoksa kurmak boşa (bildirim düşmez).
bool yarimOyunHatirlatmasiKurulmali({
  required bool oyunSuruyor,
  required int turSayisi,
  required String oyunKimligi,
  required String? hatirlatilanOyun,
  required bool izinVar,
}) {
  if (!oyunSuruyor) return false;
  if (turSayisi < 2) return false;
  if (oyunKimligi.isEmpty) return false;
  if (oyunKimligi == hatirlatilanOyun) return false;
  return izinVar;
}

/// Kurulmuş bir hatırlatma, uygulama öne geldiğinde TESLİM edilmiş sayılır
/// mı — zamanı geçmişse evet (bildirim panele düştü).
///
/// ⚠ Yaklaşık bir sinyal: kullanıcı bildirimleri sistemden kapatmışsa ya da
/// cihaz o arada yeniden başladıysa (Android alarmı yeniden başlatmada
/// silinir) bildirim görünmemiş olabilir. Bedeli küçük ve güvenli yönde:
/// o oyun bir daha hatırlatılmaz.
bool yarimOyunHatirlatmasiTeslimEdildi({
  required DateTime? kurulanZaman,
  required DateTime simdi,
}) =>
    kurulanZaman != null && !simdi.isBefore(kurulanZaman);
