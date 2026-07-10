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
| `BINGO_BONUS` | 50 | 7 taşın hepsini tek hamlede kullanma bonusu |
| `MAX_PASS_ROUNDS` | 2 | Üst üste pas → oyun bitişi |

## Oyun Mekaniği Özeti

- **Köşe bölgeleri:** 4 köşe (0=sol-üst, 1=sağ-üst, 2=sol-alt, 3=sağ-alt), her biri 4×4. 2 oyuncuda her oyuncu tek bir köşeye sahiptir (1. oyuncu sol-üst=0, 2. oyuncu sağ-alt=3). 4 oyuncuda her oyuncu tek bir köşeye sahiptir (0,1,2,3 sırasıyla). Bir oyuncunun sahip olduğu köşeler `Player.corners: number[]` alanında tutulur (`cornersFor`, `src/game/constants.ts`).
- **Başlangıç karesi:** Her köşenin en uç tek hücresi (`cornerCell`, `src/game/constants.ts`) o oyuncunun zorunlu başlangıç noktasıdır — Board'da bir ev işaretiyle (`HomeMark`) gösterilir. İlk hamle mutlaka bu hücreye değmelidir (sadece 4×4 köşe bölgesine düşmesi yetmez); oradan tahtaya doğru genişlenir.
- **Genişleyen bölge:** Bir oyuncunun bölgesi köşe bölgesiyle sınırlı değil — köşesinden başlayıp, yalnızca kendi taşlarıyla ortogonal olarak bağlı hücrelere doğru genişler (`computeTerritory`/`computeAllTerritories`, `src/utils/validator.ts`). Genişleme monoton ve sadece oyuncunun kendi bölgesinden mümkündür: rakip taşları ya da boş hücreler zinciri taşımaz. Her hamleden sonra tahtadan yeniden hesaplanır; `Board.tsx` bu dinamik bölgeleri hem boş hücre tonlamasında hem de bölgenin tam dış hattında (`buildOutline`) gösterir.
- **Merkez bonus bölgesi:** Köşeler 4×4'e küçülünce ortada kalan şerit otomatik olarak 5×5'lik bir kare olur (`BONUS_ZONE`/`inBonusZone`, `src/game/constants.ts`) — tüm klasik bonus kareleri (K2/H2/H3) kaldırıldı, yerine bu tek bölge geldi. Bu bölgeye giren (bir hücresi bölgede olan) her kelimenin puanı x2 olur; klasik bonus karelerin aksine bu, alanı ilk kullanana değil, oraya her uğrayan kelimeye uygulanır (`wordPoints`, `src/utils/validator.ts`). Tahtanın tam ortasındaki tek hücre ayrıca K3'tür (üç kat kelime) — ama yalnızca o hücreye o tur yeni bir taş konursa, klasik bonus kare gibi. Board'da bölge altın renkte, "X2" yazılı; merkez hücre "K3" yazılı.
- **Köşeye giriş:** İlk hamleden sonra bir rakibin bölgesine taş koymanın hiçbir ön koşulu yok — her zaman serbest (eski "ihlal"/breach durumu kaldırıldı).
- **Bölge vergisi:** Bu turda konan taşlardan biri bir rakip bölgesinin (genişlemiş dinamik alan) içine düşüyorsa (girme) ya da kendisi bölgenin dışında kalsa bile sınırına bitişikse (değme), hamlenin puanı ikiye bölünür; yarısı oynayana kalır, yarısı bölge sahibine aktarılır. Aynı hamle iki farklı rakip bölgesiyle birden etkileşirse puan üç kişi arasında (oynayan + iki bölge sahibi) eşit paylaşılır (`computeInvasionSplit`, `src/utils/validator.ts`). İnsan oyuncu için "Oyna" öncesinde onay modalı (`invasionConfirm` state) gösterilir. YZ için de aynı kural otomatik uygulanır (`findAIMove` kendi bölge genişlemesini hesaba katarak güvenli/güvensiz hamleleri karşılaştırır).
- **Oyun bitişi:** Raf boş + torba boş → oyun biter. Kalan raf taşları oyuncunun puanından düşülür. Alternatif: tüm oyuncular arka arkaya MAX_PASS_ROUNDS tur pas geçerse biter.
- **Joker (`?`):** 2 adet, 0 puan, oynanırken herhangi bir Türkçe harfe dönüşür.
- **Torba:** Oyuncu sayısından bağımsız olarak sabit 100 taş (Türkçe dağılım, `src/data/tiles.ts`). Not: bir ara tüm modlarda 186'ya çıkarılmıştı, ama simülasyon torbanın gerçek bitirişini (rafını torba boşken tamamen bitirme + rakip puanlarını kapma) neredeyse imkânsız kıldığını gösterdi (4 oyunculuda 0/10), bu yüzden 100'e geri dönüldü. Bölge artık statik 5×5 değil dinamik/genişleyen olduğundan (bkz. yukarı), 4 oyunculu oyunlarda köşe sınırıyla etkileşim için torbayı büyütmeye (eski `BAG_SCALE_BY_PLAYER_COUNT` denemesi) gerek kalmadı; kaldırıldı.

## Bileşen Notları

- **`UserMenu`** — Giriş yapmamış kullanıcıya sadece "Giriş" butonu gösterir. Giriş yapılmışsa dropdown menüde Hesap Ayarları / Skor Kartı / Nasıl Oynanır? / Çıkış Yap bulunur. Lider Tablosu, başlangıçta sadece YZ'ye karşı oynanacağından menüden kaldırıldı (`Leaderboard` bileşeni ve API'leri hâlâ mevcut, ileride yeniden bağlanabilir). Supabase yapılandırılmamışsa bileşen `null` döner.
- **Skor Kartı (`ScoreCard`)** — YZ'ye karşı oynanan oyunlar dahil tüm oyun sonuçlarını gösterir (`games` tablosu, `player_stats` view). `saveGame()` yalnızca oturum açık kullanıcı için kayıt oluşturur (`App.tsx` — oyun bitince tüm oyuncular için, insan rakip şartı kaldırıldı); girişsiz hiçbir oyun verisi tutulmaz.
- **`Setup`** — Oyun başlangıç ekranı. "Nasıl oynanır?" linki burada da bulunur.
- **`Board`** — Her oyuncunun genişleyen bölgesinin tam dış hattı oyuncu rengiyle çizilir (`buildOutline` + `computeAllTerritories`); boş hücreler de kendi bölgesine dahilse tonlanır.
- **`HelpModal`** — Oyun kuralları sayfası. Türkçe, kapsamlı.

## Türkçe Dil Notu

Büyük/küçük harf dönüşümünde **mutlaka** `trUpper()` / `trLower()` (`src/utils/turkish.ts`) kullanılmalı. Native `toUpperCase()`/`toLowerCase()` i/İ ve ı/I harflerini yanlış dönüştürür.

## Supabase

Env değişkenleri olmadan uygulama offline çalışır — `useAuth` içindeki `configured` flag'i `false` olur ve tüm hesap/lider tablosu özellikleri gizlenir. Lokal geliştirmede Supabase gerekmez.
