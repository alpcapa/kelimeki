# Cihaz testi — k-lig ödül & rütbe sistemi

> `mobile/TESTING.md`'nin 13. bölümü. 27 Eylül 2026'da o dosya 131 KB ile
> uyarı bandında olduğu için buraya taşındı (kök `CLAUDE.md` → "Doküman
> Boyutu Bütçesi"). **Hiçbir madde değişmedi**, bölüm numarası korundu.
>
> **Neden bu bölüm:** dosyanın açık ara en büyük bölümüydü (15 KB) ve tek
> bir özelliğin (ödül/rütbe, sunucu tarafı ödül hesabı + kutlama banner'ı)
> kendi içinde bütün bir turu; öteki bölümlerle ortak adımı yok.

## 13. k-lig ödül & rütbe sistemi (Parça 61-62)

Ödül/rütbe kayıtları SUNUCUDA, `games`e satır ekleyen bir trigger'la
(`games_award_league_rewards`) açılır — yani mobilde bitirilen bir oyun da
ödülü kendiliğinden kazanır. Kutlamanın "bir kez göster" garantisi
`league_rewards.seen_at` ile CİHAZDAN BAĞIMSIZ: webde görülen bir kutlama
mobilde tekrar ÇIKMAMALI (ve tersi). Bu zincirin büyük kısmı otomatik test
edilemiyor (gerçek oturum + gerçek oyun bitişi gerekiyor); web'in aynı
listesi kök `TESTING.md` bölüm 10.

- [ ] **Dokuz kademe, doğru eşik/ödül/renk (Parça 62).** Bilgi popup'ında
      ve mühürde gösterilen kademe şu tabloyla BİREBİR uyuşmalı — üç kopya
      (SQL / `leagueRank.ts` / `league_rank.dart`) elle senkron olduğundan
      biri sapmışsa burada görünür:

      | Kademe | Harf | Eşik | Ödül | Renk |
      |---|---|---|---|---|
      | Çaylak | Ç | 0 | — | gri |
      | Meraklı | M | 50 | +5 | mavi |
      | Oyuncu | O | 100 | +10 | yeşil |
      | Usta | U | **250** | +25 | altın |
      | Şampiyon | Ş | 500 | +50 | turuncu |
      | Destan | D | 1000 | +100 | kırmızı |
      | Efsane | E | 2500 | +250 | çivit |
      | Uzaylı | **Z** | 5000 | +500 | camgöbeği |
      | Kozmik | K | 10000 | +1000 | parlak altın |

      Üç şeye ayrıca bak: (a) Uzaylı'nın harfi **Z** (U DEĞİL — o Usta'da);
      (b) üç yeni rengin (çivit/camgöbeği/parlak altın) mühürde ve ilerleme
      çubuğunda birbirinden ayırt edilebildiği; (c) **Kozmik EN ÜST** —
      o kademede ilerleme çubuğu HİÇ çizilmemeli, Destan'da ise Efsane
      (2500) hedefiyle çizilmeli.
- [ ] **"Nasıl Oynanır?" ekranında rütbe bölümü (Parça 66).** Detaylı
      Kurallar'da, "Skor Kartı ve Puanlama"nın hemen altında **"Rütbeler ve
      Ödüller"** başlıklı bir bölüm olmalı: dokuz kademe alt alta, her
      satırda kademe renginde harf + ad + eşik + (Çaylak hariç) yeşil
      "(ödül +N)". Tablo `league_rank.dart`'tan ÜRETİLİYOR, elle
      yazılmıyor — yukarıdaki tabloyla BİREBİR aynı olmalı; ayrışırsa
      biri elle yazılmış demektir. Bölümde ödülün hayatta bir kez
      verildiği, rütbenin düşebileceği ve Kozmik'in en üst kademe olduğu
      yazmalı; "Skor Kartı ve Puanlama"nın sonunda da -2 cezasının iki
      kaynağı (Canlı 48 saat, yerel 7 gün) geçmeli. **Web'de birebir aynı
      bölüm var** (kök `TESTING.md` bölüm 10) — iki ekran ayrışmamalı.
- [ ] **Bölüm başlıkları BÜYÜK HARF (aynı turda düzeltildi).** Detaylı
      Kurallar'daki ON bölüm başlığı da ("PUAN TABLOSU", "BÖLGE VERGİSİ",
      "RÜTBELER VE ÖDÜLLER"…) web gibi büyük harfli olmalı — port bunu
      Parça 10'dan beri küçük harf çiziyordu. Türkçe kurala dikkat:
      "NASIL OYNANIR?" (noktalı İ DEĞİL) ve "BÖLGE VERGİSİ" (sondaki İ
      noktalı) — biri ters çıkarsa `trUpper` yerine native `toUpperCase`
      kullanılmış demektir.
