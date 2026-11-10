# Büyüme yol haritası — TASLAK (10 Kasım 2026, onay bekliyor)

**Durum: ÖNERİ.** Kullanıcı isteği (10 Kasım 2026): *"Dünyada bu tarz oyunların reklam stratejisi
konusunda araştırma yap, ona göre bir yol haritası çıkartalım. Bu şekilde bir yere varamıyoruz."*
Bu dosya karar DEĞİL; kararlar onaylandıkça `marketing/meta-reklam/` kütüğüne ve `ROADMAP.md`'ye tarihli
satır olarak düşer.

## 1. Teşhis — neden "bir yere varamıyoruz"

Ekim–Kasım'da dört Meta turu koştu (Aşama 1 → 4, ≈ ₺6.000/ay). Her tur "hangi kreatif kazanır" sorusunu
sordu ve hiçbiri karar üretemedi, çünkü:

1. **Örneklem karar vermeye yetmiyor.** Kol başına 6–29 Android kurulum (K: 6, Kare3: 17, Kare2: 28, h3: 29).
   Aynı kreatif (h3) üç kez tekrarlandı ve üç kez farklı çıktı; bir turda iki değişken birden değişti.
2. **Ölçülen şey ile istenen şey farklı.** Kampanyalar LPV/mağaza oturumu ile okundu; hedef ise
   "ayda 2+ oyun oynayan 100 yeni MAU" (5 Ekim kararı).
3. **Tek kanala yaslanıldı.** Sektörde bu türün kazananları ücretli edinmeyle büyümedi (aşağıda).
4. **Yol uzun:** reklam → web karşılama → mağaza → kurulum. Karşılamadan mağazaya geçen ≈ %4–12; ≤3 sn çıkış
   Kare2/Kare3/K'da %57–66, Aşama 1 h3'te %20.

Kendi verimizden sağlam çıkan tek şey: **kurulan oynuyor** (K: 6 Android cihazın 5'i oyun başlattı; h3: 29'un 21'i).
Sorun ürün/kalite değil, **doğru kişiyi mağazaya taşımak**.

## 2. Dünyada bu türde ne işe yaramış (güvenilirlik notlarıyla)

| Bulgu | Kanıt | Güven |
|---|---|---|
| **Wordle** ücretli edinmeyle değil **paylaşım döngüsüyle** büyüdü: 1 Kas 2021'de ~90 günlük oyuncu → Ocak başında ~300.000. Paylaş düğmesi (spoiler'sız emoji ızgarası) 16 Aralık 2021. NYT "düşük yedi haneli" fiyata aldı, "on milyonlarca yeni kullanıcı" getirdi | TechCrunch + Wardle'ın kendi tweet'i; günlük oyuncu sayıları Wardle beyanı | Orta-yüksek (ana rakamlar), düşük (ikincil bloglar) |
| **Chess.com / Lichess** büyümesi **içerik üreticileri + dış olay** (Queen's Gambit: 44 M → 61 M üye, 23 Eki 2020 → 23 Mar 2021). Chess.com "içerik ve topluluk > ücretli reklam" diyor; Lichess blogu büyümeyi yayıncılara bağlıyor | Business Insider, Lichess blogu, ikincil analiz | Orta |
| **Günlük tek bulmaca + seri (streak)** alışkanlık kuruyor; NYT oyunları abonelik tutundurma aracı olarak kullanıyor | Digiday, ticaret yorumları; NYT somut elde tutma verisi YAYINLAMIYOR | Düşük-orta |
| **Küçük bütçede sıra:** önce ASO/mağaza sayfası → arama-niyetli kanallar (Apple Ads / Google App) → sosyalde yaratıcı testi; reklam deney sayılır, bitmiş varlık değil | Satıcı/ajans blogları (çıkar çatışması var) | Düşük |
| **Mağaza sayfası testi:** Google "Store Listing Experiments" gerçek A/B; Apple Özel Ürün Sayfaları rastgele A/B DEĞİL. Bağımsız kontrollü indie çalışması bulunamadı | Satıcı yazıları | Düşük |
| **55+ kitle** bulmaca/kelime oyunlarının en büyük gruplarından; reklamlarda az temsil ediliyor. Veriler eski (PopCap ~2010, Facebook 2014) | PocketGamer.biz, GameDeveloper | Düşük-orta (eski) |
| **Genel kıyas:** Kuzey Amerika CPI ≈ $2,75–3,16 (iOS/Android); retention medyanı D1 ≈ %25, D7 ≈ %6; klasik türlerde (kelime dahil) uzun vadede ~2× | Satıcı blogları; kelime-türüne özel veri YOK | Düşük |
| **Türkiye:** yerli mobil gelir 2025 ≈ $347 M (+%6, AppMagic). **Kelimelik** yerleşik rakip: AppGoblin tahmini 10,1 M kurulum; geliştirici kendi beyanı "25 M üye" (doğrulanmadı). Kelimelik'in pazarlaması hakkında veri bulunamadı | pulse.bot/GamesIndustry, AppGoblin | Orta (gelir), düşük (kullanıcı) |

⚠ **Araştırmanın sınırı:** web arama sonuçları ince ve çoğu satıcı blogu; **sayfa okuma bu oturumda kapalıydı**
(ağ izni yok, 4 kaynak denendi). Bu bir derin araştırma DEĞİL, yön tayini. Kritik rakamlar (özellikle
Wordle ve Chess.com büyüme sayıları) karar öncesi birincil kaynaktan doğrulanmalı. Kelime oyunu türüne özel
CPI/retention için aranacak: Appodeal "Mobile Casual Benchmarks Report 2025", Liftoff "Casual Gaming Apps 2025".

## 3. Çıkarımlar (bizim için)

1. **Ücretli reklam kazananların itici gücü değil, ikinci kanalı.** Bizim durumumuzda ilk üç sırayı
   *paylaşım döngüsü*, *üretici/içerik* ve *mağaza sayfası dönüşümü* almalı.
2. **Meta'nın bulduğu kitle (65+) bu türün doğal kitlesiyle örtüşüyor** (K'da 65+ en yüksek erişim). Bu bir
   başarısızlık değil olabilir; asıl sorun bu kitlenin web karşılama → mağaza yolunda kopması olabilir.
   *Hipotez, doğrulanmadı.* Karşılaştırılacak: aynı kitleye doğrudan mağaza bağlantısı.
