// Kelimeki app — Ölçüm v2 (Huni v2) mobil yarısı: `funnel_events`.
//
// Web yarısı: `src/utils/funnelEvents.ts` (PR 1, 24 Eylül 2026). Plan ve
// kararlar: `docs/decisions/funnel-v2.md` → "PR 2". 27 Eylül 2026'da 5 Ekim
// trenine alındı (kullanıcı: *"Huni v2 5 Ekim'de var mı? Yoksa dahil
// edelim"*). Admin → Büyüme → Kullanıcı → "Huni v2" bir KOHORT tablosu:
// pencerede İLK KEZ gelen (`land`) cihazların kaçı başka bir gün döndü
// (`visit`), üye oldu (`signup`), YZ oyunu başlattı/bitirdi.
//
// ⚠ GİZLİLİK METNİ ZATEN KAPSIYOR — Gizlilik 6. bölüm (1) her ziyaret,
// (2) YZ oyunu başlangıcı, (4) misafir bitişi, (6) hesap açılışı, (7) girişli
// bitiş; platform-nötr yazılmış ("web/iOS/Android") ve port kopyası
// (`legal_modals.dart`) 1.1.1'den beri aynı metni taşıyor. Hesap kimliği
// ASLA gönderilmez, saat tutulmaz (gün sunucuda hesaplanıyor).
//
// ⚠ KANAL: yeni cihazın kanalı sırayla (1) Android'de **Play Install
// Referrer**'daki `utm_source` (30 Eylül 2026, kullanıcı kararı: *"Referrer'ı
// 5 Ekim trenine ekle"* — paralı kanallar uygulama içinde de görünsün; web
// mağaza rozeti `?ref=` etiketini `referrer=utm_source%3D<etiket>` olarak
// Play'e taşıyor, `taggedStoreUrl`), (2) `DeviceStamp.source` — deep link'ten
// yakalanmış bir `?ref=` varsa o, yoksa `app` (panelde "Mobil Uygulama",
// `sourceChannel('app')`). 27 Eylül'deki ilk karar *"önce kanalsız"*dı.
// ⚠ Referrer YALNIZCA bu tabloya yazılır, `DeviceStamp`e (öteki üç tablo)
// BİLEREK değil — o damga kayıt/oyun satırlarını da değiştirirdi, kapsam
// dışı. iOS'ta Apple kişi bazında kanal vermiyor → `app`.
// Plandaki `app-store`/`play-organik` BİLEREK kullanılmadı: panel onları
// "Diğer"e atardı, platform ayrımı zaten `platform` sütununda. Eski cihaz
// (ölçüm v2'den önce iz bırakmış) `mevcut` — referrer'dan ÖNCE gelir.
//
// ⚠ Olay/platform adları web kaynağından OKUNARAK kilitli:
// `test/funnel_events_parity_test.dart` (`web-ci.yml` `parite` işi).
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage/flags_store.dart';
import 'device_stamp.dart';
import '../util/platform.dart';

/// Web `FUNNEL_EVENTS` ↔ SQL `v_events` — sıra dahil birebir.
const List<String> kFunnelEvents = [
  'land',
  'visit',
  'signup',
  'game_start',
  'game_finish',
];

/// Web `FUNNEL_PLATFORMS` ↔ SQL `v_platforms`. Port yalnızca iki mobili yazar;
/// `app-web` (portun tarayıcı hâli) sunucuda reddedilirdi, hiç gönderilmez.
const List<String> kFunnelPlatforms = ['web', 'ios', 'android'];

/// Web `FUNNEL_EXISTING_CHANNEL` — rapor bu kanalı kohorta KATMAZ.
const String kFunnelExistingChannel = 'mevcut';

/// Web `FUNNEL_MEMBER_EVENTS_ENABLED` — metin (6)/(7) 24 Eylül'den beri var.
const bool kFunnelMemberEventsEnabled = true;

/// Bu istemcinin huni platformu; iOS/Android dışında `null` (yazılmaz).
String? funnelPlatformFor(String? platform) =>
    platform == 'ios' || platform == 'android' ? platform : null;

