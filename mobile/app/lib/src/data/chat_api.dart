// Oyun İçi Mesajlaşma — Faz 1 (sohbet) + Faz 2 (sessize alma/raporlama).
// Web `src/lib/api.ts`'in ilgili bölümünün portu: `fetchOnlineGameMessages`/
// `sendOnlineGameMessage`/`subscribeOnlineGameMessages` + `fetchMyChatMutes`/
// `fetchMyActiveChatReports`/`setChatMute`/`reportChatParticipant`/
// `withdrawChatReports` + `fetchChatLastReadAt`/`markChatReadRemote` (okundu
// damgası sunucuda, ROADMAP #34). Yalnızca Canlı (online multiplayer) oyunlarda
// kullanılır — yerel/YZ oyunlarında bu dosyaya hiç dokunulmaz.
//
// Web'den taşınan sözleşmeler:
// - Mesaj göndermek RPC değil doğrudan RLS ile (`online_game_messages_insert_self`)
//   — 1-200 karakter kısıtı burada da (sunucuya gitmeden) tekrarlanır.
// - Realtime aboneliği yalnızca INSERT dinler (mesajlar düzenlenmiyor/silinmiyor).
// - Mute/rapor 3 Ağustos 2026'dan beri OYUNA değil KİŞİYE bağlı — bu yüzden
//   `myMutes`/`myActiveReports` gameId almaz (bir kişiyi sessize alman/rapor
//   etmen onunla oynadığın HER oyunda geçerli).
// - Rapor otomatik olarak hedefi de sessize alır (sunucu tarafında, RPC
//   gövdesi) — istemci ayrıca bir setMute çağırmaz.
// - ENGEL (4-5 Ekim 2026, web #811/#813): "sessize al" terimi "Engelle" oldu
//   ve engel oyundan BAĞIMSIZ (`block_user`/`unblock_user`/`list_blocked_users`
//   → `blockUser`/`unblockUser`/`blockedUsers`). Engellenen kişi oyun davetini,
//   arkadaşlık isteğini, arkadaş davet linkini ve rastgele eşleşmeyi kapatır.
//   `unblock_user` engeli + sohbet engellerini temizler, açık ŞİKAYETE
//   dokunmaz (şikayeti geri çekmek ayrı adım: `withdrawReports`).
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kelimeki_core/kelimeki_core.dart' show trCompare;

import '../util/chat_read.dart';

class OnlineGameMessageRow {
  final String id;
  final String senderUserId;
  final String message;
  final String createdAt;

  const OnlineGameMessageRow({
    required this.id,
    required this.senderUserId,
    required this.message,
    required this.createdAt,
  });

  factory OnlineGameMessageRow.fromJson(Map<String, Object?> j) =>
      OnlineGameMessageRow(
        id: j['id'] as String,
        senderUserId: j['sender_user_id'] as String,
        message: j['message'] as String,
        createdAt: j['created_at'] as String,
      );
}

/// "Engellediklerim" satırı — web `BlockedUser` (`src/lib/api.ts`).
class BlockedUser {
  final String userId;
  final String name;
  final String? avatarUrl;

  /// Aktif şikayet de var — engel, şikayet geri çekilene kadar sürer.
  final bool reported;

  const BlockedUser({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.reported,
  });

  factory BlockedUser.fromJson(Map<String, Object?> j) => BlockedUser(
        userId: j['blocked_user_id'] as String,
        name: j['blocked_name'] as String,
        avatarUrl: j['blocked_avatar_url'] as String?,
        reported: j['is_reported'] == true,
      );
}

abstract class ChatGateway {
  Future<List<Map<String, Object?>>> messages(String gameId);
  Future<void> send(String gameId, String message);

  /// Yalnızca INSERT dinler; dönüş aboneliği kapatır.
  void Function() subscribe(
      String gameId, void Function(Map<String, Object?> row) onInsert);

  Future<List<String>> myMutes();
  Future<List<String>> myActiveReports();

  /// Bu oyun için SUNUCUDAKİ okundu damgam (`online_game_chat_reads`, RLS
  /// ile yalnızca kendi satırım) — satır yoksa `null`. Okunamazsa FIRLATIR
  /// (çağıran "bilinmiyor" sayar). Web `fetchChatLastReadAt`.
  Future<String?> chatLastReadAt(String gameId);

  /// Okundu damgasını sunucuya yazar (`mark_online_game_chat_read`; sunucu
  /// yalnızca İLERİ gider ve geleceği `now()`a kırpar). Web
  /// `markChatReadRemote`.
  Future<void> markChatRead(String gameId, String readAt);

  /// Engellediğim / sohbette engellediğim / şikayet ettiğim HERKES
  /// (`list_blocked_users`) — arkadaş olsun olmasın. Hata FIRLATILIR.
  Future<List<Map<String, Object?>>> blockedUsers();

  /// Kişiyi engeller (oyundan bağımsız, `block_user`).
  Future<void> blockUser(String targetUserId);

  /// Engeli + sohbet engellerini kaldırır (`unblock_user`); açık şikayete
  /// dokunmaz.
  Future<void> unblockUser(String targetUserId);

