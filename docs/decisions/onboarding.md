# Onboarding — "Oynayarak öğren" tanıtımı

> Kök `CLAUDE.md`'nin karar kayıtları indeksinden gelindi. Burada tarihli
> gerekçe ve ölçümler var; her yerde geçerli kurallar kökte kalır.

## Neden değişti (7 Eylül 2026, kullanıcı isteği)

Kullanıcının sözleri: *"Onboarding konusunda çok zayıf durumdayız. Kişiler
ilk oyun açtığında basit ve sıkıcı bir Hızlı başlangıç'la karşılaşıyor ve
çoğu kişi de okumuyor ve direkt oyuna giriyor. Orada ne yapacağını bilmediği
için sıkılıp çıkıyor."*

Teşhis üç maddeydi ve üçü de kayıtlıydı:

1. **İlk oyunda açılan şey bir METİNDİ.** `Setup.doStart` →
   `onStart(list, !hasSeenQuickStart(), level)` → App `HelpModal`'ı açıyordu:
   9 maddelik Hızlı Başlangıç. Kapatmanın bedeli tek dokunuş, kapatınca
   geriye hiçbir şey kalmıyordu.
2. **Aynı ders bir kez daha alınmıştı.** Tahtadaki "Buradan başla" balonu
   (26 Ağustos 2026) tam da kapalı testte insanların KURALI değil İLK
   HAMLEYİ bulamadığı görüldüğü için eklenmişti — yani okunan cümle,
   tahtaya bakarken hatırlanmıyor.
3. **Farkımız hiç yaşanmıyordu.** Köşe, genişleyen bölge, bölge vergisi,
   merkez çarpanı — Kelimeki'yi klasik kelime oyunlarından ayıran her şey
   ilk 60 saniyede hiç deneyimlenmiyordu.

## Senaryo — dört sahne, her birinin ardından rakip oynar

Kullanıcının iki düzeltmesi (aynı gün, planın ilk hâline karşı):
*"Yukarıdan başlayıp önce X2/3 bölgesine gelip onu öğretelim, sonra rakip
bölge temasına geçelim"* ve *"her yaptığı hareket sonrası rakipte hamle
yapsın ki gerçek simülasyon olsun"*.

İkisi de senaryonun geometrisini belirledi:

| # | Oyuncu | Ne öğretiyor | Rakibin cevabı | Skor |
|---|---|---|---|---|
| 1 | **BÜYÜ** `0,0→0,3` +12 | ev karesi zorunlu başlangıç | **KUYU** `9,12↓12,12` +8 | 12–8 |
| 2 | **ÜZENGİ** `0,3↓5,3` +15 | bölge kendi taşlarıyla büyür | **TABAK** `9,8→9,12` +7 | 27–15 |
| 3 | **İNSAN** `5,3→5,7` +12 (6×2) | merkezde puan iki katı | **SAAT** `6,8↑9,8` +10 (5×2) | 39–25 |
| 4 | **SES** `6,6→6,7` +19 (9'u rakibe) | merkez karesi ×3 **ve** sınıra değmenin bedeli | **NAR** `5,4↓7,4` +4 (2'si bize) | 60–38 |

Sıranın "merkez önce, vergi sonra" olmasının teknik sebebi: oyuncunun
zinciri sol üst köşeden aşağı ilerliyor, yani önce ortadaki altın bölgeye
varıyor; rakibin kırmızı sınırına ancak ondan sonra komşu oluyor. Ters
sırada senaryo tahtayı "ileri sarmak" (birkaç hamleyi atlayıp tahtayı
doldurmak) zorunda kalıyordu — kullanıcının düzeltmesi bu ihtiyacı da
ortadan kaldırdı.

**4. sahne iki dersi TEK hamlede veriyor** (kullanıcı kararı, 7 Eylül 2026:
*"4. slaytta hem X3 alsın hem de sınır ihlali yapsın"*). Geometri buna zaten
uygundu: merkez karesi `6,6` ile rakibin `SAAT` sütunu `6,8` arasında tek boş
kare var. İki taş (S ve E) üç kelime birden kuruyor —

- `SES` = S(6,6) + E(6,7) + **rakibin** S(6,8) → X3 karesine yeni taş: **×3**
- `AS` = A(5,6) üstte + S(6,6) → aynı X3 hücresi, o da **×3**
- `NE` = N(5,7) üstte + E(6,7) → altın bölgede: **×2**

