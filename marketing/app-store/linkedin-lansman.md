# LinkedIn — App Store lansman gönderisi (16 Eylül 2026)

**Kanal:** LinkedIn, organik, **Kelimeki şirket sayfasından** (kullanıcı
kararı). **Amaç:** App Store indirmesi + siteye trafik.
**Kardeş dosya:** `marketing/app-store/instagram-lansman.md` — görsel
envanteri (Apple Marketing Tools'un beş karesi) orada tablolandı, burada
tekrar edilmiyor.

⚠ **Instagram metnini olduğu gibi yapıştırma.** İki platform üç noktada
ayrışıyor ve üçü de metnin kurgusunu değiştiriyor:

| | Instagram | LinkedIn |
|---|---|---|
| Gönderideki link | tıklanamaz → yol "profil → bio linki" | **tıklanabilir** → yol doğrudan |
| Etiket sayısı | 8 (kampanyayla tutarlı küme) | **3-5**; fazlası burada erişim getirmiyor |
| Okuyucu | oyuncu | oyuncu + **meslektaş**; "nasıl yapıldı" burada içerik, Instagram'da değil |

---

## 1 · Sayfa mı, kişisel profil mi — İKİSİ, bu sırayla

Gönderi sayfadan çıkar (marka kaydı orada birikir), **sonra** kişisel
profilden yeniden paylaşılır ve orada tek cümlelik bir kişisel not eklenir.
Sebep: şirket sayfalarının organik erişimi kişisel profilin gerisinde
kalıyor; yeniden paylaşım, sayfanın gönderisini kendi ağına taşıyan tek
ücretsiz yol.

⚠ **Bu bir PLATFORM TEAMÜLÜ, bu depoda ölçülmedi.** Ölçülebilir hâli §5'te:
sayfa ve profil AYRI `?ref=` etiketi taşır, hangisinin getirdiği Kaynak
Hunisi'nden okunur. İlk turda sayıyı gör, ikinci gönderide ona göre karar
ver — teamüle değil kendi rakamına güven.

⚠ **Yeniden paylaşımı gönderiyle aynı dakikada yapma**; birkaç saat ara ver,
yoksa iki gönderi aynı kişilerin akışında üst üste düşer.

## 2 · Görsel + link — ÜÇÜ BİRDEN OLMAZ, birini seç

LinkedIn gönderiye **ya** yüklediğin görseli **ya** linkin önizleme
kartını koyar; ikisini birden koymaz. Yüklenen görsel her zaman kazanır ve
link önizlemesi kaybolur. Elde üç kurgu var:

| Kurgu | Ne görünür | Ne zaman |
|---|---|---|
| **A · Yalnız link** | `kelimeki.com`un kendi OG kartı: `public/og-image.png`, **1200×630** — LinkedIn'in istediği 1.91:1 oranın tam karşılığı | Hiç görsel yüklemek istemiyorsan. Kart tıklanabilir, hazırlık gerektirmiyor |
| **B · `Square Post` 1080×1080** (16 Eylül 2026'da SEÇİLEN) | Apple'ın lansman karesi; App Store rozeti ve logo görselin İÇİNDE | Akışta kare, yatay karenin ~1,9 katı dikey yer kaplar → mobilde daha çok görünür. Link gövdede kalır, önizleme kartı çıkmaz |
| C · `Link Card Preview` 1200×628 | Aynı artwork'ün yatay hâli | B yerine yalnızca "link kartı gibi dursun" istenirse. Akışta daha az yer kaplar |
| D · PDF belge gönderisi | Çevrilebilir kareler — LinkedIn'e özgü format | `sponsored-2026-08/kelimeki-02…05.png` tek PDF'e dizilirse. Depoda böyle bir PDF **yok**; istenirse üretilir |

**Elenenler:** `Story Post` 1080×1920 (LinkedIn'de story yok), `Portrait
Banner` 720×1280 (dikey kare akışta kırpılır, üstelik düşük çözünürlük),
`Landscape Banner` 1280×720 (C ile aynı işi görüyor ama link kartı için
üretilmemiş).

⚠ **Görsel yüklenince link önizleme kartı ÇIKMAZ** — gövdedeki link düz
metin olarak tıklanabilir kalır, kart kaybolur. B'yi seçmenin bedeli bu;
karşılığı akışta kapladığı yer.

⚠ **`?ref=` parametresi önizlemeyi BOZMAZ** — OG etiketleri statik
(`index.html`), sorgu dizesinden bağımsız.

⚠ **Apple'ın banner'larına dokunma** (kırpma, üstüne yazı/logo, renk/oran
değişikliği): tescilli artwork. Gerekçe ve beş karenin tam envanteri
`instagram-lansman.md`de.

## 3 · Gönderi metni — sayfa sesi (ana)

> Kelimeki bugün App Store'da.
>
> Türkçe için sıfırdan tasarlanmış bir kelime oyunu. Klasik kelime
> oyunlarından farkı tek bir kuralda: tahtada senin bir bölgen var ve oyun,
> kelime kurarak o bölgeyi büyütmek üzerine kurulu.
>
> 13×13'lük tahtanın dört köşesi oyuncuların. Kendi köşenden başlıyorsun,
> koyduğun her taş bölgeni genişletiyor. Rakibinin bölgesine de
> oynayabilirsin — ama puanının bir kısmı o bölgenin sahibine gider. Bir
> süre sonra "hangi kelimeyi kurayım" sorusunun yerini "bu kelimeyi nereye
> koyayım" alıyor.
>
> Kutunun içinde:
> • 63.905 kelimelik sözlük (TDK Güncel Türkçe Sözlük kaynaklı) — hepsi
> anlamıyla birlikte, oyunun içinde
> • Üç zorluk seviyesinde yapay zekâ rakip: Kolay, Normal, Zor
> • Arkadaşınla sırayla oynama: her hamle için 48 saat, aynı anda çevrimiçi
> olmak gerekmiyor
> • İnternetsiz oynanır — sözlük cihazın içinde
> • Ücretsiz; reklam yok, uygulama içi satın alma yok
>
> iPhone ve iPad için App Store'da. Tarayıcıdan denemek isteyen için:
> kelimeki.com
>
> #kelimeoyunu #türkçe #appstore #mobiluygulama

**Uzunluk:** 1.009 karakter (bu dosyadan sayıldı). LinkedIn'in gönderi
sınırı 3.000, yani bolca pay var; kısaltma ihtiyacı yok.

**Neden bu kurgu:** LinkedIn mobilde ilk ~2 satırdan sonrasını *"daha
fazlasını gör"* arkasına saklıyor — haber ilk satıra, oyunun ne olduğu
ikinciye kondu. Madde listesi tarama içindir ve her madde bir itirazı
kapatıyor (sözlük güveni, rakip, arkadaşın çevrimiçi olmaması, internet,
ücret). Emoji Instagram metnindekinden az: aynı liste burada `•` ile
yazıldığında daha ciddi okunuyor.

## 4 · Kişisel profilden yeniden paylaşım (yapım notu)

Sayfanın gönderisini yeniden paylaşırken üstüne bunu yaz — LinkedIn'de
"nasıl yapıldı" kısmı asıl ilgiyi çeken parça:

> Kelimeki bugün App Store'da. Uzun süredir üzerinde çalıştığım bir yan
> proje; teknik tarafından üç not:
>
> • Oyun motoru tek bir yerde yaşamıyor: tarayıcıda TypeScript, mobilde
> Dart, sunucuda bir Edge Function ve bir Postgres fonksiyonu olarak —
> dördü de aynı fixture'larla parite testinden geçiyor, çünkü bir hamlenin
> puanını nerede hesaplarsan hesapla aynı çıkmak zorunda.
> • Uygulama internetsiz de tam çalışıyor: 63.905 kelimelik sözlük ve
> anlamları cihazın içinde. Sunucu yalnızca hesap, sıralama ve arkadaşla
> oynama için gerekiyor.
> • Web React + TypeScript, mobil Flutter. Aynı ekranın iki kez yazılması
> pahalı — ama tek bir "deneyim" olması pazarlıksızdı.
>
> Denemek isteyen: App Store'da "Kelimeki", ya da kelimeki.com

**Uzunluk:** 718 karakter — yeniden paylaşım notu için de, gerekirse ilk
yorum olarak kullanmak için de (1.250 sınırı) yeterince kısa.

⚠ **Rakam ve süre UYDURMA.** "Bir yılda yazdım", "X kişi oynuyor" gibi
cümleler bu dosyada bilerek YOK — yalnızca repodan doğrulanabilir sayılar
var (63.905 kelime = `src/data/words.ts`, anlam sayısı da aynı;
`src/data/meanings.json`). Süreyi eklemek istersen kendi takviminden yaz.

## 5 · Link ve ölçüm

| Nereye | Link |
|---|---|
| Sayfa gönderisi | `https://kelimeki.com/?ref=li-sayfa` |
| Kişisel yeniden paylaşım | `https://kelimeki.com/?ref=li-profil` |

**16 Eylül 2026 kararı: gövdede site linki, App Store linki İLK YORUMDA.**
Gerekçe ölçüm değil, LinkedIn'in masaüstü ağırlığı: `apps.apple.com` linki
masaüstünde yüklenemeyen bir vitrin sayfasıdır, kişi telefona geçip yeniden
aramak zorunda kalır. `kelimeki.com` iki tarafta da çalışıyor — masaüstünde
"Hemen Oyna" ile oyun o an oynanıyor, telefonda sayfanın üstünde ve altında
App Store rozeti duruyor (`Landing.tsx`, iki `StoreBadges`).

**App Store adresi — iki biçim:**

```
https://apps.apple.com/app/kelimeki-t%C3%BCrk%C3%A7e-kelime-oyunu/id6809809788   (kanonik, storeLinks.ts'te canlı)
https://apps.apple.com/app/id6809809788                                          (kısa hâli)
```

⚠ **Kısa hâl bu depoda DOĞRULANMADI** — oturumun ağ politikası
`apps.apple.com`a da kapalı (16 Eylül 2026'da ölçüldü). Yoruma yapıştırmadan
önce bir kez kendin dokun; açılmazsa kanonik adresi kullan.

**Neden App Store'a değil siteye:** `?ref=` ölçümü yalnızca sitede
çalışıyor; doğrudan App Store'a link verirsen o gönderiden gelen trafik
admin panelindeki Kaynak Hunisi'nde **hiç görünmez**. Site 15 Eylül'den
beri App Store rozetini gösteriyor, yani ziyaretçi bir tık sonra zaten
mağazada (`src/utils/storeLinks.ts`).

⚠ **`?ref=` İLK TEMASTA saklanıyor** (`captureUtmSource`,
`src/utils/visitTracking.ts`) — siteye daha önce uğramış biri bu linkten
girse de eski etiketiyle sayılır. Yani rakam alt sınırdır, düzeltilemez.

⚠ **Etiket `li-…` olduğu sürece huninin ÜST satırında değil, `Diğer`
grubunda görünür.** `sourceChannel` (`src/utils/adminGroups.ts`) bugün
yalnızca `ig`/`instagram` ve `fb`/`facebook` öneklerini tanıyor; tanınmayan
etiket kaybolmaz ama gruplanmaz. İki seçenek: (a) `Diğer` satırını açıp ham
etiketi oku — bugün çalışır, (b) `linkedin` kanalını ekle (`SourceChannel`
+ `SOURCE_CHANNEL_LABEL` + `li`/`linkedin` öneki + `verify-admin-groups`
satırı). ⚠ `li` önekinin sınır karakteri kuralı bunu güvenli yapıyor:
`li-sayfa` eşleşir, `link` eşleşmez.

**Sonucu nereden okursun:** Admin paneli → Büyüme › Kullanıcı › Kaynak
Hunisi. App Store indirmeleri bu hunide GÖRÜNMEZ — onlar App Store Connect
→ Analytics'te, ve LinkedIn'in kendi gönderi istatistikleri de ayrı.

## 6 · Yapma listesi

- ⚠ **Android'den söz etme.** Play production sürümü 13 Eylül'de gönderildi,
  bu dosya yazılırken hâlâ incelemede (`STORE_BADGES.googlePlay.url = null`).
  "Yakında Android'de" bir tarih taahhüdüdür; vitrin oturum AÇMADAN 404
  vermeyi bıraktığında ayrı bir gönderi çıkılır.
- ⚠ **Etiket yığma.** 3-5 yeterli; Instagram'ın sekizli kümesi buraya
  taşınmaz.
- ⚠ **`#TÜRKÇE` yazma** — `trLower` refleksi: `#türkçe`. Etiketler harf
  büyüklüğüne bakmıyor ama `#TURKCE` AYRI bir etikettir.
- ⚠ **Aynı gün üç platforma aynı metni atma.** Instagram metni oraya,
  buradaki metin buraya; ortak olan yalnızca haberin kendisi.
