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
| 4 | **FES** `6,6→6,7` +39 (19'u rakibe) | merkez karesi ×3 **ve** sınıra değmenin bedeli | **NAR** `5,4↓7,4` +4 (2'si bize) | 80–48 |

Sıranın "merkez önce, vergi sonra" olmasının teknik sebebi: oyuncunun
zinciri sol üst köşeden aşağı ilerliyor, yani önce ortadaki altın bölgeye
varıyor; rakibin kırmızı sınırına ancak ondan sonra komşu oluyor. Ters
sırada senaryo tahtayı "ileri sarmak" (birkaç hamleyi atlayıp tahtayı
doldurmak) zorunda kalıyordu — kullanıcının düzeltmesi bu ihtiyacı da
ortadan kaldırdı.

**4. sahne iki dersi TEK hamlede veriyor** (kullanıcı kararı, 7 Eylül 2026:
*"4. slaytta hem X3 alsın hem de sınır ihlali yapsın"*). Geometri buna zaten
uygundu: merkez karesi `6,6` ile rakibin `SAAT` sütunu `6,8` arasında tek boş
kare var. İki taş (F ve E) üç kelime birden kuruyor —

- `FES` = F(6,6) + E(6,7) + **rakibin** S(6,8) → X3 karesine yeni taş: **×3**
- `AF` = A(5,6) üstte + F(6,6) → aynı X3 hücresi, o da **×3**
- `NE` = N(5,7) üstte + E(6,7) → altın bölgede: **×2**

vergi öncesi 58 puan, 19'u rakibe. Merkeze konan harf kullanıcı kararıyla
**F** (7 puan, torbadaki tek F): X3'ün gerçek gücü ancak pahalı bir harfle
görünür oluyor. Yani oyuncu tek hamlede hem merkezin
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

## Kapı — kime gösteriliyor (7 Eylül 2026, kullanıcı isteği)

Kullanıcının sözleri: *"Bu kurguyu web'de başlatıyoruz. Sadece yeni gelenlere
bir kere gösterilecek. Mevcut gelmiş ve oynamış kişilere gösterilmeyecek. Şu
anda çıkan hızlı başlangıcın yerini alacak."*

Karar saf bir fonksiyonda: `shouldShowTutorial` (`utils/onboarding.ts`), dört
sinyal birden okunuyor. **Tek bir cihaz bayrağı YETMİYOR** — eski bayrak
(`kelimeki:seen-quickstart`) yalnızca "bu cihazda eski pencere görüldü" der;
cihaz değiştiren ya da bugüne kadar sadece Canlı oyun oynamış bir kullanıcı
o bayrağı taşımaz ve tanıtıma sokulurdu.

| Sinyal | Nereden | Ne diyor |
|---|---|---|
| `seenTutorial` | `kelimeki:tutorial-seen` | tanıtım bu cihazda gösterildi |
| `seenLegacyQuickStart` | `kelimeki:seen-quickstart` (**salt okunur miras**) | bu cihazda eski pencere görüldü = zaten oynanmış |
| `hasPlayed` | girişlide bulut kaydı, misafirde yerel kayıt | devam eden oyunu var |
| `accountCreatedAt` | `profile.created_at` | hesap tanıtımdan eskiyse mevcut oyuncu |

Herhangi biri "bu kişi yeni değil" derse gösterilmez; **varsayılan bilerek
gösterme tarafında** (depolama kapalıysa, tarih okunamıyorsa da öyle):
mevcut bir oyuncuyu tanıtıma sokmak, yeni bir oyuncunun tanıtımı
kaçırmasından daha kötü. Tablonun tamamı
`npm run verify-tutorial-script`'te yedi vakayla koşuyor, tarayıcıdaki uç
davranış ise duman testinde ("daha önce oynamış cihazda tanıtım açılmaz").

**"Bir kere" ne demek:** işaret tanıtım AÇILIRKEN konuyor, bitince değil —
zoom balonundaki kuralın aynısı. Yarıda kapatılan bir tanıtım böylece
sonsuz döngüye dönüşmüyor.

⚠ **İki bayrak neden ayrıldı:** eskiden "Nasıl oynanır?"ı elle açıp kapatmak
da quickstart'ı "görüldü" sayıyordu (pencere bir daha kendiliğinden
açılmasın diye). Bu davranış KALDIRILDI: kuralları okumak tanıtımı
tüketmez — yoksa oynamadan önce yardıma bakan yeni kullanıcı tanıtımı hiç
göremezdi. `markQuickStartSeen` artık hiç yazılmıyor; eski bayrak yalnızca
"mevcut oyuncu" sinyali olarak okunuyor.

