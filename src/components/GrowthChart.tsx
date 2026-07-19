// Harfik — admin paneli: günlük kayıt/oyun başlatma/oyun bitirme çizgi grafiği
import { useMemo, useRef, useState } from 'react';
import type { AdminActivityGranularity, AdminActivityPoint } from '../lib/database.types';

interface GrowthChartProps {
  data: AdminActivityPoint[];
  granularity: AdminActivityGranularity;
  /** Aralık/periyot seçim kontrolleri — tablo görünümü linkiyle aynı satırda gösterilir. */
  controls?: React.ReactNode;
}

const SERIES = [
  { key: 'signups', label: 'Yeni Kayıt', color: '#2a78d6' },
  { key: 'game_starts', label: 'Başlatılan', color: '#eda100' },
  { key: 'games_finished', label: 'Bitirilen', color: '#008300' },
] as const;

const W = 640;
const H = 240;
const PAD = { top: 16, right: 58, bottom: 24, left: 30 };
const PLOT_W = W - PAD.left - PAD.right;
const PLOT_H = H - PAD.top - PAD.bottom;

function niceCeil(n: number): number {
  if (n <= 0) return 1;
  const exp = Math.floor(Math.log10(n));
  const base = Math.pow(10, exp);
  const norm = n / base;
  const niceNorm = norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10;
  return niceNorm * base;
}

function fmtShortDate(iso: string, granularity: AdminActivityGranularity): string {
  const d = new Date(iso + 'T00:00:00');
  return granularity === 'month'
    ? d.toLocaleDateString('tr-TR', { month: 'short', year: '2-digit' })
    : d.toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' });
}

function fmtFullDate(iso: string, granularity: AdminActivityGranularity): string {
  const d = new Date(iso + 'T00:00:00');
  return granularity === 'month'
    ? d.toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' })
    : d.toLocaleDateString('tr-TR', { day: '2-digit', month: 'long', year: 'numeric' });
}

