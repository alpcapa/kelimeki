# Oyun Kurallarının "Neden Böyle" Kayıtları

> Kuralların KENDİSİ kök `CLAUDE.md` → "Oyun Mekaniği Özeti"nde. Bu dosya o
> kuralların tarihli gerekçelerini, vakalarını ve ölçümlerini tutar —
> `grep`'lenir, baştan sona okunmaz.
>
> **Neden ayrı (11 Eylül 2026):** "Oyun Mekaniği Özeti" tek başına
> `CLAUDE.md`'nin **%31'iydi** (25.163 bayt) ve dosya `auto` sınıfının uyarı
> bandına girmişti. `auto` sınıfının kuralı boyut değil TÜR:
> *"tarihli 'neden böyle' anlatılarını taşı, burada yalnızca her yerde
> geçerli kural/değişmez kalsın"* (bkz. `CLAUDE.md` → "Doküman Boyutu
> Bütçesi"). Taşınan metinler BİREBİR korundu; kök dosyada kalan kural
> cümleleri kısaltıldı.

## Genişleyen bölge — "iletken hücre" kuralı (24 Ağustos 2026, kural DEĞİŞTİ)

Kural önceden şöyleydi: *"izole bir rakip taşı o tek hücrede zinciri kesip
diğer boş hücrelerden dolaşılmasına neden olur"*.

**Vaka:** Bir kullanıcı gerçek bir oyunda bunun tutarsızlığını yakaladı:
rakip onun 4×4 bloğunun üst satırına bağımsız taşlar koymuş (kendi zincirine
bağlı DEĞİL), o da bu taşlardan birine asarak blok DIŞINA bir kelime kurmuş
ve bölgesi büyümemişti.

**Tutarsızlık şurada:** o hücre **zaten onun bölgesi sayılıyordu** (taban
iddia — rakibin zinciri oraya ulaşmadığı için) ve rakip oraya bitişik oynasa
ona **vergi ödeyecekti**; yani hücre kira toplanan ama üzerinden yürünemeyen
bir alandı.

**Neden "üye olmaz, yalnızca geçirir":** iletken hücre zincire ÜYE olsaydı
aynı hücre hem taşın sahibinin hem blok sahibinin zincirine girip *"iki
oyuncunun bölgesi asla çakışmaz"* değişmezini kırabilirdi (ölçüldü).

**Uygulama iki geçişli:** önce her oyuncunun SAF zinciri (yalnızca kendi
taşları), sonra "bu rakip taşı destekli mi" sorusu O saf zincire sorulur —
kapıyı ikinci geçişin kendi sonucuna sormak dairesel olurdu.

**Kanıt:** Golden vector'lar yeniden üretildiğinde **sıfır fark** çıktı (yani
mevcut senaryoların hiçbiri bu dala girmiyordu) — tam da bu yüzden
`territory.json` fixture'ı eklendi: beş vaka, biri kuralın NEGATİF dalı
(`destekli_rakip_tasi_keser`), ve fixture'ın kurala duyarlı olduğu kural geri
alınıp yeniden üretilerek kanıtlandı (18 → 16 hücre).

## Bölge vergisi ↔ sınır ihlali terminolojisi (19 Ağustos 2026)

Kullanıcı sordu: *"bazı yerlerde bölge vergisi, bazı yerlerde sınır ihlal
vergisi diyoruz; hangisi daha yaygın?"*

İkisi AYNI şeyin iki farklı yüzü ve ayrım bilinçli: **`sınır ihlali` eylemin
adı**, **`bölge vergisi` o eylemin bedelinin adı**.

