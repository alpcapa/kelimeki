# Cihaz testi — ölçüm ve telemetri (sunucuya düşen satırlar)

> `mobile/TESTING.md`'nin 14., 18., 32. ve 33. bölümleri. 27 Eylül 2026'da o
> dosya 131 KB ile uyarı bandında olduğu için buraya taşındı (kök
> `CLAUDE.md` → "Doküman Boyutu Bütçesi"). **Hiçbir madde değişmedi**,
> bölüm numaraları korundu — atıflar kırılmasın diye.
>
> **Neden bu dördü:** hiçbiri ekranda görülen bir davranışı değil,
> SUNUCUYA yazılan telemetri/ölçüm satırını doğruluyor (`client_errors`,
> `game_starts`, `guest_visits`, `funnel_events`, `device_visits`) —
> kontrolü admin panelinden ya da Supabase'den okunuyor. Kesme noktası boyut
> değil, NEYİN doğrulandığı.

## 14. Hata telemetrisi (Parça 123)

Uygulamada doğan hatalar anonim olarak `client_errors` tablosuna yazılıyor
(hesap kimliği YOK). Portta okuma yüzeyi HİÇ YOK — kontrol web'deki Admin
Paneli → **Hatalar** sekmesinden yapılır (kök `TESTING.md` bölüm 9.12).

Bu bölümün tamamı **telemetrinin ÜRÜNÜ BOZMADIĞINI** doğrulamak içindir;
kayıtların panelde görünmesi ikincil.

- [ ] **Uçak modunda uygulama normal çalışıyor.** Çevrimdışıyken yerel/YZ
      oyunu oyna, Setup'a çık, gir — hiçbir yavaşlama/donma/ek uyarı
      olmamalı. Telemetri ağ hatasında sessizce vazgeçmek zorunda.
- [ ] **Çevrimdışı hamleler panelde İZ BIRAKMIYOR.** Uçak modunda bir Canlı
      oyunda hamle dene (ekranda "sunucuya ulaşılamıyor" uyarısı çıkar) →
      web panelinde bu yüzden YENİ bir hata satırı ÇIKMAMALI. Bu BEKLENEN
      bir durum; çıkıyorsa filtre bozulmuştur ve panel kısa sürede
      okunamaz hâle gelir.
- [ ] **Sunucunun kendi reddi de iz bırakmıyor.** Sırası sende değilken bir
      hamle göndermeye çalış ("Sıra sende değil.") → yeni satır olmamalı.
