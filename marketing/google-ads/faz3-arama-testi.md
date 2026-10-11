# Google Ads — arama testi (Faz 3 taslağı, 6 Ekim 2026)

**Durum: PLAN, kurulmadı.** Karar (kullanıcı, 6 Ekim 2026): rakip marka kelimelerine (Kelimelik vb.) bid
EDİLMEZ; genel kelimelerle küçük bir test yapılır. Meta kampanyası 7 Ekim 11:54'te bitiyor, kapanış okuması
8-9 Ekim; bu test o okumadan SONRA (Faz 3) kurulur. Hedef ölçü: **ayda 2+ oyun oynayan 100 yeni MAU**
(`kampanya-ekim-2026.md`, 5 Ekim kararı).

## Neden rakip marka DEĞİL
- Niyet uyuşmuyor: "kelimelik" arayan o oyunu indirmek istiyor.
- Reklam metninde rakip adı kullanılamaz; marka şikayetinde reklam kapanabilir (Türkiye için avukata sorulmadı).
- Marka kelimeleri genelde pahalı, rakip kendi adına zaten teklif verir.

## Test tasarımı
| | |
|---|---|
| Kampanya türü | Arama (Search) — ayrı: Android "uygulama kampanyası" Faz 3'te ayrıca değerlendirilecek |
| Bütçe | **₺100/gün × 7 gün (~₺700)** |
| Konum / dil | Türkiye · Türkçe |
| Eşleşme | **Tam + ifade** (geniş eşleşme YOK — bütçeyi eritir) |
| Cihaz | Hepsi; sonuç cihaza göre okunur (telefon → mağaza rozeti, masaüstü → web oyunu) |
| Hedef sayfa | `https://kelimeki.com/?ref=google-arama` (aşağıdaki ⚠'ye bak) |
| Başarı ölçüsü | Kurulum başı maliyet **< ₺17-18** (Meta karusel, 6 Eki) ve 2+ oyun oranı ≥ %31 (yeni cihaz kohortunun ortalaması) |

⚠ **Admin'de `google-*` etiketi "Diğer" grubuna düşer** (`src/utils/adminGroups.ts` → yalnızca `meta`, `ig`, `fb`, `li`,
`arkadas`, `app`, `direkt` bilinir). Test kurulmadan ÖNCE iki yoldan biri seçilmeli: (a) `google` kanalı eklenir
(`SourceChannel` + etiket + `verify-admin-groups` kapısı; yalnız web, port etkilenmez), (b) "Diğer"de bırakılır ve
etiketle elle okunur. Önerim (a): küçük, ve test sonucu panelde ayrı satır olarak görünür.

## Anahtar kelime adayları (ifade + tam eşleşme)
- kelime oyunu · kelime oyunu oyna · türkçe kelime oyunu · online kelime oyunu
- kelime oyunu indir · ücretsiz kelime oyunu · kelime bulma oyunu
- arkadaşla kelime oyunu · iki kişilik kelime oyunu · kelime oyunu android · kelime oyunu ios
- harf oyunu · kelime türetme oyunu *(araç arayanlara kayabilir — ilk günlerde izle)*

## Negatif kelimeler (baştan ekle)
kelimelik · kelime bulucu · harf bulucu · kelime bul(ucu) · cevap · cevapları · hile · apk · mod · tdk · sözlük ·
kelime gezmece · words of wonders · anlamı · eş anlamlı · çalışma kağıdı · etkinlik · pdf · yazdır · çocuk · okul · öğretmen · wordle · scrabble ·
çözücü · yardımcı

*(wordle/scrabble bilerek hariç: komşu ürünler, ilk testte bütçeyi bölmesin; sonra ayrı denenebilir.)*

## Keyword Planner okuması (6 Ekim 2026 16:56, Türkiye · Türkçe · Eyl 2025–Ağu 2026; kullanıcının ekran görüntüleri)
"Sayfanın üstü teklifi" = Google'ın TAHMİNİ teklif aralığı (düşük–yüksek), GERÇEK tıklama maliyeti DEĞİL; hiç
harcaması olmayan yeni hesapta aralıklar geniş çıkıyor. Rekabet sütunu reklamverenler arası (arama hacmi değil).

