// Kelimeki — kaydırılan listede BİR satırın görünür alanda olup olmadığı.
//
// k-lig listelerinin (Puan Ligi · Beyin Ligi) altındaki "senin sıran"
// satırı için: eskiden satır yalnızca "yüklenen satırlar arasında mı"
// (`meInList`) diye bakılıyordu. İlk sayfa 10 satır, pencere iPad'de 8
// satır gösteriyor → 9.-10. sıradaki oyuncunun satırı YÜKLÜ ama görünmez,
// sabit satır da gizli kalıyordu (16 Ekim 2026, kullanıcı bildirdi).
// Kural artık "ekranda mı": satır görünür alana girince sabit satır
// gizlenir, çıkınca geri gelir. Port ikizi:
// `mobile/app/lib/src/ui/score/own_row_pin.dart`. Karar saf fonksiyonda:
// `utils/ownRowPin.ts`.
import { useCallback, useEffect, useState, type RefObject } from 'react';
import { ROW_IN_VIEW_RATIO, type RowInView } from '../utils/ownRowPin';

/** Dönen `ref`i kendi satırının `<li>`sine ver; `scrollRef` listenin
 *  kaydırılan kabı. Satır listede yoksa (`ref` hiç bağlanmaz) `null`. */
export function useRowInView(scrollRef: RefObject<HTMLElement | null>) {
  const [el, setEl] = useState<HTMLElement | null>(null);
  const [inView, setInView] = useState<RowInView>(null);

  useEffect(() => {
    const root = scrollRef.current;
    if (!el || !root) {
      setInView(null);
      return;
    }
    const observer = new IntersectionObserver(
      (entries) => {
        const last = entries[entries.length - 1];
        if (last) setInView(last.intersectionRatio >= ROW_IN_VIEW_RATIO);
      },
      { root, threshold: [0, ROW_IN_VIEW_RATIO, 1] },
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [el, scrollRef]);

  const ref = useCallback((node: HTMLElement | null) => setEl(node), []);
  return { ref, inView };
}