vergi öncesi 28 puan, 9'u rakibe. Yani oyuncu tek hamlede hem merkezin
gerçek gücünü hem de bedelini görüyor; üstelik kelimesini rakibin taşına
ekleyerek kuruyor. Balon X3'ü söylüyor, vergiyi gerçek oyundaki
`Sınır İhlali!` penceresi anlatıyor — tek cümle bütçesi böyle korunuyor.

**Rakibin cevapları iki dersi bedavaya tekrar ediyor:** 3. cevabında (SAAT)
rakip de merkeze girip ×2 alıyor, 4. cevabında (NAR) OYUNCUNUN sınırına
değip ona 2 puan ödüyor — verginin iki yönlü olduğu tek cümle harcamadan
görünüyor.

**Bitmeyen ders — bingo:** X3 artık 4. sahnede öğretildiğinden kapanış
kartının kancası değişti: *"7 taşını tek hamlede oynarsan +25 bingo bonusu
var — gerçek oyunda dene."* Geriye bilerek öğretilmeyen iki şey kalıyor
(bingo ve joker); tanıtımın işi her şeyi anlatmak değil, merak bırakmak.

## Mimari — motor değişmedi

Tanıtım gerçek `gameReducer` ile oynanır (puanı, geçerliliği, vergiyi,
çarpanı hesaplayan aynı kod), ama:

- **Yeni action YOK, yeni `GameState` alanı YOK.** Bu depoda motorun DÖRT
  kopyası var (`src/`, Dart portu, Edge `_game/`, SQL aynası); motora
  dokunan her değişiklik dördünü birden bakım işine çevirir. Tanıtım bir UI
  işidir. Senaryo `RESUME_SAVED` bile kullanmaz: `createTutorialState`
  doğrudan bir `GameState` kurup `useReducer`'ın başlangıç değeri olur.
- **Ayrı bileşen, ayrı reducer.** `TutorialGame` App'in state'ine hiç
  dokunmaz; App'in otomatik kayıt / bulut kaydı / telemetri / k-lig
  effect'lerinin hiçbiri bu ekranda çalışmaz. Sonuç: tanıtım bir "oyun"
  olarak sayılmaz — `logGameStart` çağrılmaz (huninin "Başlayan" adımı
  kirlenmez), `games` satırı açılmaz, istatistik/k-lig etkilenmez,
  terk-edilme cezası üretmez. Gerçek oyun ancak tanıtım kapanınca
  (`startLocalGame`) başlar.
- **Torba ve raflar senaryolu.** `createTutorialState` torbayı rastgele
  kurmaz: `DRAW_ORDER` çekilme sırasını tam olarak yazar (`drawTiles`
  torbanın SONUNDAN `pop` ettiği için dizi tersine çevrilir). Torbanın
  dibinde hiç çekilmeyen dolgu taşları durur — boş torba + boşalan raf
  `endGame`'i tetiklerdi.

### `Board`'a eklenen iki opsiyonel prop

- `targets` — o sahnenin hedef kareleri; boşken kesikli mavi çerçeve +
  mevcut `animate-tile-pulse`. Sürükleme hedefi vurgusu (`dragOverKey`) bunu
  bilerek EZER: elindeki taşın nereye düşeceği o an daha acil bir soru.
- `coach` — bir kareyi işaret eden tek cümle. Verilirse **"Buradan başla"
  balonu bastırılır**: ekranda aynı anda tek balon olmalı (ilk sahne zaten
  ev karesini işaret ediyor, ikisi üst üste binerdi). Yerleşim "Buradan
  başla"nın aynısı — karenin yanında, tahtanın içine doğru; kenar
  karelerinde taşmayan tek düzen bu.

## Raylar — oyuncu kaybolamaz ama gerçekten oynar

- İşaretli kareye dokunmak DOĞRU harfi raftan otomatik getirir (tek dokunuş
  ≈ 1 sn). 15 taşlık senaryo 60 saniyelik bütçeye ancak böyle sığıyor.
- Konan taşa tekrar dokunmak geri alır (`RECALL_CELL`).
- Hedef dışı kareler **sessizce** reddedilir — hata mesajı yok, tanıtımda
  "yanlış yaptım" duygusu olmamalı.
- Pas / taş değiştirme / joker tanıtımda YOK; ilk 60 saniyenin konusu değil.
- 4. sahnede gerçek oyundaki `Sınır İhlali!` onay penceresi çıkar (üstüne
  tanıtımın tek satırlık açıklaması) — oyuncu o pencereye de alışsın diye.

