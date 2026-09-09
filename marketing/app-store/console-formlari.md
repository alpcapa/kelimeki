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
| DSA trader status | Yedek hat ✅ **hazır** (9 Eylül 2026) | ⬜ **BEYAN YAPILMADI** — açık kalan tek alan **adres**; gönderim kapısı (§2) |

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

1. ✅ **Yedek hat hazır** (kullanıcı bildirdi, 9 Eylül 2026) — beyanı
   bekleten iki şeyden biri düştü
2. Business → Agreements → Compliance → **"I'm a trader under the DSA"**
3. Üç alan girilecek: **adres · telefon · e-posta**
4. Apple doğrulayacak → AB dağıtımı açılacak

⚠ **Kalan TEK açık alan: ADRES** (9 Eylül 2026). E-posta ve telefon
hazır; beyan bu alan kararlaşmadan yapılamaz, çünkü form üçünü birden
istiyor ve girilen bilgi ürün sayfasında **yayınlanıyor**.

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
| Telefon | *yedek hat* | ✅ **hazır** (9 Eylül 2026); kişisel numara KULLANILMADI |
| Adres | *belirlenecek* | ⬜ **AÇIK KALAN TEK ALAN.** Ev adresi zorunlu DEĞİL — bu alan üyelikteki adresten ayrı (*"won't impact the contact details for your Apple accounts or memberships"*). Posta kutusu / sanal ofis olur, ama Apple doğruladığı için gerçek olmalı |

### Adres — üç aday (9 Eylül 2026, karar kullanıcıda)

Telefonun gerekçesi burada BİREBİR geçerli: girilen adres ürün sayfasında
herkese görünür ve **yayınlanan bilgi geri alınamaz**. Ama telefondan bir
farkı var — Apple adresi doğruluyor, yani "gerçek ama bana ait olmayan" bir
adres uydurulamaz.

| Aday | Artı | Eksi |
|---|---|---|
| **Ev adresi** | Bedava, anında, doğrulaması kesin geçer | Kalıcı olarak açıkta; telefonda kaçınılan şeyin aynısı |
| **PTT posta kutusu** | Ucuz, gerçek ve doğrulanabilir bir posta adresi | Kurulumu şubede; Apple'ın posta kutusu adresini kabul edip etmediği **ÖLÇÜLMEDİ** |
| **Sanal ofis / işletme adresi** | Ticari amaç için tasarlanmış, kabul edilme olasılığı en yüksek | Aylık ücret; ücretsiz bir oyun için orantısız olabilir |

⚠ **Hiçbiri bu depoda ölçülmedi** — Apple'ın hangi adres türünü doğrulamada
kabul ettiği yalnızca denenerek görülür. Telefonun dersini tekrarlamamak
için sıra şu olmalı: adres seçilir → beyan **bir kez** yapılır. Yarım
bilgiyle beyan edip sonra düzeltmek doğrulamayı ikinci kez tetikler.

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

**İKİ anahtar yakıldı, ikisi de kullanılamaz:**

| Ad | Key ID | Durum |
|---|---|---|
| `Kelimeki CI` | `7ARZF96LAK` | `.p8` inmedi, Download linki kayboldu |
| `Kelimeki CI 2` | *(kayda geçmedi)* | aynı hata |

Yani sıradaki ad **`Kelimeki CI 3`**.

- **İKİSİNİ DE revoke et** — bu satır bir süre yalnızca birinden söz
  ediyordu; elinde `.p8`'i olmayan Admin anahtarları listede birikirse
  hangisinin canlı olduğu karışır.
- Issuer ID **değişmez** (hesabın kimliği, anahtarın değil).
- Yeni **Key ID** secret'a girilecek.
- İndirme yolunu sağlamlaştır: Safari'de *Request Desktop Website*, indirme
  biter bitmez dosyayı **Dosyalar → İndirilenler**'de gözle doğrula. Mümkünse
  bilgisayardan dene — bu depo iPad Safari'nin dosya indirme/yükleme
  davranışıyla daha önce günlerce uğraşmıştı (Appetize `.apk` vakası).
