# Instagram — App Store lansman gönderisi (16 Eylül 2026)

**Görseller:** Apple Marketing Tools'un "ilk sürüm" banner'ları (kullanıcı
indirdi). **Kanal:** Instagram, organik. **Amaç:** App Store indirmesi.

⚠ **Banner'lara DOKUNMA.** Apple'ın ürettiği bu görseller tescilli
artwork: kırpma, renk/oran değiştirme, üstüne yazı/logo bindirme yasak.
App Store rozeti zaten görselin İÇİNDE — ikinci bir rozet ekleme
(`src/utils/storeLinks.ts`'teki yerleşim kuralları web içindir, bu
görsellerde geçerli değil).

⚠ **Android'den SÖZ ETME.** Play production sürümü 13 Eylül'de gönderildi
ve bu dosya yazılırken hâlâ incelemede (`STORE_BADGES.googlePlay.url =
null`). "Yakında Android'de" demek tarih taahhüdüdür; Play vitrini
oturum AÇMADAN 404 vermeyi bıraktığında ayrı bir gönderi çıkılır.

---

## 1 · Gönderi metni (ana)

> Kelimeki artık App Store'da 🎉
>
> Türkçe için sıfırdan tasarlanmış bir kelime oyunu. Farkı tek bir kuralda: tahtada bir bölgen var ve oyun, kelime kurarak o bölgeyi büyütmek üzerine kurulu.
>
> 13×13'lük tahtanın dört köşesi oyuncuların. Kendi köşenden başlıyorsun, koyduğun her taşla bölgen genişliyor. Rakibinin bölgesine oynayabilirsin — ama vergisini ödersin 😏
>
> 🧩 63.000+ kelime (TDK kaynaklı), anlamlarıyla
> 🤖 Yapay zekaya karşı üç zorluk: Kolay, Normal, Zor
> ✈️ İnternetsiz oynanır — sözlük uygulamanın içinde
> 👥 Arkadaşınla sırayla: her hamle için 48 saat, aynı anda çevrimiçi olmak gerekmiyor
> 🆓 Ücretsiz · reklam yok · uygulama içi satın alma yok
>
> iPhone ve iPad'de. App Store'da "Kelimeki" diye ara ya da profildeki linke dokun 👆
> Tarayıcıda oynamak istersen: kelimeki.com
>
> #kelimeoyunu #zekaoyunu #bulmaca #türkçe #ücretsizoyun #appstore #iphone #yeniuygulama

**Neden bu kurgu:** Instagram feed'de yalnızca ilk satır kesilmeden
görünür — haber ("artık App Store'da") oraya konuldu, oyunun ne olduğu
ikinci satırda. Emoji'li liste tarama için; her satır bir itiraz kapatıyor
(sözlük güveni, rakip, internet, arkadaşın çevrimiçi olmaması, ücret).

## 2 · Kısa varyant (carousel/story'ye eşlik eden kısa hâl)

> Kelimeki App Store'da 🎉
>
> Kelime oyunu, ama asıl soru şu: kelimeyi NEREYE koyacaksın? 13×13'lük tahtada köşenden başla, bölgeni büyüt, rakibinin alanına girmeyi göze al (vergisi var 😏).
>
> Ücretsiz, reklamsız, internetsiz oynanıyor. Link profilde 👆
>
> #kelimeoyunu #zekaoyunu #bulmaca #türkçe #ücretsizoyun #appstore

## 3 · Story metni (banner'ın üstüne, IG'nin kendi yazı aracıyla)

> Kelimeki artık App Store'da 🎉
> Kelime kur, bölgeni büyüt, tahtaya hükmet.
> ⬇️ Link sticker: App Store

Story'ye **Link sticker** koy — story'de bio'ya gitmeden doğrudan
App Store'a götüren tek yol bu.

## 4 · Etiketler — neden 8, neden bunlar

İlk beşi (`#kelimeoyunu #zekaoyunu #bulmaca #türkçe #ücretsizoyun`)
Ağustos kampanyasıyla aynı; aynı etiket kümesini sürdürmek hesabın
konusunu netleştiriyor. Lansmana özgü üçü (`#appstore #iphone
#yeniuygulama`) yalnızca bu gönderide. Daha uzun bir liste Instagram'da
erişim getirmiyor, gönderiyi spam'e yaklaştırıyor.

⚠ **Türkçe etiketleri `trLower` refleksiyle yaz:** `#türkçe` küçük ü/ç ile.
Instagram etiketleri harf büyüklüğüne bakmıyor ama `#TÜRKÇE`nin `#TURKCE`
diye yazılması ayrı bir etikettir.

## 5 · Link ve ölçüm

**Bio linki:** `https://kelimeki.com/?ref=ig-bio` (mevcut hâli — DEĞİŞTİRME).
Site 15 Eylül'den beri App Store rozetini gösteriyor, yani bio linki hem
`?ref=` ölçümünü koruyor hem de ziyaretçiyi App Store'a götürüyor.
Bio'yu doğrudan App Store adresine çevirirsen o gönderiden gelen trafik
admin panelindeki Kaynak Hunisi'nde HİÇ görünmez (`?ref=` ilk temasta
saklanıyor, sonradan düzeltilemiyor).

**Gönderi metnindeki link tıklanabilir değil** — `kelimeki.com` satırı
akılda kalması için var, dönüşüm yolu gönderi → profil → bio linki.

**Sonucu nereden okursun:** Admin paneli → Büyüme › Kullanıcı › Kaynak
Hunisi → `ig-bio` satırı. App Store indirmeleri bu hunide GÖRÜNMEZ;
onlar App Store Connect → Analytics'te.
