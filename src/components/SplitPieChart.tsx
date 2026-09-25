// Kelimeki — admin paneli: İKİ DİLİMLİ pasta grafiği ("Oyun Dağılımı").
//
// 22 Eylül 2026, kullanıcı isteği: *"Admin Oyun altına 2 pie chart yanyana.
// 1. Yapay zeka vs Arkadaşınla  2. 2 player vs 4 player (biten count)"*
//
// ⚠ TEK BİLEŞEN, İKİ PASTA — `StackedBucketChart`in ("Aktif Saatler" ↔
// "Aktif Günler") aynı gerekçesi: iki pastanın çizim kodu piksel piksel aynı
// olurdu ve bu depoda kopya tam olarak cezalandırılan şey. Pastanın bilmesi
// gereken her şey prop olarak geliyor: başlık, dilimler, `?` rozeti.
//
// ⚠ DİLİM SAYISI İKİYE SABİT DEĞİL ama tasarım iki dilim için yapıldı:
// üçüncü bir dilim eklenirse renk sırası (`slices` dizisinin sırası) ve
// dilim içi yüzde etiketinin eşiği yeniden ölçülmeli.
//
// NEDEN PASTA (ve bilinen itiraz): iki dilimlik bir pasta, genel veri
// görselleştirme literatüründe yığılmış tek çubuğa göre zayıf bir formdur —
// açı, uzunluktan daha zor okunur. Burada bilerek pasta: kullanıcı ikisini
// AÇIKÇA pasta olarak istedi ve soru "iki kategori kabaca hangi oranda"
// düzeyinde, milimetrik bir karşılaştırma değil. Okunabilirlik iki ek
// kanalla kurtarılıyor: dilim İÇİNDE yüzde, altında etiket + HAM SAYI.
//
// RENKLER — `USER_SERIES`/`ACTIVE_PLAYER_SERIES` ile AYNI mavi+amber çifti ve
// bu yeniden karar DEĞİL: o çift renk körlüğü ayrım testiyle seçilmişti
// (protan ΔE 27.0 · tritan 28.8 · normal 32.9; mavi+mor deutan'da 5.2 ile
// ayırt edilemiyordu). İki pasta da aynı çifti kullanıyor çünkü yan yana
// duruyorlar ve her birinin KENDİ efsanesi var — renk, pastalar arasında
// değil pastanın İÇİNDE anlam taşır.
//
// ⚠ Amberin panel zeminine (`bg-panel` #F5F7FA) karşı kontrastı 2,97:1, yani
// 3:1 eşiğinin hemen ALTINDA (ölçüldü). Bu, rengin TEK BAŞINA taşıyıcı
// olamayacağı anlamına gelir — bu yüzden yüzde dilimin içinde, etiket ve ham
// sayı da efsanede YAZIYOR. Dilimlerin arasındaki 2px zemin boşluğu da aynı
// işin parçası: sınır renkten değil boşluktan okunuyor.
import type { ReactNode } from 'react';

export interface PieSlice {
  key: string;
  label: string;
  value: number;
  color: string;
}

interface SplitPieChartProps {
  title: string;
  slices: PieSlice[];
  infoHint?: ReactNode;
  /** Pastanın altına, efsanenin ardına düşen küçük gri satır. */
  note?: string;
}

const SIZE = 120;
const C = SIZE / 2;
const R = 52;
/** Dilimler arasındaki zemin boşluğu — `bg-panel`, admin panelinin zemini. */
const SURFACE = '#F5F7FA';
/**
 * Dilim içine yüzde yazılmasının alt sınırı. Altında etiket kendi diliminden
 * taşıp komşusunun üstüne biner — sayı zaten efsanede duruyor.
 */
const LABEL_MIN_RATIO = 0.08;

function polar(angle: number, r: number) {
  return { x: C + r * Math.cos(angle), y: C + r * Math.sin(angle) };
}

/** Saat 12'den başlayıp saat yönünde giden dilim. */
function wedgePath(a0: number, a1: number): string {
  const large = a1 - a0 > Math.PI ? 1 : 0;
  const p0 = polar(a0, R);
  const p1 = polar(a1, R);
  return `M ${C} ${C} L ${p0.x.toFixed(2)} ${p0.y.toFixed(2)} A ${R} ${R} 0 ${large} 1 ${p1.x.toFixed(2)} ${p1.y.toFixed(2)} Z`;
}