- [ ] **Başlık emojileri (12 Ağustos 2026, Parça 70).** Rütbe
      yükselince **👏** ("Yeni rütben: X! 👏"), 100'lük kilometre
      taşında **🎉**, düşüşte **😔**. Üçü de GERÇEK emoji olmalı, boş
      kare (tofu) DEĞİL. (Yalnızca "Eşik ödülü kazandın!" varyantı
      emojisiz — bilinçli.)
- [ ] **Kart HER varyantta aynı genişlikte (280) ve ✕ kartın İÇİNDE.**
      Kutlama, kilometre taşı ve düşüş banner'larını yan yana koy:
      kart genişliği değişmemeli ve ✕ hiçbirinde kartın dışına
      taşmamalı. (İlk sürümde kutlama kartı içeriğe göre 238px'e
      büzülüyor ve ✕ dışarıda kalıyordu — web'de kart her zaman 280.)
- [ ] **Kutlama banner'ı bir kez çıkar.** Görülmemiş bir ödülün varken
      (test için bir satırın `seen_at`'i SQL'le null'a çekilebilir)
      uygulamayı aç: mühür damgalı, konfetili banner ekranın ORTASINDA,
      karartılmış arka planla çıkmalı. "DEVAM"dan sonra uygulama yeniden
      başlatılsa da, **web'den girilse de** bir daha çıkmamalı.
- [ ] **Banner oyun ortasında çıkmaz.** Devam eden bir YZ/Canlı oyunun
      tahtasındayken banner asla belirmemeli. Oyun bitince (GameOver
      modalı + Görüş Bildir formu kapatıldıktan sonra — banner onların
      ALTINDA duruyor, web'de de öyle) kendiliğinden görünmeli.
- [ ] **Setup'a dönünce de görünür.** Oyunu bitirmeden logoya basıp
      Setup'a dön: orada bekleyen kutlama varsa çıkmalı (Setup'ın host'u
      oyun ekranı pop edilince yeniden etkinleşir).
- [ ] **Birleşik özet.** Aynı anda birden fazla görülmemiş kayıt varken
      TEK banner çıkmalı: rütbe varsa başlık rütbe, ödül puanı yeşil
      satırda TOPLAM olarak.
- [ ] **Mühür üç yerde ve aynı kademede.** k-lig listesi satırları (18px),
      Skor Kartı ve başka bir oyuncunun kartı (34px, başlık ile ✕ ARASINDA
      ortalı, yazısız). Üçü de GÜNCEL toplam puandan türetildiğinden aynı
      kademeyi göstermeli.
- [ ] **Mühür artık İSİMLERİN yanında da — yedi yüzey (18 Ağustos 2026,
      Parça 115).** Hepsinde ismin SAĞINDA, isimle aynı dikey merkezde ve
      satırın puntosuna göre boyutlanmış olmalı: hesap menüsünün başlığı
      (18px) · Skor Kartı'ndaki kendi ismin (20px) · başka bir oyuncunun
      kartı (20px) · Setup'ta 1. koltuktaki hesap adı (18px) · Arkadaşlar
      modalının ÜÇ sekmesi de (18px — "Arkadaşlar", "Davetler",
      "Ara & Ekle") · "+ Yeni Canlı Oyun" arkadaş seçici (18px) · Oyun
      davetleri kartındaki katılımcı isimleri (16px). **Skor kartlarında
      artık İKİ mühür var** — başlıktaki 34px'lik tıklanabilir mühür VE
      ismin yanındaki 20px'lik; ikisi AYNI kademeyi göstermeli.
- [ ] **"Puan bilinmiyor" ile "0 puan" AYRI (aynı parça).** Hiç oyun
      bitirmemiş bir kullanıcının yanında **Çaylak (Ç)** mührü çıkmalı
      (o gerçekten 0 puan). Ama liste ilk açılırken, puanlar gelmeden bir
      an için HERKESİN yanında Çaylak mührü BELİRMEMELİ — mühür yalnızca
      puan bilindikten sonra çizilir. YZ koltuklarında ve misafirde mühür
      HİÇ olmamalı.
- [ ] **Rozet: dalgalı disk + iki kurdele kuyruğu (18 Ağustos 2026 — eski
      tırtıklı/noter mührü TAMAMEN bırakıldı).** Her boyda AYNI siluet:
      dolu, dalgalı kenarlı bir disk + altında V kesikli iki kurdele;
      kurdele diskten bir tık KOYU. Testere dişli eski mühür HİÇBİR yerde
      kalmamalı. Fark yalnızca iç halkada: 34/76px'te harfin etrafında
      açık renkli ince bir halka VAR, 18px'lik k-lig satırında YOK (harf
      orada daha büyük). Banner'ın rakamlı glyph'lerinde ("+1000") halka
      hiçbir boyda çizilmez. **Web'deki rozetle yan yana bak — ikisi
      BİREBİR aynı olmalı** (aynı sabitler iki dosyada elle senkron).
- [ ] **Harfin yazı tipi: M PLUS Rounded 1c 800 (18 Ağustos 2026 — öncesi
      Space Grotesk).** Harf yuvarlak hatlı ve basık görünmeli. **Portta
      asıl risk TOFU:** Flutter otomatik font fallback YAPMAZ, yani alt
      kümede olmayan bir glyph BOŞ KARE olarak çizilir — özellikle Ç ve Ş
      mühürlerine bak. Rakamlı banner glyph'i ("+1000") madalyonun dışına
      TAŞMAMALI. Web'deki rozetle yan yana bak: aynı font, aynı punto.
- [ ] **Harf dikeyde ortalı — kuyruklu olanlar dahil.** Ç ve Ş (sedillalı)
      mühürlerde harf, dairenin dikey ORTASINDA durmalı — alta kaçmış
      GÖRÜNMEMELİ. Ç ile M/O/U/D aynı hizada olmalı. Üç boyu da kontrol et
      (18px k-lig satırı, 34px kart başlığı, 88px banner). Web'deki aynı
      mühürle yan yana bak: iki platform BİREBİR aynı hizada olmalı
      (`sealBaselineEm` ↔ web `baselineY`, ikisi elle senkron).
- [ ] **Mühür popup'ı.** Skor Kartı başlığındaki mühre dokun: damga
      animasyonuyla bilgi popup'ı açılmalı (kademe adı + puan + "+N eşik
      ödülü dahil" + sıradaki rütbe hedefi + hedefe AKAN ilerleme çubuğu;
      en üst kademede çubuk yok). İstendiği kadar tekrar açılabilmeli —
      kutlamanın aksine "bir kez göster" kuralı YOK.
