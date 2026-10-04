# Rastgele Oyuncu — açık ilanla yabancıyla 2/4 kişilik Canlı oyun

**Durum: TASARIM (3 Ekim 2026, kararlar §8) · kod YOK · öneriler (§9) kabul · 
ROADMAP #45.** Kodlama, Takım Ligi gibi 12 Ekim kesiminden SONRA.

## 1. İstek (kullanıcının sözleri)

> *"Takım oyunu gibi, 2/4 kişilik oyunda da rastgele oyun açma olabilir.
> Arkadaşlar listesinin en tepesine bir tane Rasgele Oyuncu (avatarı ? olan)
> koyup seçildiğinde 2 kişilik ve 4 kişilik oyuna ekleyip davet gönder
> yaptığında devam eden oyunlar altında (üst kısımda olabilir) bir scroll
> edilebilir alan çıkabilir. Burada karışık 2 ve 4 kişilik oyunlar kabul et
> butonu ile listelenir. Kabul edince devam eden oyunlara girer veya başka
> kişi bekleniyorsa "bekliyor" yazar. Tek sorun bekleyen oyunların çok aşağıya
> kaymaması. O yüzden bekleyen oyunları 3 küçük kutu yan yana sağa sola
> kayabilir şekilde yapabiliriz. Diğer bekleyen oyunlar hemen altında
> listelenir."*

Okuma (varsayım, yanlışsa tek cümleyle çevrilir): şerit = **BAŞKALARININ
açtığı, kabul edilebilir açık ilanlar**; benim açtığım/kabul edip beklediğim
oyunlar şeridin hemen altında, Devam Edenler listesinde "Bekliyor" etiketiyle.

## 2. Motora DOKUNMAZ — Takım Ligi'nden çok daha az riskli

Kural, bölge, puan, vergi, YZ: hiçbiri değişmez. Oyun dolup `active` olunca
bugünkü 2/4 kişilik Canlı oyunun AYNISIDIR. Yani motorun dört kopyası, golden
vector'lar, `play-ai-turn` etkilenmez. Etki yalnızca **kadro kurma** (sunucu)
ve **liste** (istemci) tarafında. Takım Ligi'nin "açık ilan + atomik kabul"
parçasıyla aynı mekanizma (`team-league.md` §5.2) — **ikisi aynı altyapıyı
paylaşmalı** (`online_games.listing` ayrımı, §6).

## 3. Kurulum ekranı (`LiveGameCreateForm`)

