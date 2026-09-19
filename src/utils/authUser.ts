/**
 * Oturum kullanıcısının KİMLİK SABİTLEYİCİSİ (19 Eylül 2026).
 *
 * ## Neden var
 *
 * `useAuth`'un `applyUser`'ı `setUser(u)`yu KOŞULSUZ çağırıyordu. Supabase
 * her `onAuthStateChange` olayında (token yenileme, sekmeye dönüş, aynı
 * oturumun yeniden okunması) **yeni bir `User` nesnesi** üretir — alanları
 * birebir aynı olsa bile. React için "yeni nesne = değişti" demek olduğundan,
 * `user` NESNESİNE bağlı her effect yeniden koşuyordu.
 *
 * Canlıda ölçüldü (19 Eylül 2026, tek oturum, iPhone Safari): **41 saniyede
 * 782 istek**, saniyede ~19. Bir auth olayı = bir tam veri turu, çünkü dokuz
 * effect `[user]`e bağlıydı: `Setup` (kayıtlı oyunlar), `Leaderboard`
 * (lider tablosu + k-lig ödülleri), `LiveGamesTab` (canlı oyunlar + durumlar
 * + görülmemiş bitişler), `UserMenu` (davetler + admin rozetleri),
 * `ScoreCard` (profil) ve `App` ×3. Loglardaki tur bu listeyle BİREBİR
 * örtüştü. Kullanıcının tarifi: *"sayfayı sürekli yüklemeye çalışıyor,
 * ekran deli gibi hareket ediyor, bir türlü durmuyor."*
 *
 * ## Kural
 *
 * Nesne YALNIZCA içeriği birebir aynıysa korunur. Bir alan bile değiştiyse
 * yeni nesne geçer, yani davranış bugünküyle aynı kalır — bu fonksiyon
 * hiçbir GÜNCELLEMEYİ yutmaz, yalnızca GEREKSİZ kimlik değişimini yutar.
 *
 * ⚠ Bu yüzden `id` karşılaştırması YETMEZ: uygulama `user.email`i de okuyor
 * (ölçüldü: `user.id` 86 kullanım, `user.email` 22) ve e-posta değişiminde
 * ekran bayatlardı. Alan listesi zamanla büyüyebileceği için karşılaştırma
 * tek tek alanlara DEĞİL, nesnenin tamamına bakar.
 *
 * ⚠ Anahtar sırası farklı gelirse karşılaştırma `false` döner ve bugünkü
 * davranışa düşeriz — yani başarısızlık yönü GÜVENLİ taraf.
 */

/**
 * Karşılaştırma için gereken TEK alan `id`; gerisi `JSON.stringify` ile
 * bütün olarak okunuyor. `Record<string, unknown>` ile KESİŞTİRİLMİYOR —
 * Supabase'in `User` arayüzünde indeks imzası yok ve öyle yazılırsa çağıran
 * tarafta TS2345 veriyor (ölçüldü). `id` dışındaki alanlara tip üzerinden
 * erişilmediği için bu dar tip yeterli.
 */
type AuthUserLike = { id: string };

/**
 * İki oturum kullanıcısı REACT AÇISINDAN aynı mı — yani öncekini yeniden
 * kullanmak güvenli mi?
 *
 * `null` ↔ `null` aynıdır (çıkış yapmış durumun kimliği de sabit kalsın).
 * Biri `null` ötekisi dolu ise FARKLIdır.
 */
export function sameAuthUser(a: AuthUserLike | null, b: AuthUserLike | null): boolean {
  if (a === b) return true;
  if (!a || !b) return false;
  if (a.id !== b.id) return false;
  try {
    return JSON.stringify(a) === JSON.stringify(b);
  } catch {
    // Döngüsel referans gibi beklenmedik bir durumda güvenli tarafa düş:
    // "farklı" de, nesne tazelensin.
    return false;
  }
}

/**
 * Bir `onAuthStateChange` olayının `user`'ı UYGULANMALI MI?
 *
 * ## Neden olayın ADINA bakmıyoruz (19 Eylül 2026, ÜÇÜNCÜ tur)
 *
 * İlk sürüm `SIGNED_OUT`/`INITIAL_SESSION` dışındaki `null` oturumları yok
 * sayıyordu. Canlıda ölçüldü: **yetmedi.** Aynı gün, iki düzeltme de
 * yayındayken (derleme `7353b50`) aynı hesapta iki dakikada ~52 tur daha
 * sayıldı — her turda `/auth/v1/user` + `/rest/v1/profiles`, yani
 * `fetchMyProfile` baştan koşuyor. Bu ancak `currentUserId`'nin `null`a
 * düşmesiyle olur, yani titreten olay ya `SIGNED_OUT` ya `INITIAL_SESSION`
 * adıyla geliyordu: **olay adı bir filtre değil.**
 *
 * Hangi olayın neden `null` yaydığı sunucu loglarından GÖRÜLEMEZ (istemci
 * konsolu bizde yok, kullanıcı iPhone Safari'de). O yüzden tahmini bırakıp
 * ÖLÇÜLEBİLİR olana bakıyoruz: **depodaki oturum.** Çıkış gerçekse
 * `supabase-js` kalıcı oturumu olayı yaymadan ÖNCE siler; yani depo da
 * boşsa çıkış gerçektir, depoda oturum duruyorsa olay gürültüdür.
 *
 * ## Üç durum
 *
 * | `hasSession` | `depodakiId` | Sonuç |
 * |---|---|---|
 * | `true` | — (okunmadı) | **uygula** — oturum var, tartışma yok |
 * | `false` | `undefined` | **bekle** — depo henüz okunmadı, karar verme |
 * | `false` | `null` | **uygula** — depo da boş, çıkış GERÇEK |
 * | `false` | `'u1'` | **yok say** — depoda oturum duruyor, olay gürültü |
 *
 * ⚠ Son satırı "her ihtimale karşı" uygulamaya çevirme: bu fonksiyonun
 * varlık sebebi tam olarak o. Bir kez `TOKEN_REFRESHED`e, bir kez olay adı
 * listesine güvenildi; ikisi de canlıda düştü.
 *
 * ⚠ Depo okuması `onAuthStateChange` geri çağrısının İÇİNDEN yapılamaz —
 * Supabase'in kendi kuralı: geri çağrı auth kilidini tutarken başka bir auth
 * çağrısı yapmak kilitlenme üretir. Çağıran `setTimeout(…, 0)` ile ertelemek
 * ZORUNDA (bkz. `useAuth.tsx`).
 */
export function shouldApplyAuthSession(
  hasSession: boolean,
  depodakiKullaniciId?: string | null,
): boolean {
  if (hasSession) return true;
  if (depodakiKullaniciId === undefined) return false;
  return depodakiKullaniciId === null;
}
