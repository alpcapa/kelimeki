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
| Reklam setleri | **2 set:** Android → doğrudan Google Play · iOS → doğrudan App Store |
| Reklamlar | Her sette **3 reklam:** carousel · reel · tek kare |
| Bütçe | Toplam **₺3.000**. Test: 5 gün × ₺200/gün. Ölçek: kazanan sete 5 gün × ₺400/gün |
| Kurulum yeri | **Tarayıcıdan Ads Manager.** iOS uygulamasından verilen reklama Apple'ın %30 ücreti ekleniyor (§7) |
| Başlangıç | **Kapı açılınca** (§1). Tahmini tarih 8-12 Ekim |
| Başarı ölçüsü | Mağaza başına **kurulum başı maliyet**. Meta'nın tıklama sayısı ölçü DEĞİL (§2) |

---

## 1 · Başlangıç kapısı — Huni v2'nin mobil yarısı

`docs/decisions/funnel-v2.md` → "Pazarlama kapısı" (kullanıcı kararı, 24
Eylül 2026): **bütçe, Huni v2'nin mobil yarısı (PR 2) Play'de yayında olunca
ve admin tablosunda Android `land` satırı görününce açılır.** PR 2 **5 Ekim
treninde**. Play incelemesi 1-3 gün sürerse bütçe ~8-12 Ekim'de açılabilir.

**Neden beklenmeli:** PR 2 olmadan Android kurulumu Play Console'da görünür
(UTM satırı), ama o kişinin oyuna girip girmediğini ve üye olup olmadığını
bizim tablomuz göremez. PR 2 gelince Play Install Referrer uygulamanın ilk
açılışında okunuyor, ve reklamdan gelen Android cihaz admin → Huni v2'de
**kurulum → oyun → üyelik** zinciriyle görünüyor.

iOS'ta bu kapının karşılığı yok. Apple kişi bazında kaynak vermiyor, iOS
kırılımını ancak App Store Connect'in toplu kampanya raporu veriyor
(`funnel-v2.md` → "Kanal — platform platform"). Yani iOS seti kapıyı
beklemeden de koşabilir. **Önerilen yol yine de ikisini birlikte
başlatmak:** iki set aynı hafta, aynı kreatiflerle koşarsa sonuçları
karşılaştırılabilir olur.

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

⚠ **Cihaz filtresi bu kampanyanın omurgası.** Filtre unutulursa Android
seti iPhone'a da gösterilir. O kişi Play linkine dokunur, tarayıcıda boş bir
sayfa görür, ve para gider. Yayından önce iki setin özetinde "Android" ve
"iOS" yazdığını gözle kontrol et.

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

**Set A — URL şablonu** (etiketi değiştir, gerisine dokunma):
```
https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki&referrer=utm_source%3Dmeta-and-karusel
```
`%3D` URL-kodlu `=` işaretidir. Elle `=` yapma, Play onu ayrı parametre sanar.

**Set B — App Store kampanya linki: App Store Connect'İN ÜRETTİĞİ link olsun.**
⚠ Şimdiye kadarki linkler (`…/id6809809788?ct=fb-sayfa`) yalnızca `ct=`
taşıyordu. Apple'ın kampanya linkinde bir de **sağlayıcı numarası (`pt=`)**
var, ve o olmadan kampanya raporuna düşmemesi muhtemel. Bu hesapta
doğrulanmadı: ajan `apps.apple.com`'a erişemiyor ve Console kullanıcıda.
Doğru yol şu:

1. App Store Connect → **Uygulama Analizi** → Kelimeki → **Edinme** (Acquisition) →
   **Kampanyalar** → **Kampanya bağlantısı oluştur**. Menü adları biraz
   farklı olabilir; aranan şey "Campaign link" üreticisi.
2. Kampanya adına etiketi yaz (`meta-ios-karusel`), üç link üret.
3. Üretilen linkin şekli aşağı yukarı şöyle olmalı. `pt=` numarasını
   sayfadaki linkten al, tahmin etme:
   ```
   https://apps.apple.com/app/apple-store/id6809809788?pt=<SAĞLAYICI_NO>&ct=meta-ios-karusel&mt=8
   ```
4. Üretilen linki bu dosyaya, §9'un altına yaz. Sonraki turlar aynı
   `pt=`'yi kullanacak ve organik linkler de düzeltilebilir.

**Admin paneli notu:** `meta-` öneki admin'in kanal gruplamasında
(`sourceChannel`, `src/utils/adminGroups.ts`) YOK. Bu etiketle gelen satır
**"Diğer"** grubunda görünür, kaybolmaz. Bu kampanyada mağazalara doğrudan
gidildiği için web tablosuna zaten neredeyse hiç satır düşmeyecek. Android
satırları PR 2'den sonra Huni v2'ye düşer. Ayrı bir "Meta" grubu istenirse
tek satırlık bir web değişikliği yeter (öneki + etiketi eklemek +
`verify-admin-groups`).

---

## 6 · Takvim ve karar kuralları

| Faz | Ne zaman | Ne |
|---|---|---|
| **0 · Hazırlık** | Bugünden kapıya kadar | §5'teki App Store linklerini üret · ödeme yöntemini tarayıcıdan ekle (§7) · kampanyayı **taslak** olarak kur, yayınlama · başlangıç ölçümü: kampanyadan önceki 7 günün Play "Mağaza girişi edinmeleri" ve ASC "İlk indirmeler" sayılarını §9'a yaz |
| **1 · Test** | Kapı açılınca, 5 gün | İki set × ₺100/gün = ₺1.000 |
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
kurulum toplamı. **Meta'nın ekranındaki "sonuç başı maliyet" bu değil:** o,
tıklama başı maliyet.

₺40 bir başlangıç tahmini, ölçülmüş bir referans değil. Faz 1'in ilk
gerçek rakamı bu eşiği yeniden belirler; yeni değeri buraya yaz.

**Kalite:** kurulum ucuz ama kimse oynamıyorsa kazanan sayılmaz. Android'de
Huni v2 (PR 2'den sonra) `meta-and-*` cihazlarının kaçının oyun başlattığını
gösterir. iOS'ta tek sinyal ASC'nin "Oturumlar" ve "Etkin cihazlar"
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
| — | Başlangıç ölçümü (kampanya öncesi 7 gün): Play mağaza girişi edinmeleri = ? · ASC ilk indirmeler = ? | Play Console · ASC |
| — | App Store kampanya linkleri üretildi (`pt=` = ?) | — |
| — | Faz 1 başladı | — |

**Üretilen App Store linkleri:** *(henüz yok)*
