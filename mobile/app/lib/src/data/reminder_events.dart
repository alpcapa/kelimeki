// Kelimeki app — yarım kalan oyun hatırlatmasının anonim sayacı
// (`reminder_events`), 11 Ekim 2026.
//
// NEDEN: hatırlatma 1.1.2'den beri uygulamada ama cihazda gelmediği görüldü ve
// asıl sebep tasarımdı — izin kartı yalnızca logoyla çıkışta çıkıyor, yeni
// gelenlerin çoğu oyunu telefonu bırakarak yarım bırakıyor, yani izin HİÇ
// sorulmuyor. Kullanıcı: *"Kimse kabul etmez bence. Ama kart gösterildi /
// kabul edildi / reddedildi olaylarını koymak lazım."* Bu akışta bugüne kadar
// HİÇBİR sayı yoktu.
//
// ⚠ KİMLİK YOK, BİLEREK: ne `anon_id` ne `user_id` (`signup_events.dart` ile
// aynı karar). Gizlilik metni anonim kodun sunucuya gittiği durumları SAYIYOR;
// kimliksiz bir sayaç yeni bir durum açmaz, yani web+port hukuki metni
// DEĞİŞMEZ. Bedeli: oranlar okunur, "kaç farklı kişi" okunmaz.
//
// DESEN `signupEvents`in AYNISI (global tek örnek + `configure`): olay yerleri
// iki dosyada (`push_permission_flow.dart`, `unfinished_game_reminder.dart`),
// her birine repo parametresi açmak yerine bootstrap bir kez bağlıyor.
//   1. FIRE-AND-FORGET — asla fırlatmaz; oyundan çıkan biri bizim sayacımız
//      yüzünden hata ya da gecikme görmemeli.
//   2. YAPILANDIRILMAMIŞSA SESSİZ NO-OP — testler ve Supabase'siz açılış.
//
// ⚠ Olay/kart adları migration'daki check'lerle ELLE senkron:
// `supabase/migrations/20261011155133_reminder_events.sql`;
// `test/reminder_events_parity_test.dart` ikisini karşılaştırır.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../util/platform.dart';

/// Kart onayı akışı: gösterildi → onaylandı | ertelendi → (yalnız `izin`
/// kartında) sistem diyaloğunun sonucu.
const kReminderCardShown = 'card_shown';
const kReminderCardAccept = 'card_accept';
const kReminderCardDecline = 'card_decline';
const kReminderOsGranted = 'os_granted';
const kReminderOsDenied = 'os_denied';

/// Hatırlatma gerçekten kuruldu / uygun bir ayrılıştı ama izin yoktu.
const kReminderSet = 'set';
const kReminderSkipNoPermission = 'skip_no_permission';

/// Sunucu kısıtıyla ELLE senkron (`reminder_events.event` check'i) — SIRA da.
const List<String> kReminderEvents = [
  kReminderCardShown,
  kReminderCardAccept,
  kReminderCardDecline,
  kReminderOsGranted,
  kReminderOsDenied,
  kReminderSet,
  kReminderSkipNoPermission,
];

/// Hangi kart: "Hatırlatalım mı?" ya da "Bildirimler kapalı".
const kReminderCardIzin = 'izin';
const kReminderCardAyar = 'ayar';

/// `reminder_events.card` check'iyle ELLE senkron.
const List<String> kReminderCards = [kReminderCardIzin, kReminderCardAyar];

abstract class ReminderEventsSink {
  Future<void> insert(Map<String, Object?> row);
}

class SupabaseReminderEventsSink implements ReminderEventsSink {
  final SupabaseClient client;
  SupabaseReminderEventsSink(this.client);

  @override
  Future<void> insert(Map<String, Object?> row) async {
    await client.from('reminder_events').insert(row);
  }
}

/// Tek örnek — `bootstrap()` yapılandırır, akışlar doğrudan kullanır.
final ReminderEvents reminderEvents = ReminderEvents();

/// Olay yazıcısının imzası — akışlara parametre olarak da verilebilsin diye
/// (testlerde sahtesi).
typedef ReminderEventLogger = void Function(String event, {String? card});

class ReminderEvents {
  ReminderEventsSink? _sink;

  void configure(ReminderEventsSink? sink) => _sink = sink;

  @visibleForTesting
  void reset() => _sink = null;

  /// `reminder_events` satırı — ayrı ve saf, çünkü "kimlik YOK" bu işin tek
  /// gizlilik davranışı ve Supabase istemcisi olmadan sınanabilmeli.
  @visibleForTesting
  static Map<String, Object?> row(String event, String? card) => {
        'event': event,
        'card': kReminderCards.contains(card) ? card : null,
        'platform': currentPlatform,
        'app_version': appVersion,
      };

  /// Fire-and-forget: beklenmez, fırlatmaz. Bilinmeyen bir olay adı sunucuda
  /// check'e takılırdı — hiç gönderilmez.
  void log(String event, {String? card}) {
    final sink = _sink;
    if (sink == null) return;
    if (!kReminderEvents.contains(event)) return;
    try {
      sink.insert(row(event, card)).catchError((Object e) {
        debugPrint('[Kelimeki] reminder_events hatası: $e');
      });
    } catch (e) {
      debugPrint('[Kelimeki] reminder_events hatası: $e');
    }
  }
}
