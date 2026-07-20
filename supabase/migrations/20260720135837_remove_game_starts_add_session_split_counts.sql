-- "Başlatılan" (game_starts) verisine hiçbir yerde ihtiyaç kalmadı: yalnızca
-- biten oyun sayısı (toplam + aynı oturum/çok oturumlu kırılımı) ve terk
-- edilen oyun sayısı önemli. admin_game_activity_series artık game_starts'a
-- hiç bakmıyor, games_finished'ı da aynı oturum/çok oturumlu olarak ikiye
-- ayırıyor (avg_duration_* zaten bu kırılıma sahipti, şimdi sayım da var).
-- Ardından game_starts tablosu (ve buna bağlı RLS politikaları/index'ler)
-- tamamen kaldırılıyor — logGameStart çağrısı da istemci tarafında siliniyor.
--
-- Dönüş tipi değiştiği için CREATE OR REPLACE FUNCTION yetmiyor — fonksiyon
-- önce düşürülüyor.

drop function if exists public.admin_game_activity_series (integer, text, text, integer);

create or replace function public.admin_game_activity_series (
  p_periods integer default 30,
  p_granularity text default 'day',
  p_scope text default 'total',
  p_player_count integer default null
)
  returns table (
    bucket                              date,
    games_finished                      bigint,
    games_finished_same_session         bigint,
    games_finished_multi_session        bigint,
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
    d.bucket::date                 as bucket,
    coalesce(gf.cnt_done, 0)       as games_finished,
    coalesce(gf.cnt_done_same, 0)  as games_finished_same_session,
    coalesce(gf.cnt_done_multi, 0) as games_finished_multi_session,
    coalesce(gf.cnt_abandoned, 0)  as games_abandoned,
    gf.avg_duration                as avg_duration_seconds,
    gf.avg_duration_same           as avg_duration_same_session_seconds,
    gf.avg_duration_multi          as avg_duration_multi_session_seconds
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select
      date_trunc(v_unit, created_at) as bucket,
      count(*) filter (where completed) as cnt_done,
      count(*) filter (where completed and not multi_session) as cnt_done_same,
      count(*) filter (where completed and multi_session) as cnt_done_multi,
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

drop table if exists public.game_starts;
