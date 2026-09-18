// Kelimeki — admin paneli: "Aktif Saatler" yığılmış çubuk grafiği
// (18 Eylül 2026, kullanıcı isteği: *"Admin oyun sayfasına Aktif Saatler bar
// grafiği eklemek istiyorum. 2 saatlik dilimler olsun. Web, ios ve android
// kırılımları olursa iyi olur. Oyun bitişleri baz alalım."*)
//
// NEDEN AYRI BİR BİLEŞEN, `GrowthChart` DEĞİL: `GrowthChart` bir ZAMAN
// SERİSİ çizgi grafiği — x ekseni tarih (`bucket: string`), etiketleri
// `toLocaleDateString` ile biçimliyor ve serileri üst üste BİNEN çizgiler
// olarak çiziyor. Buradaki soru başka bir soru: 12 sabit kova ve segmentleri
// TOPLANAN tek bir çubuk. Zorlanarak uydurulsaydı tarih biçimlendirmesi de
// çizgi mantığı da yolda bozulurdu.
//
// Görsel dil yine de `GrowthChart`ınkiyle BİREBİR: aynı viewBox (640×240),
// aynı kenar boşlukları, aynı ızgara/metin renkleri, aynı "Tablo Görünümü" +
// "CSV İndir" + `infoHint` üçlüsü, aynı padding-top oranı tekniği (bkz.
// oradaki Safari notu). İki grafik aynı sekmede yan yana duruyor.
//
// ⚠ EFSANE TIKLANABİLİR DEĞİL — `GrowthChart`tan bilinçli ayrım. Orada seri
// açıp kapatmak anlamlı (çizgiler bağımsız); burada segmentler `finished`e
// TAM toplanıyor ve bir segmenti gizlemek çubuğu sessizce yalan söyletirdi
// (toplam aynı kalır, parçalar tutmaz). Efsane bu yüzden yalnızca bir
// anahtar.
import { useRef, useState } from 'react';
import type { ChartSeriesDef } from './GrowthChart';
import type { AdminActiveHoursRow } from '../lib/database.types';
import { downloadCsv } from '../utils/csvExport';

interface ActiveHoursChartProps {
  data: AdminActiveHoursRow[];
  /** Yığılma sırası: dizinin İLK öğesi en ALTTA çizilir. */
  series: ChartSeriesDef[];
  /** Bölüm başlığı (+ varsa kontroller) — CSV/tablo linkleriyle aynı satırda. */
  controls?: React.ReactNode;
  csvBaseName?: string;
  infoHint?: React.ReactNode;
}

const W = 640;
const H = 240;
const PAD = { top: 16, right: 12, bottom: 24, left: 34 };
const PLOT_H = H - PAD.top - PAD.bottom;
/** Çubuklar arası boşluğun banda oranı. */
const BAR_GAP = 0.28;

function valueOf(row: AdminActiveHoursRow, key: string): number {
  const v = (row as unknown as Record<string, unknown>)[key];
  return typeof v === 'number' ? v : 0;
}

/**
 * Y ekseninin üst sınırı.
 *
 * ⚠ Merdiven `GrowthChart`ınkinden (1 · 2 · 5 · 10) bilerek DAHA İNCE ve bu
 * kopya-sapma değil, grafik türünün gereği: çizgi grafiği ŞEKİLDEN okunur,
 * çubuk grafiği YÜKSEKLİKTEN. Kaba merdivende 236'lık bir tepe 500'e
 * yuvarlanıyor ve en yüksek çubuk çizim alanının %47'sinde kalıyordu —
 * ölçüldü (18 Eylül 2026, gerçek 30 günlük veriyle). İnce merdivende aynı
 * tepe 250'ye yuvarlanıyor, yani %94.
 */
function niceCeil(n: number): number {
  if (n <= 0) return 1;
  const exp = Math.floor(Math.log10(n));
  const base = Math.pow(10, exp);
  const norm = n / base;
  const ladder = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10];
  const niceNorm = ladder.find((t) => norm <= t) ?? 10;
  return niceNorm * base;
}

/** `0` → `"00–02"`. Tire değil EN DASH (–) — aralık işareti. */
function hourBucketLabel(hourStart: number): string {
  const bit = (hourStart + 2) % 24;
  const iki = (n: number) => String(n).padStart(2, '0');
  // 22 diliminin ucu "00" değil "24" yazılır: "22–00" bir sonraki güne
  // atlıyormuş gibi okunuyor, oysa aynı günün son dilimi.
  return `${iki(hourStart)}–${hourStart === 22 ? '24' : iki(bit)}`;
}