- **Üçüncü kez de hata verdi** (8 Eylül 2026) — tarayıcı değil Apple tarafı.

### ✅ ÇÖZÜM YOLU: `Team Keys` değil **`Individual Keys`**

Üç Team Key yakıldıktan sonra `Users and Access → Integrations →
**Individual Keys**` denendi. **Anahtar üretildi: Key ID `25Z8S0CFZFPA`.**
İndirme orada da hata verdi — ama **iki kritik fark var:**

| | Team Keys | Individual Key |
|---|---|---|
| Hata metni | `An error has occurred. Try again later.` | `We were unable to supply you with a key. **Wait a minute, then try again.**` |
| Başarısız denemeden sonra | Download linki kayboluyor, anahtar yanıyor | **AYNISI** (aşağı bkz.) |
| Yenilenebilir mi | Hayır — her deneme listede ölü bir kayıt bırakıyor | **Evet** — revoke → yeni üret (aynı anda tek anahtar) |

⚠ **DÜZELTME (8 Eylül 2026, aynı gün):** Bu tablo bir süre *"Individual
Key'de Download linki DURUYOR, tekrar denemek bedava"* diyordu. **YANLIŞTI.**
İddia ilk ekran görüntüsüne dayanıyordu — link o an gerçekten duruyordu — ama
sonraki denemelerde o da kayboldu. Doğrusu: **iki uçta da başarısız indirme
anahtarı TÜKETİYOR.** Tek gerçek fark yenilenebilirlik: bireysel anahtar
revoke edilip yenisi üretilebiliyor, Team Keys'te ölü kayıtlar birikiyor.

**Yakılan anahtarlar:** üç Team Key (ilki `7ARZF96LAK`, üçü de revoke) +
bireysel `25Z8S0CFZFPA` → yerine `18QBEN3T2RY4` üretildi, onun da linki
kayboldu.

**Plan artık "aralıklarla dene" DEĞİL:** dört başarısız denemeden ve ~7
saatten sonra bu bir geçici hata değil. **Apple Developer Support vakası
açılacak** (aşağıdaki metin hazır). ⚠ Vaka açıkken `18QBEN3T2RY4`'ü
**revoke etme** — destek ekibi anahtarın durumuna bakacak.

### ✅ VAKA AÇILDI — 9 Eylül 2026, 00:15 (UTC+3)

`developer.apple.com/contact` → **App Store Connect Users and Roles**
(on alt konu arasında API anahtarlarının konsolda gerçekten durduğu yer
orası: *Users and Access → Integrations*). Form "başka bir kullanıcıyı"
soran kalıpta; kendi bilgilerimizle dolduruldu — *User's Apple Account:*
`destek@kelimeki.com`, *User's role:* `Account Holder, Admin`.

**Cevap beklenirken YAPILMAYACAKLAR:**
- ⚠ **`18QBEN3T2RY4` REVOKE EDİLMEYECEK** — vakada "inceleyebilesiniz diye
  bilerek silmedim" yazıyor. Silmek destek ekibinin elindeki tek canlı
  kaydı yok eder ve standart *"revoke edip tekrar dene"* cevabını davet eder.
- ⚠ **Yeni anahtar üretilmeyecek.** Dört deneme yeterli kanıt; her deneme
  tabloyu karıştırır.
- ⚠ **Mükerrer vaka açılmayacak.**

### ⏳ DURUM — 9 Eylül 2026, 15:50 (UTC+3): **yanıt YOK**

Vaka açılalı ~15,5 saat (Çarşamba, iş günü). **Anahtar `18QBEN3T2RY4`
revoke EDİLMEDİ** — vakadaki söz tutuldu, destek ekibinin bakacağı canlı
kayıt duruyor.

**Karar: bekleniyor, kurcalanmıyor.** Gerekçe, yukarıdaki üç yasağın
aynısı — ama artık bir de sayıya dayanıyor: dört başarısız indirme, iki
ayrı uç. Beşinci deneme yeni bilgi üretmez, yalnızca destek ekibinin
baktığı tabloyu bozar.