## Doğrulama — `npm run verify-tutorial-script`

Tanıtım ekranda PUAN yazıyor ("6 × 2 = 12", "28 puanın 9'u rakibe gitti").
Bu sayılar elle yazıldığından motordaki bir kural değişikliği onları
sessizce bayatlatabilirdi. Betik senaryoyu gerçek motorda oynatıp şunları
kilitler: hedef kareler boş, gereken harf rafta (torba sırası!), hamle
geçerli, skor deltaları ve verginin YÖNÜ, çarpanın varlığı/yokluğu,
`raw × 2 = points + tax` eşitliği, oyunun ortada bitmemesi, ve bitiş
tahtasındaki her yatay/dikey dizilimin sözlükte olması. CI'da koşuyor.

⚠ **İki kez benim beklentim yanlış çıktı, senaryo değil** (7 Eylül 2026):

1. Çarpanı `calcScore(board, placed, {})` ile karşılaştırarak ölçmek İŞE
   YARAMIYOR — `bonuses` haritası yalnızca tam ortadaki X3 karesini taşır,
   5×5'lik ×2 bölgesi `inBonusZone`'dan gelir; iki çağrı da aynı sayıyı
   döndürür. Çarpanın tek dürüst kaynağı `calcWordRawScores`'un
   `x2`/`x3` bayrakları.
2. Rakibin son hamlesi (NAR) de merkez bölgeye düşüyor, yani o da ×2
   alıyor. Beklenti artık veriden türüyor: `TutorialMove.bonus` hangi
   çarpanın beklendiğini AÇIKÇA beyan eder (yoksa hiçbir kelime çarpan
   almamalı), `raw` ise yalnızca ekranda "6 × 2 = 12" gibi bir cümle yazan
   ve TEK kelime kuran hamlelerde dolu — 4. sahne üç kelime kurup iki farklı
   çarpan aldığından orada "raw × n" diye tek bir cümle kurulamıyor.

## Duman testi ve StrictMode dersi

`tests/smoke.spec.ts` → "Tanıtım: dört sahne oynanır…" dört sahneyi
tarayıcıda oynuyor, ekrandaki puanları (`+12`, `6 × 2 = 12`) ve vergi onay
penceresini iddia ediyor, sonunda gerçek oyuna geçildiğini doğruluyor.

İlk koşumda düştü ve sebebi öğreticiydi: rakip sırası ilk `await`ten sonra
sessizce duruyordu. **`useRef(true)` ile kurulan "ekran hâlâ ayakta" bayrağı
YETMİYOR** — React StrictMode dev'de bağla → çöz → yeniden bağla yapıyor,
yani ilk çözümde `false`a düşen bayrak bir daha hiç açılmıyordu. Bayrak
effect'in İÇİNDE yeniden açılmak zorunda. (Zamanlayıcıyla sürülen her
animasyon dizisi bu tuzağa açık.)

Diğer 15 test artık `tanitimiAtla(page)` ile tanıtımı geçiyor
(`tests/gameOverFixture.ts`) — eski "Hızlı Başlangıç penceresini kapat"
bloklarının yerine geçti. Pencere silinmedi: kendiliğinden açılmıyor, ama
tahtanın alt şeridindeki "Yardım" linkinden ve statik `/nasil-oynanir/`
sayfasından hâlâ erişiliyor.

## Kalan fazlar

Faz 1 (senaryo + doğrulayıcı + ekran) bu PR'da. Sırada:

- **Faz 2 — bağlamsal ipuçları:** atlayan da ilk gerçek oyununda aynı dört
  şeyi öğrensin. Üç ipucu (sınırın büyüdü · puanı paylaşıyorsun · burada
  iki katı), her biri tek cümle, tavan 2 gösterim, aynı anda tek balon
  (öncelik: Sınır İhlali penceresi › zoom balonu › onboarding ipucu).
  Bayraklar `utils/onboarding.ts`'e, zoom balonunun desenine birebir.
- **Faz 3 — tekrar izleme:** `HelpModal`'ın başına "Tanıtımı oyna (60 sn)".
- **Faz 4 — port ikizi:** Flutter'da aynı senaryo, aynı metinler; parite
  testi web kaynağından okuyacak. Ayrı sürüm turu.
- **Faz 5 — ölçüm (isteğe bağlı):** tanıtım başladı/bitti/atlandı + hangi
  sahnede bırakıldı; admin panelinde tek kart. Sunucu tarafı, anında canlı.
