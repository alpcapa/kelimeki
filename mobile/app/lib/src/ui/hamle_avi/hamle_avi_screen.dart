// "Hamle Avı" ekranı — web `src/components/HamleAvi.tsx` portu (ROADMAP #48,
// 3 Kasım 2026). Hazır bir tahta pozisyonu + 7 harflik raf: süre dolmadan en
// yüksek puanlı (bölge vergisi DAHİL net) hamleyi bul. Bulursan "Tebrikler",
// seri +1; süre biterse "Üzgünüz" ve seri 0. Kararlar:
// `docs/decisions/product-backlog.md` → "En iyi hamleyi bul".
//
// YALITIM (tanıtımla aynı, `TutorialGame`): kendi `GameController`'ı var;
// kayıt, bulut kaydı, `logGameStart`, `games` satırı, k-lig, istatistik ve
// terk cezası ÇALIŞMAZ. Motora DOKUNMAZ — pozisyon `restore` ile yüklenir,
// hamle gerçek `PlayAction`ından geçer (vergi dahil net puan = skor farkı).
//
// SÜRÜKLEME: `game_screen.dart`ın jestinin eşi (raf ↔ tahta, taslak taşı
// taşıma/geri alma, ıskalama kurtarma, çift dokunuşla zoom, joker). Jestin
// HİSSİ `drag_feel.dart`ta (ortak kaynak); MANTIĞI ekran başına — biri
// değişirse bu ekran da gözden geçirilir (mobile/CLAUDE.md "Etki Analizi").
//
// Bilerek FARKLI (web ile aynı): "Sınır İhlali" vergi onayı YOK (vergi
// bulmacanın parçası), sunucu kelime doğrulaması YOK (yerel sözlük), tanıtım
// balonları/eğitim ipuçları YOK.
import 'dart:async';
import 'dart:math' show Random;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kelimeki_core/kelimeki_core.dart';

import '../../data/auth_service.dart';
import '../../data/chat_api.dart';
import '../../data/feedback_api.dart';
import '../../data/friends_api.dart';
import '../../data/games_api.dart';
import '../../data/hamle_avi_api.dart';
import '../../data/meaning_store.dart';
import '../../data/stats_api.dart';
import '../../game/game_controller.dart';
import '../../game/move_status.dart';
import '../../storage/hamle_avi_store.dart';
import '../../util/hamle_avi.dart';
import '../auth/account_button.dart';
import '../game/board_fit.dart';
import '../game/board_widget.dart';
import '../game/board_zoom.dart';
import '../game/dialog_shell.dart';
import '../game/drag_feel.dart';
import '../game/fluid.dart';
import '../game/logo_mark.dart';
import '../game/meaning_modal.dart';
import '../game/modal_shell.dart';
import '../game/neo_button.dart';
import '../game/player_colors.dart';
import '../game/rack_widget.dart';
import '../game/tile_widget.dart';
import '../game/wild_letter_sheet.dart';
import '../tap_target.dart';
import '../tokens.dart';

/// Web `Phase` — 'review': süre bitti, doğru hamle TAHTADA yerleşik görünür.
enum HamleAviPhase { loading, intro, play, found, missed, review, exhausted }

/// Bankayı asset'ten yükler (web: lazy chunk `import('hamleAviBank.json')`).
Future<List<HamleAviPosition>> loadHamleAviBankAsset() async {
  final raw = await rootBundle.loadString('assets/hamle_avi/bank.json');
  return parseHamleAviBank(raw);
}

abstract class _DragSource {
  Tile get tile;
}

class _RackSource implements _DragSource {
  final int index;
  @override
  final Tile tile;
  const _RackSource(this.index, this.tile);
}

class _PlacedSource implements _DragSource {
  final int r, c;
  @override
  final Tile tile;
  const _PlacedSource(this.r, this.c, this.tile);
}

class _DragRef {
  final _DragSource source;
  final Offset start;
  bool moved = false;
  _DragRef({required this.source, required this.start});
}

class _Ghost {
  final Offset global;
  final _DragSource source;
  final String? overKey;
  final bool overValid;
  const _Ghost({
    required this.global,
    required this.source,
    required this.overKey,
    required this.overValid,
  });
}

class HamleAviScreen extends StatefulWidget {
  final String playerName;
  final Future<SetWordSource> words;
  final HamleAviStore store;

  /// null → sunucu yok (misafir/offline): yalnızca cihaz deposu.
  final HamleAviGateway? gateway;

  /// Anonim cihaz kodu (ölçüm olayı için); verilmezse olay yazılmaz.
  final Future<String?> Function()? anonId;
  final Future<List<HamleAviPosition>> Function() loadBank;
  final MeaningStore? meanings;
  final AuthService? auth;
  final StatsRepo? stats;
  final Future<GamesRepo>? games;
  final FeedbackRepo? feedback;
  final FriendsRepo? friends;
  final ChatRepo? chat;
  final VoidCallback onExit;
  final Random? rng;

  const HamleAviScreen({
    super.key,
    required this.playerName,
    required this.words,
    required this.store,
    required this.onExit,
    this.gateway,
    this.anonId,
    this.loadBank = loadHamleAviBankAsset,
    this.meanings,
    this.auth,
    this.stats,
    this.games,
    this.feedback,
    this.friends,
    this.chat,
    this.rng,
  });

  @override
  State<HamleAviScreen> createState() => _HamleAviScreenState();
}

class _HamleAviScreenState extends State<HamleAviScreen> {
  late GameController _controller;
  GameState get _state => _controller.state;

  HamleAviPhase _phase = HamleAviPhase.loading;
  SetWordSource? _words;
  bool _loadError = false;
  HamleAviStreak _streak = const HamleAviStreak(0, 0);
  int _remainingMs = kHamleAviSeconds * 1000;
  bool _leaveOpen = false;
  int _lastNet = 0;
  ({String text, MessageKind kind})? _note;

  List<HamleAviPosition>? _bank;
  HamleAviPosition? _pos;
  GameState? _initial;
  HamleAviBestMove? _solution;
  final Set<int> _logged = {};
  Set<int> _seen = {};
  late final Random _rng = widget.rng ?? Random();
  DateTime _endsAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _ticker;
  bool _alive = true;
  bool _resultOpen = false;

