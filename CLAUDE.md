# Harfik — Claude Code Rehberi

## Proje Nedir?

Türkçe kelime oyunu. Scrabble benzeri ama 13×13 tahtada köşe bölgeleriyle oynanan özgün bir mekanik. React + TypeScript, Vite ile build edilir, Vercel'e deploy edilir. Backend opsiyonel — Supabase env değişkenleri yoksa uygulama tamamen offline çalışır.

## Tech Stack

- **UI:** React 18 + TypeScript
- **Build:** Vite 5
- **Stil:** Tailwind CSS (nömorfik tasarım dili)
- **Backend (opsiyonel):** Supabase (auth, lider tablosu, istatistik, kelime anlamları)
- **Deploy:** Vercel

## Komutlar

```bash
npm run build   # TypeScript derleme + üretim build
npm run dev     # Geliştirme sunucusu
```

## Git / Branch Kuralı

- Branch adı: `claude/<kısa-açıklama>` formatı
- Her feature/fix ayrı branch → PR → main'e merge
- Main'e merge = Vercel otomatik deploy tetiklenir

## Klasör Yapısı

```
src/
  components/   # React UI bileşenleri
  game/         # Oyun mantığı ve durum yönetimi
    constants.ts    # Tahta sabitleri, köşe hesapları, bonus konumları
    gameReducer.ts  # useReducer tabanlı oyun state makinesi
    types.ts        # GameState, Player, Tile tipleri
  utils/        # Saf fonksiyonlar (validator, board, ai, bag)
  data/         # Kelime listesi (92k+), harf dağılımı, kelime anlamları
  lib/          # Supabase istemcisi ve API sarmalayıcısı
  hooks/        # useAuth
```

## Kritik Sabitler (src/game/constants.ts)

| Sabit | Değer | Açıklama |
|-------|-------|----------|
| `SIZE` | 13 | Tahta boyutu (13×13) |
| `CORNER` | 4 | Köşe bölgesi kenar uzunluğu (4×4) |
| `RACK_SIZE` | 7 | Raftaki taş sayısı |
| `BINGO_BONUS` | 25 | 7 taşın hepsini tek hamlede kullanma bonusu |
| `MAX_PASS_ROUNDS` | 2 | Üst üste pas → oyun bitişi |

## Oyun Mekaniği Özeti

