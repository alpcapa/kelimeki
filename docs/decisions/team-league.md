# Takım Ligi — 2'şer kişilik takım oyunu (TASARIM ÖNERİSİ, 3 Ekim 2026)

> **Durum: TASARIM ONAYLANDI, PARKTA (3 Ekim 2026) — KOD YOK; kodlama 12 Ekim
> treninden sonra, hedef 19 Ekim treni (ROADMAP #44).** Eski satır: ~~ÖNERİ,
> onay bekliyor~~. Kullanıcı isteği
> (3 Ekim 2026): *"Bu fikri analiz edip tüm akışı ve görselleri hazırla,
> kodlama yok henüz. Atladığım detaylar varsa hepsini ekle. Her şey
> istediğim gibi olursa sonraki sürümlere girer."* Görsel taslaklar
> (ekranlar + akış diyagramları) artefakt olarak yayınlandı; bağlantı
> `ROADMAP.md` → #44 satırında. Onaylanınca bu dosya KARAR KAYDI olur,
> açık sorular (§10) kapanır.

## 1. İstek, kendi cümleleriyle

- 4 kişilik oyunda **2'şer kişilik takımlar**. Takım kur, oyun aç (herkes
  kabul edebilir). **Takım Ligi**: takımların aldığı puana göre sıralama.
- **Takım OHP'si** olacak; hamle geçmişinde Toplam · Takım puanı · Takım
  vergisi (+/−).
- **Son Oynananlar**'a normal oyun gibi girecek; etiket/bant rengi farklı
  (silik pembe vb.).
- "Arkadaşınla" → 4 oyuncu seçilince **Normal oyun | Takım oyunu** sekmeleri.
  Normal oyun varsayılan, bugünkü ekranın aynısı.
- Takım oyunu sekmesi: **Takımlarım** bandı. Takım kurmak için aşağıdaki
  listeden 1 kişi seç, takım adı yaz, Kaydet → Takımlarım'a girer.
- **Oyun Aç** → takım seç → oyun başlat. Açılan oyunlar **Açık Oyunlar**
  listesinde, yanında **Kabul Et**; herkes kabul edebilir.
- Takım üyesinden biri kabul edince arkadaşı **otomatik kabul etmiş** sayılır.
- Setup'ta **Takım Ligi bölümü**, altında açık oyunlar.
- Kabul eden kişinin takımı yoksa **takım oluştur** adımına gider. Arkadaşın
  onayı gerekeceğinden oyun REZERVE EDİLMEZ; sonra tekrar Kabul Et'e basılır.
- k-lig penceresinde **Takım Ligi**: yalnızca puana göre, eşitlikte takım
  OHP'si; "aynı puan ligi formatı".

## 2. Terimler (tek ad, ikinci ad UYDURMA)

| Terim | Anlamı |
|---|---|
| **Takım** | Tam 2 üye, kalıcı, adı var. İki kişi bir kez onaylar, sonra istediği kadar oyun |
| **Takım oyunu** | 4 kişilik Canlı oyun, iki takım karşı karşıya, YZ YOK |
| **Açık oyun** | Bir takımın kurduğu, rakip bekleyen, girişli herkese görünen ilan |
| **Takım Ligi** | k-lig'in üçüncü alt ligi (🤝), takım puanına göre |
| **Takım puanı** | Üyelerin o oyundaki skorlarının TOPLAMI |

## 3. Motor: ORTAK BÖLGE motora dokunur (Revizyon 2 ile değişti)

İlk taslak "motora dokunmaz" diyordu (ortağın bölgesine girince vergi, ayrı
renkler). Kullanıcı bunu **ters çevirdi**: *"aynı renkte oynayacaklar, 2 kişilik
oyuncu seçildiğinde gibi. Arkadaşınla aynı bölgeyi büyüteceksin. İlk hamle
dışında arkadaşının bölgesini de büyütebileceksin; veya kendi bölgenden
arkadaşının bölgesine bağlayabilirsin."* Bu doğru ve daha iyi bir oyun, ama
**bölge hesabı takım bilir hâle gelmek zorunda** (bedel §9).

