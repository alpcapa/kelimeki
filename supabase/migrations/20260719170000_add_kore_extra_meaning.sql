-- Harfik — "kore" kelimesine ülke/bölge anlamı ekle
-- TDK'de "kore" yalnızca "kore hastalığı" (bir sinir hastalığı) anlamıyla
-- geçiyor; Kore Yarımadası'nın ve Kuzey/Güney Kore'nin ortak adı olarak da
-- yaygın kullanıldığından bu anlam meanings dizisine eklenir (bkz.
-- scripts/extra-meanings.mjs). Kelime zaten var olduğundan yeni bir satır
-- eklenmiyor, mevcut satırın meanings alanı güncelleniyor.
update public.words
set meanings = meanings || '["Asya''da tarihî bir bölge ve yarımada; Kuzey Kore ile Güney Kore''nin ortak adı."]'::jsonb
where word = 'kore'
  and not meanings @> '["Asya''da tarihî bir bölge ve yarımada; Kuzey Kore ile Güney Kore''nin ortak adı."]'::jsonb;