3. **Paylaşım döngüsü bu ürüne uymuyor (kullanıcı, 10 Kas):** skor/tahta paylaşımı alıcıya anlam taşımıyor. Wordle
   dersi "herkes aynı bulmacayı oynuyor" idi, "paylaş düğmesi koy" değil. Bizdeki karşılığı olabilecek tek şey
   **Hamle Avı** (herkese aynı pozisyon), ama bu bir *edinme kancası* olarak denenecek, paylaşım olarak değil.
4. **Asıl kayıp aktivasyonda (10 Kas, admin + canlı veri):** 1 Ekim'den beri hesap açan 61 cihazın 50'si oyun başlatmış
   ama yalnızca 28'i bitirmiş. Meta'dan gelen 23 üyenin 22'si oyun başlatmış, 10'u bitirmiş. 4 Kas'tan beri hesap
   açan 12 kişiden 5'i oyun bitirmiş, 4'ünün kayıtlı devam eden oyunu var (oynuyor, henüz bitirmemiş), 3'ünde ikisi de
   yok (7'sinin hepsi son 3 günde kaydolmuş → "bırakmış" demek için erken). ⚠ **"Oyun bitirme" aktivasyon ölçütü olarak
   kötü: oyun uzun** (13×13, 100 taş). Bitirme yerine 5. hamle ya da 2. gün dönüşü gibi bir ara ölçüt düşünülmeli.
4. **Sayılabilir bir hedef şart.** Her şey "aktif oyuncu başına maliyet"e (2+ oyun oynayan yeni cihaz) çevrilmeli.

## 3b. Ölçümler (10 Kasım 2026, ajan; kod DEĞİŞMEDİ)

**Hamle Avı bankası (1000 pozisyonun TAMAMI, üretimdekiyle aynı çözücü, `listN` 300; çözücü anahtarla 1000/1000 uyumlu):**
- En iyi hamle vergili (net < ham): **237 (%23,7)**.
- **Vergi tuzağı: 412 (%41,2)** — tahtada en yüksek HAM puanlı hamle (tahtadaki "+N" etiketi ham puanı yazıyor) doğru
  cevap DEĞİL. Vergiyi bilmeyen yeni oyuncu bu pozisyonların ≈ %41'inde "en yüksek puanı" seçip yanılır.
- Tuzaksız 588 pozisyonda en yüksek ham puanlı hamle = doğru cevap → vergi bilgisi gerekmeden çözülebilir.
  (Bunların kaçının en iyi hamlesi yine de vergili, ayrıca ölçülmedi.) Bu alt küme "giriş seviyesi" havuzu olabilir.
- Pozisyon başına çözücü süresi ≈ 0,12 sn (1000 pozisyon 119 sn).

**Karşılama ilk ekranı (canlı, build `18667d3`, soğuk ziyaretçi, `?ref=meta-k4`; Pixel 7 + iPhone 13):**
- Başlık "Kelimeyi bilmek yetmez. Nereye koyduğun kazandırır.", alt yazı bölge/vergi anlatıyor, 7×5 tahta kesitinde
  **"Vergi: puanın 1/3'ü rakibe"** rozeti var → karşılama vergi kavramını ilk ekranda zaten tanıtıyor.
- Birincil buton "HEMEN OYNA"; "Ücretsiz · Reklam yok · Üyelik gerekmez"; App Store + Google Play rozetleri; "Nasıl oynanır".
  Küçük ekranda (iPhone 13) buton alta yapışık, "Ücretsiz" satırı katlanma altında kalıyor.
- Açık bir kırık/okunmazlık görmedim. **Aynı sayfa** Aşama 1 h3'te ≤3 sn çıkış %16–25, Kare2/Kare3/K'da %57–66 verdi
  (9 Ekim'den beri karşılama kodunda yalnızca bir toplu commit + bir bağlantı eki var; ayrıntısına bakılmadı) →
  sayfa tek başına açıklamıyor; fark gelen trafikte/kreatifte olabilir. Hüküm değil, hipotez.

## 4. Önerilen yol haritası

Bütçe çerçevesi: mevcut ≈ ₺6.000/ay (Apple Ads 16 Kasım'da bitiyor). **Onay bekleyen öneri** — rakamlar kesin değil.

### Faz 0 — 10–16 Kasım: kapat ve ölçümü sabitle
- K'yı kapat, kütük + ROADMAP işlendi (10 Kas). Ads Manager'daki kesin harcamayı teyit et.
- **Tek ölçüt tanımla:** *aktif oyuncu* = 2+ oyun başlatan yeni cihaz (`funnel_events`). Kampanya raporu bunu
  kanal bazında versin (SQL tek sorgu, kütüğe yaz).
- Video 3 (Instagram) ve TikTok 2–3'ün yayın durumunu kayda geçir (`marketing/shorts-2026-10/metin.md`).
- 16 Kas: 1.1.7 kesimi (ayrı iş; bu haritayla çakışmaz).

### Faz 1 — Kasım sonu–Aralık: döngü ve mağaza (maliyet ≈ 0)
- **Mağaza dönüşümü:** Play "Store Listing Experiments" ile ekran görüntüsü/açıklama testi; ~4 Aralık Play kısa
  açıklaması okuması buna taban olur. Apple'da Özel Ürün Sayfaları bağlam için (A/B değil).
- ~~Paylaşım döngüsü (sonuç kartı + günlük bulmaca)~~ **DÜŞTÜ (10 Kas, kullanıcı):** *"İnsanların oyun sonunda
  skor veya tahta paylaşmasını beklemiyorum, kimseye bir anlam ifade etmiyor."* Wordle'da işe yarayan şey herkesin
  AYNI bulmacayı oynamasıydı; YZ'ye karşı oynanan oyunun skoru kimseye bir şey anlatmaz.
- **Hamle Avı reklamı (kullanıcı fikri, 10 Kas):** *"En yüksek puanlı hamleyi bul"* kancası, hedef = web'de
  anında oynanan Hamle Avı → ardından YZ oyunu. Kurulum/üyelik/mağaza adımı YOK: uzun yolu (reklam → karşılama →
  mağaza → kurulum) kısaltır. Ölçüt: reklam başına Hamle Avı oynayan kişi ve oradan oyun başlatan. Açık: Hamle Avı
  bugün uygulama İÇİNDE (Setup düğmesi); reklamdan doğrudan açılacak bir bağlantı/karşılama girişi YOK → küçük kod işi.
  ⚠ Aynı kanca organik Reel olarak zaten denendi (Video 1, 273 izlenme, ilk saniyede kayıp %55–91): fikir değil
  İLK SANİYE kreatifi test edilmedi/başarısız.
- **Karşılama→mağaza adımı:** web karşılamadan mağazaya geçiş oranını artırma (≈ %4–12): ilk ekranda
  mağaza rozeti zaten var, 55+ için okunabilirlik/öncelik denenir. Yalnızca hipotez.

### Faz 2 — Aralık: üretici/içerik denemesi (küçük, ölçülü)
- Türkçe kelime/zeka oyunu, satranç ve bulmaca içerik üreticilerinden **5–10** kişiye kişiye özel `?ref=` ile
  ücretsiz deneme + kısa video (Chess.com/Lichess modelinin küçük ölçeği). Ücret/ortaklık kararı kullanıcıda.
- Başarı ölçütü: üretici başına aktif oyuncu; eşik önceden yazılacak.

### Faz 3 — Ocak: ücretli kanalı yeniden kur (yalnız Faz 1–2 öğrettikten sonra)
- **Tek değişkenli Meta testi** (önceki öneri): Aşama 1 koşullarının birebir tekrarı, ≤ ₺500. Tutarsa
  ölçeklenir, tutmazsa Meta ücretli kanal olarak kapanır.
- Aktif oyuncu maliyeti ölçütü: Faz 0'da yazılan eşik.
- Google Ads arama testi (kayıtta kurulmamış) ancak tür aramalarının hacmi Search Console'da görünürse.

## 5. Karar noktaları (kullanıcıya)

1. Tek ölçüt: "2+ oyun oynayan yeni cihaz" yerine **"5. hamleyi yapan yeni cihaz"** (oyun uzun olduğu için bitirme
   kötü ölçüt; `web_sessions` `move_5` adımı var, port için ayrı kontrol gerekir) — evet/hayır?
2. ~~Paylaşım/günlük bulmaca keşfi~~ → **yerine:** Hamle Avı'nı reklam kancası olarak denemek (karşılamadan/bağlantıdan
   doğrudan açılan giriş + kreatif). Evet/hayır?
3. Üretici denemesi: bütçe ve ücretli/ücretsiz tercihi?
4. Meta tek değişkenli testi: Faz 3'te mi, hemen mi? (Masaüstü Ads Manager erişimi gerekir.)
5. Bütçenin ücretli kısmı Faz 1–2 boyunca bekletilsin mi?

## Kaynaklar (arama sonuçlarından; sayfa okunamadı)
- [TechCrunch — Wordle / NYT kullanıcı büyümesi](https://techcrunch.com/2022/05/04/wordle-new-york-times-user-growth)
- [Hustle — Wordle](https://thehustle.co/01062022-Wordle/amp/) · [Video Game Canon — Wordle tarihçesi](https://videogamecanon.com/adventurelog/the-history-of-wordle)
- [Business Insider — Chess.com ve Queen's Gambit](https://www.businessinsider.nl/chess-com-is-seeing-100000-sign-ups-a-day-following-the-success-of-netflix-series-the-queens-gambit-and-the-site-is-now-pitting-users-against-beth-harmon-bots/)
- [Chess.com — 100 milyon üye](https://www.chess.com/article/view/chesscom-reaches-100-million-members) · [Lichess blog](https://lichess.org/@/lichess/blog/100000000-games-played/VgwCfhwA)
- [Digiday — NYT oyunları ve abonelik](https://digiday.com/media/the-next-level-for-us-the-new-york-times-eyes-longer-play-sessions-for-games-in-subscription-drive/)
- [Pulse — Türkiye yerli mobil gelir 2025](https://www.pulse.bot/entertainment/news/turkiyes-domestic-mobile-revenue-grew-6-to-347m-in-2025-720c671d-6b8a-453a-a70e-58aee38a8845/) · [AppGoblin — Kelimelik](https://appgoblin.info/apps/com.he2apps.kelimelik)
- [PocketGamer.biz — 50+ oyuncular](https://www.pocketgamer.biz/over-50s-are-top-mobile-players-but-feel-overlooked) · [GameDeveloper — PopCap yaşlı oyuncular](https://www.gamedeveloper.com/game-platforms/survey-popcap-on-why-seniors-game)
- [Segwise — CPI/retention kıyasları](https://segwise.ai/blog/cpi-ipm-roas-benchmarks-optimizing-ad-spend/) · [Appodeal — Casual Benchmarks 2025](https://files.gameindustrylibrary.com/documents/mobile-casual-benchmarks-report-2025.pdf)
