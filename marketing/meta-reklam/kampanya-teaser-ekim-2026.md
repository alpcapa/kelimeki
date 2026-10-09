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

- **Kare:** 4:5 + 9:16 ayrı üretim; iki varyant: (a) yalnızca tipografi
  (Aşama 1'in kazananı), (b) tipografi + dört köşe renkli bölgesiyle tahta
  kesiti (`GameBoardPreview`). Mağaza rozeti/kutu YOK. **(b) için prototip
  hazır:** `npm run generate-meta-teaser -- --tahta [--h1]` (sağ alta taşan
  tahta; H1 önizlemesi `teaser/kelimeki-teaser-h1-tahta-*.png`). Story'de tahtanın
  alt satırı Instagram yanıt bandına girer (dekoratif, kabul).
- **Karusel (teaser):** kart 1 = kanca; kalan kartlar kuralı kanıtlar (köşe →
  bölge → vergi → gerçek tahta). "İki rozetli" kartlar yeniden kullanılabilir.
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
- **Atıf notu:** `ct=` Aşama 1'de `meta-h1/h2/h3` olarak ASC'de görünür; ASC
  küçük sayıları gizleyebilir → iOS kolları arası fark okunamazsa karar Android
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
