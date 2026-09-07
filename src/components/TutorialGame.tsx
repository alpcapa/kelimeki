// Kelimeki — "Oynayarak öğren" tanıtımı (7 Eylül 2026, kullanıcı isteği)
//
// NEDEN AYRI BİR EKRAN: tanıtım GERÇEK motorla oynanır (`gameReducer`) ama
// App'in oyun durumuna HİÇ dokunmaz — kendi `useReducer`'ı var. Kazanılan
// şey yalıtım: App'in otomatik kayıt / bulut kaydı / telemetri / k-lig
// effect'lerinin hiçbiri bu ekranda çalışmaz, yani tanıtım bir "oyun" olarak
// sayılmaz (huniye girmez, istatistik kirletmez, terk-edilme cezası
// üretmez). Motora ise tek bir action bile eklenmedi — bu depoda motorun
// DÖRT kopyası var (src, Dart portu, Edge `_game/`, SQL aynası) ve tanıtım
// bir UI işidir, motor işi değil (bkz. `src/utils/tutorialScript.ts`).
//
// RAYLAR: oyuncu yalnızca o sahnenin işaretli karelerine taş koyabilir;
// işaretli kareye dokunmak DOĞRU harfi raftan otomatik getirir (tek dokunuş
// ≈ 1 sn — 60 saniyelik bütçe ancak böyle tutuyor). Konan taşa tekrar
// dokunmak geri alır. Hedef dışı kareler sessizce reddedilir: tanıtımda
// "yanlış yaptım" duygusu olmamalı.
import { useEffect, useMemo, useReducer, useRef, useState } from 'react';
import { PLAYER_COLORS } from '../game/constants';
import { gameReducer } from '../game/gameReducer';
import { getFormedWords, key } from '../utils/board';
import { calcScore, validatePlacement } from '../utils/validator';
import { isFirstMove } from '../game/gameReducer';
import { isWordSetReady, preloadWordSet } from '../data/wordSetLoader';
import {
  TUTORIAL_FINISH_TEXT,
  TUTORIAL_FINISH_TITLE,
  TUTORIAL_STEPS,
  createTutorialState,
} from '../utils/tutorialScript';
import { useModalA11y } from '../hooks/useModalA11y';
import { Board } from './Board';
import { GameHeader } from './GameHeader';
import { Rack } from './Rack';

const MESSAGE_COLORS: Record<string, string> = {
  ok: 'text-green',
  err: 'text-red',
  warn: 'text-gold',
  '': 'text-muted',
};

/** Rakibin taşları arasındaki bekleme (ms) — insan gibi "diziliyor" hissi. */
const RAKIP_TAS_ARASI = 260;
/** Oyuncunun hamlesi oynandıktan sonra sonucu okuma payı (ms). */
const SONUC_OKUMA = 1400;
/** Rakibin cevabı oynandıktan sonra notu okuma payı (ms). */
const RAKIP_OKUMA = 1800;

interface TutorialGameProps {
  /** Skor kutusunda ve rafta görünen ad (hesap adı ya da "Sen"). */
  playerName: string;
  /** Tanıtım tamamlandı — çağıran gerçek oyunu başlatır. */
  onFinish: () => void;
  /** "Atla" — çağıran gerçek oyunu başlatır, ipuçları devrede kalır. */
  onSkip: () => void;
}

