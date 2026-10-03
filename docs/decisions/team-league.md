# Takım Ligi — 2'şer kişilik takım oyunu (TASARIM ÖNERİSİ, 3 Ekim 2026)

> **Durum: ÖNERİ — kullanıcı onayı bekliyor, KOD YOK.** Kullanıcı isteği
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

## 3. Motora dokunmama ilkesi (en önemli sınır)

Motorun dört kopyası var (web · Dart · Edge `_game/` · SQL `_km_*`). Bu özellik
**kural motorunu DEĞİŞTİRMEZ**: tahta, raf, puan, bölge, vergi, X2/X3 aynen.
Takım oyunu, "kim hangi takımda" üst katmanı olan sıradan bir 4 kişilik Canlı
oyundur.

| Kural | Karar | Neden |
|---|---|---|
| Koltuk dizilimi | **A-B-A-B**: koltuk 0 ve 2 = Takım A, 1 ve 3 = Takım B | Ortak art arda oynamasın; köşeler: A sol (↖ ↙), B sağ (↗ ↘). Renkler: A camgöbeği+yeşil, B kırmızı+mor |
| Takım içi bölge vergisi | **Aynen ödenir** (ortağın bölgesine girersen ona vergi) | Motor değişmez. Takım için net 0, yalnızca bireysel skor oynar. Onay penceresine bilgi satırı: *"Ortağının bölgesi, takımın için net 0"* (yalnızca metin) |
| Takım vergisi (gösterim) | Yalnızca **rakip takıma** ödenen/alınan | Takım içi transfer takım toplamını değiştirmez, gürültü olur |
| YZ | Takım oyununda YZ koltuğu YOK | 4 insan zorunlu |
| Teslim / 48 sa zaman aşımı | Motorun kademeli teslimi aynen: teslim olanın skoru 0, rafı torbaya | Takım puanı = kalan üyenin skoru |
| **Oyun bitişi** | Mevcut kural "aktif oyuncu 1'e düşünce biter" takım oyununda YETMEZ: A'nın iki üyesi teslimse B'de iki aktif kalır, oyun bitmez. **Yeni kural: bir takımın TÜM üyeleri teslimse biter.** | Tek motor dokunuşu. Yalnızca SQL (`check_turn_timeout` bitiş dalı) + `verify-sql-engine-parity` genişler. Canlı ekran sunucu durumunu okuduğundan web/Dart reducer'ı DEĞİŞMEZ. Golden vector gerekmez, ama bu karar onaylanınca SQL kapısı yazılmalı |

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
  çok **5 aktif takım**; takım başına aynı anda **1 açık ilan**.
- **Ayrılma:** takımın açık ilanı veya aktif oyunu varken ayrılma KAPALI
  ("önce oyunları bitir"); aksi halde yarım oyunda ortak kaybolur.
