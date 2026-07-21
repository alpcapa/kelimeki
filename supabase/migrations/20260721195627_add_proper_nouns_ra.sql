-- Kelimeki — dünya ülkeleri, başkentleri, büyük şehirleri ve diller
-- Kaynak: scripts/proper-nouns.mjs (scripts/augment-dictionary.mjs ile üretildi).
-- 1 yeni madde.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).
-- Not: rebrand sonrası production'da fonksiyon hâlâ harfik_points olarak
-- kayıtlı (kelimeki_points'e yeniden adlandırılmamış) — augment-dictionary.mjs
-- çıktısı burada elle harfik_points'e düzeltildi, uygulanan SQL budur.

insert into public.words (word, len, points, pos, meanings) values
  ('ra', char_length('ra'), public.harfik_points('ra'), null, '["Mısır mitolojisinde güneş tanrısı."]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
