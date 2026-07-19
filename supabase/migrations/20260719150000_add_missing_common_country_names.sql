-- Harfik — eksik yaygın ülke adlarını sözlüğe ekle
-- scripts/proper-nouns.mjs, TDK'nin coğrafi eksikliğini kapatmak için elle
-- eklenmiş bir liste; ancak önceki tarama sırasında bazı ülkelerin resmî
-- çok-kelimeli adı listede varken (ör. Kuzey Makedonya, Birleşik Krallık —
-- ikisi de az önce çıkarıldı) günlük dilde kullanılan tek kelimelik kısa
-- adlarının hiç eklenmediği görüldü. 155 ülkelik sistematik bir tarama
-- sonucunda 4 eksik bulundu:
--   - makedonya: Kuzey Makedonya'nın günlük dilde kullanılan kısa adı
--   - ingiltere: Birleşik Krallık'ın günlük dilde kullanılan adı
--   - kongo: Afrika'daki ülkenin/bölgenin/nehrin ortak kısa adı
--   - samoa: Bağımsız Samoa Devleti'nin günlük dilde kullanılan kısa adı
-- Dördü de tek kelime; TDK'de olmadıklarından pos=null, meanings tek
-- elemanlı bir dizi olarak eklenir (proper-nouns.mjs'teki diğer özel adlarla
-- aynı biçim).
insert into public.words (word, len, points, pos, meanings) values
  ('kongo', char_length('kongo'), public.harfik_points('kongo'), null, '["Afrika''da bir ülke."]'::jsonb),
  ('makedonya', char_length('makedonya'), public.harfik_points('makedonya'), null, '["Avrupa''da bir ülke."]'::jsonb),
  ('samoa', char_length('samoa'), public.harfik_points('samoa'), null, '["Okyanusya''da bir ülke."]'::jsonb),
  ('ingiltere', char_length('ingiltere'), public.harfik_points('ingiltere'), null, '["Avrupa''da bir ülke; Birleşik Krallık''ın günlük dilde kullanılan adı."]'::jsonb)
on conflict (word) do update set
  len = excluded.len,
  points = excluded.points,
  pos = excluded.pos,
  meanings = excluded.meanings;
