// Kelimeki — eğitim balonu SIRASININ React kabuğu (iki oyun ekranı için).
//
// Karar saf fonksiyonda (`pickOnboardingHint`, `utils/onboarding.ts`); bu hook
// yalnızca "ekran açıldı / yeni hamle geldi" olaylarını sayar, sayacı artırır
// ve balonu 4 sn ekranda tutar. App.tsx ile OnlineGameScreen.tsx'in aynı
// deseni iki kez yazıp sessizce ayrışması bu projenin kayıtlı hata sınıfı
// (bkz. useBoardZoom) — tek hook o riski kapatıyor. Port ikizi:
// `ui/game/onboarding_hints.dart` (`OnboardingHintScheduler`).
import { useEffect, useRef, useState } from 'react';
import {
  bumpOnboardingHintShown,
  ONBOARDING_HINT_MS,
  onboardingHintShownCounts,
  pickOnboardingHint,
  type OnboardingHintId,
} from '../utils/onboarding';

export type ActiveOnboardingHint = {
  id: Exclude<OnboardingHintId, 'zoom'>;
  /** Yalnız `anlam`: balonun çapalandığı kare. */
  r?: number;
  c?: number;
};

export function useOnboardingHints({
  active,
  moves,
  playerCount,
  lastWordCell,
  available,
  hasDraft,
  onZoom,
}: {
  /** Oyun ekranı görünür ve oyun sürüyor mu. */
  active: boolean;
  /** Oynanan hamle sayısı (vergi satırı HARİÇ) — artınca karar verilir. */
  moves: number;
  playerCount: number;
  /** Son hamle tahtaya kelime oturttuysa onun ilk karesi, yoksa `null`. */
  lastWordCell: [number, number] | null;
  available: Readonly<Record<OnboardingHintId, boolean>>;
  /** Oyuncu taş koymaya başladı — balon erken kapanır. */
  hasDraft: boolean;
  /** Sıra zoom'a geldi: balonu tahta çizer (`useBoardZoom.showHint`). */
  onZoom: () => void;
}): ActiveOnboardingHint | null {
  const [hint, setHint] = useState<ActiveOnboardingHint | null>(null);
  // Ref'ler: karar bir YAN ETKİ (sayaç artıyor) ve StrictMode'un çift
  // çalıştırması ikinci turda "yeni hamle yok" görmeli.
  const armed = useRef(false);
  const base = useRef(0);
  const seen = useRef(0);
  const lastShownAt = useRef<number | null>(null);
  // Girdilerin GÜNCEL hâli — effect yalnızca `moves`/`active`e bağlı.
  const latest = useRef({ playerCount, lastWordCell, available, onZoom });
  latest.current = { playerCount, lastWordCell, available, onZoom };

  useEffect(() => {
    if (!active) {
      armed.current = false;
      setHint(null);
      return;
    }
    // Oyuna YENİ girildi: o anki geçmiş "az önce oynanmış" sayılmaz —
    // kayıttan devamda DOLU bir geçmiş balon uydururdu.
    if (!armed.current) {
      armed.current = true;
      base.current = moves;
      seen.current = moves;
      lastShownAt.current = null;
      return;
    }
    // Geçmiş KISALDI: aynı ekranda yeni oyun başladı — yeniden kur.
    if (moves < seen.current) {
      base.current = moves;
      seen.current = moves;
      lastShownAt.current = null;
      return;
    }
    if (moves === seen.current) return;
    seen.current = moves;
    const { playerCount: n, lastWordCell: kelime, available: var_, onZoom: zoom } = latest.current;
    const movesSinceOpen = moves - base.current;
    const secilen = pickOnboardingHint(
      {
        movesSinceOpen,
        playerCount: n,
        lastShownAt: lastShownAt.current,
        wordPlaced: kelime !== null,
        available: var_,
      },
      onboardingHintShownCounts(),
    );
    if (!secilen) return;
    bumpOnboardingHintShown(secilen);
    lastShownAt.current = movesSinceOpen;
    if (secilen === 'zoom') {
      zoom();
      return;
    }
    setHint(
      secilen === 'anlam' && kelime
        ? { id: secilen, r: kelime[0], c: kelime[1] }
        : { id: secilen },
    );
  }, [moves, active]);

  // Balon kendi kendine kapanır; oyuncu taş koymaya başladıysa daha erken.
  useEffect(() => {
    if (!hint) return;
    const t = setTimeout(() => setHint(null), ONBOARDING_HINT_MS);
    return () => clearTimeout(t);
  }, [hint]);
  useEffect(() => {
    if (hasDraft) setHint(null);
  }, [hasDraft]);

  return hint;
}