- **Arkadaş listesinin İÇİNDE, ilk satır** (kullanıcı, 4 Ekim 2026: *"diğer arkadaşlar
  gibi listenin en üstüne koyacaksın, ayrı bir bölümde değil"*): **? avatarlı "Rastgele
  Oyuncu"**, alt yazısı *"Açık oyun başlatır. Oyuna herkes katılabilir."* (kullanıcı, 4 Ekim 2026; önce "Bunu seçerseniz rasgele oyun açarsınız." idi, aynı gün bu metne döndü). Arkadaş satırlarıyla AYNI kart
  dili ve AYNI kaydırılan liste; arama kutusunun ve "Arkadaşını davet et" düğmesinin
  ALTINDA, arkadaşlardan ÖNCE. Ayrı bir başlık/bölüm YOK. Aramada süzgeçten MUAF, "Tüm
  oyuncular" görünümünde ve hiç arkadaşı olmayanda da hep görünür. (İlk web sürümü
  satırı listenin ÜSTÜNE ayrı blok olarak koymuştu; 4 Ekim'de listenin içine alındı.)
- **ESNEK KADRO (kullanıcı kararı, 3 Ekim):** Rastgele satırına her dokunuş bir
  boş koltuğu "?" yapar; arkadaşlarla serbestçe karışır. 2 kişilikte 1 koltuk;
  4 kişilikte ortadaki iki koltuk dolmalı (arkadaş ya da rastgele), 2 kişi
  seçilirse 4. koltuk **Yapay Zeka** olur (bugünkü kural). Örnekler: 1 arkadaş +
  1 rastgele + YZ · 3 rastgele · 2 arkadaş + 1 rastgele. Koltuk kartına
  dokunmak seçimi kaldırır; satırda seçilen rastgele sayısı (×2) görünür.
- **Davet Gönder** → ilan açılır. Onay ekranı: *"İlanın yayında. Biri kabul
  edince oyun başlar. 7 gün içinde dolmazsa kendiliğinden kalkar."*
- Misafir: Canlı sekmesi zaten hesap ister; yeni bir kapı gerekmez.

## 4. Liste ekranı (`LiveGamesTab` → Devam Edenler)

```
┌ Rastgele Oyunlar · 5 ─────────────────────┐   ← başlık + sayı; liste BOŞSA
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌─ ← kaydır    │     şerit TAMAMEN gizlenir
│ │ (A)  │ │ (B)  │ │ (C)  │ │ (D           │
│ │Ayşe  │ │Can   │ │Elif  │ │              │
│ │2 kişi│ │4 kişi│ │2 kişi│ │              │
│ │ ○    │ │ ●○○○ │ │ ○    │ │              │
│ │[Kabul]│ │[Kabul]│ │[Kabul]│ │             │
│ └──────┘ └──────┘ └──────┘ └─             │
├ Devam Eden Oyunlar ───────────────────────┤
│ Zeynep ▲ SIRA SENDE …                      │
│ Mert · Ali · Su · Can  ⏳ Bekliyor 2/4     │   ← kendi açtığım/kabul ettiğim
│ …                                          │
```

- **Şerit:** yatay kaydırma, `scroll-snap`, tek satır sabit yükseklik
  (~108 px) → sayfa ne kadar ilan olursa olsun uzamaz (isteğin asıl derdi).
  Kart ~88 px: 3 tanesi 320 px'te yan yana, dördüncünün kenarı görünür (kaydırma
  ipucu). Kartta: kurucunun avatarı + kısa adı, **2 kişi / 4 kişi** rozeti
  (iki ayrı ton), dolu koltuk noktaları (dolu = yeşil, boş = içi boş halka) ve altında **"N koltuk kaldı"** (kullanıcı, 3 Ekim: saat/gün yaşı yerine; zaman bilgisi karta KONMAZ, 7 günlük süre ilanı kendiliğinden kaldırır), **Kabul** düğmesi (≥32 px yüksek).
- **Şerit başlığının sağında "Rastgele oyun aç" bağlantısı** (kullanıcı, 3 Ekim; "kaydır →" ipucunun yerine): "+ Yeni Canlı Oyun"a basmakla AYNI, kurulum ekranını açar. Şerit boşken gizlendiği için bağlantı da yoktur; o durumda "+ Yeni Canlı Oyun" kalır.
- **Sıra:** en yeni önce; kendi ilanım şeritte YOK (altta "Bekliyor" satırı). ⚠ 4 Ekim: DEĞİŞTİ, bkz. §15.
  Sessize aldığım/şikayet ettiğim kişinin ilanı çıkmaz.
- **Kabul** = tek dokunuş, onay sorulmaz (Takım Ligi Rev. 9 deseni). Toast:
  *"Kabul ettin. Diğer oyuncular bekleniyor."* Oyun doluysa kart Devam Edenler'de
  normal oyun olur; değilse **"Bekliyor 2/4"** etiketiyle orada durur. İki kişi aynı
  anda basarsa ilki kazanır, öteki *"Bu oyun doldu"* görür, şerit tazelenir.
- **Bekleyen rastgele oyunlar Oyun Davetleri sekmesine DEĞİL Devam Edenler'e
  gider** (bugünkü "Rakip Bekleniyor" kovası arkadaş davetleri için kalır).
- **Çıkış yolu:** kurucu ilanı iptal eder; kabul eden dolmadan **"Ayrıl"** der
  (koltuk yeniden açılır, ceza yok). 7 gün bekleyen yabancıyı kilitlemek olmaz.