- **Köşe bölgeleri:** 4 köşe (0=sol-üst, 1=sağ-üst, 2=sol-alt, 3=sağ-alt), her biri 4×4. 2 oyuncuda her oyuncu tek bir köşeye sahiptir (1. oyuncu sol-üst=0, 2. oyuncu sağ-alt=3). 4 oyuncuda her oyuncu tek bir köşeye sahiptir (0,1,2,3 sırasıyla). Bir oyuncunun sahip olduğu köşeler `Player.corners: number[]` alanında tutulur (`cornersFor`, `src/game/constants.ts`).
- **Başlangıç karesi:** Her köşenin en uç tek hücresi (`cornerCell`, `src/game/constants.ts`) o oyuncunun zorunlu başlangıç noktasıdır — Board'da bir ev işaretiyle (`HomeMark`) gösterilir. İlk hamle mutlaka bu hücreye değmelidir (sadece 4×4 köşe bölgesine düşmesi yetmez); oradan tahtaya doğru genişlenir.
- **Genişleyen bölge:** Bir oyuncunun bölgesi köşe bölgesiyle sınırlı değil — köşesinden başlayıp, yalnızca kendi taşlarıyla ortogonal olarak bağlı hücrelere doğru genişler (`computeTerritory`/`computeAllTerritories`, `src/utils/validator.ts`). Genişleme monoton ve sadece oyuncunun kendi bölgesinden mümkündür: rakip taşları ya da boş hücreler zinciri taşımaz. Her hamleden sonra tahtadan yeniden hesaplanır; `Board.tsx` bu dinamik bölgeleri hem boş hücre tonlamasında hem de bölgenin tam dış hattında (`buildOutline`) gösterir. Sonuç olarak, bir oyuncu vergi ödeyerek rakip bölgesine koyduğu taşı kendi zincirine (köşesine kadar kesintisiz kendi taşlarıyla) bağlarsa, o hücre bir sonraki hesaplamada kendi bölgesine geçer ve rakibin bölgesi orada küçülür — izole (zincire bağlanmayan) bir taş ise rakibin bölgesinde kalmaya devam eder.
- **Merkez bonus bölgesi:** Köşeler 4×4'e küçülünce ortada kalan şerit otomatik olarak 5×5'lik bir kare olur (`BONUS_ZONE`/`inBonusZone`, `src/game/constants.ts`) — tüm klasik bonus kareleri (K2/H2/H3) kaldırıldı, yerine bu tek bölge geldi. Bu bölgedeki bir hücreye o turda **yeni** bir taş konursa kelimenin puanı x2 olur — klasik bonus kare gibi, yalnızca hücre ilk kullanıldığı turda etkilidir (`wordPoints`, `src/utils/validator.ts`). Önceden (önceki bir turda) o hücreye konmuş bir taşa sırf bağlanmak/geçmek x2 kazandırmaz. Tahtanın tam ortasındaki tek hücre ayrıca X3'tür (üç kat kelime) — aynı şekilde yalnızca o hücreye o tur yeni bir taş konursa. X2 ve X3 hiçbir zaman aynı kelimede birleşmez: bir kelimenin yeni taşlarından biri X3 hücresindeyse o kelime tamamen ×3 sayılır — kelimenin başka bir yeni taşı ayrıca X2 bölgesine düşse bile üstüne X2 eklenmez (`wordPoints`, `src/utils/validator.ts`). X3'e hiç değmeyen bir kelime, yeni bir taşıyla X2 bölgesine düşerse sadece ×2 olur. (Aynı hamlede oluşan farklı kelimeler birbirinden bağımsızdır — biri X3, diğeri X2 alabilir, ama bunun sebebi iki ayrı kelimenin kendi kurallarını uygulaması, tek bir kelimenin çarpanları birleştirmesi değildir.) Board'da bölgenin arka planına büyük bir "X2" filigranı yazılır (köşelerdeki oyuncu numarası filigranıyla aynı mantık); merkez hücre altın zeminden ayrılan turuncu bir zeminle kendi "X3" etiketini taşır.
- **Köşeye giriş:** İlk hamleden sonra bir rakibin bölgesine taş koymanın hiçbir ön koşulu yok — her zaman serbest (eski "ihlal"/breach durumu kaldırıldı).
- **Bölge vergisi:** Bu turda konan taşlardan biri bir rakip bölgesinin (genişlemiş dinamik alan) içine düşüyorsa (girme) ya da kendisi bölgenin dışında kalsa bile sınırına bitişikse (değme), hamlenin puanından bir pay bölge sahi(pleri)ne aktarılır. Etkileşilen rakip bölge sayısına (n) göre oynayanın payı küçülür: n=1'de 2/3 oynayanda kalır, 1/3 tek bölge sahibine gider; n=2'de yarısı (1/2) oynayanda kalır, kalan yarısı iki bölge sahibi arasında eşit paylaşılır (kişi başı 1/4); n=3'te 1/3 oynayanda kalır, kalan 2/3 üç bölge sahibi arasında eşit paylaşılır (kişi başı 2/9) — genel formül, her bölge sahibinin payı `basePts*(n+1)/(6n)` (`computeInvasionSplit`, `src/utils/validator.ts`). İnsan oyuncu için "Oyna" öncesinde onay modalı (`invasionConfirm` state) gösterilir. YZ için de aynı kural otomatik uygulanır (`findAIMove` kendi bölge genişlemesini hesaba katarak güvenli/güvensiz hamleleri karşılaştırır).
- **Oyun bitişi:** Raf boş + torba boş → oyun biter. Her oyuncunun kendi elinde kalan raf taşlarının puanı kendi skorundan düşülür — rafını bitiren oyuncuya diğerlerinin kalan taş puanları eklenmez (`endGame`, `src/game/gameReducer.ts`). Alternatif: tüm oyuncular arka arkaya MAX_PASS_ROUNDS tur puansız geçerse (pas VEYA taş değiştirme — ikisi de skoru etkilemediğinden ve taş değiştirme torbadaki taş sayısını azaltmadığından aynı sayaca dahildir, yoksa oyuncular sürekli taş değiştirerek oyunu hiç bitirmeyebilirdi) biter. İstisna: oyunu bitiren hamledeki taşların TAMAMI jokerse (başka hiçbir harf yoksa) ekstra bir bitiş bonusu kazanılır — 1 joker +25, 2 joker +50 (`jokerFinishBonus`, `src/game/constants.ts`).
- **Joker (`?`):** 2 adet, 0 puan, oynanırken herhangi bir Türkçe harfe dönüşür.
- **Torba:** Oyuncu sayısından bağımsız olarak sabit 100 taş (Türkçe dağılım, `src/data/tiles.ts`). Not: bir ara tüm modlarda 186'ya çıkarılmıştı, ama simülasyon torbanın gerçek bitirişini (rafını torba boşken tamamen bitirme + rakip puanlarını kapma) neredeyse imkânsız kıldığını gösterdi (4 oyunculuda 0/10), bu yüzden 100'e geri dönüldü. Bölge artık statik 5×5 değil dinamik/genişleyen olduğundan (bkz. yukarı), 4 oyunculu oyunlarda köşe sınırıyla etkileşim için torbayı büyütmeye (eski `BAG_SCALE_BY_PLAYER_COUNT` denemesi) gerek kalmadı; kaldırıldı.
- **Teslim olma (kademeli):** Bir oyuncu teslim olduğunda (`Player.surrendered`, `SURRENDER` action, `src/game/gameReducer.ts`) oyun tümüyle bitmez — o oyuncu sırayı devretmeden çekilir, kalan oyuncular (YZ ve/veya diğer hotseat oyuncuları) oynamaya devam eder; sıra rotasyonu ve pas-turu sayacı yalnızca teslim olmamış oyuncuları sayar (`nextActiveIndex`/`activePlayerCount`). Teslim olan oyuncunun puanı dondurulmaz, **sıfırlanır** (`score: 0`) ve rafında kalan kullanılmamış taşlar torbaya geri karıştırılır (`shuffle`) — böylece o taşlar kalan oyuncular için tamamen kaybolmaz. Oyun yalnızca teslim sonrası aktif oyuncu sayısı 1'e düşünce biter: 2 kişilik oyunda tek teslim bunu anında tetikler; 4 kişilikte sırasıyla 3 → 2 → (üçüncü teslimde) 1 aktif oyuncuya iner ve o son kalan oyuncu kazanır — sıralama, teslim olanları puanlarından bağımsız olarak her zaman en sona koyan `rankPlayers` (`src/utils/ranking.ts`) ile hesaplanır ve hem `GameOver` hem `buildGameRecord`'un (`App.tsx`) skor kaydı bunu kullanır. Logodaki "Çık" onayı, sırası gelen hâlâ oyundaki insan oyuncuyu (hotseat'te herkes kendi sırasında teslim olabilsin diye), o yoksa hesap sahibini (1. oyuncu) hedefler; hesap sahibi teslim olduğunda kaydı hemen (`surrendered: true`, sabit -2 ceza, `games.player_score`/`players[].score` olarak 0) tutulur, oyun kendiliğinden bitince tekrar kaydedilmez. Bu anlık kayıt `SURRENDER` dispatch edilmeden ÖNCE (hâlâ eski state'le) çağrıldığından, `buildGameRecord` ikinci bir `surrenderingIndex` parametresiyle teslim olacak oyuncuyu sıralamadan önce elle `surrendered:true, score:0` işaretler — yoksa `rankPlayers` onu hâlâ aktifmiş gibi puanına göre sıralardı. `games.players` jsonb'sindeki her satırda artık `surrendered` alanı da var; `GameHistoryModal` yalnızca teslim olan oyuncunun kendi satırında (genel/üst köşede değil) "Teslim Oldu" rozeti gösterir.
- **Devam eden oyunun kalıcılığı:** `phase==='play'` ve oyun bitmemişken tüm state her değişiklikte `localStorage`'a yazılır (`saveGameState`/`loadGameState`/`clearGameState`, `src/utils/gameStorage.ts`); uygulama açılışında (`App.tsx`, `useReducer`'ın lazy init'i) bitmemiş bir kayıt varsa Setup ekranı atlanıp direkt kaldığı yere dönülür. Bunun asıl amacı: kalıcılık olmasaydı biri kaybederken sekmeyi/uygulamayı kapatıp yeniden açarak "teslim ol"un -2 cezasından ve kaydından tamamen kaçabilirdi — artık kapat-aç hiçbir şeyi sıfırlamıyor, oyuncu ya oynamaya devam etmek ya da mevcut "Çık" (teslim ol) akışını kullanmak zorunda. Oyun bitince (`state.isGameOver`) ya da kurulum ekranına dönülünce (`ABANDON`) kayıt otomatik silinir. Bu yalnızca tek cihazlık bir çözüm — localStorage tarayıcıya özel olduğundan ileride online (uzak/karşılıklı) oyunculuk eklenirse bu mekanizma o moda taşınmaz; orada state'in sunucuda (Supabase) otoriter olması ve hamlelerin sunucu tarafında doğrulanması gerekir.
- **Bitmiş oyunların offline/misafir kuyruğu (`src/utils/gameSync.ts`):** `saveGameDurable`, `buildGameRecord`'un (`App.tsx`) ürettiği kaydı önce hemen göndermeyi dener; bu başarısız olursa — çevrimdışıyken, ağ hatasında ya da bu cihazda hiç giriş yapılmamışken (misafir) — kaydı `localStorage`'a (`harfik:pending-games`, en fazla `MAX_PENDING_GAMES=300`, aşılırsa en eskiler düşer) kuyruklar. Her kayıt istemcide üretilen bir `id` (uuid) ve gerçek bitiş anını taşıyan bir `created_at` (ISO) içerir: `id`, kaybolan bir cevaptan sonra aynı kaydın tekrar denenmesi sunucuda ikinci bir satır açmasın diye — `saveGame` (`src/lib/api.ts`) bu durumda dönen "23505" (unique violation) hatasını başarı sayar; `created_at`, kayıt günler sonra senkronlanabildiğinden sunucunun `insert` anındaki varsayılan `now()`'ı yerine geçer, böylece oyun geçmişinde doğru kronolojik yere yerleşir. `flushPendingGames`, uygulama açılışında/`online` olayında/giriş durumu değişince (`App.tsx`'teki `useEffect([user])`) çağrılır; bu cihazda **daha önce hiç oturum yoksa** (saf misafir) ağa hiç dokunmadan hemen çıkar, kuyruk kişi bu cihazda giriş/kayıt yapana kadar sessizce bekler — o an geldiğinde tüm kuyruk o hesaba aktarılır. Kuyruk yalnızca tutulduğu cihaza özeldir; farklı cihazlarda ayrı ayrı birikir ve her biri kendi cihazında oturum açıldığında kendi kuyruğunu gönderir.

