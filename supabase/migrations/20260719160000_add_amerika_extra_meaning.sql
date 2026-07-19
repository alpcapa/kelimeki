-- Harfik — "amerika" kelimesine günlük dilde kullanılan ek anlam ekle
-- TDK'de "amerika" yalnızca kıta anlamıyla geçiyor; günlük dilde Amerika
-- Birleşik Devletleri için de kullanıldığından bu anlam meanings dizisine
-- eklenir (bkz. scripts/extra-meanings.mjs). Kelime zaten var olduğundan
-- yeni bir satır eklenmiyor, mevcut satırın meanings alanı güncelleniyor.
update public.words
set meanings = meanings || '["Amerika Birleşik Devletleri''nin günlük dilde kullanılan adı."]'::jsonb
where word = 'amerika'
  and not meanings @> '["Amerika Birleşik Devletleri''nin günlük dilde kullanılan adı."]'::jsonb;