- Şerit paylaşılan tek Realtime kanalından beslenir (`verify-shared-realtime`);
  kaydırılmış şeride yeni ilan araya girmez, başta küçük bir nokta çıkar.
- **Port:** yatay `SingleChildScrollView` + sabit yükseklik; `mobile/CLAUDE.md`
  `KModal`/iç içe liste dersi uygulama öncesi okunur (okunmadı).

## 5. Sınırlar ve kötüye kullanım

| Konu | Öneri (onay bekler) |
|---|---|
| Kişi başı eşzamanlı rastgele | En çok **3** (açtığım + kabul edip beklediğim); dolunca "Rastgele oyunların dolu" — Takım Ligi'nin 3 devam eden sınırıyla aynı fikir |
| Süre | **7 gün** (davet ve takım ilanıyla aynı, tek kavram); şişerse 48 saat |
| Kendi ilanımı kabul | Yok; sunucu da reddeder (kurucu = koltuk 0) |
| Yabancıyla sohbet | Bugünkü oyun-bazlı sohbet + KİŞİ bazlı sessize alma/şikayet aynen (`chat-moderation.md`); yeni mekanizma yok |
| Puan avcılığı | Aynı çiftin tekrar eşleşmesi k-lig'i şişirebilir (Takım Ligi S9 ile aynı sorun). v1: `online_games.listing` admin süzgeci; kural ikinci adımda |
| Görünürlük | Kurucunun ad+avatarı girişli HERKESE görünür → `TermsModal`/`PrivacyModal` güncellenir |
| Oyun sonu | `FriendSuggestModal` yabancıları zaten önerir (ağ büyür) |
| İstatistik/k-lig | Normal 2/4 kişilik oyun gibi sayılır; yeni mod/kolon yok |

## 6. Sunucu etkisi (kod yok, kapsam haritası)

- `online_games.listing text null check (listing in ('random','team'))` — NULL =
  bugünkü oyunlar. Takım Ligi aynı kolonu kullanır. `slots`ta açık koltuk:
  `{"type":"open"}`.
- Yeni RPC'ler, **mevcutların imzasına DOKUNMADAN**: `create_random_game(p_player_count)`,
  `accept_random_game(p_game_id)` (`for update` kilidi, ilk açık koltuğa yazar),
  `leave_random_game`, `cancel_random_game`, `list_random_games(limit, offset)`,
  `list_my_random_games()` (Devam Edenler "Bekliyor" satırları).
- ⚠ **Boş koltukla başlama tuzağı:** `respond_to_game_invite`, "tüm davetler
  kabul" olunca oyunu `active` yapar. Açık koltuğun davet satırı olmadığından
  koşul BOŞUNA doğru olur. Esnek kadro (karar A) kabul edildiği için bu
  fonksiyona "açık koltuk kalmadı" şartı ZORUNLU eklenir (arkadaş kabul etti
  ama rastgele koltuk boş: oyun başlamaz, ilan açık kalır). Ayrıca `accept_random_game` oyunu
  yalnızca son koltuk dolunca `active` yapıp `init_online_game_state` çağırır.
- ⚠ **Eski istemci koruması** (Takım Ligi S12 deseni): eski `list_my_online_games`
  içinde `open` tipli koşulu görmemeli (bilinmeyen `slots` tipi eski web/Dart
  ayrıştırıcısını bozar; "koltuk indeksi çöktü" dersi). Eski RPC, açık koltuğu
  olan `pending` oyunları DÖNMEZ; yeni RPC'ler döner. Oyun dolup `active` olunca
  her iki RPC de görür — o noktada `slots` tamamen bildik tiplerde.
  ⚠ **Karma kadroda eski istemcideki ARKADAŞ** daveti görüp kabul etmek zorunda
  (yoksa oyun hiç dolmaz). Aday çözüm: eski RPC açık koltuğu geçici olarak
  `{"type":"ai"}` gösterir (eski ayrıştırıcılar bu tipi bilir). Uygulamadan önce
  web `LiveGamesTab` ve Dart `live_games_tab.dart` ayrıştırıcıları okunup
  doğrulanır; olmazsa karma kadro eski sürümdeki arkadaşa sunucuda reddedilir.
