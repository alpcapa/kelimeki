# 1.1.1 cihaz turu — adım adım (25 Eylül 2026)

`ROADMAP.md` → "Tur sonu TEST PLANI"nın söz verdiği adım adım liste. Tur
BİR kez, son derleme üzerinde koşulur. Maddelerin gerekçesi ve ayrıntısı
atıf verilen bölümlerde; burada yalnızca SIRA ve KAPSAM var.

**Derleme:** `main` koşusu **#723** (`8c1828f`) — `mobile-latest`teki
`.apk` ve TestFlight'taki 1.1.1 bu. ✅ Plan adım 1 (CI + bütün derleme
adımları yeşil) 25 Eylül'de doğrulandı.

## Sonuç (26 Eylül 2026, kullanıcı)

A–D ✅, **tek bulgu:** D'nin ilk maddesi — uçak modunda Canlı oyun mesajı
ham `Failed host lookup: 'xvq….supabase.co'` gösterdi (girişte Türkçe
çıktı). Düzeltme taslak PR, **sonraki trende**; 1.1.1'i durdurmuyor (metin
düzeltmesi, acil istisna değil). **E koşulmadı** (yeni e-posta gerekiyor).

## A. Kurulum (Android)

- [ ] Play'den kurulu Kelimeki'yi **kaldır** (imza farklı, `.apk` üstüne
      kurulamaz). Yerel oyun/ayar gider; hesaptaki bulut kaydı kalır.
- [ ] `mobile-latest` prerelease'inden `kelimeki.apk`'yı indir, kur.
- [ ] Setup teşhis satırı **`Derleme 8c1828f`** ve sürüm **1.1.1** demeli.
      Değilse dur — bayat paket.

⚠ Temiz kurulum bilerek: zoom balonu (E) ve tanıtım ilk açılışı ister.

## B. Misafirken (girişsiz) — sunucu damgaları + zoom balonu

1. [ ] Girişsiz aç → oyuna başlamadan bir dakika bekle (§32 ilk madde:
       `guest_visits`e `utm_source='app'` satırı).
2. [ ] 2 kişilik YZ oyunu aç. **Zoom balonu** çıksın, DOKUNMA → ~4 sn'de
       kendiliğinden kaybolmalı (`testing-ux-turlari.md` → zoom balonu).
3. [ ] Robot avatarı daire içinde ortalı mı — Android'de telafi YOK, kaymış
       görünmemeli (§29.4); puan sütunu avatarların altında (§29.5).
4. [ ] İki hamle oyna, sonra oyun ekranındaki **GİRİŞ** ile giriş yap →
       §28.2-28.4 (skor kutusunda hesap adın, "Misafir" değil).
5. [ ] Birkaç hamle daha, "← Geri" → Setup'ta **TEK** satır, son skorlarla
       (§28.6). Web'de aynı hesapla aynı tek satır (§28.7).
6. [ ] Oyuna dön ve **bitir** → oyun sonunda hesap adın (§28.4); Setup'ta
       o oyundan iz yok (§28.5).
7. [ ] Uygulamayı kapat/aç (girişliyken) → `guest_visits`e yeni satır
       DÜŞMEMELİ (§32).

## C. Taş değiştirme sınırı (yerel oyunun asıl kanıtı)

- [ ] Yeni bir YZ oyununu torba 7'nin altına inene kadar götür → §27'nin
      ilk üç maddesi (seçim anında uyarı, 3'e düşünce kaybolur, torba
      sayısı değişmez).

## D. Hata metinleri + canlı liste

- [ ] §31 ilk madde: uçak modunda giriş dene + Canlı oyunda mesaj → Türkçe
      cümle, ham `{`/`Exception`/İngilizce YOK.
- [ ] §31 ikinci madde: Canlı oyunda sıra RAKİPTEYKEN hamle → **"Sıra sende
      değil."** (bu maddesiz birincisi yanlış güven verir).
- [ ] §15'in ilk üç maddesi (WiFi kes/ aç, uçak modu) — 504 yeniden
      denemesinin cihazdaki tek dolaylı kanıtı; 504'ü elle üretmenin yolu yok.

## E. Kayıt onayı (yeni e-posta adresi gerekir)

- [ ] Uygulamadan yeni hesap aç → §30 ilk iki madde: eylem cümlesi KALIN +
      BÜYÜK, `EDİP`/`VERİN` noktalı İ.
- [ ] Bu hesap §32'nin "yeni kayıt `Uygulama` satırına" maddesini de besler.
- ⚠ §30'un "onay linki pencereyi kapatır" maddesi **`.apk`'da KOŞULAMAZ**:
  App Links debug imzada tarayıcıda açılır (`testing-bildirimler.md`
  tablosu). O madde iPhone'da (F) ya da Play'deki 1.1.1'de.

## F. iPhone — TestFlight 1.1.1, YALNIZCA duman turu (#557)

✅ **25 Eylül: ilk üç madde kullanıcı tarafından OK** — ardından App Store
incelemesine gönderildi (`mobile/docs/surumler.md` → "1.1.1").

- [x] TestFlight'tan 1.1.1'i kur; Setup'ta `Derleme 8c1828f`.
- [x] Açılıyor, bir YZ oyunu başlıyor, robot avatarı ortalı (§29.1-29.2).
- [x] Bir metin alanında (ör. giriş e-postası) uzun bas → seçim menüsü
      **Türkçe** (Kes/Kopyala/Yapıştır), İngilizce değil.
- [ ] Setup altındaki **Gizlilik Politikası** linki → **"Son güncelleme 24 Eylül 2026"**,
      6. bölümde (6) ve (7) maddeleri var (#626).
- [ ] (E'den kalan) E-postadaki onay linki iPhone'da uygulamayı açıp
      pencereyi KAPATMALI (§30 üçüncü madde).
- Tam listeyi iOS'ta TEKRARLAMA — ortak Dart kodu APK'da doğrulandı.

## G. Sunucu tarafı — ajana bırak

B, C ve E bittikten sonra ajan Supabase'den okur, kullanıcı panele
bakmak zorunda değil: `guest_visits` (app satırı, `is_standalone` NULL,
girişliyken yeni satır yok), `game_starts`/`game_finishes` (`utm_source`,
`platform = 'android'`, girişliyken `anon_id` NULL), yeni hesabın
`profiles.signup_utm_source = 'app'`, `client_errors`te `hata-metni:*`
satırları.

## Tur sonu

Hepsi ✅ → `mobile/docs/surumler.md` → "1.1.1" ikinci kutusu işaretlenir;
Play'e `.aab` + ASC'de 1.1.1 kaydı ~27-28 Eylül (kullanıcı kararı).
