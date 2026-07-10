// Harfik — oyuncu(lar)ın bu oyundaki hamle/puan geçmişi
import { Modal } from './Modal';
import { PLAYER_COLORS } from '../game/constants';
import type { GameState } from '../game/types';

interface MoveHistoryModalProps {
  state: GameState;
  /** Verilirse yalnızca bu oyuncunun hamleleri gösterilir; verilmezse tüm oyuncular. */
  playerIndex?: number;
  onClose: () => void;
}

export function MoveHistoryModal({ state, playerIndex, onClose }: MoveHistoryModalProps) {
  const allPlayers = playerIndex === undefined;
  const entries = allPlayers
    ? state.moveHistory
    : state.moveHistory.filter((e) => e.player === playerIndex);
  const total = entries.reduce((s, e) => s + e.points, 0);
  const scoringMoveCount = entries.filter((e) => !e.action).length;

  return (
    <Modal title={allPlayers ? 'Oyun Geçmişi' : 'Hamle Geçmişi'} onClose={onClose}>
      <p className="text-[10px] font-mono text-muted mb-3 leading-relaxed">
        {allPlayers ? 'Bu oyunda kazanılan' : 'Bu oyunda kazandığın'} {scoringMoveCount} hamle ve
        puanları. Toplam <span className="font-bold text-accent text-[15px]">{total}</span> puan.
      </p>

      {entries.length === 0 ? (
        <p className="text-[11px] font-mono text-muted text-center py-4">
          Henüz kazanılmış bir puan yok.
        </p>
      ) : (
        <div className="flex flex-col gap-1.5 max-h-72 overflow-y-auto pr-1">
          {[...entries].reverse().map((e, i) => {
            const isInvasion = e.invasionFrom !== undefined;
            // Vergi geliri satırında (isInvasion) başlıkta hamleyi yapan
            // (invasionFrom) gösterilir — puanı asıl `e.player` kazanmış olsa
            // da bu satır o hamleyi anlatır, bölge sahibinin kendi hamlesini değil.
            const headerPlayer = isInvasion ? state.players[e.invasionFrom!] : state.players[e.player];
            const label = e.action === 'pass'
              ? 'Pas geçti'
              : e.action === 'exchange'
                ? `${e.tileCount} taş değiştirdi`
                : e.words.length > 0
                  ? isInvasion && !allPlayers
                    ? `${headerPlayer?.name ?? '?'}: ${e.words.join(', ')}`
                    : e.words.join(', ')
                  : '—';
            const captureNote = isInvasion
              ? `${e.points} puanı ${state.players[e.player]?.name ?? '?'} kaptı`
              : undefined;
            return (
              <div
                key={i}
                className="flex flex-col gap-0.5 py-1.5 px-2 rounded-md bg-bg border border-border"
              >
                <div className="flex items-center justify-between gap-2">
                  <div className="flex flex-col min-w-0">
                    <span className="text-[9px] font-mono text-muted uppercase tracking-[0.5px] flex items-center gap-1.5">
                      {allPlayers && (
                        <span
                          className="w-2 h-2 rounded-sm shrink-0"
                          style={{ background: PLAYER_COLORS[headerPlayer.colorIndex].base }}
                        />
                      )}
                      {allPlayers ? `${headerPlayer?.name ?? '?'} · ${e.turn + 1}. tur` : `${e.turn + 1}. tur`}
                    </span>
                    <span className="text-[12px] font-mono font-bold text-text truncate">
                      {label}
                    </span>
                  </div>
                  {!e.action && (
                    <span
                      className={[
                        'text-[13px] font-mono font-bold shrink-0',
                        isInvasion ? 'text-gold' : 'text-green',
                      ].join(' ')}
                    >
                      +{e.points}
                    </span>
                  )}
                </div>
                {captureNote ? (
                  <span className="text-[9px] font-mono text-red">{captureNote}</span>
                ) : (
                  e.lostShares &&
                  e.lostShares.length > 0 && (
                    <span className="text-[9px] font-mono text-red">
                      {e.lostShares
                        .map((s) => `${s.amount} puanı ${state.players[s.to]?.name ?? '?'} kaptı`)
                        .join(', ')}
                    </span>
                  )
                )}
              </div>
            );
          })}
        </div>
      )}
    </Modal>
  );
}
