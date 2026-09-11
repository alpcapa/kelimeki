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
| App Store Connect API | Key ID `7ARZF96LAK`, **Admin** | ✅ `.p8` **9 Eylül 2026 akşamı bir Mac'ten indirildi** ve üç secret girildi; zincir #614/#616'da uçtan uca koştu (§3) |
| DSA trader status | Beyan ✅ (9 Eylül 2026) · **doğrulama ✅ (10 Eylül 2026, 22:21)** | ✅ Apple doğruladı, bilgi AB'de App Store'da yayında — **gönderim kapısı DÜŞTÜ** (§2) |

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

## 2. DSA trader status — ✅ **DOĞRULANDI (10 Eylül 2026)**

✅ **KAPANDI — Apple doğrulamayı bitirdi.** `destek@kelimeki.com`'a düşen
e-posta (10 Eylül 2026, 22:21 · `appstoreconnect-noreply@apple.com` ·
*"Your trader contact information was verified"*): *"We successfully
verified your trader contact information for the Digital Services Act
compliance. Your information is now live on the App Store in the European
Union."* Yani beyan bilgileri AB'de App Store'da **yayında**, ve aşağıdaki
gönderim kapısı **düştü**. Doğrulama süresi ölçüldü: beyan 9 Eylül →
doğrulama 10 Eylül, **~1 gün**.

⚠ Durum alanını da teyit etmek isteyen için kontrol yeri değişmedi:
Business → Agreements → **Compliance** → `Digital Services Act`.

**Aşağısı doğrulama ÖNCESİNİN kaydı** (beyanın nasıl/neden öyle
doldurulduğu, bir gün beklenmesinin gerekçesi):

**Durum (9 Eylül 2026, Console'dan OKUNDU):**
Business → Agreements → **Compliance** → `Digital Services Act` ·
27 Countries or Regions · Last Updated `Sep 9, 2026` · Status **`In Review`**.

Yani **beyan tamamlandı, Apple doğruluyor.** ⏳ **Gönderim kapısı HÂLÂ
AÇIK** — kapanması Apple'ın incelemeyi bitirmesine bağlı ve o bizde değil.

⚠ **İKİ ADIM AYRI, ve bu satır bir kez YANLIŞ yazıldı (aynı gün
düzeltildi).** Beyanı yapmak yetmiyor; Apple ayrıca doğruluyor.
Kayıt önce *"ikisi de bitti"* diye yazılmıştı — kullanıcının sözlü
bildirimine dayanarak. **Console'un kendi STATUS alanı `In Review`
diyordu.** Ders, deponun `curl`la sha okuma refleksinin aynısı, başka bir
yüzeyde: **bir kapının kapandığını söyleyen tek kanıt, o kapının kendi
durum alanıdır** — sözlü bildirim değil, ekran görüntüsündeki satır.

**Aşağısı SÜREÇ KAYDIDIR** — neden bir gün beklendiği, hangi bilginin neden
seçildiği. Karar geriye dönük tartışılmıyor; ileride *"bu bilgi neden
açıkta"* sorulduğunda cevabı burada.

**Öncesi:** 8 Eylül 2026'da pencere açıldı ve bilinçli olarak **Cancel**
edildi.

### Karar: **trader olarak beyan edilecek** (AB dağıtımı korunacak)

Ama **bugünkü telefon numarasıyla değil.** Sıra şu:

1. ✅ **Yedek hat hazır** (kullanıcı bildirdi, 9 Eylül 2026) — beyanı
   bekleten iki şeyden biri düştü
2. Business → Agreements → Compliance → **"I'm a trader under the DSA"**
3. Üç alan girilecek: **adres · telefon · e-posta**
4. Apple doğrulayacak → AB dağıtımı açılacak

✅ **ÜÇ ALANIN ÜÇÜ DE HAZIR** (9 Eylül 2026): e-posta `destek@kelimeki.com`,
telefon yedek hat, adres kullanıcıda kararlaştırıldı. **Beyanın önünde
teknik bir engel kalmadı** — sıradaki adım Console'da tek oturumluk bir iş.

⚠ **Adres ürün sayfasında yayınlanacak ve geri alınamaz** (§2'nin başındaki
gerekçe). Kullanıcı bunu bilerek karar verdi; bu satır kararı tekrar açmak
için değil, ileride *"bu neden açıkta"* diye sorulduğunda cevabı olsun diye
duruyor.

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
| Adres | *kullanıcıda kayıtlı* | ✅ **KARARLAŞTIRILDI** (9 Eylül 2026). ⚠ Değeri bu dosyaya YAZILMIYOR — telefonun kuralının aynısı, depo public. Ev adresi zorunlu DEĞİL — bu alan üyelikteki adresten ayrı (*"won't impact the contact details for your Apple accounts or memberships"*). Posta kutusu / sanal ofis olur, ama Apple doğruladığı için gerçek olmalı |

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

### ⚠ "Edit Legal Entity" uyarısı bizi TIKAMIYOR (9 Eylül 2026, ölçüldü)

Business → Agreements sayfasında şu banner duruyor ve trader beyanını
arayan kişiyi yanlış yere çekiyor:

> *"To offer apps or other in-app purchases, you must update your legal
> entity information **prior to signing the Paid Apps Agreement**."*

**Şart, cümlenin kendi sonunda kapsanıyor: Paid Apps Agreement.** Bizim
kararımız onu hiç imzalamamak (§0) — uygulama ücretsiz, IAP yok, satır
`New` kalacak. Aynı tablodaki belirleyici satır zaten yeşil: **Free Apps
Agreement → `Active`, Sep 8 2026 – Sep 8 2027.** Ücretsiz dağıtımı kapatan
agreement odur.

⚠ **Yani "Edit Legal Entity" tıklanacak link DEĞİL.** Trader beyanı AYNI
sayfanın altındaki **`Compliance`** bölümünde:
*Compliance → Complete Compliance Requirements → "I'm a trader under the
DSA"* → adres · telefon · e-posta.

### ✅ GÖNDERİM KAPISI — DÜŞTÜ (10 Eylül 2026)

Kural: **"Trader beyanı + DOĞRULAMASI tamamlanmadan uygulama incelemeye
gönderilemez."** Beyan 9 Eylül ✅, doğrulama **10 Eylül 22:21 ✅** (yukarıdaki
e-posta). Madde gönderim öncesi kontrol listesinden ÇIKTI.

Apple'ın inceleme süresi artık ÖLÇÜLDÜ: **~1 gün** (9 Eylül beyan → 10 Eylül
doğrulama). Tek ölçüm, garanti değil.

### ⚠ Play tarafı aynı beyanı BEKLİYOR — ve artık bir referans var

DSA aynı şeyi Google Play'den de istiyor. Kelimeki Play'de kapalı testte
olduğu için henüz tetiklenmemiş olabilir; **üretime çıkınca gelecek.**
Depoda Play tarafında trader beyanı kaydı **yok**.

**İki mağazada AYNI bilgi beyan edilmeli** — farklı bilgi vermek açıklaması
zor bir tutarsızlık. Apple tarafı 9 Eylül 2026'da dolduruldu, yani
**kanonik üçlü artık orada**: Play'in formu geldiğinde bilgi yeniden karar
verilmez, App Store Connect'ten okunup birebir kopyalanır. (Apple'ın
doğrulaması sürerken de bu geçerli — kopyalanacak olan GİRİLEN bilgi,
doğrulamanın sonucu değil.)

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

### ✅ ÇÖZÜLDÜ — 9 Eylül 2026 akşamı: `.p8` bir **Mac'ten** indirildi

**Anahtar elde.** Kullanıcı aynı hesapla, eşinin **macOS** makinesinden
denedi ve indirme İLK SEFERDE başarılı oldu. Support hiç yanıt vermeden
çözüldü.

**ÖLÇÜM — arıza istemci/platform tarafındaydı, Apple'ın sunucusunda değil:**

| Ortam | Sonuç |
|---|---|
| iPadOS Safari (normal) | ✗ (defalarca) |
| iPadOS Safari (özel sekme) | ✗ |
| **macOS** | ✅ **ilk denemede** |

⚠ **Ama "iPad hiç indiremezdi" diye YAZILAMAZ:** aradan saatler geçti,
Apple'ın sessizce düzeltmiş olma ihtimali elenemez. Elimizdeki tek kesin
şey yukarıdaki tablo. **Yine de karar için yeterliydi ve doğru öneriyi
işaret etti:** "iPad'de Chrome dene" DEĞİL, "gerçekten farklı bir platform
dene". iPad'de tüm tarayıcılar WebKit kullandığından Chrome aynı motoru
koşturacaktı; macOS hem farklı motor/sürüm hem farklı indirme yığını.

