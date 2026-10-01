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
// karşılaştırılır. ⚠ 23 Eylül 2026'dan beri bu cihazdaki damga yalnızca
// YEDEK: asıl damga sunucuda (`online_game_chat_reads`), iki kaynağın
// büyüğünü `decideChatRead` (`utils/chatRead.ts`) seçiyor.
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
// ikizi: `FlagsStore.zoomHintShown` / `zoomTried`.
// ⚠ 1 Ekim 2026'dan beri balon AÇILIŞTA değil, aşağıdaki ipucu SIRASININ
// üçüncü halkası olarak çıkıyor ve tavanı 1 (kullanıcı: *"hepsi 1 kere
// gösterim"*). İki anahtar duruyor: eski cihazlardaki sayaç "gösterildi"
// sayılıyor, zoom'u kendi DENEMİŞ oyuncuya da balon gösterilmiyor.
const ZOOM_HINT_SHOWN_KEY = 'kelimeki:zoom-hint-shown';
const ZOOM_TRIED_KEY = 'kelimeki:zoom-tried';

function zoomHintShown(): number {
  try {
    return Number(localStorage.getItem(ZOOM_HINT_SHOWN_KEY) ?? '0') || 0;
  } catch {
    // Depolama kapalıysa "gösterildi" varsayılır — aynı balonu her açılışta
    // göstermek, hiç göstermemekten kötü (quickstart ile aynı ilke).
    return 1;
  }
}

