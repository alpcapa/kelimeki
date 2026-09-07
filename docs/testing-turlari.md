# Kelimeki — Tarihli Elle Test Turları (web)

Bu dosya `TESTING.md`'den ayrıldı (7 Eylül 2026, doküman boyutu bütçesi —
dosya 120 KB uyarı bandına girmişti). Kesme noktası boyut değil **içeriğin
türü**: `TESTING.md` her sürümde baştan koşulan ÖZELLİK listesidir; burası
belirli bir düzeltmenin/özelliğin gerilemediğini doğrulayan TARİHLİ turlar.
Aynı ayrım mobil tarafta 3 Eylül 2026'da yapılmıştı
(`mobile/docs/testing-ux-turlari.md`).

Bölüm numaraları DEĞİŞTİRİLMEDİ (14'ten devam ediyor) — koddaki ve öteki
dokümanlardaki atıflar kırılmasın diye.

---

## 14. Oyundan Setup'a dönüş — "← Geri" (21 Ağustos 2026)

- [ ] **Görünür:** Oyun ekranında logonun hemen altında ince, koyu bir
      "← Geri" yazıyor ve tahtanın sol kenarıyla hizalı duruyor.
- [ ] **Dokunuş:** Hem etikete hem logoya dokunmak Setup'a döndürüyor.
- [ ] **Header bozulmadı:** Skor kutuları logoyla aynı hizada; tahta
      eskisine göre gözle görülür şekilde aşağı kaymadı.
- [ ] **4 kişilik + girişli hesap:** Avatar/GİRİŞ ile etiket çakışmıyor,
      skor kutuları kırpılmıyor (dar telefonda da).
- [ ] **Canlı oyunda da var:** Aynı etiket Canlı oyun ekranında da
      görünüyor ve oradan Canlı listesine döndürüyor.

## 15. Giriş varsayılanı — hangi sekme açılıyor (21 Ağustos 2026)

- [ ] **YZ boş + Canlı oyun var:** Devam eden YZ oyunu OLMAYAN, ama devam
      eden Canlı oyunu OLAN bir hesapla gir → "Arkadaşınla" açık gelmeli,
      sıra kendisinde olmasa bile.
- [ ] **YZ oyunu varsa kaçırılmaz:** Devam eden bir YZ oyunu VARKEN ve
      Canlı'da bekleyen iş YOKKEN gir → "Yapay Zeka ile" açık gelmeli.
- [ ] **Bekleyen iş her şeyin önünde:** Sırası kendisinde bir Canlı oyun ya
      da bekleyen davet varsa, YZ oyunu olsa bile "Arkadaşınla" açılmalı.
- [ ] **Elle seçim ezilmiyor:** Açılıştan sonra elle "Yapay Zeka ile"ye geç,
      birkaç dakika bekle (Realtime/öne dönüş tazelemeleri) → sekme
      kendiliğinden Canlı'ya ATLAMAMALI.
- [ ] **Ağ kesintisi kararı yakmıyor:** Uçak modunda aç, sonra bağlantıyı
      geri ver → doğru sekme yine de açılmalı (karar düşen istekte
      tüketilmez).

## 16. Joker düzenleme — GERÇEK dokunmatik cihazda (22 Ağustos 2026)

Bir kullanıcı (Android) tahtaya koyduğu jokere tekrar dokunduğunda pencerenin
açılmadığını ve harfin kendiliğinden değiştiğini bildirdi (A → C). Kök sebep
dokunmatik tarayıcıların `pointerup`tan SONRA ürettiği uyumluluk (compat)
click'iydi; ayrıntı ve ölçümler `CLAUDE.md` → "Joker (`?`)". Otomatik
regresyon `tests/smoke.spec.ts`te var (emüle dokunmatik) — burası **gerçek
cihaz** teyidi, çünkü compat olay sırası tarayıcı/cihaz farkı taşıyor.

Her satırı **hem Android Chrome hem iOS Safari** ile, hem de **hem yerel (YZ)
hem Canlı** oyun ekranında koş — ikisi bu deseni paylaşıyor.

- [ ] **Tahtanın ÜST satırlarındaki joker:** Jokeri koy, harfini seç, sonra
      taşa bir kez dokun → "Jokeri Hangi Harfe Çevir?" penceresi AÇIK
      KALMALI (açılıp anında kapanmamalı).
- [ ] **Tahtanın ALT satırlarındaki joker (asıl vaka):** Aynısını tahtanın
      alt üçte birindeki bir hücrede yap → harf KENDİLİĞİNDEN değişmemeli.
- [ ] **Gerçek seçim çalışıyor:** Açılan pencereden yeni bir harf seç →
      taş o harfe dönmeli, pencere kapanmalı (hayalet click yutulurken
      gerçek dokunuş yutulmamalı).
- [ ] **"Geri Al" çalışıyor:** Aynı pencereden "Geri Al" → taş rafa dönmeli.
- [ ] **Sıradan taş değişmedi:** Joker OLMAYAN, bu turda konmuş bir taşa
      dokun → doğrudan rafa geri alınmalı (pencere açılmamalı).
- [ ] **Sürükleyerek koyma:** Raftaki jokeri sürükleyip bir hücreye bırak →
      harf seçme penceresi açılmalı ve açık kalmalı.
- [ ] **Titreşimli dokunuş kaybolmuyor (22 Ağustos 2026):** Parmağını hafifçe
      kaydırarak (tam sabit tutmadan) raftaki bir taşa dokun → seçilmeli;
      tahtaya koyduğun bir taşa aynı şekilde dokun → rafa geri alınmalı.
      Eşik parmakta 10px (farede 6) — eskiden 6px'lik titreşim jesti sessizce
      yutuyordu.
- [ ] **Gerçek sürükleme bozulmadı:** Raftaki taşı tahtaya sürükleyip bırak,
      tahtadaki taşı başka bir hücreye taşı, tahtadaki taşı rafa sürükle.
- [ ] **k-lig balonu (OHP) kapanışı:** k-lig listesini aç, "OHP" başlığına
      dokunup balonu aç, sonra bir OYUNCU SATIRINA dokun → balon kapanmalı ve
      o oyuncunun kartı AÇILMAMALI. İkinci dokunuş kartı açmalı.
- [ ] **Hesap menüsü kapanışı (oyun ekranında):** Oyun sırasında sağ üstteki
      avatara dokunup menüyü aç, sonra TAHTAYA dokun → menü kapanmalı ve
      tahtaya taş KONMAMALI/hücre seçilmemeli. İkinci dokunuş normal çalışmalı.

## 17. Hukuki statik sayfalar — YALNIZCA CANLIDA ölçülebilir (23 Ağustos 2026)

`/gizlilik/`, `/kullanim-kosullari/` ve `/hesap-silme/` derleme zamanında
üretilen statik sayfalar (kök `CLAUDE.md` → "Hukuki Statik Sayfalar").
Otomatik duman testleri sayfaların doğru üretildiğini, SPA kabuğuna
düşmediğini ve metnin pencerelerle aynı kaynaktan geldiğini zaten kanıtlıyor
— **bu listedeki maddeler otomatikleştirilemeyenler:** ikisi de Vercel'in
kendi yönlendirme sırasına bağlı ve bu ortamdan test EDİLEMİYOR.

Deploy sonrası, Play formuna adres girmeden ÖNCE:

- [ ] `https://kelimeki.com/gizlilik/` → politika açılıyor (uygulama değil).
- [ ] `https://kelimeki.com/kullanim-kosullari/` ve `.../hesap-silme/` aynı.
- [ ] **Eğik çizgisiz** `https://kelimeki.com/gizlilik` → `/gizlilik/`'e
      yönleniyor (`vercel.json` `redirects`). Yönlenmiyor ve uygulama
      açılıyorsa **Play formuna eğik çizgili adresi yaz** — ölçülmüş ve
      çalıştığı bilinen hâl o; yönlendirme bir kolaylık, bağımlılık değil.
- [ ] **Kurulu PWA'da (ana ekrana eklenmiş) dene.** Service worker'ın
      `navigateFallback`i bu yolları uygulama kabuğuna çeviriyordu;
      `navigateFallbackDenylist` eklendi ama gerçek kurulu bir PWA'da teyit
      cihazda yapılmalı. Uygulamayı bir kez aç (yeni SW etkinleşsin), sonra
      tarayıcıdan adrese git.
- [ ] Sayfalar JS kapalıyken de okunabiliyor (tamamen statik olmalı).
- [ ] `/hesap-silme/` içindeki "Görüş Bildir formu" bağlantısı formu açıyor.

---

## 18. Onaylanmamış hesap süpürmesi — hatırlat, sonra sil (23 Ağustos 2026)

Saatlik cron (`sweep-unconfirmed-accounts`, `25 * * * *`) e-postasını hiç
doğrulamamış hesapları ~20. saatte TAZE bir onay linkiyle hatırlatıyor, 48.
saatte siliyor. **Otomatik silme geri alınamaz** — bu bölüm bu yüzden var;
maddeler otomatik testle kapatılamıyor, çünkü gerçek bir gelen kutusu ve
gerçek bir Supabase Auth hesabı gerekiyor.

**Test hesabı kullan, kendi hesabınla koşma.** Tek kullanımlık bir adres
(`…@sharedxpteam.testinator.email`) yeterli.

### 18.1 Hatırlatma maili — tek tık, direkt içeri

- [ ] Test adresiyle kayıt ol, gelen onay mailine **DOKUNMA**.
- [ ] Damgayı geriye çek (SQL): kaydı ~21 saatlik göster
      (`update auth.users set created_at = now() - interval '21 hours' where email = '…'`).
- [ ] Cron'u bekleme, fonksiyonu elle tetikle (Edge Function → Invoke, gövde `{}`).
- [ ] Gelen kutusunda **Kelimeki markalı** "Hesabını tamamla" maili var
      (Supabase'in stok İngilizce şablonu DEĞİL).
- [ ] Metin 24 saat içinde tamamlanmazsa hesabın silineceğini SÖYLÜYOR.
- [ ] **"Hesabımı Tamamla"ya tek dokunuş → doğrudan uygulamanın içindesin.**
      Ara bir sayfa, "linki yeniden gönder" adımı, ikinci bir mail YOK.
- [ ] SQL'de `email_confirmed_at` ile `last_sign_in_at` **aynı ana** yazılmış
      (tek tıkla hem onay hem oturum).

### 18.2 Mükerrer hatırlatma gitmiyor

- [ ] Fonksiyonu ikinci kez tetikle → aynı kişiye ikinci mail **GİTMEZ**
      (`confirm_reminder_sent_at` dolu, atomik iddia).

### 18.3 Silme — üç koşul birden

Bir hesap ancak şunların HEPSİ doğruyken siliniyor: onaysız · hatırlatma
gönderilmiş · hatırlatmadan bu yana 24 saat geçmiş. **Uyarılmadan kimse
silinmez.**

- [ ] Hatırlatma damgası taze bir hesapta prova (`{"dryRun":true}`) çıktısında
      `silinecek` listesi **BOŞ**.
- [ ] Damgayı 25 saat geriye çek → prova artık o hesabı `silinecek` diyor.
- [ ] Gerçek koşudan sonra `auth.users`ta satır yok, admin Üyeler sayısı 1 azaldı.
- [ ] **Takma ad serbest kaldı:** aynı takma adla yeniden kayıt olunabiliyor.
- [ ] **E-posta serbest kaldı:** aynı adresle yeniden kayıt olunabiliyor.

### 18.4 Verisi olan hesap SİLİNMEZ

- [ ] Prova çıktısındaki `verisiOlduguIcinAtlanan` listesini oku. Kendi
      oluşturduğu kaydı (oyun, bulut kaydı, gönderdiği arkadaşlık isteği) olan
      hesap silinmez, yalnızca raporlanır.
- [ ] **Bir hesabın GELEN referansı silmeyi engellemez** — biri ona arkadaşlık
      isteği göndermişse o satır cascade ile gider (`cascadeOlacakGelenKayit`
      alanında raporlanıyor). Bunu "veri var" sanıp korkma.

### 18.5 ⚠ OTP süresi — geri çekilirse özellik SESSİZCE ölür

- [ ] Supabase Dashboard → Authentication → Sign In / Providers → Email →
      **Email OTP expiration = 86400** (24 saat). 3600'e dönmüşse hatırlatma
      maili ölü link taşır ve kimse fark etmez.
- [ ] Güvenlik denetiminde (`get_advisors`) `auth_otp_long_expiry` **WARN**
      görünüyor — bu BİLİNÇLİ, temizlemek için ayarı düşürme.

### 18.6 Hukuki metin ile davranış uyuşuyor

- [ ] Gizlilik Politikası (web modal + `/gizlilik/` sayfası + mobil port) 5.
      bölümde ~20 saat hatırlatma / 48 saat silme cümlesini taşıyor ve üç
      yüzeyde de aynı.
- [ ] **6. bölüm anonim kodun DÖRT durumunu sayıyor** (31 Ağustos 2026'da
      dördüncüsü eklendi: YZ oyununu BİTİRME, yalnızca girişsizken). Üç
      yüzeyde de aynı ve "Son güncelleme" tarihi ÜÇÜNDE de **31 Ağustos
      2026** olmalı — portun tarihi web'inkinden geri kalırsa
      `legal_text_test.dart` zaten düşer, ama statik sayfa derlemeden
      geliyor: `/gizlilik/` sayfasını da elle aç ve tarihi gör.
- [ ] **Girişliyken bitirdiğin bir YZ oyununda anonim kod GİTMEMELİ.** Metin
      bunu açıkça söylüyor ("Girişliyken … anonim kod ORAYA HİÇ YAZILMAZ").
      Sunucu iki katmanda zorluyor (trigger + CHECK), yani bu kontrol
      metnin doğruluğunu değil, davranışın metinle uyuştuğunu sınıyor:
      girişli bir oyunu bitir → `game_finishes` satırında `user_id` dolu,
      `anon_id` NULL olmalı.

## 19. Alt şerit dokunma hedefleri (24 Ağustos 2026)

Bir kullanıcı cihazda bildirdi: *"board altındaki hamleler, mesajlar ve nasıl
oynanır linkleri tıklayınca hemen açılmıyorlar. Kaç defa basmam gerekti."*
Hedefler 18 → 32 px'e çıkarıldı (dolgu KAPTAN her ÖĞEYE taşındı; şeridin dış
ölçüsü değişmedi). Ayrıntı/ölçümler: `docs/decisions/touch-ux-bugs.md` →
"Alt şerit dokunma hedefleri". `layout_parity_test.dart` düzeni kilitliyor
ama **gerçek parmakla ıskalamayı hiçbir test ölçemez** — burası o teyit.

**GERÇEK dokunmatik cihazda**, hem yerel (YZ) hem Canlı oyun ekranında koş.

- [ ] **Hamleler:** Tahtanın altındaki "Hamleler"e BİR kez dokun → hamle
      penceresi ilk dokunuşta açılmalı.
- [ ] **Mesajlaşma (yalnızca Canlı):** "Mesajlaşma"ya bir kez dokun →
      sohbet ilk dokunuşta açılmalı.
- [ ] **Nasıl Oynanır?:** Şeridin sağındaki linke bir kez dokun → kurallar
      ilk dokunuşta açılmalı.
- [ ] **Etiketin ÜSTÜNE/ALTINA dokunma da çalışıyor:** Yazının tam üstüne
      değil, hemen üstündeki/altındaki birkaç piksele dokun → yine açılmalı
      (hedef artık yazının kendisinden yüksek).
- [ ] **Şerit büyümedi:** Tahta kartının alt kenarı ile raf arasındaki
      boşluk gözle ESKİSİYLE aynı görünmeli — bu düzeltme şeridi
      büyütmemeliydi.
- [ ] **Okunmamış mesaj rozeti yerinde:** Okunmamış mesajı olan bir Canlı
      oyunda kırmızı sayı rozeti "Mesajlaşma" etiketinin sağ ÜST köşesinde
      durmalı, aşağı kaymamalı.
- [ ] **Çevrimdışı göstergesi:** Uçak modunu aç → "Çevrimdışı" şeridin
      sağında görünmeli ve "Nasıl Oynanır?" ile ÇAKIŞMAMALI (dar telefonda
      alt satıra sarabilir, bu beklenen).
## 19b. Dokunma hedefleri 48 px — İKİNCİ tur (24 Ağustos 2026)

Bölüm 19'daki düzeltme yetmedi (ölçüm: 31 px, asgari 48). Web tarafında da
aynı kusur vardı; `Board.tsx`, `HelpModal.tsx`, `Setup.tsx` ve
`UserMenu.tsx` `min-h-[48px]` aldı. Avatarda negatif marj kullanıldığından
**webde düzen bir piksel bile oynamamalı** — bu bölümün asıl amacı onu
doğrulamak.

- [ ] **Header aynı yükseklikte:** Oyun ekranında logo, skor kutuları ve
      avatar eskisiyle AYNI hizada; header büyümemiş görünüyor.
- [ ] **Avatar** tıklanınca menü açılıyor; avatarın etrafındaki 8 px'lik
      görünmez alan da tıklanabiliyor (hemen kenarına tıkla).
- [ ] **Alt şerit** üç linki de tek tıkta açılıyor; şerit biraz daha uzun
      görünecek (beklenen).
- [ ] **"Nasıl Oynanır?" penceresi:** "Detaylı Kurallar →" linki tıkla
      geçiyor; link ile başlık arası makul, üst üste binmiyor.
- [ ] **Setup'ın alt linkleri** (Kullanım Koşulları · Gizlilik Politikası ·
      Paylaş) tıklanıyor ve aradaki `·` ayraçlar dikeyde ORTALI.
