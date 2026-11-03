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
import { PLAYER_COLORS, SIZE } from '../game/constants';
import { gameReducer, isFirstMove } from '../game/gameReducer';
import type { GameState, Tile as TileModel } from '../game/types';
import { getFormedWords, getFullWordAt, key } from '../utils/board';
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
import { fetchHamleAvi, logHamleAviEvent, reportHamleAvi } from '../lib/hamleAviApi';
import { fetchMeaning } from '../lib/api';
import type { WordMeaning } from '../lib/database.types';
import { MeaningModal } from './MeaningModal';
import { findBestNetMove, type BestMove } from '../utils/hamleAviSolve';
import { useModalA11y } from '../hooks/useModalA11y';
import { useBoardZoom } from '../hooks/useBoardZoom';
import { nearbyDraftCell } from '../utils/draftRescue';
import { setActivelyPlaying } from '../lib/pwa';
import { UserMenu } from './UserMenu';
import { Board } from './Board';
import { LogoMark } from './LogoMark';
import { Modal } from './Modal';
import { Rack } from './Rack';
import { Tile } from './Tile';
import { WildcardModal } from './WildcardModal';

/** Tanıtım penceresindeki açıklamalar (ilk versiyonla aynı, süre 3 dk). */
export const HAMLE_AVI_INTRO_POINTS = [
  'Bölge vergisi puana dahildir.',
  'Bulursan sıradakine geç, istediğin kadar devam et.',
  'k-lig puanını etkilemez.',
];

const MESSAGE_COLORS: Record<string, string> = {
  ok: 'text-green',
  err: 'text-red',
  warn: 'text-gold',
  '': 'text-muted',
};

// 'review': süre bitti, oyuncu "Kapat"a basıp doğru hamleyi TAHTADA yerleşik görüyor.
type Phase = 'loading' | 'intro' | 'play' | 'found' | 'missed' | 'review' | 'exhausted';

interface HamleAviProps {
  playerName: string;
  /** Girişli kullanıcı kimliği — verilmezse (misafir) yalnızca cihaz deposu. */
  userId?: string | null;
  onExit: () => void;
}

const fmt = (ms: number) => {
  const s = Math.max(0, Math.ceil(ms / 1000));
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
};

