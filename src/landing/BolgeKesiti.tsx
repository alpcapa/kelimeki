// Kelimeki — karşılamanın ilk ekranındaki tahta kesiti (verisi ve gerekçesi:
// `ilkEkranKesiti.ts`).
//
// ⚠ Sunucuda render edilir (bkz. `Landing.tsx` başlığı): hook/olay/tarayıcı
// globali YOK.
//
// Görsel dil `Board.tsx`ten OKUNUYOR, kopyalanmıyor: renkler
// `PLAYER_COLORS`tan, bölge dış hattı oyunun kendi `buildRoundedOutlinePath`
// algoritmasıyla (aynı yarıçap, aynı kalınlık), taş puanı `TILE_DATA`dan.
// Hücre gölgeleri `Board.tsx`in boş/bölge hücre dallarıyla aynı değerler.
import { PLAYER_COLORS } from '../game/constants';
import { TILE_DATA } from '../data/tiles';
import { buildRoundedOutlinePath } from '../utils/outline';
import { OUTLINE_RADIUS, OUTLINE_STROKE } from '../components/Board';
import {
  KESIT_ACIK_KENARLAR,
  KESIT_HARITA,
  KESIT_SUTUN,
  kesitHucreleri,
} from './ilkEkranKesiti';

const SEN = PLAYER_COLORS[0];
const RAKIP = PLAYER_COLORS[1];

export function BolgeKesiti() {
  const hucreler = kesitHucreleri();
  const satir = KESIT_HARITA.length;

  const senin: [number, number][] = [];
  const rakibin: [number, number][] = [];
  hucreler.forEach((s, r) =>
    s.forEach((h, c) => {
      const kim = h.tur === 'tas' ? h.sahip : h.bolge;
      if (kim === 'sen') senin.push([r, c]);
      if (kim === 'rakip') rakibin.push([r, c]);
    }),
  );
  const seninHat = buildRoundedOutlinePath(senin, OUTLINE_RADIUS);
  const rakipHat = buildRoundedOutlinePath(rakibin, OUTLINE_RADIUS, (_r, _c, nr, nc) =>
    (KESIT_ACIK_KENARLAR.sag && nc >= KESIT_SUTUN) || (KESIT_ACIK_KENARLAR.alt && nr >= satir),
  );

  return (
    <div
      role="img"
      aria-label="Tahta kesiti: solda senin camgöbeği bölgen ve SAAT kelimen, sağ altta rakibin kırmızı bölgesi ve KUL kelimesi. SAAT'in son harfi rakibin bölgesine değiyor; bu yüzden puanın üçte biri rakibe geçer."
      className="relative w-full max-w-[340px] lg:max-w-[440px] mx-auto rounded-[18px] bg-[#DDE4EE] p-[10px] shadow-raised"
    >
      <div
        className="relative grid gap-[3px] [container-type:inline-size]"
        style={{ gridTemplateColumns: `repeat(${KESIT_SUTUN}, 1fr)` }}
      >
        {hucreler.flatMap((s, r) =>
          s.map((h, c) => {
            const anahtar = `${r}-${c}`;
            if (h.tur === 'bos') {
              const renk = h.bolge === 'sen' ? SEN : h.bolge === 'rakip' ? RAKIP : null;
              return (
                <span
                  key={anahtar}
                  className="block aspect-square rounded-[5px]"
                  style={
                    renk
                      ? {
                          background: renk.tint,
                          boxShadow: `inset 2px 2px 5px ${renk.base}22, inset -1px -1px 3px rgba(255,255,255,0.6)`,
                        }
                      : {
                          background: '#DDE4EE',
                          boxShadow:
                            'inset 3px 3px 6px rgba(163,177,198,0.6), inset -2px -2px 5px rgba(255,255,255,0.8)',
                        }
                  }
                />
              );
            }
            const renk = h.sahip === 'sen' ? SEN : RAKIP;
            return (
              <span
                key={anahtar}
                className="relative flex aspect-square items-center justify-center rounded-[5px]"
                style={{
                  background: renk.tint,
                  border: `1px solid ${renk.base}`,
                  color: renk.text,
                  boxShadow: h.degen ? `0 0 0 2px ${RAKIP.base}` : undefined,
                }}
              >
                <span
                  className="font-tile font-extrabold leading-none [-webkit-text-stroke-color:currentColor]"
                  style={{ fontSize: '8.4cqw', WebkitTextStrokeWidth: '0.35px' }}
                >
                  {h.harf}
                </span>
                <span
                  className="absolute top-[2px] right-[3px] font-mono font-bold leading-none text-accent"
                  style={{ fontSize: '3cqw' }}
                >
                  {TILE_DATA[h.harf]?.pts}
                </span>
              </span>
            );
          }),
        )}
        {/* Dış hatlar — `Board.tsx`teki gibi ızgaranın tamamını kaplayan tek SVG. */}
        <svg
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 block h-full w-full"
          style={{ overflow: 'visible' }}
          viewBox={`0 0 ${KESIT_SUTUN} ${satir}`}
          preserveAspectRatio="none"
        >
          {[
            [seninHat, SEN.base],
            [rakipHat, RAKIP.base],
          ].map(([d, renk]) => (
            <path
              key={renk}
              d={d}
              fill="none"
              stroke={renk}
              strokeWidth={OUTLINE_STROKE}
              strokeLinecap="round"
              strokeLinejoin="round"
              vectorEffect="non-scaling-stroke"
            />
          ))}
        </svg>
      </div>
      <span className="absolute -right-1.5 -top-3.5 rounded-full bg-text px-2.5 py-1.5 font-mono text-[11px] font-bold leading-none tracking-[0.5px] text-white shadow-[0_6px_14px_rgba(27,36,48,0.3)]">
        Vergi: puanın 1/3'ü rakibe
      </span>
    </div>
  );
}