**Sıradaki iki temizlik adımı (kullanıcıda):**
1. **Support vakasını kapat** — çözüldüğünü yaz. Aksi halde günler sonra
   bir geri arama gelir ve kimse neden arandığını hatırlamaz.
2. Vaka kapandıktan sonra **artık kullanılmayan bireysel anahtarı revoke
   et** — "inceleyebilesiniz diye bıraktım" gerekçesi düştü. Altı Team Key
   zaten revoke.
3. ⚠ **`.p8`'in Mac'teki kopyasını SİL.** Başkasının makinesi ve dosya
   İndirilenler'de duruyor; anahtar Admin erişimi taşıyor.

⚠ **Anahtar bir kez sohbetten geçti.** Rotasyon artık ucuz (çalışan bir
indirme yolu var: aynı Mac), yani hesabın hijyeni önemsenirse ileride yeni
bir anahtar üretip bunu revoke etmek tek adımlık iş.

### Önceki durum kaydı — Support'tan yanıt yoktu

⚠ **Bu satır bir kez "Support yanıt verdi" diye yazıldı ve YANLIŞTI**
(aynı akşam düzeltildi). Sebep tam da aşağıda uyarısı yazılı olan şey:
gelen kutusundaki *"App Store Connect API Access Request Approved"* maili
yanıt sanıldı; o mail **8 Eylül** tarihli, üyelik günündeki ilk erişim
onayı. **Vaka açılalı ~18 saat, hiçbir dönüş yok.**

Ders, deponun kendi refleksinin bir başka biçimi: bir kutudaki maili
"yanıt" saymadan önce **TARİHİNE** bak — konu başlığı doğru göründüğünde
tarih okunmuyor.