| Kural | Karar |
|---|---|
| Koltuk / köşe | Sıra **A-B-A-B saat yönünde**: koltuk 0 = A (köşe 0, sol-üst), 1 = B (köşe 1, sağ-üst), 2 = A (köşe 3, sağ-alt), 3 = B (köşe 2, sol-alt). **Takımlar çapraz köşelerde** (A: ↖ ↘, B: ↗ ↙), ortaklar art arda oynamaz |
| Renk | **Takım başına tek renk** (A camgöbeği, B kırmızı — 2 kişilik oyunun iki rengi). Taşlar, bölge dış hattı, bant hep takım renginde. `Player.colorIndex` zaten koltuktan ayrı bir alan, ikisi aynı değeri taşır |
| Oyuncu/avatar renkleri (Revizyon 12, kullanıcı: *"2 kişilik oyun renkleriyle aynı olsun"*) | Yalnızca **iki renk**: takım A **camgöbeği** (`PLAYER_COLORS[0]`), takım B **kırmızı** (`[1]`) — 2 kişilik oyunun `colorIndex = i` ile atadığı renklerin aynısı (kodda doğrulandı, `gameReducer.startGame`). Ortakların avatarı AYNI renk; dört ayrı oyuncu rengi (yeşil/mor) takım oyununda KULLANILMAZ. Listelerde bir takımın iki avatarı tek renk; iki takımlı satırda (Devam ediyor) 2 camgöbeği + 2 kırmızı. İlan açan = A, kabul eden = B. Normal 4 kişilik Canlı oyun dört rengini korur. Sunucuda `init_online_game_state` takım oyununda `colorIndex` 0,1,0,1 yazar |
| Ortak bölge | Takımın bölgesi = **iki ortağın köşelerinden ve iki ortağın taşlarından** tek zincir. Ortak bölgeyi büyütebilir; kendi bölgenden ortağın bölgesine bağlanabilirsin, iki parça birleşir |
| Takım içi vergi | **YOK.** Ortağın bölgesi senin bölgendir. Vergi yalnızca **rakip takıma** ödenir/alınır; n (etkileşilen rakip bölge sayısı) rakip TAKIM sayısıdır (tek rakip takım = n=1) |
| İlk hamle | Kural aynı, ortağınki değil **kendi** başlangıç karen (her oyuncunun kendi ev işareti var). Sonraki hamleler serbest |
| Alınan vergi kişilere nasıl yazılır (S13) | **Ödeyen = hamleyi yapan kişi** (bugünkü gibi). **Alan = rakip takım; payı iki ortağa EŞİT bölünür**, artan tek puan koltuk sırası düşük olana. Takım puanı toplam olduğundan bölüşüm onu değiştirmez. Örnek: Selin 30 puanlık hamlede A'nın bölgesine girer, n=1 → pay 10: Selin +20, Ece +5, Mert +5. Pay 3 ise Ece +2, Mert +1. Takım içi vergi yok. Gösterim: geçmişte Selin'in satırı "−10 vergi", Takım vergisi(+) kutusu takım toplamı, bitiş ekranı kişi skoru payları içerir. Uygulama: mevcut `shares:[{index,amount}]` yapısına takımın iki koltuğu yazılır, yeni alan gerekmez. Alternatif "takım kasası" motorda takım düzeyinde yeni puan alanı ister, önerilmez |
| YZ | Takım oyununda YZ koltuğu YOK |
| Teslim / 48 sa zaman aşımı | Motorun kademeli teslimi aynen: teslim olanın skoru 0, rafı torbaya. **Teslim olanın köşesi** doğal alana döner, ortağın zinciri sürer |
| Oyun bitişi | "Aktif oyuncu 1'e düşünce biter" takım oyununda yetmez. **Yeni kural: bir takımın TÜM üyeleri teslimse biter.** Yalnızca SQL (`check_turn_timeout`) |

**Geriye dönük güvenlik (en önemli mühendislik ilkesi):** `Player.team` alanı
**opsiyonel**. Alan yoksa her oyuncu kendi takımıdır ve hesap **bayt-eş** eski
davranıştır. Böylece mevcut golden vector'lar DEĞİŞMEDEN geçmeli — takım
oyunu dışındaki hiçbir oyun etkilenmediğinin kanıtı. Yeni fixture'lar yalnızca
takımlı durumları ekler.

## 4. Takım yaşam döngüsü

```
Kur (kurucu + 1 arkadaş seçer, ad yazar)
  └─► ONAY BEKLİYOR (arkadaşa davet gider; 7 gün)
        ├─ kabul ─► AKTİF  (Takımlarım'da, oyun açılabilir)
        ├─ ret / 7 gün ─► İPTAL (listeden düşer)
        └─ (kurucu iptal eder) ─► İPTAL
AKTİF ── üye "Takımdan ayrıl" ──► DAĞILDI (geçmiş + lig kaydı kalır)
```

- **Kimler:** üye ancak **arkadaşın** olan biriyle takım kurabilirsin (davet
  mekanizması zaten arkadaşlık üstünde). Rakipler arkadaş OLMAK ZORUNDA DEĞİL
  (Canlı oyundaki "tek yönlü kadro" ilkesiyle aynı).
- **Ad:** 3–16 karakter, **benzersiz** (`trLower` ile büyük/küçük harf ve
  i/ı duyarsız), sohbetteki engelli kelime listesinden geçer. Kullanıcı adı
  uygunluk denetimi (`useNicknameAvailability`) deseni.
