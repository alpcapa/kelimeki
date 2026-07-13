// Harfik — 13x13 oyun tahtası (çok oyunculu, renkli bölgeler)
import {
  BOARD_CENTER,
  BONUS_LABELS,
  BONUS_ZONE,
  CORNER,
  PLAYER_COLORS,
  SIZE,
  cornerCell,
  inBonusZone,
  type PlayerColor,
} from '../game/constants';
import type { GameState, MoveStatus } from '../game/types';
import { key } from '../utils/board';
import { computeAllTerritories } from '../utils/validator';
import { Tile } from './Tile';

interface BoardProps {
  state: GameState;
  onCellClick: (r: number, c: number) => void;
  /** Oyna'ya basmadan önceki anlık geçerlilik/puan çerçevesi; taş yoksa null. */
  moveStatus: MoveStatus | null;
  /** "Oyun Geçmişi" linkine tıklanınca çağrılır. */
  onOpenHistory: () => void;
  /** Şu an sürüklenmekte olan, bu tur yerleştirilmiş taşın hücre anahtarı — o hücre boşmuş gibi çizilir. */
  dragHiddenKey?: string | null;
  /** Sürükleme sırasında işaretçinin üzerinde olduğu hücre (bırakma hedefi vurgusu). */
  dragOverKey?: string | null;
  /** `dragOverKey` hücresine bırakmak geçerli mi? */
  dragOverValid?: boolean;
  /** Bu tur yerleştirilmiş bir taşın sürüklenmesini başlatır. */
  onTilePointerDown?: (r: number, c: number, e: React.PointerEvent<HTMLDivElement>) => void;
  onTilePointerMove?: (e: React.PointerEvent<HTMLDivElement>) => void;
  onTilePointerUp?: (e: React.PointerEvent<HTMLDivElement>) => void;
  onTilePointerCancel?: (e: React.PointerEvent<HTMLDivElement>) => void;
}

// Merkezdeki x2 bonus bölgesi altın rengi — nömorfik, diğer köşe tonlarıyla
// karışmasın diye sıcak/altın. Tam ortadaki tek X3 hücresi turuncu bir zeminle
// öne çıkar.
const GOLD_ZONE_STYLE: React.CSSProperties = {
  background: 'linear-gradient(135deg, #FDE68A, #FBBF24)',
  boxShadow: 'inset 2px 2px 5px rgba(180,130,10,0.3), inset -1px -1px 3px rgba(255,255,255,0.7), 0 2px 4px rgba(180,130,10,0.2)',
};
const CENTER_ZONE_STYLE: React.CSSProperties = {
  background: 'linear-gradient(135deg, #FDBA74, #F97316)',
  boxShadow: 'inset 2px 2px 5px rgba(180,80,10,0.35), inset -1px -1px 3px rgba(255,255,255,0.7), 0 2px 4px rgba(180,80,10,0.25)',
};
const CENTER_TEXT = 'text-[#7C2D12]';

// Tahtanın hemen altında gösterilen bonus açıklaması.
const LEGEND = [
  { label: 'X2', desc: '- kelime X2', bg: 'linear-gradient(135deg, #FDE68A, #FBBF24)', border: 'none' },
  { label: 'X3', desc: '- kelime X3', bg: 'linear-gradient(135deg, #FDBA74, #F97316)', border: 'none' },
];

/** Bir oyuncunun ilk hamlesinde mutlaka değmesi gereken köşe hücresindeki ev işareti. */
function HomeMark({ color }: { color: PlayerColor }) {
  return (
    <svg
      viewBox="0 0 24 24"
      className="w-[55%] h-[55%]"
      style={{ opacity: 0.85 }}
      fill={color.base}
    >
      <path d="M12 2.5 1.5 11h3V21h6v-6h3v6h6V11h3L12 2.5Z" />
    </svg>
  );
}

