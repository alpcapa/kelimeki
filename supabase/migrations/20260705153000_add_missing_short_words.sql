-- Harfik — "id" ve "pi" seed_dictionary.sql'de (20260628090300) doğru
-- anlamlarıyla mevcuttu, ama üretim veritabanında hiç var olmadılar (ilk
-- seed sırasında bir şekilde atlanmışlar). Bu yüzden yerel words.ts /
-- WORD_SET bu iki kelimeyi geçerli sayıp önizlemede yeşil gösteriyordu,
-- ama is_valid_word RPC'si tabloda bulamadığı için "Oyna"da reddediyordu.
-- Buradaki değerler seed_dictionary.sql'deki ile birebir aynı.
insert into public.words (word, len, points, pos, meanings) values
  ('id', char_length('id'), public.harfik_points('id'), 'a.', '["Kişiliğin bilinç dışında bulunan, doğuştan gelen içgüdüsel dürtülerin kaynağı olduğu kabul edilen ilkel bölümü"]'::jsonb),
  ('pi', char_length('pi'), public.harfik_points('pi'), 'a.', '["Bir çemberin çevresinin çapına oranını gösteren, yaklaşık değeri 3,14159 olan sayı"]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
