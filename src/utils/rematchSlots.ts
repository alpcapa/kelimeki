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