/** `0.5` → `"%50"`. Ondalık YOK: pasta zaten kaba bir okuma aracı. */
function pct(ratio: number): string {
  return `%${Math.round(ratio * 100)}`;
}

export function SplitPieChart({ title, slices, infoHint, note }: SplitPieChartProps) {
  const total = slices.reduce((a, s) => a + s.value, 0);

  // Açılar kümülatif: her dilim bir öncekinin bittiği yerden başlar. Saat
  // 12 = -90°.
  let acc = -Math.PI / 2;
  const cizilecek = slices.map((s) => {
    const oran = total > 0 ? s.value / total : 0;
    const a0 = acc;
    const a1 = a0 + oran * Math.PI * 2;
    acc = a1;
    return { ...s, oran, a0, a1 };
  });
  // Tek dilim %100 ise yay dejenere olur (a0 === a1 mod 2π) ve path HİÇBİR
  // ŞEY çizmez — o durumda tam daire çiziliyor.
  const tekDilim = total > 0 ? cizilecek.find((s) => s.oran === 1) ?? null : null;

  return (
    <div className="flex flex-col gap-2 min-w-0">
      <div className="flex items-center gap-1.5">
        <span className="text-[10px] font-mono uppercase tracking-[1px] text-muted font-bold">
          {title}
        </span>
        {infoHint}
      </div>

      {total === 0 ? (
        <div className="text-xs font-mono text-muted text-center py-8">Bu aralıkta veri yok.</div>
      ) : (
        <svg
          viewBox={`0 0 ${SIZE} ${SIZE}`}
          className="w-full h-auto"
          role="img"
          aria-label={`${title}: ${cizilecek.map((s) => `${s.label} ${s.value}`).join(', ')}`}
        >
          {tekDilim ? (
            <circle cx={C} cy={C} r={R} fill={tekDilim.color} />
          ) : (
            cizilecek.map((s) =>
              s.oran === 0 ? null : (
                <path
                  key={s.key}
                  d={wedgePath(s.a0, s.a1)}
                  fill={s.color}
                  // Sınır rengin değil ZEMİNİN işi (dosya başındaki kontrast
                  // notu) — 2px, iki dilim arasında 1+1 px.
                  stroke={SURFACE}
                  strokeWidth={2}
                  strokeLinejoin="round"
                />
              ),
            )
          )}
          {cizilecek.map((s) => {
            if (s.oran < LABEL_MIN_RATIO) return null;
            const orta = polar((s.a0 + s.a1) / 2, R * 0.58);
            return (
              <text
                key={s.key}
                x={orta.x}
                y={orta.y}
                textAnchor="middle"
                dominantBaseline="central"
                fontSize={13}
                fontWeight={700}
                fill="#FFFFFF"
              >
                {pct(s.oran)}
              </text>
            );
          })}
        </svg>
      )}

      {/* Efsane aynı zamanda TABLO: etiket + ham sayı + yüzde. Pastada
          okunamayan (ya da eşiğin altında kaldığı için hiç yazılmayan) her
          değer burada yazıyor. */}
      <div className="flex flex-col gap-1">
        {cizilecek.map((s) => (
          <div key={s.key} className="flex items-start gap-1.5 text-[10px] font-mono text-text">
            <span
              className="inline-block w-2.5 h-2.5 rounded-[2px] shrink-0 mt-[1px]"
              style={{ background: s.color }}
            />
            {/* ⚠ KIRPMA YOK, SARMA VAR: iki pasta dar bir telefonda ~150px
                sütuna düşüyor ve `truncate` ile "Yapay …" ile "Arkadaşı…"
                ayırt edilemiyordu (22 Eylül 2026, önizlemede ölçüldü).
                Satırın iki satıra çıkması, etiketin okunamamasından iyi. */}
            <span className="min-w-0 break-words leading-tight">{s.label}</span>
            <span className="ml-auto shrink-0 font-bold">{s.value}</span>
            <span className="shrink-0 text-muted w-9 text-right">
              {total === 0 ? '—' : pct(s.oran)}
            </span>
          </div>
        ))}
      </div>

      {note && <p className="text-[9px] font-mono text-muted leading-snug">{note}</p>}
    </div>
  );
}