  Future<void> setMute(String gameId, String targetUserId, bool muted);
  Future<void> report(String gameId, String targetUserId, String reason);
  Future<void> withdrawReports(String targetUserId);

  /// Kabul edilen Sohbet Kuralları sürümü (`profiles.chat_rules_version`) —
  /// hiç kabul etmediyse `null`. Okunamazsa FIRLATIR; çağıran `null` sayar.
  /// Web `fetchChatRulesVersion`. Bkz. `util/chat_rules.dart`.
  Future<int?> chatRulesVersion();

  /// Kabulü sunucuya yazar (`accept_chat_rules` RPC'si; zaman damgası
  /// sunucunun, yalnızca İLERİ yazar). Web `acceptChatRules`.
  Future<void> acceptChatRules(int version);
}

class SupabaseChatGateway implements ChatGateway {
  final SupabaseClient client;
  SupabaseChatGateway(this.client);

  @override
  Future<List<Map<String, Object?>>> messages(String gameId) async {
    final rows = await client
        .from('online_game_messages')
        .select()
        .eq('online_game_id', gameId)
        .order('created_at', ascending: true);
    return [for (final r in rows) (r as Map).cast<String, Object?>()];
  }

  @override
  Future<void> send(String gameId, String message) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Oturum açık değil.');
    await client.from('online_game_messages').insert({
      'online_game_id': gameId,
      'sender_user_id': user.id,
      'message': message,
    });
  }

  @override
  void Function() subscribe(
      String gameId, void Function(Map<String, Object?> row) onInsert) {
    final channel = client.channel('online_game_messages_$gameId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'online_game_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'online_game_id',
        value: gameId,
      ),
      callback: (payload) =>
          onInsert(payload.newRecord.cast<String, Object?>()),
    );
    channel.subscribe();
    return () => client.removeChannel(channel);
  }

  @override
  Future<List<String>> myMutes() async {
    final rows =
        await client.from('online_game_message_mutes').select('muted_user_id');
    return [for (final r in rows) r['muted_user_id'] as String];
  }

  @override
  Future<List<String>> myActiveReports() async {
    final rows = await client
        .from('online_game_chat_reports')
        .select('reported_user_id')
        .filter('withdrawn_at', 'is', null);
    return [for (final r in rows) r['reported_user_id'] as String];
  }

  @override
  Future<String?> chatLastReadAt(String gameId) async {
    final row = await client
        .from('online_game_chat_reads')
        .select('last_read_at')
        .eq('online_game_id', gameId)
        .maybeSingle();
    return row?['last_read_at'] as String?;
  }

  @override
  Future<void> markChatRead(String gameId, String readAt) async {
    await client.rpc('mark_online_game_chat_read', params: {
      'p_online_game_id': gameId,
      'p_read_at': readAt,
    });
  }

  @override
  Future<List<Map<String, Object?>>> blockedUsers() async {
    final rows = await client.rpc('list_blocked_users');
    return [for (final r in (rows as List)) (r as Map).cast<String, Object?>()];
  }

  @override
  Future<void> blockUser(String targetUserId) async {
    await client.rpc('block_user', params: {'p_target': targetUserId});
  }

  @override
  Future<void> unblockUser(String targetUserId) async {
    await client.rpc('unblock_user', params: {'p_target': targetUserId});
  }

  @override
  Future<void> setMute(String gameId, String targetUserId, bool muted) async {
    await client.rpc('mute_online_game_participant', params: {
      'p_game_id': gameId,
      'p_target_user_id': targetUserId,
      'p_muted': muted,
    });
  }

  @override
  Future<void> report(String gameId, String targetUserId, String reason) async {
    await client.rpc('report_online_game_participant', params: {
      'p_game_id': gameId,
      'p_target_user_id': targetUserId,
      'p_reason': reason,
    });
  }

  @override
  Future<void> withdrawReports(String targetUserId) async {
    await client.rpc('withdraw_online_game_chat_reports', params: {
      'p_target_user_id': targetUserId,
    });
  }

  @override
  Future<int?> chatRulesVersion() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Oturum açık değil.');
    final row = await client
        .from('profiles')
        .select('chat_rules_version')
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return (row['chat_rules_version'] as num?)?.toInt();
  }

  @override
  Future<void> acceptChatRules(int version) async {
    await client.rpc('accept_chat_rules', params: {'p_version': version});
  }
}

/// Bir Canlı oyunun devam eden sohbeti + Faz 2 durumu için politika katmanı.
class ChatRepo {
  final ChatGateway gateway;
  ChatRepo(this.gateway);

  static const maxMessageLength = 200;
  static const maxReasonLength = 500;

  /// Ağ hatasında null (UI eski listeyi korur — diğer repoların sözleşmesi).
  Future<List<OnlineGameMessageRow>?> messages(String gameId) async {
    try {
      final rows = await gateway.messages(gameId);
      return [for (final r in rows) OnlineGameMessageRow.fromJson(r)];
    } catch (_) {
      return null;
    }
  }

