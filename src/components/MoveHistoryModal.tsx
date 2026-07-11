// Harfik — oyundaki tüm oyuncuların hamle/puan geçmişi
import { Modal } from './Modal';
import { PLAYER_COLORS } from '../game/constants';
import type { GameState } from '../game/types';

interface MoveHistoryModalProps {
  state: GameState;
  onClose: () => void;
}

export function MoveHistoryModal({ state, onClose }: MoveHistoryModalProps) {
  const entries = state.moveHistory;
  const total = entries.reduce((s, e) => s + e.points, 0);
  const scoringMoveCount = entries.filter((e) => !e.action).length;
  // Vergi geliri satırı ayrı bir kart olarak gösterilmez: aynı hamle zaten
  // hamleyi yapanın kendi satırında (kelime + net puan + kaptırılan pay
  // notu) tam olarak anlatılıyor, ikinci satır sadece tekrar olur.
  const displayEntries = entries.filter((e) => e.invasionFrom === undefined);

  return (
    <Modal title="Oyun Geçmişi" onClose={onClose}>
      <p className="text-[10px] font-mono text-muted mb-3 leading-relaxed">
        Bu oyunda kazanılan {scoringMoveCount} hamle ve puanları. Toplam{' '}
        <span className="font-bold text-accent text-[15px]">{total}</span> puan.
      </p>

      {displayEntries.length === 0 ? (
        <p className="text-[11px] font-mono text-muted text-center py-4">
          Henüz kazanılmış bir puan yok.
        </p>
      ) : (
        <div className="flex flex-col gap-1.5 max-h-72 overflow-y-auto pr-1">
          {[...displayEntries].reverse().map((e, i) => {
            const player = state.players[e.player];
            const label = e.action === 'pass'
              ? 'Pas geçti'
              : e.action === 'exchange'
                ? `${e.tileCount} taş değiştirdi`
                : e.words.length > 0
                  ? e.words.join(', ')
                  : '—';
            return (
              <div
                key={i}
                className="flex flex-col gap-0.5 py-1.5 px-2 rounded-md bg-bg border border-border"
              >
                <div className="flex items-center justify-between gap-2">
                  <div className="flex flex-col min-w-0">
                    <span className="text-[9px] font-mono text-muted uppercase tracking-[0.5px] flex items-center gap-1.5">
                      <span
                        className="w-2 h-2 rounded-sm shrink-0"
                        style={{ background: PLAYER_COLORS[player.colorIndex].base }}
                      />
                      {player?.name ?? '?'} · {e.turn + 1}. tur
                    </span>
                    <span className="text-[12px] font-mono font-bold text-text truncate">
                      {label}
                    </span>
                  </div>
                  {!e.action && (
                    <span className="flex items-center gap-1 shrink-0">
                      {e.x3 && (
                        <span
                          className="text-[8px] font-mono font-bold leading-none rounded px-[3px] py-[2px]"
                          style={{ background: 'linear-gradient(135deg, #FDBA74, #F97316)', color: '#7C2D12' }}
                          title="Üç kat kelime puanı"
                        >
                          ×3
                        </span>
                      )}
                      {e.x2 && (
                        <span
                          className="text-[8px] font-mono font-bold leading-none rounded px-[3px] py-[2px]"
                          style={{ background: 'linear-gradient(135deg, #FDE68A, #FBBF24)', color: '#7C2D12' }}
                          title="İki kat kelime puanı"
                        >
                          ×2
                        </span>
                      )}
                      <span className="text-[13px] font-mono font-bold text-green">
                        +{e.points}
                      </span>
                    </span>
                  )}
                </div>
                {e.lostShares && e.lostShares.length > 0 && (
                  <span className="text-[9px] font-mono text-red">
                    {e.lostShares
                      .map((s) => `${s.amount} puanı ${state.players[s.to]?.name ?? '?'} kaptı`)
                      .join(', ')}
                  </span>
                )}
              </div>
            );
          })}
        </div>
      )}
    </Modal>
  );
}
