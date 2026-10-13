// Rövanş kadrosunun kurulması — "Tekrar Oyna" biten bir Canlı oyunun
// kadrosunu AYNEN yeni bir oyuna taşır.
//
// NEDEN AYRI DOSYA (4 Eylül 2026): bu mantık 2 Eylül'e kadar yalnızca
// `OnlineGameScreen.tsx`in içinde, oyun ekranına gömülü bir yardımcıydı.
// "Tekrar Oyna" oyun geçmişindeki aksiyon menüsüne de eklenince İKİNCİ bir
// çağıran doğdu (`GameHistoryModal.tsx`) ve kopyalamak bu depoda defalarca
// ayrışmayla sonuçlanan hata sınıfının ta kendisi olurdu — sıralama kuralı
// sessizce değişse iki yüzey farklı kadro kurar ve `create_online_game`
// birinde patlar, ötekinde patlamaz.
//
// ⚠ SIRA KURALIN KENDİSİ, kozmetik değil. `create_online_game`in üç kısıtı:
//   (1) İlk koltuk ÇAĞIRAN olmak zorunda. Biten oyunu ben kurmamış
//       olabilirim (davet edilen taraf da rövanş açabilir), o yüzden kendimi
//       her hâlükârda başa alıyorum.
//   (2) 4 kişilikte YZ yalnız SON koltukta olabilir. İnsanları kendi
//       aralarındaki sırayla koruyup YZ'leri sona yazmak bunu kendiliğinden
//       sağlıyor.
//   (3) 2 kişilikte YZ zaten olamaz — biten oyun geçerliyse yenisi de
//       geçerli, ayrıca kontrol gerekmiyor.
//
// ⚠ RPC'ye YALNIZCA `type` + `user_id` gider. `list_my_online_games`in
// eklediği `name`/`avatar_url`/`relation`/`invite_status` alanları görüntü
// içindir; gönderilirse sunucu onları yok saymaz, gövdeyi şişirir ve
// ileride bir kısıt eklendiğinde sessizce reddedilme riski doğar.
//
// Dart ikizi: `mobile/app/lib/src/util/rematch_slots.dart`.
// Parite kontrolü: `npm run verify-rematch-slots`.
import type { OnlineGameSlot } from '../lib/database.types';
import { createdNotice } from './randomGames';

/**
 * Biten bir Canlı oyunun koltuklarından rövanş kadrosunu kurar.
 *
 * @param slots     Biten oyunun `online_games.slots` değeri.
 * @param myUserId  Rövanşı açan (çağıran) kullanıcı.
 * @returns `create_online_game`e verilecek koltuklar — çağıran başta,
 *          öteki insanlar özgün sıralarında, YZ'ler sonda.
 */
export function buildRematchSlots(
  slots: OnlineGameSlot[],
  myUserId: string,
): OnlineGameSlot[] {
  const humans = slots.filter(
    (s): s is Extract<OnlineGameSlot, { type: 'human' }> => s.type === 'human',
  );
  const aiCount = slots.filter((s) => s.type === 'ai').length;
  return [
    { type: 'human', user_id: myUserId },
    ...humans
      .filter((s) => s.user_id !== myUserId)
      .map((s) => ({ type: 'human' as const, user_id: s.user_id })),
    ...Array.from({ length: aiCount }, () => ({ type: 'ai' as const })),
  ];
}

/**
 * Rövanşta karşıya çıkacak insan oyuncuların adları — onay/sonuç metni için.
 *
 * Adı olmayan bir koltuk için `Bir arkadaşın` döner: `online_games.slots`
 * ham hâlde isim TAŞIMAZ (o alanı `list_my_online_games` ekliyor), yani
 * geçmişten açılan rövanşta isimler ayrıca verilmek zorunda.
 */
