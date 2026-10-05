// Canlı oyun kurulumu — src/components/LiveGameCreateForm.tsx portu.
// Kompozisyon kuralı (online_game_ai_slot_rule migration'ı, sunucu da
// zorluyor): 2 kişilikte YZ'ye hiç izin yok (tam 1 arkadaş); 4 kişilikte
// en az 2 arkadaş, yalnızca 4. koltuk YZ olabilir. 2 arkadaşla gönderim
// 4. koltuğu DOĞRUDAN Yapay Zeka yapar (onay penceresi web 27 Eylül, port
// 1 Ekim 2026'da kalktı — ROADMAP #41 karar 12).
//
// 1 Ekim 2026 — ROADMAP #41'in form yarısı (web #663-#666, kararlar 11,
// 12, 15-21) porta geldi:
// - Seçilen rakipler oyuncu renginde KOLTUK KARTLARI; 4 kişide 2 arkadaşla
//   boş 4. koltuk "Yapay Zeka" olarak görünür (12). Kartta oyuncu numarası
//   filigranı (15). Boş koltuğa dokunmak listeye kaydırır, odak VERMEZ (18).
// - "Davet Gönder" / "Vazgeç" koltukların HEMEN altında (16).
// - Arama kutusunun altında "+ ARKADAŞINI DAVET ET" — pencere açmaz,
//   doğrudan paylaşım sayfası (11, 17). Eski "Arkadaş Ekle" satırı kalktı.
// - Kayan listede her zaman görünen kaydırma çubuğu (19).
// - "Tüm oyuncular →" / "← Arkadaşlar" (20): arkadaş olmayana EKLE · İSTEK
//   GİTTİ · KABUL ET; oyuna yalnız arkadaş çağrılır; arkadaş olmayana
//   dokunmak skor kartını açar.
// - "Sık oynadıkların / Hızlı seç" şeridi (21).
// - Gönderim sonrası "Davetin gönderildi" ekranı.
//
// Metinler web'le BİREBİR — `live_form_parity_test.dart` web kaynağını okur.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trLower;
import 'package:share_plus/share_plus.dart';

import '../../data/analytics.dart';
import '../../data/auth_service.dart';
import '../../data/chat_api.dart';
import '../../data/feedback_api.dart';
import '../../data/friends_api.dart';
import '../../data/online_games_api.dart';
import '../../data/games_api.dart';
import '../../data/stats_api.dart';
import '../../util/share_board.dart' show shareOriginFrom;
import '../auth/k_avatar.dart';
import '../friends/k_pill.dart';
import '../friends/player_directory.dart';
import '../game/neo_box.dart';
import '../game/neo_button.dart';
import '../game/player_colors.dart';
import '../rank/league_rank.dart';
import '../rank/rank_scores.dart';
import '../rank/rank_seal.dart';
import '../score/player_score_card_modal.dart';
import '../tap_target.dart';
import '../tokens.dart';
import '../loading_note.dart';
import '../form_input.dart';

const Color _text = kText;
const Color _muted = kMuted;
const Color _accent = kAccent;
const Color _border = kBorder;
const Color _panel = kPanel;

// Web metinleri — `live_form_parity_test.dart` bunları
// `LiveGameCreateForm.tsx`te arar.
const String kLiveFormSentTitle = 'Davetin gönderildi';
const String kLiveFormSentNote =
    'Davet 7 gün içinde kabul edilmezse iptal olur. Biri reddederse oyun kurulmaz.';
const String kLiveFormEmptySeat2 = 'Aşağıdan bir arkadaşını seç';
const String kLiveFormEmptySeat4 = 'Boş koltuk';
const String kLiveFormAiSeat = 'Yapay Zeka';
const String kLiveFormAiNote = 'Boş 4. koltuk yapay zeka olur';
const String kLiveFormHintTail =
    'kabul edince oyun başlar · her hamle için 48 saat';
const String kLiveFormNoFriends = 'Henüz hiç arkadaşın yok.';
const String kLiveFormBrowseAll = 'Tüm oyunculara göz at →';
const String kLiveFormToAll = 'Tüm oyuncular →';
const String kLiveFormToFriends = '← Arkadaşlar';
const String kLiveFormSearchHint = 'İsim ya da takma ad ara…';
const String kLiveFormNobody = 'Kimse bulunamadı.';

