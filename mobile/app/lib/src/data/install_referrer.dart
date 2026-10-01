// Kelimeki app — Play Install Referrer okuması (Android, 30 Eylül 2026).
//
// Huni v2'nin `land` kanalına yazılır (`funnel_api.dart` →
// `channelFromInstallReferrer`). Web mağaza rozeti ziyaretçinin `?ref=`
// etiketini Play linkine `referrer=utm_source%3D<etiket>` olarak ekliyor
// (`src/utils/storeLinks.ts` → `taggedStoreUrl`); Play bunu kurulumdan sonra
// bu API ile uygulamaya geri veriyor. iOS'ta karşılığı YOK.
//
// ⚠ Çağıran yalnızca Android'de çağırır (`FunnelRepo.create`); öteki
// platformlarda MethodChannel `MissingPluginException` fırlatırdı.
import 'package:play_install_referrer/play_install_referrer.dart';

/// Ham referrer dizesi; Play Hizmetleri yanıt vermezse zaman aşımıyla düşer.
Future<String?> readPlayInstallReferrer() async {
  final details = await PlayInstallReferrer.installReferrer
      .timeout(const Duration(seconds: 5));
  return details.installReferrer;
}
