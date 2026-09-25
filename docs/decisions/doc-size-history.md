# Doküman boyutu — bölme günlüğü

> Kök `CLAUDE.md` → "Doküman Boyutu Bütçesi" bölümünden ayrıldı (7 Eylül
> 2026): kural orada kaldı, hangi dosyanın ne zaman/nasıl bölündüğünü
> anlatan tarihli örnekler buraya taşındı. Bu dosyanın kendisi bir
> `reference` — grep'lenir, baştan sona okunmaz.

Her kesme noktası boyut değil **içeriğin türü**: kural ↔ anlatı, tek oturum
↔ iki oturum, normal kullanıcı ↔ admin, her sürümde koşulan liste ↔ tarihli
tur. Hiçbir satır değiştirilmez, bölüm numaraları korunur — atıflar
kırılmasın diye.

**26 Ağustos 2026 — uyarı bandı TAMAMEN boşaltıldı** (kullanıcı: *"md
bölünme işini hallet"*). Beş dosya da kendi kuralına göre bölündü ve
`npm run check-doc-size` artık tek uyarı vermiyor:

| Dosya | Önce → Sonra | Nasıl |
|---|---|---|
| `CLAUDE.md` (auto) | 82 → **59 KB** | `## Supabase`'in tarihli anlatıları → `docs/decisions/supabase-ops.md`; kural/tablo burada kaldı |
| `docs/decisions/components.md` | 183 → **62 KB** | üç cilt: `-account` (59) · `-score` (64) · kendisi (62) |
| `mobile/docs/parca-log.md` | 151 → **12 KB** | Parça 110-138 donduruldu (`parca-log-110-138.md`, FROZEN listesinde) |
| `mobile/TESTING.md` | 141 → **109 KB** | Arkadaşlar + Canlı oyun → `mobile/docs/testing-arkadaslar-canli.md` |
| `TESTING.md` | 124 → **83 KB** | Admin kontrolleri (9.7-9.15) → `docs/testing-admin.md` |

**3 Eylül 2026 — `mobile/TESTING.md` yeniden uyarı bandına girdi** (121 KB)
ve aynı kuralla ikinci kez bölündü: tarihli etkileşim/görünüm turları (bölüm
14-25, sürükleme eşiği · dokunma hedefleri · yazı boyutu · akıcılık · zoom)
→ `mobile/docs/testing-ux-turlari.md`, dosya **93 KB**'a indi. Kesme noktası
yine içeriğin türü: her sürüm baştan koşulan ÖZELLİK listesi ↔ belirli bir
Parça'nın gerilemediğini doğrulayan TARİHLİ tur. Dosyanın bölüm
numaralarının 14'ten yeniden başlaması bu ayrımın zaten var olduğunun
kanıtıydı.

**4 Eylül 2026 — `mobile/CLAUDE.md` uyarı bandındaydı (80 KB), aynı
kuralla bölündü.** Dosyanın en büyük tek bloğu "Klasör Yapısı" ağacıydı:
**24,5 KB, dosyanın %30'u**, ve içeriğinin çoğu dosya başına tarihli
gerekçe/uyarı — yani her turda değil, O DOSYAYA dokunurken gereken bilgi.
Açıklamalı ağaç `mobile/docs/klasor-yapisi.md`'ye taşındı (satırlar
değiştirilmeden), yerine yalnızca KLASÖR düzeyinde bir özet + ağaçtan çıkan
iki kural (üretilmiş dosyalar listesi, elle senkron web↔port çiftleri)
kaldı; dosya **60 KB**'a indi. `auto` sınıfının kesme noktası bir kez daha
"kural ↔ dosya başına ayrıntı" oldu — kök `CLAUDE.md`'nin kendi 26 Ağustos
bölmesindeki ayrımın aynısı.

**7 Eylül 2026 — `TESTING.md` (120 KB) bölündü.** Kesme noktası mobil
tarafın 3 Eylül'deki ayrımının aynısı: her sürümde baştan koşulan ÖZELLİK
listesi (1-13) ↔ belirli bir düzeltmenin gerilemediğini doğrulayan TARİHLİ
turlar (14+). Turlar `docs/testing-turlari.md`'ye taşındı, dosya **88 KB**'a
indi. Aynı turda kök `CLAUDE.md` de 81 KB ile uyarı bandına girmişti; bu
dosya (bölme günlüğü) o yüzden ayrıldı.

