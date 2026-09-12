# App Store Connect — kapanmış vaka anlatıları (arşiv)

> `marketing/app-store/console-formlari.md`'den ayrıldı (12 Eylül 2026):
> **cevap kağıdı orada kaldı, kapanmış vaka anlatıları buraya geldi.**
> Kesme noktası boyut değil İÇERİĞİN TÜRÜ — "Console'a ne yazılacak" ile
> "o cevaba nasıl gelindi" ayrı şeyler ve ikincisi yalnızca o vakaya
> dönüldüğünde gerekiyor.
>
> ⚠ **Bu dosyayı BAŞTAN SONA OKUMA — `grep`'le ara.** Bir `reference`
> dokümanı: üç kapanmış vakanın adım adım kütüğü.
>
> ⚠ **Hiçbir satır değiştirilmedi**, bölüm numaraları (`§3`, `§13`)
> korundu — cevap kağıdındaki işaretçiler buraya bu adlarla bakıyor.
>
> **Ne KALMADI burada:** işleyen kurallar ve durum kayıtları cevap
> kağıdında duruyor — anahtarın künyesi, *"API anahtarı imzalama için
> zorunlu değil"*, *"değerler bu dosyaya yazılmaz"*, **24.2 kurulum durumu
> tablosu**, 24.2'nin doğrulandığı koşu, çekim listesi, Android setinden
> iki fark, mağazaya giden kompozisyon kararı, eksik kare kuralı, alfa
> kanalı kuralı ve yerel önizleme.

## §3 — `.p8` indirilemedi (8-9 Eylül 2026)

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

## §3 — 24.2 zincirinin koşuları (9 Eylül 2026)

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

## §13 — kare boru hattının kuruluşu (8-11 Eylül 2026)

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

### 2. kare KONU DEĞİŞTİRDİ — 4 kişilik oyun (11 Eylül 2026)

⚠ **Kullanıcı kareleri yan yana görünce yakaladı:** *"1 ve 2 neredeyse
aynı... ilk slayt 2, ikinci slayt 4 kişilik oyun örneği göstermeli. 4
kişilik oyun bize özel ve başka hiçbir kelime oyununda yok."*

Haklıydı: ikisi de AYNI 2 kişilik tahtaydı, tek fark kurulmuş hamleydi —
yani iki kare tek bir şeyi anlatıyordu ve ürünün en ayırt edici özelliği
(4 kişilik oyun) sette HİÇ görünmüyordu.

Kare artık **`02-dort-kisilik`**: dört skor kutusu, tahtada dört ayrı bölge.
⚠ **Kurulmuş hamle KORUNDU** — yeşil dış hat + puan rozeti kareyi canlı
tutuyor ve dört bölge anlatısıyla yarışmıyor (biri tahtanın rengi, öteki tek
bir kelimenin çerçevesi). Yani konu değişirken hiçbir şey kaybedilmedi.

**Tohum yine ELLE SEÇİLMEDİ**, motor koşturularak ölçüldü — 1. kareyle AYNI
ölçütler: dört bölge de büyümüş · oyuncu ezilmiyor · raf oynanabilir · tahta
dolu · skorlar çekişmeli. 60 tohum × 2 hamle sayısı tarandı, beş aday geçti,
**tohum 12 / 20 hamle** seçildi:

| | |
|---|---|
| Taş | 71 |
| Skorlar | **72-68-61-77** (fark 16 — çekişmeli) |
| Bölgeler | **30/24/24/27** — dördü de net okunuyor, oyuncununki en büyük |
| Raf | `UAAKLŞI` — 4 ünlü + 3 sessiz, yani ekranda oynanabilir bir el var |

⚠ Elenen aday **26**: skorlar 73-73-73-77'de eşitleniyordu ve karede
**uydurma** duruyordu.

### (arşiv) 2. karenin ÖNCEKİ hâli — kurulmuş hamle, 9 Eylül 2026

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

### 🔴 DEBUG BANDI — bugüne kadarki BÜTÜN kareler geçersiz (11 Eylül 2026)

**Kullanıcı artefaktı indirip PNG'ye baktı ve sağ üst köşede kırmızı bir
`DEBUG` şeridi gördü.** Şerit Flutter'ın kendi işareti: `flutter drive`
uygulamayı **debug modda** derliyor ve `MaterialApp` o modda
`debugShowCheckedModeBanner`ı varsayılan `true` kabul edip bandı çiziyor.
Depoda bu bayrak hiçbir yerde kapatılmamıştı.

