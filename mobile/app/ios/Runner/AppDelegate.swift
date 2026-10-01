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
  /// **ROZET DE BURADA SIFIRLANIR (ROADMAP #25, 1.1.2).** Android'de rozet
  /// panelde duran bildirimlerden türüyor, `cancelAll()` onu kendiliğinden
  /// düşürüyor. iOS'ta ise rozet `aps.badge`den gelen MUTLAK bir sayı —
  /// sunucu 1.1.2'den itibaren gönderiyor (`_shared/push.ts` →
  /// `ROZET_ILK_SURUM`) ve sıfırlanmazsa simgede asılı kalır. Sunucudaki
  /// sayaç aynı anda `register_push_token`da sıfırlanıyor (Dart her
  /// açılışta/öne dönüşte ikisini birlikte çağırıyor).
  /// ⚠ `ROZET_ILK_SURUM` bu satırı taşıyan İLK sürüm olmak zorunda — daha
  /// eski bir sürüme rozet gönderilirse sayı simgede takılı kalır.
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
        if #available(iOS 16.0, *) {
          UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
          UIApplication.shared.applicationIconBadgeNumber = 0
        }
        sonuc(nil)
      default:
        sonuc(FlutterMethodNotImplemented)
      }
    }
  }
}
