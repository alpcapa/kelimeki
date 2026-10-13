-- visibility_probe: `greatest(null, 0)` Postgres'te 0 döner (greatest/least
-- NULL'ları yok sayar) → "girdi hiç olmadı" (NULL) ile "girdi 0. ms'de oldu"
-- ayırt edilemiyordu; ölçümün asıl sinyali tam da bu. İlk sürümle canlıda
-- doğrulamada yakalandı (first_input_ms 900 yerine 0). NULL korunur.

create or replace function public.record_visibility_probe (
  p_id uuid,
  p_device_type text,
  p_utm_source text,
  p_vis_state text,
  p_has_focus boolean,
  p_load_ms integer,
  p_in_app text,
  p_became_visible_ms integer,
  p_first_input_ms integer,
  p_input_count integer,
  p_alive_ms integer
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_id is null then
    return;
  end if;
  insert into public.visibility_probe as v (
    id, device_type, utm_source, vis_state, has_focus, load_ms, in_app,
    became_visible_ms, first_input_ms, input_count, alive_ms
  ) values (
    p_id,
    left(p_device_type, 16),
    left(p_utm_source, 64),
    left(p_vis_state, 16),
    p_has_focus,
    case when p_load_ms is null then null else least(greatest(p_load_ms, 0), 3600000) end,
    case when p_in_app in ('instagram', 'facebook', 'other-wv', 'none') then p_in_app else null end,
    case when p_became_visible_ms is null then null else least(greatest(p_became_visible_ms, 0), 3600000) end,
    case when p_first_input_ms is null then null else least(greatest(p_first_input_ms, 0), 3600000) end,
    least(greatest(coalesce(p_input_count, 0), 0), 10000),
    case when p_alive_ms is null then null else least(greatest(p_alive_ms, 0), 3600000) end
  )
  on conflict (id) do update set
    updated_at        = now(),
    became_visible_ms = coalesce(v.became_visible_ms, excluded.became_visible_ms),
    first_input_ms    = coalesce(v.first_input_ms, excluded.first_input_ms),
    input_count       = greatest(v.input_count, excluded.input_count),
    alive_ms          = greatest(coalesce(v.alive_ms, 0), coalesce(excluded.alive_ms, 0));
end;
$$;
