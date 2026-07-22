-- Kelimeki — geri bildirimin hangi formdan geldiğini ayırt eden `source` sütunu.
--
-- Şimdiye kadar tek bir "Görüş Bildir" formu vardı (oyun sonu + Kullanım
-- Şartları/Gizlilik sayfalarındaki genel link), ikisi de aynı `feedback`
-- tablosuna düşüyordu. Admin panelinde artık ikisi ayrı sekmelerde
-- yönetilecek, bu yüzden hangi formdan geldiğini kaydetmek gerekiyor.
-- Var olan satırlar (hepsi oyun sonu formundan geldi) 'game_end' olarak
-- işaretlenir; sütun sonradan not null yapılır.

alter table public.feedback
  add column if not exists source text;

update public.feedback set source = 'game_end' where source is null;

alter table public.feedback
  alter column source set default 'game_end',
  alter column source set not null;

alter table public.feedback
  drop constraint if exists feedback_source_check;
alter table public.feedback
  add constraint feedback_source_check check (source in ('game_end', 'general'));

create index if not exists feedback_source_idx on public.feedback (source);