/// Paylaşım çağrısı — testler sahte bir fonksiyon enjekte eder.
typedef InviteSharer = Future<void> Function(String text, Rect? origin);

class LiveGameCreateForm extends StatefulWidget {
  final AuthService auth;
  final FriendsRepo friends;
  final OnlineGamesRepo onlineGames;

  /// Skor kartı (Tüm oyuncular → arkadaş olmayan kişi) ve rütbe mührü için.
  final StatsRepo? stats;
  final Future<GamesRepo>? games;
  final FeedbackRepo? feedback;
  final ChatRepo? chat;

  final VoidCallback onCancel;
  final VoidCallback onCreated;

  /// Arkadaşlar penceresinin OYNA'sından gelince: o arkadaş seçili açılır
  /// (web `initialFriendId`/`initialPlayerCount`, ROADMAP #41 karar 23).
  final String? initialFriendId;
  final int? initialPlayerCount;

  /// Test kancası — verilmezse sistem paylaşım sayfası.
  final InviteSharer? sharer;

  const LiveGameCreateForm({
    super.key,
    required this.auth,
    required this.friends,
    required this.onlineGames,
    required this.onCancel,
    required this.onCreated,
    this.stats,
    this.games,
    this.feedback,
    this.chat,
    this.initialFriendId,
    this.initialPlayerCount,
    this.sharer,
  });

  @override
  State<LiveGameCreateForm> createState() => _LiveGameCreateFormState();
}

class _LiveGameCreateFormState extends State<LiveGameCreateForm> {
  late int _playerCount = widget.initialPlayerCount == 4 ? 4 : 2;
  List<FriendRow>? _friends;
  late final List<String> _selected = [
    if (widget.initialFriendId != null) widget.initialFriendId!,
  ];
  bool _busy = false;
  String? _error;
  final _query = TextEditingController();
  ({List<String> names, bool withAi})? _sentTo;
  String? _lastUserId;
  bool _showAll = false;
  String? _busyId;
  bool _inviteBusy = false;
  List<String> _frequentIds = const [];

  /// "Hızlı seç" boşluklarını dolduran rastgele sıranın tohumu — form başına
  /// BİR kez (her çizimde karışsa avatarlar dokunurken yer değiştirirdi).
  final int _tohum = math.Random().nextInt(1 << 31);

  late final PlayerDirectory _dir;
  final GlobalKey _listeKey = GlobalKey();
  final ScrollController _listScroll = ScrollController();

