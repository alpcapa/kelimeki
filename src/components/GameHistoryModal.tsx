// Harfik — oturum açan kullanıcının geçmiş tüm oyunlarının listesi
import { useEffect, useState } from 'react';
import { Modal } from './Modal';
import { fetchMyGames } from '../lib/api';
import type { GameHistoryEntry, GamePlayerSnapshot } from '../lib/database.types';

interface GameHistoryModalProps {
  playerCount: number;
  onClose: () => void;
}

function formatDateTime(iso: string): string {
  const d = new Date(iso);
  const date = d.toLocaleDateString('tr-TR');
  const time = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return `${date} · ${time}`;
}

/** Eski kayıtlarda (players alanı yokken) elde bulunan tek verilerden yaklaşık bir sıralama üretir. */
function fallbackPlayers(entry: GameHistoryEntry): GamePlayerSnapshot[] {
  const me: GamePlayerSnapshot = { name: 'Sen', score: entry.player_score, is_ai: false };
  const opponent: GamePlayerSnapshot = { name: 'Rakip', score: entry.ai_score, is_ai: false };
  return entry.player_score >= entry.ai_score ? [me, opponent] : [opponent, me];
}

export function GameHistoryModal({ playerCount, onClose }: GameHistoryModalProps) {
  const [games, setGames] = useState<GameHistoryEntry[] | null>(null);

  useEffect(() => {
    setGames(null);
    void fetchMyGames(playerCount).then(setGames);
  }, [playerCount]);

  return (
    <Modal title={`Tüm Oyunlar · ${playerCount} Oyunculu`} onClose={onClose}>
      {games === null ? (
        <p className="text-muted text-xs font-mono text-center py-4">Yükleniyor…</p>
      ) : games.length === 0 ? (
        <p className="text-muted text-[10px] font-mono text-center py-4">
          Bu kategoride henüz kayıtlı oyun yok.
        </p>
      ) : (
        <div className="flex flex-col gap-2 max-h-[65vh] overflow-y-auto pr-1">
          {games.map((entry) => {
            const players = entry.players && entry.players.length > 0
              ? entry.players
              : fallbackPlayers(entry);
            return (
              <div
                key={entry.id}
                className="bg-bg border border-border rounded-md py-2 px-2.5 flex flex-col gap-1.5"
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
                        <span className={`w-3 text-right ${i === 0 ? 'text-gold font-bold' : 'text-muted'}`}>
                          {i + 1}.
                        </span>
                        <span className={`truncate ${i === 0 ? 'text-text font-bold' : 'text-muted'}`}>
                          {p.name}
                        </span>
                        {p.is_ai && (
                          <span className="text-[8px] text-muted border border-border rounded px-1 shrink-0">
                            YZ
                          </span>
                        )}
                      </span>
                      <span className={`font-bold shrink-0 ${i === 0 ? 'text-gold' : 'text-muted'}`}>
                        {p.score}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Modal>
  );
}
