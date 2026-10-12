-- GEÇİCİ TEŞHİS (12 Ekim 2026): 31-33. saniye yığılmasının kaynağı.
-- Bkz. docs/decisions/admin-panel.md → "Yığılmanın kaynağını bulma".
--
-- #787 (`pageVisible.ts`) yığılmayı gidermedi: Android + Meta oturumlarının
-- ~%50'si hâlâ tam 31-33 sn'de "ayrılıyor". Hangi tarayıcı sinyalinin
-- (visibilityState, hasFocus, gerçek dokunuş) hayalet ile gerçek ziyareti
-- ayırdığını CANLIDAN görmek için sayfa başına BİR satır. Sayfa kimliği
-- (`p_id`) istemcide üretilir; aynı sayfanın ikinci ping'i satırı günceller.
--
-- ⚠ GEÇİCİ: ölçüm bitince (~1 hafta, birkaç yüz Android+Meta satırı) tablo,
-- fonksiyon ve istemci kodu (`utils/visibilityProbe.ts`) SİLİNİR. Kalıcı
-- bir telemetri DEĞİL; ham user-agent ve kişisel veri SAKLANMAZ — yalnızca
-- türetilmiş bayraklar.
--
-- Okuma yalnızca service_role / postgres (MCP) — istemciler okuyamaz.

create table if not exists public.visibility_probe (
  id            uuid primary key,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  device_type   text,
  utm_source    text,
  -- Sayfa YÜKLENDİĞİ ANDAKİ sinyaller (ilk ping):
  vis_state     text,      -- document.visibilityState
  has_focus     boolean,   -- document.hasFocus()
  load_ms       integer,   -- performance.now() — yüklemeden bu ana
  in_app        text,      -- 'instagram' | 'facebook' | 'other-wv' | 'none'
  -- Sayfanın ÖMRÜ boyunca (güncellenir):
  became_visible_ms integer,  -- 'visible' olduğu ilk an (yüklemeden itibaren)
  first_input_ms    integer,  -- ilk gerçek dokunma/tık/kaydırma/tuş (yoksa null)
  input_count       integer not null default 0,
  alive_ms          integer   -- son ping'deki sayfa ömrü
);

alter table public.visibility_probe enable row level security;
revoke all on table public.visibility_probe from anon, authenticated;
grant select, insert, update, delete on public.visibility_probe to service_role;

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
  -- Değerleri sınırla: bu uç herkese açık (anon), şişirilemesin.
  insert into public.visibility_probe as v (
    id, device_type, utm_source, vis_state, has_focus, load_ms, in_app,
    became_visible_ms, first_input_ms, input_count, alive_ms
  ) values (
    p_id,
    left(p_device_type, 16),
    left(p_utm_source, 64),
    left(p_vis_state, 16),
    p_has_focus,
    least(greatest(p_load_ms, 0), 3600000),
    case when p_in_app in ('instagram', 'facebook', 'other-wv', 'none') then p_in_app else null end,
    least(greatest(p_became_visible_ms, 0), 3600000),
    least(greatest(p_first_input_ms, 0), 3600000),
    least(greatest(coalesce(p_input_count, 0), 0), 10000),
    least(greatest(p_alive_ms, 0), 3600000)
  )
  on conflict (id) do update set
    updated_at        = now(),
    became_visible_ms = coalesce(v.became_visible_ms, excluded.became_visible_ms),
    first_input_ms    = coalesce(v.first_input_ms, excluded.first_input_ms),
    input_count       = greatest(v.input_count, excluded.input_count),
    alive_ms          = greatest(coalesce(v.alive_ms, 0), coalesce(excluded.alive_ms, 0));
end;
$$;

revoke all on function public.record_visibility_probe (uuid, text, text, text, boolean, integer, text, integer, integer, integer, integer) from public;
grant execute on function public.record_visibility_probe (uuid, text, text, text, boolean, integer, text, integer, integer, integer, integer) to anon, authenticated, service_role;
