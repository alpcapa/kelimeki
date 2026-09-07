// "Oynayarak öğren" tanıtımı — web `src/components/TutorialGame.tsx` portu
// (Onboarding Faz 4, 7 Eylül 2026). Metinler, süreler ve sıra web ile
// BİREBİR; `tutorial_parity_test.dart` bunları web kaynağına karşı kilitler.
//
// NEDEN AYRI BİR EKRAN: tanıtım GERÇEK motorla oynanır (`kelimeki_core`
// reducer'ı, `GameController` kabuğuyla) ama Setup'ın oyun akışına HİÇ
// dokunmaz — kendi controller'ı var, `GameSession`/`CloudGameSession`
// KURULMAZ. Kazanılan şey yalıtım: otomatik kayıt / bulut kaydı / `games`
// satırı / `logStart` / k-lig / terk-edilme cezası bu ekranda ÇALIŞMAZ,
// yani tanıtım bir "oyun" olarak sayılmaz. Gerçek oyun tanıtım kapanınca
// (`onFinish`/`onSkip`, ikisi aynı şeyi yapar) Setup'ta başlar.
//
// Motora tek bir action bile eklenmedi (kök CLAUDE.md, kural 1): başlangıç
// durumu `createTutorialState` ile doğrudan kurulup `restore` edilir,
// senaryo mevcut `PlaceTileAction`/`PlayAction` ile sürülür.
//
// ETKİLEŞİM (web'in cihaz testinden sonraki modeli): taş ELLE alınır —
// raftaki vurgulu harfe dokun → seçilir, sonra işaretli kareye dokun; VEYA
// harfi işaretli kareye sürükle. Boş kareye dokunmak tek başına HİÇBİR ŞEY
// yapmaz. RAYLAR: yalnızca o sahnenin harfleri seçilebilir/sürüklenebilir,
// yalnızca o sahnenin kareleri taş kabul eder; yanlış kare SESSİZCE
// reddedilir. Konan taşa dokunmak geri alır.
//
// SÜRÜKLEME: `game_screen.dart`ın jestinin SADELEŞTİRİLMİŞ eşi (taslak taşı
// geri sürükleme, ıskalama kurtarma, zoom ve joker YOK) — mantık sade ama
// HİS birebir aynı: eşikler, kaldırma payı ve hayaletin ölçüsü
// `drag_feel.dart`tan (üç ekranın ortak kaynağı).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import '../../data/auth_service.dart';
import '../../game/game_controller.dart';
import '../../game/move_status.dart';
import '../game/board_widget.dart';
import '../game/dialog_shell.dart';
import '../game/drag_feel.dart';
import '../game/fluid.dart';
import '../game/game_header.dart';
import '../game/neo_button.dart';
import '../game/player_colors.dart';
import '../game/rack_widget.dart';
import '../game/tile_widget.dart';
import '../tap_target.dart';
import '../tokens.dart';
import 'tutorial_script.dart';

/// Rakibin taşları arasındaki bekleme (ms) — insan gibi "diziliyor" hissi.
const int kTutorialRakipTasArasi = 260; // web RAKIP_TAS_ARASI

/// Oyuncunun hamlesi oynandıktan sonra sonucu okuma payı (ms).
const int kTutorialSonucOkuma = 1400; // web SONUC_OKUMA

/// Rakip oynadıktan SONRA "Rakip hamlesini yaptı" balonunun ekranda kalma
/// süresi (ms) — iki turda kullanıcıyla ayarlandı (1800 hızlı, 2600 fazla).
const int kTutorialRakipOkuma = 2000; // web RAKIP_OKUMA

