// Kelimeki — Rastgele Oyuncu (açık ilan) için SAF kurallar.
// Tasarım: docs/decisions/random-opponent.md. Kapı: `npm run verify-random-games`.
// Port ikizi YAZILMADI (bu iş yalnızca web): Flutter'a taşınırken kurallar
// buradaki fonksiyon notlarından birebir alınır.
//
// Neden ayrı saf dosya: bu kuralların kırılma biçimi SESSİZ (bir oyun yanlış
// sekmede görünür, bir rozet şişer, açık koltuk "Yapay Zeka" diye yazılır) ve
// bileşen içinde sınanamıyor. İmport yalnızca TİP — bu dosya Supabase
// istemcisini çekmez, `verify-random-games` onu düz esbuild ile bağlayabilir.
import type {
  MyRandomGame,
  OnlineGame,
  OnlineGameSlot,
  RandomGameResult,
  RandomListing,
} from '../lib/database.types';

// ── Koltuk türleri ──────────────────────────────────────────────────────────

/**
 * Koltuk AÇIK mı (Rastgele Oyuncu bekleniyor)?
 *
 * ⚠ İki biçim var: ham `{type:'open'}` (`list_my_random_games`) ve eski
 * istemci maskesi `{type:'ai', open:true}` (`list_my_online_games`, 3 Ekim
 * 2026). Maske yüzünden `type === 'ai'` kontrolü AÇIK koltuğu "Yapay Zeka"
 * sayardı — koltuğu çizen her yer bu fonksiyondan geçmeli.
 */
export function isOpenSeat(slot: OnlineGameSlot): boolean {
  return slot.type === 'open' || (slot.type === 'ai' && slot.open === true);
}

/** GERÇEK Yapay Zeka koltuğu (açık koltuk maskesi DEĞİL). */
export function isRealAiSeat(slot: OnlineGameSlot): boolean {
  return slot.type === 'ai' && slot.open !== true;
}

/**
 * "Bekliyor n/N" için DOLU koltuk sayısı. Yapay Zeka dolu sayılır (oyunu
 * beklemiyor); açık koltuk ve henüz yanıtlamamış arkadaş davetlisi (kurucu
 * hariç) dolu SAYILMAZ.
 */
export function filledSeatCount(slots: readonly OnlineGameSlot[]): number {
  return slots.filter((s) => {
    if (isOpenSeat(s)) return false;
    if (s.type === 'human') return s.invite_status !== 'pending';
    return true;
  }).length;
}

// ── Kova sınıflandırması (LiveGamesTab) ─────────────────────────────────────

/**
 * Rastgele ilanın KURUCUSU / ilandan KABUL EDENİ olduğum oyunların id'leri —
 * bunlar yalnızca "Devam Edenler"de ("Bekliyor n/N") görünür, davet kovalarına
 * (`waiting` = Bekleyen Oyunlar, `acceptedWaiting` = Kabul Ettin) GİRMEZ.
 *
 * ⚠ DÖRT KOVA DERSİ (live-game.md, 4 Ağustos 2026): `list_my_online_games`
 * bu oyunları AYRICA döndürür — kurucu `my_role='creator'`, kabul eden
 * `my_role='invitee' + 'accepted'` olarak. Süzmezsek aynı oyun iki sekmede
 * birden görünür.
 *
 * ⚠ `'friend'` GİRMEZ: karma kadroda arkadaş olarak davet edilen kişi için
 * bugünkü davet/kabul akışı AYNEN geçerli (`invites`/`acceptedWaiting`).
 * `list_my_random_games` onu da döndürüyor; id'ye körü körüne bakmak onun
 * davetini kaybettirirdi.
 *
 * `myRandom === null` = liste ALINAMADI. O durumda yalnızca KESİN olanı
 * saklıyoruz: açık koltuğu olan ve kurucusu ben olduğum oyun (açık koltuklu
 * oyunu yalnızca ilan RPC'si açabilir). Kabul edenin satırı geçici olarak
 * "Kabul Ettin"de görünebilir — arkadaş davetlisini yanlışlıkla gizlemekten
 * iyi.
 */
export function randomManagedIds(
  myRandom: readonly Pick<MyRandomGame, 'id' | 'my_role'>[] | null,
  rows: readonly OnlineGame[],
): Set<string> {
  const ids = new Set<string>();
  if (myRandom) {
    for (const r of myRandom) {
      if (r.my_role === 'creator' || r.my_role === 'random') ids.add(r.id);
    }
  }
  for (const g of rows) {
    if (g.my_role === 'creator' && g.status === 'pending' && g.slots.some(isOpenSeat)) ids.add(g.id);
  }
  return ids;
}