**Eşik — 11 Eylül 2026 (Cuma) sonu.** O güne kadar yanıt gelmezse sıradaki
adım yeni bir vaka DEĞİL, mevcut vakayı **telefon geri aramasına**
yükseltmek: `developer.apple.com/contact` üzerinden arama talebi.
*(Apple'ın kendi kanalı; bu depoda ÖLÇÜLMEDİ — yazılı vakanın tipik yanıt
süresi de ölçülmedi, eşik tahmin değil bir karar noktası olarak konuldu.)*

⚠ **Bu bekleyiş hiçbir işi durdurmuyor.** Tıkanan tek şey 24.2'nin
DOĞRULANMASI (TestFlight'a ilk paket). 24.5'in ekran görüntüleri, trader
beyanı, vitrin metinleri ve App Privacy bundan tamamen bağımsız yürüyor —
"anahtar gelene kadar bekleyelim" demek, gelmediğinde hiçbir şeyin
ilerlememiş olması demektir.

**Cevap gelince:** anahtar indirilirse üç secret girilir
(`APP_STORE_CONNECT_KEY_ID` · `_ISSUER_ID` · `_KEY_P8`) ve 24.2'nin iş
akışı kendiliğinden devreye girer — kodda değişiklik gerekmiyor.

### Support vakası — gönderilen metin

`developer.apple.com/contact` → *App Store Connect* / *Membership and Account*

```
I cannot download any App Store Connect API key. Every attempt fails,
across two different endpoints, over several hours.

Account: Individual, Team ID 8277D85FY9
Browser: Safari on iPadOS

1) Team Keys (Users and Access > Integrations > App Store Connect API)
   Created three keys. Each time the "Download API Key" dialog returned:
     "An error has occurred. Try again later."
   After each failed attempt the Download link disappeared and the key was
   marked as downloaded, making it permanently unusable. First key ID was
   7ARZF96LAK. All three have been revoked.

2) Individual API Key (account profile > Edit Profile)
   Same failure, with a different message:
     "We were unable to supply you with a key. Wait a minute, then try again."
   Key 25Z8S0CFZFPA failed and was replaced by 18QBEN3T2RY4, which is
   currently active but whose Download link has also disappeared.

I have never successfully downloaded a .p8 file. Membership is active and
paid. Please advise, or issue a key I can actually download.
```

**Nerede üretiliyor:** `Individual Keys` sekmesi yalnızca listeliyor.
Üretim yeri: sağ üstteki hesap adı → **Edit Profile** → *Individual API Key*.

### Team key'e dönmeye GEREK YOK

Fark, anahtarın kime bağlı olduğu: team key ekipte kalır, individual key
kişiye bağlıdır ve kişi ekipten ayrılırsa iptal olur. Bu hesap **tek
kişilik bireysel** — ayrılacak kimse yok, kullanıcı hesabın kendisi. Yetki
de aynı: individual key kişinin yetkisini taşıyor, kullanıcı da Account
Holder. **Yani `25Z8S0CFZFPA` indiği an CI'ın ihtiyacı karşılanmış olur;**
Team Keys'e dönmek ancak hesaba ileride başka biri eklenirse anlam kazanır.

### Teşhis: arıza App Store Connect'in GENELİNDE

İki farklı uç (Team Keys + Individual Key), aynı sonuç. Support vakası
açılırsa bu ikisi birlikte yazılmalı — tek uca özgü olmadığının kanıtı.
Yakılan üç Team Key'in ID'si de vakayı hızlandırır (`7ARZF96LAK` + ikisi).

**Hiçbiri işi tıkamadı — 24.2 YAZILDI** (8 Eylül 2026): `mobile-build.yml`'in
`ios` işine TestFlight adımı + `mobile/app/fastlane/` + `Gemfile`. Secret
yoksa adım kendini atlıyor, yani anahtar gelmeden de merge edilebilir.
⚠ **Ama HİÇ KOŞMADI** — "yazıldı" ile "çalışıyor" arasındaki fark burada
gerçek; ilk koşu bir doğrulama turu olacak. Kurulum adımlarının kaynağı
`mobile/docs/test-ortamlari.md` → "TestFlight kurulumu".

⚠ **Yedek yol, KISMİ:** TestFlight'a paket yüklemek için API anahtarı
yerine **uygulamaya özel şifre** (appleid.apple.com → Sign-In and Security)
kullanılabiliyor. Yüklemeyi çözer, **sertifika/profil otomasyonunu
çözmez** — 2FA yüzünden CI'da kırılgan (`FASTLANE_SESSION` süreli).
Apple'ın arızası uzarsa bakılacak, ilk tercih değil.

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

## 7. Açık işler — 9 Eylül 2026'da tazelendi

⚠ **Bu bölüm 8 Eylül'de yazıldığı hâliyle BAYATLAMIŞTI:** "App Privacy" ve
"açıklama/anahtar kelimeler" hâlâ açık iş diye duruyordu, oysa ikisi de aynı
gün §10 ve §9'a YAZILMIŞTI. Dosyanın kendi kuralı ("kaynak burası") tam da
bu yüzden var — özet liste, kaynağın kendi içinde bile bayatlayabiliyor.

| Açık iş | Kimde | Notu |
|---|---|---|
| **Ekran görüntüleri** | Ben | Yol bulundu ve ölçüldü (§13); kalan iş üretim hattı + kompozisyon |
| **Trader adresi** | Sen | Beyanın açık kalan TEK alanı (§2). Gönderim kapısı |
| **API anahtarı `.p8`** | Apple | Support vakası açık (§3); yalnızca 24.2'yi tıkıyor |

**Kapananlar:** App Privacy → §10 · mağaza metinleri → §9 · yaş derecesi →
§5 · demo hesap → §11 · Export Compliance → §12.

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

✅ **KARAR: `T2` (`kelimekitest2`)** — Play'in incelemesine verilen hesabın
aynısı, 24 Ağustos 2026'da seçilmişti ve App Store için de o geçerli
(ROADMAP 24.5 böyle kayıtlı). ⚠ Bu satır 8 Eylül'de *"karar verilmedi"*
diyordu; ROADMAP güncellenirken burası unutulmuştu — **9 Eylül 2026'da
düzeltildi.**

**Neden `T1` DEĞİL:** e-postası geliştiricinin kişisel adresi (aynı gerekçe
ekran görüntüsü çekim kurallarında da geçerli). `T2`'nin durumu üretim
veritabanından ölçülmüştü: doğrulanmış, dondurulmamış, 3 arkadaş, 1 aktif
Canlı oyun, 11 bitmiş oyun — yani incelemecinin göreceği dört ekran da boş
değil.

⚠ İki hesap da `docs/decisions/account-deletion.md` → "ASLA SİLİNMEYECEK
İKİ HESAP" kaydında; şifresinin değişmemesi kuralı oradan da bağlayıcı.

⚠ **Not alanına şunu yazmak faydalı:** uygulamanın hesapsız da (yapay zekaya
karşı) oynanabildiği, girişin yalnızca Canlı oyun/k-lig için gerektiği.
İncelemecinin "neden giriş istiyor" sorusunu baştan kapatır.

---

## 12. Export Compliance — `Info.plist`'e YAZILMALI

✅ **YAPILDI** — `ios/Runner/Info.plist` → `ITSAppUsesNonExemptEncryption`
= `<false/>`. **#490 ile girdi**, yani bu bölüm yazıldığı ANDAN itibaren
bayattı: aynı PR hem anahtarı plist'e koydu hem burada *"YOK, kullanıcı
onayı olmadan eklenmedi"* yazdı. **9 Eylül 2026'da depodan yeniden ölçülüp
düzeltildi** (`Info.plist:54`).

**Cevap neden `false`:** Kelimeki yalnızca standart HTTPS/TLS kullanıyor
(Supabase, Firebase, Brevo uçlarının tamamı) — kendi şifreleme algoritması
yok, Apple'ın muafiyet kapsamına giriyor.

**Kazancı:** anahtar plist'te olduğu için TestFlight'a yüklenen her
derlemede Apple şifreleme sorusunu TEKRAR SORMAZ; cevap pakete gömülü
gelir ve dağıtım beklemez.

⚠ **Bu bir BEYAN, kod tercihi değil.** Bir gün uygulamaya standart TLS
dışında şifreleme girerse (kendi algoritması, özel anahtar saklama)
bu satır YENİDEN değerlendirilmeli — yanlış beyan bir uyum ihlalidir.


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

### ⚙️ BORU HATTI KURULDU — 9 Eylül 2026 (⚠ HENÜZ KOŞMADI)

8 Eylül'ün "kalan iş" listesindeki üç maddenin üçü de yazıldı:

| Parça | Nerede |
|---|---|
| Kare üreten test | `mobile/app/integration_test/store_screenshots_test.dart` |
| Kareyi diske yazan sürücü | `mobile/app/test_driver/integration_test.dart` |
| Simülatörü açıp süren CI | `.github/workflows/ios-screenshots.yml` (iPhone 6.9" + iPad 13", matris) |

**Tahta fixture'ı DEPOYA GİRMİYOR.** Oyunun ortasındaki tahta, gerçek motorla
ve tohumlu rastgelelikle (`Mulberry32`) **koşma anında** üretiliyor — golden
JSON'u asset olarak paketlemek onu mağazaya giden uygulama ikilisine de
sokardı. Tohum/hamle sayısı (`11` / `12`) rastgele değil, Linux'ta motor
koşturularak **seçildi**: 43 taş, skor 114–76 (çekişmeli, oyuncu önde),
tahtada bir joker, merkezdeki X2/X3 kullanılmış ve oyuncunun rafı `KAOEMLE`
— yani ekranda gerçekten oynanabilir bir el duruyor. Taranan yedi tohum
içinde üçünü birden sağlayan tek aday buydu (kimisinde raf tamamen ünlüydü,
kimisinde oyuncu eziliyordu — mağaza karesi olamazdı).

**Neden `mobile-build.yml`'e EKLENMEDİ:** o dosyanın `paths` listesi her
dokunuşta tam bir macOS+Android derlemesi tetikliyor, ve deponun yazılı
kuralı *"yeni ve doğrulanmamış bir adım, çalışan bir adımı asla rehin
almamalı"*. Ekran görüntüsü ayda bir gereken bir iş; kendi iş akışında
duruyor ve **hiçbir secret'a ihtiyacı yok** (kareler sahte servislerle
çiziliyor, ağa çıkılmıyor).

