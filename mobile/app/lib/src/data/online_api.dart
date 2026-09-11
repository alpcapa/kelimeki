// Canlı oyun API sarmalayıcısı — şimdilik yalnızca submit_move; diğer
// RPC'ler (list_my_online_games, get_my_online_rack…) Canlı oyun UI fazında
// aynı sınıfa eklenecek.
import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util/uuid.dart';

/// Sunucunun İŞ KURALI reddi — "Sıra sende değil.", "Oyun zaten bitti." gibi.
///
/// NEDEN VAR (11 Eylül 2026): `PostgrestException.toString()` TÜM alanları
/// basıyor ve bu dize kullanıcının ekranına düşüyordu —
/// *"PostgrestException(message: Sıra sende değil., code: P0001, details:
/// Bad Request, hint: null)"*. Kullanıcı bunu iPhone'da gördü.
///
/// ⚠ Düzeltme UI'da DEĞİL burada: `PostgrestException` bir Supabase tipi ve
/// bu depoda Supabase veri katmanında kalıyor. UI'ın o tipi tanıması
/// gerekseydi katman sınırı delinirdi; onun yerine sunucu reddi burada
/// mesajına soyuluyor ve `toString()` yalnızca mesajı veriyor. Böylece
/// ekranın mevcut `_errorText`i (ve web ikizinin `err.message`'ı) aynı
/// sonucu üretiyor — parite ayrışması kapandı.
///
/// ⚠ Ağ hatası DEĞİL: `isNetworkError` metin kalıplarına bakıyor ve Türkçe
/// bir iş kuralı mesajı o kalıpların hiçbirine denk gelmiyor, yani bu tip
/// "bağlantı yok" diye maskelenmez.
class ServerRejection implements Exception {
  final String message;
  final String? code;
  const ServerRejection(this.message, {this.code});

  @override
  String toString() => message;
}

/// `client.rpc` çağrısının test kancası — bkz. `OnlineApi.withRpc`.
typedef SubmitMoveRpc = Future<void> Function(Map<String, Object?> params);

class OnlineApi {
  final SupabaseClient? client;
  final SubmitMoveRpc? _rpc;

  OnlineApi(SupabaseClient this.client) : _rpc = null;

  /// YALNIZCA testler için: gerçek RPC yerine bir fonksiyon koyar.
  ///
  /// Gerekçe (13 Ağustos 2026 denetimi): `submitMove`ın retry/idempotency
  /// döngüsü — aynı `p_move_id` ile yeniden deneme, `PostgrestException`da
  /// rethrow — mobilin ASIL güvenilirlik özelliği, ama ekran testlerinin
  /// tamamı `FakeOnlineGamesGateway.submitMove` sınırının ÜSTÜNDE ölçüyor.
  /// Bu kanca olmadan `final id = moveId ?? uuidV4()` satırı döngünün İÇİNE
  /// taşınsa (her denemede YENİ uuid → idempotensi tamamen kırılır,
  /// sunucuda çifte hamle riski geri gelir) tek bir test bile düşmüyordu.
  @visibleForTesting
  OnlineApi.withRpc(SubmitMoveRpc rpc)
      : client = null,
        _rpc = rpc;

  Future<void> _send(Map<String, Object?> params) {
    final custom = _rpc;
    if (custom != null) return custom(params);
    return client!
        .rpc<void>('submit_move', params: params)
        .timeout(const Duration(seconds: 15));
  }

  /// Hamle gönderimi — HER çağrı bir `p_move_id` UUID'si taşır
  /// (20260805225619 migration'ı). Bu sayede ağ hatasında AYNI id ile
  /// yeniden denemek güvenlidir: hamle sunucuya ilk denemede ulaştıysa
  /// retry sessizce başarı döner (çifte hamle/sahte 'Sıra sende değil.'
  /// yapısal olarak imkânsız). Web istemcisi bu parametreyi göndermiyor —
  /// mobil ağların güvenilmezliği bu sarmalayıcının varlık sebebi.
  ///
  /// Retry YALNIZCA taşıma katmanı hatalarında (timeout, soket) yapılır;
  /// `PostgrestException` sunucunun kesin kararıdır (kural reddi, sıra
  /// kontrolü…) ve olduğu gibi fırlatılır.
  Future<void> submitMove({
    required String gameId,
    required String action, // 'play' | 'pass' | 'exchange'
    List<Map<String, Object?>>? placements,
    List<String>? exchangeLetters,
    List<String> words = const [],
    List<Map<String, Object?>>? wordScores,
    int basePoints = 0,
    List<Map<String, Object?>> lostShares = const [],
    String? moveId,
    int maxAttempts = 3,
  }) async {
    final id = moveId ?? uuidV4();
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        await _send({
          'p_game_id': gameId,
          'p_action': action,
          if (placements != null) 'p_placements': placements,
          if (exchangeLetters != null) 'p_exchange_letters': exchangeLetters,
          'p_words': words,
          if (wordScores != null) 'p_word_scores': wordScores,
          'p_base_points': basePoints,
          'p_lost_shares': lostShares,
          'p_move_id': id,
        });
        return;
      } on PostgrestException catch (e) {
        // Sunucu kararı — yeniden deneme anlamsız/yanlış. Ham exception
        // dökümü ekrana düşmesin diye mesajına soyuluyor (bkz.
        // `ServerRejection`).
        throw ServerRejection(e.message, code: e.code);
      } catch (_) {
        if (attempt >= maxAttempts) rethrow;
        // 400ms, 800ms — kısa üstel bekleme; id aynı kaldığından güvenli.
        await Future<void>.delayed(
            Duration(milliseconds: 400 * (1 << (attempt - 1))));
      }
    }
  }
}
