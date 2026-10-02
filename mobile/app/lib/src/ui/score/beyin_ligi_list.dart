// Beyin Ligi listesi — web `BeyinLigiList.tsx` portu (2 Ekim 2026).
//
// k-lig penceresinin "Beyin Ligi" sekmesi. Puan Ligi listesinin ikizi ama
// puan YOK: sıra yalnızca OHP'ye göre (sunucuda, `beyin_ligi_siralama`).
// Rütbe mührü de YOK — mühür toplam puandan türüyor, puansız listede
// anlamsız (kullanıcı kararı). Sayfalama ve "kaydırılamıyorsa kendiliğinden
// sonraki sayfa" kuralı `leaderboard_modal.dart`taki Puan Ligi listesiyle
// aynı (bkz. oradaki `_maybeAutoLoadIfNotScrollable` notu).
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/friends_api.dart';
import '../../data/games_api.dart';
import '../../data/stats_api.dart';
import '../../util/beyin_ligi.dart';
import '../auth/k_avatar.dart';
import '../loading_note.dart';
import '../text_scale.dart';
import '../tokens.dart';
import 'player_score_card_modal.dart';

const _initialPageSize = 10;
const _pageSize = 20;

class BeyinLigiList extends StatefulWidget {
  final AuthService auth;
  final StatsRepo stats;
  final Future<GamesRepo>? games;
  final FriendsRepo? friends;

  const BeyinLigiList({
    super.key,
    required this.auth,
    required this.stats,
    this.games,
    this.friends,
  });

  @override
  State<BeyinLigiList> createState() => _BeyinLigiListState();
}

class _BeyinLigiListState extends State<BeyinLigiList> {
  List<BeyinLigiRow>? _rows;
  bool _hasMore = true;
  bool _loadingMore = false;
  MyBeyinLigiRank? _mine;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.stats.beyinLigi(limit: _initialPageSize, offset: 0).then((rows) {
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _hasMore = rows.length == _initialPageSize;
      });
      _maybeAutoLoadIfNotScrollable();
    });
    final user = widget.auth.user;
    if (user != null) {
      widget.stats.myBeyinRank(user.id).then((r) {
        if (mounted) setState(() => _mine = r);
      });
    }
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 80) _loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeAutoLoadIfNotScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _loadingMore) return;
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) _loadMore();
    });
  }

  void _loadMore() {
    if (_loadingMore || !_hasMore || _rows == null) return;
    setState(() => _loadingMore = true);
    widget.stats
        .beyinLigi(limit: _pageSize, offset: _rows!.length)
        .then((page) {
      if (!mounted) return;
      setState(() {
        _rows = [...?_rows, ...page];
        _hasMore = page.length == _pageSize;
        _loadingMore = false;
      });
      _maybeAutoLoadIfNotScrollable();
    });
  }

  void _openCard(String userId, String name, String? avatarUrl) =>
      showPlayerScoreCard(
        context,
        stats: widget.stats,
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        games: widget.games,
        friends: widget.friends,
        auth: widget.auth,
      );

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    if (rows == null) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: const Center(child: KLoadingNote(vertical: 0)),
      );
    }
    final user = widget.auth.user;
    final mine = _mine;
    final meInList = user != null && rows.any((r) => r.userId == user.id);
    final remaining = mine != null && mine.rank == null
        ? gamesUntilBeyinLigi(mine.ohpGames)
        : 0;

    // `mainAxisSize.min` + listede `Flexible`: k-lig penceresi gövdesini
    // kaydırmıyor (`KModal.fillBody`), yani liste pencerede KALAN alana
    // sığar ve altındaki "senin sıran"/eşik kartı/not her zaman görünür.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            ScaledCell(
                width: 28,
                align: Alignment.centerLeft,
                child: _HeadLabel('SIRA')),
            SizedBox(width: 4),
            Expanded(child: _HeadLabel('OYUNCU')),
            ScaledCell(
                width: 34,
                align: Alignment.center,
                child: _HeadLabel('OYUN', align: TextAlign.center)),
            ScaledCell(
                width: 48, child: _HeadLabel('OHP', align: TextAlign.right)),
          ]),
        ),
        const SizedBox(height: 4),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                  'Henüz listeye giren yok. $kBeyinLigiMinGames oyunu '
                  'tamamlayan ilk sen ol!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 12, color: kMuted)),
            ),
          )
        else
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: rows.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= rows.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(_loadingMore ? 'Yükleniyor…' : '',
                            style: const TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 10,
                                color: kMuted)),
                      ),
                    );
                  }
                  final r = rows[i];
                  return BeyinLigiRowTile(
                    rank: r.sira,
                    name: r.shortName,
                    avatarUrl: r.avatarUrl,
                    games: r.ohpGames,
                    avgMoveScore: r.avgMoveScore,
                    isMe: user != null && r.userId == user.id,
                    onTap: () => _openCard(r.userId, r.shortName, r.avatarUrl),
                  );
                },
              ),
            ),
          ),
        if (user != null && mine != null && mine.rank != null && !meInList) ...[
          const SizedBox(height: 8),
          const _Divider('SENİN SIRAN'),
          BeyinLigiRowTile(
            rank: mine.rank!,
            name: 'Sen',
            avatarUrl: widget.auth.profile?.avatarUrl,
            games: mine.ohpGames,
            avgMoveScore: mine.avgMoveScore,
            isMe: true,
            onTap: () => _openCard(
                user.id, widget.auth.menuName, widget.auth.profile?.avatarUrl),
          ),
        ],
        if (user != null &&
            mine != null &&
            mine.rank == null &&
            remaining > 0) ...[
          const SizedBox(height: 8),
          const _Divider('SENİN DURUMUN'),
          BeyinLigiGateCard(
            avgMoveScore: mine.avgMoveScore,
            ohpGames: mine.ohpGames,
            remaining: remaining,
          ),
        ],
        const SizedBox(height: 8),
        const Text(kBeyinLigiNote,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 10,
                height: 1.5,
                color: kMuted)),
      ],
    );
  }
}

