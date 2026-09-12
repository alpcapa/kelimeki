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

**Kapanış — dersi stratejiye bağlar** (kullanıcı kararı, 7 Eylül 2026):
*"Koyduğun kelime kadar nereye koyduğun da çok önemli. Hem bölgeni büyüterek
daha çok vergi topla, hem de rakibin hareket alanını daraltarak büyümesini
engelle."* Bir ara burada bingo bonusu tanıtılıyordu; ama bingo tanıtımda
HİÇ yaşanmayan bir mekanikti — kapanış, oyuncunun az önce dört sahnede
yaşadıklarını tek cümlede birleştirdiğinde daha çok iş görüyor. İki yarısı
da senaryoda yaşandı: bölge büyümesi 2. sahnede, verginin İKİ YÖNÜ 4.
sahnede (oyuncu ödedi, rakip de ona ödedi). Joker ve bingo bilerek
öğretilmeden kalıyor — tanıtımın işi her şeyi anlatmak değil.

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

## Fazlar — hepsi kapandı

Faz 1 (senaryo + doğrulayıcı + ekran) ilk PR'da, Faz 4 (port ikizi) 7 Eylül
2026'da, **Faz 2 · 3 · 5** 8 Eylül 2026'da. Aşağıdaki üç bölüm son turun
kaydı.

## Faz 4 — port ikizi (7 Eylül 2026, Parça 194)

Kullanıcı APK'yı indirip tanıtımı göremedi; hata değildi, port kodu hiç
taşımıyordu. Web TEK doğruluk kaynağı olarak kaldı; port ona karşı
kilitlendi.

**Ne nerede:** `mobile/app/lib/src/ui/tutorial/tutorial_script.dart`
(senaryo — `TUTORIAL_STEPS`/`DRAW_ORDER`/`BAG_FILLER`/`START_RACKS`/
`createTutorialState`in birebir eşi), `tutorial_game.dart` (ekran),
`util/onboarding.dart` (`shouldShowTutorial`, `tutorialLaunchAt`),
`FlagsStore.seenTutorial`/`markTutorialSeen` (eski `seenQuickstart` salt
okunur miras — portta zaten hiç yazılmamıştı), `BoardWidget.targets`/
`coach`, `RackWidget.highlight`, Setup'ta kapı (`_tanitimGosterilsinMi` →
`_runTutorial`).

**Dört kural portta da geçerli ve kanıtlı:**

1. *Motora dokunmaz* — `kelimeki_core`a action/alan eklenmedi; başlangıç
   durumu doğrudan kurulup `GameController.restore` ile yükleniyor,
   `autoPlayAi: false` (rakip zaten `isAI` değil).
2. *Oyun değildir* — `GameSession`/`CloudGameSession` kurulmuyor, `logStart`
   çağrılmıyor, `games` satırı açılmıyor; gerçek oyun ve `game_starts`
   sayacı ancak tanıtım rotası kapanınca kuruluyor.
3. *Senaryo doğrulanır* — `tutorial_script_test.dart` web betiğinin dokuz
   kontrolünü Dart motorunda koşuyor (+ torba yönü + kapı tablosu).
