-- Hamle Avı (ROADMAP #48): kişi başı en iyi seri (rekor) + görülen bulmaca kimlikleri.
-- Seri her girişte sıfırlanır, kalıcı olan yalnızca REKOR; "görülenler" bulmacanın
-- tekrar çıkmaması için (banka dosyası `src/data/hamleAviBank.json`, kimlik = `id`).
-- Tabloya istemci DOĞRUDAN erişmez: yalnızca iki RPC (security definer).
-- k-lig/ödül/liderlik tablosuna KARIŞMAZ.

create table if not exists public.hamle_avi_stats (
  user_id uuid primary key references auth.users(id) on delete cascade,
  best_streak integer not null default 0 check (best_streak between 0 and 5000),
  seen_ids integer[] not null default '{}',
  updated_at timestamptz not null default now()
);

alter table public.hamle_avi_stats enable row level security;
-- Politika YOK + istemciye grant YOK: erişim yalnızca RPC'lerden (RLS açık = ek güvenlik).
grant select, insert, update, delete on public.hamle_avi_stats to service_role;

-- Okuma: satır yoksa sıfır döner (satırı yaratmaz).
create or replace function public.hamle_avi_get()
returns table (best_streak integer, seen_ids integer[])
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(s.best_streak, 0), coalesce(s.seen_ids, '{}'::integer[])
  from (select 1) d
  left join public.hamle_avi_stats s on s.user_id = auth.uid()
  where auth.uid() is not null;
$$;

-- Yazma: rekor = greatest(eski, yeni); görülenler = birleşim (en çok 5000 kimlik).
-- Çevrimdışı kuyruktan tekrar/sırasız gelen çağrılar güvenli (idempotent).
create or replace function public.hamle_avi_report(p_best_streak integer, p_seen_ids integer[])
returns table (best_streak integer, seen_ids integer[])
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  uid uuid := auth.uid();
  v_best integer := greatest(0, least(coalesce(p_best_streak, 0), 5000));
  v_seen integer[] := coalesce(p_seen_ids, '{}'::integer[]);
begin
  if uid is null then
    raise exception 'Giriş gerekli' using errcode = '28000';
  end if;
  if coalesce(array_length(v_seen, 1), 0) > 5000 then
    raise exception 'Çok fazla kimlik' using errcode = 'P0001';
  end if;

  insert into public.hamle_avi_stats as s (user_id, best_streak, seen_ids)
  values (uid, v_best, (select coalesce(array_agg(distinct x order by x), '{}') from unnest(v_seen) x))
  on conflict (user_id) do update
    set best_streak = greatest(s.best_streak, excluded.best_streak),
        seen_ids = (
          select coalesce(array_agg(distinct x order by x), '{}')
          from unnest(s.seen_ids || excluded.seen_ids) x
        ),
        updated_at = now();

  return query select s.best_streak, s.seen_ids from public.hamle_avi_stats s where s.user_id = uid;
end;
$$;

revoke all on function public.hamle_avi_get() from public, anon;
revoke all on function public.hamle_avi_report(integer, integer[]) from public, anon;
grant execute on function public.hamle_avi_get() to authenticated;
grant execute on function public.hamle_avi_report(integer, integer[]) to authenticated;
