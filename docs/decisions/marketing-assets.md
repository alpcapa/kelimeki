# Reklam/Pazarlama Görselleri — Karar Kaydı

> docs/decisions/'e taşındı (context split, 24 Ağustos 2026). scripts/sponsored-post, scripts/play-store, scripts/kapak, scripts/reel.

**Bu dosya GÖRSELLERİ anlatır; kanal başına GÖNDERİ metinleri ayrı durur**
(16 Eylül lansman turu üç kanalda birden çıktı, üçünün metni/linki/etiketi
farklı): `marketing/app-store/instagram-lansman.md` ·
`linkedin-lansman.md` · `facebook-lansman.md`. Her biri kendi `?ref=`
etiketini, kare setini ve yayın kütüğünü taşır.

## Reklam Görselleri (`scripts/sponsored-post/`, 20 Ağustos 2026)

Kullanıcının kendi network'üne yaptığı organik paylaşım beğeni aldı ama tek
bir üyelik/oyun getirmedi; bunun üzerine 6 gün × 433 TL'lik sponsorlu bir
carousel için 5 kare görsel üretildi (1080×1080, 2× ölçek). Çıktılar
`marketing/sponsored-2026-08/` (5 PNG + `metin.md`: LinkedIn ve Meta metin/
hashtag setleri, reklam kurulum notları).

```bash
npm run build                          # derlenmiş CSS ŞART (aşağı bkz.)
node scripts/sponsored-post/build.mjs  # 5 PNG'yi yeniden yazar
npm run generate-reel                  # kelimeki-reel.mp4 (bkz. aşağıdaki reel notu)
npm run generate-shorts                # Reels/Shorts/TikTok için 3 kısa video (bkz. "Kısa videolar")
node scripts/generate-klig-logo.mjs    # "k-lig" wordmark'ının tek başına SVG/PNG/JPG hâli
```

⚠ Sondaki iki komut `package.json`'da BİLEREK yok (mağaza/vitrin işleri gibi
yılda birkaç kez koşuluyor) — yani `npm run` listesinde aramayın. Özellikle
`generate-klig-logo.mjs`, `KLigMark.tsx`'ten ALREADY-TRACED path verisini
okuyup `sharp` ile rasterize eder; font/tarayıcı gerektirmez, `LogoMark`
tarafının `generate-logo.mjs`'iyle aynı rolü oynar.

### Mağaza rozeti karelere girdi (16 Eylül 2026)

Uygulama 15 Eylül'de App Store'a çıktı; kareler hâlâ yalnızca `kelimeki.com`
diyordu ve 1. karenin alt satırı *"Kurulum yok"* iddiasını taşıyordu — rozetle
açıkça çelişen bir cümle. Kare 1 ve 5 artık resmî App Store rozetini taşıyor,
her karenin alt şeridi `kelimeki.com · App Store'da` diyor, 5. karedeki mavi
`CtaButon` kaldırıldı (rozet çağrının kendisi; iki güçlü çağrı son karede
hedefi ikiye bölüyordu).

- **Rozet ÇİZİLMİYOR, `public/`teki resmî dosya `<img>` ile basılıyor** —
  inline SVG yasağının gerekçesi `src/utils/storeLinks.ts`te (Illustrator
  ihracatının `.st0` sınıfları sayfaya sızıyor).
- **Kapı paylaşılıyor:** kareler `visibleStoreBadges()` çağırıyor, yani
  "yayında değilse çizme" kuralı ve rozet SIRASI (App Store önce) tek
  kaynaktan geliyor. Play yayına girip `storeLinks.ts`teki `null` dolduğunda
  ikinci rozet, kareler yeniden üretildiğinde kendiliğinden gelir — burada
  yapılacak iş yok. Alt şeridin cümlesi de (`visibleStoreNamesTr`, `storeLinks.ts`) aynı listeden
  türüyor, üçüncü bir yerde tekrarlanmıyor.
- **⚠ Ölçü EKRANA göre, dosyaya göre değil.** Apple'ın 40 px alt sınırı
  render edilmiş boyutu bağlar. Instagram karesi telefonda ~390 pt genişlikte
  çizildiğinden 1080 px'lik tasarım orada ×0,36 küçülüyor: rozetin karede
  40 / 0,36 ≈ 111 px yüksek olması gerekiyor → ≈420 px geniş. Genişlik elle
  yazılmıyor, `rozetGenisligi()` rozet SVG'sinin `viewBox`ından oranı okuyup
  hesaplıyor (aynı dosyada `~3.0` varsayımının nasıl çöktüğü yazılı).
