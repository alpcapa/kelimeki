# Apple Ads — App Store arama reklamları (30 Eylül 2026'da kuruldu)

Meta kampanyasına (`marketing/meta-reklam/kampanya-ekim-2026.md`) PARALEL,
yalnızca iOS. Neden: App Store'da indirmelerin ~%65'i doğrudan bir aramadan
sonra geliyor (Apple) ve Meta'da iOS kurulumlarının atfı GÖRÜNMÜYOR (GA4'te
`(direct)`); Apple Ads her kurulumu kendi panelinde anahtar kelimeye kadar
gösteriyor. Android'in eşdeğeri yok (Google App kampanyaları anahtar kelime
seçtirmiyor).

## Durum

| Ne | Değer |
|---|---|
| Panel | `app-ads.apple.com` → **Advanced** (Basic anahtar kelime seçtirmiyor). ⚠ `ads.apple.com` ana sayfasındaki "Get started" Apple Maps'e / Apple Business kaydına (`business.apple.com`) götürüyor — o yanlış yol; üst menüden **App Store** seçilmeli |
| Hesap | `Kelimeki_ads` · App Store Connect hesabına bağlı (Alp Resat Capa) |
| Giriş kimliği | ⚠ **destek@kelimeki.com** Apple kimliği — geliştirici hesabının (App Store Connect) kimliği DEĞİL. ASC'nin kimliğiyle açık bir Safari sekmesinde `app-ads.apple.com` (ve hoş geldin mailindeki link) `ui.ads.apple.com`'daki **yeni hesap sihirbazına** düşer ("Confirm the App Store Connect accounts… Get Started") — **Get Started'a BASMA**, ikinci hesap açılır, kampanya ve $100 kredi eskisinde kalır. Geçici yol: özel sekmede destek@ ile gir. ✅ **Çözüldü (30 Eyl):** ASC kimliği User Management'tan **Account Admin** olarak eklendi — artık iki kimlik de hesabı görür |
| Legal Entity Name | Alp Reşat Çapa — geliştirici hesabı **Bireysel**, "Kelimeki" diye kayıtlı bir tüzel kişi YOK |
| Para birimi | **USD** — Türkiye hesabında TRY sunulmuyor; sonradan DEĞİŞTİRİLEMEZ. Gerçek TL maliyeti ilk kart ekstresinden okunup buraya yazılacak |
| Saat dilimi | İstanbul |
| İletişim e-postası | destek@kelimeki.com (hizmet mailleri Zoho'ya düşer) |
| Ödeme | Kart tanımlı (30 Eyl) |
| Promosyon kredisi | **$100** — "Welcome to Apple Ads" maili, 30 Eyl 11:44, destek@. Panelde **işlendi**: Billing → Promo Credit → "Date Applied: September 30, 2026" (13:21, kullanıcı ekranı). Sayfa tutarı ve son kullanma tarihini GÖSTERMİYOR. $2/gün ile ~50 günlük bütçe → ilk okumaya (~14 Ekim) kadar harcama karttan ÇIKMAMALI, yani "ilk ekstreden TL kuru" adımı kredi bitene kadar ertelenir |

## Kampanya yapısı

```
Genel · kelime oyunu   (ID 2144785608) · Search Results · Türkiye · Manage Bids · $2/gün · bitişsiz
 ├─ Genel · exact       [kelime oyunu] [türkçe kelime oyunu] [kelime oyunları] [kelime bulmaca]
 └─ Rakip · kelimelik   [kelimelik] [kelimelik oyunu]
```

- Hepsi **Exact**, **Search Match KAPALI** (açık olursa Apple kendi seçtiği
  aramalarda da gösterir, grupların maliyeti ayrışmaz), kitle "Reach All
  Eligible Users", reklam = varsayılan ürün sayfası.
- **Max CPT $1,00.** Apple'ın önerisi $1,52'ydi; $0,50 önerinin üçte biri
  olduğundan gösterim almayabilirdi, $1,52 ise $2'lik bütçeyi günde tek
  dokunmaya indirirdi. Açık artırma ikinci fiyat, tavan ödenmez.
- **Popülerlik (Apple'ın 5'li ölçeği):** dört genel kelime de **1/5**.
  `kelimelik` öneri listesinde 2/5, Exact olarak eklenince 1/5 gösterildi.
  Yani Türkiye'de "kelime oyunu" aranmıyor denecek kadar az; insanlar oyunun
  ADINI arıyor.

## Verilen kararlar

- **Marka (`kelimeki`) kampanyası AÇILMADI** (kullanıcı: *"Kelimeki zaten
  aramalarda otomatik bizi getirmiyor mu"*). Organik sonuçta ilk biziz; marka
  reklamı yalnızca rakibin üstteki reklamına karşı savunma olurdu (Kelimo
  "Kelimeki"ye reklam veriyor — `console-formlari.md`, 12 Eyl). Hacim küçük,
  bütçe yeni kişiye gitsin. ASC arama rakamları gerekirse yeniden bakılır.
- **`kelimelik` — rakip adına reklam** kullanıcı önerisiyle eklendi, AYRI
  grupta (maliyeti genel kelimelere karışmasın). Apple buna izin veriyor;
  reklam metni ürün sayfamızdan geldiği için marka kullanımı yok.
- **`bulmaca`, `zeka oyunları` tek başına EKLENMEDİ** — çok geniş (sudoku,
  çengel bulmaca). Önerilerdeki `spiel`/`spielen` Almanca, `capcut`/`wp` vb.
  alakasız.
- **Günlük $2** (kullanıcı kararı; ~₺80). Bu hacimde tek gün bir şey
  söylemez → **karar için en az 10–14 gün**. Meta'nın 5 günlük testiyle
  doğrudan kıyaslanmaz.

## Karar kuralı (ilk okuma ~14 Ekim)

- Grup başına: harcama, gösterim, dokunma oranı (TTR), kurulum, kurulum başı
  (CPA). Kıyas: Meta'nın kaba ~₺10/kurulum tahmini (kampanya kütüğü §9) —
  gerçek TL kuru ilk ekstreden.
- 2–3 gün sonra gösterim ~0 ise tavanı yükselt; bütçe hiç harcanmıyorsa
  (1/5 hacim yüzünden olası) Broad bir `kelime oyunu` grubu düşünülür.

## Açık sorular

- **$100 kredisinin son kullanma tarihi BİLİNMİYOR.** Maildeki dipnot
  yalnızca genel şartlara bağlantı ("Apple Ads promo credit terms and
  conditions"); o şartlar kredinin "Apple'ın belirttiği bir tarihte ya da
  sürede" bitebileceğini söylüyor, gün sayısı vermiyor. Kredi tek seferlik
  (yeni hesap), devredilemez, nakde çevrilmez. Pratik kontrol: kampanya
  onaylanınca Billing → **Invoices**'ta ilk karttan çekim ne zaman görünürse
  kredi o gün bitmiş/düşmüş demektir — $2/gün ile ~50 günden ÖNCE görünürse
  buraya yaz. (Ajan `ads.apple.com` yardım sayfasını okuyamıyor, ağ engeli.)

- ~~Reklam önizlemesi "Uygulama İçi Satın Alımlar" yazıyor.~~ **KAPANDI
  (30 Eyl 2026):** iPhone'da gerçek ürün sayfasında ne "Aç" düğmesinin
  altında ne de "Bilgi" bölümünde bu ibare var — yalnızca Apple'ın reklam
  önizleme şablonu. Uygulamada IAP yok, yapılacak iş yok.

## Kütük

| Ne zaman | Ne |
|---|---|
| 30 Eyl 2026 ~12:25 | Hesap + kampanya + iki grup kuruldu. Durum **"App pending review"**, iki grup **On hold** (Apple'ın ilk uygunluk incelemesi). ⚠ `Genel · exact`in grup varsayılan teklifi $0,50 kaldı → $1,00'a çekilecek, kelime düzeyindeki teklifler kontrol edilecek |
| 30 Eyl 2026 ~12:35 | `Genel · exact` varsayılan teklif + kelime teklifleri **$1,00** yapıldı (kullanıcı bildirdi). Önizlemedeki "Uygulama İçi Satın Alımlar" sorusu hâlâ AÇIK |
| 30 Eyl 2026 | "Uygulama İçi Satın Alımlar" sorusu **kapandı**: gerçek ürün sayfasında (iPhone) ibare YOK, ne düğme altında ne "Bilgi"de (kullanıcı kontrol etti) — önizleme şablonu |
| 30 Eyl 2026 11:44 | "Welcome to Apple Ads" maili: **$100 promosyon kredisi** uygulandığı yazıyor (panelde doğrulanmadı) |
| 30 Eyl 2026 13:18 | Hâlâ **App pending review**, iki grup **On hold**, harcama $0 (~1 sa inceleme sürüyor) |
| 30 Eyl 2026 13:21 | Kredi panelde **doğrulandı**: Billing → Promo Credit, "Date Applied: September 30, 2026" |
| 30 Eyl 2026 ~16:20 | **Giriş tuzağı:** normal sekmede (ASC kimliğiyle) panel yeni hesap sihirbazına düştü, mail linki de aynı yere gitti; **özel sekmede destek@ ile girince kampanya açıldı** (kullanıcı). Hesap destek@ kimliğinde. Durum tablosuna "Giriş kimliği" satırı eklendi |
| 30 Eyl 2026 ~16:30 | Kullanıcı ASC kimliğini Apple Ads'e **Account Admin** olarak ekledi (User Management) — normal sekmeden giriş sorunu kapandı |
| 30 Eyl 2026 ~16:35 | Kampanya hâlâ **On hold** (kurulumdan ~4 sa sonra; kullanıcı bildirdi), harcama yok |
| 1 Eki 2026 00:19 | **On hold BİTTİ — iki grup "Running"** (`Rakip · kelimelik` · `Genel · exact`), Search Match Off, **grup varsayılan teklifi ikisinde de $1,00** (`Genel · exact`in $0,50 sorunu kapanmış). Son 7 gün harcama **$0,00** — Apple raporu ~3 sa gecikmeli (saat dilimi UTC); Running'e geçiş saati bilinmiyor (kullanıcı birkaç saattir bakmamıştı; kampanyanın değişiklik geçmişinden okunabilir). ⚠ Bu andan itibaren iOS "ilk kez görülen cihaz" vekili Meta ile Apple Ads'i KARIŞTIRIR | Kullanıcının ekran görüntüsü |
| 1 Eki 2026 ~10:40 | Gruplar **aktif, veri hâlâ YOK** (kullanıcı bildirdi; Running'den ~10 sa sonra, raporlama gecikmesi ~3 sa'yi aştı). Sıradaki teşhis: All Keywords → kelime durumu + teklif gücü / önerilen teklif aralığı; değişiklik geçmişinden Running saati |
| 1 Eki 2026 11:02 | **All Keywords:** altı kelimenin altısı **Running**, hepsi Max CPT **$1,00**, harcama **$0,00** (`Rakip · kelimelik`: [kelimelik oyunu] · [kelimelik] — `Genel · exact`: [kelime bulmaca] · [kelime oyunları] · [türkçe kelime o…] · [kelime oyunu]). Panelde teklif gücü sütunu YOK. **Değişiklik geçmişi Running geçişini GÖSTERMİYOR** — yalnızca kullanıcı işlemleri: 30 Eyl 9:xx (UTC) kampanya + iki grup + 4+2 kelime oluşturuldu, 1 grup değiştirildi ($0,50→$1 düzeltmesi); Apple'ın On hold→Running geçişi orada kayıt değil, saat için tek kaynak 1 Eki 00:19 gözlemimiz. Teşhis: kelimeler sorunsuz, gösterim alamıyor → büyük ihtimalle exact match + düşük hacim ve/veya teklif. Sıradaki: üstteki **Recommendations** (Apple önerilen teklifi orada gösteriyor) |
| 1 Eki 2026 ~11:10 | **Recommendations boş** (öneri yok). Karar: değişiklik YAPILMADI, 2 Eki 10:00'da yeniden bakılacak. O zaman hâlâ gösterim 0 ise TEK değişiklik: `Genel · exact` teklifi $1,50-2'ye (Search Match'li keşif grubu ayrı bir adım, aynı anda değil — etkiler ayrışsın) |
| 2 Eki 2026 10:18 | **İlk veri (son 7 gün, UTC, ~3 sa gecikmeli).** `Rakip · kelimelik`: **82 gösterim · 5 dokunuş (TTR %6,1) · 1 kurulum (CR %20) · $2,90** → ortalama CPT **$0,58** (teklif $1,00), **CPA $2,90**. `Genel · exact`: **6 gösterim · 0 dokunuş · $0**. Toplam 88 gösterim · 5 dokunuş · 1 kurulum · $2,90. Karar: **değişiklik YAPILMADI** — "gösterim 0 ise teklifi artır" koşulu tutmadı (Genel 6 gösterim aldı; 1,5 günlük veri, karar kuralı ~14 Ekim). `Genel · exact` düşük hacmi izlenecek: ~5 Eki'de hâlâ ≤ ~20 gösterimse TEK değişiklik o grubun teklifini $1,50'ye çıkarmak. Rakip grubu teklifin altında ($0,58) kazanıyor, dokunma |
| 3 Eki 2026 10:51 | **Son 7 gün (UTC, ~3 sa gecikmeli).** `Rakip · kelimelik`: **201 gösterim · 10 dokunuş (TTR %4,98) · 4 kurulum (CR %40) · $4,25** → CPT $0,42, **CPA $1,06**. `Genel · exact`: **40 gösterim · 1 dokunuş (TTR %2,5) · 1 kurulum · $0,59** (CPA $0,59). Toplam **241 gösterim · 11 dokunuş · 5 kurulum (hepsi tap-through) · $4,84 → CPA $0,97**. Karar: **değişiklik YAPILMADI** — `Genel · exact` 40 gösterimle 5 Eki koşulunun (≤ ~20) üstünde, teklif artırma tetiklenmedi. Meta karşılaştırması: Meta Android ~₺21/kurulum ↔ Apple Ads ~$1/kurulum, ama hacim çok küçük (günlük $2 bütçenin altında harcıyor) | Kullanıcının ekran görüntüleri |
| 4 Eki 2026 ~13:49 | **Son 7 gün (UTC, ~3 sa gecikmeli).** `Rakip · kelimelik`: **387 gösterim · 15 dokunuş (TTR %3,88) · 4 kurulum (CR %26,67) · $6,88** → CPT $0,46, **CPA $1,72**. `Genel · exact`: **54 gösterim · 1 dokunuş (TTR %1,85) · 1 kurulum · $0,59** (CPA $0,59). Toplam **441 gösterim · 16 dokunuş (%3,63) · 5 kurulum (CR %31,25, hepsi tap-through) · $7,47 → CPA $1,49**, CPT $0,47. Karar: **değişiklik YAPILMADI** — `Genel · exact` 54 gösterimle 5 Eki koşulunun (≤ ~20) üstünde. Not: 3 Eki'ne göre kurulum sayısı DEĞİŞMEDİ (5), harcama $4,84→$7,47 arttı → CPA $0,97→$1,49'a çıktı; 7 günlük pencere kayıyor (ilk gün çıkıyor), $1,49 trend değil gürültü sayılır (n=5). Karar kuralı ~14 Ekim | Kullanıcının ekran görüntüleri |
| 7 Eki 2026 ~14:14 | **Kullanıcı gözlemi (iPhone, TR App Store):** "kelimelik" aranınca bizim reklam ÜSTTE çıkıyor (ekran görüntüsü: `Kelimeki: Türkçe Kelime Oyu…` · Ad · varsayılan ürün sayfası ekran görüntüleri), "kelime oyunu" aranınca ÇIKMIYOR. Beklenen sonuç, çelişki yok: `Rakip · kelimelik` 4 günde 387 gösterim alırken `Genel · exact` dört kelimeyle toplam 54 gösterim aldı (4 Eki); dört genel kelime de popülerlik 1/5, tamamı **Exact** ve genel terimlerde (Words of Wonders gibi) güçlü reklamverenler var. Aynı ekranda Words of Wonders reklamı da görünüyor. Karar BEKLİYOR (kullanıcıya önerildi): `Genel · exact` teklifi $1,50'ye (kütükteki 2 Eki planı); kelime düzeyinde gösterim için **All Keywords → [kelime oyunu]** satırına bakılmalı | Kullanıcının ekran görüntüsü |
| 9 Eki 2026 ~10:29 | **Son 7 gün (UTC, ~3 sa gecikmeli; kullanıcının ekran görüntüleri).** `Rakip · kelimelik`: **875 gösterim · 35 dokunuş (TTR %4) · 6 kurulum (CR %17,14) · $14,70** → CPT $0,42, **CPA $2,45**. `Genel · exact`: **64 gösterim · 1 dokunuş (TTR %1,56) · 1 kurulum (CR %100, n=1 anlamsız) · $0,59**. Toplam **939 gösterim · 36 dokunuş (%3,83) · 7 kurulum (hepsi tap-through, CR %19,44) · $15,29 → CPA $2,18**, CPT $0,42. Karar: **değişiklik YAPILMADI**. Okuma: (1) 4 Eki'ne göre (441 gösterim · 5 kurulum · $7,47 · CPA $1,49) hacim ~2 katına çıktı, CPA $1,49→$2,18'e yükseldi; 7 günlük pencere kaydığı ve n=5-7 olduğu için trend değil gürültü sayılır. (2) Harcama ~$2,18/gün: günlük bütçeye (3 Eki notundaki $2) YAKLAŞTI, artık 'bütçenin altında harcıyor' denemez. (3) `Genel · exact` 64 gösterimle 5 Eki koşulunun (≤ ~20) üstünde → teklif artırma tetiklenmedi; ancak 7 günde 1 dokunuş (TTR %1,56) düşük hacmi doğruluyor. $1,50 teklifi KARARI hâlâ kullanıcıda (7 Eki önerisi), karar kuralı ~14 Ekim | Kullanıcının ekran görüntüleri |