- **Hesap silme:** üyesi silinen takım `DAĞILDI` olur, lig kaydı korunur, silinen
  üye "Silinmiş kullanıcı" gösterilir. Yeni nullable FK = SÖZLEŞME değişikliği:
  `docs/decisions/account-deletion.md` → "SET NULL'ın bedeli" uygulanır
  (`database.types.ts` + portun `fromJson`'ı).

## 5. Açık oyun akışı

1. **Oyun Aç:** üye, **aktif** takımlarından birini seçer ("takım seç → oyun
   başlat"). İlan açılır. Ortağı OTOMATİK katılır (onay sorulmaz: takıma
   girerken onay verdi) ve **bildirim** alır (push + uygulama içi): *"Ali, ‹Takım›
   adına açık oyun açtı."*
2. **Açık Oyunlar listesi** (girişli herkes görür): kurucu takım adı + iki
   avatar + takımın puanı/sırası + ilanın yaşı + **Kabul Et**. Kendi
   ilanlarında Kabul Et yerine **İptal**.
3. **Kabul Et:**
   - Takımı **yoksa** → "Önce bir takım kur" adımı (§6). İlan KİLİTLENMEZ.
   - Tek aktif takımı varsa onu, birden çoksa **takım seç** sheet'i.
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
Kabul Et ─► "Takım Oluştur" ekranı (arkadaş seç + ad)
              └─ Kaydet ─► takım ONAY BEKLİYOR (arkadaşa davet gitti)
                           └─ ekran: "Arkadaşın kabul edince bu oyunu tekrar
                              seçebilirsin. Oyun senin için tutulmaz."
                              (ilan açık listede KALIR, başkası alabilir)
```

Bilinçli: ilan rezerve edilmez, yoksa onay vermeyen bir arkadaş başkasının
oyununu bloke eder. Ekran bunu açıkça söyler. Arkadaş onaylayınca takımın
sahibine bildirim: *"‹Takım› hazır. Açık oyunlara dön."*

## 7. Hamle geçmişi, skor ekranı, Son Oynananlar

- **Oyun Geçmişi** (`MoveHistoryModal`) bugünkü dört kutu: Toplam · (ad) ·
  Vergi(−) · Vergi(+). Takım oyunu için: **Toplam · Takım puanı · Takım
  vergisi(−) · Takım vergisi(+)**. Kişisel ad/skor/vergi bilgisi kutuların
  ALTINDA ince bir şerit olur (bkz. görsel). `moveHistoryStats`
  saf fonksiyonu takım bilgisini alır; web ↔ Dart ikizi.
- **Skor kartları:** her oyuncunun kartında **takım bandı** (A pembe · B
  amber). Takım toplamları sayfa başlığında (*A 214 – 187 B*).
- **Oyun sonu:** önce takım sonucu (KAZANDINIZ / KAYBETTİNİZ / BERABERE),
  sonra iki takımın üyeleri ve skorları.
- **Son Oynananlar:** normal oyun gibi satır; **silik pembe bant + "TAKIM"
  etiketi**. Bugünkü Canlı satırı `bg-panel` (gri); takım oyunu ona pembe
  tonlu bant ekler. "Takımın adı" ve rakip takım adı satırda yazar.
- **Renk önerisi (görselde):** bant/etiket `#F9D7E6` zemin, `#9C2A5F` yazı;
  Takım B amber `#FCE7B2` / `#8A5A00`. Dört oyuncu rengiyle (camgöbeği,
  kırmızı, yeşil, mor) çakışmaz; kırmızıya yakın görünmemesi için pembe
  doygunluğu düşük tutuldu.

## 8. Puanlama ve Takım Ligi

| Konu | Karar (öneri) |
|---|---|
| Oyun sonucu | Takım puanı yüksek olan kazanır. Eşitlikte **berabere** |
| Lig puanı (takıma) | Kazanan **+2** · Beraberlik **+1** (ikisi de) · Kaybeden **0** · takımında **teslim olan üye varsa −2** (sonuç ne olursa; bireysel "teslim −2" kuralının aynısı) |
| Sıralama | **Takım puanı** ↓, eşitlikte **takım OHP'si** ↓, sonra oynanan oyun ↓, sonra takım id (sayfalama kararlı kalsın — `k_lig_siralama` dersi) |
| Takım OHP'si | Takımın iki üyesinin **takım oyunlarındaki** tüm puanlı hamlelerinin ortalaması. Bireysel OHP'nin takım karşılığı; YZ oyunu yok |
| Giriş eşiği | Yok (en az 1 bitmiş takım oyunu). Beyin Ligi'nin 5 oyun eşiği puana göre sıralamada gerekmiyor |
| Satır | sıra · takım adı · iki avatar · puan · OHP · oyun. Rütbe mührü YOK (puan eşiği ödül sistemi bireysel) |
| "Senin sıran" | Kullanıcının EN İYİ takımının satırı, pencerenin içinde (Beyin Ligi #796 dersi: `fillBody`) |
| Alttaki not | *"Takım puanı, oyundaki iki üyenin skorlarının toplamıdır. Puanlar eşitse takım OHP'si yüksek olan üstte."* |
| Bireysel k-lig | **Takım oyunu `games`'e normal 4 kişilik oyun gibi yazılır** (bireysel sıra bireysel skora göre) → `league_points_for` DEĞİŞMEZ, beş nesne ve `verify-league-points` etkilenmez. Hamle puanları bireysel OHP'ye (Beyin Ligi) de normal girer. Alternatif için §10 S1 |

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
  transaction'da yazar. `check_turn_timeout` takım bitiş kuralını alır (§3).
- Dönüş tipi değişen RPC'lerde `drop`+`create` ve `proacl` kontrolü (anon
  sızıntısı dersi).

**Web:** `Setup.tsx` (Takım Ligi kartı), `LiveGameCreateForm.tsx`
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

## 10. Kullanıcıya AÇIK SORULAR (onay gerektiren)

| # | Soru | Öneri |
|---|---|---|
| S1 | Takım oyunu **bireysel Puan Ligi'ne** nasıl girsin? (a) normal 4 kişilik bireysel sıra (b) takım sonucu: kazanan takımın iki üyesi de "1." sayılsın | **(a)** — `league_points_for` ve beş nesne DEĞİŞMEZ; "normal oyun gibi girecek" cümlesine uyar. (b) bireysel sıralamayı bozar ve SQL formülünü değiştirir |
| S2 | Takım içi bölge vergisi (§3) aynen mi, yoksa ortak bölgeye vergisiz mi? | **Aynen** (motora dokunmaz). Vergisiz = motorun dört kopyası + golden vector |
| S3 | Lig puanı tablosu +2 / +1 / 0 / −2 (§8) uygun mu? | Evet; Puan Ligi 4 kişilik ile aynı büyüklük |
| S4 | İlan **7 gün** mü, daha kısa mı (rakip bekleyen takım için)? | 7 gün (davetle aynı). Açık listesi şişerse 48 saate indirilir |
| S5 | Takım başına **1 açık ilan**, kullanıcı başına **5 takım**? | Evet, kötüye kullanım ve liste şişmesi için |
| S6 | Takımı olmayan kabul için "Takım oluştur" akışı §6'daki gibi (rezerve YOK) | Evet |
| S7 | Ortak, oyuna **sorulmadan** katılır (takıma girerken onay verdi). Ortak uygun değilse 48 sa sonra teslim olur ve takıma −2 yazar. Ortağa "Bu oyundan çekil" hakkı verilsin mi? | Verilmesin (Canlı'da manuel teslim yok kararıyla tutarlı); bildirim yeterli |
| S8 | **Özel takım oyunu** (açık ilan yerine belirli bir takıma meydan okuma) bu sürümde mi? | Sonraya (`product-backlog.md`), önce açık ilan |
| S9 | **Aynı rakip çiftiyle tekrar** oynayıp puan şişirme (iki arkadaş çifti birbirine kasten yenilir) | v1: yalnızca admin izleme sekmesi. v2: aynı iki takım arası 7 günde en çok 3 puanlı oyun |
| S10 | Takım **rengi**: sabit A pembe / B amber mı, yoksa takım kurarken renk seçilsin mi? | Sabit (iki takımı ayırt etmek yeter; seçilebilir renk çakışma çıkarır) |
| S11 | Rövanş: takım oyunu için (aynı iki takım, aynı dizilim) rövanş düğmesi? | Sonraya. `rematchSlots` kuralı takım için yeniden yazılmalı |
| S12 | Sürüm planı: web+sunucu önce mi, port ile birlikte mi? | **Web+sunucu bayrak arkasında önce, port 1.2.0 treniyle, açılış birlikte.** Eski mobil istemci takım oyununu sıradan 4 kişilik oyun olarak oynayabilir (bant ve takım toplamı olmadan) |

## 11. Atlanmış olabilecek ayrıntılar (taramada çıkanlar)

1. **Takım adı UGC** → sohbet engelli kelime filtresi + raporlama + admin'in
   adı değiştirmesi/takımı dağıtması gerekir (admin panelinde kalıcı yüzey).
2. **Gizlilik/Koşullar:** takım adı ve üyeleri girişli herkese görünür; yeni
   kişisel veri toplanmıyor ama GÖRÜNÜRLÜK değişiyor (`CLAUDE.md` tablosu:
   "Yeni kullanıcı verisi ya da görünürlük değişikliği → TermsModal/PrivacyModal").
3. **Rozet zinciri:** "açık oyun" bir BEKLEYEN İŞ değil haber; "takım daveti"
   bekleyen iştir (sayaç). Yeni alanlar rozet zincirine girmeli mi kararı
   ayrıca verilir (`PendingLiveGameCounts` dersi, 3 Eylül 2026).
4. **Misafir:** takım ve açık oyun hesap ister; Setup'ta misafire kart yerine
   üyelik avantajları kutusuna bir satır.
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
| 3 | Oyun içi: bant, takım toplamı, Oyun Geçmişi, oyun sonu, Son Oynananlar | M |
| 4 | Takım Ligi sıralaması (sunucu görünümü + k-lig sekmesi) | S |
| 5 | Port ikizi + parite kapıları + Koşullar/Gizlilik + TESTING | L |
