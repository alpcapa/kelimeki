# Kısa videolar — paylaşım metinleri (5 Ekim 2026)

Instagram ve TikTok AYRI hesaplar. Link: Instagram'da profil bio'su, TikTok'ta profil bio'su
("Link bio'da" kapanış kartında yazıyor — bio'daki linkin güncel olduğunu paylaşmadan önce kontrol et).
Sıra: Instagram'da günde BİR video (1 → 2 → 3); TikTok'a Instagram'daki ilk iki sonuç görüldükten sonra.
Müzik videoda gömülü (sentezlenmiş, özgün). Platformun kendi müzik kütüphanesinden ses eklenecekse
videonun sesini kapat — iki ses üst üste binmesin.

## Video 1 — En yüksek puanlı kelimeyi bul (`video-1-en-yuksek-puan.mp4`)

**Instagram**
```
Bu rafla en yüksek puanlı kelime hangisi? 🤔
3 saniyen var… cevabı yoruma yaz, sonra videoda karşılaştır!

Kelimeki'de her hamle bir strateji: merkez kare kelimeni ×3 yapar.
Kendin dene → link bio'da

#kelimeki #kelimeoyunu #türkçekelimeoyunu #kelimebulmaca #zekaoyunları #beyinjimnastiği #mobiloyun #oyunönerisi
```

**TikTok**
```
En yüksek puanlı kelimeyi bulabilir misin? 👀 Cevap sonda! Link bio'da
#kelimeoyunu #kelimeki #zeka #bulmaca #türkçe #oyun #keşfet
```

## Video 2 — Sen hangisini oynardın? (`video-2-hangisini-oynardin.mp4`)

**Instagram**
```
38 puan mı, 24 puan mı? 🧠
Yüksek puanlı hamle rakibine vergi ödetir. Düşük puanlısı vergisiz.
Hesabı yapınca sonuç şaşırtıcı… Sen hangisini oynardın? Yoruma yaz!

Kelimeki: bölgeni büyüt, tahtayı ele geçir. Link bio'da

#kelimeki #kelimeoyunu #strateji #zekaoyunları #beyinjimnastiği #türkçe #mobiloyun
```

**TikTok**
```
Yüksek puan mı, vergisiz hamle mi? Sen hangisini oynardın? 🤯 Yorumlara yaz! Link bio'da
#kelimeoyunu #kelimeki #strateji #zeka #keşfet #oyun
```

## Video 3 — 40 puan geriden çift joker bitişi (`video-3-cift-yildiz-bitis.mp4`)

**Instagram**
```
40 puan gerideydik. Torba boş, elimizde sadece 2 joker. ★★
Son hamlede iki jokerle oyunu bitirince +50 bonus… ve zafer! 🏆

Kelimeki'de oyun son hamleye kadar bitmez. Kendin dene → link bio'da

#kelimeki #kelimeoyunu #comeback #zekaoyunları #beyinjimnastiği #türkçe #mobiloyun
```

**TikTok**
```
40 puan geriden kazandık! 😱 2 joker, son hamle, +50 bonus. Link bio'da
#kelimeoyunu #kelimeki #comeback #zeka #keşfet #oyun
```

## Notlar
- Hashtag sayısı bilerek az (IG 7-8, TikTok 5-6); eski tek-tek konuşma "tavan" tartışması yok, denenip ölçülsün.
- Video 2'deki rakamlar videodaki sahneyle birebir (A: CIVATA 38 puan, 13'ü rakibe; B: CUMA 24 puan vergisiz). Açıklama metnini değiştirirsen rakamı videoya göre tut.
- Video 3 bir ÖRNEK sahnedir (puan farkı sahnelendi); açıklamada "gerçek oyunumuz" demiyor, "gerideydik" örnek anlatımı.