- **Sınırlar (öneri):** aynı iki kişi arasında TEK takım; kullanıcı başına en
  çok **5 aktif takım**; takım başına aynı anda **1 BEKLEYEN ilan** (kabul edilmemiş). İlan kabul edilip oyun başlayınca takım yeni ilan açabilir (eşzamanlı oyun sınırı aşağıda).
- **Ayrılma:** takımın açık ilanı veya aktif oyunu varken ayrılma KAPALI
  ("önce oyunları bitir"); aksi halde yarım oyunda ortak kaybolur.
- **Hesap silme:** üyesi silinen takım `DAĞILDI` olur, lig kaydı korunur, silinen
  üye "Silinmiş kullanıcı" gösterilir. Yeni nullable FK = SÖZLEŞME değişikliği:
  `docs/decisions/account-deletion.md` → "SET NULL'ın bedeli" uygulanır
  (`database.types.ts` + portun `fromJson`'ı).

## 5. Açık oyun akışı

### 5.1 Gezinme: üçüncü oyun türü ve ana sayfası (Revizyon 3)

- **Revizyon 4 (3 Ekim 2026, kullanıcı):** **Setup'a takım bölümü/kartı EKLENMEZ.**
  Arkadaşınla altında takım detayı çıkmaz; Setup bugünkü gibi kalır. Takımla
  ilgili her şey "+ Yeni Canlı Oyun" içinde. (İlk istekteki *"Setup'da Takım
  Ligi bölümü altında açık oyunlar"* böylece Takım sekmesinin içine taşındı.)
- **Sekmeler en üstte, şimdiki gibi:** `2 Kişi | 4 Kişi | 🤝 Takım`. Üstte
  "‹ Yeni Canlı Oyun" geri satırı YOK. 2 ve 4 bugünkü sistemin aynısı.
  Yapay Zeka sekmesine DOKUNULMAZ.
- **Takım sekmesinin içeriği** (aynı sayfada, form açılmaz), YUKARIDAN AŞAĞI:
  1. **Takımlarım** (+ Takım Oluştur). Altında yönerge: **"Oyun açmak için
     takımın üstüne tıkla"**. **Gelen davet** listenin BAŞINDA: *"Zeynep seni
     takımına davet etti"* + Kabul Et / Reddet. Satırlarda yalnızca **sıra ve
     puan** ("4. sıra · 22 puan"); durum etiketi sağda (Aktif / Onay bekliyor),
  2. **Açık Oyunlar** (yanında Kabul Et).
- **Oyun açmak tek dokunuş (Revizyon 8, kullanıcı: *"çok basit olmalı"*):**
  büyük "Oyun Aç" butonu ve takım seçme sheet'i YOK. Aktif takımın satırına
  tıklayınca **sağdaki durum etiketi (Aktif) "Oyun Aç" butonuna döner**; butona
  basınca ilan **hemen** açılır (soru yok), altta kısa bildirim *"Oyun açıldı.
  Rakip bekleniyor."* Takımın bekleyen ilanı varsa etiket **"Açık oyun"** olur; satıra tıklayınca bildirim *"Rakip bekleniyor. Biri onu kabul edince yeni oyun açabilirsin."* çıkar ve
  buton çıkmaz (takım başına 1 bekleyen ilan); biri kabul edip oyun başlayınca
  etiket yine **"Aktif"** olur (Revizyon 12 teyidi) ve takıma tıklayınca **tekrar Oyun Aç** çıkar; 3 devam eden oyuna ulaşınca "Oyunların dolu"
  (Revizyon 10, kullanıcı). Aktif takımın yoksa yönerge yerine
  *"Önce bir takım kur"* yazar.
- **Kendi ilanını kabul edemezsin:** ilanı açan takımın İKİ üyesinin gözünde de
  satırda Kabul Et yerine **"Bekliyor"** etiketi. İlanı iptal etmek için
  satıra dokunulur (küçük onay: "İlanı iptal et"). Sunucu da reddeder
  (`accept_open_game`: kabul eden takım ile ilan takımı üye paylaşamaz).
- **Liste boyutu / yükleme (Revizyon 7):** sayfa TEK kaydırma alanı (iç içe
  kaydırma yok). Bu yüzden uzayabilen liste EN ALTTA: **Açık Oyunlar sunucu
  sayfalıdır, ilk 10 satır, sonra kaydırdıkça 20'şer** (`IntersectionObserver`,
  `Leaderboard`/`BeyinLigiList` ile aynı `INITIAL_PAGE_SIZE=10`/`PAGE_SIZE=20`
  deseni; RPC `list_open_team_games(limit, offset)` + toplam sayı). Sıra:
  kendi ilanın üstte, sonra en yeni; kararlı sayfalama için `created_at desc,
  id`. **Takımlarım sayfalanmaz** (en çok 5 aktif takım + bekleyenler).
  **Eşzamanlı oyun sınırı (kullanıcı onayı, Revizyon 11):** bir takım aynı anda en çok **3 devam eden oyun** sürdürür (iki taraf için de: kendi açtığı ya da kabul ettiği). Dolunca takımın etiketi **"Oyunların dolu"**, Oyun Aç çıkmaz, Kabul Et listesinde soluk ve seçilemez; biri bitince açılır.
  **Kabul edilen oyun listeden KALKMAZ (Revizyon 10):** satır listenin SONUNDA
  "Devam ediyor" (iki takım adı, soluk, dokunulmaz) olarak durur; oyun bitince
  düşer. Sıra: bekleyen ilanlar (kendi ilanın üstte, sonra en yeni), sonra
  devam edenler (en yeni önce). Başlıktaki sayı yalnızca bekleyenleri sayar.
  Neden: ileride başkaları tıklayıp izleyebilsin (ürün fikri, kapsam dışı). Boş durum: "Henüz açık oyun yok. İlk ilanı sen aç." Yenileme: paylaşılan tek
  Realtime kanalı (`verify-shared-realtime`) + öne dönüş; kaydırılmış listede
  yeni ilan araya girmez, üstte "N yeni ilan" der. Port: Flutter'da iç içe
  `ListView` YOK (`mobile/CLAUDE.md`, `KModal` dersi) — `KModal` gövdesi
  kaydırılabilir zaten, düz `Column` + alt eşikte sayfa isteme (`kAllUsersPageSize`
  deseni).
- **Takım Oluştur:** Takım sekmesinden ya da takımsız Kabul Et'ten (§6) gelinen
  tek ekran (arkadaşlardan 1 kişi + ad + Kaydet); geri okuyla döner.
- **Devam eden takım oyunları** Arkadaşınla'daki **Devam Edenler** listesinde,
  biten oyunlar **Son Oynananlar**'da, ikisinde de normal oyun gibi girer.
  Ayrışma hafif: zemin çok açık pembe, solda pembe çizgi, "TAKIM" etiketi.
  **Kart düzeni DEĞİŞMEZ (Revizyon 13, kullanıcı):** bugünkü `GameRow`
  (`LiveGamesTab`) ve `_RecentRow` aynen; sağ sütun **"SIRA SENDE ▲ / SIRA
  RAKİPTE ●"** (ve Son Oynananlar'da ortadaki OYUN BİTTİ + sağdaki skor/k-lig
  sütunları) yalnızca bu duruma ait, **TAKIM etiketi oraya girmez** (gerçek
  kartta CANLI etiketi de yoktur; ilk mock'larımdaki CANLI/TAKIM rozeti uydurmaydı).
  Etiket konumu: **Devam Edenler'de avatar+puan sütununun ALTINDA** (sol, kendi
  satırı; yatay sıkışma yok, 320 px'te güvenli — yalnızca takım kartı ~12 px
  uzar), **Son Oynananlar'da tarihin YANINDA** (YZ oyunundaki zorluk rozetinin
  yeri). Avatar sırası takım gruplu (A A B B), puan satırında kişi puanı yerine
  **takım toplamı, her çiftin ilk avatarının altında** (ikincisi boş). Port ikizi:
  `devam_eden_govde.dart` / `_RecentRow`. Yer alternatifi (avatarların sağı)
  320 px'te sıkışır, önerilmez.
