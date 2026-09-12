// Kelimeki — ilk oyunda gösterilen tanıtımın kapısı.
//
// 7 Eylül 2026'ya kadar burada tek bir bayrak vardı: ilk oyunda açılan Hızlı
// Başlangıç PENCERESİ görüldü mü. Pencerenin yerini "Oynayarak öğren"
// tanıtımı alınca (bkz. `tutorialScript.ts`) bayrak İKİYE ayrıldı, çünkü
// ikisi artık farklı soruları cevaplıyor:
//
//   `kelimeki:seen-quickstart`  → SALT OKUNUR MİRAS. Yalnızca 7 Eylül 2026
//     öncesi sürümler YAZDI. Bugün tek işi "bu cihaz eski pencereyi görmüş,
//     yani burada zaten oynanmış" demek — yani MEVCUT oyuncuyu tanımak.
//   `kelimeki:tutorial-seen`    → tanıtım gösterildi mi (bir kez).
//
// ⚠ Eski davranışta "Nasıl oynanır?"ı elle açıp kapatmak da quickstart'ı
// "görüldü" sayıyordu (pencere bir daha kendiliğinden açılmasın diye). Bu
// artık YAPILMIYOR: yardım sayfasını okumak tanıtımı TÜKETMEZ — yoksa
// oynamadan önce yardıma bakan yeni kullanıcı tanıtımı hiç göremezdi.
const STORAGE_KEY = 'kelimeki:seen-quickstart';
const TUTORIAL_SEEN_KEY = 'kelimeki:tutorial-seen';

/**
 * Bu cihaz 7 Eylül 2026 öncesindeki Hızlı Başlangıç penceresini gördü mü —
 * yani burada daha önce bir oyun başlatıldı mı. Artık YAZILMIYOR, yalnızca
 * "mevcut oyuncu" sinyali olarak okunuyor.
 *
 * localStorage kapalı/erişilemez olabilir; o durumda `true` dönüyoruz —
 * kapının varsayılanı "gösterme" tarafında olmalı (bkz. `shouldShowTutorial`).
 */
export function hasSeenQuickStart(): boolean {
  try {
    return localStorage.getItem(STORAGE_KEY) === '1';
  } catch {
    return true;
  }
}

/** Tanıtım bu cihazda gösterildi mi. */
export function hasSeenTutorial(): boolean {
  try {
    return localStorage.getItem(TUTORIAL_SEEN_KEY) === '1';
  } catch {
    return true;
  }
}

/**
 * "Gösterildi" işareti. Zoom balonundaki kuralın aynısı: gösterim, ekrana
 * GELMEKTİR — nasıl kapandığı (bitirildi mi, atlandı mı, yarıda kapatıldı mı)
 * sayacı etkilemez. Böylece tanıtım gerçekten "bir kere" gösterilir ve
 * yarıda kesilen bir tanıtım sonsuz döngüye dönüşmez.
 */
export function markTutorialSeen(): void {
  try {
    localStorage.setItem(TUTORIAL_SEEN_KEY, '1');
  } catch {
    // yoksay
  }
}

/**
 * Tanıtımın web'de yayına girdiği an. Bu andan ÖNCE açılmış bir hesap =
 * MEVCUT oyuncu → tanıtım gösterilmez, cihazı yeni olsa bile.
 *
 * Kullanıcı isteği (7 Eylül 2026): *"Sadece yeni gelenlere bir kere
 * gösterilecek. Mevcut gelmiş ve oynamış kişilere gösterilmeyecek."*
 */
export const TUTORIAL_LAUNCH_AT = '2026-09-07T00:00:00.000Z';

/** `shouldShowTutorial`ın okuduğu sinyaller — hepsi çağıranda hazır. */
export interface TutorialGateInput {
  /** Tanıtım bu cihazda zaten gösterildi mi (`hasSeenTutorial`). */
  seenTutorial: boolean;
  /** Cihaz eski Hızlı Başlangıç penceresini gördü mü (`hasSeenQuickStart`). */
  seenLegacyQuickStart: boolean;
  /** Bu cihazda/hesapta devam eden bir oyun var mı — "zaten oynamış" sinyali. */
  hasPlayed: boolean;
  /** Girişli kullanıcının hesap açılış zamanı (ISO); misafirde `null`. */
  accountCreatedAt: string | null;
}