- [ ] **✕ var, "KAPAT"/"DEVAM" butonu YOK — popup'ta DA banner'da DA.**
      (12 Ağustos 2026, kullanıcı: "bu banner'larda kapat, devam vb
      olmamalı, sadece X". Önce yalnızca popup'a uygulanmıştı, aynı gün
      kutlama/düşüş banner'ına da genişletildi.) Kapatma yalnızca sağ
      üstteki ✕ ile; kartın altında tam genişlikte bir buton OLMAMALI.
      **KRİTİK — ✕ yalnızca kapatmıyor:** banner'da ödülleri "görüldü"
      işaretleyen tek yol o. Kapattıktan sonra uygulamayı yeniden başlat:
      banner **BİR DAHA ÇIKMAMALI**. Çıkıyorsa ✕ `markSeen`'e bağlanmamış
      demektir (bilgi popup'ında ise tam tersi doğru: o hiçbir şeye
      dokunmaz, istendiği kadar açılır).
- [ ] **Kart gölgesinde beyaz hale yok.** Hem bilgi popup'ının hem
      kutlama/düşüş banner'ının kartı karartılmış zeminde yalnızca
      yumuşak, koyu bir düşen gölge taşımalı — sol/üst kenarda beyaz bir
      parıltı GÖRÜNMEMELİ. Mührün kendi 88px'lik dairesi nömorfik
      kalmaya devam eder (o doğru). İkisi aynı kart: biri değişirse öteki
      de kontrol edilmeli.
- [ ] **Rozet renk kuralı.** İlerleme çubuğunun altında: ALINMIŞ ödül
      YEŞİL "(+5)" + onay işareti, henüz alınmamış hedef ödülü GRİ "(+10)"
      ve onay işareti YOK. Onay işareti gerçekten bir tik olarak
      görünmeli — boş kutu (tofu) DEĞİL (Space Mono bu glyph'i içermiyor,
      port Material ikonunu kullanıyor).
- [ ] **Rütbe düşmeli.** -2 ceza alıp eşiğin altına inen hesabın mührü üç
      yerde de bir alt kademeye İNMELİ. Puan tekrar eşiği aşarsa damga
      geri gelir ama kutlama İKİNCİ kez ÇIKMAMALI, ödül İKİNCİ kez
      VERİLMEMELİ.
- [ ] **Rütbe düşüş banner'ı.** Konfetisiz, üzgün banner ("Rütben
      geriledi! 😔 … Kazandıkça geri yükselirsin!") — **başlıktaki üzgün
      emoji GERÇEK emoji olmalı, boş kare (tofu) DEĞİL.** Boş kare
      görürsen `fontFamilyFallback` düşmüş demektir. Not: web test
      derlemesinde (CanvasKit) emoji ağdan çekilir; ağ kısıtlıysa boş
      görünebilir — bu native'de YAŞANMAZ, FAZ B'de kesin doğrula.
      Banner'da ayrıca kaybedilen eşiğe geri
      dönüş çubuğu; hedef etiketi YALNIZCA SAYI ("100" — "puan" kelimesi
      yok, o zaten bir üstteki "Sıradaki rütbe" satırında geçiyor) ve
      altında yeşil "(+10)"+tik (ödül zaten alındı). Görülmemiş OLUMLU
      bir kutlamayla çakışırsa yalnızca olumlu olan gösterilmeli.
      **Test satırını uygulama KAPALIYKEN ekle** — açıkken eklersen host
      bir sonraki öne-dönüş/kontrolünde banner'ı beklenmedik bir anda
      gösterir, refleksle kapatılır ve kayıt "görüldü" işaretlenir
      (12 Ağustos 2026'da tam bu oldu: satır 20:50'de eklendi, 20:51'de
      kapatıldı, sonra "banner çıkmadı" diye raporlandı — kayıt çoktan
      harcanmıştı). Kod tarafında SESSİZ bir işaretleme yolu yok:
      `markSeen` yalnızca gösterilen bir banner kapatılınca çağrılıyor.
- [ ] **Misafirde hiç çıkmaz.** Girişsizken oyun bitir: banner
      görünmemeli, hiçbir ağ isteği atılmamalı. Sonradan giriş yapınca
      (kuyruk sunucuya işlendikten sonraki ilk kontrolde) kutlama
      çıkabilir.
- [ ] **Uçak modu.** Ağ yokken banner çıkmamalı ve uygulama hiç
      takılmamalı; ağ dönüp uygulama öne alınınca (arka plandan dönüş)
      bekleyen kutlama kendiliğinden gösterilmeli.
- [ ] **Seviyeye göre puan — Kolay (6 Eylül 2026, ROADMAP #23 Faz 4;
      web'in aynı listesi kök `TESTING.md` §10).** Girişli hesapla Yapay
      Zeka sekmesi → "+ Yeni" → `OYUNCU SAYISI`nın ALTINDA **ZORLUK**
      satırı: `KOLAY` · `NORMAL` · `ZOR` (Zor Faz 5'le, 7 Eylül 2026'da
      girdi — web ile aynı PR; **1.0.8 turunda ZOR'la bir oyun oyna:** YZ
      hamleleri gözle görülür takılma olmadan gelmeli, şeritte ve oyun
      sonunda KIRMIZI `Zor`, birincilik k-lig **+4**), varsayılan NORMAL
      seçili. Seçicinin altında seçili seviyenin açıklaması, web ile
      BİREBİR: Normal'de "Orta-iyi seviye bir oyuncuyum… birincilik 2 k-lig
      puanı kazandırır, ikincilik puan kazandırmaz.", KOLAY'a dokununca "Çok
      iyi değilim… birincilik 1 k-lig puanı kazandırır, ikincilik puan
      kazandırmaz."; 4 OYUNCULU'ya geçince Normal: "birincilik 2, ikincilik 1
      k-lig puanı kazandırır" (7 Eylül 2026: her bileşimde ikincilik de
      yazılır). **Girişsiz** açınca puan cümlesinin ardında AYRI bir not var:
      "(Puan takibi üyelik gerektirir)" — nokta parantezin ÖNÜNDE, Zor'da
      "Bol şans!" en sonda; girişli hesapta not YOK (`ai_level_parity_test`
      kilitliyor). Misafir Setup'ında "Nasıl oynanır? · Tanıtım" satırının
      üstü/altı web ile birlikte daraltıldı ve EŞİTLENDİ: paragraf→link ve
      link→"OYUN TİPİ" arası ikisi de 16px (SizedBox 16→8 üstte, 20→8
      altta; dokunma hedefi 48→32).
      Oyunu başlat, "← Geri" ile Setup'a dön: "DEVAM
      EDEN OYUNLAR" kartında avatarların hemen SAĞINDA küçük YEŞİL `Kolay` rozeti
      (Normal oyun kartında TURUNCU `Normal`; kural: Kolay yeşil · Normal
      turuncu · Zor kırmızı, YZ oyununda her seviyede; Canlı kartında HİÇ
      rozet yok — web ile aynı). ZORLUK butonları Arkadaşınla sekmesinin
      DEVAM EDENLER / OYUN DAVETLERİ / SON OYNANANLAR pilleriyle AYNI boy ve
      puntoda, OYUNCU SAYISI'nın büyük butonu gibi DEĞİL. Oyun içinde
      tahtanın altındaki şeritte "Hamleler · Kolay" (Canlı oyunda orada
      "· Mesajlaşma" var, rozet yok; şerit tek satırda kalmalı). Oyunu
      birinci bitir: oyun sonu penceresinde başlığın altında `Kolay` rozeti
      ve k-lig sütununda **+1** (Normal'de turuncu rozet, +2). "Son Oynadıklarım"da tarihin yanında
      rozet ve +1; "Tüm Oyunlarım"da "Yapay Zeka" rozetinin sağında `Kolay`
      ve +1; kartı beğenip **Favoriler**'de de aç (ayrı RPC,
      `list_liked_games`) — orada da +1. Skor Kartı/k-lig listesindeki
      toplam da +1 artmalı (sunucu `league_points_for` ile aynı sayı; kart
      +1 gösterirken liste +2 artıyorsa iki kopya ayrışmış demektir). Oyun
      sonu "TEKRAR OYNA" → yeni oyun da Kolay (devam eden kartında rozet).
      **Web ↔ port (ROADMAP 23.5 kapanış ölçütü):** portta Kolay bitirilen
      oyun web'de aynı puan ve rozetle görünmeli, tersi de (aynı hesap, iki
      cihaz); portta Kolay başlatılıp bulut kaydına düşen oyun web'de devam
      ettirilince YZ Kolay oynamalı (Setup kartında rozet) ve tersi. Canlı
      oyun kartlarında rozet HİÇBİR koşulda çıkmaz.
