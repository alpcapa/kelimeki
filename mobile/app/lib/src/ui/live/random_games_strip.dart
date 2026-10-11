// Rastgele Oyuncu (3 Ekim 2026) — "Devam Edenler"in üstündeki yatay kayan
// ilan şeridi + benim bekleyen ilanım için "Bekliyor n/N" satırı. Web
// `src/components/RandomGamesStrip.tsx` portu; tasarım ve gerekçeler:
// `docs/decisions/random-opponent.md` (§4, §11, §15). §15 (4 Ekim 2026): şerit BENİM bekleyen ilanımı da kart
// olarak gösterir. Saf kurallar (süzgeç,
// metinler, aralıklar): `util/random_games.dart`.
//
// ⚠ Şerit Realtime ile BESLENEMEZ: Realtime RLS'e uyar ve başkasının açtığı
// ilan bana olay olarak gelmez (§11). Bu yüzden ekran GÖRÜNÜRKEN (uygulama
// ön planda) ve yalnızca bu widget takılıyken (Devam Edenler açıkken)
// yoklanır; öne dönüşte/çevrimiçine dönüşte de bir kez. Yalnızca ilk sayfa
// (20) — offset sayfalaması kayar, id ile tekilleştirilir.
//
// ⚠ Liste boşken şerit TAMAMEN gizlenir ama widget BAĞLI kalır (yoklama
// sürsün, yeni ilan gelince şerit belirsin).
//
// ⚠ Yatay kaydırma + SABİT yükseklik, iç içe DİKEY liste YOK
// (`mobile/CLAUDE.md` → "KModal'ın gövdesi ZATEN kaydırılabilir"): şerit
// ilan sayısı kaç olursa olsun sayfayı uzatmaz (isteğin asıl derdi) ve
// dikey kaydırmayı çalmaz — yatay `ListView` ayrı eksen.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trUpper;

import '../../data/online_games_api.dart';
import '../../util/error_message.dart';
import '../../util/online_status.dart';
import '../../util/random_games.dart';
import '../auth/k_avatar.dart';
import '../game/neo_box.dart';
import '../game/neo_button.dart';
import '../game/player_avatar_row.dart';
import '../tap_target.dart';
import '../tokens.dart';

const Color _text = kText;
const Color _muted = kMuted;
const Color _accent = kAccent;
const Color _border = kBorder;
const Color _panel = kPanel;
const Color _green = kGreen;

/// `user.id` → son çekilen ilanlar. Sekme değişince yeniden mount'ta şerit
/// boş başlamasın (web `stripCache`).
final Map<String, List<RandomListing>> _stripCache = {};

/// Testler arası sızıntıyı kesmek için.
void resetRandomStripCache() => _stripCache.clear();

/// KARE kart (4 Ekim 2026, kullanıcı): eni web
/// `basis-[min(7rem,calc((100%-24px)/3.25))] min-w-[84px]` — 3 TAM kart +
/// dördüncünün ~1/4'ü görünür (devamı olduğu belli olsun). 3 aralık = 24.
double randomCardWidth(double listWidth) {
  final w = (listWidth - 24) / 3.25;
  final capped = w > 112 ? 112.0 : w;
  return capped < 84 ? 84 : capped;
}

/// İçeriğin (avatar satırı + rozet/nokta satırı + durum + 32 px eylem +
/// dolgu/çerçeve) 1,0 ölçekte sığdığı alt sınır. Web `aspect-square` içerik
/// sığmazsa uzar (390 px'te ölçüldü: 103×108); Flutter yatay listede sonlu
/// yükseklik ister, bu yüzden `max(en, bu × yazı ölçeği)`.
const double kRandomCardMinHeight = 108;

/// Kart yüksekliği: kare; içerik sığmazsa ya da yazı ölçeği büyürse uzar.
double randomCardHeight(double width, double textScale) {
  final min = kRandomCardMinHeight * textScale;
  return width > min ? width : min;
}

/// Gölge (web `shadow-raised`: ~8 px aşağı/sağ taşar) liste kırpmasına
/// girmesin diye şeridin dikey dolgusu.
const double kRandomStripShadowPad = 8;

