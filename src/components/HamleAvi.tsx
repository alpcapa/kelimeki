// Kelimeki — "Hamle Avı" ekranı (3 Kasım 2026, ROADMAP #48).
//
// Hazır bir tahta pozisyonu + 7 harflik raf: süre dolmadan en yüksek puanlı
// (bölge vergisi DAHİL net) hamleyi bul. Bulursan "Tebrikler", seri +1; süre
// biterse "Üzgünüz" ve seri 0. Kararlar ve tasarım: docs/decisions/product-backlog.md
// → "En iyi hamleyi bul" → "UYGULAMA KARARLARI (3 Kasım 2026)".
//
// ⚠ YALITIM (tanıtımla aynı, `TutorialGame`): kendi `useReducer`'ı var; kayıt,
// bulut kaydı, `logGameStart`, `games` satırı, k-lig, istatistik, terk cezası
// ÇALIŞMAZ. Motora DOKUNMAZ — pozisyon `RESUME_SAVED` ile yüklenir, hamle
// gerçek `PLAY` reducer'ından geçer (vergi dahil net puan = skor farkı).
// Sürükleme jesti `TutorialGame`'inkinin sadeleştirilmiş eşi (taslak taş geri
// sürükleme, ıskalama kurtarma, zoom YOK; seçim + dokunma + sürükle var).
import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from 'react';
import { PLAYER_COLORS } from '../game/constants';
import { gameReducer, isFirstMove } from '../game/gameReducer';
import type { GameState, Tile as TileModel } from '../game/types';
import { getFormedWords, key } from '../utils/board';
import { calcScore, validatePlacement } from '../utils/validator';
import { swallowNextClick } from '../utils/ghostClick';
import {
  GHOST_TILE_STYLE,
  TAP_SLOP_ON_RELEASE,
  dragThresholdFor,
  liftedPoint,
} from '../utils/dragFeel';
import { isWordSetReady, preloadWordSet } from '../data/wordSetLoader';
import {
  HAMLE_AVI_SECONDS,
  HAMLE_AVI_WARN_SECONDS,
  isCorrect,
  netGain,
  onFound,
  onMissed,
  pickNext,
  positionToState,
  shouldWarnOnLeave,
  type HamleAviPosition,
  type StreakState,
} from '../utils/hamleAvi';
import { loadHamleAvi, mergeWithServer, saveHamleAvi } from '../utils/hamleAviStore';
import { fetchHamleAvi, reportHamleAvi } from '../lib/hamleAviApi';
import { useModalA11y } from '../hooks/useModalA11y';
import { Avatar } from './Avatar';
import { Board } from './Board';
import { Modal } from './Modal';
import { Rack } from './Rack';
import { Tile } from './Tile';
import { WildcardModal } from './WildcardModal';

/** Tanıtım penceresindeki açıklamalar (ilk versiyonla aynı, süre 3 dk). */
export const HAMLE_AVI_INTRO_POINTS = [
  'Bulursan sıradakine geç, istediğin kadar devam et.',
  'k-lig puanını etkilemez.',
];

const MESSAGE_COLORS: Record<string, string> = {
  ok: 'text-green',
  err: 'text-red',
  warn: 'text-gold',
  '': 'text-muted',
};

type Phase = 'loading' | 'intro' | 'play' | 'found' | 'missed' | 'exhausted';

interface HamleAviProps {
  playerName: string;
  avatarUrl?: string | null;
  /** Girişli kullanıcı kimliği — verilmezse (misafir) yalnızca cihaz deposu. */
  userId?: string | null;
  onExit: () => void;
}

const fmt = (ms: number) => {
  const s = Math.max(0, Math.ceil(ms / 1000));
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
};