export function ActiveHoursChart({
  data,
  series,
  controls,
  csvBaseName,
  infoHint,
}: ActiveHoursChartProps) {
  const [showTable, setShowTable] = useState(false);
  const [hoverIndex, setHoverIndex] = useState<number | null>(null);
  const wrapRef = useRef<HTMLDivElement | null>(null);

  const n = data.length;
  const maxRaw = Math.max(1, ...data.map((d) => d.finished));
  const niceMax = niceCeil(maxRaw);
  const yTicks = niceMax <= 4 ? [0, niceMax] : [0, Math.round(niceMax / 2), niceMax];

  const plotW = W - PAD.left - PAD.right;
  const band = n > 0 ? plotW / n : plotW;
  const barW = band * (1 - BAR_GAP);
  const bandX = (i: number) => PAD.left + i * band;
  const barX = (i: number) => bandX(i) + (band - barW) / 2;
  const y = (v: number) => PAD.top + PLOT_H - (v / niceMax) * PLOT_H;

  function handlePointerMove(e: React.PointerEvent<HTMLDivElement>) {
    const el = wrapRef.current;
    if (!el || n === 0) return;
    const rect = el.getBoundingClientRect();
    const xInViewBox = ((e.clientX - rect.left) / rect.width) * W;
    const idx = Math.floor((xInViewBox - PAD.left) / band);
    setHoverIndex(Math.min(n - 1, Math.max(0, idx)));
  }

  function handlePointerDown(e: React.PointerEvent<HTMLDivElement>) {
    // `GrowthChart` ile aynı gerekçe: dokunmatikte parmak birkaç piksel
    // kayınca tarayıcı jesti "pan" sanıp pointer'ı sayfaya devrediyor.
    e.currentTarget.setPointerCapture(e.pointerId);
    handlePointerMove(e);
  }

  const hover = hoverIndex !== null ? data[hoverIndex] : null;

  function handleExportCsv() {
    downloadCsv(
      `${csvBaseName}-${new Date().toISOString().slice(0, 10)}.csv`,
      ['Saat', 'Bitirilen', ...series.map((s) => s.label)],
      data.map((row) => [
        hourBucketLabel(row.hour_start),
        row.finished,
        ...series.map((s) => valueOf(row, s.key)),
      ]),
    );
  }

  return (
    <div className="flex flex-col gap-2">
      <div className="flex items-center flex-wrap gap-x-2 gap-y-1.5">
        {controls}
        <div className="flex items-center gap-2 ml-auto shrink-0">
          {infoHint}
          {csvBaseName && n > 0 && (
            <button
              type="button"
              onClick={handleExportCsv}
              className="text-[9px] font-mono uppercase tracking-[0.5px] text-muted underline underline-offset-2 active:opacity-70 transition-opacity"
            >
              CSV İndir
            </button>
          )}
          <button
            type="button"
            onClick={() => setShowTable((v) => !v)}
            className="text-[9px] font-mono uppercase tracking-[0.5px] text-muted underline underline-offset-2 active:opacity-70 transition-opacity"
          >
            {showTable ? 'Grafik Görünümü' : 'Tablo Görünümü'}
          </button>
        </div>
      </div>

      {/* Anahtar — TIKLANABİLİR DEĞİL (dosya başındaki not). Kare rozet,
          `GrowthChart`ın çizgi rozetinden bilerek farklı: orada çizgi, burada
          dolu alan. */}
      <div className="flex items-center gap-3 flex-wrap">
        {series.map((s) => (
          <span key={s.key} className="flex items-center gap-1.5 text-[10px] font-mono text-text">
            <span className="inline-block w-2.5 h-2.5 rounded-[2px]" style={{ background: s.color }} />
            {s.label}
          </span>
        ))}
      </div>

      {n === 0 ? (
        <div className="text-xs font-mono text-muted text-center py-8">Bu aralıkta veri yok.</div>
      ) : showTable ? (
        <div className="overflow-x-auto max-h-[280px] overflow-y-auto">
          <table className="w-full text-[11px] font-mono border-collapse">
            <thead>
              <tr className="text-left text-muted border-b border-border sticky top-0 bg-panel">
                <th className="py-1.5 pr-3 font-bold">Saat</th>
                <th className="py-1.5 pr-3 font-bold text-right">Bitirilen</th>
                {series.map((s) => (
                  <th key={s.key} className="py-1.5 pr-3 font-bold text-right last:pr-0">
                    {s.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {data.map((row) => (
                <tr key={row.hour_start} className="border-b border-border/50">
                  <td className="py-1.5 pr-3 text-text whitespace-nowrap">
                    {hourBucketLabel(row.hour_start)}
                  </td>
                  <td className="py-1.5 pr-3 text-text text-right font-bold">{row.finished}</td>
                  {series.map((s) => (
                    <td key={s.key} className="py-1.5 pr-3 text-text text-right last:pr-0">
                      {valueOf(row, s.key)}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="relative w-full select-none">
          <div style={{ paddingTop: `${(H / W) * 100}%` }} />
          <div
            ref={wrapRef}
            className="absolute inset-0"
            style={{ touchAction: 'none' }}
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerLeave={() => setHoverIndex(null)}
          >
            <svg width="100%" height="100%" viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none">
              {yTicks.map((t) => (
                <g key={t}>
                  <line x1={PAD.left} x2={W - PAD.right} y1={y(t)} y2={y(t)} stroke="#DCE2EA" strokeWidth={1} />
                  <text
                    x={PAD.left - 6}
                    y={y(t)}
                    textAnchor="end"
                    dominantBaseline="middle"
                    fontSize={13}
                    fill="#8A93A2"
                  >
                    {t}
                  </text>
                </g>
              ))}

              {data.map((row, i) => {
                // Segmentler ALTTAN yukarı yığılıyor; `acc` bir sonraki
                // segmentin tabanı.
                let acc = 0;
                return (
                  <g key={row.hour_start}>
                    {hoverIndex === i && (
                      <rect
                        x={bandX(i)}
                        y={PAD.top}
                        width={band}
                        height={PLOT_H}
                        fill="#8A93A2"
                        opacity={0.09}
                      />
                    )}
                    {series.map((s) => {
                      const v = valueOf(row, s.key);
                      const y0 = y(acc);
                      acc += v;
                      const y1 = y(acc);
                      if (v <= 0) return null;
                      return (
                        <rect
                          key={s.key}
                          x={barX(i)}
                          y={y1}
                          width={barW}
                          height={Math.max(0, y0 - y1)}
                          fill={s.color}
                        />
                      );
                    })}
                  </g>
                );
              })}

              {/* Saat etiketleri: 12 etiket 640 px'de kalabalık olduğundan
                  yalnızca çift dilimler (00 · 04 · 08 · 12 · 16 · 20)
                  yazılıyor — kova aralığının TAMAMI zaten tooltip'te ve
                  tabloda. */}
              {data.map((row, i) =>
                row.hour_start % 4 === 0 ? (
                  <text
                    key={row.hour_start}
                    x={bandX(i) + band / 2}
                    y={H - 4}
                    textAnchor="middle"
                    fontSize={12}
                    fill="#8A93A2"
                  >
                    {String(row.hour_start).padStart(2, '0')}
                  </text>
                ) : null,
              )}
            </svg>

            {hover && hoverIndex !== null && (
              <div
                className="absolute top-0 -translate-x-1/2 pointer-events-none bg-panel border border-border rounded-md shadow-[0_4px_12px_rgba(15,23,42,0.15)] px-2.5 py-1.5 text-[10px] font-mono whitespace-nowrap"
                // Uç kovalarda kutu grafiğin DIŞINA taşıyordu (18 Eylül
                // 2026'da ekran görüntüsüyle yakalandı: son çubuğun tooltip'i
                // grafiğin üstünü örtüyordu). Çözüm `GrowthChart`ınkiyle
                // aynı: uçlarda kutuyu yarı yarıya değil TAM kaydır.
                style={{
                  left: `${((bandX(hoverIndex) + band / 2) / W) * 100}%`,
                  marginLeft: hoverIndex === 0 ? 8 : hoverIndex === n - 1 ? -8 : 0,
                  transform:
                    hoverIndex === 0
                      ? 'translateX(0)'
                      : hoverIndex === n - 1
                        ? 'translateX(-100%)'
                        : 'translateX(-50%)',
                }}
              >
                <div className="text-muted mb-1">{hourBucketLabel(hover.hour_start)}</div>
                <div className="flex items-center gap-1.5 mb-0.5">
                  <span className="font-bold text-text text-[12px]">{hover.finished}</span>
                  <span className="text-muted">Bitirilen</span>
                </div>
                {series.map((s) => (
                  <div key={s.key} className="flex items-center gap-1.5">
                    <span className="inline-block w-2.5 h-2.5 rounded-[2px]" style={{ background: s.color }} />
                    <span className="font-bold text-text text-[12px]">{valueOf(hover, s.key)}</span>
                    <span className="text-muted">{s.label}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
