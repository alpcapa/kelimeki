-- Kelimeki — `source` sütununu tekrar ekle (bkz. feedback_drop_source).
--
-- Ayrı admin sekmeleri gereksizdi ama hangi kanaldan geldiğini (oyun sonu /
-- genel) admin listesinde bir etiket olarak göstermek faydalı bulundu.

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