/// `land` kanalı (web `decideLandChannel`). [source]: `DeviceStamp.source`;
/// [referrerChannel]: `channelFromInstallReferrer` (Android, yoksa `null`).
String decideAppLandChannel({
  required bool hadPriorTrace,
  required String source,
  String? referrerChannel,
}) =>
    hadPriorTrace ? kFunnelExistingChannel : (referrerChannel ?? source);

/// Web `taggedStoreUrl`in (`src/utils/storeLinks.ts`) mağazaya taşıdığı
/// etiket kalıbı — web'den OKUNARAK kilitli (`funnel_events_parity_test`).
final RegExp kInstallReferrerSourcePattern =
    RegExp(r'^[a-z0-9][a-z0-9._-]{0,39}$');

/// Play Install Referrer dizesinden (`utm_source=meta-reel&utm_medium=web`)
/// kanal etiketi. Organik kurulum (`utm_source=google-play&utm_medium=organic`),
/// boş/bozuk dize ya da kalıba uymayan etiket → `null` (kanal `app` kalır).
String? channelFromInstallReferrer(String? referrer) {
  if (referrer == null || referrer.trim().isEmpty) return null;
  final Map<String, String> q;
  try {
    q = Uri.splitQueryString(referrer.trim());
  } catch (_) {
    // Bozuk yüzde kodlaması `ArgumentError` fırlatır (FormatException DEĞİL).
    return null;
  }
  final source = q['utm_source'];
  if (source == null || !kInstallReferrerSourcePattern.hasMatch(source)) {
    return null;
  }
  if (source == 'google-play' || q['utm_medium'] == 'organic') return null;
  return source;
}

/// Europe/Istanbul günü (YYYY-AA-GG) — web `istanbulDay` ile aynı: Türkiye
/// 2016'dan beri sabit UTC+3. Yerel tarih KULLANILMAZ: 00:00-03:00 UTC arası
/// açılış bir önceki günün damgasına takılıp kaybolurdu.
String istanbulDay(DateTime now) => now
    .toUtc()
    .add(const Duration(hours: 3))
    .toIso8601String()
    .substring(0, 10);

/// Web `funnelEventAllowed` — metnin kapsamı dışındaki olay gönderilmez.
bool funnelEventAllowed(String event, {required bool isGuest}) {
  if (event == 'signup') return kFunnelMemberEventsEnabled;
  if (event == 'game_finish' && !isGuest) return kFunnelMemberEventsEnabled;
  return true;
}

/// Ölçüm v2'den önce iz: tanıtım görülmüş, anonim kod üretilmiş ya da bir
/// oturum var. ⚠ Uygulama AÇILIRKEN, hiçbir şey yazılmadan okunmalı
/// (`FunnelRepo.create`) — `pingGuestVisit` aynı açılışta anonim kod üretir.
bool hasPriorAppTrace(FlagsStore flags, {required bool signedIn}) =>
    signedIn || flags.seenIntro || flags.hasAnonId;

abstract class FunnelGateway {
  Future<void> logFunnelEvent({
    required String anonId,
    required String platform,
    required String event,
    String? channel,
    String? appVersion,
  });
}

class SupabaseFunnelGateway implements FunnelGateway {
  final SupabaseClient client;
  SupabaseFunnelGateway(this.client);

  @override
  Future<void> logFunnelEvent({
    required String anonId,
    required String platform,
    required String event,
    String? channel,
    String? appVersion,
  }) async {
    await client.rpc('log_funnel_event', params: {
      'p_anon_id': anonId,
      'p_platform': platform,
      'p_event': event,
      'p_channel': channel,
      'p_app_version': appVersion,
    });
  }
}

class FunnelRepo {
  final FunnelGateway gateway;
  final DeviceStamp stamp;
  final String platform;
  final String? appVersion;
  final bool hadPriorTrace;
  final Future<String?> Function()? _readInstallReferrer;
  final DateTime Function() _now;

  FlagsStore get flags => stamp.flags;

  FunnelRepo._(this.gateway, this.stamp, this.platform, this.appVersion,
      this.hadPriorTrace, this._readInstallReferrer, this._now);