- [ ] **Kart altı PUAN SATIRI — HİZA** (6 Eylül 2026, kullanıcı isteği; web
      ile birebir): Yapay Zeka ↔ Arkadaşınla sekmelerindeki devam eden oyun
      kartlarında avatarların hemen altında koltuk sırasıyla anlık puanlar,
      **her sayı KENDİ AVATARININ TAM ALTINDA** (ayırıcı tire YOK).
      ⚠ **Asıl kontrol 4 KİŞİLİK + üç haneli puanlar**: dört sayı da kendi
      yüzünün altında ve birbirine değmiyor olmalı — ilk tur tek dizeydi ve
      kullanıcı tam burada kaymayı yakaladı. ⚠ Canlı kartında **"X açtı"
      satırı ARTIK YOK**. Rakip hamle yapınca puan oyuna girmeden
      tazelenmeli (Realtime → `_reload`). "Son Oynadıklarım"da tarih
      (+ zorluk rozeti) avatarların ÜSTÜNDE, bitiş puanları altında; sağdaki
      puan/k-lig sütunları (`ScaledCell`) yerinde.
      ⚠ **Yazı boyutunu %130'a al ve hizayı TEKRAR bak:** avatarlar
      ölçekle büyümediğinden puan hücreleri de büyümüyor (bilinçli — bkz.
      `AvatarScoreRow`); sayılar yine kendi yüzlerinin altında kalmalı.
- [ ] **Yardım → zorluk paragrafı** (6 Eylül 2026, kullanıcı düzeltmesi):
      *"4 kişilik oyunda; Kolay'da birinci +1 k-lig puanı alır, ikinci puan
      almaz; Zor'da birinci +4, ikinci +2 k-lig puanı kazanır."* — cümle
      web `HelpModal` ile BİREBİR (`ai_level_parity_test` kilitliyor).
- [ ] **Web ↔ mobil aynı toplam.** Aynı hesabın "Genel" lig puanı iki
      platformda BİREBİR aynı olmalı ("Genel = 2 kişilik + 4 kişilik +
      eşik ödülü" — mod bazlı sekmelerin toplamı ödül kadar EKSİK olur,
      bu doğru; fark popup'taki "+N eşik ödülü dahil" satırıdır).

---