export function rematchOpponentNames(
  slots: OnlineGameSlot[],
  myUserId: string,
): string[] {
  return slots
    .filter(
      (s): s is Extract<OnlineGameSlot, { type: 'human' }> =>
        s.type === 'human' && s.user_id !== myUserId,
    )
    .map((s) => s.name ?? 'Bir arkadaşın');
}

/** Kadroda YZ var mı — onay metni "4. koltuk yine Yapay Zeka olacak" diyor. */
export function rematchHasAi(slots: OnlineGameSlot[]): boolean {
  return slots.some((s) => s.type === 'ai');
}

/**
 * ÇAĞIRANIN engellediği kişilerden, rövanş kadrosundaki İNSAN rakiplerin
 * adları (koltuk sırasıyla). Boş dizi = engelli rakip yok.
 *
 * NEDEN İSTEMCİDE (13 Ekim 2026, kullanıcı kararı): sunucu yalnızca "karşı
 * taraf beni engelledi mi" diye bakıyor (`_assert_invite_allowed`), yani
 * ENGELLEYEN kendi engellediği kişiye davet gönderebiliyor. Kullanıcı bunu
 * istemedi: engellediğiniz biriyle rövanşa basılırsa oyun KURULMAZ, önce
 * engeli kaldırmanız istenir ("Engel Ayarları" → `BlockedUsersModal`).
 * ⚠ Engellenen taraf için DEĞİŞMEDİ: istemci başkasının engel listesini
 * okuyamaz; düğme açık kalır, sunucunun "sizi engelledi" mesajı çıkar —
 * devre dışı bir düğme "beni engelledi" demek olurdu.
 *
 * `blocked`: `fetchBlockedUsers()` çıktısı (engel + sohbet engeli + açık
 * şikayet birleşimi). Yalnızca `userId`/`name` okunur.
 * Dart ikizi: `mobile/app/lib/src/util/rematch_slots.dart`.
 */
export function rematchBlockedOpponents(
  slots: OnlineGameSlot[],
  myUserId: string,
  blocked: { userId: string; name: string }[],
): string[] {
  const names = new Map(blocked.map((b) => [b.userId, b.name]));
  const out: string[] = [];
  for (const s of slots) {
    if (s.type !== 'human' || s.user_id === myUserId) continue;
    const name = names.get(s.user_id);
    if (name !== undefined) out.push(name);
  }
  return out;
}

/** "A kullanıcısını …" / "A ve B kullanıcılarını …" / "A, B ve C kullanıcılarını …". */
export function rematchBlockedMessage(names: string[]): string {
  const list =
    names.length <= 1
      ? (names[0] ?? '')
      : `${names.slice(0, -1).join(', ')} ve ${names[names.length - 1]}`;
  const noun = names.length > 1 ? 'kullanıcılarını' : 'kullanıcısını';
  return `${list} ${noun} engellediğiniz için önce engeli kaldırmanız gerekiyor.`;
}

// ── Yabancılı rövanş (S2, 13 Ekim 2026, kullanıcı kararı) ───────────────────
//
// Arkadaş olmayan bir insan rakip `create_online_game`da "Yalnızca
// arkadaşlarını davet edebilirsin" ile düşer. Karar: yabancı koltukları
// RASTGELE (açık) koltuğa döner, arkadaşlar davetli kalır, YZ yalnızca eski
// oyunda varsa son koltukta kalır (kendiliğinden YZ EKLENMEZ — yabancı yerine
// YZ koymak sessiz bir kadro değişikliği olurdu). Sunucu bunu zaten kabul
// ediyor: `create_random_game` (arkadaş + açık koltuk + 4 kişilikte son
// koltukta YZ). Dart ikizi: `util/rematch_slots.dart`.

