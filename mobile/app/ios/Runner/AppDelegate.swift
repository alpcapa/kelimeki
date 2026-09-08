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
}
