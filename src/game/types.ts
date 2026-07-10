// Harfik — paylaşılan oyun tipleri

/** Bir taşı/hamleyi yapan oyuncunun indeksi (0..3). */
export type Owner = number;

/** Bonus kare türü: yalnızca tahtanın tam ortasındaki tek X3 (üç kat kelime) hücresi kullanır. */
export type BonusType = 'tw';

export interface Tile {
  /** Raftaki/torbadaki ham harf ('?' joker olabilir). */
  letter: string;
  pts: number;
  /** Joker mi? */
  wild?: boolean;
  /** Joker oynandığında seçilen harf. */
  wildLetter?: string;
  /** Tahtaya konduğunda sahibi (oyuncu indeksi). */
  owner?: Owner;
}

/** "r,c" biçiminde hücre anahtarı. */
export type CellKey = string;

export interface Placement {
  r: number;
  c: number;
  tile: Tile;
}

/** Yerel (aynı cihaz) oyuncu. */
export interface Player {
  name: string;
  /** Atanmış köşe bölgesi indeksleri (0..3) — 2 oyunculu oyunda iki köşe. */
  corners: number[];
  /** Renk paleti indeksi (PLAYER_COLORS). */
  colorIndex: number;
  /** Bu oyuncuyu yapay zekâ mı oynuyor? */
  isAI: boolean;
  rack: Tile[];
  score: number;
  /**
   * Bu oyundaki en yüksek tek hamle puanı (tek veya çok kelimeli, harf/kelime
   * çarpanları dahil) — köşe vergisi kesintisinden ÖNCEKİ brüt puan.
   */
  bestMoveScore: number;
  /** Bu oyundaki en yüksek tek kelime puanı (bir hamlede oluşan kelimelerin en yükseği). */
  bestWordScore: number;
  /** `bestWordScore` puanını üreten kelime. */
  bestWord: string;
  /** Bu oyunda oluşturulan en uzun kelime. */
  longestWord: string;
  /** Bu oyunda oynanan (geçilmemiş) hamle sayısı. */
  moveCount: number;
  /**
   * Bu oyunda oynanan hamlelerin brüt puanları toplamı (köşe vergisi ve raf
   * düşümü hariç) — "ortalama hamle puanı" istatistiği için.
   */
  moveScoreSum: number;
}

/** YZ'nin bulduğu hamle. */
export interface AIMove {
  word: string;
  score: number;
  placements: Placement[];
}

export interface GameState {
  /** 'setup' = oyuncu kurulum ekranı, 'play' = oyun sürüyor. */
  phase: 'setup' | 'play';
  /** SIZE x SIZE tahta; boş hücreler null. */
  board: (Tile | null)[][];
  /** Çekiliş torbası. */
  bag: Tile[];
  /** Bonus kareler: "r,c" -> BonusType. */
  bonuses: Record<CellKey, BonusType>;
  /** Bu turda aktif oyuncunun geçici yerleştirdiği taşlar. */
  placed: Record<CellKey, Tile>;
  /** Tüm oyuncular. */
  players: Player[];
  /** Sırası gelen oyuncunun indeksi. */
  current: number;
  /** Raftaki seçili taşın indeksi. */
  selectedTile: number | null;
  /** Taş değiştirme modunda mı? (Aktif oyuncu taşlarını değiştirmek istiyor.) */
  swapMode: boolean;
  /** Taş değiştirme modunda seçilen raf taşı indeksleri. */
  swapSelection: number[];
  turnCount: number;
  /** Tüm oyuncular tarafından üst üste atılan toplam pas sayısı. */
  consecutivePasses: number;
  isGameOver: boolean;
  /** Durum çubuğu mesajı. */
  message: string;
  messageType: '' | 'ok' | 'err' | 'warn';
  /**
   * Son kabul edilen hamlede oluşan kelimeler (hücre → kelime + oynayan).
   * Bu hücrelere tıklayınca kelimenin anlamı gösterilir.
   */
  lastWords: Record<CellKey, { word: string; by: Owner }>;
  /**
   * En son oynanan hamledeki tüm hücreler (tahtada nerede oynandığını sarı
   * çerçeveyle göstermek için) — bir sonraki hamlede değişir.
   */
  lastMoveCells: [number, number][];
  /** Oyun boyunca tüm oyuncuların hamle/puan geçmişi (en yeni sonda). */
  moveHistory: HistoryEntry[];
}

/** Hamle geçmişinde tek bir satır: bir oyuncunun aldığı puan ve kaynağı. */
export interface HistoryEntry {
  turn: number;
  /** Bu puanı skoruna ekleyen oyuncu. */
  player: Owner;
  /**
   * Oynanan kelime(ler). Köşe vergisi bonusu satırlarında (`invasionFrom`
   * dolu) bu, vergiyi tetikleyen hamlede oynanan kelime(ler)dir — `player`in
   * kendisi oynamamıştır, sadece bölgesine giren/değen hamlede geçen kelime.
   */
  words: string[];
  /** Bu satırda `player`in skoruna eklenen puan. */
  points: number;
  /**
   * Doluysa: bu puan kendi hamlesinden değil, `invasionFrom` oyuncusunun
   * `player`in köşesine girmesinden ya da sınırına değmesinden (köşe vergisi)
   * geldi.
   */
  invasionFrom?: Owner;
  /**
   * Doluysa: bu hamle bir ya da daha fazla rakip köşesine girdiği ya da
   * sınırına değdiği için puanın bir kısmı o köşe sahiplerine kaptırıldı.
   */
  lostShares?: { to: Owner; amount: number }[];
  /** Doluysa: bu satır bir kelime hamlesi değil, pas ya da taş değişimidir. */
  action?: 'pass' | 'exchange';
  /** `action` 'exchange' ise değiştirilen taş sayısı. */
  tileCount?: number;
}

export interface ValidationResult {
  valid: boolean;
  reason?: string;
  words?: string[];
}

/** Tahtada, "Oyna"ya basmadan önce anlık gösterilen hamle çerçevesi. */
export interface MoveStatus {
  /** Yerel sözlüğe göre şu anki yerleştirme geçerli mi? */
  valid: boolean;
  /** Geçersizse, sebebi (köşe kuralı, sözlük vb.) — "Oyna"ya basmadan gösterilir. */
  reason?: string;
  /** Oluşan tüm kelimelere ait hücreler (birleşik dış çerçeve için). */
  cells: [number, number][];
  /** Bu hamlenin (henüz oynanmamış) potansiyel puanı. */
  score: number;
}