/**
 * Tanıtım bu açılışta gösterilsin mi? Saf fonksiyon — dört sinyalin HEPSİ
 * "hayır" derse gösterilir; herhangi biri "bu kişi yeni değil" derse
 * gösterilmez. Kapının varsayılanı bilerek GÖSTERME tarafında: mevcut bir
 * oyuncuyu tanıtıma sokmak, yeni bir oyuncunun tanıtımı kaçırmasından daha
 * kötü (kullanıcı kararı, 7 Eylül 2026).
 *
 * ⚠ SINIR — misafirde cihaz dışına bakacak bir şey YOK: tarayıcısını
 * temizlemiş ya da yeni bir cihazdan gelen eski bir MİSAFİR oyuncu "yeni"
 * görünür ve tanıtımı bir kez daha görür. Girişli kullanıcıda bu delik
 * `accountCreatedAt` ile kapalı (hesap tanıtımdan eskiyse gösterilmez).
 */
export function shouldShowTutorial(input: TutorialGateInput): boolean {
  if (input.seenTutorial) return false;
  if (input.seenLegacyQuickStart) return false;
  if (input.hasPlayed) return false;
  if (input.accountCreatedAt !== null) {
    const acilis = Date.parse(input.accountCreatedAt);
    // Okunamayan bir tarihte de gösterme: kapının varsayılanı bu yönde.
    if (Number.isNaN(acilis) || acilis < Date.parse(TUTORIAL_LAUNCH_AT)) return false;
  }
  return true;
}

// Oyun İçi Mesajlaşma — Faz 1: Canlı oyun ekranındaki "Mesajlaşma" butonuna
// ilk kez basıldığında gösterilen hoşgeldin popup'ı, aynı bire bir desen.
const CHAT_INTRO_KEY = 'kelimeki:seen-chat-intro';

export function hasSeenChatIntro(): boolean {
  try {
    return localStorage.getItem(CHAT_INTRO_KEY) === '1';
  } catch {
    return true;
  }
}

export function markChatIntroSeen(): void {
  try {
    localStorage.setItem(CHAT_INTRO_KEY, '1');
  } catch {
    // yoksay
  }
}

// Oyun İçi Mesajlaşma — okunmamış mesaj göstergesi (rozet/sayı değil,
// yalnızca "Mesajlaşma" butonunun üstünde küçük bir kırmızı nokta). Oyuncu
// sohbeti bu oyun için en son ne zaman açtığını (son görülen mesajın
// created_at'i) cihaza yazar; bir sonraki girişte (ör. 1 gün sonra) bundan
// SONRA gelen ve kendisinin göndermediği bir mesaj varsa nokta çıkar —
// `OnlineGameScreen.tsx`'teki mesaj listesi ilk yüklendiğinde bununla
// karşılaştırılır. Cihaza özel (localStorage) — sunucuda okundu bilgisi
// tutulmuyor, bilinçli olarak kapsam dışı (bkz. CLAUDE.md).
function chatLastReadKey(gameId: string): string {
  return `kelimeki:chat-last-read:${gameId}`;
}

export function getChatLastReadAt(gameId: string): string | null {
  try {
    return localStorage.getItem(chatLastReadKey(gameId));
  } catch {
    return null;
  }
}

export function markChatRead(gameId: string, lastMessageAt: string): void {
  try {
    localStorage.setItem(chatLastReadKey(gameId), lastMessageAt);
  } catch {
    // yoksay
  }
}

