# SEO — dış bağlantı kontrol listesi (6 Kasım 2026)

**Neden:** Search Console'a göre (bkz. `docs/decisions/seo.md` → "GSC okuması — 6
Kasım 2026") site yalnızca "kelimeki" aramasında görünüyor. Tür aramalarında
(`kelime oyunu`) sıralamanın asıl kaldıracı dış bağlantı. Reklam organik
sıralamayı etkilemez.

**Kural:** her kutu işaretlenince tarihini yanına yaz (`[x] 8 Kas`). Bağlantı
verirken kök adres `https://kelimeki.com/` kullanılır; kaynak ölçmek için
`?ref=<kanal>` eklenebilir (canonical var, indeks etkilenmez).

## A. Kendi hesaplarımız (30 dk, hepsi sizin kontrolünüzde)
Sosyal profil bağlantıları çoğu zaman `nofollow`'dur: sıralamaya katkısı küçük,
ama Google'a "bu site gerçek bir marka" sinyali verir ve keşfi kolaylaştırır.

- [ ] **App Store** — Marketing URL `https://kelimeki.com` (form kaydı:
  `marketing/app-store/console-formlari.md`). Mağaza sayfasında görünüyor mu?
- [ ] **Google Play** — Website `https://kelimeki.com` (form kaydı:
  `marketing/play-store/console-formlari.md`). Mağaza sayfasında görünüyor mu?
- [ ] **Instagram** — bio linki `?ref=ig-bio` (kayıtlı; DEĞİŞTİRME).
- [ ] **Facebook sayfası** — "Hakkında → Web sitesi" alanı dolu mu?
- [ ] **LinkedIn şirket sayfası** — Web sitesi alanı dolu mu?
- [ ] **YouTube / Shorts kanalı** — kanal açıklamasında ve her videonun ilk
  satırında `kelimeki.com` var mı? (`marketing/shorts-2026-10/`)
- [ ] **GitHub** — depo herkese açıksa README'de site bağlantısı (kontrol et).

## B. Dışarıdan bağlantı (asıl etki burada; haftada 2-3 hedef yeter)
- [ ] **"En iyi Türkçe kelime oyunları" yazan bloglar ve listeler:** "kelime
  oyunu", "Türkçe kelime oyunu", "Wordle Türkçe" aratıp ilk 3 sayfadaki
  listeleri çıkar, yazarına kısa bir e-posta at (şablon aşağıda).
- [ ] **Uygulama/oyun tanıtım siteleri ve bültenleri** (Türkçe mobil oyun
  haberleri, uygulama inceleme blogları).
- [ ] **Türkçe öğretmenleri / eğitim toplulukları** — oyun kelime dağarcığı
  için kullanılabilir; öğretmen blogları ve eğitim sitelerine tanıtım.
- [ ] **Forumlar** (teknoloji ve mobil oyun bölümleri): TEK, dürüst bir
  "yaptığım oyunu paylaşıyorum" başlığı; her forumun kendi tanıtım kuralını
  önce oku, tekrar tekrar yazma.
- [ ] **Yabancı dizinler:** Product Hunt, AlternativeTo (Wordle ve benzeri
  oyunların "alternatifi" olarak). Küçük ama kalıcı bağlantı.
- [ ] **Bağımsız geliştirici toplulukları / Türkçe girişim yazıları:** "bu
  oyunu nasıl yaptım" tarzı bir yazı hem bağlantı hem ilgi getirir.

## C. Kısa e-posta şablonu (blog/liste yazarına)
> Merhaba, "<yazının başlığı>" yazınızı okudum. Kelimeki adında, 13×13 tahtada
> köşe bölgeleriyle oynanan, ücretsiz bir Türkçe kelime oyunu geliştirdim
> (yapay zekaya ya da arkadaşlarınıza karşı). Uygun görürseniz listenize
> ekleyebilirsiniz: https://kelimeki.com — Teşekkürler.

## D. Yapılmayacaklar
- Satın alınmış bağlantı, yorum/forum spam'i, aynı metni onlarca yere yapıştırma
  (Google bunları cezalandırır, hesap da kapatılır).
- Aynı gün onlarca bağlantı: doğal görünmesi için yayıl, haftada birkaç tane.

## E. Ölçüm
- Search Console → **Links** (sol menü) → "External links": dış bağlantı
  sayısı ve kaynak siteler. Şu an bu rapora bakılmadı; ilk okumayı kaydet.
- 4 hafta sonra Performance → Queries'te "kelime oyunu" benzeri sorgu çıktı mı?
- Sonuç `docs/decisions/seo.md`'ye tarihli bir satır olarak yazılır.
