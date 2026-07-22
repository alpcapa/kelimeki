-- feedback_insert_any herkese (anon dahil) açık ve şimdiye kadar hiçbir
-- hız sınırı yoktu. Mesaj uzunluğuna makul bir üst sınır ekliyoruz (mevcut
-- veri en fazla 29 karakter, sınır çok daha geniş tutuldu) ve kimlik
-- başına (giriş yapmışsa user_id, değilse Supabase gateway'in ilettiği
-- x-forwarded-for) 10 dakikada en fazla 5 gönderiye izin veren bir trigger
-- ekliyoruz. Tam bir WAF/IP-rate-limit değil (x-forwarded-for başlığı bu
-- projede iletilmiyorsa anonim istekler için sınırlama pasif kalır, hata
-- vermez) ama en azından basit flood/script saldırılarını caydırır.

alter table public.feedback
  add constraint feedback_message_length check (char_length(message) between 1 and 5000);

create table public.feedback_rate_limit (
  identity text primary key,
  window_start timestamptz not null default now(),
  count integer not null default 1
);

alter table public.feedback_rate_limit enable row level security;
revoke all on public.feedback_rate_limit from anon, authenticated;

create or replace function public.feedback_rate_limit_check()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_identity text;
  v_limit constant integer := 5;
  v_window constant interval := interval '10 minutes';
  v_count integer;
begin
  v_identity := coalesce(
    new.user_id::text,
    nullif(split_part(current_setting('request.headers', true)::json ->> 'x-forwarded-for', ',', 1), '')
  );

  if v_identity is null then
    return new;
  end if;

  insert into public.feedback_rate_limit as frl (identity, window_start, count)
  values (v_identity, now(), 1)
  on conflict (identity) do update
    set window_start = case when now() - frl.window_start > v_window then now() else frl.window_start end,
        count = case when now() - frl.window_start > v_window then 1 else frl.count + 1 end
  returning frl.count into v_count;

  if v_count > v_limit then
    raise exception 'Çok fazla geri bildirim gönderdiniz, lütfen birkaç dakika sonra tekrar deneyin.';
  end if;

  return new;
end;
$$;

create trigger feedback_rate_limit_trigger
before insert on public.feedback
for each row execute function public.feedback_rate_limit_check();