- **⚠ Bu yüzden rozet her kareye konmadı.** Alt şeride sığacak bir rozet
  (~50 px) telefonda ~18 pt'ye düşerdi, yani kuralın altında. İçerik kareleri
  (2-4) alt şeritte düz metin taşıyor.

- **Görseller çizim DEĞİL, üretim bileşenlerinin sunucuda render'ı** —
  tahtalar `GameBoardPreview`→`Board` (`compact={false}`, `demoBoard.ts`),
  rütbeler `RankSeal` + `RANK_TIERS`, logo `LandingLogo`, adım şemalarının
  renkleri `PLAYER_COLORS`. Karşılama katmanının gerekçesiyle aynı: ikinci
  bir "tanıtım çizimi" sessiz ayrışma üretirdi. Palet/rütbe/tahta değişirse
  tek komutla takip ederler.
- **⚠ Poster dosyasında Tailwind sınıfı KULLANILMAZ, yalnızca inline `style`.**
  `tailwind.config.js`in `content`i `./index.html` + `./src/**/*.{ts,tsx}` —
  `scripts/` altındaki bir `text-[52px]` derlenmiş CSS'e HİÇ girmez ve
  sessizce uygulanmaz (`CountBadge`in `-right-2` tuzağının aynısı). İçe
  aktarılan üretim bileşenlerinin sınıfları `src/` tarandığı için zaten
  `dist` CSS'inde; `shadow-raised`/`btn-raised` de öyle.
- **⚠ Tahta `transform: scale` ile büyütülür, kap genişliğiyle DEĞİL.**
  `Board` `max-w-[680px]`, harf ise `vw` tabanlı bir `clamp` (`Tile.tsx`) —
  kabı oynatmak harf/hücre oranını bozar (18 Ağustos 2026'da karşılama
  katmanında yaşanan hata). Sayfa `http://` üzerinden açılıyor (`file://`
  tüm puntoları 16px okur, bkz. aynı bölüm).
- **Metinler `Landing.tsx`ten KOPYA DEĞİL** — reklam kopyası sayfa
  kopyasından kısadır. İkisi arasında senkron yükümlülüğü YOK; tek kaynak
  zorunluluğu yalnızca VERİ için (rütbe tablosu, palet, tahta taşları).
- **Ölçüldü** (Chromium, 1080 viewport, `document.fonts.ready`): beş karede de
  dikey/yatay taşma **0** — `Slide` `overflow:hidden` olduğundan taşma sessizce
  kırpılırdı, "sığdı" varsayılamaz.
- **`?ref=` ölçüm notu (`metin.md`de de yazılı):** kampanya URL'i
  `kelimeki.com/?ref=meta` gibi olmalı. `captureUtmSource`
  (`src/utils/visitTracking.ts`) YALNIZCA `?ref=` okuyor; platformların
  eklediği `utm_source=...` bu projede hiçbir yere yazılmaz, yani `?ref=`
  yoksa trafik admin panelindeki **Kaynak Hunisi**'nde "direkt" satırına
  düşer ve kampanya ayırt edilemez. Sitede Meta pixel'i / LinkedIn Insight
  Tag YOK (bilinçli), dolayısıyla platform üyeliğe göre optimize edemez —
  hedef "Trafik", optimizasyon "açılış sayfası görüntüleme".

### Google Play vitrini (`scripts/play-store/`, 23 Ağustos 2026)

`marketing/play-store/` → `store-icon-512.png` (512×512) +
`feature-graphic.png` (1024×500) + `metin.md` (Play'e elle girilecek
başlık/kısa/tam açıklama ve cihazdan alınacak ekran görüntülerinin çekim
listesi). `npm run generate-play-assets`.

- **Promotional content kartı (`promo-1920x1080.png`, 25 Eylül 2026):**
  aynı komut üretir (`promo-graphic.tsx`). Görselde **metin ve logo YOK** —
  Play kartın başlığını/açıklamasını görselin alt kısmına kendisi bindiriyor
  ve kartı yüzeye göre kırpıyor; söylenecek her şey Console alanlarında.
  Ana tahta (`DEMO_TILES_2`, tam opak) üst-ortada, iki yanda soluk 4 kişilik
  tahtalar. Kart türü **Major update** (1.1.0'ın zorluk seçimi + oynayarak
  öğren tanıtımı): k-lig'de sezon yok, yani **Event** türü gerçek bir
  etkinliğe dayanmaz ve politikaya aykırı olur. Gerekçe (trafiğin tamamı
  "Paid and direct", Play aramasından sıfır): `marketing/play-store/metin.md`.
  ⚠ Console'daki **200 KB sınırı ANIMATION (JSON) alanı için**, Primary
  image için DEĞİL — 25 Eylül'de yanlış okunup görsel bir kez JPEG'e
  çevrildi, sonra geri alındı; Console'a PNG (~600 KB) yüklendi ve kabul
  edildi.

