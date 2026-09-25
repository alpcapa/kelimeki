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

⚠ **Mağaza cümlesi ELLE YAZILMIYOR** — `visibleStoreNamesTr()`ten geliyor
(`storeLinks.ts`). Play yayına girip URL dolduğunda kapak yeniden
üretilirse satır kendiliğinden "App Store ve Google Play'de" olur; bu,
16 Eylül 2026'da SSS metninin bayatlamasıyla alınan dersin aynısı.

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

