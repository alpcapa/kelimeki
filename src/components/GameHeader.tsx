// Kelimeki — başlık: skorlar ve hesap menüsü
import { PLAYER_COLORS } from '../game/constants';
import type { GameState } from '../game/types';
import { LogoMark } from './LogoMark';
import { UserMenu } from './UserMenu';

// Skor kutuları akıcı/duyarlı: dar ekranlarda küçülüp genişte tam boya
// çıkar, böylece 4 oyunculu + Giriş butonu neredeyse hiçbir zaman
// kaydırmaya ihtiyaç duymaz (eskiden sabit 84/56px'ti — bkz. git geçmişi).
// Her `clamp(min, calc(A + Bvw), max)` 375px'te (kullanıcıya onaylatılan
// örnek görselin baz alındığı genişlik) min'e, 465px'te max'e ulaşacak
// şekilde hesaplanmıştır. 465 kasıtlı olarak geniş tutuldu: ilk denemede
// 430 kullanılmıştı ama ölçünce içeriğin büyüme hızının (vw başına),
// header'da gerçekten açılan boş alanın büyüme hızından daha yüksek
// olduğu görüldü — yani 375-430 arasında açık kapanıp sonra tekrar
// açılıyordu. 465 bu eğimi gerçek açılan alanın eğiminin altında tutuyor,
// açık bir daha açılmıyor (375px ve üstünde ölçülüp doğrulandı). 375px'in
// altında (nadir/çok küçük telefonlar) clamp() min'in altına inmez, orada
// bir miktar kaydırma gerekebilir (kabul edildi, bkz. git geçmişi).
// Tailwind class'ı değil inline style kullanılıyor çünkü clamp()/calc()
// içindeki virgüller Tailwind'in arbitrary-value söz dizimiyle iyi
// geçinmiyor.
const PLAYER_BOX_WIDTH = 'clamp(61px, calc(-34.83px + 25.56vw), 84px)';
const YZ_BOX_WIDTH = 'clamp(41px, calc(-21.5px + 16.67vw), 56px)';
const LABEL_FONT_SIZE = 'clamp(6px, calc(-2.33px + 2.22vw), 8px)';
const SCORE_FONT_SIZE = 'clamp(13px, calc(-7.83px + 5.56vw), 18px)';
const BOX_PADDING_X = 'clamp(6px, calc(-2.33px + 2.22vw), 8px)';
const BOX_GAP = 'clamp(6px, calc(-2.33px + 2.22vw), 8px)';

interface GameHeaderProps {
  state: GameState;
  onLogoClick?: () => void;
  /** true iken çıkış devre dışı — ör. teslim olup YZ'leri izlerken oyundan
   *  çıkılamaz, oyunun bitmesi beklenmek zorunda. */
  exitDisabled?: boolean;
}

export function GameHeader({ state, onLogoClick, exitDisabled }: GameHeaderProps) {
  const { players, current } = state;
  return (
    <header className="w-full max-w-[680px] flex items-center justify-between gap-2 px-3 py-2.5 border-b border-border">
      <button
        onClick={onLogoClick}
        disabled={exitDisabled}
        className="shrink-0 flex flex-col items-center leading-none active:opacity-70 transition-opacity disabled:opacity-40 disabled:cursor-not-allowed disabled:active:opacity-40"
        aria-label="Oyundan çık">
        <LogoMark height={28} />
      </button>

      {/* Akıcı boyutlandırma 375px'te (bkz. yukarı) neredeyse tam sığdırsa
          da (logo/header dolgusu küçülmediğinden birkaç px'lik açık
          kalabiliyor) ve 375px altındaki nadir/çok küçük telefonlarda
          clamp() taban değerin altına inmediğinden orada kaydırma hâlâ
          gerekebilir (kabul edildi). Bu uç durum için
          min-w-0 + overflow-x-auto + no-scrollbar hâlâ güvenlik ağı
          olarak duruyor: sığmazsa header 2. satıra taşıp kutuları
          bozmak yerine şerit görünmez biçimde yatay kaydırılır.
          justify-end KULLANMA: taşan bir flex konteynerde justify-content:
          flex-end, taşan içeriği scrollWidth'e hiç yansımayan, kaydırarak
          bile ulaşılamayan bir şekilde kırpıyor (test edilip doğrulandı).
          justify-start (varsayılan) ile taşma her zaman erişilebilir kalır
          ve en önemli kutu (0. oyuncu/hesap sahibi) her zaman görünür. */}
      <div
        className="flex items-center min-w-0 overflow-x-auto no-scrollbar"
        style={{ gap: BOX_GAP }}
      >
        {players.map((p, i) => {
          const col = PLAYER_COLORS[p.colorIndex];
          const active = i === current;
          const label = p.isAI
            ? players.length === 2
              ? 'YZ'
              : `YZ ${i + 1}`
            : p.name;
          return (
            <div
              key={i}
              className="shrink-0 shadow-raised text-center rounded-md py-0.5 transition-all"
              style={{
                width: p.isAI ? YZ_BOX_WIDTH : PLAYER_BOX_WIDTH,
                paddingLeft: BOX_PADDING_X,
                paddingRight: BOX_PADDING_X,
                // Board'daki bölge renklendirmesiyle birebir aynı eşleme:
                // iç dolgu = zone.tint, sınır çizgisi = base (bkz. Board.tsx
                // territory hücre dolgusu ve buildOutline çağrısı). Sıra
                // kimdeyse onu ayırt etmek için tek fark çerçeve kalınlığı —
                // renk her oyuncuda aynı mantıkla (kendi base'i) belirleniyor.
                background: col.tint,
                boxShadow: `inset 0 0 0 ${active ? 2.5 : 1.5}px ${col.base}`,
                opacity: p.surrendered ? 0.45 : 1,
              }}
            >
              <div
                className="uppercase tracking-[1px] font-mono font-bold truncate"
                style={{
                  fontSize: LABEL_FONT_SIZE,
                  color: col.base,
                  textDecoration: p.surrendered ? 'line-through' : 'none',
                }}
              >
                {p.surrendered ? 'Teslim' : label}
              </div>
              <div
                className="font-mono font-bold leading-none"
                style={{ fontSize: SCORE_FONT_SIZE, color: col.base }}
              >
                {p.score}
              </div>
            </div>
          );
        })}

        <UserMenu />
      </div>
    </header>
  );
}
