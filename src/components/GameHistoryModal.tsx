// Harfik — oturum açan kullanıcının geçmiş tüm oyunlarının listesi (lazy load)
import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from './Modal';
import { fetchMyGames } from '../lib/api';
import type { GameHistoryEntry, GamePlayerSnapshot } from '../lib/database.types';
import { useAuth } from '../hooks/useAuth';
import { PlayerBadge } from './PlayerBadge';

interface GameHistoryModalProps {
  playerCount: number;
  onClose: () => void;
}

const PAGE_SIZE = 20;

function formatDateTime(iso: string): string {
  const d = new Date(iso);
  const date = d.toLocaleDateString('tr-TR');
  const time = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return `${date} · ${time}`;
}

/**
 * Eski kayıtlarda (players alanı eklenmeden önce oynanmış oyunlarda) yalnızca
 * kendi puanın ve en iyi rakibin puanı bilinir — diğer oyuncuların adı/puanı
 * saklanmamıştır. Bilinen iki satırı döner; kalan oyuncu sayısını ve kendi
 * satırının indeksini ayrıca verir.
 */
function fallbackPlayers(
  entry: GameHistoryEntry,
): { known: GamePlayerSnapshot[]; unknownCount: number; meIndex: number } {
  const me: GamePlayerSnapshot = { name: 'Sen', score: entry.player_score, is_ai: false };
  const opponent: GamePlayerSnapshot = { name: 'En iyi rakip', score: entry.ai_score, is_ai: false };
  const meFirst = entry.player_score >= entry.ai_score;
  const known = meFirst ? [me, opponent] : [opponent, me];
  return { known, unknownCount: Math.max(0, entry.player_count - 2), meIndex: meFirst ? 0 : 1 };
}

/**
 * Final sıralaması (players) içinde oturum açan kullanıcının (hesap
 * sahibinin) satırının indeksini bulur. `rank` alanı (1 = birinci) bu
 * sıralamadaki pozisyonu doğrudan verir; eski kayıtlarda rank bilinmiyorsa
 * puanı entry.player_score'a eşit olan ve YZ olmayan ilk satıra düşülür.
 */
function findMeIndex(entry: GameHistoryEntry, players: GamePlayerSnapshot[]): number {
  if (entry.rank !== null && entry.rank >= 1 && entry.rank <= players.length) {
    return entry.rank - 1;
  }
  const byScore = players.findIndex((p) => !p.is_ai && p.score === entry.player_score);
  return byScore >= 0 ? byScore : 0;
}

export function GameHistoryModal({ playerCount, onClose }: GameHistoryModalProps) {
  const { user, profile } = useAuth();
  // Her oyunun `players` jsonb'si o oyun bittiği andaki ismi donmuş halde
  // tutar — takma adını sonradan değiştirsen eski kayıtlar güncellenmez.
  // Kendi satırını (meIndex) burada donmuş isim yerine her zaman GÜNCEL
  // takma adınla göstererek nickname'in geçmişte de tutarlı görünmesini
  // sağlıyoruz; diğer oyuncuların isimleri hâlâ o anki hallerini gösterir.
  const myCurrentName =
    profile?.display_name ||
    profile?.first_name ||
    (user?.email ? user.email.split('@')[0] : null) ||
    'Sen';
  const [games, setGames] = useState<GameHistoryEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const sentinelRef = useRef<HTMLDivElement | null>(null);
  const scrollRef = useRef<HTMLDivElement | null>(null);

  // Sekme (oyuncu sayısı) değişince listeyi baştan yükle.
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setGames([]);
    setHasMore(true);
    void fetchMyGames(playerCount, 0, PAGE_SIZE).then(({ games: page, hasMore: more }) => {
      if (cancelled) return;
      setGames(page);
      setHasMore(more);
      setLoading(false);
    });
    return () => {
      cancelled = true;
    };
  }, [playerCount]);

  const loadMore = useCallback(() => {
    setLoadingMore((already) => {
      if (already) return already;
      void fetchMyGames(playerCount, games.length, PAGE_SIZE).then(({ games: page, hasMore: more }) => {
        setGames((cur) => [...cur, ...page]);
        setHasMore(more);
        setLoadingMore(false);
      });
      return true;
    });
  }, [playerCount, games.length]);

  // Liste kaydırılıp en alttaki sentinel göründüğünde bir sonraki sayfayı yükler.
  useEffect(() => {
    if (!hasMore || loading) return;
    const sentinel = sentinelRef.current;
    const root = scrollRef.current;
    if (!sentinel || !root) return;
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) loadMore();
      },
      { root, rootMargin: '80px' },
    );
    observer.observe(sentinel);
    return () => observer.disconnect();
  }, [hasMore, loading, loadMore]);

  return (
    <Modal title={`Tüm Oyunlar · ${playerCount} Oyunculu`} onClose={onClose}>
      {loading ? (
        <p className="text-muted text-xs font-mono text-center py-4">Yükleniyor…</p>
      ) : games.length === 0 ? (
        <p className="text-muted text-[10px] font-mono text-center py-4">
          Bu kategoride henüz kayıtlı oyun yok.
        </p>
      ) : (
        <div ref={scrollRef} className="flex flex-col gap-2 max-h-[65vh] overflow-y-auto pr-1">
          {games.map((entry) => {
            const hasSnapshot = entry.players && entry.players.length > 0;
            const fallback = hasSnapshot ? null : fallbackPlayers(entry);
            const players = hasSnapshot ? entry.players! : fallback!.known;
            const unknownCount = fallback?.unknownCount ?? 0;
            const meIndex = hasSnapshot ? findMeIndex(entry, players) : fallback!.meIndex;
            return (
              <div
                key={entry.id}
                className="shadow-raised bg-bg border border-border rounded-md py-2 px-2.5 flex flex-col gap-1.5"
              >
                <div className="text-[9px] font-mono text-muted uppercase tracking-[0.5px]">
                  {formatDateTime(entry.created_at)}
                </div>
                <div className="flex flex-col gap-0.5">
                  {players.map((p, i) => (
                    <div
                      key={i}
                      className="flex items-center justify-between gap-2 text-[12px] font-mono"
                    >
                      <span className="flex items-center gap-1.5 min-w-0">
                        <PlayerBadge index={i} size={14} />
                        <span className={`truncate ${i === meIndex ? 'text-text font-bold' : 'text-muted'}`}>
                          {i === meIndex ? myCurrentName : p.name}
                        </span>
                        {p.surrendered && (
                          <span className="text-[8px] font-bold uppercase tracking-[0.5px] text-red border border-red/40 bg-red/10 rounded px-1 py-[1px] shrink-0">
                            Teslim Oldu
                          </span>
                        )}
                      </span>
                      <span className={`font-bold shrink-0 ${i === meIndex ? 'text-gold' : 'text-muted'}`}>
                        {p.score}
                      </span>
                    </div>
                  ))}
                  {unknownCount > 0 && (
                    <div className="text-[10px] font-mono text-muted italic pt-0.5">
                      +{unknownCount} diğer oyuncu (bu eski kayıtta bilinmiyor)
                    </div>
                  )}
                </div>
              </div>
            );
          })}
          {hasMore && (
            <div ref={sentinelRef} className="py-2 text-center">
              <span className="text-muted text-[10px] font-mono">
                {loadingMore ? 'Yükleniyor…' : ''}
              </span>
            </div>
          )}
        </div>
      )}
    </Modal>
  );
}