- `check_invite_expiry` açık ilanı da süpürmeli (7 gün → `abandoned`). Dört
  kovanın hepsi `status`e bakıyor mu dersi (`live-game.md`, 4 Ağustos 2026)
  uygulanır: yeni kovalar da `status` filtreli.
- Rozet zinciri: açık ilan = haber, **bekleyen iş değil** (sayaçlara, uygulama
  ikonu rozetine, giriş sekmesi kararına GİRMEZ). Bildirim: kurucuya *"ilanın
  kabul edildi"* ve *"oyun başladı"* (`noreply@`/push; `verify_jwt` listesi
  gerekirse güncellenir).
- Yeni tablo gerekmiyor → `grant` işi yok. RLS: ilanı yalnızca girişliler görür.
- `create_online_game` DEĞİŞMEZ (arkadaş şartı orada kalır).

## 7. İstemci etkisi

Web: `LiveGameCreateForm` (Rastgele satırı + "?" koltuk), `LiveGamesTab` (şerit +
"Bekliyor" etiketi + kova kuralı), yeni `RandomGamesStrip`, `api.ts`,
`database.types.ts`. Port ikizi: `live_games_tab.dart`, `devam_eden_govde.dart`
çevresi, form (`live_games_test.dart` kilitleri güncellenir). `TESTING.md` +
`mobile/TESTING.md` (iki gerçek hesap gerektirir, otomatik test edilemez),
ROADMAP "Sıradaki sürüme binecekler" satırı.

⚠ **Rövanş:** `rematchSlots` ilk koltuk çağıran + `create_online_game` ARKADAŞ
şartı → yabancıyla biten oyunda "Tekrar Oyna" sunucudan *"Yalnızca arkadaşlarını
davet edebilirsin"* ile düşer. Kod okunmadı; uygulamadan önce karar: rakip
arkadaş değilse rövanş gizlensin (öneri) ya da yeniden rastgele ilana dönsün.

## 8. Kararlar (3 Ekim 2026, kullanıcı)

| # | Karar |
|---|---|
| A | **Esnek kadro EVET** (arkadaş + rastgele + isteğe YZ karışık). Bedeli §6'da: boş-koltuk başlama koruması ve eski istemci görünümü |
| B | 4. koltuk **Yapay Zeka olabilir** (rastgele kadroda da) |
| C | Şerit = başkalarının açık ilanları (doğru okunmuş). Şeridin ALTINDA bugünkü Devam Eden Oyunlar listesi aynen durur; benim bekleyen rastgele oyunlarım orada "Bekliyor n/N" etiketiyle |
| D | Kişi başı en çok 3 eşzamanlı rastgele, 7 gün |
| E | Şeritte süzgeç yok, 2 ve 4 kişilik karışık akar |
| F | Plan aşaması. Mümkünse aynı trene (19 Ekim); öneriler §9 |

## 9. Öneriler — HEPSİ KABUL (kullanıcı: "1-4 ok", 3 Ekim 2026)

1. **Önce var olan ilana katıl, yoksa aç:** kadro YALNIZCA rastgele koltuklardan
   oluşuyorsa ve aynı boyutta açık ilan varsa "Davet Gönder" yeni ilan açmak
   yerine onu kabul eder (oyun anında başlar). Şerit şişmez, bekleme kısalır.
   Arkadaşlı karma kadroda uygulanmaz (kurucu kendi kadrosunu istiyor).
2. **Karta rütbe mührü** (`RankSeal`): yabancıyı seçerken seviyesini görmek ucuz
   ve adil; süzgeç değil, yalnızca bilgi.
3. **Açma/kabul kapısı:** en az 1 BİTMİŞ oyun (yeni/sahte hesapla şerit spam'ini
   keser). Tek satırlık sunucu şartı.
