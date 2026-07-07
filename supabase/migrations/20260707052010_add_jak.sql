-- Harfik — sözlükte eksik olan "jak" maddesini ekler.
-- Kaynak: TDK Güncel Türkçe Sözlük.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('jak', char_length('jak'), public.harfik_points('jak'), 'a.', '["Bir elektrik kablosunun ucunu oluşturan ve jaka (dişi fişe) sokulan metal uç"]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
