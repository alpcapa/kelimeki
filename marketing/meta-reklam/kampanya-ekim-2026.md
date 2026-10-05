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
  - App Store: `pt=129427325&ct=<etiket>` (`pt` 29 Eyl 2026'da eklendi; olmadan Apple kampanyaya atfetmiyor)
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
| `kare` v2 (29 Eyl, kullanılmadı henüz) | Tek görsel | `meta-reklam/kelimeki-sade-kare-1080.png` | `meta-reklam/kelimeki-sade-story-1080x1920.png` |

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
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/kelimeki-sade-kare-1080.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/kelimeki-sade-story-1080x1920.png
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
(`sourceChannel`, `src/utils/adminGroups.ts`) kendi **"Meta"** grubunda
görünür (30 Eyl 2026, #700; öncesinde "Diğer"deydi). Ayrı tablo değil, aynı
tablodaki etiket.

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
| 28 Eyl 2026 ~17:30 | **Reklamlar AKTİF** (kullanıcı bildirdi; ~15:50'den beri Ads Manager'da "Hazırlanıyor"du, yani inceleme ~1,5 saat sürdü). İlk gerçek oturum 17:32, `meta-reel` · Android. 16:01-17:32 arası hiç `meta-*` satırı yok → **Faz 1'in sıfır noktası 17:30**; analizde bu saatten önceki satırlar (43 inceleme oturumu) dışarıda. Test 5 değil ~4,3 gün (bitiş 3 Ekim) | `web_sessions` |
| 29 Eyl 2026 00:13 | **İlk kesit (~6,7 saat, 17:30'dan beri).** Meta: harcama ₺27,40 · erişim 324 · gösterim 386 · yönlendirme sayfası görüntüleme 28 · görüntüleme başı ₺0,98. Bizde (`web_sessions`, misafir, ≥17:30): 31 oturum, 6'sı mağazaya → **mağaza başı ≈ ₺4,6** (erken sinyal, eşik ₺40'ın çok altında). Etiket başına: `karusel` 18 oturum / 5 mağaza (11 Android · 6 iOS · 1 masaüstü) · `kare` 10 / 0 (9 Android · 1 iOS) · `reel` 3 / 1. Sitede oyun/üye 0 (beklenen: telefonda tek çağrı mağaza şeridi). Meta'nın 28'i ile bizim 31 örtüşüyor → etiket zinciri çalışıyor. Karar YOK (ilk 2 gün dokunulmaz, sayılar küçük) | Ads Manager ekran görüntüsü · §5 sorgusu |
| 29 Eyl 2026 09:56 | **Ara kesit (~16,5 saat, 17:30'dan beri).** Meta: harcama ₺72,73 · erişim 651 · gösterim 755 · yönlendirme sayfası görüntüleme 67 (₺1,09). Reklam başına harcama / Meta görüntüleme / bizde oturum / mağaza → **mağaza başı**: `karusel` ₺24,80 / 25 / 28 / 9 → **₺2,76** (Android 17→6 · iOS 10→3) · `kare` ₺45,15 / 38 / 38 / 1 → **₺45,15** (Android 35→0; 37 mobil oturumun 36'sı yalnızca `landing`) · `reel` ₺2,78 / 4 / 4 / 2 → ₺1,39 (örnek çok küçük). Toplam 70 oturum, 12 mağaza → **mağaza başı ≈ ₺6,1**. Etiket zinciri tutarlı (Meta 67 ↔ bizde 70). `kare` bütçenin %62'sini alıp mağazaya neredeyse hiç göndermiyor. Günlük hız ~₺105, yani ₺200 bütçenin altında (öğrenme dönemi). Karar YOK (ilk 2 gün dokunulmaz); 30 Eyl akşamı `kare` hâlâ ≥ ₺40/mağaza ise kapatılması önerilecek | Ads Manager ekran görüntüleri · §5 sorgusu |
| 29 Eyl 2026 10:09 | **`kare` teşhisi.** Meta kırılımı: erişim 340 / görüntüleme 38 (%11, statik görsel için yüksek); neredeyse tamamı **Instagram** (Facebook ≈ 0). Görüntülemelerin yaşı: 45-54 ≈12 · 35-44 ≈9 · 55-64 ≈7 · 18-24 ≈5 · 65+ ≈3 · 25-34 ≈2 (erişimin tepesi 35-44). İl kırılımında görüntüleme gizli (`--`), işe yaramaz. Bizde (`seconds`/`scroll_pct`, mobil): `kare` medyan **31 sn**, ort. kaydırma %23, 37'nin 5'i <5 sn · `karusel` medyan 36 sn, %35, 28'in 7'si <5 sn → **kazara dokunuş hipotezi ÇÜRÜDÜ**: `kare` ziyaretçisi sayfada kalıp okuyor, ama mağaza rozetine basmıyor. Açık hipotezler: kitle (45+ ağırlıklı) ya da görsel ↔ sayfa beklentisi. Karar yine 30 Eyl akşamı | Ads Manager ekran görüntüleri · `web_sessions` |
| 29 Eyl 2026 10:14 | **Yerleşim kırılımı (reklam × yerleşim, görüntüleme / erişim / TO).** `kare`: IG Reels **33** / 321 / %9,9 · IG akış 2 / 7 · FB Reels 2 / 9 · IG hikâye 1 → görüntülemelerin **%87'si IG Reels**. `karusel`: IG Reels 14 / 165 / %7,4 · IG akış **8** / 70 / %10,7 · FB mobil akış 2 / 66 / %3,0 · IG hikâye 2 → tek dağılımı dengeli reklam. `reel`: IG Reels 3 / 23 · FB Reels 1 / 7 (Meta bu reklama neredeyse hiç bütçe vermiyor). **Okuma:** `kare`'nin sorunu büyük ihtimalle Reels akışında duran bir statik görsel: tıklanıyor, okunuyor, kurulmuyor. `karusel` akıştan da trafik alıyor. Bizim tablo yerleşimi GÖRMÜYOR (etiket reklam düzeyinde) → hipotez henüz kanıtlanmadı. Kanıtın yolu: Faz 2'de URL'ye Meta'nın dinamik parametresi, `?ref=meta-kare-{{placement}}` (`captureUtmSource` 40 karaktere kadar, küçük harfle saklıyor; `meta-%` sorguları ve mağaza etiketi etkilenmez). Aktif reklamın URL'sini değiştirmek yeniden inceleme ister, ilk 2 günde YAPILMAZ | Ads Manager ekran görüntüleri |
| 29 Eyl 2026 10:25 | **`kare` DURAKLATILDI** (kullanıcı; silinmedi). Gerekçe: mobilde 37 oturumda 1 mağaza (%3) ↔ `karusel` 28'de 9 (%32), Fisher tek yönlü p ≈ 0,0015; Meta görüntülemeyi optimize ettiği için `kare`'ye bütçe akıtmaya devam edecekti (harcamanın %62'si). İlk 2 gün kuralına bilinçli istisna. Bütçe set düzeyinde (₺200/gün) → `karusel` + `reel`'e kayar. Analizde `kare` için bitiş 07:25 UTC. Kullanıcının teşhisi: görselde çok yazı/kutu, logo çok büyük → yeni görsel | Kullanıcı bildirdi |
| 29 Eyl 2026 17:51 | **24 saat kesiti (17:30'dan beri; `kare` 10:25'ten beri duraklatık).** Meta: toplam harcama ₺128,65 · yönlendirme sayfası görüntüleme 94. Reklam başına harcama / Meta görüntüleme / bizde oturum / mağaza → **mağaza başı**: `karusel` ₺76,30 / 46 / 57 / 18 → **₺4,24** (%32 mağaza oranı, duraklatmadan beri 28→57 oturum, 9→18 mağaza: bütçe kaymasını iyi karşıladı) · `kare` ₺49,47 / 44 / 44 / 1 → **₺49,47** (duraklatıldı) · `reel` ₺2,88 / 4 / 4 / 2 → ₺1,44 (örnek hâlâ çok küçük, Meta bütçe vermiyor). Toplam 105 oturum, 21 mağaza → **mağaza başı ≈ ₺6,13**. ⚠ Mağaza ziyareti ≠ kurulum; ₺40 eşiği KURULUM başına, kurulum sayısı Play Console / ASC'den okunacak (`ref` etiketiyle). Karar YOK; Faz 1 sonu 3 Ekim | Ads Manager ekran görüntüsü · §5 sorgusu |
| 29 Eyl 2026 18:00 | **Konsollara ilk bakış (veri 28 Eyl'e kadar, yani kampanyanın yalnızca ilk ~6,5 saati içeride).** Play (Grow users, 1–28 Eyl): cihaz gösterimi 243 (+%268, artış ayın son günlerinde) · edinme **6** (−%79) · ilk açılış 12 · aylık aktif cihaz 21. ASC (Acquisition, 28 Eyl'e biten aralık): ilk indirme **56** · yeniden indirme 4 · gösterim 1,59K · ürün sayfası görüntüleme 164 · dönüşüm %4,8. İki konsol da 1-2 gün geriden geliyor, kampanyanın etkisi henüz yok. Atıf etiketle okunacak: Play → Store performance → edinmeler, `utm_source` kırılımı · ASC → Acquisition → Campaigns (`ct=meta-…`). İlk anlamlı okuma 1 Ekim | Play Console · ASC ekran görüntüleri |
| 29 Eyl 2026 18:03 | **Play Store listings verisi ~9 gün geriden geliyor**, bu ekranda "Son 28 gün" 20 Eyl'de bitiyor. Değerler: ziyaretçi 53 · tekil kurma tıklaması 32 · tıklama oranı %60 (hepsi kampanyadan ÖNCE). Sonuç: kampanyanın Play mağaza sayfası verisi ancak ~7-9 Ekim'de görünür, yani 3 Ekim Faz 1 kararından sonra. **Faz 1 kararı bizim `store` adımına (§5) + ASC Campaigns'e (`ct=`, 1-2 gün gecikme) dayanır;** Play'in `utm_source` atfı Faz 1'i geriye dönük doğrulamak için okunur | Play Console ekran görüntüsü |
| 29 Eyl 2026 18:22 | **App Store linkine `pt=129427325` eklendi** (#692, `taggedStoreUrl`). ⚠ Bu saatten ÖNCE mağazaya giden iOS ziyaretçileri ASC Kampanyalar raporunda `ct=meta-*` olarak GÖRÜNMEZ (Apple `pt`siz atfetmiyor) — Faz 1'in iOS kurulum sayısı eksik kalacak | #692 |
| 29 Eyl 2026 ~19:40 | **İlk gün özeti** (28 Eyl 17:30 → 29 Eyl ~18:40). Meta: ₺143,02 harcama · 1.981 gösterim · 1.483 erişim · 106 yönlendirme sayfası görüntülemesi (₺1,35/görüntüleme). Reklam başına Meta ↔ bizim `web_sessions`: **karusel** ₺90,56 · 55 görüntüleme ↔ 69 oturum (37 Android · 30 iOS · 2 masaüstü), **21 mağazaya** (12 Android · 9 iOS), 2 oyun → **₺4,3/mağaza** · **kare** ₺49,47 · 44 ↔ 44 oturum (41 Android), **1 mağazaya** → ₺49/mağaza; Android'de medyan 31 sn kalıp HİÇBİRİ rozete basmadı, ekran görüntüsünde reklam **Kapalı** · **reel** ₺2,99 · 5 ↔ 4 oturum, 2 mağazaya (Meta neredeyse hiç göstermedi). Toplam 24 mağazaya → **₺6,0/mağaza** (erken sinyal, §6: kurulum başı bundan hep yüksek). Üye 0 — beklenen, telefonda karşılama mağazaya yönlendiriyor. karusel iOS'ta 30 oturumun 14'ü <3 sn (yanlış dokunuş kokusu). Meta'nın görüntüleme sayısı bizim oturum sayımızla aynı büyüklükte → ölçüm zinciri sağlam | Ads Manager ekran görüntüleri · `web_sessions` |
| 29 Eyl 2026 ~20:00 | **Kurulum vekili — Play Console OKUNAMADI.** Ajanın Play Console / ASC erişimi yok; uygulama Play Install Referrer'ı henüz okumuyor (Huni v2 mobil yarısı, 5 Ekim treni) → uygulamadaki her satır `utm_source='app'`, `meta-*` etiketi uygulama tarafında GÖRÜNMEZ. Vekil ölçü: `game_starts`ta **ilk kez görülen cihaz** (uygulamada ilk oyunu başlatan). 28 Eyl 17:30 → 29 Eyl ~19:10 (~26 sa): **Android 7** (önceki 7 gün: 6, ~0,9/gün) · **iOS 10** (önceki 7 gün: 4). Aynı pencerede mağazaya giden `meta-*` oturumu: Android 13 · iOS 11. Kaba okuma: Android'de ~6, iOS'ta ~9 fazladan cihaz → mağazaya gidenlerin kabaca yarısı (Android) ile çoğu (iOS) kurup oynamış olabilir; **atıf DEĞİL, eşzamanlılık** (organik de artmış olabilir). Karusel'e düşen kurulum başı kaba tahmin ₺143 ÷ ~15 ≈ **~₺10** (§6 eşiği ₺40'ın altında). Kesin sayı için kullanıcıdan: Play Console → Kullanıcı edinme → `utm_source=meta-*` (1-2 gün gecikmeli) | `game_starts` · `web_sessions` |
| 29 Eyl 2026 20:57 | **Son durum** (Ads Manager web, kampanya "Maksimum"): **₺162,19 · 109 yönlendirme sayfası görüntülemesi · ₺1,49/görüntüleme.** Cinsiyet: erkek %70 (76, ₺1,48) · kadın %30 (33, ₺1,51). Yaş: en çok 25-34 ve 35-44 (erkekte ~22 ve ~21); kadında 35-44 önde (~11). 45-54 ~11+7, 55-64 ~7+7, 18-24 ~9+2, 65+ ~6+2 | Kullanıcının ekran görüntüsü |
| 29 Eyl 2026 ~23:10 | **Web yolculuğu + mobil tamamlama** (28 Eyl 17:30 → 29 Eyl ~23:10, ~30 sa). Admin "Ziyaretçi Yolculuğu" (yalnızca WEB, yeni ziyaretçi, tüm cihazlar): 213 oturum · 37 etkileşimsiz · karşılamada %69 ayrıldı (medyan sayfanın %21'ini gördü) · **46 mağazaya gitti** · 33 uygulamaya geçti → 10 oyun başladı → 2 oyun bitti · 3 giriş. Web tablosu mobili GÖRMEZ; mobil tarafı DB'den: **5 yeni üye, 5'i de e-postasını onayladı**; 4'ü en az bir oyun BİTİRDİ (toplam 8 oyun: 7 iOS/Android, 1 web), beşincisinin 2 devam eden oyunu var. Aynı pencerede oyun başlatan **yeni misafir cihaz: Android 9 · iOS 8 · web 16**. `games.platform`/`game_finishes.platform` mobilden zaten doluyor (iOS/Android ayrışıyor) → "mobil eklenince" beklemeye gerek yok, bu sorgu yeter. Atıf DEĞİL (organik de dahil), ama üyelerin tamamının onaylı ve çoğunun oyun bitirmiş olması kaliteli trafik sinyali | `auth.users` · `games` · `game_finishes` · `game_starts` · kullanıcının ekran görüntüsü |
| 30 Eyl 2026 | **~2 günlük okuma** (admin "Ziyaretçi Yolculuğu", yeni ziyaretçi, web): 276 karşılama oturumu · **%63 karşılamada ayrıldı** (medyan 31 sn, sayfanın %20'si) · %26 mağazaya · 49 uygulamaya → 17 oyun · web üyeliği 0. **Kurulum atfı:** GA4 "First user source" (23-29 Eyl) yalnızca **1** `meta-karusel` Android kurulumu gösteriyor; Play Console trafik kaynağı raporu "Paid and direct: 2". iOS kurulumları GA4'te `(direct)`e düşüyor → iOS için tek kaynak ASC → Kampanyalar (`pt=` 29 Eyl 18:22'den sonra). Sonuç: **mağazaya gidiş ↔ kurulum arasında büyük kayıp ya da atıf kaybı; ikisi henüz ayrılamıyor.** Öneri (karar VERİLMEDİ): Faz 1 sonunda Meta "Uygulama yüklemeleri" hedefi değerlendirilsin | Admin · GA4 · Play Console ekran görüntüleri |
| 30 Eyl 2026 | **Karşılamada telefon için sabit alt şerit** (HEMEN OYNA + cihazın mağaza rozeti) + ilk ekranı hafif sıkılaştırma — gerekçe yukarıdaki %63/%20. iPhone 390×664'te rozet ilk ekranda HİÇ görünmüyordu. Kullanıcı önce/sonra görüntülerini onayladı. Etkisi bu kütükte, sonraki okumada "karşılamada ayrıldı" oranıyla ölçülecek. Karar: `docs/decisions/landing-page.md` → "Sabit alt şerit" | PR (bu satırla aynı) |
| 30 Eyl 2026 ~12:25 | **Apple Ads kuruldu (yalnızca iOS, $2/gün)** — `marketing/app-store/apple-ads.md`. ⚠ Bu tarihten sonra iOS'taki "ilk kez görülen cihaz" artışını tek başına Meta'ya yazma; ASC'de Apple Ads kurulumları ayrı görünür, farkı oradan düş | — |
| 30 Eyl 2026 14:38 | **Son durum** (Ads Manager, reklam düzeyi, "Maksimum"; ~45 sa): **₺341,36 · 213 yönlendirme sayfası görüntülemesi · ₺1,60/görüntüleme**. Reklam başına Meta ↔ bizim `web_sessions` (17:30'dan beri): **karusel** Açık · ₺288,90 · 164 görüntüleme (₺1,76) · 5.204 gösterim · 3.520 erişim ↔ 209 oturum (138 Android · 69 iOS · 2 masaüstü), **70 mağazaya** (52 Android · 18 iOS), 13 oyun → **₺4,1/mağaza** · **kare** Kapalı · ₺49,47 · 44 (₺1,12) · 379 gösterim ↔ 45 oturum, 1 mağazaya · **reel** Açık · ₺2,99 · 5 (₺0,60) · 50 gösterim ↔ 5 oturum, 2 mağazaya. Toplam 73 mağazaya → **₺4,7/mağaza** (29 Eyl ~19:40: ₺6,0). Dünkü okumadan (29 Eyl 20:57) bu yana karusel ~₺179 harcadı ↔ 130 oturum · 47 mağazaya → **~₺3,8/mağaza**, iyileşiyor. Android mağazaya oranı %38, iOS %26. **Reel iki günde 50 gösterim:** bütçe set düzeyinde paylaşılıyor ("Günlük, Paylaşılan"), Meta ₺200'ün tamamını karusel'e veriyor — reel fiilen test EDİLMEDİ, Faz 1 karar tablosunda "kaybetti" sayılmamalı. Web üyeliği hâlâ 0 (beklenen). Bitiş 3 Ekim ("2 gün kaldı"). Kurulum sayısı hâlâ bilinmiyor → karar için Play Console `utm_source=meta-*` + ASC `ct=meta-*` gerekli | Kullanıcının ekran görüntüleri · `web_sessions` |
| 30 Eyl 2026 14:46 | **Mağaza konsolları — kurulum sayısı henüz OKUNAMIYOR.** Play Console → Grow users (28 gün, 2-29 Eyl): device impressions **243** (+%268; artış 28-29 Eyl'de, ~100/gün) · device acquisitions **6** (-%79) · first opens **12** · aylık aktif 21 · 7 gün tutma 6. Veri 29 Eyl'de bitiyor ve o gün kısmi (1-2 gün gecikme) → kampanyanın Android kurulumları henüz görünmüyor. ASC → Kampanyalar (14-28 Eyl): "There isn't enough data" — beklenen, `pt=` 29 Eyl 18:22'de eklendi; aralık 29 Eyl sonrasına alınmalı, küçük sayılar Apple eşiği yüzünden hiç görünmeyebilir. **Kendi vekilimiz** (`game_starts`, ilk kez görülen mobil cihaz): kampanya boyunca (28 Eyl 17:30 → 30 Eyl 14:45) **Android 27 · iOS 16**; önceki 7 gün Android 6 · iOS 4 (~1,4/gün toplam) → ~1,9 günde beklenen ~3, fazlası **~40 cihaz** → harcama ÷ fazla ≈ **~₺8,5/cihaz** (§6 eşiği ₺40). Atıf DEĞİL, eşzamanlılık; iOS'ta 30 Eyl 12:25'ten sonrası Apple Ads'i de içerir | Kullanıcının ekran görüntüleri · `game_starts` |
| 1 Eki 2026 00:06 | **Gece okuması** (Ads Manager, reklam düzeyi; ~54,5 sa): toplam **₺463,05**. **karusel** Açık · ₺410,59 · 221 yönlendirme sayfası görüntülemesi (₺1,86) ↔ 292 oturum, **106 mağazaya** (80 Android · 26 iOS), 14 oyun → **₺3,9/mağaza** · **reel** Açık · ₺2,99 · 5 — 14:38'den beri HİÇ harcamadı (bütçenin tamamı karusel'de; test edilmedi, "kaybetti" sayılmaz) · **kare** Kapalı · ₺49,47 · 44 ↔ 46 oturum, 1 mağazaya. Toplam 109 mağazaya → **₺4,2/mağaza**. **14:38'den bu yana (~9,5 sa) karusel:** +₺121,69 ↔ 83 oturum · **36 mağazaya → ₺3,4/mağaza** (29 Eyl ₺4,3 → 30 Eyl öğlen ₺3,8 → gece ₺3,4: iyileşme sürüyor); Meta'nın kendi görüntüleme başı ise kötüleşti (₺1,76 → ₺1,86; son dilim ~₺2,1) — bizim ölçümüzle ters yönde, Meta'nın sayısı ölçü değil (§6). **Kurulum vekili** (`game_starts`, ilk kez görülen mobil cihaz, kampanya boyunca): **Android 39 · iOS 16** = 55; önceki 7 gün 10 (~1,4/gün) → ~2,3 günde beklenen ~3, fazlası **~52 cihaz → ~₺8,9/cihaz** (§6 eşiği ₺40). ⚠ **Son 9,5 saatte Android +12, iOS 0** — iOS'ta mağazaya gidiş sürüyor (18 → 26) ama yeni iOS cihaz gelmiyor; Apple Ads hâlâ On hold olduğundan karışma yok. iOS'ta mağaza → kurulum → ilk oyun zinciri zayıf görünüyor (ya da kuran oyun başlatmıyor); ASC verisi (2 Eki) bunu ayırır. Atıf DEĞİL, eşzamanlılık. Karar: dokunma, 3 Ekim'e kadar devam | Kullanıcının ekran görüntüsü · `web_sessions` · `game_starts` |
| 1 Eki 2026 00:16 | **Play Console → Grow users (28 gün) DEĞİŞMEDİ:** 243 gösterim · 6 edinme · 12 ilk açılış · aylık aktif **20** (14:46'da 21) · 7 gün tutma 6 — grafik hâlâ **29 Eyl'de bitiyor**, yani kampanyanın Android kurulumları hâlâ görünmüyor (1-2 gün gecikme). Ayrıca Grow users özeti etiket kırmıyor; `utm_source=meta-*` için **Kullanıcı edinme → trafik kaynağı / UTM kampanyaları** raporu gerekli. **Apple Ads 00:19'da Running** (bkz. `apple-ads.md`) → bundan sonra iOS vekili iki kaynağı karıştırır | Kullanıcının ekran görüntüleri |
| 1 Eki 2026 ~01:00 | **Kalite okuması — web + mobil birlikte** (~2,4 gün). **Web** (admin, 30 gün, çoğu Meta): Meta 333 karşılama · 114 mağazaya (%34) · 15 web oyunu · 0 web üyesi; karşılamada %59 ayrılış (medyan 31 sn); web oyununda 5. hamlede %50 kayıp; kayıt formunu açan 2 kişinin 2'si de bıraktı (küçük sayı). **Mobil yeni cihaz** (`game_starts` ilk görülen, kampanya boyunca): Android 40 · iOS 17 = 57 → 2+ oyun başlatan **18** (%32) · oyun bitiren **10** (%18) · 24 saatten eski 28 cihazdan ertesi gün oyuna dönen **3 (~%11)**. Karşılaştırma: önceki 14 günün 10 yeni cihazının 8'i geri dönmüştü (%80) — ama o kitle organik/tanıdık, birebir kıyas değil; ayrıca mobil `game_finishes.anon_id` 28 Eyl 18:31'den önce boş, önceki dönemin "bitiren" sayısı ölçülemiyor. **Yeni üye:** kampanya boyunca **14** (hepsi e-posta onaylı; önceki 14 günde 13 → ~0,9/gün iken şimdi ~6/gün); ilk oyunu Android 4 · iOS 3 · web 1 · henüz oyun yok 6. Kaba hesap: ₺463 ÷ ~12 fazla üye ≈ **~₺39/onaylı üye**, ₺463 ÷ ~52 fazla cihaz ≈ **~₺9/cihaz**. **Yorum:** huninin üstü ucuz ve sağlam; zayıf halka DERİNLİK (ertesi gün dönüş ~%11). Faz 2 kararında kurulum başının yanına bir **kalite kapısı** önerildi (ertesi gün dönüş), karar VERİLMEDİ. Atıf değil eşzamanlılık; 1 Eki 00:19'dan sonra iOS Apple Ads'i de içerir | `game_starts` · `game_finishes` · `auth.users` · `games` · admin ekran görüntüsü |
| 1 Eki 2026 10:16 | **İlk kesin iOS kurulum atfı + sabah okuması.** **ASC → Analytics → Acquisition → Campaigns** (veri **29 Eyl'de bitiyor**, 1-2 gün gecikme): `meta-karusel` **13 gösterim · 4 indirme** — tek satır, `meta-reel`/`meta-kare` yok (Apple eşiği ya da gerçekten sıfır). `pt=` 29 Eyl 18:22'de eklendiği için bu 4, kampanyanın yalnızca ilk ~1,5 gününü kapsıyor. ASC genel (Jul 2–Sep 29): ilk indirme **66** (28 Eyl'e kadar 56) · yeniden indirme 4 · gösterim 1,72K · ürün sayfası 192 · dönüşüm %5,15. **Play Console → Grow users** (28 gün, artık **30 Eyl'e kadar**): cihaz gösterimi **487** (dün 243) · edinme hâlâ **6** · ilk açılış 10 · aylık aktif 20 · 7 gün tutma 1 → gösterim kampanyayla ikiye katlandı ama Play'in "edinme"si kıpırdamadı; vekilimiz aynı dönemde 27 yeni Android cihaz saymıştı → ya gecikme ya da Play bu kurulumları mağaza-girişi edinmesi saymıyor. `utm_source` kırılımı (Store performance → Traffic sources) henüz OKUNMADI. **Meta** (Ads Manager mobil, 10:08; ~64,5 sa): toplam **₺530,96 · 304 yönlendirme sayfası görüntülemesi · ₺1,75**. karusel Açık ₺478,50 / 255 (₺1,88) · reel Açık ₺2,99 / 5 · kare Kapalı ₺49,47 / 44. Reel hâlâ bütçe almıyor. ⚠ **Yol notu:** ASC'de Analytics üst menüde DEĞİL, uygulamanın içinde Distribution ile TestFlight arasındaki sekme (doğrudan: `appstoreconnect.apple.com/analytics`) | Kullanıcının ekran görüntüleri (ASC · Play Console · Ads Manager) |
| 1 Eki 2026 10:33 | **Android kurulum atfı — GA4 "First user source"** (Sep 3–30, filtresiz; iOS kurulumları burada `(direct)`e düştüğü için `meta-*` satırları fiilen Android): **`meta-karusel` 8 kullanıcı** (7 yeni · 1 geri dönen) · ortalama etkileşim **7 dk** (`(direct)` 1 sa 32 dk, `google-play` 21 dk) · etkileşimli oturum/kullanıcı **0,25** (`(direct)` 6,78). `meta-reel`/`meta-kare` satırı YOK. Ayrıca `instagram` 5 (etiketsiz IG trafiği; Meta'dan olabilir, atfedilemez) · `google-play` 12 · `li-profil-play` 1. Firebase aktif kullanıcı: 30 gün 243 · 7 gün 103 · **1 gün 59** (kampanya öncesi ~10-15/gün). **Kesin atıflı kurulum toplamı: Android 8 (30 Eyl'e kadar) + iOS 4 (ASC, 29 Eyl'e kadar) = 12** → 30 Eyl sonu harcaması (~₺463, 1 Eki 00:06) ÷ 12 ≈ **₺39/kurulum — §6 eşiğinin (₺40) tam sınırında.** Bu bir ÜST sınır: iOS'un 30 Eyl'i ASC'de henüz yok, `pt=` öncesi iOS kurulumları atıfsız, `instagram` 5 sayılmadı; vekilimiz (~40 fazla cihaz) gerçek maliyeti ~₺10 civarına koyuyor. ⚠ **Kalite sinyali:** Meta'dan gelen Android kullanıcısının etkileşimi organikten belirgin düşük (7 dk ↔ 21 dk-1,5 sa). ⚠ **Yol notu:** Play Console'da `utm_source` kırılımı BULUNAMADI (Statistics'in boyut menüsünde UTM yok; Store performance → Traffic sources'ta "Third-party referrals" bölümü yok, muhtemelen düşük hacim). Android atfının çalışan yolu **GA4**: Firebase → "View more in Google Analytics" → arama kutusuna `User acquisition` (menüde Business objectives → Generate leads altında) → boyut **First user source** | Kullanıcının ekran görüntüleri (GA4 · Firebase) |
| 2 Eki 2026 ~10:10 | **Sabah vekil okuması (Faz 1 kararından bir gün önce; konsol rakamları kullanıcıdan bekleniyor).** `web_sessions` `meta-*` → mağazaya giden oturum, gün gün (TSİ): 28 Eyl (17:30'dan) 5 · 29 Eyl 39 · 30 Eyl 64 · 1 Eki 30 · 2 Eki (10:00'a kadar) 4 = **142** (karusel 137 · reel 3 · kare 2). 1 Eki'de düşüş: oturum 162→114, mağaza 64→30 — Meta harcaması aynıysa mağaza başı maliyet ~iki katına çıktı (Ads Manager rakamı bekleniyor). **Yeni mobil cihaz** (`game_starts` ilk görülen, TSİ gün): Android 29 Eyl 11 · 30 Eyl 26 · 1 Eki 15 · iOS 7 · 4 · 6 (önceki hafta toplam ~1,4/gün). ⚠ iOS 1 Eki'den itibaren Apple Ads'i de içerir; Android 2 Eki 00:56'dan sonra 1.1.2 güncellemesi yeni cihaz SAYILMAZ (aynı `anon_id`). Atıf değil, eşzamanlılık — kesin sayı ASC `ct=meta-*` + GA4 "First user source" | `web_sessions` · `game_starts` |
| 2 Eki 2026 10:16 | **Faz 1 kurulum başı — KESİN atıfla ilk tam okuma.** **Harcama** (Ads Manager, 2 Eki 10:13): toplam **₺724,53** · 418 yönlendirme sayfası görüntülemesi (₺1,73) — karusel ₺669,29 · 365 (₺1,83) · reel ₺5,77 · 9 (₺0,64) · kare ₺49,47 · 44 (Kapalı). **Kurulum:** iOS **ASC Campaigns** (Jul 3–Sep 30) `meta-karusel` 29 gösterim · **10 indirme** (1 Eki okumasında 4) · Android **GA4 First user source** (Sep 4–Oct 1) `meta-karusel` **25 kullanıcı** (25 yeni · 5 geri dönen) · `instagram` 9 (etiketsiz, atfedilemez). `meta-reel`/`meta-kare` satırı yine YOK. **Kesin atıflı = 35** → ₺724,53 ÷ 35 ≈ **₺20,7/kurulum** (karusel tek başına ₺669,29 ÷ 35 ≈ ₺19,1). Bu bir ÜST SINIR: harcama 2 Eki sabahına kadar, kurulumlar iOS 30 Eyl / Android 1 Eki'de bitiyor; `instagram` 9 sayılırsa ₺16,5. **§6 eşiği (₺40) rahatça altında → kural: Devam, Faz 2.** Cihaz kırılımı (§6 son satırı) için Ads Manager'da platform başına harcama gerekli — bizde mağazaya gidenlerin ~%70'i Android. ⚠ **Kalite:** GA4'te `meta-karusel` etkileşimli oturum/kullanıcı **0,20** (`(direct)` 7,42, `google-play` 0,67), ortalama etkileşim 18 dk 34 sn; 1 Eki okumasında yeni cihazların ertesi gün dönüşü ~%11 — "kurulum ucuz ama oynamıyorsa kazanan sayılmaz" (§6) kuralı için izlenmeli. ASC genel (30 Eyl'e kadar): ilk indirme 76 · ürün sayfası 223 · gösterim 1,92K · dönüşüm %5,32. **Karar kullanıcıda (3 Eki).** İlk gerçek rakam: eşik ₺40 yerine ~₺20 ölçüldü | Kullanıcının ekran görüntüleri (Ads Manager · ASC · GA4) |
| 2 Eki 2026 ~10:30 | **KARAR (kullanıcı, Ads Manager'da uyguladı): Faz 2 bir gün erken — yalnızca karusel açık.** `reel` **Kapalı** (₺5,77 · 9 görüntüleme, Meta bütçe vermedi; kurulum satırı yok), `kare` zaten Kapalı. Set bütçesi **₺300/gün** (§6'daki ₺400 yerine), **bitiş 7 Ekim**. Gerekçe: kesin atıfla kurulum başı ~₺21 (§6 eşiği ₺40). İzlenecek: ertesi gün dönüş + GA4 etkileşimli oturum/kullanıcı (`meta-karusel` 0,20) — "kurulum ucuz ama oynamıyorsa kazanan sayılmaz". Kapanış okuması 8-9 Ekim (mağaza verisi 1-2 gün gecikmeli) | Kullanıcının bildirimi |
| 3 Eki 2026 ~10:05 | **Faz 1 karar günü — karar ZATEN 2 Eki'de verildi** (Faz 2: yalnız karusel, ₺300/gün, bitiş 7 Eki). Faz 2'nin ilk ~24 saati (2 Eki 10:30 TSİ'den): `web_sessions` `meta-karusel` **171 oturum · 29 mağazaya (%17;** Faz 1'de %34, 1 Eki %25 — mağaza oranı düşüyor) → ₺300/gün ile mağaza başı ~₺10. **YENİ VE KESİN: Play Install Referrer çalışıyor** (1.1.2 Android, 2 Eki 00:56'dan beri yayında): `funnel_events` `land` (Android, 2-3 Eki) **`meta-karusel` 13 cihaz** · `app` 9 · `mevcut` 9 · `instagram` 1 → Android kurulum atfı artık GECİKMESİZ ve uygulamanın kendi verisinde. **Kalite (aynı 13 cihaz):** **9'u oyun başlattı (%69)**, 2'si oyun bitirdi; ertesi gün dönüş henüz ölçülemez (< 1 gün). Kaba Android kurulum başı: ~₺300 × (Android payı ~%70) ÷ 13 ≈ **~₺16** (harcama kırılımı tahmini). Yeni mobil cihaz vekili (`game_starts`): Android 11 · iOS 7 (iOS Apple Ads'i de içerir). ⚠ iOS 1.1.2 `funnel_events` satırları 1 Eki'den beri var (5 · 8 · 4 cihaz) — TestFlight kullanıcıları; App Store onayının kanıtı DEĞİL | `web_sessions` · `funnel_events` · `game_starts` |
| 3 Eki 2026 ~10:50 | **Konsol okuması — Faz 2'nin ilk günü dahil.** **Meta** (Ads Manager mobil, 10:33): toplam **₺1.030 · 600 yönlendirme sayfası görüntülemesi · ₺1,72** — karusel Açık **₺976,49 · 547 (₺1,79)** · kare Kapalı ₺49,47 · 44 · reel Kapalı ₺5,80 · 9. 2 Eki 10:13'ten beri karusel **+₺307,20 · +182 görüntüleme (₺1,69)** → ₺300/gün bütçe tam harcanıyor. **Android atfı — GA4 First user source** (Sep 5–Oct 2): **`meta-karusel` 35 kullanıcı** (35 yeni · 8 geri dönen; 2 Eki okumasında 25 → bir günde **+10**) · `google-play` 20 · `instagram` 9 · `(direct)` 203 · `li-profil-play` 1 · `(not set)` 8. **Kalite iyileşti:** `meta-karusel` etkileşimli oturum/kullanıcı **0,34** (dün 0,20; `google-play` 0,65 · `instagram` 0,11 · `(direct)` 7,20), ortalama etkileşim 18 dk 37 sn. **Kesin atıflı kurulum:** Android 35 (2 Eki'ye kadar) + iOS **12** (ASC Campaigns, Jul 4–Oct 1: `meta-karusel` 31 gösterim · 12 indirme; dün 10) = **47** → ₺1.030 ÷ 47 ≈ **₺21,9 ÜST SINIR** (harcama 3 Eki sabahına kadar, kurulumlar daha erken kesiliyor). Son günün marjinali: +10 Android ↔ ~₺300 × ~%70 Android payı ≈ **~₺21/kurulum** — eşik ₺40'ın altında, Faz 2 kararıyla tutarlı. **Play Console → Grow users** (28 gün, 2 Eki'ye kadar): gösterim **643** (+%793) · edinme **41** (1 Eki okumasında 6 → Play gecikmeyi kapattı) · ilk açılış 8 · aylık aktif 19 · 7 gün tutma 1. **Firebase aktif kullanıcı:** 30 gün 278 · 7 gün 147 · 1 gün 48. iOS Apple Ads aynı pencerede 5 kurulum (`apple-ads.md`) → iOS vekili `game_starts` ondan arındırılmalı | Kullanıcının ekran görüntüleri (Ads Manager · GA4 · ASC · Play Console · Firebase) |
| 3 Eki 2026 ~11:00 | **Ara bilanço (kullanıcı istedi; 28 Eyl 17:30 → 3 Eki ~11:00, ~4,7 gün).** **Harcama:** Meta ₺1.030 (karusel ₺976 · kare ₺49 · reel ₺6) + Apple Ads $4,84 (promosyon kredisinden). **Web** (`web_sessions` `meta-*`): 568 oturum → **172 mağazaya (%30) → ~₺6/mağaza** · 22 web oyunu. **Kesin atıflı kurulum 47** (Android GA4 35 + iOS ASC 12) → **≤ ₺21,9/kurulum** (eşik ₺40). **Vekil** (`game_starts` ilk görülen mobil cihaz): **Android 67 · iOS 30 = 97**; önceki 7 gün 10 (~1,4/gün) → beklenen ~7, fazlası ~90 → **~₺11/cihaz** (iOS'ta Apple Ads'in 5'i de içeride). **Yeni üye 21, hepsi onaylı** (önceki 14 gün 13 → beklenen ~4, fazlası ~17 → **~₺60/üye**). **Kalite (97 yeni cihaz):** 2+ oyun 30 (%31) · oyun bitiren 17 (%18) · ≥24 sa önce gelen 79 cihazdan ertesi gün dönen **8 (~%10)**. Install Referrer kohortu (`meta-karusel` Android, 2-3 Eki): 13 cihaz → 10 oyun başlattı · 3 bitirdi · ikinci güne dönen henüz 0 (erken). GA4 `meta-karusel` etkileşimli oturum/kullanıcı 0,34 (organik `google-play` 0,65). **Hüküm: edinme BAŞARILI** (kurulum başı eşiğin yarısı); **tutunma ZAYIF** (~%10 ertesi gün) — §6'nın "kurulum ucuz ama oynamıyorsa kazanan sayılmaz" kuralının izlediği risk bu. Faz 2 planı değişmedi (bitiş 7 Eki, kapanış okuması 8-9 Eki) | `web_sessions` · `game_starts` · `game_finishes` · `auth.users` · `funnel_events` · önceki satırlar |
| 4 Eki 2026 ~13:49 | **GA4 "User acquisition: First user source" (kelimeki mülkü, son 28 gün, 6 Eyl–3 Eki).** Toplam kullanıcı **282** · yeni **265** · geri dönen 76 · olay 13.086. Kaynak başına (toplam / yeni kullanıcı): `(direct)` **198** / 180 (%70) · `meta-karusel` **50** / 50 · `google-play` **25** / 24 · `instagram` **10** / 10 · `li-profil-play` **1** / 1. Tüm satırlarda anahtar olay oranı %90-100 (anahtar olay = yeni kullanıcı sayısına eşit, 265). `meta-karusel` etkileşimi düşük (aktif kullanıcı başına 0,38 etkileşimli oturum, 638 olay) ↔ `(direct)` 7,78. ⚠ 3 Eki ara bilançosundaki "Android GA4 35" ile `meta-karusel` 50 AYNI sayı DEĞİL (pencere 28 gün vs kampanya penceresi, platform kapsamı doğrulanmadı) — karşılaştırma yapma, Faz 1 kararı yine `store` adımı + ASC'ye dayanır. `meta-kare`/`meta-reel` satırı yok (düşük hacim ya da etiket GA4'e düşmüyor, doğrulanmadı) | Kullanıcının ekran görüntüleri |
| 4 Eki 2026 ~13:53 | **ASC → Analytics → Acquisition → Campaigns** (aralık **4 Tem–1 Eki**, İndirme Tarihi: Tümü; ASC uyarısı: *2 Ekim verisi gecikmeli*). Tek satır: **`meta-karusel` · 31 gösterim · 12 toplam indirme** · gelir ve oturum `-` (oturum yalnızca opt-in). **3 Eki ara bilançosundaki "iOS ASC 12" ile AYNI sayı** — 3 Eki'den beri ARTMADI (2 Eki verisi gecikmeli, 3 Eki henüz yok → artış görünmesi beklenmez). Satır yalnızca `meta-karusel`: `meta-kare`/`meta-reel` ASC'de hiç görünmüyor (App Store linkine `pt=` 29 Eyl 18:22'de girdi; öncesi atıfsız). 12 indirme / 31 gösterim: gösterim yalnızca `ct=` bağlantısıyla gelen ürün sayfası görüntülemesi, indirme tarihi ise kampanyaya atfedilen tüm indirmeler — oran dönüşüm DEĞİL. Apple Ads kurulumları (5) bu tabloda ayrı satır olarak görünmüyor → `meta-karusel`in 12'sine karışmadı | Kullanıcının ekran görüntüsü |
| 4 Eki 2026 ~14:00 | **Çapraz bilanço (28 Eyl 17:30 → 4 Eki ~13:50; Meta mobil ekranı ↔ `web_sessions` `meta-*` ↔ GA4 ↔ ASC).** Meta: **₺1.360 · 805 yönlendirme sayfası görüntüleme (₺1,69)**; `karusel` ₺1.300 / 752 (₺1,73) · `kare` ₺49,47 / 44 (kapalı) · `reel` ₺5,80 / 9 (kapalı); kampanya "2 gün kaldı" (bitiş ~6 Eki). Bizde **788 oturum** (karusel 754 · kare 26 · reel 8) → Meta görüntülemesiyle %98 örtüşüyor; **222 mağazaya (%28)**: karusel 217 (Android 175/576 = %30 · iOS 42/176 = %24), kare 2, reel 3 → **mağaza başı ≈ ₺6,1** (karusel ₺6,0). Oyun başlatan 18 oturum (%2). Günlük mağaza oranı (İstanbul günü): 29 Eyl %34 · 30 Eyl %42 · 1 Eki %38 · 2 Eki %22 · 3 Eki %20 · 4 Eki %18 (kısmi) → **oran yarıya indi** (hacim 80→172/gün). Atıflı kurulum: Android GA4 `meta-karusel` 50 (3 Eki'de 35'ti) + iOS ASC 12 = **62 → ₺21,9/kurulum** (eşik ₺40; Apple Ads ayrı: 5 kurulum, $7,47). Mağaza→kurulum kabaca %28 (62/222; iOS 12/44 ≈ %27, ASC verisi 2-3 Eki gecikmeli → alt sınır). ⚠ `kare` oturumu 44 değil 26 görünüyor (29 Eyl'de 44'tü) — satır/pencere farkı, nedeni araştırılmadı | `web_sessions` · Meta · GA4 · ASC |
| 4 Eki 2026 | **Karar (kullanıcı):** kampanya ~6 Eki'de bitince ne yapılacağı (yeni kampanya dahil) o gün, son bilançoyla birlikte karara bağlanacak; şimdilik mevcut kampanya olduğu gibi sürüyor, değişiklik YOK. Girdi: mağaza oranının %42→%18 düşüşü (yukarıdaki satır) | Kullanıcı |
| 4 Eki 2026 17:06 | **X (@Kelimeki) karusel gönderisi YAYINDA** (kullanıcı; 2. gönderi, ilki 31 Ağu). 4 görsel (01 → 03 → 02 → 05, rozetli); link `kelimeki.com/?ref=x-karusel` (bio'daki `?ref=x-bio`dan ayrı). Metin önerilenden farklı: "puanını paylaşırsın", "satın almasız", 5 hashtag (`#kelimeoyunu #kelimeki #türkçe #bulmaca #oyun`), metinde yanlışlıkla `@Kelimeki` anması. Hesap: **1 takipçi · 22 takip** → organik erişim ~0 beklenir; kullanıcı kişisel profilinden de repost edecek. Ölçüm: `web_sessions.utm_source='x-karusel'`; sonuç 5-10 oturumdan azsa X edinme kanalı sayılmaz (profili canlı göstermek amaçlı) | Kullanıcı bildirdi |
| 5 Eki 2026 | **Karar (kullanıcı): bir sonraki hedefin ölçüsü = ayda 2+ oyun oynayan aktif kullanıcı (MAU tanımı).** Hedef 100 yeni MAU/ay → kaba bütçe **₺3.500-7.000/ay** (girdiler: kurulum başı ₺11-21 · yeni cihazın %31'i 2+ oyun başlattı → ~320 kurulum gerekir; ertesi gün dönüş ~%10 ve 2+ oyun oranı küçük örnek, bütçe büyüdükçe kurulum başı maliyet artabilir). Ölçü: `game_starts` ilk görülen cihazlardan 2+ oyun başlatan sayısı / Firebase aktif kullanıcı. Faz 3 planı kampanya bitişinde (7 Eki, kapanış okuması 8-9 Eki) bu tanıma göre yazılacak. Aynı gün: yeni Reels videoları (`marketing/shorts-2026-10/`) organik yayında; reklam kreatifi olarak ayrı, küçük bütçeli bir testte denenecek (kapanış kartı mağaza butonlu sürüm gerekir — şimdiki 'Link bio'da' reklamda yanlış) | Kullanıcı |
| — | Başlangıç ölçümü (kampanya öncesi 7 gün): Play mağaza girişi edinmeleri = ? · ASC ilk indirmeler = ? | Play Console · ASC |
| — | Faz 1 başladı | — |

**Üretilen App Store linkleri:** *(henüz yok)*
