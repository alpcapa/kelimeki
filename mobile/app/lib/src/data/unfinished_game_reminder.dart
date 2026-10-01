// Yarım kalan oyun hatırlatması — telefonun KENDİSİNE kurulan tek bir yerel
// bildirim (sunucu yok). Kararlar `util/unfinished_reminder.dart`ta; burada
// yalnızca sıra ve platform ucu.
//
// ── NEDEN EKLENTİ DEĞİL, MethodChannel ───────────────────────────────────
// Standart yol `flutter_local_notifications` + `timezone` olurdu. Bize
// gereken TEK şey "şu anda bir bildirim göster" ve "onu iptal et"; o paket
// karşılığında Android'de core library desugaring, kendi başlatma çağrısı,
// bildirim ikonu yapılandırması ve iki bağımlılık getiriyor. Bu depo aynı
// kararı `notification_shade.dart`ta da verdi (aynı gerekçe) ve iki dildeki
// adları bir parite testiyle koruyor: `unfinished_reminder_parity_test.dart`.
//
// ── SINIRLAR (bilinçli) ──────────────────────────────────────────────────
// - Android: `AlarmManager.setAndAllowWhileIdle` — TAM ZAMANLI DEĞİL (Doze
//   birkaç dakika kaydırabilir), karşılığında `SCHEDULE_EXACT_ALARM` izni
//   gerekmiyor. Cihaz YENİDEN BAŞLARSA alarm silinir; geri kurmak için
//   BOOT_COMPLETED alıcısı ve ek izin gerekirdi — tek bir hatırlatma için
//   değmez.
// - iOS: `UNTimeIntervalNotificationTrigger` — yeniden başlatmaya dayanıklı.
// - Web derlemesinde kanal yok: çağrı `MissingPluginException` fırlatır ve
//   yutulur (davranış: hiçbir şey olmaz — doğru davranış).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import '../storage/app_storage.dart';
import '../util/unfinished_reminder.dart';
import 'push_repo.dart';

/// Tek bir yerel bildirimi kuran/iptal eden dikiş. Testte sahtesi verilir.
abstract class HatirlatmaZamanlayici {
  /// Bekleyen hatırlatmayı (varsa) [zaman]a yeniden kurar. FIRLATMAZ.
  Future<void> kur(DateTime zaman, String baslik, String govde);

  /// Bekleyen hatırlatmayı iptal eder (yoksa hiçbir şey yapmaz). FIRLATMAZ.
  Future<void> iptal();
}

/// Gerçek uç — `MainActivity.kt` + `AppDelegate.swift`teki işleyiciler.
class PlatformHatirlatmaZamanlayici implements HatirlatmaZamanlayici {
  /// ⚠ Bu üç ad Kotlin ve Swift tarafıyla BİREBİR aynı olmak zorunda;
  /// uyuşmazlık SESSİZ bir arızadır (çağrı yutulur, bildirim hiç kurulmaz).
  /// `unfinished_reminder_parity_test.dart` üç dosyayı da okuyup karşılaştırır.
  static const kanal = MethodChannel('kelimeki/hatirlatma');
  static const kurMetot = 'yarimOyunKur';
  static const iptalMetot = 'yarimOyunIptal';

  const PlatformHatirlatmaZamanlayici();

  @override
  Future<void> kur(DateTime zaman, String baslik, String govde) async {
    try {
      await kanal.invokeMethod<void>(kurMetot, {
        'zamanMs': zaman.millisecondsSinceEpoch,
        'baslik': baslik,
        'govde': govde,
      });
    } catch (e) {
      debugPrint('[Kelimeki] yarım oyun hatırlatması kurulamadı: $e');
    }
  }

  @override
  Future<void> iptal() async {
    try {
      await kanal.invokeMethod<void>(iptalMetot);
    } catch (e) {
      debugPrint('[Kelimeki] yarım oyun hatırlatması iptal edilemedi: $e');
    }
  }
}

/// Akışın tamamı: ne zaman kurulur, ne zaman iptal edilir, ne zaman
/// "teslim edildi" sayılır. Hiçbir metodu fırlatmaz — çağrı yerleri ekran
/// geçişleri ve yaşam döngüsü kancaları.
class YarimOyunHatirlatici {
  final Future<AppStorage> storage;
  final HatirlatmaZamanlayici zamanlayici;

  /// Sistem izni buradan okunur — push ile AYNI izin (Android
  /// POST_NOTIFICATIONS / iOS UNAuthorization). null ise izin yok sayılır.
  final PushMessaging? messaging;

  final DateTime Function() _saat;

  YarimOyunHatirlatici({
    required this.storage,
    required this.zamanlayici,
    required this.messaging,
    DateTime Function()? saat,
  }) : _saat = saat ?? DateTime.now;

  Future<bool> _izinVar() async {
    final m = messaging;
    if (m == null) return false;
    try {
      return await m.permission() == PushPermission.granted;
    } catch (_) {
      return false;
    }
  }

  /// Oyun ekranından ayrılırken (çıkış ya da uygulamanın arka plana gitmesi).
  Future<void> oyundanAyrildi(GameState s) async {
    try {
      final flags = (await storage).flags;
      final kurulmali = yarimOyunHatirlatmasiKurulmali(
        oyunSuruyor: s.phase == GamePhase.play && !s.isGameOver,
        turSayisi: s.turnCount,
        oyunKimligi: s.startedAt,
        hatirlatilanOyun: flags.yarimOyunHatirlatilan,
        izinVar: await _izinVar(),
      );
      if (!kurulmali) return;
      final zaman = yarimOyunHatirlatmaZamani(_saat());
      await zamanlayici.kur(zaman, kYarimOyunBaslik, kYarimOyunGovde);
      await flags.yarimOyunKuruldu(s.startedAt, zaman);
    } catch (e) {
      debugPrint('[Kelimeki] yarım oyun hatırlatma akışı hatası: $e');
    }
  }

  /// Oyun BİTTİ — yarım kalan bir şey yok, bekleyen hatırlatma düşer.
  Future<void> oyunBitti() async {
    try {
      final flags = (await storage).flags;
      if (flags.yarimOyunKurulanOyun == null) return;
      await zamanlayici.iptal();
      await flags.yarimOyunKurulanTemizle();
    } catch (e) {
      debugPrint('[Kelimeki] yarım oyun hatırlatma akışı hatası: $e');
    }
  }

  /// Uygulama açıldı ya da öne geldi — kullanıcı döndü, bekleyen hatırlatma
  /// düşer. Zamanı geçmişse bildirim teslim edilmiştir: o oyun bir daha
  /// hatırlatılmaz.
  Future<void> uygulamaAcildi() async {
    try {
      final flags = (await storage).flags;
      final oyun = flags.yarimOyunKurulanOyun;
      if (oyun == null) return;
      if (yarimOyunHatirlatmasiTeslimEdildi(
        kurulanZaman: flags.yarimOyunKurulanZaman,
        simdi: _saat(),
      )) {
        await flags.yarimOyunHatirlatildi(oyun);
      }
      await zamanlayici.iptal();
      await flags.yarimOyunKurulanTemizle();
    } catch (e) {
      debugPrint('[Kelimeki] yarım oyun hatırlatma akışı hatası: $e');
    }
  }
}