⚠ **Bilinen sınır:** misafirde cihaz dışına bakacak bir şey yok. Tarayıcısını
temizlemiş ya da yeni bir cihazdan gelen eski bir MİSAFİR oyuncu "yeni"
görünür ve tanıtımı bir kez daha görür. Girişli kullanıcıda bu delik hesap
yaşıyla kapalı.

### Balonun yerleşimi — DİKEY, ve hedefleri örtmez

3. sahnenin cümlesi kullanıcı isteğiyle uzayınca (*"burada puan iki katı"*
→ *"Sarı bölge içinde kelime puanının 2 katını alırsın"*) balon genişledi ve
**"şuraya koy" dediği üç kareyi kapattı** — çünkü ilk yerleşim "Buradan
başla"nınkiyle aynıydı: balon karenin YANINDA, tahtanın içine doğru.

Kullanıcı yerleşimi de söyledi: *"Balonu üste koyup oku aşağıda
verebilirsin."* Artık balon işaret ettiği karenin **üstünde** (`yon: 'ust'`),
kuyruk aşağı bakıyor; üstte yer yoksa **altında** (`yon: 'alt'`), kuyruk
yukarı. Balon tahtanın neredeyse tam genişliğini kullanabildiği için uzun
cümle tek satıra sığıyor, yatay hizalama da çapanın sütununa göre seçiliyor
(sol üçte bir → sola yaslı, sağ üçte bir → sağa yaslı, orta → ortalı), yani
kuyruk her zaman balonun altında kalıyor — ölçmeye gerek yok.

| Sahne | Çapa | Yön | Neden |
|---|---|---|---|
| 1 BÜYÜ | `(0,1)` | alt | hedefler en üst satırda, üstte yer yok |
| 2 ÜZENGİ | `(5,3)` | alt | kelime DİKEY; üstteki balon kendi hedeflerinin üstüne otururdu |
| 3 İNSAN | `(5,4)` | üst | kuyruk ilk hedefi gösteriyor, balon boş 3-4. satırların üstünde |
| 4 FES | `(6,6)` | üst | kuyruk doğrudan X3 karesinde |

⚠ Balon komşu **iki** satırı kapatabilir (iki satıra sarabildiği için).
`verify-tutorial-script` hem bu örtüşmeyi hem "0. satırda `ust` olmaz"
kuralını kontrol ediyor; kapının duyarlı olduğu kanıtlandı — eski çapa geri
konunca betik `balon (5,4) hedef kareleri örtüyor — (5,5), (5,6), (5,7)`
diyerek düşmüştü.

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

## Etkileşim — cihaz testi modeli DEĞİŞTİRDİ (7 Eylül 2026)

İlk sürümde işaretli kareye dokunmak doğru harfi raftan KENDİLİĞİNDEN
getiriyordu. Hızlıydı (tek dokunuş ≈ 1 sn) ama kullanıcı cihazda deneyip
şunu bildirdi: *"Ekrana dokunup taşların gelmesi gerçekçi değil. Rafta
taşıması gereken taşları yanyana koy ve highlight et, ayrıca oraya balon
koyup 'şimdi BÜYÜ kelimesini taşı' yaz."* Haklı bir itiraz: oyuncu tanıtımı
bitirdiğinde gerçek oyunun jestini hiç öğrenmemiş oluyordu.

Şimdi taş **elle** alınıyor, iki yoldan da:

- raftaki harfe dokun → seçilir, sonra işaretli kareye dokun, **ya da**
- harfi işaretli kareye **sürükle** (gerçek oyundaki jestin aynısı; parmağın
  altında taşın kopyası gider).

Boş kareye dokunmak tek başına HİÇBİR ŞEY yapmaz. Öteki raylar duruyor:
konan taşa dokunmak geri alır, hedef dışı kareler sessizce reddedilir
(hata mesajı yok — tanıtımda "yanlış yaptım" duygusu olmamalı), pas / taş
değiştirme / joker yok, 4. sahnede gerçek `Sınır İhlali!` penceresi çıkar.

**Dört balon, dört farklı iş:**

| Balon | Nerede | Ne zaman |
|---|---|---|
| Dersin cümlesi ("Ortadaki kare üç katı!") | tahtada, hedef satırın bir üstünde/altında | oyuncunun sırası, hamle **tamamlanana kadar** |
| `Şimdi FES kelimesini taşı` | rafın üstünde | harf kaldığı sürece |
| `Hamleni tamamlamak için OYNA'ya bas` | OYNA butonunun üstünde | hamle tamamlanınca |
| `Rakip hamlesini yaptı` | tahtada, rakibin oynadığı karenin yanında | rakip oynadıktan **sonra**, 2,6 sn |

