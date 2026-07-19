-- Harfik — proper-nouns.mjs içindeki bitişik yazılmış çok-kelimeli
-- ülke/başkent adlarını sözlükten çıkar
-- Bu kelimeler TDK GTS'den değil, coğrafi eksikliği kapatmak için elle
-- eklenmiş scripts/proper-nouns.mjs listesinden geliyordu. Aralarında
-- birden fazla gerçek kelimeyi boşluksuz birleştirilmiş olanlar vardı
-- (Amerika Birleşik Devletleri -> amerikabirleşikdevletleri, Birleşik Arap
-- Emirlikleri -> birleşikarapemirlikleri, Saint Vincent ve Grenadinler ->
-- saintvincentvegrenadinler gibi) — önceki üç turda GTS kaynaklı aynı
-- sorunu (çok kelimeli maddelerin boşluksuz tek token'a sıkıştırılması)
-- temizlerken kullanılan kural burada da geçerli: birden fazla kelimeden
-- oluşan hiçbir şey oynanabilir tek kelime değildir. 52 kelime siliniyor
-- (28 ülke adı, 22 başkent/şehir adı, 2 tirelenerek yazılan resmi bileşik
-- ad: Bosna-Hersek, Gine-Bissau).
delete from public.words where word in (
  'amerikabirleşikdevletleri',
  'antiguavebarbuda',
  'bağımsızsamoadevleti',
  'birleşikarapemirlikleri',
  'birleşikkrallık',
  'doğutimor',
  'ekvatorginesi',
  'fildişisahili',
  'güneyafrika',
  'güneykore',
  'güneysudan',
  'kuzeykore',
  'kuzeymakedonya',
  'marshalladaları',
  'ortaafrikacumhuriyeti',
  'papuayenigine',
  'saintkittsvenevis',
  'saintlucia',
  'saintvincentvegrenadinler',
  'saotomeveprincipe',
  'sierraleone',
  'solomonadaları',
  'srilanka',
  'trinidadvetobago',
  'yenizelanda',
  'yeşilburun',
  'dominikcumhuriyeti',
  'kongocumhuriyeti',
  'addisababa',
  'andorralavella',
  'buenosaires',
  'hongkong',
  'kualalumpur',
  'losangeles',
  'portauprince',
  'portlouis',
  'portmoresby',
  'portofspain',
  'portonovo',
  'portvila',
  'riodejaneyro',
  'saintjohns',
  'sanjose',
  'sanktpeterburg',
  'sanmarino',
  'sansalvador',
  'saopavlo',
  'saotome',
  'santodomingo',
  'yenidelhi',
  'bosnahersek',
  'ginebissau'
);
