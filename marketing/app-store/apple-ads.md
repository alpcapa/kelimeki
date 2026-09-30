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
