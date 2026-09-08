# App Store Connect — form cevap kağıdı ve adım sırası (8 Eylül 2026)

Bu dosya **App Store Connect'e elle girilecek her formun cevabını** taşıyor.
`marketing/play-store/console-formlari.md`'nin iOS ikizi ve aynı disipline
tabidir: Console'da tıklarken cevap burada hazır olsun, ikinci kez
araştırılmasın.

**Yaşayan bir kayıt, anlık görüntü DEĞİL.** Yeni bir veri toplayan özellik
ya da görünürlük değişikliği geldiğinde `TermsModal`/`PrivacyModal` ile
birlikte burası da güncellenir.

⚠ **ROADMAP `#24 FAZ C` bir İNDEKS, kaynak burası.** Bir kova kapandığında
karar bu dosyadan okunur. Play tarafında bunun tersi bir kez yaşandı ve
özet tablo altı gün bayat kaldı.

---

## 0. Bugüne kadar BİTENLER (8 Eylül 2026)

| | Ne | Durum |
|---|---|---|
| Üyelik | Apple Developer Program, **Bireysel** | ✅ aynı gün aktif (ödeme→aktivasyon ~12 dk) |
| Team ID | `8277D85FY9` | ✅ |
| App ID | `com.kelimeki.kelimeki`, **Explicit** + Push Notifications + Associated Domains | ✅ |
| APNs anahtarı | Key ID `RL4JLXL389`, Team Scoped (All Topics), Sandbox & Production | ✅ Firebase'de iki satır da dolu |
| Uygulama kaydı | `Kelimeki` · iOS · Türkçe · SKU `kelimeki-ios` | ✅ *Prepare for Submission* |
| Free Apps Agreement | Tüm ülkeler, `Sep 8, 2026 – Sep 8, 2027` | ✅ **Active** (üyelikle otomatik) |
| App Store Connect API | Key ID `7ARZF96LAK`, **Admin** | ⚠ üretildi ama `.p8` İNDİRİLEMEDİ (aşağı) |
| DSA trader status | — | ⬜ **BEKLİYOR, gönderim kapısı** (aşağı) |

**Paid Apps Agreement İMZALANMAYACAK.** `New` durumunda kalır; uygulama
ücretsiz, uygulama içi satın alma yok. Console'un *"update your legal
entity information prior to signing the Paid Apps Agreement"* uyarısı
yalnızca onu ilgilendiriyor, bizi değil.

---

## 1. Hesap kimliği

| Alan | Değer |
|---|---|
| Program | Apple Developer Program |
| Enrolled as | **Individual** |
| Ad | Alp Reşat Çapa |
| Apple ID | `destek@kelimeki.com` |
| Team ID | `8277D85FY9` |
| Yenileme | 9 Eylül 2027, auto-renew açık |

⚠ **Bireysel hesabın geri alınamaz sonucu:** App Store'da satıcı olarak
**kişinin yasal adı** görünür ve değiştirilemez. Play tarafı da kişiseldi
(*Personal account*), yani iki mağazada tutarlı.

⚠ **`destek@kelimeki.com` kritik bir kutu:** üyelik yenileme, sözleşme
değişikliği ve App Review yazışmaları oraya düşüyor. Adres Zoho'da
(`docs/decisions/support-email.md`); o kutuya erişimi kaybetmek geliştirici
hesabına erişimi kaybetmek demek. Apple ID'nin 2FA'sındaki güvenilir
numara/cihaz da kalıcı olmalı.

---

## 2. DSA trader status — **KARAR VERİLDİ, UYGULANMADI**

**Durum: beyan HENÜZ YAPILMADI.** 8 Eylül 2026'da pencere açıldı ve
bilinçli olarak **Cancel** edildi.

### Karar: **trader olarak beyan edilecek** (AB dağıtımı korunacak)

Ama **bugünkü telefon numarasıyla değil.** Sıra şu:

