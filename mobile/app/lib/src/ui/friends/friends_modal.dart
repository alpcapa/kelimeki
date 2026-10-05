// Arkadaşlar penceresi — src/components/FriendsModal.tsx portu.
//
// 1 Ekim 2026 — SEKMESİZ tek ekrana yeniden yazıldı (web 27 Eylül 2026,
// ROADMAP #41 karar 22-24; karar kaydı `docs/decisions/friends.md` → "Tek
// ekran"). Üç sekme (Arkadaşlar · Davetler · Ara & Ekle) ve dört onay
// diyaloğu kalktı; yalnızca "Arkadaşlıktan çıkar" onay soruyor. İkonlar
// yerine YAZILI haplar (`KPill`).
//
// Yukarıdan aşağı tek sütun:
// 1. Turuncu "+ ARKADAŞINI DAVET ET" — doğrudan paylaşım sayfası.
// 2. Bekleyen istekler: gelenler (kart: REDDET / KABUL ET), altında
//    gönderdiklerin (satır, GERİ AL). Arama ve "Tüm oyuncular"da da yerinde.
// 3. "ARKADAŞLARIN · N" / "TÜM OYUNCULAR" başlığı + sağda dönüşümlü bağlantı.
// 4. Arama kutusu listenin hemen üstünde; yazınca sonuçlar (sunucu).
// 5. Arkadaş satırı: rütbe, "3 haftadır", OYNA (2 kişilik), ⋯ (skor kartı ·
//    2/4 kişilik oyun kur · Engelle / Engeli kaldır (durum varsa şikayet de
//    yönetilir) · arkadaşlıktan çıkar). Listenin altında "Engellediklerim".
//    İstek kartında yalnızca "Engelle" (şikayet YOK — şikayet oyunun sohbetine
//    özel; web 4-5 Ekim 2026).
//
// OYNA / "N kişilik oyun kur": pencere kapanır, Canlı sekmesinde form o
// arkadaş seçili açılır (`util/live_game_request.dart`; oyun ekranı açıksa
// Setup'a dönülür).
//
// ⚠ Pencerede TEK kaydırılabilir var (`KModal` gövdesi) — "Tüm oyuncular"
// sayfalaması gövdenin kaydırmasına bağlı (bkz. mobile/CLAUDE.md →
// "KModal'ın gövdesi ZATEN kaydırılabilir"). Web'in `max-h-[55vh]` iç
// kaydırması (arkadaş/arama listesi, 4 Ekim 2026) bilinçli olarak taşınmadı:
// web'de nedeni "Engellediklerim bağlantısı uzun listenin altında kaybolmasın"
// idi; burada tüm gövde kayıyor, bağlantı kaydırınca erişilir.
//
// Metinler web'le BİREBİR — `friends_test.dart` web kaynağını okur.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trCompare, trUpper;
import 'package:share_plus/share_plus.dart';

import '../../data/analytics.dart';
import '../../data/auth_service.dart';
import '../../data/chat_api.dart';
import '../../data/friends_api.dart';
import '../../data/games_api.dart';
import '../../data/stats_api.dart';
import '../../util/friend_since.dart';
import '../../util/live_game_request.dart';
import '../../util/share_board.dart' show shareOriginFrom;
import '../auth/k_avatar.dart';
import '../game/dialog_shell.dart';
import '../game/modal_shell.dart';
import '../game/neo_button.dart';
import '../rank/rank_scores.dart';
import '../rank/rank_seal.dart';
import '../score/player_score_card_modal.dart';
import '../tap_target.dart';
import '../tokens.dart';
import '../loading_note.dart';
import '../form_input.dart';
import 'block_confirm_sheet.dart';
import 'blocked_users_sheet.dart';
import 'friend_moderation_sheet.dart';
import 'k_pill.dart';
import 'player_directory.dart';

const Color _text = kText;
const Color _muted = kMuted;
const Color _accent = kAccent;
const Color _border = kBorder;

/// Eski sekmeli sürümden kalan imza — çağıranlar bozulmasın diye duruyor
/// (web `initialTab`). `search` artık arama kutusuna odaklanmak demek;
/// öteki değerler yok sayılır (gelen istekler zaten en üstte).
enum FriendsTab { friends, requests, search }

