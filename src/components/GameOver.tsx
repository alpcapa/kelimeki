// Kelimeki — oyun sonu ekranı (çok oyunculu)
import { Modal } from './Modal';
import { PLAYER_COLORS } from '../game/constants';
import type { Player } from '../game/types';
import { trUpper } from '../utils/turkish';
import { rankPlayers } from '../utils/ranking';
import { PlayerBadge } from './PlayerBadge';

interface GameOverProps {
  show: boolean;
  players: Player[];
  turnCount: number;
  onOpenHistory: () => void;
  onOpenFeedback: () => void;
  onClose: () => void;
}

export function GameOver({ show, players, turnCount, onOpenHistory, onOpenFeedback, onClose }: GameOverProps) {
  if (!show) return null;

  const ranked = rankPlayers(players);
  const top = ranked[0];
  const tie = ranked.length > 1 && ranked[1].rank === top.rank;
  const winColor = PLAYER_COLORS[top.player.colorIndex];

  return (
    <Modal title="" onClose={onClose}>
      <div className="flex flex-col items-center gap-[18px]">
        <div
          className="font-mono text-[26px] font-bold tracking-[2px] text-center"
          style={{ color: tie ? '#B7791F' : winColor.base }}
        >
          {tie ? 'BERABERE' : `${trUpper(top.player.name)} KAZANDI`}
        </div>

        <div className="shadow-raised bg-bg border border-border rounded-[10px] px-5 py-4 text-center flex flex-col gap-2.5 w-full">
          <div className="flex justify-end items-center gap-4 text-[10px] uppercase tracking-wide text-muted">
            <span className="w-8 text-right">Kalan</span>
            <span className="w-10 text-right">Toplam</span>
          </div>
          {ranked.map(({ player: p, index: i, rank }) => {
            const col = PLAYER_COLORS[p.colorIndex];
            const remaining = p.rack.reduce((s, t) => s + t.pts, 0);
            return (
              <div key={i} className="flex justify-between items-center gap-8 text-[15px]">
                <span className="flex items-center gap-2">
                  <PlayerBadge index={i} colorIndex={p.colorIndex} size={14} />
                  <span className="text-text">
                    {rank}. {p.name}
                    {p.surrendered && (
                      <span className="ml-1.5 text-[9px] font-mono uppercase tracking-[0.5px] text-red">
                        (Teslim Oldu)
                      </span>
                    )}
                  </span>
                </span>
                <span className="flex items-center gap-4">
                  <span className="w-8 text-right font-mono text-[13px] text-muted">
                    {remaining > 0 ? `-${remaining}` : ''}
                  </span>
                  <span
                    className="w-10 text-right font-mono text-[22px] font-bold"
                    style={{ color: col.base }}
                  >
                    {p.score}
                  </span>
                </span>
              </div>
            );
          })}
          <div className="flex justify-between gap-8 text-[12px] border-t border-border pt-2 mt-1">
            <span className="text-muted">Toplam hamle</span>
            <span className="font-mono font-bold text-muted">{turnCount}</span>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={onOpenHistory}
            className="text-[11px] font-mono font-bold uppercase tracking-[1px] text-muted underline underline-offset-2 active:opacity-70 transition-opacity"
          >
            Oyun Geçmişi
          </button>
          <button
            onClick={onOpenFeedback}
            className="text-[11px] font-mono font-bold uppercase tracking-[1px] text-muted underline underline-offset-2 active:opacity-70 transition-opacity"
          >
            Görüş Bildir
          </button>
        </div>
      </div>
    </Modal>
  );
}