1. Yedek hat aktifleştirilecek (kullanıcı, 9 Eylül 2026'da deneyecek)
2. Business → Agreements → Compliance → **"I'm a trader under the DSA"**
3. Üç alan girilecek: **adres · telefon · e-posta**
4. Apple doğrulayacak → AB dağıtımı açılacak

### Neden kişisel numarayla başlanmadı

Trader bilgileri App Store ürün sayfasında **herkese görünür** olur
(Apple: *"verify and display trader contact information"*). Konsolda
sonradan değiştirilebiliyor — **ama yayınlanmış bilgi dünyadan geri
alınamaz**: kazıyıcılar, arama motorları, arşivler. Kişisel cep numarasını
birkaç hafta açıkta bırakmanın bedeli kalıcı.

**Ve acelesi yoktu:** trader beyanı yalnızca **gönderimden önce** gerekli.
8 Eylül itibarıyla uygulama `Prepare for Submission`, vitrin yok, TestFlight
zinciri yok. Beyanı o gün yapmanın kazandırdığı hiçbir şey yoktu.

**İkinci sebep:** Apple bilgiyi doğruluyor. Doğrulama numaraya kod
gönderiyorsa (muhtemel, doğrulanmadı) kişisel numarayla beyan edip sonra
değiştirmek doğrulamayı **iki kez** yapmak olurdu; yedek hat zaten aktif
olmadan doğrulanamaz.

### Alanlara ne girilecek

| Alan | Değer | Not |
|---|---|---|
| E-posta | `destek@kelimeki.com` | **Bedava** — zaten sitede, Play listelemesinde ve uygulamada yazılı; yeni maruziyet yok |
| Telefon | *yedek hat* | Aktifleştirilecek; kişisel numara KULLANILMAYACAK |
| Adres | *belirlenecek* | Ev adresi zorunlu DEĞİL — bu alan üyelikteki adresten ayrı (*"won't impact the contact details for your Apple accounts or memberships"*). Posta kutusu / sanal ofis olur, ama Apple doğruladığı için gerçek olmalı |

### ⚠ GÖNDERİM KAPISI

**Trader beyanı + doğrulaması tamamlanmadan uygulama incelemeye
gönderilemez.** Bu bir "unutma listesi" maddesi değil, gönderim öncesi
kontrol listesinin maddesi.

### Play tarafı aynı beyanı bekliyor

DSA aynı şeyi Google Play'den de istiyor. Kelimeki Play'de kapalı testte
olduğu için henüz tetiklenmemiş olabilir; üretime çıkınca gelecek. Depoda
Play tarafında trader beyanı kaydı **yok**. **İki mağazada AYNI bilgi
beyan edilmeli** — farklı bilgi vermek açıklaması zor bir tutarsızlık.

### Kaynaklar

- [Manage EU DSA trader requirements — App Store Connect Help](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/)
- [Apps without trader status will be removed from the App Store in the EU](https://developer.apple.com/news/?id=einwn76m)

Beyan değiştirilebilir: Business → Agreements → Compliance →
*Complete Compliance Requirements*; uygulama başına açıp kapatma da var.

---

## 3. App Store Connect API anahtarı — **`.p8` İNDİRİLEMEDİ**

| Alan | Değer |
|---|---|
| Name | `Kelimeki CI` |
| Key ID | `7ARZF96LAK` |
| Access | **Admin** |
| Issuer ID | GitHub secret'ında (bu dosyaya YAZILMADI, aşağı bkz.) |

**Access neden Admin:** yalnızca TestFlight'a paket yüklemek için *App
Manager* yeterdi. Ama bu anahtar imzalama sertifikası ve provisioning
profile de üretecek (Mac yok, fastlane API üzerinden yapacak) ve Console
açıkça uyarıyor: *"Keys don't expire, but **can't be modified** to access
more services once created."* Rol sonradan yükseltilemediğine ve tek
kişilik bireysel hesapta Admin ↔ App Manager güvenlik farkı olmadığına
göre yanlış tahminin bedeli (yeni anahtar + secret rotasyonu) gereksiz.

### ⚠ ÇÖZÜLMEMİŞ: indirme iki kez hata verdi

8 Eylül 2026: **Download API Key** penceresi *"An error has occurred. Try
again later."* dedi. İkinci denemeden sonra satırdaki **Download** linki
KAYBOLDU ve `LAST USED` doldu — yani Apple anahtarı indirilmiş sayıyor,
`.p8` elde YOK.

**Sonuç: bu anahtar KULLANILAMAZ.** Yapılacak: eskisini **revoke** et,
yenisini üret (`Kelimeki CI 2`, Admin), indir.
- Issuer ID **değişmez** (hesabın kimliği, anahtarın değil)
- Yeni **Key ID** secret'a girilecek
- Kullanılamayan anahtarı listede bırakma — hangisinin canlı olduğu karışır

**Bu YALNIZCA 24.2'yi (imzalama + TestFlight) tıkıyor.** Vitrin, yaş
derecesi, App Privacy, trader beyanı — hepsi bundan bağımsız ilerler.

### ⚠ Değerler bu dosyaya YAZILMAZ

`Key ID + Issuer ID + .p8` üçlüsü App Store Connect'e **Admin** erişimi
demek ve **depo public** (`alpcapa/kelimeki`). Üçü de GitHub secret'ında
yaşar:

| Secret | İçerik |
|---|---|
| `APP_STORE_CONNECT_KEY_ID` | Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_KEY_P8` | `.p8`'in tam içeriği (BEGIN/END satırları dahil) |

⚠ **APNs Key ID ile karıştırma:** o (`RL4JLXL389`) ROADMAP'e YAZILDI ve
doğrusu bu — her push JWT'sinin `kid` başlığında zaten herkese gidiyor,
özel anahtar olmadan işe yaramıyor, ve hangi anahtarın canlı olduğunu
bilmek operasyonel bir ihtiyaç (yanlışını iptal etmek canlıda push'u
düşürür). App Store Connect anahtarının böyle bir kamusallığı YOK.

---

## 4. Uygulama kaydı — girilen değerler

| Alan | Değer |
|---|---|
| Platform | iOS |
| Name | `Kelimeki` |
| Primary Language | **Turkish** |
| Bundle ID | `com.kelimeki.kelimeki` |
| SKU | `kelimeki-ios` |
| User Access | Full Access |

⚠ Bundle ID formda bir **açılır liste** — Developer portalında Identifiers'a
kaydedilmemiş bir id orada görünmez. Kayıt sırası: Identifiers → sonra App
Store Connect.

---

## 5. Yaş derecesi — Play'in IARC cevapları TEKRAR KULLANILIR

App Store Connect *"Review New Social Media Questions on Age Ratings"*
diye uyarıyor ve bu uygulamayı gerçekten ilgilendiriyor: Canlı oyunda
oyun içi mesajlaşma var.

**Cevaplar `marketing/play-store/console-formlari.md` §3.5'te ölçülmüş
hâliyle duruyor** — burada TEKRARLANMIYOR, oradan okunur. Özet:

- Kullanıcılar birbiriyle etkileşebiliyor / içerik paylaşabiliyor → **EVET**
- Kişisel bilgi paylaşımı → **Evet** (serbest metin sohbet, takma ad, profil fotoğrafı)
- Küfür/kaba dil (uygulamanın kendi ürettiği) → **Hayır** (sözlük TDK tabanlı)

**Play'de sonuç: en düşük bant** (PEGI 3 · USK 0 · ESRB Everyone · IARC 3+).
ROADMAP *"sohbet yaş derecesini yükseltir"* diye öngörmüştü, **ölçüm bunu
doğrulamadı** — sohbete ancak kabul edilmiş arkadaşlar arasında
erişilebildiği için. Apple'da da aynı dürüst beyan yapılacak; **sohbeti
beyan etmemek askıya alma sebebi**, beyan etmek olmadı.

---

## 6. Sabit URL'ler (formlarda tekrar tekrar sorulur)

| Ne | Adres |
|---|---|
| Destek | `https://kelimeki.com` |
| Gizlilik politikası | `https://kelimeki.com/gizlilik/` |
| Kullanım koşulları | `https://kelimeki.com/kullanim-kosullari/` |
| Hesap silme | `https://kelimeki.com/hesap-silme/` |
| Destek e-postası | `destek@kelimeki.com` |

Kategori: **Games → Word** (Play'de de Games → Word).

---

## 7. Henüz DOLDURULMAMIŞ — açık işler

- **Ekran görüntüleri.** ✅ **YOL BULUNDU ve ÖLÇÜLDÜ** (8 Eylül 2026) —
  ayrıntı §13. Kalan iş üretim değil, KOMPOZİSYON (hangi ekranlar, çerçeve,
  başlık metinleri).
- **App Privacy.** Play'in Data safety'sinin eşi ve büyük ölçüde ondan
  türer (`play-store/console-formlari.md` §3.8 — o bölüm "en dikkatli iş"
  diye işaretli, eşleme oradan yapılacak).
- **Açıklama / anahtar kelimeler / promosyon metni.**
  `marketing/play-store/metin.md` başlangıç noktası, ama App Store'un alan
  sınırları farklı.

---

## 8. Bilinen tuzaklar (hepsi 8 Eylül 2026'da yaşandı)

| Tuzak | Ders |
|---|---|
| `.p8` dosyaları KARIŞIYOR | APNs anahtarı (→ Firebase) ile App Store Connect API anahtarı (→ GitHub secret) ayrı dosyalar; ikisi de **bir kez** indirilir. `GoogleService-Info.plist` ise bir üçüncüsü ve gizli DEĞİL (repoda) |
| APNs ekranı dişli menüsünde YOK | Firebase: dişli → **General** → sekme şeridinden **Cloud Messaging**. Firebase bu bölümü birkaç kez taşıdı |
| APNs'te iki ortam satırı var | **Production** kritik (TestFlight/App Store oraya bağlanır); yalnız development doluyken bildirim **hatasız** düşmez |
| App ID capability'leri Save'siz kaydedilmiyor | İşaretleyip sayfadan çıkmak sessizce kaybettirir; hata çok sonra, imzalama sırasında *"profile doesn't include entitlement"* diye çıkar |
| Firebase'in **"Flutter"** akışı | KULLANILMADI — `firebase_options.dart` üretip Android tarafını da yeniden yazar. Bu depo yapılandırmayı iki platformda da NATIVE dosyadan okuyor (`push_init.dart`) |

---

## 9. Mağaza metinleri — App Store'un alan sınırlarına göre (8 Eylül 2026)

⚠ **Play'in metni OLDUĞU GİBİ kullanılamaz.** App Store'un alanları farklı:
`Subtitle` (30) ve `Keywords` (100) Play'de YOK; Play'in `Kısa açıklama`sı
(80) burada YOK. Uzunluklar aşağıda **ölçüldü** — Apple da Play gibi taşan
metni sessizce keser.

| Alan | Sınır | Ölçülen | Değer |
|---|---|---|---|
| **Name** | 30 | **29** | `Kelimeki: Türkçe Kelime Oyunu` |
| **Subtitle** | 30 | **25** | `Bölgeni büyüt, tahtayı al` |
| **Keywords** | 100 | **93** | aşağı |
| **Promotional text** | 170 | **162** | aşağı |
| **Copyright** | — | 19 | `2026 Alp Reşat Çapa` |

⚠ **Uygulama kaydı `Kelimeki` adıyla açıldı.** Yukarıdaki 29 karakterlik ad
Play'le hizalı ve aramada daha iyi; App Information'dan **ilk gönderimden
önce** değiştirilebilir. Değiştirilmezse de sorun değil, ama Play ile
ayrışır.

### Keywords

```
sözcük,harf,bulmaca,zeka,strateji,sözlük,TDK,arkadaş,çevrimdışı,yapay,tahta,anlam,bingo,joker
```

⚠ **Virgülden sonra BOŞLUK YOK** — boşluk 100 karakterlik bütçeden yer yer.
⚠ **Name ve Subtitle'daki kelimeler TEKRARLANMAZ** — Apple onları zaten
indeksliyor, tekrar bütçe israfı. Bu yüzden elendi: *kelime · türkçe · oyun ·
bölge · büyüt · tahtayı*.

### Promotional text (sürüm yayınlamadan değiştirilebilir)

```
Türkçe için sıfırdan tasarlanmış bir kelime oyunu. Kelime kur, bölgeni büyüt, rakibinin alanına girerken vergiyi göze al. Ücretsiz, reklamsız, çevrimdışı oynanır.
```

### Description

**Play'in tam açıklaması AYNEN kullanılabilir** (`marketing/play-store/
metin.md` → "Tam açıklama"): 4000 karakter sınırı iki mağazada da aynı ve
metin başka bir platformdan söz etmiyor. Buraya KOPYALANMIYOR — tek kaynak
o dosya, ikiye bölünürse biri bayatlar.

### Sabit alanlar

| Alan | Değer |
|---|---|
| Support URL | `https://kelimeki.com` |
| Marketing URL | `https://kelimeki.com` |
| Privacy Policy URL | `https://kelimeki.com/gizlilik/` |
| Category | Games → **Word** (ikincil: Games → Puzzle, isteğe bağlı) |
| Price | **Free** |
| License Agreement | Apple'ın standart EULA'sı (özel sözleşme YOK) |

---

## 10. App Privacy — Play'in Data safety'sinden eşleme

Kaynak: `marketing/play-store/console-formlari.md` §3.8. Apple **iki fazla
soru** soruyor, ikisi de Play'de yok:

### Soru 1 — "Used for Tracking?" → **HER SATIRDA HAYIR**

Apple'ın "tracking" tanımı dar: veriyi **üçüncü tarafın** verisiyle
eşleştirip hedefli reklam yapmak ya da veri simsarına satmak. Kelimeki'de
reklam ağı, reklam SDK'sı ve veri satışı YOK.

⚠ **Sonuç: App Tracking Transparency (ATT) izni GEREKMİYOR** — yani
`NSUserTrackingUsageDescription` ve `AppTrackingTransparency` çerçevesi
eklenmeyecek. Bir gün reklam/attribution SDK'sı girerse bu satır değişir ve
ATT ile birlikte gelir.

### Soru 2 — "Linked to the User?"

**Burada Play'in düz beyanının göstermediği bir avantaj var** (migration'lar
okundu, 8 Eylül 2026): telemetri tabloları **bilerek `user_id` taşımıyor**.

| Tablo | Kanıt |
|---|---|
| `client_errors` | *"BİLEREK user_id TAŞIMAZ"* (`20260821084652_client_errors.sql`) |
| `device_visits` | *"BİLEREK user_id YOK, hesapla asla eşleştirilmez"* (`20260824064031_...`) |
| `game_starts` | *"TABLODA `user_id` YOK ve bu BİLİNÇLİ bir gizlilik kararı"* (`20260821080322_...`) |

Yani teşhis ve analitik verisi **Not Linked to You** olarak beyan edilir.

### Eşleme tablosu

| Apple veri türü | Ne | Linked | Amaç |
|---|---|---|---|
| Contact Info → **Name** | Ad, soyad | **Linked** | App Functionality |
| Contact Info → **Email Address** | E-posta | **Linked** | App Functionality · Developer's Advertising or Marketing *(yalnız onay verildiyse)* |
| Identifiers → **User ID** | Takma isim, hesap kimliği | **Linked** | App Functionality |
| Identifiers → **Device ID** | `anon_id` · FCM token · Firebase App instance ID | **Not Linked** (`anon_id`, `device_visits`) / **Linked** (FCM token — `push_tokens.user_id` var) | App Functionality · Analytics |
| User Content → **Photos or Videos** | Profil fotoğrafı | **Linked** | App Functionality |
| User Content → **Other User Content** | Canlı oyun sohbeti · "Görüş Bildir" · şikayet nedenleri | **Linked** | App Functionality |
| Usage Data → **Product Interaction** | Oyun istatistikleri, arkadaşlık bağlantıları (`games`) | **Linked** | App Functionality · Analytics |
| Usage Data → **Product Interaction** | Ziyaret/oyun başlangıç olayları (`device_visits`, `game_starts`) | **Not Linked** | Analytics |
| Diagnostics → **Crash Data** | Hata mesajı + teknik iz (`client_errors`) | **Not Linked** | Analytics |
| Diagnostics → **Other Diagnostic Data** | Sürüm, platform, OS, cihaz modeli | **Not Linked** | Analytics |
| Other Data → **Other Data Types** | Cinsiyet, doğum tarihi *(isteğe bağlı)* | **Linked** | Analytics |

⚠ **Play'in "Paylaşılıyor: Hayır" gerekçesi burada da geçerli** ve 24 Ağustos
2026'da kullanıcı tarafından onaylanmıştı: Supabase/Brevo/Vercel/Firebase
bizim adımıza işleyen **hizmet sağlayıcı**; takma isim/fotoğraf/sohbet ise
kullanıcının kendi başlattığı görünürlük. **Bu denge bozulursa** (veriyi
kendi amacı için kullanan bir üçüncü tarafa geçilirse) hem burası hem Play
beyanı hem `PrivacyModal` birlikte değişir.

---

## 11. App Review Information — **demo hesap ZORUNLU**

Kelimeki giriş gerektiriyor (Canlı oyun, k-lig, geçmiş). Apple incelemeciye
**çalışan bir hesap** verilmesini şart koşuyor; verilmezse *"giriş
yapamadık"* diye reddedilir — yaygın bir ret sebebi.

**Gerekenler:** kullanıcı adı + şifre + (varsa) notlar.

⚠ **Hesap KALICI olmalı ve şifresi DEĞİŞMEMELİ** — her güncelleme
incelemesinde yeniden kullanılıyor.

⚠ **Karar verilmedi:** Play'in test hesapları (`T2`, `Ironman`) var ve ikisi
de `docs/decisions/account-deletion.md` → "ASLA SİLİNMEYECEK İKİ HESAP"
kaydında. Apple için bunlardan biri mi kullanılacak, ayrı bir hesap mı
açılacak — **kullanıcı kararı bekliyor.**

⚠ **Not alanına şunu yazmak faydalı:** uygulamanın hesapsız da (yapay zekaya
karşı) oynanabildiği, girişin yalnızca Canlı oyun/k-lig için gerektiği.
İncelemecinin "neden giriş istiyor" sorusunu baştan kapatır.

---

## 12. Export Compliance — `Info.plist`'e YAZILMALI

**Bugünkü durum: `ITSAppUsesNonExemptEncryption` `Info.plist`'te YOK**
(8 Eylül 2026'da ölçüldü). Sonuç: TestFlight'a yüklenen **her** derlemede
Apple şifreleme sorusunu tekrar sorar ve cevap verilene kadar paket
dağıtılamaz.

**Doğru cevap `false`:** Kelimeki yalnızca standart HTTPS/TLS kullanıyor
(Supabase, Firebase, Brevo uçlarının tamamı) — kendi şifreleme algoritması
yok. Bu, Apple'ın muafiyet kapsamına giriyor.

⚠ **Bu bir BEYAN, kod tercihi değil** — `Info.plist`'e yazmak Apple'a
verilen resmî cevabı sabitler. Kullanıcı onayı olmadan eklenmedi.


---

## 13. Ekran görüntüleri — simülatöre GEREK YOK (8 Eylül 2026, ölçüldü)

**Gereksinim (Apple, 2026):** iPhone için **tek bir set** (6.5" ya da 6.9")
ve iPad için **13"** yeterli. Verilmeyen boyutlar için Apple mevcut setten
ölçekliyor.

| Cihaz sınıfı | Piksel | dpr | Mantıksal |
|---|---|---|---|
| iPhone 6.9" | **1320×2868** | 3.0 | 440×956 |
| iPad 13" | **2064×2752** | 2.0 | 1032×1376 |

### ⚠ DÜZELTME (aynı gün): kaynak SİMÜLATÖR olacak, widget testi DEĞİL

**Önce "widget testinden üretelim, simülatöre gerek yok" sonucuna varıldı ve
bu YANLIŞTI** — `marketing/play-store/metin.md`'deki yazılı karar
okunmadan. O dosya diyor ki:

> *"Neden emülatör/Appetize/web değil: mağazaya giden görüntülerin
> uygulamanın gerçek görüntüsü olması gerekiyor; farklı bir yüzeyden alınan
> görsel **yanıltıcı ekran görüntüsü** olarak değerlendirilebilir."*

Widget testinden çizilen kare de "farklı bir yüzey": aynı Dart ağacı, ama
iOS çalışma zamanı değil (test ortamı Skia, iOS Impeller; iOS kabuğu yok).
Play için reddedilen gerekçe App Store için de geçerli.

**Doğru kaynak: iOS SİMÜLATÖRÜ.** Play'in itirazı emülatöre değil *farklı
runtime*'a: simülatör **gerçek iOS**'u ve gerçek uygulama ikilisini
koşturuyor, üstelik Xcode'un kendi akışı bu — App Store gönderimlerinde
yerleşik ve kabul gören yol. CI'ın macOS runner'ı zaten simülatör derlemesi
üretiyor (`kelimeki-ios-simulator.zip`); eklenecek adım
`xcrun simctl boot` + `io booted screenshot`.

**Widget testi yolu ÇÖPE GİTMİYOR** — iç doğrulama aracı olarak değerli
(bir düzenin belirli bir cihaz ölçüsünde taşıp taşmadığını saniyede
gösteriyor). Yalnızca MAĞAZAYA giden kare olamaz.

### Ölçüm yine de geçerli: piksel boru hattı çalışıyor

**Gereken her parça ZATEN VARDI:**

| Parça | Nerede |
|---|---|
| PNG dökümü (`RenderRepaintBoundary.toImage`) | `test/board_render_test.dart` → `capturePng` |
| Gerçek fontlar (yoksa kutu-font'a düşer) | `test/support/test_fonts.dart` → `loadAppFonts` |
| Tam piksel ölçüsü ayarı | `test/support/test_view.dart` → `setPhoneViewSize` |
| Gerçek ekranları sahte uçlarla mount etme | `test/support/fake_*.dart` |

### ÖLÇÜM (sonda koşuldu, sonra silindi)

- Boş bir Scaffold: `1320×2868` ve `2064×2752` **tam** çıktı, ~1 sn.
- **Gerçek `BoardWidget`** (`reducer_ai2` golden'ının son tahtası) iPhone
  6.9" ölçüsünde **taşmasız** çizildi (459 KB PNG): gerçek taşlar, Türkçe
  harfler, bölge dış hatları, X2/X3 filigranları, nömorfik gölgeler.
  `tester.takeException()` null.
- Fontlar GERÇEK çizildi (Space Grotesk) — test ortamının sessizce Ahem'e
  düşme riski görsel olarak elendi.

### Sınırlar (dürüstçe)

- Çizim **test ortamının Skia'sı**; iOS bugün Impeller kullanıyor. İnce
  farklar olabilir. Apple ekran görüntüsünün cihazla piksel-eş olmasını
  ŞART KOŞMUYOR (içeriğin uygulamayı doğru temsil etmesini şart koşuyor),
  yani bu bir engel değil — ama "cihazda birebir böyle görünecek" diye
  iddia edilmez.
- **Durum çubuğu yok.** Apple zorunlu tutmuyor.
- Bu turda çizilen `BoardWidget` KOLAY vakaydı. `SetupScreen`/`GameScreen`
  gibi tam ekranlar depolama + sözlük + sahte uçlar istiyor — altyapı
  `setup_screen_test.dart`'ta hazır ama her ekran için kurulum gerekiyor.

### Çekim listesi: Android'in AYNISI (kullanıcı kararı, 8 Eylül 2026)

**Liste `marketing/play-store/metin.md` → "Çekim listesi — tek tek"de.**
Buraya KOPYALANMIYOR; tek kaynak orası. Altı zorunlu + bir isteğe bağlı:

1. Oyun ekranı, oyunun ortası *(en önemli kare)*
2. Geçerli bir hamle kurulmuşken (yeşil dış hat + puan rozeti)
3. Kurulum ekranı, "Arkadaşınla" sekmesi
4. Skor kartı
5. Kelime anlamı (TDK penceresi)
6. Nasıl Oynanır
7. *(isteğe bağlı)* k-lig sıralaması

**Gizlilik kuralları da aynen geçerli** (o dosyada yazılı): test hesabıyla
çek (`T1`/`T2`), e-posta geçen ekran yok, gerçek yazışma yok, gerçek
arkadaş adı/avatarı yok.

### ⚠ İKİ FARK — Android setini olduğu gibi kullanmak MÜMKÜN DEĞİL

**1. Dosyalar yeniden çekilecek.** Play'e giden 7 kare `1080×2072` ve
**Android arayüzü**. App Store `1320×2868` (iPhone 6.9") istiyor ve
görüntünün iOS uygulaması olması gerekiyor. "Aynı set" = aynı EKRANLAR,
aynı dosyalar değil.

**2. Kırpma kuralı TERS DÖNÜYOR.** Play'de kırpma **zorunluydu** (ham
`1080×2400` = 1:2.22, Play'in 2:1 tavanını aşıyordu). App Store ise **tam
piksel ölçüsü** istiyor — simülatörün ham karesi zaten doğru ölçüde, ve
**kırpmak onu GEÇERSİZ yapar.** Play refleksiyle durum çubuğunu kırpma.

**3. iPad seti Android'de YOKTU.** App Store, uygulama iPad'i desteklediği
için **13" (2064×2752)** seti de istiyor. Aynı ekranların iPad simülatöründe
ikinci kez çekilmesi gerekiyor — Play turunda karşılığı olmayan yeni bir iş.

### Kalan iş

- CI'ın `ios` işine simülatör açıp kare çeken adım (`simctl`)
- Ekranlara gezinmenin nasıl sürüleceği (`integration_test` altyapısı depoda
  YOK, sıfırdan kurulacak)
- iPad seti için ikinci cihaz
