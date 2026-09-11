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