/// Web ALL_USERS_PAGE_SIZE — `PlayerDirectory` ile aynı.
const int kAllUsersPageSize = kPlayerDirectoryPageSize;

/// Onaydan sonra ağ işlemi düşerse gösterilen metin — `chat_settings_modal`
/// ve skor kartı aynı dizeyi kullanıyor.
const String kFriendActionFailed = 'İşlem başarısız oldu.';

// Web metinleri — `friends_test.dart` bunları `FriendsModal.tsx`te arar.
const String kFriendsInviteCaption =
    'WhatsApp ya da istediğin uygulamayla link gönder';
const String kFriendsIncomingMeta = 'Seni arkadaş olarak eklemek istiyor';
const String kFriendsOutgoingMeta = 'Cevap bekleniyor';
const String kFriendsSearchHint = 'Oyuncu ara: isim ya da takma ad';
const String kFriendsNobody =
    "Kimse bulunamadı. Kelimeki'de değilse yukarıdan davet linki gönder.";
const String kFriendsEmptyTitle = 'Henüz arkadaşın yok';
const String kFriendsEmptyBody =
    'Bir link gönder; arkadaşın linke dokunup üye olunca burada belirir ve hemen oyuna çağırırsın.';
const String kFriendsNoMorePlayers = 'Başka oyuncu yok.';
const String kFriendsMenuCard = 'Skor kartını gör';
const String kFriendsMenuPlay2 = '2 kişilik oyun kur';
const String kFriendsMenuPlay4 = '4 kişilik oyun kur';
const String kFriendsMenuModeration = 'Engel / şikayet ayarları';
const String kFriendsMenuUnblock = 'Engeli kaldır';
const String kFriendsMenuBlock = 'Engelle';
const String kFriendsBlockLink = 'Engelle';
const String kFriendsBlockedListLink = 'Engellediklerim';
const String kFriendsMenuRemove = 'Arkadaşlıktan çıkar';

Future<void> showFriendsModal(
  BuildContext context, {
  required FriendsRepo friends,
  required AuthService auth,
  StatsRepo? stats,
  Future<GamesRepo>? games,
  ChatRepo? chat,
  FriendsTab? initialTab,
  Future<void> Function(String text)? sharer,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => FriendsModal(
      friends: friends,
      auth: auth,
      stats: stats,
      games: games,
      chat: chat,
      initialTab: initialTab,
      sharer: sharer,
    ),
  );
}

class FriendsModal extends StatefulWidget {
  final FriendsRepo friends;
  final AuthService auth;

  /// Kişiye dokununca açılan skor kartı için — null ise dokunuş pasif.
  final StatsRepo? stats;
  final Future<GamesRepo>? games;

  /// 🚫/🚩 durumu ve ⋯ menüsündeki ayarlar için. null ise hiç çizilmez.
  final ChatRepo? chat;

  /// Bkz. [FriendsTab] — yalnızca `search` anlamlı (arama kutusuna odak).
  final FriendsTab? initialTab;

  /// Davet metnini paylaşan uç — testler sahte geçer; üretimde share_plus.
  final Future<void> Function(String text)? sharer;

  const FriendsModal({
    super.key,
    required this.friends,
    required this.auth,
    this.stats,
    this.games,
    this.chat,
    this.initialTab,
    this.sharer,
  });

  @override
  State<FriendsModal> createState() => _FriendsModalState();
}

class _FriendsModalState extends State<FriendsModal> {
  List<FriendRow>? _friends;
  List<IncomingFriendRequest>? _requests;
  List<OutgoingFriendRequest> _sent = const [];
  final _query = TextEditingController();
  bool _showAll = false;
  String? _busyId;
  bool _inviteBusy = false;

  late final PlayerDirectory _dir;

  /// Modalın GÖVDE kaydırması — "Tüm oyuncular" sayfalaması buna bakar
  /// (iç içe kaydırılabilir YOK, bkz. dosya başı).
  final _bodyScroll = ScrollController();

  /// İsimlerin yanındaki rütbe mührü.
  late final RankScores _rankScores;

  /// Engellediğim / şikayet ettiğim kişiler — kaynak `list_blocked_users`
  /// (engel + sohbet engeli + açık şikayet birleşimi).
  Set<String> _modBlocked = const {};
  Set<String> _modReported = const {};

