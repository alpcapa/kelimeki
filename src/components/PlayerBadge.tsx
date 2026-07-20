// Kelimeki — Setup'taki oyuncu sıra numarası karesiyle aynı: renkli kare + beyaz numara.
import { PLAYER_COLORS } from '../game/constants';

interface PlayerBadgeProps {
  /** 0 tabanlı sıra/koltuk indeksi — karede gösterilen numara (index+1) budur. */
  index: number;
  /** Renk kaynağı farklıysa (ör. Player.colorIndex) ayrıca verilebilir; yoksa index kullanılır. */
  colorIndex?: number;
  size?: number;
  className?: string;
}

export function PlayerBadge({ index, colorIndex, size = 16, className = '' }: PlayerBadgeProps) {
  const col = PLAYER_COLORS[(colorIndex ?? index) % PLAYER_COLORS.length];
  return (
    <span
      className={`rounded-sm shrink-0 flex items-center justify-center font-bold text-white ${className}`}
      style={{ background: col.base, width: size, height: size, fontSize: Math.round(size * 0.55) }}
    >
      {index + 1}
    </span>
  );
}
