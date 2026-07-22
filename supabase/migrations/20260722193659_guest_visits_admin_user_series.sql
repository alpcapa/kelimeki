-- Kelimeki — Büyüme > Kullanıcı: misafir (girişsiz) ziyaretçi sayımı
--
-- Kayıt olmadan gelip oynayan (ya da bakıp giden) benzersiz ziyaretçileri
-- görebilmek için — daha önce bu, hiç ölçülmüyordu (game_finishes yalnızca
-- BİTEN oyunları sayar, hiç oynamadan bakıp gidenler ya da kaç farklı
-- kişinin geldiği hiçbir yerde tutulmuyordu). guest_visits, istemci
-- tarafında localStorage'da üretilen rastgele bir anon_id (bkz.
-- src/utils/visitTracking.ts) ile günde bir kez "bugün buradaydım" pingi
-- atar — hiçbir kişisel veri taşımaz. Yalnızca oturum açık DEĞİLKEN
-- gönderilir (App.tsx); sunucu tarafında da yalnızca anon rolünden
-- insert'e izin verilerek bu zorlanır.
--
-- admin_user_activity_series artık bucket başına DISTINCT anon_id sayısını
-- "guest_visits" olarak da döndürüyor — dönüş tipi değiştiği için CREATE OR
-- REPLACE FUNCTION yetmiyor, fonksiyon önce düşürülüyor.

create table if not exists public.guest_visits (
  id          uuid primary key default gen_random_uuid (),
  anon_id     uuid not null,
  created_at  timestamptz not null default now()
);

comment on table public.guest_visits is 'Misafir (girişsiz) tarayıcıların günde bir kez attığı anonim "buradaydım" pingi — hiçbir kişisel veri içermez, yalnızca admin panelindeki Büyüme > Kullanıcı grafiğinde benzersiz ziyaretçi sayımı için. anon_id istemci tarafında localStorage''da üretilen rastgele bir uuid''dir, hesapla ilişkilendirilmez.';
create index if not exists guest_visits_created_at_idx on public.guest_visits (created_at desc);
create index if not exists guest_visits_anon_id_idx on public.guest_visits (anon_id);

alter table public.guest_visits enable row level security;

drop policy if exists guest_visits_insert_anon on public.guest_visits;
create policy guest_visits_insert_anon on public.guest_visits
  for insert
  to anon
  with check (true);

drop function if exists public.admin_user_activity_series (integer, text);

create or replace function public.admin_user_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day'
)
  returns table (
    bucket        date,
    signups       bigint,
    guest_visits  bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
declare
  v_unit text := case
    when p_granularity = 'year' then 'year'
    when p_granularity = 'month' then 'month'
    when p_granularity = 'week' then 'week'
    else 'day'
  end;
  v_step interval := case
    when v_unit = 'year' then interval '1 year'
    when v_unit = 'month' then interval '1 month'
    when v_unit = 'week' then interval '1 week'
    else interval '1 day'
  end;
  v_end timestamp := date_trunc(v_unit, now() at time zone 'Europe/Istanbul');
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date     as bucket,
    coalesce(u.cnt, 0) as signups,
    coalesce(gv.cnt, 0) as guest_visits
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.bucket = d.bucket
  left join (
    select
      date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket,
      count(distinct anon_id) as cnt
    from public.guest_visits
    group by 1
  ) gv on gv.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_user_activity_series (integer, text) from public, anon;
grant execute on function public.admin_user_activity_series (integer, text) to authenticated;
