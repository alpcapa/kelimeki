# Ölçüm v2 — tek olay tablosu, tüm platformlar (PLAN, 24 Eylül 2026)

> Durum: **PLAN — kodu yazılmadı.** Kullanıcı kararı (24 Eylül 2026):
> *"Kendi tablomuz ve (a), planı yaz. Ayrıca tabloda revisit de görmek
> istiyorum. 2+ kaç kişi?"* Bu dosya uygulanırken güncellenir; bittiğinde
> "PLAN" başlığı kalkar ve dosya bir karar kaydına döner.

## Neden

Kaynak Hunisi (`admin_source_funnel`) dört ayrı kaynaktan besleniyor
(`guest_visits`, `game_starts`, `game_finishes`, `profiles`). Bu kaynaklar
farklı tarihlerde başlamış (21 Ağu · 22 Ağu `is_guest` · 31 Ağu `anon_id`),
her biri "kişi"yi farklı tanımlıyor ve mobil uygulamayı yarım görüyor
(ziyaret yok, cihaz kodu yok, her şey `app` → "Diğer"). 24 Eylül'de aynı gün
üç tur yama yapıldı (#621 Kişi/Oyun, #622 Oynayan Üye) ve kullanıcı yine
*"bu rakamlara hâlâ güvenemiyorum"* dedi. Ölçülen hatalar:

- 90 günlük "Bitiren 5" gerçekte **321 misafir bitişi**ydi; 167'sinde cihaz
  kodu yoktu (kampanya kodun eklenmesinden önceydi).
- "Başlatan 121" gerçekte **en az 214**'tü (21–26 Ağu'da 108 başlangıç
  `is_guest` bayraksızdı, 20 Ağu hiç kaydedilmemişti).
- TOPLAM satırı web ile uygulamayı farklı ölçülerle topluyordu (üye oranı
  %2,8 göründü, web için gerçekte %2,0).

Karar: yamaya DEVAM ETME, ölçümü baştan kur. Pazarlama Play yayını ile
başlayacak (*"Gerçek resmi göremezsek başarılı olamayız"*).

## Kullanıcının istediği tablo

Kanal × platform (web · iOS · Android) satırları, sütunlar:

| # | Sütun | Tanım |
|---|---|---|
| 1 | **Land** | Pencerede İLK KEZ gelen cihaz (web: ilk sayfa, uygulama: ilk açılış) |
| 2 | **Geri gelen (2+ gün)** | Bu cihazlardan land gününden SONRA en az bir başka gün açan |
| 3 | **Üye** | Bu cihazlardan hesap açan |
| 4 | **Oyun başlatan** | Bu cihazlardan en az bir oyun başlatan (misafir ya da üye fark etmez) |
| 5 | **Oyun bitiren** | Bu cihazlardan en az bir oyun bitiren; yüzdesi **Oyun başlatan**'a göre |

2–4'ün yüzdesi Land'e göre, 5'inki Oyun başlatan'a göre. **KOHORT**: bütün
sütunlar AYNI cihaz kümesini sayar (pencerede land edenler), yani oran
tanım gereği ≤ %100 ve iki birim (kişi ↔ oyun) yan yana gelmez. Oyun
adetleri ikincil bir görünümde (Oyun / Kişi) kalabilir.

## Kararlar

1. **Kendi tablomuz, üçüncü taraf YOK.** Firebase Analytics uygulamada kurulu
   ama web'e GA4 eklemek cookie + onay penceresi ister ve veri Google'da
   durur. Firebase uygulamada kendi işini yapmaya devam eder, huni ona
   bağlanmaz.
2. **Cookie YOK.** Kimlik = cihazda duran rastgele anonim kod. Web:
   `localStorage['kelimeki:anon-id']` (`utils/visitTracking.ts`, bugün de
   var). Uygulama: `FlagsStore.anonId()` (bugün hata telemetrisi için var).
3. **Mobil ölçüm (a) seçeneğiyle:** incelemedeki Play #19'a GİRMEZ; #19
   onaylandıktan sonraki İLK güncellemeye girer. **Pazarlama bütçesi o
   güncelleme yayına girince açılır** (kullanıcı kararı). Kapı: yeni admin
   tablosunda Android satırlarının gerçek veriyle görünmesi.

## Veri modeli (tek tablo)

```
funnel_events
  anon_id    uuid        -- cihaz kodu; HESAP KİMLİĞİ YOK (user_id kolonu YOK)
  platform   text        -- 'web' | 'ios' | 'android'
  event      text        -- 'land' | 'visit' | 'signup' | 'game_start' | 'game_finish'
  channel    text null   -- YALNIZCA 'land' satırında dolu (tek kaynak)
  day        date        -- Europe/Istanbul günü; SAAT TUTULMAZ (aşağı bkz.)
  app_version text null
```

- `land`: cihaz başına TEK satır (unique `anon_id` where `event='land'`).
  Kanal yalnızca burada durur; öteki olaylar kanala `anon_id` üzerinden
  land satırından bağlanır → "hangi kanal" sorusunun tek cevabı olur.
- `visit`: cihaz × gün başına TEK satır (unique `anon_id, day`). "2+ gün"
  sütunu bundan: land gününden farklı ≥1 `visit` günü.
- `signup`, `game_start`, `game_finish`: her olay bir satır (oyun adetleri
  ikincil görünüm için gerekli).