- **Mağaza ikonu ELLE ÇİZİLMEZ, cihazdaki başlatıcı ikonun KAYNAĞINDAN
  küçültülür** (`mobile/app/assets/icon/icon-source.png`, yani
  `flutter_launcher_icons.image_path`) — ayrı bir kaynaktan üretilse
  mağazadaki ikon ile telefondaki ikon sessizce ayrışırdı.
- **İkisi de ALFASIZ** (`flatten`): Play ikona kendi maskesini uyguluyor,
  öne çıkan görsel ise 24-bit PNG/JPEG istiyor.
- **Öne çıkan görsel 2× çekilip 1×'e indiriliyor** — Play boyutu TAM
  1024×500 istediğinden doğrudan 1× çekmek tek seçenek gibi görünüyor, ama
  süperörnekleme gözle görülür şekilde daha keskin.
- **Ölçüm YAZMADAN ÖNCE:** güvenli kutu kenara 40/30 px'den yakınsa ya da
  sayfa taşıyorsa betik hiçbir dosya yazmadan `exit 1` — başarısız bir koşu
  diske "bitmiş gibi duran" bozuk bir görsel bırakmamalı. **Negatif eş
  ölçüldü:** kutu 600 → 980 px yapılınca betik gerçekten düşüyor ve
  `feature-graphic.png` HİÇ oluşmuyor.
- **⚠ Tanıtım videosu eklenirse tasarım gözden geçirilmeli:** Play o
  durumda öne çıkan görselin ORTASINA bir oynat düğmesi bindiriyor, yani
  tam da logonun üstüne.
- **Ekran görüntüleri burada ÜRETİLMEZ ve üretilemez** — Play'e giden
  telefon görüntülerinin uygulamanın gerçek görüntüsü olması gerekiyor,
  gerçek cihazdan alınmalı. Çekim listesi + gizlilik uyarıları (gerçek
  arkadaş adı/e-posta görünmemeli — görseller herkese açık yayınlanıyor)
  `metin.md`'de.

### Mağaza başlık görseli (`scripts/store-header/`, 22 Ağustos 2026)

`marketing/store/kelimeki-play-header-4096x2304.jpg` (4096×2304).
`npm run generate-store-header`. Google Play Games'in header/landscape
yuvasının şartları: **JPEG ya da 24-bit PNG, şeffaf DEĞİL, 4096×2304, ≤1 MB**
(aynı kullanıcı akışındaki 512×512 ≤1 MB ikon yuvasını `public/icon-512.png`
zaten karşılıyor — o dosya 24-bit RGB, alfasız, 104 KB; yeniden üretilmedi).

⚠ **Bu bölüm 4 Eylül 2026'da kurtarıldı:** üretici 22 Ağustos'ta yazılmış ama
PR açılmadığı için `main`'e hiç girmemişti (dal `claude/image-asset-specs-8hzwri`,
commit `d85ad12`). Metin o commit'ten, yalnızca yeri güncellendi — o gün
anlatılar hâlâ kök `CLAUDE.md`'deydi.

- **Kompozisyon `kapak.tsx`in aynısı, oranı farklı:** üretimdeki
  `GameBoardPreview`→`Board` tahtaları + `LandingLogo` + slogan; "ortada
  güvenli kutu + kenarlarda taşan dekor" ilkesi (başlık görselini mağaza
  yüzeyleri kendi düzenine göre kırpıyor). Güvenli kutu 1024 CSS px ve
  **en dar (kare) kırpmanın içinde olduğu ÖLÇÜLÜYOR** — betik her koşuda
  `x 512–1536 ⊂ 448–1600` kontrolünü basıyor, sığdı varsayılmıyor.
- **Kapaktaki "kelimeki.com" ve "Ücretsiz · Kurulum yok · Üyelik gerekmez"
  satırları BİLEREK yok:** mağaza sayfasında adres gereksiz ve "kurulum yok"
  bir uygulama mağazasında olgusal olarak YANLIŞ olurdu (orada ürün zaten
  kurulan şey). Kalan mesaj logo + slogan.
- **⚠ İKİ TAHTA ÜST ÜSTE BİNDİRİLMEZ.** Denendi: ikisi de `opacity: .42`
  olduğundan bindirme bölgesinde harfler birbirinin içinden geçip alt orta
  bölgede gözle görülür "hayalet" ikinci bir satır üretiyordu. Çözüm: her
  tahta tuvalin YARISINI kaplayan kendi kabına kırpılıyor ve tahtanın kendi
  kart kenarları (yuvarlatılmış köşe + gölge) dört yandan kadraj dışında
  kalıyor — geriye tek bir birleşme yeri kalıyor, o da tam merkezde,
  perdenin en opak noktasında, yani görünmüyor. (İlk sürüm `OLCEK 1.35` ile
  alt %27'yi boş beyaz bırakmıştı; tahtalar 1.9'a çıkıp dikeyde de taşıyor.)
