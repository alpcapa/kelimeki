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
- **Bölge vergisi:** Bu turda konan taşlardan biri bir rakip bölgesinin (genişlemiş dinamik alan) içine düşüyorsa (girme) ya da kendisi bölgenin dışında kalsa bile sınırına bitişikse (değme), hamlenin puanının 1/3'ü bölge sahibine aktarılır, 2/3'ü oynayanda kalır. Aynı hamle iki farklı rakip bölgesiyle birden etkileşirse puan üç kişi arasında (oynayan + iki bölge sahibi) eşit paylaşılır — bu durumda herkese 1/3 düşer (`computeInvasionSplit`, `src/utils/validator.ts`). İnsan oyuncu için "Oyna" öncesinde onay modalı (`invasionConfirm` state) gösterilir. YZ için de aynı kural otomatik uygulanır (`findAIMove` kendi bölge genişlemesini hesaba katarak güvenli/güvensiz hamleleri karşılaştırır).
- **Oyun bitişi:** Raf boş + torba boş → oyun biter. Her oyuncunun kendi elinde kalan raf taşlarının puanı kendi skorundan düşülür — rafını bitiren oyuncuya diğerlerinin kalan taş puanları eklenmez (`endGame`, `src/game/gameReducer.ts`). Alternatif: tüm oyuncular arka arkaya MAX_PASS_ROUNDS tur pas geçerse biter. İstisna: oyunu bitiren hamledeki taşların TAMAMI jokerse (başka hiçbir harf yoksa) ekstra bir bitiş bonusu kazanılır — 1 joker +25, 2 joker +50 (`jokerFinishBonus`, `src/game/constants.ts`).
- **Joker (`?`):** 2 adet, 0 puan, oynanırken herhangi bir Türkçe harfe dönüşür.
- **Torba:** Oyuncu sayısından bağımsız olarak sabit 100 taş (Türkçe dağılım, `src/data/tiles.ts`). Not: bir ara tüm modlarda 186'ya çıkarılmıştı, ama simülasyon torbanın gerçek bitirişini (rafını torba boşken tamamen bitirme + rakip puanlarını kapma) neredeyse imkânsız kıldığını gösterdi (4 oyunculuda 0/10), bu yüzden 100'e geri dönüldü. Bölge artık statik 5×5 değil dinamik/genişleyen olduğundan (bkz. yukarı), 4 oyunculu oyunlarda köşe sınırıyla etkileşim için torbayı büyütmeye (eski `BAG_SCALE_BY_PLAYER_COUNT` denemesi) gerek kalmadı; kaldırıldı.

## Bileşen Notları

- **`UserMenu`** — Giriş yapmamış kullanıcıya sadece "Giriş" butonu gösterir. Giriş yapılmışsa dropdown menüde Hesap Ayarları / Skor Kartı / Nasıl Oynanır? / Çıkış Yap bulunur. Lider Tablosu, başlangıçta sadece YZ'ye karşı oynanacağından menüden kaldırıldı (`Leaderboard` bileşeni ve API'leri hâlâ mevcut, ileride yeniden bağlanabilir). Supabase yapılandırılmamışsa bileşen `null` döner.
- **Skor Kartı (`ScoreCard`)** — YZ'ye karşı oynanan oyunlar dahil tüm oyun sonuçlarını gösterir (`games` tablosu, `player_stats` view). `saveGame()` yalnızca oturum açık kullanıcı için kayıt oluşturur (`App.tsx` — oyun bitince tüm oyuncular için, insan rakip şartı kaldırıldı); girişsiz hiçbir oyun verisi tutulmaz. `total_score` (lig puanı: 4 kişilikte 1.=2, 2.=1, diğerleri 0; 2 kişilikte sadece 1.=2, 2.=0 — tek rakipli oyunda ikinci olmak kaybetmekle aynı şey olduğundan puan getirmez; beraberlikte aynı sırayı paylaşanların hepsi o puanı alır; teslim olma (`surrendered`) her modda sabit -2 cezasıdır) `player_stats` view'ında `(user_id, player_count)` bazında ayrı satırlarda tutulur — `ScoreCard` her sekmede (2/4 oyunculu) o modun `total_score`'unu ayrı bir "Kazanılan Puan" kutusunda gösterir, başlıktaki "Lig Puanı" ise iki modun toplamıdır. Alt kısımdaki "Tüm Oyunları Gör" linki `GameHistoryModal`'ı açar; aktif sekmenin (2/4 oyunculu) tüm geçmiş oyunlarını en yeniden eskiye, tarih/saat ve final sıralamasındaki oyuncu/puan listesiyle gösterir (`games.players` jsonb sütunu — final sıralamasına göre `{name, score, is_ai}[]`, `buildGameRecord`'da doldurulur; bu sütun eklenmeden önceki kayıtlarda `null`, `GameHistoryModal` bu durumda `player_score`/`ai_score`'dan yaklaşık bir "Sen"/"Rakip" satırı üretir).
- **`Setup`** — Oyun başlangıç ekranı. "Nasıl oynanır?" linki burada da bulunur.
- **`Board`** — Her oyuncunun genişleyen bölgesinin tam dış hattı oyuncu rengiyle çizilir (`buildOutline` + `computeAllTerritories`); boş hücreler de kendi bölgesine dahilse tonlanır.
- **`HelpModal`** — Oyun kuralları sayfası. Türkçe, kapsamlı.

## Türkçe Dil Notu

Büyük/küçük harf dönüşümünde **mutlaka** `trUpper()` / `trLower()` (`src/utils/turkish.ts`) kullanılmalı. Native `toUpperCase()`/`toLowerCase()` i/İ ve ı/I harflerini yanlış dönüştürür.

## Supabase

Env değişkenleri olmadan uygulama offline çalışır — `useAuth` içindeki `configured` flag'i `false` olur ve tüm hesap/lider tablosu özellikleri gizlenir. Lokal geliştirmede Supabase gerekmez.