4. *Kapı dört sinyale bakar* — aynı saf fonksiyon; `hasPlayed` girişlide
   bulut listesi, misafirde yerel kayıt (web ile aynı ayrım); depo yoksa
   gösterilmez (web'de localStorage kapalıyken aynı yön).

**Üç yargı çağrısı:**

- **Hesap yaşı `User.createdAt`ten.** Web `profile.created_at` okuyor;
  portta `KProfile` bu alanı taşımıyor, profil önbelleği de yok. Supabase
  oturumunun `createdAt`i hesabın açılış anı — profil satırı kayıtta
  açıldığından ikisi aynı an. Sonradan açılmış bir profil portu daha "eski"
  gösterir → GÖSTERMEZ; kapının varsayılan yönü, kabul edildi.
- **`TUTORIAL_LAUNCH_AT` yeniden tarihlenmedi.** Anlamı "web yayınından
  önce hesap açan = mevcut oyuncu"; ayrı bir tarih iki platformun farklı
  kişilere göstermesi demek olurdu. Parite testi tarihi web'den okuyor.
- **Sürükleme hissi tekilleşti.** `game_screen`/`online_game_screen`deki
  iki kopya + tanıtımın üçüncüsü → `ui/game/drag_feel.dart` (web'in aynı
  gün yaptığı `dragFeel.ts`in ikizi). `layout_parity_test` artık değeri tek
  Dart kaynağından okuyor, üç ekranda pointer türüne bağlı kullanımı arıyor
  ve yerel kopyayı yasaklıyor; `TAP_SLOP_ON_RELEASE`/`DRAG_LIFT` de web ile
  sayı sayı karşılaştırılıyor.

**Balon geometrisi genelleştirildi, üçüncüsü yazılmadı:** `BoardWidget`in
zoom balonu (`_zoomHintBubble`) artık `_coachBubble`ı çağırıyor; tanıtım
balonu aynı fonksiyonu farklı çapa/yön/genişlikle. Web'deki üç kural
korundu: `ust`/`alt` yön, kuyruk çapanın sütununda, yatay hiza sütuna göre
(sol/sağ üçte bir → yaslı, orta → ortalı). Hedefleri örtmeme kontrolü
`tutorial_script_test`te (web'in #9'u).

**Parite testi ne okuyor (`tutorial_parity_test.dart`):** dört sahnenin
id/say/bubble/hamle(kelime, taşlar, puan, vergi, çarpan, raw)/done/rakip
notu · kapanış başlığı+metni · iki ad · DRAW_ORDER/BAG_FILLER/START_RACKS ·
üç süre (260/1400/2000) · beş balon/mesaj metni + vergi penceresi notu +
kapanış butonu · `TUTORIAL_LAUNCH_AT` · `TutorialGateInput` alan sayısı.
Yorumlar ayrıştırmadan önce atılıyor (`points`/`raw` yorumda da geçiyor).
Bulamazsa DÜŞER — `web_source.dart` deseni.

**Testte bulunan ders:** vurgusuz raf taşına dokunmak SEÇİMİ DEĞİŞTİRMEZ
(web'de `onSelect` de yok sayıyor), yani önceki seçim durur ve hedef kareye
o iner. İlk iddia "kare kabul etmez"di, düştü; davranış doğru, iddia
düzeltildi.

**Cihazda ölçülecek:** `mobile/TESTING.md` §1.9 (süre, yazı ölçeği,
gerçek parmakla sürükleme hissi, yalıtım). APK `main`'e merge + `mobile/**`
ile üretilir; "portta canlı mı" sorusunun cevabı Setup'taki `Derleme` sha'sı.

## Tarayıcı turu — karşılama penceresi + balon düzeltmesi (7 Eylül 2026 akşamı)

Kullanıcı Faz 4'ün Pages derlemesini tarayıcıda denedi ve üç şey bildirdi.
İkisi hataydı, biri eksik bir ürün adımı.

### 1. Balon yazısı sola yapışıyordu (PORT HATASI, ölçüldü)

*"Balon yazıları en sola yapışık geliyor. Özellikle 'rakip hamlesini yaptı'
oku kelime üstünde ama yazı board'un soluna yapışık."*

**Kök sebep bir Flutter değişmezi:** `Stack`, konumsuz çocuğuna **gevşek**
kısıt verir. Gevşek kısıtta `Column`un çapraz ekseni "en geniş çocuk" kadar
olur — yani balonun kendi genişliğine büzülür ve `crossAxisAlignment`
görünür hiçbir iş yapmaz; kutu `Stack`in varsayılan `topStart` hizasına,
yani SOLA düşer. Kuyruk kendi `Positioned`ı ile doğru yerde durduğundan
hata tam olarak "ok doğru, yazı solda" diye görünüyordu.

Düzeltme tek satır: `Column`u `SizedBox(width: double.infinity)` ile sar —
sonsuz genişlik `Stack`in maxWidth'ine kırpılır, `Column` tam genişlik olur,
hiza uygulanır. **Web'de bu hata YOKTU** (flex kabı zaten tam genişlik).

⚠ Bu, Faz 4'te zoom balonunun geometrisi genelleştirilirken girmişti: eski
`_zoomHintBubble` `Column`u doğrudan `Positioned(left:0,right:0)` içindeydi
(TIGHT genişlik → hiza çalışıyordu); ortak `_coachBubble` onu bir `Stack`in
içine aldı ve kısıt sessizce gevşedi. **Ders:** bir widget'ı `Stack`e
taşımak, çocuğun kısıtlarını değiştirir — hizalama o taşımada sessizce ölür.

Regresyon kilidi `tutorial_game_test.dart` → "balon hizası": orta banttaki
balonun merkezi tahtanın merkezine 2 px'ten yakın olmalı, kenar sütundaki
balon sağ yarıda kalmalı ve kuyruk balonun yatay aralığının İÇİNDE olmalı.
Duyarlılığı kanıtlandı — düzeltme geri alınınca sapma **156 px** ölçüldü.

### 2. Oyuncu kendini gerçek oyunda sanıyordu (EKSİK ADIM)

*"İnsanlar setup'dan hemen oynaya basınca kendisini oyunda sanıyor. Girer
girmez 'BÜYÜ kelimesini taşı' deyince oyunun öyle olduğunu düşünebilir ve
kafası karışabilir."*

Tanıtım ekranı gerçek oyun ekranına birebir benziyor (aynı tahta, aynı raf,
aynı başlık) — "burası bir tur" bilgisini ekranın kendisi taşımıyordu; sahne
sayacı (`TANITIM · 1/4`) küçük ve üstte. Artık tanıtım AÇILIRKEN tek bir
karşılama penceresi çıkıyor (kullanıcının yazdığı metin):

| | |
|---|---|
| Başlık | **Kelimeki Tanıtım Turu** |
| Metin | *Yaklaşık 1 dk sürecek ve size oyunu gösterecek kısa tanıtım turuna hoş geldiniz.* |
| Buton | **Devam** |

⚠ Metinde tek düzeltme: `hoşgeldiniz` → **`hoş geldiniz`** (TDK ayrı yazar;
3. sahnenin iyelik ekiyle aynı refleks).

**Pencere kapının parçası DEĞİL:** `shouldShowTutorial` değişmedi, pencere
tanıtım zaten gösterilmeye karar verildikten sonra çıkar ve kendi bayrağı
yoktur — tanıtım "bir kere" gösterildiğinden pencere de bir kere görünür.
İki platformda da aynı kabuk (384 px onay kartı) ve aynı metin;
`tutorial_parity_test` üçünü birden kilitler.

### 3. Balon tipografisi

*"Balon fontlarını da biraz büyütelim. Tek satır uzun olanları 2 satıra
bölelim."* Punto ve genişlik kapağı BİRLİKTE ayarlandı — kapak
daraltılmasa büyüyen punto balonu ekran boyunca uzatır, punto büyütülmese
kapak cümleyi gereksiz kırar:

| Balon | Punto | Genişlik kapağı |
|---|---|---|
| tahta (`coach`) | `clamp(9,2.4vw,13)` → **`clamp(11,3.2vw,16)`** | %96 → **%72** |
| raf / OYNA | aynı | 72vw → **58vw** |

Raf balonu ayrıca ORTALANDI (kullanıcı: *"Hepsinin ortalı ve yerinde olması
lazım"*): cümle rafın tamamı hakkında ve satırın ortası rafın üstüne düşüyor.
OYNA balonu sağda KALDI — o gerçekten sağdaki butonu işaret ediyor. Tahta
balonunun üçte-bir kuralı (sol/orta/sağ) korundu: kenar sütunlarda kuyruk
ancak öyle balonun altında kalıyor (çapa 12'de ölçüldü).

⚠ Balon artık iki satıra kırıldığından `verify-tutorial-script`in örtüşme
kontrolü İKİ değil **ÜÇ** komşu satıra bakıyor; dört sahne de geçiyor
(hedefler her sahnede yalnızca çapa satırında).

### 4. İkinci tur — okun hedefi ve kalan iki balon (aynı akşam)

Kullanıcı web önizlemesini denedi: *"Her şey ok, sadece 'Hamleni tamamlamak
için Oyna' balon yazısının oku Oyna butonunu göstermiyor. Bir de gerçek
oyuna geçince çıkan zoom mesaj fontunu da diğer balonlar kadar büyüt.
Buradan başla balon yazısını da aynı şekilde."*

**Ok neden kaymıştı — Tailwind sınıf sırası (WEB'E ÖZGÜ tuzak):** `Balon`
kabı zaten `items-center` taşıyordu, çağıran ise `items-end` ekliyordu.
Tailwind'de hangisinin kazandığını **sınıf dizesindeki sıra değil, üretilen
CSS'teki sıra** belirler — `items-end` sessizce yutuluyor, kuyruk balonun
ORTASINDA kalıp rafın ortasını gösteriyordu. Hiza artık `style` ile
veriliyor (`hiza: 'sol' | 'orta' | 'sag'` prop'u) ve kuyruk kenardan 12 px
içeride (portun `_Balon`ıyla aynı; tam köşedeki üçgen yuvarlatılmış kenarın
dışına taşmış görünüyor).

**Ders:** aynı özelliği hem kap sınıfında hem çağıranın sınıfında vermek,
CSS sırası belirsiz olduğu için "çalışıyor gibi görünüp sessizce ters
dönen" bir yapı kurar. Bir düzen kararı iki yerden geliyorsa satır içi
stile taşı.

Kilit ölçüyor: `smoke.spec.ts` kuyruğun (`[data-balon-kuyruk]`) yatay
merkezinin OYNA butonunun x aralığında kaldığını iddia ediyor; hizayı
bozunca test düşüyor (kanıtlandı).

**Kalan iki balon da aynı puntoya çekildi** — zoom ipucu ve "Buradan
başla" artık `clamp(11,3.2vw,16)`. Yani ekrandaki ÜÇ balon tek ölçüde;
`tutorial_parity_test` bunu değişmez olarak kilitliyor (`Board.tsx`teki
balon clamp'lerinin hepsi aynı olmalı — filigranlar tabanlarına göre
ayrılıyor).

### 5. Metin turu — vergi notu ve 2. sahnenin cümlesi (aynı akşam)

Kullanıcı iki cümle değiştirdi:

| Yer | Önce | Sonra |
|---|---|---|
| Vergi penceresinin alt notu | *Rakibin bölgesine girmen gerekmiyor — sınırına değmek yetiyor.* | **Rakibin bölgesine değen veya giren bir hamle yaparsan vergisini ödersin.** |
| 2. sahnenin balonu | *Kelime kurdukça sınırın büyür.* | **Kelime kurdukça bölgeni büyütürsün.** |
| 2. sahnenin sonuç satırı | *+15 puan — sınırın köşenin dışına taştı.* | **+15 puan — bölgen köşenin dışına taştı.** |

İkisi de terimi `sınır`dan `bölge`ye çekiyor — tanıtımın öğrettiği ad
`bölge` (verginin adı da "bölge vergisi", bkz. kök `CLAUDE.md` →
"Terminoloji"). Yeni not, projenin başka iki yüzeyindeki cümleyle de
aynı kalıba oturdu (`Landing.tsx` ve `intro_screen.dart`: *"rakibin
bölgesine değen/giren hamle yapabilirsin; ama vergisini ödersin"*).

⚠ Kullanıcının yazdığı iyelik biçimi (`bölgeni`) geçişli bir fiil ister:
`büyür` → **`büyütürsün`**. (`bölgeni büyür` dilbilgisi olarak tökezlerdi.)

Sonuç satırı aynı turda çekildi (kullanıcı onayı): balon "bölge" derken
hemen ardından gelen satırın "sınır" demesi TEK sahnede iki terim olurdu —
tam da kök `CLAUDE.md`'nin "Terminoloji" notunun uyardığı şey.

⚠ Parite testinin bu nota bakan iddiası CÜMLENİN İLK KELİMELERİNE
çapalıydı; metin değişince ayrıştırıcı sessizce kırılırdı. Artık port
sabitinin web dosyasında GEÇTİĞİ doğrulanıyor (boşluklar normalize) — yani
metin bundan sonra serbestçe değişebilir, parite yine kilitli kalır.

### 6. Raf balonu mesaj şeridinin üstüne taşındı (aynı akşam)

Kullanıcı: *"zaten orada 'kelimeyi taşı' balonu duruyor ve mesajlar
görünmüyor… kaydırsak iyi olur"*.

Balon rafın hemen üstüne (`bottom-full`) çapalıydı — orası da mesaj
şeridinin durduğu yer. Örtülen metin çoğunlukla balonun kendisiyle aynı
bilgiydi ("Harfi raftan al, işaretli kareye koy."), yani zarar küçüktü; ama
üst üste binmenin kendisi hatalı görünüyor.

**Çözüm yapıda, sayıda değil:** `relative` (portta `Stack`) artık raf
satırında değil, **mesaj şeridini de kapsayan** bir sarmalayıcıda. Balon
yine `bottom-full` ile onun üstüne taşıyor, dolayısıyla şeridin üstüne
değil tahtanın alt kenarına doğru çıkıyor. Sabit bir "36 px yukarı kaydır"
denmedi: şerit `min-h-[30px]` ile büyüyebilir, magic number bir gün
sessizce yanlış olurdu.

Portta dolgular birleşti — eski `(12,4,12,0)` + `(12,6,12,12)` yerine
`(12,4,12,12)` + aradaki 6 px `SizedBox`; boşluklar birebir aynı kaldı.

Kilit ÖLÇÜYOR, iki tarafta da: web `smoke.spec.ts` balon kutusunun alt
kenarının mesaj şeridinin üst kenarını geçmediğini, port
`tutorial_game_test` aynısını `getRect` ile iddia ediyor. Duyarlılık
kanıtlandı (balon eski yerine konunca port testi 565 > 545 ile düştü).


## Faz 2 — bağlamsal ipuçları (8 Eylül 2026)

Tanıtım yalnızca YENİ gelene ve yalnızca BİR KEZ açılıyor, üstelik her
sahnesinde "ATLA →" duruyor. Atlayan — ya da kapının hiç göstermediği mevcut
oyuncu — Kelimeki'yi ayıran mekanikleri hiç öğrenmeden oynuyordu. İpuçları o
boşluğu GERÇEK oyunda, mekanik YAŞANDIĞI anda kapatıyor.

| id | Ne zaman | Cümle |
|---|---|---|
| `vergi` | hamle bir rakip bölgesine vergi ödedi (`lostShares` dolu) | *Rakibin bölgesine değdin — bu yüzden puanının bir kısmı ona gitti.* |
| `carpan` | kurulan kelimelerden biri ×2/×3 aldı (`wordScores`) | *Sarı bölgede kelime puanı 2 katı, tam ortadaki karede 3 katı olur.* |
| `bolge` | hamleden SONRA bölge kendi 4×4 köşe bloğunun dışına taşıyor | *Bölgen büyüdü — kendi taşlarınla ilerledikçe köşenin dışına taşar.* |

**Terim `bölge`, `sınır` değil.** Plandaki adlar (*"sınırın büyüdü"*) 7 Eylül
akşamının metin turunda tanıtımın kendisinde zaten düzeltilmişti (`sınırın
büyür` → `bölgeni büyütürsün`); üç ipucu o dille aynı hizada. Doğrulayıcı
metinlerde `sınır` geçmesini AYRICA yasaklıyor — kural yorumda kalsa bir
sonraki cümle yine "sınır" derdi.

**Karar saf bir fonksiyonda:** `pickOnboardingHint(input, shown)`
(`utils/onboarding.ts` ↔ `util/onboarding.dart`). Sayaçlar çağıranda
(cihaz-yerel, ipucu BAŞINA tavan 1 — 12 Eylül 2026'da 2'den indi, aşağı
bkz.) — böylece tablo `verify-tutorial-script`
ve `tutorial_script_test.dart`ta depolamaya hiç dokunmadan koşuyor. İki kural
kolay kaçırılıyor ve ikisi de kilitli:

1. **Sıra sabit:** `vergi › carpan › bolge`. Aynı hamlede üçü birden hak
   edilebilir (tanıtımın 4. sahnesi tam olarak öyleydi: hem ×3 hem vergi),
   ama ekranda aynı anda TEK balon olur. Sıra "en şaşırtıcı önce": `vergi`
   sorulmadan cevaplanmazsa oyuncu puan kaybını bir HATA sanır; `bolge` ise
   tahtada zaten görünüyor (dış hat çizgisi büyüyor).
2. **Tavana çarpan bir ipucu ötekileri SUSTURMAZ** — üçü farklı mekaniği
   anlatıyor ve oyuncu ikisini bir oyunda, üçüncüsünü haftalar sonra
   yaşayabilir.

### Oyun sonu kutlaması — ilk galibiyet / ilk puan (12 Eylül 2026)

Kullanıcı önce *"mümkünse oyun sonu modalında 'Tebrikler ilk puanını
kazandın' mesajı (eğer kazanmışsa)"* dedi; sorulunca ayrımı kendisi
netleştirdi ve **iki farklı mesaj** çıktı:

| Kim | Ölçüt | Kaynak | Metin |
|---|---|---|---|
| Girişli | ilk **GALİBİYET** (n oyun oynamış olsa da) | HESAP — `player_stats_overall.wins` | *Tebrikler, ilk oyununu kazandın!* |
| Misafir | ilk **PUAN** (`leaguePoints > 0`) | CİHAZ bayrağı | *Tebrikler, ilk puanını kazandın. Bu puanı kaybetmemek için hemen giriş yap.* |

**Neden iki ayrı kaynak.** Girişlide cihaz bayrağı YANLIŞ olurdu: telefon
değiştiren ya da uygulamayı silip kuran kişi yıllar sonra yeniden "ilk
oyununu kazandın" görürdü. Misafirde ise sunucuda sayılacak bir şey YOK —
hesap yok. Mesajın kendisi zaten bunu söylüyor: puan kaydedilmiyor,
kaydolmaya davet var. Yani ikisi "aynı özelliğin iki hâli" değil, iki ayrı
ürün kararı: biri kutlama, öteki dönüşüm çağrısı.

**İki ölçüt de aynı şey DEĞİL.** 2 kişilik oyunda "kazandı" ile "puan aldı"
çakışıyor (2. sıra 0 puan alır), 4 kişilikte ayrışıyor: 2. sıra puan alır
ama kazanmamıştır. Doğrulayıcının son iki vakası tam bu ayrımı kilitliyor.

**`wins` neden kaydın ARDINDAN okunuyor.** Kaydı yazmadan önce okunsaydı
`0` beklenirdi — ama kaydın sunucuya düşüp düşmediği bilinemezdi ve
çevrimdışı biten bir oyunda mesaj YANLIŞ çıkardı. Sonradan okunan `wins == 1`
tek bir şeyi söylüyor: **bu oyun sunucuya düştü VE hesabın ilk galibiyeti.**
Kayıt düşmediyse sayı artmaz, mesaj çıkmaz — güvenli yön. (`totalWins: null`
= istek düştü → yine sessiz; doğrulayıcıda kendi vakası var.)

⚠ **Beraberlik kutlanmıyor** ve bu `wins`in tanımından geliyor:
`count(*) filter (where games.result = 'win')`, beraberlik `'tie'`. Sıralamada
rank 1 olsa da kutlama çıkmaz, bir sonraki gerçek galibiyette çıkar.

**Karar ÇAĞIRANDA, bileşende değil** — `aiLevelForBadge` deseninin aynısı:
`GameOver` "ben kimim" bilmiyor (yalnız `players` alıyor) ve iki çağıranın
kaynağı farklı. Yerel ekran iki dalı da kurabilir, Canlı ekran yalnız üye
dalını (oyun zaten hesap gerektiriyor).

**Metin TEK kaynak.** İlk sürümde misafir cümlesi JSX'te butonun iki yanına
İKİNCİ KEZ yazılmıştı — bu depodaki en sık bayatlama biçimi. Düzeltildi:
`FIRST_WIN_GUEST_CTA` ayrı bir sabit ve çizim cümleyi ondan BÖLÜYOR; parça
cümlede geçmezse buton hiç çıkmayacağından doğrulayıcı içermeyi ayrıca
kontrol ediyor.

⚠ **Port farkı (kabul edildi):** portta oyun ekranından açılabilen bir giriş
penceresi YOK (web'de `showLoginModal` var), bu yüzden misafir metni portta
düz kalıyor — cümle aynı, "hemen giriş yap" tıklanabilir değil. Web'de
buton.

### Tavan 2 → 1 (12 Eylül 2026, kullanıcı kararı)

Sözleri birebir: *"İlk defa oynayan kişiye oyun sırasında çıkan max 6
gösterim iyi bir deneyim değil. Onu her bir mesaj için 1 kere olacak şekilde
düzelteceğiz."*

**Aritmetik neden burada kaçtı:** tavan "ipucu BAŞINA" diye tasarlandı ve
yukarıdaki 2. kural (biri susunca ötekiler susmaz) tek başına doğru. Ama
üçünün TOPLAMI hiç hesaplanmadı: 3 ipucu × 2 gösterim = **6 balon**, üstelik
hepsi ilk birkaç oyunda, yani tam da oyuncunun oyunu öğrenmeye çalıştığı
anda. Ders: bir tavan "öğe başına" konurken **öğe SAYISIYLA çarpılıp** son
kullanıcının göreceği toplam da yazılmalı.

Değişen tek şey sabitin değeri (`ONBOARDING_HINT_MAX_SHOWS` ↔
`onboardingHintMaxShows`, ikisi de `1`). **Tasarım DEĞİŞMEDİ:** tavan hâlâ
ipucu başına, sıra hâlâ `vergi › carpan › bolge`, karar hâlâ aynı saf
fonksiyonda. Doğrulayıcı ve testler tavanı sabitten okuduğu için (hard-code
edilmiş `2` yok) vaka tablosu olduğu gibi geçerli kaldı —
`npm run verify-tutorial-script` yeşil, `tutorial_parity_test.dart` iki
tarafın değerini karşılaştırmaya devam ediyor.

**Çizim ikinci bir geometri yazmıyor:** balon `Board`un mevcut `coach`
prop'u (tanıtımın çizdiği balonun aynısı). Çapa cümlenin ANLATTIĞI kare —
çarpanda bonus bölgesine düşen taş, bölgede köşe bloğunun dışına taşan
hücre, vergide hamlenin ilk karesi. Yön `ust`, 0. satırda `alt` (tanıtımın
1. sahnesindeki kuralın aynısı).

⚠ **Planın yazılı önceliği UYGULANAMADI — ölçüldü.** Plan *"Sınır İhlali
penceresi › zoom balonu › onboarding ipucu"* diyordu. Ama zoom balonu bir kez
gösterilmeye karar verilince **oyun BOYUNCA duruyor**: `useBoardZoom`'daki
`hint` yalnızca çift dokunuş DENENİRSE kapanıyor, başka hiçbir yerde
(portta `_zoomHint` aynı). Yazılı sıra uygulansaydı ipuçları tam da hedef
kitlesinde — ilk iki oyun açılışında, yani zoom'u henüz denememiş kişide —
HİÇ görünmezdi. Sıra ters çevrildi: **Sınır İhlali penceresi › onboarding
ipucu › zoom balonu**. Bedeli küçük ve geçici: ipucu 4 saniye duruyor, zoom
balonu o pencereden sonra geri geliyor.

**Süre neden 4 sn:** tanıtımın "Rakip hamlesini yaptı" balonu 2 sn duruyor
ama orada söylenen şey bir OLAY; burada bir KURAL anlatılıyor ve cümle iki
satır. YZ 1,1 sn sonra oynamaya başladığından balon rakibin hamlesiyle
çakışıyor — kabul edildi: balon oyuncunun KENDİ karesini işaret ediyor, YZ
başka yere oynuyor.

**Kapsam bugün yalnızca YEREL (YZ) oyun.** Canlı oyun ekranı aynı `Board`u
kullanıyor ve prop hazır, ama hamle akışı sunucudan geliyor (`moveRows`) —
ayrı bir tetikleme yolu demek. Tanıtım da yalnızca ilk YEREL oyunda açıldığı
için ipuçlarının kitlesi zaten orada; Canlı'ya genişletmek ayrı bir iş.

**Tarayıcı testi YOK, bilerek:** ipucu ancak birkaç hamle sonra (bölge köşe
bloğunu aşınca, merkeze varınca) doğabiliyor; bunu duman testinde kurmak
uydurma bir kayıt fixture'ı gerektirirdi. Karar saf fonksiyonda ve iki
platformda yedişer vakayla kilitli; ekrandaki hâli elle koşuluyor
(`TESTING.md` §13.6, `mobile/TESTING.md` §1.9).

## Faz 3 — tanıtımı tekrar oynama (8 Eylül 2026)

"Nasıl oynanır?" penceresinin **en başında** bir buton:
**Tanıtım turunu oyna (1 dk)** (`TUTORIAL_REPLAY_CTA`). Süre etikette yazılı,
çünkü asıl itiraz "okumaya vaktim yok"tu — bir dakikadan kısa olduğunu
görmeden kimse başlatmaz; karşılama penceresindeki *"Yaklaşık 1 dk"* ile aynı
vaat. Metnin altına gömülü bir link değil, ilk görülen şey: kuralları OKUMAK
yerine oynayarak öğrenmek isteyen için pencerenin tepesi doğru yer.

**Yalnızca "Hızlı Başlangıç" adımında** — "Detaylı Kurallar" bir referans
metni, oraya bakan kişi zaten okumayı seçmiştir.

**Yalnızca SETUP'tan açılan pencerede.** Aynı `HelpModal` beş yerden açılıyor
(Setup, hesap menüsü, iki oyun ekranı, statik `/nasil-oynanir/`) ve tanıtım
tam ekran: süren bir oyunun (hele Canlı bir oyunun) üstüne binmesi oyuncuyu
tahtasından koparırdı. Bu yüzden `onReplayTutorial` OPSİYONEL bir prop
(`HelpModal` ↔ `help_modal.dart`) — verilmezse buton hiç çıkmaz, kararı
çağıran veriyor.

**Kapanışta gerçek oyun BAŞLAMAZ.** Tekrar modunda kadro yok:
`setTutorial({ replay: true })` → `startLocalGame` hiç çağrılmıyor, kullanıcı
Setup'a dönüyor. Kapanış butonunun sözü de değişiyor —
`TUTORIAL_FINISH_BUTTON` (*Gerçek oyuna başla*) ↔
`TUTORIAL_REPLAY_FINISH_BUTTON` (*Kapat*). Duman testi tam bunu kilitliyor
("oyun BAŞLAMAZ": Setup görünür, "Pas Geç" yok).

⚠ **Etiketler JSX'ten `tutorialScript.ts`e taşındı.** Parite testi kapanış
butonunu `TutorialGame.tsx`ten regex'le söküyordu (`>Gerçek oyuna başla<`);
metin koşullu hâle gelince o desen kırılırdı. İkisi de artık senaryo
dosyasında ve parite testi oradan okuyor — port ikizi `tutorial_script.dart`
(etiketler portta BÜYÜK harfli, web `uppercase` sınıfıyla büyüttüğü için
karşılaştırma `trUpper` ile).

**Oynamak tanıtımı TÜKETİR.** Tekrar başlatmak da `markTutorialSeen()`
çağırıyor. Bu, "yardımı okumak tanıtımı tüketmez" kuralıyla çelişmiyor —
oradaki ayrım OKUMAK ↔ OYNAMAK; tanıtımı Help'ten oynayan biri onu görmüştür.

## Faz 5 — ölçüm (8 Eylül 2026)

Tanıtımın varlık gerekçesi ölçülebilir bir iddiaydı (*"çoğu kişi okumuyor,
sıkılıp çıkıyor"*) ve o iddianın doğrulanacağı hiçbir sayı yoktu: tanıtım
bilerek bir "oyun" sayılmadığından (`logGameStart` çağrılmaz, `games` satırı
açılmaz) huninin hiçbir adımında görünmüyordu.

**`tutorial_events`** (migration `20260908062707_tutorial_events_funnel`,
canlıya uygulandı ve doğrulandı): `event` (`start`/`finish`/`skip`) ·
`step` (yalnızca `skip`te, ekrandaki "TANITIM · n/4" ile aynı numara) ·
`source` (`auto`/`replay`) · `platform` · `app_version` · `anon_id`.

⚠ **`user_id` YOK ve tabloda böyle bir kolon da yok** — `game_starts`taki
aynı gizlilik kararı: `PrivacyModal` bölüm 6 anonim cihaz kodu için
"hesabınızla ASLA eşleştirilmez" diyor, ikisini aynı satıra koymak tam
olarak o eşleştirmeyi yapardı. RLS: iki istemci rolüne de INSERT, SELECT
politikası YOK (tabloyu yalnızca security definer admin RPC'si okur).

**Admin kartı:** Büyüme > Kullanıcı → "Tanıtım Turu", Kaynak Hunisi'nin
hemen altında. `auto` ve `replay` AYRI satırlar — kendi isteğiyle izleyen
tanım gereği daha meraklıdır, tek satırda toplansalar `auto` kitlesinin
gerçek terk oranı yukarı çekilirdi. `starters`/`finishers` BENZERSİZ CİHAZ,
parantezdeki `starts`/`finishes` ADET (bir cihaz tanıtımı iki kez açabilir);
oran cihaz üzerinden hesaplanıyor. Satırın altındaki **sahne dökümü**
(`skip_steps`, jsonb) kartın asıl sorusunu cevaplıyor: tanıtım BAŞTA mı
kaybediyor (metin/hız) yoksa SONDA mı (uzun geliyor).

**Portta `anon_id` null gidiyor** — web'in `visitTracking.ts` damgası porta
hiç girmedi (`game_starts`ta da öyle). Yani port satırları ADET'te sayılır,
BENZERSİZ CİHAZ'da sayılmaz; `AdminTutorialFunnelRow` bunu açıkça yazıyor.

**Olay yazımı fire-and-forget ve her olay en çok bir kez** (`telemetriRef` /
`_telemetri`): StrictMode dev'de effect iki kez koştuğundan tek açılış iki
`start` satırı yazardı — `useBoardZoom`'daki `hintDecided` ile aynı sınıf
koruma.
