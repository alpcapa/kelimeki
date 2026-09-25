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

✅ **O BLOKER DÜŞTÜ — ve 13 Eylül 2026, 00:14'te ONAYLANDI.** Aylardır
sırayı belirleyen şey koda değil takvime bağlıydı: kişisel hesaplarda
**12 tester × 14 gün kesintisiz**. Sayaç doldu, kartın üç şartı da çizildi,
başvuru 10 Eylül 15:26'da gönderildi ve Google **kabul etti**
(*"Congratulations! Your app has been granted Google Play production
access"*, `com.kelimeki.kelimeki`) — Console *"7 gün ya da daha az"*
demişti, **~2,5 günde** geldi. Cevaplar, ölçümler ve soruların tam metni:
`marketing/play-store/console-formlari.md` §7.

⚠ **ERİŞİM ≠ SÜRÜM.** Onaylanan şey production KANALINI kullanma hakkı;
mağaza vitrini (`play.google.com/store/apps/details?id=com.kelimeki.kelimeki`)
o kanala bir sürüm yayınlanıp KENDİ incelemesinden geçene kadar **404**
vermeye devam eder. Yani §26'nın (mağaza rozetleri) Android yarısı bu
e-postayla AÇILMADI.

| Kova | Ne | Durum |
|---|---|---|
| **Sayaç** | 12 tester × 14 gün | ✅ **KAPANDI — production ERİŞİMİ ONAYLANDI 13 Eyl 2026, 00:14** (başvuru 10 Eyl 15:26, ~2,5 gün). ⚠ Erişim ≠ sürüm: vitrin, production kanalına sürüm yayınlanana kadar 404 · ⚠ karttaki **12**'nin gerçek adet mi şartın tavanı mı olduğu ÖLÇÜLMEDİ (2 Eylül, kullanıcı itirazı — aşağıda) · *Android developer verification* ✅ **BİTTİ** (Console'dan doğrulandı 31 Ağustos: `com.kelimeki.kelimeki` Registered, 3 anahtar, Identity dolu) |
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
| **iOS/App Store** | **#24 FAZ C** — hesap/kimlik · Mac'siz imzalama + TestFlight · APNs · Universal Links · vitrin · gönderim | ✅ **KAPANDI: `1.1.0 (665)` 15 Eylül 2026'da App Store'da YAYINDA.** Bölümün tamamı arşivde (`docs/decisions/roadmap-arsiv.md` → "24. FAZ C — App Store yayını"); işletim kaynağı `marketing/app-store/console-formlari.md` |

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