**Kapsam: yedi karenin yedisi, bugüne kadarki HER koşu.** Üretim
derlemesinde bant görünmez (debug'a özgü), yani uygulamanın hatası değil —
yalnızca bu boru hattının.

⚠ **Neden hiçbir kapı yakalamadı:** kare sayımı, piksel ölçüsü ve alfa
kontrolü üçü de dosyanın **ŞEKLİNE** bakıyor, **İÇERİĞİNE** değil. Ajan da
artefaktı indiremediği için (iki kapı kapalı, §"TAZE KARELER") kareyi hiç
GÖREMEDİ. Arızayı bulan tek şey bir insanın PNG'ye bakması oldu.

**Düzeltme:** `debugShowCheckedModeBanner: false` altı `MaterialApp`ta da.
**Kapı:** her kare artık tek bir `_kareCek` yardımcısından geçiyor ve o
yardımcı kareyi yazmadan ÖNCE `CheckedModeBanner`ın ağaçta OLMADIĞINI iddia
ediyor. Duyarlılığı ölçüldü: bayrak açıkken widget ağaçta (iddia düşer),
kapalıyken yok. ⚠ Yeni bir kare eklerken `binding.takeScreenshot`i DOĞRUDAN
çağırma — iddia atlanır.

**Ders (bu dosyaya yazılan asıl şey):** bir üretim hattının çıktısını
yalnızca ölçüyle doğrulamak yetmiyor; **kareye BAKAN biri olmadan mağaza
görseli onaylanamaz.** Ajan bakamıyor, o yüzden her yeni sette kullanıcının
en az bir kareyi açması akışın zorunlu adımı.

### 📦 (BAYAT) KARELER — `9c91adb`, 11 Eylül 2026

⚠ **BU SET ARTIK MAĞAZAYA GİTMİYOR.** Aşağıdaki dört kapıyı geçmişti ama
kompozisyonu kullanıcı reddetti (pencereler boşlukta, siyah şerit, 03'te üç
satırlık liste, teşhis satırı). Yerine geçen set: *"MAĞAZAYA GİDEN SET"*
başlığı (aşağıda, `017e2de`). Blok SİLİNMEDİ — dört kapının o turdaki
ölçümü ve gözle doğrulama kaydı burada duruyor.

Koşu
https://github.com/alpcapa/kelimeki/actions/runs/34589392557 — yeşil.
Dört kapı da geçti: **7 kare** · tam piksel ölçüsü · **alfa yok** ·
**debug bandı yok**. Kompozisyon bindirmeli şerit.

| Artefakt | Boyut |
|---|---|
| `kelimeki-store-screenshots-iphone-6.9` | 2.415.873 bayt |
| `kelimeki-store-screenshots-ipad-13` | 2.015.385 bayt |

Geçerlilik **10 Aralık 2026**.

✅ **GÖZLE DOĞRULANDI (kullanıcı, 11 Eylül 2026):** 04 · 05 · 06 açıldı —
debug bandı yok, şerit okunur, pencerelerin altı kesilmiyor. ⚠ **07 (k-lig)
bu turda gözle bakılmadı** — yüklemeden önce ona da bir bakılmalı.

⚠ **Önceki setlerin HEPSİ çöp** (debug bandı).

| Çöpe giden set | Neden |
|---|---|
| #9 · `2015ab6` (6 kare) | başlık yok · alfa · **debug bandı** |
| #10 · `538ecc4` | `KELİMELİK` · `Ironman` · alfa · **debug bandı** |
| `49182b0` | `Ironman` · alfa · **debug bandı** |
| `bb12fe7` | alfa · **debug bandı** |
| `7d6361e` / `6382820` (main) | **debug bandı** |

⚠ **Ajan artefaktı İNDİREMEZ — İKİ kapı birden kapalı** (11 Eylül 2026'da
ölçüldü). (1) GitHub MCP'de indirme aracı yok. (2) API'nin indirme ucu
`productionresultssa*.blob.core.windows.net`e yönlendiriyor ve oturumun
çıkış vekili o hedefi reddediyor (`connect_rejected`) — yani **`curl` de
çözmüyor**, denemeye değmez. Kareleri GÖRMEK gerekiyorsa PNG'lerin sohbete
eklenmesi gerekiyor; debug bandı vakası bunun neden bir formalite değil
GERÇEK bir kapı olduğunu gösterdi.

⚠ **Ajan bu iş akışını TETİKLEYEMEZ** (10 Eylül 2026'da denendi):
`workflow_dispatch` 403 döndü — GitHub App'in `actions: write` izni yok.
Elle koşu: **Actions → "iOS mağaza ekran görüntüleri" → Run workflow**.

⚠ **İKİNCİ tetikleme tuzağı — dal OLUŞTURAN push koşu başlatmıyor**
(11 Eylül 2026'da ölçüldü). Bir PR merge edilince GitHub dalı kendiliğinden
siliyor; sonraki `git push -u` o dalı YENİDEN OLUŞTURUYOR ve bu push'ta
`on: push: paths:` filtresi eşleşmiyor (karşılaştırılacak önceki commit
yok). Ölçüm: `integration_test/` değişmiş olmasına rağmen o sha için koşu
sayısı **0**. `pull_request` de kurtarmıyor — bu iş akışında öyle bir
tetikleyici YOK.

**Çözüm:** dal artık VAR olduğuna göre ikinci bir commit push etmek normal
bir push olayı üretir ve filtre çalışır. (Boş commit ATMA — deponun kuralı;
gerçek bir değişiklikle birleştir.) Alternatif: kullanıcı Actions'tan elle
koşturur.

⚠⚠ **KARŞI ÖLÇÜM — aynı gün, aynı iş akışı, TERS sonuç (11 Eylül 2026).**
Yukarıdaki nottan birkaç saat sonra `claude/dal-yok-acik-pr-yok-qd4uin`
dalını OLUŞTURAN push **koşuyu tetikledi** (koşu #21,
`017e2de`, iki iş de yeşil). Yani kural *"dal oluşturan push asla
tetiklemez"* DEĞİL — iki ölçüm de gerçek, davranış güvenilmez.

**Nota dokunulmadı, iki yön de burada dursun diye yazıldı.** Pratik sonuç
değişmiyor, yalnızca teşhis sırası değişiyor: **push'tan sonra koşu
listesini OKU** (`list_workflow_runs`, o sha için satır var mı). Varsa iş
bitti; yoksa yukarıdaki çözüm (ikinci gerçek commit ya da elle koşu).
"Tetiklemez" diye varsayıp ikinci bir commit uydurmak da, "tetikler" diye
varsayıp beklemek de yanlış — ikisi de ÖLÇÜLEREK ayrılır.

### 🖼 MODAL KARELERİ ARTIK OYUN EKRANININ ÜSTÜNDE (11 Eylül 2026)

**Kullanıcı taze seti gözle inceledi ve reddetti:** *"Tüm modal ekranları
(skor kart, k-lig tablosu, vb) normal ekran görüntüsünde olmalı. Yani
arka planda oyun açıkken mesela. Böyle sadece onları koymak çok iyi ve
anlamlı değil."*

Sorun: 04 (skor kartı), 06 (nasıl oynanır) ve 07 (k-lig) pencereyi **boş
bir `Scaffold` üstünde** çiziyordu — mağaza karesi bir pencereyi bağlamsız
gösteriyordu, arkasında oyun yoktu. 05 (kelime anlamı) baştan beri doğruydu
(oyun ekranından gerçek bir taşa dokunarak açılıyordu).

**Düzeltme:** üçü de artık oyun ekranını kurup pencereyi ÜRETİMİN kendi
yardımcısıyla onun üstünde açıyor — `showScoreCard` · `showHelpModal` ·
`showLeaderboard`, `navKey.currentContext!` üzerinden. Yani karartma, arka
plandaki tahta, skor kutuları ve raf gerçek; kare uygulamanın gerçek bir
anını gösteriyor.

⚠ **Yan kazanç:** karartma tüm ekranı kapladığından bu üç karede alttaki
ölü alan da beyaz kalmıyor (yukarıdaki "%9,6 beyaz" ölçümü bu değişiklikle
konu dışı kaldı). Ölü alan yalnızca pencere AÇILMAYAN karelerde (01 · 02 ·
03) duruyor ve orada uygulamanın gerçek hâli.