export function HamleAvi({ playerName, avatarUrl, userId, onExit }: HamleAviProps) {
  const [state, dispatch] = useReducer(gameReducer, undefined, () =>
    positionToState(EMPTY_POSITION, playerName),
  );
  const [phase, setPhase] = useState<Phase>('loading');
  const [wordsReady, setWordsReady] = useState(isWordSetReady());
  const [streak, setStreak] = useState<StreakState>(() => ({ streak: 0, best: loadHamleAvi().best }));
  const [remaining, setRemaining] = useState(HAMLE_AVI_SECONDS * 1000);
  const [leaveOpen, setLeaveOpen] = useState(false);
  const [dontShow, setDontShow] = useState(false);
  const [lastNet, setLastNet] = useState(0);
  const [note, setNote] = useState<{ text: string; type: 'ok' | 'err' | 'warn' | '' } | null>(null);
  const [loadError, setLoadError] = useState(false);
  const [pendingWild, setPendingWild] = useState<{ r: number; c: number; rackIndex: number } | null>(null);

  const bankRef = useRef<HamleAviPosition[] | null>(null);
  const posRef = useRef<HamleAviPosition | null>(null);
  const initialRef = useRef<GameState | null>(null);
  const seenRef = useRef<Set<number>>(new Set(loadHamleAvi().seen));
  const streakRef = useRef(streak);
  streakRef.current = streak;
  const endsAt = useRef(0);
  const me = state.players[state.current];

  // ── Veri: sözlük + banka (lazy chunk) + sunucu eşitlemesi ────────────────
  useEffect(() => {
    saveHamleAvi({ opened: true }); // "YENİ" balonu kalkar
    let iptal = false;
    (async () => {
      let loaded;
      try {
        loaded = await Promise.all([
        isWordSetReady() ? Promise.resolve() : preloadWordSet().catch(() => undefined),
        import('../data/hamleAviBank.json'),
        userId ? Promise.race([fetchHamleAvi(), new Promise<null>((r) => setTimeout(() => r(null), 2500))]) : null,
        ]);
      } catch {
        // Banka parçası indirilemedi (ilk açılışta çevrimdışı). Bir kez inmişse SW önbelleğinden gelir.
        if (!iptal) setLoadError(true);
        return;
      }
      if (iptal) return;
      const [, bankMod, server] = loaded;
      bankRef.current = (bankMod.default ?? bankMod) as unknown as HamleAviPosition[];
      const merged = server ? mergeWithServer(server) : loadHamleAvi();
      seenRef.current = new Set(merged.seen);
      setStreak((s) => ({ ...s, best: merged.best }));
      setWordsReady(true);
      // Cihaz sunucudan ilerideyse (çevrimdışı oynanmışsa) arka planda gönder.
      if (userId) void reportHamleAvi(merged.best, merged.seen);
      loadNext(false);
    })();
    return () => {
      iptal = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [userId]);

  /** Sıradaki görülmemiş bulmacayı yükler; banka bittiyse 'exhausted'. */
  const loadNext = (skipIntro: boolean) => {
    const bank = bankRef.current;
    if (!bank) return;
    const pos = pickNext(bank, seenRef.current);
    if (!pos) {
      setPhase('exhausted');
      return;
    }
    // Görüldü sayılır: ekrana geldiği an (bulamasa da tekrar çıkmaz).
    seenRef.current.add(pos.id);
    saveHamleAvi({ seen: [...seenRef.current] });
    posRef.current = pos;
    const st = positionToState(pos, playerName);
    initialRef.current = st;
    dispatch({ type: 'RESUME_SAVED', state: st });
    setNote(null);
    setRemaining(HAMLE_AVI_SECONDS * 1000);
    if (skipIntro || loadHamleAvi().introHidden) {
      endsAt.current = Date.now() + HAMLE_AVI_SECONDS * 1000;
      setPhase('play');
    } else {
      setPhase('intro');
    }
  };

  // ── Geri sayım ───────────────────────────────────────────────────────────
  // Yalnızca 'play' evresinde ve çıkış uyarısı kapalıyken akar; durunca kalan
  // süre `remaining`de saklanır, devam edince oradan sürer.
  const running = phase === 'play' && !leaveOpen;
  useEffect(() => {
    if (!running) return;
    endsAt.current = Date.now() + remaining;
    const id = window.setInterval(() => {
      const left = endsAt.current - Date.now();
      if (left <= 0) {
        window.clearInterval(id);
        setRemaining(0);
        finish(false, 0);
      } else {
        setRemaining(left);
      }
    }, 200);
    return () => window.clearInterval(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [running]);

  /** Bulmaca sonucu: seri/rekor güncellenir, cihaza yazılır, hesapsa sunucuya gider. */
  const finish = useCallback(
    (found: boolean, net: number) => {
      const next = found ? onFound(streakRef.current) : onMissed(streakRef.current);
      setStreak(next);
      setLastNet(net);
      setPhase(found ? 'found' : 'missed');
      const local = saveHamleAvi({ best: Math.max(loadHamleAvi().best, next.best) });
      if (userId) void reportHamleAvi(local.best, local.seen);
    },
    [userId],
  );

  // ── Hamle sonucu: `PLAY` başarılı olduysa tur sayacı değişir ──────────────
  useEffect(() => {
    const init = initialRef.current;
    const pos = posRef.current;
    if (phase !== 'play' || !init || !pos || state.turnCount === init.turnCount) return;
    const net = netGain(init, state);
    if (isCorrect(net, pos)) {
      finish(true, net);
    } else {
      // Geçerli ama daha iyisi var: pozisyon sıfırlanır, süre SÜRER (kullanıcı onayı 3 Kas 2026:
      // süre SIFIRLANMAZ — backlog "UYGULAMA KARARLARI").
      setNote({ text: `${net} puan aldın — daha iyisi var, tekrar dene.`, type: 'warn' });
      dispatch({ type: 'RESUME_SAVED', state: init });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.turnCount]);

  // ── Yerleştirme ──────────────────────────────────────────────────────────
  const canAct = phase === 'play';
  const placeAt = (r: number, c: number, rackIndex: number) => {
    const t = me.rack[rackIndex];
    if (!t) return;
    if (t.letter === '?') {
      setPendingWild({ r, c, rackIndex });
      return;
    }
    dispatch({ type: 'PLACE_TILE', r, c, rackIndex });
  };

  const handleCellClick = (r: number, c: number) => {
    if (!canAct) return;
    if (state.placed[key(r, c)]) {
      dispatch({ type: 'RECALL_CELL', r, c });
      return;
    }
    if (state.board[r][c]) return;
    if (state.selectedTile === null) return;
    placeAt(r, c, state.selectedTile);
  };

  const [ghost, setGhost] = useState<{ x: number; y: number; index: number; tile: TileModel } | null>(null);
  const [dragOverKey, setDragOverKey] = useState<string | null>(null);
  const dragRef = useRef<{ index: number; tile: TileModel; x: number; y: number; moved: boolean } | null>(null);

  const hucreAt = (x: number, y: number): string | null => {
    const el = document.elementFromPoint(x, y);
    return (el?.closest('[data-cell]') as HTMLElement | null)?.getAttribute('data-cell') ?? null;
  };
  const bosHucre = (k: string | null): boolean => {
    if (!k) return false;
    const [r, c] = k.split(',').map(Number);
    return !state.board[r][c] && !state.placed[k];
  };

  const onRackPointerDown = (i: number, e: React.PointerEvent<HTMLDivElement>) => {
    if (!canAct) return;
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      // yakalama olmadan da çalışır
    }
    dragRef.current = { index: i, tile: me.rack[i], x: e.clientX, y: e.clientY, moved: false };
  };
  const onRackPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    if (!d) return;
    if (!d.moved) {
      if (Math.hypot(e.clientX - d.x, e.clientY - d.y) < dragThresholdFor(e.pointerType)) return;
      d.moved = true;
    }
    const y = liftedPoint(e.clientY);
    setGhost({ x: e.clientX, y, index: d.index, tile: d.tile });
    setDragOverKey(hucreAt(e.clientX, y));
  };
  const onRackPointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
    if (!d) return;
    if (Math.hypot(e.clientX - d.x, e.clientY - d.y) < TAP_SLOP_ON_RELEASE) {
      dispatch({ type: 'SELECT_TILE', index: d.index });
      return;
    }
    const k = hucreAt(e.clientX, liftedPoint(e.clientY));
    if (!bosHucre(k)) return;
    const [r, c] = k!.split(',').map(Number);
    placeAt(r, c, d.index);
    // Jestin ardından gelen compat `click` yeni konan taşı geri alırdı.
    swallowNextClick();
  };
  const onRackPointerCancel = () => {
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
  };

  // ── Oyna ─────────────────────────────────────────────────────────────────
  const handlePlay = () => {
    if (!canAct || !wordsReady) return;
    setNote(null);
    dispatch({ type: 'PLAY' }); // geçersizse reducer `state.message` yazar, tur sayacı değişmez
  };

  const moveStatus = useMemo(() => {
    const keys = Object.keys(state.placed);
    if (keys.length === 0 || !wordsReady || !me) return null;
    const result = validatePlacement(state.board, state.placed, state.current, me.corners, isFirstMove(state));
    const formed = getFormedWords(state.board, state.placed);
    const cells =
      formed.length > 0 ? formed.flatMap((f) => f.coords) : (keys.map((k) => k.split(',').map(Number)) as [number, number][]);
    return { valid: result.valid, reason: result.reason, cells, score: calcScore(state.board, state.placed, state.bonuses) };
  }, [state.placed, state.board, state.current, state.bonuses, me, wordsReady, state]);

  // ── Çıkış ────────────────────────────────────────────────────────────────
  const handleExit = () => {
    if (phase === 'play' && shouldWarnOnLeave(streak)) {
      setLeaveOpen(true);
      return;
    }
    onExit();
  };
  const confirmLeave = () => {
    // Çıkış seriyi sıfırlar; rekor zaten cihazda/sunucuda.
    setStreak(onMissed(streak));
    onExit();
  };

  /** Tanıtımdan vazgeç: bulmaca yakılmaz (görülenlerden çıkarılır) ve ekrandan çıkılır. */
  const leaveIntro = () => {
    if (posRef.current) {
      seenRef.current.delete(posRef.current.id);
      saveHamleAvi({ seen: [...seenRef.current] });
    }
    onExit();
  };

  const startPlaying = () => {
    if (dontShow) saveHamleAvi({ introHidden: true });
    endsAt.current = Date.now() + HAMLE_AVI_SECONDS * 1000;
    setPhase('play');
  };

  const leaveRef = useModalA11y(leaveOpen, () => setLeaveOpen(false));
  const resultRef = useModalA11y(phase === 'found' || phase === 'missed' || phase === 'exhausted', handleExit);

  const mesaj = note?.text ?? (phase === 'play' ? state.message : '');
  const mesajTipi = note?.type ?? (phase === 'play' ? state.messageType : '');
  const warn = remaining <= HAMLE_AVI_WARN_SECONDS * 1000;
  const color = PLAYER_COLORS[me?.colorIndex ?? 0];
  const pos = posRef.current;

  return (
    <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden" data-hamle-avi="">
      {/* Üst şerit: solda Seri/Rekor, ortada büyük geri sayım, sağda avatar. */}
      <div className="w-full max-w-[680px] px-3 pt-2 flex items-center justify-between">
        <span className="font-mono text-[10px] tracking-[1.5px] text-muted">🎯 HAMLE AVI</span>
        <button
          onClick={handleExit}
          className="font-mono text-[10px] tracking-[1.5px] text-accent min-h-[44px] px-1 active:opacity-70 transition-opacity"
        >
          ÇIK ✕
        </button>
      </div>
      <div className="w-full max-w-[680px] px-3">
        <div className="bg-panel border border-border rounded-md flex items-center justify-between px-3 py-2">
          <div className="flex flex-col items-start" data-hamle-avi-seri="">
            <span className="text-[10px] text-muted uppercase font-mono">Seri</span>
            <span className="font-mono font-bold text-xl leading-none">{streak.streak}</span>
            <span className="text-[10px] text-muted font-mono mt-0.5">Rekor {streak.best}</span>
          </div>
          <div className="text-center">
            <span className="block text-[10px] text-muted uppercase font-mono">Kalan süre</span>
            <span
              data-hamle-avi-sure=""
              className={`block font-mono font-bold leading-none ${warn && phase === 'play' ? 'text-red' : 'text-text'}`}
              style={{ fontSize: 38 }}
              aria-live="off"
            >
              {fmt(remaining)}
            </span>
          </div>
          <div className="flex flex-col items-end">
            <Avatar url={avatarUrl} name={playerName} size={40} />
            <span className="text-[10px] text-muted mt-1 max-w-[80px] truncate">{playerName}</span>
          </div>
        </div>
      </div>

      <main className="w-full flex flex-col items-center mt-2">
        <div className="relative w-full flex flex-col items-center">
          <Board
            state={state}
            onCellClick={(r, c) => handleCellClick(r, c)}
            moveStatus={moveStatus}
            onOpenHistory={() => {}}
            hideFooter
            tileLifted={ghost !== null}
            dragOverKey={dragOverKey}
            dragOverValid={ghost ? bosHucre(dragOverKey) : false}
          />
        </div>

        <div className="w-full max-w-[680px] px-3 pb-3 pt-1 flex flex-col gap-1.5">
          <div
            data-mesaj=""
            className={`text-[11px] font-mono font-bold text-center min-h-[30px] py-0.5 flex items-center justify-center ${MESSAGE_COLORS[mesajTipi]}`}
          >
            {phase === 'loading'
              ? loadError
                ? 'Bulmacalar yüklenemedi — bağlantını kontrol edip tekrar dene.'
                : 'Bulmaca hazırlanıyor…'
              : mesaj}
          </div>
          <div className="flex gap-1.5 items-stretch">
            <div className="flex-1 min-w-0">
              <Rack
                tiles={me?.rack ?? []}
                selectedTile={state.selectedTile}
                onSelect={() => {}}
                title={playerName}
                color={color}
                draggable={canAct}
                dragHiddenIndex={ghost?.index ?? null}
                onTilePointerDown={onRackPointerDown}
                onTilePointerMove={onRackPointerMove}
                onTilePointerUp={onRackPointerUp}
                onTilePointerCancel={onRackPointerCancel}
              />
            </div>
            <button
              disabled={!canAct || !wordsReady || Object.keys(state.placed).length === 0}
              onClick={handlePlay}
              className="btn-raised shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] disabled:opacity-35 disabled:cursor-not-allowed"
            >
              {!wordsReady ? 'Yükleniyor…' : 'Oyna'}
            </button>
          </div>
        </div>
      </main>

      {ghost && (
        <div className="pointer-events-none fixed z-[300]" style={{ left: ghost.x, top: ghost.y, ...GHOST_TILE_STYLE }}>
          <Tile tile={ghost.tile} variant="rack" />
        </div>
      )}

      {phase === 'intro' && (
        // Standart modal kabuğu (kullanıcı, 3 Kasım 2026: genişlik/başlık diğer pencerelerle aynı).
        // Kabuk saydam bindirme: tahta arkada görünür, süre "Başla"ya kadar durur.
        // ✕ / Escape / dışarı tıklama = Vazgeç; o bulmaca görülmüş SAYILMAZ (yakılmasın).
        <Modal title="Hamle Avı" onClose={leaveIntro}>
          <div data-hamle-avi-intro="">
            <p className="text-sm text-text font-sans leading-relaxed m-0 mb-2">
              <b>{HAMLE_AVI_SECONDS / 60} dakika</b> içinde elindeki harflerle oynanabilecek{' '}
              <b>en yüksek puanlı hamleyi</b> bul.
            </p>
            <ul className="text-xs text-muted font-sans mb-3" style={{ listStyle: 'disc', paddingLeft: 18 }}>
              {HAMLE_AVI_INTRO_POINTS.map((t) => (
                <li key={t}>{t}</li>
              ))}
            </ul>
            <label className="flex items-center gap-2 text-xs font-sans mb-3">
              <input type="checkbox" checked={dontShow} onChange={(e) => setDontShow(e.target.checked)} style={{ width: 16, height: 16 }} />
              Bir daha gösterme
            </label>
            <div className="flex gap-2">
              <button
                onClick={leaveIntro}
                className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Vazgeç
              </button>
              <button
                onClick={startPlaying}
                className="btn-raised btn-raised-orange flex-1 py-2.5 rounded-md bg-orange text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Başla
              </button>
            </div>
          </div>
        </Modal>
      )}

      {pendingWild && (
        <WildcardModal
          onSelect={(letter) => {
            dispatch({ type: 'PLACE_TILE', r: pendingWild.r, c: pendingWild.c, rackIndex: pendingWild.rackIndex, wildLetter: letter });
            setPendingWild(null);
          }}
          onClose={() => setPendingWild(null)}
        />
      )}

      {leaveOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4 bg-[rgba(15,23,42,0.5)]">
          <div
            ref={leaveRef}
            role="dialog"
            aria-modal="true"
            aria-label="Çıkış onayı"
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-4 outline-none"
          >
            <p className="text-base font-bold text-text font-sans">Çıkmak istiyor musun?</p>
            <p className="text-sm text-text font-sans leading-relaxed">
              Çıkarsan serin sıfırlanır (Seri: <strong>{streak.streak}</strong>). Rekorun ({streak.best}) korunur.
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={confirmLeave}
                className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Çık
              </button>
              <button
                onClick={() => setLeaveOpen(false)}
                className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Devam
              </button>
            </div>
          </div>
        </div>
      )}

      {(phase === 'found' || phase === 'missed' || phase === 'exhausted') && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-5 bg-[rgba(15,23,42,0.5)]">
          <div
            ref={resultRef}
            role="dialog"
            aria-modal="true"
            aria-label="Sonuç"
            data-hamle-avi-sonuc={phase}
            tabIndex={-1}
            className="w-full max-w-sm bg-panel rounded-[22px] shadow-[0_24px_60px_rgba(15,23,42,0.55)] p-6 flex flex-col gap-3 outline-none"
          >
            {phase === 'found' && (
              <>
                <p className="text-[26px] leading-[30px] font-bold text-text font-sans m-0">Tebrikler! 🎯</p>
                <p className="text-sm text-text font-sans m-0">
                  En iyi hamleyi buldun: <strong className="text-green">{lastNet}</strong> puan. Seri:{' '}
                  <strong>{streak.streak}</strong> · Rekor: <strong>{streak.best}</strong>
                </p>
              </>
            )}
            {phase === 'missed' && (
              <>
                <p className="text-[26px] leading-[30px] font-bold text-text font-sans m-0">Üzgünüz, bulamadınız</p>
                <p className="text-sm text-text font-sans m-0">
                  En yüksek hamle puanı <strong className="text-red">{pos?.k}</strong> idi
                  {pos ? <> (<strong>{pos.w}</strong>)</> : null}. Serin sıfırlandı; rekorun {streak.best}.
                </p>
              </>
            )}
            {phase === 'exhausted' && (
              <>
                <p className="text-[26px] leading-[30px] font-bold text-text font-sans m-0">Hepsini çözdün!</p>
                <p className="text-sm text-text font-sans m-0">
                  Şimdilik tüm bulmacaları gördün — yeni bulmacalar yakında. Rekorun: <strong>{streak.best}</strong>
                </p>
              </>
            )}
            <div className="flex gap-2 mt-2">
              {phase !== 'exhausted' && (
                <button
                  onClick={() => loadNext(true)}
                  className="btn-raised btn-raised-orange flex-1 min-h-[48px] rounded-md bg-orange text-white text-sm font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
                >
                  Sonraki
                </button>
              )}
              <button
                onClick={onExit}
                className="btn-raised-neutral flex-1 min-h-[48px] rounded-md bg-void border border-border text-text text-sm font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                {phase === 'exhausted' ? 'Tamam' : 'Çık'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

/** İlk render için boş pozisyon (banka yüklenene kadar tahta boş + raf boş). */
const EMPTY_POSITION: HamleAviPosition = { id: -1, o: 0, t: [], r: '', k: 0, w: '' };