## 7 Eylül 2026 (akşam) — `CLAUDE.md` uyarı bandından çıkarıldı

Onboarding Faz 4'ün port notu ("İlk Oyun: Tanıtım Ekranı" bölümü) dosyayı
81 KB'a, yani `auto` sınıfının 80 KB'lık uyarı bandına soktu. Kural "bir
sonraki dokunuşta böl" — aynı dokunuşta iki tarihli vaka anlatısı kendi
konusunun karar dosyasına taşındı, yerlerinde tek satırlık kural + işaretçi
kaldı: Space Mono 700 yanlış teşhis dersi → `components.md`; teslim sonrası
izleme dalının silinmesi → `roadmap-arsiv.md`. Kesme noktası içeriğin
TÜRÜ (vaka anlatısı ↔ her yerde geçerli kural), satırlar değişmedi.

## 7 Eylül 2026 (gece) — `mobile/docs/parca-log.md`: cilt donduruldu (139-174)

Tanıtımın tarayıcı turu (Parça 195) yazılınca aktif cilt 200 KB'a çıkıp
`reference` uyarı bandına girdi. `reference` sınıfının kuralı **bölmek
değil**: (1) bayat anlatıyı buda, (2) hâlâ büyükse bir CİLT dondur. Anlatı
buda­nabilir değildi (her giriş bir ölçümün kaydı), o yüzden ikinci adım:
Parça 139-174 `parca-log-139-174.md`ye dondu, aktif cilt 200 → 79 KB.
Kesim parça sınırından; hiçbir satır değişmedi. `check-doc-size.mjs`in
`FROZEN` listesine tavanıyla (135 KB) eklendi — arşive yanlışlıkla yazmanın
tek yakalayıcısı o. Cilt haritası `mobile/CLAUDE.md`de dört → beş oldu.


## Kuralın kendi tarihçesi — kök `CLAUDE.md`'den taşınan gerekçeler (8 Eylül 2026)

Aşağıdaki üç anlatı 8 Eylül 2026'da kök `CLAUDE.md`'den buraya alındı: dosya
79.939 bayttı (uyarı eşiği 80.000) ve tek satırlık bir kural eklemek onu
banda soktu — yani kuralın kendi tarihçesi, kuralın konusu olan dosyayı
sınıra dayamıştı. Kurallar orada kaldı, gerekçeler burada.

**`reference` sınıfı neden eklendi (29 Ağustos 2026).** Kullanıcı sordu:
*"Büyüyen md dosyalarını bölme işini tüm md'lerde yapıyor muyuz? Gerek var
mı?"* Ölçüldü: repoda 43 `.md`, 2.3 MB. Eski `active` bütçesi ÖDENMEYEN bir
maliyeti vekaleten ölçüyordu — o dosyalar isteğe bağlı ve çoğunlukla grep'le
okunuyor. **Bölmenin ise gerçek bedeli var ve bu repo onu ödedi:**
`docs/decisions/` 22 dosyaya çıktı ve doğru dosyayı bulmak için kök
`CLAUDE.md`'de bir indeks tablosu gerekli hâle geldi (koddaki eski atıflar
bölünmeyle kırıldı). Kural kaldırılmadı, **daraltıldı**: bölme refleksi
artık yalnızca baştan sona okunan dosyalar için.

**Alt sınırın vakası (7 Eylül 2026).** `ROADMAP.md` bir düzenleme betiğinin
`open(p, 'w')` satırıyla sıfırlandı, "bütçe içinde" sayıldı ve BOŞ hâliyle
`main`'e girdi (PR #475; #476 geri aldı). Betiğe alt sınır bu yüzden eklendi.

**25 Ağustos 2026 — `docs/decisions/live-game-and-friends.md`** tam "ilk
dokunuşta böl" kuralı gereği bölündü: 156 KB'lık dosya `friends.md` /
`live-game.md` / `online-game-screen.md` olarak üçe ayrıldı, üçü de 64 KB'ın
altında. Dosya "bir gün" değil, ilk dokunuşta bölündü.

