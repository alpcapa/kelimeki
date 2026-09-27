# Sosyal medya — Google Play lansman gönderileri (27 Eylül 2026 turu)

**Kanallar:** Instagram · Facebook sayfası · LinkedIn (sayfa + kişisel
profil), organik. **Amaç:** Play indirmesi + siteye trafik.
**Kardeş dosyalar (App Store turu, 16 Eylül):**
`marketing/app-store/instagram-lansman.md` · `facebook-lansman.md` ·
`linkedin-lansman.md` — platform kuralları (otomatik FB paylaşımı KAPALI,
LinkedIn'de görsel ↔ link önizlemesi, etiket sayıları, kişisel profilde
sıfırdan gönderi) ORADA gerekçeleriyle yazılı; burada tekrar edilmiyor,
yalnızca farklar var.

⚠ Metinler **kod bloğunda** — iPad'den kopyalanıyor (App Store turundaki
biçim).

**Bu turun App Store turundan farkı:** Görseller Apple'ın değil, bizim
(`marketing/play-store/lansman/`, üreticisi `scripts/play-lansman/`).
Tescilli Apple artwork'ü kısıtı burada YOK, ama içindeki iki rozet
Apple'ın ve Google'ın — rozetlerin kendisine dokunulmaz.

**27 Eylül 2026 — HER görselde İKİ rozet** (kullanıcı: *"ikisinin de
olması lazım"*). Lansman setine App Store rozeti eklendi (App Store ÖNCE,
eşit yükseklik — sıra ve kapı `visibleStoreBadges`ten, `storeLinks.ts`);
üretici artık iki rozeti ve eşit yüksekliklerini ölçüp doğruluyor. Carousel
kareleri (`sponsored-2026-08/`) ve iki LinkedIn kapağı zaten mağaza
kapısından besleniyordu ama Play yayına girdikten (24 Eylül) sonra
YENİDEN ÜRETİLMEMİŞTİ — hâlâ yalnızca "App Store'da" diyorlardı; üçü de
yeniden üretildi. ⚠ Ders: `storeLinks.ts`teki bir `null` dolunca kapıya
bağlı her pazarlama üreticisi yeniden koşulmalı (`generate-play-lansman`,
`sponsored-post/build.mjs`, `generate-linkedin-cover`,
`generate-linkedin-page-cover`) — kapı kodu günceller, PNG'leri değil.

---

## 0 · Legal satırı — KULLANILMIYOR (27 Eylül 2026, kullanıcı kararı)

⚠ **Kullanıcı marka satırlarını gönderilerden BİLEREK çıkardı** (27 Eylül
2026: *"Marka satırlarını bilerek çıkarttım"*). Dört gönderinin (IG, FB,
LinkedIn sayfa + profil) metninde satır YOK. Aşağıdaki bölüm, satırların
nasıl belirlendiğinin kaydı olarak duruyor — Google ya da Apple itiraz
ederse eklenecek metin budur. Bir sonraki turda satırları kendiliğinden
geri koyma; kullanıcıya sor.

