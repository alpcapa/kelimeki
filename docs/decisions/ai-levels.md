# Seviyeli YZ — Kolay · Normal · Zor (ROADMAP #23)

Bu dosya seviyeli YZ'nin **tasarım kaydı**: nasıl çalışıyor, hangi
algoritma, hangi puan, neden böyle, neyle ölçüldü, neyle kilitli. Faz
kayıtları (ne zaman ne yapıldı) `roadmap-arsiv.md` → "23 · Faz N"de;
açık iş (saha ölçümü) `ROADMAP.md` #23'te. **Bir şey değiştirmeden önce
buradaki "Değişmezler" ve "Kadranlar" bölümlerini oku.**

Tarih: motor Faz 2 (6 Eylül 2026), ürün yüzü Faz 3-4 (6 Eylül), Zor motoru
Faz 5 (7 Eylül 2026, PR #475). Kullanıcı kararları tırnak içinde.

---

## 1. Ürün tanımı

| Seviye | Motor | Hedef (YZ'nin insana karşı kazanma oranı) | k-lig: birinci | 4 kişilikte ikinci |
|---|---|---|---|---|
| **Kolay** | bugünkü arama, **en iyi 4 hamleden rastgele biri** | ~%30 | +1 | 0 |
| **Normal** | bugünkü arama, en iyi hamle — DEĞİŞMEZ, sıfır çizgisi | ~%51 (sahada ölçülmüş) | +2 | +1 |
| **Zor** | **geniş arama** (§3), en iyi hamle | ~%70 | +4 | +2 |

- 2 kişilik oyunda ikinci hiçbir seviyede puan almaz; üçüncü/dördüncü
  hiçbir zaman almaz; teslim her seviyede **-2**.
- Seviye yalnızca **yerel YZ oyununda** (2 ve 4 kişilik) seçilir, oyun
  BAŞINDA kilitlenir, 4 kişilikte üç YZ'ye birden uygulanır, oyun içinde
  değiştirilemez (Kolay'da başlayıp son hamlede Zor'a geçmek +4 ederdi —
  puan oyunu). Rövanş seviyeyi taşır.
- **Canlı oyunda seviye YOK**, oradaki YZ hep Normal, puanlar Normal
  tablosuna göre (`play-ai-turn` `findAIMove`'u seviyesiz çağırır).
- Terminoloji TEK: **Zorluk: Kolay · Normal · Zor** ("kolay mod",
  "seviye" gibi üçüncü bir ifade üretme — HelpModal ↔ Landing ↔ portun
  yardım ekranı aynı sözcükleri taşır).
- Kullanıcı kararı (6 Eylül 2026, 23.2 "B"): *"Normal bugünkü gibi
  kalacak. Kolay daha kolay olacak (%30 gibi), zor daha zor olacak (%70
  gibi)."* A seçeneği (bugünkü motoru Zor diye etiketleyip Normal'i
  zayıflatmak) reddedildi: geçmiş kayıtlar ve Canlı YZ tutarsızlaşırdı.
- Kullanıcı kararı (6 Eylül akşamı): *"bilimsel iş yapmıyoruz"* — YZ'nin
  NASIL zayıflatıldığı/güçlendirildiği ürün metnine GİRMEZ; seçicinin
  altındaki açıklama kullanıcıya hitap eden bir cümle + puan cümlesidir.

## 2. Motor — ortak yapı (`src/utils/ai.ts`, üç kopya)

`findAIMove(board, rack, bonuses, owner, corners, isFirstMove, players,
level)` = `pickTopMove(findAIMoves(..., AI_LEVEL_TOP_N[level],
AI_LEVEL_SEARCH[level]))`. Seviye iki kadrana çevrilir:

| Kadran | Sabit (`src/game/constants.ts`) | Kolay | Normal | Zor |
|---|---|---|---|---|
| Liste boyu N ("en iyi N'den rastgele") | `AI_LEVEL_TOP_N` | **4** | 1 | 1 |
| Arama genişliği `{ wide, maxWordLen }` | `AI_LEVEL_SEARCH` | dar, 7 | dar, 7 | **geniş, 8** |

**`findAIMoves` — aday üretimi ve sıralama:**

1. Kelime havuzu: sözlüğün 2..`maxWordLen` harfli kelimeleri, sözlük
   SIRASIYLA (`WORD_SET` iterasyonu = `WORD_LIST` sırası; port
   `WordSource.pool` aynı sırayı korumak ZORUNDA — bkz. §6).
2. İlk hamle (`isFirstMove`): yalnızca rafla hecelenen kelimeler, ev
   karesine (`cornerCell`) kelimenin HANGİ harfinin (`idx`) oturacağı tek
   tek denenerek, iki yönde (17 Ağustos 2026 düzeltmesi — önceden sağ-alt
   köşe 29 puan geride başlıyordu).
3. Sonraki hamleler: tahtadaki her taş çapa; çapa harfi + rafla
   hecelenen kelimeler (`candidatesForAnchor`, harfe göre önbellek) çapa
   üzerinden yatay/dikey `tryPlace` ile denenir. `tryPlace` hattaki mevcut
   taşların kelimeyle eşleşmesini, hattın iki ucunun boş olmasını ve en az
   bir yeni taş konmasını ister.
4. `consider`: oluşan TÜM kelimeler (çapraz dahil) sözlükte olmalı; puan
   `calcScore` (X2 bölgesi / X3 merkez / bingo +25, motorun kuralla aynı
   hesabı). Bölge vergisi: konan taş bir rakip bölgesine giriyor ya da
   sınırına değiyorsa hamle **vergili**dir.
5. İki sınırlı liste: `safe` (vergisiz, ham puanla) ve `any` (hepsi; vergili
   olanlar `score − share·k` ile, `share = round(score·(k+1)/(6k))` —
   `computeInvasionSplit`in AYNI formülü, `territories` önbelleği için elle
   tekrarlanmış). **Vergisiz hamle varsa liste YALNIZCA onlardan oluşur**;
   YZ mecbur kalmadıkça puan paylaşmaz.
6. `insertBounded`: azalan `rank`, **eşitte ilk bulunan önde**, `sort` YOK
   (kararlılık garantisi olmayan sıralama eşit puanlı adayları yer
   değiştirip Dart paritesini sessizce kırar). Döngü SIRASI bu yüzden
   davranışın parçasıdır (§6).

**`pickTopMove` — rastgelelik sözleşmesi:** liste boş → `null`; tek eleman
→ o eleman, `nextRandom()` ÇAĞRILMAZ; birden fazla → TEK `nextRandom()`,
`floor(r·len)`. Sonuç: Normal ve Zor (N=1) hiç rastgele değer tüketmez ve
eski davranışla bayt-eş kalır; Kolay yalnızca gerçekten seçenek varken,
torbayla AYNI enjekte edilebilir kaynaktan (`setRandomSource`) tüketir.

**Hamle yoksa** (`null`): torbada taş varsa tüm raf değiştirilir, torba
boşsa pas — her seviyede aynı (`AI_PLAY`, `gameReducer.ts`).

## 3. Zor = geniş arama (Faz 5)

**Kural baştan beri izin veriyordu, arama üretmiyordu.**
`validatePlacement`in bağlantı şartı "konan taşlardan biri mevcut bir taşa
komşu"dur; Normal'in araması ise yalnızca **tahtadaki tek bir taştan geçen
hattı** dener. İki hamle sınıfı hiç üretilmiyordu:

1. **Paralel diziş:** tüm taşlar yeni, bağlantı yalnızca çapraz
   kelimelerle (bir taşa komşu boş "kanca" hücresinden başlayan hat).
2. **Çok çapalı kelime:** aynı hattaki birden çok tahta taşından geçen
   kelime (tek çapalı aday süzgeci `canSpell(w, raf + 1 çapa)` bunları
   eliyordu).

**Uygulama (`search.wide`):**
- `candidatesForLine(horiz, index)`: hat (satır/sütun) başına aday süzgeci
  — raf + o hattaki TÜM tahta harfleri (kapsayıcı ön eleme; kesin eşleşmeyi
  `tryPlace`/`consider` doğrular). En fazla 26 hat, her biri çağrı başına
  bir kez.
- Döngü: `r`, `c` sırasıyla her hücre. Boş hücre → yalnızca `hasNeighbor`
  ise kanca: `horiz ∈ [true, false]` → hattın adayları → `idx` 0..len-1 →
  `tryPlace` (W[idx] kancaya, yeni taş). Dolu hücre → çapa: aynı yön/aday
  sırası, `idx` çapa harfinin her geçtiği yer.
- Aynı yerleşim birden çok kanca/çapadan yeniden üretilebilir; N=1'de
  zararsız (ilk bulunan kalır). Zor N>1 yapılırsa liste aynı hamleyi iki
  kez taşıyabilir — o gün ayıklama gerekir.
- Havuz 8: çapa + tam raf = 8 harf (bingo yolu). Ölçümde 7→8 tek oyun fark
  etti, 9+ (13'e kadar) HİÇ — 9+ harf yalnızca maliyet.

**Neden bu ve başka bir şey değil — Faz 5 ölçümü (7 Eylül 2026).**
`npm run simulate-ai-levels -- --oyun 200 --motor …`; YZ↔YZ, rakip Normal,
koltuk değişimli (çift oyunlarda aday 2. koltukta), tohum 1, kazanma oranı
beraberlik dışı, GA Wilson %95:

| Aday | Kazanma | Not |
|---|---|---|
| Top1 (sıfır çizgisi — Normal'e karşı Normal) | %52 (45–59) | |
| Havuz 8, tek çapa | %52 | 409 hamlede **0** sekiz harfli — tek çapayla geometrik olarak neredeyse imkânsız |
| Joker cezası 5 / 10 puan | %46 / %43 | zararlı |
| Raf-kalıntı değeri ×0,5 / ×1 / ×2 | %52 / %44 / %32 | nötr → zararlı |
| Bölge farkı 0,5 / 1 puan/hücre | %53 / %52 | nötr |
| Net fark (vergili hamle, rakibe giden payla) | %52 | nötr |
| Gönüllü değişim (en iyi hamle < 6 / 10 / 14) | %52 / %38 / %22 | nötr → çok zararlı |
| Tek katlı ileri bakış, genel raf | %53 | nötr, 8× yavaş |
| Tek katlı ileri bakış, rakibin GERÇEK rafı | %56 (49–63) | yalnızca üst sınır; **hile — SİLİNDİ** |
| **Geniş arama, havuz 7 / 8 / 13** | **%69 / %70 / %70** (63–75) | 8 ve 13 birebir aynı oyunlar |
| Geniş + kalıntı ×0,5 / + joker 5 | %71 / %71 | ayırt edilemez |
| **Geniş arama havuz 8, tohum 1000** | **%72** (66–78) | ikinci tohumda da kapının üstünde |

Ortalama skor Zor 271 ↔ Normal 214; hamle başına 15,1 ↔ 12,1. Geniş arama
hamlelerin ~%65'inde Normal'den farklı bir hamle buluyor. İki ders: hamle
DEĞERLEMESİ (kalıntı, ileri bakış) bu oyunda kazanmıyor — oyun kısa (100
taş), çekiliş varyansı büyük; kazandıran hamle ADAYLARINI çoğaltmak.

**Kullanıcı kararı (7 Eylül 2026):** *"Rakip oyuncunun eline bakmak ve ona
göre oynamak hile kabul edilir; o nedenle, onu yapma."* Rafa bakan ileri
bakış ve (torba boşken çıkarsanabilir raflarla çalışan) oyun sonu çözücü
silindi; motorda rakip rafını okuyan HİÇBİR yol yok. Aynı mesajdaki öneri
(*"7 harfli kelime üretme sınırını açmak"*) geniş aramayı doğurdu.

## 4. Kolay = en iyi 4'ten rastgele (Faz 0)

Faz 0 ölçümü (6 Eylül 2026; 200 oyun/N, tohum 1-200, koltuk değişimli;
tablo `product-backlog.md` → "YZ zorluk seviyesi"):

| N | Kazanma (Normal'e karşı) | Ort. skor N ↔ Normal |
|---|---|---|
| 1 | %52 | 216 ↔ 224 |
| 2 | %44 | 207 ↔ 229 |
| 3 | %36 | 196 ↔ 233 |
| **4** | **%33** | 190 ↔ 233 |
| 5 | %22 | 178 ↔ 244 |
| 6 / 8 / 10 | %22 / %20 / %8 | eğri 5-8'de düzleşiyor |

Kullanıcı kararı: **N=4 kalsın**, saha ölçümü konuşsun (kullanıcı iki
Kolay oyununda *"bana pek kolay gelmedi"* dedi; N=8 bir kademe aşağısı
olarak hazır).

## 5. Puan — TEK formül, dokuz kopya

Formül: `leaguePoints(rank, playerCount, surrendered, level)`
(`src/utils/leaguePoints.ts`) — teslim → -2; birinci → Kolay 1 / Normal 2 /
Zor 4; ikinci ve 4 kişilik → Kolay 0 / Normal 1 / Zor 2; başka her şey 0.
`level` `null`/eksik → Normal.

Kopyalar: SQL `league_points_for(rank, player_count, surrendered, ai_level)`
(`immutable`; `player_stats`, `player_stats_overall`, `leaderboard`,
`_award_league_rewards`, `trg_award_league_rewards` — beşi de onu çağırır,
inline `case` YAZMA) · TS · Dart `league_points.dart` · üç kart metni.
Kilit: `npm run verify-league-points` (migration SQL ↔ TS ↔ Dart tablosu,
CI'da). ⚠ `leaguePoints`in `level`ine JS varsayılanı VERME — betik ariteyi
`.length`le okuyor.

## 6. Parite kapıları — üç motor kopyası, aynı davranış

| Kopya | Nerede | Kilit |
|---|---|---|
| Web | `src/utils/ai.ts`, `src/game/constants.ts` | kaynak |
| Dart (port) | `mobile/kelimeki_core/lib/src/ai/find_move.dart`, `constants.dart` (`aiLevelTopN`, `aiLevelSearch`) | golden'lar: `reducer_ai2` (Normal), `reducer_ai2_kolay` (tohumlu Kolay), `reducer_ai2_zor` (geniş arama döngü SIRASI), `ai_level.json` (`topN` + `search` sabitleri) — `dart run test/run_all.dart` |
| Edge | `supabase/functions/_game/ai.ts`, `_game/constants.ts` (`play-ai-turn`) | `npm run verify-edge-engine-parity`: sabit eşitliği + Normal 30 pozisyon + tohumlu Kolay 40 adım + Zor 37 adım (Normal'den sapma sayılır, 0 çıkarsa parametre kayboluyor demektir). Deploy: `verify_jwt` mevcut değerini (true) OKU ve aynen geçir |

⚠ Sürüm turu sırasında `mobile/**` altına (yorum bile olsa) dokunan her
merge `mobile-build`i tetikler ve `mobile-latest`teki paketi üzerine yazar;
Play'e yüklenmemiş bir paket varsa kütükteki koşu numarası/SHA-256 bayatlar.
Portun bayat "Zor Faz 5'e kadar yok" yorumları (`setup_screen.dart` ×2,
`ai_level_parity_test.dart` test adı) bu yüzden 1.0.8 yüklenene kadar
BİLEREK bırakıldı (7 Eylül 2026) — ilk mobil PR'da temizle.

Değişiklik disiplini: web motoru değişirse `npm run generate-golden-vectors`
→ **önce Normal golden'ları git diff boş** (bayt-eşlik kanıtı), sonra yeni
fixture; Dart aynı PR'da; Edge kopyası elle eşitlenir (gövde `diff` ile
birebir olmalı) ve `play-ai-turn` yeniden deploy edilir.

Ürün yüzü paritesi: `mobile/app/test/ai_level_parity_test.dart` web
`aiLevel.ts`i OKUYUP etiketleri, seçilebilir listeyi (`SELECTABLE_AI_LEVELS`
↔ `selectableAiLevels`), hitap cümlelerini, `aiLevelDescription`ın tüm
bileşimlerini ve HelpModal'ın zorluk paragrafını kilitler.

## 7. Değişmezler ve sözleşmeler

- **Normal = bugünkü motor, bayt-eş.** Normal'in davranışını değiştiren
  her şey "seviye işi" değil "motor işi"dir ve golden'ları kırar.
- `GameState.aiLevel?` opsiyonel; **Normal'de JSON'a YAZILMAZ** — eski
  kayıtlar, bulut kayıtları (`local_game_saves.state`), Canlı oyunlar hep
  alansız; port `codec.dart` `as String?` ile okur; `STORAGE_VERSION` bump
  EDİLMEZ. `'normal'` yazmak "aynı şeyi ikinci biçimde söylemek" olur.
- `games.ai_level` nullable (`null` = Normal); `buildGameRecord` yalnızca
  Kolay/Zor'da yazar; kart okuyucuları `aiLevelOf(raw)` ile `null`→Normal.
  Rozet: YZ oyununda her seviyede (Kolay YEŞİL · Normal TURUNCU · Zor
  KIRMIZI, `AI_LEVEL_BADGE_CLASS` ↔ `aiLevelBadgeColor`), Canlı'da HİÇ —
  "YZ oyunu mu" kararı çağıranda (`aiLevelForBadge(raw, isAiGame)`).
- Rastgelelik: N=1 hiç tüketmez; Kolay tek çağrı; yeni bir tüketici
  eklenirse golden replay'in SIRASI değişir (Dart aynı sırayı izlemeli).
- Döngü sırası davranışın parçası (eşitte ilk bulunan) — Dart'ta `sort`
  KULLANMA, sıralı ekleme yap; geniş aramada kanca/çapa → yön → aday → idx
  sırası TS ile birebir.
- Rakip rafına bakan yol YOK (kullanıcı kararı, §3).
- Seçici altı açıklama `aiLevelDescription(level, count, signedIn)`: her
  bileşimde birincilik + ikincilik ("k-lig puanı"; ikincilik 0 ise "puan
  kazandırmaz"), girişsizde puan cümlesinin ARDINDAN ayrı bir not:
  "(Puan takibi üyelik gerektirir)" — nokta CÜMLENİN sonunda, parantezin
  önünde; Zor'un "Bol şans!"ı en sonda (7 Eylül 2026, iki turda). Sayılar
  `leaguePoints`ten türetilir, metin tabloyla ayrışamaz. Tam metinler
  `ai_level_parity_test.dart`te kilitli.

## 8. Performans (Node, hamle başına, 12'şer oyun)

| Seviye | Ortalama | Medyan | p90 | p99 | En kötü |
|---|---|---|---|---|---|
| Normal | 22 ms | 22 | 28 | 51 | 77 ms |
| Kolay | 21 ms | 21 | 27 | 45 | 50 ms |
| Zor | 84 ms | 79 | 111 | 312 | 384 ms |

Tarayıcı/telefonda 2-4 katı beklenir; Zor'un tek hamlesi cihazda bir
saniyeye yaklaşabilir, ortalamada insan ölçeğinde. Smoke testi Zor
oyununa 20 sn tavan koyuyor.

## 9. Saha ölçümü ve kadranlar

**Sıfır çizgisi (7 Eylül 2026, `games` tablosu, `admin_ai_balance` filtresi:
yerel oyun, teslim yok):** 2 kişilik Normal 645 oyun → insan %53 / YZ %47;
4 kişilik Normal 119 oyun → insan %29 birinci, %20 ikinci (dört eşit
oyuncuda beklenti %25/%25 — dengeli). Kolay 1 oyun, Zor henüz canlıda
değil (portta 1.0.8 ile).

**Plan (ROADMAP #23 Faz 5, açık):** `admin_ai_balance` seviye kırılımı iki
hafta; hedef Kolay ~%30 · Normal ~%51 · Zor ~%70 YZ kazanma. Sapma varsa
**kadran ayarlanır, motor yeniden yazılmaz:**

| Sorun | Kadran |
|---|---|
| Kolay çok kolay / zor | `AI_LEVEL_TOP_N.kolay` 4 → 3 / 5 (N=8 bir kademe aşağısı) |
| Zor çok zor | `AI_LEVEL_SEARCH.zor.maxWordLen` 8 → 7 (tek oyun fark, ölçüldü) ya da geniş aramayı kısmak (ör. yalnızca kanca ya da yalnızca çok çapa) — ikisi de yeniden ölçülmeli |
| Zor yeterince zor değil | 9+ harf işe YARAMAZ (ölçüldü); kalan kaldıraç yeni bir hamle sınıfı, sezgisel değil |

Her kadran değişikliği üç kopyada birden + golden'lar (`ai_level.json`
sabitleri, `reducer_ai2_kolay`/`_zor` davranışı) + Edge paritesi + deploy.

**Ölçüm aleti:** `scripts/simulate-ai-levels.ts` —
`--n 1,2,3,4,5` (top-N koltuğu), `--motor zor|genis7|genis8|genis13`
(arama genişliği), `--oyun 200`, `--tohum`. Üretimin kendi
`findAIMoves`+`pickTopMove` çiftiyle oynar (kopya YOK); Normal koltuğu
reducer'ın `AI_PLAY`'idir. 200 oyunun altı karar için anlamsız (10 oyunun
GA'sı %31–83). Süre: dar arama ~1 sn/oyun, geniş ~2 sn/oyun.

## Köşe açılışı asimetrisi (17 Ağustos 2026)

> Kök `CLAUDE.md`'nin "Oyun Mekaniği Özeti" bölümünden buraya taşındı
> (8 Eylül 2026, doküman boyutu bütçesi) — tek satırı bile değişmedi.

**17 Ağustos 2026 — YZ bu kuralın YALNIZCA BİR YÖNÜNÜ kullanıyordu; sağ-alttaki YZ her oyuna 29 puan geride başlıyordu (kullanıcı bildirdi: "sağ alttaki YZ genelde hep sonuncu oluyor"):** `tryCornerStart` (`src/utils/ai.ts`) kelimeyi HER ZAMAN ev karesinden BAŞLATIP sağa/aşağı uzatıyordu. Bu, kuralın kendisinden gelen bir kısıt DEĞİL — doğrulama (`validatePlacement`, `src/utils/validator.ts:105`) yalnızca "konan hücrelerden biri ev karesi olsun" diyor, yön ya da "blokta başla" şartı yok; nitekim `tryPlace` (çapalı hamleler) baştan beri `idx` döngüsüyle iki yöne de uzatıyordu, yani tutarsızlık YZ'nin kendi içindeydi. **Sonuç köşeye göre asimetrikti ve ÖLÇÜLDÜ** (üretim `findAIMove`, raf `A B A R T M A`): köşe 0/1/2 → `7 taş "ABARTMA" 35 puan`, köşe 3 → `4 taş "ABAT" 6 puan`. 2 kişilik oyunda YZ HER ZAMAN köşe 3'tedir (`cornersFor`), yani bu her oyunda tekrarlanan bir açılış handikabıydı. **Düzeltme:** `tryCornerStart` artık kelimenin HANGİ harfinin eve denk geleceğini (`idx`) tek tek deniyor, kelime evden geriye ve ileriye uzayabiliyor. Düzeltmeden sonra dört köşe de `7 taş / 35 puan`; köşe 3 `12,6 … 12,12` oynuyor, yani merkeze doğru büyüyor. **Dart portu (`mobile/kelimeki_core/lib/src/ai/find_move.dart`) AYNI PR'da birebir güncellendi — döngü SIRASI da dahil:** `consider` eşit puanda İLK bulunanı tuttuğundan (strict `>`) sıra değişirse iki motor farklı hamle seçer ve parite sessizce kırılır. Golden vector'lar yeniden üretildi (bkz. o dosyanın fixture envanteri).
