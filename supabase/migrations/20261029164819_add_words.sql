-- Kelimeki — elle tutulan kelime/anlam listelerinin uygulanması
-- Kaynak: scripts/{proper-nouns,extra-words,extra-meanings}.mjs
--         (scripts/augment-dictionary.mjs ile üretildi).
-- 22 yeni madde, 0 anlam güncellemesi.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('arabistan', char_length('arabistan'), public.kelimeki_points('arabistan'), null, '["Asya''nın güneybatısında büyük bir yarımada."]'::jsonb),
  ('borneo', char_length('borneo'), public.kelimeki_points('borneo'), null, '["Güneydoğu Asya''da büyük bir ada."]'::jsonb),
  ('britanya', char_length('britanya'), public.kelimeki_points('britanya'), null, '["Avrupa''nın kuzeybatısında bir ada."]'::jsonb),
  ('çeçenistan', char_length('çeçenistan'), public.kelimeki_points('çeçenistan'), null, '["Kafkasya''da Rusya''ya bağlı bir cumhuriyet."]'::jsonb),
  ('çekoslovakya', char_length('çekoslovakya'), public.kelimeki_points('çekoslovakya'), null, '["Orta Avrupa''da, 1993''e kadar var olmuş eski bir devlet."]'::jsonb),
  ('dağıstan', char_length('dağıstan'), public.kelimeki_points('dağıstan'), null, '["Kafkasya''da Rusya''ya bağlı bir cumhuriyet."]'::jsonb),
  ('gazze', char_length('gazze'), public.kelimeki_points('gazze'), null, '["Filistin''de Akdeniz kıyısında bir şehir."]'::jsonb),
  ('iskoçya', char_length('iskoçya'), public.kelimeki_points('iskoçya'), null, '["Büyük Britanya''nın kuzeyinde bir ülke."]'::jsonb),
  ('kafkasya', char_length('kafkasya'), public.kelimeki_points('kafkasya'), null, '["Karadeniz ile Hazar Denizi arasında yer alan dağlık bölge."]'::jsonb),
  ('kaliforniya', char_length('kaliforniya'), public.kelimeki_points('kaliforniya'), null, '["ABD''de bir eyalet."]'::jsonb),
  ('katalonya', char_length('katalonya'), public.kelimeki_points('katalonya'), null, '["İspanya''nın kuzeydoğusunda özerk bir bölge."]'::jsonb),
  ('mezopotamya', char_length('mezopotamya'), public.kelimeki_points('mezopotamya'), null, '["Dicle ile Fırat nehirleri arasında kalan tarihî bölge."]'::jsonb),
  ('okyanusya', char_length('okyanusya'), public.kelimeki_points('okyanusya'), null, '["Pasifik Okyanusu''ndaki adaları ve Avustralya''yı kapsayan kıta."]'::jsonb),
  ('rumeli', char_length('rumeli'), public.kelimeki_points('rumeli'), null, '["Osmanlı Devleti''nin Avrupa''daki toprakları."]'::jsonb),
  ('sibirya', char_length('sibirya'), public.kelimeki_points('sibirya'), null, '["Asya''nın kuzeyinde, Rusya''ya ait geniş bir bölge."]'::jsonb),
  ('sumatra', char_length('sumatra'), public.kelimeki_points('sumatra'), null, '["Endonezya''da bir ada."]'::jsonb),
  ('tataristan', char_length('tataristan'), public.kelimeki_points('tataristan'), null, '["Rusya''ya bağlı bir cumhuriyet."]'::jsonb),
  ('tibet', char_length('tibet'), public.kelimeki_points('tibet'), null, '["Orta Asya''da yüksek bir bölge."]'::jsonb),
  ('trablusgarp', char_length('trablusgarp'), public.kelimeki_points('trablusgarp'), null, '["Libya''nın batısındaki tarihî bölge."]'::jsonb),
  ('transilvanya', char_length('transilvanya'), public.kelimeki_points('transilvanya'), null, '["Romanya''da tarihî bir bölge."]'::jsonb),
  ('türkistan', char_length('türkistan'), public.kelimeki_points('türkistan'), null, '["Orta Asya''da Türklerin yaşadığı tarihî bölge."]'::jsonb),
  ('yugoslavya', char_length('yugoslavya'), public.kelimeki_points('yugoslavya'), null, '["Balkanlar''da, 1992''ye kadar var olmuş eski bir devlet."]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