- **Neden saat değil gün:** `signup` satırının saati `profiles.created_at`
  ile eşleştirilirse cihaz kodu hesaba bağlanabilirdi — Gizlilik 6. bölümün
  "anonim kod hesabınızla ASLA eşleştirilmez" taahhüdü. Gün çözünürlüğü
  kohort için yeter, eşleştirmeyi pratikte imkânsız kılar.
- Yazma yolu: `log_funnel_event(...)` RPC'si (`security definer`, `anon` +
  `authenticated` execute). Tabloya doğrudan grant YOK (istemci okumuyor).
  RPC `land`ı idempotent yazar, `visit`i günde bir, bilinmeyen `event`/
  `platform`u reddeder, `land`ı olmayan cihazın öteki olaylarını da kabul
  eder (sıra garantisi yok) ama raporda o cihaz land kümesinde olmadığı
  için sayılmaz.
- Okuma: `admin_funnel(p_days, p_platform default null)` — `is_admin()`
  kapısı, kanal × platform satırları, yukarıdaki beş sütun + oyun adetleri.

## Kanal — platform platform

| Platform | Kaynak | Değer |
|---|---|---|
| Web | `?ref=` ilk temas (`captureUtmSource`, bugünkü mekanizma) | etiket ya da `direkt` |
| Android | **Play Install Referrer** — reklam linki `...&referrer=utm_source%3Dinstagram`; ilk açılışta okunur | etiket ya da `play-organik` |
| iOS | Apple kişi bazında vermiyor (MMP + ATT izni gerekir — yapılmayacak) | `app-store` |

iOS'ta kanal kırılımı App Store Connect → Analytics → **Kampanyalar**'dan
(`ct=` parametreli App Store linkleri) toplu okunur. Admin tablosunda iOS
tek satırdır ama sütunları (land → bitiren) TAM ölçülür.

⚠ **Aynı insan web + uygulama = iki cihaz.** Hesaba bağlamadığımız için
birleştirilemez; bilinçli kabul.

## Mevcut kullanıcı tuzağı

Yayından sonraki ilk açılışta HER cihaz `land` yazar — eski kullanıcılar
"yeni gelen" gibi görünür ve ilk haftaların kohortunu şişirir. Çözüm:
cihazda ölçüm v2'den ÖNCE iz varsa (web: `kelimeki:anon-id` zaten var;
uygulama: `anonId` ya da onboarding bayrağı zaten var) `land` satırı
`channel = 'mevcut'` ile yazılır ve rapor bu kanalı kohorttan çıkarır.

## İş sırası

1. **PR 1 — sunucu + web (hemen, dondurmadan bağımsız):**
   migration (`funnel_events` + iki RPC, grant'ler) · `utils/funnelEvents.ts`
   (saf: olay adı/platform/kanal türetme) + `main.tsx`'te land/visit
   (kapı kararından ÖNCE — karşılama katmanı ve SPA ikisi de sayılsın) +
   signup/game_start/game_finish çağrı yerleri · yeni admin tablosu
   ("Huni v2", Kaynak Hunisi'nin YANINDA; eskisi yerinde kalır) ·
   `npm run verify-funnel-events` · `PrivacyModal` + `/gizlilik/` metni.
2. **PR 2 — mobil (Play #19 onayından SONRA, ilk güncelleme):** aynı RPC,
   `FlagsStore.anonId()`, ilk açılış = land, uygulama öne gelişi = visit,
   `play_install_referrer` paketi (Android), iOS sabit kanal. Olay/platform
   adları web kaynağından okunarak parite testi (`funnel_events_parity_test.dart`
   → `web-ci.yml` `paths`'e `src/utils/funnelEvents.ts`). ROADMAP "Sıradaki
   sürüme binecekler" satırı. **Beyan formları büyük ihtimalle DEĞİŞMEZ**
   (24 Eyl 2026'da okundu): Play Data safety zaten "Device or other IDs →
   `anon_id`" ve "App interactions → ziyaret ve oyun başlangıç olayları"
   (Analytics) diyor; App Store gizlilik etiketi zaten "Device ID" ve
   "Product Interaction — Not Linked, Analytics" diyor. `funnel_events` aynı
   türler, aynı amaç, hesaba bağlı değil. Uygularken doğrulanacak TEK şey:
   Play Install Referrer'ın ayrı bir beyan gerektirip gerektirmediği →
   `marketing/play-store/console-formlari.md`.
3. **Pazarlama kapısı:** PR 2'nin sürümü Play'de yayında + admin tablosunda
   Android land satırı görünüyor → bütçe açılır.
4. **Emeklilik:** Huni v2 30 gün veri topladıktan sonra Kaynak Hunisi
   kaldırılır (`admin_source_funnel` + tablo bileşeni). `guest_visits`
   KALIR (cihaz/OS tabloları onu kullanıyor), `game_starts`/`game_finishes`
   kendi admin kullanımları taranıp karar verilir.

## Açık sorular (uygulamaya başlarken)

- "Land" web'de karşılama katmanı mı yoksa uygulama mı sayılır? Plan:
  ikisi de (ilk sayfa ne olursa). Yolculuk tablosu hangisi olduğunu zaten
  ayırıyor.
- Bot/tarayıcı ön-yüklemesi (Instagram uygulama içi tarayıcı): ilk sürümde
  filtre YOK; `land` sayısı `guest_visits`'le kıyaslanarak izlenir.