## Bileşen Notları

- **`UserMenu`** — Giriş yapmamış kullanıcıya sadece "Giriş" butonu gösterir. Giriş yapılmışsa dropdown menüde Hesap Ayarları / Skor Kartı / Nasıl Oynanır? / Çıkış Yap bulunur. Lider Tablosu, başlangıçta sadece YZ'ye karşı oynanacağından menüden kaldırıldı (`Leaderboard` bileşeni ve API'leri hâlâ mevcut, ileride yeniden bağlanabilir). Supabase yapılandırılmamışsa bileşen `null` döner.
- **Skor Kartı (`ScoreCard`)** — YZ'ye karşı oynanan oyunlar dahil tüm oyun sonuçlarını gösterir (`games` tablosu, `player_stats` view). `saveGame()` yalnızca oturum açık kullanıcı için sunucuya kayıt oluşturur (`App.tsx` — oyun bitince tüm oyuncular için, insan rakip şartı kaldırıldı); misafir (girişsiz) oynanan oyunlar sunucuya hiçbir zaman anonim olarak gönderilmez, ama offline kuyrukla (`gameSync.ts`, bkz. yukarı) bu cihazda saklanıp kişi ileride giriş/kayıt yaparsa hesabına aktarılır. `total_score` (lig puanı: 4 kişilikte 1.=2, 2.=1, diğerleri 0; 2 kişilikte sadece 1.=2, 2.=0 — tek rakipli oyunda ikinci olmak kaybetmekle aynı şey olduğundan puan getirmez; beraberlikte aynı sırayı paylaşanların hepsi o puanı alır; teslim olma (`surrendered`) her modda sabit -2 cezasıdır) `player_stats` view'ında `(user_id, player_count)` bazında ayrı satırlarda tutulur — `ScoreCard` her sekmede (2/4 oyunculu) o modun `total_score`'unu ayrı bir "Kazanılan Puan" kutusunda gösterir, başlıktaki "Lig Puanı" ise iki modun toplamıdır. Alt kısımdaki "Tüm Oyunları Gör" linki `GameHistoryModal`'ı açar; aktif sekmenin (2/4 oyunculu) tüm geçmiş oyunlarını en yeniden eskiye, tarih/saat ve final sıralamasındaki oyuncu/puan listesiyle gösterir (`games.players` jsonb sütunu — final sıralamasına göre `{name, score, is_ai}[]`, `buildGameRecord`'da doldurulur; bu sütun eklenmeden önceki kayıtlarda `null`, `GameHistoryModal` bu durumda `player_score`/`ai_score`'dan yaklaşık bir "Sen"/"Rakip" satırı üretir).
- **`Setup`** — Oyun başlangıç ekranı. "Nasıl oynanır?" linki burada da bulunur.
- **`Board`** — Her oyuncunun genişleyen bölgesinin tam dış hattı oyuncu rengiyle çizilir (`buildOutline` + `computeAllTerritories`); boş hücreler de kendi bölgesine dahilse tonlanır.
- **`HelpModal`** — Oyun kuralları sayfası. Türkçe, kapsamlı.