// Karşılama katmanı (18 Ağustos 2026) — ilk gelen ziyaretçiye gösterilen
// tanıtım/karşılama sayfasını geçen kullanıcı bir daha görmez. Anahtar adı
// yukarıdaki iki kardeşinin kalıbını izliyor.
//
// Bu değer `src/main.tsx`'in geçiş fonksiyonu (`gec`) ve `<head>`'deki
// senkron kapı script'i (bkz. scripts/landing-plugin.js) tarafından
// PAYLAŞILIYOR — kapı script'i HTML'e gömülü düz JS olduğundan bu modülü
// import EDEMEZ; adı orada elle tekrarlanıyor ve bu sabitle senkron
// tutulmak zorunda (eklentinin kendi yorumunda da yazılı).
// Tahta zoom'u tanıtım balonu (1 Eylül 2026, kullanıcı isteği) — port
// ikizi: `FlagsStore.zoomHintShown` / `zoomTried` / `shouldShowZoomHint`.
// Kural İKİ değere birden bakıyor, tek bayrak yetmez: *"Deneyip
// büyütenlere bir daha gösterme. Hiç denememişse bir daha sefer tekrar
// göster."* — yani gösterim sayacı (tavan 2) VE "denedi mi" ayrı ayrı.
const ZOOM_HINT_SHOWN_KEY = 'kelimeki:zoom-hint-shown';
const ZOOM_TRIED_KEY = 'kelimeki:zoom-tried';

/** Balonun görüneceği en fazla oyun açılışı sayısı. */
export const ZOOM_HINT_MAX_SHOWS = 2;

function zoomHintShown(): number {
  try {
    return Number(localStorage.getItem(ZOOM_HINT_SHOWN_KEY) ?? '0') || 0;
  } catch {
    // Depolama kapalıysa "tavana ulaşıldı" varsayılır — aynı balonu her
    // açılışta göstermek, hiç göstermemekten kötü (quickstart ile aynı ilke).
    return ZOOM_HINT_MAX_SHOWS;
  }
}

function zoomTried(): boolean {
  try {
    return localStorage.getItem(ZOOM_TRIED_KEY) === '1';
  } catch {
    return true;
  }
}

/** Balon bu açılışta gösterilsin mi? (Port `shouldShowZoomHint`.) */
export function shouldShowZoomHint(): boolean {
  return !zoomTried() && zoomHintShown() < ZOOM_HINT_MAX_SHOWS;
}

/** Gösterime KARAR VERİLDİĞİNDE çağrılır — "gösterim" balonun ekrana
 *  gelmesidir, nasıl kapandığı sayacı etkilemez. */
export function bumpZoomHintShown(): void {
  try {
    localStorage.setItem(ZOOM_HINT_SHOWN_KEY, String(zoomHintShown() + 1));
  } catch {
    // yoksay
  }
}

/** Kullanıcı zoom'u DENEDİ — balon bir daha hiç gösterilmez. */
export function markZoomTried(): void {
  try {
    localStorage.setItem(ZOOM_TRIED_KEY, '1');
  } catch {
    // yoksay
  }
}

export const SEEN_INTRO_KEY = 'kelimeki:seen-intro';

// ── Bağlamsal ipuçları (Onboarding Faz 2, 8 Eylül 2026) ─────────────────────
//
// NEDEN VAR: tanıtım ("Oynayarak öğren") yalnızca YENİ gelene ve yalnızca BİR
// KEZ açılıyor, üstelik her sahnesinde "Atla" duruyor. Atlayan — ya da hiç
// göremeyen (mevcut cihaz bayrağı taşıyan, bkz. `shouldShowTutorial`) —
// oyuncu, Kelimeki'yi klasik kelime oyunlarından ayıran üç mekaniği hiç
// öğrenmeden oynuyordu. Bu ipuçları o boşluğu GERÇEK oyunda, mekanik
// YAŞANDIĞI anda kapatır: oyuncu hamlesini yapar, hemen ardından ne olduğunu
// tek cümlede okur.
//
// Desen zoom balonunun BİREBİR aynısı (1 Eylül 2026) ve bilerek öyle: cihaz
// yerel sayaç, tavan `ONBOARDING_HINT_MAX_SHOWS`, "gösterim" balonun EKRANA
// GELMESİDİR (nasıl kapandığı sayacı etkilemez), depolama kapalıysa varsayılan
// GÖSTERME tarafında. Her ipucunun kendi sayacı var — biri tavana çarpınca
// ötekiler susmaz, çünkü üçü farklı mekaniği anlatıyor ve oyuncu ikisini bir
// oyunda, üçüncüsünü haftalar sonra yaşayabilir.
export type OnboardingHintId = 'vergi' | 'carpan' | 'bolge';