Görsellerde Google Play rozeti, metinlerde "Android" kelimesi (ve
IG/LinkedIn'de `#android` etiketi) var; ikisi de ayrı atıf istiyor.
(Apple rozeti için bkz. §0.1 — karar bekliyor.)

```
Android, Google LLC'nin ticari markasıdır.
Google Play, Google LLC'nin ticari markasıdır.
Apple, the Apple logo, iPhone, and iPad are trademarks of Apple Inc., registered in the U.S. and other countries and regions. App Store is a service mark of Apple Inc.
```

✅ **Üretici çıktısı, 27 Eylül 2026** (kullanıcı, Partner Marketing Hub →
Tools → Legal line generator; dil Turkish, iki marka öğesi AYRI satır
veriyor, Featured ↔ Incidental çıktıyı değiştirmiyor). Önceki taslaktaki
birleşik *"Google Play ve Google Play logosu Google LLC'nin ticari
markalarıdır"* üçüncü taraf belgelerinden geliyordu, üreticinin biçimi
DEĞİL. Metinlerin en altına, etiketlerden SONRA, iki satır olarak konuldu.

**Marka ekibi onayı — kullanıcı kararıyla GÖNDERİLMEDİ (27 Eylül 2026).**
Üretici sayfası "creatives must be approved before starting production"
diyor; kullanıcı organik mağaza lansmanı için gerekmediği kanısında,
Asset approval sayfası ayrıca okunmadı. Google itiraz ederse geri dönüş
yolu: rozetsiz görsel ("Google Play" yalnızca metinde → incidental).

Satırlar sosyal metinde küçük yazılamaz (platformlar boyut vermiyor);
en alttaki konum small print'in karşılığı. Unicode "küçük harf" hilesi
KULLANILMAZ — ekran okuyucu okuyamıyor, Türkçe harflerin çoğu yok.

Kılavuzun iki kuralı daha — bilerek UYGULANMADI, kullanıcı kararı bekler:
- **İlk kullanımda `Android™`**: sosyal gönderide alışılmış değil; üretici
  ya da Play rozet sayfası sosyal için istiyorsa eklenir.
- **"iyelik/çoğul yapma"**: İngilizce kuralı; Türkçede `Android'de` hâl
  eki, iyelik değil — kaçınmanın yolu yok, dokunulmadı.

### 0.1 · Apple satırı — EKLENDİ (27 Eylül 2026, kullanıcı kararı)

Görsellere App Store rozeti girdi; metinler zaten "App Store", "iPhone",
"iPad" diyor. 16 Eylül App Store turunda Apple atfı HİÇ konmamıştı (üç
dosyada da yok). Satır Apple'ın kılavuzundaki İngilizce metin — Türkçe
resmî karşılığı bu ortamdan DOĞRULANMADI (ajan apple.com'dan okumadı),
kullanıcı İngilizcesiyle eklenmesine karar verdi. Google'ın iki satırının
ALTINA, üçüncü satır olarak (dört gönderinin hepsinde; story'de legal
satırı yok):

```
Apple, the Apple logo, iPhone, and iPad are trademarks of Apple Inc., registered in the U.S. and other countries and regions. App Store is a service mark of Apple Inc.
```

---

## 1 · Görsel → kanal eşlemesi

| Dosya | Nereye |
|---|---|
| `kelimeki-google-play-kare-1080.png` | Instagram feed · Facebook gönderisi · LinkedIn (sayfa + profil) |
| `kelimeki-google-play-story-1080x1920.png` | Instagram story · Facebook story |
| `kelimeki-google-play-link-1200x628.png` | Yalnızca ÇIPLAK link paylaşımı gerekirse (LinkedIn kurgu C) |
| `kelimeki-google-play-yatay-1280x720.png` | X / YouTube topluluk / site kapağı — bu turda kullanılmıyor |
| `kelimeki-google-play-dikey-720x1280.png` | Apple setinin eşi için var; feed'e girmez (4:5'ten dar) |

**Carousel (Instagram, isteğe bağlı):** 1. kare bizim kare, 2–4.
`marketing/sponsored-2026-08/kelimeki-03 · 02 · 05.png` — App Store
turundaki sıranın aynısı. Facebook albümü dörtte durur (2×2 ızgara).

---

## 2 · Instagram

### Ana gönderi

```
Kelimeki artık Google Play'de 🎉

Türkçe için sıfırdan tasarlanmış kelime oyunu artık Android'de de. Farkı tek bir kuralda: tahtada bir bölgen var ve oyun, kelime kurarak o bölgeyi büyütmek üzerine kurulu. Bölgen ne kadar büyürse, vergi kazancın o kadar artar.

13×13'lük tahtanın dört köşesi oyuncuların. Kendi köşenden başlıyorsun, koyduğun her taşla bölgen genişliyor. Rakibinin bölgesine oynayabilirsin — ama vergisini ödersin 😏

🧩 63.000+ kelime (TDK kaynaklı), anlamlarıyla
🤖 Yapay zekaya karşı üç zorluk: Kolay, Normal, Zor
✈️ İnternetsiz oynama imkanı
👥 Arkadaşlarınla canlı oyun sırayla: her hamle için 48 saat
🆓 Ücretsiz · reklam yok · uygulama içi satın alma yok

Google Play'de "Kelimeki" diye ara ya da profildeki linke dokun 👆
iPhone'da da App Store'da. Tarayıcıda: kelimeki.com

#kelimeoyunu #zekaoyunu #bulmaca #türkçe #oyun
```

**27 Eylül 2026 — kullanıcının son hâli** (yayından önce elle düzeltildi):
vergi kazancı cümlesi eklendi, internetsiz ve canlı oyun satırları yeniden
yazıldı, "iPhone'daki arkadaşınla da" çıktı, etiketler
`#googleplay #android #yeniuygulama` → `#oyun`. Legal satırları kullanıcı
bilerek çıkardı (bkz. §0).

**App Store metninden farkı:** "iPhone'daki arkadaşınla da" — Canlı oyun
platformlar arası (aynı sunucu); Android'e yeni gelen için en güçlü satır
bu, çünkü arkadaşının hangi telefonu kullandığı artık önemsiz. Lansmana
özgü üç etiket `#googleplay #android #yeniuygulama`.

### Story (bizim story karesinin üstüne, IG yazı aracıyla)

```
Kelimeki artık Google Play'de 🎉
Android'de indir, iPhone'daki arkadaşınla oyna.
```

**27 Eylül 2026 — story'de YALNIZCA Play rozetli görsel** (kullanıcı
kararı: *"Android lansmanı olduğu için özellikle bunu seçtim"*). Kullanılan
dosya bugünkü üreticinin çıktısı DEĞİL, iki rozet eklenmeden önceki sürüm
(`git show ab921a4:marketing/play-store/lansman/kelimeki-google-play-story-1080x1920.png`). Yayındaki yazı: *"Kelimeki artık Google Play'de 🎉 /
Hemen indir, yapay zeka ile veya arkadaşınla oyna."*, sticker "Hemen İndir!".

