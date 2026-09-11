# Sürüm Kütüğü — Play'e yüklenen her paket

**Bu dosya KANONİK kaydıdır:** hangi sürüm, hangi `versionCode`, hangi
commit'ten, ne zaman yüklendi ve şu an ne durumda. "Yayında olan paket
hangisi?" sorusunun tek cevap yeri burasıdır.

**Neden ayrı bir dosya (4 Eylül 2026, kullanıcı isteği):** kütük daha önce
`build-and-distribution-log.md`in içinde, "Play Store İmzalama" bölümünün
altında bir alt başlıktı — yani adı imzalamayı anlatan 25 KB'lık bir karar
kaydının içinde gömülüydü ve bulunması için önce o dosyayı bilmek
gerekiyordu. Kullanıcı *"bir tane App version dosyası yap, bugüne kadar
çıkan tüm sürümleri güncel tut"* dedi. İçerik taşındı, **kopyalanmadı**;
eski yerinde yalnızca buraya bir işaret var.

⚠ Bu dosyanın kendisi bir bölünme dersinin ürünü: 2 Eylül 2026'ya kadar
kütük diye bir şey YOKTU, "hangi `versionCode` yayında" bilgisi
`ROADMAP.md`'nin sürüm turu bölümüyle karar kaydı arasında ikiye bölünmüştü
ve biri kapanırken öteki kapanmamıştı. **İş bölümü:** burası hangi PAKETİN
yayında olduğunu tutar; `ROADMAP.md` sürüm TURUNU (ne girdi, hangi kapı
açıldı) anlatır; `docs/decisions/roadmap-arsiv.md` kapanmış turları saklar.

---

## `versionCode` nereden geliyor

`.github/workflows/mobile-build.yml`:

```
flutter build appbundle --release "--build-number=${{ github.run_number }}"
```

Yani **`versionCode` = GitHub Actions koşu numarası.** `pubspec.yaml`'daki
`+1` Play'e HİÇ gitmez — orada hep `+1` yazması bir hata değil, CI onu
eziyor. (Play aynı `versionCode`'u iki kez kabul etmediğinden `pubspec`'in
sabit değeri ikinci yüklemede reddedilirdi; kural bu yüzden var.)

Pratik sonuç: **`versionCode` bir koşu numarasıdır**, o koşunun sayfasından
hangi commit'ten derlendiği okunabilir. `sha` sütununu doldurmanın en kolay
yolu budur.

---

## Kütük