export interface LiveGameBuckets {
  invites: OnlineGame[];
  active: OnlineGame[];
  waiting: OnlineGame[];
  acceptedWaiting: OnlineGame[];
}

/**
 * `LiveGamesTab`'in dört kovası (sıralamasız). `invites` ve `active`
 * `countPendingActions` ile AYNI süzgeç; `managed` yalnızca bekleyen iki
 * kovayı (`waiting`/`acceptedWaiting`) daraltır — `active` ve `invites`
 * ETKİLENMEZ: oyun dolup başlayınca normal bir oyun gibi görünmeli, karma
 * kadrodaki arkadaşın bekleyen daveti bugünkü gibi sayılmalı.
 */
export function classifyLiveGames(
  rows: readonly OnlineGame[],
  managed: ReadonlySet<string>,
): LiveGameBuckets {
  return {
    invites: rows.filter(
      (g) => g.my_role === 'invitee' && g.my_invite_status === 'pending' && g.status === 'pending',
    ),
    active: rows.filter((g) => g.status === 'active'),
    waiting: rows.filter(
      (g) => g.my_role === 'creator' && g.status === 'pending' && !managed.has(g.id),
    ),
    acceptedWaiting: rows.filter(
      (g) =>
        g.my_role === 'invitee' &&
        g.my_invite_status === 'accepted' &&
        g.status === 'pending' &&
        !managed.has(g.id),
    ),
  };
}

/**
 * "Devam Edenler"de "Bekliyor n/N" satırı olarak görünecek benim ilanlarım:
 * kurucu olduğum ya da ilandan kabul ettiğim, HÂLÂ bekleyen oyunlar. Dolup
 * başlamış olan `active` kovasında zaten görünür (çift satır olmasın).
 * `'friend'` burada YOK (davet akışında).
 */
export function myWaitingRandomGames(
  myRandom: readonly MyRandomGame[] | null,
): MyRandomGame[] {
  return (myRandom ?? []).filter(
    (g) => g.status === 'pending' && (g.my_role === 'creator' || g.my_role === 'random'),
  );
}

// ── Şerit ───────────────────────────────────────────────────────────────────

/**
 * Şeridin gösterebileceği ilanlar: id ile TEKİLLEŞTİR (offset sayfalaması
 * kayar, sunucu aynı satırı iki kez verebilir), kendi ilanımı ve zaten içinde
 * olduğum oyunları ÇIKAR (sunucu zaten eler; ikinci emniyet), sırayı koru
 * (sunucu: en yeni önce).
 */
export function visibleListings(
  listings: readonly RandomListing[],
  myUserId: string | null,
  myGameIds: ReadonlySet<string>,
): RandomListing[] {
  const seen = new Set<string>();
  const out: RandomListing[] = [];
  for (const l of listings) {
    if (seen.has(l.id)) continue;
    seen.add(l.id);
    if (myUserId && l.creator_id === myUserId) continue;
    if (myGameIds.has(l.id)) continue;
    out.push(l);
  }
  return out;
}

/** Şerit kartındaki "N koltuk kaldı" — zaman/yaş bilgisi KONMAZ. */
export function seatsLeftLabel(open: number): string {
  return open === 1 ? '1 koltuk kaldı' : `${open} koltuk kaldı`;
}

// ── Kurulum formu: esnek kadro ──────────────────────────────────────────────

/**
 * Seçili koltuklardaki "Rastgele Oyuncu" işareti. Gerçek bir kullanıcı
 * kimliği (uuid) ile ÇAKIŞAMAZ.
 */
export const RANDOM_SEAT = '?';

/**
 * Rastgele satırına dokunuş (kullanıcı, 4 Ekim 2026: "seçildikten sonra tekrar
 * üstüne basınca geri alsın"): boş bir koltuğu "?" yapar. Boş koltuk KALMADIYSA ve
 * seçimde "?" varsa dokunuş TÜM "?" koltuklarını geri alır (2 kişide ikinci
 * dokunuş = geri al; 4 kişide ×3'ten sonraki dokunuş = geri al). Dolu ve "?" yoksa:
 * 2 kişide dolu arkadaş koltuğu DEĞİŞTİRİLİR (tek rakip), 4 kişide dokunuş etkisiz.
 */
