-- Kelimeki — admin panelinde geri bildirim mesajlarını silebilme.
--
-- feedback tablosunda şimdiye kadar insert/select/update politikaları vardı,
-- delete yoktu (RLS'de politika olmayan işlem varsayılan olarak reddedilir).
drop policy if exists feedback_delete_admin on public.feedback;
create policy feedback_delete_admin on public.feedback
  for delete using (public.is_admin ());
