// Harfik — ana uygulama: kurulum, çok oyunculu sıra akışı ve düzen
import { useEffect, useMemo, useReducer, useRef, useState } from 'react';
import { GameHeader } from './components/GameHeader';
import { Board } from './components/Board';
import { Rack } from './components/Rack';
import { GameOver } from './components/GameOver';
import { UserMenu } from './components/UserMenu';
import { Setup } from './components/Setup';
import { MeaningModal } from './components/MeaningModal';
import { RemainingTilesModal } from './components/RemainingTilesModal';
import { MoveHistoryModal } from './components/MoveHistoryModal';
import { WildcardModal } from './components/WildcardModal';
import { createInitialState, gameReducer, isFirstMove } from './game/gameReducer';
import { calcScore, computeInvasionSplit, validatePlacement, validatePlacementStructural } from './utils/validator';
import { getFormedWords, key } from './utils/board';
import type { Tile as TileModel } from './game/types';
import { Tile } from './components/Tile';
import { trLower } from './utils/turkish';
import { PLAYER_COLORS } from './game/constants';
import { fetchMeaning, isValidWordRemote, isSupabaseConfigured, saveGame } from './lib/api';
import type { GameResult, WordMeaning } from './lib/database.types';
import { useAuth } from './hooks/useAuth';
import { AddToHomeScreen } from './components/AddToHomeScreen';

const AI_THINK_MS = 1100;
// Sürüklemenin "tıklama" değil gerçek bir sürükleme sayılması için gereken
// minimum işaretçi hareketi (piksel).
const DRAG_THRESHOLD = 6;
// Sürüklenen taşın görseli, parmağın altında kalıp görüşü engellememesi için
// işaretçinin bu kadar üzerinde çizilir.
const DRAG_LIFT = 30;

type DragSource =
  | { kind: 'rack'; index: number; tile: TileModel }
  | { kind: 'placed'; r: number; c: number; tile: TileModel };

const MESSAGE_COLORS: Record<string, string> = {
  ok: 'text-green',
  err: 'text-red',
  warn: 'text-gold',
  '': 'text-muted',
};