**Altı Team Key yandı, hepsi revoke** (Console'dan okundu, 17:26):

| Ad | Key ID | Revoke |
|---|---|---|
| Kelimeki CI 5 | `55F9XUK348` | 9 Eylül |
| Kelimeki CI 4 | `YQVJZCH5UF` | 9 Eylül |
| Kelimeki CI 3 | `6H2WY5JZ7W` | 9 Eylül |
| Kelimeki CI 3 | `FDMW75TR54` | 8 Eylül |
| Kelimeki CI 2 | `45AH6AD7U4` | 8 Eylül |
| Kelimeki CI | `7ARZF96LAK` | 8 Eylül |

⚠ Bu bölüm bir süre *"üç Team Key yakıldı"* diyordu — sayı ikiye katlandı.
Gizli değil: özel anahtar olmadan bir Key ID işe yaramıyor ve hepsi zaten
revoke; kaydedilmelerinin sebebi Support'un vakayı izleyebilmesi.

**Yeni denemeler (kullanıcı, 9 Eylül):** birkaç kez, **incognito dahil** —
hepsi başarısız.

⚠ **"API Access Request Approved" maili bugünkü yanıt DEĞİL.** Zoho'daki o
mail **8 Eylül** tarihli, yani üyelik günündeki ilk erişim onayı. Arıza
ondan sonra başladı; ikisini karıştırmak *"erişim onaylandı, o hâlde
çalışıyor olmalı"* diye yanlış bir sonuca götürür.

### ⚠ "Başka tarayıcı dene" — iPad'de bu GERÇEK bir değişiklik değil

Genel arama sonuçları Chrome önermeye eğilimli, ama **iPadOS'ta tüm
tarayıcılar WebKit kullanmak zorunda** — iPad'deki Chrome, Safari'nin
motoru + farklı bir kabuktur. (AB'de DMA sonrası alternatif motor istisnası
var; Türkiye kapsam dışı.) *(Platform kuralı; bu depoda ÖLÇÜLMEDİ.)*

Yani öneri masaüstü için yazılmış. Tamamen değersiz de değil: indirme/dosya
kaydetme katmanı farklı bir uygulama sandbox'ı, o yüzden hata "dosyayı
kaydet" adımındaysa değişebilir. Hata sunucu tarafındaysa değişmez.

### ✅ ÖNCE BEDAVA TEŞHİS — anahtar yakmadan

Her deneme bir anahtar yaktığından, sıradaki adım yeni bir anahtar DEĞİL:

> **Portaldan başka bir şey indir** — mevcut bir provisioning profile,
> bir sertifika, herhangi bir dosya.

| Sonuç | Anlamı | Sıradaki adım |
|---|---|---|
| İniyor | Sorun indirme katmanında değil, **anahtar üretmeye özgü** | Tarayıcı değiştirmek işe yaramaz; bekle ya da yolu değiştir (aşağı) |
| İnmiyor | Sorun tarayıcı/indirme tarafında | Gerçekten FARKLI bir cihaz (masaüstünde gerçek Chrome/Firefox — farklı motor VE farklı indirme yığını) |

⚠ **SİSTEM DURUMU YEŞİL — kullanıcı baktı, 9 Eylül 2026.** Bu, bir
teoriyi ZAYIFLATIYOR: Google'ın önerdiği *"Apple'ın anahtar üretim
sunucusunda geçici arıza, birkaç saat bekle"* açıklaması artık daha az
olası. **Ama ELEMİYOR** — durum sayfasının çözünürlüğü kaba, anahtar üretme
ucunun (`/iris/v1/subscriptionKeys`) kendi satırı yok; bildirilmemiş bir
hata yeşil bir tabloyla bir arada durabilir.

**Pratik sonucu: BEKLEMEK artık zayıf bir strateji.** Altı anahtar, iki
ayrı uç, ~24 saat, birden çok tarayıcı bağlamı (incognito dahil), ilan
edilmiş bir arıza YOK **ve yazılı vakadan 18 saatte dönüş yok.**

⚠ **11 Eylül eşiği ÖNE ÇEKİLDİ.** O eşik *"yazılı vaka birkaç iş günü
sürebilir"* varsayımıyla konmuştu; yeşil durum tablosu o varsayımı
desteklemiyor (ortada bekleyecek ilan edilmiş bir arıza yok). Sıradaki
adım **vakayı telefon geri aramasına yükseltmek** —
`developer.apple.com/contact` üzerinden arama talebi. Mükerrer vaka DEĞİL,
mevcut vakanın yükseltilmesi.

⚠ **Ajan durum sayfasını okuyamıyor** — `developer.apple.com` 302 ile
`www.apple.com`'a yönlendiriyor ve oraya egress proxy izin vermiyor
(9 Eylül 2026'da denendi). Bu satırın kaynağı kullanıcı gözlemi.

### 🔑 API anahtarı İMZALAMA için zorunlu DEĞİL — otomasyon için zorunlu

Arıza uzarsa 24.2 anahtarsız da kurulabilir. Zincir:

1. `openssl` ile özel anahtar + **CSR** üret (herhangi bir yerde, Mac
   gerekmez).
2. CSR'ı portala yükle → **dağıtım sertifikası** indir (`.cer`).
3. Özel anahtarla birleştirip `.p12` yap → GitHub secret.
4. Provisioning profile'ı portaldan **elle** indir → secret.
5. TestFlight'a yükleme: **uygulamaya özel şifre** (`appleid.apple.com` →
   Sign-In and Security).

**Bedeli:** `fastlane match`in otomatiği gider — profil yılda bir, sertifika
üç yılda bir ELLE yenilenir. **Kazancı:** gönderim Apple'ın bu arızasına
bağlı kalmaz. ⚠ Bu yol YAZILMADI, yalnızca kayda geçti; seçilirse
`Fastfile`ın `match` satırı ve iş akışının secret listesi değişir.

### Önceki durum kaydı — 9 Eylül 2026, 15:50: yanıt YOK

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
| `APP_STORE_CONNECT_KEY_ID` | Key ID (`.p8` dosya adındaki `AuthKey_XXXXXXXXXX` kısmı) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID — **anahtara değil HESABA ait**, tüm anahtarlarda aynı. Yeri: Users and Access → Integrations, anahtar listesinin ÜSTÜ |
| `APP_STORE_CONNECT_KEY_P8` | `.p8`'in tam içeriği (BEGIN/END satırları dahil) |

### 24.2 KURULUM DURUMU — neyin YAPILDIĞI (değerler değil, DURUM)

⚠ **Bu bölüm 9 Eylül 2026'da, bir eksiklik yüzünden eklendi.** Dokümanlar
neyin GEREKTİĞİNİ yazıyordu (`test-ortamlari.md` → secret listesi,
`Matchfile` → depo adı) ama neyin YAPILDIĞINI hiçbir yer tutmuyordu. Sonuç:
kullanıcıya bir gün önce birlikte hallettiğimiz bir şey (`kelimeki-
certificates` deposu açıldı mı) tekrar soruldu. **Değerler gizli, DURUM
değil** — durum kaydı olmayınca her oturum aynı soruları baştan sorar.

| Parça | Durum |
|---|---|
| `alpcapa/kelimeki-certificates` (private, boş) | ✅ **8 Eylül 2026'da açıldı** |
| `MATCH_GIT_TOKEN` (fine-grained, yalnız o depo, Contents: R/W) | ✅ 8 Eylül 2026 |
| `MATCH_PASSWORD` | ✅ 8 Eylül 2026 — ⚠ ilk başarılı koşudan SONRA sabittir |
| `APP_STORE_CONNECT_KEY_ID` | ✅ 9 Eylül 2026 |
| `APP_STORE_CONNECT_KEY_P8` | ✅ 9 Eylül 2026 |
| `APP_STORE_CONNECT_ISSUER_ID` | ✅ 9 Eylül 2026 (üçünün en son gireni — aşağı bkz.) |
| **İlk koşu (doğrulama turu)** | ✅ **TAMAMLANDI** — #604 `match`te düştü (aşağı bkz.), zincir #614'te bitti, doğru build numarası #616'da kanıtlandı: TestFlight'ta `1.0.9 (616)` · Complete |

#### İlk koşunun sonucu — Apple tarafı ÇALIŞIYOR, git tarafı tıkalı

**Kanıtlanan:** fastlane özetinde `app_store_connect_api_key` adımı
**BAŞARILI**. Yani `.p8` + Key ID + Issuer ID üçlüsü doğru ve Apple onları
kabul etti — günün asıl belirsizliği kapandı.

**Düşen:** `match`in İLK işi, sertifika deposunu klonlamak:

```
remote: Write access to repository not granted.
fatal: unable to access 'https://github.com/alpcapa/kelimeki-certificates.git/':
       The requested URL returned error: 403
```

Yani sorun Apple'da değil, **`MATCH_GIT_TOKEN`'da**.

✅ **KÖK SEBEP BULUNDU (9 Eylül 2026, token sayfasından okundu):** token
(`kelimeki-match`) oluşturulmuş ama **kapsamı BOŞ kalmış** — sayfa iki
yerde birden şunu diyordu:

> *Repository access:* **"This token does not have access to any repositories."**
> *Repository permissions:* **"This token does not have any repository permissions."**

Fine-grained token'larda depo seçimi ve izinler AYRI AYRI seçilir; ikisi de
boş bırakılırsa token hiçbir şeye erişemez ve git 403 verir. Düzeltme:
*Access on \<hesap\>* → **Edit** → *Only select repositories* →
`kelimeki-certificates`; *Repository permissions* → **Contents: Read and
write** (`Metadata: Read-only` kendiliğinden eklenir).

⚠ **"Regenerate token"a BASMA** — izin düzenlemek token DEĞERİNİ
değiştirmez, yani `MATCH_GIT_TOKEN` secret'ına dokunmak gerekmez.
Regenerate edilirse değer değişir ve secret da güncellenmek zorunda kalır.

Aşağıdaki liste, kök sebep bulunmadan önce hangi üç şeye bakıldığının
kaydı (bir dahaki sefere aynı sırayla bakılır):

| Olasılık | Kontrol |
|---|---|
| Token'ın **depo seçimi** `kelimeki-certificates`i içermiyor | Fine-grained token → *Repository access* → o depo AÇIKÇA seçili mi (yalnızca `kelimeki` seçiliyse bu hatayı verir) |
| İzin **Read-only** | *Permissions* → **Contents: Read and write** (match yazacak) |
| Token süresi dolmuş / depo adı farklı | Token'ın expiry'si; depo adı birebir `kelimeki-certificates` mi |

⚠ **Hata mesajı YANILTICI: 403 "write access" bir KLONLAMA sırasında
çıkıyor.** Klonlamak okuma iznine yeter; GitHub, token'ın o depoya hiç
erişimi olmadığında da (ve depo yokken de) bu mesajı üretiyor — yani
"yazma iznini aç" ile "depoyu göremiyor" aynı hataya düşüyor. Bu yüzden
kontrol listesi yalnızca izne değil, **depo seçimine ve adına** da bakıyor.

#### İkinci koşu (#606) — dört adım daha ilerledi, anahtarlıkta düştü

Token'ın kapsamı düzeltildikten sonra `match` şunları GEÇTİ:

```
Cloning remote git repo...                              ✅ token düzeltmesi tuttu
Checking out branch master...                           ✅
🔓 Successfully decrypted certificates repo             ✅ MATCH_PASSWORD doğru
Creating authorization token for App Store Connect API  ✅ Apple kimliği yine tamam
Couldn't find a valid code signing identity... creating one for you now
[!] Could not locate the provided keychain. Tried: …/kelimeki-ci …
```

**Kök sebep:** iş akışı `MATCH_KEYCHAIN_NAME="kelimeki-ci"` diyordu ama o
anahtarlığı **kimse oluşturmuyordu** — taze bir macOS runner'ında öyle bir
keychain yok. `match` sertifikayı bir anahtarlığa kurmak zorunda ve orada
düştü.

⚠ **Hata GEÇ çıkıyor ve bu yanıltıcı:** git klonlama, şifre çözme ve Apple
kimlik doğrulamasının ÜÇÜ DE geçtikten sonra patlıyor. Yani "match düştü"
demek "kimlik bilgileri yanlış" demek değil; log'da hangi satıra kadar
gelindiğine bakmak şart.

**Düzeltme:** `Fastfile`'ın başına **`setup_ci`** — fastlane'in tam bu iş
için yazdığı action: geçici anahtarlığı oluşturur, açar, varsayılan yapar,
kilit zaman aşımını kaldırır ve `MATCH_KEYCHAIN_NAME`/`_PASSWORD`i kendisi
ayarlar. İş akışındaki elle export'lar **kaldırıldı** — dursalardı
setup_ci'nin anahtarlığını ezip aynı hatayı geri getirirlerdi.
⚠ `MATCH_PASSWORD` AYRI bir şey (depo şifreleme parolası) ve duruyor.

#### Üçüncü koşu (#608) — `match` GEÇTİ, `build_app` yol hatasında düştü

```
| 1 | default_platform          | 0 |
| 2 | setup_ci                  | 0 |
| 3 | app_store_connect_api_key | 0 |
| 4 | match                     | 8 |   ← 💥 YOK
MATCH_PROVISIONING_PROFILE_MAPPING | {"com.kelimeki.kelimeki" => "match AppStore …"}
```

✅ **Sertifika üretildi ve depoya yazıldı.** `setup_ci` doğru düzeltmeydi;
zincirin git/şifre/Apple/anahtarlık dörtlüsü artık tamamen kanıtlı.

❌ Yeni durak `build_app`: `Workspace file not found at path
'…/mobile/app/Runner.xcworkspace'`.

**Kök sebep — fastlane yolları NEREYE göre çözüyor:** `fastlane/` klasörünü
İÇEREN dizine, yani burada `mobile/app`e. Flutter örneklerinin çoğunda
`fastlane/` `ios/`un altında durur ve yol `"Runner.xcworkspace"` diye
yazılır; bu depoda `fastlane/` bir üst dizinde olduğu için **`ios/` öneki
şart**. Aynı hata `output_directory`de TERS yöndeydi (`"../build/…"` →
`mobile/build`, oysa artefakt adımı `mobile/app/build/ios/ipa`ya bakıyor).

Aynı turda `export_options.provisioningProfiles` de AÇIKÇA yazıldı — `match`
eşlemeyi ortama koyuyor ve gym onu genelde kendi okuyor, ama bu zincirde her
deneme bir macOS koşusu; imzalama turunu tahmine bırakmamak daha ucuz.

#### Dördüncü koşu (#610) — yollar düzeldi, imzalama kaldı

`build_app` bu sefer gerçekten koştu (66 sn) ve `xcodebuild` şunu dedi:

```
ios/Runner.xcodeproj: error: Signing for "Runner" requires a development team.
```

**Kök sebep:** depodaki proje `flutter create` çıktısı olduğu gibi duruyor —
`CODE_SIGN_STYLE = Automatic` ve **hiçbir yerde `DEVELOPMENT_TEAM` yok**
(depodan doğrulandı). `match` ise ELLE imzalama için profil kuruyor; ikisi
birbirini bulamıyor.

**Düzeltme:** `build_app`ten önce `update_code_signing_settings` — projeyi
KOŞMA ANINDA elle imzalamaya çeviriyor (takım kimliği, profil adı,
`Apple Distribution` kimliği).

⚠ **Değişiklik repoya COMMIT EDİLMİYOR, bilinçli:** `project.pbxproj`a takım
kimliği yazmak yerel derlemeleri ve `flutter build ios --no-codesign`
adımını da bağlar, oysa imzalama YALNIZCA bu lane'in derdi. CI'ın geçici
kopyasında değiştirip bırakmak doğru sınır.

⚠ **Profil adı ELLE YAZILMIYOR:** `match` kurduğu profili
`MATCH_PROVISIONING_PROFILE_MAPPING`e koyuyor ve adlandırma kuralı onun;
`Fastfile` oradan okuyor. Elle yazılsaydı match bir gün adlandırmayı
değiştirdiğinde sessizce ayrışırdı. Paket kimliği ve takım kimliği de tek
bir sabitten geliyor (üç yerde birden kullanılıyorlar).

### ✅ 24.2 DOĞRULANDI — koşu #614, 9 Eylül 2026: paket Apple'a YÜKLENDİ

**Zincir baştan sona koştu.** `upload_to_testflight` 6 dakika sürüp
`success` döndü — #612'de aynı adım reddedilirken `exit 1` vermişti, yani
bu bir "sessizce atlandı" değil, gerçek bir yükleme.

**Paketin künyesi:** sürüm **1.0.9**, **build 1** — ⚠ *bu cümle önce
"build 614" diyordu ve YANLIŞTI; kullanıcının TestFlight ekran görüntüsü
düzeltti (aşağıdaki post-mortem).* Tasarım gereği `--build-number` = koşu
numarasıdır (TestFlight aynı numarayı ikinci kez kabul etmiyor), ama o
bayrak arşive ULAŞMAMIŞTI.

Böylece 24.2'nin — *"Mac'siz imzalama + TestFlight"* — **iddiası kanıtlandı:**
geliştiricinin elinde Mac yokken, tamamen CI'dan, imzalı bir iOS paketi
üretilip App Store Connect'e yüklenebiliyor.

✅ **TESTFLIGHT'TA GÖRÜLDÜ (9 Eylül 2026, kullanıcının ekran
görüntüsü):** App Store Connect → Kelimeki → TestFlight → iOS Builds →
**1.0.9**, tek derleme, durum **"Ready to Submit"**, "Expires in 90 days".
Yani Apple işlemeyi bitirdi ve paketi kabul etti — 24.2 artık gerçekten
uçtan uca doğrulanmış.