- **1 MB tavanı 9,4 megapiksele karşı DAR — biçim ölçümle seçiliyor:** betik
  önce kayıpsız 24-bit PNG deniyor (**2,06 MB — SIĞMIYOR**), sonra tavanın
  altına giren en yüksek kaliteli JPEG'e düşüyor (**q95, 4:4:4 alt örnekleme
  YOK → 849.732 bayt = 0,810 MB**). İki biçim de yuvanın kabul ettiği
  biçimler. Çıktının kendi baytlarından `4096×2304 · kanal=3 · alfa=false ·
  ≤1 MB` doğrulanıyor; şartlardan biri tutmazsa betik hata koduyla çıkıyor.
- **Tuval 2048×1152 CSS px, ekran görüntüsü 2× ile alınıyor** (kapak/reel ile
  aynı desen). `npm run build` ÖNCE koşmuş olmalı ve sayfa `http://` üzerinden
  açılır — `file://` mutlak asset yollarını çözemediğinden tüm puntoları
  sessizce 16px okur.

### Facebook sayfa kapağı (`scripts/kapak/`, 20 Ağustos 2026)

`marketing/sponsored-2026-08/kelimeki-fb-kapak.png` (1640×624).
`npm run generate-fb-cover`.

**⚠ Facebook kapağı İKİ FARKLI kırpılıyor** — masaüstünde geniş-alçak
(~820×312), telefonda dar-yüksek (~640×360) — ve masaüstünde profil fotoğrafı
SOL ALT köşeyi örtüyor. Tasarım bu yüzden "ortada güvenli kutu + kenarlarda
taşan dekor": okunması gereken her şey ortadaki 480 px'lik şeritte, iki yandaki
tahtalar bilerek kadraj dışına taşıyor. **Ölçüldü:** güvenli kutu x 170–650,
telefon kırpması x 90–730 → tamamen içeride. Betik bu kontrolü her çalıştırmada
tekrar ediyor, "sığdı" varsayılmıyor.