  // Sürükleme / zoom (game_screen.dart ile aynı yapı)
  final GlobalKey _gridKey = GlobalKey();
  final GlobalKey _rackKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _viewportKey = GlobalKey();
  final BoardZoomController _zoom = BoardZoomController();
  BoardPanRef? _panRef;
  Offset? _boardTapDown;
  DateTime _swallowTapsUntil = DateTime.fromMillisecondsSinceEpoch(0);
  _DragRef? _dragRef;
  _DragSource? _hiddenSource;
  final ValueNotifier<_Ghost?> _dragNotifier = ValueNotifier(null);
  ({int r, int c, Offset pos})? _reviewTap;

  // Oyuncu = pozisyonun sahibi, `state.current` DEĞİL: doğru hamle `PlayAction`
  // ile oynanınca reducer sırayı rakibe geçirir; `state.current`e bakmak
  // "Tebrikler" penceresinin arkasında rafı rakibin dolgu taşlarına çevirirdi.
  int get _ownerIdx => _initial?.current ?? _state.current;
  Player get _me =>
      _state.players[_ownerIdx.clamp(0, _state.players.length - 1)];
  bool get _canAct => _phase == HamleAviPhase.play;

  @override
  void initState() {
    super.initState();
    _controller = GameController(words: _wordsPlaceholder, autoPlayAi: false)
      ..restore(hamleAviPositionToState(_emptyPosition, widget.playerName));
    _controller.addListener(_onState);
    _streak = HamleAviStreak(0, widget.store.load().best);
    _seen = {...widget.store.load().seen};
    unawaited(_load());
  }

  // `GameController` sözlüğü kurucuda ister; gerçek sözlük asenkron geldiğinden
  // başlangıçta boş bir kaynak, yüklenince yerine yenisi konur (`_load`).
  static final SetWordSource _wordsPlaceholder = SetWordSource(const []);