/**
 * Bir ipucunun görüneceği en fazla hamle sayısı (ipucu BAŞINA).
 *
 * ⚠ **2 → 1 (12 Eylül 2026, kullanıcı kararı):** *"İlk defa oynayan kişiye
 * oyun sırasında çıkan max 6 gösterim iyi bir deneyim değil. Onu her bir
 * mesaj için 1 kere olacak şekilde düzelteceğiz."* Üç ipucu × tavan 2 =
 * oyuncunun görebileceği **6 balon**du; artık üçü de bir kez, yani en fazla
 * **3**. Tavanın ipucu BAŞINA olması DEĞİŞMEDİ — üçü farklı mekaniği
 * anlatıyor ve biri susunca ötekiler susmaz.
 */
export const ONBOARDING_HINT_MAX_SHOWS = 1;

/** Balonun ekranda kalma süresi (ms) — tanıtımdaki `RAKIP_OKUMA`nın iki katı:
 *  orada cümle "Rakip hamlesini yaptı", burada bir KURAL anlatılıyor. */
export const ONBOARDING_HINT_MS = 4000;

/**
 * İpucu metinleri — her biri TEK cümle (kullanıcı kararı, 7 Eylül 2026:
 * tanıtımın "tek cümle bütçesi" burada da geçerli).
 *
 * ⚠ Terim `bölge`, `sınır` DEĞİL (bkz. kök `CLAUDE.md` → "Terminoloji"):
 * `sınır ihlali` EYLEMİN adı, `bölge vergisi` BEDELİN adı. Tanıtımın 2.
 * sahnesi de aynı turda `sınırın büyür` → `bölgeni büyütürsün` diye
 * düzeltilmişti; üç ipucu o dille aynı hizada.
 */
export const ONBOARDING_HINT_TEXTS: Record<OnboardingHintId, string> = {
  vergi: 'Rakibin bölgesine değdin — bu yüzden puanının bir kısmı ona gitti.',
  carpan: 'Sarı bölgede kelime puanı 2 katı, tam ortadaki karede 3 katı olur.',
  bolge: 'Bölgen büyüdü — kendi taşlarınla ilerledikçe köşenin dışına taşar.',
};

/**
 * Aynı hamlede birden fazla ipucu hak edilebilir (4. tanıtım sahnesi tam
 * olarak böyleydi: hem ×3 hem vergi). Ekranda AYNI ANDA TEK BALON olacağından
 * sıra sabit ve bu sırayla: en şaşırtıcı olan önce.
 *
 *   vergi  → "puanım neden eksildi?" — sorulmadan cevaplanmazsa oyuncu bunu
 *            bir hata sanır (kayıtlı gerçek şikâyet sınıfı).
 *   carpan → puan zaten büyüdü; cümle o büyümenin ADINI koyar.
 *   bolge  → tahtada zaten GÖRÜNÜYOR (dış hat çizgisi büyüyor), yani en az
 *            açıklamaya muhtaç olan.
 */
export const ONBOARDING_HINT_ORDER: readonly OnboardingHintId[] = ['vergi', 'carpan', 'bolge'];

function hintKey(id: OnboardingHintId): string {
  return `kelimeki:hint-shown:${id}`;
}

function hintShown(id: OnboardingHintId): number {
  try {
    return Number(localStorage.getItem(hintKey(id)) ?? '0') || 0;
  } catch {
    // Depolama kapalıysa "tavana ulaşıldı" varsayılır — zoom balonuyla aynı
    // ilke: aynı cümleyi her hamlede göstermek, hiç göstermemekten kötü.
    return ONBOARDING_HINT_MAX_SHOWS;
  }
}

/** Üç sayacın tamamı — `pickOnboardingHint`e verilecek saf girdi. */
export function onboardingHintShownCounts(): Record<OnboardingHintId, number> {
  return { vergi: hintShown('vergi'), carpan: hintShown('carpan'), bolge: hintShown('bolge') };
}

