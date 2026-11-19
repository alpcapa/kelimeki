# Kelimeokey blog yazısı — Kasım 2026

**Durum (19 Kas 2026):** kelimeokey blog sahibi 6 Kas'taki e-postamıza OLUMLU döndü
(*"Makalenizi iletirseniz blog kısmına eklerim. 3 adet link çıkışı da
ekleyebilirsiniz"*). Yazı aşağıda; GÖNDERİLMEDİ, kullanıcı onayı bekliyor.
Gönderen: `destek@kelimeki.com` (imza **Kelimeki Destek** — kurumsal ad).
Bağlantı kuralları: `marketing/seo-baglanti-kontrol-listesi.md`.

## Yanıt e-postası (kısa gövde)

> Merhaba,
>
> Yanıtınız ve blogunuzda yer vereceğiniz için çok teşekkür ederiz. Makaleyi
> ekte / aşağıda iletiyoruz; üç bağlantıyı metnin içine yerleştirdik.
> Başlığı, kısa tanıtım cümlesini ve görselleri dilediğiniz gibi
> düzenleyebilirsiniz. Yayınlandığında bir bağlantı paylaşırsanız seviniriz.
>
> Saygılarımızla,
> Kelimeki Destek

## Üç bağlantı (hepsi `?ref=kelimeokey` ile — kaynağı `web_sessions`'ta ayırır)

1. `https://kelimeki.com/?ref=kelimeokey` — ana sayfa (oyunu hemen oynama)
2. `https://kelimeki.com/nasil-oynanir/?ref=kelimeokey` — kurallar sayfası
3. `https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki` — Android
   uygulaması. (iPhone okuyucular için ana sayfadaki App Store rozeti yeter;
   üçüncü bağlantıyı App Store yapmak istenirse kullanıcı karar verir.)

> ⚠ `?ref=` yalnızca KENDİ sayfalarımızda ölçüm sağlar; mağaza bağlantısına
> eklenmedi. Blog `nofollow` kullanıyorsa sıralamaya katkısı küçük olur, ama
> okuyucu trafiği yine gelir.

---

## YAZI (blogda yayınlanacak metin — KULLANICININ REVİZESİ + ajan düzeltmeleri, 19 Kas 3. sürüm)

Türkçe kelime oyunlarına yeni bir yaklaşım: Kelimeki

Temmuz 2026'da yayına giren Kelimeki, iki ya da dört kişiyle, yapay zekaya veya arkadaşlara karşı oynanabilen, strateji odaklı bir kelime oyunu. Alışılmış kelime oyunlarından farklı olarak her oyuncu kendi köşesinden başlıyor, kelimeleri yerleştirerek bölgesini büyütüyor; rakibin bölgesine temas eden ise vergiyle karşılaşıyor.

Harfleri tahtaya dizip puan toplamaya dayanan kelime oyunları Türkçede uzun zamandır var. Bağımsız olarak geliştirilen Kelimeki (https://kelimeki.com/?ref=kelimeokey), bu bilindik düzene tahtanın kendisinden gelen bir kural ekliyor: oyuncular ortadan değil, kendi köşelerinden başlıyor.

Köşeden başlayan oyun

Oyun 13×13'lük bir tahtada oynanıyor; her oyuncuya tahtanın bir köşesindeki 4×4'lük bölge ait. Her oyuncu ilk hamlesini kendi köşesindeki başlangıç karesinden yapıyor; sonraki hamlelerle tahtanın ortasına doğru ilerleyerek bölgesini genişletiyor.

Rakip bölgesine girmenin bedeli

Oyunun ayırt edici yanı bölge vergisi. Rakibin bölgesine taş koymak ya da sınırına değmek serbest, ancak bu durumda hamle puanının bir bölümü bölge sahibine vergi olarak geçiyor. Böylece yüksek puanlı bir kelime her zaman en iyi hamle olmayabiliyor: vergiden sonra geriye kalan puan, kendi bölgesinde kurulan daha mütevazı bir kelimenin puanından düşük kalabiliyor.

Tahtanın ortasındaki 5×5'lik bonus alanına yeni bir taş konan kelimenin puanı ikiye katlanıyor; tam merkez hücre ise üç kat puanlıyor. Bu da oyuncuları köşelerinden merkeze doğru ilerlemeye yöneltiyor. Raftaki yedi taşın tamamını tek hamlede kullanmak 25 puan bonus getiriyor. Oyunu, son hamlesinde yalnızca joker taş koyarak bitirmek de bonus kazandırıyor: bir jokerle 25, iki jokerle 50 puan.

Oynama biçimleri

Oyun yapay zekaya karşı üç zorluk seviyesiyle (Kolay, Normal, Zor), ya da arkadaşlarla iki veya dört kişilik canlı oyunlarla oynanabiliyor; canlı oyunlarda oyuncular sırası geldiğinde 48 saat içinde hamle yapabiliyor ve oyun içinde mesajlaşabiliyor. Bunların yanında "Hamle Avı" bölümü, üç dakika içinde tahtadaki en iyi hamleyi bulmaya yönelik bulmacalar içeriyor.

Erişim

Kelimeki ücretsiz; üyelik gerektirmeden hem tarayıcıdan hem de iPhone ve Android uygulamalarından oynanabiliyor. İlk oyunda yaklaşık bir dakikalık bir tanıtım oyunu kuralları adım adım gösteriyor. Kuralların ayrıntıları oyunun kurallar sayfasında (https://kelimeki.com/nasil-oynanir/?ref=kelimeokey) yer alıyor. Uygulamalar Google Play (https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki) ve App Store (https://apps.apple.com/app/kelimeki-t%C3%BCrk%C3%A7e-kelime-oyunu/id6809809788) üzerinden indirilebiliyor.

---

## Gönderirken kontrol
- [ ] Yazıdaki her cümle oyunla örtüşüyor mu? (kurallar kaynağı:
  `HelpModal.tsx`; **doğrulanmayan rakam eklenmedi** — kelime sayısı, oyuncu
  sayısı, indirme sayısı bilerek yok.)
- [ ] Görsel isteniyorsa: `public/og-image.png` (sosyal kart) ya da
  `marketing/store/` kareleri.
- [ ] Yayınlanınca: bağlantıyı kütüğe yaz + 1-2 gün sonra `web_sessions`'ta
  `utm_source = 'kelimeokey'` oturumlarına bak.