  /// İz, oluşturma anında DONDURULUR. Platform iOS/Android değilse `null`.
  static FunnelRepo? create({
    required FunnelGateway gateway,
    required DeviceStamp stamp,
    required bool signedIn,
    String? platform,
    String? appVersion,
    Future<String?> Function()? readInstallReferrer,
    DateTime Function()? now,
  }) {
    final p = funnelPlatformFor(platform ?? currentPlatform);
    if (p == null) return null;
    return FunnelRepo._(
        gateway,
        stamp,
        p,
        appVersion,
        hasPriorAppTrace(stamp.flags, signedIn: signedIn),
        p == 'android' ? readInstallReferrer : null,
        now ?? DateTime.now);
  }

  /// Açılış / öne geliş: `land` (henüz gönderilmediyse) + günün `visit`i.
  /// Fire-and-forget; dönüş yalnızca testler için (gönderilen olaylar).
  Future<List<String>> open() async {
    final sent = <String>[];
    try {
      final anonId = await flags.anonId();
      // Kanal İLK kararda donar (web `planLand`): gönderim düşerse sonraki
      // açılış AYNI kanalla dener — o arada anonim kod üretildiği için
      // yeniden karar verilseydi cihaz "mevcut"a dönerdi.
      var channel = flags.funnelLandChannel;
      if (channel == null) {
        channel = decideAppLandChannel(
            hadPriorTrace: hadPriorTrace,
            source: stamp.source,
            referrerChannel:
                hadPriorTrace ? null : await _installReferrerChannel());
        await flags.setFunnelLandChannel(channel);
      }
      if (!flags.funnelLandSent) {
        await _send(anonId, 'land', channel: channel);
        await flags.setFunnelLandSent();
        sent.add('land');
      }
      final today = istanbulDay(_now());
      if (flags.funnelVisitDay != today) {
        await _send(anonId, 'visit');
        await flags.setFunnelVisitDay(today);
        sent.add('visit');
      }
    } catch (e) {
      // Damga YALNIZCA başarıdan sonra yazılıyor: düşen istek sonra yeniden
      // denenir (sunucu `land`/`visit`i zaten tekil tutuyor).
      debugPrint('[Kelimeki] funnel_events açılışı düştü: $e');
    }
    return sent;
  }

  /// Oyun/üyelik olayı. [isGuest]: çağıranın o anki oturum durumu.
  Future<bool> event(String event, {required bool isGuest}) async {
    if (!funnelEventAllowed(event, isGuest: isGuest)) return false;
    try {
      await _send(await flags.anonId(), event);
      return true;
    } catch (e) {
      debugPrint('[Kelimeki] funnel_events olayı düştü ($event): $e');
      return false;
    }
  }

  // Referrer okuması düşerse (Play Hizmetleri yok, zaman aşımı, sideload
  // edilmiş `.apk`) kanal `app`e düşer — ölçüm açılışı ASLA bozmaz. Kanal
  // ilk kararda donduğu için bu tek bir denemedir.
  Future<String?> _installReferrerChannel() async {
    final read = _readInstallReferrer;
    if (read == null) return null;
    try {
      return channelFromInstallReferrer(await read());
    } catch (e) {
      debugPrint('[Kelimeki] Install Referrer okunamadı: $e');
      return null;
    }
  }

  Future<void> _send(String anonId, String event, {String? channel}) =>
      gateway.logFunnelEvent(
        anonId: anonId,
        platform: platform,
        event: event,
        channel: channel,
        appVersion: appVersion,
      );
}

/// Tek örnek — `bootstrap()` yapılandırır; olay yerleri (kayıt penceresi,
/// oyun kaydı) doğrudan kullanır (`analytics` deseninin aynısı).
final Funnel funnel = Funnel();

class Funnel {
  Future<FunnelRepo?>? _repo;

  void configure(Future<FunnelRepo?>? repo) => _repo = repo;

  @visibleForTesting
  void reset() => _repo = null;

  // Fire-and-forget: repo her hatayı kendi içinde yutuyor; future'ın kendisi
  // düşerse (depolama açılamadı) sessizce geçilir — ölçüm açılışı bozmaz.
  void open() {
    _repo?.then((repo) async {
      await repo?.open();
    }).catchError((Object e) {
      debugPrint('[Kelimeki] funnel açılamadı: $e');
    });
  }

  void event(String event, {required bool isGuest}) {
    _repo?.then((repo) async {
      await repo?.event(event, isGuest: isGuest);
    }).catchError((Object e) {
      debugPrint('[Kelimeki] funnel açılamadı: $e');
    });
  }
}