  @override
  void dispose() {
    _alive = false;
    _ticker?.cancel();
    _controller.removeListener(_onState);
    _controller.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  String? get _userId => widget.auth?.user?.id;

  // ── Veri: sözlük + banka + sunucu eşitlemesi ───────────────────────────
  Future<void> _load() async {
    try {
      final results = await Future.wait<Object?>([
        widget.words,
        widget.loadBank(),
        if (_userId != null && widget.gateway != null)
          widget.gateway!.fetch().timeout(const Duration(milliseconds: 2500),
              onTimeout: () => null)
        else
          Future<Object?>.value(null),
      ]);
      if (!_alive) return;
      _words = results[0]! as SetWordSource;
      _bank = results[1]! as List<HamleAviPosition>;
      final server = results[2] as HamleAviServer?;
      final merged = server != null
          ? await widget.store.mergeWithServer(server.best, server.seen)
          : widget.store.load();
      if (!_alive) return;
      _seen = {...merged.seen};
      // Gerçek sözlükle yeni bir kabuk: oyun içi doğrulama (PLAY) buna bakar.
      final old = _controller;
      old.removeListener(_onState);
      _controller = GameController(words: _words!, autoPlayAi: false);
      _controller.addListener(_onState);
      old.dispose();
      setState(() => _streak = HamleAviStreak(_streak.streak, merged.best));
      if (_userId != null) {
        unawaited(widget.gateway?.report(merged.best, merged.seen));
      }
      _loadNext(false);
    } catch (_) {
      if (_alive) setState(() => _loadError = true);
    }
  }

  /// Sıradaki görülmemiş bulmacayı yükler; banka bittiyse 'exhausted'.
  void _loadNext(bool skipIntro) {
    final bank = _bank;
    if (bank == null) return;
    final pos = hamleAviPickNext(bank, _seen, _rng);
    if (pos == null) {
      _setPhase(HamleAviPhase.exhausted);
      return;
    }
    // Görüldü sayılır: ekrana geldiği an (bulamasa da tekrar çıkmaz).
    _seen.add(pos.id);
    unawaited(widget.store.save(seen: _seen.toList()..sort()));
    _pos = pos;
    final st = hamleAviPositionToState(pos, widget.playerName);
    _initial = st;
    _solution = null;
    _zoom.reset();
    _controller.restore(st);
    _note = null;
    _remainingMs = kHamleAviSeconds * 1000;
    if (skipIntro || widget.store.load().introHidden) {
      _startClock();
      _setPhase(HamleAviPhase.play);
    } else {
      _setPhase(HamleAviPhase.intro);
    }
  }

  void _setPhase(HamleAviPhase p) {
    if (!_alive) return;
    setState(() => _phase = p);
    _syncTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_alive) return;
      if (_phase == p) {
        if (p == HamleAviPhase.intro) unawaited(_showIntro());
        if (p == HamleAviPhase.found ||
            p == HamleAviPhase.missed ||
            p == HamleAviPhase.exhausted) {
          unawaited(_showResult());
        }
      }
    });
  }

  // ── Geri sayım ─────────────────────────────────────────────────────────
  // Yalnızca 'play' evresinde ve çıkış uyarısı kapalıyken akar; durunca kalan
  // süre saklanır, devam edince oradan sürer.
  void _startClock() =>
      _endsAt = clock.now().add(Duration(milliseconds: _remainingMs));

  void _syncTicker() {
    final running = _phase == HamleAviPhase.play && !_leaveOpen;
    if (running && _ticker == null) {
      _startClock();
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        final left = _endsAt.difference(clock.now()).inMilliseconds;
        if (left <= 0) {
          _ticker?.cancel();
          _ticker = null;
          setState(() => _remainingMs = 0);
          _finish(false, 0);
        } else {
          setState(() => _remainingMs = left);
        }
      });
    } else if (!running && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  // ── Sonuç / ölçüm ──────────────────────────────────────────────────────
  /// Bu bulmacanın sonucunu BİR KEZ ölç (tekrar çağrılırsa yok sayılır).
  void _logResult(String result) {
    final id = _pos?.id;
    if (id == null || !_logged.add(id)) return;
    final elapsed = result == 'missed'
        ? kHamleAviSeconds
        : (kHamleAviSeconds - _remainingMs / 1000).round();
    final before = _streak.streak;
    final g = widget.gateway;
    final anon = widget.anonId;
    if (g == null || anon == null) return;
    unawaited(() async {
      try {
        await g.logEvent(
          anonId: await anon(),
          puzzleId: id,
          result: result,
          seconds: elapsed,
          streakBefore: before,
        );
      } catch (_) {}
    }());
  }

  void _finish(bool found, int net) {
    _logResult(found ? 'found' : 'missed'); // seri GÜNCELLENMEDEN önce
    final next = found ? hamleAviOnFound(_streak) : hamleAviOnMissed(_streak);
    _streak = next;
    _lastNet = net;
    // Süre dolarken açık kalan joker penceresi sonuçla çakışmasın.
    _dismissTopSheet();
    if (!found && _initial != null) {
      final init = _initial!;
      // Doğru hamleyi pencere açıkken arka planda bul; "Kapat"a basılınca hazır olsun.
      Timer(const Duration(milliseconds: 50), () {
        if (_alive && _words != null) {
          _solution ??= hamleAviFindBestNetMove(init, _words!);
        }
      });
    }
    final best = next.best > widget.store.load().best
        ? next.best
        : widget.store.load().best;
    unawaited(() async {
      final local = await widget.store.save(best: best);
      if (_userId != null) {
        await widget.gateway?.report(local.best, local.seen);
      }
    }());
    _setPhase(found ? HamleAviPhase.found : HamleAviPhase.missed);
  }

  /// Açık joker penceresi vb. rotaları kapatır (yalnızca bizim açtıklarımız).
  void _dismissTopSheet() {
    if (_wildOpen) {
      _wildOpen = false;
      Navigator.of(context, rootNavigator: false).maybePop();
    }
  }

  bool _wildOpen = false;

  // ── Hamle sonucu: `PlayAction` başarılıysa tur sayacı değişir ───────────
  void _onState() {
    if (!mounted) return;
    final init = _initial;
    final pos = _pos;
    if (_phase == HamleAviPhase.play &&
        init != null &&
        pos != null &&
        _state.turnCount != init.turnCount) {
      final net = hamleAviNetGain(init, _state);
      if (hamleAviIsCorrect(net, pos)) {
        _finish(true, net);
      } else {
        // Geçerli ama daha iyisi var: pozisyon sıfırlanır, süre SÜRER
        // (kullanıcı onayı 3 Kas 2026: süre SIFIRLANMAZ).
        _note = (
          text: '$net puan aldın — daha iyisi var, tekrar dene.',
          kind: MessageKind.warn
        );
        _controller.restore(init);
        return;
      }
    }
    // "N puan aldın" notu geçici: yeni taş konunca kalkar (canlı mesajı örtmesin).
    if (_state.placed.isNotEmpty && _note?.kind == MessageKind.warn) {
      _note = null;
    }
    setState(() {});
  }

  // ── Anlam penceresi ────────────────────────────────────────────────────
  Future<void> _openMeaning(List<String> words) async {
    final store = widget.meanings;
    if (store == null) return;
    await showMeaningModal(context, store.lookup, words,
        isUnavailable: () => store.unavailable);
  }

  /// Review'da (doğru hamle tahtada): dokunulan karedeki kelime(ler) — taslak
  /// = DOĞRU HAMLE dahil. Taslak kuralı burada GEÇERSİZ: taslak cevabın kendisi.
  Future<void> _openMeaningAt(int r, int c) => _openMeaning([
        fullWordAt(_state.board, _state.placed, r, c, 0, 1),
        fullWordAt(_state.board, _state.placed, r, c, 1, 0),
      ]);

  // ── Yerleştirme / dokunuş ──────────────────────────────────────────────
  Future<String?> _askWild({bool editing = false}) async {
    _wildOpen = true;
    final choice = await showWildLetterSheet(context, editing: editing);
    _wildOpen = false;
    if (!_alive || !_canAct) return null;
    if (choice?.recallRequested == true) return '\u0000recall';
    return choice?.letter;
  }

  Future<void> _tapDraft(int r, int c) async {
    final tile = _state.placed[cellKey(r, c)];
    if (tile == null || !_canAct) return;
    _zoom.markUnpairableTap();
    if (tile.wild) {
      final res = await _askWild(editing: true);
      if (res == null) return;
      if (res == '\u0000recall') {
        _controller.dispatch(RecallCellAction(r: r, c: c));
      } else {
        _controller.dispatch(SetWildLetterAction(r: r, c: c, wildLetter: res));
      }
    } else {
      _controller.dispatch(RecallCellAction(r: r, c: c));
    }
  }

  /// Iskalanan dokunuşu kurtarır (game_screen `_nearbyDraftCell` ikizi): taslak
  /// sürerken oynanmış/boş hücreye dokunulduğunda komşusundaki taslağı hedef sayar.
  (int, int)? _nearbyDraftCell(int r, int c, Offset global) {
    final adaylar = <(int, int)>[];
    void ekle(int rr, int cc) {
      if (rr < 0 || rr >= boardSize || cc < 0 || cc >= boardSize) return;
      if (_state.placed[cellKey(rr, cc)] != null) adaylar.add((rr, cc));
    }

    ekle(r - 1, c);
    ekle(r + 1, c);
    ekle(r, c - 1);
    ekle(r, c + 1);
    if (adaylar.isEmpty) return null;
    if (adaylar.length == 1) return adaylar.first;
    final grid = _boxOf(_gridKey);
    if (grid == null) return null;
    final local = grid.globalToLocal(global);
    const gap = 3.0;
    final strideX = (grid.size.width + gap) / boardSize;
    final strideY = (grid.size.height + gap) / boardSize;
    double uzaklik((int, int) a) {
      final cx = a.$2 * strideX + (strideX - gap) / 2;
      final cy = a.$1 * strideY + (strideY - gap) / 2;
      return (local - Offset(cx, cy)).distanceSquared;
    }

    adaylar.sort((a, b) => uzaklik(a).compareTo(uzaklik(b)));
    return uzaklik(adaylar[0]) < uzaklik(adaylar[1]) * 0.8 ? adaylar[0] : null;
  }

  Future<void> _handleCellTap(int r, int c, Offset global) async {
    final k = cellKey(r, c);
    if (_phase == HamleAviPhase.review) {
      if (_state.board[r][c] != null || _state.placed[k] != null) {
        await _openMeaningAt(r, c);
      }
      return;
    }
    if (!_canAct) return;
    // Çift dokunuşla zoom: dokunuşun kendi işinden ÖNCE sorulur.
    if (_state.board[r][c] == null) {
      if (_registerZoomTap(global)) return;
      if (_state.placed[k] == null) _zoom.registerPairableTap(global);
    } else {
      _zoom.markUnpairableTap();
    }
    final hasDraft = _state.placed.isNotEmpty;
    if (_state.board[r][c] != null) {
      if (hasDraft) {
        final hedef = _nearbyDraftCell(r, c, global);
        if (hedef != null) await _tapDraft(hedef.$1, hedef.$2);
        return;
      }
      await _openMeaning([
        fullWordAt(_state.board, const {}, r, c, 0, 1),
        fullWordAt(_state.board, const {}, r, c, 1, 0),
      ]);
      return;
    }
    if (_state.placed[k] != null) {
      await _tapDraft(r, c);
      return;
    }
    // Seçili raf taşı yokken boş hücreye ıskalama: komşudaki taslağı geri al.
    if (_state.selectedTile == null) {
      if (hasDraft) {
        final hedef = _nearbyDraftCell(r, c, global);
        if (hedef != null) await _tapDraft(hedef.$1, hedef.$2);
      }
      return;
    }
    await _placeAt(r, c, _state.selectedTile!);
  }

  Future<void> _placeAt(int r, int c, int rackIndex) async {
    final rack = _me.rack;
    if (rackIndex < 0 || rackIndex >= rack.length) return;
    if (rack[rackIndex].letter == '?') {
      final letter = await _askWild();
      if (letter == null || letter == '\u0000recall') return;
      _controller.dispatch(PlaceTileAction(
          r: r, c: c, rackIndex: rackIndex, wildLetter: letter));
      return;
    }
    _controller.dispatch(PlaceTileAction(r: r, c: c, rackIndex: rackIndex));
  }

  bool _registerZoomTap(Offset global) {
    if (clock.now().isBefore(_swallowTapsUntil)) return true;
    if (!_zoom.tryCompletePair(global)) return false;
    _toggleZoomAt(global);
    return true;
  }

  void _toggleZoomAt(Offset global) {
    final grid = _boxOf(_gridKey);
    if (grid == null) return;
    final vp = _boxOf(_viewportKey);
    _zoom.toggleAt(
      grid.globalToLocal(global) + const Offset(kBoardPad, kBoardPad),
      vp?.size ?? grid.size,
    );
  }

  // ── Sürükleme geometrisi (game_screen.dart ile aynı formüller) ─────────
  RenderBox? _boxOf(GlobalKey key) =>
      key.currentContext?.findRenderObject() as RenderBox?;

  double _liftedY(double y) {
    final box = _boxOf(_viewportKey) ?? _boxOf(_gridKey);
    final lifted = y - kDragLift;
    if (box == null) return lifted;
    final top = box.localToGlobal(Offset.zero).dy;
    return lifted < top + 1 ? top + 1 : lifted;
  }

  (int, int)? _cellAtGlobal(Offset global) {
    final grid = _boxOf(_gridKey);
    if (grid == null) return null;
    final vp = _boxOf(_viewportKey);
    if (vp != null) {
      final v = vp.globalToLocal(global);
      if (v.dx < 0 ||
          v.dy < 0 ||
          v.dx >= vp.size.width ||
          v.dy >= vp.size.height) {
        return null;
      }
    }
    final local = grid.globalToLocal(global);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx >= grid.size.width ||
        local.dy >= grid.size.height) {
      return null;
    }
    const gap = 3.0;
    final strideX = (grid.size.width + gap) / boardSize;
    final strideY = (grid.size.height + gap) / boardSize;
    final c = (local.dx / strideX).floor().clamp(0, boardSize - 1);
    final r = (local.dy / strideY).floor().clamp(0, boardSize - 1);
    return (r, c);
  }

  bool _rackContains(Offset global) {
    final box = _boxOf(_rackKey);
    if (box == null) return false;
    return (box.localToGlobal(Offset.zero) & box.size).contains(global);
  }

  bool _isCellFreeFor(_DragSource source, int r, int c) {
    if (source is _PlacedSource && source.r == r && source.c == c) return false;
    return _state.board[r][c] == null && _state.placed[cellKey(r, c)] == null;
  }

  bool _pointHitsCellBox(Offset global) {
    final grid = _boxOf(_gridKey);
    if (grid == null) return true;
    final local = grid.globalToLocal(global);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx >= grid.size.width ||
        local.dy >= grid.size.height) {
      return false;
    }
    const gap = 3.0;
    final strideX = (grid.size.width + gap) / boardSize;
    final strideY = (grid.size.height + gap) / boardSize;
    const eps = 0.5;
    return (local.dx % strideX) < strideX - gap + eps &&
        (local.dy % strideY) < strideY - gap + eps;
  }

  // ── Tahta pan'i (yalnızca zoom açıkken) ────────────────────────────────
  void _boardPointerDown(PointerDownEvent e) {
    if (_dragRef != null) return;
    _boardTapDown = e.position;
    if (!_zoom.zoomed || _panRef != null) return;
    setState(() => _panRef = BoardPanRef(e.position));
  }

  void _boardPointerMove(PointerMoveEvent e) {
    final down = _boardTapDown;
    if (down != null &&
        (e.position - down).distance >= dragThresholdFor(e.kind)) {
      _boardTapDown = null;
    }
    final p = _panRef;
    if (p == null) return;
    if (!p.moved) {
      if ((e.position - p.start).distance < dragThresholdFor(e.kind)) return;
      p.moved = true;
    }
    final grid = _boxOf(_gridKey);
    if (grid == null) return;
    _zoom.panBy(e.delta, _boxOf(_viewportKey)?.size ?? grid.size);
  }

  void _boardPointerUp(PointerUpEvent e) {
    final down = _boardTapDown;
    _boardTapDown = null;
    _endBoardPan();
    if (down == null) return;
    if (_pointHitsCellBox(down)) return;
    if (!_canAct) return;
    if (_registerZoomTap(down)) return;
    _zoom.registerPairableTap(down);
  }

  void _endBoardPan() {
    _boardTapDown = null;
    final p = _panRef;
    if (p == null) return;
    setState(() => _panRef = null);
    if (p.moved) {
      _swallowTapsUntil = clock.now().add(const Duration(milliseconds: 120));
      _zoom.markUnpairableTap();
    }
  }

  // ── Taş sürükleme ──────────────────────────────────────────────────────
  void _beginTileDrag(_DragSource source, PointerDownEvent e) {
    if (!_canAct) return;
    setState(() => _dragRef = _DragRef(source: source, start: e.position));
  }

  void _moveTileDrag(PointerMoveEvent e) {
    final d = _dragRef;
    if (d == null) return;
    if (!d.moved) {
      if ((e.position - d.start).distance < dragThresholdFor(e.kind)) return;
      d.moved = true;
      setState(() => _hiddenSource = d.source);
    }
    final lifted = Offset(e.position.dx, _liftedY(e.position.dy));
    final cell = _cellAtGlobal(lifted);
    String? overKey;
    var overValid = false;
    if (cell != null) {
      overKey = cellKey(cell.$1, cell.$2);
      overValid = _isCellFreeFor(d.source, cell.$1, cell.$2);
    }
    _dragNotifier.value = _Ghost(
        global: lifted,
        source: d.source,
        overKey: overKey,
        overValid: overValid);
  }

  Future<void> _dokunusOlarakIsle(_DragSource s, Offset globalPos) async {
    if (s is _RackSource) {
      _zoom.markUnpairableTap();
      if (!_canAct) return;
      _controller.dispatch(SelectTileAction(s.index));
    } else if (s is _PlacedSource) {
      // Çiftin İKİNCİSİYSE geri alma yutulur ve zoom değişir.
      if (_registerZoomTap(globalPos)) return;
      await _tapDraft(s.r, s.c);
    }
  }

  Future<void> _endTileDrag(PointerUpEvent e) async {
    final d = _dragRef;
    setState(() {
      _dragRef = null;
      _hiddenSource = null;
    });
    _dragNotifier.value = null;
    if (d == null) return;
    // Parmak tahtadayken süre bitmiş olabilir: sonuç aşamasında bırakma iş yapmaz.
    if (!_canAct) return;
    if (!d.moved) {
      await _dokunusOlarakIsle(d.source, e.position);
      return;
    }
    final s = d.source;
    final gittigi = (e.position - d.start).distance;
    final rafinUstunde = s is _RackSource && _rackContains(e.position);
    // Konmuş taş hayaletin GÖSTERDİĞİ boş hücreye bırakıldıysa TAŞIMA'dır
    // (kısa mesafe "geri al" sanılmasın — 23 Ekim 2026 kuralı).
    var tasimaHedefi = false;
    if (s is _PlacedSource) {
      final hedef =
          _cellAtGlobal(Offset(e.position.dx, _liftedY(e.position.dy)));
      tasimaHedefi = hedef != null && _isCellFreeFor(s, hedef.$1, hedef.$2);
    }
    if (rafinUstunde || (!tasimaHedefi && gittigi < kTapSlopOnRelease)) {
      await _dokunusOlarakIsle(s, e.position);
      return;
    }
    _zoom.markUnpairableTap();
    final lifted = Offset(e.position.dx, _liftedY(e.position.dy));
    final cell = _cellAtGlobal(lifted);
    if (cell != null) {
      final (r, c) = cell;
      if (!_isCellFreeFor(s, r, c)) return;
      if (s is _RackSource) {
        await _placeAt(r, c, s.index);
      } else if (s is _PlacedSource) {
        _controller.dispatch(
            MovePlacedTileAction(fromR: s.r, fromC: s.c, toR: r, toC: c));
      }
    } else if (s is _PlacedSource && _rackContains(lifted)) {
      _controller.dispatch(RecallCellAction(r: s.r, c: s.c));
    }
  }

  void _cancelTileDrag() {
    setState(() {
      _dragRef = null;
      _hiddenSource = null;
    });
    _dragNotifier.value = null;
  }

  // ── Oyna ───────────────────────────────────────────────────────────────
  void _handlePlay() {
    if (!_canAct || _words == null) return;
    setState(() => _note = null);
    // Geçersizse reducer `state.message` yazar, tur sayacı değişmez.
    _controller.dispatch(const PlayAction());
  }

  // ── Çıkış ──────────────────────────────────────────────────────────────
  Future<void> _handleExit() async {
    if (_phase == HamleAviPhase.play && hamleAviShouldWarnOnLeave(_streak)) {
      await _confirmLeave();
      return;
    }
    if (_phase == HamleAviPhase.play) _logResult('left');
    widget.onExit();
  }

  Future<void> _confirmLeave() async {
    setState(() => _leaveOpen = true);
    _syncTicker();
    final leave = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x800F172A),
      builder: (ctx) => KDialogCard(
        title: const Text('Çıkmak istiyor musun?', style: kDialogTitleStyle),
        content: Text.rich(TextSpan(style: kDialogBodyStyle, children: [
          const TextSpan(text: 'Çıkarsan serin sıfırlanır (Seri: '),
          TextSpan(
              text: '${_streak.streak}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '). Rekorun (${_streak.best}) korunur.'),
        ])),
        actions: [
          kDialogButton(
              label: 'ÇIK',
              variant: NeoButtonVariant.accent,
              onPressed: () => Navigator.of(ctx).pop(true)),
          kDialogButton(
              label: 'DEVAM', onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    );
    if (!_alive) return;
    if (leave == true) {
      // Çıkış seriyi sıfırlar; rekor zaten cihazda/sunucuda.
      _logResult('left');
      _streak = hamleAviOnMissed(_streak);
      widget.onExit();
      return;
    }
    setState(() => _leaveOpen = false);
    _syncTicker();
  }

  // ── Tanıtım penceresi ──────────────────────────────────────────────────
  Future<void> _showIntro() async {
    var dontShow = false;
    final start = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => KModal(
          title: 'Hamle Avı',
          titleWidget: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('🎯', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text('Hamle Avı', style: kDialogTitleStyle),
          ]),
          onClose: () => Navigator.of(ctx).pop(false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                  style: kDialogBodyStyle.copyWith(fontFamily: 'SpaceGrotesk'),
                  children: [
                    TextSpan(
                        text: '${kHamleAviSeconds ~/ 60} dakika',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: ' içinde elindeki harflerle oynanabilecek '),
                    const TextSpan(
                        text: 'en yüksek puanlı hamleyi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' bul.'),
                  ])),
              const SizedBox(height: 8),
              for (final t in kHamleAviIntroPoints)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text('•  $t',
                      style: const TextStyle(
                          fontSize: 12,
                          color: kMuted,
                          fontFamily: 'SpaceGrotesk')),
                ),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setLocal(() => dontShow = !dontShow),
                child: Row(children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                        value: dontShow,
                        onChanged: (v) =>
                            setLocal(() => dontShow = v ?? false)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Bir daha gösterme',
                      style:
                          TextStyle(fontSize: 12, fontFamily: 'SpaceGrotesk')),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: kDialogButton(
                        label: 'VAZGEÇ',
                        onPressed: () => Navigator.of(ctx).pop(false))),
                const SizedBox(width: 8),
                Expanded(
                    child: kDialogButton(
                        label: 'BAŞLA',
                        variant: NeoButtonVariant.orange,
                        onPressed: () => Navigator.of(ctx).pop(true))),
              ]),
            ],
          ),
        ),
      ),
    );
    if (!_alive || _phase != HamleAviPhase.intro) return;
    if (start == true) {
      if (dontShow) unawaited(widget.store.save(introHidden: true));
      _remainingMs = kHamleAviSeconds * 1000;
      _startClock();
      _setPhase(HamleAviPhase.play);
    } else {
      // Tanıtımdan vazgeç: bulmaca yakılmaz (görülenlerden çıkarılır).
      if (_pos != null) {
        _seen.remove(_pos!.id);
        unawaited(widget.store.save(seen: _seen.toList()..sort()));
      }
      widget.onExit();
    }
  }

  // ── Sonuç penceresi ────────────────────────────────────────────────────
  Future<void> _showResult() async {
    if (_resultOpen) return;
    _resultOpen = true;
    final phase = _phase;
    final pos = _pos;
    final String title;
    final List<InlineSpan> body;
    switch (phase) {
      case HamleAviPhase.found:
        title = 'Tebrikler! 🎯';
        body = [
          const TextSpan(text: 'En iyi hamleyi buldun: '),
          TextSpan(
              text: '$_lastNet',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: kGreen)),
          const TextSpan(text: ' puan. Seri: '),
          TextSpan(
              text: '${_streak.streak}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ' · Rekor: '),
          TextSpan(
              text: '${_streak.best}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ];
      case HamleAviPhase.missed:
        title = 'Üzgünüz, bulamadınız';
        body = [
          const TextSpan(text: 'En yüksek hamle puanı '),
          TextSpan(
              text: '${pos?.k}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: kRed)),
          const TextSpan(text: ' idi'),
          if (pos != null) ...[
            const TextSpan(text: ' ('),
            TextSpan(
                text: pos.w,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ')'),
          ],
          TextSpan(text: '. Serin sıfırlandı; rekorun ${_streak.best}.'),
        ];
      default:
        title = 'Hepsini çözdün!';
        body = [
          const TextSpan(
              text: 'Şimdilik tüm bulmacaları gördün — yeni bulmacalar '
                  'yakında. Rekorun: '),
          TextSpan(
              text: '${_streak.best}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ];
    }
    // 'missed'te geri tuşu/bariyer = Kapat (doğru hamleyi göster); ötekilerde çıkış.
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x800F172A),
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.of(ctx)
                .pop(phase == HamleAviPhase.missed ? 'kapat' : 'cik');
          }
        },
        child: KDialogCard(
          key: ValueKey('hamle-avi-sonuc-${phase.name}'),
          title: Text(title,
              style: kDialogTitleStyle.copyWith(fontSize: 26, height: 30 / 26)),
          content: Text.rich(TextSpan(
              style: kDialogBodyStyle.copyWith(fontFamily: 'SpaceGrotesk'),
              children: body)),
          actions: [
            if (phase != HamleAviPhase.exhausted)
              kDialogButton(
                  label: 'SONRAKİ',
                  variant: NeoButtonVariant.orange,
                  onPressed: () => Navigator.of(ctx).pop('sonraki')),
            kDialogButton(
                label: phase == HamleAviPhase.exhausted
                    ? 'TAMAM'
                    : phase == HamleAviPhase.missed
                        ? 'KAPAT'
                        : 'ÇIK',
                onPressed: () => Navigator.of(ctx)
                    .pop(phase == HamleAviPhase.missed ? 'kapat' : 'cik')),
          ],
        ),
      ),
    );
    _resultOpen = false;
    if (!_alive) return;
    switch (choice) {
      case 'sonraki':
        _loadNext(true);
      case 'kapat':
        _showSolution();
      default:
        widget.onExit();
    }
  }

  /// Süre bitti → "Kapat": doğru hamle tahtaya taslak taşlar olarak yerleştirilir.
  void _showSolution() {
    final init = _initial;
    if (init == null || _words == null) return;
    _solution ??= hamleAviFindBestNetMove(init, _words!);
    final sol = _solution;
    _controller.restore(init);
    if (sol != null) {
      // `PlaceTileAction` rafın O ANKİ sırasına bakar: taş çıkınca indeksler kayar.
      final rack = [...init.players[init.current].rack];
      for (final p in sol.move.placements) {
        final idx = rack.indexWhere(
            (t) => p.tile.wild ? t.letter == '?' : t.letter == p.tile.letter);
        if (idx < 0) continue;
        rack.removeAt(idx);
        _controller.dispatch(p.tile.wild
            ? PlaceTileAction(
                r: p.r, c: p.c, rackIndex: idx, wildLetter: p.tile.wildLetter)
            : PlaceTileAction(r: p.r, c: p.c, rackIndex: idx));
      }
      // Tahtadaki "+N" HAM puanı gösterir; mesaj NET (vergi dahil) toplamı yazar.
      _note = (
        text:
            'Doğru hamle: ${sol.move.word} — vergi dahil toplam ${sol.net} puan',
        kind: MessageKind.ok
      );
    }
    _setPhase(HamleAviPhase.review);
  }

  // ── Görünüm ────────────────────────────────────────────────────────────
  static String _fmt(int ms) {
    final s = (ms <= 0 ? 0 : (ms / 1000).ceil());
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Color _messageColor(MessageKind kind) => switch (kind) {
        MessageKind.err => kRed,
        MessageKind.ok => kGreen,
        MessageKind.warn => kGold,
        MessageKind.none => kMuted,
      };

  PlayerColor get _color => playerColors[_me.colorIndex % playerColors.length];

  Widget _buildGhost(_Ghost g) {
    final box = _boxOf(_stackKey);
    final local = box == null ? g.global : box.globalToLocal(g.global);
    final isRack = g.source is _RackSource;
    return Positioned(
      left: local.dx - kGhostTileSize / 2,
      top: local.dy - kGhostTileSize / 2,
      child: IgnorePointer(
        child: Transform.scale(
          scale: kGhostTileScale,
          child: SizedBox(
            width: kGhostTileSize,
            height: kGhostTileSize,
            child: TileWidget(
              tile: g.source.tile,
              variant: isRack ? TileVariant.rack : TileVariant.placed,
              color: isRack ? null : _color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hoverHighlight(_Ghost g) {
    // Erken dönüşler DE `Positioned` (Stack'in "yalnızca Positioned çocuk"
    // değişmezi — gerekçe game_screen.dart `_hoverHighlight`).
    final key = g.overKey;
    final grid = _boxOf(_gridKey);
    final stack = _boxOf(_stackKey);
    if (key == null || grid == null || stack == null) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }
    final (r, c) = parseKey(key);
    const gap = 3.0;
    final strideX = (grid.size.width + gap) / boardSize;
    final strideY = (grid.size.height + gap) / boardSize;
    final tl = stack
        .globalToLocal(grid.localToGlobal(Offset(c * strideX, r * strideY)));
    final br = stack.globalToLocal(grid.localToGlobal(
        Offset(c * strideX + (strideX - gap), r * strideY + (strideY - gap))));
    return Positioned(
      left: tl.dx,
      top: tl.dy,
      width: br.dx - tl.dx,
      height: br.dy - tl.dy,
      child: IgnorePointer(
        child: CustomPaint(
          painter: DashedBorderPainter(g.overValid ? kMoveValid : kMoveInvalid),
        ),
      ),
    );
  }

  Widget _header(double w) {
    final logoHeight = fluidSize(w, 28, -5.33, 8.89, 36);
    final labelSize = fluidSize(w, 11, -21, 10, 13);
    final auth = widget.auth;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TapTarget(
                key: const ValueKey('hamle-avi-logo'),
                minHeight: 36,
                alignment: Alignment.centerLeft,
                onTap: _handleExit,
                child: LogoMark(height: logoHeight),
              ),
            ),
          ),
          Text(
            '🎯 HAMLE AVI',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: labelSize,
              height: 1,
              color: kText,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: auth == null
                  ? const SizedBox.shrink()
                  : AccountButton(
                      auth: auth,
                      stats: widget.stats,
                      games: widget.games,
                      feedback: widget.feedback,
                      friends: widget.friends,
                      chat: widget.chat,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard() {
    final warn = _remainingMs <= kHamleAviWarnSeconds * 1000;
    final color = _color;
    final small = const TextStyle(
        fontFamily: 'SpaceMono', fontSize: 10, color: kMuted, height: 1.3);
    // Soldaki oyuncu rengi çizgisi (kullanıcı, 3 Kas 2026). Flutter,
    // renkleri FARKLI kenarlıkla `borderRadius`u birlikte çizemez (paint()
    // assert'i) — çizgi kırpılmış ayrı bir şerit, kenarlık tek renk.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: const BoxDecoration(color: kPanel),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorder),
          ),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                  key: const ValueKey('hamle-avi-cizgi'),
                  width: 5,
                  color: color.base),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('SERİ', style: small),
                          Text('${_streak.streak}',
                              key: const ValueKey('hamle-avi-seri'),
                              style: const TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  height: 1,
                                  color: kText)),
                          Text('Rekor ${_streak.best}', style: small),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('KALAN SÜRE', style: small),
                          Text(
                            _fmt(_remainingMs),
                            key: const ValueKey('hamle-avi-sure'),
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                              height: 1,
                              color: warn && _phase == HamleAviPhase.play
                                  ? kRed
                                  : kText,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Oyuncunun rengi baştan belli olsun (kullanıcı, 3 Kas 2026).
                          Container(
                            key: const ValueKey('hamle-avi-renk'),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.tint,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: color.base,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(_ownerIdx == 0 ? 'MAVİ' : 'KIRMIZI',
                                  style: TextStyle(
                                      fontFamily: 'SpaceMono',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: color.text)),
                            ]),
                          ),
                          const SizedBox(height: 4),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            if (_phase == HamleAviPhase.review) ...[
                              _miniButton('SONRAKİ', NeoButtonVariant.orange,
                                  () => _loadNext(true),
                                  key: const ValueKey('hamle-avi-sonraki')),
                              const SizedBox(width: 2),
                            ],
                            _miniButton(
                                'ÇIK ✕', NeoButtonVariant.neutral, _handleExit,
                                key: const ValueKey('hamle-avi-cik')),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _miniButton(String label, NeoButtonVariant v, VoidCallback onTap,
      {Key? key}) {
    return TapTarget(
      key: key,
      minHeight: 36,
      minWidth: 36,
      onTap: onTap,
      child: NeoButton(
        label: label,
        variant: v,
        fontSize: 10,
        letterSpacing: 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final w = MediaQuery.sizeOf(context).width;
    final words = _words;
    final moveStatus = (words == null || _phase != HamleAviPhase.play)
        ? null
        : computeMoveStatus(state, words);
    final liveMessage =
        moveStatus != null && !moveStatus.valid && moveStatus.reason != null
            ? moveStatus.reason!
            : moveStatus?.valid == true
                ? 'Oyna tuşuyla kelimeyi onayla.'
                : state.message;
    final liveKind =
        moveStatus != null && !moveStatus.valid && moveStatus.reason != null
            ? MessageKind.err
            : moveStatus?.valid == true
                ? MessageKind.ok
                : state.messageType;
    final mesaj = _phase == HamleAviPhase.loading
        ? (_loadError
            ? 'Bulmacalar yüklenemedi — bağlantını kontrol edip tekrar dene.'
            : 'Bulmaca hazırlanıyor…')
        : (_note?.text ?? (_phase == HamleAviPhase.play ? liveMessage : ''));
    final mesajKind = _phase == HamleAviPhase.loading
        ? MessageKind.none
        : (_note?.kind ??
            (_phase == HamleAviPhase.play ? liveKind : MessageKind.none));
    final me = _me;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            key: _stackKey,
            children: [
              Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(children: [_header(w), _scoreCard()]),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: (_dragRef != null || _panRef != null)
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: boardMaxWidth(
                                        boardViewportHeight(context))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 6, 12, 12),
                                  child: BoardWidget(
                                    state: state,
                                    hideFooter: true,
                                    dragListenable: _dragNotifier,
                                    moveOverlay: moveStatus == null
                                        ? null
                                        : MoveOverlay(
                                            valid: moveStatus.valid,
                                            cells: moveStatus.cells,
                                            score: moveStatus.score),
                                    onCellTap: _handleCellTap,
                                    gridKey: _gridKey,
                                    zoom: _zoom,
                                    viewportKey: _viewportKey,
                                    onBoardPointerDown: _boardPointerDown,
                                    onBoardPointerMove: _boardPointerMove,
                                    onBoardPointerUp: _boardPointerUp,
                                    onBoardPointerCancel: _endBoardPan,
                                    dragHiddenKey: _hiddenSource
                                            is _PlacedSource
                                        ? cellKey(
                                            (_hiddenSource as _PlacedSource).r,
                                            (_hiddenSource as _PlacedSource).c)
                                        : null,
                                    onTilePointerDown: (r, c, e) {
                                      final t = state.placed[cellKey(r, c)];
                                      if (_phase == HamleAviPhase.review) {
                                        _reviewTap =
                                            (r: r, c: c, pos: e.position);
                                        return;
                                      }
                                      if (t != null) {
                                        _beginTileDrag(
                                            _PlacedSource(r, c, t), e);
                                      }
                                    },
                                    onTilePointerMove: _moveTileDrag,
                                    onTilePointerUp: (e) {
                                      // Review: dokunuş = o kelimenin anlamı.
                                      final t = _reviewTap;
                                      _reviewTap = null;
                                      if (_phase == HamleAviPhase.review &&
                                          t != null &&
                                          (e.position - t.pos).distance <
                                              kTapSlopOnRelease) {
                                        unawaited(_openMeaningAt(t.r, t.c));
                                        return;
                                      }
                                      unawaited(_endTileDrag(e));
                                    },
                                    onTilePointerCancel: _cancelTileDrag,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 4, 12, 0),
                                child: ConstrainedBox(
                                  key: const ValueKey('message-line'),
                                  constraints:
                                      const BoxConstraints(minHeight: 30),
                                  child: Center(
                                    child: Text(
                                      mesaj,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'SpaceMono',
                                        fontWeight: FontWeight.bold,
                                        color: _messageColor(mesajKind),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: KeyedSubtree(
                                          key: _rackKey,
                                          child: RackWidget(
                                            tiles: me.rack,
                                            selectedTile: state.selectedTile,
                                            onSelect: (i) {
                                              if (!_canAct) return;
                                              _controller.dispatch(
                                                  SelectTileAction(i));
                                            },
                                            title: widget.playerName,
                                            color: _color,
                                            dragHiddenIndex: _hiddenSource
                                                    is _RackSource
                                                ? (_hiddenSource as _RackSource)
                                                    .index
                                                : null,
                                            onTilePointerDown: (i, e) {
                                              final rack = _me.rack;
                                              if (i < 0 || i >= rack.length) {
                                                return;
                                              }
                                              _beginTileDrag(
                                                  _RackSource(i, rack[i]), e);
                                            },
                                            onTilePointerMove: _moveTileDrag,
                                            onTilePointerUp: (e) =>
                                                unawaited(_endTileDrag(e)),
                                            onTilePointerCancel:
                                                _cancelTileDrag,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      NeoButton(
                                        label: _words == null
                                            ? 'YÜKLENİYOR…'
                                            : 'OYNA',
                                        variant: NeoButtonVariant.accent,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        onPressed: _canAct &&
                                                _words != null &&
                                                state.placed.isNotEmpty
                                            ? _handlePlay
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Raf altı düğmeler: oyun ekranındaki beşin HEPSİ
                              // durur, yalnızca bu modda anlamlı olanlar aktif
                              // (Pas/Değiştir/Torba pasif: tek hamlelik bulmaca).
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 6, 12, 12),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      for (final (i, b) in [
                                        ('PAS GEÇ', null),
                                        ('DEĞİŞTİR', null),
                                        (
                                          'KARIŞTIR',
                                          _canAct
                                              ? () => _controller.dispatch(
                                                  const ShuffleRackAction())
                                              : null
                                        ),
                                        (
                                          'GERİ AL',
                                          _canAct && state.placed.isNotEmpty
                                              ? () => _controller.dispatch(
                                                  const RecallAllAction())
                                              : null
                                        ),
                                        ('TORBA', null),
                                      ].indexed) ...[
                                        if (i > 0) const SizedBox(width: 6),
                                        Expanded(
                                          child: NeoButton(
                                            letterSpacing: 1.2,
                                            lineHeight: 1.5,
                                            label: b.$1,
                                            onPressed: b.$2,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<_Ghost?>(
                valueListenable: _dragNotifier,
                builder: (context, ghost, _) {
                  if (ghost == null) return const SizedBox.shrink();
                  return Stack(children: [
                    _hoverHighlight(ghost),
                    _buildGhost(ghost),
                  ]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// İlk render için boş pozisyon (banka yüklenene kadar tahta boş + raf boş).
const HamleAviPosition _emptyPosition =
    HamleAviPosition(id: -1, o: 0, tiles: [], rack: '', k: 0, w: '');