⚠ **"Yüklendi" ≠ "TestFlight'ta hazır".** İş akışı
`skip_waiting_for_build_processing: true` ile koşuyor (macOS runner dakikası
yakmamak için, bilinçli); Apple'ın işlemesi 10-40 dakika sürüyor. **Kanıt
CI'ın yeşili değil, App Store Connect → TestFlight'ta beliren derleme** —
bu depoda "yeşil ≠ canlıda" kuralının iOS'taki karşılığı.

**Zincirin tamamı, tek tek kanıtlanmış hâliyle:**

| Halka | Hangi koşuda kanıtlandı |
|---|---|
| Sertifika deposuna git erişimi | #606 (token kapsamı düzeltildikten sonra) |
| Depo şifresinin çözülmesi (`MATCH_PASSWORD`) | #606 |
| App Store Connect kimlik doğrulaması | #606 |
| Anahtarlık (`setup_ci`) | #608 |
| Sertifika + profil üretimi → depoya yazma | #608 |
| `build_app` yolları | #610 → #612 |
| İmzalama (`update_code_signing_settings`) | #612 (27 MB `.ipa`) |
| Apple bundle doğrulaması (iPad yönelimleri) | #614 |
| **`upload_to_testflight`** | **#614** ✅ |

**Altı koşu, sekiz ayrı arıza.** Hiçbiri ötekini maskelemedi çünkü her tur
bir öncekinden daha ileri gitti — adım sırası kararının (TestFlight en
sonda) asıl kazancı bu oldu.

#### ⚠ Post-mortem: yeşil koşu YANLIŞ numarayı yükledi (#614, 9 Eylül 2026)

**Belirti:** TestFlight'ta derleme göründü ama BUILD sütunu **1** yazıyordu,
614 değil. CI yeşildi, fastlane `success` demişti, artefakt gerçekti — hata
hiçbir log satırında GÖRÜNMÜYORDU.

**Kök sebep, tek cümle:** `flutter build ios` her koşuşunda
`ios/Flutter/Generated.xcconfig`i **sıfırdan yazıyor**, ve iş akışı o komutu
İKİ KEZ çağırıyor:

| Adım | Bayrak | Yazdığı `FLUTTER_BUILD_NUMBER` |
|---|---|---|
| "iOS derle" (release, cihaz) | `--build-number=614` | 614 |
| "iOS simülatör derlemesi" (Appetize) | *(yok)* | **1** ← `pubspec.yaml`ın `1.0.9+1`'i |
| fastlane `build_app` | — | dosyadan okur → **1** arşivlenir |

`Info.plist`in `CFBundleVersion`ı `$(FLUTTER_BUILD_NUMBER)`, yani numarayı
belirleyen şey pubspec de, ilk komut da değil — **fastlane'den önceki SON
`flutter build`**. Simülatör adımı bilerek Appetize'dan önce duruyor
(yukarıdaki sıra kararı) ve tam bu yüzden en son yazan o oldu.

**Neden pahalı bir hata:** TestFlight aynı build numarasını İKİNCİ kez kabul
etmiyor. Her koşu `1` yükleseydi, ikinci yükleme *"bundle version must be
higher"* ile reddedilirdi — yani zincir bir kez çalışıp bir daha hiç
çalışmayan bir tesisat olurdu. Bugünkü tek yükleme için zarar yok (`615 > 1`).

**Düzeltme, iki katman:**

1. Simülatör derlemesi de aynı `--build-number`ı alıyor — iki komut aynı
   dosyayı yazdığı sürece hangisinin son yazdığı önemsizleşiyor.
2. **fastlane'e girmeden ÖNCE dosya okunup doğrulanıyor** (`::error::` +
   `exit 1`). Katman 1 tek başına yeterdi ama bu hatanın sınıfı "sessiz":
   ileride araya üçüncü bir `flutter build` girerse yine kimse fark etmez.
   Kontrol o sınıfı gürültülü yapıyor.