| Anahtar kelime | Ort. aylık arama | Teklif (düşük–yüksek) | Rekabet |
|---|---|---|---|
| kelime oyunu | 10 B–100 B | ₺2,46–₺14,75 | Düşük |
| **kelime oyunu oyna** | 10 B–100 B (yıllık **+%900**) | **₺0,69**–₺13,27 | Düşük |
| türkçe kelime oyunu | 100–1 B | ₺4,92–₺29,49 | Düşük |
| online kelime oyunu | 100–1 B | ₺6,15–₺26,55 | Düşük |
| kelime oyunu indir | 1 B–10 B | ₺2,95–₺13,27 | Orta |
| kelime bulmaca *(fikir)* | 100 B–1 Mn | ₺3,45–₺14,75 | Düşük |
| kelime gezmece *(fikir, RAKİP oyun adı)* | 1 B–10 B | ₺2,46–₺10,81 | Düşük |
| words of wonders… *(fikir, RAKİP oyun adı)* | 1 B–10 B | ₺2,46–₺17,20 | Düşük |

`arkadaşla kelime oyunu` ve ötekiler ilk ekran görüntülerinde görünmüyordu (tablo kaydırılmadı) — okunmadı.

**Okuma:** hacim yeterli (üstteki iki kelime 10 B–100 B/ay; ₺100/gün ≈ ayda 600 tıklama civarı, tavana yakın değil).
Asıl soru maliyet: **başa baş tıklama→kurulum oranı = tıklama maliyeti ÷ ₺17,7**. Meta'da yönlendirme sayfası görüntülemesinden
kuruluma oran ≈ %10 (88 kurulum / 909 görüntüleme, 6 Eki). Yani ₺2,5 tıklamada %14, ₺5'te %28, ₺10'da %56 gerekir;
arama niyeti Meta'dan 1,5-3 kat iyi dönüştürmezse Meta'yı geçemez. ₺700'lük testte ~140 tıklama → ~14-40 kurulum: **örnek küçük**,
kesin hüküm değil yön verir.

**Revize öncelik:** (1) `kelime oyunu oyna` · (2) `kelime oyunu indir` (kurulum niyeti) · (3) `kelime oyunu`. `türkçe kelime oyunu` /
`online kelime oyunu`: hacim düşük, teklif yüksek → ilk testte DIŞARIDA. **Tıklama başı üst sınır (max CPC) ₺6.** `kelime bulmaca`
niyet farklı → bu testte yok. `kelime gezmece` / `words of wonders` rakip oyun adları → **bid edilmez, negatif listeye eklenir.**

## Duyuru (Responsive Search Ad) taslağı — karakter sınırları ölçüldü
Başlıklar (≤30): Türkçe Kelime Oyunu (19) · Kelimeki: Kelime Oyunu (22) · Ücretsiz Kelime Oyunu (21) ·
Köşeni Seç, Bölgeni Büyüt (25) · Arkadaşınla Kelime Oyna (23) · Yapay Zekaya Karşı Oyna (23) ·
Reklamsız Kelime Oyunu (22) · iOS ve Android'de İndir (23)

Açıklamalar (≤90):
1. Kelime bul, bölgeni büyüt, tahtayı ele geçir. Ücretsiz ve reklamsız. Hemen oyna! (80)
2. 13×13 tahtada özgün bir kelime oyunu. Arkadaşınla ya da yapay zekaya karşı oyna. (80)

## Karar kuralları (3. günde, Meta kuralı gibi)
- Anahtar kelime başına tıklama maliyeti ve hacim **Keyword Planner'dan okunacak** — kurulum öncesi bu sayılar YOK;
  CPC ₺ cinsinden bütçeye (₺100/gün) göre günde ~birkaç tıklama veriyorsa test anlamsız, kelime listesi genişletilir.
- 3 günde mağaza adımına gelen oturum başına maliyet ₺10'u aşıyorsa kelimeyi kapat.
- Sonuç 8 gün sonra: kurulum başı < ₺17-18 ise ölçeklenir (Faz 3 bütçesinden), değilse kapatılır.

## Açık sorular
- Google Ads hesabı var mı / faturalama? (kütükte iz yok)
- Kurulum atfı: Android'de Play Install Referrer `utm_source` taşıyor (1.1.2); `?ref=google-arama` bunu besler mi, kurulum zinciri doğrulanmalı.