  /// Hata FIRLATILIR (ChatModal formda gösterir) — web `sendOnlineGameMessage`
  /// istemci tarafı doğrulamasıyla aynı sınır. `async` OLMAK ZORUNDA: aksi
  /// halde doğrulama hatası senkron olarak çağıranın stack'inde fırlar
  /// (Future.error'a sarılmaz) — `expectLater(repo.send(...), throwsX)` gibi
  /// bir Future bekleyen kod, Future hiç oluşmadan test anında çöker.
  Future<void> send(String gameId, String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.length > maxMessageLength) {
      throw Exception('Mesaj 1-$maxMessageLength karakter arasında olmalı.');
    }
    return gateway.send(gameId, trimmed);
  }

  void Function() subscribe(
          String gameId, void Function(OnlineGameMessageRow row) onInsert) =>
      gateway.subscribe(
          gameId, (row) => onInsert(OnlineGameMessageRow.fromJson(row)));

  /// Ağ hatasında boş set (web `fetchMyChatMutes`'un `[]` dönüşüyle aynı —
  /// bu iki liste yalnızca rozet/bildirim bastırma için, eksik veri en fazla
  /// bir rozeti geçici olarak gizler, veri kaybı yaratmaz).
  Future<Set<String>> myMutes() async {
    try {
      return (await gateway.myMutes()).toSet();
    } catch (_) {
      return const {};
    }
  }

  Future<Set<String>> myActiveReports() async {
    try {
      return (await gateway.myActiveReports()).toSet();
    } catch (_) {
      return const {};
    }
  }

  /// Sunucudaki okundu damgası: `null` = BİLİNMİYOR (istek düştü),
  /// `(at: null)` = sunucuda satır yok (kesin). Ayrım `decideChatRead`e
  /// (`util/chat_read.dart`) gerekli — bilinmiyorken tohum sunucuya yazılmaz.
  Future<ServerChatRead?> chatLastReadAt(String gameId) async {
    try {
      return (at: await gateway.chatLastReadAt(gameId));
    } catch (_) {
      return null;
    }
  }

  /// Hata YUTULUR: damga cihazda da duruyor ve bir sonraki yüklemede
  /// (`decideChatRead` → `pushToServer`) yeniden denenir. Web
  /// `markChatReadRemote`'un aynı sözleşmesi.
  Future<void> markChatRead(String gameId, String readAt) async {
    try {
      await gateway.markChatRead(gameId, readAt);
    } catch (_) {}
  }

  /// "Engellediklerim": engellediğim / sohbette engellediğim / şikayet
  /// ettiğim HERKES, ada göre (`trCompare`; web `fetchBlockedUsers`). Hata
  /// FIRLATILIR — liste "boş" sanılmasın.
  Future<List<BlockedUser>> blockedUsers() async {
    final rows = await gateway.blockedUsers();
    final list = [for (final r in rows) BlockedUser.fromJson(r)];
    list.sort((a, b) => trCompare(a.name, b.name));
    return list;
  }

  /// Arkadaş listesindeki 🚫/🚩 için: engelli ve şikayetli kimlik kümeleri.
  /// Ağ hatasında boş kümeler — rozet süs, eksik veri en fazla ikonu geçici
  /// gizler (web `reloadModeration`un hatada boş kalmasıyla aynı).
  Future<({Set<String> blocked, Set<String> reported})> myModeration() async {
    try {
      final list = await blockedUsers();
      return (
        blocked: {for (final u in list) u.userId},
        reported: {
          for (final u in list)
            if (u.reported) u.userId
        },
      );
    } catch (_) {
      return (blocked: const <String>{}, reported: const <String>{});
    }
  }

  /// Oyundan bağımsız engel — istek/davet kartı ve arkadaş ⋯ menüsü.
  Future<void> blockUser(String targetUserId) =>
      gateway.blockUser(targetUserId);

  /// Engeli (ve sohbet engellerini) kaldırır; açık şikayete dokunmaz.
  Future<void> unblockUser(String targetUserId) =>
      gateway.unblockUser(targetUserId);

  Future<void> setMute(String gameId, String targetUserId, bool muted) =>
      gateway.setMute(gameId, targetUserId, muted);

  /// `async` gerekliliği `send`'deki aynı ders — bkz. oradaki yorum.
  Future<void> report(String gameId, String targetUserId, String reason) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty || trimmed.length > maxReasonLength) {
      throw Exception(
          'Rapor nedeni 1-$maxReasonLength karakter arasında olmalı.');
    }
    return gateway.report(gameId, targetUserId, trimmed);
  }

  Future<void> withdrawReports(String targetUserId) =>
      gateway.withdrawReports(targetUserId);

  /// Okunamazsa `null` — `needsChatRulesConsent` onu "pencereyi göster"
  /// sayar (web `fetchChatRulesVersion`'ın `undefined`'ı).
  Future<int?> chatRulesVersion() async {
    try {
      return await gateway.chatRulesVersion();
    } catch (_) {
      return null;
    }
  }

  /// Hata FIRLATILIR — pencere kendi içinde gösterir.
  Future<void> acceptChatRules(int version) => gateway.acceptChatRules(version);
}
