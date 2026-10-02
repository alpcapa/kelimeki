// Kelimeki — Beyin Ligi listesi (k-lig'in OHP alt ligi, 2 Ekim 2026)
//
// `Leaderboard.tsx`in "Beyin Ligi" sekmesi. Puan Ligi listesinin ikizi ama
// puan YOK: sıra yalnızca OHP'ye göre (sunucuda, `beyin_ligi_siralama`).
// Rütbe mührü de YOK — mühür toplam puandan türüyor, puansız listede
// anlamsız (kullanıcı kararı). Port ikizi:
// `mobile/app/lib/src/ui/score/beyin_ligi_list.dart`.
import { useCallback, useEffect, useRef, useState } from 'react';
import { LoadingNote } from './LoadingNote';
import { Avatar } from './Avatar';
import { fetchBeyinLigi, fetchMyBeyinLigiRank } from '../lib/api';
import type { BeyinLigiRow, MyBeyinLigiRank } from '../lib/database.types';
import { useAuth } from '../hooks/useAuth';
import type { PlayerSummary } from './PlayerScoreCard';
import { shortDisplayName } from '../utils/profileFields';
import { BEYIN_LIGI_MIN_GAMES, gamesUntilBeyinLigi } from '../utils/beyinLigi';

const INITIAL_PAGE_SIZE = 10;
const PAGE_SIZE = 20;

export const BEYIN_LIGI_INTRO =
  "Beyin Ligi'nde puan yok, yalnızca hamle kalitesi var: oyuncular Ortalama Hamle Puanı'na (OHP) göre sıralanır. " +
  `Listeye girmek için en az ${BEYIN_LIGI_MIN_GAMES} oyun gerekir.`;

export const BEYIN_LIGI_NOTE =
  "YZ'ye karşı oynanan oyunlar da sayılır. OHP eşitse daha çok oyun oynayan üstte.";

interface BeyinLigiListProps {
  onSelect: (p: PlayerSummary) => void;
}

function rowToPlayerSummary(r: BeyinLigiRow): PlayerSummary {
  return {
    id: r.user_id,
    username: r.username,
    first_name: r.first_name,
    last_name: r.last_name,
    display_name: r.display_name,
    avatar_url: r.avatar_url,
  };
}

