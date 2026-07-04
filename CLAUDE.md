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
| `CORNER` | 5 | Köşe bölgesi kenar uzunluğu (5×5) |
| `RACK_SIZE` | 7 | Raftaki taş sayısı |
| `BINGO_BONUS` | 50 | 7 taşın hepsini tek hamlede kullanma bonusu |
| `MAX_PASS_ROUNDS` | 2 | Üst üste pas → oyun bitişi |

## Oyun Mekaniği Özeti

- **Köşe bölgeleri:** 4 köşe (0=sol-üst, 1=sağ-üst, 2=sol-alt, 3=sağ-alt). 2 oyuncuda çapraz köşeler (0 ve 3), 4 oyuncuda dördü kullanılır.
- **Köşe ihlali:** Bir oyuncu kendi 5×5 bölgesinin iç sınır karesine (`isZoneBoundaryCell`) taş koyduğunda o köşe "ihlal edilmiş" (`breached`) sayılır ve rakipler girebilir.
- **Köşe vergisi:** Rakip köşesine giren hamlenin puanı, saldırgan ve girilen köşe sahip(ler)i arasında eşit paylaşılır (1 rakip köşesi → 2 kişi, 2 rakip köşesi → 3 kişi; bkz. `computeInvasionShares` — `src/utils/validator.ts`). İnsan oyuncu için "Oyna" öncesinde onay modalı (`invasionConfirm` state) gösterilir. YZ için de aynı kural otomatik uygulanır.
- **Oyun bitişi:** Raf boş + torba boş → oyun biter. Kalan raf taşları oyuncunun puanından düşülür. Alternatif: tüm oyuncular arka arkaya MAX_PASS_ROUNDS tur pas geçerse biter.
- **Joker (`?`):** 4 adet, 0 puan, oynanırken herhangi bir Türkçe harfe dönüşür.
- **Torba:** Toplam 100 taş (Türkçe dağılım, `src/data/tiles.ts`). Not: bir ara 186'ya çıkarılmıştı, ama simülasyon torbanın gerçek bitirişi (rafını torba boşken tamamen bitirme + rakip puanlarını kapma) neredeyse imkânsız kıldığını gösterdi (4 oyunculuda 0/10), bu yüzden orijinal 100'e geri dönüldü.

## Bileşen Notları

- **`UserMenu`** — Giriş yapmamış kullanıcıya sadece "Giriş" butonu gösterir. Giriş yapılmışsa dropdown menüde Hesap Ayarları / Skor Kartı / Nasıl Oynanır? / Çıkış Yap bulunur. Lider Tablosu, başlangıçta sadece YZ'ye karşı oynanacağından menüden kaldırıldı (`Leaderboard` bileşeni ve API'leri hâlâ mevcut, ileride yeniden bağlanabilir). Supabase yapılandırılmamışsa bileşen `null` döner.
- **Skor Kartı (`ScoreCard`)** — YZ'ye karşı oynanan oyunlar dahil tüm oyun sonuçlarını gösterir (`games` tablosu, `player_stats` view). `saveGame()` yalnızca oturum açık kullanıcı için kayıt oluşturur (`App.tsx` — oyun bitince tüm oyuncular için, insan rakip şartı kaldırıldı); girişsiz hiçbir oyun verisi tutulmaz.
- **`Setup`** — Oyun başlangıç ekranı. "Nasıl oynanır?" linki burada da bulunur.
- **`Board`** — Her köşenin iç 2 kenarında (merkeze bakan L şeklinde) oyuncu rengiyle 2px çizgi gösterilir (`cornerEdgeStyle`).
- **`HelpModal`** — Oyun kuralları sayfası. Türkçe, kapsamlı.

## Türkçe Dil Notu

Büyük/küçük harf dönüşümünde **mutlaka** `trUpper()` / `trLower()` (`src/utils/turkish.ts`) kullanılmalı. Native `toUpperCase()`/`toLowerCase()` i/İ ve ı/I harflerini yanlış dönüştürür.

## Supabase

Env değişkenleri olmadan uygulama offline çalışır — `useAuth` içindeki `configured` flag'i `false` olur ve tüm hesap/lider tablosu özellikleri gizlenir. Lokal geliştirmede Supabase gerekmez.