## LinkedIn (Video 1) — yayınlanan son metin (7 Ekim 2026, kullanıcı düzenledi)
Sayfa gönderisi (video + metin; bağlantı metinde, "link bio'da" LinkedIn'de işe yaramaz):
```
En yüksek puanlı kelime hangisi? Görebildin mi? 🤔

Kelimeki'de her hamle küçük bir strateji kararı: merkez kare kelimeni ×3 yapar, rakibin bölgesine girmek ise vergi ödetir. Kelime bul, bölgeni büyüt, tahtaya hükmet.

Ücretsiz, tarayıcıdan hemen oynanıyor: kelimeki.com
Ayrıca, App Store ve Google Play’den uygulamayı indirebilirsin.

#Kelimeki #KelimeOyunu #Türkçe #OyunGeliştirme #Strateji
```
Bağlantı `?ref=linkedin` taşıyor (admin: `li`/`linkedin` öneki → LinkedIn kanalı).
⚠ LinkedIn'de **düz repost** (yazısız) ayrı gönderi sayılmaz, kendi analitiği yoktur; analitik için "Repost with your thoughts" kullan.

## `?ref=` kodları (organik paylaşımlar)
| Yer | ref | Admin kanalı |
|---|---|---|
| Kelimeki FB sayfası (Hakkında/Web sitesi) + Video 2 FB metni | `fb` | Facebook |
| Alp Çapa FB profil bio bağlantısı | `fb-profil-bio` | Facebook |
| LinkedIn Kelimeki sayfası gönderisi | `linkedin` | LinkedIn |
| Instagram bio (marka) / hikâye bağlantı çıkartması | sade `kelimeki.com` (ref YOK → "Direkt") | Direkt |
⚠ Instagram bio ve hikâyelere `?ref=ig` / `?ref=ig-profil-bio` eklenmedikçe o trafik panelde "Direkt"e düşer. Önek kuralı: `adminGroups.ts` → `fb`/`ig`/`li` + `-` ile ayrılan etiketler kanala girer; `fbprofil` gibi tiresiz etiket "Diğer"e düşer.

## Yayın durumu (repo dışında yapılan iş — kullanıcı bildirdi)
| Video | Platform | Tarih | Not |
|---|---|---|---|
| 1 En yüksek puan | Instagram (Reel) + Facebook | 5 Ekim 2026 | Kullanıcı yükledi (Reel + FB). Hikâyeler: marka hesabında 2 (otomatik + `kelimeki.com` bağlantı çıkartmalı), kişisel hesapta 1 (`kelimeki.com`) |
| 1 En yüksek puan | LinkedIn (Kelimeki sayfası) | 7 Ekim 2026 | `?ref=linkedin` bağlantılı gönderi; Alp Çapa profilinden repost (düz repost → ayrı analitik yok) |
| 2 Hangisini oynardın | Instagram + Facebook (Kelimeki sayfaları, Reel olarak) | 7 Ekim 2026 | Instagram metninde "link bio'da"; Facebook gönderi metnine sonradan `?ref=fb` bağlantısı eklendi. Hikâye: `kelimeki.com` bağlantılı paylaşım + Alp Çapa profilinden bağlantılı hikâye repost'u |
| 3 Çift yıldız | Instagram | planlı: 8 Ekim akşamı | — |
| 1-3 | TikTok (ayrı hesap) | IG'de ilk iki sonuç görüldükten sonra | — |
| 1-3 | YouTube Shorts | en son; `ALT` → "Link açıklamada" ile yeniden üretilecek | — |
| 2-3 | LinkedIn | belirsiz | Kullanıcı kararı bekleniyor |

## İlk sonuçlar — Video 1 (7 Ekim 2026, ekran görüntüleri; örnek ÇOK küçük)
| Platform | Ölçü |
|---|---|
| Instagram + Facebook (Reel) | **273 izlenme = Facebook 225 + Instagram 48.** Facebook: 211 izleyen, **3 sn izlenme 20 (%9)**, tıklama 1, tepki/yorum/paylaşım 0, %100 takipçi olmayan, %87 erkek, 45+ ağırlıklı. Instagram (yalnızca 48 IG izlenmesini kapsayan paneller): atlama oranı %82, kaydetme 1, tutma grafiği ilk saniyede ~%45'e düşüyor, ortalama izlenme 7 sn / 13 sn. |
| LinkedIn (sayfa, 2 sa) | 12 gösterim · 3 üye · 1 tıklama · 0 tepki · 6 video izlenmesi (ort. 22 sn) · 0 yeni takipçi |
| Admin "Huni v2" (son 30 gün, organik) | Instagram 11 ziyaretçi (+3 Android kurulum) · LinkedIn 6 · Facebook 5 · üye: yalnızca LinkedIn'den 1 |
**Okuma:** asıl sorun ilk saniyeler (FB'de %91, IG'de ~%55 ilk saniyede düşüyor); izleyen kalıyorsa sonuna kadar izliyor. Organik kanallar şu an kıyaslanabilir büyüklükte değil (toplam 22 ziyaretçi / 30 gün); bedava ve ölçülebilir olduğu için sürüyor. Video 3'te (8 Ekim) ilk kareye soru/puan koymak denenebilir — dosya `generate-shorts` ile yeniden üretilir, KARAR VERİLMEDİ.
