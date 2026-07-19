-- Harfik — Büyüme > Oyun grafiğinde tamamlanan/terk edilen oyun ayrımı
--
-- "Bitirilen" sayacı artık yalnızca gerçekten sonuna kadar oynanmış
-- (completed=true) oyunları sayıyor. Bir oyun 7 gün boyunca hiç
-- kaydedilmeden (yani hiç hamle yapılmadan) localStorage'da beklerse
-- istemci tarafında terk edilmiş sayılıp silinir (bkz. src/utils/
-- gameStorage.ts ABANDON_TIMEOUT_MS) ve completed=false olarak ayrı bir
-- game_finishes satırı düşer; bu artık admin panelinde "Terk Edilen" diye
-- ayrı bir seride gösteriliyor, "Bitirilen" sayısına karışmıyor. Ortalama
-- süre kolonları da yalnızca gerçekten tamamlanan oyunlar üzerinden
-- hesaplanıyor — terk edilen bir oyunun "süresi" gerçek bir oynama süresini
-- değil, ne kadar sonra fark edilip silindiğini yansıttığından ortalamaya
-- dahil edilmesi anlamlı değil.
--
-- ÖNEMLİ: dönüş tipi (RETURNS TABLE kolonları) değiştiği için CREATE OR
-- REPLACE FUNCTION yetmiyor — fonksiyon önce düşürülüyor.

alter table public.game_finishes add column if not exists completed boolean not null default true;

comment on column public.game_finishes.completed is 'true: oyun normal biçimde (bag+raf boşalarak ya da pas/teslimle) bitti. false: 7 gün hareketsizlik sonrası istemci tarafında terk edilmiş sayılıp silindi (bkz. src/utils/gameStorage.ts ABANDON_TIMEOUT_MS) — admin panelinde ayrı bir "Terk Edilen" serisi olarak gösterilir, "Bitirilen" sayısına ya da ortalama süreye dahil edilmez.';

drop function if exists public.admin_game_activity_series (integer, text, text, integer);

create or replace function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null
)
  returns table (
    bucket                              date,
    game_starts                         bigint,
    games_finished                      bigint,
    games_abandoned                     bigint,
    avg_duration_seconds                numeric,
    avg_duration_same_session_seconds   numeric,
    avg_duration_multi_session_seconds  numeric
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
    d.bucket::date          as bucket,
    coalesce(gs.cnt, 0)     as game_starts,
    coalesce(gf.cnt_done, 0) as games_finished,
    coalesce(gf.cnt_abandoned, 0) as games_abandoned,
    gf.avg_duration         as avg_duration_seconds,
    gf.avg_duration_same    as avg_duration_same_session_seconds,
    gf.avg_duration_multi   as avg_duration_multi_session_seconds
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select date_trunc(v_unit, created_at) as bucket, count(*) as cnt
    from public.game_starts
    where (
      p_scope = 'total'
      or (p_scope = 'registered' and user_id is not null)
      or (p_scope = 'guest' and user_id is null)
    )
    and (p_player_count is null or player_count = p_player_count)
    group by 1
  ) gs on gs.bucket = d.bucket
  left join (
    select
      date_trunc(v_unit, created_at) as bucket,
      count(*) filter (where completed) as cnt_done,
      count(*) filter (where not completed) as cnt_abandoned,
      avg(duration_seconds) filter (where completed) as avg_duration,
      avg(duration_seconds) filter (where completed and not multi_session) as avg_duration_same,
      avg(duration_seconds) filter (where completed and multi_session) as avg_duration_multi
    from public.game_finishes
    where (
      p_scope = 'total'
      or (p_scope = 'registered' and user_id is not null)
      or (p_scope = 'guest' and user_id is null)
    )
    and (p_player_count is null or player_count = p_player_count)
    group by 1
  ) gf on gf.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_game_activity_series (integer, text, text, integer) from public, anon;
grant execute on function public.admin_game_activity_series (integer, text, text, integer) to authenticated;
