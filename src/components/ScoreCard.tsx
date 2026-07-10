// Harfik — skor kartı: oyuncu istatistikleri ve sıralamaya geçiş
import { useEffect, useState } from 'react';
import { Modal } from './Modal';
import { Avatar } from './Avatar';
import { fetchPlayerStats } from '../lib/api';
import type { PlayerStats } from '../lib/database.types';
import { useAuth } from '../hooks/useAuth';

interface ScoreCardProps {
  onClose: () => void;
}

const TABS = [2, 4] as const;

export function ScoreCard({ onClose }: ScoreCardProps) {
  const { user, profile } = useAuth();
  const [statsByCount, setStatsByCount] = useState<
    Record<number, PlayerStats | null | undefined>
  >({ 2: undefined, 4: undefined });
  const [tab, setTab] = useState<(typeof TABS)[number]>(2);

  useEffect(() => {
    for (const count of TABS) {
      fetchPlayerStats(count).then((s) =>
        setStatsByCount((cur) => ({ ...cur, [count]: s })),
      );
    }
  }, []);

  const name =
    profile?.username ||
    [profile?.first_name, profile?.last_name].filter(Boolean).join(' ').trim() ||
    user?.email ||
    'Oyuncu';

  const stats = statsByCount[tab];

  const pct = (n: number) =>
    stats && stats.games_played > 0 ? `%${Math.round((n / stats.games_played) * 100)}` : '%0';

  const cells: { label: string; value: number | string; cls?: string; wide?: boolean }[] = [
    { label: 'Toplam Oyun', value: stats?.games_played ?? 0 },
    { label: 'Toplam Birincilik', value: stats?.first_places ?? 0, cls: 'text-gold' },
    { label: 'Toplam İkincilik', value: stats?.second_places ?? 0, cls: 'text-accent' },
    { label: 'Birincilik Oranı', value: pct(stats?.first_places ?? 0), cls: 'text-gold' },
    { label: 'İkincilik Oranı', value: pct(stats?.second_places ?? 0), cls: 'text-accent' },
    { label: 'En Yüksek Oyun Puanı', value: stats?.best_score ?? 0, cls: 'text-gold' },
    { label: 'Beraberlik', value: stats?.ties ?? 0, cls: 'text-muted' },
    { label: 'En İyi Hamle Puanı', value: stats?.best_move_score ?? 0, cls: 'text-accent' },
    { label: 'Ortalama Hamle Puanı', value: stats?.avg_move_score ?? 0, cls: 'text-accent' },
    { label: 'En Yüksek Kelime Puanı', value: stats?.best_word_score ?? 0, cls: 'text-text' },
    { label: 'En Uzun Kelime', value: stats?.longest_word ?? '—', cls: 'text-text', wide: true },
  ];

  return (
    <Modal title="Skor Kartı" onClose={onClose}>
      <div className="mb-4 flex items-center gap-3">
        <Avatar url={profile?.avatar_url} name={name} size={44} />
        <div className="min-w-0">
          <div className="text-base font-bold text-text truncate">{name}</div>
          {user?.email && (
            <div className="text-xs text-muted font-mono truncate">{user.email}</div>
          )}
        </div>
      </div>

      <div className="mb-3 flex gap-2">
        {TABS.map((count) => (
          <button
            key={count}
            type="button"
            onClick={() => setTab(count)}
            className={`flex-1 rounded-md border py-1.5 text-xs font-mono font-bold transition-colors ${
              tab === count
                ? 'border-accent bg-accent/10 text-accent'
                : 'border-border bg-bg text-muted'
            }`}
          >
            {count} Oyunculu
          </button>
        ))}
      </div>

      {stats === undefined ? (
        <p className="text-muted text-xs font-mono text-center py-4">Yükleniyor…</p>
      ) : (
        <>
          {!stats && (
            <p className="text-muted text-[10px] font-mono text-center pb-2">
              Henüz {tab} oyunculu oyun kaydın yok.
            </p>
          )}
          <div className="grid grid-cols-3 gap-2">
            {cells.map((c) => (
              <div
                key={c.label}
                className={`bg-bg border border-border rounded-md py-3 px-1 text-center ${c.wide ? 'col-span-3' : ''}`}
              >
                <div className={`font-mono text-xl font-bold ${c.cls ?? 'text-text'}`}>
                  {c.value}
                </div>
                <div className="text-[8px] uppercase tracking-[1px] text-muted font-mono mt-0.5">
                  {c.label}
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </Modal>
  );
}