**Kural yazılırken kök `CLAUDE.md`'nin kendisi 111 KB'a çıkmıştı** — kuralı
yazmak, kuralın konusu olan dosyayı büyüttü. Öngörülen çare hemen uygulandı:
en büyük tek konu bloğu (yerel oyun kalıcılığı, 35 KB)
`docs/decisions/local-game-persistence.md`'ye taşındı, dosya 76 KB'a indi.

---

## 11 Eylül 2026 — `CLAUDE.md` (80.049 → 74.7 KB), `auto` uyarı bandı

**Tetikleyen:** admin cihaz tabloları PR'ı (#520) dosyaya iki satır ekledi
(komut listesi + utils ağacı) ve dosya **79.910 → 80.049 bayta** çıkarak
`auto` sınıfının uyarı eşiğini (80.000) 49 baytla aştı. Kuralın kendisi:
*"Uyarı bandındaki dosyayı bir sonraki dokunuşunda böl."*

**Kesme ölçütü BOYUT DEĞİL TÜR.** `auto` sınıfının betikte yazılı öğüdü
zaten bunu söylüyor: *"tarihli 'neden böyle' anlatılarını ilgili
docs/decisions/*.md'ye taşı; burada yalnızca her yerde geçerli kural/
değişmez kalsın."* Ölçüm bunu doğruladı: "Oyun Mekaniği Özeti" tek başına
dosyanın **%31'iydi** (25.163 bayt) ve içindeki en büyük maddeler kuralın
kendisiyle vaka anlatısını bir arada taşıyordu.

**Taşınanlar (anlatı) ↔ kalanlar (kural):**

| Anlatı | Nereye | Kökte kalan |
|---|---|---|
| "İletken hücre" vakası: kullanıcının yakaladığı tutarsızlık, "üye olmaz" kararının gerekçesi, iki geçişli uygulama, `territory.json`ın duyarlılık kanıtı | `game-rules.md` (YENİ) | kuralın kendisi + istisnanın sınırı |
| Zor motorunun ölçümü (%70/%72), elenen dokuz sezgisel, düşünme süresi, Faz 3/4 ürün yüzeyi, seçici altı açıklama gerekçesi | `ai-levels.md` | sözleşmeler: Normal yazılmaz, üç kopya, parite kapıları, `leaguePoints` aritesi, terminoloji |
| Vergi terminolojisi tarihçesi (uydurulan üçüncü terim, üç ölü varyantın temizliği) | `game-rules.md` | iki terimin AYRIMI + "üçüncüsünü üretme" kuralı |
| Logo'nun "Çık" modalının kaldırılması, hotseat dalının neden hiç tetiklenmediği | `game-rules.md` | logo artık teslim etmez + tek tetikleyici 7 günlük kural |
| Vercel'in atladığı commit: #447 vakası, kurtarma ölçümü, ajanın gözlem sınırı | `supabase-ops.md` | "merge ≠ canlıda, tek kanıt sha" + kurtarma adımı ve bedeli |

**Sonuç:** 80.049 → **74.659 bayt** (−%6,7), uyarı bandının ~5 KB altında.

⚠ **Bu bölmede "hiçbir satır değişmez" kuralı UYGULANAMAZ ve bu bilinçli.**
O kural bölüm SINIRINDAN kesilen dosyalar için (`TESTING.md` →
`testing-admin.md` gibi); burada kesme bir maddenin İÇİNDEN geçiyor, yani
kalan kural cümlesi yeniden yazılmak zorunda. Taşınan anlatı birebir
korundu, kalan kural kısaltıldı ve her birine karar kaydına atıf konuldu.

⚠ **Denenmedi ve bilerek denenmedi:** "Komutlar" (7,5 KB) ve "Çalışma
İlkesi" (7,6 KB) bölümleri büyük ama TAMAMI kural/indeks — taşınacak anlatı
yok, bölmek yalnızca atıfları kırardı.


## 12 Eylül 2026 — `marketing/app-store/console-formlari.md` (121 → 72,6 KB)

**Tetikleyen:** dosya 11 Eylül'de `active` uyarı bandına (120 KB) girmişti
ve kural *"bir sonraki dokunuşunda böl"* diyor. İki tur ertelendi (araya
sürüm gönderimi ve iki özellik girdi), kullanıcı üçüncü turda *"böl"* dedi.

**Kesme noktası — CEVAP KAĞIDI ↔ KAPANMIŞ VAKA ANLATISI.** Bu dosyanın işi
"Console'a ne yazılacak" sorusuna cevap vermek; ama 2.226 satırının
**1.309'u** iki kapanmış vakanın adım adım kütüğüydü: §3'ün `.p8`
indirilemedi sagası (9 Eylül'de bir Mac'ten indirilerek çözüldü) ve §13'ün
kare boru hattı anlatısı (11 Eylül'de kareler Console'a yüklendi). İkisi de
"o cevaba nasıl gelindi" — yalnızca o vakaya dönüldüğünde gerekiyor.

**Taşınan ↔ kalan, alt bölüm alt bölüm:**

| Kalan (cevap kağıdı) | Taşınan (arşiv) |
|---|---|
| §3: anahtarın künyesi + `Access neden Admin` · *"imzalama için zorunlu DEĞİL"* · *"değerler bu dosyaya YAZILMAZ"* · **24.2 kurulum durumu tablosu** · 24.2'nin doğrulandığı koşu (#614) | §3: indirme hatası, `Team Keys` ↔ `Individual Keys`, Support vakası ve metni, bekleme günlerinin durum kayıtları, "arıza ASC genelinde" teşhisi, ilk dört koşunun kütüğü, yanlış derleme numarası post-mortem'i, #612'nin reddi |
| §13: gereksinim tablosu · çekim listesi · Android setinden İKİ FARK · mağazaya giden kompozisyon kararı · eksik kare kuralı · slot doğrulaması · **alfa kanalı kuralı** · yerel önizleme · kalan iş | §13: kaynağın simülatöre çevrilmesi, ilk piksel ölçümü ve sınırları, boru hattının gün gün kütüğü (kuruluş → ilk koşu → kompozisyon bulguları → 2. karenin konu değiştirmesi → DEBUG bandı → bayat set), modal karelerinin taşınması |

**Hedef `docs/decisions/` — `marketing/app-store/` DEĞİL, ve bu bilinçli.**
Dosya bir `reference`: grep'lenir, baştan sona okunmaz. `marketing/` altına
konsaydı betiğin sınıflandırması onu `active` sayardı (kural dosya adına
değil, `docs/decisions/` ↔ `parca-log*` YOLUNA bakıyor) ve bir gün "böl"
uyarısı verirdi — oysa bir arşivin doğru çaresi budamak ya da cilt
dondurmaktır. Ayrıca depoda tarihli post-mortem'lerin adresi zaten orası ve
bulunabilirliği kök `CLAUDE.md`'nin indeks tablosu sağlıyor (bir satır
eklendi).

**Bölüm numaraları korundu:** arşivin başlıkları `## §3 — …` / `## §13 — …`
diye adlandırıldı, yani "§3" diye yapılan eski atıflar iki dosyada da
karşılık buluyor. Cevap kağıdında her boşluğa tek paragraflık bir işaretçi
kaldı. Taşınan içerikte **hiçbir satır değişmedi** — doğrulandı: eski
dosyanın boş olmayan satırlarının çokluğu, yeni ikilinin toplamına birebir
eşit (kayıp 0; eklenen 55 satır işaretçiler + arşiv başlığı).

⚠ **Bölmenin bedeli yine ödendi:** repoda §3'ün TAŞINAN kısmına bakan iki
atıf vardı (`mobile/docs/test-ortamlari.md`) ve aynı turda arşive
yönlendirildi. Üçüncü bir atıf (`parca-log.md` → §13) KALAN içeriğe
bakıyordu, dokunulmadı. Bölmeden önce `grep -rn` refleksi bu yüzden var.

⚠ **YENİ DERS — bölme, bir başlığı YALAN hâline getirebilir.** İki bölüm
başlığı da kendi içindeki bir cümleyle düzeltilmişti: §3 *"`.p8`
İNDİRİLEMEDİ"* diyordu (9 Eylül'de indirildi), §13 *"simülatöre GEREK YOK"*
diyordu ve bu iddia **aynı gün** bölümün içinde çürütülmüştü. Düzeltmeler
arşive taşınınca başlıklar yalnız kaldı — yani bölmenin KENDİSİ bir an
için yanlış bilgi üretti. İkisi de aynı turda düzeltildi (numaralar
değişmeden, gerekçe başlığın altına yazılarak).

**Kural:** bir bölümü bölmeden önce *"bu bölümün BAŞLIĞI hangi cümleyle
düzeltiliyor?"* diye sor. Düzeltme taşınan tarafa gidiyorsa başlık da
düzeltilmeli. "Hiçbir satır değişmez" kuralı TAŞINAN metin için geçerli;
kalan tarafın kendi doğruluğu ayrı bir sorumluluk.

---

## 15 Eylül 2026 — kök `CLAUDE.md` (80 → 73 KB), `auto` sınıfı uyarı bandından çıkarıldı

**Tetikleyici:** dosya 80 KB'a ulaşıp `auto` sınıfının uyarı bandına
girmişti (80 / 120 KB) ve betiğin kendi tavsiyesi *"bir sonraki dokunuşta
böl"* diyordu. İki tur üst üste uyarı görüldü, ikincisinde bölündü.

**Kesme ölçütü sınıfın kuralı:** `auto` için bölme DEĞİL, **kural ↔ anlatı
ayrımı** — *"tarihli 'neden böyle' anlatılarını `docs/decisions/*`'e taşı,
burada yalnızca HER YERDE geçerli kural/değişmez kalsın."* Yani yeni bir
dosya AÇILMADI; mevcut karar kayıtlarına eklendi.

| Taşınan | Nereye | Neden anlatı |
|---|---|---|
| "İlk Oyun: Tanıtım Ekranı" bölümünün tamamı (~3.5 KB) | `onboarding.md` | Sahneler, karşılama penceresi, ölçüm tablosu, faz geçmişi — hepsi tek özelliğin "neden böyle"si |
| "Tahta yakınlaştırması" + "Tanıtım balonu" maddeleri (~2.5 KB) | `touch-ux-bugs.md` | Dokunmatik davranış ayrıntısı; dosyanın zaten konusu |
| "Joker" maddesinin `swallowNextClick()` paragrafı (~1.3 KB) | `touch-ux-bugs.md` | Zaten oraya işaret ediyordu, gövdesi de gitti |
| "YZ seviyesi" maddesinin tam dökümü (~3.3 KB) | `ai-levels.md` | Madde zaten *"TASARIM KAYDI ai-levels.md, önce onu oku"* diyordu |
| "Bu dal merge edilmiş mi" üç tuzak tablosu (~1 KB) | `supabase-ops.md` | Vaka anlatısı; dosyada "dal temizliği" başlığı zaten vardı |
| "Teslim sonrası izleme — SİLİNDİ" maddesi | *silindi* | İçeriği `roadmap-arsiv.md`'de zaten vardı ve madde oraya işaret ediyordu — ikinci kopya |

**Her taşınan blok BİREBİR gitti** (satır aralığıyla kesilip hedefe
eklendi, tek satırı yeniden yazılmadı) ve her hedefe *"kök `CLAUDE.md`'den
15 Eylül 2026'da taşındı"* künyesi düşüldü. `CLAUDE.md`'de yerlerine
**kural çekirdeği + işaret** kaldı: değişmez kalıyor, gerekçe gidiyor.

**İndeks tablosu aynı turda güncellendi** — dört satıra "…15 Eyl 2026'da
buraya taşındı" eklendi. Bölünen içeriğin bulunabilirliğini bu tablo
sağlıyor; güncellenmezse taşıma bir kayıp olurdu.

⚠ **Önceki turun dersi uygulandı ve bir hata yakalandı.** Günlüğün kendi
kuralı *"başlığı/numarayı değiştirme, atıflar kırılır"* diyor. İlk geçişte
`## İlk Oyun: Tanıtım Ekranı (7 Eylül 2026)` başlığından tarih düşürülmüştü;
`grep -rn` taraması kırık atıf bulmadı ama başlık **eski hâline geri
alındı** — atıf taraması "bugün kırık değil" der, "yarın da kırılmaz" demez.

⚠ **"Başlık yalan oldu mu?" kontrolü koşuldu** (26 Ağustos turunun dersi):
kalan üç başlık — "İlk Oyun: Tanıtım Ekranı", "Oyun Mekaniği Özeti",
"Git / Branch Kuralı" — taşımadan sonra da kendi içeriklerini doğru
anlatıyor, düzeltme gerekmedi.

**Sonuç:** 80.489 → 73.672 bayt (~%8,5 küçülme). Uyarı listesinden ÇIKTI —
betiğin uyarı listesinde artık yalnızca `roadmap-arsiv.md` var. `auto`
tavanına (120 KB) karşı ~%39 pay kaldı.

⚠ **Kazanç mütevazı ve bu bilinçli:** taşınan ~11,5 KB'ın yerine ~4 KB
kural çekirdeği kondu. `auto` sınıfında amaç dosyayı küçültmek DEĞİL,
her turda yüklenen şeyi KURALA indirgemek; çekirdeği de kesmek bu
dosyanın var olma sebebini kesmek olurdu.


## 16 Eylül 2026 — BÖLÜM ölçüsü düzeltildi + altı dosyaya alt başlık

Kullanıcı: *"admin-panel.md'ye alt başlık ekleme işi neydi?"* → *"başla, alt
başlıkları ekle, dosya işini optimize et. **Sürekli dosya bölme uyarısı
mantıklı değil.**"*

**Kök sebep bir ölçü hatasıydı, biriken iş değil.** 15 Eylül'de eklenen
BÖLÜM ölçüsü (`enBuyukBolum`) yalnızca `^## ` başlıklarına bölüyordu. Oysa
aynı kuralın reçetesi *"ilacı bölmek değil, bloğa ALT BAŞLIK koymak"*tı —
yani önerilen tek eylem, yazdırılan sayıyı **bir bayt bile** değiştirmiyordu.
Sonuç: uyarıyı temizlemenin tek yolu kuralın açıkça yasakladığı şeydi
(bölmek), uyarı her koşumda aynı sekiz dosyayı bastı ve okunmayan sabit bir
gürültü duvarına dönüştü.

**Düzeltme:** ölçü artık YAPRAK bölümü alıyor — `##`'den `######`'ya kadar
her seviyede kesiyor, çünkü grep isabette seni en yakın başlıktan sonraki
parçaya bırakır, o başlık hangi seviyede olursa olsun. Kod çiti (```)
takibi de eklendi: çit içindeki `# ...` bir kabuk yorumudur, başlık değil
(eski ölçü de bunu kaçırıyordu).

Düzeltme TEK BAŞINA iki yanlış pozitifi temizledi — `live-game.md`
52 → 24 KB, `local-game-persistence.md` 41 → 38 KB. İkisinde alt başlık
zaten vardı; ölçü onları görmüyordu.

**Sonra kalan altı dosyaya alt başlık eklendi** (99 başlık, 245 satır;
girinti kurallarına göre yerleştirildi — 4+ boşluk girintili bir satırın
önüne başlık konamaz, markdown onu kod bloğu yapar):

| Dosya | En büyük bölüm | Eklenen |
|---|---|---|
| `admin-panel.md` | 111 → 23 KB | 15 (`###`/`####`) |
| `components-score.md` | 77 → 17 KB | 11 (`##`/`###`) |
| `components-account.md` | 75 → 22 KB | 12 (`##`) |
| `components.md` | 72 → 17 KB | 17 (`###`) |
| `online-game-screen.md` | 65 → 12 KB | 13 (`###`) |
| `mobile/docs/parca-log.md` | 108 → 9 KB | 31 (`## Parça N — …`) |

Sonuç: BÖLÜM UYARISI listesi **boş**. Hiçbir dosya bölünmedi, hiçbir cilt
dondurulmadı, tek bir atıf kırılmadı.

**Hiçbir MEVCUT satır değişmedi — ve bu iddia ölçülerek kanıtlandı.** Bir
doğrulama betiği her dosyada eklenen satırları çıkarıp sonucu `git show
HEAD:<dosya>` ile karşılaştırdı (birebir eşit), her eklemenin yalnızca bir
başlık ya da boş satır olduğunu, ve hiçbir başlığın ardından 4+ boşluk
girintili bir satır gelmediğini (kod bloğu riski) doğruladı. Altı dosyanın
`git diff --numstat`'ı da bunu gösteriyor: silinen satır **0**.

**Ders, yeni bir ölçü eklerken:** ölçünün KESTİĞİ şey ile reçetenin
DEĞİŞTİRDİĞİ şey aynı olmalı. Değilse kontrol bir iş emri değil sabit bir
gürültü üretir — ve gürültü okunmaz. Bu, 15 Eylül'ün *"sınıra çarpınca
sınırı yükseltmek kontrolü süse çevirir"* dersinin ikizi: bir kontrolü süse
çeviren ikinci yol, temizlenmesi imkânsız bir uyarı bastırmaktır.

## 23 Eylül 2026 — kök `CLAUDE.md` (81 → 79,6 KB), `auto` uyarı bandından çıkarıldı

Supabase'in Data API izin kuralı (`docs/decisions/supabase-ops.md` → "Data
API izinleri") `CLAUDE.md`in "Migration'lar" bölümüne bir kural olarak
eklendi ve dosyayı 79,5 → 81 KB'a, yani `auto` sınıfının 80 KB'lık uyarı
bandına taşıdı. Kuralın kendisi kalması gereken yerde (her migration turunda
okunuyor), o yüzden karşılığı **"Doküman Boyutu Bütçesi" bölümünün kendi
tarihli anlatısından** çıkarıldı — bölümün kuralları, tabloları ve reçeteleri
olduğu gibi duruyor. Buraya taşınan üç kayıt:

**1. 24 Ağustos 2026'nın ikinci dersi, sayıyla.** O gün `CLAUDE.md` bölündü,
ama bölünme sorunu çözmedi, YER DEĞİŞTİRDİ: `mobile/docs/parca-log.md`
sessizce **714 KB**'a, yani o tarihteki `CLAUDE.md`'nin YEDİ katına çıkmıştı.
Ölçümün otomatik olma gerekçesi bu tek sayı.

**2. `reference` bandının 200/300 → 260/400 yükseltilmesi (15 Eylül 2026).**
400 KB ≈ 100K token. Gevşetme TEK BAŞINA yapılmadı: sınıra çarpınca sınırı
yükseltmek kontrolü süse çevirir, o yüzden karşılığında bölüm ölçüsü eklendi.
`frozen` bu ölçünün DIŞINDA — o ciltlerin başlığı baştan sona okumayı zaten
yasaklıyor.

**3. Alt sınırın gerekçesi (7 Eylül 2026).** Betik 0 baytlık her `.md`'yi ve
tabanının altına düşen altı baştan sona okunan dosyayı da düşürür, çünkü bir
dosyanın BOŞALMASI da bir arıza. Ders, betik yazana: bir dosyayı yazma
modunda AÇMADAN önce içeriğini oku — vaka bu günlüğün kendisiydi.

## 25 Eylül 2026 — `docs/decisions/roadmap-arsiv.md`: cilt donduruldu (258 → 56 KB)

Arşiv `reference` uyarısına (260 KB) ~2 KB uzaktaydı ve merge turu (#565 →
… → #626) yeni kapanan maddeleri oraya taşıyacaktı. Reçetenin ilk adımı
(bayat anlatıyı buda) yerine ikinci adım seçildi, çünkü arşivin tamamı
kapanmış iş — "bayat" diye ayıklanacak bir katman yok, her satır bir atıfın
hedefi. Kesme noktası dosyanın kendi yapısından geldi: İçindekiler
tablosunun ALTI (2 Eylül'deki ilk taşımanın gövdesi, 1.0.3-1.1.0 sürüm
turları, madde 23 fazları, incelemenin geçişleri) artık hiç değişmiyordu;
üstü (15-24 Eylül taşımaları) değişiyordu. Alt katman satırı değişmeden
`roadmap-arsiv-cilt-1.md`'ye gitti ve `FROZEN` listesine girdi (tavan 210
KB). Taşınan bölümlere işaret eden 16 atıf (ROADMAP, CLAUDE, `surumler.md`,
parça günlüğü, dört karar kaydı, Play cevap kağıdı) yeni cilde çevrildi;
aktif ciltte kalanlara (§25, "24. FAZ C", güvenlik #19-#20, "Sayaç") işaret
edenler bilerek DOKUNULMADI. Tek istisna `src/game/gameReducer.ts`'teki bir
yorum (hata avı #24): motor dosyası, yalnızca bir yorum için golden/parite
turuna sokulmadı — ciltlerin başlığındaki `grep … roadmap-arsiv*.md`
reçetesi onu da buluyor.