/// Eşiğin altındaki oyuncunun kartı — "N oyun daha" + ilerleme çubuğu.
class BeyinLigiGateCard extends StatelessWidget {
  final double? avgMoveScore;
  final int ohpGames;
  final int remaining;

  const BeyinLigiGateCard({
    super.key,
    required this.avgMoveScore,
    required this.ohpGames,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
        fontFamily: 'SpaceMono', fontSize: 11, height: 1.5, color: kText);
    const bold = TextStyle(fontWeight: FontWeight.bold);
    final done = ohpGames.clamp(0, kBeyinLigiMinGames);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.05),
        border: Border.all(color: kAccent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(style: base, children: [
              if (avgMoveScore != null) ...[
                const TextSpan(text: "OHP'n "),
                TextSpan(text: avgMoveScore!.toStringAsFixed(2), style: bold),
                const TextSpan(
                    text: ", ama Beyin Ligi'ne girmek için "
                        '$kBeyinLigiMinGames oyun gerekiyor. '),
              ],
              TextSpan(text: '$remaining oyun', style: bold),
              const TextSpan(text: ' daha oyna, listeye gir.'),
            ]),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: done / kBeyinLigiMinGames,
              minHeight: 6,
              backgroundColor: kBorder,
              color: kAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text('$ohpGames / $kBeyinLigiMinGames oyun',
              style: const TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 10, color: kMuted)),
        ],
      ),
    );
  }
}

class BeyinLigiRowTile extends StatelessWidget {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int games;
  final double? avgMoveScore;
  final bool isMe;
  final VoidCallback onTap;

  const BeyinLigiRowTile({
    super.key,
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.games,
    required this.avgMoveScore,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1 ? kGold : (rank <= 3 ? kAccent : kMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isMe ? kAccent.withValues(alpha: 0.1) : Colors.white,
            border: Border.all(color: isMe ? kAccent : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              ScaledCell(
                width: 28,
                align: Alignment.centerLeft,
                child: Text('$rank',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: rankColor)),
              ),
              KAvatar(url: avatarUrl, name: name, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 14, color: kText)),
              ),
              ScaledCell(
                width: 34,
                child: Text('$games',
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 11, color: kMuted)),
              ),
              ScaledCell(
                width: 48,
                child: Text(avgMoveScore?.toStringAsFixed(2) ?? '—',
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;
  const _Divider(this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider(color: kBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 9,
                  letterSpacing: 1,
                  color: kMuted)),
        ),
        const Expanded(child: Divider(color: kBorder)),
      ]);
}

class _HeadLabel extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _HeadLabel(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: align,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 9,
            letterSpacing: 1,
            color: kMuted),
      );
}
