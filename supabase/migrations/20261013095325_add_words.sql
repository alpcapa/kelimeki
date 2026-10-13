-- Kelimeki — elle tutulan kelime/anlam listelerinin uygulanması
-- Kaynak: scripts/{proper-nouns,extra-words,extra-meanings}.mjs
--         (scripts/augment-dictionary.mjs ile üretildi).
-- 6 yeni madde, 0 anlam güncellemesi.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('efes', char_length('efes'), public.kelimeki_points('efes'), null, '["Günümüzde İzmir''in Selçuk ilçesinde yer alan, antik çağın en önemli ve görkemli liman kentlerinden biri."]'::jsonb),
  ('fuleli', char_length('fuleli'), public.kelimeki_points('fuleli'), 'sf.', '["Adım aralığı geniş olan, uzun adımlarla hareket eden."]'::jsonb),
  ('kufi', char_length('kufi'), public.kelimeki_points('kufi'), 'a.', '["Hat sanatında, Arap alfabesinin dik, sert, köşeli ve geometrik çizgilerle yazılan en eski biçimi; adını Irak''ın Kûfe şehrinden alır, İslamiyetin ilk dönemlerinde Kur''an-ı Kerim yazımlarında ve yapı kitabelerinde sıkça kullanılmıştır.","Bazı Müslümanların günlük hayatta veya namaz kılarken kafalarına taktığı takke benzeri başlık."]'::jsonb),
  ('pa', char_length('pa'), public.kelimeki_points('pa'), 'a.', '["Eski Türkçede veya köken olarak ayak (paça, patika gibi sözcüklerin kökeniyle ilişkilendirilir)."]'::jsonb),
  ('regl', char_length('regl'), public.kelimeki_points('regl'), 'a.', '["Aybaşı; belirli yaşlar arasında kadınların ayda bir adet görmesi durumu (ay hâli)."]'::jsonb),
  ('tartolet', char_length('tartolet'), public.kelimeki_points('tartolet'), 'a.', '["Normal tartların tek kişilik ve daha küçük boyutta olan, içi krema dolgulu minik bir tür tatlı veya hamur işi."]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