4. **Sıra:** motor değişmediği için bu iş Takım Ligi'nden bağımsız ve hafif. Web
   yarısı sürüm trenine bağlı DEĞİL (hemen gidebilir); yalnızca port yarısı
   19 Ekim trenine girer. `listing` altyapısı Takım Ligi Faz 2'nin de ön koşulu,
   yani önce bu yapılırsa Takım Ligi ucuzlar. Risk: ikisi aynı ekranlara
   (`LiveGameCreateForm`, `LiveGamesTab`) dokunur; aynı anda iki dal açılırsa
   çakışır, bu yüzden sıralı (önce rastgele web, sonra takım) önerilir.
5. Prototip: https://claude.ai/artifact/8CfANHX7L8N9wJmMHVz1uM (özel bağlantı,
   sahte veri).

## 10. Takvim (kullanıcı isteği, 3 Ekim 2026)

Kullanıcı: *"Rastgeleyi 12 Ekim trenine alabiliriz mümkünse."* (12 Ekim = ilk
kesim günü; port taslak PR'ı o gün merge edilir.) Bu, Takım Ligi notundaki "12
Ekim'den önce kod yok" kararını RASTGELE için değiştirir; Takım Ligi'nin
kendisi için o karar durur. Başlama onayı ayrıca beklenir (sunucu değişikliği
canlıya anında girer). Sıra: (1) sunucu (migration + eski istemci koruması) →
(2) web → (3) port taslak PR'ı → (4) iki gerçek hesapla elle test. Port 12
Ekim'e yetişmezse web+sunucu gider, port 19 Ekim trenine kayar.

## 11. Sunucu migration'ı — CANLIDA (3 Ekim 2026), tek RPC hariç

Ajan (Opus) yazdı; ben okudum, canlıyla karşılaştırdım ve parçalar hâlinde uyguladım.
**Neden parça parça:** Supabase aracı tek parça migration'da 60 sn'de zaman aşımına
uğradı (iki deneme, ikisinde de canlıya HİÇBİR şey yazılmadı: kolon/fonksiyon/kayıt
yoktu, takılı kilit yoktu). Bölünce `delete from` içeren gövde dışındakiler geçti →
**araç `delete` içeren migration'larda onay beklerken kesiliyor** (devir notundaki
uyarı doğrulandı). Obfüske ederek aşılmadı.

Uygulanan (versiyonlar `list_migrations` ile eşleşti, dosyalar yeniden adlandırıldı):
`1_schema` · `2_helpers_guard` · `3a_create` · `3b_accept_cancel` · `4_list_rpcs` ·
`5_existing_rpcs` (`respond_to_game_invite` + `list_my_online_games`).
**Elle uygulandı:** `leave_random_game` (`delete from game_invites` içerdiği için araçtan geçmedi) →
`20261003230300_random_games_3c_leave.sql`; kullanıcı SQL Editor'dan çalıştırdı, canlıda doğrulandı
(ACL temiz). ⚠ SQL Editor `schema_migrations`a satır YAZMAZ → bu parça canlı geçmişte görünmez.
Eski `20261003120000_random_games.sql` (tek parça) silindi; yerine bu parçalar var.

Canlı doğrulama (salt-okunur + geri alınan güncelleme): yeni fonksiyonlarda `anon`
YOK, yalnızca `authenticated` + `service_role` (yardımcılar ve tetikleyici
fonksiyonu yalnızca `service_role`); `online_games_random_guard` tetikleyicisi var;
mevcut bir oyunun no-op güncellemesi tetikleyiciden sorunsuz geçti; `listing`
kolonu 0 satırda dolu. Yazma gerektiren senaryolar (eşzamanlı kabul, ayrıl,
süre dolumu) HENÜZ koşulmadı → iki test hesabı gerekir. Ajanın yerel testi SAHTE
şema/PG16 üzerindeydi; canlı PG17.