  /// Arkadaş seçicideki isimlerin yanındaki rütbe mührü (18 Ağustos 2026).
  late final RankScores _rankScores;

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // GA4 `live_game_form_opened` → `live_game_created` hunisi.
    analytics.log('live_game_form_opened');
    _rankScores = RankScores(widget.stats)..addListener(_onChange);
    _dir = PlayerDirectory(widget.friends)..addListener(_onChange);
    _listScroll.addListener(_onListScroll);
    _lastUserId = widget.auth.user?.id;
    widget.auth.addListener(_onAuthEvent);
    _reloadFriends();
    _loadFrequent();
  }

  @override
  void dispose() {
    widget.auth.removeListener(_onAuthEvent);
    _query.dispose();
    _listScroll.dispose();
    _dir.removeListener(_onChange);
    _dir.dispose();
    _rankScores.removeListener(_onChange);
    _rankScores.dispose();
    super.dispose();
  }

  // Web 5 Ağustos dersi: form tam bir görünüm, hesap değişimini mount'ta
  // kalarak atlatabilir — arkadaş listesi user.id değişince yeniden çekilir.
  void _onAuthEvent() {
    final id = widget.auth.user?.id;
    if (id == _lastUserId) return;
    _lastUserId = id;
    if (mounted) setState(() => _friends = null);
    _reloadFriends();
    _loadFrequent();
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

  void _loadFrequent() {
    widget.friends.frequentOpponents(5).then((ids) {
      if (mounted) setState(() => _frequentIds = ids);
    });
  }

  void _onListScroll() {
    if (!_showAll || _dir.searchActive) return;
    final p = _listScroll.position;
    if (p.extentAfter < 80) _dir.loadMore();
  }

  void _setPlayerCount(int n) {
    if (n == _playerCount) return;
    setState(() {
      _playerCount = n;
      // 2↔4 kuralı tamamen farklı — seçimler sıfırlanır (web).
      _selected.clear();
    });
  }

  void _toggleFriend(String friendId) {
    setState(() {
      if (_playerCount == 2) {
        if (_selected.contains(friendId)) {
          _selected.clear();
        } else {
          _selected
            ..clear()
            ..add(friendId);
        }
        return;
      }
      if (_selected.contains(friendId)) {
        _selected.remove(friendId);
        return;
      }
      if (_selected.length >= 3) return;
      _selected.add(friendId);
    });
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
      _query.clear();
    });
    _dir.setQuery('');
    if (_showAll) _dir.open();
    if (_listScroll.hasClients) _listScroll.jumpTo(0);
  }

  bool get _canSubmit =>
      _playerCount == 2 ? _selected.length == 1 : _selected.length >= 2;

  FriendRow? _byId(String id) => (_friends ?? const <FriendRow>[])
      .where((f) => f.friendId == id)
      .firstOrNull;

  Future<void> _submit({required bool withAiLastSlot}) async {
    final user = widget.auth.user;
    if (user == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final slots = [
        NewGameSlot.human(user.id),
        for (final id in _selected) NewGameSlot.human(id),
        if (withAiLastSlot) const NewGameSlot.ai(),
      ];
      await widget.onlineGames.create(_playerCount, slots);
      analytics.log('live_game_created', {
        'player_count': _playerCount,
        'with_ai': withAiLastSlot ? 1 : 0, // GA4 parametresi bool almaz
      });
      if (!mounted) return;
      setState(() => _sentTo = (
            names: [
              for (final id in _selected) _byId(id)?.name ?? 'Bir arkadaşın',
            ],
            withAi: withAiLastSlot,
          ));
    } catch (e) {
      if (mounted) setState(() => _error = friendErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 4 kişilik + 2 arkadaş: 4. koltuk Yapay Zeka — ekrandaki koltuk kartı
  /// bunu zaten gösteriyor, ayrıca sorulmaz (ROADMAP #41 karar 12).
  Future<void> _handleSubmit() =>
      _submit(withAiLastSlot: _playerCount == 4 && _selected.length == 2);

  /// "Arkadaşını davet et" → DOĞRUDAN paylaşım (karar 17; web
  /// `useInviteShare`). Ankraj düğmenin KENDİ kutusu (iPad popover'ı
  /// `State.context` ile asılı kalıyordu — bkz. `shareOriginFrom`).
  Future<void> _shareInvite(BuildContext anchor) async {
    if (_inviteBusy) return;
    setState(() => _inviteBusy = true);
    try {
      final url = await widget.friends.inviteUrl();
      if (url == null || !mounted || !anchor.mounted) return;
      final origin = shareOriginFrom(anchor);
      final share = widget.sharer ??
          (String t, Rect? o) async {
            await SharePlus.instance
                .share(ShareParams(text: t, sharePositionOrigin: o));
          };
      await share('$inviteShareText\n$url', origin);
      analytics.log('invite_link_shared', {'source': 'live_game_form'});
    } finally {
      if (mounted) setState(() => _inviteBusy = false);
    }
  }

  Future<void> _iliskiIslemi(
      String id, Future<FriendRelation?> Function() islem) async {
    setState(() => _busyId = id);
    try {
      final yeni = await islem();
      _dir.patchRelation(id, yeni);
      if (yeni == FriendRelation.accepted) _reloadFriends();
    } catch (e) {
      debugPrint('[Kelimeki] arkadaşlık işlemi hatası: $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _openCard(FriendCandidate u) async {
    final stats = widget.stats;
    if (stats == null) return;
    await showPlayerScoreCard(
      context,
      stats: stats,
      userId: u.id,
      name: u.name,
      avatarUrl: u.avatarUrl,
      games: widget.games,
      friends: widget.friends,
      auth: widget.auth,
    );
    // Kartın içinden "Ekle"/"Kabul et" yapılmış olabilir — ilişki yeniden
    // okunur (web `kartiKapat`).
    final r = await widget.friends.relationWith(u.id);
    if (!mounted) return;
    _dir.patchRelation(u.id, r);
    if (r == FriendRelation.accepted) _reloadFriends();
  }

  void _scrollToList() {
    final ctx = _listeKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.02);
  }

  @override
  Widget build(BuildContext context) {
    final sent = _sentTo;
    if (sent != null) return _sentView(sent);

    final ids = <String>[
      for (final u in _dir.allUsers ?? const <FriendCandidate>[]) u.id,
      for (final u in _dir.results) u.id,
    ];
    if (ids.isNotEmpty) _rankScores.ensure(ids);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('OYUNCU SAYISI'),
        const SizedBox(height: 8),
        Row(children: [
          for (final n in const [2, 4]) ...[
            if (n == 4) const SizedBox(width: 8),
            Expanded(
              child: NeoButton(
                label: '$n KİŞİ',
                variant: _playerCount == n
                    ? NeoButtonVariant.accent
                    : NeoButtonVariant.neutral,
                // Web `toggleBtnCls`: text-sm (14/20) + py-3 = 46.
                fontSize: 14,
                lineHeight: 20 / 14,
                letterSpacing: 1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () => _setPlayerCount(n),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 20),
        _seatsBlock(),
        const SizedBox(height: 20),
        _actionsBlock(),
        const SizedBox(height: 20),
        _listBlock(),
      ],
    );
  }

  // ── Koltuklar ────────────────────────────────────────────────────────

  Widget _seatsBlock() {
    final seatCount = _playerCount - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _SectionLabel(_playerCount == 2
                  ? 'RAKİBİN'
                  : 'RAKİPLERİN · ${_selected.length}/3'),
            ),
            if (_playerCount == 4)
              const Text(kLiveFormAiNote,
                  style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 10, color: _muted)),
          ],
        ),
        const SizedBox(height: 8),
        if (_playerCount == 2)
          _seat(0, yatay: true)
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < seatCount; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _seat(i, yatay: false)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _seat(int i, {required bool yatay}) {
    // Rakip i. koltukta = oyunda (i + 2). oyuncu → `playerColors[i + 1]`.
    final col = playerColors[i + 1];
    final f = i < _selected.length ? _byId(_selected[i]) : null;
    final ai = _playerCount == 4 && i == 2 && _selected.length == 2;
    if (f != null) return _filledSeat(i, f, col, yatay: yatay);

    final govde = <Widget>[
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kVoid,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Text(ai ? '🤖' : '+',
            style: const TextStyle(fontSize: 18, height: 1, color: _muted)),
      ),
      SizedBox(width: yatay ? 12 : 0, height: yatay ? 0 : 6),
      Flexible(
        child: Text(
          ai
              ? kLiveFormAiSeat
              : yatay
                  ? kLiveFormEmptySeat2
                  : kLiveFormEmptySeat4,
          textAlign: yatay ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: _muted),
        ),
      ),
    ];
    final kutu = CustomPaint(
      key: ValueKey('koltuk-bos-$i'),
      foregroundPainter: const _DashedRRectPainter(
          color: Color(0xFFC7D0DC), width: 1.5, radius: 12),
      child: Container(
        padding: yatay
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
            : const EdgeInsets.fromLTRB(6, 12, 6, 10),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: yatay
            ? Row(children: govde)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center, children: govde),
      ),
    );
    if (ai) return kutu;
    // Boş koltuk → listeye kaydır. Odak VERİLMEZ: arama kutusuna odak
    // klavyeyi açıp listeyi örterdi (karar 18).
    return GestureDetector(
        behavior: HitTestBehavior.opaque, onTap: _scrollToList, child: kutu);
  }

  Widget _filledSeat(int i, FriendRow f, PlayerColor col,
      {required bool yatay}) {
    final kapat = Semantics(
      label: '${f.name} koltuğunu boşalt',
      button: true,
      excludeSemantics: true,
      child: TapTarget(
        onTap: () => _toggleFriend(f.friendId),
        minHeight: 28,
        minWidth: 28,
        // Gömülü yazı tiplerinde ✕ yok → ikon (KModal'ın kapatması gibi).
        child: Icon(Icons.close, size: 16, color: col.text),
      ),
    );
    // Oyuncu numarası filigranı (karar 15) — tahtadaki köşe filigranıyla
    // aynı dil: mono kalın, oyuncu rengi, %20 opaklık. Yatay kartta ✕'in
    // SOLUNDA, dikeyde sağ ALTTA.
    final filigran = Text(
      '${i + 2}',
      style: TextStyle(
        fontFamily: 'SpaceMono',
        fontWeight: FontWeight.bold,
        fontSize: yatay ? 56 : 40,
        height: 1,
        color: col.base.withValues(alpha: 0.2),
      ),
    );
    final ad = Text(
      f.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: yatay ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontSize: yatay ? 14 : 12,
        fontWeight: FontWeight.bold,
        color: col.text,
      ),
    );
    return Container(
      key: ValueKey('koltuk-dolu-$i'),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: col.tint,
        border: Border.all(color: col.base),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (yatay)
            Positioned(
                right: 48, top: 0, bottom: 0, child: Center(child: filigran))
          else
            Positioned(right: 6, bottom: 2, child: filigran),
          Padding(
            padding: yatay
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                : const EdgeInsets.fromLTRB(6, 12, 6, 10),
            child: yatay
                ? Row(children: [
                    KAvatar(url: f.avatarUrl, name: f.name, size: 36),
                    const SizedBox(width: 12),
                    Expanded(child: ad),
                    kapat,
                  ])
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KAvatar(url: f.avatarUrl, name: f.name, size: 36),
                      const SizedBox(height: 6),
                      ad,
                    ],
                  ),
          ),
          if (!yatay) Positioned(top: 2, right: 2, child: kapat),
        ],
      ),
    );
  }

  // ── Gönder / Vazgeç ──────────────────────────────────────────────────

  Widget _actionsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          // Web `flex-[1.5]` ↔ `flex-1` → 3:2.
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 52,
              child: NeoButton(
                label: _busy ? 'GÖNDERİLİYOR…' : 'DAVET GÖNDER',
                variant: NeoButtonVariant.orange,
                fontSize: 16,
                letterSpacing: 1,
                onPressed: (!_canSubmit || _busy) ? null : _handleSubmit,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: NeoButton(
                label: 'VAZGEÇ',
                variant: NeoButtonVariant.neutral,
                fontSize: 14,
                letterSpacing: 1,
                onPressed: _busy ? null : widget.onCancel,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          '${_playerCount == 2 ? 'Arkadaşın' : 'Arkadaşların'} $kLiveFormHintTail',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'SpaceMono', fontSize: 11, color: _muted),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 12, color: kRed)),
        ],
      ],
    );
  }

  // ── Arkadaş listesi / Tüm oyuncular ─────────────────────────────────

  Widget _listBlock() {
    final friends = _friends;
    final strip = _quickStrip();
    return Column(
      key: _listeKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(
              child:
                  _SectionLabel(_showAll ? 'TÜM OYUNCULAR' : 'ARKADAŞLARIN')),
          _LinkButton(_showAll ? kLiveFormToFriends : kLiveFormToAll,
              onTap: _toggleShowAll),
        ]),
        const SizedBox(height: 8),
        if (!_showAll && friends == null)
          const KLoadingNote(vertical: 16)
        else if (!_showAll && friends!.isEmpty)
          _noFriends()
        else ...[
          if (strip != null) strip,
          TextField(
            controller: _query,
            onChanged: (q) {
              setState(() {});
              if (_showAll) _dir.setQuery(q);
            },
            style: kInputTextStyle,
            decoration: kInputDecoration(hint: kLiveFormSearchHint),
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (btnCtx) => _InviteDashedButton(
              busy: _inviteBusy,
              onTap: () => _shareInvite(btnCtx),
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            // Her zaman görünen kaydırma çubuğu (karar 19): iOS kendi
            // çubuğunu yalnız kaydırırken çiziyor, "altta daha var" fark
            // edilmiyordu. İçerik taşmıyorsa çubuk çizilmez.
            child: Scrollbar(
              controller: _listScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _listScroll,
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _listRows(),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _noFriends() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          const Text(kLiveFormNoFriends,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 12, color: _muted)),
          const SizedBox(height: 10),
          Builder(
            builder: (btnCtx) => NeoButton(
              label: 'ARKADAŞINI DAVET ET',
              variant: NeoButtonVariant.accent,
              fontSize: 11,
              letterSpacing: 1,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: _inviteBusy ? null : () => _shareInvite(btnCtx),
            ),
          ),
          const SizedBox(height: 6),
          _LinkButton(kLiveFormBrowseAll, onTap: _toggleShowAll),
        ]),
      );

  /// "Sık oynadıkların" / "Hızlı seç" (karar 21) — sabit en fazla 5 avatar,
  /// kaydırma YOK. Dokunmak satırla AYNI (seçer/bırakır); seçilenin halkası
  /// oturacağı koltuğun renginde. Sık oynanan 5'ten azsa boş yerler form
  /// başına sabit rastgele arkadaşlarla dolar ve başlık "Hızlı seç" olur.
  /// Arkadaş 2'den azsa, arama yapılırken ve "Tüm oyuncular"da çizilmez.
  Widget? _quickStrip() {
    final friends = _friends;
    if (_showAll || _query.text.trim().isNotEmpty) return null;
    if (friends == null || friends.length < 2) return null;
    final sik = <FriendRow>[
      for (final id in _frequentIds)
        ...friends.where((f) => f.friendId == id).take(1),
    ];
    int anahtar(String id) {
      var h = _tohum;
      for (final c in id.codeUnits) {
        h = (h * 31 + c).toSigned(32);
      }
      return h;
    }

    final dolgu = [
      for (final f in friends)
        if (!sik.contains(f)) f
    ]..sort((a, b) => anahtar(a.friendId).compareTo(anahtar(b.friendId)));
    final dolguAl = dolgu.take(math.max(0, 5 - sik.length)).toList();
    final serit = [...sik, ...dolguAl];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(dolguAl.isEmpty ? 'SIK OYNADIKLARIN' : 'HIZLI SEÇ'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var k = 0; k < 5; k++) ...[
                if (k > 0) const SizedBox(width: 4),
                Expanded(
                  child: k < serit.length
                      ? _quickItem(serit[k])
                      : const SizedBox(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickItem(FriendRow f) {
    final sira = _selected.indexOf(f.friendId);
    final renk = sira >= 0 ? playerColors[sira + 1].base : null;
    return Semantics(
      button: true,
      selected: sira >= 0,
      label: '${f.name} — ${sira >= 0 ? 'seçimi kaldır' : 'seç'}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('hizli-${f.friendId}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleFriend(f.friendId),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: renk == null
                    ? null
                    : Border.all(
                        color: renk,
                        width: 3,
                        strokeAlign: BorderSide.strokeAlignOutside),
              ),
              child: KAvatar(url: f.avatarUrl, name: f.name, size: 46),
            ),
            const SizedBox(height: 4),
            Text(
              f.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: renk != null ? _text : _muted,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _listRows() {
    Widget empty(String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(t,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 12, color: _muted)),
        );

    if (!_showAll) {
      final q = trLower(_query.text.trim());
      final filtered = [
        for (final f in _friends ?? const <FriendRow>[])
          if (trLower(f.name).contains(q)) f
      ];
      if (filtered.isEmpty) return [empty(kLiveFormNobody)];
      return [
        for (final f in filtered) _friendRow(f.friendId, f.name, f.avatarUrl),
      ];
    }

    final liste = _dir.searchActive ? _dir.results : _dir.allUsers;
    if (liste == null || (_dir.searchActive && _dir.searching)) {
      return [const KLoadingNote(vertical: 16)];
    }
    if (liste.isEmpty && !(!_dir.searchActive && _dir.hasMore)) {
      return [empty(kLiveFormNobody)];
    }
    return [
      for (final u in liste)
        u.relation == FriendRelation.accepted
            ? _friendRow(u.id, u.name, u.avatarUrl)
            : _otherRow(u),
      if (!_dir.searchActive && _dir.hasMore && _dir.loadingMore)
        const KLoadingNote(vertical: 8),
    ];
  }

  Widget _friendRow(String id, String name, String? avatarUrl) {
    final checked = _selected.contains(id);
    final tier = _rankScores.tierOf(id);
    return Padding(
      key: ValueKey('friend-$id'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        button: true,
        selected: checked,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleFriend(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: ShapeDecorationWithCssShadows(
              color: _panel,
              borderColor: _border,
              radius: 6,
              shadows: kRaisedShadows,
            ),
            child: Row(children: [
              KAvatar(url: avatarUrl, name: name, size: 28),
              const SizedBox(width: 10),
              Expanded(child: _nameWithSeal(name, tier)),
              _CheckMark(checked: checked),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _otherRow(FriendCandidate u) {
    final busy = _busyId == u.id;
    final pill = switch (u.relation) {
      FriendRelation.pendingOutgoing => KPill(
          kind: KPillKind.gonderildi,
          semanticLabel: '${u.name} — isteği iptal et',
          onTap: busy
              ? null
              : () => _iliskiIslemi(u.id, () async {
                    await widget.friends.removeOrCancel(u.id);
                    return null;
                  }),
        ),
      FriendRelation.pendingIncoming => KPill(
          kind: KPillKind.kabul,
          semanticLabel: '${u.name} — isteği kabul et',
          onTap: busy
              ? null
              : () => _iliskiIslemi(u.id, () async {
                    await widget.friends.respond(u.id, accept: true);
                    return FriendRelation.accepted;
                  }),
        ),
      _ => KPill(
          kind: KPillKind.ekle,
          semanticLabel: '${u.name} — arkadaş ekle',
          onTap: busy
              ? null
              : () =>
                  _iliskiIslemi(u.id, () => widget.friends.sendRequest(u.id)),
        ),
    };
    return Padding(
      key: ValueKey('other-${u.id}'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kBg,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openCard(u),
              child: Row(children: [
                KAvatar(url: u.avatarUrl, name: u.name, size: 28),
                const SizedBox(width: 10),
                Expanded(
                    child: _nameWithSeal(u.name, _rankScores.tierOf(u.id))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          pill,
        ]),
      ),
    );
  }

  Widget _nameWithSeal(String name, RankTier? tier) => Row(children: [
        Flexible(
          child: Text(name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: _text)),
        ),
        if (tier != null) ...[
          const SizedBox(width: 4),
          RankSeal(tier: tier, size: 18),
        ],
      ]);

  // ── Gönderildi ekranı ────────────────────────────────────────────────

  Widget _sentView(({List<String> names, bool withAi}) sent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD6F3E1),
                shape: BoxShape.circle,
                border: Border.all(color: kGreen, width: 2),
              ),
              child: const Icon(Icons.check, size: 34, color: kGreen),
            ),
          ),
          const SizedBox(height: 12),
          const Text(kLiveFormSentTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                  color: _text)),
          const SizedBox(height: 12),
          Text(
            '${sent.names.join(', ')} kabul edince oyun başlar ve ilk sıra '
            'sende olur.${sent.withAi ? ' 4. koltuk Yapay Zeka.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.6, color: _muted),
          ),
          const SizedBox(height: 12),
          const Text(kLiveFormSentNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  height: 1.6,
                  color: _muted)),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 52,
              child: NeoButton(
                label: 'OYUNLARIMA GİT',
                variant: NeoButtonVariant.orange,
                fontSize: 14,
                letterSpacing: 1,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                onPressed: widget.onCreated,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          fontWeight: FontWeight.w700,
          color: _muted,
        ),
      );
}

/// Web `text-xs font-bold text-accent min-h-[36px]` bağlantısı.
class _LinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _LinkButton(this.text, {required this.onTap});
  @override
  Widget build(BuildContext context) => TapTarget(
        onTap: onTap,
        minHeight: 36,
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: _accent)),
      );
}

/// Web `CheckMark` — 16×16, kalın çerçeve.
class _CheckMark extends StatelessWidget {
  final bool checked;
  const _CheckMark({required this.checked});
  @override
  Widget build(BuildContext context) => Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: checked ? _accent : kBg,
          border: Border.all(color: checked ? _accent : _muted, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked
            ? const Icon(Icons.check, size: 11, color: Colors.white)
            : null,
      );
}

/// Arama kutusunun altındaki "+ ARKADAŞINI DAVET ET" — web: kesikli accent
/// çerçeve, açık mavi zemin, 44 yüksek.
class _InviteDashedButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _InviteDashedButton({required this.busy, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: busy ? null : onTap,
        child: CustomPaint(
          foregroundPainter:
              const _DashedRRectPainter(color: _accent, width: 1.5, radius: 6),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              busy ? '…' : '+  ARKADAŞINI DAVET ET',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: _accent,
              ),
            ),
          ),
        ),
      );
}

/// Kesikli yuvarlak çerçeve (web `border-dashed`).
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double width;
  final double radius;
  const _DashedRRectPainter(
      {required this.color, required this.width, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    final rrect = RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(width / 2), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.width != width || old.radius != radius;
}
