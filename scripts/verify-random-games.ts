// Kelimeki — Rastgele Oyuncu'nun SAF kurallarını ve rozet zincirine etkisini
// ÜRETİM kodunu import ederek doğrular (sahte Supabase ucu, `run-verify-random-games.mjs`).
// Tasarım: docs/decisions/random-opponent.md.
//
// NEDEN VAR: bu kuralların kırılma biçimi SESSİZ ve derleyici göremiyor —
//   · `list_my_online_games` kurucu/kabul eden oyunları AYRICA döndürür; kovalara
//     girerlerse aynı oyun iki sekmede görünür (4 Ağustos 2026 "dört kova" dersi),
//   · açık koltuk eski istemci maskesiyle `{type:'ai', open:true}` gelir ve
//     `type === 'ai'` kontrolü onu "Yapay Zeka" diye yazar,
//   · açık ilan HABERDİR, bekleyen iş DEĞİL: rozetleri/ikon rozetini/giriş
//     sekmesi kararını şişirmemeli.
//
// Koşum: npm run verify-random-games
import { readFileSync } from 'node:fs';
import { fetchRandomGames, fetchMyRandomGames } from '../src/lib/api';
import type { MyRandomGame, OnlineGame, OnlineGameSlot, RandomListing } from '../src/lib/database.types';
import { friendSuggestCandidates } from '../src/utils/friendSuggest';
import {
  RANDOM_SEAT,
  acceptNotice,
  addRandomSeat,
  isRandomOriginGame,
  aiLastSeat,
  buildRandomSlots,
  canSubmitSeats,
  classifyLiveGames,
  createdNotice,
  filledSeatCount,
  isOpenSeat,
  isRealAiSeat,
  myRandomToListing,
  myWaitingRandomGames,
  randomManagedIds,
  randomSeatCount,
  removeSeatAt,
  seatsLeftLabel,
  stripListings,
  toggleFriendSeat,
  usesRandomSeat,
  visibleListings,
} from '../src/utils/randomGames';
import {
  countPendingActions,
  decideInitialMainView,
  fetchPendingLiveGameCounts,
} from '../src/utils/pendingLiveGames';
import { __netCalls, __setFake } from './support/fake-supabase';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) console.log(`  ✓ ${name}`);
  else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}
const ids = (gs: readonly { id: string }[]) => gs.map((g) => g.id).join(',');

// ── Fixture: aynı hesabın (u1) listesinde yan yana duran altı oyun ───────────
const ME = { type: 'human', user_id: 'u1', relation: 'self' } as const;
const OTHER = { type: 'human', user_id: 'u2', relation: 'accepted', invite_status: 'accepted' } as const;
const OPEN_MASK: OnlineGameSlot = { type: 'ai', open: true };

function og(p: Partial<OnlineGame> & { id: string }): OnlineGame {
  return {
    created_by: 'u1',
    player_count: 2,
    status: 'pending',
    slots: [ME, OPEN_MASK],
    created_at: '2026-10-03T10:00:00Z',
    my_role: 'creator',
    my_invite_status: null,
    my_invite_id: null,
    ...p,
  };
}
const ROWS: OnlineGame[] = [
  // Ben kurucuyum, ilan açık.
  og({ id: 'kurucu' }),
  // İlandan kabul ettim (invitee + accepted), oyun hâlâ bekliyor.
  og({
    id: 'kabul',
    created_by: 'u2',
    my_role: 'invitee',
    my_invite_status: 'accepted',
    player_count: 4,
    slots: [{ ...OTHER, relation: 'accepted' }, ME, OPEN_MASK, OPEN_MASK],
  }),
  // KARMA kadro: arkadaş olarak çağrıldım, henüz yanıtlamadım.
  og({
    id: 'arkadas-bekliyor',
    created_by: 'u3',
    my_role: 'invitee',
    my_invite_status: 'pending',
    my_invite_id: 'inv1',
    slots: [{ type: 'human', user_id: 'u3', relation: 'accepted' }, ME, OPEN_MASK],
    player_count: 4,
  }),
  // KARMA kadro: arkadaş olarak kabul ettim, ilan hâlâ dolmadı.
  og({
    id: 'arkadas-kabul',
    created_by: 'u3',
    my_role: 'invitee',
    my_invite_status: 'accepted',
    slots: [{ type: 'human', user_id: 'u3', relation: 'accepted' }, ME, OPEN_MASK],
    player_count: 4,
  }),
  // Bugünkü arkadaş daveti — rastgele DEĞİL.
  og({ id: 'duz-bekleyen', slots: [ME, { type: 'human', user_id: 'u5', invite_status: 'pending' }] }),
  // Dolup başlamış (rastgele ilandan): normal oyun.
  og({
    id: 'aktif',
    status: 'active',
    created_by: 'u2',
    my_role: 'invitee',
    my_invite_status: 'accepted',
    slots: [{ ...OTHER }, ME],
  }),
];
const MYRANDOM = [
  { id: 'kurucu', my_role: 'creator' },
  { id: 'kabul', my_role: 'random' },
  { id: 'arkadas-bekliyor', my_role: 'friend' },
  { id: 'arkadas-kabul', my_role: 'friend' },
] as const;

