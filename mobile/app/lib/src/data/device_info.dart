// Kelimeki app — cihazın işletim sistemi sürümü + modeli (`device_visits`).
//
// NEDEN VAR (27 Eylül 2026, ROADMAP #40, kullanıcı kararı: *"cihaz
// kartlarını 2 haftalık sürüme alalım"*): admin panelinin "Cihaz" ve
// "Cihaz Markası" kartları `device_visits`ten besleniyor ve port o tabloya
// HİÇ yazmıyordu — kartlar yalnızca web'i görüyordu (başlıkta "Web" etiketi).
//
// ⚠ SÖZ DAĞARCIĞI WEB'İNKİYLE AYNI (`visitTracking.ts` → `getOsVersion` /
// `getDeviceModel`), yoksa panel aynı cihazı iki satıra böler:
// - iOS modeli `iPhone`/`iPad` GENEL KATEGORİSİ. Safari gerçek modeli hiç
//   vermediğinden web satırları hep böyle; port `iPhone15,2` yazsaydı
//   "Cihaz Markası"nda iOS web ile iOS uygulaması ayrı satırlara düşerdi.
// - Android modeli üreticinin model kodu (`SM-G991B`) — web'in UA'dan
//   yakaladığı değerin aynısı; 60 karakterle kırpılır.
// - Sürüm `18.1` / `14` biçiminde (web `OS 18_1` → `18.1`).
//
// ⚠ GİZLİLİK METNİ ZATEN KAPSIYOR: Gizlilik 6. bölüm (1) "HER ziyarette …
// işletim sistemi tipiyle … ve elde edilebiliyorsa işletim sistemi
// sürümü/cihaz modeliyle birlikte". Anonim koddan başka kimlik YOK.
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// iOS makine kodundan (`utsname.machine`, ör. `iPad13,4`) web'in genel
/// kategorisi. Simülatörde makine kodu `arm64`/`x86_64` — o durumda
/// `model` alanına (`iPhone`/`iPad`) bakılır.
@visibleForTesting
String? iosModelCategory({required String? machine, required String? model}) {
  for (final s in [machine, model]) {
    if (s == null) continue;
    if (s.startsWith('iPad')) return 'iPad';
    if (s.startsWith('iPhone')) return 'iPhone';
    if (s.startsWith('iPod')) return 'iPod';
  }
  return null;
}

/// Android model kodu — web `getDeviceModel`in kırpmasıyla aynı.
@visibleForTesting
String? androidModel(String? model) {
  final m = model?.trim();
  if (m == null || m.isEmpty) return null;
  return m.length > 60 ? m.substring(0, 60) : m;
}

/// Boş dizeyi `null`a çeker (sütun nullable; "" yazmak panelde ayrı kova açardı).
@visibleForTesting
String? osVersionOrNull(String? v) {
  final s = v?.trim();
  return s == null || s.isEmpty ? null : s;
}

typedef DeviceDetails = ({String? osVersion, String? model});

/// Cihaz bilgisini okur. Fırlatmaz — okunamayan alan `null`.
Future<DeviceDetails> readDeviceDetails({String? platform}) async {
  try {
    final info = DeviceInfoPlugin();
    switch (platform) {
      case 'ios':
        final i = await info.iosInfo;
        return (
          osVersion: osVersionOrNull(i.systemVersion),
          model: iosModelCategory(machine: i.utsname.machine, model: i.model),
        );
      case 'android':
        final a = await info.androidInfo;
        return (
          osVersion: osVersionOrNull(a.version.release),
          model: androidModel(a.model),
        );
    }
  } catch (e) {
    debugPrint('[Kelimeki] cihaz bilgisi okunamadı: $e');
  }
  return (osVersion: null, model: null);
}
