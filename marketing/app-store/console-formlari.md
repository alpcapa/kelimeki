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
| Apple ID (**hesap**) | `destek@kelimeki.com` |
| Team ID | `8277D85FY9` |
| Yenileme | 9 Eylül 2027, auto-renew açık |
| **Apple ID (UYGULAMA)** | **`6809809788`** — ASC → App Information → *General Information* → Apple ID (13 Eyl 2026'da okundu) |

⚠ **"Apple ID" bu konsolda İKİ ayrı şeyin adı** ve tablodaki iki satır
tam da o yüzden ayrı etiketlendi: biri hesabın **e-postası**, öteki
uygulamanın **10 haneli sayısal kimliği**. Sayısal olan mağaza kaydı
oluşturulunca atanır — **yayına girmeyi beklemez**, o yüzden bugün
okunabildi. Kullanıldığı yer: iOS **Smart App Banner**
(`<meta name="apple-itunes-app" content="app-id=6809809788">`,
`ROADMAP.md` §26). ⚠ Değer gizli değil (sayfanın kaynağında herkese
görünür olacak), ama etiketi **uygulama App Store'da yayına girmeden
koyma** — yoksa ziyaretçi olmayan bir mağaza sayfasına gider.

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

## 3. App Store Connect API anahtarı — ✅ **ALINDI** (9 Eylül 2026)

⚠ Başlık 12 Eylül 2026'da düzeltildi: *"`.p8` İNDİRİLEMEDİ"* diyordu ve
üç gündür YANLIŞTI. Bölüm numarası değişmedi (atıflar `§3` diyor).

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

⚠ **`.p8` SAGASI KAPANDI — anlatı arşivde.** Anahtar 9 Eylül 2026 akşamı
bir **Mac'ten** indirildi; iPad'deki indirme iki kez hata vermişti, Apple'a
vaka açılmıştı ve yanıt gelmeden çözüldü. Teşhis adımları, denenen yollar
(`Team Keys` ↔ `Individual Keys`, "başka tarayıcı dene" yanılgısı, anahtar
yakmadan bedava teşhis), Support'a gönderilen metin ve arızanın ASC
genelinde olduğunun ölçümü: `docs/decisions/app-store-gecmis.md` → "§3 —
`.p8` indirilemedi".

⚠ **Bir kez daha anahtar üretmek gerekirse iki satır yeter:** `Individual
Keys` sekmesinden üret (takım anahtarı değil) ve indirmeyi **Mac'ten** yap.


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

⚠ Bekleme günlerinin durum kayıtları, Support'a gönderilen metin ve
"arıza ASC'nin genelinde" teşhisi arşivde:
`docs/decisions/app-store-gecmis.md` → "§3 — `.p8` indirilemedi".


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

⚠ **İlk dört koşunun (#604 · #606 · #608 · #610) adım adım kütüğü arşivde**
— anahtarlıkta düşme, `match`in geçmesi, `build_app`ın yol hataları:
`docs/decisions/app-store-gecmis.md` → "§3 — 24.2 zincirinin koşuları".
Zincirin BUGÜNKÜ durumu yukarıdaki tabloda; aşağıdaki blok da onun
kanıtlandığı koşu.


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

⚠ **İki vaka anlatısı arşivde** — yeşil koşunun YANLIŞ derleme numarasını
yüklemesi (post-mortem) ve #612'de Apple'ın bundle'ı iPad yönelimleri
yüzünden reddetmesi: `docs/decisions/app-store-gecmis.md` → "§3 — 24.2
zincirinin koşuları".


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

**✅ APPLE'DA GİRİLDİ (11 Eylül 2026) — sonuç `4+`.** Apple'ın anketi artık
YEDİ adımlı ve Play'inkinden farklı bölünmüş; verilen cevaplar:

| Adım | Cevap |
|---|---|
| 1 · In-App Controls | Parental Controls **No** · Age Assurance **No** |
| 1 · Capabilities | Unrestricted Web Access **No** · **User-Generated Content `No`** · Social Media **No** · Social Media Disabled Under 13 **No** · **Messaging and Chat `YES`** · Advertising **No** |
| 2 · Mature Themes | üçü de **None** |
| 3 · Medical or Wellness | **None** / **No** |
| 4 · Sexuality or Nudity | üçü de **None** |
| 5 · Violence | dördü de **None** |
| 6 · Chance-Based Activities | Simulated Gambling **None** · **Contests `Infrequent`** · Gambling **No** · Loot Boxes **No** |
| 7 | Override **Not Applicable** · Age Suitability URL boş |

⚠ **UGC `No` + Messaging `YES` bir yorum kararı.** Apple bu ikisini ayırmış:
UGC *"içeriğin GENİŞ dağıtımı"*, Messaging *"doğrudan iletişim"*. Kelimeki'de
sohbet ve tahta yalnızca iki oyuncu arasında; akış/duvar/keşfet yok. Karşı
okuma (takma ad + profil fotoğrafı k-lig listesinde görünüyor) UGC'ye de
`Yes` dedirtebilirdi — tehlikeli yön BEYAN ETMEMEK ve o taraf `Messaging`
ile zaten kapalı.

⚠ **`Contests` neden `Infrequent`:** Apple'ın tanımı *"sıralama/ödül için
yarışma"* diyor, k-lig tam olarak bu (lider tablosu + eşik ödülleri). Gerçek
bir ödül (para/eşya/çekiliş) olmadığı için `Frequent` değil; `None` ise tek
riskli seçenekti.

⚠ **Apple otomatik iki ülke kısıtı ekledi:** *"Due to local laws, this app
will not be sold in: **Afghanistan, Morocco**"*. Anket sonucu, hata değil;
gönderimi engellemiyor. "Neden Fas'ta yok?" sorusunun cevabı budur.

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

⚠ **12 Eylül 2026 BEŞİNCİ tazeleme — ve bu sefer TERS YÖNDE:** durum
tablosu sürüm sayfası metinlerini `⬜` gösteriyordu, oysa hepsi **11 Eylül'de
girilmişti**; kullanıcı aynı metinleri ikinci kez yapıştırmak üzereyken fark
etti. Önceki dördü "kapanan iş yazılmadı" idi, bu da aynı hatanın ta
kendisi — yani tablonun kuralı ("bir sayfayı doldurduğun turda buraya da
dokun") beş kez yazılıp beş kez uygulanmadı. **Refleks:** Console'da bir
sayfayı kapatınca ÖNCE bu tabloya dokun, sonra sıradaki sayfaya geç.

⚠ **11 Eylül 2026 akşamı DÖRDÜNCÜ tazeleme:** kareler yüklendi (satır kapandı)
ve "Gönderim" satırı gerçek duruma çekildi — bir oturum gönderimi YAPILMIŞ
sanıp kütüğe öyle yazmıştı, ASC History'si tersini gösterdi.

⚠ **10 Eylül 2026 akşamı ÜÇÜNCÜ tazeleme:** iki satır birden kapandı
(TestFlight iç test grubu · trader doğrulaması). Bu tablo artık **üç kez**
kaynağın kendi içinde bayatladı — bir kova kapandığında aynı turda buraya
da dokun.

| Açık iş | Kimde | Notu |
|---|---|---|
| ~~Gönderim~~ | ✅ **KAPANDI** | **12 Eylül 2026, 17:32 (TSİ) — sürüm incelemeye GÖNDERİLDİ.** `Add for Review` → `Submit to App Review` → *"1 Item Submitted · It can take up to 48 hours"*; sol menüdeki sürüm satırı `Prepare for Submission` → **`1.1.0 Waiting for Review`** oldu. İliştirilen build **665**, yayın seçeneği **Manually release**. ⚠ **Kanıt kuralı GENİŞLEDİ:** dosya "History'de SATIR görülmeden yazma" diyordu; sürüm durumunun `Waiting for Review`a dönmesi History satırı kadar kesin bir kanıt (ve daha erken görünür) — ikisinden biri yeter, "butona bastım" yetmez. İliştirilen build geçmişi: 629 → 654 → 656 → 659 → **665** |

### Console'a NE GİRİLDİ — durum tablosu (11 Eylül 2026, 23:45)

⚠ **Bu tablo "ne GEREKİYOR"u değil "ne YAPILDI"yı yazar.** Dosyanın geri
kalanı cevap kağıdıdır; bir cevabın Console'a girilip girilmediği başka
hiçbir yerde yazmıyordu ve 11 Eylül akşamı *"sol menüdeki sayfalar dolu
mu?"* sorusu baştan soruldu. **Bir sayfayı doldurduğun turda buraya da
dokun** — yoksa bir sonraki oturum yine baştan sorar.

| Console sayfası | Durum | Not |
|---|---|---|
| App Information — Name · Subtitle · Category · License | ✅ girildi (11 Eyl) | Subtitle'ın GERÇEK değeri §9'da |
| App Information — **Content Rights** | ✅ **Yes** (11 Eyl, kullanıcı kararı) | Gerekçe §9 |
| App Information — **Age Ratings** | ✅ girildi → **4+** (11 Eyl) | Cevaplar §5 |
| App Information — Encryption · DSA etiketleri · Vietnam · Medical · Server Notifications · Shared Secret | — gerekmiyor | Sırasıyla: §12 (`Info.plist`), fiziksel ürün etiketi, VN lisansı yok, Games kategorisi + anket NONE, IAP yok |
| **App Review Information** (demo hesap · iletişim · notlar) | ✅ girildi (11 Eyl) | §11 |
| **App Privacy** | ✅ **PUBLISHED** (12 Eyl) — on türün hepsi + Privacy Policy URL | Girilen cevaplar §10 (Console sırasıyla numaralı tablo). `Save` değil **Publish** basıldı, yani beyan yayımlandı. Beyan değişirse (yeni veri türü, yeni amaç, reklam SDK'sı) aynı sayfa yeniden Publish ister |
| **Pricing and Availability** | ✅ girildi (12 Eyl) | **Free** · taban ülke `United States (USD)` (Free'de fiyat türetmediği için etkisiz) · tüm ülke ve bölgeler |
| Sürüm sayfası metinleri (Description · Keywords · URL'ler · Copyright · Promotional) | ✅ girildi (**11 Eyl**) | §9. ⚠ Bu satır 12 Eyl'e kadar `⬜` duruyordu — girilmişti, yazılmamıştı (aşağıdaki beşinci bayatlama). Sayfa: sol menünün EN ÜSTÜ → `iOS App` → **1.1.0 Prepare for Submission** (App Information DEĞİL). `Version Release` = **Manually release this version** (12 Eyl, kullanıcı Console'dan doğruladı) — Play ile aynı gün yayınlayabilmek için |
| Ekran görüntüleri | ✅ yüklendi (11 Eyl, 8/10 · 8/10) | §13 |
| Derleme iliştirme | ✅ **665** (12 Eyl; 629 → 654 → 656 → 659 → 665) | §15. Kullanıcı kuralı: *"ASC'de her zaman son versiyon olmalı"* — Play aynı numarayla takip eder (665'in `.aab`si 13 Eyl'de yüklenecek; o ana kadar Play **659**'da, yani iki mağaza GEÇİCİ olarak ayrı). ⚠ 665 ilk dört paketten FARKLI: PR #533'ün üç işini taşıyor. Ölçüm: `mobile/docs/surumler.md` → "1.1.0 (665)" + `surumler-ios.csv` |
| **Gönderim** | ✅ **GÖNDERİLDİ** (12 Eyl, 17:32) | `Submit to App Review` → *"1 Item Submitted"*; sürüm durumu **Waiting for Review**. İnceleme ≤48 saat, sonuç e-postayla gelir. Yayın **elle** (Manually) |

**Kapananlar:** **App Privacy Console'a GİRİLDİ ve Published → §10 (12 Eylül 2026)** · mağaza metinleri → §9 · yaş derecesi →
§5 · demo hesap → §11 · Export Compliance → §12 · **API anahtarı `.p8` →
§3 (9 Eylül 2026, Mac'ten indirildi)** · **imzalama + TestFlight yüklemesi
→ §3, koşu #614/#616** · **DSA trader beyanı + DOĞRULAMASI → §2 (10 Eylül
2026, 22:21 — gönderim kapısı düştü)** · **TestFlight iç test grubu →
§14 (10 Eylül 2026, uygulama iPad'de kuruldu ve çalıştı)** · **ekran
görüntüleri: kompozisyon + 7. kare + alfa + Console'a YÜKLENMESİ → §13
(11 Eylül 2026; iPhone 6.9" 8/10 · iPad 13" 8/10)** ·
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
| **Subtitle** | 30 | **30** | `Bölgeni büyüt, tahtaya hükmet.` ⚠ 11 Eyl 2026'da Console'a GİRİLEN değer bu; tasarım sırasında yazılan `Bölgeni büyüt, tahtayı al` (25) artık geçersiz |
| **Keywords** | 100 | **100** (DOLU) | aşağı |
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

⚠ **CONSOLE'A GİRİLEN DEĞER — as-built (12 Eylül 2026, 22:11, ekran
görüntüsünden okundu).** Yukarıdaki blok tasarım; girilen değer onun
`kelime,` eklenmiş hâli:

```
kelime,sözcük,harf,bulmaca,zeka,strateji,sözlük,arkadaş,çevrimdışı,yapay,tahta,anlam,tdk,bingo,joker
```

15 terim, **tam 100/100 — alan DOLU** (Console'un sayacı `0`; string
yerelde de ölçüldü). Yani bundan sonra bir kelime EKLEMEK için önce bir şey
çıkarmak gerekir. **Elde tutulan tek rezerv `kelime,` (7 karakter)** — Name
zaten `Kelimeki: Türkçe Kelime Oyunu` olduğundan Apple o sözcüğü ayrıca
indeksliyor, yani bütçe sıkışırsa ilk çıkacak olan budur. `tdk`nın küçük
harfle yazılması sorun değil; Apple anahtar kelimelerde harf büyüklüğüne
bakmıyor.

**Aynı akşam iki tur sürdü, ikisi de aynı derse çıktı (kayda değer, çünkü
alan 100'de tıkalı ve bir dahaki dokunuş aynı yerden başlayacak):**

| Saat | Değer | Ölçüm |
|---|---|---|
| 22:05 | virgülden sonra BOŞLUKLU liste + `yapay zeka` | 100/100 — ama 11 karakteri boşluklar, 5 karakteri gereksiz bir tekrar yiyordu |
| 22:11 | boşluklar silindi, `yapay zeka` → `yapay`, `tdk`+`bingo`+`joker` eklendi | 100/100 — aynı bütçeyle **üç terim daha** |

⚠ **`yapay zeka` gibi çok sözcüklü bir madde yazma.** Apple tek tek anahtar
kelimeleri kendisi birleştirip ifade üretiyor: `yapay` + `zeka` listede ayrı
ayrı dururken "yapay zeka" araması zaten karşılanıyor. İfade olarak yazmak
`zeka`yı ikinci kez ödetiyor, karşılığında hiçbir şey kazandırmıyor.

⚠ **Sürüm `Waiting for Review` iken metadata düzenlemek serbesttir** ve
sürümü incelemeden ÇIKARMAZ (Apple'ın kendi durum referansı). Yine de
kaydettikten sonra sol üstteki rozetin hâlâ `Waiting for Review` dediği
doğrulanmalı — düzenleme sırası bir kez `Prepare for Submission`'a
düşürürse sürüm sessizce kuyruktan çıkmış olur ve kimse fark etmez.

### Promotional text (sürüm yayınlamadan değiştirilebilir)

```
Türkçe için sıfırdan tasarlanmış bir kelime oyunu. Kelime kur, bölgeni büyüt, rakibinin alanına girerken vergiyi göze al. Ücretsiz, reklamsız, çevrimdışı oynanır.
```

### Description

**Play'in tam açıklaması AYNEN kullanılabilir** (`marketing/play-store/
metin.md` → "Tam açıklama"): 4000 karakter sınırı iki mağazada da aynı ve
metin başka bir platformdan söz etmiyor. Buraya KOPYALANMIYOR — tek kaynak
o dosya, ikiye bölünürse biri bayatlar. Ölçüldü: **2.072 karakter**.

⚠ **Yapıştırmadan ÖNCE satır sonlarını birleştir** (12 Eylül 2026). Kaynak
dosya ~78 sütunda SABİT SARMALI yazılmış; metin kutusuna olduğu gibi
yapıştırılırsa o sarmalar GERÇEK satır sonu olur ve mağaza sayfasında
cümleler ortasından kırılır. Birleştirme kuralı: paragraf içi satırlar tek
satıra, **boş satırlar · BAŞLIK satırları (`NASIL OYNANIR`, `İKİ OYUN
MODU`, `SÖZLÜK`, `k-lig`, `ÜCRETSİZ VE REKLAMSIZ`) · `•` ile başlayan her
madde** kendi satırında kalır (maddenin devamı üstteki maddeye eklenir).
Aynı tuzak Play'in açıklaması için de geçerli — oradaki listenin şu an
kırık olup olmadığı ÖLÇÜLMEDİ, mağaza sayfasından bakılmalı.

### Sabit alanlar

| Alan | Değer |
|---|---|
| Support URL | `https://kelimeki.com` |
| Marketing URL | `https://kelimeki.com` |
| Privacy Policy URL | `https://kelimeki.com/gizlilik/` |
| Category | Games → **Word** (ikincil: Games → Puzzle, isteğe bağlı) |
| Price | **Free** |
| License Agreement | Apple'ın standart EULA'sı (özel sözleşme YOK) |
| **Content Rights** | **Yes — üçüncü taraf içerik var** (11 Eylül 2026, kullanıcı kararı) |

⚠ **Content Rights'ın gerekçesi ve sınırı.** Apple *"uygulaman üçüncü tarafa
ait içerik barındırıyor/gösteriyor mu"* diye soruyor ve "evet" o içeriği
kullanma hakkına sahip olduğun BEYANINI da içeriyor. Kelime LİSTESİ sorun
değil (sözcük listesi başlı başına telif konusu sayılmaz), ama **anlamlar**
(`src/data/meanings.json`, TDK'nın Güncel Türkçe Sözlük'ünden üretiliyor)
uygulama içinde gösteriliyor ve mağaza açıklaması da bunu yazıyor ("TDK
sözlüğüne dayalı"). Dürüst okuma bu yüzden `Yes` oldu. **Bu bir hukuki
inceleme DEĞİL** — TDK'nın kullanım koşullarının bu yeniden kullanıma izin
verip vermediği bu depoda hiç ölçülmedi; bir gün sorulursa başlanacak yer
`docs/decisions/dictionary.md` ve GTS kaynağının koşullarıdır.


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

⚠ **İki satır "bölünmüş" — Console'a girilecek cevap `Linked`** (11 Eylül
2026 gecesi, form doldurulmadan ÖNCE ayrıştırıldı). Tablodaki `Device ID` ve
`Product Interaction` iki satır işgal ediyor çünkü verinin İKİ kökeni var;
ASC ise (bilgimiz dahilinde) her veri türü için TEK bir *"Is this data linked
to the user's identity?"* cevabı alıyor, yani aynı türü iki farklı cevapla
beyan etme yolu yok. **Bu Console'dan ÖLÇÜLMEDİ** — formu dolduran ekranda
aksini görürse (aynı tür ikinci kez eklenebiliyorsa) tablodaki iki satır
AYNEN girilir ve buraya "ölçüldü" yazılır. Ölçülene kadar geçerli cevap:

| Tür | Tablodaki iki köken | **Console'a girilecek** |
|---|---|---|
| Identifiers → **Device ID** | `anon_id`/`device_visits` (not linked) · FCM token (`push_tokens.user_id` VAR → linked) | **Linked** · `App Functionality` + `Analytics` |
| Usage Data → **Product Interaction** | `games` istatistikleri (linked) · `device_visits`/`game_starts` (not linked) | **Linked** · `App Functionality` + `Analytics` |

Gerekçe: türün toplanan örneklerinden biri bile kimlikle ilişkiliyse tür
linked'dir — "Not Linked" demek `push_tokens`ın `user_id` taşıdığını
gizlerdi. Ters yön (fazladan linked saymak) yalnızca bize maliyet yazar,
kullanıcıya değil; güvenli taraf burası. ⚠ Kalan **yedi** tür tek kökenli,
tablodaki cevap doğrudan girilir.

⚠ **Play'in "Paylaşılıyor: Hayır" gerekçesi burada da geçerli** ve 24 Ağustos
2026'da kullanıcı tarafından onaylanmıştı: Supabase/Brevo/Vercel/Firebase
bizim adımıza işleyen **hizmet sağlayıcı**; takma isim/fotoğraf/sohbet ise
kullanıcının kendi başlattığı görünürlük. **Bu denge bozulursa** (veriyi
kendi amacı için kullanan bir üçüncü tarafa geçilirse) hem burası hem Play
beyanı hem `PrivacyModal` birlikte değişir.

### 🧾 Console'a giriş sırası — tür tür cevap kağıdı (12 Eylül 2026)

⚠ **Yukarıdaki eşleme tablosu KATEGORİYE göre değil VERİYE göre yazılmış;
Console ise türleri kendi kategori sırasıyla soruyor.** Form yarıda
kaldığında ("`Name` bitti, dokuz tür kaldı") hangi türün sırada olduğunu
bulmak her seferinde tablonun yeniden çevrilmesini gerektiriyordu. Bu liste
aynı cevapları **Console'un sorduğu sırayla** yazar — tablo TEK kaynak,
burası onun sıralanmış görünümü.

ASC her tür için ÜÇ şey sorar: **amaçlar** (çoklu seçim) · **"Linked to the
User?"** · **"Used for Tracking?"**. Üçüncüsü **her satırda `No`** (Soru 1).

✅ **ONU DA GİRİLDİ VE PUBLISH EDİLDİ** (12 Eylül 2026). Aşağısı artık
"girilecek" değil **"girilmiş olan"** — beyan değişirse buradan okunur.

| # | Kategori → Tür | Amaç(lar) | Linked |
|---|---|---|---|
| ✅ | Contact Info → **Name** | App Functionality | Yes |
| 1 | Contact Info → **Email Address** | App Functionality **+ Developer's Advertising or Marketing** | Yes |
| 2 | User Content → **Photos or Videos** | App Functionality | Yes |
| 3 | User Content → **Other User Content** | App Functionality | Yes |
| 4 | Identifiers → **User ID** | App Functionality | Yes |
| 5 | Identifiers → **Device ID** | App Functionality + Analytics | Yes ⚠ (bölünmüş satır) |
| 6 | Usage Data → **Product Interaction** | App Functionality + Analytics | Yes ⚠ (bölünmüş satır) |
| 7 | Diagnostics → **Crash Data** | Analytics | **No** |
| 8 | Diagnostics → **Other Diagnostic Data** | Analytics | **No** |
| 9 | Other Data → **Other Data Types** | Analytics | Yes |

⚠ **`Third-Party Advertising` ve `Product Personalization` HİÇBİR satırda
işaretlenmez** — reklam ağı yok, kişiselleştirme yok.

⚠ **1. satırdaki ikinci amaç gerçek bir kutuya dayanıyor:** kayıt ekranında
ve hesap ayarlarında *"Pazarlama iletişimi almayı kabul ediyorum"* onayı var
(`AuthModal.tsx` · `AccountSettingsModal.tsx` → `marketing_consent`), yani
e-posta yalnız onay verende pazarlama amacıyla da kullanılıyor. Onay kutusu
kaldırılırsa bu amaç da kaldırılır.

⚠ **9. satır serbest metin İSTEMİYOR** (12 Eylül 2026, Console'dan ölçüldü —
bu dosya önce tersini yazıyordu): `Other Data Types` seçilince doğrudan amaç
ekranına gidiyor, türün adını yazdıran bir alan YOK. Yani beyanda bu türün
NE olduğu hiçbir yere yazılmıyor; kaydı yalnızca burada duruyor →
`profiles.gender` + `profiles.birth_date` (isteğe bağlı), kullanımı yalnızca
admin panelindeki yaş/cinsiyet dökümü (`get_profile_age_gender`).

⚠ **Sonunda `Publish` — `Save` YAYIMLAMAZ.** Sayfanın üstündeki durum
`Published` demeden beyan gönderime girmez. (12 Eylül 2026: basıldı.)

⚠ **Aynı sayfa bir de `Privacy Policy URL` ister** — girilen değer
`https://kelimeki.com/gizlilik/` (§6; eğik çizgi zorunlu). Yanındaki
`Privacy Choices URL` **bilerek BOŞ**: kullanıcıya ayrı bir "veri
tercihleri" sayfası sunmuyoruz, hesap silme uygulamanın içinden ve
`/hesap-silme/`ten yapılıyor ve gizlilik sayfasında anlatılıyor.

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

## 13. Ekran görüntüleri — ✅ **YÜKLENDİ** (kaynak: iOS SİMÜLATÖRÜ, CI)

⚠ Başlık 12 Eylül 2026'da düzeltildi: *"simülatöre GEREK YOK (8 Eylül
2026, ölçüldü)"* diyordu — o iddia **aynı gün çürütülmüştü** ve düzeltme
bu bölümün içindeydi. Bölme sırasında düzeltme arşive gidince başlık
yalnız kaldı; yani bölmenin kendisi bir an için yanlış bilgi üretti.
Ders: bir bölümü bölerken **başlığının hangi cümleyle düzeltildiğine**
bak — düzeltme taşınıyorsa başlık da düzeltilmeli. Numara değişmedi.

**Gereksinim (Apple, 2026):** iPhone için **tek bir set** (6.5" ya da 6.9")
ve iPad için **13"** yeterli. Verilmeyen boyutlar için Apple mevcut setten
ölçekliyor.

| Cihaz sınıfı | Piksel | dpr | Mantıksal |
|---|---|---|---|
| iPhone 6.9" | **1320×2868** | 3.0 | 440×956 |
| iPad 13" | **2064×2752** | 2.0 | 1032×1376 |

⚠ **Kaynak GERÇEK iOS SİMÜLATÖRÜ** — `ios-screenshots.yml` +
`integration_test/`. 8 Eylül'de önce "widget testiyle çizeriz" denmişti;
aynı gün çürütüldü. O yanılgı, ilk piksel ölçümü ve o günün dürüst
sınırları arşivde:
`docs/decisions/app-store-gecmis.md` → "§13 — kare boru hattının kuruluşu".


### Çekim listesi: Android'in AYNISI (kullanıcı kararı, 8 Eylül 2026)

**Liste `marketing/play-store/metin.md` → "Çekim listesi — tek tek"de.**
Buraya KOPYALANMIYOR; tek kaynak orası. Altı zorunlu + bir isteğe bağlı:

1. Oyun ekranı, oyunun ortası — **2 kişilik** *(en önemli kare)*
2. ~~Geçerli bir hamle kurulmuşken~~ → **4 KİŞİLİK oyun** + kurulmuş hamle
   (11 Eylül 2026'da değişti, aşağı bkz.)
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

⚠ **Boru hattının gün gün kütüğü arşivde** (9-11 Eylül 2026): kuruluş,
ilk koşu, kompozisyon bulguları, 2. karenin konu değiştirmesi, kalan dört
karenin eklenmesi, DEBUG bandı yüzünden o güne kadarki bütün setlerin
çöpe gitmesi ve bayat `9c91adb` seti —
`docs/decisions/app-store-gecmis.md` → "§13 — kare boru hattının kuruluşu".
Aşağıdaki blok o turun ÇIKTISI: mağazaya giden kompozisyon kararı.


### ✅ KOMPOZİSYON KARARI — başlıklı set + 7. kare (11 Eylül 2026)

Kullanıcı kararı: **kareler BAŞLIKLI çıkacak** ve **7. kare (k-lig
sıralaması) eklenecek.** Böylece §13'ün açık kalan tek maddesi kapandı.

**Neden başlıklı** (üç ölçüme dayanıyor, tercihe değil):

1. App Store kareleri önce **küçük küçük, yan yana** gösteriyor; o boyutta
   başlıksız bir tahta karesi *"bir oyun tahtası"*ndan fazlasını anlatmıyor.
2. 01/02'nin **alt ~%20'si zaten boş** (9 Eylül'de gözle ölçüldü) — şerit
   için hazır yer var, kare kaybı yok.
   ⚠ **Bu gerekçe ilk uygulamada BOŞA ÇIKTI ve düzeltildi (11 Eylül 2026).**
   Şerit önce `Column` ile uygulamanın ALTINA konuyordu: oyun ekranının boş
   alt alanı yerinde kalıyor, şerit onun altına biniyordu — yani ölü alan
   değerlenmiyordu, kare uzuyordu. Kullanıcı kareye GÖZLE bakınca görüldü.
   Şerit artık `Stack` ile uygulamanın ÜSTÜNE biniyor (kullanıcı kararı).

   ⚠ **AMA "boşluğu doldurur" da DOĞRU DEĞİL — ölçüldü (11 Eylül 2026,
   gerçek karelerden):** modal dikey olarak ORTALANMIŞ, yani kartın altında
   kalan pay şeritten büyük olabiliyor. Şerit 203px (%7,1); 04'te kartın alt
   payı 479px, dolayısıyla **276px (%9,6) beyaz kalıyor**; 06'da 147px
   (%5,1); 05'te hiç kalmıyor çünkü karartma tüm ekranı kaplıyor. Bindirme
   yine de kazanç: `Column`da şerit boşluğun ALTINA ekleniyordu, şimdi
   İÇİNDE.

   **Kullanıcı kararı: kalan boşluk KABUL EDİLDİ** (11 Eylül 2026). Gerekçe:
   şerit bir başlıktır, dolgu değil; yedi karede AYNI kalınlıkta olması seti
   "set" yapan şey. Elenen iki alternatif: şeridi kalınlaştırmak (01/02'de
   oyun ekranının butonlarını örtmeye başlıyor) ve modalı yukarı kaydırmak
   (uygulamada pencere ortalı — kare birebir görüntü olmaktan çıkardı).

   ⚠ **Bindirmenin asıl riski ÖLÇÜLDÜ ve GERÇEKLEŞMEDİ:** 04/05/06'da şerit
   pencerenin alt kenarına değmiyor (en yakını 06, 147px açık). Yine de her
   yeni sette modal kareleri gözle kontrol edilmeli — modal düzeni
   değişirse bu pay kapanabilir.
3. Kareler **sürüme kilitli**: onaylandıktan sonra değiştirmek yeni bir
   gönderim ister (promotional text gibi serbest DEĞİL), yani ilk turda
   doğru olmak zorunda.

**Başlıklar** (kaynak: `store_screenshots_test.dart` → `_kBasliklar`; bu
tablo oradan KOPYA, ikisi ayrışırsa kaynak odur):

| Kare | Başlık |
|---|---|
| `01-oyun-ekrani` | Köşenden başla, bölgeni büyüt |
| `02-dort-kisilik` | Dört oyuncu, dört bölge |
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

⚠ Modal karelerinin oyun ekranının ÜSTÜNDE açılmasını sağlayan değişiklik
(ve `SetupScreen.showDiagnostics` bayrağının doğuşu) arşivde:
`docs/decisions/app-store-gecmis.md` → "§13 — kare boru hattının kuruluşu".


### 🔍 YEREL ÖNİZLEME — CI turu artık zorunlu değil (11 Eylül 2026)

Kullanıcı isteği, birebir: *"Bu görselleri önce resim olarak yap bana
göster ondan sonra ok ise üretime gönderelim. Böyle kaç defa git gel oldu.
Canım sıkıldı artık."*

Gerekçe ölçülü: her kompozisyon düzeltmesi bir macOS koşusu (~14 dk) +
artefakt indirme + gözle bakma turu istiyordu; DEBUG bandı, alfa ve
"pencere boşlukta" arızalarının üçü de bu turlarla bulundu.

**`npm run preview-store-frames`** (kök dizinden) aynı yedi kareyi
**Linux'ta, `flutter test` içinde, ~14 saniyede** üretir →
`mobile/app/build/frame-preview/*.png` (repoya girmez, `build/`
gitignore'da).

⚠ **İKİ cihaz ölçüsünde de çizer** — CI matrisinin birebir karşılığı
(iPhone 6.9" `1320×2868` · iPad Pro 13" `2064×2752`, ikincisi `ipad/` alt
klasörüne). Tek ölçü YETMEZDİ: iPad düzeni gerçekten farklı akıyor (daha
geniş, daha kısa) ve şerit oranı bile iPad'de ayrı bir yükseklik tavanı
gerektirmişti. Alt komutlar: `preview-store-frames:iphone` /
`:ipad` (`KARE_CIHAZ` ortam değişkeni).

| | CI (`ios-screenshots.yml`) | Yerel önizleme |
|---|---|---|
| Nerede | macOS + gerçek iOS simülatörü | Linux, `flutter test` |
| Süre | ~14 dk | ~14 sn (iki cihaz) |
| Çıktı | **mağazaya giden set** | yalnızca GÖZ İÇİN |
| Kurulum | `store_frames.dart` | **AYNI** `store_frames.dart` |

⚠ **Önizleme mağaza karesi DEĞİL** — iki bilinen fark var ve ikisi de
önizlemeye özgü:

1. **Material Icons yüklenmiyor** → ✕ kapatma tuşu ve madde imleri boş
   kutu (□) çıkar. Gerçek simülatörde düzgün.
2. **`sqflite` yok** → 05'in anlam metni önizlemede elle verilmiş bir
   `MeaningEntry`'den gelir (CI'da gerçek `meanings.db`'den).

Bu yüzden kapı DEĞİŞMEDİ: mağazaya giden set hâlâ CI'ın ürettiğidir ve
hâlâ bir insan gözüyle açılmak zorundadır (DEBUG bandı dersi). Önizlemenin
işi **kompozisyonu** (hangi ekran, ne görünüyor, şerit nereye biniyor)
CI'dan ÖNCE karara bağlamak.

**Ortak kurulum tek dosyada:** `integration_test/store_frames.dart` — sahne
kurma (`midGameState`, `oyunKontrolcusu`, `oyunEkrani`, `kurulumEkrani`),
başlık tablosu (`kBasliklar`), şerit (`bantli`) ve sahte servisler orada.
CI testi (`store_screenshots_test.dart`) ve önizleme
(`test/store_frames_preview_test.dart`) ikisi de onu `import` eder — yani
**ikisi aynı kareyi çizer**, ayrışamazlar. Önizleme `KARE_ONIZLEME=1`
kapısının arkasında: normal `flutter test` koşusunda atlanır (CI'da PNG
üretmenin anlamı yok).

### Kalan iş

Kod tarafında kalan iş YOK. Kareler bir sonraki `ios-screenshots.yml`
koşusunda başlıklı, yedi kare ve **alfasız** üretilir; **artefaktı indirip
Console'a yüklemek elle** (ajan indiremiyor — yukarıdaki uyarı).

⚠ **`9c91adb` seti de artık bayat** (11 Eylül 2026): 04/06/07 pencereyi
boşlukta gösteriyordu ve 02 iki kişilikti. Mağazaya gidecek set, modal
düzeltmesinden SONRAKİ koşunun çıktısıdır — kompozisyon yerel önizlemeyle
onaylandı, ama yüklenecek dosyalar CI'ınkiler.

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

✅ **ÇÖZÜLDÜ VE DOĞRULANDI (11 Eylül 2026, 12:08 — ekran görüntüsü).**
Sürüm kaydı `1.1.0` yapıldı, derleme iliştirildi; Apps listesinde **ikon
göründü** (jenerik ızgara gitti, yerine uygulamanın kendi ikonu) ve satır
artık `iOS 1.1.0 Prepare for Submission` diyor. Yani teşhis doğruydu: ikon
derlemeden geliyor, sürüm kaydı eşleşmeden derleme iliştirilemiyor.

⚠ **İkonun GÖRÜNMESİ bu teşhisin kanıtı, ama tek başına bir ölçüt olarak da
değerli:** "sürüme derleme bağlı mı" sorusunun Apps listesinden okunabilen
görsel karşılığı bu. Bir sonraki sürüm turunda ızgara geri gelirse ilk
bakılacak yer yine buradaki eşleşmedir.

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

### 📦 MAĞAZAYA GİDEN SET — `017e2de`, 11 Eylül 2026 (koşu #21)

Koşu https://github.com/alpcapa/kelimeki/actions/runs/34600529235 — iki iş
de yeşil (`iphone-6.9`, `ipad-13`). PR #523 merge edildi (`8708896`).

**Dört kapı da geçti, ölçümler işin kendi logundan:**

| Kapı | iPhone 6.9" | iPad Pro 13" |
|---|---|---|
| Kare sayısı (`KARE_SAYISI: 7`) | 7 ✅ | 7 ✅ |
| Piksel ölçüsü | 7/7 `1320×2868` ✅ | 7/7 `2064×2752` ✅ |
| Alfa kanalı | 7/7 `alfa: no` ✅ | 7/7 `alfa: no` ✅ |
| Debug bandı (`CheckedModeBanner` iddiası) | yok ✅ | yok ✅ |

| Artefakt | Boyut |
|---|---|
| `kelimeki-store-screenshots-iphone-6.9` | 2.753.871 bayt |
| `kelimeki-store-screenshots-ipad-13` | 2.808.574 bayt |

Geçerlilik **10 Aralık 2026**.

**Bu setin öncekinden farkı** (hepsi kullanıcının önizlemeye bakıp verdiği
kararlar): 04 · 06 · 07 pencereyi oyun ekranının üstünde açıyor · şerit
zemini `kAccent` (uygulamanın mavisi, beyaz yazı) · 02 dört kişilik oyun ·
03'te 4 "SIRA SENDE" + 3 "SIRA RAKİPTE" · 03'te teşhis satırı yok
(`showDiagnostics: false`, üründe DURUYOR).

⚠ **Kompozisyon bu kez CI'dan ÖNCE onaylandı** — yedi kare iki cihaz
ölçüsünde yerelde çizilip kullanıcıya gösterildi, onay alındıktan sonra
pushlandı. §13'ün "bir mağaza görseli insan gözü olmadan onaylanamaz"
kuralı değişmedi; değişen, o gözün CI'ı beklememesi.

⚠ **Yükleme öncesi son adım hâlâ insan:** artefaktı aç, yedi kareye de bak.
Şekil kapıları (sayı · ölçü · alfa · bant) içeriği GÖREMEZ — DEBUG bandı
dersi tam olarak buydu.

### 🔴 iPAD'DE 06. KARE PENCERESİZ ÇIKTI — beşinci "kapılar içeriği göremez" vakası (11 Eylül 2026)

Kullanıcı artefaktı indirip baktı: **iPad setinde `06-nasil-oynanir.png`,
`01-oyun-ekrani.png` ile aynıydı.** Şerit doğruydu ("Kuralları üç dakikada
öğren"), ama yardım penceresi hiç açılmamıştı — altta çıplak oyun ekranı.
**iPhone setinde aynı kare sorunsuzdu.**

**Dört kapı da yeşil kaldı** (7 kare · `2064×2752` · alfa yok · debug bandı
yok), çünkü üçü de dosyanın ŞEKLİNE bakıyor. Bu, aynı dersin BEŞİNCİ tekrarı
(öncekiler: DEBUG bandı · alfa kanalı · pencerelerin boşlukta durması ·
01-02'nin aynı olması). Ortak kök: **bir mağaza görselini yalnızca insan gözü
ya da İÇERİĞE bakan bir iddia doğrulayabilir.**

**Kök sebep:** kare `settle()`nin SABİT üç `pump`ından sonra çekiliyordu.
Pencere açılış animasyonu o üç karede bitmezse kare arka planı yakalıyor ve
bu cihazdan cihaza değişiyor — iPhone'da yetti, iPad'de yetmedi.

**Düzeltme — kapı, çözümün kendisi:** `pencereyiBekle()`
(`integration_test/store_frames.dart`) pencere BULUNANA kadar pump ediyor
(tavan 10 sn), sonra oturması için `settle()`. Bulamazsa `expect` düşer, yani
**koşu kırmızıya döner**; kare artık sessizce yanlış çıkamaz. Dördü de
(04 · 05 · 06 · 07) bu kapıdan geçiyor, önizleme testi de aynısını kullanıyor.

⚠ **Kapının duyarlılığı KANITLANDI:** `showHelpModal` çağrısı geçici olarak
silinip koşuldu → test düştü (*"pencere 10 sn içinde ekrana gelmedi"*),
sonra geri alındı. Bir kapıyı "eklendi" diye yazmadan önce onu düşürmeyi
dene — yoksa yalnızca yeşil bir satır eklenmiş olur.

⚠ **Ders, bir sonraki kare eklenirken:** bir karede EKRANDA OLMASI GEREKEN
bir şey varsa (pencere, sekme, rozet), onu `find` ile İDDİA ET. Sabit sayıda
`pump` bir zamanlama VARSAYIMIDIR ve bu boru hattında iki kez yanlış çıktı.

### ✂️ 05 (kelime anlamı) SETTEN ÇIKTI — altı kare (11 Eylül 2026)

Kullanıcı iPhone setini Console'a yükledi ve **kelime anlamı karesini
almadı**: *"çok anlamlı değil"*. Doğru karar — o pencere tek bir TDK
tanımını gösteriyor, yani vitrinde oyunun ayırt edici tarafını değil
sıradan bir sözlük kutusunu anlatıyordu.

**Boru hattı da 6'ya indirildi** (yalnız Console'da atlanmadı): testten,
önizlemeden, başlık tablosundan ve `KARE_SAYISI` kapısından çıkarıldı.
Gerekçe: üretilmeye devam etse her koşu kimsenin kullanmadığı bir kareyi
çizip ölçerdi ve **"7 kare" kapısı mağazadaki 6 ile çelişirdi** — bir kapı
yanlış sayıyı bekliyorsa artık kapı değildir.

⚠ **Numaralar DEĞİŞMEDİ — set `01 · 02 · 03 · 04 · 06 · 07`, arada boşluk
var.** Bilinçli: bu dosyadaki onlarca not kareleri numarasıyla anıyor
(*"06 iPad'de penceresiz çıktı"*, *"02 konu değiştirdi"*), yeniden
numaralamak o atıfların hepsini sessizce yanlışlardı — `ROADMAP.md`'nin
"başlığı/numarayı değiştirme, atıflar kırılır" kuralının aynısı. Mağazadaki
sıra dosya adından değil YÜKLEME sırasından geldiği için boşluğun işlevsel
bir maliyeti yok.

**Geri almak tek commit:** `store_screenshots_test.dart` + önizlemedeki
`05` testi, `kBasliklar`daki satır, `kMeaningWord` ve `KARE_SAYISI: 7`.
Anlam penceresinin KENDİSİ üründe duruyor — çıkan yalnızca mağaza karesi.

#### ✅ KAPANDI: 7. kare **rütbeler** oldu (11 Eylül 2026, aynı gün)

Kullanıcı aday listesine baktı ve seçti: *"Evet rütbelerden hiç
bahsetmiyoruz. Bence o olabilir."* → **`08-rutbeler`** (numara `05` değil;
gerekçe aşağıda). Önizleme iki cihazda çizilip gösterildi, onaylandı
(*"Ok'dir"*), sonra pushlandı — süreç kuralı bu turda baştan sona işledi.

**Kare ne gösteriyor:** `RankInfoModal`, oyun ekranının üstünde. 57 puan →
**Meraklı** (eşik 50), sıradaki **Oyuncu** 100'de; ilerleme çubuğu yarı
dolu, altında ödül rakamları (`+5` / `+10`). Sayılar 04 ve 07 ile TUTARLI
seçildi — daha gösterişli bir mühür için yüksek bir rütbe konabilirdi ama
aynı sahte oyuncu 07'de 57 puanla 4. sırada görünüyor; uydurma dünyanın
tutarlılığı gösterişten önce gelir.

⚠ **Karenin sınırı:** pencere merdivenin TAMAMINI göstermiyor (üründe de
göstermiyor) — mevcut rütbe + sıradaki + ödül var, dokuz kademenin listesi
yok. Yani kare *"rütbe sistemi var ve ilerliyor"* diyor, *"şu dokuz rütbe
var"* demiyor.

**ZOOM elendi** (kullanıcı: *"bir de zoom var ama onu görsel olarak
anlatmak zor"*). Doğru: zoom bir JEST, tek kare hareketi gösteremez;
yakınlaştırılmış tahtanın görüntüsü 01 ile karışır. Anlatılabilir tek yolu
"önce/sonra" bölünmüş bir kare olurdu, o da mağaza karesini infografiğe
çevirirdi.

**Aday listesi AŞAĞIDA DURUYOR** — bir sonraki boş slot için (Apple 6.9"da
10 kareye izin veriyor) hâlâ geçerli; seçilen satır rütbelerdi.

#### (arşiv) Slot açıkken yazılan aday listesi

*"Düşünüp başka hangi özelliği 7. kare olarak ekleyebiliriz diye bakacağım
daha sonra."* Yani altı kare bir son durum DEĞİL, geçici bir durak — slot
boş duruyor. (Apple 6.9" için 10 kareye kadar izin veriyor, yani tavan
sorun değil.)

**Bugünkü altı karenin ANLATMADIĞI şeyler** — aday ararken buradan bakılsın:

| Anlatılmayan | Neden aday |
|---|---|
| **Oyun sonu / kazanma** (`GameOver` + k-lig puanı) | Vitrinde hiç "kazandım" anı yok; oyunun ödül döngüsü görünmüyor |
| **Oynayarak öğren tanıtımı** (`TutorialGame`) | *"60 saniyede öğren"* vaadi — indirme kararına doğrudan konuşur |
| **Oyun içi mesajlaşma** | Canlı oyunun sosyal tarafı; 03 yalnızca listeyi gösteriyor |
| **YZ zorluk seçimi** (Kolay · Normal · Zor) | Tek kelimelik farklılaşma, kurulum ekranında zaten var |
| **Rütbe mührü / k-lig ödülleri** (`RankInfoModal`) | 07 sıralamayı gösteriyor ama ÖDÜLÜ göstermiyor |

⚠ **Yeni kare eklerken:** numara olarak **`05`i KULLANMA** — o ad kelime
anlamı karesinin geçmişine bağlı ve bu dosyadaki notlarda öyle geçiyor.
Sıradaki boş numara **`08`**. Eklenince `KARE_SAYISI` da 7'ye çıkar
(kapı sayıyı sabit bekliyor) ve kare `pencereyiBekle` kapısından geçmek
zorunda.

#### 🔍 9. kare: ZOOM — elenmişti, geri alındı (11 Eylül 2026)

Kullanıcı: *"10 kare hakkımız varsa zoom'u da koysaydık keşke"*. İlk turda
şu gerekçeyle elenmişti: zoom bir JEST, tek kare hareketi gösteremez.
Gerekçe hâlâ doğru ama **eksikti** — jesti anlatmak gerekmiyor, SONUCUNU
göstermek yetiyor. Kare gerçek bir çift dokunuşla 2× büyümüş tahtayı
gösteriyor; harfler iri olduğundan 01 ile karışmıyor.

**Jest GERÇEK, sahnelenmiş değil:** `tester.tapAt` ×2, üretim yolundan
(`board_zoom.dart`in 300 ms / 40 px çift penceresi). Sahte bir "zoom'lu
görünüm" çizilmedi.

⚠ **Nişan noktası bir hücrenin İÇİ DEĞİL, iki hücre ARASINDAKİ ızgara
sınırı** (`kBoardPad + k*adım`). Ölçüldü: hücre kutusuna inen dokunuş, harf
seçili olmadığından ekrana *"Önce bir harf seç."* yazdırıyor ve mağaza
karesinde gerçek oyun mesajının ("Yapay Zeka …oynadı. +22 puan.") yerini
alıyordu. Boşluğa inen dokunuş `_pointHitsCellBox` false döndüğü için hücre
işleyicisine hiç gitmiyor, çift yine sayılıyor.

⚠ **Kapısı `pencereyiBekle` DEĞİL** — aranacak bir pencere yok. `zoomKapisi`
zoom matrisinin ölçeğini okuyor (`kBoardZoomScale` = 2.0): jest tutmazsa
kare sessizce **01'in kopyası** olurdu, yani iPad'de 06'nın başına gelen
şeyin aynısı. Duyarlılık kanıtlandı: ikinci dokunuş silinip koşuldu → test
düştü (*"tahta yakınlaşmamış (bulunan ölçekler: [1.0, 1.0])"*).

**Varyant seçimi kullanıcıda:** üç odak noktası ayrı ayrı çizilip
gönderildi (boş alan · harf kümesi · kart çerçevesi), kullanıcı **harf
kümesini** seçti. Sonra uyarı metni sorunu yukarıdaki ızgara-sınırı
nişanıyla ayrıca giderildi — yani seçilen çerçeveleme + temiz mesaj satırı.

**Set artık SEKİZ kare:** `01 · 02 · 03 · 04 · 06 · 07 · 08 · 09`
(`KARE_SAYISI: 8`). Apple 6.9" için tavan 10.

### 📦 MAĞAZAYA GİDEN SET — `7b0d158`, koşu #26 (11 Eylül 2026, SEKİZ kare)

Koşu https://github.com/alpcapa/kelimeki/actions/runs/34608610658 — iki iş de
yeşil. PR #524 merge edildi (`9b4a793`). **Bir önceki kayıt (#21, yedi kare)
artık bayat** — o set 05'i içeriyordu ve 08/09 yoktu.

**Set:** `01 · 02 · 03 · 04 · 06 · 07 · 08 · 09` (05 bilerek yok, numara
boşluğunun gerekçesi yukarıda).

| Kapı | iPhone 6.9" | iPad Pro 13" |
|---|---|---|
| Kare sayısı (`KARE_SAYISI: 8`) | 8 ✅ | 8 ✅ |
| Piksel ölçüsü | 8/8 `1320×2868` ✅ | 8/8 `2064×2752` ✅ |
| Alfa kanalı | 8/8 `alfa: no` ✅ | 8/8 `alfa: no` ✅ |
| Debug bandı | yok ✅ | yok ✅ |
| **Pencere açıldı mı** (`pencereyiBekle`) | ✅ | ✅ |
| **Tahta yakınlaştı mı** (`zoomKapisi`) | ✅ | ✅ |

| Artefakt | Boyut |
|---|---|
| `kelimeki-store-screenshots-iphone-6.9` | 3.568.965 bayt |
| `kelimeki-store-screenshots-ipad-13` | 3.434.972 bayt |

Geçerlilik **10 Aralık 2026**.

⚠ **Son iki kapı bu turda ilk kez koştu ve ikisi de İÇERİĞE bakıyor** —
önceki dört kapı yalnızca dosyanın ŞEKLİNE bakıyordu ve beş ayrı
kompozisyon arızasını görememişti. iPad'de 06'nın penceresiz çıkması bu
sayede bir daha sessizce geçemez.

**✅ YÜKLEME TAMAM (11 Eylül 2026, 19:04):** **sekiz karenin sekizi de İKİ
tarafa yüklendi** — iPhone 6.9" **8/10** ve iPad 13" **8/10** (Console'dan
ölçüldü). Set: `01 · 02 · 03 · 04 · 06 · 07 · 08 · 09`. Rütbe mührü son
koşuda (#29, `c22b757`) doğru çıktı ve kullanıcı gözle doğruladı — yani
`animasyonBitsin` kapısı işe yaradı.

⚠ 6.5" iPhone ve 11" iPad kendi setlerini İSTEMİYOR: ikisi de büyük
kardeşinin setini kullanıyor ("Using 6.9\" Display" / iPad 13").

**Kaynak artefakt:** koşu #29 →
`kelimeki-store-screenshots-iphone-6.9` (3.801.314 bayt) ·
`kelimeki-store-screenshots-ipad-13` (3.552.186 bayt).

⚠ **Sıradaki turda bu kareler YENİDEN üretilirse tekrar yüklenmeleri
gerekir** — Console'daki dosyalar artefaktın kopyası, bağlantılı değil.

### 🔴 RÜTBE MÜHRÜ ÇIKMADI — altıncı "kapılar içeriği göremez" vakası (11 Eylül 2026)

Kullanıcı 08 ve 09'u Console'a yükledi ve **08'de mührün hiç olmadığını**
gördü: pencerenin üst kısmı bomboş beyaz, oysa orada büyük mavi kurdele
olmalı. (Ekran görüntüsündeki küçük önizleme büyütülerek doğrulandı.)

**Kök sebep:** `RankInfoModal`ın **1000 ms'lik giriş animasyonu** var ve
rütbe mührü SON fazda. `pencereyiBekle` pencerenin VAR OLDUĞUNU doğruluyordu,
**çizilmiş olduğunu değil**; ardından gelen `settle()` yalnızca 800 ms
ilerletiyordu. Kare animasyonun ortasında çekiliyordu.

⚠⚠ **ÖNİZLEME BU SINIFI YAPISAL OLARAK GÖREMEZDİ.** `flutter test` altında
`MediaQuery.disableAnimations` **TRUE** geliyor: modal anında son karesine
atlıyor ve mühür her zaman tam çizilmiş görünüyor. Gerçek simülatörde
(`integration_test`) animasyon gerçekten koşuyor. Yani "önce yerelde bak"
süreci — ki bu turun en değerli kazanımıydı — **animasyon zamanlamasına
kör**. Ölçüldü: mühür bölgesinde beyaz olmayan piksel sayısı beklemeli
23.370, beklemesiz 23.639 — yani yerelde iki hâl AYNI.

**İki düzeltme birden:**

1. **`animasyonBitsin`** — pencere bulunduktan sonra *zamanlanmış kare
   kalmayana* kadar ilerletiliyor (tavan 5 sn). Sabit bir süre yazmak aynı
   hatayı bir sonraki pencerede tekrarlardı. ⚠ `pumpAndSettle` BİLEREK
   kullanılmadı: sonsuz bir animasyon varsa o fırlatır. **Tavana çarpmak
   artık koşuyu DÜŞÜRÜYOR** — kare animasyonun ortasında sessizce
   çekilemesin diye.
2. **Önizlemede animasyonlar AÇIK** — `bantli` artık
   `disableAnimations: false` veriyor, böylece iki yol aynı zemine oturuyor.

⚠ **Bu düzeltme YERELDE KANITLANAMAZ** (yukarıdaki ölçüm): kanıt bir
sonraki CI koşusundaki 08. karedir. Bu, önizlemenin dürüst sınırı —
kompozisyonu kanıtlar, ZAMANLAMAYI kanıtlamaz.

**Altı vakanın ortak dersi:** şekil kapıları (sayı · ölçü · alfa · bant)
içeriği göremez; içerik kapıları (`pencereyiBekle` · `zoomKapisi` ·
`animasyonBitsin`) tek tek, hep bir arıza YAŞANDIKTAN sonra eklendi. Yeni
bir kare eklerken sıra şu: *ekranda olması gereken neyse onu `find` ile
iddia et, sonra animasyonun bittiğini bekle.*