⚠ **"YAZILDI" ≠ "ÇALIŞIYOR" — bu depoda bu farkın bedeli defalarca ödendi.**
Boru hattı Linux'ta doğrulanamaz (macOS+simülatör ister); analiz temiz ve
mevcut testler yeşil, ama **ilk CI koşusu bir DOĞRULAMA turudur.** İş akışı
bu yüzden ölçümü kendisi yapıyor: her PNG'nin piksel ölçüsü `sips` ile
okunup Apple'ın istediği ölçüyle karşılaştırılıyor, tutmazsa iş DÜŞÜYOR
(artefakt yine de yükleniyor, elde inceleyecek dosya kalsın diye).

### ✅ DOĞRULANDI — run #1, 9 Eylül 2026 (iPhone yarısı)

**iPhone 6.9" işi baştan sona geçti** ve bununla birlikte zincirin her
halkası kanıtlandı: `flutter drive` simülatörde koştu, `integration_test`
gerçek iOS çalışma zamanında ekranı çizdi, `takeScreenshot` sürücüye ulaştı,
sürücü PNG'yi diske yazdı ve **ölçüm adımı geçti** — yani kare Apple'ın
istediği **tam `1320×2868`**. Artefakt gerçek: `kelimeki-store-
screenshots-iphone-6.9`, 1,6 MB. Seçilen cihaz `iPhone 17 Pro Max`.

