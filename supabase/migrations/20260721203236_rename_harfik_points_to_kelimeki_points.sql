-- Kelimeki — rebrand (Harfik → Kelimeki) sırasında bu fonksiyon yeniden
-- adlandırılmamış kalmıştı; scripts/build-dictionary.mjs ve
-- scripts/augment-dictionary.mjs zaten kelimeki_points üretiyordu, ama
-- production'da hâlâ harfik_points olarak duruyordu (bkz. "ra" ekleme
-- migration'ı, 20260721195627, bu yüzden geçici olarak harfik_points
-- kullanmak zorunda kaldı). Fonksiyonu olduğu gibi (gövde/izinler dahil)
-- yeniden adlandırıyoruz.
alter function public.harfik_points(text) rename to kelimeki_points;