**Ders (bu depoda tekrarlayan bir desen):** *"yükledim"* ile *"doğru şeyi
yükledim"* ayrı iddialar, ve ikincisi CI'ın yeşilinden GÖRÜNMÜYOR. Kanıt
yine ürünün kendi künyesinden okundu — web'de `curl … | grep
kelimeki-build`in iOS'taki karşılığı TestFlight'ın BUILD sütunu.

**Düzeltmenin ilk koşusu — #616 (9 Eylül 2026):** iş akışı dosyası `paths`
listesinde olduğu için merge kendiliğinden tam boru hattını tetikledi, yani
düzeltme gerçek bir yüklemeyle sınandı. Sonuç:

- **Kontrol GEÇTİ, ve boşuna geçmedi:** `grep` bir şey bulamasa `okunan` boş
  kalır ve karşılaştırma düşerdi; geçmesi dosyanın gerçekten `616` dediği
  anlamına geliyor.
- `build_app` 200 sn → `Runner.ipa` (27 MB), `upload_to_testflight` 90 sn →
  *"Successfully uploaded the new binary to App Store Connect"*.

✅ **KESİN KANIT ALINDI (9 Eylül 2026 22:09, kullanıcının ekran
görüntüsü):** App Store Connect → TestFlight → iOS Builds:

| Version & Build | Status | Date created |
|---|---|---|
| **1.0.9 (616)** | ✅ Complete | Sep 9, 2026 10:03 PM |
| 1.0.9 (1) | ✅ Complete | Sep 9, 2026 8:54 PM |

Version 1.0.9 altında iki derleme yan yana duruyor (**616** ve **1**),
ikisi de `Ready to Submit`. Yani teşhis doğruydu ve düzeltme arşive kadar
ulaştı: numarayı belirleyen şey gerçekten fastlane'den önceki SON `flutter
build`di, ve iki `flutter build` hizalanınca doğru numara pakete girdi.
Numara yakma riski kapandı — bundan sonra her koşu kendi numarasını taşıyor.

⚠ Kontrolün ne kanıtladığını yine de karıştırma: o, fastlane'in OKUYACAĞI
dosyayı doğrular. "Arşiv o dosyadan besleniyor" halkasını kanıtlayan tek
şey bu tablodur — bu depoda kanıt her zaman ürünün kendi künyesinden
okunur (web'de `curl … | grep kelimeki-build`in iOS karşılığı).

#### Beşinci koşu (#612) — **imzalı `.ipa` ÜRETİLDİ**, Apple bundle'ı reddetti

```
| 4 | match                        | 3   |
| 5 | update_code_signing_settings | 0   |
| 6 | build_app                    | 118 |  ← GEÇTİ
| 💥 | upload_to_testflight        | 68  |
```

✅ **İmzalama çözüldü.** `kelimeki-ipa` artefaktı gerçek: **27 MB**. Yani
Mac'siz imzalama zincirinin TAMAMI çalışıyor — sertifika, profil, arşiv,
imza. Bu, 24.2'nin asıl iddiasıydı.

❌ Kalan tek şey yükleme ve reddeden **Apple'ın kendisi** (tesisat değil):

```
Invalid bundle … you need to include all of the "Portrait,
PortraitUpsideDown, LandscapeLeft, LandscapeRight" orientations
to support iPad multitasking. (90474)
```

**Düzeltme:** `Info.plist` → `UISupportedInterfaceOrientations~ipad` dörde
çıkarıldı. iPhone listesi portre kaldı (kural yalnızca iPad için).

⚠ **BU BİR ÜRÜN SONUCU DOĞURUYOR, sadece tesisat değil:** uygulama iPad'de
artık **döndürülebilir**. `main.dart`in portre kilidi iPhone'da tutuyor ama
çoklu göreve açık bir iPad uygulamasında iOS onu yok sayıyor
(`UIRequiresFullScreen` modern SDK'larda güvenilir değil), ve **portta
manzara için ayrı bir düzen YOK** — web'deki `LandscapeHint` hiç port
edilmemiş. Hiç bakılmamış bir yüzey; cihaz kontrol listesi
`mobile/TESTING.md` §26'ya yazıldı.

⚠ **iPad desteğini bırakmak seçenek DEĞİL** — ve bu artık yalnızca mağaza
vitrini gerekçesi değil, **kullanıcı kararı** (9 Eylül 2026, sözleri
birebir): *"Ipad olmazsa olmaz. Bu oyunun en iyi oynandığı yer orası."*
`TARGETED_DEVICE_FAMILY = "1,2"` kalıyor. ✅ Manzara düzeni 10 Eylül
2026'da karara bağlandı — **değişmiyor**, kenar/alt boşluğu bilinçli kabul
(Apple'ın yazılı kuralı okundu: 2.4.1'de letterboxing yasağı yok).
Kayıt: `docs/decisions/roadmap-arsiv.md` → §25.

✅ **Adım sırası kararı DOĞRULANDI.** TestFlight adımı bilerek Appetize'dan
SONRA konmuştu (*"yeni ve doğrulanmamış bir adım, çalışan bir adımı asla
rehin almamalı"*). Bu koşuda tam olarak öyle oldu: cihaz derlemesi,
simülatör derlemesi, prerelease yüklemesi ve Appetize'ın dördü de GEÇTİ;
yalnızca 10. adım düştü.

**Kurulum tamam; kalan tek şey zincirin İLK KEZ koşması.** Tetikleme:
`main`'e push `.github/workflows/mobile-build.yml` yolunu da kapsıyor, yani
o dosyaya dokunan bir merge koşuyu KENDİLİĞİNDEN başlatır — ayrıca
`workflow_dispatch` gerekmez (`ios: true`).

⚠ **Bu satırlar bir şey değiştiğinde GÜNCELLENİR.** Bir secret döndürülür,
depo taşınır ya da match sıfırlanırsa buraya yazılır; aksi halde bölüm
sessizce bayatlar ve yukarıdaki hatanın aynısı tekrarlanır.

⚠ **`ISSUER_ID` unutulmaya en müsait olanı — 9 Eylül 2026'da gerçekten
unutuldu.** Öteki üçü girilmiş, o girilmemişti; secret listesi yalnızca
ADLARI gösterdiğinden eksiklik ancak listeye bakılınca görüldü (alfabetik
sırada `ISSUER` `KEY`'den ÖNCE gelir — orada yoksa yoktur). Sebebi anlaşılır:
ötekiler dosyadan/kullanıcıdan gelirken bu, Console'da BAŞKA bir yerde
duruyor.

⚠ **İş akışı artık bunu kendi söylüyor.** `KEY_P8` adımın "yapılandırıldı
mı" sentineli; yanındaki ikisi eksikse adım yine koşuyordu ve fastlane'in
`ENV.fetch`i ham bir Ruby `KeyError`'ı ile düşüyordu — log'da sebebi
görünmezdi. 9 Eylül 2026'da koruma üçünü de tek tek kontrol edecek şekilde
genişletildi ve hata mesajı Issuer ID'nin NEREDE olduğunu da yazıyor.

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

⚠ **10 Eylül 2026'da yine tazelendi** — aynı sebeple: `.p8` satırı hâlâ
*"Apple'da, vaka açık"* diyordu, oysa anahtar 9 Eylül akşamı alınmış ve
24.2 uçtan uca doğrulanmıştı. Bu tablo **iki kez** kaynağın kendi içinde
bayatladı; bir kova kapandığında aynı turda buraya da dokun.

⚠ **10 Eylül 2026 akşamı ÜÇÜNCÜ tazeleme:** iki satır birden kapandı
(TestFlight iç test grubu · trader doğrulaması). Bu tablo artık **üç kez**
kaynağın kendi içinde bayatladı — bir kova kapandığında aynı turda buraya
da dokun.

| Açık iş | Kimde | Notu |
|---|---|---|
| **Karelerin Console'a YÜKLENMESİ** | Sende | Kareler hazır ve doğrulandı (§13, koşu `7d6361e`); artefaktı indirip 6.9" + iPad 13" slotlarına yüklemek elle — ajan indiremiyor |
| **Gönderim** | Sende | §13 ve §15 kapandıktan sonra 24.6'nın önünde başka kapı YOK |

**Kapananlar:** App Privacy → §10 · mağaza metinleri → §9 · yaş derecesi →
§5 · demo hesap → §11 · Export Compliance → §12 · **API anahtarı `.p8` →
§3 (9 Eylül 2026, Mac'ten indirildi)** · **imzalama + TestFlight yüklemesi
→ §3, koşu #614/#616** · **DSA trader beyanı + DOĞRULAMASI → §2 (10 Eylül
2026, 22:21 — gönderim kapısı düştü)** · **TestFlight iç test grubu →
§14 (10 Eylül 2026, uygulama iPad'de kuruldu ve çalıştı)** · **ekran
görüntüleri (kompozisyon + 7. kare + alfa) → §13 (11 Eylül 2026)** ·
**sürüm kaydı `1.1.0` + derleme iliştirme → §15 (11 Eylül 2026)**.

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

⚠ **Dördüncü kural, aynı ailenin üyesi: BAŞKA BİR ÜRÜNÜN ADI da geçemez.**
4. karenin sahte verisinde "en uzun kelime" bir dönem **`KELİMELİK`**
yazıyordu — Kelimelik rakip bir Türkçe kelime oyununun adı, yani vitrin
karesi rakibin markasını *"en uzun kelimem"* diye gösteriyordu (kullanıcı
yakaladı, 11 Eylül 2026; kareler Console'a henüz yüklenmemişti, `ÇALIŞKAN`
ile değiştirildi). Sahte veri uydururken elenecekler listesi artık üç
başlıklı: **gerçek kişi/e-posta · gerçek arkadaş adı · başka bir marka.**
⚠ Sözcük havuzunu "kelime oyunu" çağrışımından seçmek tam da bu tuzağa
götürüyor — nötr bir sıfat/isim seç.

⚠ **Aynı tarama karelerdeki oyuncu adını da eledi.** Ad `Ironman`'di ve İKİ
kuralı birden çiğniyordu: *"Iron Man"* başkasının tescilli markası **ve**
`Ironman` bu projede gerçek bir hesabın takma adı (`ROADMAP.md`: *"hiçbir
koşulda silinmez"*). Kullanıcı kararı: **`Ege`** (11 Eylül 2026). Ad
karelerde üç yerde görünüyordu — başlıktaki avatar, 04'ün skor kartı,
07'nin vurgulu k-lig satırı. ⚠ `test/` altındaki birim testleri hâlâ
`Ironman` kullanıyor ve BİLEREK dokunulmadı: onlar mağazaya gitmiyor.

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
2. ✅ **ÇÖZÜLDÜ — kareler GİRİŞLİ çekiliyor** (9 Eylül 2026). Önce
   başlıkta `GİRİŞ` butonu duruyordu (misafir hâli); Play turunun yazılı
   kuralı *"test hesabıyla çek"* dediği için girişli hâl seçildi. Ağa
   çıkmadan çözüldü: `AuthService.fake(user:, profile:)` sahte oturum kabul
   ediyor, başlıkta avatar (baş harf) çiziliyor — secret ya da gerçek hesap
   gerekmiyor, iş akışı hâlâ ağa hiç çıkmıyor.
   ⚠ **`test/account_button_test.dart`in sahte kullanıcısı KOPYALANMADI:**
   o yardımcı geliştiricinin kişisel e-postasını taşıyor ve Play'in çekim
   kuralı *"e-posta geçen ekran yok"* diyor. Mağaza kimliğinin `email`i
   bilerek boş.

### 2. kare eklendi — 9 Eylül 2026

`02-kurulmus-hamle`: oyuncunun rafından tahtaya kurulmuş ama henüz
onaylanmamış bir hamle — yeşil dış hat, **+14** puan rozeti, *"Oyna tuşuyla
kelimeyi onayla."* mesajı ve öne çıkan `OYNA` butonu.

⚠ **Hamle elle KODLANMIYOR**, motorun kendi arama fonksiyonundan
seçiliyor — ama *"en yüksek puan"* kuralıyla DEĞİL. Ölçüm: en yüksek puanlı
aday `LAM` (16 puan, **2 taş**) çıkıyor ve mağaza karesinde mekaniği
anlatmıyor. Seçim kuralı bu yüzden **en çok taş kullanan** aday (eşitlikte
puan, sonra `trCompare`): `ALKIM` — 4 taş, dikey, mevcut bir `I` taşının
ÜSTÜNDEN geçiyor, yani hem kelimeyi hem kancalama kuralını gösteriyor.

⚠ **Tuzak (ölçüldü):** raf her yerleştirmede KÜÇÜLÜYOR (`_placeTile`
indeksi çıkarıyor), yani raf indeksleri önceden hesaplanamaz. İlk denemede
4 yerleştirmeden yalnızca 3'ü tuttu ve son taş **sessizce** düştü — hata
yok, eksik kare. Her adımda güncel raftan bakılıyor.

✅ **Run #3 (9 Eylül 2026) tamamen yeşil:** iki cihaz × iki kare, dördünün
de piksel ölçümü geçti. Artefaktlar `iphone-6.9` 3,21 MB + `ipad-13`
3,41 MB (bir önceki turun ~iki katı — iki kare de üretildiğinin ölçüsü).

### Kalan dört kare eklendi — 9 Eylül 2026 (6/6)

| Kare | Ne gösteriyor |
|---|---|
| `03-arkadasinla` | Kurulum → "Arkadaşınla": üç canlı oyun, iki farklı sıra durumu |
| `04-skor-karti` | Skor kartı: k-lig sırası, sekmeler, oyuncu + oyun istatistikleri |
| `05-kelime-anlami` | Tahtanın üstünde TDK anlam penceresi (`SAZ`) |
| `06-nasil-oynanir` | Kurallar penceresi (ekrandaki başlığı **"Hızlı Başlangıç"**) |

**Anlam metni UYDURULMUYOR** — `meanings.db`'den, üretimdeki yolun ta
kendisiyle okunuyor. Widget testleri bunu hiç deneyememişti (`MeaningStore`
gerçek sqflite async'i kullanıyor ve testin sahte zaman bölgesinde
çözülmüyor); `integration_test` gerçek cihazda koştuğu için `runAsync` ile
mümkün oldu. Kelime `SAZ`: tahtada gerçekten duruyor (oyuncunun köşe
açılışı) ve birden çok anlamı var, yani pencere tek satırlık değil.

⚠ **`_SahteSupabase` — bir kare "temsili" değilse mağazaya giremez.**
Setup'ın teşhis satırı üretimde HER ZAMAN görünüyor (bilinçli karar) ve
`services.supabase == null` iken *"offline mod"* yazıyor. İlk çekimde kare
şunu gösteriyordu: **üstte üç CANLI oyun, altta "offline mod".** Böyle bir
ekran gerçekte hiç oluşmaz — yani kare uygulamayı yanlış temsil ederdi, ki
Apple'ın yasakladığı tam olarak bu. Gerçek bir `SupabaseClient` kurmak
denendi ve ELENDİ: bir `HttpClient` + bekleyen zamanlayıcı yaratıyor
(ölçüldü, testi düşürdü) ve iş akışının *"ağa çıkma"* önermesini bozardı.
Çözüm, `noSuchMethod` ile boş bir stub: `services.supabase` üretimde TEK
yerde okunuyor (sadece o etiket), yani nesnenin üzerine hiçbir çağrı
düşmüyor.

⚠ **Kareyi ÇİZDİRMEK sahte verideki bir hatayı yakaladı:** skor kartında
"Teslim olma" kutusu 1 verilmesine rağmen `0` gösteriyordu — anahtar adı
`surrendered_games` yazılmıştı, doğrusu `surrendered_count`. Alan sessizce
0'a düşüyordu; hiçbir test bunu göremezdi çünkü test yok, kare var. Ders:
sahte veriyi yazmak yetmiyor, **çizdirip okumak** gerekiyor.

⚠ **Liste tek satırken özelliği ANLATMIYORDU.** İlk kurgu tek aktif oyun
gösteriyordu; üç oyuna ve İKİ farklı sıra durumuna çıkarıldı ("SIRA SENDE"
yeşil ↔ "SIRA RAKİPTE" kırmızı), ekranın ne işe yaradığı tek bakışta
anlaşılsın diye.

✅ **Run #4 (9 Eylül 2026) tamamen yeşil — 6/6 kare, İKİ cihazda da
doğrulandı.** Artefaktlar `iphone-6.9` **5,33 MB** + `ipad-13` **5,46 MB**;
on iki PNG'nin on ikisi de piksel ölçümünü geçti (`1320×2868` / `2064×2752`).
Yani mağazaya giden kareler **bugün hazır** — üretimi değil, yalnızca
kompozisyon kararı bekliyor.

### ⚙️ Boru hattı gözlemleri — 9-10 Eylül 2026

**1. Bu boru hattına YÖNELİM ölçümü bindirilemez (denendi, elendi).** Aynı
simülatöre ikinci bir hedef (iPad manzara ölçümü) eklendi ve geri alındı:
simülatör DÖNDÜRÜLEMİYOR, sebebini iOS'un kendisi yazdı —
`UISceneErrorDomain Code=101 "The current windowing mode does not allow for
programmatic changes to interface orientation."` Çoklu göreve açık bir iPad
uygulamasında `setPreferredOrientations` iki yönde de geçersiz. **Kareler
için sonucu şu: bu hattan yalnızca PORTRE kare alınabilir** — Apple zaten
iPad seti için portre istiyor, yani vitrin etkilenmiyor. Kayıt:
`docs/decisions/roadmap-arsiv.md` → §25.