| Sürüm | versionCode | sha | pubspec'te sürüm | Play'e yükleme | Durum | İçerik |
|---|---|---|---|---|---|---|
| 0.1.0 | — | `28b93ac` | 19 Ağu 2026 | **yüklenmedi** | — | Play öncesi; mağaza hazırlığı başlamamıştı. Yine de 16 mobil commit taşıyor (tanıtım ekranı, rütbe rozeti, dokunmatik düzeltmeler) — hepsi 1.0.0 ile yayına çıktı |
| 1.0.0 | ölçülmedi | `b4accee` (sürüm) · `48f01a1` (Sürüm B) | 23 Ağu 2026 | **5 gönderim** (25-28 Ağu) | yayınlandı → pasif | Mağaza kapısı + push/derin bağlantı + dokunma isabeti paketleri. In-App Update YOKTU (bkz. `build-and-distribution-log.md` → "Güncelleme modeli") |
| 1.0.1 | ölçülmedi | `7dd56ad` | 29 Ağu 2026 | **29 Ağu, 18:53** (Submission 7) | yayınlandı → pasif | Zorunlu güncelleme kullanılabilir hâle getirildi (mağaza butonu). Yaş/cinsiyet satırı aynı gün GERİ ALINDI — pakete girmedi |
| 1.0.2 | **435** | `d3d4702` | 30 Ağu 2026 | **30 Ağu, 12:07** (Submission 8) | yayınlandı → pasif | Faz 1 paketi + Play In-App Update. İnceleme **10 dk** (15:29 → Published 15:39, Console saatleri) |
| 1.0.3 | **449** | — | 31 Ağu 2026 (`c1c0437`) | **31 Ağu, 08:00** | yayınlandı → pasif | Telemetriden çıkan İKİ ÇÖKME (derin bağlantı rotası — 11 cihaz · rafta sınır dışı erişim) + bildirim rozetinin gerçekten sıfırlanması |
| 1.0.4 | **467** | — | 31 Ağu 2026 (`72278c3`) | **1 Eyl, 10:25** | yayınlandı → pasif | Faz 6'nın istemci yarısı + Faz 7'nin iki çökmesi + hata hız sınırı |
| 1.0.5 | **501** | `4a0a29b` | 1 Eyl 2026 (`f28b3da`) | **2 Eyl, 14:22** (paket) · sürüm 17:58'de güncellendi | yayınlandı → **pasif** (4 Eyl, 1.0.6 devraldı) | Tahta zoom'u + zoom tanıtım balonu + yazı ölçeği + mesaj kutusu etiketi + cihaz turu düzeltmeleri (rozet kırpması · alt şerit · çevrimdışı şerit · zoom çerçevesi · filigranlar). `.aab` 63.146.275 bayt, SHA-256 `200e82b9…451d4`. İnceleme ≈23 dk. Yayın sonrası cihazda doğrulandı (kullanıcı: *"1.0.5 turu testi tamam."*) |
| 1.0.6 | **525** | `711eaaa` | 3 Eyl 2026 (`a33fdaa`) | **4 Eyl, 15:53** (Submission 12) | yayınlandı → **pasif** (6 Eyl, 1.0.7 devraldı) | Aşağı bkz. |
| **1.0.7** | **545** | `78383eb` | 6 Eyl 2026 (`78383eb`) | **6 Eyl** (gönderim saati ÖLÇÜLMEDİ — Console okunmadı) | yayınlandı → **pasif** (7 Eyl, 1.0.8 devraldı) | Seviyesiz son paket: taş değiştirme motor düzeltmesi, hesap menüsü k-lig bayatlığı, arka plandan dönüş, kafa kafaya hizası, yardım cümlesi. Aşağı bkz. |
| **1.1.0** | **627** | `a4c809b` | 10 Eyl 2026 (`a4c809b`, #514) | **11 Eyl 2026, 08:01** (Console) | ✅ **kapalı testte YAYINDA** (Alpha; ≤ 08:33'te "Published") | İlk TestFlight turunun bulguları + onboarding Faz 2·3·5 + "Davetler" adlandırması. Aşağı bkz. |
| **1.0.9** | **581** | `1abde38` | 7 Eyl 2026 akşamı (`main`) | **8 Eyl 2026, 08:41** (Console) | yayınlandı → **pasif** (11 Eyl, 1.1.0 devraldı) | "Oynayarak öğren" tanıtımının PORT ikizi (Onboarding Faz 4) + tanıtımın cihaz/tarayıcı turu düzeltmeleri. Aşağı bkz. |
| **1.0.8** | **569** | `f4de936` | 6 Eyl 2026 (`5a540cb`) | **7 Eyl 2026, 13:28** (Console) | yayınlandı → **pasif** (8 Eyl, 1.0.9 devraldı) | Seviyeli YZ'nin TAMAMI (ROADMAP #23 Faz 2-5): ZORLUK seçici (Kolay · Normal · **Zor**), üç renkli rozet, seviyeye göre k-lig puanı, Zor = geniş arama motoru, kart altı puan satırı. Aşağı bkz. |

⚠ **1.0.0/1.0.1'in `versionCode`'u hâlâ ölçülmedi** (Console'un paket
listesi ekran görüntüsünde 435'te kesiliyordu). Ama gönderim ↔ SÜRÜM ADI
eşlemesi 4 Eylül 2026'da **tarih yakınlığından çıkarım olmaktan çıktı**:
`pubspec.yaml`'ın geçmişi hangi tarih aralığında hangi sürüm adının
derlendiğini kesin söylüyor (aşağıda "Ne yapıldı — sürüm sürüm"). Her
gönderim bu pencerelerden birine düşüyor ve üç ÖLÇÜLMÜŞ çapa (Submission
8 = 1.0.2/435, 11 = 1.0.5/501, 12 = 1.0.6/525) pencerelerle çelişmiyor.

⚠ **Bunun ilk düzelttiği şey:** eski tablo Submission 1-4'ü "1.0.0 öncesi"
sanıyordu. Değil — `pubspec` **23 Ağustos 19:36'dan** beri 1.0.0 diyordu,
yani mağazaya çıkan ilk beş gönderimin hepsi **1.0.0** adıyla gitti
(farklı `versionCode`'larla). "1.0.0'ın içeriği" derken tek bir paketi
değil, 23-29 Ağustos arasında art arda yüklenen beş paketi kastediyoruz.

⚠ **Eşlemenin dayandığı tek varsayım:** Console'un saatiyle git'in saatinin
aynı çerçevede olması. En dar marj 18 dakika (Submission 6, ki o zaten
paket değil form). Üç saatlik bir kayma varsayılsa Submission 8 = 1.0.1
çıkardı ve bu ÖLÇÜMLE çelişirdi — yani kayma yok.

⚠ 1.0.3 ve 1.0.4'ün `sha`sı boş: `versionCode` koşu numarası olduğundan
Actions'ta 449 ve 467 numaralı koşuların `head_sha`sına bakılarak
doldurulabilir. Doldurulmadı çünkü ölçülmedi.

---

## Gönderim geçmişi (Console → Publishing overview → Submission activity)

Console'un kendi kaydı, 4 Eylül 2026'da okundu. **Sürüm eşlemesi
`pubspec.yaml`'ın sürüm pencerelerine dayanıyor** (aşağıdaki "Ne yapıldı"
bölümü) — "ölçüldü" işaretli üç satır Console'dan doğrudan okundu,
ötekiler pencereye düşürüldü. `versionCode`'lar 435'in altında hâlâ
ölçülmedi.

| # | Gönderim | Kapsam | Durum | Sürüm (çıkarım) |
|---|---|---|---|---|
| 15 | **11 Eyl 2026, 08:01** | Closed testing - Alpha | ✅ **Published** | **1.1.0 (627)** — ölçüldü |
| 14 | 8 Eyl 2026, 08:41 | Closed testing - Alpha | ✅ **Published** | **1.0.9 (581)** — ölçüldü |
| 13 | 7 Eyl 2026, 13:28 | Closed testing - Alpha | ✅ **Published** | **1.0.8 (569)** — ölçüldü |
| 12 | 4 Eyl 2026, 15:53 | Closed testing - Alpha | ✅ **Published** | **1.0.6 (525)** — ölçüldü |
| 11 | 2 Eyl 2026, 17:24 | Closed testing - Alpha | Published | 1.0.5 (501) |
| 10 | 1 Eyl 2026, 13:27 | Closed testing - Alpha | Published | 1.0.4 (467) |
| 9 | 31 Ağu 2026, 11:01 | Closed testing - Alpha | Published | 1.0.3 (449) |
| 8 | 30 Ağu 2026, 15:29 | Closed testing - Alpha | Published | **1.0.2 (435)** — ölçüldü |
| 7 | 29 Ağu 2026, 18:53 | Closed testing - Alpha | Published | 1.0.1 (bump'tan 58 dk sonra) |
| 6 | 29 Ağu 2026, 17:37 | **App Content** | Published | paket değil — form gönderimi |
| 5 | 28 Ağu 2026, 00:54 | Closed testing - Alpha | Published | **1.0.0** |
| 4 | 26 Ağu 2026, 22:33 | Closed testing - Alpha | Published | **1.0.0** (eskiden "1.0.0 öncesi" yazıyordu — YANLIŞTI) |
| 3 | 26 Ağu 2026, 11:52 | Closed testing - Alpha | Published | **1.0.0** (aynı düzeltme) |
| 2 | 26 Ağu 2026, 08:57 | Closed testing - Alpha | Published | **1.0.0** (aynı düzeltme) |
| 1 | 25 Ağu 2026, 19:23 | Closed testing - Alpha, **Store Listing, App Content, Advanced distribution, Store settings** | Published | **1.0.0** + mağaza kaydının tamamı |

⚠ **Her gönderim bir SÜRÜM değil.** Submission 6 yalnızca "App Content"
formu; 1 numaralı gönderim mağaza kaydının tamamını taşıyor. Yani
"12 gönderim" ile "12 sürüm" aynı şey değil — kütükteki paket sayısıyla
buradaki satır sayısı bilerek tutmuyor.

⚠ Console'un kaydı **1 Mayıs 2026'dan itibaren** tutuluyor (sayfanın kendi
notu). Daha eskisi burada görünmez.

## 1.1.0 (627) — ✅ YAYINDA (kapalı test/Alpha, 11 Eyl 2026)

**Durum:** `pubspec.yaml` + `env.dart` 1.0.9 → **1.1.0** (#514, 10 Eyl
gecesi). Paket `main`'e merge'in ardından koşu **627**'de derlendi ve
**11 Eyl 2026 saat 08:01'de** kapalı teste (Alpha) gönderildi ve
**08:33'ten önce "Published"** oldu (kullanıcı o an bildirdi; Console'un
kendi yayın saati OKUNMADI, bu yüzden inceleme süresi "≤ 32 dk").

⚠ **"Published" ≠ testçinin telefonunda.** Console yayınlanmış gösterirken
cihazdaki paket saatlerce bir önceki olabiliyor — bu depoda ölçülmüş bir
tuzak (`build-and-distribution-log.md` → "Kapalı test: Published ≠
testçinin telefonunda"). Cihazda kanıt tek: Setup'ın `Derleme a4c809b`
satırı.

| | |
|---|---|
| `versionCode` | **627** (koşu 34531097809 — `--build-number=github.run_number`) |
| Commit | **`a4c809b`** (#514'ün merge commit'i) |
| Derleme | 10 Eyl 2026, 21:15 → 21:23 UTC; `.aab` adımı 21:21-21:23 |
| Cihazda görünen | Setup teşhis satırı: **`Derleme a4c809b`** |
| `.aab` | <https://github.com/alpcapa/kelimeki/releases/download/mobile-latest/kelimeki.aab> · **63.439.370 bayt** · SHA-256 `f33540f6…81db1` |
| `.apk` (yan yükleme/Appetize) | aynı etiket, `kelimeki.apk` · 64.397.049 bayt · SHA-256 `aad56e64…3c39` |
| iOS simülatör paketi (Appetize) | aynı etiket, `kelimeki-ios-simulator.zip` · 61.250.971 bayt · SHA-256 `69f9fb1f…c419` · 21:27:50'de tazelendi |
| **TestFlight** | ✅ yükleme adımı **21:27:52 → 21:31:23** (3 dk 31 sn) yeşil — beklenen paket **1.1.0 (627)** |

⚠ **`mobile-latest` her mobil derlemede ÜZERİNE yazılır.** Yüklemeden önce
indirdiğin paketin `versionCode`'unun **627** olduğunu doğrula; `main`'e
girecek bir sonraki mobil iş bu etiketi değiştirir (1.0.4/467 dersi).

⚠ **"TestFlight adımı yeşil" ≠ "TestFlight'ta hazır".** İş akışı
`skip_waiting_for_build_processing: true` ile koşuyor (macOS runner
dakikası, bilinçli); Apple'ın işlemesi 10-40 dk. Kanıt CI'ın yeşili değil,
**App Store Connect'te beliren derleme** — 1.0.9 turunun aynı dersi.

**Koşu 627'nin dört işi de yeşil** (Analiz+testler 21:17 · Android 21:23 ·
Pages 21:16 · iOS 21:31). Yani Appetize'ın HER İKİ uygulaması da bu turda
tazelendi — Android 21:23:10, iOS 21:27:52. (Normalde ikisi ayrı zamanlarda
tazelenir ve arada bakan "iOS bayat" tuzağına düşer; bu turda ikisi de
tamam.)

⚠ **`main`'in başı bu paketin sha'sı DEĞİL.** #515 (yalnızca `ROADMAP.md`)
merge edildiğinden `main` = `ac93500`, ama o commit `mobile-build`in `paths`
filtresine takılmadı → yeni derleme YOK. Doğru karşılaştırma **`a4c809b`**;
bunu bilmeden bakan "paket bayat" diye yanlış teşhis koyar.

### ✅ CİHAZDA DOĞRULANDI — iPhone, 11 Eyl 2026

Kullanıcı TestFlight'tan kurup baktı: *"tanıtım 1. slayt legend'lar
sabitlenmiş. OYNA butonu setup'da alta sabitlenmiş ve iyi olmuş."* Yani
10 Eylül akşamı bildirilen iki düzen hatası da kapandı — üstelik aynı
cihazda, aynı ayarlarla (Dynamic Type varsayılan, ekran 375 pt sınıfı).

⚠ Bu gözlem aynı zamanda **paketin taze olduğunun kanıtı**: iki düzeltme de
yalnızca 627'de var, 620'de yoktu. Yani `Derleme a4c809b` satırını ayrıca
okumaya gerek kalmadan doğru paket kurulmuş oluyor.

✅ **Üçüncü bulgu da doğrulandı** (11 Eyl 2026, kullanıcı: *"kontrol
ettim, iz kalmıyor"*): yeni bir YZ oyunu açılıp hiç hamle yapmadan
çıkılınca "Devam Eden Oyunlar"da ne satır kalıyor ne de bir an belirip
kayboluyor. Yani ilk TestFlight turunun ÜÇ bulgusu da cihazda kapandı.

### Play sürüm notları — OLDUĞU GİBİ yapıştırılabilir (TR)

⚠ **Play'in sürüm notu alanı dil başına 500 karakter.** Aşağıdaki metin
**498 karakter** — ölçüldü, olduğu gibi yapıştırılabilir. Uzatırsan
Console kabul etmez; satır eklerken yeniden say.

**Sürüm adı (Release name):** `1.1.0 (627)`

```
• Yeni başlayanlara oyun içi ipuçları: bölge vergisi, çarpanlar ve bölgenin büyümesi tam yaşandığı anda anlatılıyor.
• Tanıtım turunu "Nasıl oynanır?" penceresinden tekrar oynayabilirsin.
• Arkadaşlar penceresinde sekmeler artık "Arkadaşlar" ve "Davetler".
• Dar ekranlı telefonlarda "Oyunu Başlat" düğmesi hep görünür; tanıtımdaki X2/X3 açıklaması tek satırda.
• "Kalan Taşlar" penceresinin bazı oyunlarda çökmesi giderildi.
• Hiç hamle yapmadan çıktığın yapay zekâ oyunları listede iz bırakmıyor.
```

### TestFlight "What to Test" — 1.1.0 (627)

```
Bu sürümün odağı ilk TestFlight turunda bulunan üç sorun:

1) Setup'ta "OYUNU BAŞLAT" artık ekranın altına yapışık — dar ekranlı
   telefonda (ya da Display Zoom açıkken) kaydırmadan görünmeli, sayfa
   kayarken yerinde kalmalı. "Arkadaşınla" sekmesinde ise HİÇ olmamalı.
2) Tanıtımın ilk slaydında X2/X3 açıklamaları tek satırda durmalı,
   alttaki cümle kesilmemeli.
3) Yeni bir yapay zekâ oyunu açıp hiç hamle yapmadan geri çık: "Devam
   Eden Oyunlar" listesinde iz kalmamalı (belirip kaybolan satır da yok).

Ayrıca: iPad'i yatay çevir (düzen kırılmamalı), bildirim izni ve sıra
bildirimi, kelimeki.com bağlantısının uygulamada açılması.
```

### Sabah kontrol listesi (yükleme adımları)

1. **Appetize — İKİSİ DE taze** (Android 21:23:10 · iOS 21:27:52). Bak: yapışık `OYUNU BAŞLAT` · tanıtımda tek satır rozet ·
   Ayarlar → Ekran → **Ekran boyutu**'nu büyütüp ikisini tekrar. Teşhis
   satırı `Derleme a4c809b` demeli.
2. **TestFlight (iPhone/iPad).** Beklenen paket **1.1.0 (627)**. TestFlight
   otomatik güncelleme açıksa kendi iner; hemen istiyorsan TestFlight →
   Kelimeki → UPDATE. Uygulamayı açmak güncellemeyi TETİKLEMEZ (In-App
   Update yalnızca Android + yalnızca Play'den kurulan pakette).
3. **Play Console → Kapalı test (Alpha) → Yeni sürüm oluştur** → yukarıdaki
   `.aab`yi yükle → `versionCode` **627** mü, doğrula → sürüm notlarını
   yapıştır → gönder.
4. **Yükleme yapıldıktan sonra bu dosyayı güncelle** (aşağıdaki "Bir sürüm
   yüklendiğinde ne yapılır" listesi): kütükteki durumu "yüklendi/yayında"
   yap, 1.0.9'u pasife çek, gönderim saatini ve inceleme süresini yaz.

## 1.0.9 (581) — ✅ YAYINDA (kapalı test/Alpha, 8 Eyl 2026)

**Durum:** `pubspec.yaml` + `env.dart` 1.0.8 → 1.0.9 (#486, 7 Eyl akşamı).
Paket 7 Eyl gecesi derlendi, **8 Eyl 2026 saat 08:41'de** kapalı teste
(Alpha) gönderildi — Console'un kendi kaydı — ve **09:10'dan önce
"Published"** oldu (kullanıcı o an bildirdi; Console'un kendi yayın saati
OKUNMADI, bu yüzden inceleme süresi "≤ 29 dk").

| | |
|---|---|
| `versionCode` | **581** (koşu 34164451695 — `--build-number=github.run_number`) |
| Commit | **`1abde38`** (#486'nın merge commit'i) |
| Derleme | 7 Eyl 2026, 21:48 → 21:57 UTC; `.aab` adımı 21:55-21:57 |
| Cihazda görünen | Setup teşhis satırı: `Derleme 1abde38` |

⚠ **`mobile-latest` her mobil derlemede ÜZERİNE yazılır.** Play'e yüklemeden
önce indirdiğin paketin `versionCode`'unun **581** olduğunu doğrula; `main`'e
giren bir sonraki mobil iş bu etiketi değiştirir (1.0.4/467 dersi).

**İçerik — tek konu, Onboarding Faz 4 ve ardından gelen tur:** ilk oyunu
açan kullanıcı artık Hızlı Başlangıç penceresi yerine **"oynayarak öğren"
tanıtımını** görüyor (dört sahne, ~60 sn, her hamleden sonra rakip de
oynuyor). Web'de 7 Eylül sabahı yayınlanmıştı; bu paket onun PORT ikizini
getiriyor. Kullanıcıya görünen:

- Tanıtım AÇILIRKEN karşılama penceresi ("Kelimeki Tanıtım Turu" + Devam) —
  oyuncu kendini gerçek oyunda sanmasın diye.
- Raylı dört sahne: ev karesi → bölgenin büyümesi → merkezde ×2 → merkez
  karesinde ×3 + bölge vergisi (gerçek "Sınır İhlali!" penceresiyle).
- Rafta o sahnenin harfleri yan yana vurgulu; taş dokunarak ya da
  sürüklenerek konuyor (sürükleme HİSSİ gerçek oyunla aynı —
  `ui/game/drag_feel.dart` üç ekranın ortak kaynağı).
- Kapı: tanıtım YALNIZCA yeni gelene, bir kere (dört sinyal —
  `util/onboarding.dart`). Mevcut oyuncuya, devam eden oyunu olana ve hesabı
  tanıtımdan eski olana AÇILMAZ.
- Tanıtım bir "oyun" DEĞİL: kayıt, bulut kaydı, `games` satırı, k-lig,
  istatistik ve terk-edilme cezası çalışmaz.
- Balon tipografisi büyüdü (`clamp(11,3.2vw,16)`) ve uzun cümleler iki
  satıra kırılıyor; aynı punto zoom ipucu ve "Buradan başla" balonlarında da
  geçerli — yani GERÇEK OYUNDA da görünür bir değişiklik.

**Cihazda doğrulanan (7 Eyl akşamı, Appetize):** kullanıcı tanıtımın
tamamını Appetize'da koştu — *"Appetize herşey ok"*. Öncesinde web
önizlemesinde üç tur düzeltme yapıldı (balon hizası, okun hedefi, balonun
mesaj şeridini örtmesi, metinler).

⚠ **APK turu:** kullanıcı kuralı *"apk ile test edip sorunsuz olduğundan
emin olmadan aab yapılmayacak"* — bu turda kullanıcı APK yerine
**Appetize**'ı yeterli gördü (*"apk denemesine gerek yok bence"*), karar
kayda geçti.

**Sürüm adı (Console):** `1.0.9 (581)`

**Sürüm notları — TASLAK (`tr-TR`, 348/500 karakter):**

```
Yenilikler
• Oyuna ilk kez başlayanlar için kısa bir tanıtım turu: dört sahnede kendi köşenden başlamayı, bölgeni büyütmeyi, ortadaki puan çarpanlarını ve bölge vergisini oynayarak öğreniyorsun (yaklaşık 1 dakika).
• Tur yalnızca yeni gelenlere bir kez açılır, "Atla" ile geçilebilir.
• Oyun içindeki ipucu balonları büyüdü, yazıları daha okunaklı.
```

⚠ "Düzeltmeler" başlığı YOK: bu paketteki düzeltmelerin hepsi tanıtımın
KENDİ turlarında bulundu ve hiç sahaya çıkmamıştı — mevcut bir testçinin
"düzeldi" diye tanıyacağı bir şey değil. Testçiye görünen tek eski-davranış
değişikliği balon puntosu, o da "Yenilikler"in son maddesinde.

**Derlenen paket — Play'e GİDECEK olan:** koşu **581**, `1abde38`
(#486'nın merge commit'i), `.aab` **63.418.306 bayt**, SHA-256
`e7f37832c91f74f0e920e8c46244420f781ac6ecc0879f995155c5f65dfbd671`
(7 Eyl 2026, 21:57 UTC — `mobile-latest`e yüklenme anı).
İndirme: `https://github.com/alpcapa/kelimeki/releases/download/mobile-latest/kelimeki.aab`

⚠ **"Published" ≠ testçinin telefonunda.** Kanala girdi demektir; dağıtım
kademeli. Cihazda doğrularken önce Setup'ın **`Derleme 1abde38`** satırına
bak. İnmiyorsa çare beklemek DEĞİL: testçi opt-in linkine tekrar gir
(`https://play.google.com/apps/testing/com.kelimeki.kelimeki`), sonra Play
Store önbelleği, sonra Internal testing kanalı (bkz.
`build-and-distribution-log.md` → "ÇARE").

**Tur kapandı:** "İnceleme süresi" tablosuna satır eklendi, 1.0.8 pasife
çekildi, ROADMAP'teki tur `docs/decisions/roadmap-arsiv.md` → "1.0.9 sürüm
turu"na taşındı. ⚠ Kalan TEK ölçüm cihazda: testçinin telefonunda
`Derleme 1abde38` göründü mü (kanala girmek ≠ cihaza inmek).

## 1.0.8 (569) — ✅ YAYINDA (kapalı test/Alpha, 7 Eyl 2026)

**Durum:** `pubspec.yaml` + `env.dart` 1.0.7 → 1.0.8 (#472, 6 Eyl akşamı).
Sürüm adı aynı kaldı ama paket o günden beri DÖRT kez yeniden derlendi
(#473 → 555, #474 → 562, #475 → 566, #479 → **569**); Play'e gidecek olan
sonuncusu. 566 cihazda test edildi ve temiz çıktı (kullanıcı: *"test tamam,
sorunsuz"*); 569 onun üstüne yalnızca iki KOZMETİK düzeltme koyuyor
(misafir Setup boşluğu, açıklama metninde noktanın yeri).
**Gönderim:** 7 Eyl 2026, **13:28** — Console'un kendi kaydı ("Submitted
1:28 pm", Submission activity), kapalı test (Alpha). Durum o an **In
review**; **13:57'den önce "Published"** (kullanıcı o an bildirdi; Console'un
kendi yayın saati OKUNMADI, bu yüzden inceleme süresi "≤ 29 dk"). ⚠ İlk
bildirilen gönderim saati 13:42'ydi (yükleme akışının bittiği an); kütüğe
CONSOLE'un yazdığı saat girer, çünkü "İnceleme süresi" tablosundaki öteki
satırlar da Console saatleriyle ölçüldü ve karışık kaynak o tabloyu
karşılaştırılamaz hâle getirir.

⚠ **"Published" ≠ testçinin telefonunda.** Kanala girdi demektir; dağıtım
kademeli. Cihazda doğrularken önce Setup'ın `Derleme f4de936` satırına bak
(bkz. `build-and-distribution-log.md` → "Kapalı test"). ⚠ **Yayın saati HENÜZ ÖLÇÜLMEDİ** —
"Published" görüldüğünde hem aşağıdaki "İnceleme süresi" tablosuna satır
eklenmeli hem 1.0.7 pasife çekilmeli hem de ROADMAP'teki tur arşive
taşınmalı. Geçmiş kapalı test incelemeleri 10-34 dakika sürdü; "Published"
rozeti kanala GİRDİĞİNİ söyler, cihaza indiğini DEĞİL (bkz.
`build-and-distribution-log.md` → "Kapalı test").

**İçerik:** ROADMAP #23'ün TAMAMI (Faz 2-5) — yedi port commit'i, aşağıda
"1.0.8 — 7 mobil commit". Kullanıcıya görünen: Yapay Zeka oyununda
**Zorluk** seçimi (Kolay · Normal · **Zor**); Zor yeni, daha güçlü bir
motor (geniş arama — YZ↔YZ'de Normal'i %70-72 yeniyor); seviye rozeti
üç renk (Kolay yeşil · Normal turuncu · Zor kırmızı) oyun sonu / geçmiş /
son oynananlar / devam eden kartlarında ve tahta altı şeridinde; k-lig
puanı seviyeye göre (Kolay +1 · Normal +2 · Zor +4; 4 kişilikte ikinci
0 / +1 / +2); seçicinin altında her seviyenin açıklaması ve puanı (misafirde
"Puan takibi üyelik gerektirir" notu); kart altında her puan kendi
avatarının altında; rövanş seviyeyi korur. Sahadaki 1.0.7'nin web'de
başlatılan Kolay oyununu +2 gösterme tutarsızlığı kapanır (sunucu zaten
doğru sayıyordu).

**Sürüm notları — TASLAK (`tr-TR`, 462/500 karakter):**

```
Yenilikler
• Yapay Zeka oyununda zorluk seçimi: Kolay, Normal veya Zor. Yeni başlıyorsanız Kolay; kendine güvenenler için Zor — daha güçlü bir rakip, birincilik 4 k-lig puanı.
• k-lig puanı seviyeye göre: Kolay +1, Normal +2, Zor +4. Kartlarda ve tahta altında seviye rozeti.
• Devam eden ve son oynanan oyun kartlarında puanlar avatarların altında.
• Rövanş seçilen zorluğu korur.

Düzeltmeler
• Web'de başlatılan Kolay oyunun puanı geçmişte doğru (+1) görünür.
```

**Derlenen paket — Play'e GİDECEK olan:** koşu **569**, `f4de936`
(#479'un merge commit'i), `.aab` **63.264.188 bayt**, SHA-256
`49483fadb12a97269efb262f9064182e28bf1f111ace4417f2ac35b84cc0ac9c`
(7 Eyl 2026 ~09:58 UTC). `mobile-latest`ten indirilip doğrulandı: boyut,
SHA-256 ve paketin manifesti (`versionName 1.0.8`, `versionCode 569`).
Aynı koşunun `.apk`si 64.265.961 bayt, SHA-256
`17984b2f341a3e00891f97f3392e85ae127444c9b18fe262ecb62ccfb2a54d9e`,
içindeki derleme kimliği `f4de936` (Setup teşhis satırı bunu gösterir).
⚠ `main`'e giren bir sonraki MOBİL iş bu paketi üzerine yazar; yüklemeden
önce koşu numarasını yeniden oku (doküman-only merge'ler tetiklemez).

<details><summary>Önceki derlemeler (aynı sürüm adı, artık bayat)</summary>

- koşu **566**, `dd55ae0` (#475), 63.262.794 bayt, SHA-256
  `20b55edb9753fef8b6000707905a3f48591775d93eacadea47ea9a9160b3450e`
  (7 Eyl 07:27 UTC) — CİHAZDA TEST EDİLEN paket, temiz çıktı; 569'dan tek
  farkı iki kozmetik düzeltmenin yokluğu.
- koşu **553**, `5a540cb` (#472), 63.239.362 bayt, SHA-256
  `a3dac1ee0628151c9a7e9c23a24ccb7f60df71036b1de1df039e182d9b59c586`
  (6 Eyl 18:51 UTC) — Zor yok, açıklama metinleri eski.
- koşu 555 (`7a7bc26`, #473) ve 562 (`df26f46`, #474) — özetleri kayda
  geçmedi.

</details>

**Yüklemeden önce:** cihaz turu — `mobile/TESTING.md` §13 "Seviyeye göre
puan" (üç seviye seçici + açıklama metinleri, Zor oyunu: kırmızı rozet,
YZ'nin düşünme süresi insan ölçeğinde, oyun sonu +4) + aynı hesapla iki
cihazda puan eşleşmesi + `mobile/docs/testing-bildirimler.md` §7'nin
"güncelleme VARKEN" dalı (1.0.7 kuruluyken 1.0.8 yayınlanınca In-App
Update penceresi). Kullanıcı kuralı *"apk ile test edip sorunsuz olduğundan
emin olmadan aab yapılmayacak"*. Setup'taki `Derleme f4de936` satırı
görünmeli.

**Cihaz turu 566'da KOŞULDU ve temiz çıktı** (7 Eyl 2026, kullanıcı: *"test
tamam, sorunsuz"*). 569 yalnızca iki kozmetik düzeltme ekliyor; misafir
Setup ekranına bir bakış ikisini birden doğrular (link üstü/altı eşit
boşluk, açıklamada nokta parantezin önünde).

---

## 1.0.7 (545) — PASİF (7 Eyl 2026'da 1.0.8 devraldı) — gönderim 6 Eyl 2026; saat ölçülmedi

**Paket:** koşu 545, `78383eb`'den derlenmiş, `.aab` SHA-256 `4df3928c…28837`
(kısaltılmış — tam özet kayda geçmedi), release varlığı 6 Eyl 2026 07:08:49
UTC. Kapalı test (Alpha) kanalında yayınlandı; **gönderim ve yayın saati
Console'dan okunmadı**, bu yüzden "İnceleme süresi" tablosunda satırı yok.

⚠ Bu satır kütüğe **geç yazıldı** (6 Eyl akşamı, 1.0.8 hazırlanırken): 1.0.7
PR'ı (#461) ROADMAP'i güncellemiş ama bu dosyaya dokunmamıştı; tur arşive
taşınırken de (`docs/decisions/roadmap-arsiv.md` → "1.0.7 sürüm turu") kütük
atlanmıştı. "Bir sürüm yüklendiğinde ne yapılır" listesinin 1. adımı tam
bunu önlemek için var — arşive taşımak kütüğe yazmanın yerine geçmez.

**Sürüm notları:** kayda geçmedi (Console'a ne yazıldığı bilinmiyor).

⚠ **`mobile-latest`'teki paket ARTIK BU DEĞİL (6 Eyl 18:10 UTC'den beri):**
Faz 4 merge'i (`42db22b`) `mobile-build` koşu **551**'i tetikledi ve
prerelease'teki `.aab` üzerine yazıldı — sürüm adı hâlâ 1.0.7 (bump henüz
yoktu) ama içerik Faz 2-4'lü, `versionCode` 551. Yani orada duran dosya ne
sahadaki 545'tir ne de 1.0.8; 1.0.4/467 dersinin aynısı. 1.0.8 adıyla
derlenen paket ancak sürüm PR'ı `main`'e girince oluşur.

**İçerik:** aşağıda "1.0.7 — 7 mobil commit". Ağırlık hata düzeltmesi; en
güçlüsü taş değiştirmede taslak taşların kaybolması (#452, motor).

---

## 1.0.6 (525) — PASİF (6 Eyl 2026'da 1.0.7 devraldı) — gönderim 4 Eyl 2026, 15:53 · Published 16:22'den önce

**Paket:** `mobile-latest` prerelease'indeki `kelimeki.aab`, koşu 525,
`711eaaa`'dan derlenmiş, release anahtarıyla imzalı (4 Eyl 10:36).

| | |
|---|---|
| İndirme | `https://github.com/alpcapa/kelimeki/releases/download/mobile-latest/kelimeki.aab` |
| Boyut | 63.210.820 bayt |
| SHA-256 | `96f176e64d79a622a2c33cb8e49588c9ce9f15ad13e6bb55060b0f99b4769aca` |
| Yüklendiği an | 4 Eyl 2026, 10:36:00 UTC (release varlığı) |

⚠ Bu SHA-256 **4 Eylül 10:36'daki** pakete ait. `mobile-latest` her mobil
derlemede üzerine yazıldığından, gönderimden önce indirdiğin dosyanın
özetini bununla KARŞILAŞTIR — tutmuyorsa arada yeni bir derleme olmuş
demektir ve gönderdiğin paket bu satırın anlattığı paket değildir.

**Sürüm adı (Console):** `1.0.6 (525)`

**Sürüm notları (`tr-TR`, 491/500 karakter):**

```
Yenilikler
• Oyun geçmişinde "Tekrar Oyna": biten bir Canlı oyunun aynı kadrosuyla rövanş daveti gönder.
• Skor kartında kafa kafaya oran çubuğu — bir rakibe karşı galibiyet/beraberlik/mağlubiyet dağılımın.
• Biten Canlı oyunlarda "Yeni" rozeti: sonucunu görmediklerin işaretli.
• Listelerde süresi bitmeye en yakın oyun en üstte.

Düzeltmeler
• iPad'de paylaşım penceresinin asılı kalması.
• Kafa kafaya oranında teslimlerin beraberlik sayılması.
• Terk edilen oyunun yanlış güne yazılması.
```

**Notlara giren commit'ler:** `c9f03fd` · `76a7151` · `a966dec` ·
`a33fdaa` · `d07c06d` · `711eaaa`.

⚠ **Notlara girmeyen iki değişiklik — ve biri hakkında YANLIŞ gerekçe
yazılmıştı (4 Eylül 2026'da düzeltildi):**

| PR | Gerçekte ne oldu | Notlara neden girmedi |
|---|---|---|
| #427 — "Yeni Canlı Oyun" çökmesi (`913c14f`) | `mobile/` altında **sıfır** dosya: `LiveGamesTab.tsx` + web CI kapısı | Doğru gerekçe: **web-only**, bu pakette yok |
| #426 — kafa kafaya avatarları 18 → 26 px (`1bfb997`) | `mobile/app/lib/src/ui/score/player_score_card_modal.dart` **DEĞİŞTİ** (16 satır) — yani pakete GİRDİ | Kozmetik (8 px'lik avatar); 491/500 karakterlik notta yer yoktu |

**Hata nasıl doğdu:** dosya listesi `git show --stat | grep mobile/` ile
okunmuştu ve `--stat` uzun yolları `.../lib/src/ui/score/…` diye kısalttığı
için o satır grep'e takılmadı. **Ders:** bir commit'in hangi alanlara
dokunduğunu `--stat` çıktısından grep'leme — `--name-only` kullan (o yolu
kısaltmaz). Sürüm notu YANLIŞ DEĞİL (o değişiklik zaten duyurulmayacak
kadar küçüktü), yalnızca gerekçesi yanlıştı.

**Cihaz doğrulaması:** APK (`711eaaa`) 4 Eylül'de cihazda koşuldu; §0-§4'ün
koşulabilir maddeleri geçti (ayrıntı: `cihaz-testi-log.md` → "FAZ B — İLK
GERÇEK CİHAZ TURU"). Kullanıcı kuralı sağlandı: *"apk ile test edip
sorunsuz olduğundan emin olmadan aab yapılmayacak."*

---

## Ne yapıldı — sürüm sürüm

**Bu bölüm 4 Eylül 2026'da eklendi**, kullanıcı sorusuyla: *"bu tabloda
nelerin yapıldığı bilgisi yok"*. Yukarıdaki kütük hangi PAKETİN yayında
olduğunu söylüyordu ama içeriğini tek satırlık etiketlerle geçiyordu.

**Yöntem — çıkarım değil, ölçüm:** her sürümün penceresi `pubspec.yaml`'ın
geçmişinden geliyor (hangi commit sürüm adını değiştirdi), pencereye düşen
commit'ler ise **mobil pakete gerçekten giren** dosyalara göre süzüldü:

```
git log --first-parent <önceki bump>..<bu bump> -- \
  mobile/app/lib mobile/app/android mobile/app/ios \
  mobile/app/assets mobile/kelimeki_core/lib
```

⚠ **Sadece `mobile/docs` değiştiren commit'ler listede YOK** — doküman
pakete girmiyor. ⚠ **`web + port` etiketi**, aynı commit'in `src/` altında
da dosya değiştirdiğini söyler (bu depoda çoğu düzeltme iki tarafa birden
gider); `yalnız port` ise değişikliğin tamamen Flutter tarafında olduğunu.

⚠ **Sürüm penceresi ile DERLEME anı aynı şey değil.** 1.0.5 ve 1.0.6 için
derleme sha'sı biliniyor (`4a0a29b`, `711eaaa`), o yüzden pencereleri orada
kesildi. Ötekilerde sınır bir sonraki sürüm bump'ıdır — yani son bir iki
commit teorik olarak o paketin derlemesinden SONRA girmiş olabilir.

### 0.1.0 — 16 mobil commit

*Pencere: 19 Ağu 02:15 → 23 Ağu 19:36*

**Play'e hiç yüklenmedi** — ama 16 mobil commit taşıyor ve hepsi 1.0.0
paketiyle sahaya çıktı. Öne çıkanlar: **ilk açılış tanıtım ekranı**
(`IntroScreen`, dört slayttan beşe, web'in karşılama katmanıyla hizalandı,
atlama yok), **yeni rütbe rozeti + kendi alt küme fontu** ve isim yanındaki
mühürler, en üst rütbenin adının **Tanrı → Kozmik** olması, k-lig sırasının
tek kaynağa (`k_lig_siralama` view'ı) indirilmesi, giriş sekmesi varsayılanı
("YZ tarafı boşken Arkadaşınla açılsın") ve iki dokunmatik jest hatası
(jokerin harfi kendiliğinden değişiyordu · titreşimli dokunuş kayboluyordu).

<details><summary>Commit dökümü (16)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `28b93ac` | 19.08.2026 | Tanıtım ikonları, yeni rütbe rozeti + fontu, isim yanı mühürler ve karşılama metin turu | web + port |
| `8a08499` | 19.08.2026 | Kozmetik metin/boşluk turu + hukuki metin ve doküman denetimi | web + port |
| `14ec7fb` | 19.08.2026 | Portun ilk açılış tanıtımı: IntroScreen (atlama yok) + Setup'ta Tanıtım linki | yalnız port |
| `0d75b98` | 19.08.2026 | Tanıtım ekranı: dört slayt web'in karşılama katmanıyla hizalandı | web + port |
| `958f1d3` | 19.08.2026 | Tanıtım ekranı: beş slayt, alt düğme kalktı, logo içerikle birlikte ortalanıyor | yalnız port |
| `478ffce` | 19.08.2026 | En üst rütbe: Tanrı → Kozmik (T → K), web + port | web + port |
| `e200c90` | 19.08.2026 | Port düzeltmeleri: footer telifi ortalandı, tanıtım 1./2. slayt dengelendi, X2/X3 legend'i yan yana | yalnız port |
| `53e423c` | 19.08.2026 | Tanıtım kromu 47 → 29 px: 1. slayt iOS Safari'de de sığıyor | yalnız port |
| `4a1d88a` | 19.08.2026 | Tanıtım: son satır leading'i kaldırıldı + boşluklar kırpıldı (~23px) | yalnız port |
| `f0f71e0` | 21.08.2026 | k-lig sırası tek kaynaktan: k_lig_siralama view'ı + OHP eşitlik bozucu | web + port |
| `6b35fb7` | 21.08.2026 | Oyun sonu kartı, kaynak hunisi, hata telemetrisi, admin üyeler tablosu ve hoş geldiniz e-postası | web + port |
| `bacbd9d` | 21.08.2026 | Canlı liste düşen istekte "oyunun yok" demesin + oyundan Setup'a dönüş görünür olsun | web + port |
| `20149e1` | 21.08.2026 | Giriş varsayılanı: YZ tarafı boşken "Arkadaşınla" açılsın | web + port |
| `3773ffb` | 22.08.2026 | test(mobile): kalan dört korumasız web↔port çiftini de kilitle | yalnız port |
| `0d4ccc1` | 22.08.2026 | Kaynak Hunisi: misafir hunisi (game_finishes/game_starts kaynak etiketi) | web + port |
| `c62e219` | 22.08.2026 | Dokunmatik jest hataları: joker harfi kendiliğinden değişiyordu + titreşimli dokunuş kayboluyordu | web + port |

</details>

### 1.0.0 — 28 mobil commit

*Pencere: 23 Ağu 19:36 → 29 Ağu 17:55*

**Mağazaya çıkan ilk sürüm adı — tek paket değil, 23-29 Ağustos arasında
art arda yüklenen BEŞ paket** (Submission 1-5). En kalabalık sürüm (28 mobil
commit). Dört blok hâlinde:

- **Mağaza kapısı:** imzalama + `.aab` üretimi, mağaza vitrini, hukuki statik
  sayfalar, **uygulama içinden hesap silme** (mağaza blokeriydi), `AD_ID`
  izninin kaldırılması, `/.well-known/assetlinks.json` parmak izi,
  onaylanmamış hesap süpürmesi.
- **Push + derin bağlantı** (`48f01a1`, "Sürüm B"): bildirim kanalı
  `IMPORTANCE_HIGH`, push token yaşam döngüsü, kanal parite testi.
- **Kapalı testten dönen dokunma isabeti paketleri** ("Sürüm A" ve "A2"):
  48 dp dokunma hedefleri, bırakma kararı için ayrı eşik, "Buradan başla"
  balonu, ıskalanan dokunuşun komşu taslağa yönlendirilmesi, "← Geri"nin
  ayrı satıra taşınması.
- **Performans ve çökme:** tahtanın HER KAREDE yeniden boyanması
  (`RepaintBoundary`) ve nömorfik dekorun raster önbelleğe alınması — oyun
  ekranının ağır çekimi buydu; ayrıca **release APK'da eksik `INTERNET`
  izni** (giriş ve tüm sunucu özellikleri ölüydü) ve kurucusu silinmiş
  oyunun (`created_by NULL`) Canlı listeyi düşürmesi.

Oyun kuralı da bu pencerede değişti: **kendi 4×4 bloğundaki desteksiz rakip
taşı artık bölge zincirini kesmiyor** (`18689eb`).

⚠ **In-App Update mekanizması bu sürümde YOKTU** — 1.0.0 kitlesinin
güncellenememesinin sebebi bu; bir kereye mahsus `app_config` eşiğiyle
süpürüldü (bkz. `mobile/CLAUDE.md` → "Güncelleme").

<details><summary>Commit dökümü (28)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `b4accee` | 23.08.2026 | Google Play yayını: imzalama, .aab, sürüm 1.0.0, mağaza vitrini, hukuki statik sayfalar | web + port |
| `f13af84` | 23.08.2026 | Onaylanmamış hesap süpürmesi: hatırlat, sonra sil | web + port |
| `4513c37` | 24.08.2026 | Admin kart başlıkları, hata telemetrisi gürültü filtresi ve mağaza öncesi sürüm/rota alanları | web + port |
| `d59306d` | 24.08.2026 | Cihaz dökümü artık girişli ziyaretleri de kapsıyor (device_visits) | web + port |
| `fafdcb2` | 24.08.2026 | Release APK'da eksik INTERNET izni: giriş ve tüm sunucu özellikleri ölüydü | yalnız port |
| `6e481b7` | 24.08.2026 | İki teknik borç ve elenen 8px eşiği kayda geçti | web + port |
| `18689eb` | 24.08.2026 | Bölge kuralı: kendi bloğundaki desteksiz rakip taşı zinciri kesmiyor | web + port |
| `71eb73a` | 24.08.2026 | Dokunma hedefleri 48 dp; "Yükleniyor…" okunur hâle getirildi (web + port) | web + port |
| `ee26383` | 24.08.2026 | "← Geri" ayrı satıra taşındı; açılış ve yükleme deneyimi her yerde aynı | web + port |
| `825451c` | 25.08.2026 | Taslak sürerken anlam açılmıyor; ıskalanan dokunuş komşu taslağa yönleniyor | web + port |
| `17b194f` | 25.08.2026 | Play imza parmak izi: /.well-known/assetlinks.json yayınla | yalnız port |
| `69d5478` | 26.08.2026 | Uygulama içinden hesap silme (ROADMAP madde 2, mağaza blokeri) | web + port |
| `53e401c` | 26.08.2026 | Kullanım Koşulları §2: hesabı kendin silme cümlesi (web + port) | web + port |
| `42a1f67` | 26.08.2026 | Hesap silme uyarısı kırmızı + kalın + ünlemli (web + port) | web + port |
| `c947b10` | 26.08.2026 | Canlı oyun listesi: kurucusu silinmiş oyun (created_by NULL) listeyi düşürüyordu | web + port |
| `4e9aac6` | 26.08.2026 | Hesap menüsü: k-lig satırı puan geç gelince açık menüde hiç belirmiyordu | yalnız port |
| `e7e1e79` | 26.08.2026 | Doküman bölünmesi + davet hataları görünür oldu + tanıtıma DEVAM düğmesi | web + port |
| `009d478` | 26.08.2026 | Sürükleme donması: tahta her karede yeniden BOYANIYORDU (RepaintBoundary) | yalnız port |
| `8d83ed6` | 26.08.2026 | Oyun ekranı ağır çekim: bir boyamanın MALİYETİ (nömorfik dekor raster önbelleği) | yalnız port |
| `5d8c549` | 26.08.2026 | "Buradan başla" balonu: ilk hamlenin nereye yapılacağı (web + port) | web + port |
| `f9c3846` | 27.08.2026 | Sürüm A: kapalı testten gelen dört düzeltme (dokunma hedefleri, Ara & Ekle, rozet, koltuk) | web + port |
| `24c5b0c` | 27.08.2026 | Sürüm A2: dokunma isabeti paketi — beş düzeltme (web + port) | web + port |
| `0651e5e` | 28.08.2026 | Titreşimli dokunuş kayboluyordu: bırakma kararı için AYRI eşik (web + port) | web + port |
| `48f01a1` | 28.08.2026 | Sürüm B: derin bağlantı kanalı + push bildirimleri (mağaza blokeri) + sözlük/görsel düzeltmeler | web + port |
| `6409458` | 28.08.2026 | Bildirim kanalı IMPORTANCE_HIGH + kanal parite testi + push token yaşam döngüsü | yalnız port |
| `b0cff6e` | 29.08.2026 | Cihaz testi turu: iki push hatası, sistem font ölçeği, offline profil ve görsel düzeltmeler | web + port |
| `0803b95` | 29.08.2026 | Bağlantı dönünce avatar yeniden denensin + 3.5 kaydı | yalnız port |
| `b1aa863` | 29.08.2026 | AD_ID izni kaldırıldı, gizlilik politikasına Google eklendi | web + port |

</details>

### 1.0.1 — 3 mobil commit

*Pencere: 29 Ağu 17:55 → 30 Ağu 13:43*

Tek amaçlı bir sürüm: **zorunlu güncelleme ekranının butonu çalışır hâle
geldi** (`UpdateRequiredScreen` → mağazaya yollama). 1.0.0'ın çıkışsız
ekranının çaresi.

⚠ Aynı gün eklenen **yaş/cinsiyet satırı GERİ ALINDI** (`a6a1776`,
revert #369) — yani bu pakete girmedi. Kütükte "üç commit" görünmesinin
sebebi bu; net içerik tek maddedir.

<details><summary>Commit dökümü (3)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `7dd56ad` | 29.08.2026 | Zorunlu güncelleme kullanılabilir hâle getirildi: sürüm 1.0.1 + mağaza butonu | yalnız port |
| `5b77159` | 29.08.2026 | Yaş/cinsiyet satırı tüm skor kartlarında (web + port) | web + port |
| `a6a1776` | 29.08.2026 | Revert #369 — yaş/cinsiyet satırı sıradaki işlerle birlikte yayına girecek | web + port |

</details>

### 1.0.2 — 6 mobil commit

*Pencere: 30 Ağu 13:43 → 31 Ağu 10:20*

**Play In-App Update** bu sürümle geldi — günlük güncelleme yolu. ⚠ Kod
1.0.2'nin İÇİNDE olduğundan sahadaki 1.0.0/1.0.1 kitlesi onu ancak bu
sürüme geçtikten SONRA görür.

Bildirim fazları 1-3 aynı pencerede kapandı: davet bildirimleri canlıya
alındı, **bildirime dokununca doğru yere gitme** ve Analytics'in ilk altı
olayı. Düzeltmeler: hayalet "Devam Eden Oyun" kartı, bekleyen oyun
sıralaması, header'da avatarın komşusunu boyaması, iPhone'da kaybolan pasif
skor kutusu kenarı (`outline` 0.5 → 1 px). Sözlüğe 5 kelime.

<details><summary>Commit dökümü (6)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `d3d4702` | 30.08.2026 | Faz 1 paketi + Play In-App Update — sürüm 1.0.2 | web + port |
| `37e68e4` | 30.08.2026 | Faz 2 (davet bildirimleri, canlıda) + kart/ikon cilası ve bir hata düzeltmesi | web + port |
| `afeb08d` | 30.08.2026 | Faz 3: bildirime dokununca doğru yere gitme + Analytics'in ilk altı olayı | yalnız port |
| `c9a4886` | 31.08.2026 | Header'da avatarın komşusunu boyaması + 5 yeni kelime + Faz 4 saha kayıtları | web + port |
| `d3d08a3` | 31.08.2026 | GameHeader: pasif skor kutusunun kenarı iPhone'da kayboluyordu (outline 0.5px → 1px) | web + port |
| `9a611b4` | 31.08.2026 | Hayalet "Devam Eden Oyun" + bekleyen oyun sıralaması + Üyeler başlık satırı sabit | web + port |

</details>

### 1.0.3 — 3 mobil commit

*Pencere: 31 Ağu 10:20 → 31 Ağu 23:08*

**Telemetriden çıkan iki çökmenin düzeltmesi** — sahada ölçülmüş, tahmin
değil: derin bağlantı rotası **11 cihazda** çökertiyordu ve rafta sınır dışı
bir erişim vardı. Ayrıca bildirim rozetinin gerçekten sıfırlanması
(ROADMAP #15) ve "kaç kişi hangi sürümde" ölçümünün açılması (#12).

<details><summary>Commit dökümü (3)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `c1c0437` | 31.08.2026 | Sürüm 1.0.3 — appVersion + pubspec birlikte artırıldı | yalnız port |
| `0783783` | 31.08.2026 | Bildirim rozeti gerçekten sıfırlansın (#15) + "kaç kişi hangi sürümde" ölçülebilsin (#12) | web + port |
| `b8d5e78` | 31.08.2026 | Telemetriden çıkan iki çökme: derin bağlantı rotası (11 cihaz) + rafta sınır dışı erişim | yalnız port |

</details>

### 1.0.4 — 2 mobil commit

*Pencere: 31 Ağu 23:08 → 1 Eyl 14:43*

Küçük bir telemetri turu: istemci hata **hız sınırı zamana bağlandı**
(#10), admin panelinde **platform filtresi** (#11), kaynak hunisine
"Bitiren Cihaz" kırılımı.

<details><summary>Commit dökümü (2)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `72278c3` | 31.08.2026 | Sürüm 1.0.4 — appVersion + pubspec birlikte artırıldı | yalnız port |
| `cec6cbc` | 01.09.2026 | Telemetri turu: hız sınırı ZAMANA bağlandı (#10) · panelde platform filtresi (#11) · huniye "Bitiren Cihaz" | web + port |

</details>

### 1.0.5 — 11 mobil commit

*Pencere: 1 Eyl 14:43 → 2 Eyl (derleme `4a0a29b`)*

**Tahta zoom'u:** boş kareye/çerçeveye çift dokunuşla 2× büyütme + parmakla
pan, üstüne merkez kareyi işaret eden **tek seferlik tanıtım balonu**. Tek
dokunuşlar birebir korunuyor.

**Yazı boyutu — üçüncü hata sınıfı (SARMA):** sabit genişlikli sütunlarda
metin ölçekle büyüyünce satır kırıyordu; bir kullanıcı bitirme modalında
`241` skorunu `24`/`1` diye okumuştu. Çözüm `ScaledCell`.

Mesaj kutusunun üstüne yönlendirme etiketi. Geri kalanı **APK cihaz
turlarından** dönen düzeltmeler: hamle puanı rozetinin kırpılması ve zoom'da
tahtanın dışına çizilmesi (rozet klibi transform'lu katmandaydı, işe
yaramıyordu), tahta alt şeridinin çevrimdışı hâli, k-lig sütunlarının
sarması, devam eden oyun kartının web'den ayrışması, zoom'da kalıcı çerçeve,
filigranların yazı ölçeğiyle bölgeyi taşırması, bölge çizgisinin kenarda
incelmesi.

<details><summary>Commit dökümü (11)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `f28b3da` | 01.09.2026 | Tahta zoom'u (1.0.5): çift dokunuşla 2× büyütme + parmakla pan | yalnız port |
| `db4ae31` | 01.09.2026 | Zoom, APK'dan gelen iki bulgu: bölge çizgisi kenarda incelmesin + kenarlar/boşluklar da çift dokunuş yüzeyi | yalnız port |
| `154cba8` | 01.09.2026 | Hamle puanı rozeti kırpılmasın (APK turu 3) + telemetri sınır notu | yalnız port |
| `f12f10e` | 01.09.2026 | Zoom tanıtım balonu (port): merkez kareyi işaret eden tek seferlik ipucu | yalnız port |
| `a238911` | 02.09.2026 | Yazı boyutu: sabit genişlikli sütunlarda sarma (bitirme modalı puanları bölünüyordu) | yalnız port |
| `df6fcce` | 02.09.2026 | Mesaj kutusunun üstüne yönlendirme etiketi (web + port) | web + port |
| `4a46900` | 02.09.2026 | Cihaz turu: üç bulgu (k-lig sütunları · devam eden oyun kartı · alt şerit) | web + port |
| `a3a7847` | 02.09.2026 | Hamle rozeti zoom'da tahtanın dışına çiziliyordu (web + port) | web + port |
| `d4d85be` | 02.09.2026 | Rozet klibi transform'lu katmandaydı — işe yaramıyordu | web + port |
| `1abbe23` | 02.09.2026 | Tahta alt şeridi + rozet kırpması: portu web ile hizala, çevrimdışı hâli düzelt | web + port |
| `4a0a29b` | 02.09.2026 | Zoom'da kalıcı çerçeve + filigranların yazı ölçeğiyle bölgeyi taşırması | yalnız port |

</details>

### 1.0.6 — 7 mobil commit

*Pencere: 3 Eyl (derleme sonrası) → 4 Eyl (derleme `711eaaa`)*

**Yenilikler:** oyun geçmişindeki aksiyon menüsüne **"Tekrar Oyna"** (biten
bir Canlı oyunun aynı kadrosuyla rövanş daveti), skor kartına **kafa kafaya
oran çubuğu** (+ avatarları 18 → 26 px), biten Canlı oyunlarda **"Yeni"
rozeti**, listelerde "süresi bitmeye en yakın olan üstte" sıralaması.

**Düzeltmeler:** iPad'de asılı kalan paylaşım penceresi, devam eden oyun
kartlarının iki sekmede ayrışması, kafa kafaya oranında teslimlerin
beraberlik sayılması, terk edilen oyunun yanlış güne yazılması.

<details><summary>Commit dökümü (7)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `c9f03fd` | 03.09.2026 | ROADMAP temizliği + iki gerçek hata: devam eden oyun kartlarının ayrışması ve iPad'de asılı kalan paylaşım | web + port |
| `76a7151` | 03.09.2026 | Liste sıralaması "bitmeye en yakın üstte" + madde 8 kapanışı (cihaz turu tamam) | web + port |
| `a966dec` | 03.09.2026 | Skor kartına kafa kafaya oran çubuğu + "Tüm Oyunlar" etiketi tekleşti | web + port |
| `a33fdaa` | 03.09.2026 | "Oyun Bitti (Yeni)" — biten Canlı oyunun haberi + sürüm 1.0.6 | web + port |
| `1bfb997` | 03.09.2026 | Kafa kafaya çubuğunun avatarlarını büyüt (18 → 26 px) | web + port |
| `d07c06d` | 04.09.2026 | Admin verisinde iki hata: terk kaydının tarihi ve kafa kafaya teslimi | web + port |
| `711eaaa` | 04.09.2026 | Oyun geçmişine "Tekrar Oyna" (rövanş) + FAZ B ilk gerçek cihaz turunun kaydı | web + port |

</details>


### 1.0.7 — 7 mobil commit

*Pencere: 4 Eyl (derleme `711eaaa` sonrası) → 6 Eyl (derleme `78383eb`)*

**Düzeltmeler:** taş değiştirmede **taslak taşların yok olması** (motor,
iki yeni golden) + senkron rafı yeniden sıralarsa seçimin düşmesi; hesap
menüsündeki k-lig puanının oturum boyunca **donması**; arka plandan dönüşün
"ekrana yeniden giriş" sayılması; skor kartındaki kafa kafaya çubuğunun
hizası; Hızlı Başlangıç'ın oyun sonu cümlesi. Görünmez: erişilemez `INIT`
action'ının kaldırılması.

<details><summary>Commit dökümü (7)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `f75a12c` | 04.09.2026 | Kurtarma: PR açılmadığı için main'e hiç girmemiş iki iş (arka plandan dönüş = ekrana giriş) | web + port |
| `19e17fe` | 04.09.2026 | Hızlı Başlangıç'ın oyun sonu cümlesi + ROADMAP: sıradaki sürüme binecekler | web + port |
| `7312eb8` | 04.09.2026 | Kafa kafaya çubuğu: yazılar bara yaklaştı, "TÜM OYUNLAR" barın hizasına oturdu | web + port |
| `b1b9daf` | 05.09.2026 | Taş değiştirme: taslak taşlar yok olmuyor + senkron seçimi düşürüyor | web + port |
| `91325d5` | 05.09.2026 | İnceleme 4. geçişi (temizlik): erişilemez spectating dalı ve INIT action'ı kaldırıldı | web + port |
| `45bec90` | 05.09.2026 | Hesap menüsündeki k-lig puanı bayat kalıyordu (menü 198 ↔ tablo 200) | web + port |
| `78383eb` | 06.09.2026 | Sürüm 1.0.7 — kapalı teste gönderilecek paket (yalnız sürüm adı) | yalnız port |

</details>

### 1.1.0 — 12 mobil commit (4'ü Android ikilisine giriyor)

*Pencere: `1abde38` (1.0.9'un paketi) → `a4c809b`. Komut:
`git log --oneline --first-parent 1abde38..a4c809b -- mobile/app mobile/kelimeki_core`*

⚠ **12 commit'in yalnızca DÖRDÜ `lib/` altına dokunuyor**, yani Android
paketinin içeriği bu dört satır. Geri kalanı `ios/` altında (Android'i
etkilemez), CI/fastlane'de (ikiliye girmez) ya da yalnızca `test/`te.
Sınıflandırma `git show --name-only` ile satır satır yapıldı — `--stat`
çıktısını grep'lemek yanıltır (1.0.6 → #426 vakası).

| sha | Ne | Pakete girer mi |
|---|---|---|
| `80f3769` | Onboarding Faz 2·3·5: bağlamsal ipuçları (vergi/çarpan/bölge), tanıtımı tekrar oynama, `tutorial_events` ölçümü | ✅ 9 dosya `lib/` |
| `46664f6` | "Kalan Taşlar" penceresi `myIndex` -1'de çöküyordu (port-only) | ✅ 1 dosya |
| `bc18730` | Arkadaşlar modalı "davet" diline geçti (sekmeler + içerideki metinler) | ✅ 3 dosya |
| `a4c809b` | İlk TestFlight turunun üç bulgusu: hiç oynanmamış oyunun bulut kaydı · tanıtım rozetleri · yapışık `OYUNU BAŞLAT` (+ sürüm 1.1.0) | ✅ 5 dosya |
| `61b278a` | iOS Firebase yapılandırması (`GoogleService-Info.plist`) | ⛔ yalnızca `ios/` + bir yorum |
| `9e65b7b` · `a0dc9dc` | iOS entitlements, bildirim kanalı, `Info.plist` iPad yönelimleri | ⛔ `ios/` (TestFlight'a girer, Play'e girmez) |
| `ef28e7b` · `1df055e` · `1755311` · `ecbbbaa` | Mac'siz imzalama zinciri + mağaza ekran görüntüsü boru hattı | ⛔ yalnızca CI/fastlane |
| `2015ab6` | iPad düzen kapısı (`ipad_layout_test.dart`) | ⛔ yalnızca `test/` |

### 1.0.9 — 2 mobil commit (+ sürüm adı)

*Pencere: `f4de936` (1.0.8'in paketi) → `main`. Komut:
`git log --oneline f4de936..origin/main -- mobile/app mobile/kelimeki_core`*

**Yenilik — tek konu:** "oynayarak öğren" tanıtımının port ikizi ve onun
cihaz/tarayıcı turu. Ayrıntı yukarıda, "1.0.9" bölümünde.

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `4f5d31f` | 07.09.2026 | Onboarding Faz 4 — tanıtımın port ikizi: `ui/tutorial/` (senaryo + ekran), kapı (`util/onboarding.dart`, `FlagsStore.seenTutorial`), `BoardWidget.targets`/`coach`, `RackWidget.highlight`, `ui/game/drag_feel.dart` (üç ekranın ortak sürükleme hissi) | web + port |
| `e2b6cfe` | 07.09.2026 | Tanıtımın tarayıcı turu: karşılama penceresi, balon hiza hatası (Stack gevşek kısıt), punto/iki satır, OYNA okunun hedefi, raf balonunun şeridi örtmemesi, "bölge" terimi | web + port |

⚠ `c235b25` (#483, Faz 1) komutun çıktısında görünür ama pakete GİRMEZ:
`mobile/` altında yalnızca bir test dosyasına dokundu.

### 1.0.8 — 8 mobil commit

*Pencere: 6 Eyl (derleme `78383eb` sonrası) → `f4de936` (7 Eyl). Komut:
`git log --first-parent 78383eb..dd55ae0 -- mobile/app/lib
mobile/kelimeki_core/lib mobile/app/pubspec.yaml`*

**Yenilik — tek konu, ROADMAP #23 seviyeli YZ, Faz 2'den 5'e:** Yapay Zeka
oyununda **Zorluk** seçici (Kolay · Normal · Zor); Kolay'da YZ en iyi 4
hamleden rastgele birini oynar (`aiLevelTopN`), Zor'da GENİŞ arama
(`aiLevelSearch`: kanca hücresinden paralel diziş + çok çapalı kelime —
`reducer_ai2_zor` golden'ı); k-lig puanı seviyeye göre; üç renkli rozet
üç kart + devam eden kartı + tahta şeridi; seçici altı açıklama; kart altı
puan satırı; `games.ai_level` yazılır ve okunur; rövanş seviyeyi taşır;
yardım ekranına zorluk paragrafı. Normal'de hiçbir şey değişmedi
(golden'lar bayt-eş).

<details><summary>Commit dökümü (7)</summary>

| sha | Tarih | Ne | Kapsam |
|---|---|---|---|
| `fb5eb51` | 06.09.2026 | ROADMAP #23 Faz 2: YZ seviye motoru — findAIMoves/pickTopMove + aiLevelTopN, GameState.aiLevel, golden sıfır fark | web + port |
| `a47c3d2` | 06.09.2026 | ROADMAP #23 Faz 3: web ürün yüzeyi — portta yalnızca `league_points.dart` imzası | web + port |
| `42db22b` | 06.09.2026 | ROADMAP #23 Faz 4: YZ zorluğu portta — ZORLUK seçici, seviyeli k-lig puanı/rozet üç kartta, games.ai_level, parite testi | web + port |
| `5a540cb` | 06.09.2026 | Sürüm 1.0.8 — yalnız sürüm adı (`pubspec.yaml` + `env.dart`) | port |
| `7a7bc26` | 06.09.2026 | Zorluk seçicisinin açıklaması: her seviyede, kullanıcıya hitapla, puanı leaguePoints'ten | web + port |
| `df26f46` | 07.09.2026 | Zorluk rozeti üç renk + tahta şeridi + seçici stili; kart altı hizalı puan satırı | web + port |
| `dd55ae0` | 07.09.2026 | ROADMAP #23 Faz 5: Zor motoru = geniş arama, seçici web+portta açık; seviye açıklamasında ikincilik + misafir notu; "Nasıl oynanır?" boşlukları | web + port |
| `f4de936` | 07.09.2026 | Misafir Setup boşluk eşitlemesi (link altı 16px) + açıklama metninde nokta cümlenin sonunda | web + port |

</details>

---

## Bir sürüm yüklendiğinde ne yapılır

1. **Kütüğe satır ekle** — sürüm, `versionCode`, `sha`, yükleme tarihi.
   `versionCode` ile `sha`yı BİRLİKTE yaz: sahadaki bir ekran
   görüntüsündeki `Derleme <sha>` satırını Console'daki kayda bağlamanın en
   kısa yolu bu.
2. **`.aab`nin SHA-256'sını yaz** — indirdiğin anda. `mobile-latest` her
   mobil derlemede ÜZERİNE yazıldığından "şu an orada duran paket" ile
   "Play'e yüklediğin paket" birkaç saat sonra aynı şey olmayabilir.
3. **Bir önceki sürümün durumunu güncelle** (yayında → pasif).
4. **"Ne yapıldı — sürüm sürüm"e bir bölüm aç** — özet + commit dökümü.
   Dökümü elle yazma, o bölümdeki `git log --first-parent … -- mobile/app/lib
   …` komutunu koş; "hangi commit gerçekten pakete girdi" sorusunun tek
   dürüst cevabı bu. ⚠ Bir commit'in dokunduğu alanları `--stat` çıktısından
   grep'leme, `--name-only` kullan (bkz. 1.0.6 → #426 vakası).
5. **Sürüm turunu `ROADMAP.md`'de kapat**, kapanınca arşive taşı — bu dosya
   turu değil PAKETİ tutar.

## İnceleme süresi

| Sürüm | Gönderim | Yayın | Süre | Kaynak |
|---|---|---|---|---|
| 1.0.2 (435) | 30 Ağu 15:29 | 15:39 | **10 dk** | Console |
| 1.0.5 (501) | 2 Eyl 17:24 | ~17:58 | **~34 dk** | Console (gönderim) + release satırının "Last updated"ı |
| 1.0.6 (525) | 4 Eyl 15:53 | ≤ 16:22 | **≤ 29 dk** | Console (gönderim) + 16:22'de "Published" görüldü |
| 1.0.8 (569) | 7 Eyl 13:28 | ≤ 13:57 | **≤ 29 dk** | Console (gönderim) + 13:57'de "Published" bildirildi (Console'un yayın saati okunmadı) |
| 1.0.9 (581) | 8 Eyl 08:41 | ≤ 09:10 | **≤ 29 dk** | Console (gönderim) + 09:10'da "Published" bildirildi (Console'un yayın saati okunmadı) |
| **1.1.0 (627)** | 11 Eyl 08:01 | ≤ 08:33 | **≤ 32 dk** | Console (gönderim) + 08:33'te "Published" bildirildi (Console'un yayın saati okunmadı) |

⚠ **DÜZELTME (4 Eylül 2026):** bu bölüm daha önce 1.0.5 için **"≈23 dakika
(~14:40 → ~15:03)"** diyordu. O rakam Console'dan değil kullanıcının
bildirdiği anlardan türetilmişti ve **YÜKLEME ile GÖNDERİMİ karıştırıyordu**:
Console'a göre paket 14:22'de YÜKLENDİ ama incelemeye 17:24'te GÖNDERİLDİ.
İkisi arasında üç saat var. Doğru süre ~34 dk.

**Ders:** `.aab`yi yüklemek onu incelemeye sokmaz. Süreyi ölçerken
"Submission activity"deki **gönderim** anını al, paket listesindeki yükleme
anını değil.

⚠ **1.0.6'nın süresi bir ÜST SINIR, ölçüm değil.** Console'un "Submitted"
sütunu gönderim anını verir ama YAYIN anını satırın kendisi göstermiyor;
elimizdeki tek şey 16:22'de çekilen ve satırı "Published" gösteren ekran
görüntüsü. Yani inceleme 29 dakikadan KISA sürmüş, ne kadar kısa
bilinmiyor. Kesin süre satırın ok işaretine girilerek okunabilir —
okunmadı.

Çıkarım: "10 dakika" bir kural değil **alt sınır**; üç ölçümün üçü de
(10 dk · ~34 dk · ≤29 dk) yarım saat bandında. Yarım saati normal say ve
"yayınlanmadı herhâlde" teşhisini bir saatten önce kurma.

⚠ **Published ≠ testçinin telefonunda.** Kapalı testte paket yayınlansa bile
testçiye ulaşması için ayrı koşullar var; ayrıntı ve çare (opt-in linkine
tekrar girme) `build-and-distribution-log.md` → "Kapalı test" bölümünde.