export default function App() {
  const { user, profile } = useAuth();
  const [state, dispatch] = useReducer(gameReducer, undefined, createInitialState);

  // Oynanan kelime(ler)e tıklanınca gösterilen anlam penceresi. Bir hamlede
  // birden fazla kelime oluştuysa hepsi listelenir.
  const [meaning, setMeaning] = useState<{
    entries: { word: string; data: WordMeaning | null; loading: boolean }[];
  } | null>(null);

  // Torba (kalan taşlar) penceresi.
  const [showTiles, setShowTiles] = useState(false);

  // Oyun geçmişi penceresi (tüm oyuncuların hamleleri) — hem oynarken
  // Board'daki linkten, hem oyun bitince GameOver ekranından açılabilir.
  const [showHistory, setShowHistory] = useState(false);

  // Oyun sonu ekranı kapatıldı mı (X'e basıldı mı) — board'u görmek için.
  const [gameOverDismissed, setGameOverDismissed] = useState(false);
  useEffect(() => {
    if (state.isGameOver) setGameOverDismissed(false);
  }, [state.isGameOver]);

  // Joker taş konurken hangi harfe dönüşeceğini seçme penceresi.
  const [pendingWild, setPendingWild] = useState<
    { r: number; c: number; rackIndex?: number } | null
  >(null);

  // Oyundan çıkış onay popup'ı.
  const [showExitConfirm, setShowExitConfirm] = useState(false);

  // Rakip köşeye giriş onay popup'ı.
  const [invasionConfirm, setInvasionConfirm] = useState<
    { ownerName: string; ownerPts: number }[] | null
  >(null);

  // Sunucu kelime doğrulaması sırasında true — butonu devre dışı bırakır.
  const [validating, setValidating] = useState(false);
  // Sunucu doğrulaması başarılıysa true; reducer'a skipWordCheck iletilir.
  const pendingSkipWordCheck = useRef(false);

  // ── Taş sürükleme (fare + dokunmatik) ───────────────────────────────────
  // Jest sırasında değişen anlık veri `dragRef`de tutulur (her pointer
  // olayında render tetiklemeden okunup güncellenir); `ghost` yalnızca
  // gerçek bir sürükleme başladığında (eşik aşılınca) set edilir ve
  // sürüklenen taşın parmak/imleci takip eden görselini tetikler.
  const dragRef = useRef<{
    source: DragSource;
    startX: number;
    startY: number;
    moved: boolean;
  } | null>(null);
  const [ghost, setGhost] = useState<{
    x: number;
    y: number;
    source: DragSource;
    overKey: string | null;
    overValid: boolean;
  } | null>(null);
  // Gerçek bir sürükleme bitişinin hemen ardından gelen "hayalet" click
  // olayını yutmak için (bırakılan hücrenin altındaki onClick'i tetiklemesin).
  const suppressClickRef = useRef(false);

  useEffect(() => {
    const swallow = (e: MouseEvent) => {
      if (suppressClickRef.current) {
        suppressClickRef.current = false;
        e.stopPropagation();
        e.preventDefault();
      }
    };
    document.addEventListener('click', swallow, true);
    return () => document.removeEventListener('click', swallow, true);
  }, []);

  // Bir taş sürüklemesi sürerken (raftan ya da tahtadan) dokunmatik
  // tarayıcının sayfayı kaydırmasını engelle. `touch-action: none` çoğu
  // durumda yeterli ama parmak hızlı hareket ettiğinde ya da pointer
  // capture bazı tarayıcılarda güvenilmez olduğunda devreye girmeyebiliyor;
  // bu, sürükleme sırasında kaydırmayı kesin olarak engelleyen bir yedek.
  useEffect(() => {
    const preventScrollWhileDragging = (e: TouchEvent) => {
      if (dragRef.current) e.preventDefault();
    };
    document.addEventListener('touchmove', preventScrollWhileDragging, { passive: false });
    return () => document.removeEventListener('touchmove', preventScrollWhileDragging);
  }, []);

  const openMeaning = (words: string[]) => {
    const unique = [...new Set(words)];
    if (unique.length === 0) return;
    setMeaning({
      entries: unique.map((word) => ({ word, data: null, loading: true })),
    });
    for (const word of unique) {
      void fetchMeaning(word).then((data) => {
        setMeaning((cur) =>
          cur
            ? {
                entries: cur.entries.map((e) =>
                  e.word === word ? { ...e, data, loading: false } : e,
                ),
              }
            : cur,
        );
      });
    }
  };

  // İnsan oyuncunun oyun sonu kaydını oluşturur — hem oyun normal bittiğinde
  // hem de oyuncu bitmeden (logoya basıp) teslim olduğunda kullanılır.
  const buildGameRecord = (surrendered: boolean) => {
    const human = state.players.find((p) => !p.isAI);
    const opponents = state.players.filter((p) => p !== human);
    if (!human || opponents.length === 0) return null;
    const bestOpponentScore = Math.max(...opponents.map((p) => p.score));
    const result: GameResult = surrendered
      ? 'lose'
      : human.score > bestOpponentScore ? 'win' : human.score < bestOpponentScore ? 'lose' : 'tie';
    // Bitiş sırası: tüm oyuncuların skorları büyükten küçüğe sıralanır, insanın
    // skoru bu sırada ilk kez göründüğü konum + 1'dir (eşit skorlar aynı sırayı paylaşır).
    const scoresDesc = state.players.map((p) => p.score).sort((a, b) => b - a);
    const rank = scoresDesc.indexOf(human.score) + 1;
    return {
      player_score: human.score,
      ai_score: bestOpponentScore,
      result,
      rank,
      turn_count: state.turnCount,
      player_count: state.players.length,
      move_count: human.moveCount || null,
      best_move_score: human.bestMoveScore || null,
      best_word_score: human.bestWordScore || null,
      best_word: human.bestWord || null,
      longest_word: human.longestWord || null,
      move_points_sum: human.moveScoreSum || null,
      surrendered,
    };
  };

  // Oyun bitince giriş yapmış kullanıcının sonucunu kaydet (YZ'ye karşı oyunlar dahil).
  useEffect(() => {
    if (!state.isGameOver || state.phase !== 'play') return;
    const record = buildGameRecord(false);
    if (record) void saveGame(record);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.isGameOver]);

  // Oyun devam ederken giriş yapılırsa 1. oyuncunun adını güncelle.
  useEffect(() => {
    if (state.phase !== 'play') return;
    const accountName =
      profile?.display_name ||
      profile?.first_name ||
      (user?.email ? user.email.split('@')[0] : null);
    if (!accountName) return;
    const p0 = state.players[0];
    if (p0 && !p0.isAI && p0.name !== accountName) {
      dispatch({ type: 'RENAME_PLAYER', index: 0, name: accountName });
    }
  }, [user, profile, state.phase]);

  // YZ sırası: kısa bir düşünme gecikmesiyle otomatik oyna.
  const aiTurn =
    state.phase === 'play' &&
    !state.isGameOver &&
    !!state.players[state.current]?.isAI;
  useEffect(() => {
    if (!aiTurn) return;
    const t = setTimeout(() => dispatch({ type: 'AI_PLAY' }), AI_THINK_MS);
    return () => clearTimeout(t);
  }, [aiTurn, state.current, state.turnCount]);

  // Oyna'ya basmadan önce, tahtaya konan taşların anlık geçerlilik/puan
  // çerçevesi (yeşil/kırmızı). Yerel sözlükle kontrol edilir; sunucu
  // doğrulaması yalnızca Oyna'ya basınca (handlePlay) çalışır.
  const moveStatus = useMemo(() => {
    const placedKeys = Object.keys(state.placed);
    if (placedKeys.length === 0) return null;
    const current = state.players[state.current];
    if (!current) return null;

    const result = validatePlacement(
      state.board,
      state.placed,
      state.current,
      current.corners,
      isFirstMove(state),
    );
    // Oluşan tüm kelimelerin hücrelerini birleştir; Board bunun etrafına
    // tek, boşluksuz bir dış çerçeve çizer (ortak hücrelerde iç çizgi olmaz).
    const formed = getFormedWords(state.board, state.placed);
    const cells = formed.length > 0
      ? formed.flatMap((f) => f.coords)
      : (placedKeys.map((k) => k.split(',').map(Number)) as [number, number][]);

    return {
      valid: result.valid,
      reason: result.reason,
      cells,
      score: calcScore(state.board, state.placed, state.bonuses),
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.placed, state.board, state.players, state.current]);

  // Oyna'ya basmadan önce, geçersiz bir hamle varsa sebebini canlı olarak
  // alttaki mesaj alanında göster — oyuncu Oyna'ya basmadan neden geçersiz
  // olduğunu (köşe kuralı, sözlük vb.) hemen görsün. Geçerliyse aynı mesaj
  // ("Oyna tuşuyla kelimeyi onayla.") yeşile döner.
  const liveMessage = moveStatus && !moveStatus.valid && moveStatus.reason
    ? moveStatus.reason
    : state.message;
  const liveMessageType = moveStatus && !moveStatus.valid && moveStatus.reason
    ? 'err'
    : moveStatus?.valid
      ? 'ok'
      : state.messageType;

  // ── Kurulum ekranı ─────────────────────────────────────────────────────────
  if (state.phase === 'setup') {
    return (
      <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden">
        <div className="w-full max-w-[460px] flex items-center justify-end px-3.5 pt-3">
          <UserMenu />
        </div>
        <Setup onStart={(players) => dispatch({ type: 'START', players })} />
        <AddToHomeScreen />
      </div>
    );
  }

  // ── Oyun ekranı ──────────────────────────────────────────────────────────────
  const me = state.players[state.current];
  // Harf rafı: sıra bir insanda ise (aynı cihazdan sırayla oynanan hotseat
  // modunda birden fazla insan olabilir) HER ZAMAN o anki insanın kendi
  // rafı gösterilir; sıra bir YZ'deyse onun gizli tutulması gereken rafı
  // asla gösterilmez, bunun yerine ilk insan oyuncuya düşülür.
  const rackPlayer = me.isAI ? (state.players.find((p) => !p.isAI) ?? me) : me;
  const rackColor = PLAYER_COLORS[rackPlayer.colorIndex];

  // Raftan bir taş ya da tahtaya bu tur konmuş bir taş sürüklenmeye başlanır.
  const beginDrag = (source: DragSource, e: React.PointerEvent) => {
    if (!canAct || state.swapMode) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    dragRef.current = { source, startX: e.clientX, startY: e.clientY, moved: false };
  };

  // Bırakma hedefini (varsa) bulur: tahta hücresi ya da raf alanı.
  const dropTargetsAt = (x: number, y: number) => {
    const el = document.elementFromPoint(x, y);
    const cellEl = el?.closest('[data-cell]') as HTMLElement | null;
    const rackEl = el?.closest('[data-rack]') as HTMLElement | null;
    return { cellEl, rackEl };
  };

  const isCellFreeFor = (source: DragSource, r: number, c: number) => {
    if (source.kind === 'placed' && source.r === r && source.c === c) return false;
    return !state.board[r][c] && !state.placed[key(r, c)];
  };

  const moveDrag = (e: React.PointerEvent) => {
    const d = dragRef.current;
    if (!d) return;
    if (!d.moved) {
      const dist = Math.hypot(e.clientX - d.startX, e.clientY - d.startY);
      if (dist < DRAG_THRESHOLD) return;
      d.moved = true;
    }
    const { cellEl } = dropTargetsAt(e.clientX, e.clientY);
    let overKey: string | null = null;
    let overValid = false;
    if (cellEl?.dataset.cell) {
      const [r, c] = cellEl.dataset.cell.split(',').map(Number);
      overKey = key(r, c);
      overValid = isCellFreeFor(d.source, r, c);
    }
    setGhost({ x: e.clientX, y: e.clientY, source: d.source, overKey, overValid });
  };

  const endDrag = (e: React.PointerEvent) => {
    const d = dragRef.current;
    dragRef.current = null;
    setGhost(null);
    if (!d) return;
    try {
      (e.target as Element).releasePointerCapture?.(e.pointerId);
    } catch {
      // yakalama zaten bırakılmış olabilir — yok sayılır.
    }

    if (!d.moved) {
      // Hareket yok: sıradan bir dokunuş/tık — eski davranış korunur.
      if (d.source.kind === 'rack') {
        dispatch({ type: 'SELECT_TILE', index: d.source.index });
      } else {
        dispatch({ type: 'RECALL_CELL', r: d.source.r, c: d.source.c });
      }
      return;
    }

    // Gerçek bir sürükleme oldu — bırakılan hücrenin altındaki "hayalet"
    // click olayını yut (yoksa yanlışlıkla o hücrenin onClick'ini tetikler).
    // Dokunmatikte belirgin hareketten sonra tarayıcı genelde hiç click
    // üretmez, bu yüzden bayrak bir sonraki tick'te kendini temizler —
    // aksi halde sonraki (ilgisiz) bir dokunuşu sessizce yutabilirdi.
    suppressClickRef.current = true;
    setTimeout(() => {
      suppressClickRef.current = false;
    }, 0);

    const { cellEl, rackEl } = dropTargetsAt(e.clientX, e.clientY);
    if (cellEl?.dataset.cell) {
      const [r, c] = cellEl.dataset.cell.split(',').map(Number);
      if (isCellFreeFor(d.source, r, c)) {
        if (d.source.kind === 'rack') {
          if (d.source.tile.letter === '?') {
            setPendingWild({ r, c, rackIndex: d.source.index });
          } else {
            dispatch({ type: 'PLACE_TILE', r, c, rackIndex: d.source.index });
          }
        } else {
          dispatch({
            type: 'MOVE_PLACED_TILE',
            from: { r: d.source.r, c: d.source.c },
            to: { r, c },
          });
        }
      }
    } else if (rackEl && d.source.kind === 'placed') {
      dispatch({ type: 'RECALL_CELL', r: d.source.r, c: d.source.c });
    }
  };

  const cancelDrag = () => {
    dragRef.current = null;
    setGhost(null);
  };

  const handleCellClick = (r: number, c: number) => {
    const k = key(r, c);
    // Son oynanan kelimenin harfine tıklanırsa anlamını göster. Aynı hamlede
    // oluşan tüm kelimeleri (tıklanan önce gelir) listele.
    const lw = state.lastWords[k];
    if (lw) {
      const words = Object.values(state.lastWords)
        .filter((w) => w.by === lw.by)
        .map((w) => w.word);
      // Tıklanan kelimeyi listeye birinci sıraya taşı.
      const sorted = [lw.word, ...words.filter((w) => w !== lw.word)];
      openMeaning(sorted);
      return;
    }
    if (state.isGameOver || me.isAI || state.swapMode) return;
    // Bu tur konmuş bir taşın hücresi buraya hiç ulaşmaz — Board o hücreye
    // onClick yerine sürükleme (basılı tut/bırak) olay dinleyicileri bağlar.
    if (state.board[r][c]) return;

    const sel = state.selectedTile !== null ? me.rack[state.selectedTile] : null;
    if (sel && sel.letter === '?') {
      // Joker taş: hangi harfe dönüşeceği seçilene kadar taş konmaz.
      setPendingWild({ r, c });
      return;
    }
    dispatch({ type: 'PLACE_TILE', r, c });
  };

  const canAct = !state.isGameOver && !me.isAI;

  const handlePlay = async () => {
    // Rakip köşeye giriş tespiti.
    const placedCoords = Object.keys(state.placed).map(
      (k) => k.split(',').map(Number) as [number, number],
    );
    const { shares } = computeInvasionSplit(
      placedCoords,
      state.current,
      state.players,
      potentialScore,
      state.board,
    );
    const invasion = shares.length > 0
      ? shares.map((s) => ({ ownerName: state.players[s.index].name, ownerPts: s.amount }))
      : null;

    // Sunucu kelime doğrulaması (Supabase yapılandırılmışsa).
    if (isSupabaseConfigured) {
      const structural = validatePlacementStructural(
        state.board,
        state.placed,
        state.current,
        me.corners,
        isFirstMove(state),
      );
      if (structural.valid && structural.words && structural.words.length > 0) {
        setValidating(true);
        let serverOk = true;
        try {
          for (const word of structural.words) {
            const result = await isValidWordRemote(trLower(word));
            if (result === false) {
              dispatch({
                type: 'SET_MESSAGE',
                message: `"${word}" geçerli bir kelime değil.`,
                messageType: 'err',
              });
              return;
            }
            if (result === null) {
              // Sunucu hatası — yerel sözlüğe düş.
              serverOk = false;
              break;
            }
          }
        } finally {
          setValidating(false);
        }
        if (serverOk) {
          // Tüm kelimeler sunucuda onaylandı, yerel kontrol atla.
          pendingSkipWordCheck.current = true;
          if (invasion) { setInvasionConfirm(invasion); return; }
          dispatch({ type: 'PLAY', skipWordCheck: true });
          return;
        }
      }
    }

    // Supabase yoksa veya yapısal kontrol başarısızsa yerel doğrulama (reducer).
    pendingSkipWordCheck.current = false;
    if (invasion) { setInvasionConfirm(invasion); } else { dispatch({ type: 'PLAY' }); }
  };

  // Pas, sırayı tümüyle harcadığı için onay ister.
  const handlePass = () => {
    const placed = Object.keys(state.placed).length > 0;
    const msg = placed
      ? 'Pas geçilsin mi? Tahtaya koyduğun taşlar rafa geri alınır ve sıran geçer.'
      : 'Pas geçmek istediğine emin misin? Sıran karşı tarafa geçer.';
    if (window.confirm(msg)) dispatch({ type: 'PASS' });
  };

  const potentialScore = moveStatus?.score ?? 0;

  const dragHiddenKey = ghost && ghost.source.kind === 'placed'
    ? key(ghost.source.r, ghost.source.c)
    : null;
  const dragHiddenIndex = ghost && ghost.source.kind === 'rack' ? ghost.source.index : null;

  return (
    <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden">
      <GameHeader
        state={state}
        onLogoClick={() => setShowExitConfirm(true)}
      />

      <Board
        state={state}
        onCellClick={handleCellClick}
        moveStatus={moveStatus}
        onOpenHistory={() => setShowHistory(true)}
        dragHiddenKey={dragHiddenKey}
        dragOverKey={ghost?.overKey ?? null}
        dragOverValid={ghost?.overValid ?? false}
        onTilePointerDown={(r, c, e) =>
          beginDrag({ kind: 'placed', r, c, tile: state.placed[key(r, c)] }, e)
        }
        onTilePointerMove={moveDrag}
        onTilePointerUp={endDrag}
        onTilePointerCancel={cancelDrag}
      />

      <div className="w-full max-w-[680px] px-3 pb-3 pt-1 flex flex-col gap-1.5">
        <div
          className={`text-[11px] font-mono text-center min-h-[15px] py-0.5 ${
            MESSAGE_COLORS[liveMessageType]
          }`}
        >
          {liveMessage}
        </div>

        <div className="flex gap-1.5 items-stretch">
          <div className="flex-1 min-w-0">
            <Rack
              tiles={rackPlayer.rack}
              selectedTile={state.selectedTile}
              onSelect={(i) => {
                if (me.isAI) return;
                if (state.swapMode) dispatch({ type: 'TOGGLE_SWAP_TILE', index: i });
                else dispatch({ type: 'SELECT_TILE', index: i });
              }}
              title={rackPlayer.name}
              color={rackColor}
              swapMode={state.swapMode}
              swapSelection={state.swapSelection}
              draggable={canAct}
              dragHiddenIndex={dragHiddenIndex}
              onTilePointerDown={(i, e) =>
                beginDrag({ kind: 'rack', index: i, tile: rackPlayer.rack[i] }, e)
              }
              onTilePointerMove={moveDrag}
              onTilePointerUp={endDrag}
              onTilePointerCancel={cancelDrag}
            />
          </div>
          {!state.swapMode && (
            state.isGameOver ? (
              <button
                onClick={() => dispatch({ type: 'INIT' })}
                className="shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] transition-transform"
              >
                Yeni Oyun Aç
              </button>
            ) : (
              <button
                disabled={!canAct || validating}
                onClick={() => { void handlePlay(); }}
                className="shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
              >
                {validating ? 'Kontrol…' : 'Oyna'}
              </button>
            )
          )}
        </div>

        {state.swapMode ? (
          <div className="flex gap-1.5">
            <button
              disabled={!canAct || state.swapSelection.length === 0}
              onClick={() => dispatch({ type: 'CONFIRM_SWAP' })}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-gold text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Değiştir{state.swapSelection.length > 0 ? ` (${state.swapSelection.length})` : ''}
            </button>
            <button
              disabled={!canAct}
              onClick={() => dispatch({ type: 'TOGGLE_SWAP_MODE' })}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-muted border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Vazgeç
            </button>
          </div>
        ) : (
          <div className="flex gap-1.5">
            <button
              disabled={!canAct}
              onClick={handlePass}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Pas Geç
            </button>
            <button
              disabled={!canAct || state.bag.length === 0}
              onClick={() => dispatch({ type: 'TOGGLE_SWAP_MODE' })}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Değiştir
            </button>
            <button
              disabled={!canAct}
              onClick={() => dispatch({ type: 'SHUFFLE_RACK' })}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Karıştır
            </button>
            <button
              disabled={!canAct}
              onClick={() => dispatch({ type: 'RECALL_ALL' })}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              Geri Al
            </button>
            <button
              onClick={() => setShowTiles(true)}
              className="flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform"
            >
              Torba <span className="text-[13px] text-accent">{state.bag.length}</span>
            </button>
          </div>
        )}
      </div>

      {invasionConfirm && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center bg-black/40 px-4">
          <div className="w-full max-w-sm bg-panel rounded-2xl shadow-2xl p-6 flex flex-col gap-4">
            <p className="text-sm text-text font-sans leading-relaxed">
              Dikkat, kelimen rakip köşesine giriyor ya da sınırına değiyor. Bu hamleden kazanacağın {potentialScore} puanın{' '}
              {invasionConfirm
                .map((inv, i) => (
                  <span key={i}>
                    <strong>{inv.ownerPts} puanını</strong> <strong>{inv.ownerName}</strong>
                    {i < invasionConfirm.length - 1 ? ', ' : ' '}
                  </span>
                ))}
              kapacak. Devam etmek istiyor musun?
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={() => {
                  const skip = pendingSkipWordCheck.current;
                  pendingSkipWordCheck.current = false;
                  setInvasionConfirm(null);
                  dispatch({ type: 'PLAY', skipWordCheck: skip });
                }}
                className="flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Oyna
              </button>
              <button
                onClick={() => setInvasionConfirm(null)}
                className="flex-1 py-2.5 rounded-md border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Vazgeç
              </button>
            </div>
          </div>
        </div>
      )}

      {showExitConfirm && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center bg-black/40 px-4">
          <div className="w-full max-w-sm bg-panel rounded-2xl shadow-2xl p-6 flex flex-col gap-4">
            <p className="text-sm text-text font-sans leading-relaxed">
              {state.isGameOver
                ? 'Anasayfaya dönmek istediğinden emin misin?'
                : 'Bu oyundan çıkmak istediğine emin misin? Teslim olursun, oyun bu şekilde kaydedilir ve puanından 2 puan düşülür.'}
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={() => {
                  setShowExitConfirm(false);
                  if (!state.isGameOver) {
                    const record = buildGameRecord(true);
                    if (record) void saveGame(record);
                  }
                  dispatch({ type: 'ABANDON' });
                }}
                className="flex-1 py-2.5 rounded-md bg-red text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Çık
              </button>
              <button
                onClick={() => setShowExitConfirm(false)}
                className="flex-1 py-2.5 rounded-md border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Vazgeç
              </button>
            </div>
          </div>
        </div>
      )}

      {meaning && (
        <MeaningModal entries={meaning.entries} onClose={() => setMeaning(null)} />
      )}

      {showTiles && (
        <RemainingTilesModal state={state} onClose={() => setShowTiles(false)} />
      )}

      {showHistory && (
        <MoveHistoryModal state={state} onClose={() => setShowHistory(false)} />
      )}

      {pendingWild && (
        <WildcardModal
          onSelect={(letter) => {
            dispatch({
              type: 'PLACE_TILE',
              r: pendingWild.r,
              c: pendingWild.c,
              wildLetter: letter,
              rackIndex: pendingWild.rackIndex,
            });
            setPendingWild(null);
          }}
          onClose={() => setPendingWild(null)}
        />
      )}

      {ghost && (
        <div
          className="fixed z-[300] pointer-events-none"
          style={{
            left: ghost.x,
            top: ghost.y - DRAG_LIFT,
            width: 46,
            height: 46,
            transform: 'translate(-50%, -50%) scale(1.1)',
            filter: 'drop-shadow(0 10px 16px rgba(0,0,0,0.35))',
          }}
        >
          <Tile
            tile={ghost.source.tile}
            variant={ghost.source.kind === 'rack' ? 'rack' : 'placed'}
            color={ghost.source.kind === 'placed' ? PLAYER_COLORS[me.colorIndex] : undefined}
          />
        </div>
      )}

      <GameOver
        show={state.isGameOver && !gameOverDismissed}
        players={state.players}
        turnCount={state.turnCount}
        onOpenHistory={() => setShowHistory(true)}
        onClose={() => setGameOverDismissed(true)}
      />
    </div>
  );
}