## Türkçe Dil Notu

Büyük/küçük harf dönüşümünde **mutlaka** `trUpper()` / `trLower()` (`src/utils/turkish.ts`) kullanılmalı. Native `toUpperCase()`/`toLowerCase()` i/İ ve ı/I harflerini yanlış dönüştürür.

## Supabase

Env değişkenleri olmadan uygulama offline çalışır — `useAuth` içindeki `configured` flag'i `false` olur ve tüm hesap/lider tablosu özellikleri gizlenir. Lokal geliştirmede Supabase gerekmez.

### Migration'lar — CI yok, elle uygulama

Kullanıcı iPad üzerinden çalışıyor; `.github/workflows/supabase-migrations.yml` (main'e push'ta `supabase db push` çalıştırır) teoride var ama kullanıcının bunu tetikleyip sonucunu takip edecek bir CLI/CI erişimi yok. Bu yüzden **her yeni migration'ı Claude'un kendisi, Supabase MCP (`apply_migration`/`execute_sql`) ile doğrudan production'a uygulaması gerekiyor** — migration dosyasını repoya eklemek tek başına yeterli değil, kimse `db push`'un geçtiğini doğrulamıyor. Akış:

1. Migration dosyasını normal şekilde `supabase/migrations/` altına yaz.
2. SQL'i kullanıcıya açıkça göster (ne çalıştırılacağını gizleme).
3. Supabase MCP ile aynı SQL'i doğrudan production'a uygula, sonra `execute_sql` ile canlıda doğrula (view/fonksiyon tanımını tekrar oku).
4. Uyguladığını kullanıcıya açıkça söyle ("canlıya uyguladım, doğruladım" gibi) — sessizce dosya eklemekle yetinme.

15 Temmuz 2026'da bu yüzden repo ile production'ın migration geçmişi (`supabase_migrations.schema_migrations`) birbirinden kopmuştu: geçmiş migration'lar CI yerine elle (muhtemelen `apply_migration` ile, kendi otomatik zaman damgasıyla) uygulanmış, dosya adlarındaki timestamp'lerle hiç eşleşmiyordu, `supabase db push` bu yüzden sürekli "Remote migration versions not found" hatasıyla fail ediyordu. Tüm dosyaların içeriği tek tek production'da doğrulanıp (`games.players` jsonb için eksik olan tek dosya da eklendi) kayıt tablosu repodaki 26 dosyayla birebir eşleşecek şekilde yeniden yazıldı. Yeni migration eklerken bu senkronu bozmamak için 1-4 adımlarını takip et.