function zoomTried(): boolean {
  try {
    return localStorage.getItem(ZOOM_TRIED_KEY) === '1';
  } catch {
    return true;
  }
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

// ── Eğitim balonları (Onboarding Faz 2; akış 1 Ekim 2026'da yeniden kuruldu) ──
//
// NEDEN VAR: tanıtım ("Oynayarak öğren") yalnızca YENİ gelene ve yalnızca BİR
// KEZ açılıyor; oyunun ARAYÜZÜNÜ (menü, hamle geçmişi, torba, mesajlaşma) ve
// iki gizli etkileşimi (kelimeye dokununca anlam, çift dokununca zoom)
// anlatmıyor. Bu balonlar onları GERÇEK oyunda, birer kez söyler.
//
// ⚠ **1 Ekim 2026 — tek balon SIRAYA dönüştü (kullanıcı, 1.1.2 cihaz turu):**
// *"Eğitim balonlarına eklemeler var … Hepsi 1 kere gösterim … Zoom ve anlam
// balonlarını da bu gruba ekleyip akışı düşünmek lazım. Bence 2-3 hamle sonra
// Avatar menü ile başlasın. Sonra 4-5 hamle arayla … O kadar devam
// etmezlerse sorun yok. Yeniden geldiklerinde görürler."* Netleştirme:
// sayım TUR (herkes bir kez oynadı), mesaj EN SONA (misafir/YZ oyununda
// mesajlaşma yok), menü misafirde ATLANIR (sağ üstte avatar değil "Giriş").
//
// Kurallar (saf — `pickOnboardingHint`):
//   • sıra `ONBOARDING_HINT_ORDER`; her balon EN FAZLA BİR KEZ (cihaz sayacı);
//   • ekran açılışından `ONBOARDING_HINT_FIRST_ROUNDS` tur sonra ilki, sonra
//     bu ekranda gösterilen son balondan `ONBOARDING_HINT_GAP_ROUNDS` tur
//     sonra bir sonraki — oyun biterse kalanlar SONRAKİ açılışa kalır;
//   • bu ekranda ÇİZİLEMEYEN balon (Canlı'da menü/anlam, YZ oyununda mesaj,
//     misafirde menü, dolu köşede zoom) ATLANIR ve beklemez: sıradaki çizilebilir
//     balon gelir, atlanan ileride çizilebildiği bir yerde çıkar;
//   • `anlam` yalnızca tahtaya KELİME oturan hamlede ve açılıştan en az
//     `ONBOARDING_HINT_ANLAM_MIN_ROUNDS` tur sonra çıkar; sırası daha önce
//     gelmişse BEKLER, atlanmaz.
//
// Desen eski tek balonun aynısı: "gösterim" balonun EKRANA GELMESİDİR (nasıl
// kapandığı sayacı etkilemez), depolama kapalıysa varsayılan GÖSTERME.
export type OnboardingHintId = 'menu' | 'anlam' | 'zoom' | 'hamleler' | 'torba' | 'mesaj';

/**
 * Gösterim sırası. ⚠ Port `onboardingHintOrder` ile BİREBİR
 * (`tutorial_parity_test.dart` okuyor).
 */
export const ONBOARDING_HINT_ORDER: readonly OnboardingHintId[] = [
  'menu',
  'anlam',
  'zoom',
  'hamleler',
  'torba',
  'mesaj',
];

/**
 * Bir balonun görüneceği en fazla sayı (balon BAŞINA).
 *
 * ⚠ **2 → 1 (12 Eylül 2026, kullanıcı kararı):** *"İlk defa oynayan kişiye
 * oyun sırasında çıkan max 6 gösterim iyi bir deneyim değil. Onu her bir
 * mesaj için 1 kere olacak şekilde düzelteceğiz."*
 */
export const ONBOARDING_HINT_MAX_SHOWS = 1;

/**
 * Ekran açıldıktan sonra İLK balondan önce geçmesi gereken TUR sayısı
 * (bir tur = oyuncu sayısı kadar hamle; pas/değişim de hamle, vergi satırı
 * değil). Kullanıcı: *"2-3 hamle sonra Avatar menü ile başlasın"* — "hamle"
 * onun dilinde TUR (30 Eylül'de "karşılıklı 6-7 hamle = toplam 12-14").
 */
export const ONBOARDING_HINT_FIRST_ROUNDS = 2;

/**
 * İki balon arasında geçmesi gereken TUR sayısı (aynı ekranda). Kullanıcı:
 * *"4-5 hamle arayla"*. 2 kişilik oyunda sıra: menü 4. · anlam 12. (eski
 * `ONBOARDING_HINT_MIN_MOVES` = 12 ile AYNI yer, tahta artık orta dolu) ·
 * zoom 20. · hamleler 28. · torba 36. hamle — ilk oyun ~33 hamlede biter,
 * torba ve mesaj sonraki oyunlara kalır (kullanıcı: *"sorun yok"*).
 */
export const ONBOARDING_HINT_GAP_ROUNDS = 4;

/**
 * `anlam` balonunun açılıştan sayılan EN ERKEN turu — sıra ona erken gelse
 * de (misafirde menü atlanınca 2. tur) bekler. 30 Eylül 2026 kararının
 * korunması: *"karşılıklı 6-7 hamle … 12-14 toplam hamle sonra"* — tahta o
 * zaman ortaya doğru dolmuş olur, balon en üst satırda kesilmez.
 */
export const ONBOARDING_HINT_ANLAM_MIN_ROUNDS = 6;

/**
 * ⚠ **3 → 12 (1 Ekim 2026, kullanıcı, 1.1.2 cihaz turu):** iki hamleden sonra
 * çıkan balon tahtanın en üstündeydi. Balonun ÜSTTE yer bulamayacağı satır
 * sayısı: çapa bu satırlardaysa balon karenin ALTINA konur (yalnız `anlam`,
 * tahtaya çapalı tek balon). Balon dar ekranda iki satır (~1,5 hücre) +
 * kuyruk tutuyor.
 */
export const ONBOARDING_HINT_ALT_ROWS = 3;

/** Balon çapanın üstünde mi altında mı — `ONBOARDING_HINT_ALT_ROWS` kuralı. */
export function onboardingHintYon(r: number): 'ust' | 'alt' {
  return r < ONBOARDING_HINT_ALT_ROWS ? 'alt' : 'ust';
}

/** Balonun ekranda kalma süresi (ms) — tanıtımdaki `RAKIP_OKUMA`nın iki katı.
 *  Zoom balonu kendi `ZOOM_HINT_AUTO_HIDE_MS`ini kullanır (aynı değer). */
export const ONBOARDING_HINT_MS = 4000;

/**
 * Balon metinleri — her biri TEK cümle (kullanıcı kararı, 7 Eylül 2026:
 * tanıtımın "tek cümle bütçesi"). Menü/hamleler/torba/mesaj kullanıcının
 * kendi cümleleri (1 Ekim 2026). Zoom'un metni `boardZoom.ts`
 * `ZOOM_HINT_TEXT`te (tahta balonu, iki satır) — burada tekrarlanmıyor.
 */
export const ONBOARDING_HINT_TEXTS: Record<Exclude<OnboardingHintId, 'zoom'>, string> = {
  menu: 'Kullanıcı menüsü için tıkla.',
  anlam: 'Kelimenin üzerine tıklarsan anlamı gelir.',
  hamleler: 'Buradan tüm hamleleri görebilirsin.',
  torba: 'Dışarıda kalan taşlar burada.',
  mesaj: 'Buradan oyunculara mesaj gönderebilirsin.',
};

function hintKey(id: OnboardingHintId): string {
  return `kelimeki:hint-shown:${id}`;
}

function hintShown(id: OnboardingHintId): number {
  try {
    return Number(localStorage.getItem(hintKey(id)) ?? '0') || 0;
  } catch {
    // Depolama kapalıysa "tavana ulaşıldı" varsayılır — aynı cümleyi her
    // hamlede göstermek, hiç göstermemekten kötü.
    return ONBOARDING_HINT_MAX_SHOWS;
  }
}

/** Sayaçların tamamı — `pickOnboardingHint`e verilecek saf girdi. Zoom eski
 *  anahtarlarından okunur: gösterilmiş YA DA kendisi denenmiş = tamam. */
export function onboardingHintShownCounts(): Record<OnboardingHintId, number> {
  return {
    menu: hintShown('menu'),
    anlam: hintShown('anlam'),
    zoom: zoomTried() ? ONBOARDING_HINT_MAX_SHOWS : zoomHintShown(),
    hamleler: hintShown('hamleler'),
    torba: hintShown('torba'),
    mesaj: hintShown('mesaj'),
  };
}

/** Gösterime KARAR VERİLDİĞİNDE çağrılır. */
export function bumpOnboardingHintShown(id: OnboardingHintId): void {
  if (id === 'zoom') {
    bumpZoomHintShown();
    return;
  }
  try {
    localStorage.setItem(hintKey(id), String(hintShown(id) + 1));
  } catch {
    // yoksay
  }
}

/** Bir hamlenin ve ekranın durumu — çağıran türetir. */
export interface OnboardingHintInput {
  /** Ekran açıldığından beri oynanan hamle sayısı, bu hamle DAHİL (vergi
   *  satırı hariç; pas/değişim/teslim dahil — kimin oynadığından bağımsız). */
  movesSinceOpen: number;
  /** Oyuncu sayısı (tur = bu kadar hamle). */
  playerCount: number;
  /** Bu ekranda son balonun gösterildiği andaki `movesSinceOpen`; bu ekranda
   *  henüz balon çıkmadıysa `null`. */
  lastShownAt: number | null;
  /** Bu hamle tahtaya bir KELİME oturttu mu (`anlam`ın koşulu). */
  wordPlaced: boolean;
  /** Bu ekranda çizilebilen balonlar — çizilemeyen ATLANIR. */
  available: Readonly<Record<OnboardingHintId, boolean>>;
}

/**
 * Bu hamlede hangi balon gösterilsin? Saf fonksiyon — sayaçlar çağırandan
 * geliyor (depolama erişimi burada YOK, `verify-tutorial-script` tabloyu
 * doğrudan koşabilsin diye). `null` = bu hamlede balon yok.
 */
export function pickOnboardingHint(
  input: OnboardingHintInput,
  shown: Record<OnboardingHintId, number>,
): OnboardingHintId | null {
  const n = Math.max(1, input.playerCount);
  const acilistanTur = Math.floor(input.movesSinceOpen / n);
  const tur =
    input.lastShownAt === null
      ? Math.floor(input.movesSinceOpen / n)
      : Math.floor((input.movesSinceOpen - input.lastShownAt) / n);
  const esik = input.lastShownAt === null ? ONBOARDING_HINT_FIRST_ROUNDS : ONBOARDING_HINT_GAP_ROUNDS;
  if (tur < esik) return null;
  for (const id of ONBOARDING_HINT_ORDER) {
    if ((shown[id] ?? 0) >= ONBOARDING_HINT_MAX_SHOWS) continue;
    if (!input.available[id]) continue;
    // Anlam sırası geldiyse BEKLER: kelime oturmayan hamlede dokunulacak bir
    // kelime yok, ama atlamak da onu sona iterdi.
    if (id === 'anlam' && (!input.wordPlaced || acilistanTur < ONBOARDING_HINT_ANLAM_MIN_ROUNDS)) {
      return null;
    }
    return id;
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
