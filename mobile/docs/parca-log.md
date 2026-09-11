# Parça Günlüğü — AKTİF

> **Yeni girişler BURAYA**, en yeni en başta. Bu cilt **Parça 175'ten itibaren**.
>
> **Hangi cilt?** Parça 1-48 → `parca-log-1-48.md` · 49-109 →
> `parca-log-49-109.md` · 110-138 → `parca-log-110-138.md` · 139-174 →
> `parca-log-139-174.md` · **175+ → `parca-log.md` (aktif, bu dosya)**.
> Kod yorumlarındaki "bkz. mobile/CLAUDE.md, Parça N" atıfları bu BEŞ
> dosyadan birine düşer.
>
> **26 Ağustos 2026:** aktif cilt 151 KB'a çıkıp uyarı bandına girdiği için
> 110-138 donduruldu; bu dosya 12 KB'a indi.
>
> **7 Eylül 2026:** aynı şey tekrarlandı (200 KB → `reference` uyarı bandı),
> **139-174 donduruldu**. `reference` sınıfının kuralı bölmek DEĞİL cilt
> dondurmaktır — dosya grep'leniyor, bölmek çoğu zaman baytı yer değiştirir.
>
> ⚠ **Bir cildi BAŞTAN SONA OKUMA — `grep` ile ara.** Ciltler tam da bu
> yüzden var: tek bir atıf için yüz binlerce bayt okumak bağlamı yakar.
>
> **Neden ciltlere ayrıldı (24 Ağustos 2026):** tek dosya 714 KB'a (9.800
> satır) çıkmıştı — 24 Ağustos'taki context split'in ÇÖZDÜĞÜ sorun yer
> değiştirip burada birikmişti. Kesimler bölüm/parça sınırlarından yapıldı,
> hiçbir satır değişmedi. Tekrarını önleyen kontrol:
> `npm run check-doc-size` (bkz. kök `CLAUDE.md` → "Doküman Boyutu
> Bütçesi") — bu cilt de sınıra gelince yenisi açılır.

   - ✅ **Parça 202 — Sonsuz "Yükleniyor…": `catch` yetmez, TAVAN gerekiyor
     (11 Eylül 2026):** Kullanıcı iPhone'da bildirdi — *"bekleyen oyuna
     tıklayınca bu ekran uzun süre asılı kalıyor. Sanıyorum internet yavaş
     veya çekmiyor."* Teşhis tarifini doğruladı ama sebebi tamamlıyor.
     **Bu semptom 14 Ağustos 2026'da bir kez düzeltilmişti** — o tur sorun
     "hata YAKALANMIYORDU" idi (rack çağrısı fırlıyor, `Promise.all`
     reddediyor, `setLoadFailed` satırına ulaşılmıyordu). Bu turun sebebi
     FARKLI: **hata hiç DOĞMUYOR.** Yavaş/asılı bağlantıda istek ne
     çözülür ne reddedilir; `try/catch` yalnızca REDDEDİLEN isteği yakalar,
     hiç bitmeyeni yakalayacak tek şey bir zaman aşımıdır.
     ⚠ **En can sıkıcı yanı: tavan İKİ TARAFTA DA ZATEN VARDI** — portta
     `_callTimeout` (20 sn), web'de `withTimeout` (20 sn). Ama yalnızca
     ARKA PLAN çağrılarına uygulanmıştı (`triggerAiTurn`,
     `checkTurnTimeout`, `setPlatform`); kullanıcının arkasında BEKLEDİĞİ
     ilk yüklemeye uygulanmamıştı. Port bu boşluğu web'den sadakatle
     kopyalamış.
     **Düzeltme:** ilk yükleme iki tarafta da tavanın altına alındı
     (`loadGame`in `Future.wait`i `.timeout(_callTimeout)`, web'in
     `Promise.all`i `withTimeout(..., 20000)`). Zaman aşımı MEVCUT catch'e
     düşüyor → `null` → "Tekrar Dene" paneli + zaten kurulu otomatik
     yeniden deneme; yani yeni bir hata yolu açılmadı, var olana kapı
     eklendi.
     **Kapı:** `live_games_test.dart` → *"20 sn sonra null döner"*.
     ⚠ `fakeAsync` ŞART — gerçek zamanla test 20 saniye sürerdi ve kimse
     20 saniyelik bir testi takıma koymaz, yani kapı ya yavaş ya hiç
     olmazdı. Test İKİ yönü de ölçüyor: 19. sn'de HENÜZ dönmemeli (erken
     dönmek yavaş ama çalışan bir bağlantıyı boşuna kesmek olurdu), 21.
     sn'de `null`. Duyarlılık kanıtlandı: `.timeout` kaldırılınca DÜŞTÜ.
     ⚠ **Kalan denetim kapatılmadı, ÖLÇÜLDÜ:** `OnlineGamesRepo`'nun 16
     gateway çağrısından yalnızca 3'ünde tavan vardı. Bu tur yalnızca ilk
     yükleme kapatıldı (bildirilen yüzey oydu ve web ikizi de aynı yerde
     değişti, parite korundu); tavansız kalanların listesi
     `docs/decisions/live-game.md` → "Sonsuz 'Yükleniyor…'".
     **Doğrulama:** `dart analyze` temiz · **844 test yeşil** ·
     `npm run lint` temiz. **Doğrulama sınırı:** gerçek yavaş ağ cihazda
     denenmedi — `TESTING.md`'ye elle madde eklendi.

   - ✅ **Parça 201 — Sahte "Sıra sende değil.": hamle işlenmişti, ekranda
     hata vardı (11 Eylül 2026):** Kullanıcı iPhone'da bildirdi — taşları
     koydu, OYNA'ya bastı, ekranda ham
     `PostgrestException(message: Sıra sende değil., code: P0001, details:
     Bad Request…)` gördü; geri dönünce **hamlenin oynanmış olduğunu**
     gördü.
     **İlk adım kural gereği CANLIYDI, kod değil.** `online_game_moves`
     sorgulandı: hamlenin **TEK** satırı vardı (oyun `5ad3bc04…`, tur 28,
     +12 puan, 14:20:48Z) — yani ilk gönderim ulaşmıştı, çifte hamle yoktu.
     Semptom "sunucu reddetti" değil, "istemci başarıyı hata sandı".
     Sonra `submit_move`'un CANLI tanımı (`pg_proc.prosrc`) okundu:
     idempotency kontrolü `p_move_id` ile ve *"Sıra sende değil."*'den ÖNCE
     duruyor (satır 80 ↔ 107). **Sunucu suçsuz** — demek ki ikinci çağrı
     FARKLI bir id taşımış.
     **İki kusur.** (1) *Anahtar çağırana açık değildi:*
     `OnlineApi.submitMove` id'yi kendi içinde üretiyordu ve `moveId`
     zincirin üst halkalarında (`OnlineGamesGateway` · impl ·
     `OnlineGamesRepo`) HİÇ yoktu. Sarmalayıcının kendi taşıma-hatası
     tekrarları id'yi koruyordu; **kullanıcının elle tekrar denemesi**
     korumuyordu — yani koruma tam da gereken anda devre dışıydı.
     (2) *Ham exception dökümü ekrandaydı:* `_errorText` → `e.toString()`.
     Web ikizi bunu ZATEN soyuyordu (`api.ts` → `new Error(error.message)`),
     yani sessiz bir parite ayrışmasıydı; karar kaydı "sunucunun MESAJI
     olduğu gibi kalsın" diyor, "exception dökümü basılsın" demiyor.
     **Düzeltme.** `moveId` zincirin üç halkasına eklendi; ekran onu
     **hamleye bağlı** tutuyor (`_moveIdFor('play|<turnCount>|<placements>')`)
     ve **başarıda temizliyor** — `pass`/`exchange` de aynı kusuru
     taşıyordu, üçü birden düzeltildi. `PostgrestException` →
     `ServerRejection(message, code)` dönüşümü **veri katmanında**, UI'da
     DEĞİL: `PostgrestException` bir Supabase tipi ve bu depoda Supabase
     veri katmanında kalıyor.
     ⚠ **Temizleme kuralın İKİNCİ yarısı:** anahtar başarıdan sonra
     sıfırlanmazsa bir sonraki tur aynı id'yi taşır ve sunucu hamleyi
     "zaten işledim" deyip SESSİZCE yutar. Düzeltmenin ters yöndeki hatası
     bu olurdu; ikinci test tam bunu ölçüyor.
     **Üç kapı, üçü de duyarlılığı KANITLANARAK:** tekrar aynı id ile gider
     (`_moveIdFor` → `uuidV4()` yapıldı, test DÜŞTÜ, geri alındı) ·
     başarıdan sonra id yenilenir (ters yön) · `ServerRejection.toString()`
     yalnız mesaj (`contains('P0001')` negatif iddiası).
     ⚠ **Sahte gateway BAŞARISIZ denemeyi de kaydetmek zorunda kaldı**
     (`submitAttempts`): yalnızca başarılı çağrıları kaydeden bir sahte, iki
     denemenin id'sinin aynı olduğunu yapısal olarak gösteremez — Parça
     86'nın dersinin tekrarı.
     **Web AYNI PR'da:** `p_move_id`'yi hiç göndermiyordu (ROADMAP'te açık
     borç); artık gönderiyor ve anahtarı port ile AYNI kuralla tutuyor
     (`moveIdRef` + `moveIdFor`; `useState` DEĞİL `useRef` — değer hiçbir
     şey çizmiyor).
     **Doğrulama:** `dart analyze` temiz · **843 test yeşil** ·
     `npm run lint` temiz. **Doğrulama sınırı:** gerçek ağ koşullarında
     (yanıtı kaybolan istek) uçtan uca denenmedi; cihaz maddesi
     `mobile/docs/testing-arkadaslar-canli.md`'de hâlâ işaretsiz.
     Kayıt: `docs/decisions/live-game.md` → "Sahte 'Sıra sende değil.'".

   - ✅ **Parça 200 — Mağaza kareleri: pencereler artık OYUN EKRANININ
     ÜSTÜNDE + kareler CI'dan ÖNCE yerelde görülebiliyor (11 Eylül 2026,
     App Store FAZ C 24.5):** Kullanıcı Parça 199'un taze setine gözle
     baktı ve reddetti: *"Tüm modal ekranları (skor kart, k-lig tablosu,
     vb) normal ekran görüntüsünde olmalı. Yani arka planda oyun açıkken
     mesela."* 04 (skor kartı), 06 (nasıl oynanır) ve 07 (k-lig) pencereyi
     **boş bir `Scaffold` üstünde** çiziyordu — mağaza karesi bağlamsız bir
     pencere gösteriyordu. Üçü de artık oyun ekranını kurup pencereyi
     ÜRETİMİN kendi yardımcısıyla (`showScoreCard` · `showHelpModal` ·
     `showLeaderboard`) onun üstünde açıyor; 05 baştan beri böyleydi.
     ⚠ Yan kazanç ölçüldü: karartma tüm ekranı kapladığından bu üç karede
     Parça 199'un *"%9,6 beyaz kalıyor"* ölçümü konu dışı kaldı — ölü alan
     yalnızca pencere açılmayan karelerde (01 · 02 · 03) duruyor ve orada
     uygulamanın gerçek hâli.
     **İkinci ve asıl iş — geri besleme turu kısaldı.** Kullanıcı isteği
     birebir: *"Bu görselleri önce resim olarak yap bana göster ondan sonra
     ok ise üretime gönderelim. Böyle kaç defa git gel oldu. Canım sıkıldı
     artık."* Gerekçe ölçülü: DEBUG bandı, alfa kanalı ve "pencere boşlukta"
     arızalarının ÜÇÜ de ancak bir macOS koşusu (~14 dk) + artefakt indirme
     + insan gözü turuyla bulunmuştu, üstelik ajan artefaktı indiremiyor.
     Ortak sahne kurulumu `integration_test/store_frames.dart`'a çıkarıldı
     (⚠ `_test.dart` DEĞİL — koşucu toplamasın diye) ve
     `test/store_frames_preview_test.dart` onu import ederek AYNI yedi
     kareyi **Linux'ta `flutter test` içinde ~7 saniyede** çiziyor
     (`npm run preview-store-frames` → `build/frame-preview/*.png`, repoya
     girmez). İki dosya aynı kurulumu paylaştığı için ayrışamazlar.
     ⚠ **Önizleme mağaza karesi DEĞİL, iki bilinen fark var:** Material
     Icons yüklenmiyor (✕ ve madde imleri boş kutu □ çıkar) ve `sqflite`
     yok (05'in anlam metni elle verilmiş bir `MeaningEntry`'den gelir).
     Bu yüzden kapı DEĞİŞMEDİ — mağazaya giden set hâlâ CI'ınki ve hâlâ bir
     insan gözüyle açılmak zorunda (Parça 199'un DEBUG bandı dersi).
     Önizlemenin işi yalnızca **kompozisyonu** CI'dan önce karara bağlamak.
     Kapı: `KARE_ONIZLEME=1` ortam değişkeni — normal `flutter test`
     koşusunda test atlanıyor (CI'da PNG üretmenin anlamı yok, ölçüldü).
     Kayıt: `marketing/app-store/console-formlari.md` §13.

   - ✅ **Parça 199 — Mağaza kareleri: başlık şeridi, 7. kare ve ALFA
     ARIZASI (11 Eylül 2026, App Store FAZ C 24.5):** Kompozisyon kararı
     verildi (kullanıcı): kareler **başlıklı** çıkıyor ve **7. kare**
     (k-lig sıralaması) eklendi. Şerit `MaterialApp.builder` ile Flutter
     ağacının İÇİNDE çiziliyor — uygulama `Expanded` altında biraz daha
     kısa bir görünüm alanında gerçekten render ediliyor, hiçbir içerik
     örtülmüyor ve hiçbir arayüz öğesi taklit edilmiyor. Böylece son işlem
     (ImageMagick/`sharp`) gerekmiyor, kare yine cihazın fiziksel
     pikselinde çıkıyor ve iş akışının ölçüm adımı değişmeden geçiyor.
     `builder` Navigator'ın üstünü sardığı için dialog kareleri (05'in
     anlam penceresi) da kendiliğinden şeridin üstünde kalıyor.
     **Ölçüm:** yalnızca genişliğe oranlanan punto iPad'de şeridi
     yüksekliğin %11,6'sına çıkarıyordu (iPad iPhone'a göre çok daha geniş
     ama aynı oranda uzun değil); yükseklik tavanıyla iPhone %7,1 / iPad
     %9,0 ve yedi başlığın yedisi tek satıra sığıyor (gerçek
     `SpaceGrotesk-Bold` metrikleriyle ölçüldü).
     **ASIL BULGU — alfa.** İş akışına eklenen `sips -g hasAlpha` ölçümü
     yedi karenin yedisinde de `yes` dedi: Flutter'ın ekran görüntüsü yolu
     RGBA üretiyor, App Store Connect ise ekran görüntüsünde saydamlık
     kabul etmiyor. Yani kareler ölçü olarak doğru olmalarına rağmen
     YÜKLENEMEZDİ ve arıza ancak Console'da, zincirin en sonunda
     görünecekti. Düzeltme sürücüde: `test_driver/png_flatten.dart` kareyi
     opak beyaz zemine kompozit edip RGB olarak yazıyor (`sips` alfa
     kanalını kaldıramıyor; JPEG'e gidip dönmek metni bozardı). Kapı İKİ
     katmanlı: `test/png_flatten_test.dart` dönüşümü Linux'ta saniyeler
     içinde, iş akışındaki `hasAlpha != no` ise gerçek çıktıyı macOS'ta
     doğruluyor.
     **İki içerik düzeltmesi (ikisi de kullanıcı yakaladı):** 4. karenin
     "en uzun kelime"si `KELİMELİK`ti — rakip bir Türkçe kelime oyununun
     adı, vitrinde *"en uzun kelimem"* diye duruyordu (→ `ÇALIŞKAN`); ve
     karelerdeki oyuncu adı `Ironman`dı — hem başkasının tescilli markası
     hem bu projede gerçek bir hesabın takma adı (→ `Ege`). Ders kayda
     geçti: sahte veri uydururken elenecekler listesi ÜÇ başlıklı —
     gerçek kişi/e-posta · gerçek arkadaş adı · **başka bir marka**.
     Sözcüğü "kelime oyunu" çağrışımından seçmek tam da bu tuzağa
     götürüyor.
     **Üçüncü boşluk:** ölçüm adımı `build/screenshots/*.png` üzerinde
     dönüyordu, yani üretilmeyen bir kare hiç bakılmadan geçiyordu — bir
     `testWidgets` düşse koşu YEŞİL kalırdı (adımın kendi yorumu bunun
     kapsandığını iddia ediyordu). `KARE_SAYISI` ile önce sayım yapılıyor.
     **Doğrulama:** `flutter analyze` temiz, **838 test** yeşil,
     `ios-screenshots.yml` koşusu yeşil. **Doğrulama sınırı:** karelerin
     KOMPOZİSYONU gözle görülmedi — ajan artefaktı indiremiyor (MCP'de araç
     yok; API'nin indirme ucu `blob.core.windows.net`e yönlendiriyor ve
     oturumun çıkış vekili onu reddediyor). Şerit oranları sayıyla
     doğrulandı, göze nasıl göründüğü kullanıcının onayında.

   - ✅ **Parça 198 — DAR EKRAN (375 pt) GERÇEK BİR HEDEF: tanıtım
     rozetleri ve Setup'ın birincil butonu (10 Eylül 2026, iPhone/TestFlight):**
     Kullanıcı iki şey bildirdi — *"tanıtım ilk slaytta X2/X3 legend'lar 2
     satıra çıktığı için yazı alta kaymış"* ve *"setup tarafında oyna butonu
     ekran dışında kalıyor"*. İlk hipotez ("sistem yazı boyutu büyütülmüş")
     ekran görüntüleriyle ÇÜRÜDÜ: hem iPhone hem iPad varsayılan Dynamic
     Type'taydı.

     **Ölçüm teşhisi verdi** (gerçek fontlarla widget testi): rozetler
     375 pt'de ×1,0'da bile alt alta düşüyor, 390/393 pt'de düşmüyor;
     393 pt'de ×1,15'te düşüyor. Setup'ta gerçek güvenli alan paylarıyla
     (üst 59 · alt 34) `OYUNU BAŞLAT` 375 pt ×1,0'da 769–786 → görünür alt
     sınır 778, yani **varsayılan ayarlarla kesik**. Yani kırılmanın kaynağı
     yazı ölçeği değil GENİŞLİK; 375 pt de egzotik değil: iPhone SE/mini ve
     **Display Zoom açık her iPhone** oraya düşüyor.

     **İki düzeltme:** (1) rozetlerin `Wrap`ı `FittedBox(scaleDown)` içine
     alındı — sarmak yerine satırı küçültüyor, küçültme ×1,3'te ~0,76 olup
     çarpım bugünkü ×1,0 render'ına eşit çıkıyor, yani okunaklılık
     düşmüyor. (2) `OYUNU BAŞLAT`/`VAZGEÇ` satırı kaydırılan gövdeden
     çıkarılıp `Scaffold.bottomNavigationBar`a yapıştırıldı (kullanıcı
     kararı: *"A yap"*). Elenen alternatif: dar ekranda ZORLUK açıklamasını
     gizlemek — bir eşik oyunu, bir sonraki uzayan içerikte hata geri gelir.

     ⚠ **İki tuzak yaşandı:** (a) `Center` gevşek kısıt altında TÜM
     yüksekliği kaplıyor — çubuk bütün ekranı yiyip gövdeyi ezdi, testler
     dokunuşların çubuğa düşmesiyle yakaladı; çözüm `heightFactor: 1`.
     (b) Buton taşınınca "kutu butona yapışmasın" iddiası anlamını
     yitirdi (kutu artık butonun ÜSTÜNDE) — iddia SİLİNMEDİ, yapışık
     çubuğun kendi değişmezine çevrildi: *çubuk kaydırılan içeriğin sonunu
     kalıcı olarak gizlememeli*.

     **Görmeyen testlerin sebebi tek bir sayıydı:** ikisi de tek bir boyda
     koşuyordu (420×900/950) ve güvenli alan payı hiç modellenmemişti.
     Artık `intro_screen_test` 375@1,0 · 375@1,3'ü, `setup_screen_test`
     375@1,0 · 375@1,3 · 393@1,3'ü gerçek çentik/gösterge paylarıyla
     ölçüyor. Doğrulama: `dart analyze` temiz, **835 test yeşil**.

   - ✅ **Parça 197 — HİÇ OYNANMAMIŞ OYUN ARTIK PORTTA DA HİÇ
     YAZILMIYOR (10 Eylül 2026; ilk TestFlight turunda kullanıcı gördü):**
     Cihaz turu (1.0.9/620, `Derleme 46664f6`) temiz geçti; tek gözlem şuydu:
     *"Login olup YZ'ye döndüğümde tanıtım turundan sonra hamle yapılmamış
     oyun bekleyen oyunlarda duruyordu. Sonra pat diye ekrandan silindi."*

     **Teşhis — web'de 31 Ağustos 2026'da DEĞİŞEN bir kural porta hiç
     işlenmemişti.** Web o gün autosave'in ÖNÜNE tek bir kapı koydu
     (`App.tsx`: `if (state.turnCount < 2) return;`) ve gerekçesini yazdı:
     eşiği yalnızca çıkışta uygulamak *telafi edicidir*, yani TEK bir çıkış
     yolunu kapatır. Port ise o günden önceki tasarımı taşıyordu —
     `CloudGameSession._onChange` / `GameSession._onChange` koşulsuz
     yazıyor, `end()` telafi ediyordu. Kod yorumu bunu açıkça yanlış
     biliyordu: *"turnCount eşiği YOK — web'de de autosave koşulsuz yazar"*.

     **Görünen şey buydu:** oyun 600 ms debounce dolunca
     `local_game_saves`e yazıldı (satır listede belirdi), Setup'a dönerken
     `end()` sildi (satır kayboldu). **Asıl risk temiz çıkışta değil:**
     iOS uygulamayı arka planda öldürürse `end()` hiç çalışmaz ve satır
     bulutta kalır — `local_game_saves` cihazlar arası olduğundan web dahil
     her yüzeyde hayalet bir "Devam Eden Oyun" olarak 7 gün. Haksız -2 YOK
     (süpürme yalnızca `turnCount>=2`'yi cezalandırıyor).

     **Düzeltme:** iki `_onChange`e de `if (s.turnCount < 2) return;`
     (satır id'si de artık ancak ilk gerçek değişimde üretilir);
     `end()`teki silme dalı DURUYOR — düzeltmeden önce yazılmış satırlar
     için hâlâ gerekli.

     **Testler eski davranışı kodluyordu, sekizi birden düştü** — yani kapı
     duyarlı: `cloud_save_test` (helper `newPlayState` artık GERÇEKTEN
     başlamış oyun üretiyor), `local_game_repo_test`, `setup_cloud_test`.
     Yeni iddialar eskisinin tersi: kill yolunda (`detach()`, `end()` YOK)
     ne satır ne terk olayı kalıyor; Setup'ta satır bir an bile görünmüyor.
     Doğrulama: `dart analyze` temiz + tam takım yeşil.

   - ✅ **Parça 196 — iPad MANZARA: ölçüldü, karar verildi, kapı Linux'a
     indi (9-10 Eylül 2026; arşiv §25):** Apple bundle'ı 90474 ile
     reddedince `Info.plist` iPad için DÖRT yönelimi bildirmek zorunda kaldı
     (#501), yani uygulama iPad'de artık döndürülebilir ve `main.dart`in
     portre kilidi orada FİİLEN ÖLÜ. Manzara hiç bakılmamış bir yüzeydi.
     - **DENENDİ ve ELENDİ — gerçek simülatörde ölçüm.** 24.5'in kare boru
       hattı zaten gerçek bir `iPad Pro 13"` simülatörü koşturduğu için
       ölçüm oraya bindirildi (`ios-screenshots.yml`e ikinci iş +
       `integration_test/ipad_landscape_test.dart`). **Simülatör DÖNMEDİ**
       ve sebebini iOS'un kendisi söyledi:
       `UISceneErrorDomain Code=101 "The current windowing mode does not
       allow for programmatic changes to interface orientation."`
       Yani çoklu göreve açık bir iPad uygulamasında
       `setPreferredOrientations` **İKİ YÖNDE DE** geçersiz — §25 bunun
       yalnızca portre yönünü yazıyordu, artık iki yönü de kanıtlı ve
       ALINTILANABİLİR bir hata koduyla.
     - **Sonucu: iş SİLİNDİ.** Manzara metriklerini kurabilen tek şey
       `tester.view.physicalSize` override'ı, o da platformdan bağımsız —
       yani 14 dakikalık bir macOS işi hiçbir şey eklemiyordu. Kapı
       `mobile/app/test/ipad_layout_test.dart`e indi: 9 test, **4 saniye**,
       her push'ta koşuyor. Çekim sahnesinin ortak dosyaya çıkarılması da
       geri alındı — ikinci tüketici kalmayınca soyutlama gereksizdi;
       `store_screenshots_test.dart` bayt bayt eski (yeşil) hâline döndü.
     - ⚠ **İKİ TURLUK DERS — bir ölçü aleti kendi bulgusuyla düşmemeli.**
       İlk sürüm dönüşü bir `expect` ile zorunlu kılmıştı: koşu #6'da altı
       testin altısı da o satırda düştü ve bulgunun GERİ KALANINI (kareler,
       taşma raporu, kutu ölçüleri) beraberinde götürdü. Dönüş raporlamaya
       çevrilince (koşu #7) ölçüm baştan sona koştu ve iOS'un hata satırı
       ancak o zaman görüldü.
     - **KARAR (kullanıcı, arşiv §25): manzaraya özgü düzen YAPILMAYACAK.**
       Sözleri birebir: *"Eğer Apple açısından sıkıntı yoksa bazı ekran
       tiplerinde alt kısımda boşluk kalması ok. Sonuçta her ekran tipine
       göre ekran design etmek çok maliyetli bir iş olur ve riskli olur."*
       Koşulu varsayılmadı, Apple'ın yazılı kuralı okundu: 2.4.1 bugün
       yalnızca *"iPhone apps should run on iPad whenever possible"* diyor,
       letterboxing/"ekranı tam kullan" yasağı YOK; 2.3.3 ekran
       görüntüsünden yalnızca "kullanımda göstersin" istiyor.
     - **Kapının ne SORDUĞU karardan türüyor:** *"iyi mi?"* değil
       *"kırılmıyor mu?"*. Boşluk ölçülmez (bilinçli kabul); ölçülen üç şey
       taşma · tahta/raf ekranın içinde · `OYNA`/`PAS GEÇ`/`OYUNU BAŞLAT`
       erişilebilir. Üç ölçü: portre 1032×1376 · manzara 1376×1032 · Split
       View 458×1032. **Duyarlılığı kanıtlandı** (dar pencere geçici olarak
       200×320'ye çekildi: hem tahta hem `OYUNU BAŞLAT` yakalandı).
     - ⚠ **Yan gözlem — kare boru hattında İLK takılma:** koşu #7'de
       `iphone-6.9` işi "Kareleri üret" adımında ~6 saat asılı kalıp
       GitHub'ın iş tavanına takıldı (koşu "cancelled" göründü). Aynı dosya
       koşu #6'da geçmişti ve `ipad-13` bu koşuda da geçti — yani altyapı
       takılması, kod değil. Tekrarlarsa bir zaman aşımı (`timeout-minutes`)
       eklenmeli; tek vakada eklenmedi.

   - ✅ **Parça 195 — tanıtımın tarayıcı turu: karşılama penceresi + balon
     hizası/tipografisi (7 Eylül 2026 akşamı; web + port AYNI PR):**
     kullanıcı Pages derlemesini denedi, üç madde bildirdi.
     - **HATA (port): balon yazısı sola yapışıyordu.** Kök sebep bir Flutter
       değişmezi: `Stack` konumsuz çocuğuna GEVŞEK kısıt verir → `Column`un
       çapraz ekseni "en geniş çocuk" kadar kalır → `crossAxisAlignment`
       görünür iş yapmaz → kutu `topStart`a, yani SOLA düşer. Kuyruk kendi
       `Positioned`ıyla doğru yerdeydi, hata bu yüzden "ok doğru, yazı
       solda" görünüyordu. Düzeltme: `Column`u
       `SizedBox(width: double.infinity)` ile sarmak. **Web'de yoktu.**
       ⚠ Hata Parça 194'te zoom balonunun geometrisi genelleştirilirken
       girdi: eski `_zoomHintBubble`ın `Column`u doğrudan
       `Positioned(left:0,right:0)` içindeydi (TIGHT genişlik → hiza
       çalışıyordu), ortak `_coachBubble` onu bir `Stack`e aldı ve kısıt
       sessizce gevşedi. **Ders: bir widget'ı `Stack`e taşımak çocuğun
       kısıtlarını değiştirir; hizalama o taşımada sessizce ölür.**
     - **Regresyon kilidi ÖLÇÜYOR, bakmıyor:** `tutorial_game_test` →
       "balon hizası" orta banttaki balonun merkezini tahtanın merkeziyle
       (<2 px), kenar sütundakini sağ yarıyla ve kuyruğun balonun yatay
       aralığında kaldığını sınıyor. Duyarlılık kanıtlandı: düzeltme geri
       alınınca sapma **156 px**.
     - **ÜRÜN: karşılama penceresi.** *"Setup'dan hemen oynaya basınca
       kendini oyunda sanıyor"* — tanıtım ekranı gerçek oyuna birebir
       benziyor. Tanıtım açılırken tek pencere: "Kelimeki Tanıtım Turu" +
       "Yaklaşık 1 dk sürecek…" + "Devam". Kapının parçası DEĞİL, kendi
       bayrağı YOK (tanıtım zaten bir kere gösteriliyor). Metinde tek
       düzeltme `hoşgeldiniz` → `hoş geldiniz`.
     - **Tipografi:** punto `clamp(9,2.4vw,13)` → `clamp(11,3.2vw,16)`;
       genişlik kapağı tahta balonunda %96 → %72, raf balonunda 72vw → 58vw
       (uzun cümleler iki satıra kırılsın diye — ikisi BİRLİKTE ayarlanır).
       Raf balonu ortalandı; OYNA balonu sağda kaldı (butonu işaret ediyor).
       Tahta balonunun üçte-bir kuralı korundu: kenar sütunda kuyruk ancak
       öyle balonun altında kalıyor.
     - **`verify-tutorial-script` genişletildi:** balon iki satıra
       kırıldığından örtüşme kontrolü İKİ değil ÜÇ komşu satıra bakıyor;
       dört sahne de geçiyor.
     - **Testler:** `tutorial_parity_test` +2 (karşılama metinleri; punto ve
       genişlik kapağı iki tarafta aynı sayı), `tutorial_game_test` +1 hiza
       + tüm testler pencereyi geçiyor, `setup_screen_test` kapı testi de.
       Web: `smoke.spec.ts` + `gameOverFixture.tanitimiAtla` pencereyi
       kapatıyor (71/71 yeşil).
     - **İKİNCİ TUR (aynı akşam, kullanıcı web önizlemesini denedi):**
       *"Oyna balonunun oku Oyna butonunu göstermiyor"* — WEB'E ÖZGÜ tuzak:
       `Balon` kabı `items-center`, çağıran `items-end` veriyordu; Tailwind'de
       kazananı sınıf dizesi DEĞİL üretilen CSS sırası belirler, yani
       `items-end` sessizce yutulup kuyruk balonun ortasında kalıyordu. Hiza
       artık `style` (prop: `hiza`), kuyruk kenardan 12 px içeride (portun
       `_Balon`ıyla aynı). **Ders: bir düzen kararı hem kabın sınıfından hem
       çağıranın sınıfından geliyorsa satır içi stile taşı.** Kilit ölçüyor:
       `smoke.spec.ts` kuyruğun merkezinin OYNA butonunun x aralığında
       kaldığını iddia ediyor; hiza bozulunca düşüyor (kanıtlandı).
       Ayrıca zoom ipucu ve "Buradan başla" balonları da aynı puntoya
       (`clamp(11,3.2vw,16)`) çekildi — ekrandaki ÜÇ balon tek ölçüde,
       `tutorial_parity_test` bunu değişmez olarak kilitliyor.
     - **ÜÇÜNCÜ TUR — metin (aynı akşam):** vergi penceresinin notu
       *"Rakibin bölgesine değen veya giren bir hamle yaparsan vergisini
       ödersin."*, 2. sahnenin balonu *"Kelime kurdukça bölgeni
       büyütürsün."* — ikisi de terimi `sınır`dan `bölge`ye çekiyor
       (`Landing.tsx`/`intro_screen.dart`teki cümleyle aynı kalıp).
       Kullanıcının `bölgeni` biçimi geçişli fiil istediğinden `büyür` →
       `büyütürsün`. Parite testinin nota bakan iddiası cümlenin İLK
       KELİMELERİNE çapalıydı (metin değişince sessizce kırılırdı); artık
       port sabitinin web dosyasında geçtiğini doğruluyor. Aynı sahnenin
       SONUÇ satırı da çekildi (`+15 puan — bölgen köşenin dışına taştı.`):
       balon "bölge" derken bir sonraki satırın "sınır" demesi tek sahnede
       iki terim olurdu.
     - **DÖRDÜNCÜ TUR (aynı akşam):** raf balonu mesaj şeridinin üstüne
       biniyordu (*"mesajlar görünmüyor… kaydırsak iyi olur"*). Çözüm
       yapıda: `Stack`/`relative` artık raf satırında değil, MESAJ ŞERİDİNİ
       DE kapsayan sarmalayıcıda — balon `bottom-full` ile ikisinin birden
       üstüne taşıyor. Sabit bir "şu kadar yukarı kaydır" YAZILMADI (şerit
       `min-h` ile büyüyebilir; magic number bir gün sessizce yanlış olur).
       Portta dolgular birleşti: (12,4,12,0) + (12,6,12,12) → (12,4,12,12)
       + 6 px `SizedBox`, boşluklar birebir aynı. Kilit iki tarafta da
       ÖLÇÜYOR (kutular çakışmamalı); port testi balon eski yerine konunca
       565 > 545 ile düştü.
     - **Doğrulama sınırı:** cihazda koşulmadı; punto/satır kırılması ve
       balonun hedefi örtmemesi gözle `mobile/TESTING.md` §1.9'da.

   - ✅ **Parça 194 — "Oynayarak öğren" tanıtımının port ikizi (Onboarding
     Faz 4, 7 Eylül 2026; web `TutorialGame.tsx` + `tutorialScript.ts` +
     `utils/onboarding.ts`in portu):** kullanıcı APK'yı indirip tanıtımı
     göremedi — hata değildi, port kodu hiç taşımıyordu (web Faz 1 aynı gün
     canlıya çıkmıştı, PR #483).
     - **Ne yapıldı:** `ui/tutorial/tutorial_script.dart` (dört sahne, torba
       sırası, başlangıç durumu — `StartAction`sız, DOĞRUDAN kurulup
       `GameController.restore` ile yüklenir; motora action/alan EKLENMEDİ),
       `ui/tutorial/tutorial_game.dart` (ekran: raylar, senaryolu rakip,
       vergi onayı, kapanış kartı; kendi controller'ı — `GameSession`/
       `CloudGameSession`/`logStart`/k-lig ÇALIŞMAZ), `util/onboarding.dart`
       (`shouldShowTutorial`, dört sinyal, `tutorialLaunchAt` web ile AYNI
       tarih — port için yeniden tarihlenmedi, bilinçli), `FlagsStore.
       seenTutorial`/`markTutorialSeen` (eski `seenQuickstart` salt okunur
       miras; yazıcısı kaldırıldı — portta zaten hiç yazılmıyordu),
       `BoardWidget.targets`/`coach` + `RackWidget.highlight`, Setup'ta kapı
       (`_tanitimGosterilsinMi` → `_runTutorial`; işaret AÇILIRKEN konur).
     - **Zoom balonu geometrisi GENELLEŞTİRİLDİ, üçüncü geometri yazılmadı:**
       `_zoomHintBubble` artık `_coachBubble`ı çağırıyor (çapa 6,6 · `ust`
       · %78 · 10/7 dolgu); tanıtım balonu aynı fonksiyonu %96 ve 9/6 ile.
       Kuyruk çapanın sütununda, yatay hiza sütuna göre (sol/sağ üçte bir →
       yaslı, orta → ortalı) — web `Board.tsx`in `coach` bloğu.
     - **Sürükleme hissi tekilleşti (devir notu tuzak 5):** sabitler
       `game_screen`+`online_game_screen`de İKİ kopyaydı; tanıtım üçüncüyü
       gerektirince `ui/game/drag_feel.dart`a çıkarıldı (web `dragFeel.ts`
       ile aynı gün, aynı gerekçe). Hayalet ölçüsü/ölçeği de oradan.
       `layout_parity_test` değeri tek Dart kaynağından okuyor, üç ekranda
       `dragThresholdFor(e.kind)` kullanımını arıyor, yerel kopyayı
       yasaklıyor; `kTapSlopOnRelease`/`kDragLift` web ile sayı sayı eşit.
     - **Torba yönü DOĞRULANDI (tuzak 2):** `bag.dart` `removeLast` ile
       çeker (web `pop`) — torba `[dolgu…, çekilme sırası TERS]` kuruluyor;
       `tutorial_script_test` ilk dört çekilişi `tutorialDrawOrder` ile
       karşılaştırıyor.
     - **Hesap yaşı sinyali:** web `profile.created_at` okuyor; portta
       `KProfile` bu alanı taşımıyor ve profil önbelleği de yok — Supabase
       oturumunun `User.createdAt`i kullanıldı (aynı an: profil satırı
       kayıtta açılıyor). Profil sonradan açılmışsa port daha "eski" görür
       → GÖSTERMEZ; kapının varsayılan yönü, kabul edildi.
     - **Testler:** `tutorial_script_test` (senaryo GERÇEK motorda — web
       `verify-tutorial-script`in dokuz kontrolü + kapı tablosunun yedi
       vakası + torba yönü), `tutorial_parity_test` (web KAYNAĞINI okur:
       dört sahnenin id/say/bubble/hamle/done/not'u, kapanış, adlar,
       DRAW_ORDER/BAG_FILLER/START_RACKS, üç süre, beş balon/mesaj metni,
       vergi notu, kapı tarihi, TutorialGateInput alan sayısı — bulamazsa
       DÜŞER), `tutorial_game_test` (dört sahne dokunarak: puan metinleri,
       vergi penceresinde 58/19, kapanış → `onFinish`; sürükleme: taş
       parmağın 30 px üstünden iner, yanlış kare rafa döner, vurgusuz taş
       sürüklenemez, konan taşa dokunuş geri alır; raylar sessiz; ATLA),
       `setup_screen_test` (+4: tertemiz depoda misafir → tanıtım + bayrak
       açılırken; görmüş depo → doğrudan oyun; eski hesap → açılmaz; yeni
       hesap → hesap adıyla açılır). Depo YOKSA kapı kapalı — öteki Setup
       testleri değişmedi.
     - **Bulunan ders (testte):** vurgusuz raf taşına dokunmak SEÇİMİ
       DEĞİŞTİRMEZ (pointerDown erken döner) — yani önceki seçim durur ve
       hedef kareye o iner. Web'de de böyle (`onSelect` vurgusuzu yok
       sayar); ilk test iddiası bunu "kare kabul etmez" sanıp düştü, iddia
       davranışa çekildi (davranış doğru: ray "yanlış taşı seçtirmez",
       "seçimi silmez").
     - **Doğrulama sınırı:** cihazda koşulmadı — süre (60-90 sn hedefi),
       balonun %200 yazı ölçeğinde kırpılmaması ve gerçek parmakla
       sürükleme hissi `mobile/TESTING.md` §1.9'da. Web'in duman testi
       hayalet tık için 350 ms bekliyor; Flutter'da compat click YOK,
       tanıtımda `swallowNextClick` eşi de yok (gerekmiyor).
     - **`mobile/` DIŞINDA da dosya değişti:** kök `CLAUDE.md` ("İlk Oyun"
       + etki tablosu), `README.md`, `ROADMAP.md` §24 (Faz 4 kapandı),
       `docs/decisions/onboarding.md` (Faz 4 kaydı). Web kaynak kodu
       DEĞİŞMEDİ; parite testi `src/**` okuduğu için `web-ci.yml`in mevcut
       `paths` listesi zaten kapsıyor.

   - ✅ **Parça 193 — puan satırı AVATAR HİZASINA oturdu + yardım metninin
     zorluk cümlesi (6 Eylül 2026, kullanıcı iki bildirim; web + port aynı
     PR):** *"Puanlar avatarların tam altına gelmiyor. Özellikle 4 kişilik
     oyunda. Tire olmasa acaba nasıl olurdu?"*
     - **Teşhis (ölçüm, yama değil):** Parça 192'nin satırı tek bir DİZEYDİ
       (`238 - 179 - 103 - 87`). Avatarlar 6 px BİNİYOR (26 px çap → adım
       20 px), akan metin ise kendi harf genişliğiyle ilerler — iki ritim 4
       koltukta tamamen ayrışıyor. Yani sorun punto/boşluk ayarı değil,
       yapısaldı; kullanıcıya üç seçenek (mevcut · tiresiz · hizalı) gerçek
       kart stilleriyle çizilip ekran görüntüsüyle sunuldu, kullanıcı
       **"C hizalı"** dedi.
     - **Çözüm:** `AvatarScoreRow` (web `PlayerAvatarRow.tsx` · port
       `ui/game/player_avatar_row.dart`) — her puan `adım` eninde kendi
       hücresinde, satır `binişme/2` kadar kaydırılmış; cebiri
       `util/score_line.dart` ↔ `utils/scoreLine.ts` (`scoreCellWidth`,
       `scoreRowOffset`). Hiza gelince AYIRICI TİRE düştü. Binişme artık iki
       tarafta da adı olan bir sabit (`kAvatarRowOverlap` /
       `AVATAR_ROW_OVERLAP`); web'de `-space-x-1.5` sınıfının içinde gizli
       kalsaydı biri değişince hiza sessizce kayardı.
     - ⚠ **`ScaledCell` DEĞİL, sabit en + `FittedBox` — kuralın bilinçli
       istisnası:** `ScaledCell` kutuyu yazı ölçeğiyle büyütür, oysa
       AVATARLAR ölçekle büyümüyor; hücre büyüseydi hiza tam da tavanda
       kayardı. Kuralın amacı (sarma/taşma yok) `FittedBox(scaleDown)` ile
       karşılanıyor. `score_line_test` iddiayı ölçek 1,0 VE `kMaxTextScale`
       için ayrı ayrı koşuyor.
     - **Testler:** `score_line_test.dart` yeniden yazıldı — geometri cebiri
       + 4 kişilik/üç haneli en kötü hâlde her puanın merkezi kendi
       avatarının merkezinde (<0,5 px) ve komşusuna değmiyor. ⚠
       `share_recent_test`in DÖRT testi düştü ve bu GERÇEK bir uyarıydı:
       aynı sayı artık satırda iki kez var (sağdaki "kendi skorun" +
       hizalı puan). Bulucular gevşetilmedi, `ScaledCell`e daraltıldı
       (`sagSutunMetni`) — sağ sütun hizasını ölçen test yanlış widget'ı
       ölçmeye devam etseydi sessizce anlamsızlaşırdı.
     - **Yardım metni:** zorluk paragrafının son cümlesi kullanıcının
       yazdığı biçime çekildi ("4 kişilik oyunda; Kolay'da birinci +1 k-lig
       puanı alır, ikinci puan almaz; Zor'da birinci +4, ikinci +2 k-lig
       puanı kazanır."), web + port BİREBİR (`ai_level_parity_test` zaten
       paragrafı karşılaştırıyor — ikisinden biri unutulsaydı düşerdi).
     - **Doğrulama:** `flutter test` tam takım **795 yeşil**, `dart analyze`
       temiz; web `tsc` + `vite build` temiz, Playwright **67 yeşil**.
       Ayrıca GERÇEK uygulamada uçtan uca doğrulandı (Chromium, 4 kişilik
       YZ oyunu oynanıp Setup'a dönüldü): kart `0 36 43 45` puanlarını dört
       avatarın altında hizalı çizdi.
   - ✅ **Parça 192 — kart altı PUAN SATIRI + "X açtı" kalktı + Son
     Oynananlar'da tarih üste (6 Eylül 2026, kullanıcı isteği; web + port
     aynı PR):** *"Canlı ve YZ bekleyen oyunlarda avatarların altına
     kişilerin o anki puanlarını yazalım. Sayılar çok yakınsa araya tire
     koyalım. Ironman açtı kalksın … Font kalan süre ile aynı olsun. Son
     oynananlarda da aynı şekilde bitiş puanlarını koy. Oradaki tarihi
     avatarların üstüne koy."*
     - **Tek kaynak metin:** `util/score_line.dart` ↔ web `scoreLine.ts`
       — koltuk/snapshot sırasıyla `join(' - ')`. Sıra AVATAR sırası (rank
       değil): N'inci sayı N'inci yüzün altında. Ayırıcı her zaman tire
       (boşluk "45 38"i tek sayı gibi okutuyor).
     - **Veri:** Canlı puanları `online_game_states.players[].score`tan;
       `gateway.deadlines` seçimine `players` eklendi (üçüncü bir istek
       açılmadı), `OnlineGamesSnapshot.scores` (4. pozisyonel, varsayılan
       boş — fake gateway'ler değişmedi), `scoresFromPlayersJson` bozuk
       elemanı 0 sayar (web `typeof p.score === 'number'` ikizi). YZ kartı
       `state.players`, Son Oynananlar `entry.players` snapshot'ından.
     - **Düzen:** `_SavedGameRow._solBlok` Row → Column (üst satır avatar +
       rozet, altında puan); `_GameRow` "X açtı" Text'i puan satırıyla yer
       değiştirdi (kurucu zaten `slots[0]`, ilk avatar); `_RecentRow` sol
       sütun tarih(+rozet) → avatar → puan. Stil üçünde de
       `devamEdenSureStil(_muted)` (kullanıcı: "font kalan süre ile aynı").
     - **Testler:** `score_line_test.dart` (metin sözleşmesi + JSON ayrıştırma
       + Son Oynananlar dikey sırası), `live_games_test` "Devam Edenler kartı"
       (puan avatar altında, süre puanın altında, `açtı` yok),
       `setup_screen_test` "DEVAM EDEN OYUN" (`^0 - \d+$` sol alanın içinde,
       aynı dikey sıra) — kartı açan test artık `ValueKey('game-g1')` ile
       dokunuyor. Tam takım yeşil (`flutter test`).
     - **Doğrulama sınırı:** gerçek `online_game_states` satırının `players`
       jsonb'si sahte uçla temsil edildi; cihazda `mobile/TESTING.md`
       "Kart altı PUAN SATIRI" maddesi (Realtime tazelenmesi dahil).
   - ✅ **Parça 191 — zorluk rozeti üç renk + tahta şeridinde + seçici
     alt-sekme stilinde (6 Eylül 2026 gece, kullanıcı isteği; web + port
     aynı PR):** *"kolay rozeti yeşil, normal turuncu, zor kırmızı olsun;
     rozetleri boardun altındaki mesajlaşmanın olduğu yere de koyalım;
     zorluk butonlarını Arkadaşınla alt-sekme buton stiliyle aynı yapalım."*
     - **Kural değişti:** rozet artık YZ oyununda HER seviyede (Normal
       turuncu da çizilir), yalnızca Canlı oyunda yok. "YZ oyunu mu" kararı
       çağıranda: `aiLevelForBadge(raw, isAiGame:)` (web aynı ad) —
       kartlarda `onlineGameId == null`, GameOver'da YZ ekranı geçirir /
       Canlı ekran geçirmez (`showGameOverModal(aiLevel:)`), tahta şeridinde
       `BoardWidget.aiLevel` yalnız `game_screen` verir. Renk
       `aiLevelBadgeColor` (kGreen/kOrange/kRed) ↔ web `AI_LEVEL_BADGE_CLASS`.
     - **Şerit:** rozet "Hamleler"in sağında, Canlı'daki "· Mesajlaşma"nın
       yerinde, ayraç aynı; `TapTarget` DEĞİL — `layout_parity_test`in "üç
       TapTarget / beş `min-h-[48px]`" sayımı bilerek korundu (web'de ayraç
       ve rozet 48px sınıfı taşımıyor).
     - **Seçici:** `_zorlukBtn` = `_localSubTabBtn`in rozetsiz ikizi (11px,
       dikey 10 dolgu, aynı gölgeler); web `Setup.tsx` `LiveGamesTab`
       alt-sekme sınıf dizesine geçti. `_SavedGameRow._solBlok` avatarların
       SAĞINA rozet koyan bir `Row` (önce alt satırdaydı; Preview'da rozet
       `flex-col` çocuğu olarak tam genişliğe uzadı, kullanıcı gördü).
     - **Doğrulama:** `flutter analyze` temiz; `ai_level_test` (Kolay
       yeşil/+1, Normal turuncu/+2, Canlı rozetsiz — GameOver · Tüm Oyunlarım
       · Son Oynadıklarım), `ai_level_parity_test` (`aiLevelForBadge` dört
       dalı), setup/layout/text_scale/tap_target/game_screen takımları
       yeşil; web `tsc` + smoke Kolay/Normal yeşil. **Sınır:** cihazda
       renklerin ve şeridin tek satırda kaldığı görülmedi — §13 maddesi.

   - ✅ **Parça 190 — Zorluk seçicisinin açıklama metni: her seviyede,
     kullanıcıya hitapla, puanı `leaguePoints`ten (6 Eylül 2026 akşamı, web +
     port AYNI PR):** kullanıcı Kolay'ın altındaki *"en iyi birkaç hamleden
     birini oynar"* cümlesini gördü: *"bilimsel iş yapmıyoruz, kullanıcıya
     bunu söylemeye gerek yok"* — üç seviyenin metnini kendisi verdi ve 4
     kişilikte puan bilgisinin genişlemesini istedi. Kaynak web
     `src/utils/aiLevel.ts` (`AI_LEVEL_PITCH` + `aiLevelDescription`) →
     port `util/ai_level.dart` (`aiLevelPitch` + `aiLevelDescription`);
     `setup_screen.dart`te açıklama artık `_level == kolay` koşulsuz, seçili
     seviye + `_count` ile her zaman çizilir (web `Setup.tsx` aynı).
     - **Yorum:** kullanıcının "beraberlik puanları" dediği şey puan
       tablosunda 4 kişiliğe özgü tek satır olan **ikincilik** puanı olarak
       okundu (Kolay 0 → "ikincilik puan kazandırmaz", Normal 1, Zor 2);
       beraberlik zaten aynı sırayı paylaşarak birincilik puanını verir.
     - **Neden metin değil fonksiyon:** sayılar `leaguePoints` tablosundan
       türetiliyor (web `leaguePoints.ts`, port core `league_points.dart`) —
       tablo değişirse metin kendiliğinden değişir, dördüncü bir kopya
       açılmadı (ROADMAP 23.4 "dokuz kopya" dersi). Zor'un metni bugünden
       hazır; Faz 5 `selectableAiLevels`e `zor`u ekleyince kendiliğinden
       görünür.
     - **Kapı:** `ai_level_parity_test` artık hitap cümlelerini web
       kaynağından okuyup karşılaştırıyor + altı bileşimi (3 seviye × 2/4
       kişi) TAM metinle kilitliyor; web `tests/smoke.spec.ts` aynı metinleri
       Setup'ta görüyor (iki taraf ayrışırsa biri orada, öteki burada
       düşer). `setup_screen_test` ZORLUK testi üç seviye/iki sayı geçişini
       sınıyor.
     - **Yan etki (test):** açıklama her seviyede görününce misafir formu
       900 px'lik test ekranında uzadı ve "Neden Ücretsiz Üye Olmalıyım?"
       testinin `GİRİŞ YAP / KAYIT OL` dokunuşu ekran dışına düştü —
       `ensureVisible` eklendi. Cihazda karşılığı yok (form zaten
       kaydırılabilir).
     - **Doğrulama:** `flutter analyze` temiz; `flutter test` tam takım
       yeşil; web `npm run lint` + Playwright Zorluk testleri (2) yeşil.
       **Sınır:** metin cihazda okunmadı — `mobile/TESTING.md` §13 maddesi
       yeni metinlere göre güncellendi, 1.0.8 turunda okunur. ⚠ 1.0.8 Play'e
       yüklenmediyse bu değişiklik o pakete biner (`mobile-latest` yeniden
       derlenir, kütükteki koşu no/SHA-256 bayatlar).

   - ✅ **Parça 189 — YZ zorluğu portta: ZORLUK seçici + seviyeli k-lig
     puanı/rozet üç kartta (6 Eylül 2026, ROADMAP #23 Faz 4 — web Faz 3'ün
     ikizi):** kaynak `Setup.tsx` / `AiLevelBadge.tsx` / `aiLevel.ts` /
     `gameRecord.ts` / `HelpModal.tsx` (Faz 3 PR'ı). Ne yapıldı ve neden:
     `docs/decisions/roadmap-arsiv.md` → "23 · Faz 4" (tek kopya orada).
     - **Bilinçli eksik YOK; dokunulmayanlar:** `kelimeki_core` (motor Faz
       2'de bitti — golden'lar aynen), Canlı ekranlar/kartlar (seviye yok),
       `devam_eden_govde.dart` (rozet sol sütuna girdi, ortak gövde aynen),
       `surumler.md` (paket yüklenmedi).
     - **Ders:** rozet gibi "yokken hiç çizilmeyen" bir öğeyi porta
       taşırken web'in `null` dönüşünün flex `gap`i de kapattığını hesaba
       kat — `SizedBox.shrink()` tek başına yetmez, ÖNÜNDEKİ boşluk da
       koşullu olmalı; aksi hâlde Normal kart 6 px kayar ve hiçbir test
       (piksel testleri Normal veriyle koşuyor) bunu görmez.
     - **Doğrulama:** `flutter analyze` temiz; `flutter test` tam takım
       yeşil (yeni: `ai_level_parity_test` 5 · `ai_level_test` 4 ·
       `setup_screen_test` +3 · `game_record_test` +1). **Sınır:** cihaz
       kanıtı (web ↔ port aynı puan, aynı hesap iki cihaz) sürüm turunda —
       `mobile/TESTING.md` §13'e madde yazıldı.

   - ✅ **Parça 124 — arka plandan dönüş artık "ekrana giriş" sayılıyor
     (21 Ağustos 2026 yazıldı, **4 Eylül 2026'da kurtarıldı**; web + port
     AYNI PR):** kullanıcı webde bildirdi — arka planda açık kalan uygulama
     öne getirildiğinde, sırası kendisinde olmasına rağmen "Arkadaşınla"
     sekmesi açık gelmiyordu. Sebep bir hata değil, **"bir kez" kuralının
     KAPSAMI**: `_appliedLoginDefault` (web `appliedLoginDefaultRef`) hesap
     başına bir kez uygulanıyor ve ekran hiç dispose OLMUYOR (`SetupScreen`
     `MaterialApp.home`, oyunlar `Navigator.push` — Parça 38'in "Setup'a her
     geliş" dersinin aynısı), yani o bir kez ilk girişte tükeniyordu.
     **Portta bu web'den DAHA sık görülür**: mobil uygulama gün boyunca
     defalarca arka plana alınıyor.
     - ⚠ **Neden bu ciltte:** Parça 124 numarası donmuş `parca-log-110-138.md`
       cildine düşüyor; kök `CLAUDE.md`'nin "Doküman Boyutu Bütçesi" kuralı
       dondurulmuş bir cilde yeni girdi yazmayı YASAKLIYOR ("girişi AKTİF
       cilde taşı"), o yüzden burada. Commit `f5f81ad`, dal
       `claude/friend-tab-not-opening-04aa9o` — PR açılmadığı için `main`'e
       hiç girmemişti, dal temizliğinde fark edildi.
     - **Yeni `lib/src/util/away_return.dart`** (web `src/utils/awayReturn.ts`
       portu): uzaklaşma/dönüş anlarını sayıyor, eşik **5 dakika**
       (`kLongAway`). Sinyal `AppLifecycleState` — `resumed` DIŞINDAKİ her
       durum "uzaklaştı" sayılıyor; iOS'ta bildirim bandı/Kontrol Merkezi
       `inactive` üretiyor ama süre kısa kaldığından eşiği geçemiyor.
     - **İKİ ekran birden bağlandı** (`setup_screen.dart` ana sekme,
       `live_games_tab.dart` alt sekme) — yalnız birini bağlamak, sekmede
       oturan kullanıcıyı yarı yolda bırakırdı.
     - **Yeniden silahlanmak tek başına sekmeyi DEĞİŞTİRMEZ:**
       `_refreshLiveBadge` hâlâ yalnızca bekleyen iş varsa Canlı'ya geçiyor,
       alt sekme kararı da yalnızca bekleyen DAVET varsa "Oyun Davetleri"ne.
       Alt sekmeyi zorla "Devam Edenler"e çekmek BİLEREK yapılmadı — bekleyen
       hiçbir iş yokken bile kullanıcıyı yerinden ederdi.
     - **Eşik web dosyası OKUNARAK kilitli** (`test/away_return_test.dart`,
       `offline_notice_test`in deseni) — biri değişip öteki kalırsa mobil
       test paketi düşer. Kararın kendisi de 6 testle sınanıyor (kısa
       kesinti → false, ilk `markAway` kazanır, karar bir kez tüketilir).
     - **Flutter SDK bu ortamda YOK** — Dart yarısının kanıtı CI.

   - ✅ **Parça 188 — kafa kafaya çubuğunun avatarları 18 → 26 px
     (3 Eylül 2026, kullanıcı cihazda gördü; değişen
     `ui/score/player_score_card_modal.dart` + web ikizi
     `PlayerScoreCard.tsx`):**
     - **Kullanıcı:** *"Web yayında ve düzelmiş gözüküyor. Ama skor kart %
       çubuğu avatarlar çok küçük duruyor, biraz büyütmek lazım."* Yani
       Parça 187'nin iki düzeltmesi sahada doğrulandı, kalan tek şey
       ölçüydü.
     - **26 keyfi bir sayı DEĞİL** — bu projede avatarın standart boyutu
       (kullanıcının kendi kararı: *"hepsi 26 olsun"*). Yeni bir ölçü
       uydurmak yerine var olana çekildi. Çubuk 8 → 10 px, çünkü 26'lık
       avatarın yanında 8 px cılız kalıyordu.
     - **Çakışma ÖLÇÜLDÜ, tahmin edilmedi:** blok 144 → 160 px; kartın
       336 px'lik iç genişliğinde `justify-between` şeridin öteki ucundaki
       `Tüm Oyunlar` butonuyla arası hâlâ 70 px (buton sağ kenarı 126,9 ↔
       blok sol kenarı 197).
     - **Kod değişikliği tek satırlık ama testler kendiliğinden korudu:**
       Parça 187'de eklenen `RenderBox.size` ölçümü hâlâ dilimlerin
       boyandığını zorluyor; üç şeritli yapının simetrisi avatar boyutundan
       BAĞIMSIZ olduğundan hiçbir hiza testi dokunulmadan geçti (757 test +
       `dart analyze` temiz, web tarafında 65 Playwright testi).

   - ✅ **Parça 187 — cihazda çıkan İKİ hata: boş çubuk ve bozuk hiza
     (3 Eylül 2026, kullanıcı APK testi; değişen
     `ui/score/player_score_card_modal.dart`,
     `ui/setup/recent_games_section.dart` + web ikizi):**
     - ⚠⚠ **Kafa kafaya çubuğu İÇİ BOŞ geliyordu** ve testler yeşildi.
       Sebep saran `Row`un `crossAxisAlignment` VARSAYILANI (`center`):
       gevşek dikey kısıtta çocuğu ve ölçüsü olmayan `ColoredBox` **en küçük
       boyutu (0)** alıyor. Dilimler ağaçta duruyor, sıfır yükseklikte.
       Çare `CrossAxisAlignment.stretch`.
       **Testin hatası:** `ColoredBox`ların VARLIĞINI ölçüyordu, boyanan
       ALANINI değil. Artık `RenderBox.size` ölçülüyor; düzeltme öncesi
       `Actual: <0.0>` ölçüldü. **Genel kural: "widget ağaçta var" bir
       GÖRÜNÜRLÜK iddiası DEĞİLDİR.**
     - ⚠ **Puan/k-lig sağda hizalı değildi — İKİ sebep:** (a) sütunlar düz
       `Text`ti, genişlik içeriğe göre değişiyordu; (b) sol sütun Canlı'da
       `Flexible`di (loose fit), avatar SAYISI genişliği değiştiriyordu ve
       artan boşluk `MainAxisAlignment.start` gereği en sağda kalıyordu.
       ÖLÇÜLDÜ (412 px): k-lig sağ kenarı dört farklı yerde, 4 kişilik satır
       **30,9 px** sağda. Çözüm: sayısal sütunlar `ScaledCell` + sol sütun
       `Expanded`.
     - ⚠ **İkinci parça ortadaki etiketten genişlik ALDI:** 1:1 bölüşüm
       320 px/ölçek 1,3'te etiketi 0,4 px kırpıyordu (111,0 ↔ 110,6). Flex
       **2:3** ikisini birden karşılıyor. İki test birden kilitliyor —
       flex'i değiştiren bir sonraki tur birinden düşer.
     - **Regresyon: 1 yeni test + 1 sıkılaştırma.** Hiza testi üç satırı
       (2 kişilik · 4 kişilik · tek basamaklı) ölçüp sağ kenarların 0,5 px
       içinde eşit olmasını istiyor (skor 375,0 · k-lig 401,0).
       ⚠ Testin kendi hatası da bir ders: `find.text('+2')` iki satırda
       eşleşip belirsiz kaldı — aynı metin birden fazla satırdaysa
       `evaluate()` ile HEPSİNİ topla.
     - Kullanıcı ayrıca *"en büyük fontla denedim sorun yok"* dedi — Parça
       186'nın `Wrap` düzeltmesi sahada doğrulandı.

   - ✅ **Parça 186 — "Oyun Bitti (Yeni)": biten oyunun haberi (3 Eylül
     2026, kullanıcı isteği; yeni tablo `game_finish_seen` + 2 RPC, değişen
     `data/online_games_api.dart`, `ui/live/live_games_tab.dart`,
     `ui/setup/setup_screen.dart`, `ui/setup/recent_games_section.dart`,
     `ui/live/online_game_screen.dart` + web ikizleri):**
     - **Kullanıcı:** *"Kişi başkasıyla oynadığı oyunun bittiğinden haberi
       olmuyor… ancak son oynadıklarıma girersen görüyorsun."* Push BİLEREK
       elendi (*"oyun bitti mesajı atmak işin dozunu kaçırabilir"*) — sistemde
       zaten sıra ve son-tarih bildirimleri var, üçüncü tür yorgunluk üretirdi.
     - ⚠ **`games`'e kolon EKLENMEDİ.** O tablonun SELECT politikası
       `auth.uid() is not null` — girişli HERKES herkesin satırını okuyor;
       "gördü" kolonu kimin ne zaman listesine baktığını herkese açardı. Aynı
       sınıf bu repoda bir kez yaşandı (`games.messages`, 10 Ağustos 2026).
     - **İşaretlemenin İKİ yolu şart:** toplu (sekme ziyareti) ve tek oyunluk
       (bitiş modalı). Yalnız toplu olsaydı oyunu bitiren — modalı GÖREN —
       kişi kendi oyunu için de rozet alırdı; yalnız tek olsaydı sekme
       ziyareti sayacı sıfırlamazdı. Bitiş modalında toplu işaretlemek de
       yanlış olurdu: görülmemiş BAŞKA oyunlar sessizce yutulurdu.
     - ⚠ **ROZET ZİNCİRİ bir karar, tesadüf değil:** alt sekme → üst sekme
       EVET; giriş varsayılanı (`decideInitialMainView`) HAYIR (kullanıcı
       kararı — o "yapacak işin var" demek, biten oyun ise HABER). Kazara
       bozulmamasını sağlayan şey, o kararın alanları TEK TEK toplaması
       (`inviteCount + myTurnCount`), nesneyi kör toplamaması.
       `PendingLiveGameCounts`'a alan eklerken bu deseni koru.
     - ⚠ **Kullanıcının tarifinde İKİ AN var ve aynı anda olmuyorlar:**
       *"girip gördüğünde tab numarası sıfırlanır"* (giriş anında) ama
       *"yeni kalkar, sadece Oyun bitti kalır"* (ÇIKIŞTA). Bu yüzden satır
       rozetleri anlık listeye değil, sekmeye girerken alınan bir
       ENSTANTANEye bağlı (`_freshFinished`) — anlık listeyi bağlasaydık
       rozetler kullanıcı tam bakarken gözünün önünde kaybolurdu.
     - **Sayaç yalnızca sunucu ONAYLARSA sıfırlanıyor.** Çevrimdışıyken
       yerelde sıfırlamak rozeti kaybettirir ama sunucuda görülmemiş bırakır;
       bir sonraki tazelemede geri gelip "kayboldu sonra döndü" diye tuhaf
       görünürdü. Bu kod tabanında tek seferlik kararların BAŞARISIZ veriyle
       tüketilmesi üç kez hata olarak kayıtlı.
     - **Alt sekme değişimi TEK kapıdan** (`_setSubTab`) geçiyor: elle
       dokunuş da varsayılan-sekme kararı da. Ayrıca `didUpdateWidget` —
       kullanıcı ZATEN sekmedeyken bir oyun biterse (Realtime tazeledi)
       rozet yine görünsün diye; yoksa haber sekme açıkken sessizce birikir.
     - **`_RecentRow` yine parametre aldı** (`yeni`): ayrı bir
       `StatelessWidget`, `widget.` yok — Parça 184'ün dersi tekrar geçerli.
     - **Regresyon: 7 test** (`live_games_test.dart`) — rozet çıkar/çıkmaz ·
       sekme ziyareti TOPLU işaretler ve sayacı sıfırlatır · **işaretleme
       düşerse sayaç sıfırlanmaz** (negatif eş) · `pendingCounts` listeyi
       taşır ama "bekleyen iş"e katmaz · haber çekimi düşse de sayılar gelir ·
       `markFinishesSeen` ağ hatasında `false`.
     - ⚠ **KAPSAM aynı gün daraltıldı (kullanıcı):** *"YZ'de oyun bitti
       yazmasına gerek yok. Bu sadece canlı oyunlar için geçerli."* İlk tur
       `OYUN BİTTİ` etiketini HER İKİ listeye de koymuştu; haklı olarak
       kaldırıldı — YZ oyunu SENİN cihazında bitiyor, bitişini zaten gözünle
       görüyorsun, orada etiket bilgi taşımaz. Üçü de (etiket · `YENİ` ·
       sayı) artık yalnızca Canlı'da. Koşul `_RecentRow`a **parametre**
       olarak geçiyor (`onlineOnly`) — Parça 184'ün dersi üçüncü kez.
       Regresyon: 3 test daha (`share_recent_test.dart`) — YZ'de ÇİZİLMEZ ·
       Canlı'da çizilir · görülmemişte `YENİ` çıkar. İlk test satırın
       gerçekten çizildiğini ayrıca doğruluyor, yoksa hiçbir şey kanıtlamaz.
     - **TESLİM OLDUN etiketi (aynı gün, kullanıcı sorusu):** *"teslim
       rozeti koymak iyi olurdu ama yer sınırlı sanırım. Küçük ekranlarda
       kayabilir."* Endişe haklıydı ama çözüm ayrı bir sütun DEĞİL: aynı
       kutunun metni teslimde `TESLİM OLDUN` oluyor.
     - **Son düzen turu (kullanıcı):** *"Oyun bitti yazısını büyük harf ve
       ortadaki boşluğa koy, yeni rozeti hemen yanına gelsin ve fontu büyüt
       biraz. Teslimi de Teslim Oldun yap."* Etiket ortadaki boşluğa geçti
       (sol sütun `Expanded` → `Flexible`, boşluğu etiket alıyor), `YENİ`
       alttan YANA taşındı, punto 9 → 10 / rozet 8 → 9.
       ⚠ `Expanded`↔`Flexible` koşulu ŞART: YZ'de etiket hiç olmadığından
       boşluğu sol sütun almalı, yoksa skor bloğu sağ kenardan kopup ortaya
       kayardı. Koşul için `_SolSutun` sarmalayıcısı yazıldı — alternatif
       aynı `Column`u iki kez kopyalamaktı.
       ⚠ Metin KAYNAKTA büyük harf, `toUpperCase()` ile DEĞİL: Türkçe'de
       "Bitti"nin i'si noktasız I'ya dönebilir; repo native dönüşümü zaten
       yasaklıyor. Dönüşüme gerek yoktu.
       **Ölçüldü (tarayıcıda, 320/360 px × 4 vaka):** orta bloğun içeriği
       en kötü durumda 113,9 px, blok 164 px → 50 px pay; 16 bileşimde
       taşma/sarma/kırpılma sıfır. Portta ayrıca `Flexible` + `maxLines: 1`
       + `ellipsis` var (yazı ölçeği riski YALNIZCA portta — web'de
       `text-[10px]` mutlak px, sistem yazı boyutuyla ölçeklenmiyor).
       ⚠ Bayrak SATIR SAHİBİNE ait (`games.surrendered` kişi başına):
       rakibin süresi dolduysa benim satırım `OYUN BİTTİ` kalır.
       `GameHistoryModal`'ın "Teslim Oldu" kuralıyla aynı. Renk nötr —
       teslimin kırmızısı zaten sağdaki -2'de.
       Regresyon: 2 test daha — teslimde `TESLİM` + `-2` görünür ·
       RAKİBİN teslimi benim satırımı değiştirmez.
     - ⚠ **`YENİ` "YENI" diye okunuyordu — sebep KOD DEĞİL GLİF** (kullanıcı
       bildirdi). Karakter ölçüldü: `Y E N` + **U+0130**, yani kod her zaman
       doğruydu. Space Mono'da `İ`nin noktası 8-9 px'te harfin gövdesine
       YAPIŞIYOR (6× büyütmeyle ölçüldü; 10 px'ten sonra ayrılıyor) ve rozet
       9 px'ti. Çare punto: etiket ve rozet ikisi de **11 px**. Bu bir
       tercih değil okunabilirlik zorunluluğu — iki dosyada da yorumla
       işaretli, düşüren bir sonraki tur hatayı geri getirir.
       Yan bulgu: aynı probe'da CSS `uppercase` `lang="en"` bağlamında
       "Yeni"yi U+0049 (noktasız I) yapıyor. Metni kaynağa büyük harf yazmak
       bu locale bağımlılığını tamamen kaldırdı.
     - ⚠⚠ **EN BÜYÜK YAZI BOYUTU: kullanıcı sordu, ÖLÇÜLDÜ ve GERÇEK BİR
       KIRPILMA BULUNDU.** *"Ekran büyütenler için en büyük font nasıl
       davranıyor?"* Web'de bu sorunun konusu yok (px metin ölçeklenmez,
       sayfa zoom'lanır). Portta ölçek tavanında (1,3) 320 px'te etiket
       **111 px istiyor, 74,9 px alıyordu** → `TESLİ…`. **Kırpılma HATA
       BASMAZ**, yani "taşma yok" iddiası bunu göremezdi.
       Çare `Row` → **`Wrap`**: sığdığı sürece rozet yanda, sığmadığında
       alta iner (satır uzar, harf kaybolmaz) — kök CLAUDE.md'nin "sıkışan
       satırı BÖL" önerisi. `Flexible` kaldırıldı (Wrap çocuğuna esneklik
       verilemez).
       **32 bileşim ölçüldü** (320/360/390/430 px × 2-4 kişi × iki etiket ×
       iki ölçek): oyuncu SAYISI hiç fark etmiyor; ölçek 1,0'da 360 px ve
       üstünde hepsi yanda (320'de yalnız teslim alta), ölçek 1,3'te 430'da
       hepsi yanda, 390'da yalnız `OYUN BİTTİ` yanda.
       ⚠ `Wrap` TAŞMAZ SARAR — repo kuralı gereği aynı turda "tek satırda
       mı" iddiası da yazıldı: 360 px/normal ölçekte rozet YANDA olmak
       ZORUNDA. `Row`a dönülürse tavan testi GERÇEKTEN düşüyor.
     - **Süre aşımı teslimi kendiliğinden kapsandı:** o senaryo normal bir
       bitiş gibi `games` satırı yazıyor (canlıda doğrulandı, iki tarafa da),
       yani haber rozeti orada da çalışıyor — ve en çok işe yaradığı yer
       burası: oyunu bitiren hamleyi yapmadın, bitiş modalını görmen mümkün
       değildi.
     - **Doğrulama sınırı:** gerçek akış İKİ hesap ister (rakip senin yokken
       oynayıp oyunu bitirmeli). Cihaz kontrolü `mobile/TESTING.md`'de.

   - ✅ **Parça 185 — kafa kafaya istatistik: skor kartının alt şeridi (3
     Eylül 2026, kullanıcı isteği; yeni `util/head_to_head.dart` +
     `test/head_to_head_test.dart`, değişen `data/stats_api.dart`,
     `ui/score/player_score_card_modal.dart` + web ikizleri; yeni RPC
     `head_to_head_stats`):**
     - **Kullanıcı:** *"Skor kartın altında tüm geçmiş oyunlar tüm oyunlar
       olsun ve sola dayansın. Sağ tarafa dayalı bir % çubuğu, üstünde oyun
       sayısı, barın sol tarafına bakılan kişi avatar, sağ tarafına bakan
       kişi avatar. İsim yazmayacak."* Alt satır tek ortalanmış butondan
       `spaceBetween` bir şeride döndü; etiket `TÜM OYUNLARI GÖR` → **`TÜM
       OYUNLAR`** (web'de de `Tüm Oyunlar`).
     - **Aynı gün ikinci istek:** *"Hepsinde Tüm oyunlar olsun / Ve sola
       yapışsın."* İlk tur yalnızca BAŞKASININ kartını değiştirmişti; kendi
       kartı (`score_card_modal.dart`) hâlâ ortalanmış `TÜM GEÇMİŞ OYUNLAR`
       diyordu — aynı işin iki adı, iki hizası. Artık dört yüzeyde de tek
       ad + sola yaslı. Geçmiş modalının BAŞLIĞI da (`Tüm Geçmiş Oyunlar`)
       `Tüm Oyunlar` oldu ve bu ESKİ bir parite açığını kapattı: web o
       başlığı zaten öyle yazıyordu. ⚠ Kalan fark — web başlığa oyuncu
       sayısını ekliyor (`Tüm Oyunlar · 2 Oyunculu`), port eklemiyor;
       bilinçli borç.
     - **Sayım SUNUCUDA, çünkü istemcide DOĞRU yapılamıyordu:** `games`in
       donmuş `players` anlık görüntüsü `user_id` TAŞIMIYOR — istemcide
       eşleme ancak İSİMLE olurdu ve takma ad değiştirilebildiği için
       sessizce yanlış sayardı. `online_games.slots` gerçek `user_id`
       taşıyor. (İkincil sebep: geçmiş sayfalı, tamamını saymak tüm
       geçmişi sayfalamak demekti.)
     - **Güvenlik sınırı TEK koşul:** `g.user_id = auth.uid()` — fonksiyon
       yalnızca çağıranın KENDİ `games` satırlarını okuyor. ⚠ Ve
       `revoke ... from public` `anon`u KALDIRMADI (Supabase'in
       `alter default privileges`i ayrı bir grant veriyor); ikinci bir
       migration gerekti. Yeni bir `security definer` fonksiyonda grant'leri
       `execute_sql` ile GERÇEKTEN oku.
     - **Yalnızca 2 KİŞİLİK oyunlar (kullanıcı kararı):** 4 kişilikte
       ikinizin arasındaki sonucu öteki iki oyuncu belirlemiş olabilir.
       Aynı filtre `ai_score`u da doğrudan rakibin skoru yapıyor.
     - ⚠ **Yuvarlama KÜMÜLATİF olmak zorunda:** üç oranı bağımsız
       yuvarlamak 1/3-1/3-1/3'te 33+33+33=**99** verir ve çubukta bir
       piksellik boşluk açar. Kural saf ve iki tarafta birebir:
       `head_to_head.dart` ↔ `src/utils/headToHead.ts`, aynı vakalar
       `test/head_to_head_test.dart` + `npm run verify-head-to-head` (14
       kontrol).
     - ⚠ **`Expanded(flex: 0)` KULLANILMADI** — Flutter'da sıfır flex
       güvenilir davranmıyor; sıfır genişlikli dilim `if (bar.left > 0)`
       ile satırdan tamamen çıkarılıyor. Web'de karşılığı yüzde genişlik,
       o dal gerekmiyor.
     - `StatsGateway`'e metot eklemek `implements` eden **BEŞ** test
       sahtesini birden bozdu (Parça 152'nin `profileAgeGender` notuyla
       aynı refleks) — hepsi aynı PR'da tamamlandı.
     - ⚠⚠ **"Ben kimim" PARAMETREYLE taşındığı için bir yerde SESSİZCE
       kayboldu.** Modal `auth`u zaten alıyor ve beş çağrı yerinin DÖRDÜ
       geçiyordu; "Beğenenler" listesinden açılan kart
       (`game_history_modal.dart`) geçmiyordu — çubuk yalnızca o yoldan
       açılan kartta çizilmiyor, hiçbir derleyici/test bunu söylemiyordu.
       `showGameHistory` artık `auth`u taşıyor. **Web'de bu tuzak YOK:**
       orada `useAuth()` bir BAĞLAM, parametre değil — port karşılığı
       `OnlineScope` deseni olurdu (bkz. `mobile/CLAUDE.md`, `KAvatar`ın
       19 çağrı yeri gerekçesi). Bugün eklenmedi çünkü çağrı yeri beş;
       altıncıda kapsam yazmak parametre taşımaktan ucuz.
     - ⚠ **`_LikersModal` ayrı bir `StatelessWidget`, orada `widget.` YOK**
       — `auth` alan olarak eklendi. Aynı hata 2 Eylül'de `_RecentRow`da da
       yapılmıştı; "web'de derledi" Dart tarafı için kanıt değil,
       `dart analyze` şart.
     - **Regresyon (`test/score_card_test.dart`, 3 test):** başkasının
       kartında oyun sayısı + TAM İKİ dilim (0 beraberlikte orta dilim
       ÇİZİLMEZ) ve isim yazılmaz · KENDİ kartında hiç çizilmez · games=0'da
       hiç çizilmez. Negatif eş koşuldu: sıfır dilim koruması kaldırılınca
       ilk test GERÇEKTEN düşüyor.
     - İsim yazılmadığı için çubuk web'de `role="img"` + açıklayıcı
       `aria-label` taşıyor: ekran okuyucuda iki avatar arasındaki renk
       şeridi hiçbir şey ifade etmezdi.
     - **Üçüncü tur (aynı gün):** *"Toplam oyun barın hemen altına ortalı
       gelsin. Barın üstüne de yeşil kırmızı alanlara %'ler gelsin.
       Beraberlik hep ortada kalsın ama % gösterme."* Blok üç satır oldu:
       üstte yüzdeler, ortada avatar+çubuk, altta oyun sayısı.
       ⚠ **Yüzdeler dilimin ORTASINA değil kendi UCUNA yaslı**
       (`spaceBetween`, çubuk genişliğinde bir `SizedBox`): kırmızı hep sol
       uçtan başlar, yeşil hep sağ uçta biter, yani dilim daralsa bile
       etiket kendi alanının üzerinde kalır ve ikisi çakışmaz. Ortalasaydık
       `%5 – %95` gibi bir dağılımda dar dilimin etiketi taşardı.
       ⚠ **Sıfır etiketi `SizedBox.shrink` ile GİZLENMEZ, `Opacity(0)` ile
       gizlenir** — kaldırılsaydı `spaceBetween` altında tek kalan etiket
       ortaya kayardı.
       **Üç şeridin hizası hesapla değil YAPIDAN geliyor:** avatar satırı
       18+6+96+6+18 = 144, yani çubuk satırın tam ortasında; üst/alt
       şeritler 96 genişlikte ve `center` olduğundan kendiliğinden hizalı.
       Regresyon: yeni bir test — beraberlik dilimi çiziliyor ama `%34`
       hiçbir yerde YOK; yüzdelerin renkleri de kilitlendi.
     - **Doğrulama sınırı:** iki GERÇEK hesap gerektiriyor — `flutter test`
       sahte uçla çiziyor. Cihaz kontrolü `mobile/TESTING.md`'de.

   - ✅ **Parça 184 — liste sıralaması: "bitmeye en yakın üstte" (3 Eylül
     2026, kullanıcı isteği; yeni `util/game_list_order.dart`, değişen
     `data/online_games_api.dart`, `ui/setup/setup_screen.dart` + web
     ikizleri; `test/game_list_order_test.dart`):**
     - **Kullanıcı:** *"YZ ve canlı sıra sende bekleyen oyunlarda sıralama
       bitmeye en yakın üstte şeklinde olmalı. Oyun davetlerinde de süresi
       bitmeye en yakın üstte olacak."*
     - ⚠ **KÖR TERS ÇEVİRME YANLIŞ OLURDU.** Aktif liste zaten "son oynanan
       üstte" (AZALAN) diye sıralıydı ve bu 31 Ağustos'ta BAŞKA bir
       kullanıcı şikayetiyle konmuştu. Tamamını artana çevirmek iki gün
       önceki düzeltmeyi geri getirirdi. Çözüm asimetrik:
       **sıra BENDE artan** (yapacak iş var, en acil üstte),
       **sıra RAKİPTE azalan** (yapabileceğim şey yok, anlamlı sıra "son
       hareket eden"). Kullanıcının isteği zaten yalnızca ilk gruba aitti.
     - ⚠ **NULL TUZAĞI — sessizdi ve yön değişince patlıyordu.** İki tarafta
       da deadline yoksa `0` kullanılıyordu; AZALAN sıralamada zararsızdı
       (dibe düşerdi), ARTANDA ise `0` "en yakın bitiş" sayılıp EN ÜSTE
       çıkardı. Kural artık null'ı her iki grupta da SONA koyuyor.
     - **Kural İKİ AYRI YERDE elle yazılıydı** (web'de inline sort, portta
       `activeBucket`); yorumları "birebir aynı ölçütler" diyordu ama
       hiçbir şey zorlamıyordu. Ortak dosyaya çıkarıldı, iki taraf aynı
       vakalarla testli: `npm run verify-game-list-order` +
       `game_list_order_test.dart` (10 vaka, yön iddiaları negatif eş).
     - ✅ **CİHAZDA DOĞRULANDI (3 Eylül 2026, kullanıcı — Appetize/Android):**
       *"Sıralama doğru geliyor."*
       ⚠ Yol üstünde ölçülen işletim ayrıntısı: **Appetize'ın Android ve iOS
       uygulamaları AYRI işlerde, AYRI zamanlarda yükleniyor** (Android işi
       ~8 dk, iOS macOS runner'ında ~15 dk). Yani merge'den hemen sonra
       Android app'i tazeyken iOS app'i hâlâ bir önceki derlemedir —
       panelde "updated N hours ago" görülmesinin sebebi budur, arıza değil.
       Tazeliğin kesin ölçüsü panel metni değil, Setup'taki
       `Derleme <sha>` satırı.
     - Davetler/bekleyenler `created_at`e (davet süresi ondan işliyor),
       yerel YZ kayıtları `updated_at`e (7 günlük silinme ondan işliyor)
       göre ARTAN. İkisinin de depo sorgusu `desc` döndüğü için sıra
       gösterim katmanında çevriliyor.

   - ✅ **Parça 183 — avatarlar 26 px, bindirme 4 → 6 (2 Eylül 2026,
     kullanıcı isteği; değişen `ui/game/player_avatar_row.dart`,
     `ui/live/live_games_tab.dart` + web ikizleri):**
     - Kullanıcı sordu: *"kutuyu genişletmeden, yazıları bozmadan
       avatarları biraz daha büyütecek yerimiz var mı?"* — ölçüldü, VAR:
       davet kartında ada kalan 218 px'e karşılık 10 karakterlik takma ad
       (`maxLength: 10`) tavanda bile ~117 px. Genişlik hiç darboğaz
       değildi; gerçek bedel satır YÜKSEKLİĞİ.
     - Kullanıcı *"hepsi 26 olsun"* dedi; `PlayerAvatarRow` varsayılanı
       20 → 26 (üç kartı birden besliyor) ve davet kartının insan+robot
       avatarları 22 → 26 (robot ikonu 13 → 15, kutuyla orantılı).
     - ⚠ **BİNDİRME 4 → 6 ve bu kozmetik DEĞİL, ölçümden geliyor.** Şerit
       `Expanded` bir alanın içinde; yazı ölçeği tavanında o alan 320 px
       ekranda 92,5 px'e iniyor (`setup_screen_test`in CI ölçümü). 4
       oyunculu oyunda şeridin eni `size + 3*(size − overlap)`:
       26/4 → **92 px** (0,5 px marj, pratikte taşma), 26/6 → **86 px**
       (6,5 px marj). Kullanıcının istediği BOYUT korundu, taşmayı önleyen
       bindirme ayarlandı. Web'de `-space-x-1` → `-space-x-1.5`.
     - Yol üstünde `PlayerAvatarRow`un doküman yorumu BAYAT çıktı: "İki
       çağrı yeri var" diyordu, ÜÇ tane (Canlı kartı sonradan eklenmiş).
       Boyut değiştirmeye gelen biri kapsamı eksik ölçerdi.
     - ✅ **CİHAZDA DOĞRULANDI (3 Eylül 2026, kullanıcı — Appetize).**

   - ✅ **Parça 182 — "Son Oynananlar"da avatarlar (2 Eylül 2026, kullanıcı
     isteği; yeni `util/recent_game_avatars.dart`, değişen
     `ui/setup/recent_games_section.dart`, `ui/live/live_games_tab.dart`,
     `ui/setup/setup_screen.dart`, `ui/game/player_avatar_row.dart` +
     web ikizleri + `test/recent_game_avatars_test.dart`):**
     - **Kullanıcı:** *"Son oynananlara da avatar koyalım. Bu saçma kararı
       geri al. Leaderboard'da zaten avatarlar herkese görünüyor, ayrıca bu
       gizlilik ihlali değil, isteyen fotoğrafını kaldırabilir."* HAKLI ve
       koddan doğrulandı: `leaderboard` view'ı `security_invoker = false`
       ile RLS'i bypass edip herkesin takma adını VE avatarını açıyor
       (`20260722114853_lock_down_profiles_games_select.sql`). Fotoğrafı
       burada gizlemek kendi içinde tutarsızdı.
     - ⚠ **İLK ANALİZİM YANLIŞTI ve kullanıcının ikinci sorusu düzeltti.**
       "Snapshot'ta `user_id` de `avatar_url` de yok → migration + RLS
       kararı şart" demiştim. Kullanıcı sordu: *"bekleyen oyunlardan farkı
       ne, niye bu kadar zor?"* — ve fark VERİDEYDİ, bileşende değil:
       canlı kartlar `list_my_online_games`in koltuklarını okuyor (orada
       `avatar_url` profillerden join'leniyor), "Son Oynananlar" ise
       donmuş jsonb'yi. Kapalı kapıda durup YANINDAKİ açık kapıyı
       aramamışım: `games.online_game_id` DURUYOR ve bitmiş çevrimiçi
       oyunların `online_games` satırı SİLİNMİYOR. **Migration da RLS
       kararı da gerekmedi.** Deponun kendi dersi (Parça 54): bir kapı
       kapalıysa aynı mekanizmanın öteki örneklerini ara.
     - **Çözüm:** çevrimiçi kayıtta `online_game_id` → oyunun canlı
       koltukları → isim eşlemesi; yerel kayıtta ada BAKMADAN hesabın kendi
       avatarı (tek insan koltuk her zaman satırın sahibi).
     - ⚠ **Eşleme OYUNLA SINIRLI, global DEĞİL** — takma adlar
       değiştirilebiliyor (`AccountSettingsModal`), global arama adı
       sonradan devralan BAŞKASININ yüzünü gösterirdi. En kötü ihtimal
       artık "eşleşme yok → baş harf", yanlış yüz değil. Bu sınırın negatif
       eşi iki tarafta da testli ("başka oyundaki aynı isim sızmaz").
     - Kural saf bir dosyada ve İKİ tarafta aynı vakalarla koşuyor:
       `npm run verify-recent-game-avatars` + `recent_game_avatars_test.dart`.
     - ✅ **CİHAZDA DOĞRULANDI (3 Eylül 2026, kullanıcı — Appetize):**
       *"Avatar maddeleri de ok."* Fotoğraflar listede görünüyor.

   - ✅ **Parça 181 — iPad'de paylaşım İKİ yolda ASILI KALIYORDU: ankrajın
     kendisi geçersizdi (2 Eylül 2026; değişen: `util/share_board.dart`,
     `ui/setup/setup_screen.dart`, `ui/friends/friends_modal.dart`,
     `test/share_recent_test.dart`):**
     - **Kullanıcı Appetize'da ölçtü — iPad Air / iOS 16.2, ekran
       görüntüleriyle.** Üç paylaşım yolundan İKİSİ kırık: Setup footer
       "Paylaş" *"hiç tepki vermiyor"*, Arkadaşlar "Davet et" butonu `…`
       (meşgul) durumunda KİLİTLİ. Oyun geçmişindeki tahta paylaşımı
       ÇALIŞTI.
     - **Aradaki tek fark ankrajın NEREDEN geldiğiydi:**

       | Yol | Ankraj kaynağı | Sonuç |
       |---|---|---|
       | Oyun geçmişi | `_captureKey.currentContext` — tahtanın `RepaintBoundary`si, küçük gerçek kutu | ✅ |
       | Setup | `_SetupScreenState.context` — ekranın TAMAMI | ❌ |
       | Arkadaşlar | `_FriendsModalState.context` — ekranın TAMAMI | ❌ |

     - **Parça 86 işin YARISINI çözmüştü:** ankraj VERMEMEYİ düzeltti,
       ankrajın KENDİSİNİN geçerli olması gerektiğini kontrol etmedi.
       Ekranı kaplayan bir dikdörtgen hem "boş değil" hem "kök view'ın
       içinde"dir — eski iki kontrolden de geçer.
     - **FIRLATMA DEĞİL, ASILMA — ve kanıt ekran görüntüsünde:**
       `_handleInvite`in `finally`si `_inviteBusy`i sıfırlıyor; buton yine
       de `…`ta kaldı, yani future DÖNMEDİ. Setup'ta meşgul göstergesi
       olmadığından aynı asılma "hiçbir şey olmuyor" diye görünüyor —
       tek hata, iki ayrı belirti.
     - **TESTLER NEDEN YEŞİLDİ:** ankraj iddiası yalnızca "boş değil" +
       "ekranın içinde" diyordu. Üstelik test yalnızca ÇALIŞAN yolu
       kapsıyordu. Sözleşmeyi ölçen test, sözleşmenin YETERSİZ tarifini
       ölçüyorsa yeşil olması hiçbir şey garanti etmiyor.
     - **Düzeltme:** `shareOriginFrom` ekranı İKİ EKSENDE birden (≥%95)
       kaplayan kutuyu ankraj saymıyor, 1×1 merkez yedeğine düşüyor; iki
       kırık çağrı yeri kendi düğmesinin kutusuna bağlandı
       (`_shareLinkKey`, `_inviteButtonKey`) — oyun geçmişindeki desenin
       aynısı.
     - ⚠ **İLK YAZDIĞIM EŞİK ÇALIŞAN YOLU KIRARDI:** %50 ALAN oranıydı ve
       tahtanın ankrajı telefonda alanın ~%46'sı — teğet. Ölçüt "büyük"
       değil **"ekranın tamamı"** olmalı: popover büyük bir kutuya sorunsuz
       bağlanıyor, kıran şey ankrajın kök view'la ÖRTÜŞMESİ. Geniş ama kısa
       bir kutu geçerli ankraj olarak kaldı.
     - ✅ **CİHAZDA DOĞRULANDI (3 Eylül 2026):** kullanıcı Appetize'da iPad'de
       üç yolu da denedi — *"üçü de açtı"*. Kanıtı güçlü kılan tek yeşil
       değil DAVRANIŞIN DEĞİŞMESİ: aynı ortamda düzeltmeden önce ikisi
       kırıktı. ROADMAP madde 8 bu doğrulamayla kapandı.

   - ✅ **Parça 180 — "devam eden oyun" kartları İKİ SEKMEDE AYRIŞMIŞTI
     (2 Eylül 2026; değişen: yeni `ui/devam_eden_govde.dart`,
     `ui/setup/setup_screen.dart`, `ui/live/live_games_tab.dart`,
     `test/live_games_test.dart`, `test/setup_screen_test.dart`,
     `test/setup_cloud_test.dart` + web ikizleri):**
     - **Kullanıcı 1.0.5'te (`Derleme 4a0a29b`) iki ekran görüntüsüyle
       bildirdi:** YZ sekmesinde kalan süre kendi alt satırındayken,
       Arkadaşınla sekmesinde durum etiketiyle aynı sağ sütunda ve
       "X açtı" yazısına biniyor.
     - **Kök sebep düzenin yanlış olması DEĞİL, doğrusunun ULAŞILAMAZ
       olması:** doğru şekil aynı günün erken turunda (#408) YZ kartında
       kurulmuştu ama `_DevamEdenGovde` olarak `setup_screen.dart`ın
       İÇİNDE, yani PRIVATE doğdu; Canlı kartı dokunulmadan kaldı. Web'de
       de aynı ayrışma vardı (`flex-col` ↔ `flex items-center`) — tek bir
       yapı hatasının iki platformdaki tekrarı.
     - **Ölçüm (320 px):** durum ve süre tek sağ sütunda toplanınca sütunun
       enini SÜRE belirliyor — "SIRA SENDE" 89,6 px, süre satırı **194,3
       px**. Daraltan etiket değil süre, ölçek 1,0'da bile.
     - **Çözüm:** gövde + tipografi ortak kaynağa (`devam_eden_govde.dart`).
       Aynı turda YZ kartındaki "Sıra: X" alt satırı kaldırıldı (kullanıcı
       isteği — yanındaki `SIRA SENDE` ile aynı şeyi söylüyordu; Canlı
       karttaki "X açtı" BENZEMEZ ve kalır) ve durum puntosu 13 → **15**
       (üçgen/nokta ölçüsü ona çapalı: 8×9/9×9 → 9×10/10×10, web SVG'si ve
       Dart path'i birlikte).
     - **CI DÜŞTÜ ve düzeltildi (aynı gün):** `setup_screen_test` →
       *"isim alanı sıkışmaz"* iddiası **0,710 < 0,75** verdi (ölçülen:
       130,2 → 92,5 px; öncesi 143,4 → 109,7 = 0,765). Eşik **0,70**'e
       çekildi. Bu bir susturma DEĞİL — üç ölçüm gerekçesi:
       (1) 0,75 tasarlanmış sınır değil CIRCIR'dı, o günkü değerin hemen
       altına konmuştu ve **herhangi bir** punto artışını bloke ediyordu
       (15 px → 0,710 gerçek, 14 px → 0,739 türetildi);
       (2) sol sütunda artık METİN YOK — daralmanın kurbanı "Sıra: X"
       satırıydı, bu turda kaldırıldı; geriye kalan `PlayerAvatarRow`
       SABİT genişlikte ve ölçekle büyümüyor;
       (3) daralmanın kaynağı meşru (durum etiketi ölçekle büyüyor,
       durdurmanın tek yolu ekran başına ölçek kısıtı olurdu — kural 1
       yasaklıyor).
       **Oranın kaybettiği koruma somut bir iddiayla YERİNE KONDU:** avatar
       şeridi iki ölçekte de sol alana SIĞMALI. Vekil bir sayı gevşerken
       koruduğu şeyin kendisi kilitlendi.
     - ⚠ **SESSİZ TEST ARIZASI YAKALANDI:** sıkışmayı ölçen iddia sol
       sütunu `find.ancestor(of: PlayerAvatarRow, matching: Column)` ile
       buluyordu. "Sıra: X" kalkınca sol taraf tek bir `PlayerAvatarRow`a
       indi — eni SABİT 36 px — ve bulucu DIŞ sütuna sıçrayıp kartın
       tamamını ölçerdi: test düşmez, **anlamsızlaşırdı**. Sol alan artık
       ortak gövdede anahtarlı (`kDevamEdenSolKey`). **Bir düzeni ölçen
       test, o düzenin İÇERİĞİ değişince yeniden okunmalı.**
     - ✅ **CİHAZDA DOĞRULANDI (3 Eylül 2026, kullanıcı — Appetize):**
       *"Sonuncu madde de ok."* Bu turun dört işi de (iPad paylaşımı,
       avatar 26, Son Oynananlar avatarları, kart düzeni) onaylandı.

   - ✅ **Parça 179 — zoom'da kalıcı 10 px çerçeve + filigranların yazı
     ölçeğiyle bölgeyi taşırması (2 Eylül 2026; değişen:
     `ui/game/board_widget.dart`, `ui/game/game_screen.dart`,
     `ui/live/online_game_screen.dart`, `test/board_zoom_test.dart`,
     `test/text_scale_test.dart`):**
     - **Kullanıcı APK'da bildirdi (ekran görüntüsüyle):** *"App'de
       zoomdayken kenarlarda çerçeve duruyor. Web'deki gibi yuvarlak
       kenarlı alanın tamamına kadar gitmeli. Web'e bak, aynısını uygula.
       Bir de en büyük fontta bölge watermarklar da büyüyüp bölgenin
       dışına taşıyor."*
     - **A) ÇERÇEVE — fark YAPISALDI, değer değil.** Kural gereği önce web
       okundu:

       | | Web | Port (önce) |
       |---|---|---|
       | Kırpan kutu | kartın TAMAMI (`inset-0`) | kart − 10 px |
       | 10 px dolgu | transform'un İÇİNDE | transform'un DIŞINDA |

       ÖLÇÜLDÜ: kart 390×390 iken portun kırpan kutusu **10..380** —
       dört kenarda ölçeklenmeyen, kaydırmayla da kaybolmayan bir çerçeve.
       Web'de dolgu `data-board-grid`in içinde (`p-[10px]`) ve transform
       onun üzerinde, yani çerçeve zoom'la ölçeklenip kaydırmayla ekrandan
       çıkıyor.
     - **Düzeltme = web'in katman sırasının birebir portu:**
       `Listener → ClipPath(kart) → Transform → Padding(10) → ızgara`.
       Kırpma artık kartın kendisi (üst iki köşe yuvarlak, web
       `inset(0 round 18px 18px 0 0)`).
     - **Matematiksel yan etkisi VAR ve atlanmadı:** ölçeklenen kutu artık
       ızgara değil KART, yani `toggleAt`/`panBy`e verilen boyut görünür
       kare olmalı ve odak `kBoardPad` eklenerek ızgara uzayından tahta
       uzayına çevrilmeli. Verilmeseydi izinli öteleme 20 px kısa kalırdı —
       1 Eylül'de web'de tam bu sınıftan bir hata yaşanmıştı.
     - **Parite ÖLÇÜLDÜ, varsayılmadı:** web'de (görünür kare 366 px) en uç
       ötelemede ızgara elemanının sağ kenarı görünür kareninkine tam
       oturuyor (378 = 378), yani öteleme −366 = −(kare genişliği). Portta
       düzeltmeden sonra −390 = −(kare genişliği 390). Aynı kural.
     - **`_zoomClipSlack` (≈3.5 px) KALDIRILDI.** Var olma sebebi "dolgu
       kırpmanın dışında"ydı; artık dış hattın ≤2.5 px'lik taşması kırpma
       sınırından ≥10 px (zoom'da ≥20 px) içeride. Web de tam bu gerekçeyle
       pay taşımıyor. Onu iddia eden test SİLİNMEDİ, aynı değişmezi
       MESAFEYLE ölçen bir testle değiştirildi.
     - ⚠ **Yanındaki test SESSİZCE BOŞA DÜŞMÜŞ.** Rozetin kırpılmadığını
       iddia eden test `ClipRect && clipper != null` arıyordu; görünür kare
       `ClipPath`e dönünce predicate hiçbir şeye uymaz oldu ve test yeşil
       kalarak bir şey kanıtlamamaya başladı. Ayırt edici ızgaranın kendi
       transform anahtarına çevrildi. **Ders: bir widget TİPİNİ değiştiren
       her düzeltmede, o tipi arayan testleri de ara** — yeşil kalmaları
       düzeltmenin doğru olduğunu değil, testin körleştiğini gösterebilir.
     - **B) FİLİGRANLAR.** Köşe numarası / "X2" / merkez "X3" puntoları
       `fluidSize(screenWidth, …)` ile GEOMETRİDEN türüyor ama sistem yazı
       ölçeği onları ayrıca çarpıyordu; `OverflowBox` içinde oldukları için
       de kırpılmadan bölgeden taşıyorlardı. ÖLÇÜLDÜ (tavan 1,3; köşe
       rakamı ↔ 4×4 blok kenarı): **320 px %115 · 360 px %101 (ikisi de
       taşıyor)** · 390 %93 · 412 %88 · 430 %84. "X2" (≤%69) ve "X3"
       (≤%84) taşmıyordu ama %30 büyüyorlardı.
     - **Çözüm `textScaler: TextScaler.noScaling`** — üçüne birden.
       ⚠ Bu, `mobile/CLAUDE.md` kural 1'in ("ekran başına ölçek kısıtı
       YAZMA") ihlali DEĞİL: o kural OKUNAN metni korur, bunlar puntosu
       geometriden türeyen dekoratif zemin şekilleri (ikon gibi).
       Büyütmek okunurluğa bir şey katmıyor, yalnızca bölge sınırını
       bozuyor. Ve ölçüt web: orada `clamp()` px tabanlı, tarayıcı tüm
       SAYFAYI zoom'lar — yani sabitlemek pariteyi KURUYOR. Yalnızca
       taşanı düzeltmek ikisini web'den ayrık bırakırdı, o yüzden üçü de.
     - **İki negatif eş de koşuldu:** filigran sabitlemesi kaldırılınca
       yeni test *"X2 filigranı ölçekle büyümüş (73,4 → 95,5)"* ile,
       dolgu tekrar dışa alınınca zoom testi *"görünür karenin içinde tam
       dolgu kadar durmalı"* ile düşüyor.
     - ⚠ **Testin kendisi ilk yazılışta yanlış kuruldu ve ölçüm düzeltti:**
       köşeye çift dokunmak odak ötelemesi yarattığından mesafe 20 yerine
       −3,1 çıktı. Kurulum "ötelemeyi 0'a daya, sonra ölç" hâline geldi.
     - **Doğrulama:** `dart analyze` temiz · `flutter test` 701 → **702**.

   - ✅ **Parça 178 — şerit ÇEVRİMDIŞIYKEN iki satıra düşüyordu; "taşma
     yok" testi bunu göremez (2 Eylül 2026; değişen:
     `ui/game/board_widget.dart`, `test/text_scale_test.dart`):**
     - **Kullanıcı sordu** (punto turundan hemen sonra): *"Bizim senaryoda
       çevrimdışı konuşmadık. O da gelince ne oluyor? 2 satıra gelip o
       alanı büyütüyor mu?"* — cevap EVET'ti. Bütün punto ölçümleri
       çevrimiçi hâl için yapılmıştı; "Çevrimdışı" beşinci öğe olarak
       girince şerit **48 → 96 px**'e çıkıyordu.
     - **KÖR NOKTA, dersin kendisi:** `Wrap` TAŞMAZ, **sarar**. Mevcut test
       ("tahta alt şeridi 1,3 ölçeğinde TAŞMIYOR") `online: false` ile
       koşuyordu ve YEŞİLDİ — çünkü iddiaları "taşma hatası yok" ve "üç
       metin görünür"dü; ikisi de şerit iki satıra düşmüş hâlde DE doğru.
       Sessiz bozulmayı ancak **konum** ölçen bir iddia yakalar (aynı ders
       30 Ağustos'ta `tap_target_test` için de alınmıştı: kutu BOYUTU ölçen
       test, kümelenmeyi göremedi).
     - **ÖLÇÜLDÜ — tek satır için gereken en az genişlik** (ikili arama):

       | Senaryo | Gereken |
       |---|---|
       | yerel oyun, çevrimiçi, 1,0 ve 1,3 | 240 px |
       | yerel oyun, ÇEVRİMDIŞI, 1,3 | 282 px |
       | Canlı oyun, çevrimiçi, 1,3 | 305 px |
       | Canlı oyun, ÇEVRİMDIŞI, 1,0 | 336 px |
       | Canlı oyun, ÇEVRİMDIŞI, 1,3 | **405 px** |

       Yani asıl offline hâl (yerel/YZ oyunu — offline oynamak bir ÖZELLİK)
       her telefonda güvendeydi; patlayan tek bileşim **Canlı oyun +
       bağlantı kaybı**: 320/360/390 px'te iki satır.
     - **Ayrım ölçmeden görünmüyordu:** "Mesajlaşma" yalnızca Canlı oyunda
       çizilir. İlk ölçüm onu her durumda geçirdiği için sorun olduğundan
       GENİŞ görünüyordu; kırılım yapılınca kapsam daraldı.
     - **Çözüm (kullanıcı seçti):** çevrimdışıyken "Mesajlaşma" ETİKETİ
       düşer, ikon ve okunmamış sayacı kalır. Gerekçe: o anda mesaj zaten
       gönderilemiyor, ikon okumak için duruyor, asıl bilgi olan sayaç hiç
       kaybolmuyor. Eşik 405 → ~348 px.
     - **Sonuç ölçüldü:** 320@1,0 · 360@1,3 · 390@1,3 → hepsi 48 px.
       320@1,0 vakası düzeltmeden ÖNCE de iki satırdı (normal fontta!) ve
       yan fayda olarak kapandı.
     - ⚠ **BİLİNEN SINIR: 320 px + tavan HÂLÂ iki satır.** Gizlenmedi —
       test bunu AÇIKÇA iddia ediyor (`isFalse`), yani bir gün düzelirse
       test düşer ve notlar güncellenir. "Sessizce düzeldi sanmak" bu
       projede iki kez yanlış çıktı.
     - ⚠ **WEB İKİZİ BİLEREK DEĞİŞMEDİ** — parite "aynı kod" değil "aynı
       sonuç": ölçüldü ki `Board.tsx` şeridi 320 px'te bile çevrimdışıyken
       tek satır (48 px), çünkü web'de sistem yazı ölçeği diye bir şey yok
       (tarayıcı tüm SAYFAYI zoom'lar). Web'de çözülecek bir sorun yokken
       etiket kaldırmak yalnızca bilgi kaybı olurdu. Bu, "ikiz dosyalar
       birlikte değişir" kuralının bilinçli istisnası ve gerekçesi hem
       burada hem kodda yazılı.
     - **Negatif eş koşuldu:** düzeltme kaldırılınca yeni test tam beklenen
       mesajla düşüyor (*"360.0 px, ölçek 1.3, ÇEVRİMDIŞI: şerit iki satıra
       düştü"*). Mevcut 2. test de düzeltmeyle birlikte DÜŞTÜ ve doğru
       düştü — çevrimdışıyken metin yerine artık İKONU arıyor
       (`ValueKey('chat-icon')`; sınıf private olduğundan tip olarak
       aranamıyor).
     - **Doğrulama:** `dart analyze` temiz · `flutter test` 700 → **701**.

   - ✅ **Parça 177 — sistem yazı boyutunun ÜÇÜNCÜ hata sınıfı: sabit
     genişlikli kutuda SARMA (1 Eylül 2026; YENİ dosya
     `test/text_wrap_test.dart`; değişen: `ui/text_scale.dart`,
     `game_over_modal.dart`, `leaderboard_modal.dart`,
     `game_history_modal.dart`, `meaning_modal.dart`, `help_modal.dart`):**
     - **Kullanıcı bildirdi (ekran görüntüsüyle):** *"fontlarını büyüten
       kişilerde bitirme modalı puanları bölüyor."* Skor `241` ekranda
       `24`/`1`; başlıklar `KAL`/`AN`, `TOPLA`/`M`, `k-`/`lig`.
     - **Bu, tanımlı iki sınıfın HİÇBİRİ değil.** Taşma üretmiyor (ölçüldü:
       takımın tamamı ölçek 1,3'te koşturuldu → taşma **sıfır**, yani
       tavan+Wrap turu tutmuş) ve sıkışma da değil (bilgi kaybolmuyor,
       okunamaz hâle geliyor). Tavan ÇÖZMÜYOR.
     - **Envanter ÖLÇÜLDÜ** (gerçek fontlarla, 15 sabit genişlikli sütun):
       tavanda 10 nokta sarıyor; **dördü ölçek 1,0'da bile sarıyordu**.
     - **Test verisi de ölçüldü, uydurulmadı** — ilk taslakta "+12" ve
       "1000" gibi imkânsız değerler vardı: `leaguePoints` yalnızca
       -2/0/1/2 döndürüyor (yani k-lig katkısı en fazla iki karakter) ve
       100 taşlık torbayla skor üç hane. Buna karşılık `meanings.json`
       taranınca en çok anlamlı kelimenin **`çıkmak`, 54 anlam** olduğu
       çıktı — yani anlam modalindeki `54.` GERÇEK bir en kötü durum.
     - **Çözüm `ScaledCell`** (`ui/text_scale.dart`): kutu `scaledWidth` ile
       ölçekle büyür + `maxLines:1`/`softWrap:false` + `FittedBox` güvenlik
       ağı. `game_history_modal`'da zaten `softWrap:false` vardı — o sarmayı
       değil KIRPMAYI seçiyordu (bilgi kaybı); ScaledCell ikisini de çözer.
     - **⚠ TESTİN KENDİSİNDE ölçülmüş bir ders:** ilk negatif eş SESSİZCE
       GEÇTİ, çünkü test yanlış katmanı ölçüyordu — `FittedBox` tek başına
       bölünmeyi engelliyor, `scaledWidth`in işi ise metnin KÜÇÜLMEMESİ.
       İki mekanizma, iki ayrı iddia: kapı artık ikisini AYRI ölçüyor
       (bölünme + küçültme) ve negatif eşi gerçekten düşürüyor. Ders: bir
       düzeltme iki mekanizmadan oluşuyorsa negatif eş her ikisini de
       tek tek kaldırarak koşulmalı.
     - **Doğrulama:** 3 yeni test (envanter + negatif eş + GameOver'ın
       GERÇEK render'ı tavan ölçeğinde) + tam takım **696 test yeşil**,
       `dart analyze` temiz. Cihaz listesi: `mobile/TESTING.md` § 25.
       **Doğrulama SINIRI:** sınıf 2 (sessiz sıkışma) bu turda ÖLÇÜLMEDİ;
       web tarafındaki aynı desen (`w-[29px]` vb.) de ölçülmedi — orada
       sistem ölçeği metni büyütmüyor ama tarayıcının "en küçük yazı
       boyutu" ayarı aynı sınıfı doğurabilir.
   - ✅ **Parça 176 — zoom tanıtım balonu (1 Eylül 2026; YENİ dosya
     `test/zoom_hint_test.dart`; değişen: `flags_store.dart`,
     `board_widget.dart`, `game_screen.dart`, `online_game_screen.dart`,
     `setup_screen.dart`):**
     - **Kullanıcı isteği (birebir):** *"Sadece İlk oyun açılışında, açan
       kişide ve karşıdaki kişilerde 1 kereye mahsus bir balon çıksın.
       Tahtanın ortasında bir yerde boş kareye işaret eden bir balon…
       Deneyip büyütenlere bir daha gösterme. Hiç denememişse bir daha
       sefer tekrar göster. Deneme gösterimi bitirir."*
     - **Kural İKİ değere birden bakıyor**, tek bayrak yetmez:
       `zoomHintShown` (kaç açılışta gösterildi, tavan 2) + `zoomTried`
       (bir kez bile zoom yapıldı mı → sayaç ne olursa olsun bir daha
       çıkmaz). Karar tek noktada: `FlagsStore.shouldShowZoomHint`.
       "Gösterim", balonun EKRANA GELMESİDİR — nasıl kapandığı sayacı
       etkilemez; sayaç karar anında artıyor.
     - **Cihaz-yerel bayrak = "açan kişide ve karşıdaki kişilerde"**
       kendiliğinden sağlanıyor: sunucuya bir şey yazılmıyor, her cihaz
       kendi ilk açılışında görüyor.
     - **Balon "Buradan başla"nın kardeşi ama üç farkla:** metin uzun →
       kutu genişliği tahtanın %78'i ve metin sarılıyor; oyuncuya özgü
       değil → renk `kAccent`; hedef ev karesi değil MERKEZ (ipucu
       "herhangi bir boş kare" hakkında). Kuyruk aşağı bakıyor
       (`_HintTailDownPainter` — yataydaki ikiliyi üçe çıkarmak yerine
       ayrı sınıf). Konum yine hücre geometrisiyle (yüzdeyle DEĞİL).
     - **`GameScreen`e `storage` prop'u eklendi** (Canlı ekranda zaten
       vardı) — verilmezse balon hiç çıkmaz, yani testlerin/önizlemelerin
       yolu değişmedi ve `setup_screen.dart`'taki tek satır özelliğin açma
       anahtarı.
     - **Ölçülen tuzak:** `testWidgets` İÇİNDE `AppStorage.open`u beklemek
       testi ASTI (sahte zonda gerçek I/O tamamlanmıyor) — `tester.runAsync`
       ile açıldı. Bu, `mobile/CLAUDE.md`'nin tarama listesindeki
       "await newRepo(" kuralının aynısı; yeni dosya o kurala uyuyor.
     - **Doğrulama:** 6 yeni test (ilk açılış, ikinci açılış, tavan,
       denenmişse hiç, denenince anında kapanma + kalıcı bayrak, storage
       yokken sessizlik) + tam takım **693 test yeşil**, `dart analyze`
       temiz. Cihaz listesi: `mobile/TESTING.md` § 24 → "Tanıtım balonu".
       **Doğrulama SINIRI:** balonun dar telefonda taşıp taşmadığı widget
       testiyle KANITLANMADI — cihaz listesinde ayrı madde.
   - ✅ **Parça 175 — tahta zoom'u: çift dokunuşla 2× büyüt/küçült +
     parmakla pan (1 Eylül 2026; YENİ dosyalar
     `ui/game/board_zoom.dart`, `test/board_zoom_test.dart`; değişen:
     `board_widget.dart`, `game_screen.dart`, `online_game_screen.dart`,
     `pubspec.yaml` → `clock`):**
     - **Kullanıcı isteği (spec, birebir):** *"Sadece board'un içi çift tık
       yapılınca büyüyecek ve board'u elinle sürükleyebiliceksin. Diğer
       bütün alanlar sabit kalacak. Çift tıkla eski haline dönecek. Zoom
       halindeyken taş sürükleme bırakma, tek tıkla taş koyma/geri alma,
       vb mükemmel çalışmalı."* + iterasyonla kilitlenen kararlar:
       (a) *"mevcut tek dokunuşlar aynen kalmalı"* — tek dokunuş
       GECİKTİRİLMEZ (Flutter'ın `onDoubleTap`'i her tek dokunuşa ~300 ms
       ekler → reddedildi, elle algılayıcı yazıldı); (b) çiftin İKİNCİ
       dokunuşu yutulur, İLKİNİN yaptığı iş — koyulan taş dahil —
       OLDUĞU GİBİ KALIR: *"taşı geri almadan, koyduğu yerde bırakarak
       zoomlamak lazım."* Çift yalnızca BOŞ kareye dokunuşla başlar; taşa
       dokunuş (taslak geri alma / onaylı anlam penceresi) çift
       BAŞLATAMAZ ama İKİNCİ dokunuş olarak yutulabilir — ilk dokunuş
       taşı koyduysa parmağın altındaki hücre artık boş değildir, ikinci
       vuruş o taşı geri almasın.
     - **DÜZELTME DERSİ (aynı gün, kullanıcı reddetti):** ilk sürüm
       "dokunuş-1'in etkisini GERİ SAR" (`ZoomTapEffect` kayıtları +
       `applyZoomTapUndo`) ve "joker penceresini ~330 ms ERTELE"
       (`deferModal`) mekanizmalarını taşıyordu — kullanıcı ikisini de
       gereksiz buldu: *"taşı geri almadan, koyduğu yerde bırakarak"* ve
       *"joker tablosu... Bunun zoom olayıyla ne ilgisi var."* İkisi de
       SİLİNDİ; joker penceresi eskisi gibi ANINDA açılır (pencere
       açıkken ikinci dokunuş zaten tahtaya değil pencereye düşer) ve
       `game_screen_test.dart` origin/main ile BAYT BAYT aynıya döndü —
       "tek dokunuşlar aynen kaldı" iddiasının kanıtı. Tek kabul edilen
       davranış farkı: koyduktan sonra 300 ms İÇİNDE aynı noktaya ikinci
       dokunuş artık tanım gereği çift dokunuştur (geri alma değil zoom);
       koy→geri-al dizen dört test bu yüzden araya gerçekçi bir 350 ms
       koydu. Ders: bir jest özelliği eklerken "durumu bozmamak" için
       kurulan telafi mekanizması, kullanıcının zihinsel modelinden daha
       karmaşıksa muhtemelen yanlış katmandadır — önce sor.
     - **Mimari: layout değil PAINT matrisi** — `Transform` +
       `ClipRect` (görünür kare). `RenderBox.globalToLocal` ata
       transform'ları kendisi tersine çevirdiğinden mevcut stride
       matematiği (`_cellAtGlobal`, `_nearbyDraftCell`) DEĞİŞMEDEN doğru
       kaldı — backlog'un "koordinat çevrimi bozulur" endişesi bu yolla
       kökten çözüldü; widget testi bunu kanıtlıyor ("zoom altında
       sürükle-bırak nişan alınan hücreye iner").
     - **Ölçülen tuzak — görünmez hücre:** zoom'luyken rafın üstündeki bir
       nokta ters transform'da SANAL ızgara sınırları içine düşüyor; kapı
       (`_cellAtGlobal`'ın ClipRect kutusu kontrolü) olmasa rafa bırakılan
       taslak "görünmez bir hücreye" iner, rafa dönemezdi. Kapı + testi
       (`board_zoom_test` "RAFA sürüklemek") birlikte girdi.
     - **Ölçülen tuzak — `DateTime.now()` sahte saatte İLERLEMEZ:** çift
       dokunuş penceresi önce `DateTime.now()` ile yazıldı; `flutter test`
       ortamında `tester.pump` sahte saati ilerlettiği hâlde gerçek saat
       milisaniyeler içinde kaldığından üçüncü dokunuş ikinciyle
       "çift" sayılıp joker penceresini yuttu (GERÇEK test düşüşü).
       Çözüm `package:clock` → `clock.now()` (fake_async'e uyar);
       pubspec'e `clock: ^1.1.1` bu gerekçeyle girdi.
     - **Ölçülen tuzak — test tarafında iki düşüş:** (1)
       `TweenAnimationBuilder` hedefi pump edilen KAREDE değişir ve
       animasyon o karede t=0'dan başlar — tek `pump(100ms)` 180 ms'lik
       kapanışın ortasında (scale 1.0924) assert ediyordu; `doubleTapAt`
       artık pencereyi VE animasyon süresini ayrı ayrı ilerletiyor. (2)
       odak (3,3)'te offset −96 px ve hücre (1,1)'in MERKEZİ görünür
       karenin soluna taşıyor (ölçüldü: LTRB(-13.6, 62.4, …)) — dokunuş
       kırpılmış alana düşüp taşı hiç tutamıyordu; test odağı (0,0)'a
       alındı. Ders: zoom'lu bir testte `getCenter` transform SONRASI
       konumu verir ama o noktanın ClipRect İÇİNDE olduğunu ayrıca
       düşünmek gerekir.
     - **Jest ayrımı:** pan ham `Listener`'la (ev deseni, jest arenası
       yok); hit-test sırası çocuk→ata olduğundan taş sürüklemesi
       `_dragRef`i pan'den ÖNCE doldurur, doluysa pan hiç başlamaz. Pan
       bitince 120 ms'lik dokunuş-yutma penceresi (bayrak değil süre —
       ghost-click dersi: 10-18 px'lik pan'ler compat dokunuşu hâlâ
       üretir). ONAYLI taş zoom'a hiç karışmaz (anlam penceresi anında).
     - **Perf:** `AnimatedBuilder` prebuilt `child` ile — 169 hücre pan
       sırasında YENİDEN İNŞA EDİLMEZ (Parça 23 kuralı);
       `RepaintBoundary` bilinçli YOK (2×'te metin vektör-keskin
       kalmalı; blur'lar zaten NeoBox raster önbelleğinde).
     - **İki ekran birden** (`game_screen` ↔ `online_game_screen`) aynı
       PR'da, paylaşılan desen kuralı gereği. **Web'de karşılığı YOK ve bu
       BİLİNÇLİ bir port farkı** (backlog'daki "karar verilmeli" sorusunun
       cevabı): masaüstünde tarayıcı zoom'u var, dokunmatik web kitlesi
       küçük; istek mobil testçiden geldi.
     - **İKİNCİ APK TURU (aynı gün) — cihazda bulunan iki bulgu:**
       (1) *"Bölge çizgisi kenarlarda inceliyor"* — dış hat stroke'u (2.5)
       yolun merkezinde çizildiğinden ızgara kutusunun dışına yarım
       kalınlık taşıyor; zoom'dan önce kırpma OLMADIĞI için taşma 10 px'lik
       dolguya çiziliyordu, ClipRect tam kutudan kırpınca kenar çizgisi
       yarıya indi. Düzeltme: `_ZoomClipSlackClipper` — görünür kare
       zoom'lu taşmayı (2.5·2/2 + AA = 3.5 px) kapsayacak kadar payla
       kırpar; bedeli zoom'da kenarın 3.5 px geç kesilmesi (seçilemiyor).
       (2) *"Zoom sadece karelerde çalışıyor, kenarlar da dahil olmalı"* —
       dokunma yüzeyi yalnızca hücre GestureDetector'larıydı; Listener
       10 px'lik dolgunun DIŞINA taşındı (Padding artık `_zoomWrap`ın
       içinde) ve ekranlar hücre kutusuna DÜŞMEYEN dokunuşları
       (`_pointHitsCellBox` — boşluk/çerçeve) tahta dokunuşu sayıyor.
       ⚠ Ölçülen tuzak: karar İNİŞ noktasına göre verilmeli — parmak
       hücrede inip boşlukta kalkarsa hücre tanıyıcısı YİNE ateşler;
       kalkışa bakan ilk taslak aynı jesti İKİ kez sayıp tek dokunuşu
       "çift" yapardı (testi: "hücreye inen dokunuş tahta dinleyicisinde
       SAYILMAZ").
     - **ÜÇÜNCÜ APK TURU (aynı gün) — kırpmanın ikinci kurbanı:** kullanıcı
       *"kenarda kalan deneme sayıları kesiliyor"* dedi (iki telefonun yan
       yana fotoğrafı: yayındaki 1.0.4'te `+6` rozeti tam, test
       derlemesinde `+7`nin sol kenarı düz kesik). Sebep bir önceki turun
       payı DEĞİL, kırpmanın KAPSAMI: hamle rozeti `FractionalTranslation
       (-0.35,-0.35)` ile ızgara kutusunun ~10 px dışına taşıyor (zoom'da
       ~22 px) ve ClipRect'in İÇİNDEYDİ. Pay büyütmek yanlış çözüm olurdu —
       aynı pay kadar zoom'lu ızgara da taşıp kartın gövdesine sızardı.
       **Düzeltme:** `_zoomWrap` artık bir `unclipped` katmanı alıyor;
       rozet ızgarayla AYNI matrisi (tek tween — ikiye bölmek animasyon
       boyunca ayrıştırırdı) ama kırpmayı ALMIYOR. Ders: bir ağaca kırpma
       eklerken "kutunun dışına bilerek taşan" her katmanı say — bu tahtada
       ikisi vardı (dış hat çizgisi ve rozet), ilk turda yalnız biri
       görüldü. Testi YAPISAL (piksel değil): rozetin üstünde kırpıcılı
       ClipRect bulunmamalı + rozet gerçekten ızgaranın dışına taşmalı;
       negatif eşi koşuldu (rozet kırpmanın içine alınınca test düşüyor).
     - **Doğrulama:** 20 yeni test (`board_zoom_test.dart`: 3 birim +
       17 widget) + tam takım **687 test yeşil**, `dart analyze` temiz
       (tek info main'de de olan eski `tap_target_test` satırı).
       **Doğrulama SINIRI:** widget testleri cihaz hissini (çift dokunuş
       ritmi, pan akıcılığı, gerçek parmakla ıskalama) KANITLAMAZ —
       kullanıcı kararı: *"Bunu apk ile test edip sorunsuz olduğundan emin
       olmadan aab yapılmayacak."* Cihaz listesi: `mobile/TESTING.md`
       § 24.