/// Balon/mesaj metinleri — web ile birebir (parite testi kilitler).
const String kTutorialRakipYaptiText = 'Rakip hamlesini yaptı';
const String kTutorialRakipOynuyorText = 'Rakip oynuyor…';
const String kTutorialHarfiAlText = 'Harfi raftan al, işaretli kareye koy.';
const String kTutorialOynaBalonuText = 'Hamleni tamamlamak için OYNA\'ya bas';
String kTutorialTasiBalonuText(String word) => 'Şimdi $word kelimesini taşı';
const String kTutorialInvasionNote =
    'Rakibin bölgesine değen veya giren bir hamle yaparsan vergisini ödersin.';

enum _Mode { oyna, bekle, bitti }

enum _RakipEvre { yok, diziyor, bitti }

class _DragRef {
  final int index;
  final Tile tile;
  final Offset start;
  bool moved = false;
  _DragRef({required this.index, required this.tile, required this.start});
}

class _Ghost {
  final Offset global; // kaldırılmış (lifted) nokta
  final Tile tile;
  final String? overKey;
  final bool overValid;
  const _Ghost({
    required this.global,
    required this.tile,
    required this.overKey,
    required this.overValid,
  });
}

class TutorialGame extends StatefulWidget {
  /// Skor kutusunda ve rafta görünen ad (hesap adı ya da "Sen").
  final String playerName;
  final WordSource words;

  /// Tanıtım tamamlandı — çağıran gerçek oyunu başlatır.
  final VoidCallback onFinish;

  /// "Atla" (ve başlıktaki logo) — çağıran gerçek oyunu başlatır.
  final VoidCallback onSkip;

  /// Başlıktaki hesap kontrolü için; verilmezse çizilmez (testler).
  final AuthService? auth;

  const TutorialGame({
    super.key,
    required this.playerName,
    required this.words,
    required this.onFinish,
    required this.onSkip,
    this.auth,
  });

  @override
  State<TutorialGame> createState() => _TutorialGameState();
}

class _TutorialGameState extends State<TutorialGame> {
  late final GameController _controller =
      GameController(words: widget.words, autoPlayAi: false)
        ..restore(createTutorialState(widget.playerName));

  int _stepIndex = 0;
  _Mode _mode = _Mode.oyna;
  _RakipEvre _rakipEvre = _RakipEvre.yok;
  String? _note;

  /// Zamanlayıcıyla sürülen rakip animasyonu, ekran kapanırken durmalı.
  bool _alive = false;
  final List<Timer> _timers = [];

  // ── Sürükleme (raftan tahtaya, tek yön) ────────────────────────────────
  _DragRef? _dragRef;
  int? _hiddenIndex;
  final ValueNotifier<_Ghost?> _dragNotifier = ValueNotifier(null);
  final GlobalKey _gridKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  GameState get _state => _controller.state;
  TutorialStep get _step => tutorialSteps[_stepIndex];
  Player get _me => _state.players[0];

