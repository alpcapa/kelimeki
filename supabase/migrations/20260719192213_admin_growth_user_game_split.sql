-- Harfik — büyüme grafiğini kullanıcı büyümesi / oyun büyümesi olarak ikiye böl
--
-- admin_activity_series tek bir RPC'de kayıt + oyun başlatma + oyun bitirme
-- sayılarını birlikte dönüyordu. Bundan böyle iki ayrı RPC var:
--   - admin_user_activity_series: yalnızca yeni kayıt (signup) sayısı.
--   - admin_game_activity_series: oyun başlatma/bitirme sayısı.
-- Oyun bitirme sayısı artık `games` (yalnızca giriş yapmış kullanıcıların
-- skor kaydı) yerine yeni `game_finishes` tablosundan okunuyor — böylece
-- misafir (girişsiz) oynanan oyunlar da büyüme grafiğine dahil olabiliyor.
-- Bu simetriyi kurmak için game_starts'a da misafir insert izni eklendi.

-- ── GAME_STARTS: misafir (anon) kayıt izni ─────────────────────────────────
drop policy if exists game_starts_insert_anon on public.game_starts;
create policy game_starts_insert_anon on public.game_starts
  for insert to anon with check (user_id is null);

-- ── GAME_FINISHES ───────────────────────────────────────────────────────────
create table if not exists public.game_finishes (
  id           uuid primary key default gen_random_uuid (),
  user_id      uuid references auth.users (id) on delete set null,
  player_count integer not null,
  created_at   timestamptz not null default now()
);

comment on table public.game_finishes is 'Biten her oyun için bir satır (misafir dahil) — büyüme grafiğindeki "bitirilen oyun" sayısı için. games tablosundan farklı olarak yalnızca girişli kullanıcıların skor kaydını değil, tüm bitişleri tutar.';
create index if not exists game_finishes_created_at_idx on public.game_finishes (created_at desc);
create index if not exists game_finishes_player_count_idx on public.game_finishes (player_count);

alter table public.game_finishes enable row level security;

drop policy if exists game_finishes_insert_self on public.game_finishes;
create policy game_finishes_insert_self on public.game_finishes
  for insert to authenticated with check (auth.uid () = user_id);

drop policy if exists game_finishes_insert_anon on public.game_finishes;
create policy game_finishes_insert_anon on public.game_finishes
  for insert to anon with check (user_id is null);

-- ── RPC'ler ──────────────────────────────────────────────────────────────
drop function if exists public.admin_activity_series (integer, text);

create or replace function public.admin_user_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day'
)
  returns table (
    bucket   date,
    signups  bigint
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
  v_end timestamp := date_trunc(v_unit, now());
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date     as bucket,
    coalesce(u.cnt, 0) as signups
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_user_activity_series (integer, text) from public, anon;
grant execute on function public.admin_user_activity_series (integer, text) to authenticated;

create or replace function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day'
)
  returns table (
    bucket          date,
    game_starts     bigint,
    games_finished  bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
declare
  v_unit text := case
    when p_granularity = 'month' then 'month'
    when p_granularity = 'week' then 'week'
    else 'day'
  end;
  v_step interval := case
    when v_unit = 'month' then interval '1 month'
    when v_unit = 'week' then interval '1 week'
    else interval '1 day'
  end;
  v_end timestamp := date_trunc(v_unit, now());
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date       as bucket,
    coalesce(gs.cnt, 0)  as game_starts,
    coalesce(gf.cnt, 0)  as games_finished
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.game_starts
    group by 1
  ) gs on gs.bucket = d.bucket
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.game_finishes
    group by 1
  ) gf on gf.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_game_activity_series (integer, text) from public, anon;
grant execute on function public.admin_game_activity_series (integer, text) to authenticated;
