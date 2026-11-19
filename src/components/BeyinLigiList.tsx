// Kelimeki — Beyin Ligi listesi (k-lig'in OHP alt ligi, 2 Ekim 2026)
//
// `Leaderboard.tsx`in "Beyin Ligi" sekmesi. Puan Ligi listesinin ikizi ama
// puan YOK: sıra yalnızca OHP'ye göre (sunucuda, `beyin_ligi_siralama`).
// Rütbe mührü 2 Ekim 2026'da YOKTU (mühür toplam puandan türüyor, kullanıcı
// kararı); 20 Kasım 2026'da kullanıcı isteğiyle EKLENDİ (*"Beyin ligindeki
// isimlerin yanına da rütbe rozeti koyalım puan ligi gibi"*): sıralama hâlâ
// yalnızca OHP'ye göre, mühür yalnızca oyuncunun kimliğini gösterir. Puan
// `useRankScores` ile (toplu `leaderboard` okuması) gelir — satırda puan
// kolonu YOK, bu yüzden Puan Ligi gibi `total_score` satırdan okunamaz.
// "Senin sıran" satırında mühür YOK (Puan Ligi'nin aynı satırı da çizmiyor).
// Port ikizi:
// `mobile/app/lib/src/ui/score/beyin_ligi_list.dart`.
import { useCallback, useEffect, useRef, useState } from 'react';
import { LoadingNote } from './LoadingNote';
import { Avatar } from './Avatar';
import { RankSeal } from './RankSeal';
import { fetchBeyinLigi, fetchMyBeyinLigiRank } from '../lib/api';
import type { BeyinLigiRow, MyBeyinLigiRank } from '../lib/database.types';
import { useAuth } from '../hooks/useAuth';
import { useRowInView } from '../hooks/useRowInView';
import { useRankScores } from '../hooks/useRankScores';
import { shouldPinOwnRow } from '../utils/ownRowPin';
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
  const { ref: meRowRef, inView: meInView } = useRowInView(scrollRef);

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

  // ⚠ Hook, aşağıdaki erken `return`ün ÜSTÜNDE (React #300 kapısı:
  // `npm run verify-hook-order`). Satırlar yüklenene kadar boş dizi: lookup
  // `null` döner ve mühür HİÇ çizilmez (herkesi bir an Çaylak göstermez).
  const tierOf = useRankScores((rows ?? []).map((r) => r.user_id));

  if (rows === null) {
    return (
      <div className="h-[50vh] min-h-0 flex items-center justify-center">
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
    // `min-h-0`: k-lig penceresinin gövdesi bir flex sütunu (`fillBody`),
    // liste kalan alana küçülür, altındaki satır/kart/not hep görünür.
    <div className="flex flex-col gap-2 min-h-0">
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
        <ol ref={scrollRef} className="flex flex-col gap-1 max-h-[50vh] min-h-0 overflow-y-auto pr-1">
          {rows.map((r) => {
            const me = user && r.user_id === user.id;
            const name = shortDisplayName(r, 'Anonim');
            return (
              <li key={r.user_id} ref={me ? meRowRef : undefined}>
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
                  <span className="flex-1 min-w-0 flex items-center gap-1">
                    <span className="truncate text-text">{name}</span>
                    {/* Rütbe mührü — Puan Ligi satırıyla AYNI boy/yer (18px
                        kompakt, ismin hemen yanında); GÜNCEL puandan türer. */}
                    {tierOf(r.user_id) && (
                      <RankSeal tier={tierOf(r.user_id)!} size={18} className="shrink-0" />
                    )}
                  </span>
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

      {user && mine && shouldPinOwnRow({ hasRank: mine.rank != null, inList: meInList, inView: meInView }) && (
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
