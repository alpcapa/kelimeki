// Kelimeki — arayüz öğesine çapalı eğitim balonu (1 Ekim 2026).
//
// Menü (avatar), "Hamleler", "Torba" ve "Mesajlaşma" balonları bunu kullanır;
// tahtaya çapalı iki balon (anlam · zoom) Board'un kendi `coach`/`zoomHint`
// geometrisinde kalıyor. Görsel dil o ikisiyle AYNI (mavi zemin, beyaz kalın
// metin, `clamp(11px, 3.2vw, 16px)`, 9 px köşe, aynı gölge) — üç balon tek
// ölçüde okunsun (7 Eylül 2026 kararı).
//
// Kullanım: hedefin kendisi `relative` olur, balon onun ÇOCUĞU olarak
// mutlak konumlanır (sarmalayıcı yok — `flex-1` düğmeler bozulmasın diye).
// `pointer-events-none`: balona dokunmak hedefi tetiklemez, alttaki öğeye
// geçer. Port ikizi `ui/game/hint_bubble.dart`.

export type HintBubbleYon = 'ust' | 'alt';
export type HintBubbleHiza = 'bas' | 'orta' | 'son';

export function HintBubble({
  text,
  yon,
  hiza,
}: {
  text: string;
  /** Balon hedefin üstünde mi (kuyruk aşağı) altında mı (kuyruk yukarı). */
  yon: HintBubbleYon;
  /** Balonun hedefe göre yatay hizası; kuyruk her zaman hedefin ortasında. */
  hiza: HintBubbleHiza;
}) {
  const yatay =
    hiza === 'bas'
      ? { left: 0 }
      : hiza === 'son'
        ? { right: 0 }
        : { left: '50%', transform: 'translateX(-50%)' };
  return (
    <>
    <span
      data-hint-bubble=""
      role="status"
      className="pointer-events-none absolute z-30 block"
      style={{
        ...(yon === 'ust' ? { bottom: 'calc(100% + 8px)' } : { top: 'calc(100% + 8px)' }),
        ...yatay,
        width: 'max-content',
        maxWidth: 'min(260px, 70vw)',
      }}
    >
      <span
        className="block font-sans font-bold leading-snug text-center rounded-[9px] text-white normal-case tracking-normal"
        style={{
          background: '#2563EB',
          fontSize: 'clamp(11px, 3.2vw, 16px)',
          padding: '7px 10px',
          boxShadow: '0 2px 6px rgba(15,23,42,0.28)',
        }}
      >
        {text}
      </span>
    </span>
    <HintBubbleTail yon={yon} />
    </>
  );
}

/** Kuyruk ayrı çiziliyor: balon hedefe göre kaysa da (bas/son) kuyruk
 *  HEDEFİN ortasında kalmalı — hedefin kendi kutusuna çapalı. */
function HintBubbleTail({ yon }: { yon: HintBubbleYon }) {
  return (
    <span
      aria-hidden="true"
      className="pointer-events-none absolute z-30"
      style={{
        left: '50%',
        transform: 'translateX(-50%)',
        width: 0,
        height: 0,
        borderLeft: '6px solid transparent',
        borderRight: '6px solid transparent',
        ...(yon === 'ust'
          ? { bottom: 'calc(100% + 2px)', borderTop: '7px solid #2563EB' }
          : { top: 'calc(100% + 2px)', borderBottom: '7px solid #2563EB' }),
      }}
    />
  );
}