- [ ] **Panelde görünen kayıtların platformu doğru.** Gerçek bir hata
      düştüyse `ios`/`android` (Flutter web'de `app-web`) olmalı, `web`
      DEĞİL — `web` React uygulamasına ait.
- [ ] **Derleme kimliği dolu.** CI'dan kurulan bir derlemede kayıttaki
      `build`, Setup teşhis satırındaki sha ile AYNI olmalı. Boşsa
      "hangi sürümde?" sorusu cevapsız kalır — telemetrinin yarısı gider.
- [ ] **Yol her kayıtta `app`.** Portta ekran adı/token taşınmıyor.
- [ ] **Kırmızı ekran hâlâ çalışıyor** (debug derlemede): `FlutterError`
      yakalayıcısı raporu gönderirken ÖNCEKİ davranışı da çağırmalı, yani
      konsol logu/kırmızı ekran kaybolmamalı.

---

## 18. Telemetri — sürüm ve ekran adı (23 Ağustos 2026, Parça 130)

Cihazda koşulur; karşılığı admin panelinin "Hatalar" sekmesi ve
Büyüme > Kullanıcı > "Sürüm Dağılımı" tablosu.

- [ ] **Sürüm satırı doğru:** Setup'ın altındaki `Sürüm 1.0.0` metni
      `pubspec.yaml`taki sürümle aynı olmalı. (Ayrışırsa CI zaten düşer —
      `app_version_parity_test.dart` — ama cihazda bir kez gözle bak.)
- [ ] **Bir YZ oyunu aç** → panelde Sürüm Dağılımı tablosunda `iOS` (ya da
      `Android`) satırı belirmeli; satıra dokununca sürüm kırılımı açılmalı
      ve uygulamanın sürümü orada olmalı. Sürüm `—` çıkıyorsa `logGameStart`
      platform/sürüm göndermiyor demektir. (Tablo 16 Eylül 2026'da açılır
      hâle geldi — üst satır artık PLATFORM.)
- [ ] **Aynı oyunu BİTİR** (16 Eylül 2026) → Büyüme > Oyun'daki "Oyun Sayısı"
      grafiğinde `iOS`/`Android` serisi o günün kovasında **1 artmalı**.
      Artmıyor ve artış "Diğer"e gidiyorsa `logGameFinish` `platform`
      alanını göndermiyor demektir (`data/games_api.dart`) — grafiğin
      platform kırılımını besleyen TEK alan bu. ⚠ Mağazadaki ESKİ pakette
      bu alan yok, yani oradan biten oyunların "Diğer"e düşmesi BEKLENEN;
      testi bu değişikliği içeren bir derlemeyle koş.
- [ ] **Ekran adı:** oyun ekranındayken bir hata oluştur (ör. uçak modunda
      Canlı bir oyuna gir) → hata kaydının "Yol" alanı `game` /
      `online-game` / `intro` olmalı, `app` DEĞİL. `app` görünüyorsa ya
      gözlemci takılı değil ya push'ta `RouteSettings(name: …)` unutulmuş.
- [ ] **Zorunlu güncelleme kapısı hâlâ çalışıyor:** `app_config`taki eşiği
      geçici olarak uygulamanın sürümünün ÜSTÜNE çek → güncelleme ekranı
      çıkmalı; geri al → normal açılmalı. (Sürüm sabiti bu kapının girdisi;
      parite testi tam bunu koruyor.)

## 32. Kaynak Hunisi — app'in damgası (Parça 214, 22 Eylül 2026)

⚠ **Bu bölüm SUNUCUYA yazılanı doğrular** — `flutter test` sahte uçlarla
koşuyor, yani "satır gerçekten düştü mü" sorusunu YALNIZCA burası
cevaplıyor. Kontroller admin panelinden (web) ya da Supabase'den okunur.

- [ ] **Girişsiz açılışta `guest_visits`e satır düşer.** Uygulamayı
      ÇIKIŞ YAPMIŞ hâlde aç → `guest_visits` tablosunda en yeni satır
      `utm_source = 'app'`, `anon_id` dolu, `device_type` = `ios`/`android`
      olmalı. ⚠ `is_standalone` NULL olmalı (native uygulama "ana ekrana
      ekleme" sorusunun dışında).
- [ ] **Aynı gün ikinci açılış YENİ satır yazmaz.** Uygulamayı kapat/aç →
      satır sayısı artmamalı (günde bir kez kuralı).
- [ ] **GİRİŞLİYKEN hiç yazmaz.** Giriş yap, uygulamayı kapat/aç →
      `guest_visits`e yeni satır DÜŞMEMELİ. (Sunucu da RLS ile reddeder;
      burada istemcinin hiç denemediğini doğruluyoruz.)
- [ ] **Yeni kayıt `Uygulama` satırına düşer.** Uygulamadan yeni bir hesap
      aç → `profiles.signup_utm_source = 'app'` olmalı, admin panelinde
      Büyüme > Kullanıcı > **Kanal → Üye Kalitesi**'nde **Mobil Uygulama**
      satırının "Üye"si artmalı.
      ⚠ `bilinmiyor` satırı ARTMAMALI — artıyorsa damga metadata'ya
      girmemiş demektir (anahtar adı `utmSource`, camelCase).
- [ ] **YZ oyunu başlat/bitir → `game_starts`/`game_finishes`.** Misafirken
      bir YZ oyunu başlat ve bitir → iki satırda da `utm_source = 'app'`,
      `game_starts.anon_id` dolu. ⚠ **Girişliyken bitirilen oyunda
      `game_finishes.anon_id` NULL olmalı** (gizlilik: anonim kod ile hesap
      kimliği aynı satırda ASLA bulunmaz).
- ⚠ **Eski "dört adım aynı satırda" maddesi DÜŞTÜ (25 Eylül 2026):** bu
      bölüm yazıldığında panelde Gelen/Üye/Başlayan/Biten sütunlu bir
      Kaynak Hunisi vardı; #625 onu yalnızca üye kohortuna (Üye Kalitesi)
      indirdi, misafir adımları Huni v2'nin işi. Damganın kendisi
      yukarıdaki satır kontrolleriyle doğrulanır.
- [ ] **"Ana Ekrana Ekleme" dökümü app'ten ETKİLENMEZ.** App açılışlarından
      sonra o tablodaki toplam ziyaretçi sayısı artmamalı (migration
      `20260922070950` app satırlarını eliyor). Artıyorsa filtre düşmüş.

## 33. Huni v2 + Cihaz kartları — app'in satırları (Parça 216, 27 Eylül 2026)

⚠ Bölüm 32 gibi SUNUCUYA yazılanı doğrular (testler sahte uçla koşuyor).
Kontroller admin panelinden (Büyüme > Kullanıcı) ya da Supabase'den okunur.

- [ ] **Yeni kurulum → `land` kanalı `app`.** Uygulamayı SİL, yeniden kur,
      aç → `funnel_events`te o cihazın `land` satırı: `platform` =
      `ios`/`android`, `channel = 'app'`, `app_version` dolu. Aynı anda
      `visit` satırı. ⚠ `channel = 'mevcut'` çıkıyorsa "önceden iz"
      okuması anonim kod üretildikten SONRA yapılmış demektir
      (`bootstrap.dart`taki sıra).
- [ ] **Güncelleyen eski kullanıcı → `mevcut`.** Önceki sürümü kurulu bir
      cihazı GÜNCELLE, aç → `land` satırı `channel = 'mevcut'`. Panelde
      "Eski cihaz (kohort dışı)" sayısı artar, kohort satırları ARTMAZ.
- [ ] **Aynı gün tekrar açılış yeni satır yazmaz; ertesi gün `visit`.**
      Uygulamayı arka plana al/öne getir → aynı İstanbul gününde yeni satır
      YOK. Ertesi gün öne getir (kapatmadan) → yeni `visit`.
- [ ] **Olaylar:** YZ oyunu başlat → `game_start`; bitir → `game_finish`
      (girişli de, misafir de); uygulamadan hesap aç → `signup`. Üçünde de
      `channel` NULL. ⚠ 7 günlük terk kaydı `game_finish` YAZMAZ.
- [ ] **Hiçbir satırda hesap kimliği yok** — tabloda `user_id` sütunu da yok,
      saat de yok (`day`). Burada yalnızca "satır düşüyor mu" doğrulanır.
- [ ] **Cihaz pingi (`device_visits`) GİRİŞLİYKEN DE düşer.** Girişli aç →
      yeni satır: `device_type` = `ios`/`android`, `os_version` dolu (`18.1`
      / `14` biçimi), `device_model` iOS'ta `iPhone`/`iPad` (makine kodu
      DEĞİL), Android'de model kodu (`SM-…`). Aynı gün ikinci açılış yazmaz.
- [ ] **Panel:** "Cihaz" ve "Cihaz Markası" kartlarında uygulama satırları
      görünür (iOS → Apple, Android → marka). Görününce kartlardaki "Web"
      etiketini kaldır (ROADMAP #40), Huni v2'de iOS/Android satırları
      görününce onunkini de.
