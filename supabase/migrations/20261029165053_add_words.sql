-- Kelimeki — elle tutulan kelime/anlam listelerinin uygulanması
-- Kaynak: scripts/{proper-nouns,extra-words,extra-meanings}.mjs
--         (scripts/augment-dictionary.mjs ile üretildi).
-- 36 yeni madde, 0 anlam güncellemesi.
-- Tekrar çalıştırmaya güvenli (ON CONFLICT DO UPDATE).

insert into public.words (word, len, points, pos, meanings) values
  ('alpler', char_length('alpler'), public.kelimeki_points('alpler'), null, '["Avrupa''da bir dağ silsilesi."]'::jsonb),
  ('aras', char_length('aras'), public.kelimeki_points('aras'), null, '["Doğu Anadolu''dan doğan ve Hazar Denizi''ne dökülen bir nehir."]'::jsonb),
  ('asur', char_length('asur'), public.kelimeki_points('asur'), null, '["Mezopotamya''da kurulmuş eski bir devlet."]'::jsonb),
  ('atlantik', char_length('atlantik'), public.kelimeki_points('atlantik'), null, '["Bir okyanus."]'::jsonb),
  ('babil', char_length('babil'), public.kelimeki_points('babil'), null, '["Mezopotamya''da kurulmuş eski bir devlet."]'::jsonb),
  ('bizans', char_length('bizans'), public.kelimeki_points('bizans'), null, '["Doğu Roma İmparatorluğu."]'::jsonb),
  ('boğaziçi', char_length('boğaziçi'), public.kelimeki_points('boğaziçi'), null, '["İstanbul Boğazı çevresi."]'::jsonb),
  ('bosna', char_length('bosna'), public.kelimeki_points('bosna'), null, '["Balkanlar''da tarihî bir bölge."]'::jsonb),
  ('çoruh', char_length('çoruh'), public.kelimeki_points('çoruh'), null, '["Türkiye''de Karadeniz''e dökülen bir nehir."]'::jsonb),
  ('erciyes', char_length('erciyes'), public.kelimeki_points('erciyes'), null, '["Kayseri''de bir dağ."]'::jsonb),
  ('fırat', char_length('fırat'), public.kelimeki_points('fırat'), null, '["Türkiye, Suriye ve Irak''tan geçen bir nehir."]'::jsonb),
  ('frig', char_length('frig'), public.kelimeki_points('frig'), null, '["Orta Anadolu''da yaşamış eski bir halk."]'::jsonb),
  ('himalaya', char_length('himalaya'), public.kelimeki_points('himalaya'), null, '["Asya''da dünyanın en yüksek dağ silsilesi."]'::jsonb),
  ('kaçkarlar', char_length('kaçkarlar'), public.kelimeki_points('kaçkarlar'), null, '["Doğu Karadeniz''de bir dağ silsilesi."]'::jsonb),
  ('kafkaslar', char_length('kafkaslar'), public.kelimeki_points('kafkaslar'), null, '["Karadeniz ile Hazar Denizi arasında uzanan dağ silsilesi."]'::jsonb),
  ('kapadokya', char_length('kapadokya'), public.kelimeki_points('kapadokya'), null, '["Orta Anadolu''da tarihî bir bölge."]'::jsonb),
  ('karaibler', char_length('karaibler'), public.kelimeki_points('karaibler'), null, '["Orta Amerika ile Güney Amerika arasındaki deniz ve adalar."]'::jsonb),
  ('kartaca', char_length('kartaca'), public.kelimeki_points('kartaca'), null, '["Kuzey Afrika''da kurulmuş eski bir devlet."]'::jsonb),
  ('kızıldeniz', char_length('kızıldeniz'), public.kelimeki_points('kızıldeniz'), null, '["Afrika ile Arabistan arasında bir deniz."]'::jsonb),
  ('lidya', char_length('lidya'), public.kelimeki_points('lidya'), null, '["Batı Anadolu''da kurulmuş eski bir devlet."]'::jsonb),
  ('missisipi', char_length('missisipi'), public.kelimeki_points('missisipi'), null, '["ABD''de bir nehir."]'::jsonb),
  ('ortadoğu', char_length('ortadoğu'), public.kelimeki_points('ortadoğu'), null, '["Asya''nın güneybatısı ile Mısır''ı kapsayan bölge."]'::jsonb),
  ('ölüdeniz', char_length('ölüdeniz'), public.kelimeki_points('ölüdeniz'), null, '["Muğla''da bir koy."]'::jsonb),
  ('pasifik', char_length('pasifik'), public.kelimeki_points('pasifik'), null, '["Bir okyanus."]'::jsonb),
  ('patagonya', char_length('patagonya'), public.kelimeki_points('patagonya'), null, '["Güney Amerika''nın güney ucundaki bölge."]'::jsonb),
  ('pireneler', char_length('pireneler'), public.kelimeki_points('pireneler'), null, '["Fransa ile İspanya arasında bir dağ silsilesi."]'::jsonb),
  ('süphan', char_length('süphan'), public.kelimeki_points('süphan'), null, '["Van Gölü kıyısında bir dağ."]'::jsonb),
  ('trakya', char_length('trakya'), public.kelimeki_points('trakya'), null, '["Türkiye''nin Avrupa''daki bölümü."]'::jsonb),
  ('tuna', char_length('tuna'), public.kelimeki_points('tuna'), null, '["Avrupa''da Karadeniz''e dökülen büyük bir nehir."]'::jsonb),
  ('uludağ', char_length('uludağ'), public.kelimeki_points('uludağ'), null, '["Bursa''da bir dağ."]'::jsonb),
  ('urallar', char_length('urallar'), public.kelimeki_points('urallar'), null, '["Rusya''da Avrupa ile Asya''yı ayıran dağ silsilesi."]'::jsonb),
  ('urartu', char_length('urartu'), public.kelimeki_points('urartu'), null, '["Doğu Anadolu''da kurulmuş eski bir devlet."]'::jsonb),
  ('uzakdoğu', char_length('uzakdoğu'), public.kelimeki_points('uzakdoğu'), null, '["Asya''nın doğusundaki ülkeleri kapsayan bölge."]'::jsonb),
  ('volga', char_length('volga'), public.kelimeki_points('volga'), null, '["Rusya''da Hazar Denizi''ne dökülen bir nehir."]'::jsonb),
  ('yakındoğu', char_length('yakındoğu'), public.kelimeki_points('yakındoğu'), null, '["Akdeniz''in doğusundaki ülkeleri kapsayan bölge."]'::jsonb),
  ('yeşilırmak', char_length('yeşilırmak'), public.kelimeki_points('yeşilırmak'), null, '["Karadeniz''e dökülen bir nehir."]'::jsonb)
on conflict (word) do update set len = excluded.len, points = excluded.points, pos = excluded.pos, meanings = excluded.meanings;
