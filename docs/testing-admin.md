# Elle test — Admin paneli

> `TESTING.md`'nin 9.7-9.15 arası bölümleri. 26 Ağustos 2026'da o dosya
> 124 KB ile uyarı bandına girdiği için buraya taşındı (kök `CLAUDE.md` →
> "Doküman Boyutu Bütçesi"). **Hiçbir madde değişmedi**, bölüm numaraları
> da korundu — atıflar kırılmasın diye.
>
> **Neden bu blok:** hepsi yalnızca admin hesabıyla, çoğu canlı veriyle
> koşuluyor; `TESTING.md`'de kalan listenin tamamı normal bir kullanıcı
> hesabıyla koşulabiliyor. Kesme noktası boyut değil, KİMİN koştuğu.
>
> **Kararların kendisi burada DEĞİL** — "neden bu metrik, tanımı ne"
> soruları `docs/decisions/admin-panel.md`'de. Burası yalnızca kontrol
> listesi.
>
> ⚠ Yeni bir admin paneli kontrolü BURAYA yazılır; kök `TESTING.md`'ye değil.

## 9.7. Admin — Aktif Oyuncu / Aktivasyon / Retention (14 Ağustos 2026)

Üç panel Büyüme > Kullanıcı'ya eklendi. Üç RPC de canlıda gerçek admin
JWT'siyle koşuldu (yetki matrisi dahil); aşağıdakiler yalnızca gerçek
tarayıcıda görülebilecek olanlar. **Admin hesabı gerekiyor.**

- [ ] **Üçü de yükleniyor.** Admin Paneli → Büyüme → Kullanıcı: "Yeni Üye /
      Ziyaret"in altında sırasıyla **Aktif Oyuncu** grafiği, **Aktivasyon**
      (4 kutu), **Retention** tablosu görünmeli. Hiçbiri "Yükleniyor…"da
      asılı kalmamalı.
- [ ] **Aktivasyonun 3. ve 4. kutusu bir HUNİ okumalı** (9 Eylül 2026): "İlk
      Saatte Aktive" ≤ "24 Saatte Aktive" ≤ aktive üye sayısı. İlki ikincisini
      GEÇİYORSA sayım hatası vardır. Dağılım satırındaki üçlü ise AYRIK:
      24 saatte + 1-3 gün + sonra = aktive üye sayısı. Kutuda artık medyan
      YOK — çift tepeli dağılımda gözlem olmayan bir boşluğa düşüyordu.
- [ ] **Aktif Oyuncu grafiği iki seri gösteriyor** ("Aktif Oyuncu (28 gün)"
      mavi, "Dönem İçi Aktif" amber) ve legend'dan tek tek açılıp
      kapanabiliyor. Tanım artık altta paragraf DEĞİL: "CSV İndir"in solundaki
      `?` rozetine dokun → popup'ta "…bu sayı bilerek MAU değil" cümlesi
      çıkmalı (17 Ağustos 2026'da taşındı).
- [ ] **Periyot/granülerlik kontrolü grafiği GERÇEKTEN değiştiriyor.**
      Üstteki periyot kombosunu değiştir: Aktif Oyuncu grafiği de yeniden
      çekilmeli (Yeni Üye/Ziyaret ile aynı kontrolleri paylaşıyor).
      **Aktivasyon ve Retention DEĞİŞMEMELİ** — ikisi bilerek periyoda bağlı
      değil (kohortun ekseni kayıt haftası, aktivasyon tüm zamanların oranı).
- [ ] **Retention tablosu üçgen görünmeli.** En yeni kohort ÜSTTE; sağ üst
      köşe boş (penceresi tamamlanmamış haftalar hiç çizilmiyor). Bir hücrenin
      üstüne gel → "3/10 üye aktif" gibi bir ipucu çıkmalı.
- [ ] **Hücre yazısı HER tonda okunabilir olmalı** — en koyu hücrede bile
      (%100'e yakın oran) rakam net görünmeli. Ton yalnızca ikincil işaret;
      oran zaten sayıyla yazıyor.
- [ ] **CSV'ler ham sayı veriyor.** Retention'da "CSV İndir" → dosyada yüzde
      DEĞİL aktif üye SAYILARI ve bir "Üye" (payda) sütunu olmalı.
- [ ] **NEGATİF EŞİ ŞART — admin olmayan hesap.** Sıradan bir hesapla giriş
      yap: "Admin Paneli" menü satırı HİÇ görünmemeli. (RPC'ler sunucuda
      ayrıca `Yetkisiz erişim.` fırlatıyor, ama UI'ın da sızdırmadığı
      görülmeli.)

> **Sayıları okurken:** 23 hesabın 4'ü test hesabı ve 325 oyunun 27'si
> onlara ait — bunları eleyen bir bayrak YOK (kullanıcı kararı: test verisi
> sonradan silinecek). Bu ölçekte kohort eğrileri gürültüdür; buradaki amaç
> enstrümantasyonun ÇALIŞTIĞINI doğrulamak, eğrileri yorumlamak değil.

## 9.8. Admin — Platform dökümü (14 Ağustos 2026) — **PARK EDİLDİ**

> **TABLO 15 Ağustos 2026'da PANELDEN KALDIRILDI** (kullanıcı kararı: bugün
> karar verdirecek bir şey söylemiyor, uygulamalar mağazaya çıkınca
> web/iOS/Android/diğer olarak yeniden yapılandırılacak). **Veri toplanmaya
> DEVAM EDİYOR** (`games.platform` + `online_game_clients`).
>
> Aşağıdaki UI maddeleri bilerek **kutusuz** — bugün koşulacak bir iş
> DEĞİLLER, tablo geri geldiğinde çevrilecek bir taslaktırlar. Doğrulama o
> güne kadar SQL'den yapılır. Bu bölümdeki tek KOŞULABİLİR madde en alttaki
> gizlilik metni kontrolü (veri toplandığı sürece geçerli).

**Tablo geri geldiğinde koşulacaklar (bugün DEĞİL):**

- **Tablo yükleniyor.** Admin Paneli → Büyüme → Kullanıcı: "Cihaz"ın
  hemen altında **Platform** tablosu (Platform / Oyun / Oyuncu / %).
  "Cihaz"dan farkı ekranda yazmalı — 17 Ağustos 2026'dan beri tablonun
  altındaki paragrafta değil, "CSV İndir"in solundaki `?` popup'ında
  (bkz. 9.11), yani tablo geri gelirken `HINTS`e kendi girdisi de eklenmeli.
- **Web'den oynanan yeni bir oyun `Web` satırına düşüyor.** kelimeki.com'da
  girişliyken bir YZ oyunu BİTİR (yarıda bırakma — satır ancak oyun
  bitince yazılıyor), sonra paneli aç: `Web` satırının "Oyun" sayısı 1
  artmalı. Toplam da artmalı, `Bilinmiyor` DEĞİŞMEMELİ.
- **Uygulamadan oynanan oyun `iOS`/`Android` satırına düşüyor.** Aynı
  şeyi mobil uygulamada yap (GitHub Pages web derlemesinde `App (Tarayıcı)`
  satırına düşer — o da doğru davranış, uygulamanın tarayıcıdaki hâli).
- **Canlı oyun da sayılıyor.** İki hesapla bir Canlı oyunu SONUNA kadar
  bitir; her katılımcı KENDİ oynadığı istemcinin satırına düşmeli (biri
  web'den biri app'ten oynadıysa iki farklı satır).
- **"Bilinmiyor" satırı GİZLENMEMELİ.** Kolon 14 Ağustos 2026'da eklendi;
  öncesinde biten ~300 oyun orada toplanıyor. Satırı görmüyorsan tablo
  yanlış filtreliyor demektir — yüzdeler de yalancı olur.
- **CSV İndir** çalışmalı; dosyada Platform/Oyun/Oyuncu/% sütunları ve bir
  TOPLAM satırı olmalı.

**Bugün koşulabilir:**

- [ ] **Gizlilik metni güncel.** Gizlilik Politikası → "Toplanan Veriler"de
      "Bir oyunu hangi istemciden oynadığınız…" maddesi olmalı (mobil
      uygulamadaki metin de AYNI). Tablo panelde olmasa da veri
      toplandığından bu madde metinde KALMALI.

## 9.9. Admin — Kaynak Hunisi (16 Ağustos 2026)

"Ziyaretçi Kaynağı" tablosunun yerini aldı: kaynak → **Kişi** → **Başlayan**
→ **Üye** → **Oyun**. İlk sütun eskisiyle aynı sayı. Sunucu tarafı canlıda
rollback'li senaryolarla doğrulandı (yetki matrisi, damgalama, write-once
trigger, toplamların korunması); aşağıdakiler gerçek istemcide görülmesi
gerekenler.

