# Meta reklam kampanyası — Ekim 2026 (iOS + Android, Instagram + Facebook)

**Karar tarihi:** 28 Eylül 2026. Kullanıcı: *"genel bir kampanya planlayalım,
sadece Play için yapmayalım"*; aynı gün: *"2 store ortak bir hale getirelim,
tüm ios ve android cihazlara çıkartalım"*.
**Amaç:** iki mağazadan kurulum + tarayıcıda oyun, ve her liranın neyi
getirdiğini okuyabilmek.
**Kardeş dosyalar:** organik gönderiler `marketing/play-store/sosyal-lansman.md`
ve `marketing/app-store/*-lansman.md`. İlk ücretli deneme (Ağustos kareleri,
16 Eylül boost'u) `marketing/sponsored-2026-08/metin.md`.

⚠ Metinler iPad'den kopyalanacağı için **kod bloğunda**.

---

## 0 · Özet

| | |
|---|---|
| Kampanya | **1 kampanya**, hedef **Trafik** |
| Reklam seti | **1 set**, bütün telefonlar (iOS + Android). Reklam `kelimeki.com/?ref=meta-…`e gider; mağazaya sitedeki rozetten geçilir, telefonda tarayıcıda da oynanır (§3.0) |
| Reklamlar | **3 reklam:** carousel · reel · tek kare |
| Bütçe | Toplam **₺3.000**. Test: 5 gün × ₺200/gün. Ölçek: en iyi reklam(lar)la 5 gün × ₺400/gün |
| Kurulum yeri | **Tarayıcıdan Ads Manager.** iOS uygulamasından verilen reklama Apple'ın %30 ücreti ekleniyor (§7) |
| Başlangıç | **Web PR'ı (#673) canlıya çıkınca** (§1) |
| Başarı ölçüsü | Erken sinyal: **mağazaya giden oturum başı maliyet** (bizim tablo, anında). Asıl ölçü: **kurulum başı maliyet** (mağaza raporları, 1-2 gün gecikmeli). Meta'nın tıklama sayısı ölçü DEĞİL (§2, §6) |

---

## 1 · Başlangıç — web PR'ı canlıda olunca

**Başlangıç koşulu:** PR #673 `main`'e merge edildi **ve** `kelimeki.com`'un
derleme kimliği o commit'i gösteriyor (`curl -s https://kelimeki.com/ | grep
kelimeki-build`). Bu olmadan sitedeki rozet linkleri reklam etiketini
taşımaz ve mağazaya giden kurulum "organik" görünür.

İlk plan reklamı doğrudan mağazaya gönderiyordu; Android'de kurulumdan
sonrasını görmek için Huni v2'nin mobil yarısını (5 Ekim treni,
`docs/decisions/funnel-v2.md` → "Pazarlama kapısı") bekleyecekti. Reklam
artık siteye gittiği için yolun tamamı bizim web tablomuzda görünüyor; o
kapı ön koşul değil. Mobil yarı gelince Android'de bir halka daha görünür:
mağazadan kurulan uygulamanın ilk açılışı ve oyunu.

---

## 2 · 16 Eylül boost'undan ders

| Kaynak | Sayı |
|---|---|
| Meta (Business Suite) | 35,3K erişim · **1,6K link tıklaması** · ₺2.598 |
| Bizim tablo (`guest_visits`, `?ref=instagram`) | **5 misafir cihaz**, 25 oyun başlangıcı |

⚠ **Bu iki sayı aynı şeyi ölçmüyor, "₺500/ziyaretçi" diye OKUMA.**
16 Eylül'de karşılama sayfasının (`/`) kendi ziyaret pingi henüz YOKTU.
`misafirZiyaretiBildir` (`src/main.tsx`) 24 Eylül'de eklendi (#621). O gün
yalnızca karşılamadan geçip uygulamayı açan kişi sayılıyordu. Yani 5 sayısı
"siteye gelen" değil, **"oyuna geçen"** misafir sayısı. Karşılamaya gelip
çıkanlar hiç ölçülmedi.

Kesin olan iki şey var:
1. **Meta'nın "link tıklaması" kalite ölçüsü değil.** Görsele, "daha fazla"ya
   ve profile yapılan dokunuşları da sayıyor. Boost bu ölçüye göre optimize
   ediyor, yani ucuz ama boş tıklama satın alıyor.
2. **O gün karşılamadan mağazaya geçiş hiç ölçülmüyordu.** Bu kampanyada
   karşılama, mağaza rozeti (`store` adımı), oyun ve üyelik reklam
   etiketiyle ölçülüyor (§3.0, §5).

---

## 3 · Kampanya yapısı

### 3.0 · ⚠ Meta, Trafik kampanyasında mağaza linkine İZİN VERMİYOR

28 Eylül 2026, kurulum sırasında Ads Manager'ın kendi hatası:

> *"Uygulama URL'si sadece Uygulama Yüklemeleri reklam verme amacında
> destekleniyor… (#1487810)"*

Bu belgenin ilk sürümü reklamı `play.google.com` / `apps.apple.com`
adresine gönderiyordu, cihaza göre iki ayrı setle. O kurgu çalışmaz.

| Yol | Ne | Karar |
|---|---|---|
| **1** | Trafik kalır, reklam `kelimeki.com/?ref=meta-…`e gider. Mağazaya sitedeki rozetten ya da telefondaki mağaza şeridinden geçilir | ✅ **Seçildi** (kullanıcı, 28 Eyl) |
| 2 | Yeni bir "Uygulama tanıtımı" kampanyası. Uygulamanın Meta for Developers'a kaydı gerekir, iOS'ta SKAdNetwork kısıtları var, SDK'sız davranışı doğrulanmadı | Elendi |

Site iki rozeti de gösterdiği için cihaza göre ayrı set tutmanın gerekçesi
kalmadı; aynı gün **tek sete** geçildi. Cihaz kırılımı yine okunuyor:
bizim tabloda `web_sessions.device_type`, Ads Manager'da **Döküm →
Etkileşim cihazı**.

**Bunu mümkün kılan web değişikliği (PR #673):**
- Sitedeki mağaza rozetleri ve telefon şeridi ziyaretçinin `?ref=` etiketini
  mağazaya taşıyor (`taggedStoreUrl`, `src/utils/storeLinks.ts`):
  - Play: `referrer=utm_source%3D<etiket>%26utm_medium%3Dweb`
  - App Store: `ct=<etiket>`
- Rozete dokunmak ziyaretçi yolculuğuna **`store`** adımı yazıyor
  (`web_sessions`, migration `20260928100430_web_journey_store_step`).
  Admin → Ziyaretçi Yolculuğu kartında "Mağazaya gitti" satırı.

### 3.1 · Neden "Trafik" ve neden optimizasyon "Yönlendirme sayfası görüntülemeleri"

- Sitede **Meta pixel'i yok**, uygulamada **Meta SDK'sı yok**. İkisi de
  bilinçli karar: üçüncü taraf izleyici kullanılmıyor. Eklemek gizlilik
  metnini, Data safety formunu ve App Store gizlilik etiketini değiştirir.
- Bu yüzden Meta kurulumu ya da üyeliği göremiyor. **"Uygulama tanıtımı"**
  hedefi SDK olmadan kör optimize eder; Ads Manager'da "Uygulama" dönüşüm
  konumu zaten gri geliyor.
- **Performans hedefi: "Yönlendirme sayfası görüntülemelerinin sayısını en
  üst seviyeye çıkar"** (eski adı "Açılış sayfası görüntülemeleri").
  - ⚠ Bu belgenin ilk sürümü "pixel ister" diyordu, **YANLIŞTI.** Ads
    Manager 28 Eylül'de: *"Yönlendirme sayfası görüntülemeleri artık Meta
    Pikseli entegrasyonu gerektirmiyor"*; bağlantı tıklamalarına göre sonuç
    başına ~%23 daha düşük ücret tahmin ediyordu.
  - "Bağlantı tıklamaları"na göre farkı: sayfa gerçekten yüklenmeden çıkan
    dokunuşları saymıyor. 16 Eylül'ün sorunu tam buydu.
  - Hedef artık `kelimeki.com` (Meta'nın tarayıcısında açılıyor), yani
    görüntüleme ölçülebilir. İlk 48 saatte bağlantı tıklaması var ama
    yönlendirme sayfası görüntülemesi ~0 ise yine de "Bağlantı
    tıklamaları"na çevir (öğrenmeyi baştan başlatır, bir kez yapılır).

### 3.2 · Kampanya düzeyi

| Alan | Değer |
|---|---|
| Kampanya adı | `Kelimeki · Ekim 2026 · Trafik` |
| Satın alma türü | Açık Artırma |
| Hedef | **Trafik** · kurulum **Manuel** ("Tavsiye edilen ayarlar" DEĞİL — reklam alanlarını Advantage+'a kilitliyor) |
| Özel reklam kategorisi | Yok |
| Bütçe stratejisi | **Reklam seti bütçesi.** "Bütçenin %20'sini diğer setlerle paylaş" işaretsiz |
| Kampanya harcama sınırı | ₺3.000 |
| A/B testi | Kapalı |

### 3.3 · Reklam seti düzeyi — tek set

⚠ **Taslakta kurulu `A · Android → Play` setini düzenle, yenisini açma.**
Değişen satırlar **kalın**.

| Alan | Değer |
|---|---|
| Set adı | **`Mobil · kelimeki.com`** |
| Dönüşüm konumu | İnternet Sitesi |
| Performans hedefi | Yönlendirme sayfası görüntülemelerinin sayısını en üst seviyeye çıkar. Teklif stratejisi **En yüksek hacim**, tutar boş |
| Günlük bütçe (test) | **₺200** |
| Takvim | Başlangıç + bitiş (5 gün). Meta başlangıcı en fazla ~1 hafta ileri alıyor; yayından önce gerçek tarihe çek |
| Konum | Türkiye · "Bu konumda yaşayan kişiler" |
| Yaş | Minimum 18 (kesin sınır). Öneri yaşı boş |
| Dil | Türkçe |
| Detaylı hedefleme | Advantage+ hedef kitle **açık**. Öneri: *Kelime oyunları, Bulmaca, Scrabble, Wordle*. "Hedef kitlenizi daha fazla sınırlayın" KULLANMA |
| Reklam alanları | Açık: FB Akış · IG Akış · IG Keşfet (ve ana sayfası) · FB/IG Hikayeler · FB/IG Reels. Kapalı: profil akışları, Marketplace, Bildirimler, sağ sütun, işletme keşfi, Threads, Messenger, WhatsApp Durum, yayın içi Reels reklamları, arama sonuçları, **Uygulamalar ve siteler (Audience Network)**. "Hariç tutulan alanlarda sınırlı harcama" **işaretsiz** |
| Cihazlar | **Mobil → "Tüm mobil cihazlar"** (Android + iOS). "Sadece Android" seçimini kaldır; işletim sistemi sürümü alanı kaybolur |
| Wi-Fi koşulu | Kapalı |

**Meta bütçeyi ucuz cihaza kaydırabilir** (genelde Android). Bu kabul
edilen bir durum: soru "hangi cihaz daha ucuz kurulum getiriyor", ve cevabı
§5'teki sorgu ile Ads Manager'ın **Döküm → Etkileşim cihazı** kırılımı
veriyor.

---

## 4 · Reklamlar — üç tane

Reklam adları etiketle aynı olsun ki Ads Manager, mağaza raporları ve bizim
tablo yan yana okunabilsin.

| Reklam | Biçim | Görsel | Hikaye / Reels alanı |
|---|---|---|---|
| `karusel` | Carousel, 4 kart | `sponsored-2026-08/kelimeki-01 → 03 → 02 → 05.png` (2160², iki rozetli) | Meta 1:1 kartları kendisi yerleştirir |
| `reel` | Tek video | `sponsored-2026-08/kelimeki-reel.mp4` (9:16, 9,4 sn; 28 Eyl'den beri alt şeritte iki rozet) | Videonun kendisi |
| `kare` | Tek görsel | `sponsored-2026-08/kelimeki-01.png` | **Görseli değiştir →** `meta-reklam/kelimeki-story-1080x1920.png` |

**Görseller mağazadan bağımsız olmalı.** `kelimeki-01…05` ve yeni hikaye
görseli iki rozeti birlikte taşıyor. ⚠ `play-store/lansman/*` görselleri
("Artık Google Play'de") bu kampanyada **KULLANILMAZ** — iPhone'da yanlış.

**Hikaye görseli** (`meta-reklam/kelimeki-story-1080x1920.png`): Play
lansman story'sinin mağazadan bağımsız varyantı. Başlık "Kelime bul,
bölgeni büyüt, tahtayı ele geçir.", alt satır "Strateji odaklı Türkçe
kelime oyunu", iki rozet (App Store önce, eşit yükseklik). Üretici:
`npm run build && npm run generate-meta-story` (`scripts/play-lansman/`,
`--genel`); içeriği Instagram'ın üst %14 / alt %20 bantlarının dışında
tuttuğunu ölçüyor.

**Kart sırası (carousel):** 01 durdurur (bu ne) → 03 farkı anlatır (köşe →
bölge → merkez → vergi) → 02 kanıtlar (gerçek tahta) → 05 çağırır (rütbeler +
rozetler). 04 bilerek dışarıda.

| Kart | Görsel | Kart başlığı |
|---|---|---|
| 1 | kelimeki-01 | `Kelime bul, bölgeni büyüt` |
| 2 | kelimeki-03 | `Köşeden başla, tahtayı sar` |
| 3 | kelimeki-02 | `Gerçek tahta, gerçek oyun` |
| 4 | kelimeki-05 | `Ücretsiz · reklamsız` |

**Reel'in müziği:** video sessiz. Medya düzenleyicisinde "Müzik ekle" →
telifsiz, sakin bir parça. IG'nin trend sesleri reklamda kullanılamaz.

**İndirme linkleri** (Safari'de uzun bas → "Bağlantılı dosyayı indir"; hikaye
görseli PR #673 merge edilince `main`'de):
```
https://github.com/alpcapa/kelimeki/raw/main/marketing/sponsored-2026-08/kelimeki-01.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/sponsored-2026-08/kelimeki-02.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/sponsored-2026-08/kelimeki-03.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/sponsored-2026-08/kelimeki-05.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/sponsored-2026-08/kelimeki-reel.mp4
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/kelimeki-story-1080x1920.png
```

### 4.1 · Metinler — üç reklamda da aynı

**Birincil metin — varyant 1 (kanca: soru)**
```
Bu bir kelime oyunu ama asıl soru şu: kelimeyi NEREYE koyacaksın? 🧩

Tahtada senin bir bölgen var. Kelime kurdukça büyüyor. Rakibinin bölgesine oynayabilirsin — ama vergisini ödersin 😏

🤖 Yapay zekaya karşı: Kolay, Normal, Zor
👥 Arkadaşlarınla sırayla: her hamle için 48 saat
✈️ İnternetsiz de oynanır
🆓 Ücretsiz · reklamsız · satın alma yok
📱 App Store ve Google Play'de, tarayıcıda da
```

**Birincil metin — varyant 2 (kısa)**
```
Kelime bul, bölgeni büyüt, tahtayı ele geçir 🧩
Türkçe için sıfırdan tasarlanmış strateji kelime oyunu. 63.000+ kelime, yapay zeka rakip, arkadaşlarla canlı oyun. iPhone'da, Android'de ve tarayıcıda ücretsiz.
```

**Başlık**
```
Kelimeki — ücretsiz Türkçe kelime oyunu
```

**Açıklama**
```
App Store ve Google Play'de
```

**Eylem çağrısı:** `İndir` (listede yoksa `Şimdi Yükle`, o da yoksa `Daha
Fazla Bilgi`). Varsayılan `Detayları Gör` gelir, değiştir.

**Reklam düzeyindeki öteki ayarlar:**
- Kimlik: Kelimeki sayfası + `kelimeki` Instagram.
- "Reklamları alışveriş deneyimine dönüştürün" → **Daha sonra hatırlat**.
- ⚠ **"Çok reklamverenli reklamlar" varsayılan İŞARETLİ gelir — kaldır**
  (görsel kırpılabiliyor, rozetler kırpılmamalı).
- Advantage+ kreatif iyileştirmeleri ve "en iyi kartı önce göster": **hepsi kapalı**.
- "Daha Fazlasını Gör" görünen bağlantısı boş. Kişiselleştirilmiş
  yönlendirme hedefleri "Kapalı".
- Kreatif testi: yok. Takip → internet sitesi / uygulama / çevrimdışı
  olaylar: **Ayarla'ya basma**. URL parametreleri boş.

### 4.2 · Metin kuralları

- İki birincil metin varyantını reklamın **metin seçeneği** alanlarına
  birlikte gir; Meta hangisini daha çok göstereceğine kendi karar verir.
- **Metne link YAZMA.** Link reklamın "İnternet Sitesi Adresi" alanında (§5).
- **Etiket (#) YOK.** Reklamda hashtag erişim getirmez.
- **Marka satırı YOK.** Organik turdaki kullanıcı kararıyla aynı
  (`sosyal-lansman.md` §0).
- "63.000+" ve "üç zorluk" gibi sayılar değişirse metin bayatlar. Kaynak:
  README'deki kelime sayısı ve `AI_LEVEL_TOP_N`.

---

## 5 · Linkler ve etiketler

**Kural:** her reklamın **kendi etiketi** var; cihaz etikette DEĞİL,
ölçümden geliyor. Önek `meta-`, çünkü reklam FB ve IG'de birlikte koşuyor.

| Reklam | İnternet Sitesi Adresi (URL) |
|---|---|
| karusel | `https://kelimeki.com/?ref=meta-karusel` |
| reel | `https://kelimeki.com/?ref=meta-reel` |
| kare | `https://kelimeki.com/?ref=meta-kare` |

Carousel'de kartların kendi URL alanı varsa dördüne de aynı adres. Reklamda
mağaza linki YOK (§3.0). Site etiketi ilk temasta saklıyor
(`captureUtmSource`) ve mağaza rozetine kendisi ekliyor.

**Etiketin nerede göründüğü:**
- **Bizim tablo (anında):** `web_sessions` — etiket başına ve cihaz başına:
  ```sql
  select utm_source, device_type, count(*) oturum,
         count(*) filter (where 'store' = any (steps)) magazaya,
         count(*) filter (where 'game_start' = any (steps)) oyun,
         count(*) filter (where 'signup_done' = any (steps)) uye
  from web_sessions
  where utm_source like 'meta-%' and created_at > now() - interval '14 days'
  group by 1, 2 order by 1, 2;
  ```
  ⚠ Yalnızca **misafir** oturumu yazılır; girişli ziyaretçi sayılmaz.
- **Play Console → Kullanıcı edinme:** `utm_source=meta-*`, `utm_medium=web`.
- **App Store Connect → Kampanyalar:** `ct=meta-*`. ⚠ Apple'ın kampanya
  linki büyük ihtimalle bir de **sağlayıcı numarası (`pt=`)** istiyor; site
  bunu bilmiyor. Öğrenmenin yolu: App Store Connect → Uygulama Analizi →
  Edinme → Kampanyalar → "Kampanya bağlantısı oluştur"; üretilen linkteki
  `pt=` sayısını §9'a yaz, `taggedStoreUrl`e eklenir. Doğrulanmadı (ajan
  `apps.apple.com`'a erişemiyor, Console kullanıcıda).

**Admin paneli notu:** `meta-` öneki admin'in kanal gruplamasında
(`sourceChannel`, `src/utils/adminGroups.ts`) YOK; bu etiketler Kaynak/Kanal
tablolarında **"Diğer"** grubunda görünür, kaybolmaz. Ayrı bir "Meta" grubu
istenirse tek satırlık web değişikliği (+ `verify-admin-groups`).

---

## 6 · Takvim ve karar kuralları

| Faz | Ne zaman | Ne |
|---|---|---|
| **0 · Hazırlık** | Bugünden PR #673 canlıya çıkana kadar | Harcama limiti (§7) · tek seti §3.3'e göre düzenle, **taslak** kalsın · üç reklamı §4-§5'e göre kur · başlangıç ölçümü: kampanyadan önceki 7 günün Play "Mağaza girişi edinmeleri" ve ASC "İlk indirmeler" sayılarını §9'a yaz · isteğe bağlı: App Store `pt=` (§5) |
| **1 · Test** | PR #673 canlıda (§1), 5 gün | Tek set × ₺200/gün = ₺1.000 |
| **Karar** | 6. gün (+1-2 gün mağaza verisi) | Aşağıdaki kurallar |
| **2 · Ölçek** | 5 gün | Set ₺400/gün, yalnızca kazanan reklam(lar) açık |
| **Kapanış** | Bitişin ertesi haftası | §9'a sonuç satırları |

**Veri gecikmesi:** Play Console edinme raporu 1-2 gün, ASC kampanya verisi
24-48 saat gecikir; Apple küçük sayıları gizlilik eşiği yüzünden
göstermeyebilir. İlk 2 günde bütçeye/metne dokunma (Meta'nın öğrenme dönemi).

**Karar kuralları** (Faz 1 sonunda):

| Durum | Karar |
|---|---|
| Kurulum başı ≤ **₺40** | Devam; Faz 2 |
| ₺40-80 | En iyi reklamı bırak, ötekileri kapat, ₺200/gün'le 5 gün daha |
| ≥ ₺80 ya da ₺500 harcandı ve ≤ 5 kurulum | Dur. Sorun kreatif ya da hedef kitle; yeni kreatif turu |
| Reklam düzeyinde: 3 günde bağlantı TO < %0,5 | O reklamı kapat |
| Bir cihazda kurulum başı ötekinin 2 katından fazla | Faz 2'de cihazı daralt (set → yalnızca ucuz olan) |

- **Kurulum başı** = harcama ÷ (Play `utm_source=meta-*` + ASC `ct=meta-*`
  kurulumları). Reklam başına: reklamın harcaması ÷ o etiketin kurulumları.
- **Erken sinyal:** harcama ÷ `store` adımına ulaşan oturum (§5 sorgusu).
  Mağazaya giden her kişi kurmaz; bu sayı kurulum başından hep DÜŞÜK çıkar,
  eşiklerle doğrudan karşılaştırma.
- **Meta'nın "sonuç başı maliyet"i bu değil:** o, görüntüleme/tıklama başı.
- ₺40 bir başlangıç tahmini; Faz 1'in ilk gerçek rakamı eşiği yeniden
  belirler, buraya yaz.
- **Kalite:** kurulum ucuz ama kimse oynamıyorsa kazanan sayılmaz. Tarayıcıda
  oynayanı §5 sorgusunun `oyun`/`uye` sütunları gösterir; Android'de Huni
  v2'nin mobil yarısı gelince (5 Ekim treni) uygulamadaki oyun da görünür.

---

## 7 · Ödeme ve Apple komisyonu

- **Reklamı ASLA Facebook/Instagram iOS uygulamasından verme ya da öne
  çıkarma.** Meta, iOS uygulamasından yapılan öne çıkarmalara Apple'ın %30
  hizmet ücretini ekliyor. Tarayıcıdan verilen reklamda bu ücret yok.
- iPad Safari'de: `adsmanager.facebook.com`. Sayfa uygulamaya atıyorsa
  Aa menüsü → **Masaüstü Web Sitesini İste**.
- **Ödeme yöntemi:** Ads Manager → ☰ → **Faturalama ve ödemeler** →
  **Ödeme ayarları** → **Ödeme yöntemi ekle** → kart (kredi ya da banka
  kartı) ya da PayPal. Reklam harcandıkça karttan çekilir; eşiğe ya da ay
  sonuna göre fatura kesilir.
- **Fon ekle / ön ödemeli bakiye:** bazı hesaplarda ve para birimlerinde
  görünür. TL hesapta çıkıp çıkmadığı doğrulanmadı. Görürsen ₺3.000
  yüklemek harcamayı baştan sınırlar.
- **Hesap harcama limiti: ₺3.000** (Ödeme ayarları → Hesap harcama limiti).
  Bir set yanlışlıkla bitişsiz kalsa bile tavan bu.
- **Vergi:** Meta TL faturasına KDV ekleyebilir. Planlanan ₺3.000 reklam
  harcaması; faturadaki toplam bundan fazla olabilir. İlk faturadan gerçek
  oranı okuyup §9'a yaz.
- **16 Eylül'ün ₺2.598'i:** iPad uygulamasından verildiyse faturada Apple
  ücreti olabilir. Faturalama → İşlemler → o işlemin makbuzundan kontrol
  et. Bu dosyaya hiç yazılmadı.

---

## 8 · Yapma listesi

- ❌ Gönderi altındaki **"Öne Çıkar"** düğmesi. Etiket ve cihaz ayarı orada
  yok, iOS uygulamasından Apple ücretiyle geliyor (§2, §7).
- ❌ Reklam URL'sine mağaza linki (`play.google.com`, `apps.apple.com`).
  Trafik kampanyası reddeder (#1487810, §3.0).
- ❌ "Artık Google Play'de" görselleri (`play-store/lansman/*`). Set artık
  iPhone'a da gidiyor.
- ❌ Kampanya düzeyinde bütçe (CBO) ya da "Tavsiye edilen ayarlar".
- ❌ Sağ paneldeki "Advantage+ reklam alanları → Şimdi uygula" önerileri.
  Yapılan reklam alanı ayarlarını geri alıyor; puan kalite ölçüsü değil.
- ❌ Etiketi yeniden kullanmak. `instagram`, `ig-bio`, `fb-sayfa-play` gibi
  eski etiketler organik turlarındır; `?ref=` ilk temasta sabitlendiği için
  karışırsa sonradan ayrılamaz.
- ❌ Meta'nın "sonuç" sayısını kurulum sanmak (§6).
- ❌ İlk 48 saatte bütçe ya da metin değiştirmek.
- ❌ Pixel ya da SDK "hızlıca" eklemek. Gizlilik metni, Data safety ve App
  Store etiketi değişir; ayrı bir karar konusu.

---

## 9 · Yayın kütüğü

| Ne zaman | Ne | Ölçüm |
|---|---|---|
| 28 Eyl 2026 | **Kurulum:** "Kelimeki" işletme portföyü + reklam hesabı `1089910146731962` açıldı (kişisel hesaptan AYRI; 16 Eylül boost'u kişisel hesaptaydı). Mastercard tanımlandı, otomatik ödeme, fatura eşiği ₺99. Meta'nın günlük tavanı ₺10.781,62. Hesap harcama limiti henüz KONMADI. Ads Manager "Hesaba Genel Bakış'ta birkaç detayı onaylayın" diyor | Kullanıcının ekran görüntüsünden okundu |
| 28 Eyl 2026 | **Plan değişti:** Set A'nın `karusel` reklamına Play linki yazılınca Ads Manager #1487810 verdi (Trafik'te mağaza linki yok). Kullanıcı Yol 1'i seçti (§3.0). Web değişikliği PR #673'te; `store` adımının migration'ı (`20260928100430_web_journey_store_step`) **canlıya uygulandı** ve doğrulandı (iki fonksiyonda da `store` var, grant'ler ve `security definer` aynı) | `pg_get_functiondef` · `list_migrations` |
| 28 Eyl 2026 | Set A kuruldu (taslak): Trafik · yönlendirme sayfası görüntülemeleri · ₺100/gün · 5-10 Ekim (Meta başlangıcı en fazla ~1 hafta ileri alıyor, yayından önce gerçek tarihe çekilecek) · yalnızca Android, min 7.0 · FB/IG akış, IG Keşfet, hikaye, reels · 18+ · Türkçe. `karusel` reklamının URL'si henüz Play linki → `kelimeki.com/?ref=meta-and-karusel` olacak | Kullanıcının ekran görüntülerinden okundu |
| 28 Eyl 2026 | **Tek set kararı** (kullanıcı: *"2 store ortak bir hale getirelim, tüm ios ve android cihazlara çıkartalım"*). A/B setleri birleşti; etiketler `meta-and-*`/`meta-ios-*` → `meta-karusel`/`meta-reel`/`meta-kare`; mağazadan bağımsız hikaye görseli üretildi (`kelimeki-story-1080x1920.png`, `npm run generate-meta-story`) | — |
| 28 Eyl 2026 | PR #673 merge edildi, `kelimeki.com` derleme kimliği `95767a4` (canlı HTML'de 4 rozette `data-kelimeki-magaza`, ana pakette etiketleme kodu) | `curl` |
| 28 Eyl 2026 | Reel yeniden üretildi: alt şeritte iki mağaza rozeti, kapanışta "App Store ve Google Play'de" (kullanıcı: *"reel'de app store ve Play ikonları yok"*). Ads Manager'daki `reel` reklamında video YENİSİYLE değiştirilmeli | — |
| 28 Eyl 2026 ~15:50 | **YAYINLANDI** (kullanıcı bildirdi). Tek set `Mobil · kelimeki.com` (₺200/gün, tüm mobil) · üç reklam: `karusel` (Döngü; tek medya/koleksiyon kapalı), `Reel` (rozetli yeni video, video rötuşları kapalı, müzik açık), `Kare` (akış `kelimeki-01`, hikaye `kelimeki-story-1080x1920`; yapay zekâ görselleri seçilmedi, müzik açık). Kurulum tuzakları: çoğaltılan reklam carousel biçiminde kalıyor (elle "Tek Görsel veya Video"ya çevrildi); medya kitaplığından eski "Artık Google Play'de" görseli yanlışlıkla seçilebiliyor; "Video rötuşları" videonun ortasına Meta'nın yazdığı bir kural metni bindiriyordu | Kullanıcının ekran görüntüleri |
| 28 Eyl 2026 ~16:00 | İlk `web_sessions` satırları (`meta-*`, 37 oturum, çoğu masaüstü ve iOS) yayından DAKİKALAR sonra geldi ve eski `meta-and-karusel` etiketini de içeriyor → reklam incelemesinin/önizlemelerin URL kontrolü, gerçek trafik DEĞİL. Analizde bu saatten önceki satırları dışarıda bırak | `web_sessions` |
| — | Başlangıç ölçümü (kampanya öncesi 7 gün): Play mağaza girişi edinmeleri = ? · ASC ilk indirmeler = ? | Play Console · ASC |
| — | App Store kampanya linkleri üretildi (`pt=` = ?) | — |
| — | Faz 1 başladı | — |

**Üretilen App Store linkleri:** *(henüz yok)*