**28 Eylül 2026: iki rozet, FB kapağında da** (LinkedIn kapaklarından bir
gün sonra; kişisel FB profili için istendi, aynı dosya sayfada da geçer).
Eski *"Ücretsiz · Kurulum yok · Üyelik gerekmez"* satırı yalnızca web'i
anlatıyordu — iki mağazada yayındayken yanıltıcıydı, *"Ücretsiz ·
Reklamsız"* oldu. Rozetler `linkedin.tsx`'in `Rozetler`i (aynı kapı), 34
CSS px; `build.mjs`in rozet ölçümü artık üç kapakta da koşuyor.
⚠ **Aynı gün: blok YUKARI yaslandı.** Kişisel profilde (mobil) avatar
kapağın ALT ORTASINI örtüyor (iPad önizlemesinde üst kenarı ~%71'de);
ortalanmış blokta Play rozeti avatarın altında kaldı. Sayfa kapağının
"sol alt" kuralı kişisel profile YETMİYOR. `build.mjs` artık içeriğin
yüksekliğin %68'inin üstünde kaldığını ölçüyor, değilse düşer.

### LinkedIn kişisel profil kapağı (`scripts/kapak/linkedin.tsx`, 16 Eylül 2026)

`marketing/app-store/kelimeki-linkedin-kapak.png` (1584×396).
`npm run generate-linkedin-cover` — FB kapağıyla **aynı boru hattı**,
`build.mjs --linkedin` bayrağı.

**Neden ayrı bir dosya:** oran ve kırpma kuralları başka. LinkedIn kişisel
kapak **4:1** (FB'ninki 2.63:1) ve yükseklik yalnızca 198 CSS px — metni
dikeyde ortalarsan profil fotoğrafının örttüğü banda giriyor. Üç kısıt
birden: avatar SOL ALT'ı örter · telefonda kapak yanlardan kırpılır · ad
kartı kapağın hemen altında başlar. Çözüm FB'dekiyle aynı ilke, farklı
sayılar: güvenli kutu 440 px, dikeyde 26 px yukarı kaydırılmış.

**Ölçüldü (üretimde her koşuda tekrar ediliyor):** güvenli kutu x 176–616,
y 35–137 · telefon kırpması x 116–676 → içeride · avatar bölgesi (sol %22,
alt %45) → uzakta.

⚠ **Mağazalar KAPIDAN geliyor, elle yazılmıyor** (`storeLinks.ts`) — 16
Eylül 2026'da SSS metninin bayatlamasıyla alınan dersin aynısı.

**27 Eylül 2026: metin → ROZET, iki kapakta da** (kullanıcı isteği).
`visibleStoreBadges()` (App Store önce, eşit yükseklik), `<img>` ile;
`kelimeki.com` rozetlerin yanında. ⚠ Rozetler bilerek KÜÇÜK (30 CSS px)
— ilk deneme yüksekliği Apple'ın 40 pt sınırından türetmişti (telefon
kırpmasına göre 58 / 87 px), kapak rozetlere boğuldu ve kullanıcı
reddetti: *"olmamış, küçültmek lazım"*. Bedel: telefonda ~21 / ~14 pt,
Apple'ın ekran sınırının altında — kapakta rozete dokunulamadığı için
(LinkedIn link koydurmuyor) kabul edildi. Betik iki rozetin kırpma
şeridinde ve eşit yükseklikte olduğunu ölçer, değilse DÜŞER.

### Reel (`scripts/reel/`, 20 Ağustos 2026)

Instagram "trial reel" denemesi için 1080×1920 / 9.4 sn MP4
(`marketing/sponsored-2026-08/kelimeki-reel.mp4`). Video **ÜRETİM
UYGULAMASININ kendisi sürülerek** üretiliyor: Playwright kayıtlı bir oyun
ortasını açıyor, taşları raftan tahtaya sürüklüyor, OYNA'ya basıyor, YZ
cevabını veriyor.

- **Sahne elle yazılmadı, ÖLÇÜLDÜ.** `scripts/reel/senaryo.ts` üretim
  YZ'sini (`findAIMove`) tanıtım tahtasına karşı çağırıp oynanabilir
  hamleleri listeliyor; seçilen hamle (7. sütunda dikey **ARKADAŞ**, 50 puan)
  böylece sözlük/bitişiklik/puan açısından motorun kendisiyle garantili.
  Elle "şu kelimeyi şuraya koyayım" demek, çekim sırasında tahtanın kırmızıya
  dönmesiyle sonuçlanabilirdi.
- **⚠ `buildSnapshotGameState` `isGameOver: true` DÖNER** (bitmiş oyun
  önizlemeleri için yazıldı). Sahne onu `false`a çekmezse `loadGameState`
  kaydı "bitmiş" sayıp null dönüyor ve App ilk effect'te localStorage'ı
  SİLİYOR — ölçüldü: 4215 bayt yazılıyor, ~1 sn sonra null, Setup'ta
  "Devam Eden Oyun" satırı hiç çıkmıyor.
- **Sahne ARA BİR DOSYAYA yazılmıyor** (5 Eylül 2026'da onarıldı). Önceden
  `build.mjs` sahneyi `node_modules/.cache/kelimeki/reel-state.json`'dan
  OKUYORDU ama o dosyayı üreten `scripts/reel/emit-state.ts` hiçbir yerden
  çağrılmıyordu — ne `package.json`'dan ne CI'dan; komut taze bir klonda
  ENOENT ile düşerdi. `build.mjs` artık `state.ts`'i, kapanış kartı için
  ZATEN kullandığı esbuild + dinamik import kalıbıyla kendisi koşuyor;
  `emit-state.ts` silindi. **Ders:** bir "üretici → tüketici" zinciri kurarken
  üreticinin ÇAĞRILDIĞI yeri de aynı PR'da göster — üretilmiş dosya
  geliştiricinin `node_modules`'ünde durduğu sürece kopukluk görünmez.
- **⚠ Kapanış kartı AYRI BİR CONTEXT'te render edilmeli.** Uygulamayı açan
  bağlamda PWA service worker'ı kayıtlı ve `navigateFallback` bilinmeyen her
  navigasyona `index.html` döndürüyor; ilk sürümde videonun son 2 saniyesi
  kapanış kartı yerine Setup ekranını gösterdi.
- **⚠ Sürükleme hedefi +30 px AŞAĞIDA** (`DRAG_LIFT`) — bu tuzak bu dokümanda
  zaten kayıtlı, betik onu telafi ediyor.
- **Taş SIRASI görsel bir karar:** yukarıdan aşağı dizmek ara adımlarda
  "ARKAD geçerli bir kelime değil" kırmızısını saniyelerce ekranda tutuyordu.
  Mevcut A'nın ALTINDAN başlayınca ara adımlar gerçek kelime oluyor
  (AD ✓ ADA ✓ ADAŞ ✓), doğrulama satırı hamlenin çoğunda yeşil kalıyor.
- **Kare kare (stop-motion) yakalanıyor, `recordVideo` DEĞİL:** o, videoyu
  viewport boyunda kaydedip büyütürken taş harflerini bulanıklaştırırdı;
  `page.screenshot` + `deviceScaleFactor: 2` gerçek 1080×1920 üretiyor.
  Kareler ffmpeg'in concat demuxer'ıyla, her karenin kendi süresiyle
  birleşiyor (bekleme = tek dosya + uzun süre).
- **Uygulama içeriği 540 px genişlikte 819 px sürüyor** (ölçüldü), kare ise
  9:16. Artan yer boş bırakılmıyor: altta kalıcı bir `kelimeki.com` şeridi
  bindiriliyor (`renderBantHtml`).
- **ffmpeg bu ortamda apt ile kuruldu** — Playwright'ın kendi ffmpeg'i
  (`/opt/pw-browsers/ffmpeg-1011`) yalnızca VP8/webm derlenmiş, H.264 yok.


## Kısa videolar — Reels / Shorts / TikTok (`scripts/reel/shorts*`, 5 Ekim 2026)

`npm run build && npm run generate-shorts [1|2|3]` → `marketing/shorts-2026-10/`
(1080×1920, H.264, AAC). **Müzik videonun içinde** (5 Ekim, kullanıcı: *"müzikleri sen ekle"*): `scripts/reel/muzik.mjs` özgün bir döngüyü SENTEZLER (C–Am–F–G, 112 BPM, pluck arpej + bas + vuruş; son 1,2 sn kısılır) — internetten ses indirilmiyor (ortam kapalı + telif tarayıcısı riski yok). ⚠ Kulakla dinlenmedi, yalnızca seviye ölçüldü (ort. −19 dB, tepe −3 dB). Paylaşım metinleri: `marketing/shorts-2026-10/metin.md`. Instagram ve TikTok AYRI hesaplar (kullanıcı, 5 Ekim); yayın sırası: IG günde bir video (1→2→3), TikTok sonra, Shorts en son (`ALT` → "Link açıklamada" gerekir). Kullanıcı isteği: üç kısa video, hepsi *"Kelimeki'ye gel, kendin
dene!"* + *"Link bio'da"* kapanışıyla (2,8 sn tam ekran kart, mağaza
rozetleri dahil).

| # | Dosya | Süre | Kurgu |
|---|---|---|---|
| 1 | `video-1-en-yuksek-puan.mp4` | ~13,5 sn | Tek altyazı "En yüksek puanlı kelimeyi bul" (kullanıcı kararı, 5 Ekim) → 3-2-1 geri sayım → **ÖVEÇ = 97 puan** (merkez ×3 karesi; puanı uygulamanın kendi +97 rozeti gösterir, altyazı yok) |
| 2 | `video-2-hangisini-oynardin.mp4` | ~20 sn | "Sen hangisini oynardın?" → A: CIVATA 38 puan (**sınır ihlali onay penceresi: 13 puan rakibe vergi**) → geri al → B: CUMA 24 puan vergisiz → hesap: A fark **+12**, B fark **+24** |
| 3 | `video-3-cift-yildiz-bitis.mp4` | ~16 sn | "40 puan geride! Torba boş, elinde 2 joker ★★" → DAĞCI + **çift joker bitişi +50** → gerçek "SEN KAZANDI" ekranı **229–203** |

- **Hamleler elle seçilmedi, motordan ÖLÇÜLDÜ** (`shorts-state.ts`; seçim
  ölçütleri `kesif.ts` / `kesif-v2.ts` / `kesif-v3.ts`). V1: tanıtım
  tahtası + `ÇÖVÜZÜI` rafının `findAIMoves` (Zor genişliği) en iyisi; V2:
  YZ↔YZ gerçek oyun (tohum 21, 14. tur), `computeInvasionSplit` ile vergi
  payı, ölçüt "A'nın net puanı B'nin brütünü geçsin AMA fark (net − rakip
  payı) B'nin altında kalsın" — yani ilk bakışta yüksek puan cazip, hesap
  tersini söylüyor; V3: YZ↔YZ oyunun torbası boşaldığı ilk an (tohum 4).