- [ ] **"Başlayan" sütunu gerçekten sayıyor (21 Ağustos 2026, ROADMAP #9).**
      Misafirken (çıkış yapıp) yapay zekaya karşı bir oyun BAŞLAT, hemen
      logoya basıp çık — bitirmene gerek YOK. Admin panelinde Kaynak
      Hunisi'nde o cihazın kaynağının (`?ref=` ile gelmediysen `direkt`)
      "Başlayan" değeri 1 ARTMALI, "Oyun" değeri DEĞİŞMEMELİ. Bu ayrım işin
      bütün sebebi: "Oyun" yalnızca BİTMİŞ ve yalnızca GİRİŞLİ kullanıcının
      oyununu sayıyor.
- [ ] **Aynı cihazda ikinci oyun: Oyun görünümünde "Başlayan Oyun" 2, Kişi
      görünümünde "Başlatan" 1 kalmalı** (24 Eylül 2026'dan beri iki görünüm
      var; eskiden bu `%` modunun işiydi). "Oyun / Kişi" o satırda 2.0 olmalı.
- [ ] **"Tekrar Oyna" da bir başlangıçtır.** Bir oyunu bitirip kartın
      altındaki "Tekrar Oyna"ya bas → "Başlayan" yine artmalı. (Web'de her
      iki yol da tek bir `startLocalGame` yardımcısından geçiyor; portta iki
      ekran da `GamesRepo.logStart` çağırıyor.)
- [ ] **Devam eden oyuna DÖNMEK bir başlangıç DEĞİL.** Yarım bırakılmış bir
      oyunu "Devam Eden Oyun" satırından sürdür → "Başlayan" ARTMAMALI.
      Artıyorsa aynı oyun her oturum dönüşünde tekrar sayılıyor demektir.
- [ ] **"Bitiren" KİŞİ sayar (31 Ağustos 2026 cihaz kodu, 24 Eylül 2026 sütun).**
      MİSAFİRKEN bir YZ oyununu BİTİR → Kişi görünümünde "Bitiren" 1 artmalı.
      Aynı cihazda ikinci bir oyunu daha bitir → Oyun görünümünde "Biten Oyun"
      2 olmalı, Kişi görünümünde "Bitiren" DEĞİŞMEMELİ (cihaz hâlâ 1).
- [ ] ⚠ **Oyun VAR ama "Başlatan"/"Bitiren" "—" ise bu DOĞRU davranış.**
      Cihaz kodu bitmiş tarafa 31 Ağustos 2026'da eklendi ve geriye dönük
      doldurulamaz; mobil uygulama da iki tarafa henüz yazmıyor (bugün `app`
      satırı: 73 oyun, 0 cihaz). "0" yazmak "kimse oynamadı" derdi. Oyun da 0
      ise hücre gerçekten 0 yazar.
- [ ] **CSV'de "Bitiren Cihaz" sütunu var** ve ham sayı veriyor; "Biten Oyun"
      sütunundan küçük ya da ona eşit olmalı (büyükse bir şey yanlıştır).
- [ ] **GİZLİLİK — girişliyken bitirilen oyunda cihaz kodu YAZILMAMALI.**
      Giriş yapıp bir YZ oyunu bitir → `game_finishes` satırında `user_id`
      dolu, `anon_id` NULL olmalı. Sunucu bunu iki katmanda zorluyor (BEFORE
      INSERT trigger sessizce NULL'a çeker, CHECK kısıtı da değişmezi
      kanıtlar), yani bu kontrol istemcinin yanlış davranışını değil
      taahhüdün ayakta olduğunu sınıyor. Gizlilik metninin 6. bölümü tam
      olarak bunu söylüyor.

- [ ] **Tablo yükleniyor ve zaman filtresine bağlı.** Admin Paneli → Büyüme →
      Kullanıcı: "Kaynak Hunisi (Son N …)" başlığı üstteki granülerlik/periyot
      seçimini takip etmeli; seçim değişince sayılar değişmeli.
- [ ] **Bugünkü beklenen tablo — İKİ satır: `direkt` ve `arkadas`.**
      "Bilinmiyor" satırı OLMAMALI: 16 Ağustos 2026'da damgalama öncesi 23
      üyeden 22'si `arkadas`, hesap sahibi ise `direkt` olarak dolduruldu
      (hesap sahibinin bilgisi: o tarihe kadar üyelerin tamamı davetle geldi,
      kendisi hariç). Bilinmiyor ancak
      damgalamayan bir istemciden (bugün: mobil uygulama) kayıt gelirse
      yeniden belirir.
- [ ] **Davet linki `?ref=arkadas` taşıyor VE yakalanıyor (21 Ağustos 2026,
      ROADMAP #7).** Arkadaşlar → "Arkadaşını Davet Et" ile link üret;
      URL'in sonunda `?ref=arkadas` OLMALI. Sonra o linki **temiz bir
      tarayıcıda** (gizli sekme) aç ve devtools'ta
      `localStorage.getItem('kelimeki:utm-source')` → **`"arkadas"`**
      dönmeli. `null` dönüyorsa etiket konuyor ama yakalanmıyor demektir —
      hata tam olarak buydu ve `boot.tsx`te düzeltildi.
      **Not:** bu, `arkadas` satırının eski "%100 dönüşüm"ünü de anlamlı
      hale getiriyor; o rakam bu düzeltmeden ÖNCE bir ölçüm değil tesadüftü
      (iki uç aynı popülasyonu ölçmüyordu).
- [ ] **`direkt` satırında tam 1 üye olmalı (hesap sahibi).** Projeyi kuran
      hesap kimse tarafından davet edilmedi; geri kalan 22 üye `arkadas`.
- [ ] **Yeni bir kayıt kaynağını damgalıyor.** Gizli sekmede
      `kelimeki.com/?ref=instagram` aç, sonra ORADAN üye ol → panelde
      `instagram` satırı belirmeli, "Üye" 1 olmalı. Aynı hesapla bir oyun
      bitir → aynı satırın "Oyun"u 1 olmalı.
- [ ] **`?ref=` olmadan üye olan `Direkt`e düşmeli** (Bilinmiyor'a DEĞİL) —
      ikisi bilinçli olarak ayrı: Bilinmiyor = damgalanmamış (eski üyeler ve
      mobil uygulama kayıtları).
- [ ] **İlk temas kazanır.** Önce `?ref=instagram` ile gel, sonra siteyi
      `?ref=` olmadan (ya da başka bir ref ile) tekrar aç ve ANCAK O ZAMAN üye
      ol → kaynak hâlâ `instagram` olmalı.
- [ ] **TOPLAM satırı tutuyor mu.** Üç sütunun toplamı, satırların toplamına
      eşit olmalı; "Üye" toplamı o dönemdeki yeni üye sayısıyla (Yeni Üye/Ziyaret
      grafiği) tutarlı olmalı.
- [ ] **`Kişi / Oyun` düğmesi dönüşümlü çalışmalı (24 Eylül 2026 — eski `% /
      Sayı` düğmesinin yerine).** Tablonun sağ üstünde, "CSV İndir"in
      yanında. Kişi → sütunlar Gelen · Üye · Başlatan · Bitiren; bas → Başlayan
      Oyun · Biten Oyun · Oyun / Kişi; tekrar bas → geri. Aktif görünüm her
      zaman vurgulu olmalı. İki birim (kişi ↔ oyun) AYNI ekranda yan yana
      GÖRÜNMEMELİ — tablonun yeniden yapılmasının sebebi buydu.
- [ ] **Kişi görünümünde yüzdenin tabanı HER sütunda o satırın "Gelen"i.**
      Doğrulaması kolay: gelen=260, başlatan=29 olan bir satırda "Başlatan"ın
      yanında **11.2%**, bitiren=4 ise "Bitiren"in yanında **1.5%** yazmalı.
      Bir sütunun yüzdesi solundakinden büyükse (Üye hariç — ayrı ölçüm) bir
      şey yanlıştır.
- [ ] **Gelen = 0 olan satırda yüzde YAZILMAZ** (yalnızca sayı; `app` satırı
      bugün böyle — port ziyaret kaydetmiyor).
- [ ] **CSV görünümden bağımsız.** Hangi görünümde olursan ol "CSV İndir" →
      dosyada bütün ham sayılar (oyun VE cihaz sütunları) olmalı.
- [ ] **CSV İndir** çalışmalı; dosyada Kaynak/Kişi/Üye/Oyun/**Oynayan Kişi**
      sütunları ve bir TOPLAM satırı olmalı.
- [ ] **`?` popup'ı okunuyor mu.** Tanım artık tablonun altında paragraf
      DEĞİL — "CSV İndir"in sağındaki `?` rozetine dokun: popup "Kişi"/"Üye"/
      "Oyun" tanımlarını, kohort OLMADIĞINI, Bilinmiyor/Direkt farkını ve
      oranın %100'ü aşabileceğini anlatmalı. Bu tablo bu not olmadan kolayca
      yanlış okunur.
- [ ] **Gizlilik metni güncel.** Gizlilik Politikası → "Toplanan Veriler"de
      kaynak etiketi maddesi olmalı ve "Son güncelleme: 16 Ağustos 2026"
      yazmalı (mobil uygulamadaki metin de AYNI).

## 9.10. Admin — Oyun Süresi (Medyan) + YZ Dengesi (16 Ağustos 2026)

İki değişiklik: süre grafiği ORTALAMADAN medyana geçti (+ p90 serisi) ve
Büyüme > Oyun'a yeni bir "YZ Dengesi" paneli eklendi. Sunucu tarafı canlıda
gerçek admin JWT'siyle doğrulandı (yetki matrisi, dönen değerlerin bağımsız
ölçümle birebir eşleşmesi); aşağıdakiler gerçek istemcide görülmesi
gerekenler.

> ⚠ **16 Eylül 2026: süre artık GRAFİK DEĞİL, dört KUTU.** Aşağıdaki
> legend/eğri/CSV maddeleri o tarihten itibaren GEÇERSİZ; güncel liste
> **9.17**'de. Bölüm, atıflar kırılmasın diye olduğu gibi bırakıldı (dosyanın
> kendi kuralı) — medyan/p90 ve kaynak filtresi maddeleri kutularda da
> geçerli, yalnızca "grafikte" diyen cümleleri "kutuda" diye oku.

- [ ] ~~**Grafik başlığı "Oyun Süresi (Medyan)" olmalı** — "Ortalama Oyun
      Süresi" YAZMAMALI. Legend'da üç seri açık (**Genel**, **Tek Oturumda**,
      **Günlere Yayılan**) + **Uzun kuyruk (p90)** KAPALI gelmeli.~~
      (16 Eyl 2026: legend yok, dört kutu — bkz. 9.17)
- [ ] **Sayı gerçekten düştü mü.** Yerel/tek oturum kovasında değer saatler
      değil DAKİKALAR mertebesinde olmalı (ölçüm anında ~18 dk; eski ortalama
      ~247 dk gösteriyordu). Saatlerce süren bir değer görürsen ortalamaya
      geri dönülmüş demektir.
- [ ] **p90 legend'ı açılınca medyanın belirgin ÜSTÜNDE bir eğri çizmeli**
      (kuyruk gerçek: ölçüm anında 49 oyun 1 saatten, 7 oyun 1 günden uzundu).
      p90 medyanın altında çıkıyorsa seriler karışmış demektir.
- [ ] **Hiç biten oyunu olmayan kovada süre 0 DEĞİL, boş olmalı** (grafikte
      nokta yok / tabloda "—"). 0 dakika "çok hızlı bitmiş oyun" gibi okunur.
- [ ] **Kaynak filtresi hâlâ çalışıyor.** Toplam / Canlı / Yapay Zeka arasında
      geçiş yapınca süre değerleri değişmeli; "Toplam", iki kaynağın ham
      sürelerinin TEK bir medyanı olmalı (iki medyanın ortalaması DEĞİL —
      Toplam genelde iki kaynağın arasında bir yerde çıkar, ikisinin tam
      ortasında değil).
- [ ] **CSV İndir** çalışmalı; başlıkta ortalama değil medyan/p90 sütunları
      olmalı.
- [ ] **YZ Dengesi paneli görünüyor.** Büyüme > Oyun'un üst kısmında, beğeni/
      paylaşma kutularının altında **ÜÇ** kutu: "2 Kişilik — İnsan Birincilik",
      "4 Kişilik — İnsan Birincilik" ve "4 Kişilik — İnsan İkincilik"
      (üçüncüsü 17 Ağustos 2026'da eklendi).
- [ ] **Seviye kırılımı henüz GÖRÜNMEZ olmalı (6 Eylül 2026, ROADMAP #23 Faz 1).**
      `admin_ai_balance` artık `(oyuncu sayısı, seviye)` başına satır döndürüyor
      ama bugün tüm kayıtlar seviyesiz (= Normal), yani kutular YİNE üç ve
      etiketlerde " · Kolay"/" · Zor" eki YOK. Ek çıkıyorsa seviye yazan bir
      kayıt var demektir — Faz 3'ten önce bu bir hata. Faz 3 canlıya
      çıkınca Kolay'da biten ilk oyun "2 Kişilik · Kolay — İnsan Birincilik"
      kutusunu AÇMALI, Normal kutusunun sayıları DEĞİŞMEMELİ.
- [ ] **2 kişilikte İKİNCİLİK kutusu OLMAMALI.** Orada rank=2 kaybetmenin
      kendisi (canlıda ölçüldü: ikincilik sayısı = kayıp sayısı) ve k-lig
      puanı getirmiyor — kutu çıkıyorsa filtre atlanmış demektir.
- [ ] **Her kutuda rastgele referansı YAZMALI** — 2 kişilikte "rastgele %50",
      4 kişilikte "rastgele %25" (ikincilik kutusunda da %25: rastgele bir
      sonuçta 1. olmak da 2. olmak da aynı olasılıkta). Bu satır olmadan
      4 kişilikteki düşük yüzde yanlış okunur.
- [ ] **Sayılar tutarlı mı.** Birincilik kutusundaki `NG / NB / NM` toplamı,
      o oyuncu sayısındaki teslimsiz yerel oyun sayısına eşit olmalı; yüzde =
      G / (G+B+M). İkincilik kutusundaki `N/M`nin paydası (M) aynı sayı
      olmalı — iki kutu AYNI oyun kümesini bölüyor.
- [ ] **Üç kutu aynı yükseklikte ve taşmıyor.** Telefonda etiketler 2-3
      satıra sarabilir, bu normal; kutular birbirinden farklı boyda olmamalı
      ve sayfa YANA kaymamalı.
- [ ] **`?` popup'ı toplamı anlatmalı.** Başlığın yanındaki `?`: metin,
      asıl denge sayısının birincilik + ikincilik TOPLAMI olduğunu ve
      rastgele karşılığının %50 olduğunu söylemeli. (Ölçüm anında 4 kişilik:
      %31 + %18 = %49-50 bandı, yani neredeyse tam rastgele.)
- [ ] **Teslim olunan oyunlar sayılmamalı.** 7 günlük terk cezası almış bir
      oyun (bkz. bölüm 4) bu panelde ne "M" ne toplam sayıya girmeli — süre
      aşımıyla biten bir oyundan sonra sayılar DEĞİŞMEMELİ.
- [ ] **Canlı oyunlar sayılmamalı.** Bir Canlı oyun bitir → YZ Dengesi
      sayıları değişmemeli (panel yalnızca Yapay Zeka'ya karşı oynananları
      kapsıyor).
- [ ] **Hiç yerel oyun yokken** panel "Henüz Yapay Zeka'ya karşı tamamlanmış
      oyun yok." demeli — boş kutular ya da "%0" DEĞİL.
- [ ] **Admin olmayan hesap panele hiç giremiyor** (menüde "Admin Paneli"
      satırı yok) — bu iki RPC de admin dışına kapalı.
- [ ] **YZ güçlendi: 2 kişilik birincilik oranı ZAMANLA DÜŞMELİ
      (17 Ağustos 2026, bkz. `mobile/CLAUDE.md` Parça 109).** YZ'nin
      sağ-alt köşedeki ilk hamle kısıtı kaldırıldı — 2 kişilikte YZ HER
      ZAMAN o köşede olduğundan bu panel, düzeltmenin gerçek oyunlarda
      işe yarayıp yaramadığını gösteren TEK ölçüm. Düzeltme öncesi değer
      **%57** (95/167) idi; bundan sonra bitirilen oyunlarda oranın
      rastgeleye (%50) doğru inmesi BEKLENEN davranış, regresyon DEĞİL.
      **Panel kümülatif olduğundan tek bir oyunla okunmaz** — 20-30 yeni
      oyun birikene kadar sayıya bakıp karar verme. 4 kişilik kutular bu
      değişiklikten çok daha az etkilenir (orada YZ koltuklarının yalnızca
      biri köşe 3'te).

## 9.11. Admin — metrik tanımı `?` rozetleri (17 Ağustos 2026)

Grafik/tablo altındaki uzun açıklama paragrafları kaldırılıp tek bir popup'a
taşındı. Ekranda kalan tek "açıklama" aktivasyonun DAĞILIM satırı — o bir
açıklama değil veri.

- [ ] **Her CSV'nin yanında bir `?` var.** `?` her zaman "CSV İndir"in
      SOLUNDA. ⚠ **Sayı 16 Eylül 2026'da değişti:** üç grafik (Arkadaşlık,
      Oyun Süresi, Beğeni/Paylaşma) kaldırıldı, rozetleri BAŞLIĞIN YANINA
      geçti — güncel döküm 9.17'de.
- [ ] **CSV'si olmayan panellerde `?` başlığın yanında.** Bu paneller CSV'ye
      bağlansaydı açıklamaları kaybolurdu. Her rozetin `HINTS`te kendi metni
      var, ikisi aynı metni göstermemeli.
- [ ] **`?` bir DAİRE, elips değil** ve bulunduğu satırı büyütmemeli — kontrol
      satırının yüksekliği "CSV İndir"in tek başına olduğu hâlle aynı kalmalı.
- [ ] **Popup açılıyor ve kapanıyor.** Dokun → başlık + metin; "Kapat" ve
      Escape kapatmalı. Panelin kendisi kapanMAMALI (iç içe dialog).
- [ ] **Veri YOKKEN de `?` görünmeli.** Periyodu hiç veri olmayan bir aralığa
      çek (ör. en kısa periyot + boş bir kova): tablo "Bu aralıkta veri yok."
      derken `?` hâlâ orada olmalı — "bu grafik neyi sayıyor?" sorusu tam da
      o anda sorulur. (CSV'nin kaybolması BEKLENEN: indirilecek satır yok.)
- [ ] **Aktivasyonun dağılım satırı EKRANDA kalmalı** ("İlk oyununu bitirme
      dağılımı — 24 saatte: N · 1-3 gün: N · sonra: N · medyan: N"). Bu veri,
      popup'a taşınMAMALI; popup yalnızca tanımları anlatmalı. Medyan 9 Eylül
      2026'da kutudan BU satıra indi (gerekçesi 9.7'de).
- [ ] **Uzun metin taşmıyor.** "Kaynak Hunisi" popup'ı en uzunu — telefonda
      kart ekrana sığmalı, sığmıyorsa kartın KENDİSİ kaydırılabilmeli (panel
      değil).
- [ ] **Hiçbir grafiğin altında artık hikaye paragrafı YOK.**

## 9.13. Admin — Üyeler tablosundaki kayıt alanları (21 Ağustos 2026)

Tablo artık kayıt formunun tüm alanlarını ve izinleri taşıyor (18 kolon).

- [ ] **Tablo yana kaydırılıyor, SAYFA kaymıyor.** Kaydırma tablonun kendi
      kabında kalmalı; panelin kendisi ya da arka plan yatay kaymamalı.
- [ ] **İsim kolonu SABİT.** Sağa doğru kaydır: İsim hem başlıkta hem her
      satırda solda kalmalı, altından geçen içerik onun İÇİNDEN görünmemeli
      (zemin opak) ve sağ kenarında ince bir ayraç çizgisi olmalı.
- [ ] **Sabit hücre satırın tonunu ALIYOR.** Bir şikayet kartından "Kişiye
      Git →" ile gel: vurgulanan satırın İSİM hücresi de mavi tonlanmalı,
      beyaz kalmamalı. (Farede: satırın üstüne gelince hover tonu da isim
      hücresini kapsamalı.)
- [ ] **Uzun ad taşırmıyor.** 18 karakterden uzun bir ada sahip hesapta isim
      kırpılıp `...` ile bitmeli; sabit kolon geri kalan kolonları ekrandan
      İTMEMELİ (telefonda bile en az birkaç kolon görünür kalmalı).
- [ ] **Girilmemiş her alan `—`.** Cinsiyet/Doğum/Kaynak/Davet Eden'i boş
      bir hesapta kontrol et — boş hücre değil tire görünmeli.
- [ ] **`Koşullar` neredeyse herkeste "Evet".** Kayıt formunda zorunlu
      olduğundan "Hayır" yalnızca onayın kayda hiç geçmediği çok eski
      hesap(lar)da görünür. **Bu, düzeltilmiş bir hatanın regresyon
      kontrolü:** eskiden HERKESTE "Hayır" çıkardı.
- [ ] **Yeni bir kayıt "Evet" ile geliyor.** Test hesabıyla kayıt ol →
      satırında Koşullar "Evet" olmalı. (E-posta doğrulaması açıkken de —
      düzeltmenin asıl noktası bu.)
- [ ] **`Pazarlama` ve tarihi tutarlı.** Onay verilmişse tarih dolu,
      verilmemişse `—`. Hesap Ayarları'ndan onayı aç/kapat → paneli kapatıp
      yeniden aç → yeni değer ve yeni tarih görünmeli (**"ileride yapılan
      değişiklikler yansımalı" maddesinin kontrolü**).
- [ ] **`E-posta Bildirimi` Açık/Kapalı** (Evet/Hayır DEĞİL) ve varsayılanı
      Açık. Hesap Ayarları'ndan kapat → tabloda "Kapalı".
- [ ] **`Kanal` ile `Kaynak` karışmıyor.** Kanal Direkt/Form; Kaynak
      `?ref=` etiketi (ör. `instagram`, `arkadas`, `direkt`) ya da `—`.
- [ ] **`Davet Eden`** yalnızca davet linkiyle gelen üyelerde dolu.
- [ ] **İzin hücrelerinde kırmızı YOK** — yeşil (verilmiş) ya da nötr gri.
      Kırmızı bu tabloda yalnızca "Donduruldu" durumuna ait.
- [ ] **CSV tabloyla aynı.** İndir, aç: kolonlar ekrandakiyle aynı sırada,
      Ad ve Soyad AYRI sütun, boş alanlar gerçekten BOŞ (tire değil).
- [ ] **`?` popup'ı** Koşullar/Pazarlama/E-posta Bildirimi ayrımını ve
      Kanal ↔ Kaynak farkını anlatıyor.
- [ ] **Admin olmayan hiçbir şey göremiyor** (RPC `Yetkisiz erişim.` verir).

## 9.12. Admin — "Hatalar" sekmesi (21 Ağustos 2026, ROADMAP #3)

İstemci hata telemetrisi. Kayıtlar anonim (`client_errors`, hesap kimliği
YOK) ve okuma yalnızca admin'e açık.

- [ ] **Dördüncü sekme görünüyor ve kırpılmıyor.** Telefonda (dar ekran)
      sekmeler 2×2 ızgara, geniş ekranda tek sıra olmalı; hiçbir genişlikte
      etiket kesilmemeli ve yatay kaydırma oluşmamalı. **Bu, düzeltilmiş bir
      hatanın regresyon kontrolü:** dört sekme tek sıraya sığmıyordu ve panel
      onu sessizce kırpıyordu.
- [ ] **Sekmede rozet YOK.** "Geri Bildirim"de kırmızı sayı rozeti çıkabilir,
      "Hatalar"da ASLA — rozet bu projede "bekleyen iş" demek, hata kaydı bir
      gözlem.
- [ ] **Pencere seçici çalışıyor** (24 saat / 7 / 30 / 90 gün) ve seçim
      değişince liste yeniden yükleniyor.
- [ ] **PLATFORM seçici çalışıyor** (31 Ağustos 2026, ROADMAP #11): Tüm
      Platformlar / Web / iOS / Android / App (web). Seçim değişince liste
      yeniden yükleniyor ve **sayılar da daralıyor** — eleme sunucuda,
      gruplamadan ÖNCE yapılıyor. Somut kontrol: iki platformda birden
      görülen bir satır bul ("Platform" sütununda virgülle iki değer yazar);
      "Tüm Platformlar"daki **Kez/Cihaz** sayısı, tek platform seçilince
      DÜŞMELİ. Aynı kalıyorsa eleme istemciye kaymış demektir ve sayılar
      yanlıştır. (31 Ağustos'ta canlıda böyle bir satır vardı:
      `[online_games_repo.load] AuthApiException…` — android+app-web'de
      2 kez/2 cihaz, yalnız android'de 1/1.)
- [ ] **CSV filtreyi izliyor:** bir platform seçiliyken CSV indir → yalnızca o
      platformun satırları ve daraltılmış sayılar olmalı ("CSV ekranda
      görüneni indirir" sözü).
- [ ] ⚠ **Platformu boş olan kayıtlar** (yayınlanmayan masaüstü hedefleri)
      bir platform seçiliyken görünmez; "Tüm Platformlar"da `?` olarak
      durur. Listede olmayan bir platform değeri de aynı şekilde yalnızca
      "Tüm Platformlar"da okunur — `client_errors.platform` üzerinde
      BİLEREK kısıt yok.
- [ ] **Hiç kayıt yoksa "Bu pencerede hata kaydı yok."** — boş bir liste
      değil, açık bir metin.
- [ ] **Kartta "Kez" ve "Cihaz" AYRI AYRI okunuyor.** İkisi karıştırılırsa
      metrik anlamsızlaşır: 40 kez / 1 cihaz bir kişinin döngüsü, 3 kez /
      3 cihaz yaygın bir hata.
- [ ] **Karta dokununca yol, ilk görülme ve örnek yığın açılıyor**, tekrar
      dokununca kapanıyor.
- [ ] **Yol maskelenmiş.** Bir kayıtta `/davet/<token>` ya da `/game/<uuid>`
      HAM görünüyorsa bu bir GİZLİLİK hatasıdır — `/davet/:token` ve
      `/game/:id` olmalı.
- [ ] **CSV iniyor** ve örnek yığını da içeriyor.
- [ ] **`?` popup'ı açılıyor**, "Kez ≠ Cihaz" ayrımını anlatıyor, hız
      sınırını **saatte** 10 diye söylüyor (süreç ömrü DEĞİL) ve platform
      filtresinin sayıları da daralttığını yazıyor.
- [ ] **Admin OLMAYAN bir hesap bu sekmeyi hiç görmemeli** (Admin Paneli
      girişi zaten çıkmaz) — ayrıca doğrudan sorgulayan biri de satırları
      okuyamamalı (tabloda SELECT politikası YOK).
- [ ] **Gerçek bir kayıt oluşuyor mu:** çevrimdışıyken bir Canlı oyunda hamle
      dene — bu BEKLENEN bir durum, telemetriye satır DÜŞMEMELİ. Kaydın
      gerçekten oluştuğunu görmek için tarayıcı konsolundan
      `window.dispatchEvent(new PromiseRejectionEvent('unhandledrejection',
      { promise: Promise.reject(new Error('elle test')), reason: new
      Error('elle test') }))` çalıştır → panelde "elle test" belirmeli.
- [ ] **Tekrar bastırma:** aynı hatayı arka arkaya iki kez tetikle — panelde
      TEK satır olmalı (aynı imza pencere başına bir kez gönderilir).
      ⚠ 31 Ağustos 2026'da pencere SÜREÇ ÖMRÜNDEN son 1 saate taşındı
      (ROADMAP #10): aynı hata bir saat sonra YENİDEN gönderilir, yani
      "Kez" sayacının artması bir hata değil beklenen davranıştır.
- [ ] **GÜRÜLTÜ ELENİYOR (23 Ağustos 2026, ilk gerçek veriden):** Siteyi
      **Instagram/Facebook uygulamasının içindeki tarayıcıdan** (Android)
      aç, biraz gez ve sekmeyi kapat → panelde
      `Error invoking postMessage: Java exception…` YA DA `Script error.`
      BELİRMEMELİ. Bunlar uygulama-içi tarayıcının kendi enjekte ettiği
      script'ten geliyor, bizim kodumuzla ilgisi yok. Belirirse filtre
      kırılmıştır (`isThirdPartyError`).
- [ ] **Oturum düşmesi hata sayılmıyor:** girişliyken başka bir sekmeden
      çıkış yap (ya da tarayıcı depolamasından `sb-*-auth-token` anahtarını
      sil) ve eski sekmede "Arkadaşınla" sekmesine dön →
      `permission denied for function list_my_online_games` panele
      DÜŞMEMELİ. **Ama bu, aynı mesajı sonsuza dek gizlemek DEĞİL:** oturumu
      geçerli bir kullanıcı aynı mesajı alıyorsa o GERÇEK bir grant
      hatasıdır ve panelde görünmeli.

## 9.15. Admin — Sürüm Dağılımı + hata kartında sürüm (23 Ağustos 2026)

Mağaza öncesi hazırlık. **Bugün app yayında olmadığı için tablo yalnızca
web/bilinmiyor satırları gösterir — asıl sınama uygulamalar çıkınca.**

- [ ] Büyüme > Kullanıcı'da **"Sürüm Dağılımı"** tablosu Cihaz'ın hemen
      altında görünüyor; sayı sütununun başlığı **"Başlangıç"** (Ziyaretçi
      DEĞİL — bu tablo oyun açılışı sayıyor).
- [ ] Sürümsüz satırlar **—** ile çiziliyor (web'in sürümü yok; "bilinmiyor"
      yazmak eksik veri izlenimi verirdi).
- [ ] `?` popup'ı "kullanıcı değil oyun açılışı sayar" ve "kapsam yalnızca YZ
      oyunları" sınırlarını söylüyor.
- [ ] CSV iniyor ve başlık satırı "Başlangıç" diyor.
- [ ] Hatalar sekmesinde bir web kaydında **"Sürüm:" satırı HİÇ ÇIKMIYOR**
      (web sürüm göndermez — boş bir satır her web hatasında gürültü olurdu).
- [ ] **APP ÇIKINCA:** telefondan bir YZ oyunu aç → tabloda `ios · 1.0.0`
      (ya da android) satırı belirmeli; uygulamada bir hata oluştur →
      hata kartında "Sürüm: 1.0.0" görünmeli ve "Yol" alanı `game` /
      `online-game` / `intro` gibi gerçek bir ekran adı olmalı, `app` değil.
- [ ] **APP ÇIKINCA:** `mobile_min_supported_version`'ı yükseltmeden ÖNCE bu
      tabloya bak — eski sürümden hâlâ oyun açılıyorsa eşiği yükseltmek o
      kullanıcıları uygulamadan kilitler.

## 9.14. Admin — kart başlıklarında gönderen adı (23 Ağustos 2026)

Geri Bildirim (Gelen Kutusu) ve Şikayetler kartlarının başlığı. Bu bölüm bir
kullanıcı raporunun regresyon kontrolü: ad tek satırdaki TEK esnek öğe
olduğundan telefonda hep O kırpılıyordu (`Ser…`, `kelimekitest4@sh…`).
Admin paneli oturum + admin rolü istediğinden otomatik test EDİLEMİYOR.

- [ ] **TELEFONDA** Gelen Kutusu'nu aç: her kartta gönderenin adı (ya da
      misafirse e-posta adresi) **TAMAMEN** görünmeli — hiçbir yerde `…` ile
      biten bir ad olmamalı. Rozetler (`Yanıtlandı`/`Oyun Sonu`/`Gönderilen`/
      `↳ Cevaben`) ve tarih adın ALTINDAKİ satırda, tarih sağ uçta.
- [ ] **En uzun vaka:** misafir bir geri bildirim (uzun e-posta adresi) ve
      girişli bir üyenin kaydı (ad + ` · ` + e-posta) — ikisi de sarmalı,
      kırpılmamalı, karttan taşmamalı.
- [ ] **Şikayetler alt sekmesinde aynısı:** `{raporlayan} → {raporlanan}`
      satırı tam görünmeli.
- [ ] **Kart açılıp kapanıyor** (başlık iki satıra çıkınca dokunma davranışı
      bozulmamalı) ve `Okundu işaretle` / `Yanıtla` / silme aynen çalışmalı.
- [ ] **Üyeler tablosundaki isim kolonu DEĞİŞMEDİ** — orada 150px kapak ve
      `title` bilinçli (sabit kolon dar ekranda tüm alanı yemesin diye).

## 9.16. Admin — "Tanıtım Turu" kartı (8 Eylül 2026, Onboarding Faz 5)

Büyüme > Kullanıcı → **Kaynak Hunisi'nin hemen ALTINDA**. Kartın kararları
(neden ayrı bir tablo, neden iki satır, neden oran cihaz üzerinden)
`docs/decisions/admin-panel.md` → "Tanıtım Turu kartı"nda; burası yalnızca
kontrol listesi. **Kullanıcı tarafındaki tur** (balonlar, tekrar oynama,
ATLA) kök `TESTING.md` §13.6'da — önce onu koş, sonra buraya bak: kartın
sayıları o turun ÇIKTISI.

- [ ] **Kart yerinde ve başlığı aralığı yazıyor:** "Tanıtım Turu (Son 30
      gün)" gibi — üstteki dönem seçicisi (gün/hafta/ay) DEĞİŞTİRİLİNCE
      başlık ve sayılar birlikte değişmeli (Kaynak Hunisi ile aynı seçiciye
      bağlı).
- [ ] **En fazla İKİ satır: `Otomatik` ve `Tekrar`.** Ham `auto`/`replay`
      değerleri ekranda GÖRÜNMEMELİ. Hiç tekrar izleyen yoksa `Tekrar`
      satırı hiç olmayabilir — bu normal, boş satır çizilmemeli.
- [ ] **Sayı çifti doğru okunuyor (15 Eylül 2026'da TERS ÇEVRİLDİ):**
      `Başlatma`/`Bitirme` sütunundaki büyük sayı ADET, parantezdeki soluk
      sayı BENZERSİZ CİHAZ. Parantezdeki sayı hiçbir zaman büyük sayıdan
      BÜYÜK olamaz. Tanıtımı aynı cihazda iki kez açınca yalnızca büyük sayı
      artmalı.
- [ ] **UYGULAMADAN açılan tanıtım parantezi ARTIRMAZ** ve bu bir hata
      değil: port `anon_id` yazmıyor, benzersiz sayım NULL saymaz. Kontrol:
      telefonda tanıtımı aç → büyük sayı +1, parantez AYNI kalmalı. (Tersi —
      parantezin de artması — portun damgayı yazmaya başladığı anlamına
      gelir; o zaman ROADMAP'teki madde kapanmış demektir ve oran cihaz
      paydasına geri alınabilir.)
- [ ] **`Oran` sütunu ADET üzerinden:** `Bitirme / Başlatma`. Aynı cihazda
      iki kez açıp bir kez bitirince oran DÜŞER — bu beklenen davranış, kabul
      edilmiş bedel (gerekçe: `docs/decisions/admin-panel.md`).
- [ ] **`Başlatma` 0 ise oran `—`, `%0` DEĞİL** ("0% ≠ bilgi yok" kuralı,
      Kaynak Hunisi ile aynı).
- [ ] **Bırakılan sahne dökümü:** ATLA ile 1. sahnede çıkıp yeniden açıp 3.
      sahnede çıktıktan sonra satırın altında *"bırakılan sahne: 1. (1) · 3.
      (1)"* görünmeli — sahne numarasına göre ARTAN sırada.
- [ ] **`Atlayan` ile döküm toplamı EŞİT OLMAYABİLİR** ve bu bir hata değil:
      sahne yazmayan bir istemcinin satırı `Atlayan`a girer, döküme girmez.
      Ters yön hata: döküm toplamı `Atlayan`ı AŞMAMALI.
- [ ] **Boş aralık "Bu aralıkta veri yok." demeli** — sıfırlarla dolu bir
      tablo DEĞİL. Yüklenirken "Yükleniyor…"; ikisinde de `?` rozeti çizili
      kalmalı.
- [ ] **`?` popup'ı (`tanitim-turu`)** başlığı "Tanıtım Turu" olmalı ve üç
      şeyi açıkça söylemeli: adet ↔ benzersiz cihaz ayrımı, parantezdeki
      cihaz sayısının YALNIZCA web'i gördüğü, ve iki kaynağın neden ayrı
      satır olduğu.
- [ ] **Tanıtım Kaynak Hunisi'ni KİRLETMİYOR.** Bir tanıtım turu oyna → üstteki
      Kaynak Hunisi'nin "Başlayan" sütunu DEĞİŞMEMELİ (tanıtım bilerek bir
      "oyun" değil: `game_starts` yazılmıyor, `games` satırı açılmıyor).
      Kart artıp huni artıyorsa yalıtım kırılmış demektir.
- [ ] **Kartın CSV düğmesi YOK** — bilinçli (tablo en çok iki satır). Çıkmışsa
      `SourceFunnelTable`'ın kipi yanlışlıkla buraya kopyalanmış demektir.
- [ ] **Gizlilik: hesap kimliği hiçbir yerde görünmemeli.** `tutorial_events`
      satırında `user_id` YOK (bilerek); kartta ad/e-posta/kullanıcı kırılımı
      çıkıyorsa bu `game_starts` ile ortak olan gizlilik kararının ihlalidir.
- [ ] **Admin olmayan hesap hiçbir şey göremiyor:** `admin_tutorial_funnel`
      admin dışına kapalı ve `tutorial_events` tablosunun SELECT politikası
      hiç YOK (yazma anon + authenticated'a açık, okuma kimseye) — normal bir
      hesapla tabloyu okumaya çalışınca boş dönmeli.
- [ ] **MOBİLDE:** port `anon_id` GÖNDERMİYOR — telefondan tanıtımı açıp
      bitirince yalnızca parantezdeki ADET artmalı, BENZERSİZ CİHAZ sayısı
      DEĞİL. (Port damgalamayı eklerse bu madde ve `admin-panel.md`'deki not
      birlikte güncellenir.)


## 9.17. Admin — açılır tablolar + üç grafiğin kaldırılması (16 Eylül 2026)

Yedi maddelik bir tur (kullanıcı isteği). Sunucu tarafı canlıda doğrulandı
(geriye doldurma sayıları, dört serinin toplamının "Bitirilen"e eşitliği,
`grouping sets` ağacı); aşağıdakiler **gerçek istemcide** görülmesi
gerekenler. Kararların tamamı: `docs/decisions/admin-panel.md` → "Açılır
tablolar + üç grafiğin kaldırılması".

### Büyüme > Kullanıcı

- [ ] **Kaynak Hunisi artık KANAL satırları gösteriyor** — "Instagram",
      "Facebook", "Arkadaş Daveti", "Direkt", "Bilinmiyor". Ham `instagram`/
      `ig-bio`/`fb-reel` satırları ÜST düzeyde GÖRÜNMEMELİ.
- [ ] **Satıra dokun → ham etiketler açılıyor** (ok 180° dönüyor). Birden çok
      etiketi olmayan kanalda **ok HİÇ çizilmemeli** (ör. "Arkadaş Daveti") —
      açılınca aynı sayıyı ikinci kez yazardı.
- [ ] **Kanalın sayısı alt satırların toplamı.** Facebook'u aç: alt satırların
      "Gelen" değerleri üstteki kanal satırını vermeli.
- [ ] **% / Sayı düğmesi açık satırlarda da çalışıyor.** Yüzdeye çevir → hem
      kanal hem ham etiket satırları yüzdeye dönmeli, "Gelen" sütunu genel
      toplamın payını göstermeli.
- [ ] **CSV DÜZ iniyor:** ilk sütun "Kanal", ikinci "Kaynak"; her kanal için
      bir `(kanal toplamı)` satırı + ham etiketleri. Tabloyu katlamak veriyi
      GİZLEMEK değildi.
- [ ] **Sürüm Dağılımı da açılır oldu** — üst satırlar "Web / Android / iOS /
      Uygulama (web)". Android'i aç: sürümler **yeniden eskiye** sıralı
      (1.1.0 → 1.0.9 → 1.0.0), metin sırasıyla DEĞİL (1.0.10, 1.0.9'un
      ÜSTÜNDE olmalı). Web'in tek satırı **—** olduğundan oku OLMAMALI.
- [ ] **Başlık "Bildirim İzni Verenler" oldu** ("Kurulu Sürümler — Kişi"
      YAZMAMALI). `?` metni kapsamı açıkça söylemeli: yalnızca giriş yapmış
      VE bildirim izni vermiş kişiler.
- [ ] ⚠ **TOPLAM, alt satırların toplamı OLMAK ZORUNDA DEĞİL** ve bu bir hata
      değil: değerler benzersiz KİŞİ, iki telefonu olan biri iki satırda
      birden görünür. Platform satırı ve TOPLAM sunucuda ayrı ayrı sayılıyor.
      Sağlama: TOPLAM asla satırların toplamından BÜYÜK olmamalı.
- [ ] **Arkadaşlık GRAFİĞİ yok, dört kutu duruyor** ("Toplam Arkadaşlık",
      "Bekleyen İstek", "Oluşturulan Davet Linki", "Davetle Katılan Üye") ve
      `?` rozeti başlığın yanında.
- [ ] **Kutular periyot kombosuna BAĞLI DEĞİL** — periyodu değiştir, dört sayı
      da AYNI kalmalı (tüm zamanlar). `?` metni bunu söylemeli.

### Büyüme > Oyun

- [ ] **Oyun Sayısı grafiğinde altı seri var:** Bitirilen, Teslim, Web, iOS,
      Android, Diğer. Açılışta yalnızca **Bitirilen** açık olmalı.
- [ ] **Dört platform serisi "Bitirilen"e TAM toplanıyor.** Dördünü birden aç,
      bir kovanın değerlerini topla → "Bitirilen"i vermeli. Tutmuyorsa sunucu
      tarafı bozulmuştur.
- [ ] **"Teslim" kırılmadı** — platform serileri açıkken bile tek bir Teslim
      çizgisi olmalı.
- [ ] **Geçmiş boş DEĞİL.** 17 Ağustos 2026 sonrası kovalarda Web/Android
      gerçek değerler göstermeli (geriye doldurma çalıştı). "Diğer" eski
      kovalarda baskın olacak — bu beklenen.
- [ ] **Oyun Süresi GRAFİĞİ yok, DÖRT kutu var:** Genel · Tek Oturumda ·
      Günlere Yayılan · Uzun kuyruk (p90). `?` rozeti başlığın yanında (CSV
      yok — YZ Dengesi ile aynı desen).
- [ ] **Kutular pencerenin TAMAMINI ölçüyor, son kovayı değil.** Periyodu
      uzat/kısalt → değerler değişmeli. Sağlama: **p90 her zaman Genel'in
      ÜSTÜNDE** olmalı.
- [ ] **Kutuların altında "Pencerede biten oyun: N" yazıyor** ve N, Oyun
      Sayısı grafiğindeki "Bitirilen" toplamıyla uyumlu olmalı.
- [ ] **Hiç biten oyun olmayan aralıkta "Bu aralıkta biten oyun yok." çıkıyor**
      — kutularda 0 dk YAZMAMALI.
- [ ] **Kaynak/kapsam/oyuncu sayısı komboları kutuları da değiştiriyor**
      (grafikle AYNI filtreler). Değişmiyorsa özet RPC'sine parametreler
      geçmiyor demektir.
- [ ] **Beğeni/Paylaşma GRAFİĞİ yok, iki kutu duruyor** ve `?` başlığın
      yanında. Kutular yine periyottan bağımsız (tüm zamanlar).

### Telemetri

- [ ] **Web'den bir oyun bitir** → "Web" serisi o günün kovasında **1
      artmalı**. Bu, merge'den hemen sonra koşulabilir.
- [ ] **Misafirken (web) bir oyun bitir** → "Diğer" artmalı, Web DEĞİL. Bu
      yapısal: misafirin `games` satırı hiç açılmıyor.
- [ ] ⚠ **Uygulamadan biten oyunlar ŞU AN "Diğer"e düşüyor ve bu BEKLENEN.**
      Portun `logGameFinish`i damgayı henüz yazmıyor — o değişiklik inceleme
      dondurması yüzünden ayrı bir PR'da (`claude/oyun-bitis-platform-port`).
      **iOS/Android serileri bugün yalnızca Canlı oyunları sayıyor.**
- [ ] **O PR merge edilip yeni paket çıkınca:** uygulamadan bir oyun bitir
      (iOS ve Android ayrı ayrı) → ilgili platform serisi 1 artmalı. Hâlâ
      "Diğer"e gidiyorsa `data/games_api.dart` damgayı göndermiyordur. Bu
      maddeyi o sürüm turunda koş, öncesinde DEĞİL.

## 9.18. Admin — Üyeler tablosunda "Onay" kolonu + filtre (16 Eylül 2026)

ROADMAP #9'u kapatan tur. Sunucu tarafı canlıda doğrulandı (RPC yeni kolonu
döndürüyor, ACL merge öncesiyle birebir aynı); aşağıdakiler gerçek
istemcide görülmesi gerekenler. Kararlar: `docs/decisions/admin-panel.md` →
"Üyeler tablosuna 'Onay' kolonu + onaylanmamış filtresi".

- [ ] **"Onay" kolonu E-posta'nın hemen SAĞINDA.** Çoğu satır yeşil
      **Onaylı** olmalı.
- [ ] **"Onaylı" üstüne gelince (hover / uzun dokunuş) onay TARİHİ çıkıyor.**
- [ ] **Onaysız satır TURUNCU "Bekliyor" yazıyor** — soluk gri DEĞİL. Gri
      görüyorsan `ConsentCell`e geri dönülmüş demektir; o soluklaştırma
      "kullanıcının tercihi" içindi, burada bakılması gereken bir durum var.
- [ ] **"Yalnızca onaylanmamışlar (N)" düğmesi arama kutusunun altında** ve
      N, turuncu satırların sayısıyla aynı olmalı.
- [ ] **Düğme listeyi daraltıyor**; tekrar basınca eski hâline dönüyor.
- [ ] **Arama ile BİRLİKTE çalışıyor:** bir isim ara + filtreyi aç → ikisi
      birden uygulanmalı. Sonuç boşsa metin *"Bu aramada onaylanmamış üye
      yok."* olmalı, *"Aramayla eşleşen üye yok."* DEĞİL.
- [ ] **Alt sayaç daralmayı yansıtıyor:** filtre açıkken (arama boş olsa
      bile) `N / M üye` yazmalı, "Toplam M üye" DEĞİL.
- [ ] ⚠ **Onaysız hesap yokken düğme HİÇ çizilmemeli.** (Canlıda genelde
      1-4 onaysız olur; hiç yoksa bu maddeyi doğrulamak için bekle, düğmeyi
      "eksik" sayma.)
- [ ] **CSV'de `E-posta Onayı` sütunu var** ve değeri ya onay tarihi ya
      `Bekliyor`. CSV filtre/aramayla daralmış listeyi indirmeli.
- [ ] **Sıralama başlığı EKLENMEDİ** — "Onay" tıklanabilir OLMAMALI (mevcut
      yedi sıralama anahtarı korunuyor).
- [ ] **`?` metni okunuyor:** 24 saat / ~20. saat hatırlatma / 48. saatte
      silme zincirini ve "eskimiş Bekliyor bir arıza işaretidir" cümlesini
      içermeli.

### Yapısal sağlama (ayda bir bakılır)

- [ ] **"Bekliyor" satırlarının hepsi son 48 SAATTEN olmalı.** Katılma
      tarihi daha eski bir "Bekliyor" görürsen `sweep-unconfirmed-accounts`
      cron'u durmuş demektir — kolonun asıl teşhis değeri bu.

## 9.19. Admin — "Aktif Saatler" grafiği (18 Eylül 2026)

Büyüme > **Oyun** sekmesi, "Oyun Sayısı"nın hemen altında.

- [ ] Grafik açılıyor, **12 çubuk** var ve x ekseni `00 · 04 · 08 · 12 · 16 · 20`
      yazıyor (ara dilimler etiketsiz — kalabalık olmasın diye bilerek).
- [ ] Çubukların üzerine gelince tooltip çıkıyor; başlığı `22–24` gibi bir
      ARALIK (tek saat değil), 22 diliminin ucu `24` yazıyor — `00` DEĞİL.
- [ ] Tooltip'teki **Web + iOS + Android + Diğer toplamı, "Bitirilen"e TAM
      eşit.** Tutmuyorsa sunucudaki değişmez kırılmış demektir.
- [ ] ⚠ **İlk ve SON çubuğun tooltip'i grafiğin dışına taşmıyor** (18 Eylül
      2026'da tam bu hata yakalanmıştı: son çubuğun kutusu grafiğin üstünü
      örtüyordu).
- [ ] **Efsane tıklanamaz** — Web/iOS/Android/Diğer rozetlerine basmak hiçbir
      şey yapmamalı (bu grafikte seri açıp kapatmak YOK; segmentler toplama
      tam eklendiği için bir segmenti gizlemek çubuğu yalan söyletirdi).
- [ ] "Tablo Görünümü" 12 satır + `Saat · Bitirilen · Web · iOS · Android ·
      Diğer` kolonlarını veriyor; geri dönünce grafik yeniden çiziliyor.
- [ ] "CSV İndir" aynı 12 satırı veriyor.
- [ ] `?` rozeti "Aktif Saatler" açıklamasını açıyor.
- [ ] ⚠ **Üstteki kombolar (kaynak / kapsam / oyuncu sayısı) bu grafiği
      DEĞİŞTİRMEMELİ** — bilerek bağımsız, sabit 30 günlük pencere. Kombo
      değiştirince çubuklar kıpırdıyorsa effect'in bağımlılık dizisi
      kirlenmiş demektir.

⚠ **Bugünkü BEKLENEN görüntü:** "Diğer" segmenti şişkin ve iOS neredeyse
görünmez. Bu bir hata DEĞİL — portun `logGameFinish`i platform damgasını
yazmıyor (PR #565 dondurulmuş). O merge edilip yeni mağaza paketi dağılınca
"Diğer" kendiliğinden incelmeli. **Toplam çubuk yüksekliği bundan
etkilenmez.** Ayrıntı: `docs/decisions/admin-panel.md` → "Aktif Saatler".

## 9.20. Admin — "Aktif Günler" grafiği (20 Eylül 2026)

Büyüme > **Oyun** sekmesi, "Aktif Saatler"in hemen altında. §9.19'un
İKİZİ — aynı bileşen, aynı seri, aynı pencere.

- [ ] Grafik açılıyor, **7 çubuk** var ve x ekseni `Pzt · Sal · Çar · Per ·
      Cum · Cmt · Paz` yazıyor — **hepsi etiketli** (saat ekseninin aksine
      hiçbiri atlanmıyor) ve hafta **Pazartesi** başlıyor.
- [ ] ⚠ **Hafta Pazar'dan BAŞLAMIYOR.** Başlıyorsa sunucuda `isodow` yerine
      `dow` kullanılmış demektir ve hafta sonu çubukları grafiğin iki ucuna
      dağılmıştır — desen okunamaz hale gelir.
- [ ] Tooltip başlığı günün **TAM adı** (`Perşembe`), kısaltma değil.
- [ ] Tooltip'teki **Web + iOS + Android + Diğer toplamı, "Bitirilen"e TAM
      eşit.**
- [ ] ⚠ **EN ÖNEMLİ KONTROL — iki grafiğin toplamı birbirini tutuyor.**
      "Aktif Saatler"in tablo görünümündeki `Bitirilen` kolonunun toplamı ile
      "Aktif Günler"inki **EŞİT** olmalı (20 Eylül 2026'da canlıda ölçüldü:
      ikisi de **1279**). Tutmuyorsa iki RPC'den biri değişmiş, öteki
      güncellenmemiştir — ikisi AYNI popülasyonu sayıyor.
- [ ] İlk ve SON çubuğun tooltip'i grafiğin dışına taşmıyor.
- [ ] **Efsane tıklanamaz** (§9.19 ile aynı gerekçe).
- [ ] "Tablo Görünümü" 7 satır + `Gün · Bitirilen · Web · iOS · Android ·
      Diğer` kolonlarını veriyor; ilk kolon başlığı **`Gün`** (`Saat` DEĞİL).
- [ ] "CSV İndir" aynı 7 satırı veriyor, dosya adı `kelimeki-aktif-gunler-…`.
- [ ] `?` rozeti "Aktif Günler" açıklamasını açıyor.
- [ ] ⚠ **Üstteki kombolar (kaynak / kapsam / oyuncu sayısı) bu grafiği
      DEĞİŞTİRMEMELİ** — §9.19 ile aynı, bilerek bağımsız sabit 30 gün.
- [ ] ⚠ **"Aktif Saatler" de hâlâ doğru çalışıyor** — bileşen 20 Eylül'de
      genelleştirildiği (`ActiveHoursChart.tsx` → `StackedBucketChart.tsx`)
      için §9.19'un TAMAMI bu turda yeniden koşulmalı. Regresyon riski
      kovaya özgü olan üç yerde: eksen etiketlerinin atlanması, `22–24`
      aralık başlığı ve tablo/CSV'nin `Saat` başlığı.

⚠ **Bugünkü BEKLENEN görüntü:** §9.19 ile aynı — "Diğer" şişkin, iOS
neredeyse görünmez (portun `logGameFinish`i damgayı yazmıyor, PR #565
dondurulmuş). Ayrıntı: `docs/decisions/admin-panel.md` → "Aktif Günler".

## 9.21. Admin — "Oyun Dağılımı" pastaları (22 Eylül 2026)

Büyüme > **Oyun** sekmesi, "Oyun Süresi (Medyan)" ile "Beğeni / Paylaşma"
arasında. İki pasta yan yana: **Oyun Tipi** (Yapay Zeka ↔ Arkadaşınla) ve
**Masa** (2 Kişilik ↔ 4 Kişilik). Başlık `Oyun Dağılımı (Son 30 Gün)`.

- [ ] İki pasta da çiziliyor, **yan yana** (dar telefonda da iki sütun).
- [ ] ⚠ **EN ÖNEMLİ KONTROL — iki pastanın toplamı birbirini tutuyor.**
      Soldaki efsanenin iki ham sayısının toplamı, sağdakinin iki ham
      sayısının toplamına **EŞİT** olmalı ve ikisi de pastaların altındaki
      `Pencerede biten oyun: N` satırına eşit (22 Eylül 2026'da canlıda
      ölçüldü: **1271 + 72 = 1095 + 248 = 1343**). Tutmuyorsa satır bunu
      zaten yazar (`⚠ masa kırılımı … ediyor`) — o uyarı çıkıyorsa
      `game_finishes`e 2/4 dışında bir `player_count` düşmüş demektir.
- [ ] Efsanede **ham sayı ve yüzde birlikte** var; etiketler **kırpılmamış**
      (`Yapay …` gibi üç noktayla bitmiyor) ve dar telefonda **tek satırda**
      duruyor — etiket 22 Eylül 2026'da bunun için kısaldı ("Yapay Zeka ile"
      → "Yapay Zeka"). Sarma hâlâ mümkün ama artık son çare.
- [ ] Sol dilimin etiketi, üstteki **Kaynak** kombosunun `Yapay Zeka`
      seçeneğiyle **aynı kelime**.
- [ ] Dilim içindeki yüzde yalnızca **büyük dilimlerde** yazıyor; küçük dilim
      (bugün "Arkadaşınla", ~%5) etiketsiz — sayısı efsanede.
- [ ] İki dilim arasında ince bir **zemin boşluğu** görünüyor (sınır renkten
      değil boşluktan okunuyor).
- [ ] `?` rozeti "Oyun Dağılımı" açıklamasını açıyor ve açıklama
      **"Arkadaşınla = OYUN TİPİ, rakip insandı DEĞİL"** uyarısını taşıyor.
- [ ] ⚠ **Üstteki kombolar (kaynak / kapsam / oyuncu sayısı) bu pastaları
      DEĞİŞTİRMEMELİ** — §9.19/§9.20 ile aynı, bilerek bağımsız sabit 30 gün.
      Değişiyorlarsa kırılım yok olur: kaynak "Canlı"da soldaki pasta tek
      dilime düşer.
- [ ] Teslimle biten oyunlar **hiçbir dilimde sayılmıyor** — "Oyun Sayısı"
      grafiğinin `Bitirilen` serisiyle aynı tanım.

⚠ **BEKLENEN görüntü (22 Eylül 2026):** "Yapay Zeka ile" ezici çoğunlukta
(~%95) — Canlı oyun hacmi hâlâ küçük. Ayrıntı:
`docs/decisions/admin-panel.md` → "Oyun Dağılımı".

## 9.22. Admin — "Ziyaretçi Yolculuğu" kartı (23 Eylül 2026)

Gerekçe ve tuzaklar: `docs/decisions/admin-panel.md` → "Ziyaretçi
Yolculuğu". Burası yalnızca elle kontrol listesi. Kendi ziyaretini üretmek
için **gizli sekme** kullan: oturum kodu sekmeye özel, karşılama sayfası da
yalnızca ilk kez gelene gösteriliyor.

- [ ] **Kart yerinde:** Büyüme > Kullanıcı, Kaynak Hunisi'nin ÜSTÜNDE,
      başlık "Ziyaretçi Yolculuğu (Son 30 Gün)". Cihaz kombosu (Tüm Cihazlar /
      Masaüstü / iOS / Android) değişince yalnızca bu kart yenilenmeli.
- [ ] **Karşılamada çıkış:** gizli sekmede `kelimeki.com`u aç, biraz kaydır,
      sekmeyi kapat → kartta "Karşılama sayfası" Ulaşan +1, Ayrılan +1. Alttaki
      "sayfanın medyan %X kadarını gördü" satırı görünmeli.
- [ ] **Oyun yolu:** yeni gizli sekme → Oyna → (tanıtımı bitir) → oyunda 5
      hamle yap → sekmeyi kapat → "5. hamle" satırının Ayrılan'ı +1;
      "Uygulamaya geçti", "Uygulama açıldı", "Oyun başladı", "İlk hamle"
      Ulaşan'ları da +1 (Ayrılan'ları DEĞİŞMEMELİ).
- [ ] **Kayıt/giriş başarıdır:** misafirken giriş yap → "Giriş yaptı" satırı
      Ayrılma sütununda `✓` göstermeli, kırmızı vurgu ALMAMALI.
- [ ] **Girişli oturum yazılmıyor:** girişliyken uygulamayı aç, bir oyun
      başlat → hiçbir satır artmamalı.
- [ ] **Yeni / Dönen süzgeci:** varsayılan **Yeni**. Gizli sekmede karşılamadan
      gelen oturum yalnızca Yeni'de (ve Tümü'nde) görünmeli. Aynı sekmede sayfayı
      kapatıp `kelimeki.com`u normal sekmede yeniden açınca (karşılama atlanır)
      oturum Dönen'de görünmeli.
- [ ] **`?` popup'ı (`ziyaretci-yolculugu`)** "OTURUM sayar, kişi değil",
      "adımlar bir sıra DEĞİL, bir küme" ve "Dönen = karşılama atlandı; linkle
      gelen yeni ziyaretçi de burada" uyarılarını taşımalı.
