-- Kelimeki — elle tutulan kelime/anlam listelerinin uygulanması
-- Kaynak: scripts/{proper-nouns,extra-words,extra-meanings}.mjs
--         (scripts/augment-dictionary.mjs ile üretildi).
-- 1 yeni madde, 0 anlam güncellemesi.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('misli', char_length('misli'), public.kelimeki_points('misli'), 'a.', '["Benzer, örnek, eşdeğer.","Kat (bir sayının kendisiyle çarpıldığı miktar)."]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