  /// "+ ARKADAŞINI DAVET ET"in kendi kutusu — iPad popover ankrajı BURADAN
  /// (State.context modalın tamamını ankraj yapıyordu ve iPad'de paylaşım
  /// asılı kalıyordu — 2 Eylül 2026, `shareOriginFrom`).
  final GlobalKey _inviteButtonKey = GlobalKey();

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _rankScores = RankScores(widget.stats)..addListener(_onChange);
    _dir = PlayerDirectory(widget.friends)..addListener(_onDirChange);
    _reloadFriends();
    _reloadRequests();
    _reloadSent();
    unawaited(_reloadModeration());
    _bodyScroll.addListener(() {
      if (_bodyScroll.position.extentAfter < 80) _loadMore();
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _bodyScroll.dispose();
    _dir.removeListener(_onDirChange);
    _dir.dispose();
    _rankScores.removeListener(_onChange);
    _rankScores.dispose();
    super.dispose();
  }

  void _onDirChange() {
    _onChange();
    _autoLoadIfNotScrollable();
  }

  void _loadMore() {
    if (!_showAll || _dir.searchActive) return;
    _dir.loadMore();
  }

  /// Liste kaydırılamayacak kadar kısaysa gövde dinleyicisi HİÇ ateşlenmez
  /// ve sonraki sayfa asla istenmez (Parça 31'in dersi) — her yüklemeden
  /// sonra bir kare bekleyip elle kontrol.
  void _autoLoadIfNotScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showAll || !_dir.hasMore) return;
      if (!_bodyScroll.hasClients) return;
      if (_bodyScroll.position.maxScrollExtent <= 0) _loadMore();
    });
  }

  void _reloadFriends() {
    widget.friends.friends().then((f) {
      if (!mounted) return;
      setState(() {
        if (f != null) {
          _friends = f;
        } else {
          _friends ??= const [];
        }
      });
      _rankScores.ensure((_friends ?? const []).map((x) => x.friendId));
    });
  }

  void _reloadRequests() {
    widget.friends.incomingRequests().then((r) {
      if (!mounted) return;
      setState(() {
        if (r != null) {
          _requests = r;
        } else {
          _requests ??= const [];
        }
      });
      _rankScores.ensure((_requests ?? const []).map((x) => x.requesterId));
    });
  }

  void _reloadSent() {
    widget.friends.outgoingRequests().then((s) {
      if (!mounted || s == null) return;
      setState(() => _sent = s);
      _rankScores.ensure(s.map((x) => x.friendId));
    });
  }

  Future<void> _reloadModeration() async {
    final chat = widget.chat;
    if (chat == null) return;
    final m = await chat.myModeration();
    if (!mounted) return;
    setState(() {
      _modBlocked = m.blocked;
      _modReported = m.reported;
    });
  }

  // ── İlişki eylemleri — TEK DOKUNUŞ (yalnızca "çıkar" onay sorar) ────────

  Future<void> _handleSend(String id) async {
    setState(() => _busyId = id);
    try {
      final r = await widget.friends.sendRequest(id);
      // Karşı taraftan bekleyen istek varsa sunucu ilişkiyi doğrudan
      // 'accepted'a çeviriyor.
      _dir.patchRelation(id, r);
      if (r == FriendRelation.accepted) _reloadFriends();
      _reloadSent();
    } catch (e) {
      debugPrint('[Kelimeki] arkadaşlık isteği hatası: $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _handleRespond(String requesterId,
      {required bool accept}) async {
    setState(() => _busyId = requesterId);
    try {
      await widget.friends.respond(requesterId, accept: accept);
      _dir.patchRelation(requesterId, accept ? FriendRelation.accepted : null);
      _reloadRequests();
      if (accept) _reloadFriends();
    } catch (e) {
      debugPrint('[Kelimeki] istek yanıtlama hatası: $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _handleCancel(String id) async {
    setState(() => _busyId = id);
    try {
      await widget.friends.removeOrCancel(id); // gönderilen isteği iptal et
      _dir.patchRelation(id, null);
      if (mounted) {
        setState(() => _sent = [
              for (final r in _sent)
                if (r.friendId != id) r
            ]);
      }
    } catch (e) {
      debugPrint('[Kelimeki] istek iptal hatası: $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _confirmRemove(String id, String name) async {
    final ok = await confirmFriendAction(
      context,
      title: 'Arkadaşlıktan Çıkar',
      message: '$name ile arkadaşsınız. Arkadaşlıktan çıkmak mı istiyorsunuz?',
      confirmLabel: 'Çıkar',
    );
    if (!ok || !mounted) return;
    setState(() => _busyId = id);
    try {
      await widget.friends.removeOrCancel(id);
      _reloadFriends();
      _dir.patchRelation(id, null);
    } catch (e) {
      debugPrint('[Kelimeki] arkadaş çıkarma hatası: $e');
      if (mounted) await showFriendInfoDialog(context, kFriendActionFailed);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  /// OYNA: pencere kapanır, Canlı sekmesinde form o arkadaş seçili açılır.
  void _play(String friendId, int playerCount) {
    Navigator.of(context).pop();
    liveGameRequests
        .request(LiveGameRequest(friendId: friendId, playerCount: playerCount));
  }

  Future<void> _handleInvite() async {
    setState(() => _inviteBusy = true);
    try {
      final url = await widget.friends.inviteUrl();
      if (url == null) return;
      if (!mounted) return;
      final anchor =
          shareOriginFrom(_inviteButtonKey.currentContext ?? context);
      final share = widget.sharer ??
          (String text) async {
            await SharePlus.instance
                .share(ShareParams(text: text, sharePositionOrigin: anchor));
          };
      await share('$inviteShareText\n$url');
      // GA4 `invite_link_shared` — ölçülen paylaşım SAYFASININ açılması.
      analytics.log('invite_link_shared', {'source': 'friends_modal'});
    } finally {
      if (mounted) setState(() => _inviteBusy = false);
    }
  }

  Future<void> _openCard(String id, String name, String? avatarUrl) async {
    final stats = widget.stats;
    if (stats == null) return;
    await showPlayerScoreCard(
      context,
      stats: stats,
      userId: id,
      name: name,
      avatarUrl: avatarUrl,
      games: widget.games,
      friends: widget.friends,
      auth: widget.auth,
    );
    if (!mounted) return;
    // Kart İÇİNDEN arkadaş eklenip çıkarılabiliyor — ilişki yeniden okunur.
    final r = await widget.friends.relationWith(id);
    if (!mounted) return;
    _dir.patchRelation(id, r);
    _reloadFriends();
    _reloadRequests();
    _reloadSent();
  }

  Future<void> _openModeration(FriendRow f) async {
    final chat = widget.chat;
    if (chat == null) return;
    final changed = await showFriendModeration(
      context,
      chat: chat,
      target: FriendModerationTarget(
        userId: f.friendId,
        name: f.name,
        avatarUrl: f.avatarUrl,
        blocked: _modBlocked.contains(f.friendId),
        reported: _modReported.contains(f.friendId),
      ),
    );
    if (changed) await _reloadModeration();
  }

  /// "Engelle" onayı — istek kartı (`isFriend: false`) ve arkadaş ⋯ menüsü.
  /// Önce engel, sonra isteği reddet: engel başarısızsa istek yerinde kalır
  /// (kullanıcı "engelledim" sanmaz); ret başarısız olursa engel kalır ve istek
  /// zaten engelli kişiden geldiğinden zararsızdır.
  Future<void> _confirmBlock(String id, String name,
      {required bool isFriend}) async {
    final chat = widget.chat;
    if (chat == null) return;
    final ok = await showBlockConfirm(
      context,
      name: name,
      onConfirm: () async {
        await chat.blockUser(id);
        if (!isFriend) {
          await widget.friends.respond(id, accept: false);
          _dir.patchRelation(id, null);
          _reloadRequests();
        }
      },
    );
    if (ok) await _reloadModeration();
  }

  Future<void> _openBlockedList() async {
    final chat = widget.chat;
    if (chat == null) return;
    final changed = await showBlockedUsers(context, chat: chat);
    if (changed) await _reloadModeration();
  }

  void _toggleShowAll() {
    setState(() => _showAll = !_showAll);
    if (_showAll) _dir.open();
    _autoLoadIfNotScrollable();
  }

  // ── Çizim ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _rankScores.ensure([
      for (final u in _dir.results) u.id,
      for (final u in _dir.allUsers ?? const <FriendCandidate>[]) u.id,
    ]);
    final requests = _requests ?? const <IncomingFriendRequest>[];
    return KModal(
      title: 'Arkadaşlar',
      bodyController: _bodyScroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: NeoButton(
              key: _inviteButtonKey,
              label: _inviteBusy ? '…' : '+  ARKADAŞINI DAVET ET',
              variant: NeoButtonVariant.orange,
              fontSize: 15,
              letterSpacing: 1,
              onPressed: _inviteBusy ? null : _handleInvite,
            ),
          ),
          const SizedBox(height: 6),
          const Text(kFriendsInviteCaption,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _muted)),
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionLabel('İSTEKLER · ${requests.length}'),
            const SizedBox(height: 8),
            for (final r in requests) _requestCard(r),
          ],
          if (_sent.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionLabel('GÖNDERDİĞİN İSTEKLER · ${_sent.length}'),
            const SizedBox(height: 8),
            _listBox([
              for (final r in _sent)
                _row(
                  key: ValueKey('sent-${r.friendId}'),
                  children: [
                    _person(
                        r.friendId, r.name, r.avatarUrl, kFriendsOutgoingMeta),
                    KPill(
                      kind: KPillKind.geriAl,
                      semanticLabel: '${r.name} — isteği geri al',
                      onTap: _busyId == r.friendId
                          ? null
                          : () => _handleCancel(r.friendId),
                    ),
                  ],
                ),
            ]),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _SectionLabel(_showAll
                  ? 'TÜM OYUNCULAR'
                  : 'ARKADAŞLARIN${(_friends?.isNotEmpty ?? false) ? ' · ${_friends!.length}' : ''}'),
            ),
            TapTarget(
              onTap: _toggleShowAll,
              minHeight: 36,
              child: Text(_showAll ? '← Arkadaşlar' : 'Tüm oyuncular →',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _accent)),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _query,
            autofocus: widget.initialTab == FriendsTab.search,
            onChanged: (q) {
              _dir.setQuery(q);
              setState(() {});
            },
            style: kInputTextStyle,
            decoration: kInputDecoration(hint: kFriendsSearchHint),
          ),
          const SizedBox(height: 8),
          ..._body(),
          if (widget.chat != null) ...[
            const SizedBox(height: 12),
            Center(
              child: _TextLink(
                label: kFriendsBlockedListLink,
                fontSize: 11,
                onTap: _openBlockedList,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _body() {
    if (_dir.searchActive) {
      if (_dir.searching) return [const KLoadingNote(vertical: 16)];
      if (_dir.results.isEmpty) {
        return [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(kFriendsNobody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.6, color: _muted)),
          ),
        ];
      }
      return [
        Text('"${_query.text.trim()}" için ${_dir.results.length} oyuncu',
            style: const TextStyle(fontSize: 12, color: _muted)),
        const SizedBox(height: 8),
        _listBox([for (final u in _dir.results) _userRow(u)]),
      ];
    }
    if (_showAll) {
      final all = _dir.allUsers;
      if (all == null) return [const KLoadingNote(vertical: 16)];
      return [
        _listBox([
          for (final u in all) _userRow(u),
          if (all.isEmpty && !_dir.hasMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(kFriendsNoMorePlayers,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 12, color: _muted)),
            ),
          if (_dir.hasMore && _dir.loadingMore) const KLoadingNote(vertical: 8),
        ]),
      ];
    }
    final friends = _friends;
    if (friends == null) return [const KLoadingNote(vertical: 16)];
    if (friends.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Text(kFriendsEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _text)),
            SizedBox(height: 8),
            Text(kFriendsEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.6, color: _muted)),
          ]),
        ),
      ];
    }
    return [
      _listBox([
        for (final f in friends)
          _row(
            key: ValueKey('friend-${f.friendId}'),
            children: [
              _person(f.friendId, f.name, f.avatarUrl,
                  friendSinceLabel(f.since, kisa: true)),
              KPill(
                kind: KPillKind.oyna,
                semanticLabel: '${f.name} ile oyna',
                onTap: () => _play(f.friendId, 2),
              ),
              _moreButton(f),
            ],
          ),
      ]),
    ];
  }

  /// Arama / tüm oyuncular satırı — ilişkiye göre TEK yazılı düğme.
  Widget _userRow(FriendCandidate u) {
    final busy = _busyId == u.id;
    final friend = (_friends ?? const <FriendRow>[])
        .where((f) => f.friendId == u.id)
        .firstOrNull;
    final meta = switch (u.relation) {
      FriendRelation.accepted => 'Arkadaşın',
      FriendRelation.pendingOutgoing => 'Yanıt bekleniyor',
      FriendRelation.pendingIncoming => 'Seni eklemek istiyor',
      null => null,
    };
    return _row(
      key: ValueKey('user-${u.id}'),
      children: [
        _person(u.id, u.name, u.avatarUrl, meta),
        ...switch (u.relation) {
          FriendRelation.accepted => [
              KPill(
                kind: KPillKind.oyna,
                semanticLabel: '${u.name} ile oyna',
                onTap: () => _play(u.id, 2),
              ),
              if (friend != null) _moreButton(friend),
            ],
          FriendRelation.pendingOutgoing => [
              KPill(
                kind: KPillKind.gonderildi,
                semanticLabel: '${u.name} — isteği iptal et',
                onTap: busy ? null : () => _handleCancel(u.id),
              ),
            ],
          FriendRelation.pendingIncoming => [
              KPill(
                kind: KPillKind.kabul,
                semanticLabel: '${u.name} — isteği kabul et',
                onTap: busy ? null : () => _handleRespond(u.id, accept: true),
              ),
            ],
          null => [
              KPill(
                kind: KPillKind.ekle,
                semanticLabel: '${u.name} — arkadaş ekle',
                onTap: busy ? null : () => _handleSend(u.id),
              ),
            ],
        },
      ],
    );
  }

  Widget _requestCard(IncomingFriendRequest r) {
    final busy = _busyId == r.requesterId;
    return Container(
      key: ValueKey('request-${r.requesterId}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: kOrange, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _person(r.requesterId, r.name, r.avatarUrl, kFriendsIncomingMeta),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 42,
                child: NeoButton(
                  label: 'REDDET',
                  variant: NeoButtonVariant.neutral,
                  fontSize: 12,
                  letterSpacing: 1,
                  onPressed: busy
                      ? null
                      : () => _handleRespond(r.requesterId, accept: false),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 42,
                child: NeoButton(
                  label: 'KABUL ET',
                  variant: NeoButtonVariant.orange,
                  fontSize: 12,
                  letterSpacing: 1,
                  onPressed: busy
                      ? null
                      : () => _handleRespond(r.requesterId, accept: true),
                ),
              ),
            ),
          ]),
          // Yalnızca "Engelle" (web 4 Ekim 2026, kullanıcı kararı): istek
          // kartında şikayet YOK — şikayet oyunun sohbetine özeldir.
          if (widget.chat != null)
            Align(
              alignment: Alignment.center,
              child: _TextLink(
                label: kFriendsBlockLink,
                fontSize: 11,
                onTap: busy
                    ? null
                    : () =>
                        _confirmBlock(r.requesterId, r.name, isFriend: false),
              ),
            ),
        ],
      ),
    );
  }

  /// Avatar + isim (+ rütbe, + 🚩/🚫) + alt satır; dokununca skor kartı.
  Widget _person(String id, String name, String? avatarUrl, String? meta) {
    final tier = _rankScores.tierOf(id);
    final mod = _modReported.contains(id)
        ? '🚩'
        : _modBlocked.contains(id)
            ? '🚫'
            : null;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            widget.stats == null ? null : () => _openCard(id, name, avatarUrl),
        child: Row(children: [
          KAvatar(url: avatarUrl, name: name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _text)),
                  ),
                  if (tier != null) ...[
                    const SizedBox(width: 6),
                    RankSeal(tier: tier, size: 16),
                  ],
                  if (mod != null) ...[
                    const SizedBox(width: 6),
                    Text(mod,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamilyFallback: [
                            'Noto Color Emoji',
                            'Apple Color Emoji'
                          ],
                        )),
                  ],
                ]),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _moreButton(FriendRow f) => Semantics(
        button: true,
        label: '${f.name} — diğer seçenekler',
        excludeSemantics: true,
        child: TapTarget(
          key: ValueKey('more-${f.friendId}'),
          onTap: () => _openMenu(f),
          minHeight: 40,
          minWidth: 40,
          child: const Icon(Icons.more_horiz, size: 22, color: _muted),
        ),
      );

  /// Web `listCls` — çerçeveli, köşeleri yuvarlak, satırlar arası çizgi.
  Widget _listBox(List<Widget> rows) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: _border),
              rows[i],
            ],
          ],
        ),
      );

  /// Web `rowCls` — en az 60 yüksek, sol 14 sağ 8.
  Widget _row({required Key key, required List<Widget> children}) => Container(
        key: key,
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        color: kBg,
        child: Row(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ]),
      );

  // ── ⋯ kişi menüsü — alttan açılır ────────────────────────────────────────

  Future<void> _openMenu(FriendRow f) async {
    final chatVar = widget.chat != null;
    final reported = _modReported.contains(f.friendId);
    final blockedNow = _modBlocked.contains(f.friendId);
    final items = <(String, bool, VoidCallback)>[
      (
        kFriendsMenuCard,
        false,
        () => _openCard(f.friendId, f.name, f.avatarUrl)
      ),
      // OYNA 2 kişilik kurar; menü ikisini de açıkça sunar.
      (kFriendsMenuPlay2, false, () => _play(f.friendId, 2)),
      (kFriendsMenuPlay4, false, () => _play(f.friendId, 4)),
      // Engelle / Engeli kaldır (web 5 Ekim 2026): durum yoksa "Engelle"
      // (onaylı, yalnızca engel — şikayet oyun içi sohbetten açılır); durum
      // varsa geri alma paneli (engel kaldır / şikayeti geri çek).
      if (chatVar)
        if (reported || blockedNow)
          (
            reported ? kFriendsMenuModeration : kFriendsMenuUnblock,
            false,
            () => _openModeration(f)
          )
        else
          (
            kFriendsMenuBlock,
            false,
            () => _confirmBlock(f.friendId, f.name, isFriend: true)
          ),
      (kFriendsMenuRemove, true, () => _confirmRemove(f.friendId, f.name)),
    ];
    final secilen = await showModalBottomSheet<VoidCallback>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x730F172A),
      constraints: const BoxConstraints(maxWidth: 460),
      builder: (sheetCtx) {
        final uzun = friendSinceLabel(f.since);
        return Container(
          decoration: const BoxDecoration(
            color: kPanel,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 24 + MediaQuery.of(sheetCtx).viewPadding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7D0DC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                KAvatar(url: f.avatarUrl, name: f.name, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _text)),
                      if (uzun != null)
                        Text(uzun,
                            style:
                                const TextStyle(fontSize: 12, color: _muted)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(height: 1, color: _border),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFEEF1F5)),
                InkWell(
                  onTap: () => Navigator.of(sheetCtx).pop(items[i].$3),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    alignment: Alignment.centerLeft,
                    child: Text(items[i].$1,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: items[i].$2 ? kRed : _text)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    secilen?.call();
  }
}