**Link sticker:** Play adresi (§5) — story'de bio'ya gitmeden mağazaya
götüren tek yol. Sticker'ı rozetin ALTINA, dip satırın üstüne koy;
karenin üst %14'ü ve alt %20'si IG arayüzünün altında kalıyor (üretici
içeriği bu bantların dışında tutuyor, sticker'ı sen koyuyorsun).

---

## 3 · Facebook (Business Suite, IG'den AYRI yazılır)

```
Kelimeki artık Google Play'de 🎉

Türkçe için sıfırdan tasarlanmış kelime oyunu artık Android'de de. Farkı tek bir kuralda: tahtada bir bölgen var ve oyun, kelime kurarak o bölgeyi büyütmek üzerine kurulu. Bölgen ne kadar büyürse, vergi kazancın o kadar artar.

13×13'lük tahtanın dört köşesi oyuncuların. Kendi köşenden başlıyorsun, koyduğun her taşla bölgen genişliyor. Rakibinin bölgesine oynayabilirsin — ama vergisini ödersin 😏

🧩 63.000+ kelime (TDK kaynaklı), anlamlarıyla
🤖 Yapay zekaya karşı üç zorluk: Kolay, Normal, Zor
✈️ İnternetsiz oynama imkanı
👥 Arkadaşlarınla canlı oyun sırayla: her hamle için 48 saat
🆓 Ücretsiz · reklam yok · uygulama içi satın alma yok

🤖 Android için Google Play:
https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki&referrer=utm_source%3Dfb-sayfa-play

📱 iPhone ve iPad için App Store:
https://apps.apple.com/app/id6809809788?ct=fb-sayfa-play

💻 Tarayıcıda hemen oyna:
https://kelimeki.com/?ref=fb-sayfa-play

#kelimeoyunu #zekaoyunu #türkçe
```

**27 Eylül 2026:** gövde Instagram'daki kullanıcı düzeltmeleriyle eşitlendi (vergi cümlesi, internetsiz ve canlı oyun satırları); linkler ve etiketler FB'nin kendi hâlinde kaldı.

**Neden App Store linki de var:** App Store gönderisi 16 Eylül'de
Android'den bilerek söz etmemişti (Play incelemedeydi); bu gönderi ikisini
birden veren İLK gönderi. Sayfanın gönderisini gören iPhone'lu da boşa
düşmesin.

---

## 4 · LinkedIn

Kurgu App Store turundaki **B**: kare görsel yüklenir, link gövdede düz
metin olarak tıklanabilir kalır (önizleme kartı çıkmaz — bilinen bedel).

### Sayfa sesi

```
Kelimeki bugün Google Play'de.

16 Eylül'de App Store'a çıkan Türkçe kelime oyunumuz artık Android'de de. Tahtada senin bir bölgen var; kelime kurarak onu büyütüyorsun, rakibinin bölgesine oynarsan puanının bir kısmı ona gidiyor. Bir süre sonra "hangi kelimeyi kurayım" sorusunun yerini "bu kelimeyi nereye koyayım" alıyor.

Kutunun içinde:
• 63.905 kelimelik sözlük (TDK Güncel Türkçe Sözlük kaynaklı), hepsi anlamıyla
• Üç zorluk seviyesinde yapay zekâ rakip: Kolay, Normal, Zor
• Platformlar arası oyun: Android'deki oyuncu iPhone'daki arkadaşıyla aynı oyunu oynuyor
• İnternetsiz oynanır — sözlük cihazın içinde
• Ücretsiz; reklam yok, uygulama içi satın alma yok

Android için Google Play:
https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki&referrer=utm_source%3Dli-sayfa-play

iPhone ve iPad için App Store:
https://apps.apple.com/app/id6809809788

Tarayıcıda: https://kelimeki.com/?ref=li-sayfa-play

#kelimeoyunu #türkçe #googleplay #mobiluygulama
```

### Kişisel profil (sıfırdan gönderi, sayfadan birkaç saat SONRA)

**@Kelimeki** elle yazılıp listeden seçilir (yapıştırınca düz metin kalır).

```
Kelimeki artık Google Play'de de 🎉

Üzerinde çalıştığım Türkçe kelime oyunu 16 Eylül'de App Store'a çıkmıştı; bugün Android sürümü de yayında. Tek bir kod tabanından iki mağazaya — ve en sevdiğim kısmı: Android'deki oyuncu iPhone'daki arkadaşıyla aynı oyunu oynuyor.

Denemek isteyene:
https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki&referrer=utm_source%3Dli-profil-play

iPhone'da App Store'da, bilgisayarda https://kelimeki.com/?ref=li-profil-play

@Kelimeki
```

⚠ "Tek bir kod tabanından" iddiası mobil uygulama için doğru (Flutter,
iOS + Android aynı kod); web ayrı bir kod tabanı. Metin yalnızca iki
mağazadan söz ediyor, yani doğru — "üç platform, tek kod" diye
GENİŞLETME.

---

## 5 · Link ve ölçüm

| Nereye | Link |
|---|---|
| Instagram bio | `https://kelimeki.com/?ref=ig-bio` (mevcut — DEĞİŞTİRME) |
| IG story sticker | `https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki&referrer=utm_source%3Dig-story-play` |
| Facebook (site / Play / App Store) | `?ref=fb-sayfa-play` · `referrer=utm_source%3Dfb-sayfa-play` · `?ct=fb-sayfa-play` |
| LinkedIn sayfa | `?ref=li-sayfa-play` · `referrer=utm_source%3Dli-sayfa-play` |
| LinkedIn profil | `?ref=li-profil-play` · `referrer=utm_source%3Dli-profil-play` |

**Neden yeni etiketler (`-play` soneki):** `?ref=` ilk temasta
sabitleniyor; 16 Eylül'ün `fb-sayfa`/`li-sayfa`/`li-profil`
etiketleri tekrar kullanılırsa iki lansman Kaynak Hunisi'nde tek satıra
karışır. Kod değişikliği GEREKMİYOR: `sourceChannel`
(`src/utils/adminGroups.ts`) `fb-`/`li-`/`ig-` önekli her etiketi kendi
kanal grubuna topluyor.

**Play linkindeki `referrer=`:** Play'in Install Referrer parametresi —
indirme Play Console → Kullanıcı edinme'de UTM kampanyası olarak görünür.
⚠ **Bu hesapta ÖLÇÜLMEDİ** (ajan `play.google.com`'a erişemiyor). Console'da
görünmezse parametre zararsızdır, link aynen mağazaya gider. Değer
URL-kodlu (`%3D` = `=`); elle düzeltip `=` yazma, Play onu ayrı parametre
sanar.

**Sonucu nereden okursun:** site ziyaretleri admin paneli → Kaynak Hunisi
(Facebook / LinkedIn grupları, `-play` satırları); Play indirmeleri Play
Console → Grow users → Acquire (UTM satırları, görünürse). Mağazaya
doğrudan giden tıklama Kaynak Hunisi'nde GÖRÜNMEZ.

---

## 6 · Yapma listesi

- ❌ App Store turunun etiketlerini (`fb-sayfa`, `li-sayfa`, `li-profil`)
  tekrar kullanma — iki lansman karışır (§5).
- ❌ Rozetleri kırpma, yeniden renklendirme, sırasını değiştirme (App
  Store önce) ya da üçüncü bir rozet bindirme. Rozet dışındaki her şey bizim, değiştirilebilir —
  üreticiden (`npm run build && npm run generate-play-lansman`).
- ❌ Instagram'ın otomatik Facebook paylaşımını açma (gerekçe:
  `app-store/facebook-lansman.md` §1).
- ❌ Bio linkini doğrudan Play'e çevirme — o trafik hunide hiç görünmez.

---

## 7 · Yayın kütüğü

| Ne zaman | Ne | Ölçüm |
|---|---|---|
| 27 Eyl 2026 12:20 | Instagram story — yalnızca Play rozetli görsel, "Hemen İndir!" link sticker'ı (`ig-story-play`) | Play Console → Acquire (UTM `ig-story-play`, görünürse) |
