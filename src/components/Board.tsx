// Harfik — 13x13 oyun tahtası (çok oyunculu, renkli bölgeler)
import {
  BONUS_LABELS,
  CORNER,
  PLAYER_COLORS,
  SIZE,
  regionOf,
  type PlayerColor,
} from '../game/constants';
import type { GameState, MoveStatus } from '../game/types';
import { key } from '../utils/board';
import { Tile } from './Tile';

interface BoardProps {
  state: GameState;
  onCellClick: (r: number, c: number) => void;
  /** Oyna'ya basmadan önceki anlık geçerlilik/puan çerçevesi; taş yoksa null. */
  moveStatus: MoveStatus | null;
  /** "Hamle Geçmişi" linkine tıklanınca çağrılır. */
  onOpenHistory: () => void;
}

// Nömorfik bonus kareleri: sadece yazı rengi (arkaplan style ile verilir).
const BONUS_CLASSES: Record<string, string> = {
  dw: 'text-[#0D6B28]',
  tw: 'text-[#8B4200]',
  dl: 'text-[#0A3A90]',
  tl: 'text-[#4A1A90]',
};

// Nömorfik bonus kareleri inline stilleri.
const BONUS_STYLES: Record<string, React.CSSProperties> = {
  dw: {
    background: 'linear-gradient(135deg, #B8ECC8, #C8F0D4)',
    boxShadow: 'inset 2px 2px 5px rgba(100,180,120,0.3), inset -1px -1px 3px rgba(255,255,255,0.8), 0 2px 4px rgba(100,180,120,0.2)',
  },
  tw: {
    background: 'linear-gradient(135deg, #FAC890, #FBD8A8)',
    boxShadow: 'inset 2px 2px 5px rgba(200,120,40,0.25), inset -1px -1px 3px rgba(255,255,255,0.8), 0 2px 4px rgba(200,120,40,0.15)',
  },
  dl: {
    background: 'linear-gradient(135deg, #9EC8FA, #B0D4FC)',
    boxShadow: 'inset 2px 2px 5px rgba(40,100,200,0.25), inset -1px -1px 3px rgba(255,255,255,0.8), 0 2px 4px rgba(40,100,200,0.15)',
  },
  tl: {
    background: 'linear-gradient(135deg, #CEB4FA, #DCC8FC)',
    boxShadow: 'inset 2px 2px 5px rgba(120,60,220,0.25), inset -1px -1px 3px rgba(255,255,255,0.8), 0 2px 4px rgba(120,60,220,0.15)',
  },
};

// Tahtanın hemen altında gösterilen bonus açıklaması.
const LEGEND = [
  { label: 'K2', desc: 'kelime x2', bg: 'linear-gradient(135deg, #B8ECC8, #C8F0D4)', border: 'none' },
  { label: 'K3', desc: 'kelime x3', bg: 'linear-gradient(135deg, #FAC890, #FBD8A8)', border: 'none' },
  { label: 'H2', desc: 'harf x2',   bg: 'linear-gradient(135deg, #9EC8FA, #B0D4FC)', border: 'none' },
  { label: 'H3', desc: 'harf x3',   bg: 'linear-gradient(135deg, #CEB4FA, #DCC8FC)', border: 'none' },
];

/** Her köşenin merkeze bakan 2 iç kenarına (L şeklinde) renk çizgisi ekler. */
function cornerEdgeStyle(
  r: number,
  c: number,
  cornerColors: (PlayerColor | undefined)[],
): React.CSSProperties {
  const s: React.CSSProperties = {};
  const border = (color: string) => `2px solid ${color}`;

  // Köşe 0: sol-üst (0–4, 0–4) → alt ve sağ kenar
  if (r < CORNER && c < CORNER && cornerColors[0]) {
    if (r === CORNER - 1) s.borderBottom = border(cornerColors[0].base);
    if (c === CORNER - 1) s.borderRight = border(cornerColors[0].base);
  }
  // Köşe 1: sağ-üst (0–4, 8–12) → alt ve sol kenar
  if (r < CORNER && c >= SIZE - CORNER && cornerColors[1]) {
    if (r === CORNER - 1) s.borderBottom = border(cornerColors[1].base);
    if (c === SIZE - CORNER) s.borderLeft = border(cornerColors[1].base);
  }
  // Köşe 2: sol-alt (8–12, 0–4) → üst ve sağ kenar
  if (r >= SIZE - CORNER && c < CORNER && cornerColors[2]) {
    if (r === SIZE - CORNER) s.borderTop = border(cornerColors[2].base);
    if (c === CORNER - 1) s.borderRight = border(cornerColors[2].base);
  }
  // Köşe 3: sağ-alt (8–12, 8–12) → üst ve sol kenar
  if (r >= SIZE - CORNER && c >= SIZE - CORNER && cornerColors[3]) {
    if (r === SIZE - CORNER) s.borderTop = border(cornerColors[3].base);
    if (c === SIZE - CORNER) s.borderLeft = border(cornerColors[3].base);
  }
  return s;
}