Kararlar: kabul eden `game_invites`'ta `accepted` satırı alır + koltuğa `via:"random"`
(ayrılma yalnızca bu koltuğu boşaltır); açık koltuklu oyunu aktif yapmayı bir
TETİKLEYİCİ engeller (`init_online_game_state` açık koltuğu sessizce YZ sayardı)
ve ilan/açık koltuk yalnızca bu RPC'lerden yazılabilir (RLS kurucuya doğrudan
yazım izni veriyordu); bitmiş-oyun kapısı `games` tablosuna bakar (YUMUŞAK fren,
tablo istemciden yazılabilir). `respond_to_game_invite` canlı tanımıyla aynı +
kilit sırası + "açık koltuk kalmadı" şartı; `list_my_online_games` yalnızca
`open`→`{"type":"ai","open":true}` maskesi farkıyla.

**İstemciyi bağlayan sonuçlar:**
- **Şerit Realtime ile BESLENEMEZ:** Realtime RLS'e uyar, yabancının ilanı olay
  olarak gelmez (§4'teki "tek kanal" varsayımı yanlıştı). Şerit sayfa görünürken
  ve öne dönüşte yoklanır (aralık istemci tarafında seçilir, ölçüyle).
- offset sayfalaması kayar → istemci id ile tekilleştirir.
- Sessize alma yalnızca benim yönümde süzülür (v1; iki yönlüye gerek görülürse sonra).
- Karma kadroda arkadaşın reddi tüm ilanı (oturmuş yabancılarla) kapatır
  (bugünkü ret kuralı, değişmedi).
- Eski sürümlü arkadaş açık koltuğu "Yapay Zeka" sanır (bilinen bedel).
- Doğrulanmadı: oyun başlarken `_notify_your_turn` tetiklenir mi.

## 12. Web yarısı — YAZILDI, canlıya alınmadı (3 Ekim 2026)

Sonnet ajanı yazdı, ben okudum ve `lint`, `build`, `verify-hook-order`,
`verify-auth-user-identity`, `verify-error-messages`, `verify-live-games-load`,
`verify-shared-realtime`, `verify-game-list-order`, YENİ `verify-random-games` (59 kontrol)
ve ilgili Flutter parite testlerini (web kaynağını okuyanlar) koştum: hepsi geçti.
Saf kurallar `src/utils/randomGames.ts`'te; bileşenler `RandomGamesStrip.tsx` +
`LiveGamesTab.tsx` + `LiveGameCreateForm.tsx`. **Gerçek Supabase'e karşı hiçbir akış
denenmedi** (yalnızca sahte uç + izole sayfada 320/390 px görsel kontrol) → iki
hesapla `docs/testing-rastgele.md` koşulmadan merge EDİLMEZ.

Kararlar/sapmalar:
- Kova kuralı: yalnızca `my_role` 'creator' ve 'random' Devam Edenler'e gider; 'friend'
  (karma kadrodaki arkadaş) bugünkü davet akışında kalır (yoksa daveti kaybolurdu).
- Şerit yoklaması 40 sn (en az 8 sn aralık), yalnızca sekme görünür+çevrimiçi iken.
- "Rastgele Oyuncu" satırı arkadaş listesinin İÇİNDE ilk satır ve aramadan muaf (§3).
  Rütbe mührü (§9.2) EKLENMEDİ.
- Kart ~173 px yüksek (tasarım notundaki ~108 değil); "N koltuk kaldı" dar kartta iki satıra sarıyor.
- **Yasal metin:** Gizlilik §2'ye ve Koşullar §1'e ilan görünürlüğü maddesi; Koşullar §5'teki
  "mesajlaşma yalnızca arkadaşlar arasında" cümlesi (ZATEN yanlıştı: sohbet oyun bazlı,
  live-game.md 11 Eylül) "aynı Canlı oyundaki oyuncular arasında" olarak düzeltildi.
  ⚠ "Son güncelleme: 25 Eylül 2026" tarihi DEĞİŞMEDİ: mobil `legal_text_test.dart` o tarihi web
  kaynağından okuyor; tarihi değiştirmek mobil dosyayı gerektirir. Tarih ve Dart metni
  PORT PR'ında birlikte güncellenir (YAPILDI: 4 Ekim 2026, bkz. §13).
- Yabancıyla biten oyunda "Tekrar Oyna" (§7) HÂLÂ açık.

## 13. Port (Flutter) ikizi — YAZILDI, taslak PR (4 Ekim 2026)

Dal `claude/random-opponent-port`; 1.1.3 trenine taslak (ROADMAP "1.1.3 treni"
tablosu). Kurallar `src/utils/randomGames.ts`ten BİREBİR → `mobile/app/lib/src/
util/random_games.dart`; `test/random_games_test.dart` web dosyasını OKUYUP
sabitleri/metinleri/RPC adlarını karşılaştırır (web CI `parite` işi), ekran
akışı `test/random_games_ui_test.dart`ta. Cihaz listesi: `mobile/docs/
testing-arkadaslar-canli.md` → "Rastgele Oyuncu" (web belgesi 13.10 aynen
koşulur).

Port kararları/sapmaları:
- `OnlineSlot` artık üç tür: insan / YZ / **açık** (`isOpen`; ham `{type:'open'}` ve
  maske `{type:'ai',open:true}` ikisi de). ⚠ **"İnsan mı" için `!isAi` YETMEZ →
  `isHuman`** (açık koltuk ne YZ ne insan); `mySlotIndex`, `creatorSlot`,
  `rematchSlots`, kartlardaki insan süzgeçleri bu yüzden güncellendi.
- Gateway'e altı RPC (`create/accept/leave/cancel_random_game`, `list_random_games`,
  `list_my_random_games`); ağ hatası ↔ boş liste ayrımı web'deki gibi (`null` =
  bilmiyoruz, son bilinen korunur). `create` arkadaş koltuğu varsa `notify-game-invite`
  (yalnız YENİ ilanda).