function mr(id: string, role: MyRandomGame['my_role'], status: MyRandomGame['status'] = 'pending'): MyRandomGame {
  return {
    id,
    created_by: 'u1',
    player_count: 2,
    status,
    created_at: '2026-10-03T10:00:00Z',
    expires_at: '2026-10-10T10:00:00Z',
    slots: [{ type: 'human', user_id: 'u1' }, { type: 'open' }],
    filled_seats: 1,
    open_seats: 1,
    my_role: role,
    my_invite_id: null,
  };
}

async function main() {
  console.log('Rastgele Oyuncu — saf kurallar ve rozet zinciri\n');

  // ── 1) Açık koltuk "Yapay Zeka" DEĞİL ─────────────────────────────────────
  console.log('Koltuk türleri');
  check('ham {type:open} AÇIK', isOpenSeat({ type: 'open' }));
  check('maske {type:ai, open:true} AÇIK (eski istemci maskesi)', isOpenSeat(OPEN_MASK));
  check('gerçek {type:ai} açık DEĞİL', !isOpenSeat({ type: 'ai' }));
  check('maske YZ SAYILMAZ', !isRealAiSeat(OPEN_MASK));
  check('ham open YZ SAYILMAZ', !isRealAiSeat({ type: 'open' }));
  check('gerçek {type:ai} YZ', isRealAiSeat({ type: 'ai' }));
  check('insan koltuğu ne açık ne YZ', !isOpenSeat(ME) && !isRealAiSeat(ME));
  check(
    '"Bekliyor n/N": açık ve yanıtlamamış davetli dolu SAYILMAZ, YZ sayılır',
    filledSeatCount([
      { type: 'human', user_id: 'a' },
      { type: 'human', user_id: 'b', invite_status: 'pending' },
      { type: 'open' },
      { type: 'ai' },
    ]) === 2,
  );

  // ── 2) Dört kova: my_random id'si yalnızca Devam Edenler'e ────────────────
  console.log('\nKova sınıflandırması (dört kova dersi)');
  const managed = randomManagedIds(MYRANDOM, ROWS);
  check('kurucu ve kabul eden "yönetilen"', managed.has('kurucu') && managed.has('kabul'));
  check('arkadaş davetlisi (my_role friend) yönetilen DEĞİL', !managed.has('arkadas-bekliyor') && !managed.has('arkadas-kabul'));
  const b = classifyLiveGames(ROWS, managed);
  check('kurucu → "Bekleyen Oyunlar"a (waiting) GİRMEZ', !b.waiting.some((g) => g.id === 'kurucu'));
  check('kabul eden → "Kabul Ettin"e (acceptedWaiting) GİRMEZ', !b.acceptedWaiting.some((g) => g.id === 'kabul'));
  check('bugünkü arkadaş daveti waiting\'te KALIR', ids(b.waiting) === 'duz-bekleyen', ids(b.waiting));
  check('karma kadro: arkadaşın bekleyen daveti invites\'ta KALIR', ids(b.invites) === 'arkadas-bekliyor', ids(b.invites));
  check('karma kadro: arkadaşın kabulü acceptedWaiting\'te KALIR', ids(b.acceptedWaiting) === 'arkadas-kabul', ids(b.acceptedWaiting));
  check('dolup başlayan oyun active\'te (normal oyun)', ids(b.active) === 'aktif', ids(b.active));
  check(
    'Devam Edenler "Bekliyor" satırları = kurucu + kabul eden (arkadaş YOK)',
    ids(myWaitingRandomGames([mr('kurucu', 'creator'), mr('kabul', 'random'), mr('af', 'friend')])) === 'kurucu,kabul',
  );
  check(
    'başlamış ilan (status active) "Bekliyor" satırı OLMAZ (çift satır yok)',
    myWaitingRandomGames([mr('x', 'creator', 'active')]).length === 0,
  );
  // İlan listesi alınamadı (null): yalnızca KESİN olan gizlenir.
  const mNull = randomManagedIds(null, ROWS);
  const bNull = classifyLiveGames(ROWS, mNull);
  check('liste yokken açık koltuklu kurucu oyunu yine gizlenir', !bNull.waiting.some((g) => g.id === 'kurucu'));
  check('liste yokken arkadaş davetlisi GİZLENMEZ', bNull.invites.some((g) => g.id === 'arkadas-bekliyor'));

  // ── 3) Rozet zinciri: ilan HABERDİR, bekleyen iş DEĞİL ────────────────────
  console.log('\nRozetler (ilan haber, bekleyen iş değil)');
  const SADECE_ILAN = ROWS.filter((g) => g.id === 'kurucu' || g.id === 'kabul');
  const bos = countPendingActions([], {});
  const ilanli = countPendingActions(SADECE_ILAN, {});
  check(
    'kurucu + kabul eden oyunlar hiçbir sayaca düşmez',
    ilanli.inviteCount === bos.inviteCount && ilanli.myTurnCount === bos.myTurnCount,
    JSON.stringify(ilanli),
  );
  const hepsi = countPendingActions(ROWS, { aktif: 1 });
  check('yalnızca karma kadrodaki arkadaşın bekleyen daveti sayılır (=1)', hepsi.inviteCount === 1, `${hepsi.inviteCount}`);
  check('sıra bende sayacı yalnızca AKTİF oyundan (=1)', hepsi.myTurnCount === 1, `${hepsi.myTurnCount}`);

  __setFake({ rpcData: { list_my_online_games: SADECE_ILAN as unknown[] } });
  const sayilar = await fetchPendingLiveGameCounts();
  check(
    'fetchPendingLiveGameCounts: yalnızca ilanlı hesapta hepsi 0',
    !!sayilar && sayilar.inviteCount === 0 && sayilar.myTurnCount === 0 && sayilar.activeCount === 0,
    JSON.stringify(sayilar),
  );
  check(
    'giriş varsayılanı: yalnızca ilan varsa Canlı\'ya ZORLAMAZ (local)',
    !!sayilar && decideInitialMainView(sayilar, [{}]) === 'local',
  );
  check(
    'YZ tarafı boşken de ilan Canlı\'yı AÇTIRMAZ (activeCount=0)',
    !!sayilar && decideInitialMainView(sayilar, []) === 'local',
  );

  // ── 4) Şerit süzgeci ──────────────────────────────────────────────────────
  console.log('\nŞerit');
  const L = (id: string, creator: string): RandomListing => ({
    id,
    player_count: 2,
    created_at: '2026-10-03T10:00:00Z',
    creator_id: creator,
    creator_name: creator,
    creator_avatar_url: null,
    seats: ['creator', 'open'],
    open_seats: 1,
  });
  check(
    'id ile tekilleştirir, dışlananı (excludeIds) çıkarır, sırayı korur; kendi ilanımı creator_id\'ye bakıp ÇIKARMAZ',
    ids(visibleListings([L('a', 'x'), L('b', 'u1'), L('a', 'x'), L('c', 'y'), L('d', 'z')], new Set(['d']))) === 'a,b,c',
  );
  // §15: benim ilanım şeritte
  const mine1: MyRandomGame = {
    ...mr('m1', 'creator'),
    created_at: '2026-10-04T09:00:00Z',
    slots: [{ type: 'human', user_id: 'u1', name: 'Ben', avatar_url: 'a.png', relation: 'self' }, { type: 'open' }],
  };
  const mine2: MyRandomGame = {
    ...mr('m2', 'random'),
    created_by: 'u2',
    player_count: 4,
    open_seats: 1,
    created_at: '2026-10-04T10:00:00Z',
    slots: [
      { type: 'human', user_id: 'u2', name: 'Kurucu', avatar_url: null },
      { type: 'human', user_id: 'u1', via: 'random', invite_status: 'accepted', relation: 'self' },
      { type: 'human', user_id: 'u9', invite_status: 'pending' },
      { type: 'open' },
    ],
  };
  const l1 = myRandomToListing(mine1);
  check('benim kartım: kurucu adı/avatarı + koltuklar [creator, open]', l1.creator_name === 'Ben' && l1.creator_avatar_url === 'a.png' && l1.seats.join() === 'creator,open' && l1.open_seats === 1);
  const l2 = myRandomToListing(mine2);
  check('kabul ettiğim ilan: kurucu slots\'tan, koltuklar [creator, filled, invited, open]', l2.creator_name === 'Kurucu' && l2.seats.join() === 'creator,filled,invited,open', l2.seats.join());
  check('koltuk: gerçek YZ → ai, maske → open', myRandomToListing({ ...mine1, slots: [ME, { type: 'ai' }, OPEN_MASK] }).seats.join() === 'creator,ai,open');
  check('eylem rolü: creator → creator (İptal), random → random (Ayrıl)', l1.mine === 'creator' && l2.mine === 'random');
  const strip = stripListings([L('a', 'x'), L('m1', 'u1'), L('c', 'y'), L('a', 'x')], [mine1, mine2, mr('f', 'friend'), mr('x', 'creator', 'active')]);
  check('şeritte benim ilanım VAR; benimkiler ÖNCE (en yeni önce), sonra başkaları', ids(strip) === 'm2,m1,a,c', ids(strip));
  check('yinelenme yok: sunucu listesindeki kendi id\'m düşer, benim kartım kazanır', strip.filter((x) => x.id === 'm1').length === 1 && strip.find((x) => x.id === 'm1')?.mine === 'creator');
  check('Kabul YOK = yalnızca mine olmayan kartlar kabul edilebilir (a, c)', strip.filter((x) => !x.mine).map((x) => x.id).join() === 'a,c');
  check('yalnız benim ilanım varken şerit görünür (başkaları boş)', ids(stripListings([], [mine1])) === 'm1');
  check('ilan yok → şerit boş', stripListings([], []).length === 0 && stripListings([], null).length === 0);
  check('başlık sayısı benimkileri de sayar', stripListings([L('a', 'x')], [mine1]).length === 2);
  check('arkadaş/aktif oyun şeritte çıkmaz (başkaları listesinde olsa bile)', ids(stripListings([L('f', 'x'), L('x', 'y')], [mr('f', 'friend'), mr('x', 'creator', 'active')])) === '');
  check('"N koltuk kaldı" (zaman YOK)', seatsLeftLabel(1) === '1 koltuk kaldı' && seatsLeftLabel(3) === '3 koltuk kaldı');

  // ── 5) Esnek kadro ────────────────────────────────────────────────────────
  console.log('\nRastgele kökenli oyun işareti (Devam Edenler)');
  check('ilandan oturan koltuk (via:random) → rastgele kökenli', isRandomOriginGame([{ type: 'human', user_id: 'a' }, { type: 'human', user_id: 'b', via: 'random' }]));
  check('arkadaş daveti oyunu (via yok) → rastgele DEĞİL', !isRandomOriginGame([{ type: 'human', user_id: 'a' }, { type: 'human', user_id: 'b' }]));
  check('karma kadro: arkadaş + ilandan oturan → rastgele kökenli', isRandomOriginGame([{ type: 'human', user_id: 'a' }, { type: 'human', user_id: 'f' }, { type: 'human', user_id: 'r', via: 'random' }, { type: 'ai' }]));
  check('yalnız YZ koltuğu → rastgele DEĞİL', !isRandomOriginGame([{ type: 'human', user_id: 'a' }, { type: 'ai' }]));
  console.log('\nEsnek kadro (kurulum formu)');
  check('2 kişi: ? ekler', addRandomSeat([], 2).join() === RANDOM_SEAT);
  check('2 kişi: ? seçiliyken tekrar dokunuş GERİ ALIR', addRandomSeat([RANDOM_SEAT], 2).length === 0);
  check('4 kişi: ×3 doluyken dokunuş tüm ?\'leri geri alır', addRandomSeat([RANDOM_SEAT, RANDOM_SEAT, RANDOM_SEAT], 4).length === 0);
  check('4 kişi: arkadaş + ?? doluyken dokunuş yalnız ?\'leri geri alır', addRandomSeat(['f1', RANDOM_SEAT, RANDOM_SEAT], 4).join() === 'f1');
  check('4 kişi: ×2 doluyken (boş koltuk var) dokunuş ÜÇÜNCÜYÜ ekler', randomSeatCount(addRandomSeat([RANDOM_SEAT, RANDOM_SEAT], 4)) === 3);
  check('2 kişi: dolu koltukta ? onu DEĞİŞTİRİR (tek rakip)', addRandomSeat(['f1'], 2).join() === RANDOM_SEAT);
  check('2 kişi: arkadaş dolu ?\'yi değiştirir', toggleFriendSeat([RANDOM_SEAT], 'f1', 2).join() === 'f1');
  check('4 kişi: ? ve arkadaş karışır', addRandomSeat(['f1'], 4).join() === `f1,${RANDOM_SEAT}`);
  check('4 kişi: en çok 3 seçim', addRandomSeat(['a', 'b', 'c'], 4).length === 3 && toggleFriendSeat(['a', 'b', 'c'], 'd', 4).length === 3);
  check('4 kişi: üç ? alınabilir', randomSeatCount(addRandomSeat(addRandomSeat(addRandomSeat([], 4), 4), 4)) === 3);
  check('koltuk kartına dokunmak o koltuğu boşaltır', removeSeatAt(['a', RANDOM_SEAT, 'b'], 1).join() === 'a,b');
  check('4 kişi: 1 seçim gönderilemez', !canSubmitSeats(['a'], 4));
  check('4 kişi: 2 seçim gönderilir ve 4. koltuk YZ', canSubmitSeats(['a', RANDOM_SEAT], 4) && aiLastSeat(['a', RANDOM_SEAT], 4));
  check('4 kişi: 3 seçimde YZ YOK', !aiLastSeat(['a', 'b', 'c'], 4));
  check('2 kişide YZ hiç yok', !aiLastSeat(['a'], 2) && !aiLastSeat([RANDOM_SEAT, RANDOM_SEAT], 2));
  check('"?" yoksa bugünkü yol (ilan DEĞİL)', !usesRandomSeat(['a', 'b']) && usesRandomSeat(['a', RANDOM_SEAT]));
  const s2 = buildRandomSlots('u1', [RANDOM_SEAT], 2);
  check('2 kişi p_slots: [ben, open]', s2.length === 2 && s2[0].type === 'human' && s2[1].type === 'open');
  const s4 = buildRandomSlots('u1', ['f1', RANDOM_SEAT], 4);
  check(
    '4 kişi 2 seçim p_slots: [ben, arkadaş, open, ai]',
    s4.length === 4 && s4[1].type === 'human' && s4[2].type === 'open' && s4[3].type === 'ai',
    JSON.stringify(s4),
  );
  const s4b = buildRandomSlots('u1', [RANDOM_SEAT, RANDOM_SEAT, 'f1'], 4);
  check('4 kişi 3 seçim p_slots: 4 koltuk, YZ yok', s4b.length === 4 && !s4b.some((s) => s.type === 'ai'));
  check('açık koltuk p_slots\'ta user_id TAŞIMAZ', s4.every((s) => s.type !== 'open' || !('user_id' in s)));

  // ── 6) Metinler ───────────────────────────────────────────────────────────
  console.log('\nMetinler');
  check('kabul + başladı', acceptNotice({ started: true }) === 'Kabul ettin. Oyun başladı.');
  check('kabul + bekliyor', acceptNotice({ started: false }) === 'Kabul ettin. Diğer oyuncular bekleniyor.');
  check('uygun ilana katılma metni', createdNotice({ joined: true, started: false }).body.startsWith('Uygun bir ilan vardı, ona katıldın.'));
  check(
    'yeni ilan metni (7 gün, ceza yok)',
    createdNotice({ joined: false, started: false }).body ===
      'İlanın yayında. Biri kabul edince oyun başlar. 7 gün içinde dolmazsa kendiliğinden kalkar, ceza yok.',
  );

  // ── 7) Ağ hatası ↔ boş liste ──────────────────────────────────────────────
  console.log('\nListe uçları: ağ hatası ↔ boş');
  __setFake({ offline: true });
  check('list_random_games ağ hatası → null (boş dizi DEĞİL)', (await fetchRandomGames()) === null);
  __setFake({ offline: true });
  check('list_my_random_games ağ hatası → null', (await fetchMyRandomGames()) === null);
  __setFake({ rpcData: { list_random_games: [] } });
  const bosSerit = await fetchRandomGames();
  check('sunucu boş dedi → [] ve tek çağrı', Array.isArray(bosSerit) && bosSerit.length === 0 && __netCalls() === 1);

  // ── 8) Kaynak taraması: koltuğu çizen yerler maskeyi YZ sanmasın ──────────
  console.log('\nKaynak taraması');
  for (const f of ['LiveGamesTab.tsx', 'RandomGamesStrip.tsx', 'LiveGameCreateForm.tsx']) {
    const src = readFileSync(`src/components/${f}`, 'utf8').replace(/\/\/.*$/gm, '').replace(/\/\*[\s\S]*?\*\//g, '');
    check(`${f}: ham \`type === 'ai'\` kontrolü YOK (isRealAiSeat/isOpenSeat kullanılır)`, !/type\s*===\s*'ai'/.test(src));
  }
  const tab = readFileSync('src/components/LiveGamesTab.tsx', 'utf8');
  check('LiveGamesTab kovaları classifyLiveGames\'ten alıyor', /classifyLiveGames\(/.test(tab) && /randomManagedIds\(/.test(tab));

  const strip8 = readFileSync('src/components/RandomGamesStrip.tsx', 'utf8');
  check('şerit "Bekliyor" etiketi + İptal/Ayrıl içeriyor; LiveGamesTab handleLeaveRandom\'u geçiriyor', /Bekliyor/.test(strip8) && /'İptal'/.test(strip8) && /onLeaveMine=\{/.test(tab));

  // Oyun sonu arkadaş önerisi (4 Ekim 2026)
  {
    const H = (id: string, relation?: 'self' | 'accepted' | 'pending_outgoing' | 'pending_incoming' | null): OnlineGameSlot =>
      ({ type: 'human', user_id: id, name: id, relation }) as OnlineGameSlot;
    const slots: OnlineGameSlot[] = [H('me', 'self'), H('a', 'accepted'), H('b', 'pending_outgoing'), H('c', 'pending_incoming'), H('d', null), { type: 'ai' } as OnlineGameSlot, H('d', null)];
    const ids = friendSuggestCandidates(slots, 'me', new Set()).map((c) => c.user_id);
    check('öneri: yalnız gelen-istek + ilişkisiz (c, d), tekrarsız', ids.join(',') === 'c,d', ids.join(','));
    const ids2 = friendSuggestCandidates(slots, 'me', new Set(['d'])).map((c) => c.user_id);
    check('öneri: güncel arkadaş listesindeki (d) elenir — slot.relation bayat olabilir', ids2.join(',') === 'c', ids2.join(','));
    check('öneri: açık koltuk/YZ aday olmaz', friendSuggestCandidates([{ type: 'open' } as OnlineGameSlot, { type: 'ai' } as OnlineGameSlot], 'me', new Set()).length === 0);
  }

  console.log(failures === 0 ? '\nTümü geçti.' : `\n${failures} kontrol düştü.`);
  process.exit(failures === 0 ? 0 : 1);
}

void main();