export function Board({ state, onCellClick, moveStatus, onOpenHistory }: BoardProps) {
  const { board, placed, bonuses, lastWords, players, current } = state;

  // Köşe bölgesi -> o köşenin sahibinin rengi (boş kareleri renklendirmek için).
  const cornerColor: (PlayerColor | undefined)[] = [
    undefined,
    undefined,
    undefined,
    undefined,
  ];
  for (const p of players) cornerColor[p.corner] = PLAYER_COLORS[p.colorIndex];

  // Köşe bölgesi -> o köşedeki oyuncunun numarası (1, 2, …) — soluk filigran.
  const cornerNumber: (number | undefined)[] = [
    undefined,
    undefined,
    undefined,
    undefined,
  ];
  players.forEach((p, i) => (cornerNumber[p.corner] = i + 1));

  // 5×5 köşenin tahtaya oranı (kenar uzunluğu).
  const cornerFrac = `${(CORNER / SIZE) * 100}%`;

  const colorOf = (owner: number | undefined): PlayerColor | undefined =>
    owner === undefined ? undefined : PLAYER_COLORS[players[owner]?.colorIndex ?? 0];

  const currentColor = PLAYER_COLORS[players[current]?.colorIndex ?? 0];

  const cells = [];

  for (let r = 0; r < SIZE; r++) {
    for (let c = 0; c < SIZE; c++) {
      const k = key(r, c);
      const boardTile = board[r][c];
      const placedTile = placed[k];
      const bonus = bonuses[k];
      const region = regionOf(r, c);
      const zone = region >= 0 ? cornerColor[region] : undefined;

      let content: React.ReactNode = null;
      let style: React.CSSProperties | undefined;
      const classes = [
        'min-w-0 min-h-0 rounded-[5px] flex items-center justify-center',
        'font-mono font-bold text-[clamp(5px,1.4vw,8px)] select-none',
        'transition-[background,box-shadow,opacity] duration-300',
      ];

      const isLastWord = !!lastWords[k];

      if (boardTile) {
        classes.push(
          isLastWord
            ? 'bg-transparent cursor-pointer rounded-[5px] ring-2 ring-gold/60'
            : 'bg-transparent cursor-default',
        );
        content = <Tile tile={boardTile} variant="board" color={colorOf(boardTile.owner)} />;
      } else if (placedTile) {
        classes.push('bg-transparent');
        content = <Tile tile={placedTile} variant="placed" color={currentColor} />;
      } else if (bonus) {
        classes.push(BONUS_CLASSES[bonus], 'cursor-pointer', 'text-[clamp(7px,1.9vw,12px)]');
        content = BONUS_LABELS[bonus];
        style = { ...BONUS_STYLES[bonus] };
        if (zone) style = { ...style, outline: `1.5px solid ${zone.base}44` };
      } else if (zone) {
        // Bir oyuncunun köşesindeki boş kare: nömorfik içe gömülü + oyuncu tonu.
        classes.push('cursor-pointer');
        style = {
          background: zone.tint,
          boxShadow: `inset 2px 2px 5px ${zone.base}22, inset -1px -1px 3px rgba(255,255,255,0.6)`,
        };
      } else {
        // Merkez (tarafsız) boş kare: nömorfik içe gömülü.
        classes.push('bg-[#DDE4EE] cursor-pointer');
        style = { boxShadow: 'inset 3px 3px 6px rgba(163,177,198,0.6), inset -2px -2px 5px rgba(255,255,255,0.8)' };
      }

      const edgeBorder = cornerEdgeStyle(r, c, cornerColor);
      if (Object.keys(edgeBorder).length > 0) {
        style = style ? { ...style, ...edgeBorder } : edgeBorder;
      }

      cells.push(
        <div
          key={k}
          className={classes.join(' ')}
          style={{ ...style, gridRow: `${r + 1} / ${r + 2}`, gridColumn: `${c + 1} / ${c + 2}` }}
          onClick={() => onCellClick(r, c)}
        >
          {content}
        </div>,
      );
    }
  }

  // Oyna'ya basmadan önce anlık geçerlilik çerçevesi: oluşan tüm kelimelerin
  // hücrelerini kapsayan TEK bir dış hat çizilir (iç kesişim hücrelerinde
  // ayırıcı çizgi olmaz) — her hücrenin yalnızca kümenin dışına bakan
  // kenarlarına çizgi eklenir.
  const moveOutline: React.ReactNode[] = [];
  if (moveStatus) {
    // Kesişim hücreleri (hem ana hem çapraz kelimede) birden fazla kez
    // geçebilir — tekilleştir, aksi halde aynı hücreye iki kez çerçeve çizilir.
    const uniqueCells = [...new Map(moveStatus.cells.map(([r, c]) => [key(r, c), [r, c] as [number, number]])).values()];
    const cellSet = new Set(uniqueCells.map(([r, c]) => key(r, c)));
    const color = moveStatus.valid ? '#1FA05C' : '#E0483A';
    let badge: [number, number] | null = null;
    for (const [r, c] of uniqueCells) {
      if (!badge || r < badge[0] || (r === badge[0] && c > badge[1])) badge = [r, c];
    }
    for (const [r, c] of uniqueCells) {
      const top = cellSet.has(key(r - 1, c));
      const bottom = cellSet.has(key(r + 1, c));
      const left = cellSet.has(key(r, c - 1));
      const right = cellSet.has(key(r, c + 1));
      const side = (occupied: boolean) => (occupied ? 'none' : `2.5px solid ${color}`);
      const radius = (a: boolean, b: boolean) => (!a && !b ? '5px' : '0');
      moveOutline.push(
        <div
          key={`${r},${c}`}
          className="pointer-events-none z-10"
          style={{
            gridRow: `${r + 1} / ${r + 2}`,
            gridColumn: `${c + 1} / ${c + 2}`,
            borderTop: side(top),
            borderBottom: side(bottom),
            borderLeft: side(left),
            borderRight: side(right),
            borderTopLeftRadius: radius(top, left),
            borderTopRightRadius: radius(top, right),
            borderBottomLeftRadius: radius(bottom, left),
            borderBottomRightRadius: radius(bottom, right),
            position: 'relative',
          }}
        >
          {badge && badge[0] === r && badge[1] === c && (
            <span
              className="absolute -top-[9px] -right-[9px] flex items-center justify-center rounded-full font-mono font-bold text-white leading-none whitespace-nowrap"
              style={{
                background: color,
                fontSize: 'clamp(8px,2vw,11px)',
                padding: '3px 6px',
                boxShadow: '0 2px 5px rgba(0,0,0,0.25)',
              }}
            >
              +{moveStatus.score}
            </span>
          )}
        </div>,
      );
    }
  }

  return (
    <div className="w-full max-w-[680px] mx-auto px-3 pt-2 pb-3 flex flex-col items-center">
      <div
        className="relative grid gap-[3px] bg-[#DDE4EE] rounded-[18px] p-[10px] w-full aspect-square"
        style={{
          gridTemplateColumns: `repeat(${SIZE}, 1fr)`,
          gridTemplateRows: `repeat(${SIZE}, 1fr)`,
          boxShadow: '8px 8px 20px rgba(163,177,198,0.7), -4px -4px 14px rgba(255,255,255,0.9), 0 20px 60px rgba(163,177,198,0.5)',
        }}
      >
        {cells}

        {/* Oyna'ya basmadan önce anlık geçerlilik çerçevesi (yeşil/kırmızı) + puan:
            tüm kelimelerin hücrelerini kapsayan tek dış hat, iç kesişimde çizgi yok. */}
        {moveOutline}

        {/* Her oyuncunun 5×5 köşesine soluk numara filigranı. */}
        <div className="pointer-events-none absolute inset-1">
          {[0, 1, 2, 3].map((i) => {
            const col = cornerColor[i];
            const num = cornerNumber[i];
            if (!col || !num) return null;
            const top = i === 0 || i === 1;
            const left = i === 0 || i === 2;
            return (
              <div
                key={i}
                className="absolute flex items-center justify-center font-mono font-bold leading-none"
                style={{
                  width: cornerFrac,
                  height: cornerFrac,
                  top: top ? 0 : 'auto',
                  bottom: top ? 'auto' : 0,
                  left: left ? 0 : 'auto',
                  right: left ? 'auto' : 0,
                  color: col.base,
                  opacity: 0.20,
                  fontSize: 'clamp(80px, 32vw, 220px)',
                }}
              >
                {num}
              </div>
            );
          })}
        </div>
      </div>

      <div className="flex items-center justify-between gap-2 shrink-0 pt-1 w-full">
        <button
          onClick={onOpenHistory}
          className="text-[9px] font-mono font-bold uppercase tracking-[0.5px] text-accent underline underline-offset-2 shrink-0"
        >
          Hamle Geçmişi
        </button>
        <div className="flex gap-2 justify-end flex-wrap">
          {LEGEND.map((item) => (
            <div
              key={item.label}
              className="text-[8px] font-mono flex items-center gap-[3px] text-muted"
            >
              <span
                className="w-2 h-2 rounded-[1px]"
                style={{ background: item.bg, border: item.border }}
              />
              <span className="font-bold">{item.label}</span>
              <span className="text-muted/70">{item.desc}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
