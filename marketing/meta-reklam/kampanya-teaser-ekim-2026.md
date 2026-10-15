# Meta teaser kampanyası — Faz 3 (Ekim 2026)

**Karar tarihi:** 7 Ekim 2026. Kullanıcı: *"Kampanya gitgide zayıfladı. Bir
teaser kampanyası olabilir"*; kanca metinleri kullanıcıdan; sıra (önce kanca,
sonra biçim), bütçe (~₺2.400) ve "görselleri sen üret" onaylandı.
**Önceki kampanya ve kapanış okuması:** `kampanya-ekim-2026.md` (§9, 7 Eki
satırı). **Ölçüt (5 Eki kararı):** ayda 2+ oyun oynayan aktif kullanıcı.

⚠ Metinler iPad'den kopyalanacağı için **kod bloğunda**.

## 0 · Önceki kampanyadan taşınan dersler

1. **Üç reklamlı test test olmadı:** bütçe set düzeyinde paylaşılıyordu, Meta
   tamamını `karusel`'e verdi (`reel` ₺5,80, `kare` ₺49,47). → **Her kolun kendi
   seti ve kendi bütçesi var.**
2. **`kare` Reels'te çöktü** (44 oturumdan 1 mağaza; görüntülemenin %87'si IG
   Reels). Kullanıcı teşhisi: çok yazı/kutu, büyük logo → yeni görsel tek cümle,
   küçük logo.
3. **Üst huni sağlam** (ziyaretçi ₺1,91 · kurulum ~₺17-31), **zayıf halka
   kurulumdan sonrası** (133 kurulum → 5 üye, ertesi gün dönüş ~%10).
4. **Meta'nın ölçüsü ölçü değil:** karar mağazaya giden oturum başı maliyet ve
   kurulum başı maliyet üzerinden. Teaser merak tıklaması toplayabilir; bu
   yüzden CTR/görüntüleme başı maliyet kazananı BELİRLEMEZ.

## 1 · Yapı — iki aşama, her aşamada TEK değişken