Sayım yapıldığında tek gerçek tutarsızlık `Landing.tsx`'in "Nasıl oynanır"
4. adımıydı: `"Sınır ihlal vergisine dikkat!"` ikisini birleştirip projede
başka HİÇBİR yerde geçmeyen üçüncü bir terim uyduruyordu (üstelik "ihlal
vergisi" dilbilgisi olarak da tökezliyor). Başlık **"Bölge vergisine
dikkat!"** oldu — karşılama katmanı kuralları ilk kez anlatan yüzey, orada
verginin kanonik adı geçmeli.

Aynı turda kod YORUMLARINDAKİ iki ölü varyant da (`köşe vergisi` →
`types.ts`/`gameReducer.ts`, `sınır vergisi` → `validator.ts` +
`_game/validator.ts` + portun `validator.dart`'ı) `bölge vergisi`ne çekildi;
davranış değişmedi, golden vector'lar yeniden üretildi ve **sıfır fark**
çıktı.

## Logo'nun "Çık" modalının kaldırılması (29 Temmuz 2026)

Öncesinde logoya tıklamak bir "Çık" onay modalı açıyor, sırası gelen hâlâ
oyundaki insan oyuncuyu (hotseat'te herkes kendi sırasında teslim olabilsin
diye) ya da yoksa hesap sahibini (1. oyuncu) hedefleyip `SURRENDER` dispatch
ediyordu.

Canlı oyundaki 48 saatlik zaman aşımı modeli YZ tarafına da uygulanınca
(kullanıcı isteği) bu modal tamamen kaldırıldı.

**Kaybı yok:** Setup'taki Yapay Zeka sekmesinde çalışan mevcut kurulumda
zaten yalnızca 1. oyuncu (hesap sahibi) insan olabildiğinden (diğerleri her
zaman YZ), modalın hotseat dalı — *"başka bir insan oyuncuyu teslim et,
diğerleri devam etsin"* — pratikte hiç tetiklenmiyordu.


## Taş değiştirme sınırı: torbada kalandan fazlası değiştirilemez (14 Eylül 2026)

**Kullanıcı raporu (Asnmzr):** *"torbada 4 harf kalmışken 7 harf
değiştirdim"*. Doğru: üretim reducer'ıyla birebir yeniden üretildi —
torba 4, seçim 7, sonuç `"Ben 7 taş değiştirdi ve sırasını kullandı."`,
torba yine 4, raf yine 7, hata da uyarı da yok.

**Neden hiçbir kapı yakalamadı.** Motorun dördü de aynı sırayı uyguluyordu:
*önce seçilenleri torbaya koy, SONRA en fazla o kadar çek*
(`shuffle([...bag, ...returned])` → `drawTiles(bag, returned.length)`;
SQL'de `v_draw_n := least(v_tile_count, array_length(v_bag_arr, 1))`).
Yani **taş korunumu hiç bozulmuyordu** — `verify-swap-invariants`in 1.
kontrolü (`tileTotal` değişmesin) bu hatayı tanımı gereği GÖREMEZ, golden
vector'lar da web ↔ Dart'ı karşılaştırdığından ikisinde birden var olan bir
kuralsızlığa kör. Arıza tamamen sessizdi; tek görünen yeri oyuncunun kendi
rafıydı.

**Bedeli neydi.** Torbanın taşıyamayacağı bir tazeleme bedavaya alınıyordu:
torba 4'e düşmüş bir oyun sonunda 7 taşın tamamı yenileniyor (üstelik geri
konan taşların bir kısmı yeniden çekilebildiğinden sonuç kısmen "aynı raf"
da olabiliyor). Oyun sonu dengesi tam da torbanın tükendiği yerde bozuluyor.

**Kural:** sınır torbanın KENDİSİ — 4 taş varsa en fazla 4. Torba boşsa
değiştirme zaten hiç açılmıyordu (`Torba boş — taş değiştirilemez.`), yani
yeni kural o kapının doğal devamı. Alternatif olarak klasik Scrabble'ın
"torbada 7'den az taş varsa değiştirme YOK" kuralı da düşünüldü ve
elendi: oyuncunun elindeki tek çıkışı tamamen kapatıyor, üstelik
kullanıcının istediği davranış da bu değildi.

**Uyarı SEÇİM anında.** `TOGGLE_SWAP_TILE` sınırı aşan dokunuşu yutup
metni basıyor; "Değiştir"e basılana kadar beklemek, sınırı ancak
reddedildiğinde öğrenmek olurdu. Metin tek kaynakta (`swapLimitMessage`)
çünkü dört kopyanın da aynı cümleyi söylemesi gerekiyor.

**Sınırın sahibi UI değil reducer.** `CONFIRM_SWAP` kontrolü TEKRAR yapıyor
— `swapSelection` state'e başka yollardan da girebiliyor (kayıttan devam,
araya giren senkron torbayı küçültebilir). Aynı ders `docs/decisions/
roadmap-arsiv.md`'deki taş korunumu vakasında da alınmıştı: bir değişmez,
onu hiç bilmeyen UI koduna emanet edilmez.

**⚠ YZ ve sıralama.** `play-ai-turn` tıkandığı turda rafın TAMAMINI
değiştirmeye gönderiyordu. Sunucu kapısı tek başına deploy edilseydi bu
hamle reddedilir, fonksiyonun `catch`i son çare olarak pas geçmeye düşer
ve **YZ Canlı oyunlarda tıkandığı her turda sessizce pas geçerdi** —
`verify-edge-engine-parity`nin doğuş sebebiyle aynı sınıftan bir arıza.
Bu yüzden migration ile Edge deploy'u ayrılmaz: ikisi birlikte gider.
Yerel YZ (`AI_PLAY`) de aynı dilimi uyguluyor ki iki yüzey ayrışmasın.

**Ölçüm:** golden vector'lar yeniden üretildi ve **bayt-eş** kaldı —
mevcut senaryoların hiçbiri bu yola girmiyordu, yani düzeltme yalnızca
erişilebilir olmaması gereken dalı kapattı. `verify-swap-invariants`e
dokuz yeni kontrol eklendi (sınırın kendisi + "sınırın altını engelleme" +
reducer'ın kendi kapısı), `verify-sql-engine-parity` metin şablonunu
kilitliyor.

## Torba neden 100 taş (ve 186 denemesi neden geri alındı)

Torba oyuncu sayısından bağımsız olarak sabit **100** taş (Türkçe dağılım,
`src/data/tiles.ts`).

Bir ara tüm modlarda 186'ya çıkarılmıştı. Simülasyon bunun torbanın gerçek
bitirişini — rafını torba boşken tamamen bitirme + rakip puanlarını kapma —
neredeyse imkânsız kıldığını gösterdi (4 oyunculuda 0/10), bu yüzden 100'e
geri dönüldü.

Bölge statik 5×5 değil dinamik/genişleyen olduğundan, 4 oyunculu oyunlarda
köşe sınırıyla etkileşim için torbayı büyütmeye (eski
`BAG_SCALE_BY_PLAYER_COUNT` denemesi) de gerek kalmadı; kaldırıldı.