export function GrowthChart({ data, granularity, controls }: GrowthChartProps) {
  const [showTable, setShowTable] = useState(false);
  const [hoverIndex, setHoverIndex] = useState<number | null>(null);
  // Legend'a tıklayarak açılıp kapatılabilen seriler — başlangıçta sadece
  // "Yeni Kayıt" görünür, diğerleri tıklanınca eklenir/çıkarılır.
  const [activeKeys, setActiveKeys] = useState<Set<(typeof SERIES)[number]['key']>>(
    () => new Set(['signups']),
  );
  const wrapRef = useRef<HTMLDivElement | null>(null);

  const activeSeries = SERIES.filter((s) => activeKeys.has(s.key));

  function toggleSeries(key: (typeof SERIES)[number]['key']) {
    setActiveKeys((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  }

  const n = data.length;
  const maxRaw = Math.max(
    1,
    ...data.flatMap((d) => activeSeries.map((s) => d[s.key])),
  );
  const niceMax = niceCeil(maxRaw);
  const yTicks = niceMax <= 4 ? [0, niceMax] : [0, Math.round(niceMax / 2), niceMax];

  const x = (i: number) => PAD.left + (n <= 1 ? 0 : (i / (n - 1)) * PLOT_W);
  const y = (v: number) => PAD.top + PLOT_H - (v / niceMax) * PLOT_H;

  const paths = useMemo(
    () =>
      activeSeries.map((s) => ({
        ...s,
        d: data.map((row, i) => `${i === 0 ? 'M' : 'L'} ${x(i)} ${y(row[s.key])}`).join(' '),
      })),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [data, niceMax, activeKeys],
  );

  // Son noktadaki değer etiketlerini üst üste binmeyecek şekilde dikey olarak ayır.
  const endLabels = useMemo(() => {
    if (n === 0) return [];
    const raw = activeSeries.map((s) => {
      const value = data[n - 1][s.key];
      return { ...s, value, rawY: y(value) };
    }).sort((a, b) => a.rawY - b.rawY);
    const MIN_GAP = 13;
    for (let i = 1; i < raw.length; i++) {
      if (raw[i].rawY - raw[i - 1].rawY < MIN_GAP) {
        raw[i].rawY = raw[i - 1].rawY + MIN_GAP;
      }
    }
    return raw;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [data, niceMax, activeKeys]);

  function handlePointerMove(e: React.PointerEvent<HTMLDivElement>) {
    const el = wrapRef.current;
    if (!el || n === 0) return;
    const rect = el.getBoundingClientRect();
    const xInViewBox = ((e.clientX - rect.left) / rect.width) * W;
    const idx = Math.round(((xInViewBox - PAD.left) / PLOT_W) * (n - 1));
    setHoverIndex(Math.min(n - 1, Math.max(0, idx)));
  }

  const hover = hoverIndex !== null ? data[hoverIndex] : null;
  const hoverPct = hoverIndex !== null ? { left: `${(x(hoverIndex) / W) * 100}%` } : null;

  return (
    <div className="flex flex-col gap-2">
      <div className="flex items-center flex-wrap gap-x-2 gap-y-1.5">
        {controls}
        <button
          type="button"
          onClick={() => setShowTable((v) => !v)}
          className="text-[10px] font-mono font-bold uppercase tracking-[0.5px] text-muted underline underline-offset-2 active:opacity-70 transition-opacity shrink-0 ml-auto"
        >
          {showTable ? 'Grafik Görünümü' : 'Tablo Görünümü'}
        </button>
      </div>

      <div className="flex items-center gap-3 flex-wrap">
        {SERIES.map((s) => {
          const active = activeKeys.has(s.key);
          return (
            <button
              key={s.key}
              type="button"
              onClick={() => toggleSeries(s.key)}
              className={`flex items-center gap-1.5 text-[10px] font-mono transition-opacity ${
                active ? 'text-text' : 'text-muted opacity-45'
              }`}
            >
              <span
                className="inline-block w-3 h-[2px] rounded-full"
                style={{ background: active ? s.color : '#8A93A2' }}
              />
              {s.label}
            </button>
          );
        })}
      </div>

      {n === 0 ? (
        <div className="text-xs font-mono text-muted text-center py-8">Bu aralıkta veri yok.</div>
      ) : showTable ? (
        <div className="overflow-x-auto max-h-[280px] overflow-y-auto">
          <table className="w-full text-[11px] font-mono border-collapse">
            <thead>
              <tr className="text-left text-muted border-b border-border sticky top-0 bg-panel">
                <th className="py-1.5 pr-3 font-bold">Tarih</th>
                <th className="py-1.5 pr-3 font-bold text-right">Yeni Kayıt</th>
                <th className="py-1.5 pr-3 font-bold text-right">Başlatılan</th>
                <th className="py-1.5 font-bold text-right">Bitirilen</th>
              </tr>
            </thead>
            <tbody>
              {[...data].reverse().map((row) => (
                <tr key={row.bucket} className="border-b border-border/50">
                  <td className="py-1.5 pr-3 text-text whitespace-nowrap">{fmtFullDate(row.bucket, granularity)}</td>
                  <td className="py-1.5 pr-3 text-text text-right">{row.signups}</td>
                  <td className="py-1.5 pr-3 text-text text-right">{row.game_starts}</td>
                  <td className="py-1.5 text-text text-right">{row.games_finished}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div
          ref={wrapRef}
          className="relative w-full select-none"
          style={{ aspectRatio: `${W} / ${H}` }}
          onPointerMove={handlePointerMove}
          onPointerLeave={() => setHoverIndex(null)}
        >
          <svg width="100%" height="100%" viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none">
            {yTicks.map((t) => (
              <g key={t}>
                <line
                  x1={PAD.left}
                  x2={W - PAD.right}
                  y1={y(t)}
                  y2={y(t)}
                  stroke="#DCE2EA"
                  strokeWidth={1}
                />
                <text x={PAD.left - 6} y={y(t)} textAnchor="end" dominantBaseline="middle" fontSize={9} fill="#8A93A2">
                  {t}
                </text>
              </g>
            ))}

            <text x={PAD.left} y={H - 4} textAnchor="start" fontSize={9} fill="#8A93A2">
              {fmtShortDate(data[0].bucket, granularity)}
            </text>
            {n > 2 && (
              <text x={x(Math.floor((n - 1) / 2))} y={H - 4} textAnchor="middle" fontSize={9} fill="#8A93A2">
                {fmtShortDate(data[Math.floor((n - 1) / 2)].bucket, granularity)}
              </text>
            )}
            <text x={x(n - 1)} y={H - 4} textAnchor="end" fontSize={9} fill="#8A93A2">
              {fmtShortDate(data[n - 1].bucket, granularity)}
            </text>

            {hoverIndex !== null && (
              <line
                x1={x(hoverIndex)}
                x2={x(hoverIndex)}
                y1={PAD.top}
                y2={PAD.top + PLOT_H}
                stroke="#8A93A2"
                strokeWidth={1}
              />
            )}

            {paths.map((p) => (
              <path key={p.key} d={p.d} fill="none" stroke={p.color} strokeWidth={2} strokeLinejoin="round" strokeLinecap="round" />
            ))}

            {activeSeries.map((s) => (
              <circle
                key={s.key}
                cx={x(n - 1)}
                cy={y(data[n - 1][s.key])}
                r={4}
                fill={s.color}
                stroke="#FFFFFF"
                strokeWidth={2}
              />
            ))}

            {endLabels.map((l) => (
              <g key={l.key}>
                {Math.abs(l.rawY - y(l.value)) > 0.5 && (
                  <line x1={x(n - 1) + 5} x2={x(n - 1) + 10} y1={y(l.value)} y2={l.rawY} stroke="#DCE2EA" strokeWidth={1} />
                )}
                <text x={x(n - 1) + 12} y={l.rawY} dominantBaseline="middle" fontSize={10} fontWeight={700} fill="#1B2430">
                  {l.value}
                </text>
              </g>
            ))}
          </svg>

          {hover && hoverPct && (
            <div
              className="absolute top-0 -translate-x-1/2 pointer-events-none bg-panel border border-border rounded-md shadow-[0_4px_12px_rgba(15,23,42,0.15)] px-2.5 py-1.5 text-[10px] font-mono whitespace-nowrap"
              style={{
                left: hoverPct.left,
                marginLeft: hoverIndex === 0 ? 8 : hoverIndex === n - 1 ? -8 : 0,
                transform: hoverIndex === 0 ? 'translateX(0)' : hoverIndex === n - 1 ? 'translateX(-100%)' : 'translateX(-50%)',
              }}
            >
              <div className="text-muted mb-1">{fmtFullDate(hover.bucket, granularity)}</div>
              {activeSeries.map((s) => (
                <div key={s.key} className="flex items-center gap-1.5">
                  <span className="inline-block w-2.5 h-[2px] rounded-full" style={{ background: s.color }} />
                  <span className="font-bold text-text">{hover[s.key]}</span>
                  <span className="text-muted">{s.label}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