export function addRandomSeat(selected: readonly string[], playerCount: 2 | 4): string[] {
  if (selected.length < playerCount - 1) return [...selected, RANDOM_SEAT];
  if (selected.includes(RANDOM_SEAT)) return selected.filter((s) => s !== RANDOM_SEAT);
  if (playerCount === 2) return [RANDOM_SEAT];
  return [...selected];
}

/** Arkadaş satırına dokunuş (eski `toggleFriend` ile AYNI kural; "?" koltukları korunur). */
export function toggleFriendSeat(
  selected: readonly string[],
  friendId: string,
  playerCount: 2 | 4,
): string[] {
  if (playerCount === 2) return selected.includes(friendId) ? [] : [friendId];
  if (selected.includes(friendId)) return selected.filter((id) => id !== friendId);
  if (selected.length >= 3) return [...selected];
  return [...selected, friendId];
}

/** Koltuk kartına dokunuş: o koltuğu boşaltır. */
export function removeSeatAt(selected: readonly string[], index: number): string[] {
  return selected.filter((_, i) => i !== index);
}

export const randomSeatCount = (selected: readonly string[]): number =>
  selected.filter((s) => s === RANDOM_SEAT).length;

/** En az bir "?" varsa kadro bir İLAN (`create_random_game`), yoksa bugünkü davet yolu. */
export const usesRandomSeat = (selected: readonly string[]): boolean => randomSeatCount(selected) > 0;

/** 2 kişide 1, 4 kişide en az 2 (ortadaki iki koltuk dolmalı). */
export function canSubmitSeats(selected: readonly string[], playerCount: 2 | 4): boolean {
  return playerCount === 2 ? selected.length === 1 : selected.length >= 2;
}

/** 4 kişide tam 2 seçim → 4. koltuk Yapay Zeka (bugünkü kural; rastgele kadroda da, karar B). */
export const aiLastSeat = (selected: readonly string[], playerCount: 2 | 4): boolean =>
  playerCount === 4 && selected.length === 2;

/**
 * `create_random_game`'e giden `p_slots`: koltuk 0 çağıran, sonra seçimler
 * (arkadaş → human, "?" → open), 4 kişide tam 2 seçimde sondaki YZ.
 */
export function buildRandomSlots(
  userId: string,
  selected: readonly string[],
  playerCount: 2 | 4,
): OnlineGameSlot[] {
  return [
    { type: 'human', user_id: userId },
    ...selected.map<OnlineGameSlot>((s) =>
      s === RANDOM_SEAT ? { type: 'open' } : { type: 'human', user_id: s },
    ),
    ...(aiLastSeat(selected, playerCount) ? [{ type: 'ai' } as OnlineGameSlot] : []),
  ];
}

// ── Metinler (port birebir aynısını kullanmalı) ─────────────────────────────

/** Kabul sonrası ileti. */
export function acceptNotice(r: Pick<RandomGameResult, 'started'>): string {
  return r.started ? 'Kabul ettin. Oyun başladı.' : 'Kabul ettin. Diğer oyuncular bekleniyor.';
}

/** "Davet Gönder" sonrası başlık + açıklama (onay ekranı). */
export function createdNotice(r: Pick<RandomGameResult, 'joined' | 'started'>): {
  title: string;
  body: string;
} {
  if (r.joined) {
    return {
      title: 'Oyuna katıldın',
      body: r.started
        ? 'Uygun bir ilan vardı, ona katıldın. Oyun başladı.'
        : 'Uygun bir ilan vardı, ona katıldın. Diğer oyuncular bekleniyor.',
    };
  }
  return {
    title: 'İlanın yayında',
    body: 'İlanın yayında. Biri kabul edince oyun başlar. 7 gün içinde dolmazsa kendiliğinden kalkar, ceza yok.',
  };
}

/** Şeridin ve kartların sabit yoklama aralığı (ms) — Realtime RLS yüzünden şerit olayla beslenemez. */
export const RANDOM_STRIP_POLL_MS = 40_000;
/** Öne dönüş/odak yoklamasının en sık tekrar aralığı (ms). */
export const RANDOM_STRIP_MIN_GAP_MS = 8_000;
/** Şerit yalnızca ilk sayfayı çeker. */
export const RANDOM_STRIP_LIMIT = 20;
