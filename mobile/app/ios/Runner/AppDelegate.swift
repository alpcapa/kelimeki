import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    kurBildirimKanali(engineBridge.pluginRegistry)
    kurHatirlatmaKanali(engineBridge.pluginRegistry)
  }

  /// Bildirim panelini temizleyen kanal — `MainActivity.kt`teki Kotlin
  /// işleyicisinin iOS ikizi (ROADMAP #15 · FAZ C 24.3).
  ///
  /// **NEDEN BURADA:** `data/notification_shade.dart` bu ucu 31 Ağustos
  /// 2026'dan beri bekliyordu ve ne yapılacağını yazılı bırakmıştı —
  /// *"APNs günü geldiğinde `AppDelegate.swift`e aynı kanal adıyla bir
  /// işleyici eklemek yeterli; Dart tarafı DEĞİŞMEZ."* Bu fonksiyon tam
  /// olarak o. Dart'ta tek satır değişmedi.
  ///
  /// ⚠ **Kanal adı ve metot adı Dart tarafıyla BİREBİR aynı olmak zorunda.**
  /// Derleyici bunu göremez ve uyuşmazlık SESSİZ bir arızadır: Dart
  /// `MissingPluginException`ı BİLEREK yutuyor, yani yanlış bir ad hiçbir
  /// hata göstermez — yalnızca panel temizlenmez ve kimse fark etmez.
  /// `notification_shade_parity_test.dart` bu yüzden hem Kotlin'i hem bu
  /// dosyayı okuyup karşılaştırıyor.
  ///
  /// ⚠ **ROZET BİLEREK SIFIRLANMIYOR.** Android'de rozet panelde duran
  /// bildirimlerden türüyor, bu yüzden orada `cancelAll()` rozeti de
  /// düşürüyor. iOS'ta rozet `aps.badge`den geliyor ve sunucu onu HİÇ
  /// göndermiyor (`_shared/push.ts`) — yani sıfırlanacak bir rozet yok.
  /// Sunucu bir gün `badge` göndermeye başlarsa buraya `setBadgeCount(0)`
  /// eklenir; o değişiklik `verify-push-payload` ile birlikte gelmeli.
  private func kurBildirimKanali(_ registry: FlutterPluginRegistry) {
    // `registrar(forPlugin:)` uzun ömürlü ve kararlı bir API; messenger'ı
    // `window?.rootViewController` üzerinden almak bu projede ÇALIŞMAZDI —
    // uygulama SceneDelegate kullanıyor (`UIApplicationSceneManifest`,
    // `Info.plist`), yani `didFinishLaunchingWithOptions` anında `window`
    // henüz kurulmuş olmayabilir.
    guard let registrar = registry.registrar(forPlugin: "KelimekiBildirimler") else { return }

    let kanal = FlutterMethodChannel(
      name: "kelimeki/bildirimler",
      binaryMessenger: registrar.messenger()
    )

    kanal.setMethodCallHandler { cagri, sonuc in
      switch cagri.method {
      case "hepsiniTemizle":
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        sonuc(nil)
      default:
        sonuc(FlutterMethodNotImplemented)
      }
    }
  }

  /// Yarım kalan oyun hatırlatması (1 Ekim 2026) — `MainActivity.kt`teki
  /// `kelimeki/hatirlatma` işleyicisinin iOS ikizi. Dart ucu:
  /// `data/unfinished_game_reminder.dart`. ⚠ Kanal/metot adları
  /// `unfinished_reminder_parity_test.dart` ile kilitli.
  ///
  /// Android'den farkı: `UNTimeIntervalNotificationTrigger` yeniden
  /// başlatmaya dayanıklı; izin yoksa iOS isteği sessizce düşürür.
  private static let yarimOyunKimligi = "kelimeki.yarimOyun"

  private func kurHatirlatmaKanali(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "KelimekiHatirlatma") else { return }

    let kanal = FlutterMethodChannel(
      name: "kelimeki/hatirlatma",
      binaryMessenger: registrar.messenger()
    )

    kanal.setMethodCallHandler { cagri, sonuc in
      let merkez = UNUserNotificationCenter.current()
      switch cagri.method {
      case "yarimOyunKur":
        guard let arg = cagri.arguments as? [String: Any],
              let zamanMs = (arg["zamanMs"] as? NSNumber)?.doubleValue,
              let baslik = arg["baslik"] as? String,
              let govde = arg["govde"] as? String
        else {
          sonuc(FlutterError(code: "arguman", message: "zamanMs/baslik/govde eksik", details: nil))
          return
        }
        let icerik = UNMutableNotificationContent()
        icerik.title = baslik
        icerik.body = govde
        icerik.sound = .default
        let saniye = max(1, zamanMs / 1000 - Date().timeIntervalSince1970)
        let tetik = UNTimeIntervalNotificationTrigger(timeInterval: saniye, repeats: false)
        // Aynı kimlik → bekleyen istek YENİSİYLE değişir (en fazla bir tane).
        let istek = UNNotificationRequest(
          identifier: AppDelegate.yarimOyunKimligi, content: icerik, trigger: tetik)
        merkez.add(istek) { _ in }
        sonuc(nil)
      case "yarimOyunIptal":
        merkez.removePendingNotificationRequests(withIdentifiers: [AppDelegate.yarimOyunKimligi])
        sonuc(nil)
      default:
        sonuc(FlutterMethodNotImplemented)
      }
    }
  }
}