- **k-lig → Takım Ligi satırı:** sütun sırası **OHP solda, puan sağda**
  (başlık "OHP · puan").

### 5.2 İlan ve kabul

1. **Oyun Aç:** üye, aktif takımının satırına tıklar, sağdaki etiket "Oyun
   Aç"a döner, basınca ilan açılır (§5.1). Ortağı OTOMATİK katılır (onay sorulmaz: takıma
   girerken onay verdi) ve **bildirim** alır (push + uygulama içi): *"Ali, ‹Takım›
   adına açık oyun açtı."*
2. **Açık Oyunlar listesi** (girişli herkes görür): kurucu takım adı + iki
   avatar + takımın puanı/sırası + ilanın yaşı + **Kabul Et**. Kendi
   ilanlarında Kabul Et yerine **İptal**.
3. **Kabul Et (Revizyon 9, kullanıcı):** basınca **alttan takım listesi**
   ("Hangi takımla kabul ediyorsun?") açılır; **takıma dokunduğun anda oyun
   başlar** (ayrı onay butonu yok). Satırlarda sıra ve puan; onay bekleyen
   takım soluk, seçilemez.
   - **Liste boşsa** (aktif takımın yoksa): *"Henüz takımın yok. **Takım
     oluştur.**"* — basınca Takım Oluştur adımına gider (§6). İlan KİLİTLENMEZ.
   - Kabul eden takımın ortağı OTOMATİK katılır, bildirim alır.
   - Sunucuda **tek atomik işlem** (`for update` kilidi): ilan `pending`→`active`,
     4 koltuk atanır, `init_online_game_state` çalışır. İki takım aynı anda
     basarsa ilki kazanır, öteki *"Bu oyun doldu"* görür ve liste tazelenir.
   - **Yasaklar:** iki takımın ortak üyesi olamaz; takım `onay bekliyor` iken
     kabul edemez.
