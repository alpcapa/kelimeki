// Kelimeki app — misafir ziyaret sayacı (`guest_visits`). Web
// `logGuestVisit` (`src/lib/api.ts`) + `visitTracking.ts` paritesi.
//
// NEDEN VAR: admin panelinin Kaynak Hunisi'nin İLK adımı ("Gelen") bu
// tablodan besleniyor ve port hiç yazmıyordu — yani app'ten gelen hiç kimse
// huninin girişinde görünmüyordu. Gerekçenin tamamı `device_stamp.dart`ın
// başlığında.
//
// ÜÇ DEĞİŞMEZ (web'den birebir):
//   1. YALNIZCA OTURUM KAPALIYKEN. Sunucu da bunu zorluyor
//      (`guest_visits_insert_anon` RLS politikası yalnızca `anon` rolüne
//      insert veriyor), yani girişliyken çağırmak sessiz bir hata olurdu.
//      Huni bilinçli olarak misafir-only (`source_funnel_guest_only`
//      migration'ı) — bu kural onun parçası, bir eksiklik değil.
//   2. GÜNDE BİR KEZ (yerel tarih). Damga `FlagsStore.anonVisitDate`'te;
//      web'in `kelimeki:anon-visit-date` anahtarının karşılığı.
//   3. FIRE-AND-FORGET. Hata yutulur, açılışı ASLA geciktirmez/düşürmez
//      (`Analytics`in ve `logGameStart`ın aynı duruşu).
//
// ⚠ `is_standalone` BİLEREK YAZILMIYOR (null). O kolon web'in "ana ekrana
// eklenmiş mi" (PWA) sorusunu ölçüyor ve panelde AYRI bir döküme besleniyor;
// native uygulama için `true` yazmak o tabloyu şişirirdi — app zaten bir
// tarayıcı sekmesi değil, sorunun DIŞINDA. Native satırları o dökümden
// sunucu tarafında eleniyor (bkz. `admin_guest_device_breakdown`
// migration'ı, 22 Eylül 2026).
//
// ⚠ `os_version`/`device_model` de null: portta `device_info_plus` YOK ve
// bir telemetri alanı için yeni bir native bağımlılık eklemek bu işin
// kapsamı değil. Kolonlar nullable, web'de de sık sık null geliyor.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util/platform.dart';
import 'device_stamp.dart';

/// Gerçek uç ya da testin sahtesi (`GamesGateway` deseninin aynısı).
abstract class VisitsGateway {
  /// Oturum açık mı — ağa ÇIKMAZ (yerel oturum deposu).
  bool get signedIn;

  /// `guest_visits`e bir satır ekler.
  Future<void> insertGuestVisit({
    required String anonId,
    required String? utmSource,
    required String? deviceType,
  });
}

class SupabaseVisitsGateway implements VisitsGateway {
  final SupabaseClient client;
  SupabaseVisitsGateway(this.client);

  @override
  bool get signedIn => client.auth.currentUser != null;

  @override
  Future<void> insertGuestVisit({
    required String anonId,
    required String? utmSource,
    required String? deviceType,
  }) async {
    await client.from('guest_visits').insert({
      'anon_id': anonId,
      'utm_source': utmSource,
      'device_type': deviceType,
      // Yukarıdaki başlıktaki iki karar: PWA sorusu ve native bağımlılık.
      'is_standalone': null,
      'os_version': null,
      'device_model': null,
    });
  }
}

/// `guest_visits.device_type` — web'in `getDeviceType()` SÖZ DAĞARCIĞIYLA
/// aynı olmak zorunda (`ios` | `android` | `desktop`), yoksa panelin "Cihaz"
/// dökümü aynı cihazı iki satıra böler.
///
/// ⚠ `currentPlatform` bunu TEK BAŞINA veremez: o `app-web` de dönebiliyor
/// (portun tarayıcıda çalışan test hâli) ve `guest_visits` böyle bir değer
/// tanımıyor. Bilinmeyen hedef `desktop`a düşüyor — web'in kendi
/// `getDeviceType()` varsayılanının aynısı.
@visibleForTesting
String deviceTypeForVisit(String? platform) {
  switch (platform) {
    case 'ios':
      return 'ios';
    case 'android':
      return 'android';
    default:
      return 'desktop';
  }
}

class VisitsRepo {
  final VisitsGateway gateway;
  final Future<DeviceStamp> stamp;

  /// Yerel "bugün" — testler sabitliyor.
  final String Function() today;

  VisitsRepo(this.gateway, this.stamp, {String Function()? today})
      : today = today ?? _bugun;

  static String _bugun() => DateTime.now().toIso8601String().substring(0, 10);

  /// Açılış pingi. Üç değişmez (başlıkta) burada uygulanıyor; çağıran
  /// koşul YAZMAZ — tek karar yeri burası olsun diye.
  ///
  /// Dönüş yalnızca testler için: satır GERÇEKTEN yazıldı mı.
  Future<bool> pingGuestVisit() async {
    try {
      // 1. Girişliyse hiç deneme: RLS reddederdi ve huni misafir-only.
      if (gateway.signedIn) return false;
      final s = await stamp;
      // 2. Günde bir kez.
      final gun = today();
      if (s.flags.anonVisitDate == gun) return false;
      await gateway.insertGuestVisit(
        anonId: await s.anonId(),
        utmSource: s.source,
        deviceType: deviceTypeForVisit(currentPlatform),
      );
      // Damga YAZMADAN SONRA: insert düşerse yarın tekrar denenir. (Tersi
      // olsaydı düşen bir istek o günü sessizce yakardı.)
      await s.flags.setAnonVisitDate(gun);
      return true;
    } catch (e) {
      // 3. Fire-and-forget.
      debugPrint('[Kelimeki] guest_visits pingi düştü: $e');
      return false;
    }
  }
}
