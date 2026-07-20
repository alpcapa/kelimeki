// Kelimeki — oyun sonu / teslim olma sırasında oyuncuları sıralama mantığı
//
// Teslim olan oyuncular, ne kadar puanları olursa olsun her zaman teslim
// olmamış (hâlâ oyunda olan) tüm oyunculardan sonra sıralanır — bir bölge
// vergisi ya da kademeli teslim sonrasında kalan tek oyuncu, diğerlerinin
// dondurulmuş puanı ne olursa olsun 1. sırayı alır. Teslim olmamışlar
// kendi aralarında puana göre sıralanır; eşit puan aynı sırayı paylaşır.
import type { Player } from '../game/types';

export interface RankedPlayer {
  player: Player;
  index: number;
  rank: number;
}

export function rankPlayers(players: Player[]): RankedPlayer[] {
  const withIndex = players.map((p, index) => ({ p, index }));
  const active = withIndex
    .filter((x) => !x.p.surrendered)
    .sort((a, b) => b.p.score - a.p.score);
  const surrendered = withIndex
    .filter((x) => x.p.surrendered)
    .sort((a, b) => b.p.score - a.p.score);
  const ordered = [...active, ...surrendered];

  let rank = 0;
  let prevScore: number | null = null;
  let prevSurrendered = false;
  return ordered.map((x, pos) => {
    if (prevScore === null || x.p.score !== prevScore || x.p.surrendered !== prevSurrendered) {
      rank = pos + 1;
    }
    prevScore = x.p.score;
    prevSurrendered = x.p.surrendered;
    return { player: x.p, index: x.index, rank };
  });
}