- [ ] **"Yükleniyor…" okunur:** k-lig ve Skor Kartı açılırken ortada
      belirgin mavi/kalın bir "Yükleniyor…" görünüyor (soluk gri değil).

## 19c. Modaller tek boyda açılıyor mu (24 Ağustos 2026)

Mobil portta bildirilen "önce küçük pencere, sonra büyük pencere"
davranışının webdeki eşi de düzeltildi: yükleme sırasında yer baştan
ayrılıyor.

- [ ] **k-lig** açılınca pencere tek boyda açılmalı; içerik alanının
      ortasında "Yükleniyor…" görünmeli ve veri gelince pencere BÜYÜMEMELİ.
- [ ] **Skor Kartı** açılınca istatistik kutuları `—` ile baştan çizili
      olmalı; sayılar yerinde dolmalı.
- [ ] Oyun geçmişi / arkadaşlar gibi öteki pencerelerde de "Yükleniyor…"
      belirgin (mavi/kalın) görünmeli.

## 19d. Taslak sürerken kelime anlamı açılmamalı (24 Ağustos 2026)

Mobil portta bildirilen davranışın webdeki eşi de değişti.

- [ ] Tahtaya bir taş koy (OYNA'ya BASMA) → oynanmış bir taşa tıkla →
      anlam penceresi AÇILMAMALI, imleç de "tıklanır" göstermemeli.
- [ ] Taslağı geri al → oynanmış taşa tıkla → anlam penceresi AÇILMALI.
- [ ] Aynı ikisini Canlı oyun ekranında da dene.

### Iskalama kurtarma (mobil tarayıcıda dene — asıl hedef orası)

- [ ] Taslak taşını geri almak için **kasten biraz aşağısına** (altındaki
      oynanmış taşa) dokun → taslak taşı GERİ ALINMALI.
- [ ] **Yan yana üç taslak harf**, ortadakine dokun → yalnızca ortadaki.
- [ ] **Mevcut bir taşın hem üstüne hem altına** harf koy, ortadaki
      oynanmış taşa tam ortasından dokun → hiçbir şey olmamalı; biraz
      yukarı/aşağı kayarsan yakın olan geri alınmalı.
- [ ] Boş hücrelere taş koymak eskisi gibi kolay olmalı.

## 20. Bölge kuralı — bloktaki desteksiz rakip taşı (24 Ağustos 2026)

Kural değişti: kendi 4×4 köşe bloğunun içindeki bir hücre, üzerinde rakip taşı
olsa bile, o taş **rakibin kendi zincirine bağlı değilse** senin zincirini
kesmez (iletken). Gerekçe ve ölçümler: `CLAUDE.md` → "İstisna — kendi 4×4 köşe
bloğu". `territory.json` golden vector'ı iki motoru da kilitliyor, ama **canlı
bir oyunda gözle teyit** ayrı bir şey — bölge dış hattı ve vergi onayı bu
hesaba bağlı.

- [ ] **İletken durum:** Rakip senin bloğunun içine, kendi bölgesine BAĞLI
      OLMAYAN bir taş koysun. O taşa asarak blok dışına bir kelime kur →
      bölgenin dış hattı yeni taşlarını içine alacak şekilde büyümeli.
- [ ] **Negatif dal:** Rakip kendi bölgesini kesintisiz kendi taşlarıyla senin
      bloğuna kadar getirmişse, onun taşına asarak kurduğun kelime bölgene
      dahil OLMAMALI (ve o hücreler onun bölgesinde görünmeli).
- [ ] **Vergi tutarlı:** Yukarıdaki iletken durumda büyüyen bölgenin sınırına
      rakip oynadığında "Sınır İhlali!" onayı çıkmalı ve vergi sana gelmeli.
- [ ] **Çakışma yok:** Hiçbir hücre aynı anda iki oyuncunun renkli dış hattı
      içinde görünmemeli.
- [ ] **Devam eden oyunlar:** Deploy sonrası açık bir oyunda bölge sınırları
      yeniden hesaplanır — tahtanın dış hattı bir anda değişebilir, bu
      beklenen.

## 21. Davet sayfası (`/davet/:token`) — zenginleştirilmiş ekran (25 Ağustos 2026)

Sayfa artık davet cümlesinin yanında oyunu da ANLATIYOR (davet edenin baş harf
avatarı, tek bir "Daveti Kabul Et" düğmesi, gerçek tanıtım tahtası + X2/X3
rozetleri, dört özellik kutusu, hukuki alt şerit). Gerekçe:
`docs/decisions/friends.md`. Duman testi yalnızca "bölüm render oluyor mu"yu
kilitliyor (`tests/smoke.spec.ts`); aşağıdakiler GERÇEK bir token + gerçek bir
kayıt gerektirdiğinden elle koşulur.

- [ ] **Girişsiz, geçerli link.** Arkadaşlar → "Arkadaşını Davet Et" ile link
      üret, **gizli sekmede** aç: davet edenin adı başlıkta görünmeli, avatar o
      adın baş harflerini taşımalı. Kartta düğmenin ALTINDA hiçbir açıklama
      metni OLMAMALI (25 Ağustos 2026'da bilerek kaldırıldı).
- [ ] **Kayıt akışı bozulmadı.** "Daveti Kabul Et" (üstteki VEYA sayfanın
      altındaki aynı etiketli düğme) → AuthModal **kayıt** modunda açılmalı;
      kayıt + e-posta onayı sonrası uygulamaya dönüldüğünde arkadaşlık KURULMUŞ
      olmalı (token kuyruğu, `App.tsx`).
- [ ] **Zaten üye olan da tek düğmeden geçebiliyor.** Aynı düğme →
      AuthModal'daki "Zaten hesabın var mı? Giriş yap" ile giriş → davet
      otomatik işlenmeli ("artık arkadaşsınız").
- [ ] **Girişli kullanıcı tanıtımı GÖRMEZ.** Aynı linki girişli bir hesapla aç:
      yalnızca davet kartı + "İşleniyor…" → "artık arkadaşsınız" görünmeli,
      "Kelimeki nedir?" bölümü HİÇ çıkmamalı.
- [ ] **Geçersiz/kullanılmış token çıkmaz değil.** Uydurma bir token ile aç:
      açıklama + "Kelimeki'ye Git" düğmesi ve altında tanıtım bölümü olmalı.
- [ ] **KENDİ davet linkine tıkla** (25 Ağustos 2026'da kullanıcı bunu bildirdi;
      o gün arayüz *"bir hata oluştu, lütfen tekrar dene"* + **Tekrar Dene**
      gösteriyordu — tekrar denemek hiçbir zaman çalışmayacaktı). Girişliyken
      kendi linkini aç: sunucunun kendi cümlesi görünmeli — **"Kendi linkinle
      arkadaş olamazsın."** — ve düğme **"Kelimeki'ye Git"** olmalı,
      "Tekrar Dene" ÇIKMAMALI. Kural: sunucu `raise exception` ile reddettiyse
      (SQLSTATE `P0001`) mesajı OLDUĞU GİBİ göster, tekrar denemeyi önerme;
      "Tekrar Dene" yalnızca kodsuz (ağ/beklenmeyen) hatalarda çıkar.
- [ ] **Tahta gerçek tahtaymış gibi görünüyor.** Bölge dış hatları, ev
      işaretleri, sarı X2 alanı ve turuncu X3 hücresi seçilebilmeli; altındaki
      iki rozetin rengi tahtadaki karelerle AYNI olmalı (zeminler
      `Board.tsx`'ten geliyor — ayrışmışsa biri elle yazılmış demektir).
- [ ] **Dar ekran.** 320 px genişlikte yatay kaydırma OLMAMALI, düğmeler tek
      satırda kalmalı.
- [ ] **Hukuki şerit.** "Kullanım Koşulları" / "Gizlilik Politikası" pencereleri
      açılıp Esc ile kapanmalı (sayfa uygulama paketinde, statik `/gizlilik/`
      sayfasına GİTMEZ).

## 22. Uygulama içinden hesap silme (25 Ağustos 2026, ROADMAP madde 2)

**GERİ DÖNÜŞSÜZ.** Bu bölümü YALNIZCA feda edilebilir bir test hesabıyla
koş — `Ironman` ve App access formunda incelemeciye verilen `T2` HARİÇ
(ROADMAP #4). Karar/kaskad: `docs/decisions/account-deletion.md`.

Duman testi yalnızca `/hesap-silme/` sayfasının metnini kilitliyor; aşağısı
gerçek bir oturum ve gerçek veri gerektirdiğinden elle koşulur.

- [ ] **Giriş görünür.** Hesap menüsü → Hesap Ayarları → en altta, KAYDET'in
      altındaki ayracın arkasında kırmızı **"Hesabımı Sil"** ve altında
      "Kalıcıdır, geri alınamaz." olmalı.
- [ ] **Kuru çalıştırma GERÇEK sayı gösteriyor.** Pencere açılınca
      "Silinecekler" listesi belirmeli ve sayılar hesabın gerçek verisiyle
      uyuşmalı (ör. oyun geçmişindeki kayıt sayısı ile "Bitmiş oyun kaydın").
      Sıfır olan satırlar HİÇ görünmemeli.
- [ ] **"Kalacaklar" bölümü.** Birlikte oynadığın biri varsa, o kişinin
      kaç bitmiş oyun kaydının KORUNACAĞI ve adının "Silinmiş oyuncu"
      olacağı yazmalı. Hiç ortak oyunu olmayan bir hesapta bu bölüm
      çıkmamalı.
- [ ] **Onay olmadan silinmiyor.** `SİL` yazmadan buton devre dışı olmalı;
      `sil` (küçük harf) de kabul edilmeli (`trUpper`), `SIL` (noktasız I)
      de — ama `SL`/boş kabul EDİLMEMELİ.
- [ ] **Silme sonrası.** Onaydan sonra sayfa `/`'e dönmeli, oturum kapanmış
      olmalı ve aynı e-posta/takma adla **yeniden kayıt** olunabilmeli
      (takma ad serbest kalmış olmalı).
- [ ] **Rakibin kaydı KORUNDU ve ANONİMLEŞTİ.** Silinen kişiyle oynamış
      BAŞKA bir hesapla gir: Oyun Geçmişi'ndeki o oyun hâlâ listede olmalı,
      puanlar DEĞİŞMEMELİ, ama oyuncu adı **"Silinmiş oyuncu"** olmalı.
      Sohbet arşivi (balon ikonu) açıldığında o kişinin mesajları da aynı
      adla görünmeli.
- [ ] **k-lig bozulmadı.** Aynı hesabın Skor Kartı'ndaki toplam puanı silme
      ÖNCESİYLE aynı olmalı (`games` oyuncu başına satır tutuyor; kimsenin
      puanı silinen kişiden gelmiyor).
- [ ] **Devam eden Canlı oyun.** Silinen kişiyle YARIM kalmış bir oyun varsa
      rakibin "Canlı" listesinden düşmüş olmalı (oynanamaz bir oyun ortada
      asılı kalmamalı).
- [ ] **Yönetici silinemiyor.** Admin bir hesapla pencereyi aç: kuru
      çalıştırma **"Yönetici hesabı uygulama içinden silinemez."** demeli ve
      silme butonu HİÇ etkinleşmemeli.
- [ ] **`/hesap-silme/` sayfası tutarlı.** Sayfanın 1. bölümü uygulama içi
      yolu anlatmalı (eski "kendi kendine hesap silme özelliği şu anda
      bulunmuyor" cümlesi KALMAMALI) ve 2. bölümdeki "Görüş Bildir"
      bağlantısı hâlâ çalışmalı — Play bu URL'i Data safety formundan
      açıyor.

---

## 23. `destek@` gönderen ayrımı + "Zoho" rozeti (25 Ağustos 2026)

Kod canlıda ama zincirin yarısı Brevo/Zoho/GoDaddy panellerinde. Kurulum
adımları ve sırası: `docs/decisions/support-email.md` → "Kurulum". Bu liste
o adımlar bittikten SONRA koşulur.

**Otomatik test YOK ve olamaz:** gerçek bir Brevo hesabı, gerçek bir MX
kaydı ve gerçek bir gelen kutusu gerekiyor.

### 23.1 Transactional mail gerçekten cevaplanamıyor mu

1. Kendine bir bildirim mailini tetikle (en kolayı: yeni bir hesap açıp
   doğrula → "Hoş Geldiniz" maili).
2. Gelen mailin **altında** şu not olmalı: *"Bu otomatik bir bildirimdir; bu
   adrese gönderilen yanıtlar okunmaz. Bize ulaşmak için destek@kelimeki.com"*
   — `destek@` tıklanabilir bir `mailto:` linki olmalı.
3. Gönderen `Kelimeki <noreply@kelimeki.com>` olmalı (ham başlıktan oku —
   Gmail → "Orijinali göster"; Apple Mail kişi kartındaki adı gösterip
   yanıltır, bkz. `console-formlari.md`'deki ölçüm tuzağı).
4. **Bu maile "Yanıtla" de ve gönder.** Beklenen: mail GERİ DÖNER (bounce).
   ⚠ Geri dönmüyor ve `destek@` kutusuna düşüyorsa, Zoho'daki `noreply@`
   GRUBU hâlâ silinmemiş demektir (kurulum adım 2).

### 23.2 Görüş bildirim yanıtı destek@'ten gidiyor mu

1. Uygulamadan (misafir ya da üye) bir görüş bildir, e-posta alanını doldur.
2. Admin panel → Geri Bildirim → Gelen Kutusu → mesajı aç → **Yanıtla** → gönder.
3. ⚠ **502 + "destek@kelimeki.com Brevo'da doğrulanmış gönderen değil"**
   hatası alırsan bu bir kod hatası DEĞİL: kurulum adım 1 yapılmamış.
   Brevo → Settings → Senders'a adresi ekle, doğrula, tekrar dene.
4. Gelen mailde gönderen `Kelimeki Destek <destek@kelimeki.com>` olmalı ve
   notta *"Bu e-postayı doğrudan yanıtlayabilirsin"* yazmalı.
5. **Maile doğrudan "Yanıtla" de.** Cevap `destek@` Zoho kutusuna düşmeli.

### 23.3 Rozet — cevap gelince admin haber alıyor mu

⛔ **BU BÖLÜM ŞU AN KOŞULAMAZ (26 Ağustos 2026).** Rozeti besleyen gelen
zinciri kurulmadı: Brevo'nun **Inbound webhook**'u ücretli plana bağlı ve
plan yükseltilmedi (gerekçe: `docs/decisions/support-email.md` → "GELEN
ZİNCİRİ DURDURULDU"). `support_inbox` boş kalır, rozet hiç belirmez —
**bu bir hata değil, beklenen hâl.** Panel içindeki "Zoho" düğmesi yine de
çalışır (kutuyu açan kısayol). Zincir bir gün kurulursa aşağıdaki adımlar
olduğu gibi geçerli.



1. 23.2'nin 5. adımından sonra Zoho kutusunu kontrol et: mail **kutuda
   kalmalı** (yönlendirme bir KOPYA olmalı, taşıma değil).
2. Admin paneli → Geri Bildirim sekmesi. Alt sekme satırında **Zoho** düğmesi
   ve üstünde kırmızı **1** rozeti görünmeli.
   ⚠ Rozet gelmiyorsa sırayla bak: Zoho filtresi çalıştı mı → Brevo Inbound
   "logs" ekranı maili gördü mü → Supabase Edge Function logları
   (`inbound-email`) ne diyor. 401 = webhook URL'indeki `?key=` yanlış,
   503 = `INBOUND_EMAIL_SECRET` secret'ı eklenmemiş.
3. **Zoho düğmesine tıkla.** Beklenen: yeni sekmede Zoho gelen kutusu açılır
   (`mail.zoho.eu`) VE rozet anında kaybolur.
4. Paneli yenile — rozet geri gelmemeli (`seen_at` damgalandı).
5. İkinci bir cevap gönder → rozet tekrar **1** olmalı.

- [ ] **Dıştaki "Admin Paneli" rozeti de arttı mı.** Paneli AÇMADAN, hesap
      menüsünü aç: "Admin Paneli" satırının yanındaki kırmızı sayı bu cevabı
      da içermeli (`fetchAdminPendingCount` üç kaynağı toplar). İlk sürümde
      yalnızca panelin İÇİNDEKİ rozet sayıyordu — dışarıdaki saymayınca
      bildirim işe yaramıyor.

### 23.4 Admin'in üyeye yazdığı mesaj

1. Admin panel → Üyeler → bir üyenin satırında **Mesaj Gönder** → konu+mesaj.
2. Mail `destek@`'ten gitmeli; Geri Bildirim sekmesinde "Gönderilen" rozetiyle
   görünmeli.
3. Üye "Yanıtla" derse: cevap Zoho'ya + rozet artmalı (23.3 ile aynı).
4. Üye maildeki **"siteden de yazabilirsin"** linkine tıklayıp formu
   doldurursa: cevap ZOHO'ya DEĞİL, doğrudan admin paneline düşmeli ve
   "↳ Cevaben" rozetiyle orijinal mesaja bağlanmalı. (İki yolun farklı yere
   gitmesi bilinçli — bkz. karar kaydı.)

### 23.5 Gürültü elenmesi

- `destek@`'e bir "tatil/otomatik yanıt" maili düşerse rozet ARTMAMALI
  (`Auto-Submitted`/`X-Autoreply`/`Precedence: bulk` eleniyor).
- `destek@` ya da `noreply@` adresinden gelen kopyalar da elenmelidir
  (döngü koruması).


## 24. Tarayıcı yazı boyutu ayarı — hiçbir sütun bölünmüyor (2 Eylül 2026)

Mobil portta 1 Eylül 2026'da bulunan hata sınıfının web eşleniği (kullanıcı:
*"fontlarını büyüten kişilerde bitirme modalı puanları bölüyor… Her koşulda
modallar, butonlar, vb genel olarak hiç bir şey patlamamalı"*).

⚠ **Tarayıcı ZOOM'u bu hatayı ÜRETMEZ** — zoom kutuları da büyütür. Doğru
ayar **asgari yazı boyutu**: Chrome → Ayarlar → Görünüm → *Yazı tipi boyutunu
özelleştir* → **Minimum yazı tipi boyutu = 16** (Safari: Tercihler →
Gelişmiş → "Yazı tipi boyutu asla şundan küçük olmasın"). Yalnızca eşiğin
altındaki puntoları yukarı çeker, px genişlikli kutular yerinde kalır.

Bitirme modalı **otomatik ölçülüyor** (`npm run test` →
`tests/text-scale.spec.ts`, `--blink-settings=minimumFontSize=16`); aşağıdaki
üçü ise gerçek bir Supabase oturumu gerektirdiğinden ELLE:

- [ ] **Skor Kartı → k-lig lider tablosu** → `Sıra`/`OHP`/`Puan` sütunları
      tek satır; sayılar rakam rakam bölünmemeli, komşusunun üstüne
      binmemeli.
- [ ] **Tüm Oyunlarım → bir oyun kartı** → `Puan` ve `k-lig` başlıkları ve
      altlarındaki sayılar tek satır.
- [ ] **Nasıl Oynanır → Rütbeler ve Ödüller** → rütbe harfi tek satır.
- [ ] Ayarı normale al → üç yüzeyde de görünüm ESKİSİYLE AYNI olmalı
      (sütun genişlikleri ve aralıklar değişmemeli).
- [ ] **LİSTE SIRALAMASI** (3 Eylül 2026): (a) Yapay Zeka "DEVAM EDEN
      OYUNLAR" → silinmeye en yakın kayıt EN ÜSTTE; (b) Canlı "Devam
      Edenler" → sırası SENDE olanlar üstte ve KENDİ İÇİNDE en yakın teslim
      en üstte; (c) "Oyun Davetleri" → süresi bitmeye en yakın davet en
      üstte. ⚠ Sırası RAKİPTE olan oyunlarda yön TERSİ ve bu bilinçli:
      orada "son oynanan üstte" (31 Ağustos kararı) — o grubu en-yakın-bitiş
      sanıp hata bildirme.
- [ ] **Son Oynananlar / Son Oynadıklarım → AVATARLAR** (2 Eylül 2026'da
      eklendi; öncesinde bu listede hiç fotoğraf çıkmıyordu): bitmiş bir
      Canlı oyunda rakiplerin fotoğrafı görünmeli; Yapay Zeka sekmesinde
      kendi fotoğrafın görünmeli. ⚠ Fotoğrafı olmayan üye ve YZ/misafir
      koltukları baş harf/robot/"?" olarak KALIR — eksik değil, kural.
      ⚠ Oyundan SONRA takma adını değiştiren biri baş harfe düşer (bilinçli:
      yanlış yüz göstermektense baş harf).
- [ ] **Setup → devam eden oyun kartı** → `SIRA SENDE` oyuncu satırının
      sağında, kalan süre altta tam genişlik satırda (2 Eylül 2026'da
      portla birlikte değişti). Avatarların altında `Sıra: X` YAZMAMALI.
- [ ] **İki sekmeyi yan yana karşılaştır** ("Yapay Zeka" ↔ "Arkadaşınla"):
      Canlı oyun kartında da kalan süre **puan satırının ALTINDAKİ**
      kendi satırında olmalı, o satıra binmemeli (2 Eylül 2026'da bu iki
      kart AYRIŞMIŞTI). `SIRA SENDE`/`SIRA RAKİPTE` puntosu 15 px — iki
      kartta da aynı.
- [ ] **Kart altı PUAN SATIRI — HİZA** (6 Eylül 2026, kullanıcı isteği; ilk
      tur tek dizeydi (`45 - 38`) ve kullanıcı 4 kişilikte kaydığını
      bildirdi): iki sekmedeki devam eden oyun kartlarında avatarların
      hemen altında koltuk sırasıyla anlık puanlar, **her sayı KENDİ
      AVATARININ TAM ALTINDA** (ayırıcı tire YOK — ayrımı hiza yapıyor).
      ⚠ **Asıl kontrol 4 KİŞİLİK + üç haneli puanlar** (238 179 103 87):
      dört sayı da kendi yüzünün altında ve birbirine değmiyor olmalı.
      ⚠ Canlı kartında **"X açtı" satırı ARTIK YOK** (kurucu zaten ilk
      avatar). Rakip hamle yapınca puanlar oyuna girmeden tazelenmeli
      (Realtime → liste yeniden çekilir). "Son Oynananlar"da (iki sekme):
      **tarih (+ zorluk rozeti) avatarların ÜSTÜNDE**, bitiş puanları
      altında ve aynı hizada; sağdaki kendi puanın/k-lig sütunları yerinde.
      Port ile birebir.
- [ ] **Board altındaki şerit** (Hamleler · Mesajlaşma · **Yardım**) →
      punto 11 ve TEK SATIR; portla AYNI olmak zorunda. Etiket 2 Eylül
      2026'da `Nasıl Oynanır?`dan kısaltıldı (şerit tavanda iki satıra
      düşüyordu).

**Neden ikisi farklı düzeltildi:** bitirme modalı ızgaraya çevrildi (sütunlar
`auto`, yani genişliğini içeriğinden alıyor — elle yazılmış 29/37/20 px'in
türetildiği kuralın kendisi; normal ölçekte AYNI sayıları verdiği ölçüldü).
Ötekilerde `w-*` → `min-w-* whitespace-nowrap` yapıldı: normal ölçekte
kanıtlanabilir biçimde etkisiz (kutular zaten içerikten geniş), büyüyünce
kutu içeriğe göre açılıyor. Izgaraya çevirmek oralarda görünümü kaydırırdı,
çünkü o genişlikler içeriğe tıpatıp oturmuyor (ör. `k-lig` için `w-8`).

## 25. Sunucu-otoriter hamle — gölge fazı (5 Eylül 2026, ROADMAP #18)

**Neden elle:** `submit_move` artık her hamleyi kendi motoruyla da hesaplayıp
istemcinin gönderdiğiyle karşılaştırıyor. Bu fazda karar DEĞİŞMİYOR (hâlâ
istemcinin değeri kullanılıyor), yalnızca sapma `move_shadow_diffs` tablosuna
yazılıyor. Amaç: zorlama fazına geçmeden önce aynanın sahada gerçekten
istemciyle aynı sonucu verdiğini ölçmek. **Tablo boş kalmazsa zorlamaya
GEÇİLMEZ.**

Otomatik kanıt zaten var (2.641 gerçek hamle yeniden oynatıldı, 0
açıklanamayan sapma) ama o kanıt yalnızca GERÇEKLEŞMİŞ yolları kapsıyor.
Aşağıdaki dördü mevcut veride az geçtiği için elle koşulmalı.

Her turdan sonra kontrol (Supabase → SQL Editor):
```sql
select alan, count(*), max(created_at)
from public.move_shadow_diffs group by alan order by 2 desc;
```
Beklenen: **sıfır satır.** Satır varsa `girdi` sütununda board + placed +
players duruyor, vaka birebir tekrar üretilebilir.

- [ ] **25.1 — Normal Canlı oyun (2 kişilik).** Birkaç hamle oyna: kelime
      kur, çapraz kelime oluştur, pas geç, taş değiştir. Sorgu boş kalmalı.
- [ ] **25.2 — 4 kişilik oyunda bölge etkileşimi.** Rakibin bölgesine gir
      ve/veya sınırına değ; vergi onay modalı çıksın, hamleyi onayla.
      Ekranda görünen vergi ile skorlara yansıyan pay tutmalı; sorgu boş
      kalmalı. **En riskli yol burası** — bölge hesabı maliyetin %56'sı ve
      SQL aynasının en karmaşık parçası.
- [ ] **25.3 — İletken hücre kuralı (24 Ağustos 2026).** Rakip senin 4×4
      köşe bloğuna kendi zincirine BAĞLI OLMAYAN bir taş koysun; sen o taşın
      ötesine oynayıp bölgeni büyüt. Bölge dış hattı büyümeli ve sorgu boş
      kalmalı. (Bu dal golden vector'lara ilk girdiğinde SIFIR kapsama
      vermişti — otomatik kanıtın en zayıf olduğu yer.)
- [ ] **25.4 — Joker bitiş bonusu.** Torba boşken rafını YALNIZCA jokerle
      bitir (1 joker +25, 2 joker +50). Bonus skora yansımalı, sorgu boş
      kalmalı.
- [ ] **25.5 — Oyun ortasında teslim (48 saat zaman aşımı).** Teslim olan
      oyuncunun bölgesi doğal alana dönmeli; sonraki hamlelerde ona vergi
      ödenmemeli. Sorgu boş kalmalı.
- [ ] **25.6 — Eski istemci.** Mağazadan/Appetize'dan ESKİ bir sürümle bir
      hamle oyna. RPC imzası değişmediği için çalışmalı ve sapma yazmamalı —
      bu, "kurulu sürümler kırılmıyor" iddiasının sahadaki kanıtı.

⚠ **Hız kontrolü:** hamle gönderimi gözle fark edilir şekilde yavaşlamamalı.
Ölçülen ek maliyet +7,5-8,6 ms (ağ gidiş-dönüşünün %5'inden az); hissedilir
bir yavaşlama varsa sebep başka yerdedir, önce `move_shadow_diffs`in
'hata' satırlarına bak.