/** Gösterime KARAR VERİLDİĞİNDE çağrılır (zoom balonundaki kuralın aynısı). */
export function bumpOnboardingHintShown(id: OnboardingHintId): void {
  try {
    localStorage.setItem(hintKey(id), String(hintShown(id) + 1));
  } catch {
    // yoksay
  }
}

/** Bir hamlenin HANGİ mekanikleri yaşattığı — çağıran motordan türetir. */
export interface OnboardingHintInput {
  /** Bu hamlede bir ya da daha fazla rakip bölgesine vergi ödendi mi. */
  paidTax: boolean;
  /** Bu hamlede kurulan kelimelerden biri ×2 ya da ×3 aldı mı. */
  gotMultiplier: boolean;
  /** Hamleden SONRA oyuncunun bölgesi kendi 4×4 köşe bloğunun DIŞINA taşıyor mu. */
  territoryOutsideCorner: boolean;
}

/**
 * Bu hamlede hangi ipucu gösterilsin? Saf fonksiyon — sayaçlar çağırandan
 * geliyor (depolama erişimi burada YOK, `verify-tutorial-script` tabloyu
 * doğrudan koşabilsin diye).
 *
 * `null` = gösterilecek ipucu yok (mekanik yaşanmadı ya da hepsi tavanda).
 */
export function pickOnboardingHint(
  input: OnboardingHintInput,
  shown: Record<OnboardingHintId, number>,
): OnboardingHintId | null {
  const hakEdilen: Record<OnboardingHintId, boolean> = {
    vergi: input.paidTax,
    carpan: input.gotMultiplier,
    bolge: input.territoryOutsideCorner,
  };
  for (const id of ONBOARDING_HINT_ORDER) {
    if (hakEdilen[id] && (shown[id] ?? 0) < ONBOARDING_HINT_MAX_SHOWS) return id;
  }
  return null;
}

// ── Oyun sonu kutlaması — "ilk kazanma" / "ilk puan" (12 Eylül 2026) ──────
//
// Kullanıcı isteği: *"oyun sonu modalında 'Tebrikler ilk puanını kazandın'
// mesajı (eğer kazanmışsa)"*, ardından ayrımı kendisi netleştirdi:
//
//   • GİRİŞLİ → *"Girişliyse sadece 'Tebrikler ilk oyununu kazandın'. Bunu
//     n oyun da oynasa, ilk kazandığında çıkartmalıyız."* Yani ölçüt oyun
//     SAYISI değil, ilk GALİBİYET — ve kaynağı cihaz değil HESAP (`wins`,
//     `player_stats_overall`). Cihaz bayrağı burada yanlış olurdu: telefonu
//     değiştiren ya da uygulamayı silip kuran kişi yıllar sonra yeniden
//     "ilk oyununu kazandın" görürdü.
//   • MİSAFİR → *"ilk puan alan kişiye 1 kere 'Tebrikler, ilk puanını
//     kazandın. Bu puanı kaybetmemek için hemen giriş yap'"*. Misafirin
//     hesabı YOK, yani sunucuda sayılacak bir şey de yok — tek olabilecek
//     kaynak cihaz bayrağı. Mesajın kendisi zaten bunun sebebini söylüyor:
//     puan kaydedilmiyor, kaydolmaya davet var.
//
// ⚠ İki dal AYNI şeyi ölçmüyor ve bu bilinçli: girişlide "kazandı" (1.
// sıra), misafirde "puan aldı" (k-lig puanı > 0). 2 kişilik oyunda ikisi
// aynı şeye denk düşüyor (2. sıra 0 puan alır), 4 kişilikte ayrışıyor —
// orada 2. sıra puan alır ama kazanmamıştır. Metinler de öyle diyor.
export type FirstWinCelebrationId = 'uye' | 'misafir';

/**
 * Kutlama metinleri. ⚠ Port ikizi `util/onboarding.dart` ile BİREBİR aynı
 * olmak zorunda (`tutorial_parity_test.dart` karşılaştırıyor).
 */
