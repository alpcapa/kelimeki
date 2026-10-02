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
çıkacağını** söyler. Madde 0 (FAZ B) omurgaydı — 24 Eylül 2026'da
KAPANDI (Play production).

**Fazları belirleyen tek kısıt, bir tercih değil bir ölçüm:**

| Değişiklik türü | Bedeli | Ne zaman canlıda |
|---|---|---|
| İstemci (Flutter) | paket + Play incelemesi + cihaz turu | sürüm turu |
| Sunucu (migration / Edge Function) | yok | **anında**, merge'den bağımsız |
| Web (`src/`) | yok | `main`'e merge → Vercel |

Yani maddeleri "konu"ya göre değil **paketlenebilirliğe** göre grupladım.
Sonuç: kalan HER ŞEY **iki sürüm turuna** sığıyor — bildirim işinin yarısı
sunucu tarafında olduğu için sürüm beklemiyor.

### Kalan işlerin tamamı — tek bakışta (26 Eylül 2026'da yeniden yazıldı)

Bu tablo bir İNDEKS: yalnızca AÇIK maddeler, gövdeleri aşağıda (ya da
belirtilen dosyada). Bir madde kapanınca satırı buradan, gövdesi de
arşive gider. Önceki sürüm (2 Eylül 2026; 1.0.4-1.0.6 turları, Play
sayacı, Console kovaları — hepsi kapanmıştı):
`docs/decisions/roadmap-arsiv.md` → "Kalan işlerin tamamı — tek bakışta
(2 Eylül 2026 sürümü)".

**Durum (1 Ekim 2026 akşamı):** mağazalarda `1.1.1 (723)` = `8c1828f`;
**1.1.2 (831) = `05f1c1f` iki mağazada incelemede** (`mobile/docs/surumler.md`
→ "1.1.2 (831)"). Tren HER PAZARTESİ (1 Eki gece kullanıcı kararı), sonraki kesim
**12 Ekim 2026** = 1.1.3 ("SÜRÜM TRENİ"). Onaya kadar `main`'e mobil kod girmez. 1 Ekim'de kapanıp arşive
taşınanlar: #37, #38, #41 (`docs/decisions/roadmap-arsiv.md` → "Altıncı
taşıma").