**#26 — Tahtanın yükseklik bütçesi PORTA da gerekli** → ⏳ **AÇIK, freeze'i
bekliyor** (22 Eylül 2026; web yarısı `main`'de).

⚠ **Sıra: #611 merge edilmeden BAŞLAMA** (23 Eylül 2026). #611 (filigran
tavanı, #609'un port ikizi, merge turunun dokuzuncusu) da
`board_widget.dart`e dokunuyor ve tavanı bu maddenin ön koşulu olarak
yazıldı; #26'yı onun üstüne kur, yan yana değil.

Kullanıcı bildirdi: *"Kelimeki'yi Samsung katlanabilirde denedim, tahta yatay
iPad gibi görünüyordu, raf ve butonlar ekranın altında kalıyordu. Görmek için
aşağı kaydırmak gerekiyor, oynamak imkânsız."*

Sebep: tahta YALNIZCA genişlikten boyutlanıyor, layout'ta "ne kadar boyum
kaldı" sorusu hiç yok. ⚠ **Katlanabilire özel DEĞİL** — yatay tablet ve 800px
yüksekliğindeki sıradan bir dizüstü tarayıcısı da aynı durumdaydı (webde
ölçüldü: açık Fold yatay 195px · yatay iPad 143px · dizüstü 1440×800 163px
taşma).

**Web yarısı yapıldı** (`src/utils/boardFit.ts` + `Board.tsx` + kapısı
`tests/board-fit.spec.ts`; kullanıcı kararı: *"Sadece web'de yap"*). Kalan:

- **Port ikizi** — `mobile/app/lib/src/ui/game/board_widget.dart` aynı deseni
  taşıyor (`MediaQuery.sizeOf(context).width` + `aspectRatio: 1`, yükseklik
  bütçesi yok). ⚠ **Ölçülmedi**, yalnızca kaynaktan okundu; işe başlarken
  önce cihazda ya da bir Flutter testinde ölçülmeli. Ölçüler
  `boardFit.ts`teki üç sabitten gelmeli (301 krom · 680 tavan · 324 taban) —
  web↔port ayrışırsa iki platform aynı tahtayı iki boyda çizer.
- **`LandscapeHint` ikizi** — web'de kural `(orientation: landscape)`ten
  YÜKSEKLİĞE taşındı (eski kural açık katlanabilirde de tetikleniyor ve
  *"dikeye dön"* orada yanlış tavsiye oluyordu). Portun karşılığı varsa aynı
  ölçüte geçmeli.

⚠ **Bu bir "yatay düzen" işi DEĞİL, ayrı bir madde:** telefon YATAYDA hiçbir
sınır değeri oyunu oynanabilir yapmaz — krom tek başına 301px, viewport
375–430, yani tahtaya 56–111px kalıyor (13 hücreye 4–9px). Orayı gerçekten
açmak tahta solda / raf+butonlar sağda bir YAN YANA düzen ister; karar
verilmedi, bu maddenin kapsamında değil.

**#25 — iOS uygulama simgesinde rozet SAYISI çıkmıyor** → ⏳ **AÇIK, freeze'i
bekliyor** (18 Eylül 2026, kullanıcı bildirdi: *"Apple uyarılar geliyor ama
ikon üzerinde numara çıkmıyor"*).

Bildirimler geliyor, yalnızca sayı yok. Sebep bir regresyon DEĞİL, dayanağı
geçersizleşmiş bilinçli bir erteleme — kod üç yerde yazmış
(`_shared/push.ts`, `notification_shade.dart`, `AppDelegate.swift`):
*"iOS henüz CANLI DEĞİL… yükü BİLEREK vermiyoruz"*. iOS artık canlı
(18 Eylül'de ölçüldü: **9 token / 5 kişi**), varsayım düştü.

⚠ **İki platform rozeti tamamen farklı üretiyor.** Android'de rozet bizim
gönderdiğimiz bir sayı değil — One UI onu PANELDE DURAN bildirimlerden
türetiyor, yani `cancelAll()` rozeti de düşürüyor (#15). iOS'ta böyle bir
türetme YOK: sayı yalnızca `aps.badge`den gelir ve `buildFcmMessage`
`apns.payload`ı hiç göndermiyor.

**Düzeltme iki yarım ve İKİSİ AYNI PR'DA gitmeli:**

| Yarım | Nerede | Freeze |
|---|---|---|
| Rozeti göster — `apns.payload.aps.badge` + sayıyı hesapla | `supabase/functions/` + `verify-push-payload` | ✅ `mobile/` dışı |
| Rozeti sıfırla — açılışta `setBadgeCount(0)` | `ios/Runner/AppDelegate.swift` | ⛔ `mobile/` |

⚠ **Yalnızca sunucu yarımını göndermek işi BOZAR:** iOS rozeti MUTLAK bir
sayı, yeni bir push gelene kadar ekranda asılı kalır — 31 Ağustos'taki
*"9'da takılı kaldı"* hatasının iOS kopyası. `AppDelegate.swift` bunu zaten
öngörmüş (*"o değişiklik `verify-push-payload` ile birlikte gelmeli"*).

**Sayının tanımı da karar:** web'de `useAppIconBadge` üç şeyi topluyor
(arkadaşlık isteği + Canlı oyun + yerel kayıt); sunucuda bunu hesaplayan
hazır bir fonksiyon YOK, yazılması gerekiyor.

**Sıradaki adım:** Play production incelemesi kapanıp mobil merge kapısı
açılınca tek PR. Kullanıcı kararı (18 Eylül): acele yok, 5 test kullanıcısı
etkileniyor.

**#32 — e-posta onayı bir kullanıcı kaybı kapısı** → ⏳ **AÇIK, ERTELENDİ**
(20 Eylül 2026, kullanıcı: *"İnsanlar burada bounce ediyor, bu işi bir daha
düşünmek lazım"* → aynı gün: *"Şu anda mobilde 7 update var. Bu zaten
oldukça fazla. Roadmap'e yaz, daha sonra bakalım."*). İki saha vakası, yedi
alternatif, önerilen sıra ve dondurma uyumluluğu aşağıda, #32'de.

**#33 — gizlilik metni kendi içinde çelişiyor: "dört durumda" diyor, BEŞ
madde sayıyor** → ⏳ **AÇIK, dondurmayı bekliyor** (21 Eylül 2026, kod
okunurken bulundu — kullanıcı bildirmedi, yani sahada kimse fark etmemiş
olabilir ama metin CANLIDA yanlış).

`src/legal/LegalContent.tsx`: *"Bu kod **dört** durumda sunucuya iletilir:
(1)… (2)… (3)… (4)… **(5)** Oyunu tanıtan kısa turu…"* ve paragraf
*"**Bu beş kaydın** hiçbirinde…"* diye bitiyor. Tanıtım turu (5) 8 Eylül'de
eklenirken açılış cümlesindeki sayı güncellenmemiş. Aynı hata portun birebir
kopyasında da var (`mobile/app/lib/src/ui/auth/legal_modals.dart`: satır 417
"dört durumda", 442 "(5)", 447 "Bu beş kaydın") — kopya sadık, hatayı da
taşımış. `/gizlilik/` statik sayfası aynı kaynaktan üretildiği için hata
yayında.

**Düzeltme tek kelime** (`dört` → `beş`), ama ⚠ **iki dosyada birden ve
`Son güncelleme` tarihiyle**: `mobile/app/test/legal_text_test.dart` port
kopyasının tarihini doğrudan web kaynağını okuyarak karşılaştırıyor, yani
tek taraflı düzeltme web CI'ın `parite` işini düşürür. `mobile/app/` dosyası
olduğu için **mobil derlemeyi tetikler** → dondurma bitmeden yapılmaz;
**port merge turuyla AYNI PR'da** halledilmeli (bkz. "Dondurulmuş port
PR'ları — merge turu SIRASI").

⚠ **Ders (aynı gün ikinci kez):** bir listeye madde eklerken listeyi SAYAN
cümle de güncellenmeli — bu, rozet zincirinin metindeki karşılığı.

**#34 — Canlı sohbet okundu bilgisinin PORT yarısı** → ⏳ **AÇIK,
dondurmayı bekliyor** (23 Eylül 2026; web yarısı #610 ile `main`'de).

Okundu damgası artık sunucuda (`online_game_chat_reads` +
`mark_online_game_chat_read` RPC'si), ama uygulama hâlâ yalnızca cihazdaki
`chat_read_store.dart`'ı kullanıyor. ⚠ **Sonuç SAHADA: uygulamada okunan
mesajlar web'e yansımıyor** (ve Android'deki "ilk açılışta her şey okundu"
tohumu hâlâ yeni mesajları yutuyor). Yapılacak: port tabloyu OKUSUN ve
RPC'yle YAZSIN; karar `decideChatRead`in (`utils/chatRead.ts`, kapı
`npm run verify-chat-read`) Dart ikizine geçsin — iki kaynağın büyüğü,
sunucu isteği düştüyse ve cihazda damga yoksa tohum sunucuya YAZILMAZ.
Tasarım ve tuzaklar: `docs/decisions/chat-moderation.md` → "Okundu damgası
SUNUCUDA". `mobile/app/` dosyası → mobil derlemeyi tetikler, merge turu
bitince.

**#35 — Kayıt Hunisi'nin PORT yarısı: uygulama da `signup_events`e
yazsın** → ⏳ **AÇIK, dondurmayı bekliyor** (23 Eylül 2026, kullanıcı
isteği: *"Roadmap'e ekle"*).

Admin → Büyüme → Kullanıcı'daki "Kayıt Hunisi" kartı (#600) **yalnızca
web'i** sayıyor: port aynı iki olayı (`signup_started`/`signup_completed`,
`ui/auth/auth_modal.dart`) yalnızca Firebase Analytics'e yazıyor. Kayıtların
önemli bir kısmı mobilden geldiği için kart, kitlenin bir kısmını görüyor.
Kullanıcı "veri yok" deyince fark edildi. Canlıdan ölçüldü (23 Eylül): tablo
boştu ama arıza yoktu. 21 Eylül'deki yayından beri web'de kimse kayıt
formunu açmamış, hiçbir platformda yeni hesap da açılmamıştı (son hesap
20 Eylül).

Yapılacak: `auth_modal.dart`taki iki `analytics.log` noktasına paralel
olarak `signup_events` insert'i (`games_api.dart`taki `tutorial_events`
ucunun deseni: `platform` + `app_version` dolu, hata akışı bozmaz). Firebase
çağrısı KALIR. Kanal (`direct`/`form`) web'le aynı küme olmalı. ⚠ **`anon_id`
EKLEME:** tablo bilerek kimliksiz, gizlilik metnine dokunmamak için (bkz.
migration `20260921122031_signup_events_funnel.sql` başlığı ve #33). Aynı
PR'da şunlar da güncellenmeli: kartın `?` metnindeki "⚠ Yalnızca web"
paragrafı (`AdminDashboard.tsx` → `HINTS['kayit-hunisi']`), `logSignupEvent`
yorumu (`src/lib/api.ts`), migration'daki "tablo yalnızca web'den yazılıyor"
notu ve `docs/decisions/admin-panel.md`. Port da yazmaya başlayınca oran
yine AYNI tablodan kurulabilir, `profiles`a geçmeye gerek yok. `mobile/app/`
dosyası olduğu için mobil derlemeyi tetikler, merge turu bitince yapılır.

**#36 — Takma isim değişince geçmiş oyunlar ESKİ ismi göstermeye devam
ediyor** → ⏳ **AÇIK, sonra bakılacak** (23 Eylül 2026, kullanıcı: *"Geçmiş
oyunları da yeni isme döndürmek mantıklı gözüküyor ama bu anlık olabilecek
bir değişiklik değil… roadmap'e koyalım"*).

Bugünkü durum (kaynaktan okundu): benzersizlik yalnızca şu anki değerlere
bakan unique index (`profiles_display_name_tr_lower_key`, migration
`20260729141514`). İsim değişince eskisi **anında serbest kalır**; bekleme
süresi ya da isim geçmişi yok. `games.players` jsonb'si ise oyunun bittiği
andaki ismi DONMUŞ saklıyor. Kişi kendi geçmişinde kendi satırını güncel
isimle görüyor (`GameHistoryModal.tsx` → `myCurrentName`; port ikizi
`game_history_modal.dart`), rakipleri ise eski ismi görüyor. ⚠ **Asıl risk:**
biri "A"yı bırakıp başkası "A"yı alırsa, eski geçmişlerdeki "A" artık yeni
sahibine aitmiş gibi okunur.

Neden anlık değil: `GamePlayerSnapshot`ta (`database.types.ts`) **kullanıcı
kimliği YOK**; yalnızca `name` / `score` / `is_ai` / `colorIndex` var. Yani
rakibin satırını bugünkü profiline bağlayacak bir anahtar kayıtta durmuyor.
Olası yollar (karar verilmedi, ölçülmedi):
(a) snapshot'a `user_id` ekle, isimleri okurken `profiles`tan çöz. Eski
kayıtlar için Canlı oyunlarda `online_game_id` + koltuk eşlemesiyle
backfill mümkün olabilir; yerel/YZ oyunlarında zaten tek insan var.
(b) İsim değişikliğinde `games.players`ı yeniden yaz (toplu UPDATE, bir
tetikleyici ya da RPC). Basit ama kimliği isimden tahmin etmek zorunda.
(c) Ucuz ara çözüm: bırakılan ismi bir süre kilitle (karışıklığı önler,
geçmişi düzeltmez).
⚠ **Dokunacağı yerler:** `players`ı okuyan her yüzey (oyun geçmişi,
favoriler/`list_liked_games`, herkese açık `/game/:id`, admin), port ikizi
ve `database.types.ts` ↔ portun `fromJson`'ı (sözleşme değişikliği).
Hesap silme de aynı jsonb'yi İSİMDEN eşleyerek yeniden yazıyor
(`delete_account_cascade` → `name`i "Silinmiş oyuncu" yapar); (a) seçilirse
o da kimliğe geçmeli, (b) onunla aynı kırılganlığı taşır.

**#8** (FAZ A1 Bölüm 6 — Paylaşma, iPad popover)
✅ **KAPANDI** 3 Eylül 2026 — hata bulunup düzeltildi ve Appetize/iPad'de
doğrulandı; arşivde.
**#11** (hata panelinde platform filtresi) ✅ **KAPANDI** 31 Ağustos 2026
— bu satır 2 Eylül'e kadar onu hâlâ bekleyen iş gibi gösteriyordu, oysa
aynı gün yukarıdaki özet tablo ✅ diyordu (kaydın iki yerde durması).
**#12** (sürüm dağılımı kapsamı) ✅ **KAPANDI** 31 Ağustos 2026 — bkz.
arşivde "Faz 6".
**#15 — uygulama öne gelince bildirim panelini temizle** → ✅ **KOD TAMAM**
(31 Ağustos 2026), sıradaki mobil sürümle çıkar. Ayrıntı arşivde: "Faz 6".
**iOS/App Store** → ✅ **KAPANDI** (15 Eylül 2026, `1.1.0 (665)` yayında);
**#24 FAZ C** arşivde. Push tasarımı bilerek FCM üzerinden
yazıldığı için **ikinci bir gönderici YAZILMAYACAK** — bu karar duruyor ve
sunucu tarafı ölçülünce zaten iOS-hazır çıktı (`apns-collapse-id` yazılmış,
`push_tokens.platform` `'ios'` kabul ediyor; kanıtlar #24.0'da). ⚠ Bu satır
uzun süre kalan işi *"APNs anahtarını yükle + Push capability"* kadar
gösterdi; ölçüm daha büyük çıktı (imzalama zinciri, entitlements, AASA,
vitrin) — tahmin, kaynak okunarak düzeltildi.

**#36 — Huni v2'nin gizlilik metni yarısı: "Üye" sütunu + üye bitişi** →
⏳ **AÇIK, dondurmayı bekliyor** (24 Eylül 2026, kullanıcı kararı: *"ikiye
böl"*). Sunucu + web yarısı (`funnel_events`, admin "Huni v2") bu tarihte
yayında, ama web yalnızca gizlilik metninin BUGÜN saydığı olayları yazıyor
(ziyaret, YZ oyunu başlangıcı, misafir bitişi). `signup` ve üye oyun bitişi
`FUNNEL_MEMBER_EVENTS_ENABLED` (`src/utils/funnelEvents.ts`) bayrağının
arkasında, çağrı yerleri hazır. Yapılacak TEK PR: 6. bölüme yeni durumları
ekle (anonim kodla, hesap kimliği OLMADAN, yalnızca GÜN: "hesap açtığınızda"
+ "girişliyken oyun bitirdiğinizde") + tarihi güncelle + port kopyası
(`legal_modals.dart`) + bayrağı `true` yap. `npm run verify-funnel-events`
bayrağın metin güncellenmeden açılmasını engelliyor. **#33'ün "dört → beş"
düzeltmesiyle AYNI PR** (ikisi de aynı paragraf, aynı tarih, aynı port
dosyası). Mobil derlemeyi tetikler → merge turunda; Huni v2'nin mobil yarısı
(PR 2, `docs/decisions/funnel-v2.md`) ile birleştirilebilir.

## Dondurulmuş port PR'ları — merge turu SIRASI (21 Eylül 2026)

Play production incelemesi (#19) kapanınca girecek yedi PR. Önerilen sıra:
**#565 → #562 → #579 → #576 → #554 → #557 → #547**.

⚠ **Dondurmanın artık YAZILI bir dayanağı var (22 Eylül 2026).** Play
destek talebine gelen cevap: *"each new submission will reset the review
turnaround time, as the evaluation period is counted from the date of the
most recent change"* — yani Play'e yeni bir paket yüklemek #19'un saatini
SIFIRLAR. ⚠ Ama kapsamı karıştırma: bağlayıcı olan **Play'e yükleme**,
`main`'e merge değil (merge yalnızca `mobile-build` + TestFlight'ı
tetikler, Play kuyruğuna dokunmaz). Merge dondurması yine de duruyor,
çünkü merge incelemedeki paketin `.aab`sini `mobile-latest`ten siliyor.
Cevabın tamamı ve talebin künyesi:
`marketing/play-store/console-formlari.md` → "Google cevapladı".

Sıra tahmin DEĞİL, ölçüldü (`main` = `3a55492`): yedisinin başı çekilip
`merge-tree` ile tek tek denendi, sonra ayrı bir çalışma ağacında *"her
adımda temiz birleşenler arasından, sonrasında en çok PR'ı temiz bırakanı
seç"* diyen ileriye bakan bir simülasyon koşuldu.

⚠ **"Çakışmasızları öne al" İŞE YARAMIYOR — denendi ve elendi.** Bugünkü
`main`'e karşı üçü temiz (#557, #576, #579), ama bu özellik ilk merge'ü
yaşamıyor: altı PR `mobile/docs/parca-log.md`'ye, altısı
`mobile/TESTING.md`'ye ekleme yapıyor. Hangisi önce girerse KALAN ALTISI
çakışıyor — simülasyonda en iyi adayın skoru bile **0**. Yani sıra
çakışmayı önlemiyor, yalnızca kimin bedava geçeceğini seçiyor. Ölçüt bu
yüzden "çakışmasız" değil, **küçükten büyüğe**: her çözüm olabildiğince
küçük kalsın, en geniş iki PR temiz zemine otursun.

⚠ **"Mobil tetiklemeyenleri öne al" seçeneği de YOK:** yedisi de
`mobile/app` ya da `mobile/kelimeki_core` altında KOD değiştiriyor, yani
her merge ayrı bir `mobile-build` + TestFlight yüklemesi demek.

| Sıra | PR | Dosya | Neden burada |
|---|---|---|---|
| 1 | **#565** oyun bitiş `platform` damgası | 3 | `parca-log`'a hiç dokunmuyor — turun tek gerçekten temiz halkası |
| 2 | **#562** kayıt onayı | 5 | küçük; tek dart dosyası + testi. ⚠ #32'nin E/F alternatifleri bunun SAHAYA inmesini bekliyor |
| 3 | **#579** 504 yeniden deneme | 6 | `mobile/TESTING.md`'ye dokunmuyor, yalnızca `parca-log` |
| 4 | **#576** zoom balonu otomatik kapanma | 8 | kapsam dar |
| 5 | **#554** taş değiştirme sınırı | 9 | MOTOR dosyası (`constants.dart` + `reducer.dart`) → golden vector'lar + `dart run test/run_all.dart` aynı turda |
| 6 | **#557** oyun ortasında giriş | 22 | en geniş; `Runner.xcodeproj` + `pubspec.lock` taşıyor |
| 7 | **#547** ham hata metinleri | 20 | turun tek **web** dosyasını (`src/utils/errorMessage.ts`) ve `web-ci.yml`i o taşıyor; parite kapısı `error_message_parity_test.dart` onunla geliyor → en son, temiz zeminde. `npm run lint` + `verify-error-messages` |

### Dal ↔ PR eşlemesi — ⚠ İKİ DALIN ADI İÇERİĞİYLE UYUŞMUYOR

⚠ **Merge turunda seçimi DAL ADINA göre yapma, PR NUMARASINA göre yap.**
Aşağıdaki son iki satır bunun nedeni: dal adları o dalın taşıdığı işi
tarif etmiyor (iş, adı başka bir konuya göre konmuş bir dalın üstüne
yazılmış). Ada güvenen biri sırayı sessizce karıştırır ve — daha kötüsü —
"bu dal zaten şu işti" diye yanlış PR'ı merge eder.

| Sıra | PR | Dal |
|---|---|---|
| 1 | #565 oyun bitiş `platform` damgası | `claude/oyun-bitis-platform-port` |
| 2 | #562 kayıt onayı | `claude/kayit-onay-port` |
| 3 | #579 504 yeniden deneme | `claude/gecici-sunucu-hatasi-retry-port` |
| 4 | #576 zoom balonu otomatik kapanma | `claude/zoom-balonu-otomatik-kapanma-port` |
| 5 | #554 taş değiştirme sınırı | `claude/tas-degistirme-siniri-port` |
| 6 | #557 oyun ortasında giriş | ⚠ `claude/mobile-latest-merge-conflict-lf2og7` |
| 7 | #547 ham hata metinleri | ⚠ `claude/app-store-play-review-status-9wecvh` |
| 8 | #601 kaynak hunisi (`app` kanalı) | `claude/frozen-port-prs-merge-cis79o` |
| 9 | #611 filigran tavanı (#609'un port ikizi) | `claude/ipad-filigran-tasmasi` |

⚠ **#601 bu turun SEKİZİNCİSİ.** Yukarıdaki yedili sıra 21 Eylül'de
ölçüldüğünde #601 henüz yoktu; o da aynı dondurmayı bekliyor ve en sona
biniyor (`mobile/app/` altında yedi dosya taşıyor, yani o da mobil
derlemeyi tetikler).

⚠ **#611 DOKUZUNCU** (23 Eylül 2026, kullanıcı: *"diğerleriyle sonraki
sürüme dahil et"*). Web ikizi #609 zaten canlıda; #611 `board_widget.dart`e
dokunuyor, yani ROADMAP #26 (portta yükseklik bütçesi) aynı dosyada
başlayacağı için #26'dan ÖNCE merge edilmeli.

**Eşleme 22 Eylül 2026'da canlıdan ölçüldü** (`git ls-remote --heads
origin 'refs/heads/claude/*'` + açık PR listesi): `origin`'de sekiz
`claude/*` dalı var ve **sekizinin de açık bir PR'ı var** — öksüz dal YOK.
Bu kontrol tekrarlanmaya değer, çünkü bu depoda PR'sız bırakılmış dallar
iki kez gerçek iş kaybetti (kök `CLAUDE.md` → "Git / Branch Kuralı").

**Çakışmaların tamamı EKLEME çakışması** (`parca-log.md`,
`mobile/TESTING.md`, bir kez kök `CLAUDE.md`): iki tarafı da tut, sırala,
içerik kaybı yok. ⚠ `mobile/TESTING.md`'de bölüm NUMARALARI var —
birleştirdikten sonra yeniden sırala. `ROADMAP.md` bugünkü ölçümde yedisinde
de otomatik birleşiyor, ama sıra ilerledikçe bu değişebilir.

⚠ **`mobile/docs/surumler.md` → "SÜRÜM SENKRONU" tur SONUNDA bir kez**
güncellenir, her merge'de değil — yedi merge yedi build tetikler, anlamlı
olan sonuncusudur.

**Dokuzlu yeniden ölçüm (23 Eylül 2026, `main` = `184dba1`, TAM geçmişle):**
dokuz PR sırayla, arka arkaya birleştirildi — dokuzu da birleşiyor, her
dosyada TEK blok. Tek KOD çakışması **#565 ↔ #601**
(`mobile/app/lib/src/data/games_api.dart`, `game_finishes` satırı): #565
`platform`, #601 `utm_source: d.source` + misafirde `anon_id` ekliyor —
**üçü de tutulur**. Geri kalanı ekleme çakışması (`ROADMAP.md`,
`parca-log.md`, `mobile/TESTING.md`, #547'de iki `CLAUDE.md`). ⚠ Sığ klonda
#547 13 dosyada çakışıyor GÖRÜNÜYOR — yanlış alarm, önce
`git fetch --unshallow`.

### Tur sonu TEST PLANI — son derleme üzerinde, BİR kez (23 Eylül 2026)

Kullanıcı kararı: dokuz PR tek sürümle çıkıyor, test her merge'de değil
SON derlemede yapılır. Sürüm "tamam" sayılmadan ÖNCE üçü birden:

1. **Son `main` commit'inde CI yeşil** (web CI'ın `parite` işi dahil) **ve
   son `mobile-build` koşusu BÜTÜN adımlarını bitirmiş** — CI yeşilken
   TestFlight yüklemesi ya da `.aab` imzası ayrıca düşebilir.
2. **Android `.apk` ile tam tur** — dokuz PR'ın `mobile/TESTING.md`
   maddeleri. Sekiz PR (#565 #562 #579 #576 #554 #547 #601 #611) yalnızca
   ortak Dart kodu değiştiriyor, yani APK'da doğrulanan iOS'ta da doğrudur.
3. **iPhone'da (TestFlight) KISA kontrol — yalnızca #557 için:** #557
   APK'nın hiç taşımadığı iOS dosyalarına dokunuyor (`Info.plist` +
   `Runner.xcodeproj` → paket dili `tr`; `flutter_localizations` → iOS'ta
   metin seçme menüsünü Cupertino çiziyor). Uygulama açılıyor mu, metin
   seçme menüsü Türkçe mi, kısa bir duman turu. Tam listeyi iOS'ta
   TEKRARLAMA.

⚠ Sunucuya dayanan PR'larda (ör. #601 huni damgası) ilgili migration/Edge
Function'ın CANLIDA olduğunu da doğrula — istemci alanı gönderir, sunucuda
karşılığı yoksa sessizce düşer. Adım adım test listesi tur sonunda,
derleme hazır olunca verilecek.

⚠ **Ölçüm `main` = `3a55492`'ye ait.** `main` ilerlediyse sıra yeniden
ölçülmeli:

```
git fetch origin main $(for n in 547 554 557 562 565 576 579; do \
  echo "refs/pull/$n/head:refs/remotes/pr/$n"; done)
git merge-tree --write-tree --name-only origin/main refs/remotes/pr/<n>
```

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

✅ **KAPANDI 10 Eylül 2026 → ARŞİVDE** (`docs/decisions/roadmap-arsiv.md`,
aynı başlık; 24 Eylül 2026'da taşındı). Sayacın yeri, tester sayısının
nereden okunacağı ve kartın "12" tavanı orada.

## Sıradaki sürüme binecekler — `main`'de var, MAĞAZADA yok

⚠ **GÜNCELLEME (12 Eylül 2026, akşam): aşağıdaki üç satır ARTIK PAKETTE.**
PR #533'ün merge'i koşu **#665**'i tetikledi; `mobile-latest` ezildi ve
TestFlight'a 665 yüklendi. Kullanıcı kararı: **ASC'de her zaman son derleme
iliştirili olur, Play aynı numarayla takip eder** — ASC 665'e çekiliyor,
Play'e 13 Eylül'de 665'in `.aab`si yüklenecek. Kural ve aradaki pencerenin
riski: `mobile/docs/surumler.md` → "SÜRÜM SENKRONU". Senkron bitince bu
tablo yeniden BOŞALIR ve tur arşive taşınır.

⚠ **DURUM (12 Eylül 2026): 1.1.0 (659) SAHADA.** `7bccbf7` Play'in kapalı
testinde (Alpha) yayınlandı — gönderim ≤ 12:24, yayın ~13:42 (kullanıcı
bildirdi). Aynı kod App Store Connect'in 1.1.0 sürüm kaydında da iliştirili,
yani **iki mağaza ilk kez tek NUMARADA ve tek PAKETTE**. Turun tablosu
kuralı gereği aynı gün `docs/decisions/roadmap-arsiv-cilt-1.md` → **"1.1.0 sürüm
turu"**na taşındı (ROADMAP yalnızca AÇIK maddeleri tutar). Paket künyesi ve
sürüm notları: `mobile/docs/surumler.md` → "1.1.0 (659)".

⚠ **Liste yayın GÜNÜ yeniden doldu — üç satır** (aşağıda). 8 Eylül'ün
tıpatıp tekrarı: bu tablonun "boş" hâli bir DURUM değil, bir AN. Doğrulama
komutu (yayındaki paketin sha'sıyla):
`git log --oneline 7bccbf7..origin/main -- mobile/app mobile/kelimeki_core`

⚠ **`mobile-latest` her mobil derlemede ÜZERİNE yazılır** — sıradaki sürüm
adı Play'e yüklenene kadar `main`'e giren her mobil iş bu paketi de
değiştirir (1.0.4/467 dersi, arşivde). Yüklemeden önce indirdiğin `.aab`nin
derleme sha'sını `main`'in başıyla karşılaştır.

**Kapalı testteki paket:** 1.1.0 (659) = commit `7bccbf7` (#529),
12 Eylül 2026'da yayınlandı. Bir öncekisi: 1.1.0 (627) = `a4c809b` (#514).

**YAYINDAKİ PAKETTEN (659, `7bccbf7`) SONRA porta dokunan işler — sıradaki
sürümün içeriği:**

| Commit / PR | Ne | Neden porta dokunuyor |
|---|---|---|
| (12 Eyl) | **Oyun sonu kutlaması** — ilk galibiyet (girişli) / ilk puan + giriş çağrısı (misafir) | ⚠ **SÜRÜME BİNİYOR:** `util/onboarding.dart` · `storage/flags_store.dart` · `data/stats_api.dart` (`wins` alanı) · `ui/game/game_over_modal.dart` · iki oyun ekranı (+ web ikizi `utils/onboarding.ts` · `GameOver.tsx` · `App.tsx` · `OnlineGameScreen.tsx`). Karar saf fonksiyonda, İKİ dal AYNI şeyi ölçmüyor (girişli: GALİBİYET + hesabın `wins`i; misafir: PUAN + cihaz bayrağı) — gerekçe `docs/decisions/onboarding.md`. Kapılar: `npm run verify-tutorial-script` (dokuz vaka + CTA içermesi) · `tutorial_parity_test.dart` (metin paritesi); **846 test yeşil**. ⚠ Port farkı: portta oyun ekranından açılan giriş penceresi yok → misafir metni düz, web'de buton. Cihaz listesi `TESTING.md` §13.7 |
| (12 Eyl) | **Bağlamsal ipucu tavanı 2 → 1** (ipucu başına) | ⚠ **SÜRÜME BİNİYOR:** `util/onboarding.dart` (+ web ikizi `src/utils/onboarding.ts`). Kullanıcı kararı: *"İlk defa oynayan kişiye oyun sırasında çıkan max 6 gösterim iyi bir deneyim değil. Onu her bir mesaj için 1 kere olacak şekilde düzelteceğiz."* Üç ipucu × tavan 2 = **6 balon**du, artık en fazla **3**. Tavanın ipucu BAŞINA olması ve sıranın sabitliği (`vergi › carpan › bolge`) DEĞİŞMEDİ. Değer iki tarafta da sabitten okunuyor (testler/doğrulayıcı hard-code etmiyor), parite `tutorial_parity_test.dart` ile kilitli. Kapı: `npm run verify-tutorial-script` yeşil |
| (15 Eyl) | **YZ robot avatarı iPhone/iPad'de ortalı değildi** | ⚠ **SÜRÜME BİNİYOR:** `ui/game/player_avatar_row.dart`. Apple Color Emoji'nin mürekkebi kendi kutusunda ortalı değil (advance ≈ 1,26 em, mürekkep 1,0 em ve sola yaslı); `Container(alignment: center)` kutuyu ortalıyor, mürekkebi değil. Kullanıcının ekran görüntüsünden daire maskesiyle ÖLÇÜLDÜ, dört yalıtık robotta birebir: **yatay −0,131 em · dikey +0,083 em**. Telafi aynı değerin tersi, YALNIZCA Apple platformlarında (Linux/Noto ölçümü 0,00 em → Android'de sapma yok). Kapı: `avatar_emoji_nudge_test.dart` (3 test; ⚠ piksel ölçmez — cihaz maddesi `mobile/TESTING.md` §29). **858 test yeşil**. Web ikizi bilerek dışarıda (ölçülmedi, telafisi CSS'e girer). Kayıt: Parça 210 |
| (15 Eyl) | **App Store ürün sayfası dili "EN English" görünüyordu** | ⚠ **SÜRÜME BİNİYOR:** `ios/Runner/Info.plist` + `Runner.xcodeproj/project.pbxproj`. Apple bu satırı Connect'ten değil PAKETTEN okuyor (`CFBundleLocalizations`, yoksa `CFBundleDevelopmentRegion`); ikisi de `flutter create` varsayılanındaydı (`en`). Artık `tr`. ⚠ Yalnızca YENİ derleme işlenince etkisini gösterir; Connect'te tıklanacak düğme yok. ⚠ Uygulama İÇİ yerelleştirme ayrı iş ve AYNI GÜN yapıldı: `flutter_localizations` + `MaterialApp` delegeleri + `supportedLocales: [tr]` (Parça 209) — öncesinde metin seçme menüsü/semantik etiketler İngilizceydi; `GlobalCupertinoLocalizations` olmadan hata YALNIZCA iPhone'da görünürdü. Kapı: `test/localization_test.dart` (3 test, ikisi duyarlılık kanıtlı); **855 test yeşil**. Kayıt: Parça 208-209 + `marketing/app-store/console-formlari.md` §17 |
| (15 Eyl) | **Oyun ORTASINDA giriş: ad "Misafir" kalıyor + bulutta HAYALET "Devam Eden Oyun"** | ⚠ **SÜRÜME BİNİYOR:** `game/game_session_host.dart` (YENİ) + `ui/setup/setup_screen.dart`. Kullanıcı cihazda bildirdi (1.1.0/665, `Derleme 9c62289`): bitiş ekranı "Misafir" diyor, Setup'ta aynı oyun girişin yapıldığı ANIN skorlarıyla listede kalıyor. Kök sebep web'de VAR olan iki effect'in portta hiç yazılmamış olması (mid-game `RENAME_PLAYER` + autosave hedefinin `user`a bağlı olması); ayrıca Setup'ın auth dinleyicisi oyun ekranı açıkken `migrateGuestSave` koşturup ikinci satırı doğuruyordu (kapı: `_gameRouteOpen`). **Web'de değişiklik YOK.** Kapılar: `game_session_host_test.dart` (5 test) + `setup_screen_test.dart` → "oyun ekranı AÇIKKEN giriş… TEK bulut satırı"; duyarlılık iki yönde de kanıtlandı; **852 test yeşil**. Kayıt: Parça 207 + `docs/decisions/local-game-persistence.md`. Cihaz maddesi: `mobile/TESTING.md` §28 |
| (13 Eyl) | **Ham hata metinleri kullanıcıya gösteriliyordu** — `{"message":"Gateway Timeout"}` | ⚠ **SÜRÜME BİNİYOR:** yeni `util/error_message.dart` + sekiz çağrı yeri (`auth_modal` · `reset_password_modal` · `account_settings_modal` · `delete_account_modal` · `chat_modal` · `feedback_modal` · `online_game_screen` · `friends_api`) + `main.dart` (telemetri bağı). Kullanıcı App Store ekran kaydı çekerken giriş penceresinde YAKALADI. Web ikizi aynı PR'da (`src/utils/errorMessage.ts` + `api.ts`'te 45 satır `rethrowSupabase`e çevrildi — SQLSTATE yolda düşüyordu). ⚠ Sunucunun Türkçe redleri (P0001: "Sıra sende değil.") KORUNUYOR, en büyük regresyon riski oydu. Kapılar: `npm run verify-error-messages` (66 kontrol) · `error_message_parity_test.dart` (22 test); **868 test yeşil**. Kayıt: `docs/decisions/telemetry.md` → "Ham hata metni" |
| (12 Eyl) | Canlı oyunda rafın üstündeki **mesaj satırı yazı ölçeğinde kesiliyordu** | ⚠ **SÜRÜME BİNİYOR:** `ui/live/online_game_screen.dart` — `SizedBox(height: 30)` + `maxLines: 2` → `ConstrainedBox(minHeight: 30)`, `maxLines`/`ellipsis` kaldırıldı. Kullanıcı iPhone'da ekran görüntüsüyle bildirdi (2. satır yarım). ⚠ **Android'de de vardı** — dosya tek, `textScaler` iki platformda da sistemden geliyor. ⚠ **Aynı hata 2 Eylül 2026'da YEREL ekranda düzeltilmişti** (`game_screen.dart` + `message_line_test.dart`); Canlı ikizi o turda atlandı — kök `CLAUDE.md`'nin "ikisi deseni paylaşıyor" çiftinin bir kez daha kaçırılması. Web ikizi ZATEN doğruydu (`min-h-[30px]`, iki ekranda da), yani web'de değişiklik YOK. Kapı: `online_game_screen_test.dart` → "mesaj satırı ölçekte kesilmez" (ölçek 1,0 + `kMaxTextScale`), duyarlılığı kanıtlandı (+10 px ile düşüyor); **845 test yeşil**. Kayıt: Parça 203, cihaz maddesi `mobile/docs/testing-ux-turlari.md` §25 |
| (16 Eyl) | **Oyun bitiş telemetrisine `platform` damgası** | ⚠ **SÜRÜME BİNİYOR:** `data/games_api.dart` → `logGameFinish` artık `game_finishes`e `'platform': currentPlatform` yazıyor. Web yarısı + sunucu 16 Eylül'de `main`'e girdi (PR: admin paneli açılır tabloları); bu PR o işin **port ikizi** ve kullanıcı kararıyla AYRI bırakıldı — *"Mobile dokunma"*, inceleme dondurması sürüyor. Admin panelindeki "Oyun Sayısı" grafiğinin platform kırılımını (Web/iOS/Android/Diğer) besleyen tek alan — **bu PR merge edilene kadar app'ten biten her oyun "Diğer" kovasında görünür**, sunucu tarafı hazır olmasına rağmen. Kolon + geriye doldurma canlıda uygulandı (`20260916054513_game_finishes_platform`; geçmişin %71'i `games`ten kurtarıldı). Davranış değişikliği YOK, yeni izin/veri sınıfı YOK (`games.platform` aynı değeri zaten aylardır yazıyor). Kararlar: `docs/decisions/admin-panel.md` → "Açılır tablolar + üç grafiğin kaldırılması"; cihaz maddeleri `docs/testing-admin.md` §9.17 |
| (16 Eyl) | **Kayıt onayı: kırmızı uyarı BÜYÜK+kalın · onay linki pencereyi kapatıyor** — port yarısı | ⚠ **SÜRÜME BİNİYOR** (⛔ PR henüz merge EDİLMEDİ — Play production incelemesi/665 dondurması): `ui/auth/auth_modal.dart` (mesajın eylem cümlesi `Text.rich` ile kalın+BÜYÜK; `AuthService` dinleyicisiyle oturum açılınca pencere kendini `pop` ediyor) · `app/test/signup_test.dart` (İKİ yeni widget testi). **Web yarısı AYRI PR (#561) ve merge edildi**, yani hata web'de düzeldi, mobilde ancak bu sürümle düzelir. ⚠ Port farkı bilinçli: web'de pencere bir BİLEŞEN (efekt kapatıyor), portta bir ROTA — kapanma yalnızca *"oturum yokken açıldı"* geçişinde tetikleniyor (`_oturumVardi`), çünkü mount anında koşulsuz bir `pop` pencereyi değil SAYFAYI kapatırdı (widget testleri modalı doğrudan `Scaffold` gövdesine gömüyor). Duyarlılık kanıtlandı: dinleyici susturulunca yeni test düşüyor. Kayıt: Parça 211, cihaz maddesi `mobile/TESTING.md` §30 |
| (17 Eyl) | **504 geçici sunucu hatası yeniden denenir + oturum kapısı** | ⚠ **SÜRÜME BİNİYOR:** `util/offline_notice.dart` (`isTransientServerError`) + `data/online_games_api.dart` (`_fetchWithRetry` · `load()` rapor kapısı · gateway `hasValidSession`). Admin panelindeki `client_errors` yığılmasından çıktı: 62 kaydın 11'i `online_games_repo.load` → 504 (android 9 · ios 2, 8 cihaz). Sunucu ELENDİ (aynı RPC en ağır kullanıcıda 12,7 ms), kusur sınıflandırmadaydı — 504 taşıma kalıplarına uymadığı için tekrarlanmıyor ve telemetriye düşüyordu. İkinci iş: oturumu düşmüş istemcinin yetki hatası artık raporlanmıyor (web `reportLiveListError` paritesi); oturum VARKEN gelen aynısı raporlanmaya devam ediyor. Web yarısı 17 Eyl'de `main`'e girdi (#578). Kapı: `live_games_test.dart` dört yeni vaka, duyarlılığı kanıtlandı |
| (16 Eyl) | **Zoom tanıtım balonu 4 sn sonra kendi kendine kapanır** | ⚠ **SÜRÜME BİNİYOR:** `ui/game/board_zoom.dart` (`kZoomHintAutoHide`) + iki oyun ekranı (`game_screen.dart` · `online_game_screen.dart`). Oyuncu bildirdi: *"tanıtımdan sonra zoom özelliği için sürekli kalan uyarı mesajı oyun oynamayı zorlaştırıyor... 3-5 saniye sonra gidecek şekle getirelim. İnsanlar okumuyor."* Öncesinde balonu kapatan TEK şey zoom'u denemekti. ⚠ Kapanma **"denedi" SAYILMAZ** (`markZoomTried` çağrılmaz), yani tavan 2 kuralı DEĞİŞMEDİ — denemeyen oyuncu balonu ikinci açılışta yine görür. Web yarısı ayrı PR'da (`ZOOM_HINT_AUTO_HIDE_MS`, aynı gün `main`'e girdi); bu PR port ikizi ve inceleme dondurması yüzünden AYRI bırakıldı. Kapı: `zoom_hint_test.dart` → "balon KENDİ KENDİNE kapanır" (erken kapanmayı da ölçüyor) |
| (14 Eyl) | **Taş değiştirme sınırı: torbada kalandan fazlası değiştirilemez** — port yarısı | ⚠ **SÜRÜME BİNİYOR** (⛔ PR henüz merge EDİLMEDİ — mağaza incelemesi/665 dondurması): `kelimeki_core/lib/src/constants.dart` (`maxSwapCount` + `swapLimitMessage`) · `kelimeki_core/lib/src/engine/reducer.dart` (seçim anı + `_confirmSwap` ikinci kapısı + `_aiPlay` dilimi) · `app/test/swap_limit_parity_test.dart` (YENİ) · `kelimeki_core/test/run_all.dart` (`testSwapLimit`). Kullanıcı raporu (Asnmzr): torbada 4 taş kalmışken 7 taş değiştirilebiliyordu. ⚠ **Web + sunucu yarısı AYRI PR (#553) ve sunucu ZATEN CANLIDA** (migration `20260914152808` + `play-ai-turn` v10) — yani **Canlı oyun eski pakette bile doğru davranıyor, YEREL oyun ancak bu sürümle düzeliyor**. Golden vector'lar DEĞİŞMEDİ (mevcut senaryoların hiçbiri bu yola girmiyordu); Dart core 6883 → **6890** kontrol, duyarlılık düzeltme geri alınarak kanıtlandı (5 hata). Kayıt: Parça 206, cihaz maddesi `mobile/TESTING.md` §27 |
| (22 Eyl) | **Kaynak Hunisi'nde app görünür oldu** — huninin DÖRT adımı da damgalanıyor | ⚠ **SÜRÜME BİNİYOR:** `data/device_stamp.dart` (YENİ) · `data/visits_api.dart` (YENİ) · `data/games_api.dart` (`game_starts`/`game_finishes` artık `anon_id`+`utm_source` yazıyor) · `data/auth_service.dart` (kayıtta `utmSource`) · `bootstrap.dart` · `ui/app.dart`. Kullanıcı bildirdi (*"bilinmeyen 1, üye 20 — %2000 conversion not possible"*) ve asıl işi istedi: *"Kaynak belliyse onun altına girecek… bilinmemesi mümkün olmamalı çünkü ya web'den direkt gelmiştir ya da app'den"*. Öncesinde port dört adımın HİÇBİRİNDE damgalamıyordu; app'in tabloya kattığı tek şey 20 damgasız üyeydi. Kaynak `'app'` (deep link'ten gerçek `?ref=` gelirse O kazanır). Web ikizi bu PR'dan DÜŞTÜ: #625 (24 Eyl) `app`i zaten **Mobil Uygulama** kanalına eşliyor ve huniyi Üye Kalitesi kohortuna indirdi; port damgası olmazsa yeni app kayıtları orada `Bilinmiyor`a düşer. Sunucu: `20260922070950_guest_visits_app_rows_out_of_web_breakdowns` CANLIYA UYGULANDI (app satırları web'e özgü iki dökümden eleniyor). ⚠ Gizlilik metni değişmedi — zaten platform-nötr kapsıyor (gerekçe: `docs/decisions/admin-panel.md`). Kapı: `test/source_stamp_test.dart` (9 vaka). Cihaz maddesi `mobile/TESTING.md` §32 |
| (23 Eyl) | **iPad yatayda filigranlar tahtadan taşıyordu** (köşe rakamı + "X2") | ⚠ **SÜRÜME BİNİYOR:** `ui/game/board_widget.dart` — punto ekran genişliğinden geliyordu, iPad yatayda tahta YÜKSEKLİĞE sığdırıldığı için punto tavanda (220/165) kalırken tahta küçülüyordu. Punto artık tahtanın kendi genişliğiyle de sınırlı (oran web'in 320 px'teki oranı: 0,371 / 0,279), telefonda tavan devreye girmiyor → web paritesi aynen. Web ikizi #609'da CANLIDA (taşma web'de görülmüştü: ana ekran uygulaması, iPad yatay). Portta bugün tahta yalnızca genişlikten boyutlandığı için etkisi Split View'le sınırlı; asıl işlevi **#26'nın (yükseklik bütçesi) ön koşulu** olmak. Kapı: `board_render_test.dart` → "filigran tahtadan taşmaz — iPad yatay" (düzeltme olmadan düşüyor); **847 test yeşil** |
| (25 Eyl) | **Sürüm 1.1.1 — App Store'un 1.1.0 treni KAPANDI** | ⚠ **SÜRÜME BİNİYOR (ve sürümün KENDİSİ):** `app/pubspec.yaml` (`1.1.0+1` → `1.1.1+1`) + `lib/src/config/env.dart` (`appVersion`). Kod değişikliği YOK, davranış değişikliği YOK. Dondurma kalkıp altı port PR'ı merge edilince `mobile-build.yml` **altı koşu üst üste düştü** (#698 · #700 · #702 · #704 · #706 · #708) ve hiçbiri ayrıca bildirilmedi: düşen adım `iOS (imzasız)` işinin EN SONUNCUSU (*"TestFlight'a yükle"*), ondan önceki her şey — Android `.apk`+`.aab`, `mobile-latest`, Appetize, Pages, imzalı `.ipa` — yeşil tamamlanıyor. Apple'ın reddi: **90186** (*train '1.1.0' is closed for new build submissions*) + **90062** (*CFBundleShortVersionString must be higher than the previously approved version*). Yani sebep 1.1.0'ın 15 Eylül'de YAYINLANMASI; `--build-number` artırmak YETMEZ (o `CFBundleVersion`). Kapı `app_version_parity_test.dart` iki dosyanın ayrışmasını düşürür (duyarlılık kanıtlandı); **891 test yeşil**, `flutter analyze` temiz. Kayıt: `mobile/docs/surumler.md` → "1.1.0 TRENİ KAPANDI" + `mobile/CLAUDE.md` |

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
`docs/decisions/roadmap-arsiv-cilt-1.md` → "1.0.7 sürüm turu".

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
`docs/decisions/roadmap-arsiv-cilt-1.md` → "Temizlik geçişi"nin ardındaki bölüm.

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

### 19-20. `anon` telemetri yazımı · `CRON_SECRET` fail-open — ✅ **ÖLÇÜLDÜ, KABUL EDİLDİ → ARŞİVDE**

İkisi de "ölçüldü, risk düşük, bilinçli olarak kabul edildi" diye kapandı;
tam ölçümler (tablo hacimleri, hangi RPC'nin `count(distinct)` kullandığı,
üç cron fonksiyonunun atomik iddia koruması) **arşivde**, başlıkları AYNEN:
`docs/decisions/roadmap-arsiv.md` → *"19. `anon` için sınırsız telemetri
yazımı"* · *"20. `CRON_SECRET` fail-open"*.

⚠ Kabul kararının iki koşulu orada yazılı ve bu geçiş bir daha açılırsa
önce onlar okunmalı: limit gerekirse IP'ye DEĞİL `anon_id`'ye anahtarlanır;
`CRON_SECRET` bir gün tanımlanırsa koddaki `if (CRON_SECRET && ...)`
satırlarına "koruma iddia sütunlarından geliyor" notu düşülmeli.

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
listeleri ve dersleri — `docs/decisions/roadmap-arsiv-cilt-1.md`'ye taşındı;
başlıklar ("Hata avı geçişi — KAPANDI", "Performans geçişi — KAPANDI",
"Temizlik geçişi — KAPANDI") değiştirilmedi. Yukarıdaki geçiş tablosu canlı
indeks olarak burada kaldı. **Dört geçiş de kapandı**; incelemeden açık
kalan tek şey güvenlik geçişinin yukarıda duran maddeleri — 15 Eylül
2026'dan beri **18, 21 ve 22** (19 ve 20 ölçülüp kabul edildi, arşive
taşındı).

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

**Durum eki (13 Eylül 2026, 00:14):** Bu fazın takvimini belirleyen kısıt
— aşağıdaki "12 tester × 14 gün" — **tamamen kapandı**: production erişimi
onaylandı (`console-formlari.md` §7). Fazın kalanı artık takvim değil karar
işi: 665 paketi hangi kanala yüklenecek (kapalı test ↔ production) ve
production sürümünün kendi incelemesi.

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
   SAHADA 1.0.3 ile). Madde arşivde: `docs/decisions/roadmap-arsiv-cilt-1.md` →
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

## 30. Port anonim cihaz damgası (`anon_id`) — **AÇIK, ölçüldü** (15 Eylül 2026)

Kullanıcı admin panelindeki Tanıtım Turu kartına bakıp sordu: *"Sanki
sadece parantez içindeki rakamlar artıyor"*. Doğruydu ve sebebi tek satır:
port `anon_id` YAZMIYOR (`mobile/app/lib/src/data/games_api.dart` →
`tutorial_events` ve `game_starts` insert'lerinde `'anon_id': null`).
`count(distinct anon_id)` NULL saymaz, yani BENZERSİZ CİHAZ sayan her
sütun yalnızca web'i görüyor. Canlıdan ölçüldü (son 30 gün):

| Tablo | Uygulamadan gelen satır (`anon_id` NULL) | Web |
|---|---|---|
| `tutorial_events` | 24 (hepsi iOS) | 7 |
| `game_starts` | **618** (`android` 587 · `ios` 16 · `app-web` 15) | 993 |

**Yarısı 15 Eylül'de kapatıldı (web tarafı):** Tanıtım Turu kartının oranı
CİHAZ paydasından ADET paydasına çevrildi — kart %85 yerine %50 yazıyordu.
Ayrıntı: `docs/decisions/admin-panel.md` → "Tanıtım Turu kartı". Bu bir
yama; ölçümün kendisi hâlâ eksik.

**Kalan iş (port):** web'in `src/utils/visitTracking.ts` damgasının ikizi —
cihazda saklanan rastgele bir uuid üretilip `tutorial_events` ve
`game_starts` satırlarına yazılsın.

- **Gizlilik kapsamı ZATEN var:** `PrivacyModal` bölüm 6 anonim cihaz kodunu
  tarif ediyor (*"hesabınızla ASLA eşleştirilmez"*), yani yeni bir veri
  TÜRÜ değil — web'de var olanın portta da yazılması. ⚠ `user_id` ile aynı
  satıra KOYMA; tabloların ikisinde de böyle bir kolon yok ve olmayacak.
- **Nerede saklanacağı bir karar:** uygulama silinip yeniden kurulunca
  sıfırlanan bir yer (uygulama dizini) mi, yoksa kalıcı (Keychain) mi?
  Web'de `localStorage`, yani "tarayıcı verisi silinene kadar" — porta en
  yakın karşılığı uygulama dizinidir. Keychain iOS'ta kurulumlar arası
  YAŞAR ve bu, gizlilik metninin vaat ettiğinden daha kalıcı bir kimlik
  üretir; bilerek seçilmediyse ALMA.
- ⚠ **`mobile/app/**` değiştirir → merge mobil derlemeyi TETİKLER**
  (`mobile-latest` ezilir, TestFlight'a build gider). Sürüm dondurması
  bitmeden başlama.
- **Kapandığında geri alınacak yama:** Tanıtım Turu kartının oranı cihaz
  paydasına dönebilir (adet paydası, aynı cihazda iki kez açıp bir kez
  bitireni oranı düşürerek cezalandırıyor). Dönülürse
  `docs/decisions/admin-panel.md`, `docs/decisions/onboarding.md` ve
  `docs/testing-admin.md`'deki üç not birlikte güncellenmeli.

**Saha kanıtı (20 Eylül 2026) — eksiklik bir vakada ISPATLANDI.** Bir
oyuncunun "misafir oynadı → üye olmayı denedi" hunisi elle, zaman damgası
eşleştirerek kurulmak zorunda kaldı: iOS'ta 01:02 `tutorial start`
(`src=auto`, yani sıfırdan kurulum) · 01:05 `game_starts`
(`is_guest=true`) · 01:24 ve 01:27 iki kayıt denemesi. Dört satırı bağlayan
tek şey ZAMANDI — `anon_id` dördünde de NULL olduğu için sorgu kurulamadı,
çıkarım elle yapıldı ve KANIT değil KARİNE. Vakanın tamamı #32'de.

---

## 32. E-posta onayı bir kullanıcı kaybı kapısı — **AÇIK, iki saha vakası** (20 Eylül 2026)

Kullanıcı: *"İnsanlar burada bounce ediyor, bu işi bir daha düşünmek
lazım."*

**İki vaka, ikisi de aynı gün konuşuldu:**

1. Kullanıcının bir arkadaşı kaydolup onay beklemede kalmış; şahsen
   hatırlatılınca *"Aa onay mı gerekiyordu"* demiş. Yani mail kutuya DÜŞTÜ,
   kişi ne yapması gerektiğini bilmedi.
2. 20 Eylül gecesi bir oyuncu (iOS, `1.1.0`) üç dakika arayla **İKİ** hesap
   açtı, ikisi de onaysız kaldı. İkincisinin adresi `…@icloid.com` —
   `icloud.com`un yazım hatası, yani o hesaba onay maili de 20. saatteki
   hatırlatma da **hiç ulaşmayacak**, hesap 48. saatte sessizce silinecek.
   Zaman çizgisi: 01:02 `tutorial start` (`src=auto`, sıfırdan kurulum) ·
   01:05 misafir oyun · 01:24 ve 01:27 iki kayıt · 02:19 yine misafir oyun.
   **Kişi uygulamayı bırakmadı, HESABI bırakamadı.**

### Ölçüm — ve ölçümün kör noktası

| | |
|---|---|
| Toplam hesap (28 Haziran 2026'dan beri) | 64 |
| Onaylamış | 62 — **60'ı ilk 5 DAKİKA içinde** |
| 1 saatten sonra onaylamış | 1 |
| Şu an onaysız | 2 (yukarıdaki vaka) |

İlk satırın dersi: onay ya **hemen** oluyor ya hiç. "Sonra hallederim" diye
bir davranış YOK; pencere dakikalarla ölçülüyor. Metni büyütmek bu yüzden
tek başına yetmiyor — kullanıcı o dakikaların içinde kayboluyor.

⚠ **Gerçek kayıp oranı BİLİNMİYOR ve bugünkü şemayla BİLİNEMEZ:**
`sweep-unconfirmed-accounts` 48. saatte hesabı SİLİYOR, yani "kaydoldu, hiç
onaylamadı" nüfusu kanıtıyla birlikte yok oluyor. 64 sayısı hayatta
kalanlar; ölenler hiçbir yerde sayılmıyor. **Hiçbir alternatifin işe
yarayıp yaramadığı, A yapılmadan ölçülemez.**

### Bugün ne var

Web'de kalın+BÜYÜK uyarı (#561, canlıda) · portta hâlâ eski sessiz satır
(#562, dondurulmuş PR) · 20. saatte tek seferlik hatırlatma · 48. saatte
silme. İlk ikisi METİN: vaka 1 metnin yetmediğini gösteriyor (kişi maili
gördü, yine de bilmedi), vaka 2 ise metnin hiç okunamadığı bir yol.

### Alternatifler

| # | Ne | Kazanç | Bedel / risk |
|---|---|---|---|
| **A** | **Ölçümü aç** — `sweep` silmeden ÖNCE anonim bir sayaç satırı yazsın (kayıt anı, platform, hatırlatma gitti mi) | Kayıp oranı nihayet SAYIYLA bilinir; sonraki her kararın öncesi/sonrası olur | Küçük migration + Edge; `mobile/` DIŞI → **dondurmayı beklemeden bugün yapılabilir** |
| **B** | **Yazım hatası denetimi** — `icloid→icloud`, `gmial→gmail`, `hotmial→hotmail`…; "Bunu mu demek istediniz?" tek dokunuşla düzeltme | Vaka 2'yi tamamen keser; sessiz bounce sınıfını kapatır | Saf istemci, sunucu DEĞİŞMEZ. Web + port ikizi |
| **C** | **Kayıt sonrası "bekleme odası"** — pencere kapanıp kullanıcıyı yalnız bırakmasın: adresi EKRANDA göster + "Maili aç" + "Yanlış adres mi? Değiştir" + "Tekrar gönder" (60 sn sayaç) + spam uyarısı | Vaka 1'in tam ilacı: ne yapılacağı, kullanıcı kapatana kadar ekranda DURUR. Adres ekranda olduğu için vaka 2'yi de yakalar | Orta: akış değişikliği, web + port |
| **D** | **Link yerine 6 haneli KOD** (Supabase email OTP) | En büyük kazanç: kullanıcı UYGULAMADAN ÇIKMIYOR. Mobilde link→tarayıcı→uygulama dönüşü zaten kırılgan (#562'nin ikinci hatası tam buydu). Kod gelmezse kişi hâlâ orada ve adresi düzeltebilir | Kayıt akışının yeniden yazımı (web + port) + Supabase şablonuna `{{ .Token }}`. **Doğrulama KORUNUR** |
| **E** | **Onaysız direkt üyelik** (`Confirm email` KAPALI) — kullanıcının önerisi | Kapı tamamen kalkar, bu kayıp sıfırlanır | ⚠ Aşağıda ayrı |
| **F** | **Yumuşak onay** — hesap hemen açılır, ama onaylanana kadar **hiçbir bildirim maili gönderilmez** ve uygulamada küçük kalıcı bir "E-postanı doğrula" şeridi durur | E'nin kazancını verir, E'nin en pahalı riskini (bounce) ALMAZ | Mail gönderen HER yola bir kapı; `sweep` yeniden yazılır (artık silme yok) |
| **G** | **#17 Google ile giriş** (zaten ertelenmiş) | Onay adımını tamamen atlar — Google adresi doğrulanmış verir | Ayrı ve büyük iş; bu vaka onun ÖNCELİĞİNİ yükseltiyor |

### E'nin (onaysız direkt üyelik) bedeli — seçilecekse BİLEREK seçilsin

- **Yanlış adres = kurtarılamayan hesap.** Parola sıfırlama tek kanal;
  `icloid.com` yazan kişi cihaz değiştirdiğinde hesabını SONSUZA DEK
  kaybeder. Bugün o hesap 48 saatte siliniyor ve kişi yeniden kaydolabiliyor
  — yani bugünkü "sertlik" aynı zamanda bir emniyet kemeri.
- **Bounce itibarı.** Proje çok mail atıyor (sıra bildirimi, arkadaşlık,
  süre uyarısı, k-lig). Doğrulanmamış adreslere gönderim Brevo'da sert
  bounce üretir ve bu **GERÇEK adreslere teslimatı da bozar** — teslimat bu
  projede bir kez zaten kırıldı (`docs/decisions/supabase-ops.md`).
  **F bu riski kapatıyor, saf E kapatmıyor.**
- **Başkasının adresiyle kayıt** mümkün hale gelir: lider tablosunda görünen
  bir takma ad + o adrese giden bildirimler.
- **`sweep-unconfirmed-accounts` anlamını yitirir** — takma ad ve e-posta
  serbest bırakma mekanizması baştan tasarlanmalı.

### Öneri (sıra)

1. **A + B önce.** İkisi de ucuz ve geri alınabilir; A olmadan sonraki
   adımların işe yarayıp yaramadığı ölçülemez. A tamamen `mobile/` dışında,
   yani **dondurma sürerken bile yapılabilir**; B'nin port ikizi dondurma
   sonrasına kalır.
2. **Sonra C** — akışın omurgasını değiştirmeden en çok kazandıran adım.
3. **D ya da F bir SEÇİM, ikisi birden gerekmiyor:** doğrulamayı KORUMAK
   istiyorsan D, kapıyı KALDIRMAK istiyorsan F. Saf E (F'siz) önerilmiyor —
   yukarıdaki bounce zinciri yüzünden.
4. **G** kendi sırasında; bu madde onun gerekçesine bir satır ekliyor.

### Dondurma uyumluluğu — `mobile/` dosyası ≠ sahadaki davranış

⚠ **"Mobile dokunuyor mu" sorusunun İKİ ayrı cevabı var** (20 Eylül 2026,
kullanıcı sordu ve ilk cevap eksikti):

1. `mobile/` altında **dosya** değiştirmek → merge `mobile-build.yml`'i
   tetikler (`mobile-latest` ezilir, TestFlight'a build gider).
2. Sahadaki paketin **DAVRANIŞINI** değiştirmek → tek satır mobil kod
   değişmeden de olur, çünkü **Supabase Auth ayarları anında canlıdır**
   (bkz. "Deploy Doğrulaması", üçüncü satırın tersine tuzağı).

| | `mobile/` dosyası | Sahadaki paketi etkiler | Dondurma sırasında |
|---|---|---|---|
| **A** ölçüm | yok (migration + Edge) | hayır | ✅ serbest |
| **B** yazım hatası denetimi | **web yarısı yok** | hayır | ✅ web yarısı serbest |
| **C** bekleme odası | **web yarısı yok** | hayır | ✅ web yarısı serbest |
| **D** 6 haneli kod | web yarısı yok; şablon ORTAK | 🟡 kuruluşa bağlı | 🟡 koşullu |
| **E** onaysız üyelik | **yok** | ⛔ **EVET, anında** | ⛔ |
| **F** yumuşak onay | **yok** | ⛔ **EVET, anında** | ⛔ |
| **G** Google girişi | var (SDK) | — | ⛔ |

⚠ **Ters sürpriz: E ve F `mobile/` altında HİÇBİR dosyaya dokunmuyor ama en
riskli olanlar.** `Confirm email` anahtarı global; kapatıldığı anda App
Store'daki `1.1.0` paketi de etkilenir ve o paket buna hazır DEĞİL:
`signUp` artık oturum döndürür (kullanıcı anında girmiş olur), ama sahadaki
uygulama ekrana hâlâ *"Hesap oluşturuldu. E-postanı doğrulayıp giriş yap."*
yazar **ve pencere kendini kapatmaz — çünkü onu kapatan düzeltme #562'de,
yani hâlâ dondurulmuş.** Sonuç: giriş yapmış kullanıcı, "e-postanı doğrula"
diyen açık bir pencereye bakar. **E/F, #562 SAHAYA İNMEDEN açılmaz.**

⚠ **D'nin koşulu daha yumuşak:** Supabase şablonu `{{ .ConfirmationURL }}`
ile `{{ .Token }}`'ı BİRLİKTE taşıyabilir. Şablona kod eklenirse link
çalışmaya devam eder → sahadaki paket eski yolundan (link) gider, web yeni
kod kutusunu kullanır; kademeli ve geriye uyumlu. **Şablondan link
KALDIRILIRSA sahadaki paketin onay yolu kopar.**

### Karar: ERTELENDİ (20 Eylül 2026)

Kullanıcı: *"Şu anda mobilde 7 update var. Bu zaten oldukça fazla. Roadmap'e
yaz, daha sonra bakalım."* — yani A/B/C dondurma sırasında teknik olarak
mümkün olsa da **açılmıyor**: bekleyen yedi port PR'ı (#547, #554, #557,
#562, #565, #576, #579) zaten bir merge turu ve bir sürüm borcu demek,
üstüne yeni bir akış işi eklemek kuyruğu uzatır. **Tetikleyici:** yedi PR'ın
merge turu kapanıp sürüm sahaya indikten sonra bu madde yeniden açılır ve
sıra A → B → C olarak yürür. O turun ölçülmüş merge SIRASI yukarıda:
"Dondurulmuş port PR'ları — merge turu SIRASI".

⚠ **Hepsi kayıt akışına dokunuyor** → `TESTING.md` ve `mobile/TESTING.md`'nin
kayıt onayı maddeleri aynı PR'da güncellenir. ⚠ **C/D/F portu değiştirir →
merge mobil derlemeyi TETİKLER** (`mobile-latest` ezilir, TestFlight'a build
gider); sürüm dondurması bitmeden başlama.

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
başlangıç kiti `docs/decisions/roadmap-arsiv-cilt-1.md` → *"23 · Plan gövdesi"*ne
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

---

## 26. Web'den mağazalara yönlendirme — **APPLE YARISI ✅ (15 Eyl) · ANDROID YARISI ✅ · PWA kutusu KALDIRILDI (24 Eyl 2026) · manifest satırı AÇIK**

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

⚠ **13 Eylül 2026, 00:14 — Play production ERİŞİMİ onaylandı, ama bu
maddeyi AÇMADI.** Onay, production kanalını kullanma hakkı; vitrin adresi
o kanala bir sürüm yayınlanıp incelemesi bitene kadar 404 kalmaya devam
ediyor. Android yarısının tetikleyicisi bu yüzden aşağıda düzeltildi.

**Ama madde artık YAKIN:** aynı gün kullanıcı 665'i **doğrudan
production'a** yüklemeye karar verdi (`console-formlari.md` §7.5). Yani
Android yarısının kapısı bir sürüm incelemesi kadar uzakta — Apple yarısı
da 1.1.0'ın ASC incelemesini bekliyor. **İki yarı aynı hafta içinde
açılabilir**, o yüzden §26'yı tek turda yapmaya hazır ol.

⚠ **İKİ TUR OLACAK, tek seferde bitmez** — **ama sıra tersine dönebilir**
(12 Eylül 2026): App Store'a 1.1.0 (665) o gün gönderildi (inceleme ≤48
saat) ve kullanıcı kararı *"Apple önce gelirse direkt yayına alırız"*;
Play'in production ERİŞİM başvurusu ise hâlâ Google'da (10 Eyl, ≤7 gün) ve
onay gelse bile production sürümünün kendi incelemesi var. Yani ilk turun
Apple yarısı olması artık daha olası — hangisi önce açılırsa o yarısı
yapılır.

### Tetikleyici

**Yayınlanmış** bir Play production sürümü (vitrin adresi 404 vermeyi
bıraktığında — ÖLÇ, varsayma) → Android yarısı. App Store yayını → Apple
yarısı.

✅ **15 Eylül 2026 — APPLE YARISI YAPILDI.** 1.1.0 (665) onaylandı, yayın
başlatıldı ve rozet siteye kondu. **Vitrinin açıldığının kanıtı:** Apple'ın
Marketing Tools akışı bu uygulama için ilerledi ve rozeti/linki üretti —
10 Eylül'de aynı akış yayında olmayan uygulamada DURUYORDU, yani ilerlemesi
ölçümün kendisi. (⚠ Ajan doğrudan ölçemez: `apps.apple.com`,
`itunes.apple.com` ve `tools.applemediaservices.com` agent proxy'den **403**
dönüyor; yalnız `developer.apple.com` erişilebilir.)

Girilenler: `public/app-store-badge.svg` (Türkçe SİYAH, künye
`..._Badge_TR_blk_...`) + `storeLinks.ts`'te ülkesiz adres. ⚠ Bu tur
**dokümante edilmiş bir kuralın çiğnendiğini ortaya çıkardı** — eşit
yükseklik hizalaması Google'ın "same size or larger"ını bozuyordu, çünkü
Apple'ın oranı `~3.0` diye VARSAYILMIŞTI ama Türkçe rozet **3.78:1**.
Hizalama genişliğe çevrildi, kapı iki dosyayı da okuyacak şekilde yeniden
yazıldı. Ayrıntı: `src/utils/storeLinks.ts`.

**✅ ANDROID YARISI YAPILDI (24 Eylül 2026)** — Play production #19
(1.1.0/665) 17:44'te yayında; vitrin gizli sekmede açıldı, *Erken Erişim*
etiketi yok (kullanıcı ölçtü, bu ortamın vekili Play'i engelliyor).
`googlePlay.url` dolduruldu: rozet App Store'un yanına geldi, Android'de
üstteki mağaza şeridi çıkıyor ve aşağıdaki `AddToHomeScreen` satırının
Android yarısı AYNI PR'da yapıldı (`decideAppPromo`). Pixel 7
emülasyonunda ölçüldü: şerit 1, PWA kutusu 0, iki rozet 166 px genişlikte
(Apple 44 · Play 49 px yükseklik). Kayıt:
`mobile/docs/surumler/gonderimler-ios.csv` satır 12-13.

⚠ **Ve ölçümü KENDİ Play hesabınla yapma** (13 Eyl 2026, yaşandı): geliştirici
`Kelimeki Testers` listesinde olduğundan Play ona her hâlükârda bir liste
gösteriyor — *(Erken Erişim)* etiketiyle, arama sonucunda, yüklü rozetiyle.
#19 incelemedeyken tam bu görüldü ve "yayınlandı" sanıldı. Doğru ölçüm
OTURUM AÇMADAN: gizli sekme, ya da testçi olmayan biri. Vaka:
`marketing/play-store/console-formlari.md` §7.5.

⚠ **Ajan İKİ vitrini de ölçemez** (13 Eyl 2026): oturumun ağ politikası
`play.google.com`'a **ve** `apps.apple.com`'a `CONNECT` 403 veriyor,
`kelimeki.com` ise 200 — yani engel siteye özel, ağ genel olarak açık.
Yani maddenin HER İKİ yarısını da açan bilgi KULLANICIDAN gelir; "curl
ile bakarım" diye söz verme. (Apple yarısı ayrıca `id6809809788` ile
denendi, aynı 403.)

⚠ Bu satır 13 Eylül 2026'da düzeltildi; önce *"Play production onayı
(e-posta `destek@kelimeki.com`'a düşecek) → Android yarısı"* diyordu.
E-posta 13 Eyl 00:14'te geldi ve tetikleyici sanılıp madde açılabilirdi —
ama onay ERİŞİM verir, vitrin açmaz. Doğru kapı yayınlanmış sürümdür.

### ✅ İSKELET KURULDU (14 Eylül 2026)

İlk iki parça YAPILDI ve `main`'de; bugün ekranda hiçbir değişiklik YOK
(iki URL de `null`, `StoreBadges` `null` dönüyor). Rozeti GÖSTERMEK için
yapılacak tek şey `src/utils/storeLinks.ts`teki `null`u gerçek adresle
değiştirmek.

⚠ **Ama "tek satır" maddeyi KAPATMAZ.** Aynı gün yapılan ölçüm (aşağıda,
`AddToHomeScreen` satırı) rozetin tek başına yayınlanmasının çelişkili bir
ekran ürettiğini gösterdi: "ana ekrana ekle" şeridi footer'ın üstüne binen
bir katman ve Android'de rozetle aynı anda görünüyor. Yani URL'yi doldurmak
ile maddeyi kapatmak AYNI ŞEY DEĞİL — ikisi birlikte gitmeli.

**Yerleşim ÖLÇÜLDÜ** (14 Eylül 2026, 390×844, üretim derlemesi, URL geçici
doldurulup gerçek Setup ekranında): rozet **44 × 148,4 px** · rozet altı →
hukuki satırın kutusu **12 px** · rozet altı → **görünür metin 28,5 px** ·
şart (yükseklik/4) **11 px**. İkisi de şartın üstünde; aradaki fark
hukuki butonların `min-h-[48px]` dokunma hedefinden geliyor (kutu erken
başlıyor, yazı aşağıda).

⚠ **Play rozeti ELDE** (`public/google-play-badge.svg`, kullanıcı indirdi):
Türkçe · siyah · gri kenarlık yerinde · `<text>` yok (path'e çevrilmiş) ·
5.480 bayt · oran 3.37:1. Render edilip gözle doğrulandı.
**Apple rozeti HÂLÂ YOK** — Marketing Tools yayında olmayan uygulamada
ilerlemiyor (10 Eylül ölçümü); o yarı yayını bekliyor.

⚠ **Yerleşim kuralları artık İKİ KAYNAKTAN da doğrulandı** (14 Eylül 2026):

| Kural | Kaynak |
|---|---|
| App Store **ilk** (solda) | Apple, yazılı: *"Place the App Store badge first in the lineup of badges."* |
| Play rozeti **aynı boy ya da daha büyük** | Google, yazılı: *"make sure the Google Play badge is the same size or larger"*. ⚠ 24 Eyl 2026: iki rozet **eşit YÜKSEKLİKTE** (kullanıcı: *"Aynı boy olmaları gerekmiyor mu?"*); "size" yükseklik olarak okunuyor, genişlikte Play ~%11 dar. 15-24 Eyl arası eşit genişlikti. Gerekçe `storeLinks.ts` |
| Clear space = yüksekliğin **1/4**'ü | İKİSİ DE aynı sayıyı veriyor |
| Ekranda min **40 px** | Apple |

⚠ **Görünürdeki çelişki GERÇEK DEĞİL:** Google'ın kılavuzundaki örnek
görselde Play SOLDA duruyor, ama o bir ÖRNEK — Google'ın metni sıra
hakkında hiçbir şey söylemiyor. Apple'ınki açık bir kural, sıra ona göre.
Bu tuzağa düşülmesin diye `npm run verify-store-badges` sırayı KİLİTLİYOR
(duyarlılığı kanıtlandı: sıra ters çevrildiğinde 3 kontrol düşüyor).

⚠ **Rozet SVG'leri DOM'a INLINE EDİLMEZ, `<img>` ile çizilir.** Illustrator
ihracatları `<style>` içinde `.st0`/`.st1` gibi jenerik sınıflar taşıyor
(elimizdeki Play dosyasında da var) ve inline SVG'nin CSS'i sayfa geneline
sızıyor — Apple'ın dosyası da aynı adları taşıyacağından ikisi inline
edilirse renkleri birbirini ezer.

### Kalan yapılacaklar
| ✅ ~~**Yayın gelince: `storeLinks.ts`'te `null` → URL**~~ (App Store 15 Eyl · Play 24 Eyl) | ⚠ Ölçüt "onay geldi" ya da Console'un "Active"i DEĞİL, vitrinin 404 vermeyi bırakması — ve ölçüm OTURUM AÇMADAN (gizli sekme). `verify-store-badges`in "bugün hiçbir rozet çizilmiyor" satırı o an bilerek DÜŞER, bakanı uyarır |
| Apple rozet dosyası (`public/app-store-badge.svg`) | Yayından sonra Marketing Tools'tan; yedek yol 336 MB arşivden yalnızca Türkçe SİYAH dosya |
| `AddToHomeScreen.tsx` platforma göre dallansın | ✅ **ANDROID YAPILDI (24 Eyl 2026):** karar tek saf fonksiyonda (`decideAppPromo`, `storeLinks.ts`) — Android tarayıcıda Play yayındaysa PWA kutusu ÇEKİLİR, yerine üstteki mağaza şeridi çıkar; kapı `verify-store-badges`. ✅ **iOS DE YAPILDI, üstelik kutu TAMAMEN kaldırıldı (24 Eyl 2026 akşam, kullanıcı: *"Ios'da da çıkmamalı, sadece app store çıkmalı… tamamen kaldırmak gerekir"*):** `AddToHomeScreen.tsx` silindi, masaüstü dahil; telefonda (tarayıcı + standalone) tek çağrı `AppStoreStrip`, `decideAppPromo` da gereksiz kaldığı için silindi. Eski açık soru: App Store yayında olduğu hâlde iOS tarayıcısında PWA kutusu hâlâ çıkıyor (Safari'nin Smart App Banner'ı üstte, yani iki zıt çağrı); bilerek dokunulmadı, çünkü Smart App Banner uygulama-içi tarayıcılarda (WhatsApp/Instagram) çizilmiyor ve orada şerit mi kutu mu sorusu ayrı. Eski metin: **Asıl iş burada.** Bugün `detectPlatform()` zaten `ios`/`android`/`other` ayırıyor ama üçü de aynı PWA talimatına düşüyor. Mağaza yayındaysa o platform mağazaya, değilse bugünkü PWA şeridine düşmeli — hiçbir aşamada boş ekran olmamalı. ⚠ **14 Eylül 2026'da ÖLÇÜLDÜ ve gerekçe somutlaştı:** şerit `fixed bottom-4 … z-[60]`, yani sayfa akışında DEĞİL — footer'ın üstüne biniyor ve hukuki satır ile `© Kelimeki`yi ÖRTÜYOR (390×844'te üretim derlemesinde görüldü). Bu bugün de böyle, rozetten bağımsız; ama rozet çıkınca Android kullanıcısı aynı anda **hem** *"ana ekrana ekle"* şeridini **hem** Play rozetini görecek — biri PWA'ya, öteki mağazaya, üstelik üst üste. Yani bu madde rozetlerle birlikte açılmalı, sonraya bırakılırsa çelişkili bir ekran doğar |
| iOS Smart App Banner | ✅ **YAPILDI (19 Eyl 2026)** — `index.html`e eklendi. Koşulu (App Store'da yayında olmak) 15 Eylül'de §24 kapanınca sağlanmıştı ama madde dört gün açık kaldı; tetikleyen şey davetle gelen gerçek bir oyuncunun web'de oynayıp ayrılması oldu (`platform='web'`, push token yok). ⚠ Yalnızca iOS **Safari**'de çıkar — WhatsApp/Instagram'ın uygulama-içi tarayıcılarında ÇİZİLMEZ ve davet linkleri tam da oradan açılıyor; bu yüzden `/davet/:token` sayfasına AYRICA mağaza rozeti kondu (aynı PR), üstelik footer'a değil davet kartının hemen ALTINA — footer ölçümü 1153 px vermişti, kart altı 378 px (390×844, geçerli davet ekranı). ⚠ Statik SEO/hukuki sayfalar (`src/legal/render.tsx`) kendi `<head>`ini üretiyor, etiket oraya GİRMEDİ — `/nasil-oynanir/` bir kazanım sayfası, istenirse tek satır. Önceki not: `<meta name="apple-itunes-app" content="app-id=6809809788">`, App ID `marketing/app-store/console-formlari.md` §1'den. ⚠ Bu etiket bugünkü Universal Links bandının yerine geçmez, onu KAPSAR: uygulama yoksa *GET* (mağazaya), varsa *OPEN* — bugünkü bant yalnızca ikinci hâli yapıyor (bkz. 24.4) |
| ⏳ **Android misafirde "uygulama yüklü mü"** (24 Eyl 2026, kullanıcı: *"app yüklü insanlara çıkartmama şansımız var mı?"*) | Mağaza şeridi bugün iOS Safari'de (Apple'ınki var) ve `push_tokens`ı olan üyede susuyor (`shouldShowStoreStrip`). Kalan boşluk: uygulaması yüklü **misafir**. iOS'ta web'den sormanın yolu YOK. Android'de Chrome'un `navigator.getInstalledRelatedApps()`i var: web manifestine `related_applications` (Play kimliği `com.kelimeki.kelimeki`, `prefer_related_applications` AÇILMADAN — alttaki satır) + Android uygulamasının `AndroidManifest.xml`ine `asset_statements` meta-data'sı. İkincisi `mobile/app/` → mobil derleme → **merge turundan sonra**, sıradaki mobil PR'a binebilir. Etkisi küçük: uygulaması yüklü olan kelimeki.com linkinde zaten App Links ile uygulamaya düşüyor |
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