| | Aşama 1 · Kanca | Aşama 2 · Biçim |
|---|---|---|
| Süre / bütçe | **5 gün** (9 Eki kararı; önce 3'tü) · 3 set × ₺100/gün = **₺1.500** | 4 gün · 4 set × ₺100/gün = **₺1.600** |
| Değişen | Yalnızca metin (görsel aynı) | Yalnızca biçim (kazanan kancayla) |
| Kollar | `h1` · `h2` · `h3` | Kontrol (eski karusel) · yeni kare · teaser karusel · yeni reel |
| Etiket | `meta-h1` · `meta-h2` · `meta-h3` | `meta-karusel` (kontrol) · `meta-kare2` · `meta-kar2` · `meta-reel2` |

Kampanya hedefi **Trafik**, optimizasyon **Yönlendirme sayfası görüntülemeleri**
(önceki kampanyayla aynı; kıyas bozulmasın). **Bütçe ayar düzeyi: reklam seti,
paylaşılan DEĞİL** (CBO kapalı). Üç/dört set aynı kitle; Meta'nın **A/B Test
(Deneyler)** aracı setleri çakışmasız böler — kullanılacak.

**Kitle:** önceki sette olduğu gibi (tüm mobil, 18+, Türkiye, Türkçe). Yaş
daraltma YOK; kırılım okunacak (önceki kampanyada sonuçların ~%40'ı 55+).

### 1.1 · Kanca metinleri (kullanıcı, 7 Eki)

| Etiket | Görsel metni | Açı |
|---|---|---|
| `h1` | Bu alıştığınız kelime oyunlarından **değil.** | kimlik / fark |
| `h2` | Klasik kelime oyunlarından **sıkıldınız mı?** | soru (olumsuz çerçeve — bilerek deneniyor) |
| `h3` | Değişik bir kelime oyunu arıyorsanız **Kelimeki'ye gelin.** | davet |

Kural: rakip adı YOK ("klasik kelime oyunları" yeterli); "en iyi/tek" gibi
üstünlük iddiası YOK.

### 1.2 · Aşama 1 — görseller (ÜRETİLDİ)

`npm run build && npm run generate-meta-teaser` →
`marketing/meta-reklam/teaser/kelimeki-teaser-{h1,h2,h3}-{feed-1080x1350,story-1080x1920}.png`
(altı dosya). Üretici `scripts/meta-teaser/`: tek cümle, küçük logo, rozet/tahta
YOK; story'de içerik Instagram'ın üst %14 / alt %20 bandının dışında (ölçülüyor).

Yerleşim: akış (feed) ve Reels/hikâye için AYRI görsel — "Yerleşimleri
özelleştir" ile feed görseli akışa, story görseli Reels + hikâyeye atanır
(aynı kareyi her yere kırpmak `kare`'nin sorunlarından biri olabilir).

```
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h1-feed-1080x1350.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h1-story-1080x1920.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h2-feed-1080x1350.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h2-story-1080x1920.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h3-feed-1080x1350.png
https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-h3-story-1080x1920.png
```
(Bağlantılar bu dosyalar `main`'e girince çalışır.)

### 1.3 · Aşama 1 — reklam metni (ÜÇ kolda AYNI; hook görselde)

**Birincil metin**
```
Kelime kur, bölgeni büyüt. Rakibin bölgesine girersen vergisini ödersin 😏

🤖 Yapay zekaya karşı ya da arkadaşlarınla
🆓 Ücretsiz · reklamsız · satın alma yok
✈️ İnternetsiz de oynanır
```
**Başlık:** `Kelimeki — ücretsiz Türkçe kelime oyunu` · **Açıklama:** `App Store ve
Google Play'de` · **Eylem çağrısı:** `İndir` (yoksa `Şimdi Yükle`/`Daha Fazla
Bilgi`). Metne link YAZMA, # YOK, marka satırı YOK (`kampanya-ekim-2026.md` §4.2).
Reklam düzeyi ayarları (çok reklamverenli kapalı, Advantage+ kreatif kapalı,
müzik/rötuş kapalı, takip "Ayarla'ya basma") önceki kampanyayla aynı (§4.1).

**URL (İnternet Sitesi Adresi alanı):**
```
https://kelimeki.com/?ref=meta-h1
https://kelimeki.com/?ref=meta-h2
https://kelimeki.com/?ref=meta-h3
```
⚠ `{{placement}}` son eki KULLANMA: etiket `ct=` ile App Store'a da taşınıyor,
iOS indirmeleri yerleşim başına parçalanınca Apple "yeterli veri yok" der ve
iOS atfı görünmez olur. Yerleşim kırılımı Meta'nın KENDİ ekranından
(Kırılımlar → Yerleşim) okunur; bizim tablo yerleşimi görmez.

## 2 · Aşama 2 — biçimler (Aşama 1 kazanınca üretilecek)

Kazanan kancayla, bu sefer yalnızca biçim değişir. Kontrol kolu eski karusel
(eski metin, `meta-karusel`) — yeni bir kreatifin işe yaradığını ancak onun
₺17-31 kurulum başı referansına karşı söyleriz.

- **Kare:** ⚠ **9 Eki 2026'da DEĞİŞTİ: Aşama 1 TAHTALI görsellerle başladı** (kullanıcı kararı,
  `…-tahta-*` dosyaları) — yani aşağıdaki (a)/(b) ayrımı artık yok: Aşama 1'in
  kazananı zaten tahtalı. "Tahta işe yarıyor mu" sorusunu Aşama 2'de sade kolu
  EKLEYEREK ölçmek gerekir (`kelimeki-teaser-h*-feed/story` sade dosyalar hazır).
  Eski tarif: 4:5 + 9:16 ayrı üretim; iki varyant: (a) yalnızca tipografi
  (Aşama 1'in kazananı), (b) tipografi + dört köşe renkli bölgesiyle tahta
  kesiti (`GameBoardPreview`). Mağaza rozeti/kutu YOK. **(b) için prototip
  hazır:** `npm run generate-meta-teaser -- --tahta [--h1]` (sağ alta taşan
  tahta; H1 önizlemesi `teaser/kelimeki-teaser-h1-tahta-*.png`). Story'de tahtanın
  alt satırı Instagram yanıt bandına girer (dekoratif, kabul).
- **Karusel (teaser) — ÜRETİLDİ (15 Eki 2026, ajan):** 4 kart, 1:1 (1080×1080),
  `npm run build && npm run generate-meta-teaser -- --karusel` →
  `marketing/meta-reklam/teaser/kelimeki-teaser-karusel-{1..4}-1080x1080.png`.
  Kart 1 = h3 kancası ("Değişik bir kelime oyunu arıyorsanız Kelimeki'ye gelin." +
  "Kaydır →") · kart 2 = "Kelime kur, bölgeni büyüt." + gerçek 4 kişilik tahta
  (`GameBoardPreview`) · kart 3 = "Rakibin bölgesine girersen vergisini ödersin." +
  karşılamanın `BolgeKesiti`si (FA/SAAT/TA, +7 ve "Vergi: puanın 1/3'ü rakibe") ·
  kart 4 = "Yapay zekaya karşı ya da arkadaşlarınla." + ücretsiz · reklamsız · satın
  alma yok · internetsiz de oynanır. Kart 2-3 üretimdeki bileşenlerden gelir (kural
  değişirse görsel de değişir). Rakip adı / üstünlük iddiası YOK. **Reklam kurulumu:**
  Aşama 2 kampanyasında `Kare2` setini çoğalt → `Kar2`; reklam biçimi **Carousel**
  (çoğaltılan reklam tek görselde kalıyor, biçimi elle değiştir), 4 kart sırayla,
  "Kartları otomatik sırala" KAPALI, "tek medya/koleksiyon" kapalı, kart başına URL
  `https://kelimeki.com/?ref=meta-kar2`, ana metin/başlık/açıklama/İndir `Kare2` ile
  aynı. İlk görsel dosyaları `main`'e girince indirme linkleri
  `https://github.com/alpcapa/kelimeki/raw/main/marketing/meta-reklam/teaser/kelimeki-teaser-karusel-N-1080x1080.png`.
  (Eski "iki rozetli" `sponsored-2026-08` kartları kontrol referansı olarak kaldı.)
- **Reel:** 7-10 sn; ilk 1,5 sn'de kanca yazısı; kapanışta **mağaza butonlu**
  kart ("Link bio'da" reklamda yanlış). Organik shorts'tan
  (`marketing/shorts-2026-10/`) yeniden kurgulanır. **Kendi setinde ve kendi
  bütçesiyle** (önceki kampanyada aç bırakıldı).

## 3 · Karar kuralları (BAŞLAMADAN yazıldı)

- **Kazanan ölçüsü:** reklam başına **mağazaya giden oturum başı maliyet**
  (`web_sessions`, §5 sorgusu), sonra kurulum başı maliyet (Android GA4 /
  Play Install Referrer; iOS ASC `ct=`). **Eşik (9 Eki 2026 netleştirildi):**
  kol başına en az **150 karşılama oturumu VE 40 mağaza oturumu** olmadan
  kazanan ilan edilmez ("~100 oturum" ifadesi belirsizdi). **Fark kuralı:**
  mağazaya giden oturum başı maliyet farkı göreli **%25'ten azsa BERABERE**
  sayılır (bu örneklemde daha küçük fark gürültü); berabere ise kanca seçimi
  veriye değil marka tercihine kalır.
  *Gerekçe (hesap, ölçüm değil):* ₺100/gün/set ≈ 57 görüntüleme/gün (₺1,76,
  önceki kampanya) ve %24 mağaza oranı → 5 günde kol başına ~285 görüntüleme,
  ~68 mağaza oturumu; 3 günde ~170/~41 olurdu ve ancak ~9-10 puanlık mağaza
  oranı farkı gürültüden ayrılırdı (5 günde ~7 puan). 5 gün 10-14 Ekim'i,
  yani hafta sonunu da hafta içini de kapsar.
- **Kalite kapısı (YALNIZCA Aşama 2'de):** kazananın 2+ oyun başlatan oranı ve
  ertesi gün dönüşü kontrolden belirgin kötü olmamalı ("kurulum ucuz ama
  oynamıyorsa kazanan sayılmaz"). ⚠ **Aşama 1'de ÖLÇÜLEMEZ:** kontrolün 2+ oyun
  oranı ~%2 → kol başına 3-6 kişi; Aşama 1 yalnızca üst huniyle karar verir.
- **Erken durdurma:** bir kol 40 oturumda mağaza oranı %5'in altındaysa
  KAPATILIR (`kare` vakası). Bunun dışında ilk 2 gün dokunulmaz.
- **Etiket yeniden kullanılmaz** (`kampanya-ekim-2026.md` §8).
- **Atıf notu (11 Eki'de İKİ kez gözden geçirildi — §5 son satır):** `ct=` ASC'de
  `pt=` varsa tanımlama GEREKMEDEN görünür (`meta-karusel` böyle göründü); h1/h2/h3'ün
  11 Eki'deki yokluğu ASC'nin **5 farklı Apple hesabı eşiğinden** (+ gecikme): kol başına
  5 kurulum olmadan satır ÇIKMAZ. Eski "küçük sayıları gizleyebilir" notu DOĞRUYMUŞ → iOS kolları arası fark okunamazsa karar Android
  + mağaza oranı + web oturumlarıyla verilir.

## 4 · Başlamadan önce (kullanıcıda)

1. ✅ **Hesap harcama limiti (9 Eki 2026):** ₺6.000'e çıkarıldı ve kaydedildi; sıfırlanma **aylık (her ayın 1'i)**, ekimde ₺1.683,78 harcandı → **₺4.316,22 kaldı**, plan (~₺2.500) sığar. Limit vergi/ücret içermez; karttan çekilen tutar daha yüksek olur. (Önceki 'birikimli, ~₺755 kaldı' varsayımı yanlıştı.)
2. **Zamanlama:** kapanışın kesin kurulum sayıları 8-9 Ekim'de oturuyor;
   Aşama 1 en erken **10 Ekim**'de başlar. Kapanış sayıları 9 Eki'de okundu
   (103 kurulum, ~₺21,8) → bu şart geçti; "yarın" teknik bir zorunluluk
   DEĞİL, tarih "en erken". **Önerilen:** bugün kur, reklam incelemesi
   bitsin, **10 Ekim 00:00 (TSİ) için zamanla** (ilk gün tam bütçeyle başlar);
   üç set AYNI anda başlamalı. Başlangıç tarihi kararı kullanıcıda.
3. ✅ Görseller `main`'de (PR #820, 9 Eki 2026) — indirme linkleri çalışır.

## 5 · Yayın kütüğü

| Ne zaman | Ne | Kaynak |
|---|---|---|
| 7 Eki 2026 | Plan onaylandı; Aşama 1 görselleri üretildi (`npm run generate-meta-teaser`, 6 PNG) | Kullanıcı kararı |
| 9 Eki 2026 | **Karar (kullanıcı): Aşama 1 = 5 gün (₺1.500), kazanan ölçütü = mağazaya giden oturum başı maliyet; eşik kol başına 150 karşılama + 40 mağaza oturumu, fark <%25 → berabere; kalite kapısı Aşama 2'ye taşındı.** Toplam plan ₺3.100 (Aşama 1 ₺1.500 + Aşama 2 ₺1.600), ekim limitinin kalanına (₺4.316,22) sığar; vergi limite dahil değil. Gerekçe §3'te | Kullanıcı kararı |
| 9 Eki 2026 ~13:19 | **AŞAMA 1 BAŞLADI (kullanıcı, Ads Manager).** Kampanya `Kelimeki · Ekim 2026 · Teaser Aşama 1` (Trafik, reklam seti bütçesi, harcama sınırı ₺1.800); üç set `h1`/`h2`/`h3` (her biri ₺100/gün, İnternet Sitesi, yönlendirme sayfası görüntülemeleri, En yüksek hacim, Türkiye 18+ Türkçe, Advantage+ hedef kitle, manuel reklam alanları: Akış + Hikayeler/Reels, Audience Network KAPALI) ve üç reklam (URL `?ref=meta-h1/h2/h3`). **Görseller TAHTALI** (`…-tahta-feed` 4:5 + `…-tahta-story` Dikey 9:16, "Meta AI ile ayarlandı" kapalı); ana metin/başlık/açıklama/İndir üçünde aynı, kanca görselin içinde. Reklamlar 13:19'da açıldı, üçü de **Aktif**. ⚠ **Plandan sapmalar:** (1) başlangıç **bugün** (10 Eki 00:00 DEĞİL) — kopyalanan setin başlangıcı Meta'da kilitli; h1 seti 11:14'te, h2/h3 kopyaları ~12:51'de başlamış sayıldı, ama teslimat reklamlar açılınca (13:19) başladı; (2) **tahtalı** görsel (plan sadeydi); (3) bitiş 14 Eki ~11:14 (kopyalarda aynı olduğu ekranda doğrulanmadı); (4) kampanya **5 gün ≈ ₺1.500**, ilk gün kısmi. İlk 2 gün (11 Eki 13:19'a kadar) dokunulmaz; ilk okuma 11-12 Eki. Eski kampanya (`…Trafik`) 'Tamamlandı' idi, anahtarı **kapatıldı** (kullanıcı, 9 Eki) | Kullanıcı bildirdi (ekran görüntüleri) |
| 10 Eki 2026 08:54 | **ARA ÖLÇÜM #1 (~19,5 saat, Meta Ads Manager mobil; üçü de Aktif, müdahale YOK).** Meta'nın "Yönlendirme sayfası görüntüleme" sayısı / sonuç başı maliyet / harcama: **h3 58 · ₺1,44 · ₺83,34**; **h2 40 · ₺1,88 · ₺75,33**; **h1 35 · ₺2,12 · ₺74,10**. ⚠ **Karar DEĞİL:** (1) bunlar Meta'nın kendi LPV'si, §3'ün ölçütü değil (`web_sessions` mağazaya giden oturum başı maliyet); (2) eşik (kol başına 150 karşılama + 40 mağaza oturumu) çok uzakta; (3) h3 harcamayı biraz fazla çekmiş (₺83 vs ₺74-75), yani ucuz LPV kısmen teslimat dengesizliği; (4) erken durdurma kuralı (40 oturumda mağaza oranı <%5) `web_sessions`ten okunmadan işletilemez — bu ölçümde okunmadı. İlk 2 gün (11 Eki 13:19'a kadar) dokunulmaz; ilk gerçek okuma 11-12 Eki | Kullanıcı bildirdi (ekran görüntüsü) |
| 10 Eki 2026 (öğleye doğru) | **Ara ölçüm #2 — `web_sessions` (9 Eki 13:00 sonrası), mağaza adımı görülen / oturum:** h3 8/54 (%15) · h2 4/36 (%11) · h1 5/36 (%14); karşılaştırma için `meta-karusel` 4/10, `instagram` 3/13. Hiçbir kol 40 oturumun altında %5'e düşmedi (erken durdurma tetiklenmedi); h2/h1 henüz 36 oturumda, eşik dolmadı → **karar yok**, müdahale yok. Oyun yolu: 105 oturum yalnız `landing`te kaldı, 24 `store`, 15 `app`. Uygulama tarafı (yeni gelen oyunu bitirmiyor) `docs/decisions/funnel-v2.md` → "Okuma: yeni üyeler oyunu bitirmiyor" | Canlı `web_sessions` okuması (ajan) |
| 11 Eki 2026 16:33-16:35 | **GA4 + ASC okuması (kullanıcı ekran görüntüsü; bu veriler Meta'nın değil, mağaza/analitik tarafının).** **GA4** (Kullanıcı edinimi · İlk kullanıcı kaynağı, son 90 gün, **10 Eki'ne kadar**): `meta-h3` **8** kullanıcı (8 yeni, 2 geri dönen, 23dk53sn, 64 olay) · `meta-h1` **2** · `meta-h2` **1**; karşılaştırma: `meta-karusel` 75 · `google-play` 60 · `instagram` 14 · `(direct)` 260 · toplam 419. **ASC** (Analytics → Acquisition → Campaigns, 12 Tem-9 Eki, UTC): YALNIZ `meta-karusel` görünüyor — 65 gösterim, **28 indirme** (eski kampanya). **`meta-h1/h2/h3` ASC'de HİÇ yok** — kullanıcı: *Apple'da campaign olarak TANIMLANMADIĞI için görünmüyor* (⚠ **DÜZELTME, aynı gün:** bu "tanımsız" açıklaması DOĞRULANMADI, kullanıcı sözüydü. `meta-karusel` ASC'de hiç tanımlanmadan, yalnızca linkte `pt=`+`ct=` olduğu için göründü (`storeLinks.ts` her `?ref=`e ikisini de ekliyor); `meta-kare/reel` yalnız `pt`'den ÖNCEKİ trafik olduğu için görünmedi. ASIL neden (16:39, kullanıcının ASC "Generate a Campaign Link" ekranı): **ASC bir kampanyayı en az 5 FARKLI Apple hesabı kurana kadar GÖSTERMİYOR** ("To see a campaign, your app needs to be installed by at least 5 individual Apple Accounts"). h1/h2/h3'ün iOS kurulumu kol başına 5'in altında; veri gecikmesi (ASC aralığı 9 Eki'nde bitiyor, 1-2 gün geri) ikincil). ⚠ **Okuma (karar DEĞİL):** (1) GA4 sayıları (h3 8) Meta LPV'sinin (58) ve `web_sessions`in (54) çok altında → GA4 rıza/engelleyici filtresi yüzünden eksik sayıyor, kol KARŞILAŞTIRMASI için kullanılmaz; kararın kaynağı `web_sessions` (mağaza adımı) kalır. (2) iOS kolları arası fark ASC'den henüz okunamıyor (§3: gerekirse karar Android + mağaza oranı + web oturumlarıyla). (3) GA4 veri aralığı 10 Eki'nde bitiyor, ilk gün kısmi → h-kolları 1 günlük. **Yapılacak: HİÇBİR ŞEY.** ASC'de link üretmek gereksiz (site `pt=`+`ct=`'yi zaten ekliyor; dialog aynı linki elle üretir) ve eşiği değiştirmez. iOS kol karşılaştırması ASC'den büyük olasılıkla hiç okunamayacak (kol başına 5 kurulum ancak geçilirse satır çıkar, o zaman da fark okunacak sayı olmaz) → Aşama 1 kararı Android (Play `utm_source`) + mağaza oranı + `web_sessions` ile verilir (§3'ün yedek yolu) | Kullanıcı bildirdi (ekran görüntüleri) |
| 11 Eki 2026 16:42 | **META OKUMASI #3 (~51 sa; Ads Manager, reklam düzeyi, "Maksimum"; üçü de Açık, müdahale YOK).** Yönlendirme sayfası görüntüleme / sonuç başı ücret / harcama / gösterim / erişim: **h1 144 · ₺1,73 · ₺248,86 · 5.245 · 4.520**; **h2 146 · ₺1,55 · ₺226,61 · 3.873 · 3.151**; **h3 151 · ₺1,50 · ₺226,13 · 4.612 · 3.762**. Toplam **₺701,60 · 441 LPV**. Bitiş 14 Eki ("2 gün kaldı"). Ara ölçüm #1'den (10 Eki 08:54: h3 58 / h2 40 / h1 35) beri LPV üç kolda da ~2,5-4 kat arttı. ⚠ **Karar DEĞİL:** (1) Meta LPV'si §3'ün ölçütü değil; ölçüt `web_sessions` (karşılama oturumu + mağazaya giden oturum başı maliyet); (2) kollar Meta açısından BAŞA BAŞ (LPV 144-151, fark ~%5), teslimat dengesiz: h1 ₺22 fazla harcadı ama en az LPV aldı (en pahalı ₺1,73); (3) h1 gösterim/erişim en yüksek (5.245/4.520) ama LPV'ye en az dönüşüyor → kanca h1'in tıklaması zayıf görünüyor, fakat mağaza oranı henüz okunmadı; (4) erişim/gösterim = frekans ~1,16-1,24, doygunluk yok. İlk iki gün (11 Eki 13:19) DOLDU → müdahale serbest ama karar için `web_sessions` okuması gerekir (eşik: kol başına 150 karşılama oturumu + 40 mağaza oturumu) | Kullanıcı bildirdi (ekran görüntüleri) |
| 11 Eki 2026 ~16:50 | **`web_sessions` okuması (Aşama 1 başından, 9 Eki 13:19 TSİ'den beri, son oturum 11 Eki 16:40 TSİ; §5 sorgusu, ajan canlıdan okudu).** Oturum / mağazaya giden (oran) / oyun / üye: **h1 146 / 17 (%11,6) / 1 / 0**; **h2 137 / 19 (%13,9) / 3 / 0**; **h3 158 / 19 (%12,0) / 1 / 0**; `meta-karusel` (eski, artık harcamasız) 17 / 6 / 1 / 0. Cihaz (oturum; mağazaya): h1 iOS 26 (1) · Android 120 (16); h2 iOS 33 (5) · Android 104 (14); h3 iOS 29 (1) · Android 129 (18); masaüstü 0. **Mağazaya giden oturum başı maliyet (Meta harcaması ÷ mağaza oturumu):** h1 ₺248,86/17 = **₺14,64**; h2 ₺226,61/19 = **₺11,93**; h3 ₺226,13/19 = **₺11,90**. **Eşik (§3):** karşılama oturumu ≥150 → yalnız h3 geçti (158; h1 146, h2 137 sınırda); mağaza oturumu ≥40 → **HİÇBİRİ (17-19)**. **KARAR YOK.** Yine de: h1 h2/h3'ten ~%23 pahalı → §3'ün %25 BERABERE kuralının altında; h2 ↔ h3 fark ~%0 → beraber. Erken durdurma (40 oturumda mağaza <%5) tetiklenmedi, hepsi %12-14. Meta LPV'si (144/146/151) `web_sessions`le tutarlı (146/137/158) → Meta sayısı güvenilir vekil. **iOS:** kol başına yalnız 26-33 oturum, iOS mağaza oturumu 1/5/1 → ASC'nin 5 kurulum eşiği h*'leri göstermeyecek (önceki satır). **Projeksiyon:** mağaza oturumu ~0,37/saat (19/51 sa) → 14 Eki 11:14 bitişte kol başına ~35 → **40 eşiğine ulaşmama riski var**; ulaşmazsa karar kullanıcıda: eşiği düşür, kampanyayı birkaç gün uzat ya da kanca seçimini marka tercihine bırak (§3 beraberlik kuralı). Oyunu başlatan 1-3, üye 0 → oyuna geçiş sorunu `funnel-v2.md` konusu, kanca ayrımı değil | Canlı `web_sessions` okuması (ajan) |
| 12 Eki 2026 ~11:45 | **Okuma #4 — GA4 + Play + `web_sessions` (Meta harcaması bu okumada YOK, kullanıcıdan istendi).** **`web_sessions`** (9 Eki 13:19'dan 12 Eki ~11:20'ye, karşılama oturumu / mağazaya giden (oran) / oyun): **h1 197 / 23 (%11,7) / 3** (Android 161 → 22 · iOS 36 → 1); **h2 196 / 23 (%11,7) / 3** (Android 154 → 16 · iOS 42 → 7); **h3 225 / 24 (%10,7) / 4** (Android 189 → 24 · iOS 36 → 0). Eşik (§3): karşılama ≥150 → üçü de GEÇTİ; mağaza ≥40 → **HİÇBİRİ (23-24)**, ~0,3/sa → 14 Eki bitişte kol başına ~30 → **eşiğe ulaşmayacak** (11 Eki projeksiyonu doğrulandı). Mağaza oranları başa baş (%10,7-11,7). ⚠ #787'den (2 Eki) beri arka planda yüklenip görünmeyen sayfa sayılmıyor. **GA4** (İlk kullanıcı kaynağı, 90 gün, 11 Eki'ne kadar): `meta-h3` **11** · `meta-h1` **7** · `meta-h2` **5** (hepsi yeni); `meta-karusel` 75 · `google-play` 60 · `instagram` 16 · `(direct)` 270 · toplam 443. GA4 kolları eksik sayıyor (rıza/engelleyici), karşılaştırma için değil. **Play Console** (28 gün): cihaz edinimi 164 (+%125) · ilk açılış 25 (−%42) · aylık aktif cihaz 93 (+%288) · toplam kurulum 181 · mağaza ziyaretçisi ort. 9,64/gün (+%575) · mağaza dönüşümü %15,0 (−4,3 pp) · günlük aktif kullanıcı ort. 11. ⚠ Play kartları kampanya kırılımı vermiyor → kol başına Android kurulumu için UTM kırılımı istendi. **Karar YOK** (Meta harcaması + Play UTM kırılımı bekleniyor) | Kullanıcı ekran görüntüleri (GA4 · Play) + canlı `web_sessions` (ajan) |
| 12 Eki 2026 11:46 | **Okuma #4b — Meta harcaması (Ads Manager mobil, reklam seti düzeyi; üçü de Aktif).** LPV / sonuç başı / harcama: **h1 191 · ₺1,75 · ₺334,98**; **h2 210 · ₺1,54 · ₺322,71**; **h3 217 · ₺1,47 · ₺318,27** (toplam ₺975,96). Meta LPV ↔ `web_sessions` (11:20) tutarlı: 191↔197 · 210↔196 · 217↔225. **Mağazaya giden oturum başı maliyet:** h1 ₺334,98/23 = **₺14,56** · h2 ₺322,71/23 = **₺14,03** · h3 ₺318,27/24 = **₺13,26**; en pahalı ↔ en ucuz farkı **%9,8 → §3'ün %25 kuralıyla BERABERE** (11 Eki'de %23'tü, fark kapandı). Mağaza eşiği (40) hâlâ hiçbir kolda yok (23-24); bitişte ~30. ⚠ **Neden ulaşılamıyor:** plan %24 mağaza oranıyla hesaplanmıştı (eski karusel), teaser kolları **%11-12**'de → aynı bütçe yarı mağaza oturumu üretiyor; bu bir bulgu (kancalı tahtalı görsel karuselden yarı oranda mağazaya taşıyor), kollar arası fark değil. **Karar kullanıcıda** (Play UTM kırılımı hâlâ bekleniyor) | Kullanıcı ekran görüntüsü (Ads Manager) |
| 12 Eki 2026 ~11:55 | **Okuma #4c — Android kurulumu KENDİ ölçümümüzden (`funnel_events` `land`, kanal = Play Install Referrer; Play Console UTM kırılımına GEREK KALMADI).** Uygulamayı ilk açan Android cihaz / oyun başlatan / oyun bitiren / ikinci gün dönen: **h1 9 / 8 / 0 / 0** · **h2 7 / 3 / 1 / 1** · **h3 16 / 11 / 2 / 2**. Android mağaza oturumu → kurulum: h1 22 → 9 · h2 16 → 7 · h3 24 → 16. **Kol harcaması ÷ Android kurulumu** (harcama iOS'u da içerir, iOS mağaza oturumu 1/7/0 → küçük pay): h1 ₺334,98/9 ≈ **₺37** · h2 ₺322,71/7 ≈ **₺46** · h3 ₺318,27/16 ≈ **₺20**. Mağaza oturumunda BERABERE olan kollar kurulumda AYRIŞIYOR: h3 h1'den ~%46, h2'den ~%57 ucuz (§3'ün ikinci ölçüsü "kurulum başı maliyet"; %25 eşiğinin üstünde). ⚠ Sayılar küçük (7-16), yalnızca Android ve yalnızca uygulamayı AÇAN cihaz; eğilim, kesin hüküm değil. Karar kullanıcıda | Canlı `funnel_events` (ajan) |
| 12 Eki 2026 ~12:00 | **KARAR (kullanıcı): Aşama 1 14 Eki bitişine kadar dokunulmadan sürer, sonra Aşama 2 h3 kancasıyla.** Gerekçe okuma #4c: mağaza oturumunda berabere, Android kurulum başında h3 ~₺20 ↔ h1 ~₺37 / h2 ~₺46. Kapanış okuması 14 Eki öğleden sonra (ajan hatırlatıcısı kurulu): aynı üç sorgu (`web_sessions`, `funnel_events` Android `land`, Meta harcaması) — h3 öndeliğini koruyorsa Aşama 2 (§2) h3 ile kurulur; tersine dönerse kullanıcıya sorulur | Kullanıcı kararı |
| 13 Eki 2026 ~12:35 | **Okuma #5 — Meta (Ads Manager iPad + mobil, reklam düzeyi, "Maksimum"; üçü Açık, "1 gün kaldı", müdahale YOK) + GA4 + `visibility_probe`.** LPV / sonuç başı / harcama / gösterim / erişim: **h1 259 · ₺1,66 · ₺428,91 · 8.180 · 6.694**; **h2 278 · ₺1,51 · ₺418,84 · 6.911 · 5.107**; **h3 278 · ₺1,49 · ₺413,11 · 8.879 · 6.332** (toplam ≈ ₺1.261, LPV 815; harcama sınırı ₺1.800). **GA4** (İlk kullanıcı kaynağı, 90 gün, 12 Eki'ne kadar): `meta-h3` 16 · `meta-h1` 7 · `meta-h2` 6; karşılaştırma `meta-karusel` 76 · `google-play` 61 · `instagram` 16 · `(direct)` 275 · toplam 456 (rıza/engelleyici filtresi → karşılaştırma değil, ölçek göstergesi). **`visibility_probe` (12 Eki 09:47'den, yalnız mobil, son 3 gün; ham sayfa / gerçek girdili / 31-33 sn grubu):** **h1 76 / 25 / 23 (%30)** · **h2 66 / 25 / 20 (%30)** · **h3 68 / 34 / 10 (%15)**; `meta-karusel` 4 / 3 / 0. ⚠ **Okuma (karar DEĞİL; ölçüt hâlâ §3):** (1) Meta'nın LPV'si ucuz ama GERÇEK ziyareti şişiriyor: probe'ta Android + Meta girdisiz sayfaların çoğu tam 31-33 sn'de kapanıyor (`docs/decisions/admin-panel.md` → "Yığılmanın kaynağını bulma"); bu sayfalar yine de LPV sayılıyor, yani bütçenin kabaca **%15-30'u (≈ ₺200-380, hayalet olduğu KANITLANMADI) kimsenin bakmadığı sayfalara gitmiş olabilir**. (2) Hayalet payı kollar arasında FARKLI: h3 yarı yarıya düşük → h3'ün kurulum başı avantajı (#4c) kısmen "daha az boşa tıklama" olabilir, kancanın gücü tek başına değil. (3) h1/h2'nin mağaza oranı payda şişkin olduğu için ALT tahmin; h1/h2 'berabere' bulgusunu bozmaz ama h3 öndeliğini ZAYIFLATMAZ, güçlendirir. (4) Probe penceresi (12 Eki 09:47 →) kampanyanın yalnız son ~2,5 günü, Meta toplamı tamamı → 815 ile 210 doğrudan oranlanamaz. **Karar değişmedi (12 Eki ~12:00): 14 Eki bitişine kadar dokunulmaz, kapanış okuması + h3 ile Aşama 2.** Aşama 2'de ölçütlere **'girdili sayfa başı maliyet' EKLENMELİ** (hayalet sayfa Meta'ya göre ucuz görünür); probe'a `end_event` alanı #852 ile 13 Eki'de canlıya çıktı, tetikleyici bulunursa Meta tarafında da bir önlem (ör. reklam alanı/optimizasyon olayı) düşünülebilir | Kullanıcı ekran görüntüleri (Meta · GA4) + canlı `visibility_probe` (ajan) |
| 15 Eki 2026 ~16:10 | **AŞAMA 1 KAPANIŞ OKUMASI (kullanıcı ekran görüntüleri: Meta mobil · GA4 · ASC · Apple Ads · Play; ajan canlıdan `web_sessions` + `funnel_events` okudu; pencere 9 Eki 13:19 – 14 Eki 12:00 TSİ).** **Meta (final):** harcama/LPV/₺ sonuç: h1 ₺495,53 · 309 · 1,60; h2 ₺491,06 · 332 · 1,48; h3 ₺491,21 · 345 · 1,42 (toplam ≈ ₺1.478). **Bağlantı tıklaması / CPC / CTR / tıklama→LPV / erişim:** h1 354 · ₺1,40 · %3,24 · %87 · 7.515; h2 363 · ₺1,35 · %4,04 · %91 · 5.948; h3 396 · ₺1,24 · %3,19 · %87 · 7.263. **Yerleşim (LPV, grafikten yaklaşık, Instagram/Facebook):** h1 ~70/30; h2 ~80/20; h3 ~60/40 (Stories/Reels ayrımı mobil uygulamada yok). **Yaş:** h1 ve h3 yaşlıya yığılı (65+ ve 55-64 en büyük), h2 yaygın. **`web_sessions`** oturum / mağazaya giden (oran): **h1 335 / 30 (%9,0); h2 335 / 37 (%11,0); h3 375 / 42 (%11,2)**; ₺ / mağaza oturumu: 16,5 · 13,3 · **11,7** (h3 ↔ h1 %29 → %25 kuralının ÜSTÜNDE; h3 ↔ h2 %12 → berabere). Mağaza eşiği (40) yalnız h3'te geçildi. 31-33 sn yığılması (hayalet göstergesi): h1 %25 · h2 %28 · h3 %19. **`funnel_events` Android `land` (ilk açan cihaz):** h1 11 · h2 13 · **h3 27** (karusel 6) → ₺ / Android kurulum ≈ 45 · 38 · **18** (harcama iOS'u da içerir, üst sınır). **Okuma (karar DEĞİL):** (1) h3 hem mağaza oturumunda hem kurulumda önde; kurulumda h1/h2'nin ~2 katı. (2) **Hayalet-sayfa açıklaması zayıfladı:** h2'nin tıklama→LPV kaybı en düşük (%9) ve CTR'ı en yüksek, ama kurulumu yarı yarıya; yani h3'ün farkı "daha az boşa tıklama" değil. (3) **Yerleşim ve yaş de tek başına açıklamıyor:** Facebook payı h3>h1>h2 sırasında ama kurulum h3≫h2≈h1; yaş h1'de de h3 kadar yaşlıya yığılı, h1 kurulumu düşük. Kanca etkisi (h3 'davet') en olası açıklama; küçük örneklem (11/13/27) → eğilim, kesin hüküm değil. (4) Karıştırıcı faktör aranırken ölçülemeyen: yaş/yerleşim bazında KURULUM yok. **Okunamayanlar:** Play Console UTM raporu kol ayırmıyor (h1/h2/h3 "Other"da toplanıyor, yalnız `meta-karusel` ayrı satır) → Play bu karar için kullanılmaz. ASC: Campaigns'te hâlâ yalnız `meta-karusel` (5 farklı Apple hesabı eşiği), Sources'ta Web Referrer boş → iOS kol kıyası yok. GA4 (14 Eki'ne kadar): meta-karusel 78 · meta-h3 24 · meta-h2 8 · meta-h1 8 (rıza/engelleyici nedeniyle düşük, kol kıyası için kullanılmaz). **Apple Ads (son 4 hafta, bu kampanyadan AYRI):** `Rakip · kelimelik` $24,26 · 54 dokunuş · 8 kurulum · $3,03/kurulum (%14,8 dönüşüm); `Genel · exact` $0,59 · 94 gösterim · 1 kurulum → genel set neredeyse hiç gösterim almıyor (teklif/anahtar kelime gözden geçirilmeli). **KARAR (12 Eki'deki yön doğrulandı, kullanıcı onayı bekleniyor): Aşama 2 h3 kancasıyla.** Aşama 2 önerileri: ölçütlere "girdili sayfa başı maliyet" eklenir (§3); isteğe bağlı deney: aynı h3 kancası, tek kol yalnız Instagram, tek kol yalnız Facebook (yerleşimi kanca sabitken ölçmek için). Yaş kırpma için kanıt YOK. Bütçe: ekimde kalan ≈ ₺2.800 (₺4.316,22 − ≈₺1.478); kullanıcıdan Aşama 2 tavanı beklenir | Kullanıcı ekran görüntüleri + canlı `web_sessions`/`funnel_events` (ajan) |
| 15 Eki 2026 ~16:37 – akşam | **AŞAMA 2 YAYINLANDI (kullanıcı, Ads Manager mobil; ekran görüntüleri).** Kampanya `Kelimeki · Ekim 2026 · Teaser Aşama 2` (Trafik, reklam seti bütçesi), İKİ set, her biri ₺150/gün, **15 Eki 16:37 – 21 Eki 14:22 (TSİ)**, kitle 18+ Türkiye Türkçe (Aşama 1 ile aynı): **`Kare2`** = h3 tahtalı kare görseli (Aşama 1'in kazanan reklamı, kontrol), URL `?ref=meta-kare2`, CTA İndir; **`Kar2`** = 4 kartlı teaser karusel (kart 1 h3 kancası, §2), URL `?ref=meta-kar2` her kartta, CTA İndir, "Kartları otomatik sırala" KAPALI. Yayın sırası: `Kare2` 16:37'de (inceleme bitince ilk harcama ₺4,91 → ₺7,12 / 1 LPV akşam saatlerinde); `Kar2` aynı akşam sonradan (reklam "Processing"/incelemede). ⚠ **Kurulum tuzakları (bir sonraki seferde):** (1) **mobil Ads Manager'da çoğaltılan reklam carousel biçimini/kartları KAYDETMİYOR**, CTA "Send message" ile geliyor ve "WhatsApp number required" / "Missing Messenger Destination in Child Item" hatası veriyor → her kartta Destination URL'yi (Website) seçmek ve CTA'yı İndir yapmak gerekti; (2) karusel reklamı ilk olarak `Kare2` SETİNİN İÇİNE girdi (aynı sette iki reklam = bütçe paylaşımı, 28 Eylül `kare`/`reel` vakası) → setin çoğaltılıp reklamların ayrıştırılmasıyla `Kar2` AYRI sete alındı; (3) **Duplicate Ad Set sihirbazı optimizasyonu "Link Clicks"e çevirdi** (orijinal: yönlendirme sayfası görüntülemeleri) ve Instagram Reels'i yerleşimlerden düşürdü → **yerleşimler DOĞRULANDI (15 Eki akşamı, iki ekran görüntüsü): `Kare2` ve `Kar2` AYNI — Mobil · Facebook+Instagram · FB Akış, IG Akış, FB/IG Hikâye, IG Reels, FB Reels; Audience Network ve öteki alanlar kapalı.** Optimizasyon hedefi (yönlendirme sayfası görüntülemeleri ↔ bağlantı tıklaması) `Kar2` için HÂLÂ doğrulanmadı (bir sonraki okumada ilk iş); (4) Meta "Advantage+ creative enhancements" önerisi (+6 puan) UYGULANMADI, kreatifler aynen yayınlanmalı. **Okuma yönergesi:** `Kare2` ↔ `Kar2` karşılaştırması aynı pencerede (15 Eki 16:37 sonrası). Ölçütler §3 + **girdili sayfa başı maliyet** (hayalet sayfa). Eşik: kol başına 40 mağaza oturumu. Aşama 1 bütçesi ≈ ₺1.478 + Aşama 2 en fazla ₺1.800 (2 set × ₺150 × 6 gün) → ekim limiti (₺6.000) içinde kalır (vergi hariç) | Kullanıcı ekran görüntüleri |
