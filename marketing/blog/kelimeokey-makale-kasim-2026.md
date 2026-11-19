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

## YAZI (blogda yayınlanacak metin)

**Başlık:** Kelimeki: 13×13 Tahtada, Köşeden Köşeye Türkçe Kelime Oyunu

**Özet:** Yeni bir Türkçe kelime oyunu: her oyuncunun kendi köşesi var, rakibin
bölgesine girmek ise bedeli olan bir hamle.

Türkçe kelime oyunu denince çoğumuzun aklına aynı tahta gelir: ortadan başlarsın,
harfleri yerleştirirsin, en yüksek puanı toplayan kazanır. **Kelimeki** bu
kalıba bir soru ekliyor: *Kelimeyi bilmek yetmiyorsa, onu nereye koyduğun da
önemliyse?*

### Köşeden başlarsın

Oyun 13×13'lük bir tahtada oynanır. Dört köşenin her biri 4×4'lük bir bölge ve
her oyuncu kendi köşesinden oyuna başlar. İlk kelimen mutlaka köşendeki başlangıç
karesine değmeli; oradan tahtanın ortasına doğru genişlersin. Taşlarını kendi
taşlarına bağlı biçimde ilerlettikçe bölgen de büyür.

### Rakibin bölgesine girmek bedelli

Rakibin bölgesine kelime kurmak serbest, ama bedava değil: hamlenin puanının bir
kısmı bölge sahibine gider. Bu **bölge vergisi** her hamleyi bir hesaba
çeviriyor. Yüksek puanlı bir kelime rakibin alanına değiyorsa, vergiyi ödemeye
değer mi? Yoksa kendi bölgende daha az puanla yetinmek mi akıllıca? Rakip
bölgesine bıraktığın izole bir taş ise bölgeyi senin lehine değiştirmeyebilir;
ama zincirini kendi köşene bağlamayı başarırsan o hücreler senin olur.

Tahtanın ortasındaki 5×5'lik şerit de ayrı bir gerilim: orada yeni bir taş
koyarak kurduğun kelime çarpanla puanlanır, tam merkez ise üç kat.

### Kime karşı oynarsın

- **Yapay zekaya karşı:** Kolay, Normal ve Zor olmak üzere üç seviye.
- **Arkadaşınla:** Canlı oyun; sırayla, istediğin zaman hamleni yap. 2 ya da 4
  kişilik oynanabilir ve oyun içi mesajlaşma var.
- **Hamle Avı:** 3 dakikalık bir bulmaca: tahtadaki en iyi hamleyi bul.

Oyunda iki joker taş var; her istediğin harfe dönüşür. Raftaki 7 taşın hepsini
tek hamlede kullanırsan 25 puan bonus kazanırsın.

### Ücretsiz ve hemen başlar

Kelimeki ücretsiz; üyelik gerekmeden tarayıcıdan oynayabilirsin. İlk oyunda
yaklaşık bir dakikalık, oynayarak öğreten kısa bir tanıtım seni karşılıyor.
Android uygulaması da Google Play'de.

- **Hemen oyna:** [kelimeki.com](https://kelimeki.com/?ref=kelimeokey)
- **Kurallar:** [Nasıl oynanır?](https://kelimeki.com/nasil-oynanir/?ref=kelimeokey)
- **Android:** [Google Play'den indir](https://play.google.com/store/apps/details?id=com.kelimeki.kelimeki)

*Kelimeki, bağımsız olarak geliştirilen bir Türkçe kelime oyunudur.*

---

## Gönderirken kontrol
- [ ] Yazıdaki her cümle oyunla örtüşüyor mu? (kurallar kaynağı:
  `HelpModal.tsx`; **doğrulanmayan rakam eklenmedi** — kelime sayısı, oyuncu
  sayısı, indirme sayısı bilerek yok.)
- [ ] Görsel isteniyorsa: `public/og-image.png` (sosyal kart) ya da
  `marketing/store/` kareleri.
- [ ] Yayınlanınca: bağlantıyı kütüğe yaz + 1-2 gün sonra `web_sessions`'ta
  `utm_source = 'kelimeokey'` oturumlarına bak.
