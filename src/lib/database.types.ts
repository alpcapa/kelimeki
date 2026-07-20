// Kelimeki — Supabase şema tipleri (elle yazıldı; MCP erişimi açılınca
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
  is_admin: boolean;
  created_at: string;
  updated_at: string;
}

/** Bir oyunun bitişindeki tek bir oyuncu satırı (final sıralamasında). */
export interface GamePlayerSnapshot {
  name: string;
  score: number;
  is_ai: boolean;
  /** Bu oyuncu oyunu bitirmeden teslim oldu mu (dolduysa; eski kayıtlarda yok). */
  surrendered?: boolean;
  /**
   * Oyuncunun sabit koltuk/renk kimliği (PLAYER_COLORS indeksi) — final
   * sıralamasındaki konumuyla (rank) KARIŞTIRILMAMALI. Bu alan eklenmeden
   * önceki kayıtlarda yok; GameHistoryModal isimden ("Yapay Zeka N") tahmin
   * eder.
   */
  colorIndex?: number;
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
  best_move_score: number | null;
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
  /**
   * İstemci tarafında üretilen uuid. Offline kuyruklamada, bağlantı geri
   * gelince aynı kaydın tekrar denenmesi durumunda sunucu tarafında
   * yinelenmeyi (duplicate insert) engellemek için kullanılır — bkz.
   * `saveGame` (lib/api.ts) ve `gameSync.ts`.
   */
  id?: string;
  /**
   * Oyunun gerçekten bittiği an (istemci saati, ISO 8601). Offline/misafir
   * kuyruklamada kayıt sunucuya çok sonra ulaşabildiğinden, sunucunun
   * `insert` anındaki `now()` varsayılanı yerine bu değer kullanılır — böylece
   * oyun geçmişi gerçek oynanma sırasına göre görünür.
   */
  created_at?: string;
  user_id?: string | null;
  move_count?: number | null;
  best_move_score?: number | null;
  longest_word?: string | null;
  move_points_sum?: number | null;
  surrendered?: boolean;
  players?: GamePlayerSnapshot[];
};

/** Oyun geçmişi listesinde gösterilecek alanlar. */
export type GameHistoryEntry = Pick<
  Game,
  | 'id'
  | 'created_at'
  | 'player_count'
  | 'players'
  | 'player_score'
  | 'ai_score'
  | 'rank'
  | 'surrendered'
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
  longest_word: string | null;
  first_places: number;
  second_places: number;
  /**
   * Lig puanı (oyun içi ham skorların toplamı değil): 4 kişilikte 1.=2,
   * 2.=1, 3./4.=0; 2 kişilikte sadece 1.=2, 2.=0 (tek rakipli oyunda ikinci
   * olmak kaybetmekle aynı şey olduğundan puan getirmez). Beraber
   * bitirenler grubun en iyi sırasının puanını paylaşır (2 kişilik tam
   * beraberlikte ikisi de rank=1 olur, ikisi de 2 alır). Teslim olunan
   * oyunlar sıradan bağımsız olarak sabit -2 puan getirir.
   */
  total_score: number;
  /** Oyuncunun bitirmeden terk ettiği (teslim olduğu) oyun sayısı. */
  surrendered_count: number;
}

// ── Admin paneli ────────────────────────────────────────────────────────────

/** admin_list_members RPC çıktısındaki tek satır (auth.users + profiles). */
export interface AdminMember {
  id: string;
  email: string | null;
  username: string | null;
  first_name: string | null;
  last_name: string | null;
  display_name: string | null;
  is_admin: boolean;
  signup_channel: 'direct' | 'form';
  created_at: string;
  last_sign_in_at: string | null;
  banned_until: string | null;
}

export type AdminActivityGranularity = 'day' | 'week' | 'month' | 'year';

/** admin_user_activity_series RPC çıktısındaki tek kova (Büyüme > Kullanıcı grafiği). */
export interface AdminUserActivityPoint {
  bucket: string;
  signups: number;
}

/** admin_game_activity_series'in p_scope parametresi: Toplam/Kayıtlı/Misafir kombosu. */
export type AdminGameScope = 'total' | 'registered' | 'guest';

/**
 * admin_game_activity_series RPC çıktısındaki tek kova (Büyüme > Oyun grafiği).
 * `games_finished` yalnızca gerçekten tamamlanan (completed=true) oyunları
 * sayar (`games_finished_same_session`/`games_finished_multi_session` bu
 * toplamın kırılımı); `games_abandoned` 7 gün hareketsizlik sonrası terk
 * edilmiş sayılıp silinen oyunları (bkz. `gameStorage.ts`
 * `ABANDON_TIMEOUT_MS`) ayrı bir seride tutar. avg_duration_* alanları da
 * yalnızca tamamlanan oyunlar üzerinden hesaplanır ve o kovada hiç biten
 * oyun yoksa null döner (0 değil). same_session: hiç kapatılıp devam
 * ettirilmemiş oyunlar; multi_session: en az bir kez kapatılıp
 * localStorage'dan devam ettirilmiş oyunlar (bkz. `GameState.multiSession`).
 * "Başlatılan" (eski `game_starts`) hiçbir yerde ihtiyaç görülmediği için
 * 20 Temmuz 2026'da tamamen kaldırıldı (tablo dahil).
 */
export interface AdminGameActivityPoint {
  bucket: string;
  games_finished: number;
  games_finished_same_session: number;
  games_finished_multi_session: number;
  games_abandoned: number;
  avg_duration_seconds: number | null;
  avg_duration_same_session_seconds: number | null;
  avg_duration_multi_session_seconds: number | null;
}

/** feedback tablosundaki tek satır (admin panelinden okunur). */
export interface AdminFeedbackRow {
  id: string;
  user_id: string | null;
  email: string | null;
  message: string;
  handled: boolean;
  created_at: string;
}
