-- Kelimeki — Büyüme > Oyun: İstanbul saat dilimine göre kova + teslim (surrender) ayrımı
--
-- 1) Bucket hesaplaması artık İstanbul yerel gününe göre yapılıyor. Önceki
--    haliyle now()/created_at veritabanının (UTC) saat dilimine göre
--    kesiliyordu — "bugün" kovası aslında UTC 00:00-23:59'du, yani İstanbul
--    saatiyle 03:00-03:00 arasıydı. admin_user_activity_series de aynı
--    hataya sahipti, o da düzeltiliyor.
-- 2) game_finishes.ended_by_surrender: bir oyunun completed=true olarak
--    bitmesinin iki farklı yolu vardı ama ayrımı yoktu — bag+raf boşalarak/
--    pas turuyla GERÇEKTEN sonuna kadar oynanan bir oyun ile, birinin
--    teslim olmasıyla (mesela logodaki "Çık" akışı) aktif oyuncu sayısının
--    1'e düşüp aniden bitmesi aynı "Bitirilen" sayacına ve ortalama süreye
--    karışıyordu. İkincisi gerçek bir oyun süresini yansıtmaz (genelde
--    saniyeler içinde biter) ve "normal oyun kaç dakika sürüyor" sorusunu
--    çarpıtıyordu. Artık endGame()'in hangi yoldan çağrıldığı
--    (src/game/gameReducer.ts) istemci tarafında GameState.endReason'a
--    yazılıp logGameFinish'e iletiliyor; admin_game_activity_series
--    "Bitirilen" (ve ortalama süre) sayaçlarını yalnızca
--    ended_by_surrender=false satırlardan hesaplıyor, teslimle bitenler
--    ayrı bir games_surrendered serisinde. Var olan satırlar (bu
--    migration'dan önce kaydedilenler) geriye dönük olarak ayrıştırılamıyor
--    — hepsi ended_by_surrender=false varsayılanıyla "Bitirilen"e dahil
--    kalıyor.
--
-- ÖNEMLİ: dönüş tipi değiştiği için CREATE OR REPLACE FUNCTION yetmiyor —
-- fonksiyonlar önce düşürülüyor.

alter table public.game_finishes add column if not exists ended_by_surrender boolean not null default false;

comment on column public.game_finishes.ended_by_surrender is 'true: oyun bag+raf boşalarak/pas turuyla değil, aktif oyuncu sayısının teslim(ler) yüzünden 1''e düşmesiyle bitti (bkz. SURRENDER, src/game/gameReducer.ts endGame çağrısı). completed=true olsa da bu satırlar admin panelinde "Bitirilen" değil ayrı bir "Teslim" serisinde sayılır ve ortalama süreye dahil edilmez — teslim genelde saniyeler içinde geldiğinden gerçek oyun süresini yansıtmaz. Bu sütun eklenmeden önceki kayıtlarda varsayılan false''tur (geriye dönük ayrıştırılamaz).';

drop function if exists public.admin_user_activity_series (integer, text);

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
  v_end timestamp := date_trunc(v_unit, now() at time zone 'Europe/Istanbul');
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
    select date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket, count(*) as cnt
    from auth.users
    group by 1
  ) u on u.bucket = d.bucket
  order by d.bucket;
end;
$$;

revoke all on function public.admin_user_activity_series (integer, text) from public, anon;
grant execute on function public.admin_user_activity_series (integer, text) to authenticated;

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
    games_surrendered                   bigint,
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
  v_end timestamp := date_trunc(v_unit, now() at time zone 'Europe/Istanbul');
  v_start timestamp := v_end - (greatest(p_periods, 1) - 1) * v_step;
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    d.bucket::date                  as bucket,
    coalesce(gf.cnt_done, 0)        as games_finished,
    coalesce(gf.cnt_done_same, 0)   as games_finished_same_session,
    coalesce(gf.cnt_done_multi, 0)  as games_finished_multi_session,
    coalesce(gf.cnt_surrendered, 0) as games_surrendered,
    coalesce(gf.cnt_abandoned, 0)   as games_abandoned,
    gf.avg_duration                 as avg_duration_seconds,
    gf.avg_duration_same            as avg_duration_same_session_seconds,
    gf.avg_duration_multi           as avg_duration_multi_session_seconds
  from generate_series(v_start, v_end, v_step) as d (bucket)
  left join (
    select
      date_trunc(v_unit, created_at at time zone 'Europe/Istanbul') as bucket,
      count(*) filter (where completed and not ended_by_surrender) as cnt_done,
      count(*) filter (where completed and not ended_by_surrender and not multi_session) as cnt_done_same,
      count(*) filter (where completed and not ended_by_surrender and multi_session) as cnt_done_multi,
      count(*) filter (where completed and ended_by_surrender) as cnt_surrendered,
      count(*) filter (where not completed) as cnt_abandoned,
      avg(duration_seconds) filter (where completed and not ended_by_surrender) as avg_duration,
      avg(duration_seconds) filter (where completed and not ended_by_surrender and not multi_session) as avg_duration_same,
      avg(duration_seconds) filter (where completed and not ended_by_surrender and multi_session) as avg_duration_multi
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