class RandomGamesStrip extends StatefulWidget {
  final OnlineGamesRepo repo;
  final OnlineStatus onlineStatus;

  /// Oturumun kullanıcı kimliği (STRING — `user` nesnesi değil).
  final String userId;

  /// `list_my_random_games` sonucu (`null` = alınamadı). Bekleyen creator/
  /// random ilanlarım şeride KART olarak eklenir (§15); kimlikleri
  /// başkaları listesinden düşülür.
  final List<MyRandomGame>? myRandom;

  /// İptal/Ayrıl sürerken o ilanın id'si (düğme kilitli).
  final String? busyRandomId;

  /// Kartımdaki "İptal" (kurucu) / "Ayrıl" (kabul eden).
  final void Function(MyRandomGame game) onLeaveMine;

  /// Başlıktaki "Rastgele oyun aç" — "Yeni Oyun Başlat" ile AYNI: kurulum
  /// ekranını açar.
  final VoidCallback onOpenCreate;

  /// Kabul başarılı: üst bileşen iletiyi gösterir, listeyi tazeler.
  final void Function(RandomGameResult result) onAccepted;

  /// Kabul reddedildi (ör. "Bu oyun doldu."): sunucunun Türkçe metni.
  final void Function(String text) onNotice;

  /// Test kancası — saat.
  final int Function()? nowMs;

  const RandomGamesStrip({
    super.key,
    required this.repo,
    required this.onlineStatus,
    required this.userId,
    required this.myRandom,
    this.busyRandomId,
    required this.onLeaveMine,
    required this.onOpenCreate,
    required this.onAccepted,
    required this.onNotice,
    this.nowMs,
  });

  @override
  State<RandomGamesStrip> createState() => _RandomGamesStripState();
}