/// Web'in `underline underline-offset-2` küçük metin bağlantısı
/// ("Engelle", "Engellediklerim").
class _TextLink extends StatelessWidget {
  final String label;
  final double fontSize;
  final VoidCallback? onTap;
  const _TextLink({required this.label, required this.fontSize, this.onTap});

  @override
  Widget build(BuildContext context) => TapTarget(
        onTap: onTap,
        minHeight: 36,
        child: Text(
          trUpper(label),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: _muted,
            decoration: TextDecoration.underline,
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          letterSpacing: 1.5,
          color: _muted,
        ),
      );
}

int trCandidate(FriendCandidate a, FriendCandidate b) =>
    trCompare(a.name, b.name);

/// Web ConfirmDialog — Onayla/Vazgeç; true = onaylandı. PlayerScoreCard'ın
/// arkadaşlık simgesi de aynı diyaloğu kullanır (paylaşılan).
Future<bool> confirmFriendAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  // Tek kanonik kart `dialog_shell.dart` (15 Ağustos 2026).
  return showKConfirm(
    context,
    title: title,
    message: message,
    confirmLabel: trUpper(confirmLabel),
  );
}

/// Web InfoDialog — tek "Tamam" butonlu sonuç mesajı.
Future<void> showFriendInfoDialog(BuildContext context, String message) {
  return showKInfo(context, message: message);
}