**2. İLK takılma gözlendi (koşu #7).** `iphone-6.9` işi "Kareleri üret"
adımında **~6 saat** asılı kaldı ve GitHub'ın iş tavanına takıldı; koşu
dışarıdan *"cancelled"* göründü. Aynı dosya koşu #6'da geçmişti ve `ipad-13`
bu koşuda da geçti — yani **altyapı takılması, kod değil.** ⚠ Tekrarlarsa
işe bir `timeout-minutes` eklenmeli (tek vakada eklenmedi); ayrıca *"koşu
iptal oldu"* ile *"iş düştü"* ayrımını hatırla — ikisi ekran görüntüsünde
aynı görünüyor.

### 📦 TAZE KARELER HAZIR — `7d6361e`, 11 Eylül 2026 (yeniden koşturma GEREKMEZ)

**Mağazaya gidecek set BU — ve o güne kadarki BÜTÜN setler çöp.** Başlıklı
kompozisyonun, 7. karenin ve alfa düzeltmesinin birlikte koştuğu ilk tur;
`claude/dal-yok-acik-pr-yok-qd4uin` dalında **yeşil** (08:43→09:01 UTC).
Üç kapı da aynı adımda geçti: `KARE_SAYISI` sayımı · piksel ölçüsü ·
`hasAlpha = no` (yedi karenin yedisi, iki cihazda).

| | |
|---|---|
| Koşu | https://github.com/alpcapa/kelimeki/actions/runs/34580565810 |
| Artefaktlar | `kelimeki-store-screenshots-iphone-6.9` (**2,47 MB**) · `kelimeki-store-screenshots-ipad-13` (**2,03 MB**) |
| Geçerlilik | **10 Aralık 2026**'ya kadar |

⚠ **Boyut YARIYA DÜŞTÜ (5,77/5,83 → 2,47/2,03) ve bu bir kayıp DEĞİL.** İki
sebep: alfa kanalı gitti (baytın dörtte biri) ve kare artık `image`
paketinin PNG kodlayıcısından çıkıyor (Flutter'ınkinden daha iyi
sıkıştırıyor). PNG kayıpsız — piksel verisi birebir aynı, `png_flatten_test`
renk korunumunu ayrıca ölçüyor.

**Çöpe giden setler** (hepsi en az bir sebeple kullanılamaz):

| Koşu | Set | Neden |
|---|---|---|
| #9 · `2015ab6` | 6 kare, başlıksız | başlık yok · alfalı |
| #10 · `538ecc4` | 7 kare, başlıklı | `KELİMELİK` · `Ironman` · alfalı |
| `49182b0` | 7 kare | `Ironman` · alfalı |
| `bb12fe7` | 7 kare | alfalı |

⚠ **Ajan bu iş akışını TETİKLEYEMEZ** (10 Eylül 2026'da denendi):
`workflow_dispatch` 403 döndü — GitHub App'in `actions: write` izni yok.
Elle koşu: **Actions → "iOS mağaza ekran görüntüleri" → Run workflow**. Ama
önce yukarıdaki koşuya bak: `integration_test/` değişmediyse kareler zaten
taze (bu iş akışı o yola her dokunuşta kendiliğinden koşuyor — dalda da).

⚠ **Ajan artefaktı İNDİREMEZ — İKİ kapı birden kapalı** (11 Eylül 2026'da
ölçüldü). (1) GitHub MCP'de indirme aracı yok. (2) API'nin indirme ucu
`productionresultssa*.blob.core.windows.net`e yönlendiriyor ve oturumun
çıkış vekili o hedefi reddediyor (`connect_rejected`) — yani **`curl` de
çözmüyor**, denemeye değmez. Kareleri GÖRMEK gerekiyorsa PNG'lerin sohbete
eklenmesi gerekiyor.

### ✅ KOMPOZİSYON KARARI — başlıklı set + 7. kare (11 Eylül 2026)

Kullanıcı kararı: **kareler BAŞLIKLI çıkacak** ve **7. kare (k-lig
sıralaması) eklenecek.** Böylece §13'ün açık kalan tek maddesi kapandı.

**Neden başlıklı** (üç ölçüme dayanıyor, tercihe değil):

1. App Store kareleri önce **küçük küçük, yan yana** gösteriyor; o boyutta
   başlıksız bir tahta karesi *"bir oyun tahtası"*ndan fazlasını anlatmıyor.
2. 01/02'nin **alt ~%20'si zaten boş** (9 Eylül'de gözle ölçüldü) — şerit
   için hazır yer var, kare kaybı yok.
3. Kareler **sürüme kilitli**: onaylandıktan sonra değiştirmek yeni bir
   gönderim ister (promotional text gibi serbest DEĞİL), yani ilk turda
   doğru olmak zorunda.

**Başlıklar** (kaynak: `store_screenshots_test.dart` → `_kBasliklar`; bu
tablo oradan KOPYA, ikisi ayrışırsa kaynak odur):

| Kare | Başlık |
|---|---|
| `01-oyun-ekrani` | Köşenden başla, bölgeni büyüt |
| `02-kurulmus-hamle` | Kelimeni kur, puanını gör |
| `03-arkadasinla` | Arkadaşınla sırayla oyna |
| `04-skor-karti` | İstatistiklerini takip et |
| `05-kelime-anlami` | Kelimenin anlamı bir dokunuş |
| `06-nasil-oynanir` | Kuralları üç dakikada öğren |
| `07-klig-siralamasi` | k-lig'de sıranı yükselt |

⚠ **Son işlem (ImageMagick/`sharp`) YOK.** Şerit Flutter ağacının İÇİNDE,
`MaterialApp.builder` ile çiziliyor: uygulama `Expanded` içinde biraz daha
kısa bir görünüm alanında GERÇEKTEN çiziliyor, hiçbir içerik örtülmüyor.
Sonuç kare yine cihazın fiziksel pikselinde (`1320×2868` / `2064×2752`),
yani ölçüm adımı değişmeden geçiyor ve CI'a yeni bir araç/bağımlılık
girmiyor. `builder` Navigator'ın ÜSTÜNÜ sardığından 05'in anlam penceresi
gibi dialog kareleri de kendiliğinden şeridin üstünde kalıyor.

**Ölçüm — şerit oranları (11 Eylül 2026, gerçek `SpaceGrotesk-Bold` ile):**

| | punto | şerit | en uzun başlık |
|---|---|---|---|
| iPhone 6.9" (440×956 mantıksal) | 24,2 | 67,8 = yüksekliğin **%7,1**'i | %90 (tek satır) |
| iPad 13" (1032×1376) | 44,0 | 123,3 = **%9,0** | %71 (tek satır) |

⚠ **Yalnızca genişliğe oranlamak YETMİYOR.** İlk kural `punto = genişlik ×
%5,5`ti; iPad karesi iPhone'a göre çok daha geniş ama aynı oranda uzun
DEĞİL, yani şerit iPad'de yüksekliğin **%11,6**'sına çıkıyordu. Bir yükseklik
tavanı eklendi (`punto ≤ yükseklik × %3,2`) ve ikisi de %7-9 bandına indi.
Yedi başlığın yedisi de bu puntoda tek satıra sığıyor — `FittedBox`
`scaleDown` yine de duruyor, ama devreye girmiyor.

**7. kare** (`07-klig-siralamasi`): `LeaderboardModal`, sahte ama tutarlı bir
k-lig listesiyle. Oyuncunun satırı **4.** sırada — birinci olsaydı kare
*"yükselinecek bir yer"* anlatmazdı, listenin dışında olsaydı vurgulu satır
hiç görünmez, yerine alttaki kesikli *"senin sıran"* kısayolu çıkardı.
Sayılar öteki uçlarla tutarlı (sıra 4, puan 57, OHP 21,40 — aynı üçlü
`myLeaderboardRank` ve `playerStats`ta da var, 04. kare onları gösteriyor).
⚠ `avatar_url` her satırda **null**: dolu olsa `KAvatar` ağa çıkardı, bu iş
akışının tüm önermesi ise *"ağa hiç çıkma"*.

### ⚠ EKSİK KARE ARTIK KOŞUYU DÜŞÜRÜYOR (11 Eylül 2026)

7. kare eklenirken bir boşluk bulundu: ölçüm adımı `build/screenshots/*.png`
üzerinde dönüyordu, yani **üretilmeyen bir kare hiç bakılmadan geçiyordu** —
bir `testWidgets` düşerse `flutter drive` o kareyi yazmaz ve koşu YEŞİL
kalırdı. (Adımın kendi yorumu *"eksik kare zaten bu adımın işi"* diyordu;
değildi.) `ios-screenshots.yml`e `KARE_SAYISI` eklendi ve ölçümden ÖNCE
sayım yapılıyor. ⚠ Kare eklenir/çıkarılırsa o sayı da değişmeli.

### Slot doğrulaması — 6.9" var (11 Eylül 2026, kullanıcı Console'dan ölçtü)

Sürüm sayfasında ilk görünen kutu `iPhone 6.5" Display` olduğu için bir an
boru hattının ölçüsü (6.9" = `1320×2868`) yanlış sanıldı. **Media Manager'da
6.9" slotu var ve kareler oraya giriyor** — ölçü değişikliği GEREKMİYOR.
Sayfanın kendi açıklaması da bunu söylüyor: verilen kareler öteki ekran
boyutları için ölçekleniyor.

### 🔴 ALFA KANALI — kareler yüklenemeyecekti (11 Eylül 2026, ölçüldü)

**App Store Connect ekran görüntüsünde saydamlık kabul etmiyor** ("flattened"
istiyor). İş akışına eklenen `sips -g hasAlpha` ölçümü koşu **34578979721**'de
şunu dedi: **yedi karenin yedisi de `hasAlpha: yes`.** Yani kareler ölçü
olarak doğru olmalarına rağmen yüklenemezdi ve arıza ancak **Console'da,
yükleme anında** — zincirin en sonunda — görünecekti.

Sebep: Flutter'ın ekran görüntüsü yolu RGBA üretiyor. Uygulamanın hatası
değil, boru hattının.

**Düzeltme sürücüde:** `mobile/app/test_driver/png_flatten.dart` kareyi opak
beyaz bir zemine kompozit edip RGB olarak yazıyor. ⚠ `sips` bu işi
YAPAMIYOR — alfa kanalını kaldıran bir seçeneği yok, JPEG'e gidip dönmek de
metni bozardı; sürücü zaten PNG baytlarını elinde tuttuğu için en ucuz yer
orası ve CI'a yeni bir araç girmiyor. Alfa "siliniyor" değil
**birleştiriliyor**: kanalı düpedüz atmak yarı saydam bir pikselin ham
RGB'sini ortaya çıkarırdı.

**Kapı İKİ katmanlı, bilerek:**

| Katman | Nerede | Ne kanıtlıyor | Maliyet |
|---|---|---|---|
| `test/png_flatten_test.dart` | Linux, `flutter test` | dönüşümün kendisi (RGBA→RGB, yarı saydam→zemin, alfasız kare yeniden kodlanmaz) | saniyeler |
| `hasAlpha != no` → `::error` | macOS, iş akışı | GERÇEK çıktının alfasızlığı | bir koşu (~14 dk) |

İlki olmasaydı her denemede bir macOS koşusu beklenirdi; ikincisi olmasaydı
dönüşümün gerçekten uygulandığına dair kanıt olmazdı.

### Kalan iş

Kod tarafında kalan iş YOK. Kareler bir sonraki `ios-screenshots.yml`
koşusunda başlıklı, yedi kare ve **alfasız** üretilir; **artefaktı indirip
Console'a yüklemek elle** (ajan indiremiyor — yukarıdaki uyarı).

---

## 14. TestFlight iç test — ✅ KURULDU VE CİHAZDA ÇALIŞTI (10 Eylül 2026)

**Durum:** `INTERNAL TESTING` → grup **`İç Test`** · 2 testçi · derleme
**`1.0.9 (620)`** dağıtıldı. iPad'e kuruldu, açıldı, Setup teşhis satırı
`Derleme 46664f6` (= `main`'in o günkü başı) gösterdi. Yani ROADMAP §24
FAZ C'nin "cihaz turunun TEK kapısı" maddesi kapandı; 24.3 (push), 24.4
(Universal Links) ve `mobile/TESTING.md` §26 (iPad manzarası) artık
koşulabilir.

⚠ **BİR SÜRÜM YÜKLEMEK GEREKMEDİ:** `mobile-build.yml` `main`'e her
push'ta TestFlight'a yüklüyor, yani orada 616'nın yanında 618 ve 620 de
duruyordu. Gruba **en yenisini** ekle; doküman "616" diyorsa bayattır.

### ⚠ İKİ AYRI DAVET E-POSTASI VAR — karıştırmak bir akşam yedi

| E-posta | Konusu | Götürdüğü yer |
|---|---|---|
| **Ekip daveti** | *"…invited to join … on App Store Connect"* | Tarayıcıda ASC girişi. Bir kez kullanılır |
| **Testçi daveti** | TestFlight'tan, *"… has invited you to test Kelimeki"*, içinde **View in TestFlight** | TestFlight **uygulamasını** açar — kurulumu başlatan TEK bağlantı |

10 Eylül akşamı tıkanma tam buradaydı: ekip daveti tekrar tekrar tıklandı,
her seferinde ASC'ye götürdü; TestFlight uygulaması ise boş "Redeem"
ekranında kaldı. **O ekran bir kod İSTEMİYOR** — uygulama listesi boşken
gösterdiği varsayılan ekran o; `testflight.apple.com/join/...` kodu
yalnızca DIŞ testin herkese açık linkinde vardır ve bizde dış test yok.
Çözüm: testçi davetindeki **View in TestFlight**'a cihazdan dokunmak.

### Konsoldaki tester statüsü teşhis ARACI DEĞİL

Ölçüldü: `destek@` satırı `Invited`, ikinci testçi `No Builds Available`
görünüyordu ve ikisi de kurulumu engellemiyordu. Statü sütunu kurulumun
SONUCUNU yansıtır, sebebini değil — `Installed`a kurulumdan sonra döner.
Ayrıca elenen üç şüpheli (hepsi yanlış çıktı, tekrar denemeye değmez):
uygulama erişimi (`All Apps` idi), rol (`Marketing` → `App Manager`
değiştirildi, fark etmedi), cihazın mağaza hesabı (doğruydu).

### İç testçi = ekipteki kişi; arkadaşlar için yol AYRI

İç testçi olmak App Store Connect'te bir rol gerektiriyor (Users and
Access). Ekipten olmayan birine göndermenin yolu **External Testing**
grubu + Beta App Review + isteğe bağlı herkese açık link — bu depoda
henüz kurulmadı. Bir derlemenin sayfasındaki *"Individual Testers"* kutusu
DIŞ testçi eklemez, yalnızca ekipteki bir kişiyi tek bir derlemeye bağlar.

---

---

## 15. Sürüm kaydı ↔ derleme eşleşmesi (11 Eylül 2026)

**Belirti:** Apps listesinde uygulama **jenerik ızgara ikonuyla** görünüyordu.

**Yanlış ilk hipotez elendi:** ekran görüntüleriyle (24.5) ilgisi YOK —
Connect o küçük resmi vitrin karelerinden değil, **derlemenin içindeki
1024×1024 pazarlama ikonundan** okuyor. İkili de sağlamdı; depodan üç ölçüm:

| Kontrol | Sonuç |
|---|---|
| `Icon-App-1024x1024@1x.png` | tam `1024×1024`, **colortype 2 (RGB, alfa YOK)** — Apple'ın alfa yasağına uygun |
| `Contents.json` | `idiom: ios-marketing` girdisi var, dosya adı eşleşiyor (25 görsel tam) |
| `project.pbxproj` | üç yapılandırmada da `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` |

**Gerçek sebep — sürüm numaraları tutmuyordu.** Connect'teki App Store
sürüm kaydı **`1.0`**'dı; yüklenen paketler ise `1.0.9` ve bundan sonrası
`1.1.0` (iş akışı `--build-name` geçirmiyor, ad `pubspec.yaml`'dan geliyor
ve o bugün `1.1.0+1`). Yani **kısa sürüm dizesi `1.0` olan bir derleme hiç
yoktu ve olmayacaktı**; sürüme derleme iliştirilemediği için Connect'in
gösterecek bir ikonu da yoktu.

✅ **ÇÖZÜLDÜ (11 Eylül 2026, kullanıcı):** sürüm kaydı `1.1.0` yapıldı ve
derleme iliştirildi.

⚠ **Sürüm turunda bunu hatırla:** `pubspec.yaml`'ın sürüm adı ile
Console'daki App Store sürüm kaydı AYNI olmak zorunda. Play tarafında böyle
bir eşleşme yok (`versionCode` yeterli), yani bu Android refleksiyle
kaçırılacak bir adım — ve belirtisi "ikon çıkmıyor" gibi tamamen alakasız
görünüyor.

⚠ **Yeni arayüzde "App Store" sekmesinin adı `Distribution`.** Sürüm
numarası sayfanın en altındaki **General App Information** bölümünde
düzenlenir (başlıktaki "Version 1.0" yazısı o alandan beslenir,
düzenlenebilir değil); derleme aynı sayfadaki **Build** bölümünden `+` ile
iliştirilir.