⚠ **Ölçüm adımı burada bir SÜS DEĞİL:** iş ancak `sips` iki boyutu da
doğrularsa yeşile dönüyor, yani "kare üretildi" ile "kare KULLANILABİLİR"
aynı koşuda ayrışıyor. Yanlış ölçüde bir PNG sessizce mağazaya gitmez.

✅ **iPad yarısı da DOĞRULANDI — run #2:** iki iş de yeşil, artefaktlar
`iphone-6.9` 1,6 MB + `ipad-13` 1,77 MB, ikisinin de ölçüm adımı geçti —
yani `2064×2752` de tam tutuyor. **Boru hattının tamamı çalışıyor.**

**iPad yarısı run #1'de düşmüştü — ve kapı doğru çalıştı.** Sabit bir cihaz
adı yerine aday listesi kullanıldığı için hata *"device not found"* diye geç
ve okunmaz değil, **40 saniyede** net bir mesajla ("aday simülatörlerin
hiçbiri yok") ve mevcut simülatör dökümüyle geldi. Ölçüm: runner'da iPad
**M4 değil M5** duruyor (`iPad Pro 13-inch (M5)`). Liste düzeltildi;
Xcode sürümü ilerledikçe ad yine kayacağı için tek ad değil LİSTE tutuluyor.

### Kompozisyon bulguları — 9 Eylül 2026, kare GÖZLE incelendi

CI artefaktı indirmek kimlik doğrulaması istiyor (ajan indiremiyor), ama
aynı ekran aynı tohumla YEREL olarak da çizdirildi — §13'ün başında elenen
widget-testi yolu tam da bunun için *"iç doğrulama aracı olarak değerli"*
diye saklanmıştı. Önizleme mağaza karesi DEĞİL (Skia ≠ Impeller, iOS kabuğu
yok), ama kompozisyon sorularını cevaplıyor.

**İyi olanlar:** taşma yok (`takeException()` null), fontlar gerçek çizildi,
iki bölgenin dış hattı da net (oyuncu camgöbeği / YZ kırmızı), merkezdeki
X2 filigranı ve sarı bonus bölgesi görünüyor, jokerin **kırmızı `0`**'ı
tahtada okunuyor, mesaj satırı oyunu canlı gösteriyor (*"Yapay Zeka 'KEFE'
oynadı. +22 puan."*), raf `KAOEMLE` ve "TORBA 43".

**⬜ KARAR GEREKTİREN İKİ ŞEY:**

1. **Karenin alt ~%20'si BOŞ.** Butonların altında geniş bir beyaz alan
   kalıyor. Bu bir hata değil — uygulama uzun bir telefonda gerçekten böyle
   görünüyor — ama mağaza karesinde ölü alan. Bu, §13'ün *"çerçeve/başlık
   metni eklensin mi"* sorusunu somutlaştırıyor: **başlık metni için doğal
   bir yer var.** Alternatif, kareyi olduğu gibi bırakmak (Apple ham kareyi
   kabul ediyor).
2. **Başlıkta `GİRİŞ` butonu görünüyor**, yani oturum açılmamış hâl. Play
   turunun kuralı *"test hesabıyla çek"* diyordu. Ağa çıkmadan çözülebilir:
   `AuthService.fake(user:, profile:)` sahte bir oturum kabul ediyor, yani
   başlıkta `GİRİŞ` yerine avatar/kullanıcı adı çizdirilebilir — secret ya
   da gerçek hesap gerekmeden. Karar: kare girişli mi görünsün, misafir mi?

### Kalan iş

- **Kalan beş kare.** Bugün yalnızca 1. kare (oyun ekranı, oyunun ortası —
  listenin *en önemli* karesi) üretiliyor. 2-6 aynı desenle eklenecek;
  Kurulum/Skor Kartı gibi ekranlar depolama + sahte uç kurulumu istiyor
  (altyapı `test/support/fake_*.dart`'ta hazır, her ekran için kurulum
  gerekiyor)
- **Kompozisyon:** çerçeve/başlık metni eklenip eklenmeyeceği (Apple ham
  kareyi de kabul ediyor)