- Şerit: yatay `ListView` + **sabit yükseklik** (iç içe dikey liste YOK), kart eni
  `(genişlik-16)/3.4` (min 84), yükseklik 176 × yazı ölçeği. Yoklama 40 sn, alt
  aralık 8 sn, yalnızca uygulama ön plandayken + çevrimiçiyken; Realtime YOK.
- Süresi dolmuş ilan (`expires_at`) `check_invite_expiry` ile süpürülür (web ile aynı).
- Rozet zinciri (`pendingCounts`, `decideInitialMainView`, ikon rozeti) DOKUNULMADI;
  `random_games_test.dart` ilan listesinin sayaç yoluna girmediğini kilitler.
- **Yasal metin + tarih**: web `LegalContent.tsx` ve port `legal_modals.dart` İKİSİ de
  "Son güncelleme: **4 Ekim 2026**"; `legal_text_test.dart` artık yalnız tarihi değil
  üç cümleyi (Gizlilik §2, Koşullar §1, Koşullar §5) iki tarafta da arar.
  ⚠ #779 (taslak) aynı tarihi 12 Ekim'e çekiyor — birleşirken TEK tarih seçilmeli.
- "Tekrar Oyna" (§7) HÂLÂ açık; port da sunucunun Türkçe reddini gösterir.

Gerçek Supabase'e karşı hiçbir akış denenmedi (sahte uç + widget testi).

**§15 port ikizi (4 Ekim 2026) — YAZILDI:** şerit benim bekleyen ilanımı da kart gösterir
(`stripListings`/`myRandomToListing`/`visibleListings(listings, excludeIds)`/`StripListing`
→ `random_games.dart`; kart: `random_games_strip.dart`, "Bekliyor" + "İptal"/"Ayrıl" ≥32 dp,
zemin `kAccent` %5 / kenar %30 = web `border-accent/30 bg-accent/5`; eylem
`LiveGamesTab._handleLeaveRandom` — ikinci kopya yok). Testler: `random_games_test.dart`
(kurallar + web metin/sınıf paritesi), `random_games_ui_test.dart` (benim kart, yalnız-benim
şerit, İptal/Ayrıl, yinelenme yok). Cihaz maddesi: `mobile/docs/testing-arkadaslar-canli.md`.

