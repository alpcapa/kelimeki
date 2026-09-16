# LinkedIn — Kelimeki SAYFASI: alan alan cevap kâğıdı (16 Eylül 2026)

`marketing/play-store/console-formlari.md` ile aynı işi görür: konsol
ekranındaki her alanın karşılığı burada yazılı, ekrandan ezbere
doldurulmaz. **Değerler kopyalanabilir olsun diye kod bloklarında.**

⚠ **Android'den söz eden tek bir cümle bile YOK** — Play vitrini hâlâ
incelemede (`STORE_BADGES.googlePlay.url = null`). Vitrin açıldığında bu
dosyadaki mağaza cümleleri de elden geçer (aşağıda işaretli).

## 1 · Kimlik alanları

| Alan | Değer | Not |
|---|---|---|
| Page name | `Kelimeki` | — |
| Tagline (≤120 karakter) | `Türkçe için tasarlanmış stratejik kelime oyunu. Ücretsiz, reklamsız.` | 68 karakter. Alternatif, daha marka sesiyle: `Kelime bul, bölgeni büyüt, tahtayı ele geçir.` |
| Website | `https://kelimeki.com/?ref=li-hakkinda` | ⚠ `?ref=` OLMADAN yazma — sayfadan gelen ziyaretçi huniye "direkt" düşer |
| Industry | **Computer Games** (TR arayüz: *Bilgisayar Oyunları*) | *Mobile Gaming Apps* da savunulabilir; oyun hem web hem mobil olduğu için genel olan seçildi |
| Company size | `1` çalışan (0-1 bandı) | — |
| Company type | **Self-employed** / *Şahıs şirketi* | Kozmetik alan, aramada bir etkisi ölçülmedi |
| Location | `İstanbul, Türkiye` | Dashboard'daki *"Add location"* uyarısını kapatan alan bu |
| Founded | `2026` | — |
| Phone | boş bırak | Zorunlu değil; destek kanalı e-posta |

## 2 · Açıklama (About, ≤2.000 karakter)

```
Kelimeki, Türkçe için sıfırdan tasarlanmış stratejik bir kelime oyunudur.

Klasik kelime oyunlarından farkı tek bir kuralda: 13×13'lük tahtanın dört köşesi oyunculara aittir ve herkes kendi köşesinden başlayarak bölgesini büyütür. Koyduğun her taş bölgeni genişletir. Rakibinin bölgesine de oynayabilirsin — ama kazandığın puanın bir kısmı o bölgenin sahibine geçer. Böylece "hangi kelimeyi kurayım" sorusu kadar "bu kelimeyi nereye koyayım" sorusu da belirleyici olur.

Öne çıkanlar:
• 63.905 kelimelik sözlük (TDK Güncel Türkçe Sözlük kaynaklı), hepsi anlamlarıyla birlikte
• Üç zorluk seviyesinde yapay zekâ rakip: Kolay, Normal, Zor
• 2 veya 4 kişilik oyun; arkadaşlarınla sırayla, her hamle için 48 saat
• İnternet olmadan da oynanır — sözlük cihazın içinde
• Ücretsiz; reklam yok, uygulama içi satın alma yok

iPhone ve iPad için App Store'da; tarayıcıdan oynamak için kelimeki.com
```

⚠ Son satır mağaza durumuna bağlı — Play yayına girince *"iPhone, iPad ve
Android için"* diye güncellenir. Metnin kaynağı `src/utils/storeLinks.ts`
kapısıdır, ezbere değil ona bakılır.

## 3 · Görseller

| Ne | Ölçü | Dosya |
|---|---|---|
| Logo | 300×300 (min) | Mevcut daire logo yerinde kalsın — değişecekse `marketing/play-store/store-icon-512.png` |
| Kapak | **1128×191** | `marketing/app-store/kelimeki-linkedin-sayfa-kapak.png` (2256×382 basılır, LinkedIn oranı koruyup küçültür) · `npm run build && npm run generate-linkedin-page-cover` |

⚠ **Kişisel profil kapağıyla AYNI DOSYA DEĞİL** (o 1584×396). İkisinin
oranı ve örtülen bölgeleri farklı; karıştırılırsa sayfa logosu metnin
üstüne biner. Tasarım kararları: `docs/decisions/marketing-assets.md`.

## 4 · Buton ve etiketler

| Alan | Değer |
|---|---|
| Custom button | **Visit website** → `https://kelimeki.com/?ref=li-buton` |
| Hashtags (en çok 3) | `#kelimeoyunu` · `#türkçe` · `#oyun` |

⚠ Etiketleri `trLower` refleksiyle yaz: `#türkçe`, `#TÜRKÇE` değil.

## 5 · Doldurduktan sonra

1. **Add a valid email domain → `kelimeki.com`.** Dashboard'un ikinci
   uyarısı bu; marka koruması ve doğrulama için isteniyor, `destek@`
   kutusu zaten var (`docs/decisions/support-email.md`).
2. **Invite connections** — sayfanın takipçisi 0; ilk kitle buradan gelir.
3. Lansman gönderisi zaten yayında (`marketing/app-store/linkedin-lansman.md`).

## 6 · Ölçüm

Bu dosyadaki iki yeni etiket — `li-hakkinda` (Website alanı) ve `li-buton`
(Custom button) — gönderi etiketlerinden (`li-sayfa`, `li-profil`) ayrı
tutuldu: sayfayı gezip siteye geçen ile gönderiden tıklayan aynı şey değil.

⚠ Hepsi bugün admin panelinde **`Diğer`** grubunda görünür;
`sourceChannel` (`src/utils/adminGroups.ts`) `li` önekini henüz tanımıyor.
Kaybolmazlar, gruplanmazlar. Kanal eklenirse dört etiket birden tek
"LinkedIn" satırında toplanır.
