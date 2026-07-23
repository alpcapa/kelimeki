// Kelimeki — başlık: skorlar ve hesap menüsü
import { PLAYER_COLORS } from '../game/constants';
import type { GameState } from '../game/types';
import { LogoMark } from './LogoMark';
import { UserMenu } from './UserMenu';

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

      {/* min-w-0: flex öğesi doğal içerik genişliğinin altına küçülemiyor
          olması varsayılan flexbox davranışı — bu olmadan, 4 oyunculu +
          uzun bir oyuncu adı + Giriş butonu aynı anda dar bir ekrana
          sığmadığında bu şerit header'ı sağa doğru taşırırdı. overflow-x
          + no-scrollbar: sığmazsa (nadir durum) header 2. satıra taşıp
          kutu boylarını bozmak yerine şerit görünmez biçimde yatay
          kaydırılır — kutu boyutları/header yüksekliği hep sabit kalır.
          justify-end KULLANMA: taşan bir flex konteynerde justify-content:
          flex-end, taşan içeriği scrollWidth'e hiç yansımayan, kaydırarak
          bile ulaşılamayan bir şekilde kırpıyor (test edilip doğrulandı —
          çocuklar konteynerin 201px genişliğine karşı 15-308px aralığına
          yayılıyor ama scrollWidth yine de 201 dönüyor). justify-start
          (varsayılan) ile taşma her zaman erişilebilir kalıyor. */}
      <div className="flex gap-2 items-center min-w-0 overflow-x-auto no-scrollbar">
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
              className="shrink-0 shadow-raised text-center rounded-md px-2 py-0.5 transition-all"
              style={{
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
                className="text-[8px] uppercase tracking-[1px] font-mono truncate max-w-[72px]"
                style={{
                  color: col.base,
                  textDecoration: p.surrendered ? 'line-through' : 'none',
                }}
              >
                {p.surrendered ? 'Teslim' : label}
              </div>
              <div className="font-mono text-lg font-bold leading-none" style={{ color: col.base }}>
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