| Kova | # | Ne | Durum |
|---|---|---|---|
| **1.1.2'de — incelemede, SAHAYA İNİNCE arşive** | #25 | iOS simgesinde rozet SAYISI | `main`'de (#647, kesim 1 Eki); 1.1.2 (831) iki mağazada incelemede. Beş bildirim fonksiyonu yeni `_shared/push.ts` ile deploy edildi (`verify_jwt` korundu) |
| | #34 | Canlı sohbet okundu bilgisi — port yarısı | `main`'de (kesim 1 Eki), 1.1.2 (831) incelemede |
| | #35 · #30 | Kayıt Hunisi port yarısı · `tutorial_events` `anon_id` | `main`'de (#651), migration canlıda (`20261001104454`); 1.1.2 (831) incelemede. #30'un cihaz paydası kararı sahadaki pay ölçülünce |
| | #40 · Huni v2 PR 2 | Cihaz kartları + Huni v2'nin mobil yarısı + Play Install Referrer | `main`'de (#659 + #709), 1.1.2 (831) incelemede. ✅ Admin'deki "Web" etiketleri Huni v2 + iki Cihaz kartından kaldırıldı (2 Eki; Ziyaretçi Yolculuğu'nunki tanım gereği kalır). Kalan: Play Data safety / App Store gizlilik beyanını cihaz modeli için kontrol et |
| **Sıradaki mobil işler** | #26 | Web → mağaza yönlendirmesi: kalan iki satır | Android'de uygulaması yüklü misafir (`asset_statements`, mobil) · manifest `related_applications` (ÖLÇMEDEN AÇMA) |
| | #42 | Uygulama içi puan isteği (App Store + Play) | **30 Eyl 2026, kullanıcı kararı: #41 (tasarım) yayına girdikten SONRAKİ bir trene.** App Store'da hiç yorum yok. Kendi uygulamana yorum yazmak YASAK (Review Guidelines 5.6, geliştirici hesabı riski), bu yüzden ilk yorumların yolu işletim sisteminin kendi penceresi: `in_app_review` paketi (iOS `SKStoreReviewController` — yılda en fazla 3 gösterim, Apple kısıtı; Android In-App Review API). Tetik bir KAZANÇ anında (ör. 3.-5. biten oyun ya da bir galibiyet sonrası), tanıtımda/ilk oyunda ASLA. Karar `utils/onboarding.ts` desenindeki gibi saf fonksiyonda. Web'de karşılığı yok (yalnızca port). Gelen yorumlara ASC'de `Kelimeki Destek` adıyla cevap verilebilir |
| **Ölçüm / izleme** | #23 | Seviyeli YZ — Faz 5 SAHA ölçümü | Kod ✅. **İlk okuma 2 Eki:** Normal hedefte (%48), Zor kişi içi Normal'den ~+13 puan güçlü → kullanıcı: *"Zor şimdilik yeterli"*. **Açık kalan yalnızca Kolay** (27 oyun %41, ~100 oyunda yeniden bak; >%40 ise top-N 4→5). `docs/decisions/ai-levels.md` §9 |
| | #18 | `submit_move` puan hakemliği | GÖLGE FAZINDA (`move_shadow_diffs`) |
| | #14 | Uzun modal listeleri tembel inşa | Eşiğe bağlı izleme |
| **Güvenlik** | #21 | Advisor gürültüsü + Auth ayarları | Kısmen yapıldı |
| | #22 | `feedback` hız sınırı XFF ile atlanabilir | Açık, ölçülmedi |
| **Ertelendi (kullanıcı kararı)** | #32 | E-posta onayı bir kullanıcı kaybı kapısı | "Daha sonra bakalım" (20 Eyl) |
| | #39 | Takma isim değişince geçmiş oyunlarda eski isim | "Sonra bakılacak" (23 Eyl) |
| | #17 | Google ile giriş/kayıt | Sunucu → web → mobil; migration BLOKER |
| **İsteğe bağlı** | #5 | k-lig puan grafiği | — |
| | #9 | Admin Üyeler'e "onaylanmamış" filtresi | Gövdesi dondurulmuş arşivde (`roadmap-arsiv-cilt-1.md` → "9.") |

**Madde numarası kuralı (26 Eylül 2026):** yeni madde **bir sonraki boş
numarayı** alır — şu an **#43**. Numara hiçbir zaman yeniden kullanılmaz,
kapanmış (arşivdeki) maddelerinki de. 26 Eylül'de iki AKTİF çakışma
bulundu ve sonradan gelen maddeye yeni numara verildi: tahta yükseklik
bütçesi **#26 → #38** (mağaza yönlendirmesi #26 olarak kaldı; kodda ve
dokümanlarda onun atıfı çok daha fazla) ve takma isim geçmişi
**#36 → #39** (#36 Huni v2'nin gizlilik metni, kapalı, arşivde).
⚠ Arşivde eski, KAPALI çakışmalar da var (madde 24 = FAZ C ↔ onboarding;
25 = iPad manzarası ↔ bugünkü #25; hata avı geçişinin #23-#25'i) —
atıflar kırılmasın diye bilerek dokunulmadı; arşivde bir numara ararken
başlığa da bak.

### Sonra / bloke

> **1 Ekim 2026:** `main`'de (kesim), 1.1.2 (831) iki mağazada incelemede — sahaya inince arşive.

**#25 — iOS uygulama simgesinde rozet SAYISI çıkmıyor** → 🔧 **KOD HAZIR,
1.1.2 trenine biniyor** (18 Eylül 2026, kullanıcı bildirdi: *"Apple uyarılar geliyor ama
ikon üzerinde numara çıkmıyor"*).

**26 Eylül 2026 — yapıldı** (kullanıcı tekrar sordu; sayının tanımı
kararı: *"Bildirimlerde ne varsa onlar. Her bildirim sayıyı arttırmalı."*):
- Sayaç CİHAZ başına: `push_tokens.badge_count` — `bump_push_badge`
  (yalnızca service_role) artırır, `register_push_token` (her açılış/öne
  dönüş) sıfırlar. Migration `20260926182535_push_badge_count` **CANLIDA**
  (proacl doğrulandı: `bump_push_badge` → yalnızca postgres + service_role).
- `_shared/push.ts`: `apns.payload.aps.badge` yalnızca **iOS ≥ 1.1.2**
  cihaza (`ROZET_ILK_SURUM`). Aşağıdaki "iki yarım AYNI PR" kuralı bu
  sürüm kapısıyla GEREKSİZ kaldı: sunucu yarımı eski sürüme hiç sayı
  göndermiyor. Kapı: `npm run verify-push-payload` (42 kontrol).
- `AppDelegate.swift`: `hepsiniTemizle` artık rozeti de sıfırlıyor
  (iOS 16+ `setBadgeCount(0)`, 13-15 `applicationIconBadgeNumber = 0`);
  kapı `notification_shade_parity_test.dart`.
- ⏳ **KALAN TEK ADIM — beş push fonksiyonunun yeniden deploy'u**
  (`notify-your-turn`, `notify-game-invite`, `notify-friend-request`,
  `notify-friend-request-reminders`, `notify-deadline-warnings`;
  `verify_jwt` deploy ÖNCESİ `list_edge_functions`tan okunmalı — 26 Eylül'de
  your-turn/reminders/deadline `false`, friend-request/game-invite `true`). 1.1.2
  mağazaya çıkmadan yapılmalı; öncesinde yapmak da zararsız (kapı).
- Cihaz maddeleri: `mobile/docs/testing-bildirimler.md` → §3h.

Aşağısı 18 Eylül'ün teşhisi, tarihçe olarak duruyor:

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

> **1 Ekim 2026:** `main`'de (kesim), 1.1.2 (831) iki mağazada incelemede — sahaya inince arşive.

**#34 — Canlı sohbet okundu bilgisinin PORT yarısı** → 🚆 **TRENDE — taslak
PR (26 Eylül 2026), 5 Ekim kesiminde merge** (23 Eylül 2026; web yarısı #610 ile `main`'de).
Port yarısı yazıldı: `util/chat_read.dart` (web'in sekiz vakası
`chat_read_test.dart`te birebir) + `ChatRepo.chatLastReadAt`/`markChatRead`
+ `online_game_screen.dart`. Ayrıntı: Parça 216. Aşağıdaki metin işin
ÖNCEKİ tarifi; madde 1.1.2 sahaya inince arşive gider.

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

> **1 Ekim 2026:** `main`'de (kesim), 1.1.2 (831) iki mağazada incelemede — sahaya inince arşive.

**#35 — Kayıt Hunisi'nin PORT yarısı: uygulama da `signup_events`e
yazsın** → 🚆 **TRENDE — taslak PR (26 Eylül 2026, #30 ile aynı PR), 5 Ekim
kesiminde merge** (23 Eylül 2026, kullanıcı isteği: *"Roadmap'e ekle"*).
Yapıldı: `data/signup_events.dart` (YENİ) + `auth_modal.dart`taki üç
`analytics.log` noktası + `bootstrap.dart`; kartın `?` metni ve
`logSignupEvent` yorumu güncellendi. Migration'daki "yalnızca web" notuna
BİLEREK dokunulmadı (uygulanmış dosya). Ayrıntı: Parça 217. Aşağıdaki
metin işin ÖNCEKİ tarifi.

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

**#39 — Takma isim değişince geçmiş oyunlar ESKİ ismi göstermeye devam
ediyor** (26 Eylül 2026'ya kadar **#36** numarasını taşıyordu — Huni v2'nin
gizlilik metniyle çakışıyordu) → ⏳ **AÇIK, sonra bakılacak** (23 Eylül 2026, kullanıcı: *"Geçmiş
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

## Dondurulmuş port PR'ları — merge turu ✅ TAMAMLANDI (25 Eylül 2026)

✅ **1.1.1 İKİ MAĞAZADA YAYINDA (26 Eylül 2026) → ARŞİVDE** (`docs/decisions/roadmap-arsiv.md`,
aynı başlık; tur kararları ve "Tur sonu TEST PLANI" dahil).

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

## 1.1.3 treni — kesim Pazartesi 12 Ekim 2026 (taslak PR'lar, `main`'de DEĞİL)

⚠ **Kesimde sürüm numarası da 1.1.3'e çıkmalı** (`pubspec.yaml` + `config/env.dart`,
`app_version_parity_test`) — 1.1.2 App Store'da onaylanınca o trene yeni
build girmez (`90186`/`90062`, `surumler.md` → "Neden 1.1.1 — tur sırasında
ÖLÇÜLDÜ").

| Taslak PR | Ne | Dokunduğu yer |
|---|---|---|
| #756 (2 Eki) | **Tanıtımın vergi penceresi: "Rakip kullanıcısına" → "rakibine"** — port yarısı (web #755 ile hemen yayında) | `ui/tutorial/tutorial_game.dart` (tek metin; gerçek oyunun `invasion_confirm.dart`ı DEĞİŞMEDİ). Kayıt: `docs/decisions/onboarding.md` |
| #757 (2 Eki) | **"Bildirimler kapalı" kartı** — yarım oyun çıkışında izin ayarlardan kapalıysa (Android `permanentlyDenied` · iOS `denied`) "AYARLARI AÇ"; ayarlardan dönüşte hatırlatma kurulur | `util/unfinished_reminder.dart` (`yarimOyunKartiSec`) · `data/unfinished_game_reminder.dart` · `ui/push/push_permission_flow.dart` · `setup_screen.dart` · `MainActivity.kt` + `AppDelegate.swift` (`bildirimAyarlariniAc`). Parça 228 · cihaz: `mobile/TESTING.md` §34 |
| #760 (2 Eki) | **Tanıtım kapısı: cihazda gerçek oyun başlayınca "görüldü"** — üye olarak oynayıp çıkış yapan cihaz misafirken tanıtıma düşmesin (web #759 ile hemen yayında) | `setup_screen.dart` (`_startNewGame`) · `live/open_online_game.dart`. Parça 229 · cihaz: `mobile/TESTING.md` §1.9 · kayıt `docs/decisions/onboarding.md` |
| #765 (2 Eki) | **Canlı oyun formu: 1. koltuk SEN, 4 kişide 2×2, numaralar hizalı, isim numaraya binmez** (web #764 ile hemen yayında) — #762'nin (koltuk numarası iPhone'da alta yapışıktı, taban çizgisi kuralı) üstüne kurulu, #762 buna katılıp kapandı | `ui/live/live_game_create_form.dart`. Parça 230 + 231 · cihaz: `mobile/TESTING.md` → "Canlı oyun formu" · kayıt `docs/decisions/onboarding.md` |
| #772 (2 Eki) | **Setup'ın oyuncu sayısı satırı: "2 kişilik oyunda yapay zekaya karşı oynarsın." / "4 kişilik oyunda 3 yapay zekaya karşı oynarsın."** (kullanıcı isteği; web yarısı hemen yayında) | `ui/setup/setup_screen.dart` (tek metin) + `setup_screen_test` / `setup_cloud_test` beklentileri |
| #774 (2 Eki) | **"Tüm oyuncular →" / "← Arkadaşlar" bağlantıları başlıkla aynı tipografide, mavi + kalın** (kullanıcı isteği; web yarısı #775 ile hemen yayında) | `ui/live/live_game_create_form.dart` (`_LinkButton`) + `ui/friends/friends_modal.dart`; `trUpper` ile büyük harf, sabitler web'le birebir |
| #779 (2 Eki) | **Kayıt formu: ad/soyad isteğe bağlı, zorunlular üstte + Gizlilik "Ad ve soyad (isteğe bağlı)"** (kullanıcı isteği; web formu hemen yayında) | `ui/auth/auth_modal.dart` · `account_settings_modal.dart` · `legal_modals.dart` + web `src/legal/LegalContent.tsx` (Gizlilik tarihi 12 Ekim 2026 — `legal_text_test` web↔port tarih eşliği yüzünden İKİSİ BU PR'da). Cihaz: `TESTING.md` → "Ad/soyad İSTEĞE BAĞLI" |

## Sıradaki sürüme binecekler — `main`'de var, MAĞAZADA yok

⚠ **DURUM (1 Ekim 2026 gece): 1.1.2 (831) PLAY'DE YAYINDA (2 Eki 00:56 TSİ), App Store İNCELEMEDE — iOS'ta yayındaki hâlâ `1.1.1 (723)`.** Play paketi yayında olduğu için `mobile-latest`in korunma gereği kalktı; ASC'deki build gönderime iliştirili, ezilmez. Mobil işler yine treni bekler (her Pazartesi, ilki 12 Ekim). Kayıt: `surumler.md` → "1.1.2 (831)".
⚠ **1 Ekim 2026 akşamı, kullanıcı kararı: #41'in port yarısının TAMAMI
(tasarım) 1.1.2'ye girer, 1.1.2 ancak o bitip test edilince TEK paket olarak
gönderilir** — *"Arka arkaya güncelleme iyi fikir değil … Hepsini koyalım,
test edelim, emin olunca review'a göndeririz. 90 gün süresi var nasılsa."*
(TestFlight build'i 90 gün geçerli.) Yani aşağıdaki "sıradaki adımlar"daki
gönderim, #41 port parçaları `main`'e girene kadar BEKLER; parçalar taslak
değil, doğrudan `main`e merge edilir (1.1.2 henüz gönderilmedi).
Kullanıcı kararı (1 Eki): *"Bizim gibi yeni uygulamalar daha sık güncelleme
geçiyorlardır"* → 5 Ekim beklenmedi, kesim 1 Ekim'de yapıldı ve tren
**haftalık** oldu; aynı gece sabit gün kondu: **her Pazartesi, ilki 12 Ekim** (`surumler.md` → "SÜRÜM TRENİ").
Aşağıdaki tablonun TAMAMI 1.1.2'nin içeriği.

**Kesim (1 Eki, ajan):** 17 PR sırayla squash-merge edildi — #642 #649 #655
#657 #670 #676 #678 #687 #697 #716 #637 #640 #647 #651 #659 #709 #731; son
`main` = `927e7bc`. Önce yerelde tek tek birleştirildi, çakışmalar orada
çözüldü (kod: `game_screen.dart` ×3, `board_widget.dart`, `bootstrap.dart`
×2, `auth_modal.dart`; geri kalanı doküman) ve birleşik ağaçta **app 1.020
test · core 6.895 kontrol · web lint + 9 doğrulayıcı** yeşil; her PR'a o
adımın ağacı merge commit'iyle kondu, `main`'in son ağacı test edilenle
BİREBİR aynı. Sunucu adımları: #647'nin migration'ı (`push_badge_count`)
26 Eyl'den beri canlıdaydı; #647 sonrası beş bildirim fonksiyonu yeni
`_shared/push.ts` ile deploy edildi (`verify_jwt` her birinde korundu);
#651'in migration'ı canlıya uygulandı → canlı sürüm `20261001104454`, dosya
adı ona çevrildi, `proacl` öncesiyle aynı.

**Sıradaki adımlar (1 Ekim 2026 akşamı güncellendi):** ✅ `main` derlemesi
(826 → bulgular #746 → **831**) · ✅ cihaz turu (kullanıcı: *"Herşey ok"*) ·
✅ App Store + Play gönderimi (`mobile/docs/surumler.md` → "1.1.2 (831)").
**Kalan:** (1) onaylar gelince yayın — Apple önce gelirse beklemeden
("YAYIN SIRASI"); (2) yarım oyun hatırlatması (#731) cihazda HENÜZ
GÖRÜLMEDİ — ilk bildirim 3 Ekim 19:00 bekleniyor (`mobile/TESTING.md` §34);
(3) sahaya inince bu bölüm + yukarıdaki "1.1.2'de" kovası arşive. (Admin'deki
"Web" etiketleri 2 Ekim'de kalktı — Ziyaretçi Yolculuğu'nunki tanım gereği kalır.)

⚠ **`mobile-latest` her mobil derlemede ÜZERİNE yazılır** — sıradaki sürüm
adı Play'e yüklenene kadar `main`'e giren her mobil iş bu paketi de
değiştirir (1.0.4/467 dersi, arşivde). Yüklemeden önce indirdiğin `.aab`nin
derleme sha'sını `main`'in başıyla karşılaştır.

**Yayındaki paket:** 1.1.1 (723) = commit `8c1828f` (#632). Doğrulama:
`git log --oneline 8c1828f..origin/main -- mobile/app mobile/kelimeki_core`
(26 Eylül'de BOŞ — sonraki trenin işleri henüz taslak PR'da, `main`'de değil).

**YAYINDAKİ PAKETTEN (723, `8c1828f`) SONRA porta dokunan işler — sıradaki
sürümün içeriği:**

> ⚠ Aşağıdaki satırlardaki *"taslak PR"*, *"sonraki tren"*, *"1.1.1'e
> BİNMİYOR"* ibareleri yazıldıkları günün durumu; **hepsi 1 Ekim
> kesiminde `main`'e girdi ve 1.1.2 (831)'in içinde.** Tablo paketin
> içerik kaydı olarak duruyor, yayından sonra arşive gider.

| Commit / PR | Ne | Neden porta dokunuyor |
|---|---|---|
| (26 Eyl, taslak PR) | **Canlı sohbetin okundu bilgisi artık SUNUCUDA — uygulamada okunan web'e, web'de okunan uygulamaya yansıyor** (ROADMAP #34) | ⚠ **1.1.1'DE HATA VAR, sonraki trende düzelir.** `util/chat_read.dart` (YENİ, web `chatRead.ts` ikizi) + `data/chat_api.dart` (`chatLastReadAt`/`markChatRead`) + `ui/live/online_game_screen.dart`; `chat_read_store.dart` yedek kaldı. Kullanıcının vakası: oyun bir cihazda ilk kez açılınca "ilk ziyaret" tohumu yeni mesajları da okunmuş sayıyordu (rozet 0, içeride 2 yeni mesaj). Sunucu tarafı canlıda, migration YOK. Aynı PR'da: tazeleme düşünce sohbet artık SİLİNMİYOR (web ikizi #650). Kapı: `chat_read_test.dart` (11) + `online_game_chat_test.dart` (9 yeni; eski ekranla 5'i düşüyor); app **921 test yeşil**. Cihaz maddesi `mobile/docs/testing-arkadaslar-canli.md` → "Okundu bilgisi cihazlar arasında" |
| (27 Eyl, taslak PR) | **Tahtanın yükseklik bütçesi — port ikizi (ROADMAP #38)**: açık katlanabilir / yatay iPad'de raf ve butonlar ekranın altında kalmıyor | ⚠ **Sonraki tren.** `ui/game/board_fit.dart` (yeni) + `board_widget.dart` · `tile_widget.dart` · `game_screen.dart` · `online_game_screen.dart` · `tutorial_game.dart` · `main.dart` (yorum). Web sabitleri birebir; taş harfi/puanı ve X3 tahtaya göre tavanlı. Telefon DİKEYDE davranış piksel piksel aynı (testli). Kapı: `board_fit_test.dart` + `online_game_screen_test.dart`; **917 test yeşil**. Cihaz maddesi `mobile/docs/testing-ux-turlari.md` §33 |
| (30 Eyl, taslak PR) | **Oyun içi ipuçları: vergi/×2-×3/bölge balonları kaldırıldı, yerine "Kelimenin üzerine tıklarsan anlamı gelir."** — web + port AYNI PR | `util/onboarding.dart` + `ui/game/game_screen.dart`: tek ipucu `anlam`, tahtaya kelime oturunca (YZ'nin hamlesi dahil) bir kez — ama ekran açılışından (= zoom balonundan) en az 3 hamle sonra (`onboardingHintMinMoves`); Canlı oyunda YOK (kullanıcı kararı). Kullanıcı kararı (Instagram'dan uçtan uca deneme). Çift tık balonu DEĞİŞMEDİ. `tutorial_parity_test.dart` web kaynağını okuduğundan web yarısı ayrılamadı → PR bütünüyle trende (5 Ekim). Kapı: `tutorial_script_test` + `tutorial_parity_test` (hamle eşiği dahil) yeşil, app **901 test yeşil**, `verify-tutorial-script` yeşil. Kayıt: `docs/decisions/onboarding.md` → "30 Eylül 2026" |
| (26 Eyl, taslak #647) | **iOS simge rozeti sayısı (#25)** — `AppDelegate.swift` açılışta rozeti sıfırlıyor | Sunucu 1.1.2+ iOS cihazlara `aps.badge` gönderiyor (her bildirim +1); sıfırlayan kod bu pakette. Kapı: `notification_shade_parity_test.dart`. ⚠ Beş push fonksiyonunun deploy'u ayrıca gerekli (ROADMAP #25) |
| (26 Eyl, taslak PR) | **Sürüm numarası 1.1.2** (`pubspec.yaml` `1.1.2+1` + `config/env.dart` `appVersion`) | Kesim günü (5 Ekim) trenin öteki taslaklarıyla BİRLİKTE merge edilir, tek başına DEĞİL. Kapı: `app_version_parity_test.dart` yeşil |
| (26 Eyl, taslak PR) | **Kayıt Hunisi uygulamayı da sayıyor + tanıtım olayları cihaz kodunu taşıyor** (ROADMAP #35 + #30) | `data/signup_events.dart` (YENİ, kimliksiz; web `logSignupEvent` ikizi) + `ui/auth/auth_modal.dart` (üç `analytics.log`in yanına) + `bootstrap.dart`; `data/games_api.dart` `tutorial_events` → `anon_id` artık `_damga()`dan. Web yarısı AYNI PR'da ama yalnızca metin: admin kartının `?`'i + `logSignupEvent` yorumu. Kapı: `signup_events_test.dart` (7). Sunucu değişmedi, migration YOK |
| (26 Eyl, taslak PR) | **Uçak modunda Canlı oyun mesajı ham `Failed host lookup: '…supabase.co'` gösteriyordu** | ⚠ **1.1.1'e BİNMİYOR — sonraki tren.** `util/error_message.dart`: makine kalıbına Dart'ın taşıma metinleri eklendi (`Failed host lookup` · `Connection refused/reset/closed/timed out` · `Network is unreachable` · `OS Error`). 1.1.1 cihaz turunda (D, §31 ilk madde) bulundu: `ClientException.message` sınıf adını taşımıyor, `SocketException` kalıbı `toString()`e bakıyordu. Web'de bu metinler oluşmuyor, web değişmedi; kalıp SAYISI parite için aynı (tek regex). Kapı: `error_message_parity_test.dart` üç yeni vaka; **904 test yeşil**. Metin düzeltmesi → acil istisna DEĞİL (`surumler.md` → "SÜRÜM TRENİ") |
| (26 Eyl, taslak PR) | **Oyun sonunda kendiliğinden açılan "Görüş Bildir" formu kaldırıldı** — port yarısı | ⚠ **1.1.1'e BİNMİYOR — sonraki tren.** `ui/game/game_screen.dart` + `ui/live/online_game_screen.dart`: GameOver kapanınca `openFeedback()` artık çağrılmıyor; modalın içindeki "GÖRÜŞ BİLDİR" linki DURUYOR. Kullanıcı: *"Oyun sonlarında çıkan görüş bildir popup'ı kaldıralım artık."* (Parça 48'in otomatik açılışının geri alınması.) Web yarısı AYRI PR, hemen merge. Kapı: `game_screen_test.dart` + `online_game_screen_test.dart` ters çevrildi (form AÇILMAZ); **904 test yeşil**. Cihaz maddesi `mobile/TESTING.md` "Kapatmak formu AÇMAZ" |
| (26 Eyl, taslak PR) | **Kayıt sonrası satır: "Hesap oluşturuldu." kaldırıldı** — port yarısı | ⚠ **1.1.1'e BİNMİYOR — sonraki tren.** `ui/auth/auth_modal.dart`: satır artık yalnızca *"LÜTFEN E-POSTANIZI KONTROL EDİP DOĞRULAMA YAPIN."* (tamamı kalın). Kullanıcı: insanlar hesabın hazır olduğunu sanıyor. Web yarısı #644. Kapı: `signup_info_parity_test.dart` (web kaynağını OKUR). Cihaz maddesi `mobile/TESTING.md` §30 |
| (26 Eyl, taslak PR) | **YZ taş değişimi elde kalan taşları siliyordu + daha açık mesaj** — port yarısı | ⚠ **1.1.1'DE DE VAR, sonraki trende düzelir.** `kelimeki_core/lib/src/engine/reducer.dart` `_aiPlay`: torba 7'nin altındayken hamle bulamayan YZ `maxSwapCount` kadar taş değiştirip rafını yalnızca yeni çektiklerinden kuruyordu → elde kalan taşlar oyundan siliniyordu (torba 4 → raf 7'den 4'e). Raf artık elde kalanlar + yeni çekilenler; mesaj insan/Canlı ile aynı: *"<ad> <n> taş değiştirdi ve sırasını kullandı."* Yalnızca yerel YZ oyunu (Canlı'da rafı `submit_move` kuruyor). Web yarısı #645 (canlıda). Kapı: `run_all.dart` `testSwapLimit` (yeni blok) + golden `reducer_crafted_ai_exchange.json` yeniden üretildi; Dart core **0 hata**, app **907 test yeşil**. Vaka: `docs/decisions/game-rules.md` |
| (27 Eyl, taslak PR) | **Zoom ipucu balonu: kısa metin + SOL-ALT bloğun boş karesini gösteriyor** — port yarısı | ⚠ **Sonraki tren.** `ui/game/board_zoom.dart` (`kZoomHintText` + `zoomHintTarget`) + `ui/game/board_widget.dart` (`_zoomHintBubble`). Kullanıcı: *"X3 üzerine göstermesi kafa karıştırıyor"*; yeni metin *"Boş kareye çift tık tahtayı büyütür. Şimdi Dene!"* (iki satır). Web yarısı AYRI PR, hemen merge — port PR'ı o merge'e BAĞLI (`zoom_hint_test.dart` metni web'in `ZOOM_HINT_TEXT`inden okuyor). Metin düzeltmesi → acil istisna DEĞİL. Cihaz maddesi `mobile/docs/testing-ux-turlari.md` |
| (28 Eyl, taslak PR) | **Oyun Geçmişi: üstte TOPLAM · (adın) · VERGİ(−) · VERGİ(+) kutuları** — port yarısı | ⚠ **1.1.1'e BİNMİYOR — sonraki tren.** `ui/game/move_history_modal.dart`: *"Bu oyunda kazanılan N hamle… Toplam X puan"* satırının yerine dört kutu (N pas turlarını saymadığından 44 yazıp 45. hamleyi listeliyordu): TOPLAM (oyunun puanı) · açanın ADI (skor tablosundaki puanı) · VERGİ(−) · VERGİ(+) (açanın kendisi; `moveHistoryStats`, web ile birebir). Çağrı yerleri koltuğu geçiriyor: `game_screen.dart` (0), `online_game_screen.dart` (`_mySlot`), `score/game_history_modal.dart` (sıradan koltuğa). Web yarısı #669 + #671. Kapı: `move_history_test.dart` |
| (28 Eyl, taslak PR) | **Kendi skor kartında "arkadaş ekle" simgesi çıkıyordu** — yalnızca port | `ui/score/player_score_card_modal.dart`: `relationWith` kendisi (ve misafir) için null dönüyor, kart null'ı "ilişki yok" diye çizip dokununca kişiye kendine davet teklif ediyordu. Artık gateway'in `currentUserId`si yoksa ya da kartın sahibiyse simge HİÇ çizilmez (web'in `!!user && user.id !== member.id` koşulu; web'de hata YOK). Kapı: `friends_test.dart` → *"ilişki simgesi YOK — kendi kartı / misafir"* (düzeltmesiz DÜŞÜYOR); **903 test yeşil**. Acil istisna DEĞİL → sonraki tren |
| (28 Eyl, taslak PR) | **"Arkadaşınla" rozeti davet kabulünden sonra "1"de takılı kalıyordu** — port yarısı | `ui/live/live_games_tab.dart` + `ui/setup/setup_screen.dart`: liste her başarılı yüklemede davet + sırası sende sayısını (`inviteBucket` + `myTurnCount`, rozet sorgusuyla AYNI fonksiyonlar) `onActionCount` ile Setup'a bildiriyor; liste ile rozet artık çelişemez. Öncesinde kabulden sonra liste tazeleniyor, rozet yalnızca Realtime olayını bekliyordu; olay kaçınca sekme değiştirmek düzeltmiyordu, uygulamayı yeniden açmak düzeltiyordu (kullanıcı bildirdi, canlıda ölçüldü: yeni oyunda sıra rakipteydi). Web yarısı AYRI PR, hemen merge. Kapı: `setup_screen_test.dart` → *"LİSTEYLE hizalanır"* (düzeltmesiz DÜŞÜYOR). Acil istisna DEĞİL → 5 Ekim treni |
| (29 Eyl, taslak PR) | **Skor kartında "Ekle" / "Kabul et" yazılı buton** — port yarısı | Sonraki tren. `ui/score/player_score_card_modal.dart`: eylem çağıran iki dal (ilişki yok, gelen istek) ikon yerine web `Pill` biçiminde hap ("EKLE" / "KABUL ET"); ✓ ve ⌛ ikon kaldı, ✓'ye dokunmak yine çıkarma onayı. Kullanıcı: *"o ikonlar çok anlaşılmıyor"*. Web yarısı #686 (canlıda). "Tüm oyuncular → skor kartı" kısmı portta YOK: o liste ROADMAP #41'in port yarısıyla gelecek. Kapı: `friends_test.dart` dört dal hap/ikon olarak yeniden çivilendi; **901 test yeşil** |
| (29 Eyl, taslak PR #687) | **Tüm Oyunlar → "Favoriler" sekmesinde küçük dolu kalp** — port yarısı | Sonraki tren. `ui/score/game_history_modal.dart` `_FilterTab`: `heart` bayrağı; seçili değilken kırmızı, seçiliyken beyaz (web ile aynı). Kullanıcı: *"oyunlardaki kalbin o işe yaradığı belli olsun"*. Kapı: `game_likes_test.dart` (sekme kalbi `kFavoritesTabHeartKey` ile satır kalbinden ayrılıyor + yeni test); **902 test yeşil** |
| (29 Eyl, taslak PR #687) | **Canlı oyun: hamle kabul edildikten sonra ekran Realtime'ı beklemeden kendini tazeliyor** — port yarısı | Sonraki tren. `ui/live/online_game_screen.dart` `_syncAfterSubmit`: üç gönderim dalında (oyna/pas/değiştir) `_moveIdTemizle()`'den sonra `_refresh()` BEKLENİYOR, `_busy` ancak sonra düşüyor. Kullanıcı web'de bildirdi: hamle sunucuya tek kez yazılmıştı (15:18:44), soket düşmüş olduğundan yankı gelmedi, OYNA etkin kaldı, ikinci basış gerçek "Sıra sende değil." aldı. Değiştir dalında swap modundan çıkış senkrondan ÖNCEYE alındı. Web yarısı ayrı PR. Kapı: `online_game_screen_test.dart` yeni regresyon (düzeltmesiz koşulda DÜŞTÜĞÜ doğrulandı); **903 test yeşil** |
| (29 Eyl, taslak PR #687) | **Skor kartları: ismin yanındaki rütbe mührü kalktı** + arkadaşlık hapı 26 px — port yarısı | Sonraki tren. `ui/score/score_card_modal.dart` + `player_score_card_modal.dart`: isim yanındaki 20px `RankSeal` çıktı, başlıktaki 34px mühür duruyor. Kullanıcı: *"zaten üstte var"*. Hap: görünen 26 px, dolgu 10 (web #690). Kapı: `score_card_test.dart` (20px mühür artık YOK); **903 test yeşil** |
| (29 Eyl, taslak PR) | **Avatar bazen hiç yüklenmiyor / yüklenirken boş gri daire** — port yarısı | ⚠ **Sonraki tren.** `ui/auth/k_avatar.dart`: yüklenirken boş gri daire yerine baş harf (`frameBuilder`); ilk hatada kalıcı baş harfe düşmek yerine BİR KEZ anında yeniden deneme (ikinci hata gerçek). `data/auth_service.dart` `uploadAvatar`: `cacheControl: '31536000'` (adres `?v=` ile sürümlü). Web yarısı #696. Sunucu temizdi (4 nesne, 68-123 KB, eksik yok). Kapı: `avatar_retry_test.dart` yeni vaka; **app 902 test yeşil**. Kalıcı disk önbelleği bilerek eklenmedi (yeni paket ister). Vaka: `docs/decisions/components-account.md` |
| (25 Eyl) | **Canlı oyunda sıra bandı kısaldı:** "Sıra: X — oynaması bekleniyor" → "Sıra: X bekleniyor" | ⚠ **1.1.1'e BİNMİYOR — sonraki sürüm** (1.1.1/723 incelemede; ⛔ Play'e 723 yüklenmeden MERGE ETME, `mobile-latest` ezilir): `ui/live/online_game_screen.dart` (yalnızca metin). Kullanıcı bildirdi: dar/kısa Android ekranında büyük yazıyla bant iki satıra sarıyor, raf altındaki buton şeridi ekranın altına itiliyordu. Web ikizi AYRI PR'da ve önden gitti (`OnlineGameScreen.tsx`, dal `claude/sira-bandi-kisa-web`). Tam çözüm değil — kalan alan seçenekleri (bant boyu, kısa ekranda sıkıştırma) karar bekliyor |
| (25 Eyl) | **Sohbet Kuralları onayı + Kullanım Koşulları §3/§5** — port yarısı + koşul metni | ⚠ **SÜRÜME BİNİYOR** (⛔ TASLAK PR, sürüm treni — kesimde merge): `ui/chat/chat_rules_modal.dart` (YENİ) · `util/chat_rules.dart` (YENİ) · `ui/chat/chat_modal.dart` (kapı) · `data/chat_api.dart` (iki uç) · `ui/live/online_game_screen.dart` (bağlantı) · `ui/auth/legal_modals.dart` (§3 yasak listesi + "sıfır tolerans", §5 mutlak muafiyet cümlesi yerine "sorumluluk gönderene ait; bildirilen içerik incelenir ve kaldırılır", Gizlilik'e onay kaydı satırı) + **küfür süzgecinin metin/port yarısı (#37)**: §5'te "denetlenmez" yerine otomatik süzgeç cümlesi, Gizlilik'e süzgeçlenen mesajın orijinalinin saklanması, `data/auth_service.dart` → `nicknameStatus` (`nickname_status` RPC'si; süzgece takılan ad "kullanımda" değil "kullanılamaz" — `auth_modal`/`account_settings_modal`, `signup_test` yeni vaka). ⚠ **Web `LegalContent.tsx` de BU PR'da** — `legal_text_test.dart` web tarihini okuduğu için ayrı gidemez. Web onay penceresi + `accept_chat_rules` migration'ı AYRI PR'da ve önce gitti (sunucu CANLIDA). Kapı: `chat_rules_parity_test.dart` + `chat_test.dart` (5 vaka). Kayıt: Parça 215 · `docs/decisions/chat-moderation.md` |
| (27 Eyl, taslak PR) | **Huni v2'nin mobil yarısı + "Cihaz" kartları uygulamayı da görsün (#40)** | ⚠ **5 Ekim treni** (kullanıcı: *"dahil edelim"*). `data/funnel_api.dart` (yeni): `funnel_events`e `land`/`visit`/`signup`/`game_start`/`game_finish`, kanal `app` (Play Install Referrer YOK — kullanıcı: *"önce kanalsız"*), eski cihaz `mevcut`. `data/device_info.dart` (yeni) + **`device_info_plus` paketi**: `device_visits`e girişli dahil günde bir satır + `guest_visits`in OS/model alanları. `bootstrap.dart` (sıra tuzağı: iz okuması `errorReporter`dan ÖNCE), `ui/app.dart`, `games_api.dart`, `auth_modal.dart`, `flags_store.dart`. Kapı: `funnel_events_parity_test.dart` (web + SQL okunur) + `source_stamp_test.dart`; **917 test yeşil**. Cihaz maddeleri `mobile/docs/testing-olcum.md` §33. Merge + mağaza sonrası: admin kartlarındaki "Web" etiketlerini kaldır (#658'in `PlatformTag`i), #40 ve Huni v2 satırlarını arşive taşı |
| (30 Eyl, taslak PR — #659'un ÜSTÜNE) | **Huni v2: Play Install Referrer → Android `land` kanalı** (Parça 218) | ⚠ **5 Ekim treni, #659'dan SONRA merge.** Kullanıcı: *"Referrer'ı 5 Ekim trenine ekle"*. **`play_install_referrer` paketi** + `data/install_referrer.dart` (yeni) + `funnel_api.dart` (`channelFromInstallReferrer`) + `bootstrap.dart`. Web rozetinin `?ref=` → Play `referrer=utm_source%3D…` zinciri uygulamada okunur; organik/bozuk → `app`, eski cihaz → `mevcut`. Kapı: `funnel_events_parity_test.dart` (web kalıbı okunur). Cihaz: `testing-olcum.md` §33 (mağazadan kurulum şart) |
| (1 Eki, taslak PR) | **Yarım kalan oyun hatırlatması — telefona kurulan TEK yerel bildirim (misafir dahil)** | ⚠ **#731 · 5 Ekim treni** (kullanıcı 1 Eki: önce *"sonraki trene taslak PR"*, aynı gün *"5 Ekim trenine ekle"*). Cihazda HİÇ denenmedi → kesim sonrası TestFlight/iç test turunda `mobile/TESTING.md` §34 önce koşulmalı. Yeni: `util/unfinished_reminder.dart` (saf: ayrılıştan ≥12 sa sonraki ilk 19:00 · oyun başına bir kez · izin) + `data/unfinished_game_reminder.dart` + native `kelimeki/hatirlatma` kanalı (`YarimOyunHatirlatmasi.kt` — `AlarmManager.setAndAllowWhileIdle`, yeni izin YOK · `AppDelegate.swift` — `UNTimeIntervalNotificationTrigger`) + manifestte `YarimOyunAlicisi`. Kancalar: `SetupScreen._openGame` (oyun ekranında `onHide` + logoyla çıkışta izin kartı → kur; oyun bitince iptal), `_HomeGate` (gerçekten gizlenip dönünce iptal). İzin kartı misafire de çıkıyor, sayacı Canlı kartıyla ORTAK. Gerekçe: Meta kalite okuması, ertesi gün dönüş ~%11 (`product-backlog.md` → "Ertelenenler" #1). Kapı: `unfinished_reminder_test.dart` + `unfinished_reminder_parity_test.dart` (Dart↔Kotlin↔Swift adları); app **927 test yeşil**. Cihaz maddesi `mobile/TESTING.md` §34 |
| (1 Eki, taslak PR) | **"Kelimenin üzerine tıklarsan anlamı gelir" balonu: karşılıklı 6. hamleden sonra (toplam 12) + ilk 3 satırda ALTA** — web + port AYNI PR | 1.1.2 cihaz turunda (iPhone) balon tahtanın üstünde kesik çıktı. `util/onboarding.dart` (`onboardingHintMinMoves` 3→12, `onboardingHintAltRows`, `onboardingHintYon`) + `ui/game/game_screen.dart`; web `utils/onboarding.ts` + `App.tsx`. Parite testi web kaynağını okuduğundan iki yarı ayrılamaz. Kapı: `verify-tutorial-script` + `tutorial_parity_test` + `tutorial_script_test`; app **1.020 test yeşil** |
| (1 Eki) | **Setup sadeleşti — misafir giriş uyarısı YOK · misafire her zaman / girişliye ilk oyunda Kolay (web+port) · misafir logo altı paragrafı YOK · 4. koltuk YZ onayı YOK** (ROADMAP #41 karar 4, 7, 2'nin parçası, 12'nin parçası) | Kullanıcı 1.1.2 turunda: *"insanların bir an evvel oyun başlatmasını istiyoruz"* → kontrol grubu iptal, 1.1.2'ye. `ui/setup/setup_screen.dart` (`_handleStart`, `_chosenLevel`/`_level`, `_ilkOyunMu`, seviye OYUNU BAŞLAT anında sabit) + `util/ai_level.dart` (`defaultAiLevel`) + `ui/live/live_game_create_form.dart`. Testler güncellendi; app **1.020 yeşil**. Karar kaydı `docs/decisions/onboarding.md` → "Kontrol grubu İPTAL" |
| (1 Eki) | **Tek standart Setup ekranı — port yarısı** (ROADMAP #41 karar 2 + 13; Parça 219) | **1.1.2** (kullanıcı 1 Eki: *"herşeyi 1.1.2'ye koyup gönderelim"*). `ui/setup/setup_screen.dart`: "KİME KARŞI" · "YAPAY ZEKA" · "N KİŞİ"; "OYUNCULAR" koltuk listesi yerine tek satır özet; turuncu OYUNU BAŞLAT akışta, zorluğun altında (altta yapışık çubuk KALKTI — 375 pt kapısı değiştirilmeden geçiyor); girişli listede "YENİ OYUN BAŞLAT". App **1.019 yeşil** |
| (1 Eki) | **Arkadaşınla ekranları — port yarısı: girişsiz alt pencere + "YENİ OYUN BAŞLAT"** (ROADMAP #41 karar 9 + 10; Parça 220) | **1.1.2.** `ui/live/guest_live_sheet.dart` (YENİ): misafir "Arkadaşınla"yı seçince alttan "Arkadaşınla oynamak için giriş yap" — ÜYE OL · GİRİŞ YAP · YAPAY ZEKAYLA DEVAM ET; kapatmak Yapay Zeka'ya döndürür, giriş penceresinden vazgeçince geri gelir. `live_games_tab.dart`: "+ YENİ CANLI OYUN AÇ" → "YENİ OYUN BAŞLAT" (52/16, listenin üstünde). `showLoginModal(startInSignup:)`. Metinler web'den testle okunuyor |
| (1 Eki) | **Canlı oyun formu — port yarısı: koltuk kartları, doğrudan davet paylaşımı, "Tüm oyuncular", "Hızlı seç"** (ROADMAP #41 karar 11, 12, 15-21; Parça 221) | **1.1.2.** `ui/live/live_game_create_form.dart` yeniden yazıldı (web #663-#666): oyuncu renginde koltuk kartları + numara filigranı, 4 kişide 2 arkadaşla 3. koltuk "Yapay Zeka", boş koltuk listeye kaydırır; DAVET GÖNDER/VAZGEÇ koltukların altında; "+ ARKADAŞINI DAVET ET" doğrudan paylaşım; her zaman görünen kaydırma çubuğu; "Tüm oyuncular →" (EKLE · İSTEK GİTTİ · KABUL ET, skor kartı); "Sık oynadıkların / Hızlı seç" (RPC `my_frequent_opponents`); "Davetin gönderildi". YENİ: `ui/friends/k_pill.dart`, `ui/friends/player_directory.dart` (Port 4 de kullanacak). Metinler web'den testle okunuyor |
| (1 Eki) | **Arkadaşlar penceresi TEK EKRAN — port yarısı + OYNA** (ROADMAP #41 karar 22-24; Parça 222) | **1.1.2.** `ui/friends/friends_modal.dart` yeniden yazıldı (web #665): sekme yok; turuncu "+ ARKADAŞINI DAVET ET" → gelen istek kartları (REDDET/KABUL ET, onaysız) → gönderdiğin istekler (GERİ AL, RPC `list_outgoing_friend_requests`) → "ARKADAŞLARIN · N" / "Tüm oyuncular →" → arama → satır (rütbe, "3 haftadır", OYNA, ⋯). Yalnızca "Arkadaşlıktan çıkar" onay sorar. OYNA / ⋯ "2-4 kişilik oyun kur" → pencere kapanır, oyun ekranı açıksa Setup'a dönülür, Canlı formu o arkadaş seçili açılır (YENİ `util/live_game_request.dart`). YENİ `util/friend_since.dart`. Moderasyon kısayolu ⋯ menüsünde |
| (1 Eki) | **Tanıtım: açılış penceresi YOK + yeni kapanış penceresi** (ROADMAP #41 karar 5 + 6; Parça 223) — web + port AYNI PR | **1.1.2.** "Kelimeki Tanıtım Turu / Devam" penceresi kalktı, 1. sahne doğrudan. Kapanış: onay mührü + "TANITIM TAMAM · 4/4", "Hazırsın!", SEN/RAKİP skor kutuları, gri şeritte "SIRADAKİ: YAPAY ZEKA · KOLAY · 2 KİŞİ" (Setup seçimi; tekrar turunda yok), turuncu düğme. Web `TutorialGame.tsx` + `tutorialScript.ts` ↔ `tutorial_game.dart` (`_BitisKarti`) + `tutorial_script.dart`; `tutorial_parity_test` + Playwright tanıtım testleri |
| (1 Eki) | **İlk açılış ekranı (`IntroScreen`) TEK EKRAN — web'in yeni ilk ekranı** (ROADMAP #41 karar 14; Parça 224) | **1.1.2.** `ui/intro/intro_screen.dart` yeniden yazıldı, `ui/intro/bolge_kesiti.dart` (YENİ, web `BolgeKesiti.tsx`); beş slayt + DEVAM kalktı. Cihaz: `mobile/TESTING.md` §0.4 |
| (1 Eki) | **1.1.2 cihaz turu bulguları: Setup'ta "Tanıtım" linki YOK · skor kartında "2/4 KİŞİ" ("Oyunculu" değil) · k-lig başlığında SIRA↔OYUNCU boşluğu** (Parça 225) | **1.1.2.** `setup_screen.dart`, `stats_api.dart`, `score_card_modal`/`player_score_card_modal`/`game_history_modal`, `leaderboard_modal.dart`; yeni `score_labels_parity_test.dart` |
| (1 Eki) | **Eğitim balonu SIRASI — menü · anlam · zoom · hamleler · torba · mesaj, birer kez, 2. turdan sonra 4'er tur arayla; zoom artık açılışta çıkmıyor** (Parça 226) — web + port AYNI PR | **1.1.2.** `util/onboarding.dart`, `storage/flags_store.dart`, YENİ `ui/game/onboarding_hints.dart` + `ui/game/hint_bubble.dart`, `game_header.dart`, `board_widget.dart`, iki oyun ekranı. Cihaz: `mobile/TESTING.md` §1.9.1 |
| (1 Eki) | **Yatay iPad'de alt düğmeler ~10 pt taşıyordu → oyun başlığı web geometrisine indi** (kartın üstü 88 → 62, web 63; "← Geri" yine logonun altına taşan etiket, dokunma alanı satırın tam boyu) (Parça 227) | **1.1.2.** `ui/game/game_header.dart`, `ui/tap_target.dart` (`TapTargetScope`), `board_fit.dart` yorumu; testler `board_fit_test`, `online_game_screen_test`, `game_header_test`, `layout_parity_test`. Cihaz: Geri/logo/avatar/skor kutusu dokunuşları yeniden denenmeli |

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

## 0. FAZ B — Google Play yayını — ✅ **KAPANDI: PLAY PRODUCTION'DA YAYINDA** (24 Eylül 2026)

`1.1.0 (665)` Play production gönderimi #19 ile 24 Eylül 2026'da yayına
girdi (künye: `mobile/docs/surumler.md` → "1.1.0 (665)"). Bölümün tamamı
(0.A sayacı başlatan minimum · 0.B 14 gün işlerken paralelde · 0.C Console
formları · 0.D vitrin varlıkları) başlıkları değişmeden arşivde:
`docs/decisions/roadmap-arsiv.md`. İşletim kaynağı
`marketing/play-store/console-formlari.md`.

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

> **1 Ekim 2026:** `main`'de (kesim), 1.1.2 (831) iki mağazada incelemede — sahaya inince arşive.

## 30. Port anonim cihaz damgası (`anon_id`) — **KISMEN: `game_starts`/`game_finishes`/`guest_visits` ✅ (#601) · `tutorial_events` AÇIK** (15 Eylül 2026)

🚆 **Durum (26 Eylül 2026): son halka TRENDE** — `tutorial_events` da
`anon_id` yazıyor (`SupabaseGamesGateway._damga()`, taslak PR, #35 ile
birlikte; Parça 217). Cihaz paydasına dönüş BİLEREK ertelendi, karar
1.1.2'nin sahadaki payı ölçülünce (`docs/decisions/admin-panel.md` →
"Tanıtım Turu kartı" → Güncelleme). Sahaya inince madde arşive.

⚠ **Durum (25 Eylül 2026):** #601 `main`'e girdi — port artık cihaz kodunu
(`FlagsStore.anonId()`, uygulama dizini; Keychain DEĞİL) `game_starts`,
misafir `game_finishes` ve `guest_visits`e yazıyor (sahaya bir sonraki
paketle iner). **`tutorial_events` hâlâ `'anon_id': null`**
(`games_api.dart`) — Tanıtım Turu kartının cihaz paydası için kalan tek
halka. `_damga()` hazır; gizlilik metninin (5) maddesi tanıtım turunu zaten
sayıyor, yani yeni bir veri durumu açmıyor.

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