export function TutorialGame({ playerName, onFinish, onSkip }: TutorialGameProps) {
  const [state, dispatch] = useReducer(gameReducer, playerName, createTutorialState);
  const [stepIndex, setStepIndex] = useState(0);
  // 'oyna' = sıra oyuncuda, raylar açık · 'bekle' = hamle/rakip animasyonu
  // sürüyor, tahta kilitli · 'bitti' = kapanış kartı.
  const [mode, setMode] = useState<'oyna' | 'bekle' | 'bitti'>('oyna');
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [note, setNote] = useState<string | null>(null);
  const [wordsReady, setWordsReady] = useState(isWordSetReady());

  const step = TUTORIAL_STEPS[stepIndex];

  // Zamanlayıcılarla sürülen rakip animasyonu, ekran kapanırken durmalı.
  const timers = useRef<number[]>([]);
  const alive = useRef(true);
  // Async dizide `state` bayatlar (closure) — rakibin raf indeksleri her taşta
  // yeniden okunmak zorunda. Her render'da tazelenen bir ref bunu çözüyor;
  // aradaki `await` (≥260 ms) React'in yeniden render etmesine fazlasıyla yeter.
  const stateRef = useRef(state);
  stateRef.current = state;

  useEffect(() => {
    // ⚠ Bayrak effect'in İÇİNDE yeniden açılıyor, `useRef(true)` YETMEZ:
    // StrictMode dev'de bağla → çöz → yeniden bağla yapıyor, yani ilk
    // çözümde `false`a düşen bayrak bir daha hiç açılmıyordu ve rakibin
    // sırası ilk `await`ten sonra sessizce duruyordu (7 Eylül 2026, duman
    // testi yakaladı: skor 12 yazıyor, sahne 1'de kilitli kalıyor).
    alive.current = true;
    return () => {
      alive.current = false;
      timers.current.forEach((id) => window.clearTimeout(id));
      timers.current = [];
    };
  }, []);

  // Motor kelime listesini tembel yüklenen chunk'tan okuyor: hazır değilken
  // `PLAY` fırlatır (bkz. `wordSetLoader`). Setup'tan gelen normal akışta
  // liste çoktan yüklü olur, yine de tanıtım kendi kapısını kuruyor —
  // "Nasıl oynanır?"tan doğrudan açılabildiği için.
  useEffect(() => {
    if (wordsReady) return;
    let iptal = false;
    preloadWordSet()
      .then(() => {
        if (!iptal) setWordsReady(true);
      })
      .catch(() => {
        // Sessiz: buton "Yükleniyor…" olarak kalır, "Atla" hep çalışır.
      });
    return () => {
      iptal = true;
    };
  }, [wordsReady]);

  const bekle = (ms: number) =>
    new Promise<void>((resolve) => {
      const id = window.setTimeout(resolve, ms);
      timers.current.push(id);
    });

  /** Verilen harfi AKTİF oyuncunun rafından bulup tahtaya koyar. */
  const koy = (r: number, c: number, letter: string): boolean => {
    const s = stateRef.current;
    const idx = s.players[s.current].rack.findIndex((t) => t.letter === letter);
    if (idx < 0) return false;
    dispatch({ type: 'PLACE_TILE', r, c, rackIndex: idx });
    return true;
  };

  // ── Oyuncunun sırası ─────────────────────────────────────────────────────
  const kalanHedefler = useMemo(() => {
    if (mode !== 'oyna') return [];
    return step.move.cells.filter((cell) => !state.placed[key(cell.r, cell.c)]);
  }, [mode, step, state.placed]);

  const targets = useMemo(
    () => new Set(kalanHedefler.map((cell) => key(cell.r, cell.c))),
    [kalanHedefler],
  );
  const hazir = mode === 'oyna' && kalanHedefler.length === 0;

  const handleCellClick = (r: number, c: number) => {
    if (mode !== 'oyna') return;
    const k = key(r, c);
    if (state.placed[k]) {
      dispatch({ type: 'RECALL_CELL', r, c });
      return;
    }
    const hedef = step.move.cells.find((cell) => cell.r === r && cell.c === c);
    // Hedef dışı kare: sessizce yoksayılır (ray). Hata mesajı YOK.
    if (!hedef) return;
    koy(r, c, hedef.letter);
  };

  /** Hamleyi oynatır, rakibin cevabını dizer, sonraki sahneye geçer. */
  const oyna = async () => {
    setConfirmOpen(false);
    setMode('bekle');
    dispatch({ type: 'PLAY' });
    setNote(step.done);
    await bekle(SONUC_OKUMA);
    if (!alive.current) return;

    setNote(null);
    for (const cell of step.reply.cells) {
      if (!koy(cell.r, cell.c, cell.letter)) {
        // Senaryo bozulduysa (olmaması gereken durum — doğrulayıcı bunu
        // koşumda yakalıyor) oyuncuyu kilitli bir tahtada bırakmaktansa
        // tanıtımı bitiriyoruz.
        setMode('bitti');
        return;
      }
      await bekle(RAKIP_TAS_ARASI);
      if (!alive.current) return;
    }
    dispatch({ type: 'PLAY' });
    setNote(step.reply.note);
    await bekle(RAKIP_OKUMA);
    if (!alive.current) return;

    setNote(null);
    if (stepIndex + 1 < TUTORIAL_STEPS.length) {
      setStepIndex(stepIndex + 1);
      setMode('oyna');
    } else {
      setMode('bitti');
    }
  };

  const handlePlay = () => {
    if (!hazir || !wordsReady) return;
    // Vergi sahnesinde gerçek oyundaki onay penceresi çıkar — tanıtımın işi
    // oyuncuyu o pencereye de alıştırmak.
    if (step.move.tax > 0) {
      setConfirmOpen(true);
      return;
    }
    void oyna();
  };

  // ── Board'un canlı hamle çerçevesi (App.tsx ile aynı hesap) ──────────────
  const moveStatus = useMemo(() => {
    const placedKeys = Object.keys(state.placed);
    if (placedKeys.length === 0 || !wordsReady) return null;
    const current = state.players[state.current];
    if (!current) return null;
    const result = validatePlacement(
      state.board,
      state.placed,
      state.current,
      current.corners,
      isFirstMove(state),
    );
    const formed = getFormedWords(state.board, state.placed);
    const cells =
      formed.length > 0
        ? formed.flatMap((f) => f.coords)
        : (placedKeys.map((k) => k.split(',').map(Number)) as [number, number][]);
    return {
      valid: result.valid,
      reason: result.reason,
      cells,
      score: calcScore(state.board, state.placed, state.bonuses),
    };
  }, [state.placed, state.board, state.players, state.current, state.bonuses, wordsReady]);

  const confirmRef = useModalA11y(confirmOpen, () => setConfirmOpen(false));
  const finishRef = useModalA11y(mode === 'bitti', onFinish);

  const mesaj = note ?? (mode === 'oyna' ? step.say : '');
  const mesajRengi = note ? 'ok' : '';
  const me = state.players[0];

  return (
    <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden">
      <GameHeader state={state} onLogoClick={onSkip} />

      {/* Sahne sayacı + her sahnede duran "Atla". Kullanıcı kararı: tanıtım
          zorunlu değil, ama atlayan da ilk gerçek oyununda ipuçlarını görür. */}
      <div className="w-full max-w-[680px] px-3 flex items-center justify-between">
        <span className="font-mono text-[10px] tracking-[1.5px] text-muted">
          TANITIM · {Math.min(stepIndex + 1, TUTORIAL_STEPS.length)}/{TUTORIAL_STEPS.length}
        </span>
        <button
          onClick={onSkip}
          className="font-mono text-[10px] tracking-[1.5px] text-accent min-h-[44px] px-1 active:opacity-70 transition-opacity"
        >
          ATLA →
        </button>
      </div>

      <main className="w-full flex flex-col items-center">
        <Board
          state={state}
          onCellClick={(r, c) => handleCellClick(r, c)}
          moveStatus={moveStatus}
          onOpenHistory={() => {}}
          hideFooter
          targets={mode === 'oyna' ? targets : null}
          coach={mode === 'oyna' ? { r: step.bubble.r, c: step.bubble.c, text: step.say } : null}
        />

        <div className="w-full max-w-[680px] px-3 pb-3 pt-1 flex flex-col gap-1.5">
          <div
            className={`text-[11px] font-mono font-bold text-center min-h-[30px] py-0.5 flex items-center justify-center ${MESSAGE_COLORS[mesajRengi]}`}
          >
            {mesaj}
          </div>

          <div className="flex gap-1.5 items-stretch">
            <div className="flex-1 min-w-0">
              {/* Raf HER ZAMAN oyuncunun (rakip oynarken bile) — App'teki
                  `rackPlayer` ile aynı kural: sıra karşıdayken kendi
                  taşlarını görmeye devam edersin. */}
              <Rack
                tiles={me.rack}
                selectedTile={null}
                onSelect={() => {}}
                title={me.name}
                color={PLAYER_COLORS[me.colorIndex]}
              />
            </div>
            <button
              disabled={!hazir || !wordsReady}
              onClick={handlePlay}
              className="btn-raised shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] disabled:opacity-35 disabled:cursor-not-allowed"
            >
              {!wordsReady ? 'Yükleniyor…' : 'Oyna'}
            </button>
          </div>
        </div>
      </main>

      {/* Vergi sahnesi — gerçek oyundaki onay penceresinin aynısı, üstüne
          tanıtımın tek satırlık açıklaması. */}
      {confirmOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
          <div
            ref={confirmRef}
            role="dialog"
            aria-modal="true"
            aria-label="Sınır ihlali onayı"
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-4 outline-none"
          >
            <p className="text-base font-bold text-text font-sans">Sınır İhlali!</p>
            <p className="text-sm text-text font-sans leading-relaxed">
              Bu hamleden kazanacağın{' '}
              <strong className="text-green">{step.move.points + step.move.tax}</strong> puanın{' '}
              <strong className="text-red">{step.move.tax}</strong> puanı{' '}
              <strong>{state.players[1].name}</strong> kullanıcısına vergi olarak gidecek.
            </p>
            <p className="text-xs text-muted font-sans leading-relaxed">
              Rakibin bölgesine girmen gerekmiyor — sınırına değmek yetiyor.
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={() => void oyna()}
                className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Oyna
              </button>
              <button
                onClick={() => setConfirmOpen(false)}
                className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Vazgeç
              </button>
            </div>
          </div>
        </div>
      )}

      {mode === 'bitti' && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
          <div
            ref={finishRef}
            role="dialog"
            aria-modal="true"
            aria-label="Tanıtım tamamlandı"
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-3 outline-none"
          >
            <p className="text-lg font-bold text-text font-sans">{TUTORIAL_FINISH_TITLE}</p>
            <p className="text-sm text-text font-sans leading-relaxed">{TUTORIAL_FINISH_TEXT}</p>
            <button
              onClick={onFinish}
              className="btn-raised mt-1 py-3 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              Gerçek oyuna başla
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
