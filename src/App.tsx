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
import { calcScore, computeBreachedCorners, computeInvasionSplit, validatePlacement, validatePlacementStructural } from './utils/validator';
import { getFormedWords, key } from './utils/board';
import { trLower } from './utils/turkish';
import { PLAYER_COLORS } from './game/constants';
import { fetchMeaning, isValidWordRemote, isSupabaseConfigured, saveGame } from './lib/api';
import type { WordMeaning } from './lib/database.types';
import { useAuth } from './hooks/useAuth';
import { AddToHomeScreen } from './components/AddToHomeScreen';

const AI_THINK_MS = 1100;

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

  // Hamle geçmişi penceresi.
  const [showHistory, setShowHistory] = useState(false);

  // Joker taş konurken hangi harfe dönüşeceğini seçme penceresi.
  const [pendingWild, setPendingWild] = useState<{ r: number; c: number } | null>(null);

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

  // Oyun bitince giriş yapmış kullanıcının sonucunu kaydet (YZ'ye karşı oyunlar dahil).
  useEffect(() => {
    if (!state.isGameOver || state.phase !== 'play') return;
    const human = state.players.find((p) => !p.isAI);
    const opponents = state.players.filter((p) => p !== human);
    if (!human || opponents.length === 0) return;
    const bestOpponentScore = Math.max(...opponents.map((p) => p.score));
    const result =
      human.score > bestOpponentScore ? 'win' : human.score < bestOpponentScore ? 'lose' : 'tie';
    void saveGame({
      player_score: human.score,
      ai_score: bestOpponentScore,
      result,
      turn_count: state.turnCount,
      move_count: human.moveCount || null,
      best_move_score: human.bestMoveScore || null,
      best_word: human.bestWord || null,
      longest_word: human.longestWord || null,
    });
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

    const open = computeBreachedCorners(state.board, state.players);
    const result = validatePlacement(
      state.board,
      state.placed,
      current.corner,
      open,
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
      cells,
      score: calcScore(state.board, state.placed, state.bonuses),
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.placed, state.board, state.players, state.current]);

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
  const rackPlayerIndex = state.players.indexOf(rackPlayer);

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
    if (state.placed[k]) {
      dispatch({ type: 'RECALL_CELL', r, c });
      return;
    }
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
    const { shares } = computeInvasionSplit(placedCoords, me.corner, state.players, potentialScore);
    const invasion = shares.length > 0
      ? shares.map((s) => ({ ownerName: state.players[s.index].name, ownerPts: s.amount }))
      : null;

    // Sunucu kelime doğrulaması (Supabase yapılandırılmışsa).
    if (isSupabaseConfigured) {
      const open = computeBreachedCorners(state.board, state.players);
      const structural = validatePlacementStructural(
        state.board,
        state.placed,
        me.corner,
        open,
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
      />

      <div className="w-full max-w-[680px] px-3 pb-3 pt-1 flex flex-col gap-1.5">
        <div
          className={`text-[11px] font-mono text-center min-h-[15px] py-0.5 ${
            MESSAGE_COLORS[state.messageType]
          }`}
        >
          {state.message}
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
            />
          </div>
          {!state.swapMode && (
            <button
              disabled={!canAct || validating}
              onClick={() => { void handlePlay(); }}
              className="shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
            >
              {validating ? 'Kontrol…' : 'Oyna'}
            </button>
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
              Dikkat, rakip köşesinde oynuyorsun. Bu hamleden kazanacağın {potentialScore} puanın{' '}
              {invasionConfirm.length > 1
                ? invasionConfirm
                    .map((inv, i) => (
                      <span key={i}>
                        <strong>{inv.ownerPts} puanını</strong> <strong>{inv.ownerName}</strong>
                        {i < invasionConfirm.length - 1 ? ', ' : ' '}
                      </span>
                    ))
                : (
                  <>
                    <strong>yarısını ({invasionConfirm[0].ownerPts} puan)</strong>{' '}
                    <strong>{invasionConfirm[0].ownerName}</strong>{' '}
                  </>
                )}
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
              {'Bu oyundan çıkmak istediğine emin misin? Oyun kaydedilmez ve mevcut ilerleme silinir.'}
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={() => { setShowExitConfirm(false); dispatch({ type: 'ABANDON' }); }}
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
        <MoveHistoryModal
          state={state}
          humanIndex={rackPlayerIndex}
          onClose={() => setShowHistory(false)}
        />
      )}

      {pendingWild && (
        <WildcardModal
          onSelect={(letter) => {
            dispatch({ type: 'PLACE_TILE', r: pendingWild.r, c: pendingWild.c, wildLetter: letter });
            setPendingWild(null);
          }}
          onClose={() => setPendingWild(null)}
        />
      )}

      <GameOver
        show={state.isGameOver}
        players={state.players}
        turnCount={state.turnCount}
        onRestart={() => dispatch({ type: 'INIT' })}
      />
    </div>
  );
}