- ⚠ **`findAIMoves` vergisiz hamle varsa SADECE onları döner** (güvenli
  tercih) — vergili/vergisiz çifti ölçerken oyuncuları `surrendered: true`
  yapıp (bölge boşalır) TÜM hamleleri alıyor, vergiyi sonra gerçek
  oyuncularla hesaplıyoruz (`shorts-state.ts` → `tumHamleler`). Elle
  yazılmış "vergili/vergisiz" çifti yerine bu ölçüm, demo tahtasında çiftin
  HİÇ çıkmadığı görüldüğü için gerekti (merkez ×3 vergisiz hamle hep daha
  yüksekti).
- **V3 bir SAHNELEME:** gerçek oyunun sonundan bir durum alınıp insanın
  rafı iki jokerle, puanı rakipten 40 geriye ayarlandı (kullanıcı örneği:
  *"40 puan gerideyken çift yıldız bitme"*). Oyuncunun eski rafındaki
  taşlar kaybolur (torba zaten boş) — ekranda sayılabilecek bir şey değil.
  Kazanma ve +50 motorun kendisinden: `endGame` + `jokerFinishBonus(2)`.
- **Uygulama bir IFRAME içinde** (`shorts-kabuk.html`, `renderSarmalHtml`):
  üstte altyazı (108 CSS px), altta adres şeridi, ortada 540×816 uygulama.
  `build.mjs`in "viewport + alt bant" düzeninden farkı: altyazı DOM'da
  olduğu için her karede değiştirilebiliyor. Fare koordinatları sayfa
  koordinatı → iframe içi ölçüye `CAP_H` EKLENİR (sürükleme hedefi hâlâ
  +30 px, `DRAG_LIFT`).
