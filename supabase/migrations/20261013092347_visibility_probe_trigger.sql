-- GEÇİCİ TEŞHİS, ikinci adım (13 Ekim 2026): 31-33. sn'de sayfayı KİMİN/NEYİN
-- kapattığı. Bkz. docs/decisions/admin-panel.md → "Yığılmanın kaynağını bulma".
--
-- İlk gün verisi (217 satır): Android + Meta girdisiz sayfaların yarısından
-- fazlası 31,4–34,0 sn'de bitiyor; `vis_state`/`has_focus` ayırt etmiyor.
-- Eksik olan: son ping'i hangi olay attı, sayfa hiç gizlendi mi (ne zaman,
-- kaç kez), `pagehide` bfcache'e mi gitti (`persisted`).
--
-- ⚠ Eski 11 argümanlı `record_visibility_probe` BİLEREK silinmiyor: canlıdaki
-- istemci hâlâ onu çağırıyor; yeni istemci merge edilene kadar veri akmaya
-- devam etsin. İki imza adlandırılmış argüman kümeleriyle ayrışır (PostgREST
-- belirsizliği yok). Ölçüm bitince ikisi birlikte silinir.
--
-- Yeni kolonlar yalnızca türetilmiş bayraklar — kişisel veri YOK.

alter table public.visibility_probe
  add column if not exists end_event      text,     -- son ping'i atan olay: 'load' | 'timer' | 'hidden' | 'pagehide'
  add column if not exists first_hidden_ms integer, -- sayfa ilk kez 'hidden' olduğunda (yüklemeden itibaren; yoksa null)
  add column if not exists hidden_count   integer not null default 0,
  add column if not exists persisted      boolean;  -- pagehide.persisted (bfcache); pagehide gelmediyse null

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
  p_alive_ms integer,
  p_end_event text,
  p_first_hidden_ms integer,
  p_hidden_count integer,
  p_persisted boolean
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_end text := case when p_end_event in ('load', 'timer', 'hidden', 'pagehide') then p_end_event else null end;
begin
  if p_id is null then
    return;
  end if;
  insert into public.visibility_probe as v (
    id, device_type, utm_source, vis_state, has_focus, load_ms, in_app,
    became_visible_ms, first_input_ms, input_count, alive_ms,
    end_event, first_hidden_ms, hidden_count, persisted
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
    case when p_alive_ms is null then null else least(greatest(p_alive_ms, 0), 3600000) end,
    v_end,
    case when p_first_hidden_ms is null then null else least(greatest(p_first_hidden_ms, 0), 3600000) end,
    least(greatest(coalesce(p_hidden_count, 0), 0), 1000),
    p_persisted
  )
  on conflict (id) do update set
    updated_at        = now(),
    became_visible_ms = coalesce(v.became_visible_ms, excluded.became_visible_ms),
    first_input_ms    = coalesce(v.first_input_ms, excluded.first_input_ms),
    input_count       = greatest(v.input_count, excluded.input_count),
    -- Son ping'in olayı yalnızca ömür ilerlediyse kazanır (sıra dışı varışa karşı).
    end_event         = case when coalesce(excluded.alive_ms, 0) >= coalesce(v.alive_ms, 0)
                             then coalesce(excluded.end_event, v.end_event)
                             else v.end_event end,
    alive_ms          = greatest(coalesce(v.alive_ms, 0), coalesce(excluded.alive_ms, 0)),
    first_hidden_ms   = coalesce(v.first_hidden_ms, excluded.first_hidden_ms),
    hidden_count      = greatest(v.hidden_count, excluded.hidden_count),
    persisted         = coalesce(excluded.persisted, v.persisted);
end;
$$;

revoke all on function public.record_visibility_probe (uuid, text, text, text, boolean, integer, text, integer, integer, integer, integer, text, integer, integer, boolean) from public;
grant execute on function public.record_visibility_probe (uuid, text, text, text, boolean, integer, text, integer, integer, integer, integer, text, integer, integer, boolean) to anon, authenticated, service_role;
