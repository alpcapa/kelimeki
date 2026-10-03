# Rastgele Oyuncu — açık ilanla yabancıyla 2/4 kişilik Canlı oyun

**Durum: TASARIM TASLAĞI (3 Ekim 2026) · kod YOK · kullanıcı onayı bekliyor ·
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

- Arkadaş listesinin EN ÜSTÜNDE tek satır: **? avatarlı "Rastgele Oyuncu"**,
  alt yazısı *"Biri kabul edince oyun başlar"*. "Sık oynadıkların" şeridinin
  ve arama kutusunun altında, listenin ilk satırı (aramada süzgeçten MUAF,
  hep görünür).
- **Seçim = mod (v1, açık soru A):** Rastgele seçilince arkadaş seçimi temizlenir,
  arkadaş seçilince Rastgele kalkar. 2 kişilikte 1 koltuk, 4 kişilikte 3 koltuk
  "?" olur (koltuk kartları oyuncu renginde, adı "Rastgele"). Koltuk kartına
  dokunmak seçimi kaldırır. 4 kişilikte YZ koltuğu yok (v1).
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
  (iki ayrı ton), dolu koltuk noktaları (●○), **Kabul** düğmesi (≥32 px yüksek).
- **Sıra:** en yeni önce; kendi ilanım şeritte YOK (altta "Bekliyor" satırı).
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
  koşul BOŞUNA doğru olur. v1'de karma kadro (arkadaş+rastgele) yok ve kabul
  yolu ayrı RPC olduğu için tetiklenmez; ama karma kadro açılırsa bu fonksiyona
  "açık koltuk kalmadı" şartı eklenir. Ayrıca `accept_random_game` oyunu
  yalnızca son koltuk dolunca `active` yapıp `init_online_game_state` çağırır.
- ⚠ **Eski istemci koruması** (Takım Ligi S12 deseni): eski `list_my_online_games`
  içinde `open` tipli koşulu görmemeli (bilinmeyen `slots` tipi eski web/Dart
  ayrıştırıcısını bozar; "koltuk indeksi çöktü" dersi). Eski RPC, açık koltuğu
  olan `pending` oyunları DÖNMEZ; yeni RPC'ler döner. Oyun dolup `active` olunca
  her iki RPC de görür — o noktada `slots` tamamen bildik tiplerde.
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

## 8. Kullanıcıya AÇIK SORULAR

| # | Soru | Öneri |
|---|---|---|
| A | 4 kişilikte arkadaş + rastgele **karışık** kadro (2 arkadaş + 1 rastgele) olsun mu? | v1 hayır: karma kadro eski-istemci davetlisini kilitleyebilir (görmediği oyunu kabul edemez) ve yukarıdaki boş-koltuk tuzağını açar. 4 kişilikte ya hepsi arkadaş ya hepsi rastgele |
| B | 4 kişilik rastgele oyunda 4. koltuk YZ olabilsin mi? | v1 hayır (kadro basit kalsın), sonra eklenir |
| C | Şeridin okunuşu (§1) doğru mu? | Başkalarının açık ilanları; benimkiler altta "Bekliyor" |
| D | Kişi başı 3 eşzamanlı, 7 gün | Onay |
| E | Şeritte 2/4 süzgeci (Hepsi · 2 · 4)? | v1 yok, karışık akar (isteğin böyle) |
| F | Takım Ligi (19 Ekim) ile sırası | Motor değişmediği için bağımsız ve daha hafif; öneri: aynı `listing` altyapısı için Takım Ligi Faz 2'den SONRA, tarih sizin kararınız |
