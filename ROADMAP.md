# Kelimeki — Sıradaki İşler (22 Ağustos 2026)

**Bu dosya bir FİKİR LİSTESİ DEĞİL, sıralı bir yürütme planı.** Kök
`CLAUDE.md`'deki "Sonraya Bırakılan Ürün Fikirleri" bölümü *ne* yapılacağını
ve *neden* ertelendiğini anlatır; burası *hangi sırayla*, *hangi modelle* ve
*hangi tuzaklara dikkat ederek* yapılacağını anlatır.

**Burada YALNIZCA AÇIK maddeler yaşar.** Bir madde kapandığında (✅ /
YAPILDI / KAPANDI / CANLIDA / SAHADA) **aynı PR'da**
`docs/decisions/roadmap-arsiv.md`'ye taşınır — başlığı, madde numarası ve
tek tek satırları değiştirilmeden, böylece ona yapılan atıflar kırılmaz.
Kalıcı bir ders üretmişse dersin kendisi ayrıca ilgili bölümün tarihli
notuna geçer (projenin genel "değişiklik = tarihli not" disiplini).

⚠ **Aşağıda bir bölüme atıf görüp bulamıyorsan arşive bak** — "Faz 1-7",
"1.0.3/1.0.4 sürüm turu", "madde 1/6/10/11/12/13/16" ve "Sürüm A" 2 Eylül
2026'da oraya taşındı. O gün ölçüldü: dosyanın **%45'i** kapanmış işti ve
118 KB'a bu yüzden çıkmıştı — eşik düşük olduğu için değil, bu kural
uygulanmadığı için.

**Durum (25 Ağustos 2026):** `main` yeşil. FAZ A1 cihaz turu Bölüm 6
(Paylaşma, iPad popover) hariç kapalı. Web + port paritesi güncel.
**24-25 Ağustos Android cihaz turu TEMİZ geldi** (dokunma hedefleri, "← Geri",
Paylaş, tahta açılışı, k-lig/Skor Kartı yükleme — yani #324 ve #325'in
cihazdaki karşılığı doğrulandı). **Madde 8 bundan ETKİLENMEDİ:** oradaki iş
iPad'in popover ankrajı, bu tur Android'de koşuldu.
**Google Play Console hesabı açıldı** (22 Ağustos) — bu, listenin sırasını
değiştirdi: artık omurga aşağıdaki **madde 0 (FAZ B)**, çünkü kişisel
hesaplarda production'a çıkmanın önünde **daha başlamamış 14 günlük bir
tester sayacı** var. Maddeler 1, 2 ve 4 o fazın içinde yaşıyor.

**Durum eki (27 Ağustos 2026):** Sürüm A merge edildi (`f9c3846`, paket
`1.0.0 (403)`) ve cihaz testinde. Dal Sürüm B için yeniden birikmeye
başladı; ayrıntı aşağıdaki "Yalnızca sohbette kalmış üç karar" bölümünde.

**21 Ağustos'ta kapanan ÜÇ madde** (kalan maddelerin numaraları DEĞİŞMEDİ):
- eski **#3** (istemci hata telemetrisi) — `client_errors` tablosu + web/port
  raporlayıcıları + admin panelinde "Hatalar" sekmesi. Kaydı kök
  `CLAUDE.md` → "İstemci Hata Telemetrisi" bölümünde.
  **Ders (bu turda çıktı):** dördüncü admin sekmesi tek sıraya SIĞMIYORDU —
  320px'te kabı 77px aşıp `overflow-hidden` tarafından sessizce kırpılıyordu.
  Bir sekme/buton eklemek "tek satır" değil bir DÜZEN değişikliğidir; ölç.

Aşağıdaki ikisinin kaydı kök `CLAUDE.md` → Kaynak Hunisi bölümünde:
- eski **#9** ("Oyun başladı" olayı) — `game_starts` tablosu + huniye
  "Başlayan" sütunu, web + port. Bir sonraki reklam harcaması artık
  ölçülebilir.
- eski **#7** (davet linkine `?ref=arkadas`) — "tek satır" sanılıyordu,
  ÖLÇÜNCE tek başına no-op olacağı çıktı: `/davet/:token` ve `/game/:id`
  `?ref=` etiketini HİÇ yakalamıyordu (`captureUtmSource` `App.tsx`'teydi,
  o iki route `App`'i mount etmiyor). Yakalama `boot.tsx`e taşındı.
  **Ders:** bu dosyadaki efor tahminleri (`low`/`medium`) bir SÖZ değil —
  işin gerçekten tek satır olduğunu ölçmeden varsayma.

---

## Faz planı — kalan işlerin YAYIN sırası (29 Ağustos 2026)

Kullanıcı isteği: *"Tüm işleri fazlandırıp plan yapalım. Uygun gördüğün
maddeleri ona göre birleştirip sırayla yayına alalım."*

Bu bölüm aşağıdaki maddelerin YERİNE geçmez — onların **hangi paketle
çıkacağını** söyler. Madde 0 (FAZ B) omurga olmaya devam ediyor.

**Fazları belirleyen tek kısıt, bir tercih değil bir ölçüm:**

| Değişiklik türü | Bedeli | Ne zaman canlıda |
|---|---|---|
| İstemci (Flutter) | paket + Play incelemesi + cihaz turu | sürüm turu |
| Sunucu (migration / Edge Function) | yok | **anında**, merge'den bağımsız |
| Web (`src/`) | yok | `main`'e merge → Vercel |

Yani maddeleri "konu"ya göre değil **paketlenebilirliğe** göre grupladım.
Sonuç: kalan HER ŞEY **iki sürüm turuna** sığıyor — bildirim işinin yarısı
sunucu tarafında olduğu için sürüm beklemiyor.

### Kalan işlerin tamamı — tek bakışta (2 Eylül 2026'da güncellendi)

✅ **O BLOKER DÜŞTÜ (10 Eylül 2026, 15:26).** Aylardır sırayı belirleyen
şey koda değil takvime bağlıydı: kişisel hesaplarda **12 tester × 14 gün
kesintisiz**. Sayaç doldu, kartın üç şartı da çizildi ve **production
başvurusu gönderildi**; Console *"7 gün ya da daha az"* diyor ve sonucu
`destek@kelimeki.com`'a yazacak. Cevaplar, ölçümler ve soruların tam metni:
`marketing/play-store/console-formlari.md` §7 — **ret gelirse oradan devam
edilir, sıfırdan yazılmaz.**

| Kova | Ne | Durum |
|---|---|---|
| **Sayaç** | 12 tester × 14 gün | ✅ **DOLDU — başvuru gönderildi 10 Eyl 2026, 15:26; inceleme ≤7 gün, sonuç e-postayla** · ⚠ karttaki **12**'nin gerçek adet mi şartın tavanı mı olduğu ÖLÇÜLMEDİ (2 Eylül, kullanıcı itirazı — aşağıda) · *Android developer verification* ✅ **BİTTİ** (Console'dan doğrulandı 31 Ağustos: `com.kelimeki.kelimeki` Registered, 3 anahtar, Identity dolu) |
| **Console (elle)** | — | ✅ **KAPANDI** (bu satır 31 Ağustos'a kadar bayat kaldı; ayrıntı aşağıda) |
| **1.0.4'e binecek kod** | Faz 6 istemci yarısı (rozet sıfırlama + sürüm damgası) · Faz 7 (iki çökme) · **+ #10 hata hız sınırı** (1 Eylül'de eklendi) | ✅ **1.0.4 (467) Play'e YÜKLENDİ, incelemede** (1 Eylül 2026) |
| **1.0.5'e binen kod** | Tahta zoom'u (+2 APK turu) · zoom tanıtım balonu · yazı ölçeği (sınıf 3+2) · mesaj kutusu etiketi · **cihaz turu düzeltmeleri (rozet kırpması · alt şerit · çevrimdışı şerit · zoom çerçevesi · filigranlar)** | ✅ **TUR KAPANDI** — `1.0.5 (501) — 4a0a29b` kapalı testte yayında (~15:03) ve üç işin cihaz doğrulaması da alındı (2 Eylül, kullanıcı). Ayrıntı: arşiv → "1.0.5 SÜRÜM TURU" |
| **1.0.6'ya binen kod** | Biten Canlı oyunun haberi (`OYUN BİTTİ`/`TESLİM OLDUN` + `YENİ` rozeti + sekme sayacı) · skor kartında kafa kafaya oran çubuğu · `Tüm Oyunlar` etiketinin tekleşmesi · **oyun geçmişine "Tekrar Oyna" (rövanş)** | ⏳ **`1.0.6 (525) — 711eaaa`** 4 Eylül'de kapalı teste çıktı (Submission 12; inceleme ≤29 dk), **6 Eylül'de `1.0.7 (545) — 78383eb` devraldı; 1.0.8 gönderilmeyi bekliyor** (kütük: `mobile/docs/surumler.md`). Kullanıcı kuralı sağlandı: APK önce cihazda koşuldu (§0-§4'ün koşulabilir maddeleri geçti). **TUR HENÜZ KAPANMADI.** Play imzalı paket 4 Eylül'de cihaza kuruldu ve §7'nin "güncelleme yokken pencere çıkmamalı" dalı geçti. §4.5 (davet linki uygulamayı açıyor) da geçti ve App Links doğrulamasını kanıtladı. Kalanlar: §4.1 (kayıt onayı) + kabul akışının uygulama içi maddeleri — ikisi de **YENİ bir hesap** ister (Ironman ↔ T3 zaten arkadaş, T2 Play'in test hesabı) · §1.4 ("ŞİMDİ DEĞİL") de KAPANDI (4 Eylül, kullanıcı gözlemi) · §7'nin "güncelleme VARKEN" dalı — ancak 1.0.6 kuruluyken 1.0.7 yayınlanınca koşulabilir. Kanonik paket kütüğü: `mobile/docs/surumler.md` |
| **Cihazda denenmemiş** | §3c'nin davete özgü dalları · GA4 DebugView | ⏳ bildirim→tahta DOĞRULANDI (sıcak+soğuk, 31 Ağustos); **1.0.5'in tamamı 2 Eylül'de onaylandı** (zoom turu, çevrimdışı şerit, filigranlar, balon, yazı ölçeği, mesaj etiketi) — kalan iki kalem bu ikisi |
| **Karar verilmiş, yapılmamış** | — | ✅ Kova BOŞ: **#3** hatırlatma, **#8** iPad paylaşımı (3 Eylül cihazda doğrulandı) ve **#16** kart düzeni kapandı; üçü de arşivde |
| **Ertelendi** | #2 zorunlu güncelleme | ✅ **KAPANDI/ARŞİVDE** (2 Eylül 2026, kullanıcı: *"Artık app'de güncelleme çıkıyor, bunu görünce zaten yapar"*). ⚠ Sürüm kapısı DURUYOR ve artık KULLANILABİLİR — acil fren olarak `app_config.mobile_min_supported_version` |
| **Seviyeli YZ** | **#23** Kolay/Normal/Zor + seviyeye göre k-lig puanı — 5 faz (sunucu → motor → web → port → Zor motoru) | ⬜ **Faz 0-5 kod ✅ (Faz 5 = Zor motoru, 7 Eylül 2026: GENİŞ arama, YZ↔YZ %70/%72 — web'de canlı, portta 1.0.8 sürümüyle); kalan: Faz 5 SAHA ölçümü** (`admin_ai_balance` seviye kırılımı iki hafta: Kolay ~%30 · Normal ~%51 · Zor ~%70). Faz 0 ölçtü: **Kolay = N=4** (200 oyun/N; N=3 %36, N=4 %33, N=5 %22 — backlog notu) |
| **İsteğe bağlı** | #5 k-lig grafiği · #9 admin filtre · #14 tembel liste | ⬜ hiçbiri yolu tıkamıyor · **#10 hata hız sınırı ✅** ve **#11 platform filtresi ✅ YAPILDI** (31 Ağustos 2026) |
| **Yapıldı** | #6 taranabilir `/nasil-oynanir/` sayfası | ✅ 31 Ağustos 2026 |
| **Play Store'a girdikten sonra** | **#17 Google ile giriş** — sunucu → web → mobil; migration BLOKER (OAuth bugün `handle_new_user`'da patlar) | ⏳ ERTELENDİ — acelesi yok, çalışan kimlik akışına şimdi dokunulmuyor (2 Eylül, kullanıcı). ⚠ Sayaçla İLİŞKİSİ YOK; o bağ aynı gün koptu, gerekçe #17'de |
| **iOS/App Store** | 🔓 **BLOKE KALKTI** (8 Eylül 2026 — Apple Developer hesabı açıldı). Fazlı plan: **#24 FAZ C**. Kalan iş APNs'ten İBARET DEĞİL: Mac'siz imzalama/TestFlight zinciri, entitlements, Associated Domains ve mağaza vitrini de bu fazın parçası | ⬜ |

⚠ **"Console (elle)" satırı 31 Ağustos'a kadar BAYAT kaldı** — dört maddesi
de aslında 25-26 Ağustos'ta bitmişti ve bu tablo onları hâlâ "kullanıcıda"
gösteriyordu. Kullanıcı akşam "formları şimdi güncelleyelim" dediğinde
yapılacak iş olmadığı anlaşıldı. Tek tek:

| Satırın dediği | Gerçek |
|---|---|
| Data deletion → "uygulama içi yol VAR" seçimi | **Böyle bir form alanı YOK.** Silme sorusunun cevabı `Evet → kelimeki.com/hesap-silme/` ve öyle kalıyor; Play'in uygulama içi şartı bir form alanı değil, uygulamanın KENDİSİNDE aranan politika şartı — 372'de karşılandı. `marketing/play-store/console-formlari.md` §3.8 bunu 26 Ağustos'ta "ENGEL KALKTI, beyanda değişen bir şey YOK" diye kapatmıştı |
| Kategori (Oyunlar → Kelime) | ✅ Games → Word, 25 Ağustos |
| İletişim e-postası | ✅ `destek@kelimeki.com` |
| Web sitesi | ✅ `https://kelimeki.com` |

**Ders:** bir işin kaydı İKİ yerde durursa (burada özet tablo, orada cevap
kâğıdı) biri kapanırken öteki kapanmıyor. Bu tablo bir İNDEKS — bir kova
kapandığında kaynağı `console-formlari.md`'dir, karar oradan okunur.

### Sonra / bloke