class _RandomGamesStripState extends State<RandomGamesStrip>
    with WidgetsBindingObserver {
  late List<RandomListing> _listings =
      List.of(_stripCache[widget.userId] ?? const []);
  String? _busyId;
  bool _inflight = false;
  int _last = 0;
  Timer? _timer;

  int _now() => (widget.nowMs ?? () => DateTime.now().millisecondsSinceEpoch)();

  /// Uygulama ön planda mı — web `document.visibilityState === 'visible'`.
  /// `null` (henüz bildirilmedi) görünür sayılır.
  bool get _foreground {
    final s = WidgetsBinding.instance.lifecycleState;
    return s == null || s == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.onlineStatus.addListener(_onConnectivity);
    unawaited(_load(force: true));
    _timer = Timer.periodic(kRandomStripPoll, (_) => unawaited(_load()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onlineStatus.removeListener(_onConnectivity);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Öne dönüş: bir kez yokla (en az `kRandomStripMinGap` aralıkla).
    if (state == AppLifecycleState.resumed) unawaited(_load());
  }

  void _onConnectivity() {
    if (widget.onlineStatus.online) unawaited(_load());
  }

  Future<void> _load({bool force = false}) async {
    if (!mounted || _inflight) return;
    if (!_foreground) return;
    if (!widget.onlineStatus.online) return;
    final now = _now();
    if (!force && now - _last < kRandomStripMinGap.inMilliseconds) return;
    _inflight = true;
    _last = now;
    final rows =
        await widget.repo.fetchRandomListings(limit: kRandomStripLimit);
    _inflight = false;
    if (!mounted) return;
    // `null` = bilmiyoruz: ELDEKİ listeyi koru (boşla ezmek şeridi
    // sessizce kaldırırdı).
    if (rows != null) {
      _stripCache[widget.userId] = rows;
      setState(() => _listings = rows);
    }
  }

  Future<void> _accept(RandomListing l) async {
    if (_busyId != null) return;
    setState(() => _busyId = l.id);
    try {
      final sonuc = await widget.repo.acceptRandom(l.id);
      // Kabul edilen ilan şeritten hemen kalkar (yoklamayı beklemeden).
      if (mounted) {
        setState(() => _listings = [
              for (final x in _listings)
                if (x.id != l.id) x
            ]);
      }
      widget.onAccepted(sonuc);
    } catch (e) {
      widget.onNotice(friendlyErrorMessage(e,
          surface: 'rastgele-kabul', fallback: kRandomAcceptFallback));
    } finally {
      if (mounted) setState(() => _busyId = null);
      // Başarıda da başarısızlıkta da (ör. "Bu oyun doldu.") şeridi tazele.
      unawaited(_load(force: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = stripListings(_listings, widget.myRandom);
    if (visible.isEmpty) return const SizedBox.shrink();
    final olcek = MediaQuery.textScalerOf(context).scale(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  trUpper('$kRandomStripTitle · ${visible.length}'),
                  style: const TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: _muted),
                ),
              ),
              TapTarget(
                onTap: widget.onOpenCreate,
                minHeight: 36,
                minWidth: 36,
                // Başlıkla AYNI boy/yazı (10 px mono, büyük harf, harf
                // aralıklı), mavi + kalın, altı çizili DEĞİL — Arkadaşlar
                // penceresinin "Tüm oyuncular →" bağlantısıyla aynı desen.
                child: Text(
                  trUpper(kRandomStripCreate),
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(builder: (context, c) {
            final w = randomCardWidth(c.maxWidth);
            final h = randomCardHeight(w, olcek);
            return SizedBox(
              key: const Key('random-strip-list'),
              height: h + kRandomStripShadowPad * 2,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: kRandomStripShadowPad),
                clipBehavior: Clip.hardEdge,
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(
                  width: w,
                  height: h,
                  child: _ListingCard(
                    key: ValueKey('ilan-${visible[i].id}'),
                    listing: visible[i],
                    busy: _busyId != null,
                    leaveBusy: widget.busyRandomId == visible[i].id,
                    onAccept: () => _accept(visible[i]),
                    onLeave: () {
                      for (final g
                          in widget.myRandom ?? const <MyRandomGame>[]) {
                        if (g.id == visible[i].id) {
                          widget.onLeaveMine(g);
                          return;
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Dolu koltuk = yeşil nokta; boş (açık / henüz yanıtlamamış davetli) = içi
/// boş halka (web `SeatDots`).
class _SeatDots extends StatelessWidget {
  final List<String> seats;
  const _SeatDots({required this.seats});

  @override
  Widget build(BuildContext context) {
    final dolu = seats.where(seatDotFilled).length;
    return Semantics(
      label: '${seats.length} koltuktan $dolu dolu',
      image: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < seats.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Container(
              key: ValueKey(
                  'nokta-$i-${seatDotFilled(seats[i]) ? 'dolu' : 'bos'}'),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seatDotFilled(seats[i]) ? _green : Colors.transparent,
                border: Border.all(
                    color: seatDotFilled(seats[i]) ? _green : _muted,
                    width: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final StripListing listing;
  final bool busy;
  final bool leaveBusy;
  final VoidCallback onAccept;
  final VoidCallback onLeave;
  const _ListingCard(
      {super.key,
      required this.listing,
      required this.busy,
      required this.leaveBusy,
      required this.onAccept,
      required this.onLeave});

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final iki = l.playerCount == 2;
    final ad = l.creatorName ?? 'Oyuncu';
    final mine = l.mine;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: ShapeDecorationWithCssShadows(
        // Benim ilanım: web `border-accent/30 bg-accent/5`.
        color: mine != null ? _accent.withValues(alpha: 0.05) : _panel,
        borderColor: mine != null ? _accent.withValues(alpha: 0.3) : _border,
        radius: 10,
        shadows: kRaisedShadows, // web shadow-raised
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            KAvatar(url: l.creatorAvatarUrl, name: l.creatorName, size: 22),
            const SizedBox(width: 4),
            Expanded(
              child: Text(ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: _text)),
            ),
          ]),
          // Rozet + koltuk noktaları; dar kartta SARABİLİR (web flex-wrap).
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color:
                      iki ? const Color(0xFFE7F6FA) : const Color(0xFFF3ECFE),
                  border: Border.all(
                      color: iki
                          ? const Color(0xFFA9E4EF)
                          : const Color(0xFFDCC8FC)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${l.playerCount} kişi',
                    style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: iki
                            ? const Color(0xFF0A6076)
                            : const Color(0xFF4A1A90))),
              ),
              _SeatDots(seats: l.seats),
            ],
          ),
          // Durum mesajı ORTALI (web `text-center`).
          if (mine != null)
            Text(trUpper(kRandomMineWaiting),
                key: const Key('ilan-bekliyor'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 9,
                    height: 1.25,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                    color: _muted))
          else
            Text(seatsLeftLabel(l.openSeats),
                key: const Key('ilan-kalan'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 9,
                    height: 1.25,
                    color: _muted)),
          if (mine != null)
            // Benim ilanım (§15): "Kabul" YOK; küçük eylem.
            Semantics(
              button: true,
              label: mine == 'creator' ? kRandomCancelLabel : 'İlandan ayrıl',
              excludeSemantics: true,
              child: TapTarget(
                key: const Key('ilan-benim-eylem'),
                onTap: leaveBusy ? null : onLeave,
                minHeight: 32,
                minWidth: 32,
                child: Opacity(
                  opacity: leaveBusy ? 0.5 : 1,
                  child: Text(
                    mine == 'creator' ? kRandomMineCancel : kRandomLeaveLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kRed,
                      decoration: TextDecoration.underline,
                      decorationColor: kRed,
                    ),
                  ),
                ),
              ),
            )
          else
            Semantics(
              button: true,
              label: '$ad ilanını kabul et',
              excludeSemantics: true,
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: NeoButton(
                  label: trUpper(kRandomAcceptLabel),
                  variant: NeoButtonVariant.accent,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  onPressed: busy ? null : onAccept,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Benim bekleyen ilanım ("Devam Edenler" listesinde, oyun satırlarının
/// altında): koltuk avatarları (dolu = avatar, açık = kesik çerçeveli "?"),
/// "Bekliyor n/N", kurucu için "İlanı iptal et", kabul eden için "Ayrıl"
/// (ceza yok). Satıra dokunmak bir şey açmaz — oyun henüz başlamadı. Web
/// `RandomWaitingRow`.
class RandomWaitingRow extends StatelessWidget {
  final MyRandomGame game;
  final bool busy;
  final VoidCallback onLeave;
  const RandomWaitingRow({
    super.key,
    required this.game,
    required this.busy,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final creator = game.myRole == 'creator';
    final dolu = filledSeatCount(game.slots);
    final acik = game.slots.where(isOpenSeat).length;
    final bekleyenDavetli =
        game.slots.any((s) => s.isHuman && s.inviteStatus == 'pending');
    final durum = acik > 0
        ? kRandomWaitingSeat
        : bekleyenDavetli
            ? kRandomWaitingFriend
            : kRandomWaitingStarting;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const ShapeDecorationWithCssShadows(
        color: _panel,
        borderColor: _border,
        radius: 6,
        shadows: kRaisedShadows, // web shadow-raised
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: PlayerAvatarRow(players: [
                  for (final s in game.slots)
                    s.isHuman
                        ? AvatarRowPlayer(
                            name: s.name ?? 'Oyuncu', avatarUrl: s.avatarUrl)
                        : isOpenSeat(s)
                            ? const AvatarRowPlayer(
                                name: kRandomWaitingSeat, isOpen: true)
                            : const AvatarRowPlayer(
                                name: 'Yapay Zeka', isAi: true),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trUpper('Bekliyor $dolu/${game.playerCount}'),
              style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: kOrange),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: Text(durum,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 11, color: _muted)),
            ),
            TapTarget(
              onTap: busy ? null : onLeave,
              minHeight: 36,
              child: Opacity(
                opacity: busy ? 0.5 : 1,
                child: Text(
                  creator ? kRandomCancelLabel : kRandomLeaveLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kRed,
                    decoration: TextDecoration.underline,
                    decorationColor: kRed,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
