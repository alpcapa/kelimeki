// Kelimeki app — Kayıt Hunisi'nin anonim sayacı (`signup_events`), web
// `logSignupEvent` paritesi (ROADMAP #35, 26 Eylül 2026).
//
// NEDEN: admin → Büyüme → Kullanıcı'daki "Kayıt Hunisi" kartı (#600) yalnızca
// web'i sayıyordu; port aynı iki olayı (`signup_started`/`signup_completed`)
// yalnızca Firebase Analytics'e yazıyordu. Kayıtların önemli bir kısmı
// mobilden geldiği için kart kitlenin bir kısmını görüyordu — ROADMAP #32'nin
// (e-posta onayı kaybı) kararı bu oranı bekliyor. Firebase çağrısı KALIYOR;
// bu dosya ona PARALEL.
//
// ⚠ KİMLİK YOK, BİLEREK: ne `anon_id` ne `user_id`. Tablo kimliksiz, çünkü
// gizlilik metni anonim kodun sunucuya gittiği durumları SAYIYOR; beşinci
// bir durum metni (ve portun kopyasını) değiştirmeyi gerektirirdi (migration
// `20260921122031_signup_events_funnel.sql` başlığı). `DeviceStamp` bu yüzden
// burada KULLANILMAZ.
//
// DESEN `analytics`in AYNISI (global tek örnek + `configure`): olay yeri
// `AuthModal` ve onu açan üç çağrı yeri var; her birine bir repo parametresi
// açmak yerine bootstrap bir kez bağlıyor. İki değişmez de aynı:
//   1. FIRE-AND-FORGET — asla fırlatmaz; kayıt olmaya çalışan biri bizim
//      sayacımız yüzünden hata görmemeli (web'in aynı sözleşmesi).
//   2. YAPILANDIRILMAMIŞSA SESSİZ NO-OP — testler ve Supabase'siz açılış.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../util/platform.dart';

/// `'started'` = kayıt FORMU görüldü, `'completed'` = hesap OLUŞTU.
/// Sunucu kısıtıyla ELLE senkron (`signup_events.event` check'i).
const kSignupStarted = 'started';
const kSignupCompleted = 'completed';

/// Sunucunun kabul ettiği kanal kümesi (`profiles.signup_channel` ile aynı,
/// `signup_events.channel` check'i). Dışındaki bir değer null gider —
/// satır düşmesin, `bilinmiyor`a sayılsın.
const kSignupChannels = {'direct', 'form'};

abstract class SignupEventsSink {
  Future<void> insert(Map<String, Object?> row);
}

class SupabaseSignupEventsSink implements SignupEventsSink {
  final SupabaseClient client;
  SupabaseSignupEventsSink(this.client);

  @override
  Future<void> insert(Map<String, Object?> row) async {
    await client.from('signup_events').insert(row);
  }
}

/// Tek örnek — `bootstrap()` yapılandırır, `AuthModal` doğrudan kullanır.
final SignupEvents signupEvents = SignupEvents();

class SignupEvents {
  SignupEventsSink? _sink;

  void configure(SignupEventsSink? sink) => _sink = sink;

  @visibleForTesting
  void reset() => _sink = null;

  /// Fire-and-forget: beklenmez, fırlatmaz.
  void log(String event, String channel) {
    final sink = _sink;
    if (sink == null) return;
    try {
      sink.insert({
        'event': event,
        'channel': kSignupChannels.contains(channel) ? channel : null,
        // Web'in aksine DOLU: app sürümü derleme sha'sıyla tekil değil
        // (`tutorial_events` ucunun aynı sözleşmesi).
        'platform': currentPlatform,
        'app_version': appVersion,
      }).catchError((Object e) {
        debugPrint('[Kelimeki] signup_events hatası: $e');
      });
    } catch (e) {
      debugPrint('[Kelimeki] signup_events hatası: $e');
    }
  }
}
