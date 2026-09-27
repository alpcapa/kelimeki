// Kelimeki — karşılamanın İLK EKRANINDAKİ küçük tahta kesiti (27 Eylül 2026,
// ROADMAP #41; tasarım kararı `docs/decisions/onboarding.md` → "İlk oyun akışı
// v2", karar 1).
//
// Aşağıdaki iki büyük tanıtım tahtasından (`demoBoard.ts`) AYRI, çünkü işi
// başka: 13×13'lük bir oyunu göstermiyor, oyunun TEK fikrini anlatıyor —
// senin bölgen (camgöbeği), rakibin bölgesi (kırmızı) ve rakibin sınırına
// değen bir hamle (SAAT'in T'si). Bu yüzden `DEMO_BOARDS`a GİRMİYOR: o liste
// portun intro ekranına da üretiliyor (`generate-demo-board-dart`) ve 13×13
// ev-karesi bağlantısı doğrulamasından geçiyor; bir kesit ikisine de uymaz.
//
// ⚠ Harflerin kelime olması yine ZORUNLU — `npm run verify-demo-board` bu
// kesitin ≥2 uzunluktaki her yatay/dikey dizilimini de sözlüğe karşı sınar.
//
// Harita — her satır `KESIT_SUTUN` karakter:
//   `c` senin bölgen (boş) · `r` rakibin bölgesi (boş) · `.` tarafsız boş
//   BÜYÜK harf = senin taşın (bölgene dahil) · `harfler`deki hücre = rakibin
//   taşı (rakip bölgesine dahil).
export const KESIT_SUTUN = 7;

export const KESIT_HARITA: readonly string[] = [
  'ccc....',
  'cSAAT..',
  'c...rrr',
  '....rrr',
  '....rrr',
];

/** Rakibin taşları — `"satır,sütun"` → harf. KUL, dikey. */
export const KESIT_RAKIP_HARFLERI: Readonly<Record<string, string>> = {
  '2,5': 'K',
  '3,5': 'U',
  '4,5': 'L',
};

/** Rakip bölgesinin sınırına DEĞEN taş (vergiyi doğuran). */
export const KESIT_DEGEN = '1,4';

/**
 * Rakip bölgesi kesitin SAĞ ve ALT kenarında kesiliyor — oradaki dış hat
 * çizilmez, bölge kadrajın dışına sürüyor okunsun diye.
 */
export const KESIT_ACIK_KENARLAR = { sag: true, alt: true } as const;

export type KesitHucre =
  | { tur: 'bos'; bolge: 'sen' | 'rakip' | null }
  | { tur: 'tas'; sahip: 'sen' | 'rakip'; harf: string; degen: boolean };

/** Haritayı hücre listesine çevirir (satır satır). Doğrulayıcı da bunu kullanır. */
export function kesitHucreleri(): KesitHucre[][] {
  return KESIT_HARITA.map((satir, r) =>
    Array.from(satir).map((ch, c): KesitHucre => {
      const k = `${r},${c}`;
      const rakipHarf = KESIT_RAKIP_HARFLERI[k];
      if (rakipHarf) return { tur: 'tas', sahip: 'rakip', harf: rakipHarf, degen: false };
      if (ch === 'c') return { tur: 'bos', bolge: 'sen' };
      if (ch === 'r') return { tur: 'bos', bolge: 'rakip' };
      if (ch === '.') return { tur: 'bos', bolge: null };
      return { tur: 'tas', sahip: 'sen', harf: ch, degen: k === KESIT_DEGEN };
    }),
  );
}