export function BeyinLigiList({ onSelect }: BeyinLigiListProps) {
  const { user, profile } = useAuth();
  const [rows, setRows] = useState<BeyinLigiRow[] | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [mine, setMine] = useState<MyBeyinLigiRank | null>(null);
  const scrollRef = useRef<HTMLOListElement | null>(null);
  const sentinelRef = useRef<HTMLLIElement | null>(null);

  useEffect(() => {
    fetchBeyinLigi(INITIAL_PAGE_SIZE, 0).then((r) => {
      setRows(r);
      setHasMore(r.length === INITIAL_PAGE_SIZE);
    });
  }, []);

  useEffect(() => {
    if (!user) return;
    fetchMyBeyinLigiRank(user.id).then(setMine);
  }, [user?.id]);

  // Puan Ligi listesindeki desenin aynısı (bkz. Leaderboard.tsx — neden ref).
  const rowsRef = useRef(rows);
  rowsRef.current = rows;
  const loadMore = useCallback(() => {
    if (rowsRef.current === null) return;
    setLoadingMore((already) => {
      if (already) return already;
      void fetchBeyinLigi(PAGE_SIZE, rowsRef.current!.length).then((page) => {
        setRows((cur) => [...(cur ?? []), ...page]);
        setHasMore(page.length === PAGE_SIZE);
        setLoadingMore(false);
      });
      return true;
    });
  }, []);

  const rowsLoaded = rows !== null;
  useEffect(() => {
    if (!hasMore || !rowsLoaded) return;
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
  }, [hasMore, rowsLoaded, loadMore]);

  if (rows === null) {
    return (
      <div className="h-[50vh] flex items-center justify-center">
        <LoadingNote py="py-0" />
      </div>
    );
  }

  const meInList = user ? rows.some((r) => r.user_id === user.id) : false;
  const remaining = mine && mine.rank == null ? gamesUntilBeyinLigi(mine.ohp_games) : 0;
  const mySummary: PlayerSummary | null = user
    ? {
        id: user.id,
        username: profile?.username ?? null,
        first_name: profile?.first_name ?? null,
        last_name: profile?.last_name ?? null,
        display_name: profile?.display_name ?? null,
        avatar_url: profile?.avatar_url ?? null,
      }
    : null;

  return (
    <div className="flex flex-col gap-2">
      <div className="flex items-center text-[9px] uppercase tracking-[1px] text-muted font-mono font-bold px-2 pb-1 gap-1">
        <span className="min-w-6 whitespace-nowrap">Sıra</span>
        <span className="flex-1">Oyuncu</span>
        <span className="min-w-[34px] whitespace-nowrap text-center shrink-0">Oyun</span>
        <span className="min-w-12 whitespace-nowrap text-right shrink-0">OHP</span>
      </div>
      {rows.length === 0 ? (
        <p className="text-muted text-xs font-mono text-center py-4">
          Henüz listeye giren yok. {BEYIN_LIGI_MIN_GAMES} oyunu tamamlayan ilk sen ol!
        </p>
      ) : (
        <ol ref={scrollRef} className="flex flex-col gap-1 max-h-[50vh] overflow-y-auto pr-1">
          {rows.map((r) => {
            const me = user && r.user_id === user.id;
            const name = shortDisplayName(r, 'Anonim');
            return (
              <li key={r.user_id}>
                <button
                  type="button"
                  onClick={() => onSelect(rowToPlayerSummary(r))}
                  className={[
                    'w-full flex items-center gap-1 text-sm font-mono rounded-md px-2 py-1.5 text-left active:opacity-70 transition-opacity',
                    me ? 'bg-accent/10 border border-accent' : 'bg-bg',
                  ].join(' ')}
                >
                  <span
                    className={[
                      'w-6 font-bold shrink-0',
                      r.sira === 1 ? 'text-gold' : r.sira <= 3 ? 'text-accent' : 'text-muted',
                    ].join(' ')}
                  >
                    {r.sira}
                  </span>
                  <Avatar url={r.avatar_url} name={name} size={22} className="mr-1 shrink-0" />
                  <span className="flex-1 min-w-0 truncate text-text">{name}</span>
                  <span className="min-w-[34px] whitespace-nowrap text-right text-[11px] text-muted shrink-0">
                    {r.ohp_games}
                  </span>
                  <span className="min-w-12 whitespace-nowrap text-right font-bold text-accent shrink-0">
                    {r.avg_move_score.toFixed(2)}
                  </span>
                </button>
              </li>
            );
          })}
          {hasMore && (
            <li ref={sentinelRef} className="py-2 text-center">
              <span className="text-muted text-[10px] font-mono">{loadingMore ? 'Yükleniyor…' : ''}</span>
            </li>
          )}
        </ol>
      )}

      {user && mine && mine.rank != null && !meInList && (
        <>
          <Divider label="senin sıran" />
          <button
            type="button"
            onClick={() => mySummary && onSelect(mySummary)}
            className="w-full flex items-center gap-1 text-sm font-mono rounded-md px-2 py-1.5 text-left bg-accent/10 border border-accent active:opacity-70 transition-opacity"
          >
            <span className="min-w-6 whitespace-nowrap font-bold text-muted shrink-0">{mine.rank}</span>
            <span className="flex-1 text-text">Sen</span>
            <span className="min-w-[34px] whitespace-nowrap text-right text-[11px] text-muted shrink-0">
              {mine.ohp_games}
            </span>
            <span className="min-w-12 whitespace-nowrap text-right font-bold text-accent shrink-0">
              {mine.avg_move_score?.toFixed(2) ?? '—'}
            </span>
          </button>
        </>
      )}

      {user && mine && mine.rank == null && remaining > 0 && (
        <>
          <Divider label="senin durumun" />
          <div className="rounded-md border border-dashed border-accent bg-accent/5 px-3 py-2.5 flex flex-col gap-2">
            <p className="text-[11px] font-mono text-text leading-relaxed">
              {mine.avg_move_score != null && (
                <>
                  OHP'n <b>{mine.avg_move_score.toFixed(2)}</b>, ama Beyin Ligi'ne girmek için{' '}
                  {BEYIN_LIGI_MIN_GAMES} oyun gerekiyor.{' '}
                </>
              )}
              <b>{remaining} oyun</b> daha oyna, listeye gir.
            </p>
            <div
              className="h-1.5 rounded-full bg-border overflow-hidden"
              role="progressbar"
              aria-valuemin={0}
              aria-valuemax={BEYIN_LIGI_MIN_GAMES}
              aria-valuenow={mine.ohp_games}
            >
              <div
                className="h-full bg-accent"
                style={{ width: `${(Math.min(mine.ohp_games, BEYIN_LIGI_MIN_GAMES) / BEYIN_LIGI_MIN_GAMES) * 100}%` }}
              />
            </div>
            <span className="text-[10px] font-mono text-muted">
              {mine.ohp_games} / {BEYIN_LIGI_MIN_GAMES} oyun
            </span>
          </div>
        </>
      )}

      <p className="text-[10px] text-muted font-mono text-center leading-relaxed pt-1">{BEYIN_LIGI_NOTE}</p>
    </div>
  );
}

function Divider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-2 px-2">
      <div className="flex-1 border-t border-dashed border-border" />
      <span className="text-[9px] text-muted font-mono uppercase tracking-[1px]">{label}</span>
      <div className="flex-1 border-t border-dashed border-border" />
    </div>
  );
}