export function Board({
  state,
  onCellClick,
  moveStatus,
  onOpenHistory,
  dragHiddenKey = null,
  dragOverKey = null,
  dragOverValid = false,
  onTilePointerDown,
  onTilePointerMove,
  onTilePointerUp,
  onTilePointerCancel,
}: BoardProps) {
  const { board, placed, bonuses, lastWords, players, current } = state;

  // Köşe bölgesi -> o köşenin sahibinin rengi (boş kareleri renklendirmek için).
  const cornerColor: (PlayerColor | undefined)[] = [
    undefined,
    undefined,
    undefined,
    undefined,
  ];
  for (const p of players) {
    for (const corner of p.corners) cornerColor[corner] = PLAYER_COLORS[p.colorIndex];
  }

  // Köşe bölgesi -> o köşedeki oyuncunun numarası (1, 2, …) — soluk filigran.
  const cornerNumber: (number | undefined)[] = [
    undefined,
    undefined,
    undefined,
    undefined,
  ];
  players.forEach((p, i) => {
    for (const corner of p.corners) cornerNumber[corner] = i + 1;
  });

  // Köşe bölgesinin tahtaya oranı (kenar uzunluğu).
  const cornerFrac = `${(CORNER / SIZE) * 100}%`;

  // Merkezdeki x2 bonus bölgesinin tahtaya oranı ve konumu — köşe numarası
  // filigranıyla aynı mantıkla, tek büyük bir "X2" o bölgenin arkasına yazılır.
  const zoneSize = BONUS_ZONE.r1 - BONUS_ZONE.r0 + 1;
  const zoneFrac = `${(zoneSize / SIZE) * 100}%`;
  const zoneTop = `${(BONUS_ZONE.r0 / SIZE) * 100}%`;
  const zoneLeft = `${(BONUS_ZONE.c0 / SIZE) * 100}%`;

  // Köşenin tam ucundaki tek başlangıç hücresi -> o köşenin sahibinin rengi.
  // İlk hamle bu hücreye değmek zorunda olduğundan burada bir "ev" işareti
  // gösterilir.
  const homeCellColor = new Map<string, PlayerColor>();
  players.forEach((p) => {
    for (const corner of p.corners) {
      const [hr, hc] = cornerCell(corner);
      homeCellColor.set(key(hr, hc), PLAYER_COLORS[p.colorIndex]);
    }
  });

  const colorOf = (owner: number | undefined): PlayerColor | undefined =>
    owner === undefined ? undefined : PLAYER_COLORS[players[owner]?.colorIndex ?? 0];

  const currentColor = PLAYER_COLORS[players[current]?.colorIndex ?? 0];

  // En son oynanan hamlenin hücreleri — kabartma + ince halka ile vurgulanır.
  const lastMoveSet = new Set(state.lastMoveCells.map(([r, c]) => key(r, c)));

  // Her oyuncunun bölgesi: kendi köşesi + oradan kendi taşlarıyla genişleyen
  // alan. Sabit 4×4 köşenin aksine hamle oynandıkça büyür.
  const territories = computeAllTerritories(board, players);
  const territoryOwnerAt = (r: number, c: number): number => {
    const k = key(r, c);
    for (let i = 0; i < territories.length; i++) {
      if (territories[i].has(k)) return i;
    }
    return -1;
  };

  const cells = [];

  for (let r = 0; r < SIZE; r++) {
    for (let c = 0; c < SIZE; c++) {
      const k = key(r, c);
      const boardTile = board[r][c];
      const rawPlacedTile = placed[k];
      // Sürüklenmekte olan taş, alındığı hücrede boşmuş gibi çizilir (görsel olarak).
      const placedTile = k === dragHiddenKey ? undefined : rawPlacedTile;
      const bonus = bonuses[k];
      const inZone = inBonusZone(r, c);
      const territoryOwner = territoryOwnerAt(r, c);
      const zone = territoryOwner >= 0 ? PLAYER_COLORS[players[territoryOwner]?.colorIndex ?? 0] : undefined;
      const homeColor = homeCellColor.get(k);

      let content: React.ReactNode = null;
      let style: React.CSSProperties | undefined;
      const classes = [
        'min-w-0 min-h-0 rounded-[5px] flex items-center justify-center',
        'font-mono font-bold text-[clamp(5px,1.4vw,8px)] select-none',
        'transition-[background,box-shadow,opacity] duration-300',
      ];

      const isLastWord = !!lastWords[k];

      if (boardTile) {
        classes.push(isLastWord ? 'bg-transparent cursor-pointer' : 'bg-transparent cursor-default');
        content = (
          <Tile
            tile={boardTile}
            variant="board"
            color={colorOf(boardTile.owner)}
            lastMove={lastMoveSet.has(k)}
          />
        );
      } else if (placedTile) {
        classes.push('bg-transparent');
        content = <Tile tile={placedTile} variant="placed" color={currentColor} />;
      } else if (inZone) {
        // Merkezdeki x2 bonus bölgesi — altın zemin, büyük "X2" filigranı
        // bölgenin tamamının arkasına yazılır (aşağıda). Tam ortadaki tek
        // hücre bunun dışında, turuncu zemin + kendi X3 etiketiyle öne çıkar.
        classes.push('cursor-pointer');
        style = bonus ? { ...CENTER_ZONE_STYLE } : { ...GOLD_ZONE_STYLE };
        if (bonus) {
          classes.push(CENTER_TEXT, 'text-[clamp(7px,1.9vw,12px)]');
          content = BONUS_LABELS[bonus];
        }
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

      if (homeColor && !boardTile && !placedTile) {
        // Oyuncunun mutlaka değmesi gereken başlangıç köşesi: ev işareti.
        content = <HomeMark color={homeColor} />;
      }

      // Bu turda yerleştirilmiş (henüz oynanmamış) bir taş, tıklama yerine
      // sürükleme jestiyle (basılı tut → hareket ettir → bırak) yönetilir.
      const hasPending = !!rawPlacedTile;

      if (dragOverKey === k) {
        style = {
          ...style,
          outline: `2px dashed ${dragOverValid ? '#1FA05C' : '#E0483A'}`,
          outlineOffset: '-2px',
        };
      }

      cells.push(
        <div
          key={k}
          className={classes.join(' ')}
          style={{
            ...style,
            gridRow: `${r + 1} / ${r + 2}`,
            gridColumn: `${c + 1} / ${c + 2}`,
            ...(hasPending ? { touchAction: 'none' } : null),
          }}
          data-cell={`${r},${c}`}
          onClick={hasPending ? undefined : () => onCellClick(r, c)}
          onPointerDown={hasPending ? (e) => onTilePointerDown?.(r, c, e) : undefined}
          onPointerMove={hasPending ? onTilePointerMove : undefined}
          onPointerUp={hasPending ? onTilePointerUp : undefined}
          onPointerCancel={hasPending ? onTilePointerCancel : undefined}
        >
          {content}
        </div>,
      );
    }
  }

  // Bir mazgal (sur dişi) kenar şeridinin arka planı: iki kısa diş, kenarın
  // ortasında küçük bir boşlukla ayrılmış, iki ucunda da eşit boşlukla —
  // her hücrede tam olarak aynı konumda, simetrik (boşluk/diş/boşluk/diş/
  // boşluk). Tek uzun ortalanmış diş, iki hücre birleştiğinde tek bir kalın
  // kütle gibi durup istenen "kale mazgalı" hissini vermiyordu; ortadaki
  // kısa boşluk her dişi kendi mazgal parçası gibi ayırıyor. Kenarın ucuna
  // yaslı bir diş de köşelerde bir tarafa yakın, diğer tarafa uzak kalıp
  // köşe dolgusunu diş deseninden kopuk, izole bir nokta gibi gösteriyordu;
  // simetrik desen bu asimetriyi de ortadan kaldırır. Kalınlık düz çizgiyle
  // hemen hemen aynı. Her hücre bu deseni kendi genişliğinde baştan
  // çizdiğinden (tek periyot = bir hücre), bitişik hücrelerin şeritleri ek
  // hizalama gerekmeden kesintisiz birleşir. Tam piksel (3px, 2.5px değil)
  // kullanılır: kesirli yükseklik, şeridin `top:0` mı `bottom:0`'a mı
  // sabitlendiğine göre farklı yuvarlanıp dış (üst/sol) ve iç (alt/sağ,
  // genişleyen) kenarları görünürde asimetrik kalınlıkta gösteriyordu.
  const CRENEL_THICKNESS = '3px';
  const crenelGradient = (color: string, axis: 'to right' | 'to bottom') =>
    `linear-gradient(${axis}, transparent 0 18%, ${color} 18% 46%, transparent 46% 54%, ${color} 54% 82%, transparent 82% 100%)`;

  // Verilen hücre kümesini kapsayan TEK bir dış hat üretir (iç kesişim
  // hücrelerinde ayırıcı çizgi olmaz) — her hücrenin yalnızca kümenin
  // dışına bakan kenarlarına çizgi eklenir. `badgeScore` verilirse en üst
  // sağdaki hücrenin köşesine puan rozeti eklenir. `extraOpen`, kümenin
  // dışına bakan bir kenarı da "kapalı" (çizgisiz) sayabilmek için — bonus
  // bölgesi/merkez çerçevesi, bir oyuncunun bölgesinin İÇİNDEN geçen kendi
  // kenarını bu şekilde bastırır, böylece oyuncunun genişleyen bölgesi
  // içinde gereksiz bir amber çizgi kalmaz. `crenellated` verilirse düz
  // çizgi yerine kale suru gibi dişli bir kenar çizilir (bölge sınırı için).
  const buildOutline = (
    cellsList: [number, number][],
    color: string,
    keyPrefix: string,
    options: {
      badgeScore?: number;
      extraOpen?: (r: number, c: number, nr: number, nc: number) => boolean;
      crenellated?: boolean;
    } = {},
  ): React.ReactNode[] => {
    const { badgeScore, extraOpen, crenellated } = options;
    const uniqueCells = [...new Map(cellsList.map(([r, c]) => [key(r, c), [r, c] as [number, number]])).values()];
    const cellSet = new Set(uniqueCells.map(([r, c]) => key(r, c)));
    // Rozet en üst-soldaki hücreye konur (tahtaya konan taşın kendi puan
    // üst simgesiyle çakışmaması için sağ üst yerine sol üst köşede).
    let badge: [number, number] | null = null;
    if (badgeScore !== undefined) {
      for (const [r, c] of uniqueCells) {
        if (!badge || r < badge[0] || (r === badge[0] && c < badge[1])) badge = [r, c];
      }
    }
    return uniqueCells.map(([r, c]) => {
      const isOpen = (nr: number, nc: number) =>
        cellSet.has(key(nr, nc)) || (extraOpen ? extraOpen(r, c, nr, nc) : false);
      const top = isOpen(r - 1, c);
      const bottom = isOpen(r + 1, c);
      const left = isOpen(r, c - 1);
      const right = isOpen(r, c + 1);

      if (crenellated) {
        // Diş deseni her kenarın uçlarında boşluk bırakır (gap-çizgi-gap-
        // çizgi-gap); çizilen her kenarın iki ucuna da küçük bir dolgu kare
        // ("nokta") eklenir — hem 90°'lik gerçek dönüş köşelerinde hem de
        // düz bir kenarın hücreden hücreye geçtiği ara noktalarda. Böylece
        // tüm sınır boyunca nokta-çizgi-nokta-çizgi deseni tutarlı kalır.
        const cap = (vert: 'top' | 'bottom', horiz: 'left' | 'right') => (
          <div
            key={`cap-${vert}-${horiz}`}
            className="absolute"
            style={{
              [vert]: 0,
              [horiz]: 0,
              width: CRENEL_THICKNESS,
              height: CRENEL_THICKNESS,
              background: color,
            }}
          />
        );
        return (
          <div
            key={`${keyPrefix}-${r},${c}`}
            className="pointer-events-none z-10"
            style={{ gridRow: `${r + 1} / ${r + 2}`, gridColumn: `${c + 1} / ${c + 2}`, position: 'relative' }}
          >
            {!top && (
              <div className="absolute inset-x-0 top-0" style={{ height: CRENEL_THICKNESS, background: crenelGradient(color, 'to right') }} />
            )}
            {!bottom && (
              <div className="absolute inset-x-0 bottom-0" style={{ height: CRENEL_THICKNESS, background: crenelGradient(color, 'to right') }} />
            )}
            {!left && (
              <div className="absolute inset-y-0 left-0" style={{ width: CRENEL_THICKNESS, background: crenelGradient(color, 'to bottom') }} />
            )}
            {!right && (
              <div className="absolute inset-y-0 right-0" style={{ width: CRENEL_THICKNESS, background: crenelGradient(color, 'to bottom') }} />
            )}
            {(!top || !left) && cap('top', 'left')}
            {(!top || !right) && cap('top', 'right')}
            {(!bottom || !left) && cap('bottom', 'left')}
            {(!bottom || !right) && cap('bottom', 'right')}
          </div>
        );
      }

      const side = (occupied: boolean) => (occupied ? 'none' : `2.5px solid ${color}`);
      const radius = (a: boolean, b: boolean) => (!a && !b ? '5px' : '0');
      return (
        <div
          key={`${keyPrefix}-${r},${c}`}
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
              className="absolute -top-[9px] -left-[9px] flex items-center justify-center rounded-full font-mono font-bold text-white leading-none whitespace-nowrap"
              style={{
                background: color,
                fontSize: 'clamp(8px,2vw,11px)',
                padding: '3px 6px',
                boxShadow: '0 2px 5px rgba(0,0,0,0.25)',
              }}
            >
              +{badgeScore}
            </span>
          )}
        </div>
      );
    });
  };

  // Her oyuncunun bölgesinin dış hattı — köşeden taşlarla genişledikçe
  // sınır da ona göre büyür.
  const territoryOutlines = players.flatMap((p, i) => {
    const territoryCells = [...territories[i]].map(
      (k) => k.split(',').map(Number) as [number, number],
    );
    return territoryCells.length > 0
      ? buildOutline(territoryCells, PLAYER_COLORS[p.colorIndex].base, `territory-${i}`, { crenellated: true })
      : [];
  });

  // Bir bonus-bölgesi kenarını, iki tarafı da AYNI oyuncunun bölgesine
  // aitse "açık" (çizgisiz) sayar — bir oyuncunun genişleyen bölgesi bonus
  // alanına girip devam ettiğinde, amber çerçeve o iç bağlantıyı kesmesin.
  const sameTerritoryOpen = (r: number, c: number, nr: number, nc: number) => {
    const owner = territoryOwnerAt(r, c);
    return owner >= 0 && owner === territoryOwnerAt(nr, nc);
  };

  // Merkezdeki x2 bonus bölgesinin tam dış hattı — altın/turuncu zeminle
  // uyumlu koyu amber bir çerçeve.
  const zoneCells: [number, number][] = [];
  for (let r = BONUS_ZONE.r0; r <= BONUS_ZONE.r1; r++) {
    for (let c = BONUS_ZONE.c0; c <= BONUS_ZONE.c1; c++) {
      zoneCells.push([r, c]);
    }
  }
  const zoneOutline = buildOutline(zoneCells, '#B45309', 'bonus-zone', { extraOpen: sameTerritoryOpen });

  // Tam ortadaki tek X3 hücresinin kendi çerçevesi — turuncu zeminle uyumlu.
  // Hücreye bir taş oynandıktan sonra (artık oyuncunun rengiyle çizildiğinden)
  // bu çerçeve kaldırılır.
  const centerOutline = board[BOARD_CENTER[0]][BOARD_CENTER[1]]
    ? []
    : buildOutline([BOARD_CENTER], '#9A3412', 'center-zone', { extraOpen: sameTerritoryOpen });

  // Oyna'ya basmadan önce anlık geçerlilik çerçevesi (yeşil/kırmızı) + puan.
  const moveOutline = moveStatus
    ? buildOutline(moveStatus.cells, moveStatus.valid ? '#1FA05C' : '#E0483A', 'move', { badgeScore: moveStatus.score })
    : [];

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

        {/* Merkezdeki x2 bonus bölgesinin dış hattı. */}
        {zoneOutline}

        {/* Tam ortadaki tek X3 hücresinin kendi çerçevesi. */}
        {centerOutline}

        {/* Her oyuncunun genişleyen bölgesinin dış hattı — bonus bölgesi
            çerçevesinin üzerinde çizilir, böylece bir oyuncunun bölgesi
            bonus alanına ilerlediğinde sınır kendi renginde kalır. */}
        {territoryOutlines}

        {/* Oyna'ya basmadan önce anlık geçerlilik çerçevesi (yeşil/kırmızı) + puan:
            tüm kelimelerin hücrelerini kapsayan tek dış hat, iç kesişimde çizgi yok. */}
        {moveOutline}

        {/* Her oyuncunun 4×4 köşesine soluk numara filigranı. */}
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

        {/* Merkezdeki x2 bonus bölgesinin arkasına yazılan büyük "X2" filigranı. */}
        <div className="pointer-events-none absolute inset-1">
          <div
            className="absolute flex items-center justify-center font-mono font-bold leading-none"
            style={{
              width: zoneFrac,
              height: zoneFrac,
              top: zoneTop,
              left: zoneLeft,
              color: '#92660A',
              opacity: 0.28,
              fontSize: 'clamp(60px, 24vw, 165px)',
            }}
          >
            X2
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between gap-2 shrink-0 pt-1 w-full">
        <button
          onClick={onOpenHistory}
          className="text-[9px] font-mono font-bold uppercase tracking-[0.5px] text-accent underline underline-offset-2 shrink-0"
        >
          Oyun Geçmişi
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
