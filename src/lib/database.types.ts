// Harfik — Supabase şema tipleri (elle yazıldı; MCP erişimi açılınca
// `generate_typescript_types` ile otomatik üretilebilir).

export type GameResult = 'win' | 'lose' | 'tie';

export interface Profile {
  id: string;
  username: string;
  first_name: string;
  last_name: string;
  display_name: string | null;
  avatar_url: string | null;
  agreed_to_terms: boolean;
  created_at: string;
  updated_at: string;
}

/** Bir oyunun bitişindeki tek bir oyuncu satırı (final sıralamasında). */
export interface GamePlayerSnapshot {
  name: string;
  score: number;
  is_ai: boolean;
}

export interface Game {
  id: string;
  user_id: string | null;
  player_score: number;
  ai_score: number;
  result: GameResult;
  /** Oyuncunun oyunu bitirdiği sıra (1 = birinci). Eski kayıtlarda bilinmiyorsa null. */
  rank: number | null;
  turn_count: number;
  player_count: number;
  move_count: number | null;
  best_word: string | null;
  best_move_score: number | null;
  best_word_score: number | null;
  longest_word: string | null;
  /** Bu oyunda oynanan hamlelerin brüt puanları toplamı (ortalama hamle puanı için). */
  move_points_sum: number | null;
  /** Oyuncu oyunu bitirmeden (logoya basıp) terk etti mi? */
  surrendered: boolean;
  /** Final sıralamasına göre tüm oyuncular ve puanları. Eski kayıtlarda null. */
  players: GamePlayerSnapshot[] | null;
  created_at: string;
}

/** games tablosuna eklenecek yeni kayıt. */
export type NewGame = Pick<
  Game,
  'player_score' | 'ai_score' | 'result' | 'rank' | 'turn_count' | 'player_count'
> & {
  user_id?: string | null;
  move_count?: number | null;
  best_word?: string | null;
  best_move_score?: number | null;
  best_word_score?: number | null;
  longest_word?: string | null;
  move_points_sum?: number | null;
  surrendered?: boolean;
  players?: GamePlayerSnapshot[];
};

/** Oyun geçmişi listesinde gösterilecek alanlar. */
export type GameHistoryEntry = Pick<
  Game,
  'id' | 'created_at' | 'player_count' | 'players' | 'player_score' | 'ai_score' | 'rank'
>;

/** Bir kelimenin sözlük kaydı (word_meaning RPC çıktısı). */
export interface WordMeaning {
  word: string;
  pos: string | null;
  meanings: string[];
}

export interface LeaderboardRow {
  user_id: string;
  username: string | null;
  first_name: string | null;
  last_name: string | null;
  display_name: string | null;
  avatar_url: string | null;
  best_score: number;
  total_score: number;
  games_played: number;
  wins: number;
}

export interface MyLeaderboardRank {
  rank: number;
  total_score: number;
}

export interface PlayerStats {
  user_id: string;
  player_count: number;
  games_played: number;
  wins: number;
  losses: number;
  ties: number;
  best_score: number;
  avg_score: number;
  avg_move_score: number | null;
  best_move_score: number | null;
  best_word_score: number | null;
  best_word: string | null;
  longest_word: string | null;
  first_places: number;
  second_places: number;
  /**
   * Lig puanı (oyun içi ham skorların toplamı değil): 1.=2, 2.=1, 3./4.=0.
   * Beraber bitirenler grubun en iyi sırasının puanını paylaşır (2 kişilik
   * tam beraberlikte ikisi de rank=1 olur, ikisi de 2 alır). Teslim olunan
   * oyunlar sıradan bağımsız olarak sabit -2 puan getirir.
   */
  total_score: number;
  /** Oyuncunun bitirmeden terk ettiği (teslim olduğu) oyun sayısı. */
  surrendered_count: number;
}
