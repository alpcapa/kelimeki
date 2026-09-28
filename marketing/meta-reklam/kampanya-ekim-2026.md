# Meta reklam kampanyası — Ekim 2026 (iOS + Android, Instagram + Facebook)

**Karar tarihi:** 28 Eylül 2026. Kullanıcı: *"genel bir kampanya planlayalım,
sadece Play için yapmayalım"*.
**Amaç:** iki mağazadan da kurulum almak ve her liranın neyi getirdiğini
ayrı ayrı okuyabilmek.
**Kardeş dosyalar:** organik gönderiler `marketing/play-store/sosyal-lansman.md`
ve `marketing/app-store/*-lansman.md`. İlk ücretli deneme (Ağustos kareleri,
16 Eylül boost'u) `marketing/sponsored-2026-08/metin.md`.

⚠ Metinler iPad'den kopyalanacağı için **kod bloğunda**.

---

## 0 · Özet

| | |
|---|---|
| Kampanya | **1 kampanya**, hedef **Trafik** |
| Reklam setleri | **2 set:** Android · iOS. İkisi de `kelimeki.com/?ref=meta-…` adresine gider, mağazaya sitedeki rozetten geçilir (§3.0) |
| Reklamlar | Her sette **3 reklam:** carousel · reel · tek kare |
| Bütçe | Toplam **₺3.000**. Test: 5 gün × ₺200/gün. Ölçek: kazanan sete 5 gün × ₺400/gün |
| Kurulum yeri | **Tarayıcıdan Ads Manager.** iOS uygulamasından verilen reklama Apple'ın %30 ücreti ekleniyor (§7) |
| Başlangıç | **Web PR'ı (#673) canlıya çıkınca** (§1). Huni v2'nin mobil yarısını beklemek artık gerekmiyor |
| Başarı ölçüsü | Erken sinyal: **mağazaya giden oturum başı maliyet** (bizim tablo, anında). Asıl ölçü: **kurulum başı maliyet** (mağaza raporları, 1-2 gün gecikmeli). Meta'nın tıklama sayısı ölçü DEĞİL (§2, §6) |

---

## 1 · Başlangıç — web PR'ı canlıda olunca

**28 Eylül 2026'da değişti.** İlk plan reklamı doğrudan mağazaya
gönderiyordu. O durumda Android'de kurulumdan sonrasını (oyun, üyelik)
görmek için Huni v2'nin mobil yarısı (PR 2, 5 Ekim treni) gerekiyordu, ve
bu yüzden `docs/decisions/funnel-v2.md` → "Pazarlama kapısı" beklenecekti.

Reklam artık siteye gidiyor (§3.0). Reklamdan gelen kişinin bütün yolu
(karşılama → mağaza rozeti ya da tarayıcıda oyun → üyelik) **bizim web
tablomuzda** reklam etiketiyle görünüyor. Kapının sorusu cevaplanmış oluyor.

**Başlangıç koşulu:** PR #673 `main`'e merge edildi **ve** `kelimeki.com`'un
derleme kimliği o commit'i gösteriyor (`curl -s https://kelimeki.com/ | grep
kelimeki-build`). Bu olmadan sitedeki rozet linkleri etiketi taşımaz ve
mağazaya giden kurulum "organik" görünür.

Huni v2'nin mobil yarısı gelince (5 Ekim treni) Android'de bir halka daha
görünür: mağazadan kurulan uygulamanın ilk açılışı ve oyunu. Bu bir bonus,
başlangıç için ön koşul değil.

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
2. **Tıklamadan kuruluma giden yolda iki adım fazlaydı:** reklam → karşılama
   sayfası → mağaza rozeti → mağaza → kur. Bu kampanya mağazaya
   **doğrudan** gidiyor (§3).

---

## 3 · Kampanya yapısı

### 3.0 · ⚠ Meta, Trafik kampanyasında mağaza linkine İZİN VERMİYOR

28 Eylül 2026, kurulum sırasında Ads Manager'ın kendi hatası:

> *"Uygulama URL'si sadece Uygulama Yüklemeleri reklam verme amacında
> destekleniyor… (#1487810)"*

Bu belgenin ilk sürümü reklamı `play.google.com` / `apps.apple.com`
adresine gönderiyordu. O kurgu çalışmaz. İki yol vardı:

| Yol | Ne | Karar |
|---|---|---|
| **1** | Trafik kalır, reklam `kelimeki.com/?ref=meta-…`e gider. Mağazaya sitedeki rozetten ya da telefondaki mağaza şeridinden geçilir | ✅ **Seçildi** (kullanıcı, 28 Eyl) |
| 2 | Yeni bir "Uygulama tanıtımı" kampanyası. Uygulamanın Meta for Developers'a kaydı gerekir, iOS'ta SKAdNetwork kısıtları var, SDK'sız davranışı doğrulanmadı | Elendi |

Yol 1'in bedeli bir adım fazlalık (reklam → site → mağaza). Kazancı:
yolun tamamı bizim tabloda ölçülüyor, ve telefondan gelen kişi kurulum
yapmadan tarayıcıda hemen oynayabiliyor.

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
  Bu kampanya için değer değil.
- Bu yüzden Meta kurulumu ya da üyeliği göremiyor ve onlara göre optimize
  edemiyor. **"Uygulama tanıtımı" hedefi** SDK olmadan kurulumu
  ölçemeyeceği için kör optimize eder, seçme. Ads Manager'da "Uygulama"
  dönüşüm konumu zaten gri geliyor, çünkü uygulama Meta'ya kayıtlı değil.
- **Performans hedefi: "Yönlendirme sayfası görüntülemelerinin sayısını en
  üst seviyeye çıkar"** (Türkçe arayüzün adı; eski adı "Açılış sayfası
  görüntülemeleri").
  - ⚠ **28 Eylül 2026 — bu belgenin ilk sürümü "pixel ister" diyordu,
    YANLIŞTI.** Kurulum sırasında Ads Manager'ın kendisi okundu: *"Yönlendirme
    sayfası görüntülemeleri artık Meta Pikseli entegrasyonu gerektirmiyor"*.
    Aynı ekran, bağlantı tıklamalarına göre sonuç başına ~%23 daha düşük
    ücret tahmin ediyordu.
  - "Bağlantı tıklamaları"na göre farkı: sayfa gerçekten yüklenmeden çıkan
    dokunuşları saymıyor. 16 Eylül'ün sorunu tam buydu.
  - **Açık risk:** hedef URL'ler mağaza adresi. Play ya da App Store
    uygulaması sayfayı Meta'nın tarayıcısından önce açarsa Meta görüntülemeyi
    göremeyebilir. **İlk 48 saatte bağlantı tıklaması var ama yönlendirme
    sayfası görüntülemesi ~0 ise** performans hedefini "Bağlantı tıklamaları"na
    çevir. Bu değişiklik öğrenmeyi baştan başlatır, bir kez yapılır.
- Kalite kontrolünü yine biz yapıyoruz: hedef URL'ler doğrudan mağazaya
  gidiyor, sonucu mağazanın kendi raporundan okuyoruz (§5).

### 3.2 · Kampanya düzeyi

| Alan | Değer |
|---|---|
| Kampanya adı | `Kelimeki · Ekim 2026 · Trafik` |
| Hedef | **Trafik** |
| Özel reklam kategorisi | Yok |
| Advantage+ kampanya bütçesi (CBO) | **KAPALI.** Bütçe set düzeyinde. Açık olursa Meta parayı ucuz tıklayan sete akıtır, iki mağazayı karşılaştıramazsın |
| A/B testi | Kapalı. Setler zaten ayrı |

### 3.3 · Reklam seti düzeyi — iki set, TEK fark cihaz ve link

| Alan | Set A · Android | Set B · iOS |
|---|---|---|
| Set adı | `A · Android → Play` | `B · iOS → App Store` |
| Dönüşüm konumu | Web sitesi | Web sitesi |
| Performans hedefi | Yönlendirme sayfası görüntülemelerinin sayısını en üst seviyeye çıkar (§3.1'deki geri dönüş kuralıyla). Teklif stratejisi **En yüksek hacim**, ücret hedefi boş | aynı |
| Günlük bütçe (test) | **₺100** | **₺100** |
| Takvim | Başlangıç + bitiş tarihi gir (5 gün). Bitişsiz bırakma | aynı |
| Konum | Türkiye · "Bu konumda yaşayan kişiler" | aynı |
| Yaş | 18-65+ | aynı |
| Dil | Türkçe | aynı |
| Detaylı hedefleme | Advantage+ hedef kitle **açık**. Öneri olarak ilgi alanları: *Kelime oyunları, Bulmaca, Scrabble, Wordle, Sözcük oyunları, Türk Dil Kurumu, Bulmaca oyunları* | aynı |
| Reklam alanları | **Manuel:** Facebook Akış · Instagram Akış · Instagram Keşfet · Facebook ve Instagram Hikayeler · Facebook ve Instagram Reels. **KAPAT:** Audience Network, Messenger, sağ sütun, arama sonuçları | aynı |
| Cihaz | Manuel alanlar → **Belirli mobil cihazlar ve işletim sistemleri** → **Yalnızca Android** | aynı yer → **Yalnızca iOS** |
| Wi-Fi koşulu | Kapalı | Kapalı |

⚠ **Cihaz filtresi iki mağazayı karşılaştırmanın tek yolu.** Reklam artık
siteye gittiği için yanlış cihaza giden tıklama boşa gitmiyor (site iki
rozeti de gösteriyor), ama o zaman "Android mi iOS mu daha ucuz" sorusunun
cevabı bulanıklaşır. Yayından önce iki setin özetinde "Android" ve "iOS"
yazdığını gözle kontrol et.

**Android setinin ek ayarı:** İşletim sistemi sürümü **Min. 7.0** — uygulama
`minSdk = flutter.minSdkVersion` (24 = Android 7.0) istiyor.

---

## 4 · Reklamlar — her sette üç tane

Aynı üç reklam iki sette de var. Değişen yalnızca metindeki mağaza adı ve
hedef URL. Reklam adları etiketle aynı olsun ki Ads Manager ile mağaza
raporu yan yana okunabilsin.

| Reklam | Biçim | Görsel | Hangi alanlarda |
|---|---|---|---|
| `karusel` | Carousel, 4 kart | `sponsored-2026-08/kelimeki-01 → 03 → 02 → 05.png` (2160², iki rozetli) | Akış · Keşfet |
| `reel` | Tek video | `sponsored-2026-08/kelimeki-reel.mp4` (9:16, 9,4 sn) | Reels · Hikayeler |
| `kare` | Tek görsel | `sponsored-2026-08/kelimeki-01.png` | Akış · Keşfet. **Yalnızca Set A'da** Hikayeler alanı için görsel değiştir → `play-store/lansman/kelimeki-google-play-story-1080x1920.png` |

**Neden bu görseller:**
- `kelimeki-01…05` iki rozetli ve mağazadan bağımsız ("App Store ve Google
  Play'de"). İki sette de aynen kullanılabilir.
- Play lansman karesi ve story "Artık Google Play'de" diyor. **iOS setinde
  KULLANMA.**
- iOS setinde 9:16 hikaye görseli yok. O alanları `reel` karşılıyor, `kare`
  reklamında Meta hikayeye otomatik uyarlama yapar.

**Kart sırası (carousel):** 01 durdurur (bu ne) → 03 farkı anlatır (köşe →
bölge → merkez → vergi) → 02 kanıtlar (gerçek tahta) → 05 çağırır (rütbeler +
rozetler). 04 bilerek dışarıda: 4 kart, 5 karttan daha fazla tam izleniyor.
Organik turda da sıra buydu.

**Reel'in müziği:** video sessiz. Ads Manager'ın medya düzenleyicisinde
"Müzik ekle" → telifsiz kütüphaneden sakin/enstrümantal bir parça seç. IG
uygulamasının trend sesleri reklamda KULLANILAMAZ, lisans organiğe özel.

**Reel'in alt şeridi `kelimeki.com` diyor, rozet taşımıyor.** Bu bir sorun
değil: reklam düğmesi mağazaya gidiyor. Şeridi değiştirmek için üretici
(`npm run generate-reel`) yeniden koşmalı, bu kampanya için gerekmez.

### 4.1 · Metinler — Set A (Android)

**Birincil metin — varyant 1 (kanca: soru)**
```
Bu bir kelime oyunu ama asıl soru şu: kelimeyi NEREYE koyacaksın? 🧩

Tahtada senin bir bölgen var. Kelime kurdukça büyüyor. Rakibinin bölgesine oynayabilirsin — ama vergisini ödersin 😏

🤖 Yapay zekaya karşı: Kolay, Normal, Zor
👥 Arkadaşlarınla sırayla: her hamle için 48 saat
✈️ İnternetsiz de oynanır
🆓 Ücretsiz · reklamsız · satın alma yok
```

**Birincil metin — varyant 2 (kısa)**
```
Kelime bul, bölgeni büyüt, tahtayı ele geçir 🧩
Türkçe için sıfırdan tasarlanmış strateji kelime oyunu. 63.000+ kelime, yapay zeka rakip, arkadaşlarla canlı oyun. Ücretsiz ve reklamsız.
```

**Başlık**
```
Kelimeki — Google Play'de ücretsiz
```

**Açıklama**
```
Türkçe strateji kelime oyunu
```

**Harekete geçirici düğme (Ads Manager: "Eylem çağrısı"):** `İndir`. Listede yoksa `Şimdi Yükle`, o da yoksa `Daha Fazla Bilgi`. Varsayılan `Detayları Gör` gelir, değiştir. **"Çok reklamverenli reklamlar" kutusu varsayılan olarak İŞARETLİ gelir, kaldır.**

### 4.2 · Metinler — Set B (iOS)

Birincil metnin iki varyantı Set A'dakiyle **birebir aynı**. Mağaza adı
yalnızca başlıkta geçiyor.

**Başlık**
```
Kelimeki — App Store'da ücretsiz
```

**Açıklama**
```
iPhone ve iPad için Türkçe kelime oyunu
```

**Düğme:** Set A ile aynı (`İndir`).

### 4.3 · Metin kuralları

- İki birincil metin varyantını reklamın **"Birden fazla metin seçeneği"**
  alanına ikisini birden gir. Meta hangisini daha çok göstereceğine kendi
  karar verir; ayrı reklam açmaya gerek yok.
- **Metne link YAZMA.** Link reklamın "Web sitesi URL'si" alanında (§5).
  Metindeki link tıklanmaz ama ölçümsüz bir kopya olarak dolaşır.
- **Etiket (#) YOK.** Reklamda hashtag erişim getirmez, tıklamayı
  profile kaçırır.
- **Marka satırı YOK.** Organik turdaki kullanıcı kararıyla aynı
  (`sosyal-lansman.md` §0). Google ya da Apple itiraz ederse eklenecek metin
  orada.
- "63.000+" ve "üç zorluk" gibi sayılar değişirse metin bayatlar. Kaynak:
  README'deki kelime sayısı ve `AI_LEVEL_TOP_N`.

---

## 5 · Linkler ve etiketler

**Kural:** her reklamın **kendi etiketi** var. Böylece hangi kreatifin kurulum
getirdiği mağaza raporunda ayrı satır olarak görünür. Önek `meta-`, çünkü
reklam FB ve IG'de birlikte koşuyor. `ig-`/`fb-` öneki yanlış olur.

| Reklam | Set A · Android (Play) | Set B · iOS (App Store `ct=`) |
|---|---|---|
| karusel | `meta-and-karusel` | `meta-ios-karusel` |
| reel | `meta-and-reel` | `meta-ios-reel` |
| kare | `meta-and-kare` | `meta-ios-kare` |

**Reklam URL'si — iki sette de aynı şablon** (etiketi değiştir):
```
https://kelimeki.com/?ref=meta-and-karusel
```

| Reklam | Set A · Android | Set B · iOS |
|---|---|---|
| karusel | `https://kelimeki.com/?ref=meta-and-karusel` | `https://kelimeki.com/?ref=meta-ios-karusel` |
| reel | `https://kelimeki.com/?ref=meta-and-reel` | `https://kelimeki.com/?ref=meta-ios-reel` |
| kare | `https://kelimeki.com/?ref=meta-and-kare` | `https://kelimeki.com/?ref=meta-ios-kare` |

Site etiketi ilk temasta saklıyor (`captureUtmSource`) ve mağaza rozetine
kendisi ekliyor (§3.0). Reklamda mağaza linki YOK.

**Etiketin nerede göründüğü:**
- **Bizim tablo (anında):** `web_sessions.utm_source` = etiket. Oturumun
  `steps`i karşılamayı, `store`u (mağazaya gitti), oyunu ve üyeliği içerir.
  Admin kartı etikete göre süzmüyor; etiket başına sayı için:
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
- **Play Console → Kullanıcı edinme:** `utm_source=meta-and-*`,
  `utm_medium=web`. Reklamdan siteye, oradan Play'e geçen kurulum.
- **App Store Connect → Kampanyalar:** `ct=meta-ios-*`. ⚠ Apple'ın
  kampanya linki büyük ihtimalle bir de **sağlayıcı numarası (`pt=`)**
  istiyor; site bunu bilmiyor. `pt=` öğrenilirse `taggedStoreUrl`e eklenir.
  Öğrenmenin yolu: App Store Connect → Uygulama Analizi → Edinme →
  Kampanyalar → "Kampanya bağlantısı oluştur"; üretilen linkteki `pt=`
  sayısını bu dosyaya (§9) yaz. Doğrulanmadı: ajan `apps.apple.com`'a
  erişemiyor ve Console kullanıcıda.

**Admin paneli notu:** `meta-` öneki admin'in kanal gruplamasında
(`sourceChannel`, `src/utils/adminGroups.ts`) YOK. Bu etiketle gelen satır
Kaynak/Kanal tablolarında **"Diğer"** grubunda görünür, kaybolmaz. Ayrı bir "Meta" grubu istenirse
tek satırlık bir web değişikliği yeter (öneki + etiketi eklemek +
`verify-admin-groups`).

---

## 6 · Takvim ve karar kuralları

| Faz | Ne zaman | Ne |
|---|---|---|
| **0 · Hazırlık** | Bugünden PR #673 canlıya çıkana kadar | Ödeme yöntemi ve harcama limiti (§7) · kampanyayı **taslak** olarak kur, yayınlama · reklam URL'lerini §5'e göre `kelimeki.com/?ref=…` yap · başlangıç ölçümü: kampanyadan önceki 7 günün Play "Mağaza girişi edinmeleri" ve ASC "İlk indirmeler" sayılarını §9'a yaz · isteğe bağlı: App Store `pt=` numarasını öğren (§5) |
| **1 · Test** | PR #673 canlıda (§1), 5 gün | İki set × ₺100/gün = ₺1.000 |
| **Karar** | 6. gün (verinin gelmesi için +1-2 gün bekle) | Aşağıdaki kurallar |
| **2 · Ölçek** | 5 gün | Kazanan set ₺400/gün. Kaybeden set kapatılır ya da ₺50/gün'e iner |
| **Kapanış** | Bitişin ertesi haftası | §9'a sonuç satırları. Huni v2'den 7. gün geri dönüşü |

**Veri gecikmesi:** Play Console edinme raporu 1-2 gün geriden gelir. App
Store Connect kampanya verisi 24-48 saat gecikir ve Apple küçük sayıları
gizlilik eşiği yüzünden **göstermeyebilir**. Günlük bütçeyi ilk 2 günün
verisine bakıp değiştirme: Meta'nın "öğrenme" dönemi de bu kadar sürer.

**Karar kuralları** (Faz 1 sonunda, set başına):

| Durum | Karar |
|---|---|
| Kurulum başı ≤ **₺40** | Kazanan. Faz 2 bütçesi buraya |
| ₺40-80 | En iyi reklamı bırak, ötekileri kapat, ₺100/gün'le 5 gün daha koştur |
| ≥ ₺80 ya da ₺500 harcandı ve ≤ 5 kurulum | Seti kapat |
| İki set de ≥ ₺80 | Faz 2 YOK. Sorun kreatif ya da hedef kitle. Yeni kreatif turu planla |
| Reklam düzeyinde: 3 günde bağlantı TO < %0,5 | O reklamı kapat |

Kurulum başı = set harcaması ÷ o setin etiketlerinin mağaza raporundaki
kurulum toplamı. **Erken sinyal** (mağaza raporları 1-2 gün gecikir): set
harcaması ÷ o setin etiketlerinde `store` adımına ulaşan oturum sayısı
(§5'teki sorgu). Mağazaya giden her kişi kurmaz; bu sayı kurulum başından
her zaman DÜŞÜK çıkar, eşiklerle doğrudan karşılaştırma. **Meta'nın ekranındaki "sonuç başı maliyet" bu değil:** o,
tıklama başı maliyet.

₺40 bir başlangıç tahmini, ölçülmüş bir referans değil. Faz 1'in ilk
gerçek rakamı bu eşiği yeniden belirler; yeni değeri buraya yaz.

**Kalite:** kurulum ucuz ama kimse oynamıyorsa kazanan sayılmaz. Tarayıcıda
oynayanı §5'teki sorgunun `oyun` ve `uye` sütunları gösterir. Android'de
Huni v2'nin mobil yarısı gelince (5 Ekim treni) mağazadan kurulan
uygulamanın oyunu da görünür. iOS'ta tek sinyal ASC'nin "Oturumlar" ve "Etkin cihazlar"
sayıları.

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

- ❌ Gönderi altındaki **"Öne Çıkar"** düğmesi. Cihaz filtresi, reklam başına
  etiket ve set bütçesi orada yok, ve iOS uygulamasından Apple ücretiyle
  geliyor (§2, §7).
- ❌ Reklam URL'sine mağaza linki (`play.google.com`, `apps.apple.com`)
  koymak. Trafik kampanyası reddeder (#1487810, §3.0).
- ❌ Android setinde iOS, iOS setinde Android. Cihaz filtresi olmadan kurma
  (§3.3).
- ❌ iOS setinde "Artık Google Play'de" görselleri.
- ❌ Kampanya düzeyinde bütçe (CBO) (§3.2).
- ❌ Etiketi yeniden kullanmak. `instagram`, `ig-bio`, `fb-sayfa-play` gibi
  eski etiketler organik turlarındır. Karışırsa ayrım sonradan düzeltilemez,
  çünkü `?ref=` ilk temasta sabitleniyor.
- ❌ Meta'nın "sonuç" sayısını kurulum sanmak (§6).
- ❌ İlk 48 saatte bütçe ya da metin değiştirmek. Değişiklik öğrenmeyi baştan
  başlatır.
- ❌ Pixel ya da SDK "hızlıca" eklemek. Gizlilik metni, Data safety ve App
  Store etiketi değişir. Ayrı bir karar konusu.

---

## 9 · Yayın kütüğü

| Ne zaman | Ne | Ölçüm |
|---|---|---|
| 28 Eyl 2026 | **Kurulum:** "Kelimeki" işletme portföyü + reklam hesabı `1089910146731962` açıldı (kişisel hesaptan AYRI; 16 Eylül boost'u kişisel hesaptaydı). Mastercard tanımlandı, otomatik ödeme, fatura eşiği ₺99. Meta'nın günlük tavanı ₺10.781,62. Hesap harcama limiti henüz KONMADI. Ads Manager "Hesaba Genel Bakış'ta birkaç detayı onaylayın" diyor | Kullanıcının ekran görüntüsünden okundu |
| 28 Eyl 2026 | **Plan değişti:** Set A'nın `karusel` reklamına Play linki yazılınca Ads Manager #1487810 verdi (Trafik'te mağaza linki yok). Kullanıcı Yol 1'i seçti (§3.0). Web değişikliği PR #673'te; `store` adımının migration'ı (`20260928100430_web_journey_store_step`) **canlıya uygulandı** ve doğrulandı (iki fonksiyonda da `store` var, grant'ler ve `security definer` aynı) | `pg_get_functiondef` · `list_migrations` |
| 28 Eyl 2026 | Set A kuruldu (taslak): Trafik · yönlendirme sayfası görüntülemeleri · ₺100/gün · 5-10 Ekim (Meta başlangıcı en fazla ~1 hafta ileri alıyor, yayından önce gerçek tarihe çekilecek) · yalnızca Android, min 7.0 · FB/IG akış, IG Keşfet, hikaye, reels · 18+ · Türkçe. `karusel` reklamının URL'si henüz Play linki → `kelimeki.com/?ref=meta-and-karusel` olacak | Kullanıcının ekran görüntülerinden okundu |
| — | Başlangıç ölçümü (kampanya öncesi 7 gün): Play mağaza girişi edinmeleri = ? · ASC ilk indirmeler = ? | Play Console · ASC |
| — | App Store kampanya linkleri üretildi (`pt=` = ?) | — |
| — | Faz 1 başladı | — |

**Üretilen App Store linkleri:** *(henüz yok)*