Açık madde KALMADI. **#8** (FAZ A1 Bölüm 6 — Paylaşma, iPad popover)
✅ **KAPANDI** 3 Eylül 2026 — hata bulunup düzeltildi ve Appetize/iPad'de
doğrulandı; arşivde.
**#11** (hata panelinde platform filtresi) ✅ **KAPANDI** 31 Ağustos 2026
— bu satır 2 Eylül'e kadar onu hâlâ bekleyen iş gibi gösteriyordu, oysa
aynı gün yukarıdaki özet tablo ✅ diyordu (kaydın iki yerde durması).
**#12** (sürüm dağılımı kapsamı) ✅ **KAPANDI** 31 Ağustos 2026 — bkz.
arşivde "Faz 6".
**#15 — uygulama öne gelince bildirim panelini temizle** → ✅ **KOD TAMAM**
(31 Ağustos 2026), sıradaki mobil sürümle çıkar. Ayrıntı arşivde: "Faz 6".
**iOS/App Store** → 🔓 **artık bloke DEĞİL** (8 Eylül 2026, Apple Developer
hesabı açıldı); fazlı plan **#24 FAZ C**. Push tasarımı bilerek FCM üzerinden
yazıldığı için **ikinci bir gönderici YAZILMAYACAK** — bu karar duruyor ve
sunucu tarafı ölçülünce zaten iOS-hazır çıktı (`apns-collapse-id` yazılmış,
`push_tokens.platform` `'ios'` kabul ediyor; kanıtlar #24.0'da). ⚠ Bu satır
uzun süre kalan işi *"APNs anahtarını yükle + Push capability"* kadar
gösterdi; ölçüm daha büyük çıktı (imzalama zinciri, entitlements, AASA,
vitrin) — tahmin, kaynak okunarak düzeltildi.

## Sürüm sıralaması, force update ve davetliler (27 Ağustos 2026)

Bu bölümde artık TEK konu var: açık test penceresinin İŞLETİM bilgisi.
Koda yazılamadığı için buraya yazıldı; oturum kapanınca kaybolmasın.

⚠ Başlıktaki öteki iki konu 2 Eylül 2026'da KAPANDI ve arşive taşındı:
"force update" (#2 — kullanıcı kararı, Play'in kendi güncelleme bildirimi
yeterli) ve "davetliler" (#3 — zaten yürüyen bir alışkanlık). Başlık,
atıflar kırılmasın diye değiştirilmedi.

⚠ **Sürüm kapısı silinmedi ve artık KULLANILABİLİR durumda** (#2 kapansa
bile): `config/version_gate.dart` her açılışta `app_config`teki
`mobile_min_supported_version`ı okuyor, düşükse `UpdateRequiredScreen`e
düşürüyor, ulaşılamazsa FAIL-OPEN. #2'nin engel saydığı iki eksik de
bugün YOK (kod okundu): `appVersion` artık sürümü takip ediyor (`1.0.5`,
parite testiyle zorlanıyor) ve ekranda `market://` + web yedeği var. Yani
acil bir fren gerekirse eşiği yükseltmek YETER.

### Sayaç — nerede okunur, 14. gün ne zaman

✅ **KAPANDI 10 Eylül 2026** — sayaç doldu, başvuru gönderildi (15:26).
Aşağısı bir sonraki uygulama/hesap için işletim bilgisi olarak duruyor.
⚠ Tahmin TUTTU: bu bölüm *"14. gün ~10 Eylül"* diyordu ve kart tam o gün
açıldı.

⚠ Bu bir MADDE değil, açık pencerenin işletim bilgisi. *"Davetlilere
hatırlatma"* maddesi 2 Eylül 2026'da KAPANDI (kullanıcı: *"Hep ben
hatırlatıyorum zaten, burada madde olarak durmasına gerek yok"*) — arşivde:
`docs/decisions/roadmap-arsiv.md` → *"3. Davetlilere hatırlatma"*. Aşağısı
o maddeyle birlikte kaybolmasın diye burada kaldı.

**Sayacın yeri:** Dashboard → (aşağı kaydır) Production → `Apply for access
to production` kartı. Test menüsünde DEĞİL; track sayfasında da yok
(ölçüldü). **14. gün ~10 Eylül 2026** (sayaç 27/28 Ağustos'ta başladı;
Console'un günü nasıl saydığı ölçülmedi, ±1 gün kabul et ve tarihi kartın
kendi metninden takip et).

**Katılan/indiren sayısı:** Test → Closed testing → (track) → **Testers**
sekmesi — ⚠ oradaki sayı opt-in DEĞİL, **izin listesi**; indirme adedi için
**Statistics**.

**14 gün dolmadan yapılabilecek iki iş** (ikisi de hâlâ açık): karttaki
**`Preview questions`**'dan başvuru sorularını okuyup cevapları hazırlamak,
ve tester'lardan **yazılı geri bildirim** toplamak (başvuru "testi nasıl
yürüttün" diye soruyor).

#### ✅ "12" TAVAN — kapandı (6 Eylül 2026, kullanıcı tespiti)

Kullanıcı, Console'a bakarak kapattı: *"12 kişi Tavan, google daha fazla
olsa bile gerçek sayıyı göstermiyor."* Yani kart `min(gerçek, 12)`
gösteriyor; 2 Eylül'deki sezgisi (*"12'den fazla katılım olduğunu
düşünüyorum"*) doğruymuş.

Eski kayıt iki tezi yan yana tutuyordu ve ayırt edici gözlem olarak
*"sayının 12'nin ÜSTÜNE çıktığının bir kez görülmesi"*ni işaret ediyordu.
**O gözlem hiçbir zaman gerçekleşemezdi** — tavan tam da onu engelliyor.
Ayırt etme yöntemi olarak yanlış seçilmişti; doğru kaynak baştan beri
Console'un kendisiydi ve ona yalnızca kullanıcı bakabiliyor (bu oturumların
Play Console erişimi YOK).

**Pratik sonucu — kartın sayısı bir kapasite ölçüsü DEĞİL:**

| Soru | Kart cevaplıyor mu |
|---|---|
| Şart sağlanıyor mu (≥12)? | ✅ evet, 12 yazıyorsa sağlanıyor |
| Kaç kişi var, payımız ne kadar? | ❌ hayır, 12'de sabitleniyor |
| Biri düşerse eşiğin altına iner miyiz? | ❌ karttan ANLAŞILMAZ |

Son satır önemli: *"biri düşerse sayaç sıfırlanır"* endişesi kartla
yanıtlanamaz, çünkü kart payı gizliyor. Gerçek katılım için **Test →
Closed testing → (track) → Testers** (izin listesi) ve **Statistics**
(indirme) sekmelerine bakılmalı — ikisi de yukarıda tarif edildi.

Kaynak kayıt: `marketing/play-store/console-formlari.md` §7.

## Sıradaki sürüme binecekler — `main`'de var, MAĞAZADA yok

⚠ **SÜRÜM 1.1.0 HAZIR (10 Eylül 2026 gece).** `appVersion` + `pubspec`
1.1.0'a çekildi (#514); mağazadaki paket hâlâ **1.0.9 (581)**, yani
aşağıdaki 11 satırın tamamı bu sürümle gidiyor. **Android paketine
GERÇEKTEN binen dört iş:** #488 (onboarding Faz 2·3·5) · #509 ("Kalan
Taşlar" çökmesi) · #512 (Arkadaşlar → "Davetler") · #514 (hiç oynanmamış
oyunun bulut kaydı + tanıtım rozetleri + yapışık `OYUNU BAŞLAT`). Geri
kalanlar `ios/` altında, CI'da ya da yalnızca `test/`te — ikiliye girmiyor
(her satırın kendi ⚠'ı bunu söylüyor). Doğrulama komutu:
`git log --oneline 1abde38..origin/main -- mobile/app mobile/kelimeki_core`
(10 Eylül gecesi koşuldu: 12 commit, tablo eksiksiz).

⚠ **DURUM (8 Eylül 2026): 1.0.9 (581) = `1abde38` kapalı testte YAYINDA
(gönderim 08:41, yayın ≤ 09:10). Liste aynı gün SIFIRLANDI, ama AYNI GÜN
yeniden doldu — onboarding Faz 2·3·5 (#488) porta dokundu, aşağıdaki tabloya
bak.** Turun kaydı (paket, içerik tablosu, dersler):
`docs/decisions/roadmap-arsiv.md` → "1.0.9 sürüm turu"; paket künyesi ve
sürüm notları `mobile/docs/surumler.md` → "1.0.9 (581)".

⚠ **`mobile-latest` her mobil derlemede ÜZERİNE yazılır** — sıradaki sürüm
adı Play'e yüklenene kadar `main`'e giren her mobil iş bu paketi de
değiştirir (1.0.4/467 dersi, arşivde). Yüklemeden önce indirdiğin `.aab`nin
derleme sha'sını `main`'in başıyla karşılaştır.

**Kapalı testteki paket:** 1.0.9 (581) = commit `1abde38` (#486),
8 Eylül 2026'da yayınlandı.

**O paketten beri porta dokunan işler — sıradaki sürümün içeriği.** Yeni bir
satır eklemeden önce komutu KOŞ (aşağıdaki uyarı):

| Commit / PR | Ne | Neden porta dokunuyor |
|---|---|---|
| `80f3769` (#488) | Onboarding Faz 2·3·5 — bağlamsal ipuçları (`vergi`/`carpan`/`bolge`), tanıtımı tekrar oynama, `tutorial_events` ölçümü | Port ikizi aynı PR'da: `util/onboarding.dart` (ipucu kararı + sayaç), `storage/flags_store.dart`, `ui/game/game_screen.dart` (balon), `ui/game/help_modal.dart` + `ui/setup/setup_screen.dart` (tekrar oynama), `ui/tutorial/*`, `data/games_api.dart` (olay yazımı), `ui/auth/legal_modals.dart` (gizlilik metni "beş kayıt") |
| #490 (FAZ C) | iOS Firebase yapılandırması — `GoogleService-Info.plist` + Xcode kaydı | `ios/Runner/GoogleService-Info.plist` (YENİ), `ios/Runner.xcodeproj/project.pbxproj` (dört girdi), `lib/src/data/push_init.dart` (bayat yorum). ⚠ **Android'i ETKİLEMEZ** ve **iOS'ta da davranış DEĞİŞMEZ**: `Firebase.initializeApp()` artık iOS'ta başarılı oluyor ama APNs kaydı `aps-environment` entitlement'ı istiyor, o henüz yok → `getToken()` fırlatır ve `PushRepo` yutar. Yani bu satır sıradaki Android sürümüne **hiçbir şey** taşımıyor; tabloda olmasının sebebi `mobile/app/` altına dokunmuş olması |
| #492 (FAZ C) | iOS entitlements + bildirim paneli kanalı + Mac'siz imzalama zinciri | `ios/Runner/Runner.entitlements` (YENİ), `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner.xcodeproj/project.pbxproj`, `Gemfile` + `fastlane/*` (YENİ), `test/notification_shade_parity_test.dart`. ⚠ **Android'i ETKİLEMEZ** — dokunulan her şey `ios/` altında ya da yalnızca CI'da koşan imzalama zinciri. ⚠ Bu satır 9 Eylül 2026'da **geriye dönük** eklendi: #492 kendi PR'ında tabloya yazılmamıştı ve refleks komutuyla (`git log 1abde38..origin/main -- mobile/app`) yakalandı — kuralın BEŞİNCİ kaçırılışı |
| #497 (FAZ C 24.5) | Mağaza ekran görüntüsü boru hattı — `integration_test/` + `test_driver/` | `pubspec.yaml` (`integration_test` **dev** bağımlılığı), `integration_test/store_screenshots_test.dart` (YENİ), `test_driver/integration_test.dart` (YENİ). ⚠ **Sıradaki sürüme HİÇBİR ŞEY taşımıyor**: dev bağımlılığı mağazaya giden ikiliye girmez, `flutter test` `integration_test/`i toplamaz ve yeni kod yalnızca `flutter drive` ile koşar. Tabloda olmasının sebebi `mobile/app/` altına dokunmuş olması |
| #498 · #499 · #500 (FAZ C 24.2) | TestFlight zincirinin ilk gerçek koşuları — `setup_ci`, `build_app` yolları, elle imzalama | Yalnızca `fastlane/Fastfile` (+ `mobile-build.yml`). ⚠ **Sıradaki sürüme hiçbir şey taşımıyor** — fastlane yalnızca CI'da koşuyor, uygulama ikilisine girmiyor. Tabloda olmasının sebebi `mobile/app/` altına dokunmuş olması |
| #505 (arşiv §25) | iPad düzen kapısı — `test/ipad_layout_test.dart` (YENİ, 9 test) | Yalnızca bir TEST dosyası. ⚠ **Sıradaki sürüme HİÇBİR ŞEY taşımıyor** — `test/` mağazaya giden ikiliye girmez ve uygulama kodu değişmedi (§25'in kararı zaten *"düzen değişmiyor"*). Tabloda olmasının sebebi #497'nin aynısı: `mobile/app/` altına dokunmuş olması. ⚠ Aynı PR'da denenen `integration_test` yolu GERİ ALINDI (simülatör döndürülemiyor — `UISceneErrorDomain 101`), `store_screenshots_test.dart` bayt bayt eski hâlinde |
| #509 (10 Eyl) | "Kalan Taşlar" penceresi `myIndex` -1'de ÇÖKÜYORDU | ⚠ **SÜRÜME BİNİYOR:** `ui/game/remaining_tiles_modal.dart` — `players[-1]` Dart'ta RangeError atıyor, web'de aynı satır `?.rack ?? []` olduğu için hata YALNIZCA porttaydı. Canlı ekranın `_mySlot`'u koltuk bulamazsa -1 döner (o ekran altı yerde eliyor, modal elemiyordu). Regresyon: `game_screen_test.dart` → *"myIndex -1 iken ÇÖKMEZ"*, duyarlılığı düzeltme geri alınarak kanıtlandı. ⚠ Kullanıcının bildirdiği "elimdeki taş torbada görünüyor" şikâyeti BU DEĞİL — o ayrıca araştırıldı ve üretilemedi (kayıt: `docs/decisions/components-account.md`) |
| #501 (FAZ C 24.2) | iPad yönelimleri — Apple'ın 90474 reddi | ⚠ **BU SATIR SÜRÜME GERÇEKTEN BİNİYOR:** `ios/Runner/Info.plist` → `UISupportedInterfaceOrientations~ipad` dörde çıktı, yani **uygulama iPad'de döndürülebilir hâle geliyor** ve portta manzara düzeni YOK. Android'i ETKİLEMEZ (dosya `ios/` altında). Cihaz kontrolü: `mobile/TESTING.md` §26 |
| #512 (10 Eyl, kozmetik) | Arkadaşlar modalı "davet" diline geçti: sekmeler "Arkadaşlarım" → **Arkadaşlar**, "İstekler" → **Davetler**; sekmenin İÇİ de (buton etiketleri, onay diyaloğu başlıkları/metinleri, sonuç mesajları) *istek* → *davet* | ⚠ **SÜRÜME BİNİYOR:** `ui/friends/friends_modal.dart` **ve** `ui/score/player_score_card_modal.dart` — kartın ilişki simgesi aynı diyalogları açtığından ikisi birlikte çevrildi (kullanıcı isteği, 10 Eylül 2026). Metinler web ile BİREBİR. Yalnızca GÖRÜNEN METİN: sekme kimlikleri (`FriendsTab.requests`), RPC adları ve veri dili değişmedi; e-posta/push metinleri (Edge Function) bilerek kapsam dışı. `test/friends_test.dart` etiketi büyük harfle arıyor (`DAVETLER`) ve sonuç mesajlarını metinle eşliyor |
| #514 (10 Eyl gece) | Hiç oynanmamış YZ oyunu artık portta da HİÇ kalıcılaştırılmıyor (`turnCount<2` kapısı autosave'in ÖNÜNE geçti) | ⚠ **SÜRÜME BİNİYOR:** `data/cloud_save_repo.dart` + `game/local_game_repo.dart`. İlk TestFlight turunda cihazda görüldü: hamle yapılmamış oyun "Devam Eden Oyunlar"da belirip kayboluyordu. Web bu kapıyı 31 Ağustos 2026'da koymuştu, port ikizi o gün güncellenmemişti — `end()`teki eşik yalnızca TEMİZ çıkışı kapsıyor, iOS uygulamayı öldürünce satır bulutta (yani web dahil her cihazda) hayalet kalıyordu. Sekiz test eski davranışı kodluyordu, üçü yeni sözleşmeye çevrildi; `dart analyze` temiz, **830 test yeşil**. Kayıt: `docs/decisions/local-game-persistence.md` + Parça 197 |
| #514 (10 Eyl gece) | Tanıtım 1. slayt: X2/X3 rozetleri dar ekranda SARMIYOR, sığdırılıyor | ⚠ **SÜRÜME BİNİYOR:** `ui/intro/intro_screen.dart` — iPhone'da bildirildi. Ölçüldü (gerçek fontlar): **375 pt genişlikte varsayılan yazı boyutunda bile** sarıyordu (390/393 pt sarmıyor; 393 pt ×1,15'te sarıyor). 375 pt gerçek bir hedef: iPhone SE/mini + Display Zoom açık her iPhone. Sarma taşma üretmediğinden hiçbir test görmemişti — `intro_screen_test` artık 375 pt ve ×1,3 de ölçüyor |
| (11 Eyl, FAZ C 24.5) | Mağaza kareleri **başlıklı** oldu + **7. kare** (k-lig sıralaması) + karelerden alfa kanalı kaldırıldı | `integration_test/store_screenshots_test.dart`, `test_driver/png_flatten.dart` (YENİ), `test/png_flatten_test.dart` (YENİ), `pubspec.yaml` (`image` **dev** bağımlılığı — transitif geliyordu, import edildiği için açıkça bildirildi) (+ `.github/workflows/ios-screenshots.yml`). ⚠ **Sıradaki sürüme HİÇBİR ŞEY taşımıyor** — `integration_test/`, `test_driver/`, `test/` ve dev bağımlılıkları mağazaya giden ikiliye girmez; uygulama kodu (`lib/`) hiç değişmedi. Tabloda olmasının sebebi #497/#505'in aynısı: `mobile/app/` altına dokunmuş olması |
| #514 (10 Eyl gece) | Setup'ın `OYUNU BAŞLAT`/`VAZGEÇ` satırı ekranın altına YAPIŞIK + **sürüm 1.1.0** | ⚠ **SÜRÜME BİNİYOR:** `ui/setup/setup_screen.dart` (+ `config/env.dart` · `pubspec.yaml`). Ölçüldü (gerçek güvenli alan payı): 375 pt ×1,0'da buton 769–786, görünür sınır 778 → **varsayılan ayarlarla kesik**; 393 pt ×1,3'te de kesik. Kullanıcı kararı: eşik oyunu değil, sınıfı kapatan çözüm. Kapı: `setup_screen_test` üç bileşimi ilk karede ölçüyor |

`main` ile mağazadaki paket bilerek ayrışabilir; bu bölüm o farkı görünür
tutuyor, çünkü fark tam da unutulmaya müsait yerde duruyor — `main` yeşil,
web canlı, CI derlemesi hazır, ama Play'e giden hiçbir otomatik yol YOK
(gönderim elle).

⚠ **Listeye GÜVENME, komutu koş.** Bu tablo DÖRT kez eksik yakalandı: bir kez
bölümü yazan PR kendi diff'ini saymamıştı (4 Eylül), bir kez porta dokunan
iki commit hiç eklenmemişti (5 Eylül — `#452` ve `#457`), bir kez de Faz 2'nin
motor commit'i (6 Eylül). **Dördüncüsü #488** (8 Eylül): PR ROADMAP'e dokundu
(madde 24'ü arşive taşıdı) ama bu tabloyu boş bıraktı — üstelik 14 dosyayla
porta dokunuyordu. Yani "kendi PR'ını da say" uyarısı, o uyarıyı taşıyan
bölümün kendisinde bir kez daha atlandı; tablo aynı gün yayınlanan bir
sürümün ardından "YOK" derken doldu. İkincisinin bedeli
ölçüldü: eksik liste yüzünden sürüm bir gün gecikti, üstelik eksiklerden biri
gerçek bir hata düzeltmesiydi. Refleks:

```
git log --oneline <mağazadaki-paketin-commiti>..origin/main -- mobile/app mobile/kelimeki_core
```

⚠ **Kendi PR'ını da say** — kapanan işi arşive taşırken tabloyu da güncelle.

⚠ **Play Console hakkında bir şey yazmadan ÖNCE SOR.** Bu oturumların Play
Console erişimi YOK. 6 Eylül 2026'da iki yanlış hüküm kuruldu (uydurma bir
"14 gün sayacı sıfırlanır mı" gönderim kapısı ve "12 tavan mı" sorusu için
gerçekleşmesi imkânsız bir ayırt etme yöntemi). Kayıt:
`docs/decisions/roadmap-arsiv.md` → "1.0.7 sürüm turu".

**Test penceresi:** 7 Eylül itibarıyla **12. gün**, 14. gün ≈ 10 Eylül.
"Kalan günlere ne konsun" tartışması KAPANDI: seviyeli YZ (#23 Faz 0-4) aynı
gün bitti ve bu sürüme biniyor. Başvuru için hâlâ açık iki iş kod değil:
`Preview questions`'ı okuyup cevap hazırlamak + tester'lardan YAZILI geri
bildirim (bkz. "Sayaç" bölümü).

**Göndermeden önce, sırayla:**

1. **Sürüm adını artır — İKİ dosya birden:** `mobile/app/pubspec.yaml`
   (`version:`) **ve** `mobile/app/lib/src/config/env.dart` (`appVersion`);
   `app_version_parity_test` ikisini kilitliyor. Derleme numarası
   (`versionCode`) ELLE VERİLMEZ — CI `--build-number` ile
   `github.run_number`ı basıyor, yani her koşu Play için yeni ve artan.
2. **Cihaz turu — yukarıdaki içerik tablosunun kapsadığı maddeler:**
   `mobile/TESTING.md`'nin ilgili bölümleri + o sürüme özgü yeni davranış.
   Sürümler arası geçişte `mobile/docs/testing-bildirimler.md` §7'nin
   "güncelleme VARKEN" dalı da denenebilir (Play In-App Update penceresi) —
   ⚠ bu dal YALNIZCA Play'den kurulmuş pakette çalışır, yan yüklenen APK'da
   sessizce devre dışıdır; 1.0.6→1.0.7 ve 1.0.7→1.0.8 geçişlerinde
   koşulmadı, kayıt hâlâ yok.
3. **Test ettiğin paketin TAZE olduğunu doğrula:** Setup'taki
   `Derleme <sha>` satırı `main`'in başıyla (bu PR'ın merge commit'i) aynı
   olmalı. Appetize'da Android ve iOS AYRI zamanlarda tazeleniyor (bkz.
   `mobile/docs/test-ortamlari.md`), yani iOS'ta eski derlemeyi test etmek
   kolay bir hata. Kullanıcı kuralı: *"apk ile test edip sorunsuz olduğundan
   emin olmadan aab yapılmayacak"* — APK turu geçmeden `.aab` yüklenmez.

## Güvenlik geçişi — açık kalan maddeler (5 Eylül 2026)

Play Store öncesi kapsamlı incelemenin ilk geçişi. **Kapatılan madde
(oturumsuz kimlik sızıntısı) burada DEĞİL** — uygulandı ve
`docs/decisions/supabase-ops.md` → "Play Store öncesi güvenlik geçişi"ne
yazıldı. Aşağıdakiler hâlâ açık.

**İncelemenin dört geçişi de BİTTİ** (kullanıcı isteği,
5 Eylül 2026: *"Play Store öncesi kapsamlı bir code review... Buglar,
temizlik, güvenlik, performans"*). Sıra ve gerekçe:

| # | Geçiş | Durum |
|---|---|---|
| 1 | **Güvenlik** — RLS, grant'ler, RPC yetkileri, Edge Function kapıları | ✅ **BİTTİ** (5 Eylül 2026) |
| 2 | **Hata avı** — reducer/validator değişmezleri, web↔port paritesi, eşzamanlı yazım yarışları, hook sırası | ✅ **BİTTİ** (5 Eylül 2026) |
| 3 | **Performans** — bundle, sıcak sorguların index kapsamı (advisor'ın kendi listesi var), liste render'ı, N+1 RPC | ✅ **BİTTİ** (5 Eylül 2026) |
| 4 | **Temizlik** — ölü kod, erişilemez şubeler, kullanılmayan bağımlılıklar, bayat doküman atıfları | ✅ **BİTTİ** (5 Eylül 2026) |

⚠ **Her geçiş KENDİ oturumunda koşulmalı.** Ölçüldü: web `src/` 38.6K +
port 68.3K + Edge Function 4.1K satır, yani 111 bin satır uygulama kodu tek
bağlam penceresine sığmıyor. Tek turda "hepsini tara" denirse — hangi model
olursa olsun — yüzeysel bir liste ve yanlış pozitif çıkar.

⚠ **Model: Opus 5, efor `high`–`xhigh`.** Fable'a verme: `ROADMAP`in kendi
ölçütü Fable'ı "geri dönüşü OLMAYAN" iş için ayırıyor, inceleme ise rapor
üretir — yanlışsa bedeli bir turu yeniden koşmak. Fable'ın hak ettiği yer
bulguların DÜZELTMESİ: veri kaskadına ya da web+port+DB'yi birlikte
değiştirmeye çıkan bir düzeltme o sınıfa girer.

⚠ **Güvenlik geçişinin en büyük dersi:** dört bulgunun biri ölçünce BÜYÜDÜ
(anon sızıntısı), üçü ölçünce KÜÇÜLDÜ (#19/#20 kabul edildi, #21
sömürülebilir değildi). İlk rapordaki öncelik sırasını ölçümler tersine
çevirdi. Sonraki geçişlerde de bulguyu ciddiyetiyle birlikte YAZMADAN önce
ölç.

Zeminin sağlam olduğunu da kayda geçir, çünkü bir sonraki tur bunu yeniden
ölçmesin: 28 tablonun 28'inde RLS açık, 71 `SECURITY DEFINER` fonksiyonun
71'inde `search_path` sabitlenmiş, yazma politikalarında istisnasız
`auth.uid() = user_id` var, Edge Function `verify_jwt` envanteri kök
`CLAUDE.md`'deki 8'lik listeyle birebir tutuyor, repoda gömülü sır yok.
`notify-turn-timeout-surrender` / `notify-welcome` / `notify-your-turn`
herkese açık POST hedefi olmalarına rağmen doğru yazılmış (atomik iddia,
taze pencere, hedefi gövdeden değil canlı durumdan alma) — bulgu değiller.

### 18. `submit_move` puana değil yalnızca taşa hakem — **GÖLGE FAZINDA**

**Durum (5 Eylül 2026):** ayna yazıldı, canlıya uygulandı, gölge fazı AÇIK.
Karar hâlâ istemcinin değerleriyle veriliyor; sunucu paralelde kendi hesabını
yapıp sapmayı `move_shadow_diffs`e yazıyor. **Zorlama fazına ancak o tablo
gerçek oyunlarda boş kaldıktan sonra geçilecek.**

⚠ **"Tablo boş" TEK BAŞINA KANIT DEĞİL — kapı payda olmadan okunamıyor
(5 Eylül 2026 akşamı ölçüldü).** Boş bir tablonun iki zıt anlamı var: (a)
sunucu istemciyle birebir uyuştu, (b) o koddan hiç hamle geçmedi ya da sensör
öldü. Gölge fazı canlıya alındıktan ~1 saat sonra gerçek durum (b)'ye çok
yakındı: **0 sapma, ama payda yalnızca 10 hamle** (7 oyun, 6 oyuncu) — ve
ROADMAP'in "cihazda ayrıca sına" dediği riskli yolların TAMAMI sıfır
kapsamlıydı (0 vergili hamle, 0 joker bitişi, 0 bingo). Kapı nominal olarak
açıktı, kanıt olarak boştu.

İki şey eklendi:
1. **Sensörün canlı olduğu kanıtlandı** (negatif eş): `_km_shadow_check`e
   kasten yanlış bir istemci base'i verildi → `base_points` sapması YAZILDI;
   geçerli bir hamlede ise sıfır satır. Yani boşluk sensör ölümünden değil.
2. **`move_shadow_coverage` tablosu** (payda) — her gölge kontrolü bir gün
   satırını artırır ve riskli yolları AYRI sayar: `hamle`, `cok_oyunculu`,
   `vergi`, `joker`, `teslim_var`, `blokta_rakip` (sonuncusu 24 Ağustos
   "iletken hücre" kuralının ÖN KOŞULU — kuralın yükte olduğunu kanıtlamaz,
   ama sıfırsa hiç denenmediğini kesinleştirir). Sayaç yapısal erken-return'den
   ÖNCE ve KENDİ exception bloğunda artıyor; ikisi de
   `verify-sql-engine-parity`de kilitli ve negatif eşle sınandı.

**Ölçüm (6 Eylül 2026, 12:25 UTC) — sapma YOK, payda hâlâ kapının ALTINDA.**
`move_shadow_diffs`: **0 satır**. Payda (`move_shadow_coverage`):

| gün | hamle | cok_oyunculu | vergi | joker | teslim_var | blokta_rakip |
|---|---|---|---|---|---|---|
| 6 Eylül | 27 | 0 | 3 | 0 | 0 | 7 |
| 5 Eylül | 23 | 0 | 4 | 1 | 0 | 2 |
| **toplam** | **50** | **0** | **7** | **1** | **0** | **9** |

**Kapsamanın 1:1 olduğu ÖLÇÜLDÜ** — bu, yukarıdaki negatif eşin yanında
sensörün canlı olduğuna dair İKİNCİ ve sürekli kanıt, çünkü tek seferlik
değil her gün yeniden okunabiliyor: bugünkü `online_game_moves` `play`
sayısı **27**, sayaç da **27**; 5 Eylül'de sayaç migration'ından
(18:58 UTC) sonraki play **23**, sayaç da **23**. Yani gerçek hamlelerin
tamamı gölge kontrolünden geçiyor, "0 sapma" gerçekten uyuşma demek.
(5 Eylül 17:51–18:58 arasındaki 10 hamle gölgeden geçti ama sayaç henüz
yoktu — gerçek gölge paydası 60, sayılan 50.)

**Kapının neresindeyiz** (1. maddedeki sayısal ölçüte göre):
- ✅ `vergi` (7) · `joker` (1) · `blokta_rakip` (9) — üçü de sıfırdan çıktı,
  yani 24 Ağustos "iletken hücre" kuralının ön koşulu artık yükte.
- ❌ `hamle` **50**, ölçüt "birkaç yüz". Gerçek trafik ~100 play/gün
  (4 Eylül 91, 5 Eylül 105) → 300'e **~3 gün**.
- ⚠ `cok_oyunculu` ve `teslim_var` hâlâ **0**; gerçek trafikte
  birikmeyebilirler, tek kanıtları 2. maddedeki cihaz turu. Payda beklerken
  o tur PARALEL yürüyebilir — sıralı değiller.

Ayna tarafında drift yok: `npm run verify-sql-engine-parity` yeşil, canlıdaki
`_km_shadow_check` ve `submit_move` repodaki migration'larla tutuyor.

**Sıradaki değerlendirme: 9 Eylül 2026** (kullanıcı isteğiyle hatırlatma
kuruldu). O gün yalnızca iki sorunun cevabı gerekiyor: `move_shadow_diffs`
hâlâ boş mu, ve `hamle` birkaç yüze ulaştı mı. İkisi de evetse zorlama
fazının önündeki tek engel cihaz turu kalır.

**Madde ölçünce BÜYÜDÜ.** İlk yazımda üç eksik sayılıyordu (sözlük yok, harf
puanı yeniden hesaplanmıyor, tavan yok). Fonksiyonun tamamı okununca iki şey
daha çıktı:

- **Yerleştirme MEŞRUİYETİ de denetlenmiyordu.** Bitişiklik, süreklilik,
  "aynı satır/sütun", ilk hamlede ev karesi, kelime oluşması — hiçbiri yoktu.
  Katılımcı 7 taşı tahtaya dağınık serpebiliyordu.
- **`p_lost_shares` bir TRANSFER kanalıydı:** tutar yalnızca `p_base_points`i
  aşmamakla sınırlı, o da sınırsız — yani suç ortağının puanı da istendiği
  kadar yükseltilebiliyordu (iki hesaplı danışıklı senaryo).

**Sömürülmüş mü? Hayır** — 2.641 `play` hamlesi tarandı: max 56 puan, p99 38.

**Çözüm SQL'de, Edge Function'da DEĞİL.** Motorun Deno kopyası zaten vardı
(`_game/`, `play-ai-turn` kullanıyor) ama ölçüm tersini söyledi: Edge yolu her
hamleye bir ağ adımı ekler ve her soğuk isolate'te 63.905 kelimeyi yükler
(~1 MB) — bu maliyet YZ turunda kabul edilmişti, insan hamlesinin kritik
yoluna girmemeli. SQL'de sözlük zaten `public.words` (`word` PRIMARY KEY): bir
hamlenin oluşturabileceği EN FAZLA 8 kelimenin tamamı **1,1 ms**. Üstelik RPC
imzası değişmediğinden **kurulu mobil sürümler kırılmıyor**, EXECUTE revoke
penceresi beklemek gerekmiyor.

**Maliyet ölçüldü:** +7,5-8,6 ms/hamle (bölge hesabı %56'sı). `submit_move`
bugün zaten ortalama 23-42 ms; kullanıcının hissettiği süre ağ gidiş-dönüşü
olduğundan fark %5'in altında.

**Parite kanıtı** (kör test değil, negatif eşleriyle): 2.641 gerçek üretim
hamlesi boş tahtadan yeniden oynatıldı — skorda 0 sapma, yapısal+sözlükte 0
yanlış red. Vergide ham 10 sapmanın 7'si harness'ın kendi varsayımı (teslim
bayrağını oyun sonu snapshot'ından okuyordum), 3'ü 24 Ağustos "iletken hücre"
kural değişikliğinden önceki hamleler — üçünde de ESKİ kural kayıtlı değeri
birebir üretiyor. Açıklanamayan sapma: **0**. Ayrıntı:
`docs/decisions/roadmap-arsiv.md` → "Temizlik geçişi"nin ardındaki bölüm.

**AÇIK KALAN İŞ — zorlama fazı:**
1. `move_shadow_diffs`i **`move_shadow_coverage` ile BİRLİKTE** oku. Boş
   değilse zorlamaya GEÇME, önce sapmayı çöz (tablo `girdi` sütununda
   board+placed+players var, vaka tekrar üretilir). Boşsa da paydaya bak:
   ```sql
   select * from public.move_shadow_coverage order by gun desc;
   ```
   **Sayısal kapı (öneri, kullanıcı onayına tabi):** `hamle` birkaç yüze
   ulaşmadan ve `vergi` · `joker` · `blokta_rakip` sütunlarının her biri
   sıfırdan çıkmadan zorlamaya geçme — bunlar tam da 2. maddedeki riskli
   yollar, ve az geçtikleri için gerçek trafikte kendiliğinden birikmeleri
   zaman alır. `cok_oyunculu` ile `teslim_var` gerçek trafikte hiç
   birikmeyebilir; onlar için 2. maddedeki cihaz turu tek kanıt.
2. Cihazda dört yolu ayrıca sına (mevcut veride az geçiyor): 4 kişilik oyunda
   bölge etkileşimi, joker bitiş bonusu, oyun ortasında teslim, ve iletken
   hücre kuralının kendisi (bu dal golden vector'lara ilk girdiğinde sıfır
   kapsama vermişti — en riskli yer orası).
3. Zorlama migration'ı: `submit_move` `p_base_points`/`p_words`/
   `p_word_scores`/`p_lost_shares`i YOK SAYIP `_km_*` çıktısını kullansın,
   yapısal/sözlük hatasında `raise exception` etsin.
4. ⚠ Zorlamaya geçince istemci ile sunucu arasındaki HER kural farkı
   kullanıcıya hata olarak görünür. `verify-sql-engine-parity` sabitleri ve
   hata metinlerini kilitliyor ama davranışı kilitleyemiyor — o yüzden 1. adım
   atlanamaz.

### 19. `anon` için sınırsız telemetri yazımı — **ÖLÇÜLDÜ: KABUL EDİLDİ**

`client_errors`, `device_visits`, `guest_visits`, `game_starts` — dördünde
de INSERT politikası `with_check: true`, yani oturumsuz sınırsız satır
eklenebiliyor. **İlk yazımda "feedback_rate_limit desenini kopyala" deniyordu;
o tavsiye ÖLÇÜMDEN ÖNCEYDİ ve GERİ ALINDI.** Ölçünce üç şey çıktı:

**1. İddia edilen zarar büyük ölçüde YOK — tüketici zaten dayanıklı.**
Dokuz admin RPC'sinin sekizi `count(distinct ...)` kullanıyor.
`admin_source_funnel`ın "Ziyaretçi" adımı YALNIZCA
`count(distinct gv.anon_id)`; `game_starts`/`game_finishes` adımları ham `n`
ile `uniq`i YAN YANA döndürüyor (ham sayı meşru olarak ham: "toplam
başlangıç"). `admin_activation_stats` bu tabloların hiçbirine dokunmuyor.
Yani bir sel `uniq` sütunlarını oynatamaz.

**2. Bugün kötüye kullanım yok ve hacim küçük** (5 Eylül 2026):

| Tablo | Toplam | Farklı cihaz | Son 7 gün |
|---|---|---|---|
| `client_errors` | 40 | 27 | 12 |
| `device_visits` | 877 | 731 | 184 |
| `guest_visits` | 2.316 | 2.032 | 128 |
| `game_starts` | 931 | 181 | 346 |

**3. IP'ye anahtarlanan bir limitin İKİ yan etkisi, faydasından büyük:**
- **CGNAT.** Türk mobil operatörleri operatör düzeyinde NAT kullanıyor;
  gerçek kullanıcılar tek çıkış IP'sini paylaşıyor. Ziyaret/oyun başına
  yazan bir tabloda IP limiti gerçek satırları SESSİZCE düşürür (istemci
  hatayı yutuyor — ölçüldü, iki tarafta da fire-and-forget) ve huni EKSİK
  sayar. Bu, önlemeye çalıştığımız zararın aynı sınıfı, ters yönü.
- **`client_errors`'ta olayı gizler.** Tek cihazdan gelen hata seli tam da
  görmek istediğin şeydir; limit gerçek bir çökme olayında kanıtı kısar.
  Üstelik #10 ile istemci tarafında zaten hız sınırı var.

**Karar: bugün bir şey yapma.** Yeniden açılma tetikleyicisi: telemetri
tablolarından birinde `count(*)` ile `count(distinct anon_id)` arasında
açıklanamayan bir uçurum görülmesi, ya da satır sayısının maliyet yaratacak
mertebeye çıkması.

⚠ Limit ileride gerekirse **IP'ye DEĞİL `anon_id`'ye anahtarla** — CGNAT
komşularını vurmaz. Saldırgan `anon_id`yi de döndürebilir (yani naif seli
durdurur, kararlıyı durdurmaz), ama dürüst kullanıcıya maliyeti sıfırdır.

### 20. `CRON_SECRET` fail-open — **ÖLÇÜLDÜ: DÜŞÜK, kabul edilebilir**

**Durum (5 Eylül 2026): `CRON_SECRET` Dashboard'da TANIMLI DEĞİL** (kullanıcı
ekran görüntüsüyle doğruladı — Custom secrets'ta yalnızca `BREVO_API_KEY` ve
`FCM_SERVICE_ACCOUNT` var). Yani `if (CRON_SECRET && ...)` kapısı fiilen
açık ve **üç** fonksiyon (beş değil — ilk sayım yanlıştı) internetten
çağrılabiliyor: `notify-deadline-warnings`,
`notify-friend-request-reminders`, `sweep-unconfirmed-accounts`.

**Ama etkisi ölçüldü ve düşük** — üçünde de atomik "iddia" koruması var
(`.is(alan, null)` filtreli UPDATE), yani `notify-turn-timeout-surrender`
ile aynı desen:

| Fonksiyon | Dışarıdan tekrar çağrılırsa |
|---|---|
| `notify-deadline-warnings` | `deadline_warning_sent_at` → satır başına tek mail |
| `notify-friend-request-reminders` | `reminder_sent_at` → aynısı |
| `sweep-unconfirmed-accounts` | Yaş ölçütünü kendi uyguluyor → erken silme YOK |

Saldırgan zaten gönderilmeyecek tek bir mail bile göndertemiyor; kalan etki
yalnızca boşa çağrı maliyeti. **Bu yüzden acil değil.**

⚠ **Düzeltmenin bedeli faydasından büyük olabilir — üç parça aynı anda
değişmek zorunda.** Ölçüldü: `cron.job`taki üç komut da **hiçbir
`Authorization` başlığı göndermiyor** (`headers` yalnızca `Content-Type`).
Yani secret'ı tek başına tanımlamak üç özelliği birden 401'e düşürür ve
arıza SESSİZ olur (mailler durur, hata veren bir yüzey yok). Sıra şu
olmalı: secret + cron komutları + kodun fail-closed'a çevrilmesi, hepsi
tek turda.

**İki seçenek:**

- **(a) Vault ile, Dashboard adımı OLMADAN:** sır `supabase_vault`'ta
  (0.3.1 kurulu), cron komutu onu okuyup `Authorization` başlığına koyar,
  Edge Function beklenen değeri kendi `service_role` istemcisiyle DB'den
  okur. Depoda ve sohbette sır geçmez, tamamen ajandan doğrulanabilir.
  Bedeli: çağrı başına bir DB okuması (15 dk/saatlik/günlük iş için
  önemsiz) ve koddaki `Deno.env.get('CRON_SECRET')` deseninden sapma.
- **(b) Kabul et ve YAZ:** bugünkü fiili durum bu; ölçüm yukarıda. Bu
  seçilirse koddaki `if (CRON_SECRET && ...)` satırlarına "secret bilerek
  tanımlı değil, koruma iddia sütunlarından geliyor" notu düşülmeli —
  aksi halde bir sonraki okuyan onu çalışan bir kapı sanır.

⚠ **`inbound-email` bu maddeye DAHİL DEĞİL.** O fail-closed yazılmış
(`INBOUND_EMAIL_SECRET` yoksa 503) ve sırrının tanımsız olması BİLİNÇLİ:
Brevo Inbound webhook'u ücretli plana bloke, bkz.
`docs/decisions/support-email.md` → "GELEN ZİNCİRİ DURDURULDU". Boş
`support_inbox` (0 satır) beklenen durum, arıza değil.

### 21. Advisor gürültüsü + Auth ayarları — **KISMEN YAPILDI**

**✅ Trigger fonksiyonlarının REST erişimi KAPATILDI** (5 Eylül 2026,
migration `20260905055111_revoke_trigger_function_execute`, canlıya
uygulandı). Dört fonksiyon (`trg_award_league_rewards`,
`handle_friend_request_insert`, `keep_signup_utm_source`,
`_game_finishes_strip_anon_id`) `anon`+`authenticated`e açıktı; ötekiler
zaten yalnızca `service_role`'du, yani sekizin dördü kuruluştaki örtük
grant'i temizlemeyi atlamıştı. Sonra sondalandı: sekiz trigger
fonksiyonunun sekizinde de `anon`/`authenticated` kapalı, `service_role`
açık, her biri bir trigger'a bağlı. Advisor'ın dört uyarısı kapandı.

⚠ Sömürülebilir oldukları GÖSTERİLMEDİ (Postgres trigger fonksiyonunun
doğrudan çağrılmasını reddeder); bu derinlemesine savunmaydı. Trigger'ların
bozulmayacağı ise ölçüldü: aynı işlem `feedback_rate_limit_check` için
22 Temmuz 2026'da yapılmış ve o tarihten sonra `feedback`e 18 satır girmiş
— her biri o BEFORE INSERT trigger'ından geçerek. **EXECUTE izni
`create trigger` anında kontrol edilir, trigger ateşlenirken değil.**

**⬜ Kalan iki kalem — ikisi de Dashboard, kod işi değil:**

- **Authentication → OTP süresi uzun** ve **sızmış-parola koruması kapalı**
  (advisor WARN). İkisi de tek tık.
- **`pg_net` public şemada** (advisor WARN). ⚠ **YAPILMASI ÖNERİLMİYOR:**
  şema taşımak çalışan cron zincirine (`net.http_post` çağıran üç iş)
  dokunur ve kazancı bir uyarı satırını silmekten ibaret. Advisor'ın
  kırmızısını temizlemek için çalışan bir zinciri riske atma.

### 22. `feedback` hız sınırı XFF ile atlanabilir — **AÇIK, ölçülmedi**

#19'u incelerken çıktı ve ondan bağımsız: bu, CANLIDA çalışan bir kontrol.
`feedback_rate_limit_check` kimliği şöyle alıyor:

```sql
split_part(current_setting('request.headers')::json ->> 'x-forwarded-for', ',', 1)
```

Yani `X-Forwarded-For`un **en soldaki** değeri. Vekiller gerçek IP'yi zincirin
**sağına ekler**; en soldaki değer istemcinin kendi gönderdiğidir. Doğruysa
sonuç ters: saldırgan her istekte sahte bir ilk XFF yazıp limiti tamamen
atlar, kendi XFF'i olmayan gerçek kullanıcı ise gerçek IP'siyle sayılıp
limite takılır — yani kontrol yalnızca DÜRÜST trafiği kısıtlıyor olur.

⚠ **ÖLÇÜLMEDİ.** Bu ortam `supabase.co`ya POST atamıyor (ajan vekili
engelliyor), yani Supabase ağ geçidinin XFF'i nasıl birleştirdiği
doğrulanamadı. **İlk iş bunu ölçmek:** `inbound-email` ya da herhangi bir
uçtan `request.headers`ı bir yere yazdırıp, kendi XFF'ini gönderen bir
istekle göndermeyen bir isteğin ne ürettiğini karşılaştır. Ağ geçidi
istemcinin XFF'ini TAMAMEN yok sayıyorsa bulgu düşer.

Doğrulanırsa düzeltme: en soldaki değil **sağdan** sayılan (vekil sayısı
kadar içeriden) değeri al, ya da Supabase'in kendi güvenilir istemci-IP
başlığını kullan. `feedback` limiti dışında bu deseni kopyalayan başka yer
YOK (arandı) — yani düzeltme tek noktada.

## İncelemenin KAPANMIŞ geçişleri → arşivde

2. geçişin (**hata avı**), 3. geçişin (**performans**) ve 4. geçişin
(**temizlik**) tam anlatıları — bulgular, ölçümler, "zemin sağlam"
listeleri ve dersleri — `docs/decisions/roadmap-arsiv.md`'ye taşındı;
başlıklar ("Hata avı geçişi — KAPANDI", "Performans geçişi — KAPANDI",
"Temizlik geçişi — KAPANDI") değiştirilmedi. Yukarıdaki geçiş tablosu canlı
indeks olarak burada kaldı. **Dört geçiş de kapandı**; incelemeden açık
kalan tek şey güvenlik geçişinin yukarıda duran maddeleri (18-21).

## Modeller — hangi iş için hangisi

Ölçüt maliyet değil **hata bedeli** ve **ufuk uzunluğu**:

| Model | Ne zaman |
|---|---|
| **Fable 5** (`claude-fable-5`) | Geri dönüşü OLMAYAN ya da çok uzun ufuklu iş: veri silme kaskadı, çok platformlu yapılandırma zincirleri. En yetenekli model; pahalı, o yüzden yalnızca bu iki sınıf için. |
| **Opus 5** (`claude-opus-5`) | Varsayılan. Tasarım kararı gerektiren, çok dosyaya yayılan, ama geri alınabilir işler. |
| **Sonnet 5** (`claude-sonnet-5`) | Spesifikasyonu bu dosyada NET yazılmış, mekanik iş. Takılırsa Opus 5'e yükselt — inatla devam ettirme. |

**Efor:** uzun/agentic işlerde `high`–`xhigh`; mekanik işlerde `low`–`medium`.

---

## Bu projede bir oturumun gerçek maliyeti

19 Ağustos turunda ölçüldü — planlarken bunu hesaba kat:

- **`mobile/**` altına dokunan her PR** şu boru hattını tetikliyor: Analiz +
  testler (~3 dk) → Android APK (~5 dk) → iOS (~5 dk) → `main`'e merge
  sonrası Pages yayını. Tur başına **15-20 dk** ve birkaç mesaj.
- **Yalnızca web** (`src/**` vb.) → yalnız `web-ci.yml`, ~2 dk.
- **Yalnızca doküman** (`*.md`) → **hiç CI koşmaz.** Ücretsiz.
- **Taslak PR deseni işe yarıyor:** Flutter SDK bu ortamda YOK, yani Dart
  testleri yalnızca CI'da koşuyor. Emin olmadığın bir Dart değişikliğini
  önce `draft: true` PR ile CI'a sor, yeşilse merge et. 19 Ağustos'ta bu,
  iki bozuk testin `main`'e girmesini önledi.

---

## 0. FAZ B — Google Play yayını — **SIRA OMURGASI**

**Durum (22 Ağustos 2026):** Play Console hesabı açıldı ve kayıt işlemleri
bitti (*Personal account*, Account ID `5939732949280610022`), henüz **sıfır**
uygulama var. Aşağıdaki 1, 2 ve 4 numaralı maddeler bu fazın parçaları —
bu bölüm onların **hangi sırayla** yapılacağını söyler.

**TAKVİMİ BELİRLEYEN TEK ŞEY:** Kasım 2023'ten sonra açılan **kişisel**
hesaplarda Play, production'a başvurmadan önce kapalı testte **en az 12
tester'ın 14 gün boyunca kesintisiz kayıtlı** kalmasını istiyor. Yani
"her şey bitince yayınlarım" MÜMKÜN DEĞİL — ortada daha başlamamış 14
günlük bir sayaç var. Sol menüdeki **Android developer verification**
(kimlik doğrulama) da tamamlanmalı.

**Bu yüzden sıra "kolaydan zora" değil: ÖNCE SAYACI BAŞLAT.** Ağır işler
(hesap silme, deep link) o 14 gün içinde paralel yürür.

### 0.A — Sayacı başlatan minimum (bunlar olmadan dosya YÜKLENEMEZ)

**Model: Opus 5, efor `high`.** Tasarım kararı az, ama 0.A1'in kaybı
telafi edilemez (aşağı bkz.) — Sonnet'e verme.

Dördü de **ölçülmüş** eksikler, tahmin değil:

| | Eksik | Kanıt | Yapılacak |
|---|---|---|---|
| 0.A1 | ✅ **BİTTİ** (22 Ağu 2026) — release DEBUG anahtarıyla imzalanıyordu | `build.gradle.kts:31` → `signingConfigs.getByName("debug")` + `// TODO` | Upload keystore üretildi (RSA 4096, 2054'e kadar); `key.properties` varsa release, yoksa **bilerek** debug'a düşüyor |
| 0.A2 | ✅ **BİTTİ** (22 Ağu 2026) — CI yalnızca `.apk` üretiyordu | `mobile-build.yml:157` → `flutter build apk --release` | `android` işine `.aab` adımı eklendi; secret yoksa sessizce atlar, varsa paketin imzasını **geri okuyup** doğrular |
| 0.A3 | ✅ **BİTTİ** (22 Ağu 2026) — sürüm `0.1.0+1`di | `pubspec.yaml` + `env.dart` (`appVersion`) | İkisi de **`1.0.0`**; senkron artık `test/app_version_parity_test.dart` ile ZORLANIYOR. `versionCode`'u CI `--build-number=run_number` ile veriyor |
| 0.A4 | ✅ **BİTTİ** (23 Ağu 2026) | `marketing/play-store/` | İkon (512) + öne çıkan görsel (1024×500) + başlık/kısa/tam açıklama üretildi (`npm run generate-play-assets`). Telefon ekran görüntüleri **gerçek cihazdan alındı** (7 kare, 1080×2400) ve Play'in 2:1 oran tavanına sokmak için **1080×2072'ye kırpıldı**; dosyalar kullanıcıda. Kırpmanın neden zorunlu olduğu `marketing/play-store/metin.md` → "Teknik gereksinim" |
| 0.A5 | ✅ **BİTTİ** (23 Ağu 2026) — politika YALNIZCA SPA modalıydı | `?gizlilik=1` | `/gizlilik/` · `/kullanim-kosullari/` · `/hesap-silme/` derleme zamanı statik sayfa; metin tek kaynakta. Sonuncusu Data safety formunun istediği **web silme adresi** |

**0.A1 + 0.A2 + 0.A3 BİTTİ (22 Ağustos 2026).** GitHub secret'ları
(`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`) kullanıcı
tarafından girildi. Ayrıntı, ölçümler ve negatif eşler: `mobile/CLAUDE.md`
→ "Play Store İmzalama ve `.aab`".

**CI'DA DOĞRULANDI (23 Ağustos 2026, koşu 32644482976, sha `a22cea6`):**
`.aab` gerçekten üretildi (60.9 MB, artefakt `kelimeki-aab`) ve log'daki
`beklenen:` / `paket   :` parmak izleri hem birbirine hem üretilen upload
anahtarına eşit — yani secret'lar okundu, Gradle `key.properties`i gördü,
paket debug değil upload anahtarıyla imzalandı. `.apk` artefaktı da
yerinde (Appetize akışı bozulmadı).

**ÖLÇÜLDÜ (24 Ağustos 2026) — ikisi de temiz, aksiyon GEREKMİYOR.** Kaynağa
değil YAYINLANMIŞ pakete bakıldı: `mobile-latest`teki `kelimeki.apk`
(sha `18689eb`) indirilip derlenmiş `AndroidManifest.xml`i çözüldü.

| | Ölçülen | Sonuç |
|---|---|---|
| `minSdkVersion` | **24** (Android 7.0) | — |
| `targetSdkVersion` | **36** | Android'in en yeni API seviyesi; Play'in asgarisinin ALTINDA olması mümkün değil → **pinlemeye gerek yok** |
| İzinler | **3 adet** (aşağı) — Play'in `.aab`'de gösterdiği **4** (bkz. not) | Data safety beyanı etkilenmiyor |

İzinlerin tamamı: `INTERNET` (Parça 131 düzeltmesi — pakette olduğu böylece
ikinci bir yoldan da doğrulandı), `ACCESS_NETWORK_STATE` (connectivity_plus)
ve `com.kelimeki.kelimeki.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`
(AndroidX'in kendi ürettiği iç izin — kullanıcıya görünmez, beyan edilmez).

**DÜZELTME (25 Ağustos 2026):** yukarıdaki "3 izin" YAYINLANMIŞ `.apk`'dan
ölçülmüştü; Play Console'un paket ayrıntısı `.aab` için **4** gösteriyor.
Fark `com.android.vending.CHECK_LICENSE` — beyanı değiştirmiyor (çalışma
zamanı izni değil, veri toplamıyor). Ders: `.apk` ölçümü `.aab`'yi
kanıtlamıyor, Play bundle'ı işlerken manifeste ekleme yapabiliyor. Ayrıntı:
`marketing/play-store/console-formlari.md` § 6.

**`image_picker` HİÇBİR izin eklememiş** — bu dosyanın beklediği risk
gerçekleşmedi. Modern Android'de Photo Picker/SAF üzerinden çalıştığı için
depolama/medya izni istemiyor. Yani Data safety formunda medya erişimi
beyan edilmeyecek.

**0.A bölümünün TAMAMI bitti.** Sıradaki: ilk `.aab` yüklemesi → kapalı test
kanalı → 12 tester → 14 günlük sayaç başlar.

**Console'a girilecek her formun cevabı yazıldı (24 Ağustos 2026):**
`marketing/play-store/console-formlari.md` — adım sırası, Data safety veri
türü eşlemesi (her satırın kodda karşılığıyla), IARC anketi, App access test
hesabı, kapalı test kanalı ve tester metni. Vitrin METİNLERİ hâlâ
`metin.md`'de.

**ÖLÇÜLDÜ (24 Ağustos 2026) — `.aab` indirilebilir DEĞİLDİ, düzeltildi:**
0.A2 paketi yalnızca `actions/upload-artifact` ile bırakıyordu; artefakt
bağlantısı oturum istiyor ve dosyayı ZIP'liyor — yani iPad'den yükleyecek
kişi için `.apk`nın 7 Ağustos'ta çözülen probleminin aynısı hâlâ açıktı
(`build-and-distribution-log.md` → Appetize). `mobile-build.yml`'in release
adımı artık `kelimeki.aab`'yi de `mobile-latest`e koyuyor:
`https://github.com/alpcapa/kelimeki/releases/download/mobile-latest/kelimeki.aab`.
Artefakt DURUYOR. **DOĞRULANDI (25 Ağustos 2026, koşu 349, sha `5eddf3d`):**
dosya release'te, 60.929.323 bayt. Kanıt PR'da alınamazdı — release adımı
PR'da bilerek atlanıyor (workflow başlığındaki "YAYINLAMA" notu) — bu yüzden
merge sonrası ilk `main` koşusunda okundu.
**Play'e YÜKLENEN: 372** (26 Ağustos 2026 sabahı, kapalı test — Release name
`372 (1.0.0)`). Uygulama içi hesap silmeyi İÇEREN ilk paket bu.
Console'un paket ayrıntısından ölçüldü: `targetSdk` **36**, `minSdk` **24+**,
**4 izin**, ABI 3, ekran düzeni 4, gerekli özellik 2 — yani 349'un satırıyla
her sütunda aynı.

**Yüklenmeye hazır EN YENİ paket: 374** (koşu 374, sha `42a1f67`, `.aab`
26 Ağustos 05:42'de `mobile-latest`e yüklendi — 60.972.640 bayt). 372'den
tek farkı silme onayındaki uyarı cümlesinin kırmızı/kalın olması (#341) —
**kozmetik**, bu yüzden 372 için ayrı bir yükleme turu harcanmadı. Bir
sonraki mobil sürüm bu tabandan gider.

**370 neden atlandı:** aynı akşam Kullanım Koşulları §2'ye hesabı kendin
silme cümlesi eklendi (#338) ve hukuki metnin tarihi portu da zorunlu kıldı
(`legal_text_test.dart`) — yani 370 daha yüklenmeden bayatladı.
**Kalıcı ders: hukuki metne dokunmak her zaman bir paket turudur**, "tek
cümle" diye ucuz sayma. **İkinci ders — koşu numarası ardışık DEĞİL:** sayaç
PR koşularında da ilerliyor, 371'i #338'in kendi koşusu yedi. Bir sonraki
paketin numarasını önceden yazma, merge sonrası `main` koşusundan OKU.

**Tuzaklar — 0.A1:**
- **Keystore repoya GİRMEZ.** `*.jks`/`key.properties` gitignore'a; CI'a
  base64 GitHub secret olarak. Bu dosyayı **kullanıcı kendi tarafında da
  yedeklemeli** — Claude'un ürettiği bir dosyanın tek kopyası CI'da kalırsa
  iş kaybedilebilir.
- **Play App Signing'e kaydol.** Kaydolursan upload anahtarı kaybedilse
  bile sıfırlanabilir; kaydolmazsan anahtarın kaybı = uygulamanın bir daha
  asla güncellenememesi.
- **`assetlinks.json`'a hangi parmak izinin gireceği bu kararla değişiyor:**
  Play App Signing kullanılıyorsa oraya **Play'in ürettiği** SHA-256 girer,
  senin upload anahtarınınki DEĞİL. Yanlışını koymak App Links'i sessizce
  kırar (madde 1 ile aynı iş).
  **YAPILDI (25 Ağustos 2026):** dosya `public/.well-known/assetlinks.json`
  olarak yazıldı, içinde Play'in ürettiği parmak izi var (`2B:7D:26:11…`) —
  upload anahtarı (`B6:CD:FB:A9…`) DEĞİL. ⚠ Değer, App signing sayfasının
  anahtar TABLOSUNDAN değil, aynı sayfanın **"Digital Asset Links JSON"**
  panelinden okunur; ilk tur tablodan okunup yanlış parmak iziyle canlıya
  çıktı ve aynı gün düzeltildi. Ayrıntı ve ölçümler:
  `marketing/play-store/console-formlari.md` → §6.6.

**Tuzaklar — 0.A2/0.A3:**
- `targetSdk` hâlâ `flutter.targetSdkVersion`'dan geliyor
  (`build.gradle.kts:47`), yani pinli DEĞİL — ama ölçüldüğünde **36** çıktı
  (yukarı), o yüzden bugün pinlemeye gerek yok. Flutter kanalı geri giderse
  bu sessizce düşebilir; sürüm yükseltmelerinde yeniden ölç.
- `image_picker`'ın izin eklemediği **ölçüldü** (yukarı) — paket yalnızca 3
  izin taşıyor ve hiçbiri medya/depolama değil.
- **Paket adı `com.kelimeki.kelimeki` ilk yüklemeden sonra KALICI**
  (`mobile/CLAUDE.md`). Değişecekse bu adımdan ÖNCE.

**0.A5 NEDEN 0.B'DEN BURAYA TAŞINDI (23 Ağustos 2026, ölçüldü):** Play'in
kendi dokümanı, **Data safety formunun kapalı/açık test kanallarındaki
uygulamalar için de zorunlu** olduğunu ve **formu tamamlamak için gizlilik
politikası URL'inin gerektiğini** söylüyor. Yani politika sayfası "14 gün
işlerken paralelde" yapılacak bir iş DEĞİL — onsuz ilk kapalı test
yayınlanamaz, dolayısıyla sayaç hiç başlamaz. Bu dosya 22 Ağustos'ta onu
0.B'ye koymuştu; o sıralama YANLIŞTI.

**Çıkış kriteri:** imzalı AAB kapalı test kanalına yüklendi, 12 tester
kaydoldu, **sayaç işlemeye başladı.**

**DURUM (25 Ağustos 2026):** Console'daki her form dolduruldu, kapalı test
sürümü incelemeye gönderildi ve **YAYINLANDI** — Submission 1 durumu
`Published`. Adım adım ne girildiği ve neden:
`marketing/play-store/console-formlari.md` § 6.5.
26 Ağustos'ta uygulama içi hesap silmeyi içeren **372** yüklendi.

**Kriter HENÜZ karşılanmadı:** Dashboard **`0 testers currently opted-in`**
diyor — listede olmak opt-in sayılmıyor, kişinin linke tıklayıp testi kabul
etmesi gerekiyor ve bugüne kadar kimseye link gönderilmemişti.

**26 Ağustos 09:03'te opt-in linkleri Console'da BELİRDİ** (Join on Android
+ Join on the web), liste 11 kişiyken. Bir gün önce yoklardı; kapısının ne
olduğu ölçülmedi (bkz. `console-formlari.md` §6.5 — o tabloda yalnızca
GÖRÜLEN kaydedildi, sebep uydurulmadı).

**26 Ağustos (öğleden sonra) — liste 11 → 54 KİŞİ.** Kullanıcı bildirdi;
Console'dan okunan sayı. §7'nin "15-20 kişi topla, biri çıkarsa sayaç
kırılır" tavsiyesinin çok üstünde, yani yedek payı bol.

⚠ **Listede olmak ≠ opt-in — ve aradaki fark ÖLÇÜLDÜ (26 Ağustos 2026):**
liste **54 kişi**, gerçekten opt-in olan **10 kişi**. Yani davetlilerin
%80'i linke tıklamamış. Sayaç için kişilerin linke tıklayıp testi KABUL
etmesi gerekiyor; `testers currently opted-in` bunu sayıyor.

**Eşik 12 ise 2 kişi eksik.** Buradan çıkan iki pratik sonuç:
- Yapılacak iş yeni adres toplamak DEĞİL (54 zaten fazlasıyla yeter),
  mevcut davetlilere *"linke tıklayıp 'Testçi ol' demen gerekiyor"* diye
  hatırlatmak.
- **Geliştiricinin kendi cihazından uygulamayı kaldırması artık RİSKLİ:**
  10 sayısı eşiğin altındayken tek bir düşüş oransal olarak büyük. Native
  `.apk` ile performans testi yapılacaksa opt-in OLMAYAN bir cihaz
  kullanılmalı. (Kaldırmanın opt-in'i gerçekten düşürüp düşürmediği
  ÖLÇÜLMEDİ — Play davranışı çıkarımla yazılmıyor.)

⚠ **Ve bugün ölçülen asıl darboğaz opt-in değil:** davetliler uygulamayı
kurup açsalar bile **tanıtım ekranında takılıyorlardı** (kaydırmayı
anlamıyorlar, atlama da yok → çıkmaz). 3 günde yalnızca 2 kayıt olmasının
sebebi buydu. Düzeltildi (Parça 143, "DEVAM ›" düğmesi) ama **uygulamaya
ancak yeni bir paket yüklenince ulaşır** — 54 kişi bekliyorsa bu yükleme
sıradaki en öncelikli iş.

### 0.B — 14 gün işlerken paralelde

Sırası önemli olan tek bağ: **#4, #2'den SONRA** (hesap silme kaskadı
çıkmadan test hesaplarını silmek aynı analizi iki kez yaptırır).

1. ✅ **BİTTİ (25 Ağustos 2026) — Madde 2, uygulama içinden hesap silme.**
   Play'in hesap açtıran uygulamalardan istediği İKİ şeyin ikisi de yerinde:
   web silme talep URL'i (`/hesap-silme/`, 0.A5) **ve** uygulama içi yol
   (Hesap Ayarları › Hesabımı Sil, web + port). Kaskad service-role bir Edge
   Function'da (`delete-my-account`) + `delete_account_cascade` RPC'sinde;
   `dryRun` bayrağıyla hiçbir şey silmeden sayan bir kuru çalıştırma modu
   var ve onay penceresi bunu gösteriyor. Karar/ölçüm/tuzaklar:
   `docs/decisions/account-deletion.md`.
   ✅ **Console'da yapılacak iş de YOK** (2 Eylül 2026'da düzeltildi).
   Burada *"App content › Data deletion formunda artık 'uygulama içi silme
   yolu VAR' seçilmeli"* yazıyordu; **böyle bir form alanı YOK.** Silme
   sorusunun cevabı `Evet → kelimeki.com/hesap-silme/` ve öyle kalıyor —
   Play'in uygulama içi şartı bir form alanı değil, **uygulamanın
   kendisinde** aranan bir politika şartı ve 372'de karşılandı.
   `console-formlari.md` §3.8 bunu 26 Ağustos'ta *"ENGEL KALKTI, beyanda
   değişen bir şey YOK"* diye kapatmıştı; bu satır o güne kadar geriye
   dönük olarak bayat kaldı.
3. ✅ **Madde 1 — deep link: KAPANDI** (30 Ağustos 2026, Faz 3'te ölçüldü;
   SAHADA 1.0.3 ile). Madde arşivde: `docs/decisions/roadmap-arsiv.md` →
   *"1. `kelimeki://` deep link kanalı"*. **Numara bilerek duruyor** —
   arşivdeki madde buraya (`0.B/3`) atıf yapıyor.
   ⚠ Bu satır 2 Eylül 2026'ya kadar bayat kaldı: hâlâ *"kayıt onayı maili
   uygulamayı değil web'i açıyor"* ve *"intent filter, Supabase redirect
   allow-list, e-posta şablonları, Flutter yönlendirme duruyor"* diyordu.
   Dördü de bitmişti — kayıt onayı 28 Ağustos'ta https'e geçti, intent
   filtreleri Parça 87/158'de zaten yazılmıştı, yönlendirmeyi Faz 3 ekledi.
   Açık kalan TEK parça **iOS Associated Domains**, o da bu maddenin değil
   **#24 FAZ C**'in (24.4). 8 Eylül 2026'da bloke kalktı; dosyanın içeriği
   Apple **Team ID**'sine bağlı, o gelmeden yazılamaz.
4. **0.C — App content formları** (aşağı).
5. ~~Test hesaplarının silinmesi~~ — **madde KALDIRILDI** (26 Ağustos 2026,
   kullanıcı kararı: *"gerekirse daha sonra hesabımı silden ben yaparım,
   önemli bir konu değil"*). Kalan test hesapları duruyor; büyüme
   metriklerini bir miktar kirletmeleri kabul edildi. ⚠ **`T2` ve
   `Ironman` hiçbir koşulda silinmez** — gerekçeleri
   `docs/decisions/account-deletion.md` → "ASLA SİLİNMEYECEK İKİ HESAP".

### 0.C — Play Console'da doldurulacak formlar (kod işi değil, zorunlu)

**Cevapların TAMAMI `marketing/play-store/console-formlari.md`'de** (24
Ağustos 2026). Aşağısı yalnızca hangi formun neden riskli olduğunun özeti.

- **Data safety — en dikkatli iş.** Beyan ile gerçek ayrışırsa askıya alma
  sebebi. Toplananlar: e-posta, ad/soyad, takma isim, cinsiyet, doğum
  tarihi, profil fotoğrafı, **oyun içi mesajlar**, anonim cihaz kodu
  (`anon_id`), hata telemetrisi (`client_errors`), ziyaret/oyun başlangıç
  olayları. **Kaynak metin hazır:** `PrivacyModal`'ın "Toplanan Veriler"
  bölümü satır satır forma eşlenmeli. Üçüncü taraflar: Supabase, Brevo,
  Vercel (19 Ağustos'ta politikaya eklendi). **"Paylaşılıyor" her satırda
  HAYIR** — hizmet sağlayıcı ve kullanıcının başlattığı görünürlük
  istisnalarıyla; 24 Ağustos 2026'da kullanıcı onayladı, gerekçe
  `console-formlari.md` §3.8'de.
- **Content rating (IARC):** ✅ **BİTTİ (25 Ağustos 2026).** Sohbet beyan
  edildi. Bu satır "yaş derecesini yükseltir" diyordu — **ölçüm bunu
  doğrulamadı:** sonuç en düşük bant (PEGI 3, USK 0, ESRB Everyone,
  IARC 3+). Sebebi, sohbete yalnızca kabul edilen arkadaşın girebilmesi ve
  sessize alma/şikayetin var olması.
- **UGC / moderasyon:** sohbet olduğu için gerekiyor. Karşılayacak
  mekanizma ZATEN var — sessize alma, şikayet, hesap dondurma, admin
  paneli; yalnızca beyan edilecek.
- **App access:** Canlı oyun/arkadaş özellikleri giriş istiyor →
  incelemeciye **çalışan bir test hesabı** verilmeli (bkz. 0.B/5).
  **Hesap seçildi: `T2` (`kelimekitest2`), 24 Ağustos 2026.** `T1`
  kullanılmıyor — e-postası geliştiricinin kişisel adresi. T2'nin durumu
  üretim veritabanından ölçüldü: doğrulanmış, dondurulmamış, 3 arkadaş,
  1 aktif Canlı oyun, 11 bitmiş oyun — yani incelemecinin göreceği dört
  ekran da boş değil.
- **Ads:** yok · **Advertising ID:** kullanılmıyor · **Government /
  Financial / Health:** hayır.
- **Target audience:** **13+ öner** — 13 yaş altı hedeflenirse "Families"
  politikası devreye girer, çok daha ağır bir rejim.

### 0.D — Vitrin varlıkları

**23 Ağustos 2026'da üretildi** (`npm run generate-play-assets`,
`marketing/play-store/`) — bu bölüm artık yalnızca kalanı listeliyor:

- İkon **512×512** ✓ — cihazdaki başlatıcı ikonun KAYNAĞINDAN küçültüldü
- **Feature graphic 1024×500** ✓ — üretim bileşenlerinden render edildi
- Başlık (29/30) · kısa açıklama (79/80) · tam açıklama (1906/4000) ✓ —
  `marketing/play-store/metin.md`
- ✅ **Telefon ekran görüntüleri** — 7 kare, gerçek cihazdan, 1080×2072'ye
  kırpıldı (23 Ağu 2026, dosyalar kullanıcıda). Çekim listesi + gizlilik
  uyarıları + oran kuralı `metin.md`'de. Tablet desteği iddia edilecekse
  tablet görselleri ayrıca gerekir.
- ✅ Kategori **Games → Word** (25 Ağustos), iletişim e-postası
  `destek@kelimeki.com`, web sitesi `https://kelimeki.com` — üçü de
  Console'a girildi.
  ⚠ Bu satır 2 Eylül'e kadar ⬜ duruyordu ve BAYATTI; aynı üç madde
  yukarıdaki "Console (elle)" düzeltme tablosunda 31 Ağustos'ta zaten
  kapatılmıştı. Kaydın iki yerde durmasının bu dosyadaki dördüncü örneği.

**Görseller elle çizilmez:** reklam kareleri (`scripts/sponsored-post/`) ve
reel (`scripts/reel/`) zaten ÜRETİM bileşenlerini sunucuda render eden bir
desen kurdu — mağaza görselleri de aynı yoldan üretilmeli, yoksa vitrin ile
ürün sessizce ayrışır. **Tuzak:** o betiklerde Tailwind sınıfı çalışmaz
(`content` yalnızca `index.html` + `src/**` tarar), yalnızca inline `style`.


## 5. k-lig puan grafiği — **İSTEĞE BAĞLI**

**Model: Sonnet 5, efor `medium`.** Spesifikasyon kök `CLAUDE.md`'de eksiksiz
yazılı (seri nasıl kurulur, hangi oyunlar atlanır, hangi etiketler). Takılırsa
Opus 5'e yükselt.

**Ertelemenin maliyeti SIFIR** — `games.created_at` durduğu sürece seri her
zaman geriye dönük kurulabilir. Bugün 15 kullanıcının yalnızca 4'ünde dolu
bir grafik çıkıyor ve `league_rewards`'ta toplam 6 satır var, yani etiketler
neredeyse boş. Ironman 100 puanı geçtiğinde anlam kazanmaya başlar.

**Değişmez:** son nokta `player_stats_overall.total_score` ile BİREBİR
eşleşmeli (14 Ağustos'ta canlıda 15/15 kullanıcıda doğrulandı). Web + port
AYNI PR'da.

---

## 9. Admin Üyeler tablosuna "onaylanmamış" filtresi — **İSTEĞE BAĞLI**

**Model: Sonnet 5, efor `medium`.** Salt-okunur bir liste filtresi.

Kullanıcı 23 Ağustos 2026'da onayladı ("Filtre kalsın") ama o günkü "hemen
canlıya alalım" kapsamının DIŞINDA bırakıldı — asıl sorun (onaylanmamış
hesabın takma adı süresiz kilitlemesi) artık saatlik süpürmeyle çözülü
(bkz. kök `CLAUDE.md` → "Onaylanmamış hesap süpürmesi"), yani bu filtre bir
arıza değil bir görünürlük kolaylığı.

**Ne:** Üyeler tablosunda "yalnızca onaylanmamışları göster" seçeneği. Bugün
`admin_list_members` bu alanı HİÇ döndürmüyor — `auth.users.email_confirmed_at`
istemciye kapalı, yani RPC'ye bir kolon eklemek gerekiyor (dönüş tipi
değişince `create or replace` YETMEZ, drop+create + grant'leri elle geri kur;
kayıtlı tuzak: `fix_withdraw_report_wrong_overload`).

**Kapsam kararı:** yeni kolon Üyeler tablosunda gösterilecekse CSV'ye de
eklenmeli — "CSV ekranda görüneni indirir" sözü ancak öyle doğru kalır.
Sıralama anahtarı EKLEME (mevcut yedi anahtar korunuyor, gerekçesi
`CLAUDE.md` → "Kayıt alanlarının tamamı tabloda").

---

## 14. Uzun modal listeleri tembel inşa edilsin — **İZLEME, eşiğe bağlı**

27 Ağustos 2026, kullanıcı sordu: *"Arkadaşlar ara&ekle lazy yükleniyor
değil mi?"* İki ayrı "lazy" var ve cevap ikisinde farklı:

- **Veri yüklemesi: EVET, lazy.** 20'şerlik sayfalar
  (`kAllUsersPageSize` → `list_users_for_friend(offset, limit)`), gövdenin
  sonuna 80 px kala sonraki sayfa isteniyor; liste kaydırılamayacak kadar
  kısaysa `_autoLoadIfNotScrollable` elle tetikliyor. Bu değişmedi.
- **Widget inşası: HAYIR, artık değil.** Aynı gün kaydırma hatası
  düzeltilirken (Parça 146) iç içe `ListView` kaldırıldı ve yerine düz bir
  `Column` kondu — yani yüklenmiş TÜM satırlar inşa ediliyor. Tembelliğin
  kaybı o kararın bilinçli ama İKİNCİL bir bedeliydi; amaç iç içe
  kaydırılabiliri kaldırmaktı (Flutter zincirlemiyor, listenin alt 128 px'i
  erişilemiyordu).

**Bugün bedeli YOK ve sayı bu:** canlıda 47 profil var, yani en fazla ~46
satır. Ayrıca aynı modaldeki öteki iki sekme ("Arkadaşlarım", "İstekler")
BAŞTAN BERİ düz `Column`, ve web de tüm satırları DOM'a basıyor
(sanallaştırma yok) — yani parite de bozulmadı.

**Karar tetikleyicisi:** üye sayısı ~300'ü geçtiğinde, ya da liste gözle
görülür yavaşladığında. Muhtemelen ondan ÖNCE bir tasarım sorunu gelir
("kullanıcı 15 sayfa kaydırıyor") — o zaman doğru cevap sanallaştırma değil
arama/filtre olabilir; ikisini birlikte değerlendir.

⚠ **Çözüm iç içe `ListView`'a DÖNMEK DEĞİL** — düzeltilen hata aynen geri
gelir (bkz. `mobile/CLAUDE.md` → "`KModal`'ın gövdesi ZATEN
kaydırılabilir"). Doğru yol `KModal`'ın gövdesini `SingleChildScrollView`
yerine `CustomScrollView` + `SliverList` yapmak: kaydırılabilir yine TEK
kalır (zincirleme sorunu doğmaz) ama satırlar tembel inşa edilir.
`KModal`'a `bodyController`'ın yanına bir `slivers` yolu eklenir.

**Etki alanı geniş:** `KModal`'ı 15 modal kullanıyor, yani bu değişiklik
hepsine dokunur — küçük bir iş değil, kendi test turunu ister. Aynı
gerekçeyle 27 Ağustos'ta Sürüm A'ya alınmadı.

---

## Her iş için değişmeyen kurallar

1. **Önce etki analizi** (kök `CLAUDE.md` → "Çalışma İlkesi"): bu kodun
   ikinci okuyucusu/yazarı var mı? bir zincirin halkası mı? derleyicinin
   göremeyeceği hangi değişmeze dokunuyorum?
2. **Bitince `git status` oku** ve dokunduğun her alanın eşini güncelle —
   `CLAUDE.md`/`README.md`/`TESTING.md`/`mobile/*`.
3. **Migration varsa** MCP ile canlıya uygula, `list_migrations` ile dosya
   adını gerçek versiyonla eşleştir, ve **fonksiyonu GERÇEKTEN çağır** —
   "uygulandı" yetmez (bu projede geçerli SQL iki kez ilk çağrıda patladı).
4. **Ölçmeden "ölçüldü" yazma.** Flutter SDK bu ortamda yok; Dart tarafında
   bir sayıyı ancak CI ya da cihaz kanıtlar.
5. **Geometri ölçen bir teste `setUpAll(loadAppFonts)` şart** — yoksa
   Ahem'in düzenini ölçersin, ürünün değil (19 Ağustos'ta iki testi birden
   düşürdü).
6. **Düzen testinin boyu** ürünün göründüğü EN DAR/EN KISA yüzeyi temsil
   etmeli — etmiyorsa yeşil olması hiçbir şey garanti etmez.

---

## 17. Google ile giriş/kayıt — **ERTELENDİ** (2 Eylül 2026) · Play Store'a girdikten SONRA

Kullanıcı sordu: *"Google ve Apple signup/signin özelliği eklemek zor mu?
Belki şimdilik sadece Google ile başlanabilir"* ve *"test sürecinde yapmak
mantıklı mı?"*. Cevap: Google tek başına makul, **ama sıraya girdi.**

### Neden ertelendi — kullanıcı kararı, 2 Eylül 2026

> *"Google signin olayını erteledik çünkü bu dönemde bu işi yapmanın
> acelesi yok. Çalışan düzene çomak sokmak olur boşuna. O nedenle önce
> Play Store'a girelim, sonra yaparız dedik. O kadar."*

Gerekçe bu: **öncelik sıralaması.** Yeni bir giriş yolu bugün hiçbir şeyi
açmıyor — kimse "Google ile giremiyorum" diye şikayet etmedi — ve çalışan
bir kimlik akışına dokunmanın karşılığı yok. Play Store'a girildikten
sonra yapılır.

⚠ **BU MADDE SAYAÇLA İLİŞKİLİ DEĞİL — 2 Eylül 2026'da AYRILDI.** Burada
*"kapalı test sayacı bitmeden BAŞLAMA"* diye dört maddelik bir risk
analizi vardı: özü, bozuk bir girişin tester'ı kaybettirip 12/14 sayacını
sıfırlayabileceğiydi. Kullanıcı sordu (*"17 Google sign-in işi değil mi?
Test süreciyle ne alakası var?"*) ve zincir açılınca ÜÇ yerden koptu:

- **Uygulamayı silmek testerlıktan çıkmak değil** — deponun kendi tester
  mesajı bunu söylüyor (*"uygulamayı silsen bile testerlıktan çıkma"*) ve
  kaldırmanın opt-in'i düşürüp düşürmediği zaten ÖLÇÜLMEMİŞ.
- **Mevcut tester'lar çoktan kayıtlı.** Google girişi EK bir yol; e-posta/
  şifreyle girenler yeni bir butondan etkilenmez. "Giriş yapamıyorum"
  asıl olarak YENİ kayıt olanı vurur.
- **Sayacın "tam 12" olduğu da artık kesin değil** (yukarıdaki açık soru).

**Ders:** bir erteleme kararının gerekçesi, kararın KENDİSİNDEN daha
karmaşık yazılmışsa muhtemelen sonradan uydurulmuştur. Gerçek sebep bir
öncelik tercihiydi; yerine bir risk zinciri yazılınca hem yanlış hem de
sahte bir takvim bağı ("~10 Eylül") doğdu.

### İşin KENDİ riski — takvimden bağımsız, ne zaman yapılırsa yapılsın

Yukarıdaki zincir düştü ama şu ikisi düşmedi; ikisi de "ne zaman"la değil
"nasıl"la ilgili:

1. **`handle_new_user` web ile portun ORTAK trigger'ı.** "Yalnızca web'de
   yaparım" diye bir kaçış YOK — hatalı bir migration mobil tarafta da yeni
   kayıt açılmasını bozar. Migration adımı (aşağıda "0.") bu yüzden BLOKER.
2. **Hesap birleştirme ölçülmedi** — aynı e-postayla önce şifreyle kayıt
   olup sonra Google ile girmek. Bu, MEVCUT bir kullanıcıyı da vurabilir
   (bkz. aşağıda "Ölçülmesi gereken, varsayılmayacak iki şey").

### Sıra: sunucu → web → mobil

Web'de oturmuş bir profil-tamamlama akışını porta taşımak, tersinden yapmaktan
belirgin biçimde ucuz.

**0. Migration — BLOKER, ilk iş.** Bugün Google girişi açılsa ilk denemede
patlar (ölçülmedi ama kaynak kesin): OAuth'ta `sharedxp_pending_profile`
metadata'sı HİÇ gelmez → `handle_new_user` ad/soyadı `coalesce(..., '')` ile
boşa düşürür → `profiles_first_name_not_blank` (`20260717164244`) ihlal edilir
→ trigger patlar, `auth.users` insert'i geri alınır, kullanıcı *"Database error
saving new user"* görür. Yapılacaklar:
- Ad/soyadı Google'ın `raw_user_meta_data`'sından türet (`full_name` /
  `given_name` / `family_name`), yoksa kısıtı sağlayan geçici bir değer.
- `display_name` **not null + `profiles_display_name_tr_lower_key` (Türkçe
  duyarsız UNIQUE)** — `split_part(email,'@',1)` fallback'i iki Gmail
  kullanıcısında çakışır; benzersiz geçici bir ad üret.
- **"Profili tamamla" bayrağı** (yeni kolon); `agreed_to_terms` OAuth'ta false
  doğar, modalda yazılır. `signup_channel`/`signup_utm_source` damgalanmaya
  devam etmeli.
- ⚠ **Aynı migration'da `sharedxp_pending_profile` borcunu da kapat** — trigger
  İKİ anahtarı birden okusun (`docs/decisions/product-backlog.md` → "Miras
  isimler"). Bu iş zaten trigger'a dokunuyor; ayrı PR bedeli ikiye katlar.
- Proje kuralı: uygula → `execute_sql` ile DOĞRULA → `list_migrations` ile
  dosya adını eşleştir.

**1. Konsol (kod değil, panelden).**
- Google Cloud: OAuth consent screen — yalnızca `email` + `profile` kapsamı
  (Google doğrulaması gerekmez); gizlilik + kullanım koşulları URL'leri zaten
  yayında (`/gizlilik/`, `/kullanim-kosullari/`).
- Web client ID + secret → Supabase → Authentication → Providers → Google.
- Supabase → URL Configuration → Redirect URLs (`kelimeki.com`, preview
  adresleri, `harfik.vercel.app` durduğu sürece o da — bkz. backlog'daki
  Vercel rename planı, ikisi çakışıyor).
- Android: **upload anahtarının VE Play App Signing anahtarının SHA-1'i**
  Firebase'e girilecek (Firebase Android OAuth istemcisini kendisi üretir).
  SHA-256 zaten `assetlinks.json` için çıkarılmıştı — `console-formlari.md` §6.6,
  aynı sayfa.

**2. Web (`src/`).** `signInWithGoogle()` (`api.ts`) · `AuthModal`'a buton ·
işin AĞIRLIĞI olan **profil tamamlama modalı** (takma isim — mevcut
`useNicknameAvailability`/`check_nickname_available` yeniden kullanılır —,
ad/soyad, şartlar, isteğe bağlı pazarlama izni) · OAuth-only hesapta şifre
yollarının gizlenmesi (`ResetPasswordModal`, `AccountSettingsModal`) ·
`useAuth`'un "profil eksik" durumunu yayması.

**3. Mobil (`mobile/app`).** `google_sign_in` + `signInWithIdToken` (web'in
redirect akışı DEĞİL, native akış; `supabase_flutter ^2.10.2` destekliyor) ·
aynı modalın portu · sürüm artışı (`pubspec.yaml` + `env.dart`, ikisi birlikte) ·
yeni `.aab` + Play incelemesi.

**4. Beyan ve doküman.** `TermsModal`/`PrivacyModal` + statik `/gizlilik/`
(Google'a giden veri) · Play **Data safety** formunun yeniden okunması ·
`TESTING.md` + `mobile/TESTING.md` — **gerçek bir Google hesabı gerektirdiği
için otomatik test EDİLEMEZ**, elle koşulan listeye girer · `CLAUDE.md`/`README`.

### Ölçülmesi gereken, varsayılmayacak iki şey

- **Hesap birleştirme:** aynı e-postayla önce şifreyle kayıt olup sonra Google
  ile girmek. Supabase'in kimlik birleştirme davranışı ayara bağlı; iki hesap
  mı bir hesap mı olduğu kullanıcının puanını ve k-lig geçmişini etkiler.
- **Hoş geldiniz e-postası:** `on_auth_user_welcome` `after insert or update of
  email_confirmed_at` — OAuth kullanıcısı DOĞRULANMIŞ doğduğundan bugüne kadar
  "ulaşılamaz" sayılan INSERT dalı devreye girer. Beklenen davranış doğru (mail
  gider), ama migration'ın yorumundaki "bugün ulaşılamaz" cümlesi o PR'da
  güncellenmeli.

### Apple neden bu maddede YOK

Apple Developer üyeliği alınmadı ve iOS yayında değil. Ayrıca **App Store 4.8:**
iOS uygulaması üçüncü taraf girişi (Google) sunuyorsa eşdeğer bir gizlilik
odaklı seçenek de sunmak zorunda — yani **iOS'a Google girişi koyulan gün Apple
girişi de zorunlu olur**; ikisi orada birlikte gider. Web ve Android'de böyle bir
kural YOK. Günü gelince iki tuzak: kullanıcı e-postasını gizleyebilir
(`@privaterelay.appleid.com`) ve **ad/soyad yalnızca ilk yetkilendirmede bir kez**
döner — o an kaydedilmezse bir daha alınamaz.


---

## 23. Seviyeli YZ (Kolay / Normal / Zor) + seviyeye göre k-lig puanı — **Faz 0-5 kod ✅ · Faz 5 SAHA ÖLÇÜMÜ sırada** (7 Eylül 2026)

Kaynak: `docs/decisions/product-backlog.md` → "YZ zorluk seviyesi" (5 Eylül
2026; kadran ölçümü, kapsam ve KESİN puan tablosu orada — burada
TEKRARLANMIYOR, yalnızca plana giren kısımları özetleniyor). Kullanıcı isteği
(6 Eylül): *"Analizini yapıp fazlı planı çıkart."* Bu bölüm o analiz. **Kod
yazılmadı.** Aşağıdaki her satır kaynak okunarak çıkarıldı (dosya:satır
verilen yerler ölçüm, "tahmin" yazanlar tahmin).

### 23.0 Neyin sabit olduğu (backlog'dan, değişmez)

| Oyun | 1. sıra | 2. sıra | Teslim |
|---|---|---|---|
| Canlı 4 kişilik (YZ'li) — seviye YOK, Normal sayılır | +2 | +1 | -2 |
| Yerel 2 kişilik — Kolay / Normal / Zor | 1 / **2** / 4 | yok | -2 |
| Yerel 4 kişilik — Kolay / Normal / Zor | 1 / **2** / 4 | 0 / **1** / 2 | -2 |

- **Normal = bugünkü değer, her hücrede.** Seviyesiz kayıt (bugüne kadarki
  her şey + tüm Canlı oyunlar) `null` → Normal dalı; **veri taşıma YOK.**
- Teslim her seviyede -2 (backlog: "varsayılan böyle kalsın; ölçeklenmesi
  istenirse ayrıca sorulur").
- Seviye seçimi yalnızca yerel YZ oyununda (2 ve 4 kişilik), 4 kişilikte
  ÜÇ YZ'ye birden uygulanır. Canlı'ya dokunulmaz.
- **HEDEF ORANLAR (6 Eylül 2026, kullanıcı kararı — 23.2'yi kapattı):**
  *"Normal bugünkü gibi kalacak. Kolay daha kolay olacak (%30 gibi), zor
  daha zor olacak (%70 gibi)."* Sayılar **YZ'nin insana karşı kazanma
  oranı** olarak okundu — Normal bugün ~%51 (insan %48,7), yani ölçek
  tutarlı:

  | Seviye | Motor | YZ kazanma hedefi (insana karşı) | Nasıl ölçülür |
  |---|---|---|---|
  | Kolay | bugünkü motor, en iyi N'den rastgele — **N=4** (Faz 0 ölçtü, kullanıcı onayladı, 6 Eylül) | **~%30** | `admin_ai_balance` seviye kırılımı (Faz 1'de geliyor) |
  | Normal | bugünkü motor, N=1 — DEĞİŞMEZ | ~%51 (bugünkü, 429 oyun) | aynı — sıfır çizgisi |
  | Zor | YENİ, daha güçlü motor (Faz 5) | **~%70** | aynı |

  Hedef bir SAHA ölçümü; YZ↔YZ koşumu yalnızca ön eleme (aşağı, Faz 0).
- **Bu planın eklediği kural:** seviye oyun BAŞINDA kilitlenir, oyun içinde
  değiştirilemez (aksi hâlde Kolay'da başlayıp son hamlede Zor'a geçmek +4
  eder — puan oyunu). `GameState`'e bir kez yazılır, değiştiren action YOK.

### 23.1-23.4 ve 23.6 → **ARŞİVDE** (8 Eylül 2026)

Etki haritası, karar noktası (B), Faz 0-5 özetleri, tuzaklar ve Faz 5
başlangıç kiti `docs/decisions/roadmap-arsiv.md` → *"23 · Plan gövdesi"*ne
taşındı. Hepsi kapandı: karar verildi, kod yazıldı, canlıya çıktı.
Tasarım kaydı: `docs/decisions/ai-levels.md`.

**ROADMAP'te kalan TEK açık iş aşağıda.**

### AÇIK İŞ — Faz 5 SAHA ölçümü

**Kod bitti, ölçüm bitmedi.** Zor motoru 7 Eylül 2026'da canlıya çıktı
(web) ve 1.0.8 ile porta girdi; YZ↔YZ ön elemesi Zor'un Normal'i %70/%72
yendiğini gösterdi. Ama ön eleme SAHA değil.

**Ölçülecek:** `admin_ai_balance` seviye kırılımı, **iki hafta**.

| Seviye | Beklenen YZ kazanma oranı |
|---|---|
| Kolay | ~%30 |
| Normal | ~%51 |
| Zor | ~%70 |

**Sapma çıkarsa kadran ayarlanır, motor yeniden yazılmaz** — `AI_LEVEL_TOP_N`
(Kolay'ın N'i) ve `AI_LEVEL_SEARCH` bu iş için var. Üç kopya birlikte
değişir (web · Dart · Edge) ve `verify-edge-engine-parity` ayrışmayı yakalar.

### 23.5 Kapanış ölçütü

| Faz | "Bitti" kanıtı |
|---|---|
| 0 | ✅ `simulate-ai-levels` repoda, 200 oyunluk koşum tablosu backlog notunda, Kolay **N=4** seçildi (6 Eylül 2026) |
| 1 | ✅ migration canlıda (`20260906114252`), altı view/tablo karması öncesi/sonrası bayt-eş (953 oyun), `verify-league-points` CI'da yeşil (6 Eylül 2026) |
| 2 | ✅ golden'lar yeni motorla yeniden üretildi → **git diff boş** (N=1 bayt-eş); `reducer_ai2_kolay` + `ai_level.json` Dart'ta yeşil (6871 kontrol); `verify-edge-engine-parity` `AI_LEVEL_TOP_N` kilidi + tohumlu Kolay adımıyla yeşil (32 pozisyon, 24'ünde Normal'den sapıyor); `play-ai-turn` deploy edildi, `verify_jwt=true` korundu (6 Eylül 2026) |
| 3 | ✅ kod (6 Eylül 2026): Zorluk seçici + 4 kartta seviyeli puan/rozet, `list_liked_games` canlıda, `verify-league-points` 3 seviye yeşil, golden sıfır fark, smoke Kolay/Normal testleri. **Yayın kanıtı merge sonrası:** `curl kelimeki.com \| grep kelimeki-build` = `main` başı; Kolay'da biten oyunun kartı +1 gösteriyor ve `k_lig_siralama` aynı sayıyı veriyor |
| 4 | ✅ kod (6 Eylül 2026): ZORLUK seçici + üç kartta seviyeli puan/rozet + devam eden kartı rozeti, `ai_level` kayıt/liste/Favoriler, `ai_level_parity_test` (web etiket/liste/açıklama/yardım paragrafı ↔ port), `flutter analyze` temiz. **Cihaz kanıtı sürüm turunda:** portta Kolay seçilip bitirilen oyun web'de aynı puanla görünüyor ve tersi (aynı hesap, iki cihaz) — `mobile/TESTING.md` §13 |
| 5 | ✅ kod (7 Eylül 2026, PR #475): Zor = geniş arama, YZ↔YZ Normal'e karşı **%70** (tohum 1, GA %63-75) ve **%72** (tohum 1000, GA %66-78); Normal golden'ları git diff boş; `reducer_ai2_zor` + `ai_level.json` Dart'ta yeşil (6883 kontrol); `verify-edge-engine-parity` `AI_LEVEL_SEARCH` kilidi + Zor adımıyla yeşil; `play-ai-turn` yeniden deploy edildi (`verify_jwt=true` korundu); seçici web+portta açık, `ai_level_parity_test` + smoke Zor testi yeşil; web canlıda `dd55ae0`. **KALAN:** sahada iki hafta — Kolay ~%30 / Zor ~%70 YZ kazanma bandında |


## 24. FAZ C — App Store yayını — **YÜRÜYOR** (8 Eylül 2026)

**Bu bölüm bir İNDEKS. Kaynak: `marketing/app-store/console-formlari.md`** —
Console cevapları, kararlar, ölçümler ve tuzaklar orada; burada yalnızca
hangi fazın nerede olduğu duruyor. (Play tarafında bunun tersi bir kez
yaşandı ve özet tablo altı gün bayat kaldı.)

| Faz | Durum |
|---|---|
| **24.1** Hesap & kimlik | ✅ üyelik aktif · Team ID `8277D85FY9` · App ID + capability'ler · APNs anahtarı `RL4JLXL389` · uygulama kaydı · Free Apps Agreement · **DSA trader: beyan ✅, doğrulama `In Review`** (9 Eyl) · ✅ **API anahtarı `.p8` ALINDI** (9 Eyl akşamı, bir Mac'ten — §3) |
| **24.2** Mac'siz imzalama + TestFlight | ✅ **UÇTAN UCA DOĞRULANDI** (9 Eyl, koşu #614): zincir baştan sona koştu ve paket App Store Connect → TestFlight'ta **"Ready to Submit"** olarak GÖRÜLDÜ. Altı koşu, sekiz ayrı arıza; teşhis zinciri `console-formlari.md` §3'te. ⚠ Dokuzuncu arıza yeşil koşudan SONRA bulundu: paket **1.0.9 (1)** olarak yüklendi, 614 olarak değil — araya giren bayraksız `flutter build ios` `Generated.xcconfig`i eziyordu. Düzeltildi (bayrak + fastlane öncesi doğrulama) ve **koşu #616 ile kanıtlandı: TestFlight'ta `1.0.9 (616)` · Complete**; post-mortem `console-formlari.md` §3 |
| **24.3** APNs / push | ✅ Firebase (prod+dev) · `GoogleService-Info.plist` · `Runner.entitlements` · `AppDelegate` bildirim kanalı. ⚠ `aps-environment` değeri CI'da doğrulanamaz — **kapı: TestFlight iç test grubu** (aşağı, madde 0) |
| **24.4** Universal Links | ✅ web yarısı **CANLIDA ölçüldü** (`200` + `application/json`) · ✅ iOS yarısı yazıldı · ⚠ doğrulama TestFlight ister — **kapı: iç test grubu** (aşağı, madde 0) |
| **24.5** Mağaza vitrini | ✅ cevap kâğıdı · metinler (ölçülü) · App Privacy eşlemesi · yaş derecesi · demo hesap `T2` · ✅ **ekran görüntüsü boru hattı ÇALIŞIYOR** — 9 Eyl, run #1 ile CI'da DOĞRULANDI: iPhone 6.9" karesi **tam 1320×2868**, artefakt 1,6 MB. iPad yarısı da run #2'de DOĞRULANDI (`2064×2752`) · ✅ **6/6 kare, iki cihazda da CI'da DOĞRULANDI** (9 Eyl, run #4: on iki PNG'nin on ikisi tam ölçüde) · ✅ **KOMPOZİSYON KARARI VERİLDİ** (11 Eyl, kullanıcı): kareler **başlıklı** + **7. kare** (k-lig) eklendi — şerit `MaterialApp.builder` ile Flutter ağacının içinde, son işlem YOK, piksel ölçüsü değişmiyor; eksik kare artık koşuyu düşürüyor (`KARE_SAYISI`). ⚠ **Aynı turda bir yükleme blokeri bulundu ve kapatıldı:** kareler ALFA kanalı taşıyordu (ölçüldü: 7/7 `hasAlpha: yes`) ve ASC saydamlık kabul etmiyor — arıza ancak Console'da görünecekti; düzeltme `test_driver/png_flatten.dart`, kapı hem Linux birim testi hem iş akışı. ⚠ Kalan: bir sonraki `ios-screenshots.yml` koşusunun artefaktını indirip **Console'a elle yüklemek** |
| **24.6** Gönderim | ⬜ DSA doğrulaması ✅ bitti (10 Eyl), paket ✅ (24.2), kareler ✅ (24.5, 11 Eyl). ⚠ **Console'da iki adım BEKLİYOR (11 Eyl, ekran görüntüsüyle ölçüldü):** sürüm kaydı hâlâ `1.0` ama yüklenen paketler `1.0.9`/bundan sonrası `1.1.0` — kısa sürüm dizesi `1.0` olan derleme YOK, yani sürüme derleme İLİŞTİRİLEMİYOR. Sürüm numarası `1.1.0` yapılıp derleme iliştirilmeli; Apps listesindeki jenerik ızgara ikonu da bunun belirtisi (ikili sağlam: 1024×1024, alfasız, `ios-marketing` girdisi ve `ASSETCATALOG_COMPILER_APPICON_NAME` depodan doğrulandı) |

⏳ **TRADER: beyan ✅, doğrulama SÜRÜYOR (9 Eylül 2026).** Console'un
Compliance tablosu `Digital Services Act · 27 ülke · In Review` diyor —
yani gönderim kapısı HÂLÂ AÇIK. ⚠ Bu satır bir kez *"kapandı"* diye
yazıldı ve aynı gün düzeltildi: sözlü bildirim değil, **Console'un kendi
STATUS alanı** kanıttır (gerekçe `console-formlari.md` §2).

**Sırayı tıkayan şeyler (10 Eylül 2026 GECE tazelendi — ÜÇ maddenin ÜÇÜ de
düştü; bu listede artık tıkayan bir şey YOK):**
0. ✅ **TestFlight iç test grubu KURULDU ve uygulama iPad'de ÇALIŞTI**
   (10 Eylül 2026 akşamı). `İç Test` grubu · 2 testçi · dağıtılan derleme
   **`1.0.9 (620)`**; cihazda Setup teşhis satırı `Derleme 46664f6`
   gösterdi. Cihaz turu koşuldu ve **temiz geçti** (manzara/düzen/taşma
   yok); tek bulgu hiç oynanmamış YZ oyununun bulut kaydıydı → düzeltildi
   (aşağıdaki sürüm tablosuna bak). Böylece 24.3 (`aps-environment`), 24.4
   (Universal Links iOS yarısı) ve `mobile/TESTING.md` §26 artık
   koşulabilir durumda. ⚠ *"Ready to Submit"* bir engel DEĞİLDİ: o durum
   DIŞ dağıtımı anlatır, iç testçi için Beta App Review yok — ölçüldü.
   Kurulumun tuzakları (ekip daveti ≠ testçi daveti, "Redeem" ekranı bir
   kod istemiyor, tester statüsü teşhis aracı değil):
   `console-formlari.md` §14.
1. ✅ **API anahtarı ALINDI (9 Eylül 2026 akşamı)** — bir **Mac'ten**, ilk
   denemede. iPadOS'ta (özel sekme dahil) defalarca başarısız olmuştu;
   ölçüm arızanın istemci/platform tarafında olduğunu gösteriyor, Apple'ın
   sunucusunda değil. Support hiç yanıt vermeden çözüldü. ✅ **Ardından
   secret'lar girildi ve 24.2 uçtan uca doğrulandı** (#614 zinciri
   bitirdi, #616 doğru build numarasını kanıtladı) — yani bu madde artık
   hiçbir şeyi tıkamıyor. ⚠ Ama anahtar **imzalama için zorunlu değil, OTOMASYON için
   zorunlu** — `openssl` CSR + elle sertifika/profil + uygulamaya özel şifre
   ile anahtarsız bir zincir kurulabilir (kayıt `console-formlari.md` §3).
   Arıza uzarsa gönderim buna çevrilir.
2. ✅ **DSA doğrulaması BİTTİ (10 Eylül 2026, 22:21).** Apple'ın
   e-postası: *"We successfully verified your trader contact information…
   Your information is now live on the App Store in the European Union."*
   Beyan 9 Eylül → doğrulama 10 Eylül, yani **~1 gün** (ölçüldü, tek
   ölçüm). Gönderim kapısı DÜŞTÜ — kayıt `console-formlari.md` §2.

✅ **Bizde kod işi KALMADI** (11 Eylül 2026): 24.5'in kompozisyon kararı
verildi ve uygulandı (başlıklı set + 7. kare). Sıradaki adım **sende ve
Console'da**: (1) sürüm numarasını `1.1.0` yapıp derlemeyi iliştir,
(2) `ios-screenshots.yml`in bir sonraki koşusunun artefaktını indirip
kareleri 6.9" ve iPad 13" slotlarına yükle.

**Durum:** kullanıcı Apple Developer hesabını açtı. Bu, bugüne kadar altı
ayrı yerde *"🔒 Apple Developer üyeliğine bloke"* diye kayıtlı olan işleri
birden açıyor. Bu bölüm onların **hangi sırayla** yapılacağını söyler —
`0. FAZ B`nin (Google Play) App Store ikizi.

⚠ **Play'in sayacının burada karşılığı YOK.** Faz B'nin takvimini "12
tester × 14 gün" belirliyordu; Apple'da böyle bir bekleme yok. Buradaki
takvimi belirleyen tek şey **App Review** (reddedilirse tur başa döner).
TestFlight'ın *iç* test kanalı incelemesiz; *dış* kanal ayrı bir Beta App
Review istiyor. *(Apple dokümanından; bu depoda ÖLÇÜLMEDİ.)*

**Hesap kimliği (8 Eylül 2026, kullanıcı bildirdi + ekran görüntüsü):**
**Bireysel** (Individual), ad **Alp Reşat Çapa**, Apple ID
**`destek@kelimeki.com`**. Play tarafının karşılığı da kişiseldi
(*Personal account*, Account ID `5939732949280610022`), yani iki mağazada
tutarlı.

✅ **ÜYELİK AKTİF** — aynı gün 14:48'de `(Pending)` düştü (ekran
görüntüsüyle doğrulandı: *Program resources* açıldı, yani **App Store
Connect · Certificates, IDs & Profiles · Membership details** erişilebilir).
Ödeme→aktivasyon **~12 dakika** sürdü; Apple'ın vaat ettiği 48 saatlik
tavan bu turda hiç kullanılmadı. Kimlik taraması İSTENMEDİ.
**24.1 artık koşulabilir.**

⚠ **Bireysel hesabın geri alınamaz sonucu:** App Store'da satıcı olarak
**kişinin yasal adı** görünür ve sonradan değiştirilemez. 24.5'in cevap
kâğıdı bunu veri olarak alır, yeniden sormaz.

⚠ **`destek@kelimeki.com` artık kritik bir kutu:** üyelik yenileme,
sözleşme değişikliği ve App Review yazışmaları oraya düşüyor. Adres Zoho'da
(bkz. `docs/decisions/support-email.md`) ve o kutuya erişimi kaybetmek
geliştirici hesabına erişimi kaybetmek demek. Aynı sebeple Apple ID'nin
2FA'sındaki güvenilir numara/cihaz kalıcı olmalı.

⚠ **`(Pending)` iken hiçbir 24.1 adımı yapılamaz** (bu tur ~12 dakika
sürdü, ama kayda geçsin): Team ID, Identifiers ve Keys ekranları üyelik
aktifleşmeden açılmıyor. Pending sayfasındaki *"complete your purchase
now"* banner'ı hem "ödeme yapılmadı" hem "işleniyor" durumunda göründüğü
için **tek başına kanıt değil** — ayrım Apple'ın makbuzuyla yapılır
(`destek@` kutusu ya da `reportaproblem.apple.com`). Apple bireysel
kayıtlarda ayrıca kimlik taraması isteyebiliyor ve bunu web'den değil
iPad/iPhone'daki *Apple Developer* uygulamasından yaptırıyor; **bu turda
istenmedi**, ama uzun süre Pending kalan bir hesapta ilk bakılacak yer
orası. *(Apple'ın süreci; bu depoda ÖLÇÜLMEDİ.)*

### 24.0 — Neyin HAZIR olduğu (8 Eylül 2026'da depodan ölçüldü)

Beklenenden fazlası hazır; özellikle **sunucu tarafı push tamamen
iOS-hazır**, çünkü tasarım baştan FCM üzerinden yazıldı:

| Hazır olan | Kanıt |
|---|---|
| Bundle id `com.kelimeki.kelimeki` (Android'le AYNI), deployment target iOS 13 | `ios/Runner.xcodeproj/project.pbxproj:385,363` |
| CI'da macOS runner'lı `ios` işi — `--no-codesign` cihaz + Appetize simülatör derlemesi | `.github/workflows/mobile-build.yml:369` |
| `push_tokens.platform` **`'ios'` değerini zaten kabul ediyor**, `register_push_token` doğruluyor | `20260828114349_push_tokens_and_preference.sql:39` · `20260831093203_...:60` |
| Çakıştırma etiketinin iOS yarısı **yazılmış**: `apns-collapse-id` | `supabase/functions/_shared/push.ts:310` (`npm run verify-push-payload` kilitliyor) |
| Admin hata panelinde platform filtresi (#11) | ✅ 31 Ağustos 2026 |
| Sürüm kapısı iOS anahtarını okuyor | `config/version_gate.dart:35` → `Platform.isIOS ? 'ios' : 'android'` |
| `Info.plist`'te `kelimeki://` şeması + iPad yönelimleri | `ios/Runner/Info.plist:30,83` |

### 24.1 — SENDE: hesap & kimlik (Console işi, kod yok)

Bunlar bitmeden 24.2 ve 24.3 test EDİLEMEZ.

1. Üyeliğin aktifleştiğini doğrula (satın alma → aktivasyon Apple'da 24-48
   saat sürebiliyor).
2. **Team ID'yi not et.** 24.4'ün `apple-app-site-association` dosyası buna
   bağlı ve **ben üretemem** — Membership sayfasında yazıyor.
3. Identifiers → App ID `com.kelimeki.kelimeki`; capability olarak **Push
   Notifications** ve **Associated Domains** işaretlensin.
   ⚠ Bundle ID tipi **Explicit** olmalı — *Wildcard* App ID push
   DESTEKLEMEZ ve sonradan değiştirilemez.
   ⚠ Bu adım **5'i kilitliyor**: App Store Connect'in "New App" formunda
   bundle ID bir AÇILIR LİSTE, burada kayıtlı olmayan görünmez.
4. Keys → **APNs Authentication Key** (`.p8`) üret.
5. Keys → **App Store Connect API Key** (rol: Admin ya da App Manager) —
   `.p8` + **Key ID** + **Issuer ID**. CI'ın Mac'siz imzalama yolu bu.
6. App Store Connect → yeni uygulama: ad **Kelimeki**, birincil dil
   **Türkçe**, SKU, bundle id yukarıdaki.

⚠ **5 ve 6 burada İLK KEZ yazılmıyor** — `mobile/docs/test-ortamlari.md`
→ *"TestFlight kurulumu"* onları 25 Ağustos 2026'da adım adım yazmıştı.
O dosya kaynak, burası indeks.

⚠ **İki `.p8` KARIŞTIRILMAZ:** biri APNs (→ Firebase Console'a yüklenir),
biri App Store Connect API (→ GitHub secret'ı olur). İkisi de **yalnızca
bir kez indirilebilir**; kaybolursa iptal edip yenisi üretilir.

### 24.2 — BENDE: Mac'siz imzalama + TestFlight (CI)

**Kısıt, `mobile-build.yml`in kendi notundan:** *"geliştirici iPad'den
çalışıyor; elinde ne Mac ne Android cihaz var"* (satır 461). Yani imzalama
ve yükleme **tamamen CI'dan** yürümek zorunda — Xcode'da elle "Archive"
seçeneği YOK. Android'de `.aab` için kurulan desenin aynısı:

**KAYNAK BU BÖLÜM DEĞİL:** işletim adımları `mobile/docs/test-ortamlari.md`
→ *"TestFlight kurulumu"*'nda zaten yazılı (25 Ağustos 2026) ve orası daha
ayrıntılı. Burada yalnızca indeks duruyor — karar oradan okunur.

- `mobile-build.yml`'e `ios` işinin yanına imzalı `.ipa` adımı: App Store
  Connect API anahtarıyla headless sertifika + App Store profili, sonra
  `upload_to_testflight`.
- Secret'lar: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
  `APP_STORE_CONNECT_KEY_P8`, `MATCH_PASSWORD`.
- ⚠ **`fastlane match` + AYRI BİR ÖZEL DEPO zorunlu, tercih değil:** Apple
  hesap başına dağıtım sertifikası sayısını sınırlıyor, yani her koşuda
  yenisini üretmek ÇALIŞMAZ — sertifika/profil şifreli olarak kalıcı bir
  depoda saklanmalı (gerekçenin tamamı `test-ortamlari.md`'de).
- **Secret yoksa adım sessizce atlanır** — `ANDROID_KEYSTORE_BASE64`'ün
  kuralı; mevcut Appetize/imzasız akışlar bozulmaz.
- ⚠ **Bu iş ancak gerçek anahtarla doğrulanabilir.** Yazıldığı an "çalışıyor"
  denemez; kanıt, TestFlight'ta beliren derlemedir (Faz B'de `.aab`'nin
  parmak izini CI log'undan geri okumakla aynı refleks).
- ⚠ **`mobile-build.yml`in başlığındaki iki yorum BAYAT ve bilerek
  düzeltilmedi** (satır 42-48 *"TestFlight… o iş üyelik geldiğinde
  eklenecek"*, satır 462 *"Apple Developer üyeliği (TestFlight) askıda"*).
  Sebep: o dosyaya dokunmak `paths` listesi gereği **tam bir macOS+Android
  derlemesi tetikliyor** ve deponun *"yalnızca doküman değişikliği
  ücretsizdir"* ilkesini bir yorum için bozmak anlamsız. **Düzeltme 24.2'nin
  kendi PR'ında yapılır** — imzalama adımı zaten o dosyaya giriyor.

### 24.3 — SENDE + BENDE: APNs / push

ROADMAP bunu bugüne kadar *"APNs anahtarını Firebase'e yükle + Push
capability ekle"* kadar kısa yazıyordu; ölçünce istemci tarafında üç dosya
daha çıktı.

| Kim | İş |
|---|---|
| Sen | Firebase Console → projeye **iOS uygulaması** ekle (`com.kelimeki.kelimeki`) → `GoogleService-Info.plist` indir |
| Sen | ✅ **YAPILDI (8 Eylül 2026)** — `.p8` Firebase'e yüklendi. **İKİ SATIR DA dolu** (*development* + *production*), ikisinde de `RL4JLXL389` / `8277D85FY9`. ⚠ Bu konsol sürümü ortamları AYRI satır olarak listeliyor ve **kritik olan `production`**: TestFlight/App Store derlemeleri production APNs'e bağlanır, yalnız development doluyken bildirim **hatasız** düşmez. *development* pratikte kullanılmıyor (Xcode debug derlemesi Mac ister, yok) — boş bırakılabilirdi, doldurmanın zararı yok |
| — | ⚠ **Yer bulma notu:** APNs yükleme ekranı *Project settings*'in **Cloud Messaging** sekmesinde ve dişli menüsünde GÖRÜNMÜYOR — dişliden **General**'a girip sekme şeridini kullanmak gerekiyor. Firebase bu bölümü birkaç kez taşıdı |
| — | ✅ **APNs anahtarı ÜRETİLDİ** (8 Eylül 2026): **Key ID `RL4JLXL389`**, ad *Kelimeki APNs*, Team Scoped (All Topics) + Sandbox & Production. Firebase'e yüklenmesi gereken üçlü: bu Key ID + Team ID `8277D85FY9` + `.p8` |
| Ben | ✅ **YAPILDI (8 Eylül 2026)** — `ios/Runner/GoogleService-Info.plist`. Aynı Firebase projesi doğrulandı (`kelimeki` / `791040026998`, bundle id eşleşiyor). Android'in `google-services.json`'ı da repoda, aynı karar. ⚠ **Klasöre atmak YETMEZ:** `project.pbxproj`'a dört yerden kaydedildi (PBXFileReference · PBXBuildFile · Runner grubu · **Runner hedefinin Resources fazı**). Sonuncusu olmadan dosya pakete GİRMEZ ve `Firebase.initializeApp()` cihazda sessizce başarısız olur. ⚠ Firebase Console'un **"Flutter"** akışı KULLANILMADI — o akış `firebase_options.dart` üretip Android tarafını da yeniden yazar; bu depo yapılandırmayı iki platformda da NATIVE dosyadan okuyor |
| Ben | `ios/Runner/Runner.entitlements` — dosya bugün **hiç yok**; `aps-environment` + `Info.plist`'e `UIBackgroundModes: remote-notification` |
| Ben | `AppDelegate.swift`'e bildirim paneli kanalı |

⚠ **`.p8` DOSYALARI DEPOYA GİRMEZ — depo PUBLIC** (8 Eylül 2026'da
doğrulandı: `alpcapa/kelimeki`, `visibility: public`). Burada yalnızca
**Key ID** ve **Team ID** kayıtlı; ikisi de gizli değil (Team ID her iOS
uygulamasının AASA'sında zaten yayınlanıyor, APNs Key ID her push JWT'sinin
`kid` başlığında gidiyor) ve özel anahtar olmadan işe yaramıyorlar.
Kaydedilmelerinin sebebi operasyonel: hesapta birkaç anahtar birikince
"Firebase hangisini kullanıyor" sorusunun cevabı olmazsa **yanlış anahtar
iptal edilip canlıda push düşer**.

⚠ **APNs anahtarının iki ayarı sessiz arıza üretir** (bu turda seçildi,
kayda geçsin): *Environment* **Sandbox & Production** olmalı — TestFlight
ve App Store derlemeleri Production'a, Xcode'dan çıkan geliştirme
derlemeleri Sandbox'a bağlanır; tek ortam seçilirse öteki tarafta bildirim
**hata vermeden** gelmez. *Type* **Team Scoped (All Topics)** — kısıtlı bir
anahtar, sonradan eklenen bir bundle ID'de aynı şekilde sessizce çalışmaz.

**Kanal adı ve metot BUGÜNDEN belli, uydurulmayacak** —
`data/notification_shade.dart:52,56` Kotlin tarafıyla birebir aynı olmak
zorunda diyor ve iOS için ne yapılacağını da yazmış: kanal
`kelimeki/bildirimler`, metot `hepsiniTemizle`, iOS karşılığı
`removeAllDeliveredNotifications()`. **Dart tarafı DEĞİŞMEZ.** Parite testi
(`test/notification_shade_parity_test.dart`) bugün Kotlin'i okuyor; iOS
yarısı eklenince Swift'i de okumalı — yoksa uyuşmazlık SESSİZ arıza
(çağrı `MissingPluginException` fırlatır ve yutulur).

⚠ **iOS rozeti bugün hiç ARTMAZ ve bu ayrı bir karar.** Rozet
`aps.badge`den geliyor, sunucu onu **hiç göndermiyor**
(`notification_shade.dart:26`). Yani "paneli temizle" işi iOS'ta rozet
değil yalnızca bildirim satırlarını hedefler. Sunucuya `badge` eklenip
eklenmeyeceği bu fazın parçası DEĞİL — açılırsa `_shared/push.ts` +
`verify-push-payload` birlikte değişir.

### 24.4 — Universal Links (Associated Domains) — **WEB YARISI ✅**

**ROADMAP 0.B/3'ün açık kalan TEK parçası buydu** (satır 858).

**Team ID: `8277D85FY9`** (8 Eylül 2026, Membership details'ten okundu —
gizli değil, uygulama kimliğinin parçası).

✅ **Web yarısı YAZILDI** (8 Eylül 2026):
`public/.well-known/apple-app-site-association`, tek `appID`
`8277D85FY9.com.kelimeki.kelimeki`.

**Kapsam Android'le BİLEREK aynı: `/*`, yani tüm `kelimeki.com` yolları.**
`AndroidManifest.xml`'deki `autoVerify` intent-filter'ında da `android:path`
kısıtı yok. İkisi ayrışırsa aynı link iki platformda farklı davranır ve bu
**sessiz** bir arızadır — kapsamı daraltmak isteyen iki tarafı BİRLİKTE
daraltmalı.

⚠ **Vercel'de `Content-Type` ELLE verilmek zorunda ve bu iOS'a özgü.**
Apple dosyayı **uzantısız** istiyor, Vercel ise Content-Type'ı uzantıdan
türetiyor — yani dosya varsayılan olarak `application/json` etiketlenmez ve
Apple'ın CDN'i doğrulamayı reddedebilir. `vercel.json` → `headers`'a açık
bir kural eklendi. `assetlinks.json`'ın böyle bir derdi YOK (`.json`
uzantısı var; canlıda ölçüldü: `content-type: application/json`), o yüzden
bu tuzak Android turunda hiç görülmedi.
⚠ `vercel.json`'a **şema dışı anahtar YAZILMAZ** — gerekçe yorumu olarak
bir `comment` alanı denendi ve geri alındı; Vercel `vercel.json`'ı şemaya
göre doğruluyor, bilinmeyen anahtar deploy'u kırabilir.

**Ölçüldü (derlemeden sonra):** dosya `dist/.well-known/`e kopyalanıyor ve
service worker precache'ine **girmiyor** (`globPatterns` varsayılanı
uzantıya bakıyor, uzantısız dosya eşleşmiyor) — yani SW araya girmiyor.

**KALAN — iOS yarısı, 24.3 ile AYNI PR'da:**
- `ios/Runner/Runner.entitlements` (dosya bugün hiç yok) →
  `com.apple.developer.associated-domains` = `applinks:kelimeki.com`
- `project.pbxproj` → `CODE_SIGN_ENTITLEMENTS` bu dosyayı göstermeli
- ⚠ App Links'in Android'deki dersi burada da geçerli: doğrulama yalnızca
  **TestFlight/mağaza imzalı** derlemede sınanabilir, CI'nın imzasız
  çıktısında değil (`mobile/docs/sonraya-birakilanlar.md`).

⚠ **Yayından sonra `curl` ile OKU** (deploy doğrulamasının aynı kuralı):
```
curl -sI https://kelimeki.com/.well-known/apple-app-site-association | grep -i content-type
```
`application/json` dönmüyorsa Apple doğrulaması yapılmadan iOS yarısına
geçme — entitlements doğru olsa bile link uygulamayı açmaz.

### 24.5 — SENDE + BENDE: mağaza vitrini

- **Ben:** `marketing/app-store/console-formlari.md` — Play'in cevap
  kâğıdının iOS ikizi. **App Privacy**, Play'in Data safety'sinin eşi ve
  büyük ölçüde ondan türer (`marketing/play-store/console-formlari.md` §3).
  Kategori **Games → Word**, destek URL `kelimeki.com`, gizlilik URL
  `kelimeki.com/gizlilik/`, hesap silme `kelimeki.com/hesap-silme/`.
- **Ekran görüntüleri — cihaz yokluğu burada ısırıyor.** Apple hem büyük
  iPhone hem (uygulama iPad'i desteklediği için) **13" iPad** seti istiyor.
  Play'de bunlar gerçek cihazdan alınmıştı; burada kaynak CI'nın zaten
  ürettiği **simülatör derlemesi** (`kelimeki-ios-simulator.zip`) ya da
  Appetize. Çözülmemiş: simülatör penceresinden Apple'ın istediği tam
  piksel ölçüsünde kare almanın yolu — **ölçülmedi, tur açılırken bak.**
- ⚠ **App Store 4.8 kapısı bugün KAPALI ve öyle kalsın:** uygulamada
  üçüncü taraf girişi YOK, o yüzden "Apple ile giriş" de zorunlu değil.
  #17 (Google ile giriş) iOS'a girdiği gün ikisi **birlikte** gider —
  gerekçe #17 → "Apple neden bu maddede YOK".
- ⚠ **`in_app_update` Android'e özgü**, iOS'ta karşılığı yok
  (`mobile/CLAUDE.md`). Yani iOS'ta elimizdeki TEK fren sürüm kapısı
  (`app_config.mobile_min_supported_version`).
  ✅ **9 Eylül 2026'da CANLIDAN ölçüldü: anahtar EKSİK DEĞİL** —
  satır `{"ios":"0.0.0","android":"0.0.0"}`. Bu bölüm *"o anahtarın satırı
  doldurulmalı"* diyordu; yanlıştı, `version_gate.dart`in okuduğu `'ios'`
  anahtarı zaten yazılı. **`0.0.0` bugün DOĞRU değer** (fail-open: kapı
  kapalı, zorunlu güncelleme yok) çünkü henüz yayınlanmış bir iOS sürümü
  yok. Gerçek iş şu: ilk TestFlight/App Store sürümünden SONRA bu satır
  iOS'ta tek fren olduğu için bilinçli yükseltilmeli — Android'deki gibi
  bir mağaza diyaloğu devreye girmiyor.

### 24.6 — Gönderim & inceleme

TestFlight'ta çalışan bir derleme + 24.5'in formları tamamlanınca gönderim.
Faz B'nin dersi burada da geçerli: **bir işin kaydı iki yerde durursa biri
kapanırken öteki kapanmıyor** — bu tablo bir İNDEKS, kararların kaynağı
`marketing/app-store/console-formlari.md` olacak.

### Sıra ve bağımlılıklar

```
24.1 (sende, Console)
  ├─→ 24.2 (imzalama/TestFlight)  ─┐
  ├─→ 24.3 (APNs)                  ├─→ 24.6 (gönderim)
  ├─→ 24.4 (Universal Links)      ─┤
  └─→ 24.5 (vitrin) ───────────────┘
```

**24.1 tek gerçek kilit.** 24.5'in cevap kâğıdı ondan bağımsız yazılabilir
(hesap tipi hariç); 24.2/24.3/24.4 anahtarlar ve Team ID gelmeden
YAZILABİLİR ama DOĞRULANAMAZ — ve bu depoda "yazıldı" ile "çalışıyor"
arasındaki farkın bedeli defalarca ödendi.

---

## 26. Web'den mağazalara yönlendirme — **BEKLİYOR: mağaza linkleri canlı değil** (10 Eylül 2026)

Kullanıcı isteği: *"web'de çıkan 'Add to homescreen' sadece web'de kalmalı.
Android ve iOS'dan gelenleri Store'lara yönlendirmek gerekecek. Bir de
Setup'ın alt kısmına App Store ve Google Play butonları koymamız lazım."*

**Tamamı WEB işi** (`src/`) — mobil pakete binmez, `main`'e merge olur olmaz
Vercel'den canlıya çıkar. Yani bir sürüm turu BEKLEMEZ.

### Neden bugün yapılmadı — bilinçli erteleme

İki mağaza linkinin **ikisi de bugün 404**: Play'in production başvurusu
10 Eylül 15:26'da gönderildi (inceleme ≤7 gün) ve production sürümü olmadan
vitrin adresi 404 veriyor (`marketing/play-store/console-formlari.md` §7'nin
ölçümü); App Store ise henüz gönderilmedi (24.6 açık). Rozetleri şimdi
koymak kullanıcıyı 404'e göndermek olurdu.

⚠ **İKİ TUR OLACAK, tek seferde bitmez:** Play muhtemelen bir hafta içinde,
App Store haftalar sonra açılıyor. Önce Android yarısı, sonra Apple'ınki.

### Tetikleyici

Play production onayı (e-posta `destek@kelimeki.com`'a düşecek) → Android
yarısı. App Store yayını → Apple yarısı.

### Yapılacaklar

| Parça | Not |
|---|---|
| Mağaza URL'leri tek bir sabit dosyasında | `null` = "henüz yayında değil" → o rozet/dal HİÇ render edilmez. Tek satır değiştirip merge etmek yeter |
| `Setup.tsx` footer'ına rozet satırı | Hukuki linklerin (`Kullanım Koşulları · Gizlilik Politikası · Paylaş`) ÜSTÜNE, ortalanmış kendi satırı |
| `AddToHomeScreen.tsx` platforma göre dallansın | **Asıl iş burada.** Bugün `detectPlatform()` zaten `ios`/`android`/`other` ayırıyor ama üçü de aynı PWA talimatına düşüyor. Mağaza yayındaysa o platform mağazaya, değilse bugünkü PWA şeridine düşmeli — hiçbir aşamada boş ekran olmamalı |
| iOS Smart App Banner | `<meta name="apple-itunes-app" content="app-id=…">` — tek satır, ama App Store onayı + **sayısal App ID** ister |
| Manifest `related_applications` + `prefer_related_applications` | ⚠ **ÖLÇMEDEN AÇMA.** Chrome'un PWA kurulumunu Play'e yönlendirmesinin standart yolu, ama masaüstü kurulumunu da bastırıp bastırmadığı bu depoda ÖLÇÜLMEDİ — açılırsa masaüstündeki çalışan davranış sessizce kaybedilebilir |
| Doküman senkronu | `docs/decisions/components.md` → `AddToHomeScreen` notu |

### Rozet görselleri — ÇİZİLMEZ, resmî dosya indirilir

Apple ve Google rozetleri **tescilli marka**; ikisi de yeniden çizmeyi,
rengini/oranını değiştirmeyi yasaklıyor. Bu depo logosunu SVG path'e
çeviriyor diye bunlar da öyle sanılmasın.

- Apple → `https://developer.apple.com/app-store/marketing/guidelines/`
  (10 Eylül 2026'da doğrulandı, `200`)
- Google → Play badge generator, `https://play.google.com/intl/en_us/badges/`
  ⚠ bu adres oturumun ağ politikası yüzünden DOĞRULANAMADI

**Türkçe sürümlerini al** (uygulama Türkçe-only), ikisini **aynı yükseklikte
yan yana** göster, her rozetin kendi "clear space" kuralına uy; minimum
ölçüleri ezberden değil kendi güncel kılavuz sayfalarından oku.

⚠ **ÖLÇÜLDÜ (10 Eylül 2026, kullanıcı denedi): Apple rozeti yayına
girmeden ALINAMIYOR.** Kılavuz sayfasındaki hafif yol olan **App Store
Marketing Tools**, rozeti vermeden önce uygulamayı **arattırıyor**;
Kelimeki App Store'da olmadığı için o akış ilerlemiyor. Yani bu madde
yalnızca "link 404" yüzünden değil, **rozet dosyası da elde edilemediği
için** bekliyor. Aynı sayfadaki `Download (All Versions)` bağlantısı
çalışıyor ama **336 MB** (her dil × her stil × her boyut) — yayın
gecikirse yedek yol budur, arşivden yalnızca Türkçe siyah dosya alınır,
gerisi repoya GİRMEZ.

⚠ **Apple'ın "Preferred Badges" kuralları — yerleşimi BAĞLAR** (aynı
sayfadan, 10 Eylül 2026):

| Kural | Bizde karşılığı |
|---|---|
| Başka platform rozetleriyle aynı düzendeyse **siyah** rozet kullanılır | Play rozetiyle yan yana duracağımız için siyah şart |
| Rozeti çevreleyen **gri kenarlık artwork'ün parçasıdır**, değiştirilmez | Kırpma/yeniden çerçeveleme yok |
| *"Place the App Store badge first in the lineup"* | **App Store SOLDA, Google Play SAĞDA** — bu, ilk önerilen sıralamayı tersine çevirdi |

### Efor

Yarım gün (testler + doküman senkronu dahil). Hiçbir şeye bağımlı değil —
onay geldiği gün oturulup bitirilir. ⚠ Bu tahmin bir SÖZ değil: bu dosyanın
kendi dersi, eski #7'nin *"tek satır"* sanılıp ölçünce no-op çıkmasıydı.