export const FIRST_WIN_TEXTS: Record<FirstWinCelebrationId, string> = {
  uye: 'Tebrikler, ilk oyununu kazandın!',
  misafir: 'Tebrikler, ilk puanını kazandın. Bu puanı kaybetmemek için hemen giriş yap.',
};

/**
 * Misafir metninin BUTONA dönüşen parçası. Ayrı bir sabit, çünkü çizim
 * tarafı cümleyi ikiye bölmek zorunda ve metni İKİNCİ KEZ yazmak bu
 * depodaki en sık bayatlama biçimi — `FIRST_WIN_TEXTS.misafir` tek kaynak
 * kalsın diye bölme bu parçadan yapılıyor.
 *
 * ⚠ Bu dizgi `FIRST_WIN_TEXTS.misafir`in İÇİNDE geçmek zorunda;
 * `verify-tutorial-script` bunu ayrıca kontrol ediyor (geçmezse buton hiç
 * çıkmaz ve kimse fark etmez).
 */
export const FIRST_WIN_GUEST_CTA = 'hemen giriş yap';

export interface FirstWinCelebrationInput {
  /** Hesapla mı oynanıyor. */
  signedIn: boolean;
  /** Bu oyunda 1. sırada bitirdi mi (`rankPlayers`). */
  won: boolean;
  /** Bu oyundan k-lig puanı kazandı mı (`leaguePoints(...) > 0`). */
  earnedPoints: boolean;
  /**
   * GİRİŞLİ dal: hesabın toplam galibiyet sayısı — **bu oyun DAHİL**
   * (`player_stats_overall.wins`, kayıt sunucuya düştükten SONRA okunur).
   * `null` = okunamadı (offline, istek düştü) → kutlama YOK.
   *
   * ⚠ "Bu oyun dahil" olması bir yarışı kapatıyor: kaydı yazmadan ÖNCE
   * okunsaydı `0` beklenirdi, ama kaydın yazılıp yazılmadığı bilinemezdi
   * ve çevrimdışı bir oyun sonunda mesaj YANLIŞ çıkardı. Sonradan okunan
   * `wins === 1` ise tek bir şeyi söyler: bu oyun sunucuya düştü VE
   * hesabın ilk galibiyeti. Kayıt düşmediyse sayı artmaz, mesaj çıkmaz —
   * güvenli yön.
   */
  totalWins: number | null;
  /** MİSAFİR dal: bu cihazda kutlama daha önce gösterildi mi. */
  guestCelebrated: boolean;
}

/**
 * Oyun sonu modalında hangi kutlama gösterilsin? Saf fonksiyon — depolama
 * ve ağ erişimi çağıranda (`verify-tutorial-script` tabloyu doğrudan
 * koşabilsin diye, `pickOnboardingHint` ile aynı gerekçe).
 *
 * `null` = kutlama yok.
 */
export function pickFirstWinCelebration(
  input: FirstWinCelebrationInput,
): FirstWinCelebrationId | null {
  if (input.signedIn) {
    // Girişlide ölçüt GALİBİYET, ve "ilk" hesabın kendi geçmişinden.
    if (!input.won) return null;
    return input.totalWins === 1 ? 'uye' : null;
  }
  // Misafirde ölçüt PUAN; "ilk" cihaz bayrağından.
  if (!input.earnedPoints || input.guestCelebrated) return null;
  return 'misafir';
}

const FIRST_POINTS_KEY = 'kelimeki:first-points-celebrated';

/** Misafir kutlaması bu cihazda gösterildi mi. */
export function guestFirstPointsCelebrated(): boolean {
  try {
    return localStorage.getItem(FIRST_POINTS_KEY) === '1';
  } catch {
    // Depolama kapalıysa "gösterilmiş" say — ipuçlarındaki ilkenin aynısı:
    // aynı kutlamayı her oyun sonunda tekrarlamak, hiç göstermemekten kötü.
    return true;
  }
}

/** Gösterime KARAR VERİLDİĞİNDE çağrılır (ipuçlarındaki kuralın aynısı). */
export function bumpGuestFirstPointsCelebrated(): void {
  try {
    localStorage.setItem(FIRST_POINTS_KEY, '1');
  } catch {
    // yoksay
  }
}