export function HamleAvi({ playerName, userId, onExit }: HamleAviProps) {
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
  // Tahtadaki oynanmış kelimeye dokununca anlam (kullanıcı, 3 Kasım 2026: cevabı ele vermez, çünkü
  // tahtada ZATEN duran kelimeler). Taslak taş varken AÇILMAZ — App.tsx ile aynı kural.
  const [meaning, setMeaning] = useState<{
    entries: { word: string; data: WordMeaning | null; loading: boolean }[];
  } | null>(null);
  const [pendingWild, setPendingWild] = useState<{ r: number; c: number; rackIndex: number; editing?: boolean } | null>(null);

  const bankRef = useRef<HamleAviPosition[] | null>(null);
  const posRef = useRef<HamleAviPosition | null>(null);
  const initialRef = useRef<GameState | null>(null);
  const solutionRef = useRef<BestMove | null>(null);
  // Ölçüm: her bulmaca için TEK sonuç olayı (bulundu/süre bitti/çıktı). Bkz. `logHamleAviEvent`.
  const loggedRef = useRef<Set<number>>(new Set());
  const remainingRef = useRef(HAMLE_AVI_SECONDS * 1000);
  const reviewTapRef = useRef<{ r: number; c: number; x: number; y: number } | null>(null);
  const seenRef = useRef<Set<number>>(new Set(loadHamleAvi().seen));
  const streakRef = useRef(streak);
  streakRef.current = streak;
  remainingRef.current = remaining;
  const endsAt = useRef(0);
  // Oyuncu = pozisyonun sahibi, `state.current` DEĞİL: doğru hamle `PLAY` ile oynanınca reducer sırayı
  // rakibe geçirir; `state.current`e bakmak "Tebrikler" penceresinin arkasında rafı rakibin dolgu
  // taşlarına (E E E…), rozeti/çizgiyi rakibin rengine çevirirdi (denetimde bulundu, 3 Kasım 2026).
  const ownerIdx = initialRef.current?.current ?? state.current;
  const me = state.players[ownerIdx];

  // ── Veri: sözlük + banka (lazy chunk) + sunucu eşitlemesi ────────────────
  useEffect(() => {
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
    solutionRef.current = null;
    boardZoom.reset();
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

  /** Bu bulmacanın sonucunu BİR KEZ ölç (aynı bulmaca için tekrar çağrılırsa yok sayılır). */
  const logResult = useCallback((result: 'found' | 'missed' | 'left') => {
    const id = posRef.current?.id;
    if (id === undefined || loggedRef.current.has(id)) return;
    loggedRef.current.add(id);
    const elapsed = result === 'missed' ? HAMLE_AVI_SECONDS : HAMLE_AVI_SECONDS - remainingRef.current / 1000;
    void logHamleAviEvent(id, result, elapsed, streakRef.current.streak);
  }, []);

  /** Bulmaca sonucu: seri/rekor güncellenir, cihaza yazılır, hesapsa sunucuya gider. */
  const finish = useCallback(
    (found: boolean, net: number) => {
      logResult(found ? 'found' : 'missed'); // seri GÜNCELLENMEDEN önce: `streak_before`
      const next = found ? onFound(streakRef.current) : onMissed(streakRef.current);
      // Süre dolarken açık kalan joker penceresi sonuç penceresinin ALTINDA kalıp, "Kapat"tan sonra
      // kilitli tahtaya taş koyabilirdi.
      setPendingWild(null);
      setStreak(next);
      setLastNet(net);
      setPhase(found ? 'found' : 'missed');
      if (!found && initialRef.current) {
        // Doğru hamleyi pencere açıkken arka planda bul (YZ çözücüsü ~0,1-0,5 sn); "Kapat"a basılınca hazır olsun.
        const init = initialRef.current;
        window.setTimeout(() => {
          solutionRef.current ??= findBestNetMove(init);
        }, 50);
      }
      const local = saveHamleAvi({ best: Math.max(loadHamleAvi().best, next.best) });
      if (userId) void reportHamleAvi(local.best, local.seen);
    },
    [userId, logResult],
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

  const openMeaning = (words: string[]) => {
    const unique = [...new Set(words)];
    if (unique.length === 0) return;
    setMeaning({ entries: unique.map((word) => ({ word, data: null, loading: true })) });
    for (const word of unique) {
      void fetchMeaning(word).then((data) => {
        setMeaning((cur) =>
          cur ? { entries: cur.entries.map((en) => (en.word === word ? { ...en, data, loading: false } : en)) } : cur,
        );
      });
    }
  };

  /** Review'da (doğru hamle tahtada): dokunulan karedeki kelime(ler)in anlamı — taslak = DOĞRU HAMLE dahil. */
  const openMeaningAt = (r: number, c: number) => {
    const words = [
      getFullWordAt(state.board, state.placed, r, c, 0, 1),
      getFullWordAt(state.board, state.placed, r, c, 1, 0),
    ].filter((w) => w.length >= 2);
    openMeaning(words);
  };

  const handleCellClick = (r: number, c: number, e: React.MouseEvent) => {
    // Süre bitti, doğru hamle tahtada: oynanmış kelimeye dokununca anlamı açılır (kullanıcı, 3 Kasım 2026:
    // "bilmediği bir kelime ise anlamını görmesi iyi olur"). Taslak kuralı burada GEÇERSİZ — taslak cevabın kendisi.
    if (phase === 'review') {
      if (state.board[r][c] || state.placed[key(r, c)]) openMeaningAt(r, c);
      return;
    }
    if (!canAct) return;
    // Çift dokunuşla zoom: dokunuşun kendi işinden ÖNCE sorulur (App.tsx handleCellClick ile aynı sıra).
    if (!state.board[r][c]) {
      if (boardZoom.registerCellTap(e.clientX, e.clientY)) return;
      if (!state.placed[key(r, c)]) boardZoom.registerPairable(e.clientX, e.clientY);
    } else {
      boardZoom.markUnpairable();
    }
    const hasDraft = Object.keys(state.placed).length > 0;
    // Iskalama kurtarma (`utils/draftRescue.ts`, App.tsx ile aynı kural): hücre ~24 px ve parmağın
    // merkezi nişanın altına düşer → taslak taşı geri almaya çalışan komşu hücreye isabet eder.
    // Oynanmış taşa isabet: taslak varken alan komşudaki taslak taşa devredilir. Boş hücreye
    // isabet: YALNIZCA hiçbir raf taşı seçili değilken (yoksa dizerken yan hücreye koymak zorlaşır).
    const rescue = () => {
      const target = nearbyDraftCell(
        SIZE,
        r,
        c,
        (rr, cc) => !!state.placed[key(rr, cc)],
        { x: e.clientX, y: e.clientY },
        (rr, cc) => document.querySelector(`[data-cell="${rr},${cc}"]`)?.getBoundingClientRect() ?? null,
      );
      if (target) tapDraft(target[0], target[1]);
      return !!target;
    };
    if (state.board[r][c]) {
      if (hasDraft) {
        rescue();
        return;
      }
      const words = [
        getFullWordAt(state.board, {}, r, c, 0, 1),
        getFullWordAt(state.board, {}, r, c, 1, 0),
      ].filter((w) => w.length >= 2);
      openMeaning(words);
      return;
    }
    if (state.placed[key(r, c)]) {
      tapDraft(r, c);
      return;
    }
    if (state.selectedTile === null) {
      if (hasDraft) rescue();
      return;
    }
    placeAt(r, c, state.selectedTile);
  };

  // Sürükleme kaynağı: raftan bir taş YA DA tahtaya bu turda konmuş (taslak) bir taş.
  // Taslak taş: dokunuş = geri al, boş kareye sürükle = taşı, rafa sürükle = geri al
  // (kullanıcı isteği 3 Kasım 2026; `App.tsx` `endDrag`in sadeleştirilmiş eşi).
  type Source =
    | { kind: 'rack'; index: number; tile: TileModel }
    | { kind: 'placed'; r: number; c: number; tile: TileModel };
  const [ghost, setGhost] = useState<{ x: number; y: number; source: Source } | null>(null);
  const [dragOverKey, setDragOverKey] = useState<string | null>(null);
  const dragRef = useRef<{ source: Source; x: number; y: number; moved: boolean } | null>(null);
  // Tahta yakınlaştırması (çift dokunuş) — oyun ekranlarıyla AYNI hook (kullanıcı: "her yerde aynı
  // deneyim"). Sürükleme sürerken pan hiç başlamaz.
  const boardZoom = useBoardZoom(() => dragRef.current !== null);

  // Servis çalışanı güncellemesi bir bulmaca sürerken sayfayı yeniden YÜKLEMESİN (App.tsx oyun için
  // aynısını yapıyor; App'in kendi effect'i burada çalışmaz çünkü yerel oyun state'i 'setup'ta).
  useEffect(() => {
    setActivelyPlaying(phase === 'play');
    return () => setActivelyPlaying(false);
  }, [phase]);

  /** Tahtaya bu turda konmuş (taslak) taşa dokunma: joker → harf penceresi, değilse geri al. */
  const tapDraft = (r: number, c: number) => {
    const tile = state.placed[key(r, c)];
    if (!tile) return;
    if (tile.wild) setPendingWild({ r, c, rackIndex: -1, editing: true });
    else dispatch({ type: 'RECALL_CELL', r, c });
  };

  const dropAt = (x: number, y: number) => {
    const el = document.elementFromPoint(x, y);
    return {
      cell: (el?.closest('[data-cell]') as HTMLElement | null)?.getAttribute('data-cell') ?? null,
      onRack: !!el?.closest('[data-rack]'),
    };
  };
  /** Bu kare, bu kaynak için geçerli bir hedef mi? (boş + kaynağın kendi karesi değil) */
  const hedefUygun = (k: string | null, src: Source): boolean => {
    if (!k) return false;
    const [r, c] = k.split(',').map(Number);
    if (src.kind === 'placed' && src.r === r && src.c === c) return false;
    return !state.board[r][c] && !state.placed[k];
  };

  const beginDrag = (source: Source, e: React.PointerEvent<HTMLDivElement>) => {
    if (!canAct) return;
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      // yakalama olmadan da çalışır
    }
    dragRef.current = { source, x: e.clientX, y: e.clientY, moved: false };
  };
  const moveDrag = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    if (!d) return;
    if (!d.moved) {
      if (Math.hypot(e.clientX - d.x, e.clientY - d.y) < dragThresholdFor(e.pointerType)) return;
      d.moved = true;
    }
    const y = liftedPoint(e.clientY);
    setGhost({ x: e.clientX, y, source: d.source });
    setDragOverKey(dropAt(e.clientX, y).cell);
  };
  const endDrag = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
    // Parmak tahtadayken süre bitmiş olabilir: sonuç/review aşamasında bırakma HİÇBİR iş yapmaz.
    if (!canAct) return;
    if (!d) return;
    const { source } = d;
    const dist = Math.hypot(e.clientX - d.x, e.clientY - d.y);
    const target = dropAt(e.clientX, liftedPoint(e.clientY));
    // Taşıma: konmuş taş hayaletin GÖSTERDİĞİ boş kareye bırakıldıysa (kaldırma payı
    // yüzünden kısa mesafe 24 px kuralına takılmasın — App.tsx'teki 23 Ekim kuralı).
    // ⚠ `d.moved` ŞART: hiç kıpırdamayan bir dokunuşta bırakma noktası yine `DRAG_LIFT`
    // kadar YUKARI hesaplanır ve üstteki kare boşsa dokunuş "taşıma" sanılıp taş
    // bir üst kareye kayıyordu (kullanıcı bildirdi, 3 Kasım 2026).
    const tasima = d.moved && source.kind === 'placed' && hedefUygun(target.cell, source);
    if (!tasima && dist < TAP_SLOP_ON_RELEASE) {
      // Dokunuş: raf taşı = seç, konmuş taş = geri al (joker → harf penceresi).
      if (source.kind === 'rack') {
        boardZoom.markUnpairable(); // raf dokunuşu tahta çifti oluşturamaz
        dispatch({ type: 'SELECT_TILE', index: source.index });
      } else {
        // Çiftin İKİNCİSİYSE geri alma yutulur ve zoom değişir (App.tsx `dokunusOlarakIsle`).
        if (!boardZoom.registerCellTap(e.clientX, e.clientY)) tapDraft(source.r, source.c);
      }
      // Ardından gelen compat `click` sökülen/konan karenin üstüne düşüp ikinci bir iş yapmasın.
      swallowNextClick();
      return;
    }
    swallowNextClick();
    boardZoom.markUnpairable(); // sürükleme sonrası dokunuş zoom çifti oluşturmasın
    if (target.cell && hedefUygun(target.cell, source)) {
      const [r, c] = target.cell.split(',').map(Number);
      if (source.kind === 'rack') placeAt(r, c, source.index);
      else dispatch({ type: 'MOVE_PLACED_TILE', from: { r: source.r, c: source.c }, to: { r, c } });
    } else if (target.onRack && source.kind === 'placed') {
      dispatch({ type: 'RECALL_CELL', r: source.r, c: source.c });
    }
  };
  const cancelDrag = () => {
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
  };

  // Bir taş sürüklenirken dokunmatik tarayıcının sayfayı kaydırmasını/esnetmesini KESİN engelle.
  // `touch-action: none` hızlı harekette ya da pointer capture güvenilmez olduğunda yetmiyor;
  // `App.tsx` (1204. satır) aynı yedeği taşıyor. Bu olmadan iOS'ta sürüklerken tahta titriyor,
  // büyüyüp küçülüyordu (kullanıcı bildirdi, 3 Kasım 2026).
  useEffect(() => {
    const preventScrollWhileDragging = (e: TouchEvent) => {
      if (dragRef.current) e.preventDefault();
    };
    document.addEventListener('touchmove', preventScrollWhileDragging, { passive: false });
    return () => document.removeEventListener('touchmove', preventScrollWhileDragging);
  }, []);
  // Ana ekran uygulamasında sürükleme sırasında arka plana düşülürse WebKit `pointerup` göndermeyebilir:
  // hayalet taş ekranda asılı kalır. Görünürlük/odak değişince sürükleme elle temizlenir (App.tsx ile aynı).
  useEffect(() => {
    const clearStuckDrag = () => {
      if (dragRef.current) {
        dragRef.current = null;
        setGhost(null);
        setDragOverKey(null);
      }
    };
    document.addEventListener('visibilitychange', clearStuckDrag);
    window.addEventListener('blur', clearStuckDrag);
    return () => {
      document.removeEventListener('visibilitychange', clearStuckDrag);
      window.removeEventListener('blur', clearStuckDrag);
    };
  }, []);

  // "N puan aldın — daha iyisi var" notu geçici: oyuncu yeni bir taş koyunca/aldığında kalkar. Kalmazsa
  // not canlı mesajı ("Kelime mevcut harflere bağlanmalı." vb.) bir sonraki Oyna'ya kadar ÖRTERDİ.
  const placedCount = Object.keys(state.placed).length;
  useEffect(() => {
    if (placedCount > 0) setNote((n) => (n && n.type === 'warn' ? null : n));
  }, [placedCount]);

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
    if (phase === 'play') logResult('left'); // bulmaca sürerken çıkıldı
    onExit();
  };
  const confirmLeave = () => {
    // Çıkış seriyi sıfırlar; rekor zaten cihazda/sunucuda.
    if (phase === 'play') logResult('left');
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

  /** Süre bitti → "Kapat": doğru hamle tahtaya taslak taşlar olarak yerleştirilir (kullanıcı, 3 Kasım 2026). */
  const showSolution = () => {
    const init = initialRef.current;
    if (!init) return;
    solutionRef.current ??= findBestNetMove(init);
    const sol = solutionRef.current;
    dispatch({ type: 'RESUME_SAVED', state: init });
    if (sol) {
      // `PLACE_TILE` rafın O ANKİ sırasına bakar: yerleştirilen taş rafından çıkınca indeksler kayar.
      const rack = [...init.players[init.current].rack];
      for (const p of sol.move.placements) {
        const idx = rack.findIndex((t) => (p.tile.wild ? t.letter === '?' : t.letter === p.tile.letter));
        if (idx < 0) continue;
        rack.splice(idx, 1);
        dispatch(
          p.tile.wild
            ? { type: 'PLACE_TILE', r: p.r, c: p.c, rackIndex: idx, wildLetter: p.tile.wildLetter }
            : { type: 'PLACE_TILE', r: p.r, c: p.c, rackIndex: idx },
        );
      }
      // Tahtadaki "+N" etiketi HAM puanı gösterir; mesaj NET (vergi dahil) toplamı yazar —
      // anahtar net puandır (kullanıcı, 3 Kasım 2026: "vergi dahil toplam N puan").
      setNote({ text: `Doğru hamle: ${sol.move.word} — vergi dahil toplam ${sol.net} puan`, type: 'ok' });
    }
    setPhase('review');
  };

  const leaveRef = useModalA11y(leaveOpen, () => setLeaveOpen(false));
  const resultRef = useModalA11y(
    phase === 'found' || phase === 'missed' || phase === 'exhausted',
    phase === 'missed' ? showSolution : handleExit,
  );

  // Canlı mesaj `App.tsx` `liveMessage` ile AYNI kural: taslak GEÇERSİZSE nedeni (kırmızı), GEÇERLİYSE
  // "Oyna tuşuyla kelimeyi onayla." (yeşil). Reducer'ın PLACE_TILE mesajı ("…onayla") geçerliliğe bakmaz —
  // yalnızca onu göstermek, geçersiz bir kelimede yanıltıyordu (kullanıcı bildirdi, 3 Kasım 2026).
  const liveMessage =
    moveStatus && !moveStatus.valid && moveStatus.reason
      ? moveStatus.reason
      : moveStatus?.valid
        ? 'Oyna tuşuyla kelimeyi onayla.'
        : state.message;
  const liveMessageType: 'ok' | 'err' | 'warn' | '' =
    moveStatus && !moveStatus.valid && moveStatus.reason ? 'err' : moveStatus?.valid ? 'ok' : state.messageType;
  const mesaj = note?.text ?? (phase === 'play' ? liveMessage : '');
  const mesajTipi = note?.type ?? (phase === 'play' ? liveMessageType : '');
  const warn = remaining <= HAMLE_AVI_WARN_SECONDS * 1000;
  const color = PLAYER_COLORS[me?.colorIndex ?? 0];
  const pos = posRef.current;

  return (
    <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden" data-hamle-avi="">
      {/* Üst şerit: solda Seri/Rekor, ortada büyük geri sayım, sağda avatar. */}
      <div className="w-full max-w-[680px] px-3 pt-1 pb-1.5 grid grid-cols-[1fr_auto_1fr] items-center">
        {/* Logo oyun ekranındaki gibi çıkış düğmesi (GameHeader ile aynı boy/davranış). */}
        <button
          onClick={handleExit}
          aria-label="Hamle Avı'ndan çık"
          className="justify-self-start flex items-center leading-none active:opacity-70 transition-opacity min-h-[36px] tap-expand"
        >
          <LogoMark height="clamp(28px, calc(-5.33px + 8.89vw), 36px)" />
        </button>
        {/* Etiket ortada (kullanıcı, 3 Kasım 2026: logoya yapışmasın). */}
        {/* Başlık büyük + kalın (kullanıcı, 3 Kasım 2026); header yüksekliği DEĞİŞMEZ (logo satırı belirliyor).
            Punto ekrana göre ölçeklenir: 320 px'te 15 px logoya YAPIŞIYORDU (ölçüldü), 12 px'te 12 px boşluk kalır. */}
        <span
          className="font-mono font-bold tracking-[1px] text-text text-center whitespace-nowrap leading-none"
          style={{ fontSize: 'clamp(11px, calc(10vw - 21px), 13px)' }}
        >
          🎯 HAMLE AVI
        </span>
        {/* Avatar/hesap menüsü oyun başlığındaki yerinde (GameHeader ile aynı bileşen). */}
        <div className="justify-self-end">
          <UserMenu />
        </div>
      </div>
      <div className="w-full max-w-[680px] px-3">
        <div
          className="bg-panel border border-border rounded-md flex items-center justify-between px-3 py-1"
          // Kartın solunda oyuncu renginde çizgi (kullanıcı, 3 Kasım 2026).
          style={{ borderLeft: `5px solid ${color.base}` }}
        >
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
              style={{ fontSize: 34 }}
              aria-live="off"
            >
              {fmt(remaining)}
            </span>
          </div>
          <div className="flex flex-col items-end gap-1">
            {/* Oyuncunun rengi baştan belli olsun: bankada oyuncu bazen sol-üst (camgöbeği = "Mavi"),
                bazen sağ-alt (kırmızı = "Kırmızı") köşede (kullanıcı, 3 Kasım 2026; metin yalnızca "MAVİ/KIRMIZI"). */}
            <span
              data-hamle-avi-renk=""
              className="px-2 py-0.5 rounded-full text-[10px] font-bold font-mono flex items-center gap-1.5 whitespace-nowrap"
              style={{ background: color.tint, color: color.text }}
            >
              <span style={{ width: 8, height: 8, borderRadius: '50%', background: color.base, display: 'inline-block' }} />
              {ownerIdx === 0 ? 'MAVİ' : 'KIRMIZI'}
            </span>
            <div className="flex items-center gap-0.5">
              {phase === 'review' && (
                <button
                  onClick={() => loadNext(true)}
                  data-hamle-avi-sonraki=""
                  className="btn-raised btn-raised-orange bg-orange text-white rounded-md px-2 min-h-[28px] tap-expand font-mono text-[10px] font-bold tracking-[0.5px] active:scale-[0.97] transition-transform"
                >
                  SONRAKİ
                </button>
              )}
              <button
                onClick={handleExit}
                data-hamle-avi-cik=""
                className="btn-raised-neutral bg-void border border-border text-text rounded-md px-2 min-h-[28px] tap-expand font-mono text-[10px] font-bold tracking-[0.5px] active:scale-[0.97] transition-transform"
              >
                ÇIK ✕
              </button>
            </div>
          </div>
        </div>
      </div>

      <main className="w-full flex flex-col items-center mt-1">
        <div className="relative w-full flex flex-col items-center">
          <Board
            state={state}
            onCellClick={(r, c, e) => handleCellClick(r, c, e)}
            moveStatus={moveStatus}
            onOpenHistory={() => {}}
            hideFooter
            tileLifted={ghost !== null}
            dragOverKey={dragOverKey}
            dragOverValid={ghost ? hedefUygun(dragOverKey, ghost.source) : false}
            dragHiddenKey={ghost && ghost.source.kind === 'placed' ? key(ghost.source.r, ghost.source.c) : null}
            onTilePointerDown={(r, c, e) => {
              const tile = state.placed[key(r, c)];
              if (phase === 'review') {
                reviewTapRef.current = { r, c, x: e.clientX, y: e.clientY };
                return;
              }
              if (tile) beginDrag({ kind: 'placed', r, c, tile }, e);
            }}
            onTilePointerMove={moveDrag}
            onTilePointerUp={(e) => {
              // Review: dokunuş = o kelimenin anlamı. Pencere pointerup'ta açılır ve ardından gelen compat
              // click yutulur (yoksa yeni açılan modalın dışına düşüp onu hemen kapatır — ghostClick.ts).
              const t = reviewTapRef.current;
              reviewTapRef.current = null;
              if (phase === 'review' && t && Math.hypot(e.clientX - t.x, e.clientY - t.y) < TAP_SLOP_ON_RELEASE) {
                swallowNextClick();
                openMeaningAt(t.r, t.c);
                return;
              }
              endDrag(e);
            }}
            onTilePointerCancel={cancelDrag}
            zoom={boardZoom.zoom}
            viewportRef={boardZoom.viewportRef}
            onBoardPointerDown={boardZoom.onPointerDown}
            onBoardPointerMove={boardZoom.onPointerMove}
            onBoardPointerUp={boardZoom.onPointerUp}
            onBoardPointerCancel={boardZoom.onPointerCancel}
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
                dragHiddenIndex={ghost && ghost.source.kind === 'rack' ? ghost.source.index : null}
                onTilePointerDown={(i, e) => beginDrag({ kind: 'rack', index: i, tile: me.rack[i] }, e)}
                onTilePointerMove={moveDrag}
                onTilePointerUp={endDrag}
                onTilePointerCancel={cancelDrag}
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
          {/* Raf altı düğmeler: oyun ekranındaki beş düğmenin HEPSİ durur, yalnızca bu
              modda anlamlı olanlar aktif (kullanıcı, 3 Kasım 2026). Pas/Değiştir/Torba
              pasif (tek hamlelik bulmaca; torba yok); Geri Al + Karıştır aktif. */}
          <div className="flex gap-1.5" data-hamle-avi-butonlar="">
            {[
              { label: 'Pas Geç', on: false, act: () => {} },
              { label: 'Değiştir', on: false, act: () => {} },
              { label: 'Karıştır', on: canAct, act: () => dispatch({ type: 'SHUFFLE_RACK' }) },
              {
                label: 'Geri Al',
                on: canAct && Object.keys(state.placed).length > 0,
                act: () => dispatch({ type: 'RECALL_ALL' }),
              },
              { label: 'Torba', on: false, act: () => {} },
            ].map((b) => (
              <button
                key={b.label}
                disabled={!b.on}
                onClick={b.act}
                className="btn-raised-neutral flex-1 py-2.5 px-1.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1.2px] bg-panel text-text border border-border active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
              >
                {b.label}
              </button>
            ))}
          </div>
        </div>
      </main>

      {ghost && (
        <div className="pointer-events-none fixed z-[300]" style={{ left: ghost.x, top: ghost.y, ...GHOST_TILE_STYLE }}>
          <Tile tile={ghost.source.tile} variant="rack" />
        </div>
      )}

      {phase === 'intro' && (
        // Standart modal kabuğu (kullanıcı, 3 Kasım 2026: genişlik/başlık diğer pencerelerle aynı).
        // Kabuk saydam bindirme: tahta arkada görünür, süre "Başla"ya kadar durur.
        // ✕ / Escape / dışarı tıklama = Vazgeç; o bulmaca görülmüş SAYILMAZ (yakılmasın).
        <Modal title={<span className="inline-flex items-center gap-2"><span aria-hidden>🎯</span>Hamle Avı</span>} onClose={leaveIntro}>
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

      {meaning && <MeaningModal entries={meaning.entries} onClose={() => setMeaning(null)} />}

      {pendingWild && (
        <WildcardModal
          title={pendingWild.editing ? 'Jokeri Hangi Harfe Çevir?' : undefined}
          onSelect={(letter) => {
            if (pendingWild.editing) {
              dispatch({ type: 'SET_WILD_LETTER', r: pendingWild.r, c: pendingWild.c, wildLetter: letter });
            } else {
              dispatch({ type: 'PLACE_TILE', r: pendingWild.r, c: pendingWild.c, rackIndex: pendingWild.rackIndex, wildLetter: letter });
            }
            setPendingWild(null);
          }}
          onClose={() => setPendingWild(null)}
          onRecall={
            pendingWild.editing
              ? () => {
                  dispatch({ type: 'RECALL_CELL', r: pendingWild.r, c: pendingWild.c });
                  setPendingWild(null);
                }
              : undefined
          }
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
                onClick={phase === 'missed' ? showSolution : onExit}
                data-hamle-avi-kapat={phase === 'missed' ? '' : undefined}
                className="btn-raised-neutral flex-1 min-h-[48px] rounded-md bg-void border border-border text-text text-sm font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                {phase === 'exhausted' ? 'Tamam' : phase === 'missed' ? 'Kapat' : 'Çık'}
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
