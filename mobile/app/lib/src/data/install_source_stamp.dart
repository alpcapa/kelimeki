// Kelimeki app — kurulum kaynağını cihaz damgasına yazar (#46-1, 13 Ekim 2026).
//
// Play Install Referrer'daki `utm_source` (`channelFromInstallReferrer`)
// `FlagsStore.captureUtmSource` ile first-touch yazılır; `DeviceStamp.source`
// değişmez, yalnızca değeri dolar → `game_starts`, `game_finishes`,
// `guest_visits` ve kayıt damgası (`signup_utm_source`) aynı kanalı taşır.
// Karar kaydı: `docs/decisions/funnel-v2.md` → "#46-1 tasarım notu".
//
// Kullanıcı kararları (13 Ekim 2026):
// - YARIŞ: açılışta başlatılır, BEKLENMEZ. Okuma bitmeden oyun/kayıt olursa o
//   satır `app` kalır (yeni kurulumda ilk oyundan önce 60 sn'lik tanıtım var).
// - ESKİ CİHAZLAR: damga için bir kez okunur. `funnel_events.land`
//   kanalına DOKUNULMAZ (orası `hadPriorTrace` → `mevcut` kalır); bu yüzden
//   ayrı bayrak (`installSourceStamped`).
//
// ⚠ iOS'ta karşılığı yok (Apple kişi bazında kanal vermiyor): çağıran
// Android dışında çağırmaz, burada da platform süzülür.
import 'package:flutter/foundation.dart';

import '../storage/flags_store.dart';
import 'funnel_api.dart';
import '../util/platform.dart';

/// Tek deneme: başarıyla okunduysa (etiket çıksa da çıkmasa da) bayrak
/// yazılır; okuma düşerse (Play Hizmetleri yok, zaman aşımı, sideload)
/// bayrak YAZILMAZ, sonraki açılış yeniden dener. Asla fırlatmaz.
/// Dönüş: yazılan etiket (testler için).
Future<String?> stampInstallSource({
  required FlagsStore flags,
  required Future<String?> Function() readInstallReferrer,
  String? platform,
}) async {
  if (funnelPlatformFor(platform ?? currentPlatform) != 'android') return null;
  if (flags.installSourceStamped) return null;
  try {
    final channel = channelFromInstallReferrer(await readInstallReferrer());
    if (channel != null) await flags.captureUtmSource(channel);
    await flags.setInstallSourceStamped();
    return channel;
  } catch (e) {
    debugPrint('[Kelimeki] Kurulum kaynağı okunamadı: $e');
    return null;
  }
}