  @override
  void initState() {
    super.initState();
    _alive = true;
    _controller.addListener(_onState);
    // Karşılama penceresi — ilk sahneden ÖNCE (bkz. `tutorialIntroTitle`).
    // `initState`te `showDialog` çağrılamaz (ağaç henüz kurulmadı), ilk
    // kareden sonra açılıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_showIntro());
    });
  }

  /// Tanıtımın ne olduğunu ve ne kadar süreceğini söyleyen tek pencere.
  /// Kapanış kartıyla AYNI kabuk; kapatmanın her yolu (buton, bariyer, geri
  /// tuşu) tanıtımı başlatır — pencerenin kendi bayrağı YOK, tanıtım zaten
  /// "bir kere" gösteriliyor.
  Future<void> _showIntro() => showDialog<void>(
        context: context,
        builder: (context) => KDialogCard(
          title: const Text(tutorialIntroTitle,
              style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.bold,
                  color: kText)),
          content: const Text(tutorialIntroText, style: kDialogBodyStyle),
          actions: [
            kDialogButton(
              label: tutorialIntroButton,
              variant: NeoButtonVariant.accent,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  void _onState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _alive = false;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _controller.removeListener(_onState);
    _controller.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  Future<void> _bekle(int ms) {
    final c = Completer<void>();
    _timers.add(Timer(Duration(milliseconds: ms), () {
      if (!c.isCompleted) c.complete();
    }));
    return c.future;
  }

  // ── Bu sahnede ne kaldı ────────────────────────────────────────────────
  List<TutorialPlacement> get _kalanHedefler => _mode != _Mode.oyna
      ? const []
      : [
          for (final cell in _step.move.cells)
            if (_state.placed[cellKey(cell.r, cell.c)] == null) cell,
        ];

  bool get _hazir => _mode == _Mode.oyna && _kalanHedefler.isEmpty;

  /// Rafta işaretlenecek taşlar: kalan harflerin raf indeksleri, KELİME
  /// SIRASINDA — bitişik blok aranır (web ile aynı gerekçe: harf harf
  /// eşleme 3. sahnede önceki sahneden artan "A"yı işaretleyip tanıtımı
  /// kilitliyordu; `tutorial_script_test` bloğun varlığını kilitler).
  List<int> get _vurgulu {
    final kalan = _kalanHedefler;
    if (_mode != _Mode.oyna || kalan.isEmpty) return const [];
    final rack = _me.rack;
    final harfler = [for (final h in kalan) h.letter];
    for (var bas = 0; bas + harfler.length <= rack.length; bas++) {
      var uyar = true;
      for (var i = 0; i < harfler.length; i++) {
        if (rack[bas + i].letter != harfler[i]) {
          uyar = false;
          break;
        }
      }
      if (uyar) return [for (var i = 0; i < harfler.length; i++) bas + i];
    }
    // Bitişik blok yoksa senaryo bozulmuş demektir; tanıtım yine de
    // kilitlenmesin diye harf harf eşleşmeye düşülüyor.
    final kullanildi = <int>{};
    final out = <int>[];
    for (final hedef in kalan) {
      for (var i = 0; i < rack.length; i++) {
        if (rack[i].letter == hedef.letter && !kullanildi.contains(i)) {
          kullanildi.add(i);
          out.add(i);
          break;
        }
      }
    }
    return out;
  }

  /// Bu hücre, seçili/sürüklenen harf için geçerli bir hedef mi?
  bool _hedefUygun(String? k, String letter) {
    if (k == null) return false;
    final (r, c) = parseKey(k);
    return _kalanHedefler
        .any((h) => h.r == r && h.c == c && h.letter == letter);
  }

  // ── Dokunarak yerleştirme (seç → kareye dokun) ─────────────────────────
  void _handleCellTap(int r, int c, Offset _) {
    if (_mode != _Mode.oyna) return;
    final k = cellKey(r, c);
    if (_state.placed[k] != null) {
      _controller.dispatch(RecallCellAction(r: r, c: c));
      return;
    }
    TutorialPlacement? hedef;
    for (final cell in _kalanHedefler) {
      if (cell.r == r && cell.c == c) hedef = cell;
    }
    if (hedef == null) return; // hedef dışı kare: sessizce yoksayılır (ray)
    final sec = _state.selectedTile;
    // Harf seçilmeden kareye dokunmak taş GETİRMEZ: taş her zaman raftan
    // gelir. Yönlendirme raf balonunda zaten yazıyor.
    if (sec == null || sec >= _me.rack.length) return;
    if (_me.rack[sec].letter != hedef.letter) return;
    _controller.dispatch(PlaceTileAction(r: r, c: c, rackIndex: sec));
  }

  // ── Sürükleme geometrisi (game_screen.dart'ın zoom'suz eşi) ───────────
  RenderBox? _boxOf(GlobalKey key) =>
      key.currentContext?.findRenderObject() as RenderBox?;

  double _liftedY(double y) {
    final box = _boxOf(_gridKey);
    final lifted = y - kDragLift;
    if (box == null) return lifted;
    final top = box.localToGlobal(Offset.zero).dy;
    return lifted < top + 1 ? top + 1 : lifted;
  }

  (int, int)? _cellAtGlobal(Offset global) {
    final grid = _boxOf(_gridKey);
    if (grid == null) return null;
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

  void _onRackPointerDown(int i, PointerDownEvent e) {
    if (_mode != _Mode.oyna || !_vurgulu.contains(i)) return;
    if (i >= _me.rack.length) return;
    // setState şart: kaydırma görünümünün `physics`i buna bağlı.
    setState(() {
      _dragRef = _DragRef(index: i, tile: _me.rack[i], start: e.position);
    });
  }

  void _onRackPointerMove(PointerMoveEvent e) {
    final d = _dragRef;
    if (d == null) return;
    if (!d.moved) {
      // Eşik parmakta 10, farede 6 — pointer TÜRÜNE bağlı (drag_feel.dart).
      if ((e.position - d.start).distance < dragThresholdFor(e.kind)) return;
      d.moved = true;
      setState(() => _hiddenIndex = d.index);
    }
    // Taş parmağın üzerinde çizilir ve hedef DE aynı noktadan hesaplanır.
    final lifted = Offset(e.position.dx, _liftedY(e.position.dy));
    final cell = _cellAtGlobal(lifted);
    final overKey = cell == null ? null : cellKey(cell.$1, cell.$2);
    _dragNotifier.value = _Ghost(
      global: lifted,
      tile: d.tile,
      overKey: overKey,
      overValid: _hedefUygun(overKey, d.tile.letter),
    );
  }

  void _onRackPointerUp(PointerUpEvent e) {
    final d = _dragRef;
    _resetDrag();
    if (d == null) return;
    // Bırakma kararının eşiği hayalet eşiğinden AYRI ve daha geniş
    // (`kTapSlopOnRelease`): titreyen parmak taşı kaybetmesin.
    if (!d.moved || (e.position - d.start).distance < kTapSlopOnRelease) {
      if (_mode == _Mode.oyna) {
        _controller.dispatch(SelectTileAction(d.index));
      }
      return;
    }
    final lifted = Offset(e.position.dx, _liftedY(e.position.dy));
    final cell = _cellAtGlobal(lifted);
    final k = cell == null ? null : cellKey(cell.$1, cell.$2);
    if (!_hedefUygun(k, d.tile.letter)) return; // yanlış kare: rafa döner
    _controller
        .dispatch(PlaceTileAction(r: cell!.$1, c: cell.$2, rackIndex: d.index));
  }

  void _resetDrag() {
    if (_dragRef != null || _hiddenIndex != null) {
      setState(() {
        _dragRef = null;
        _hiddenIndex = null;
      });
    }
    _dragNotifier.value = null;
  }

  // ── Oyna → rakip → sonraki sahne ───────────────────────────────────────
  Future<void> _handlePlay() async {
    if (!_hazir) return;
    // Vergi sahnesinde gerçek oyundaki onay penceresi çıkar — tanıtımın
    // işi oyuncuyu o pencereye de alıştırmak.
    if (_step.move.tax > 0) {
      final ok = await _showInvasionConfirm();
      if (!ok || !mounted) return;
    }
    await _oyna();
  }

  Future<void> _oyna() async {
    final step = _step;
    setState(() => _mode = _Mode.bekle);
    _controller.dispatch(const PlayAction());
    setState(() => _note = step.done);
    await _bekle(kTutorialSonucOkuma);
    if (!_alive) return;

    setState(() {
      _note = null;
      _rakipEvre = _RakipEvre.diziyor;
    });
    for (final cell in step.reply.cells) {
      final s = _state;
      final idx =
          s.players[s.current].rack.indexWhere((t) => t.letter == cell.letter);
      if (idx < 0) {
        // Senaryo bozulduysa (doğrulayıcı bunu testte yakalıyor) oyuncuyu
        // kilitli bir tahtada bırakmaktansa tanıtımı bitiriyoruz.
        setState(() {
          _rakipEvre = _RakipEvre.yok;
          _mode = _Mode.bitti;
        });
        unawaited(_showFinish());
        return;
      }
      _controller
          .dispatch(PlaceTileAction(r: cell.r, c: cell.c, rackIndex: idx));
      await _bekle(kTutorialRakipTasArasi);
      if (!_alive) return;
    }
    _controller.dispatch(const PlayAction());
    setState(() {
      _rakipEvre = _RakipEvre.bitti;
      _note = step.reply.note;
    });
    await _bekle(kTutorialRakipOkuma);
    if (!_alive) return;

    setState(() {
      _rakipEvre = _RakipEvre.yok;
      _note = null;
    });
    if (_stepIndex + 1 < tutorialSteps.length) {
      setState(() {
        _stepIndex++;
        _mode = _Mode.oyna;
      });
    } else {
      setState(() => _mode = _Mode.bitti);
      unawaited(_showFinish());
    }
  }

  /// Vergi sahnesi — gerçek oyundaki onay penceresinin aynısı
  /// (`invasion_confirm.dart` metni/vurguları), üstüne tanıtımın tek
  /// satırlık açıklaması. Sayılar senaryodan (motor da aynı sonucu
  /// veriyor — `tutorial_script_test` kilitler).
  Future<bool> _showInvasionConfirm() async {
    final move = _step.move;
    final rakip = _state.players[1].name;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => KDialogCard(
        title: const Text('Sınır İhlali!', style: kDialogTitleStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(
              style: kDialogBodyStyle.copyWith(fontFamily: 'SpaceGrotesk'),
              children: [
                const TextSpan(text: 'Bu hamleden kazanacağın '),
                TextSpan(
                    text: '${move.points + move.tax}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kGreen)),
                const TextSpan(text: ' puanın '),
                TextSpan(
                    text: '${move.tax}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kRed)),
                const TextSpan(text: ' puanı '),
                TextSpan(
                    text: rakip,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: ' kullanıcısına vergi olarak gidecek.'),
              ],
            )),
            const SizedBox(height: 8),
            const Text(
              kTutorialInvasionNote,
              style: TextStyle(
                  fontSize: 12,
                  height: 1.625,
                  color: kMuted,
                  fontFamily: 'SpaceGrotesk'),
            ),
          ],
        ),
        actions: [
          kDialogButton(
            label: 'OYNA',
            variant: NeoButtonVariant.accent,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          kDialogButton(
            label: 'VAZGEÇ',
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    return ok == true;
  }

  /// Kapanış kartı. Kapatmanın HER yolu (buton, bariyer, geri tuşu) gerçek
  /// oyunu başlatır — web'de `useModalA11y(mode === 'bitti', onFinish)`.
  Future<void> _showFinish() async {
    await showDialog<void>(
      context: context,
      builder: (context) => KDialogCard(
        title: const Text(tutorialFinishTitle,
            style: TextStyle(
                fontSize: 18,
                height: 28 / 18,
                fontWeight: FontWeight.bold,
                color: kText)),
        content: const Text(tutorialFinishText, style: kDialogBodyStyle),
        actions: [
          kDialogButton(
            label: 'GERÇEK OYUNA BAŞLA',
            variant: NeoButtonVariant.accent,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (!mounted) return;
    widget.onFinish();
  }

  // ── Hayalet taş + bırakma hedefi (game_screen.dart deseninin sade eşi) ──
  Widget _buildGhost(_Ghost g) {
    final box = _boxOf(_stackKey);
    final local = box == null ? g.global : box.globalToLocal(g.global);
    return Positioned(
      left: local.dx - kGhostTileSize / 2,
      top: local.dy - kGhostTileSize / 2,
      child: IgnorePointer(
        child: Transform.scale(
          scale: kGhostTileScale,
          child: SizedBox(
            width: kGhostTileSize,
            height: kGhostTileSize,
            child: TileWidget(tile: g.tile, variant: TileVariant.rack),
          ),
        ),
      ),
    );
  }

  Widget _hoverHighlight(_Ghost g) {
    final key = g.overKey;
    final grid = _boxOf(_gridKey);
    final stack = _boxOf(_stackKey);
    // Erken dönüşler DE `Positioned` (Stack'in "yalnızca Positioned çocuk"
    // değişmezi — gerekçe `game_screen.dart` → `_hoverHighlight`).
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

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final step = _step;
    final me = _me;
    final hazir = _hazir;
    final kalan = _kalanHedefler;
    final vurgulu = _vurgulu;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final targets = _mode == _Mode.oyna
        ? {for (final cell in kalan) cellKey(cell.r, cell.c)}
        : null;

    // Tahtadaki balon — aynı anda EKRANDA TEK balon: (1) rakip oynadıysa
    // "Rakip hamlesini yaptı", (2) sıra oyuncuda ve hamle TAMAMLANMADIYSA
    // dersin cümlesi, (3) tamamlandıysa HİÇBİRİ (söz OYNA balonunun).
    final BoardCoach? tahtaBalonu = _rakipEvre == _RakipEvre.bitti
        ? BoardCoach(
            r: step.reply.cells[0].r,
            c: step.reply.cells[0].c,
            yon: 'ust',
            text: kTutorialRakipYaptiText,
          )
        : (_mode == _Mode.oyna && !hazir)
            ? BoardCoach(
                r: step.bubble.r,
                c: step.bubble.c,
                yon: step.bubble.yon,
                text: step.say,
              )
            : null;

    final mesaj = _note ??
        (_rakipEvre == _RakipEvre.diziyor
            ? kTutorialRakipOynuyorText
            : (_mode == _Mode.oyna && !hazir)
                ? kTutorialHarfiAlText
                : '');
    final mesajRengi = _note != null ? kGreen : kMuted;

    final moveStatus = computeMoveStatus(state, widget.words);

    return Scaffold(
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
                    child: GameHeader(
                      state: state,
                      auth: widget.auth,
                      onLogoTap: widget.onSkip,
                    ),
                  ),
                ),
                // Sahne sayacı + her sahnede duran "Atla". Tanıtım zorunlu
                // değil; atlayan da ilk gerçek oyununda ipuçlarını görür.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TANITIM · ${_stepIndex + 1}/${tutorialSteps.length}',
                            style: const TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: kMuted,
                            ),
                          ),
                          TapTarget(
                            minHeight: 44,
                            onTap: widget.onSkip,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'ATLA →',
                                style: TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  color: kAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    // Taş sürüklenirken sayfa kaymasın (game_screen.dart ile
                    // aynı ders).
                    physics: _dragRef != null
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                              child: BoardWidget(
                                state: state,
                                onCellTap: _handleCellTap,
                                moveOverlay: moveStatus == null
                                    ? null
                                    : MoveOverlay(
                                        valid: moveStatus.valid,
                                        cells: moveStatus.cells,
                                        score: moveStatus.score,
                                      ),
                                gridKey: _gridKey,
                                hideFooter: true,
                                targets: targets,
                                coach: tahtaBalonu,
                                dragListenable: _dragNotifier,
                              ),
                            ),
                            Padding(
                              // ⚠ Mesaj şeridi ve raf satırı TEK Stack'in
                              // içinde (7 Eylül 2026 akşamı, kullanıcı:
                              // *"zaten orada 'kelimeyi taşı' balonu duruyor
                              // ve mesajlar görünmüyor… kaydırsak iyi
                              // olur"*). Balonlar Stack'in ÜSTÜNE taştığı
                              // için, Stack şeridi de kapsayınca balon
                              // şeridin üstünü örtmüyor. Dolgular birleşti:
                              // eski (12,4,12,0) + (12,6,12,12) → (12,4,12,12)
                              // + aradaki 6 px `SizedBox` (boşluk aynen aynı).
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        key: const ValueKey('tutorial-message'),
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
                                              color: mesajRengi,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: RackWidget(
                                                tiles: me.rack,
                                                selectedTile:
                                                    state.selectedTile,
                                                onSelect: (i) {
                                                  if (_mode == _Mode.oyna &&
                                                      vurgulu.contains(i)) {
                                                    _controller.dispatch(
                                                        SelectTileAction(i));
                                                  }
                                                },
                                                title: me.name,
                                                color: playerColors[
                                                    me.colorIndex %
                                                        playerColors.length],
                                                highlight: vurgulu,
                                                dragHiddenIndex: _hiddenIndex,
                                                onTilePointerDown:
                                                    _mode == _Mode.oyna
                                                        ? _onRackPointerDown
                                                        : null,
                                                onTilePointerMove:
                                                    _onRackPointerMove,
                                                onTilePointerUp:
                                                    _onRackPointerUp,
                                                onTilePointerCancel: _resetDrag,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            NeoButton(
                                              label: 'OYNA',
                                              variant: NeoButtonVariant.accent,
                                              fontSize: 12,
                                              letterSpacing: 1.2,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              onPressed:
                                                  hazir ? _handlePlay : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Raf balonu SATIRIN ORTASINDA (7 Eylül 2026
                                  // akşamı, kullanıcı: *"Hepsinin ortalı ve
                                  // yerinde olması lazım"*) — cümle rafın
                                  // TAMAMI hakkında, satırın ortası da rafın
                                  // üstüne düşüyor. OYNA balonu sağda kalıyor:
                                  // o gerçekten sağdaki butonu işaret ediyor.
                                  if (_mode == _Mode.oyna && !hazir)
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: -4,
                                      child: FractionalTranslation(
                                        translation: const Offset(0, -1),
                                        child: _Balon(
                                          text: kTutorialTasiBalonuText(
                                              step.move.word),
                                          screenWidth: screenWidth,
                                          align: CrossAxisAlignment.center,
                                        ),
                                      ),
                                    ),
                                  if (hazir)
                                    Positioned(
                                      left: 0,
                                      right: 4,
                                      top: -4,
                                      child: FractionalTranslation(
                                        translation: const Offset(0, -1),
                                        child: _Balon(
                                          text: kTutorialOynaBalonuText,
                                          screenWidth: screenWidth,
                                          align: CrossAxisAlignment.end,
                                        ),
                                      ),
                                    ),
                                ],
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
            // Hover çerçevesi + hayalet taş — yalnızca `_dragNotifier`
            // değişince kendi küçük alt ağacını günceller (Parça 23 kuralı).
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
    );
  }
}

/// Tanıtım balonu — mavi kutu + aşağı bakan kuyruk (tahtadaki balonun eşi;
/// web `Balon`: 9-13px akışkan punto, 7/10 dolgu, en fazla ekranın %72'si).
class _Balon extends StatelessWidget {
  final String text;
  final double screenWidth;
  final CrossAxisAlignment align;
  const _Balon(
      {required this.text, required this.screenWidth, required this.align});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Container(
            // Genişlik kapağı 0.72 → 0.58 ve punto 9-13 → 11-16 (web
            // `TutorialGame.tsx` ile aynı sayılar): uzun cümleler iki satıra
            // kırılıyor, kısa olanlar tek satır kalıyor.
            constraints: BoxConstraints(maxWidth: screenWidth * 0.58),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x470F172A),
                    offset: Offset(0, 2),
                    blurRadius: 6),
              ],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.bold,
                height: 1.25,
                fontSize: fluidSize(screenWidth, 11, 0, 3.2, 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomPaint(
              size: const Size(10, 6),
              painter: _TailDownPainter(kAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TailDownPainter extends CustomPainter {
  final Color color;
  const _TailDownPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TailDownPainter old) => old.color != color;
}