export interface RematchPlan {
  /** 'friends' = bugünkü akış (`create_online_game`); 'random' = açık koltuklu ilan (`create_random_game`). */
  kind: 'friends' | 'random';
  /** Sunucuya gidecek koltuklar — çağıran başta, YZ sonda. */
  slots: OnlineGameSlot[];
  /** Davet edilecek (arkadaş) rakiplerin adları, koltuk sırasıyla. */
  friendNames: string[];
  /** Rastgele (açık) koltuk sayısı; 'friends' planında 0. */
  openCount: number;
}

/**
 * @param friends  arkadaş kimliği → ad. `null` = liste OKUNAMADI: bugünkü akış
 *                 (sunucu kendi kapısını uyguluyor) — hata "hiç arkadaşım yok"
 *                 diye OKUNMAZ, yoksa ağ hatası herkesi yabancı yapardı.
 */
export function buildRematchPlan(
  slots: OnlineGameSlot[],
  myUserId: string,
  friends: ReadonlyMap<string, string> | null,
): RematchPlan {
  const humans = slots.filter(
    (s): s is Extract<OnlineGameSlot, { type: 'human' }> =>
      s.type === 'human' && s.user_id !== myUserId,
  );
  const strangers = friends === null ? [] : humans.filter((s) => !friends.has(s.user_id));
  if (friends === null || strangers.length === 0) {
    return {
      kind: 'friends',
      slots: buildRematchSlots(slots, myUserId),
      // Ad önceliği: arkadaş listesi (kesin) → koltuktaki ad → yer tutucu.
      friendNames: humans.map((s) => friends?.get(s.user_id) ?? s.name ?? 'Bir arkadaşın'),
      openCount: 0,
    };
  }
  const aiCount = slots.filter((s) => s.type === 'ai').length;
  const kept = humans.filter((s) => friends.has(s.user_id));
  return {
    kind: 'random',
    slots: [
      { type: 'human', user_id: myUserId },
      ...kept.map((s) => ({ type: 'human' as const, user_id: s.user_id })),
      ...strangers.map(() => ({ type: 'open' as const })),
      ...Array.from({ length: aiCount }, () => ({ type: 'ai' as const })),
    ],
    friendNames: kept.map((s) => friends.get(s.user_id) ?? 'Bir arkadaşın'),
    openCount: strangers.length,
  };
}

/** Onay penceresinin metni. 'friends' planı bugünkü cümleyle BİREBİR aynı. */
export function rematchConfirmText(plan: RematchPlan, hasAi: boolean): string {
  const ai = hasAi ? ' 4. koltuk yine Yapay Zeka olacak.' : '';
  if (plan.kind === 'friends') {
    return `${plan.friendNames.join(', ')} ile aynı kadroda yeni bir oyun açılacak ve davet gönderilecek.${ai} Emin misin?`;
  }
  const who = plan.openCount === 1 ? 'oyuncunun' : 'oyuncuların';
  const what = plan.openCount === 1 ? 'rastgele bir oyuncu' : `${plan.openCount} rastgele oyuncu`;
  const head =
    plan.friendNames.length > 0
      ? `${plan.friendNames.join(', ')} davet edilecek; arkadaşınız olmayan ${who} yerine ${what} aranacak.`
      : `Arkadaşınız olmayan ${who} yerine ${what} aranacak.`;
  return `${head}${ai} Emin misin?`;
}

/**
 * Gönderim sonrası başlık + gövde ('random' planı). `joined` = sunucu yeni ilan
 * açmak yerine uygun bir ilana KATILDI (yalnızca arkadaşsız, YZ'siz kadroda
 * olabilir); iki durum ayrı metin alır. Metinler `randomGames.ts` →
 * `createdNotice`ten gelir, rövanş yalnızca davet notunu ekler.
 */
export function rematchSentNotice(
  plan: RematchPlan,
  result: { joined: boolean; started: boolean },
): { title: string; body: string } {
  const base = createdNotice(result);
  if (result.joined || plan.friendNames.length === 0) return base;
  return { title: base.title, body: `${base.body} ${plan.friendNames.join(', ')} davet edildi.` };
}