4. **Süre:** ilan **7 gün** (Canlı davet ve yerel oyun süresiyle AYNI); dolunca
   `abandoned`, ceza yok. Kurucu tarafı istediği an iptal edebilir.
5. **Oyun başlayınca** dört kişi de "Aktif Oyunlar"da görür (Arkadaşınla
   sekmesi), sıra bildirimleri mevcut `notify-your-turn` ile gelir.

## 6. Takımı olmayan biri Kabul Et'e basarsa

```
Kabul Et ─► alttan takım listesi: "Henüz takımın yok. Takım oluştur."
              └─ Takım oluştur ─► Takım Oluştur ekranı (arkadaş seç + ad)
                    └─ Kaydet ─► takım ONAY BEKLİYOR (arkadaşa davet gitti)
                         └─ "Arkadaşın kabul edince Açık Oyunlar'a dönüp Kabul
                            Et'e tekrar bas. Oyun senin için tutulmaz."
                            (ilan açık listede KALIR, başkası alabilir)
```

Bilinçli: ilan rezerve edilmez (kullanıcı: *"oyunu bloke edemeyiz"*), yoksa
onay vermeyen bir arkadaş başkasının oyununu bloke eder. Takım kurulunca
oyun otomatik başlamaz; kişi Açık Oyunlar'a dönüp Kabul Et'e tekrar basar ve
listeden takımını seçer. Arkadaş onaylayınca takımın sahibine bildirim:
*"‹Takım› hazır. Açık oyunlara dön."*

## 7. Oyun içi, Oyun Geçmişi, bitiş ekranı, Son Oynananlar

