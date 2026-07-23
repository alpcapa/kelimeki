// Kelimeki — modal/dialog'lar için ortak erişilebilirlik davranışı:
// açılışta içeri odaklanma, Tab ile döngüsel odak hapsi (focus trap),
// kapanışta tetikleyici öğeye geri dönüş ve (opsiyonel) Escape ile kapatma.
import { useEffect, useRef, type RefObject } from 'react';

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])';

// Modaller iç içe açılabiliyor (ör. AuthModal üstünde TermsModal, ScoreCard
// üstünde GameHistoryModal) — bu durumda yalnızca en son açılan (en üstteki)
// dialog Escape/Tab'ı yakalamalı, yoksa aynı tuşa iki dialog birden tepki
// verip Escape'te üsttekiyle birlikte alttaki de kapanır. Modül seviyesinde
// tutulan bu yığın, aktif dialogları mount sırasına göre izler.
let stack: symbol[] = [];

export function useModalA11y(
  active: boolean,
  onClose?: () => void,
  closeOnEscape = true,
): RefObject<HTMLDivElement> {
  const containerRef = useRef<HTMLDivElement>(null);
  const idRef = useRef<symbol>();
  if (!idRef.current) idRef.current = Symbol('modal');

  // onClose çoğu çağrı yerinde satır-içi bir fonksiyon (ör. `() =>
  // setX(false)`) olduğundan üst bileşen her render olduğunda referansı
  // değişir. Bunu asıl mount/unmount efektinin bağımlılığına koyarsak,
  // ebeveyn her render olduğunda yığından çıkip tekrar girer — üstte başka
  // bir dialog açıkken bu, bu dialogu yanlışlıkla yığının tepesine geri
  // taşıyabilir. Bu yüzden en güncel değerler ayrı bir ref'te tutulup
  // yalnızca tuş basıldığı anda okunuyor; yığına giriş/çıkış sadece
  // `active` değiştiğinde olur.
  const latest = useRef({ onClose, closeOnEscape });
  latest.current = { onClose, closeOnEscape };

  useEffect(() => {
    if (!active) return;
    const id = idRef.current!;
    const container = containerRef.current;
    const previouslyFocused = document.activeElement as HTMLElement | null;

    stack.push(id);

    if (container && !container.contains(document.activeElement)) {
      const first = container.querySelector<HTMLElement>(FOCUSABLE_SELECTOR);
      (first ?? container).focus();
    }

    const onKeyDown = (e: KeyboardEvent) => {
      if (stack[stack.length - 1] !== id) return;
      if (e.key === 'Escape') {
        const { onClose, closeOnEscape } = latest.current;
        if (closeOnEscape && onClose) {
          e.preventDefault();
          onClose();
        }
        return;
      }
      if (e.key !== 'Tab' || !container) return;
      const items = Array.from(container.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR));
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    };

    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      stack = stack.filter((s) => s !== id);
      previouslyFocused?.focus?.();
    };
  }, [active]);

  return containerRef;
}
