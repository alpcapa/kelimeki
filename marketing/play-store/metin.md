# Google Play — mağaza vitrini (22–23 Ağustos 2026; açıklama 25 Eylül 2026)

Bu dosya Play Console'a ELLE girilecek METİNLERİ ve cihazdan alınacak ekran
görüntülerinin çekim listesini taşıyor. Metin dışındaki her form (Data
safety, App content, kapalı test kanalı, tester'lar) ayrı bir dosyada:
**`console-formlari.md`**. Görseller `node scripts/play-store/build.mjs`
ile üretilir (ekran görüntüleri HARİÇ — aşağı bkz.).

| Varlık | Dosya | Durum |
|---|---|---|
| Mağaza ikonu 512×512 | `store-icon-512.png` | ✅ üretildi |
| Öne çıkan görsel 1024×500 | `feature-graphic.png` | ✅ üretildi |
| Promotional content kartı 1920×1080 (Major update) | `promo-1920x1080.png` | ✅ üretildi ve yüklendi — kart **oluşturuldu** (25 Eyl 2026), bkz. "Promotional content" |
| Telefon ekran görüntüleri (7) | kullanıcıda | ✅ cihazdan alındı, 1080×2072'ye kırpıldı (23 Ağu 2026) |

---

## Uygulama adı (≤30 karakter)

```
Kelimeki: Türkçe Kelime Oyunu
```
29 karakter (ölçüldü).

## Kısa açıklama (≤80 karakter)

**AS-BUILT — 25 Eylül 2026'da Console'a girildi, incelemeye gönderildi.**

```
Türkçe kelime oyunu: kelime kur, bölgeni büyüt. İnternetsiz ya da arkadaşınla.
```
78 karakter (ölçüldü).

## Tam açıklama (≤4000 karakter)

**AS-BUILT — 25 Eylül 2026** (kısa açıklamayla aynı gönderim). 2462
karakter (ölçüldü). ⚠ Paragraflar kod bloğunda da TEK SATIR — Console'a
aynen böyle yapıştırılır; satırı elle kırmak mağazada da satırı kırar.

```
Kelimeki, Türkçe için sıfırdan tasarlanmış bir kelime oyunu. Harflerle kelime kurarsın, tahtada kendi bölgeni büyütürsün. Yapay zekaya karşı internetsiz oyna ya da arkadaşınla online, sırayla oyna.

Klasik kelime oyunlarından farkı tek bir kuralda: tahtada bir bölgen var ve oyun, kelime kurarak o bölgeyi büyütmek üzerine kurulu. 13×13'lük tahtada her oyuncu bir köşeden başlar. Kurduğun her kelime bölgeni biraz daha genişletir; rakibinin bölgesine girersen puanın bir kısmı ona gider — "bölge vergisi". Yani her hamlede iki soru var: kaç puan alıyorum ve tahtanın neresini elimde tutuyorum? Kelime bilgisi kadar strateji de isteyen bir zeka oyunu.

NASIL OYNANIR
• Kendi köşendeki başlangıç karesinden başla, kelimelerle merkeze doğru ilerle.
• Ortadaki bölgeye taş koyarsan kelimenin puanı ikiye, tam merkezde üçe katlanır.
• Rakibin bölgesine değen ya da giren hamlelerde puanın bir kısmı ona aktarılır.
• Rafındaki yedi harfin hepsini tek hamlede kullanırsan bingo bonusu kazanırsın.
• Torba ve raflar bittiğinde oyun biter; elinde kalan harfler puanından düşülür.
• İlk oyununda kısa bir tanıtım, kuralları oynayarak öğretir.

YAPAY ZEKAYA KARŞI — İNTERNETSİZ
• Üç zorluk seviyesi: Kolay, Normal, Zor.
• 2 veya 4 kişilik oyun, anında başlar.
• İnternet bağlantısı gerekmez; sözlük uygulamanın içinde. Uçakta, yolda, çevrimdışı oyna.

ARKADAŞINLA ONLINE
• Arkadaşını davet et, sırayla oyna; 2 veya 4 kişilik online kelime oyunu.
• Sıra sana geçtiğinde bildirim gelir; hamle için 48 saatin var.
• Oyun ekranından rakiplerinle mesajlaşabilirsin.

SÖZLÜK VE KELİME ANLAMLARI
TDK sözlüğüne dayalı, 63 binden fazla kelimelik bir liste (bulmacalarda sık geçen birkaç madde ayrıca eklendi). Tahtadaki bir kelimeye dokunarak anlamına bakabilirsin — oynarken kelime dağarcığın da gelişir.

k-lig: SIRALAMA VE RÜTBELER
Oynadığın her oyun k-lig puanına işler. Puan biriktikçe rütben yükselir: Çaylak'tan başlayıp Meraklı, Oyuncu, Usta, Şampiyon, Destan, Efsane, Uzaylı ve en tepede Kozmik. Belirli eşikleri geçtiğinde ek puan ödülü kazanırsın. Sıralamayı, istatistiklerini ve geçmiş oyunlarının tahtalarını skor kartından görebilirsin.

ÜCRETSİZ VE REKLAMSIZ
Kelimeki tamamen ücretsiz. Reklam yok, uygulama içi satın alma yok. Hesap açmadan da yapay zekaya karşı oynayabilirsin; hesap yalnızca online oyun, k-lig ve oyun geçmişi için gerekiyor.

Kelime oyunlarını, bulmacaları ve harf oyunlarını seviyorsan Kelimeki'yi dene. Tarayıcıdan oynamak istersen: kelimeki.com
```

### Neden bu metin — bulunabilirlik (25 Eylül 2026)

Grow users → Acquire → **Traffic source** ölçüldü: son 28 günün 12
edinmesinin **tamamı "Paid and direct"**, Google Play search'ten SIFIR;
buna karşılık mağaza sayfasının dönüşümü **%60,38** (son 90 gün). Yani
sayfa iyi dönüştürüyor, sorun Play içinde BULUNMAMAK. Önceki metin
(22 Ağustos) "kelime oyunu"yu kısa açıklamada hiç, "online"ı hiçbir yerde
kullanmıyordu ("canlı" diyordu — kimse öyle aramıyor); "internetsiz"
bir cümlenin içinde kalmıştı; sonradan gelen zorluk seviyeleri ve
tanıtım hiç yoktu. Eklenen arama ifadeleri: kelime oyunu · online ·
internetsiz/çevrimdışı · bulmaca · harf oyunu · zeka oyunu.

⚠ **Bilerek YOK:** rakip adları (Scrabble, Kelimelik — Play meta veri
politikası: başka markayı izinsiz anmak) ve anahtar kelime listesi/tekrarı
(keyword stuffing cezası). Başlık değişmedi.

⚠ **Terim sapması:** uygulama içinde "Canlı", vitrinde "online" — vitrin
metni arama terimini kullanıyor, uygulama yüzeyi değil (sürüm notlarındaki
"seviye" ↔ "Zorluk" kararıyla aynı gerekçe).

**Ölçüm:** ~3-4 hafta sonra aynı ekranda (Acquire → Traffic source)
"Google Play search" satırı çıktı mı bak.

**Uzunluk kontrolü:** `python3 - <<'P'` ile ölç (aşağıdaki komut) — Play 4000
karakterde kesiyor ve kesilen metin sessizce kayboluyor.

---

## Promotional content — Major update kartı (25 Eylül 2026)

**AS-BUILT — Console'da oluşturuldu, incelemede.**

| Alan | Değer |
|---|---|
| Event name (iç kimlik, değiştirilemez) | `major-update-1.1-zorluk-tanitim-2026-10` |
| Tür | Major update – Features & announcements |
| Ülke / süre | Türkiye · 3 Eki 2026 12:49 UTC → 31 Eki 2026 12:49 UTC (28 gün) |
| Önizleme | başlangıçtan 3 gün önce (30 Eyl) |
| Primary image | `promo-1920x1080.png` (metinsiz; `npm run generate-play-assets`) |
| Animation / Video | yok |

Önerilen metin (tagline ≤80, description ≤500). ⚠ İlk denemede Console
"Some languages have errors" verdi; tagline'ın büyük harfle başlaması ya
da "yeni" kelimesi şüpheliydi — **Console'daki SON hâli bundan farklı
olabilir**, bir sonraki kartta oradan okuyup buraya işle.

```
Yeni: yapay zekaya karşı üç zorluk seviyesi ve oynayarak öğrenme
```
```
Kelimeki'de yapay zekaya karşı oynarken artık zorluğu sen seçiyorsun: Kolay'la ısın, Normal'de dengeli bir rakiple karşılaş, Zor'da en iyi hamleleri arayan yapay zekayı yenmeye çalış. Seçim oyun kurulumunda, her oyunda değiştirilebilir.

Oyuna yeni başlıyorsan ilk oyunun kısa bir tanıtımla açılır: kelime kurmayı, bölgeni büyütmeyi ve bölge vergisini bir dakikada oynayarak öğrenirsin.

Güncellemeyi yükle ya da uygulamayı aç, hemen oyna. İnternet gerekmez.
```

**Neden Major update, Event değil:** k-lig'de sezon yok; gerçekte olmayan
bir etkinliği duyurmak politika ihlali. Duyurulan iki özellik de 1.1.0
(665) ile production'da. **Ölçüm:** kart bittikten sonra (Kasım başı)
Grow users → Acquire → Traffic source'ta "Google Play explore/search"
satırı çıktı mı bak.

---

## Sürüm notları / "What's new" (≤500 karakter, dil BAŞINA)

**AS-BUILT — 1.1.0 (665), ilk production sürümü (13 Eylül 2026).**
Console'a bu metin girildi; Play'in çok dilli alanı `<tr-TR>` etiketiyle
kullanıldı (mağazanın tek dili tr-TR, §1):

```
<tr-TR>
Kelimeki - Yepyeni ve çok farklı bir kelime oyunuyla tanış

Türkçe için sıfırdan tasarlandı: Kendi köşenden başlar, kelime kurarak bölgeni büyütürsün. Rakibinin bölgesine girersen puanının bir kısmını ona kaptırırsın. Stratejik düşünüp, akıllı oynamalısın.

• Yapay zekaya karşı üç seviye: Kolay, Normal, Zor
• İnternetsiz oynanır — sözlük uygulamanın içinde
• Arkadaşınla canlı, sırayla oynanan oyunlar
• TDK tabanlı 63 binden fazla kelime, anlamlarıyla
• Reklam yok, uygulama içi satın alma yok
</tr-TR>
```

⚠ **496/500 karakter** (etiketler hariç ölçüldü). Tavana **4 karakter**
kaldı — bir sonraki sürümde bu metne tek kelime bile eklenemez, önce bir
yerden kısaltılmalı.

**Neden değişiklik listesi değil tanıtım:** production'da kimsede önceki
sürüm yok, "şu düzeltildi" yeni kullanıcıya bir şey söylemez. Kapalı
testteki 659 kullanıcıları 665'i production'dan alacağı için aynı metni
bir *güncelleme* notu olarak da görecekler; "ilk sürüm" ifadesinden bu
yüzden vazgeçildi (kullanıcı kararı: *"İlk sürüm demeye gerek yok"*).

⚠ **Terminoloji sapması, bilerek kabul edildi:** uygulama içinde bu şey
**"Zorluk"** (kök `CLAUDE.md` → seviyeli YZ: *"Terminoloji tek: Zorluk:
Kolay · Normal · Zor"*), mağaza metninde **"üç seviye"** yazıyor. Vitrin
metni uygulama yüzeyi değil; ikisi ayrışırsa buradaki değil oradaki
kazanır.

---

## Ekran görüntüleri — GERÇEK CİHAZDAN

**Neden emülatör/Appetize/web değil:** Play'e giden görüntülerin uygulamanın
gerçek görüntüsü olması gerekiyor; farklı bir yüzeyden alınan görsel
"yanıltıcı ekran görüntüsü" olarak değerlendirilebilir. Appetize ve Flutter
web derlemesi aynı Dart kodunu koşturuyor ama gerçek Android çerçevesi değil.

**Uygulamayı cihaza kur:** en son test derlemesi `mobile-latest`
prerelease'inde — `https://github.com/alpcapa/kelimeki/releases/download/mobile-latest/kelimeki.apk`
(Chrome'dan indir, "bilinmeyen kaynak" iznini ver). Bu `.apk`, Play'e
yüklenecek `.aab` ile AYNI koddan derleniyor.

### Teknik gereksinim
- 2–8 adet, PNG veya JPEG, alfa YOK.
- Her kenar 320–3840 px.
- **En/boy oranı 2:1'i AŞAMAZ.** Bu satır 24 Ağustos 2026'ya kadar *"16:9 ile
  9:16 arasında; telefonun 1080×2400'ü bu aralıkta — kırpma yapma"* diyordu.
  **İkisi de yanlıştı ve birbiriyle çelişiyordu:** 1080×2400 = **1:2.22**,
  yani 16:9'un (1:1.78) de 2:1'in de dışında. Modern telefonların ham
  ekran görüntüsü Play'e OLDUĞU GİBİ yüklenemez.
- **Bu yüzden kırpmak ZORUNLU** — ve zaten öyle yapıldı: 23 Ağustos'ta
  cihazdan alınan 7 kare `1080×2400` idi, üst durum çubuğu ve alt gezinme
  çubuğu kırpılarak **`1080×2072` (1:1.92)** hâline getirildi. Yeni kare
  çekilirse aynı işlem gerekir; oranı önce ölç, sonra yükle.
- Ölçmek için:
  `python3 -c "import struct;f=open('X.png','rb');f.read(16);w,h=struct.unpack('>II',f.read(8));print(w,h,round(h/w,2))"`

### ⚠ Çekmeden ÖNCE — gizlilik
Bu görseller HERKESE AÇIK yayınlanıyor ve sonradan silinse de indirilmiş
olabilir. Bu yüzden:
- **Gerçek arkadaşlarının adı/avatarı görünmesin** — canlı oyun ve arkadaş
  listesi ekranlarını test hesaplarıyla (T1/T2 gibi) çek.
- E-posta adresi geçen hiçbir ekranı çekme (Hesap Ayarları).
- Sohbet ekranında gerçek yazışma olmasın; test mesajı yaz.
- Bildirim çubuğunu temizle (bildirim yok, pil/şebeke dolu).

### Çekim listesi — tek tek

Play en fazla 8 kabul ediyor; **4 yeterli, 6 ideal.** İlk 2-3 kare arama
sonuçlarında ve listenin başında görünen karelerdir — en iyi olanları başa koy.
Aşağıdaki sıra, listede görünecek sıradır.

---

**1 — Oyun ekranı, oyunun ortası** *(en önemli kare)*

Nasıl: Setup → "Yapay Zeka ile" → 2 Kişilik → OYUNU BAŞLAT → **en az 8-10
hamle oyna** (ya da devam eden bir oyunu aç). Zaten yarıda kalmış bir oyunun
varsa onu kullan, daha hızlı.

Karede görünmeli: tahtanın en az yarısı dolu · en az iki oyuncunun renkli
bölge dış hatları · raf dolu · üstteki skor kutuları.

Neden: oyunun asıl mekaniği (bölge büyütme) yalnızca bu karede anlaşılıyor.

---

**2 — Geçerli bir hamle kurulmuşken**

Nasıl: aynı oyunda raftan tahtaya birkaç taş koy, **OYNA'ya basma.**

Karede görünmeli: konmuş taşların **yeşil** doğrulama dış hattı · yanındaki
puan rozeti · alttaki OYNA düğmesi etkin.

Neden: "bu oyun nasıl oynanıyor" sorusunu tek karede cevaplıyor.

---

**3 — Kurulum ekranı, "Arkadaşınla" sekmesi**

Nasıl: oyun ekranında logonun altındaki **"← Geri"** → "OYUN TİPİ" altında
**"Arkadaşınla"** sekmesine dokun.

Karede görünmeli: iki sekme (Yapay Zeka ile / Arkadaşınla) · "Devam Edenler"
listesinde en az bir oyun.

⚠ **Test hesabıyla çek** (T1/T2). Gerçek arkadaşlarının adı/avatarı bu karede
görünmemeli — görseller herkese açık yayınlanıyor.

Neden: iki oyun modunun varlığını gösteren tek kare.

---

**4 — Skor kartı**

Nasıl: sağ üstteki avatar → **"Skor Kartı"**.

Karede görünmeli: başlıktaki **rütbe mührü** · k-lig puanı · istatistik
kutuları (Toplam Oyun, Birincilik, En Yüksek Oyun Puanı…).

Neden: uzun vadeli ilerleme/rütbe sistemini gösteriyor.

---

**5 — Kelime anlamı**

Nasıl: oyun ekranında tahtadaki bir kelimeye dokun.

Karede görünmeli: kelime + TDK anlamı penceresi, arkada tahta.

Neden: rakiplerinden ayrıştığın yer — sözlük uygulamanın içinde.

---

**6 — Nasıl Oynanır (kurallar)**

Nasıl: oyun ekranının alt şeridinde **"Yardım"** → "Hızlı Başlangıç".

Karede görünmeli: kural maddeleri (bölge, X2/X3, bingo).

Neden: oyunun öğrenilebilir olduğunu gösteriyor.

---

**İSTEĞE BAĞLI 7 — k-lig sıralaması** (avatar → "k-lig Sıralama")

⚠ **Bu karede GERÇEK kullanıcıların takma adları görünür.** Uygulama içinde
zaten girişli herkese açıklar, ama mağaza vitrini çok daha geniş bir yayın.
Çekeceksen bunu bilerek çek; istemiyorsan 4. kare (kendi skor kartın) zaten
aynı mesajı veriyor.

---

### Çekmemen gerekenler

- **Hesap Ayarları** — e-posta adresi görünür.
- **Arkadaşlar listesi / arkadaş arama** — gerçek isimler.
- **Gerçek yazışma içeren Mesajlaşma ekranı** — çekeceksen test mesajı yaz.
- **Admin paneli** — mağaza vitrininde işi yok.

### Nasıl çekilir

- Android'de **Güç + Ses Kısma** tuşlarına birlikte bas.
- **Düzenleme/çerçeve ekleme YOK** — ama **kırpma ZORUNLU**: telefonun ham
  karesi (1080×2400 = 1:2.22) Play'in 2:1 tavanını aşıyor, olduğu gibi
  yüklenemez. Durum ve gezinme çubuklarını kırparak 1080×2072'ye indir
  (yukarıdaki "Teknik gereksinim"). Bu satır 24 Ağustos 2026'ya kadar
  *"kırpma YOK, Play'in istediği aralıkta"* diyordu — aynı dosyanın
  düzeltilmiş teknik gereksinimiyle çelişiyordu.
- Her karede önce **bildirim çubuğunu temizle** (bildirim yok, pil/şebeke dolu).

### Çekim sonrası
Dosyaları bana gönder — boyut/oran/alfa kontrolünü ölçerim, Play'in
reddedeceği bir şey varsa yüklemeden önce görürüz.