- **Oyun ekranı: düzen DEĞİŞMEZ (Revizyon 5, kullanıcı: *"Alıştığımız her
  şey aynı kalmalı"*).** Header'daki skor kutuları (`GameHeader`) aynı yerde,
  aynı boyutta ve aynı stilde kalır; yalnızca dört yerine **iki kutu**:
  üstte takım adı, altında takım puanı, takım renginde. Üste yeni bir kart
  satırı EKLENMEZ. "Sıra sende" / "Sıra: X bekleniyor" bilgisi bugünkü gibi
  alttaki mesaj kutusunda ve **X sırası gelen KİŞİNİN adıdır, takımın değil**
  (kutuda hangi ortağın oynayacağı görünmediği için). Tahta, raf, butonlar aynı. Sırası gelen takımın
  kutusu bugünkü gibi kalın çerçeveli. Kutuya dokununca açılan skor kartı
  penceresi bugünkü gibi çalışır, takım için iki üyenin kartını gösterir (S17).
- **Oyun Geçmişi** (`MoveHistoryModal`) (Revizyon 8): **alt kısım (hamle
  satırları) bugünküyle AYNI**: "sıra no. oyuncunun adı", kelime ve puanı,
  Sınır İhlali etiketi, "N puanı X kaptı" notu. Değişen yalnızca üstteki dört
  kutunun SAYILARI, hepsi takımın: **Toplam · (takım adı = takım puanı) ·
  Vergi(−) · Vergi(+)** (bugünkü ikinci kutu `me.name` + skor, burada takım adı
  + takım puanı). Vergi yalnızca rakip takımla; alan taraf takım olduğundan
  not *"10 puanı Kıvılcım kaptı"* der. `moveHistoryStats` takım bilgisini alır;
  web ↔ Dart.
- **Bitiş ekranı (Revizyon 2):** mevcut `GameOver` ızgarası (`ad · Kalan ·
  Toplam · k-lig`) aynen, iki takım için iki blok:
  - **Takım satırı:** takım adı · (boş) · **takım toplamı** · **+2** (kazanan)
    ya da 0. Başlıkta *"KIVILCIM KAZANDI"* (ya da BERABERE).
  - **Altında iki kişi satırı:** ad · **Kalan** (elde kalan taşların değeri,
    `−N`) · **Toplam** (kişinin skoru) · **k-lig** (`+2` ya da `0`; teslimde
    `−2`). Bugünkü kuralın aynısı; yalnızca ızgaraya takım satırı eklenir.
- **Son Oynananlar:** normal oyun gibi satır; **silik pembe bant + "TAKIM"
  etiketi**. Gri CANLI'dan ayrışır. Takım adları satırda yazar. Bant rengi
  `#F9D7E6` / yazı `#9C2A5F`. **Pembe yalnızca "bu bir takım oyunu"
  işaretidir**; oyun içindeki takım renkleri camgöbeği ve kırmızıdır (Revizyon 2:
  önceki amber/pembe takım rengi önerisi KALKTI).

## 8. Puanlama ve Takım Ligi (Revizyon 2)

Kullanıcı: *"Takım ligindeki puandan kastım kazanınca kazanılan takım puanı:
galibiyet 2 puan, ikinciye puan yok. Kazanan takımın oyuncularının ikisine de
+2 yazacak ayrıca. Takım 2 puan alacak, oyuncular +2 alacak."*

| Konu | Karar |
|---|---|
| Takım puanı | Kazanan **+2**, kaybeden **0**. Beraberlik tanımsız (S14, öneri +1/+1) |
| Oyuncu k-lig puanı | Kazanan takımın İKİ oyuncusu da **+2**, kaybedenler **0**, teslim olan **−2** (bugünkü kural) |
| **Uygulama: sunucu formülü DEĞİŞMEZ** | `games`'e yazılan **sıra**: kazananlar `rank=1,1`, kaybedenler `rank=3,3`. `league_points_for(rank, 4, surrendered, null)` zaten 1.→+2, 3.→0 verir. `verify-league-points` ve beş nesne etkilenmez. Beraberlikte dördü `rank=2` → +1 |
| Takım puanı toplamı | Takım Ligi puanı, `team_game_results` toplamı |
| Sıralama | Takım puanı ↓, eşitlikte **takım OHP'si** ↓, sonra oyun sayısı ↓, sonra takım id |
| Takım OHP'si | İki üyenin takım oyunlarındaki puanlı hamlelerinin ortalaması |
| Giriş eşiği | Yok (en az 1 bitmiş takım oyunu) |
| Satır | sıra · takım adı · iki avatar · **OHP (solda) · puan (sağda)**. Rütbe mührü YOK |
| "Senin sıran" | En iyi takımının satırı, pencerenin içinde (Beyin Ligi #796 dersi) |
| Alttaki not | *"Galibiyet 2 puan. Puanlar eşitse takım OHP'si yüksek olan üstte."* |
| Takım teslim cezası | Takıma ayrıca ceza YOK; teslim olan üye zaten kendi −2'sini alır |
| Bireysel OHP | Hamle puanları Beyin Ligi'ne normal girer |

## 9. Sunucu ve istemci etkisi (kod yok, kapsam haritası)

**Sunucu (migration'lar ELLE uygulanır, `grant` zorunlu):**
- Yeni tablolar: `teams` (ad, `name_key` benzersiz, durum), `team_members`
  (davet/durum, `game_invites` deseni), `team_game_results` (oyun başına her
  takım için: puan, rakip puanı, sonuç, lig puanı, vergi ±, hamle puanı
  toplamı/sayısı).
- `online_games`'e: `team_game` bayrağı, iki takım id'si, `open` ilan alanları.
  Açık ilan, koltukları DOLMAMIŞ bir `online_games` satırıdır. Bugünkü kuruluş
  (`create_online_game`) 4 koltuğu baştan ister; bunu açık ilanda GEVŞETMEK
  `list_my_online_games`, `check_invite_expiry`, rozet zinciri ve
  `fetchPendingLiveGameCounts`'ı etkiler (dört kovadan üçü `status`e bakıyor,
  dördüncüyü unutma dersi — `live-game.md`, 4 Ağustos 2026).
- RPC'ler: `create_team`, `respond_to_team_invite`, `leave_team`,
  `open_team_game`, `cancel_open_game`, `accept_open_game`, `my_teams`,
  `list_open_team_games`, `my_team_rank`; görünüm `takim_ligi_siralama`
  (`security_invoker`, `k_lig_siralama` deseni).
- `_finish_online_game_records` (oyun bitişi) `team_game_results`'i AYNI
  transaction'da yazar ve `games`'e takım sonucuna göre `rank` (1,1,3,3)
  yazar (§8). `check_turn_timeout` takım bitiş kuralını alır (§3).
- **Motor (Revizyon 2) — dört kopyada ortak bölge:** `Player.team?` (opsiyonel)
  · `cornersForTeams` (koltuk→köşe 0,1,3,2; renk 0,1,0,1) ·
  `computeConqueredChain` (tohum: takımın iki köşesi; zincir: takım üyelerinin
  taşları) · `computeAllTerritories` (ortaklar aynı kümeyi paylaşır) ·
  `computeInvasionSplit` (kendi takımını dışla, rakip TAKIMLARI say, payı
  takımın koltuklarına böl). Kopyalar: `src/utils/validator.ts` · Dart
  `kelimeki_core` · `supabase/functions/_game/validator.ts`
  (`verify-edge-engine-parity`, `play-ai-turn` yeniden deploy) · SQL
  `_km_all_territories`, `_km_conquered_chain`, `_km_foe_in_own_block`,
  `_km_fresh_corners`, `_km_invasion_split` + `init_online_game_state` +
  `submit_move` lostShares doğrulaması (hedef rakip takımın koltuğu olmalı).
  `Board.tsx` dış hattı takım başına BİR kez çizer. Kapılar:
  golden `territory.json`a takımlı vakalar (mevcutlar bayt-eş kalmalı),
  `verify-sql-engine-parity`, `move_shadow_diffs` ölçümü.
- Dönüş tipi değişen RPC'lerde `drop`+`create` ve `proacl` kontrolü (anon
  sızıntısı dersi).

**İstatistik (Revizyon 3, S16):** `player_stats` oyunları `player_count`
(2/4) ile gruplar (`20260906114252` migration'ı, ölçüldü). Takım oyunu
`player_count=4` yazılırsa 4 kişilik kazanma oranı ve Skor Kartı bozulur.
Çözüm: `games`'e **mod işareti** (ör. `team_game_id` ya da `mode='team'`),
`player_stats` bunu ayırır, Skor Kartı'na **Takım** satırı, `total_score`
(k-lig Genel) takım puanlarını da toplar. Bu **beş nesnenin** (`player_stats`,
`player_stats_overall`, `leaderboard`, `_award_league_rewards`,
`trg_award_league_rewards`) hepsini ilgilendirir: dönüş tipi/kolon değişimi
→ `drop`+`create` ve `proacl` kontrolü; "Genel = 2 + 4 + Takım + ödül"
değişmezi güncellenir; `verify-league-points` formülü sınamaya devam eder,
görünüm toplamları için yeni bir kontrol gerekir. `GameOver`/`GameHistoryModal`/
`SharedGamePage`/head-to-head gibi `player_count`a bakan yüzeyler takım
satırını tanımalı.

**Web:** `types.ts`/`constants.ts`/`validator.ts` (motor), `Setup.tsx` (Takım Ligi kartı), `LiveGameCreateForm.tsx`
(Normal | Takım oyunu), `LiveGamesTab.tsx` (pembe bant), `RecentGamesSection`,
`MoveHistoryModal` + `moveHistoryStats`, `PlayerScoreCard`/`GameOver`,
`Leaderboard.tsx` (üçüncü sekme `KLIG_TABS`), yeni `TeamLeagueModal`,
`TeamList`, `OpenGamesList`, `TeamCreateForm`.
**Port:** AYNI özellik ikizi (Flutter): `mobile/CLAUDE.md` parite disiplini,
`mobile/TESTING.md` yeni bölüm, ROADMAP "Sıradaki sürüme binecekler" satırı.
**Kapılar (yeni):** `verify-team-league` (SQL puan tablosu ↔ TS ↔ Dart,
`verify-beyin-ligi` deseni), `verify-sql-engine-parity` genişlemesi (bitiş
kuralı), migration–`list_migrations` eşleşmesi.
**Belgeler:** `TESTING.md` (Canlı özellik → elle liste), `mobile/TESTING.md`,
`TermsModal`/`PrivacyModal`/legal sayfalar (takım adı + üye adı/avatarı
girişli herkese görünür; açık ilanlar girişli herkese görünür), CLAUDE.md
klasör yapısı ve karar tablosu.

**Bildirimler (yeni olaylar):** takım daveti geldi · takım hazır · ortağın
oyun açtı · ilanın kabul edildi (oyun başladı) · ilanın süresi doldu. Aynı
gönderen kuralı: `noreply@` (makine). `verify_jwt` envanterine yeni Edge
fonksiyonu girerse `false` listesi güncellenir.

## 10. Kullanıcıya AÇIK SORULAR

**Kapandı (Revizyon 2):** S1 bireysel puan (takım kazanırsa iki üyeye +2) ·
S2 takım içi vergi (YOK, ortak bölge) · S3 puan tablosu (+2 / 0) · S10 takım
rengi (camgöbeği / kırmızı, pembe yalnızca liste işareti).

| # | Soru | Öneri |
|---|---|---|
| S17 | Takım kutusuna dokununca ne açılsın? | Bugünkü skor kartı penceresi, iki üyenin kartı alt alta |
| S16 | Takım oyunu istatistikte nereye girsin? (S16, §9) | Ayrı mod işareti; Skor Kartı'na Takım satırı, Genel puana dahil, 2 ve 4 kişilik satırları değişmez |
| S4 | İlan **7 gün** mü? | 7 gün (davetle aynı). Liste şişerse 48 saat |
| S5 | Takım başına **1 bekleyen ilan**, kullanıcı başına **5 takım**? | Evet |
| S20 | Kabul edilen oyun açık listede kalsın mı? | **Evet (kullanıcı kararı, Revizyon 10):** listenin sonunda "Devam ediyor", bitince düşer; ileride başkaları izleyebilsin diye. İzleme ürün fikri `product-backlog.md`te |
| S7 | Ortak oyuna **sorulmadan** katılır. "Çekil" hakkı? | Verilmesin; bildirim yeter |
| S8 | Belirli takıma özel meydan okuma bu sürümde mi? | Sonraya (`product-backlog.md`) |
| S9 | Aynı iki takımın birbirine kasten yenilmesi | v1: admin izleme. v2: aynı çift arası 7 günde en çok 3 puanlı oyun |
| S11 | Takım rövanşı | Sonraya |
| S12 | Sürüm planı | Web+sunucu bayrak arkasında önce, port 1.2.0 treniyle, açılış birlikte. ⚠ Eski mobil istemci ortak bölgeyi/rengi BİLMEZ: takım oyunu onda bozuk görünür. Bu yüzden **takım oyunu açma/kabul etme, eski sürümde engellenmeli** (minimum sürüm kapısı) |
| S13 | **Alınan vergi kişilere nasıl yazılsın?** (§3 satırı, sayılı örnek) | İki ortağa eşit bölünsün; ödeyen hamleyi yapan kişi. Bitiş ekranındaki kişi skoru paylar dahil |
| S14 | **Beraberlik** (takım puanları eşit): puan? | Her takıma **+1**, oyunculara +1 (`rank=2`). İsterseniz "eşitlikte takım OHP'si kazandırır" |
| S15 | **Motor değişikliği kabulü:** ortak bölge, motorun dört kopyasında bölge hesabını değiştirir (§9). Kabul mü, yoksa ortak bölgesiz (ayrı bölge, takım içi vergi var) sade sürümle mi başlansın? | Ortak bölge (istediğiniz oyun). Opsiyonel `team` alanı ve bayt-eş kapısı riski küçültür |

## 11. Atlanmış olabilecek ayrıntılar (taramada çıkanlar)

1. **Takım adı UGC** → sohbet engelli kelime filtresi + raporlama + admin'in
   adı değiştirmesi/takımı dağıtması gerekir (admin panelinde kalıcı yüzey).
2. **Gizlilik/Koşullar:** takım adı ve üyeleri girişli herkese görünür; yeni
   kişisel veri toplanmıyor ama GÖRÜNÜRLÜK değişiyor (`CLAUDE.md` tablosu:
   "Yeni kullanıcı verisi ya da görünürlük değişikliği → TermsModal/PrivacyModal").
3. **Rozet zinciri:** "açık oyun" bir BEKLEYEN İŞ değil haber; "takım daveti"
   bekleyen iştir (sayaç). Yeni alanlar rozet zincirine girmeli mi kararı
   ayrıca verilir (`PendingLiveGameCounts` dersi, 3 Eylül 2026).
4. **Misafir:** takım ve açık oyun hesap ister; Takım sekmesi misafire içerik yerine
   üyelik çağrısı gösterir (üyelik avantajları kutusu deseni).
5. **Çevrimdışı:** açık ilan listesi ağ gerektirir; `friendlyErrorMessage`,
   düşen istek "boş liste" demez kuralı (`verify-live-games-load` deseni).
6. **Realtime:** açık ilan listesi tek paylaşılan kanalı kullanmalı
   (`verify-shared-realtime`, kanal çarpanı maliyeti).
7. **Tanıtım (Oynayarak öğren) ve YZ oyunu** takımdan etkilenmez.
8. **Arkadaş önerisi:** oyun bitince `FriendSuggestModal` rakip takımı da
   önerir (zaten "arkadaş olmayan katılımcılar" mantığı).
9. **Yarım oyun hatırlatması / sıra bildirimi:** takım oyununda ortağın sırası
   da bildirim sayar; iki ortağın telefonu aynı anda ötmez (sırayı yalnızca
   sırası gelen alır, mevcut davranış).
10. **Hesap silme / anonimleştirme** ve **k-lig geçmiş görünümü** (§4).
11. **ROADMAP #23 ölçümleri:** `admin_ai_balance` takım oyunlarını (YZ yok)
    zaten dışlar; yine de `game_finishes` takım oyununu "4 kişilik canlı"
    sayar, admin kırılımında ayrı bir "takım" etiketi önerilir.
12. **Aynı kişi iki takımda:** kullanıcı en çok 5 takım; bir ilanda iki takımın
    üyeleri çakışamaz (§5).

## 12. Aşamalar (kaba büyüklük, onay sonrası)

| Faz | İçerik | Büyüklük |
|---|---|---|
| 1 | Takım kur/kabul/ayrıl (sunucu + web) | M |
| 2 | Açık ilan + atomik kabul + bildirimler | L |
| 0 | **Motor: ortak bölge** (4 kopya + golden + SQL kapıları). Diğer her şeyin ön koşulu | L |
| 3 | Oyun içi: takım kutuları, Oyun Geçmişi, oyun sonu, Son Oynananlar | M |
| 4 | Takım Ligi sıralaması (sunucu görünümü + k-lig sekmesi) | S |
| 5 | Port ikizi + parite kapıları + Koşullar/Gizlilik + TESTING | L |
