-- Harfik — kullanıcı geri bildirimi (oyun bitiminde "Görüş Bildir" formu)
--
-- destek@harfik.com için henüz gerçek bir e-posta gönderim/alım altyapısı
-- (Resend + doğrulanmış domain) kurulu değil. Bu yüzden mesajlar doğrudan
-- bu tabloya yazılır ve admin panelinden okunur — e-posta altyapısı
-- kurulduğunda buraya bir bildirim e-postası da eklenebilir, ama tablo
-- kaynak olarak kalmaya devam eder.

create table if not exists public.feedback (
  id         uuid primary key default gen_random_uuid (),
  user_id    uuid references auth.users (id) on delete set null,
  email      text,
  message    text not null check (char_length(message) between 1 and 2000),
  handled    boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table public.feedback is 'Kullanıcıların oyun içinden gönderdiği görüş/şikayet mesajları.';
create index if not exists feedback_created_at_idx on public.feedback (created_at desc);
create index if not exists feedback_handled_idx on public.feedback (handled);

alter table public.feedback enable row level security;

-- Girişli kullanıcı yalnızca kendi adına, anonim kullanıcı user_id boş
-- bırakarak gönderebilir.
drop policy if exists feedback_insert_any on public.feedback;
create policy feedback_insert_any on public.feedback
  for insert
  with check (user_id is null or auth.uid () = user_id);

-- Yalnızca adminler okuyabilir/işaretleyebilir (is_admin(), 20260717162342'de tanımlı).
drop policy if exists feedback_select_admin on public.feedback;
create policy feedback_select_admin on public.feedback
  for select using (public.is_admin ());

drop policy if exists feedback_update_admin on public.feedback;
create policy feedback_update_admin on public.feedback
  for update using (public.is_admin ()) with check (public.is_admin ());
