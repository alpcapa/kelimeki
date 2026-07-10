-- Harfik — sözlükte eksik olan "go" maddesini ekler.
-- Kaynak: TDK Güncel Türkçe Sözlük.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('go', char_length('go'), public.harfik_points('go'), 'a.', '["Uzak Doğu kökenli, siyah ve beyaz taşlarla iki kişi arasında oynanan bir zekâ oyunu"]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
