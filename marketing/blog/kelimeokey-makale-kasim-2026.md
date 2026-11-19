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

## YAZI (blogda yayınlanacak metin — haber/makale dili, 19 Kas 2. sürüm)

**Başlık:** Türkçe kelime oyunlarına yeni bir yaklaşım: Kelimeki

**Özet:** Yaklaşık üç ay önce yayına giren, her oyuncuya bir köşe veren ve rakip bölgesine
girmeyi vergiye bağlayan ücretsiz bir Türkçe kelime oyunu.

Harfleri tahtaya dizip puan toplamaya dayanan kelime oyunları Türkçede uzun
zamandır var. Bağımsız olarak geliştirilen ve yaklaşık üç ay önce yayına giren
[Kelimeki](https://kelimeki.com/?ref=kelimeokey), bu bilindik düzene tahtanın
kendisinden gelen bir kural ekliyor: oyuncular ortadan değil, köşelerinden başlıyor.

**Köşeden başlayan oyun**

Oyun 13×13'lük bir tahtada oynanıyor. Dört köşenin her biri 4×4'lük bir bölge
oluşturuyor ve her oyuncu kendi köşesinden başlıyor. İlk kelimenin köşedeki
başlangıç karesine değmesi gerekiyor; sonraki hamlelerle tahtanın ortasına doğru
ilerleniyor. Oyuncunun bölgesi, köşesine kesintisiz bağlı kendi taşlarıyla
genişliyor.

**Rakip bölgesine girmenin bedeli**

Oyunun ayırt edici yanı bölge vergisi. Rakibin bölgesine taş koymak ya da
bölgenin sınırına değmek yasak değil, ancak hamlenin puanının bir bölümü bölge
sahibine geçiyor. Bir rakip bölgesiyle etkileşimde puanın üçte biri o rakibe
gidiyor; birden fazla rakip bölgesine değen hamlelerde pay, bölge sahipleri
arasında paylaşılıyor. Böylece yüksek puanlı bir kelime her zaman en iyi hamle
olmayabiliyor: vergiden sonra geriye kalan puan, kendi bölgede kurulan daha
mütevazı bir kelimeden düşük kalabiliyor.

Tahtanın ortasındaki 5×5'lik şerit de puanı etkiliyor. Bu şeride o turda yeni bir
taş konan kelimenin puanı ikiye katlanıyor; tam merkez hücre ise üç kat
puanlıyor. Oyunda ayrıca her istenen harfe dönüşebilen iki joker bulunuyor ve
raftaki yedi taşın tamamını tek hamlede kullanmak 25 puan bonus getiriyor.

**Oynama biçimleri**

Oyun yapay zekaya karşı üç zorluk seviyesiyle (Kolay, Normal, Zor), ya da arkadaşlarla
iki veya dört kişilik canlı oyunlarla oynanabiliyor; canlı oyunlarda oyuncular
sırayla, kendi zamanlarında hamle yapıyor ve oyun içinde mesajlaşabiliyor.
Bunların yanında "Hamle Avı" adlı bölüm, üç dakika içinde tahtadaki en iyi
hamleyi bulmaya dayanıyor.

**Erişim**

Kelimeki ücretsiz ve üyelik gerektirmeden tarayıcıdan oynanabiliyor; ilk oyunda
yaklaşık bir dakikalık bir tanıtım kuralları adım adım gösteriyor. Kuralların
ayrıntıları [oyunun kurallar sayfasında](https://kelimeki.com/nasil-oynanir/?ref=kelimeokey)
yer alıyor. Oyunun Android sürümü [Google Play](https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki)
üzerinden indirilebiliyor.

---

## Gönderirken kontrol
- [ ] Yazıdaki her cümle oyunla örtüşüyor mu? (kurallar kaynağı:
  `HelpModal.tsx`; **doğrulanmayan rakam eklenmedi** — kelime sayısı, oyuncu
  sayısı, indirme sayısı bilerek yok.)
- [ ] Görsel isteniyorsa: `public/og-image.png` (sosyal kart) ya da
  `marketing/store/` kareleri.
- [ ] Yayınlanınca: bağlantıyı kütüğe yaz + 1-2 gün sonra `web_sessions`'ta
  `utm_source = 'kelimeokey'` oturumlarına bak.
