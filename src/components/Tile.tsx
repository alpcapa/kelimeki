// Harfik — tek harf bileşeni (rafta ya da tahtada)
import type { PlayerColor } from '../game/constants';
import type { Tile as TileModel } from '../game/types';
import { tileLetter } from '../utils/board';

export type TileVariant = 'rack' | 'placed' | 'board';

interface TileProps {
  tile: TileModel;
  variant: TileVariant;
  /** Tahta/yerleştirme taşları için sahibinin rengi. */
  color?: PlayerColor;
  selected?: boolean;
  /** En son oynanan hamlenin parçası mı — kabartma + ince halka ile vurgulanır. */
  lastMove?: boolean;
  onClick?: () => void;
}

export function Tile({ tile, variant, color, selected = false, lastMove = false, onClick }: TileProps) {
  const isRack = variant === 'rack';
  const raw = tileLetter(tile) || tile.letter;
  // Tahtaya konmuş joker (harfi seçilmiş olsa da) puan yerine yıldız gösterir;
  // rafta duran joker taşı puan köşesinde 0'ı korur.
  const isPlacedJoker = !isRack && tile.wild;
  // Joker (?) rafta yıldız olarak görünür; oynanınca seçilen harfe döner.
  const display = raw === '?' ? '★' : raw;

  // Renkli varyantlarda (tahta/yerleştirme) sahibinin paleti; rafta altın nömorfik.
  const style: React.CSSProperties = color
    ? {
        background: color.tint,
        border: `1px solid ${color.base}`,
        color: color.text,
      }
    : isRack
    ? {
        background: 'linear-gradient(150deg, #FFF0A0 0%, #FFD800 60%, #F0C000 100%)',
        boxShadow: '4px 4px 10px rgba(163,130,0,0.55), -2px -2px 6px rgba(255,250,200,0.8), 0 6px 14px rgba(163,130,0,0.35)',
        color: '#5A3800',
      }
    : {};

  const sizeClass = isRack
    ? 'w-full h-full rounded-[10px] active:scale-105'
    : variant === 'placed'
      ? 'w-full h-full rounded-[5px] animate-tile-pulse'
      : 'w-full h-full rounded-[5px]';

  return (
    <div
      onClick={onClick}
      style={style}
      className={[
        'relative flex items-center justify-center select-none transition-transform',
        'cursor-pointer flex-shrink-0',
        sizeClass,
        selected
          ? '!-translate-y-[7px] shadow-[0_8px_20px_rgba(163,130,0,0.6)]'
          : '',
        lastMove && variant === 'board'
          ? '!-translate-y-[2px] shadow-[0_0_0_2px_#38BDF8,0_5px_10px_rgba(15,23,42,0.35)]'
          : '',
      ].join(' ')}
    >
      {/* Harf — büyük ve kalın (Nunito 800 + ince kontur). */}
      <span
        style={{ WebkitTextStrokeWidth: isRack ? '0.7px' : '0.35px' }}
        className={[
          'font-tile font-extrabold leading-none [-webkit-text-stroke-color:currentColor]',
          isRack ? 'text-[24px]' : 'text-[clamp(14px,3.8vw,24px)] text-tile-letter',
        ].join(' ')}
      >
        {display}
      </span>
      {/* Puan — harfin sağ üstünde üst simge gibi. Tahtadaki joker 0 puan yerine minik yıldız gösterir. */}
      <span
        className={[
          'absolute font-mono font-bold leading-none',
          isRack
            ? 'top-[3px] right-[4px] text-[10px] text-[#8B5E00]'
            : 'top-[1px] right-[1.5px] text-[clamp(6px,1.6vw,10px)] text-accent',
        ].join(' ')}
      >
        {isPlacedJoker ? '★' : tile.pts}
      </span>
    </div>
  );
}
