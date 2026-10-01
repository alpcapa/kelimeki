// Kendi içinde kayan bir liste + HER ZAMAN görünen kaydırma çubuğu.
//
// Neden kendi çubuğumuz: iOS Safari'nin (ve macOS'un "kaydırırken göster"
// ayarının) çubuğu yalnızca parmak hareket ederken çizer ve `::-webkit-
// scrollbar` biçimlendirmesini dokunmatikte uygulamaz. Kullanıcı (27 Eylül
// 2026, canlı oyun formunun arkadaş listesi): *"Arkadaş listesinin kendi
// içinde kaydığı anlaşılmıyor. Listenin en sağına scroll bar koyalım."*
// Tarayıcının çubuğu gizlenir (iki çubuk olmasın), yerine sağ kenarda ince
// bir ray + konumlu bir tutamaç çizilir. İçerik taşmıyorsa ray hiç çizilmez.
//
// Tutamaç yalnızca GÖSTERGE — sürüklenmez (dokunmatikte 6px'lik bir hedef
// zaten tutulamaz); kaydırma parmakla içerikte yapılır.
import { useCallback, useEffect, useRef, useState, type ReactNode, type RefObject } from 'react';

interface ScrollAreaProps {
  children: ReactNode;
  /** Kayan kutunun sınıfları (yükseklik sınırı dahil, ör. `max-h-[280px]`). */
  className?: string;
  /** Dışarıdan erişim gerekiyorsa (ör. IntersectionObserver `root`u). */
  scrollRef?: RefObject<HTMLDivElement>;
}

const MIN_TUTAMAC = 24;

export function ScrollArea({ children, className = '', scrollRef }: ScrollAreaProps) {
  const icRef = useRef<HTMLDivElement>(null);
  const kutuRef = scrollRef ?? icRef;
  const [cubuk, setCubuk] = useState<{ ust: number; boy: number } | null>(null);

  const olc = useCallback(() => {
    const el = kutuRef.current;
    if (!el) return;
    const { scrollHeight, clientHeight, scrollTop } = el;
    if (scrollHeight <= clientHeight + 1) {
      setCubuk(null);
      return;
    }
    const boy = Math.max(MIN_TUTAMAC, (clientHeight / scrollHeight) * clientHeight);
    const ust = (scrollTop / (scrollHeight - clientHeight)) * (clientHeight - boy);
    setCubuk((o) => (o && Math.abs(o.ust - ust) < 0.5 && Math.abs(o.boy - boy) < 0.5 ? o : { ust, boy }));
  }, [kutuRef]);

  // İçerik (filtre, sayfalı yükleme) ya da kutu boyu değişince yeniden ölç.
  useEffect(() => {
    const el = kutuRef.current;
    if (!el) return;
    olc();
    const ro = new ResizeObserver(olc);
    ro.observe(el);
    const mo = new MutationObserver(olc);
    mo.observe(el, { childList: true, subtree: true });
    return () => {
      ro.disconnect();
      mo.disconnect();
    };
  }, [kutuRef, olc]);

  return (
    <div className="relative min-h-0">
      <div
        ref={kutuRef}
        onScroll={olc}
        className={`overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden ${cubuk ? 'pr-3' : ''} ${className}`}
      >
        {children}
      </div>
      {cubuk && (
        <div aria-hidden className="pointer-events-none absolute top-0 bottom-0 right-0.5 w-1.5 rounded-full bg-[#DDE4EE]">
          <div
            className="absolute left-0 right-0 rounded-full bg-[#9AA8BA]"
            style={{ top: cubuk.ust, height: cubuk.boy }}
          />
        </div>
      )}
    </div>
  );
}