## 14. Rastgele satırına tekrar dokunuş = GERİ AL (4 Ekim 2026, kullanıcı)

Kullanıcı: *"Rastgele seçildikten sonra tekrar üstüne basınca geri alsın. X3'de 3 kere
basınca."* Uygulanan okuma: her dokunuş bir boş koltuğu "?" yapar; **boş koltuk kalmayınca
ve seçimde "?" varsa bir sonraki dokunuş TÜM "?" koltuklarını geri alır** (2 kişide ikinci
dokunuş; 4 kişide ×3'ten sonraki dokunuş; arkadaşlar korunur). Dolu ve "?" yoksa: 2 kişide
dolu arkadaş koltuğu "?" ile DEĞİŞİR, 4 kişide etkisiz. Tek kaynak `addRandomSeat`
(`randomGames.ts` ↔ `random_games.dart`); tek bir "?" koltuğunu boşaltmak hâlâ koltuk kartına
dokunmakla. ⚠ "×3'de 3 kere" cümlesi iki biçimde okunabilir; yanlışsa değişen yer yalnızca bu
fonksiyon ve `verify-random-games` kontrolleri.

## 15. Şerit benim ilanımı da gösterir (4 Ekim 2026, kullanıcı)

Kullanıcı: *"Bu yanlış: şeritte tüm oyunlar, benimki dahil, görünmeli. Sadece bana kabul et
yerine bekliyor yazsın ki benim ilan ne oldu, gitti mi gitmedi mi kafa karıştırmasın. Bakınca
hemen geldiğini görsün. Ama iptal de edebilsin haliyle."* Gerekçe: ilan açınca şerit
boş/başkalarının ilanlarıyla kalıyor, "benimki yayında mı" belirsiz kalıyordu (§4'ün "kendi
ilanım şeritte YOK" kararını bu değiştirir).

- **Kaynak:** sunucunun `list_random_games`'i (başkaları) + `list_my_random_games`'ten (LiveGamesTab'ın
  zaten çektiği `myRandom`) BEKLEYEN ve `my_role` `creator`/`random` olanlar. Saf: `myWaitingRandomGames`,
  `myRandomToListing`, `stripListings` (`randomGames.ts`).
- **Sıra:** benimkiler ÖNCE (en yeni önce), sonra başkaları. Id ile tekilleştirme: `myRandom`da geçen
  her id başkaları listesinden düşer (benim kartım kazanır; arkadaş/aktif oyun da şeritte çıkmaz).
  `visibleListings` artık `creator_id`'ye bakıp kendi ilanımı ÇIKARMAZ.
- **Kart:** aynı en/boy. "Kabul" YOK; yerine soluk "Bekliyor" etiketi (düğme değil; "N koltuk kaldı" satırının YERİNE — 320 px'te etiket+eylem yan yana sığmadı, koltuk durumu noktalarda) + altında küçük kırmızı eylem:
  `creator` → "İptal" (`cancelRandomGame`), `random` → "Ayrıl" (`leaveRandomGame`); ≥32 px. Ayrışma: `border-accent/30 bg-accent/5`.
  Eylem mantığı/iletileri `LiveGamesTab.handleLeaveRandom`'dan (ikinci kopya yok).
- **Koltuk durumları** (`list_random_games` ile aynı anlam): açık→`open`, gerçek YZ→`ai`, kurucu (`created_by`)→`creator`,
  `invite_status` pending/declined→`invited`, diğer insan→`filled` (`filledSeatCount` ile tutarlı).
- Şerit yalnızca benim ilanım olsa bile görünür; "Rastgele Oyunlar · N" benimkini de sayar.
- **Bilinçli yinelenme:** "Devam Eden Oyunlar"daki "Bekliyor n/N" satırları (`RandomWaitingRow`) ŞİMDİLİK durur;
  aynı ilan iki yerde görünür. Kapı: `verify-random-games`.
