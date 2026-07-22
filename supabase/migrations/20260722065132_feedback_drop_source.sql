-- Kelimeki — bir önceki migration'da eklenen `source` sütununu geri al.
--
-- Oyun sonu ve genel "Görüş Bildir" linkinin aslında aynı form olduğu, ayrı
-- admin sekmeleri gerektirmediği anlaşıldı — bu yüzden kaynak ayrımı iptal
-- edildi, kod tarafı da (feedback_add_source migration'ıyla eklenen)
-- eski haline döndürüldü.

alter table public.feedback
  drop constraint if exists feedback_source_check;

drop index if exists public.feedback_source_idx;

alter table public.feedback
  drop column if exists source;