**İkinci cihaz turunun iki düzeltmesi** (7 Eylül 2026, kullanıcı):

1. *"BÜYÜ tahtaya koyulduktan sonra OYNA balonu çıkınca 'Kendi köşenden
   başla' balonu kaybolmalı."* — iki balon aynı anda duruyordu. Tahta
   balonu artık hamle tamamlanınca susuyor; söz sırası OYNA balonunun.
2. *"Rakip hamlesini yapıyor balonu çok hızlı gidiyor."* — balon taşlar
   dizilirken çıkıyordu (~1 sn) ve okunmuyordu. Artık hamle BİTTİKTEN
   sonra, geçmiş zamanla ve **2 saniye** duruyor; dizilme sırasında
   yalnızca mesaj şeridi "Rakip oynuyor…" diyor (göz zaten inen taşlarda).
   Süre iki turda ayarlandı: 1,8 sn *"çok hızlı"*, 2,6 sn fazla → **2,0 sn**.

### Sürükleme: MANTIK sade, HİS ortak

`App.tsx` ve `OnlineGameScreen.tsx` bu jesti ayrı ayrı taşıyor (~170 satır:
taslak taşı geri sürükleme, ıskalama kurtarma, zoom, joker). Tamamını ortak
bir kancaya çıkarmak iki CANLI ekranın en hassas kodunu elden geçirmek
demekti — o risk alınmadı; `TutorialGame` yalnızca ihtiyacı olanı içeriyor
(raftan tahtaya, tek yön).

Ama kullanıcı ikinci turda *"taşlar gerçek oyundaki gibi çok akıcı değil"*
dedi ve fark ölçülünce ortaya **dört ayar** çıktı — hiçbiri mantıkta,
hepsi HİSTE:

| Ayar | Ne yapıyor |
|---|---|
| `DRAG_LIFT = 30` | taş parmağın 30 px ÜZERİNDE çizilir (parmak taşı örtmesin) — **ve hedef de aynı noktadan hesaplanır**, görsel ile bırakma noktası ayrışmaz |
| `liftedPoint` | kaldırılmış nokta tahtanın üst satırının altında kalacak şekilde kırpılır; yoksa ilk satırdaki ev karesine hiç bırakılamazdı |
| `dragThresholdFor` | hayalet eşiği farede 6, parmakta 10 px |
| `TAP_SLOP_ON_RELEASE = 24` | bırakma anında bu kadar kaymayan jest DOKUNUŞ sayılır (titreyen parmak taşı kaybetmesin) |

Bunlar `App` ile `OnlineGameScreen`te zaten İKİ KOPYAYDI; tanıtım üçüncüsünü
gerektireceği için **`src/utils/dragFeel.ts`e çıkarıldı** ve üç ekran da
oradan besleniyor (hayaletin görseli — `scale(1.1)` + gölge — dahil). Yani
bu tur bir kopyayı çoğaltmak yerine mevcut ikisini de tekilleştirdi. Ölçüm
gerekçeleri (hangi şikâyet, hangi tarih) o dosyada.

⚠ **Hayalet tık:** sürükleme bir tahta hücresinde bittiğinde tarayıcı compat
`click` üretir ve o hücrede ARTIK TAŞ VARDIR — `handleCellClick` onu anında
geri alırdı. `swallowNextClick()` (bkz. `utils/ghostClick.ts`) bu yüzden
bırakmanın hemen ardından çağrılıyor; duman testi 350 ms sonra taşın hâlâ
yerinde olduğunu doğruluyor.

### Vurgu bitişik bloğa bağlı — ölçülmüş bir hata

Rafta işaretlenecek taşları "hedef harfleri tek tek ara" diye bulmak
YETMİYOR. 3. sahnede raf `A T N S A N K`, gereken harfler `N S A N`: harf
harf eşleyen arama üçüncü hedef için raftaki İLK `A`yı (indeks 0, önceki
sahneden kalan artık taş) işaretliyordu. Oyuncu onu "sıradaki" sanıp
seçiyor, kare kabul etmiyor ve tanıtım kilitleniyordu — ilk koşumda tam bu
oldu. Doğrusu senaryonun kendi garantisini kullanmak: gereken harfler rafta
**yan yana ve kelime sırasında** durur (torba sırası elle yazılı), ekran o
bitişik bloğu arar. `verify-tutorial-script` bu bloğun her sahnede var
olduğunu artık ayrıca kilitliyor.

## Doğrulama — `npm run verify-tutorial-script`

Tanıtım ekranda PUAN yazıyor ("6 × 2 = 12", "58 puanın 19'u rakibe gitti").
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