- **Joker penceresi başlığı `Joker Hangi Harf Olsun?`** (düzenleme modundaki
  `Jokeri Hangi Harfe Çevir?` DEĞİL); harf, ızgaradaki hücreye
  `click()` ile seçilir.
- **Rafta tahtaya konan taş raftan düşer** — "kullanıldı" işareti tutmaya
  GEREK YOK (ilk sürüm `dataset` işaretliyordu; iki joker aynı öğeyi
  yeniden kullanıp "Rafta '?' yok" ile düştü).
- ⚠ **Altyazıda `<b>/<i>/<u>` bir `<span>` İÇİNDE olmalı** — `#cap`
  `display:flex` olduğundan çıplak etiketler arası boşluk yutuluyor.
- **Güvenli bölge:** Reels/TikTok altta ~%35, üstte ~%14'ü arayüze
  verir; bu videolar ona UYMUYOR (altyazı üst ~%11'de, raf alt kısımda).
  Aynı tercih ilk reel'de de yapıldı; sorun çıkarsa kabuk ölçüleri
  (`CAP_H`, `FOOT_H`) tek yerden değişir.
- **Kapanış metni** `shorts.mjs` başındaki `SLOGAN` / `ALT`: YouTube
  Shorts'ta "bio" yok → o platform için `ALT` "Link açıklamada" yapılıp
  yeniden üretilmeli (henüz yapılmadı).

**28 Eylül 2026 — iki mağaza rozeti (Meta kampanyası):** alt bant artık logo +
adres yerine **iki rozet + adres** (`visibleStoreBadges`, App Store önce, eşit
yükseklik); kapanış kartındaki mavi `kelimeki.com` düğmesi ve artık yanlış
olan *"Kurulum yok · Üyelik gerekmez"* satırı kalktı, yerine *"App Store ve
Google Play'de"* + *"Ücretsiz · Reklamsız · Tarayıcıda da oynanır"*.
Kapanışa ayrıca rozet KONMADI: bant her karede duruyor, ikinci satır aynı
karede rozeti iki kez gösterdi (denendi). Aynı turda betik düştü: Setup'taki
satırın etiketi "Senin hamlen bekleniyor" → "SIRA SENDE" olmuştu; seçici
ikisini de tanıyor. ⚠ ffmpeg bu ortamda kurulu gelmiyor, `apt-get install -y
ffmpeg` gerekiyor (H.264 için; Playwright'ın ffmpeg'i yalnızca VP8).

## "Artık Google Play'de" lansman görselleri (`scripts/play-lansman/`, 26 Eylül 2026)

`npm run build && npm run generate-play-lansman` →
`marketing/play-store/lansman/` altında Apple setinin beş boyu: kare
1080×1080 (IG/FB feed), story 1080×1920, dikey 720×1280, yatay 1280×720,
link kartı 1200×628 (LinkedIn/FB).

**Neden elle üretiliyor:** App Store lansmanında görseller Apple Marketing
Tools'tan HAZIR geldi (`marketing/app-store/instagram-lansman.md`). Google'ın
karşılığı yok — Partner Marketing Hub → Tools 26 Eylül 2026'da okundu,
yalnızca "Device art generator" ve "Legal line generator" var.

- Rozet `public/google-play-badge.svg` (sitedeki resmî dosya) — çizilmez,
  oranı değiştirilmez. Rozet kullanıldığı için gönderi metnine Google'ın
  legal satırı girer (Legal line generator).
- **27 Eylül 2026: İKİ rozet** (kullanıcı: *"ikisinin de olması lazım"*).
  App Store rozeti de eklendi; hangi rozetin çıktığı ve sırası üretimin
  kapısından (`visibleStoreBadges` — App Store önce, eşit yükseklik).
  Betik iki rozetin kadrajda ve eşit yükseklikte olduğunu ölçer. Aynı gün
  fark edildi: kapıya bağlı carousel kareleri (`sponsored-2026-08/`) ve
  LinkedIn kapakları Play yayına girdikten sonra yeniden üretilmemişti,
  hâlâ yalnızca App Store diyorlardı — ⚠ `storeLinks.ts` değişince kapıya
  bağlı üreticileri YENİDEN KOŞ (liste: `play-store/sosyal-lansman.md`).
- Simge cihazdaki başlatıcı ikonla aynı kaynak (`icon-source.png`); simge
  "kelimeki" yazısını taşıdığı için kare/story'de ayrıca logo YOK.
- Story'de içerik Instagram'ın bindirme bantlarının (üst ~%14, alt ~%20)
  dışında kalmak zorunda; betik ölçer, taşarsa dosya yazmadan düşer.
- Yatay ve link kartında 4 kişilik tahta TAMAMEN kadrajda (ilk taslakta
  kenardan taşıyordu, kullanıcı istemedi); betik tahtanın kadrajda
  kaldığını ve metnin ona binmediğini ölçer. Kare/story/dikeydeki silik
  arka plan tahtaları ise bilerek kenardan taşan dekor.

**28 Eylül 2026 — `--genel` varyantı (`npm run generate-meta-story`):** Meta
kampanyası tek reklam setiyle iOS + Android'e birlikte gidiyor ve "Artık
Google Play'de" başlığı iPhone'da yanlış olurdu. Aynı üretici yalnızca
`story` düzeninde mağazadan bağımsız bir görsel çıkarıyor →
`marketing/meta-reklam/kelimeki-story-1080x1920.png` (başlık "Kelime bul,
bölgeni büyüt, tahtayı ele geçir.", punto 0,8× — 56 px'te "tahtayı ele
geçir." güvenli kutuya sığmıyor). Play dosyalarına dokunmuyor. Kare için
ayrı varyant yok: `sponsored-2026-08/kelimeki-01.png` zaten mağazadan
bağımsız. Kampanya: `marketing/meta-reklam/kampanya-ekim-2026.md`.

**29 Eylül 2026 — `--sade` varyantı (`npm run generate-meta-sade`):** Meta
kampanyasının `kare` reklamı (akış `kelimeki-01`, Reels/hikaye yukarıdaki
story) mobilde 37 ziyaretten 1'ini mağazaya gönderdi (`karusel` 28'de 9) ve
10:25'te duraklatıldı. Kullanıcının teşhisi: *"çok fazla yazı, kutu vb var.
Logo çok büyük."* Sade varyant kahramanı değiştiriyor: GERÇEK 4 kişilik
tahta tam görünür ve soluk değil; üstünde küçük logo + tek satır başlık
("Kelime bul, bölgeni büyüt."), altında tek dip satırı. İstatistik kutusu,
ikon ve rozet YOK (reklamın "İndir" düğmesi o işi yapıyor, link siteye
gidiyor; görseldeki rozet dokunulabilir sanılıyor). Çıktı:
`marketing/meta-reklam/kelimeki-sade-kare-1080.png` +
`kelimeki-sade-story-1080x1920.png`. Betik story'de güvenli bandı ölçmeye
devam ediyor, rozet kontrolü bu varyantta tersine döner (rozet varsa düşer).


## verify-store-badges neyi kilitler

(2 Ekim 2026'da `CLAUDE.md`'nin komut listesinden taşındı — doküman boyutu
bütçesi. Satır aynen:)

```
npm run verify-store-badges      # mağaza rozetleri + Safari Smart App Banner (app-id tek kaynak: `storeLinks.ts` ↔ `index.html` ↔ `render.tsx`): App Store ÖNCE (Apple'ın yazılı kuralı), EŞİT YÜKSEKLİK (24 Eyl 2026 kullanıcı kararı; 15-24 Eyl arası eşit genişlikti — oranlar farklı, Apple 3.78:1 ↔ Play 3.37:1, ikisi birden eşit olamaz), yükseklik ≥40px, clear space yüksekliğin 1/4'ü, yayında olmayan rozet HİÇ çizilmiyor + "ana ekrana ekle" kutusu YOK (24 Eyl 2026'da kaldırıldı; telefonda tek çağrı mağaza şeridi) + rozet/şerit linki ziyaretçinin `?ref=` etiketini mağazaya taşıyor (`taggedStoreUrl`, 28 Eyl 2026 — Meta kampanyası)
```
