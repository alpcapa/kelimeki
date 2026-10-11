// Kelimeki — oyun SONUNDA "bu oyuncuları arkadaş eklemek ister misin?" önerisinin
// aday listesi (kullanıcı kararı, 4 Ekim 2026: Takım / Rastgele / arkadaşının
// dahil ettiği Canlı oyunlarda, arkadaşın OLMAYAN insanlar). Port ikizi:
// `util/friend_suggest.dart`. Kapı: `npm run verify-random-games`.
import type { OnlineGameSlot } from '../lib/database.types';

export interface FriendSuggestCandidate {
  user_id: string;
  name?: string;
  avatar_url?: string | null;
}

/**
 * Önerilecek kişiler: insan koltuğu, kendim değilim, zaten arkadaş değil ve
 * isteğim henüz beklemede değil. ⚠ `slot.relation` oyun yüklendiği ANIN
 * görüntüsü — oyun sürerken arkadaş olunmuş olabilir; bu yüzden güncel
 * arkadaş kimlikleri (`friendIds`) de ayrıca elenir. Gelen istek
 * (`pending_incoming`) ELENMEZ: karşılıklı istek sunucuda otomatik kabul olur.
 */
export function friendSuggestCandidates(
  slots: readonly OnlineGameSlot[],
  myUserId: string,
  friendIds: ReadonlySet<string>,
): FriendSuggestCandidate[] {
  const out: FriendSuggestCandidate[] = [];
  const seen = new Set<string>();
  for (const s of slots) {
    if (s.type !== 'human') continue;
    if (s.user_id === myUserId || s.relation === 'self') continue;
    if (s.relation === 'accepted' || s.relation === 'pending_outgoing') continue;
    if (friendIds.has(s.user_id) || seen.has(s.user_id)) continue;
    seen.add(s.user_id);
    out.push({ user_id: s.user_id, name: s.name, avatar_url: s.avatar_url });
  }
  return out;
}
