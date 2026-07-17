-- Harfik — admin paneli: is_admin bayrağı, oyun başlangıç kaydı ve admin RPC'leri
--
-- games tablosu yalnızca BİTEN oyunları tutar (saveGame yalnızca oyun sonunda
-- çağrılır). Admin panelinde "başlatılan" sayısını (bitirilmeyenler dahil)
-- göstermek için ayrı bir game_starts tablosu ekleniyor; Setup ekranında
-- "Oyunu Başlat"a basıldığında (giriş yapılmışsa) bir satır eklenir.

-- ── PROFILES: admin bayrağı ─────────────────────────────────────────────────
alter table public.profiles
  add column if not exists is_admin boolean not null default false;

comment on column public.profiles.is_admin is 'Admin panosuna erişim yetkisi.';

-- ── GAME_STARTS ─────────────────────────────────────────────────────────────
create table if not exists public.game_starts (
  id           uuid primary key default gen_random_uuid (),
  user_id      uuid references auth.users (id) on delete set null,
  player_count integer not null,
  created_at   timestamptz not null default now()
);

comment on table public.game_starts is 'Başlatılan her oyun için bir satır (bitirilip bitirilmediğine bakılmaksızın) — admin panelindeki "başlatılan" sayacı için.';
create index if not exists game_starts_created_at_idx on public.game_starts (created_at desc);
create index if not exists game_starts_player_count_idx on public.game_starts (player_count);

alter table public.game_starts enable row level security;

-- Kullanıcı yalnızca kendi başlangıç kaydını ekleyebilir; kimse doğrudan
-- okuyamaz (admin erişimi aşağıdaki security definer fonksiyonlarla sağlanır).
drop policy if exists game_starts_insert_self on public.game_starts;
create policy game_starts_insert_self on public.game_starts
  for insert with check (auth.uid () = user_id);

-- ── is_admin() yardımcı fonksiyonu ──────────────────────────────────────────
create or replace function public.is_admin ()
  returns boolean
  language sql
  stable
  security definer
  set search_path = public
  as $$
  select coalesce((select p.is_admin from public.profiles p where p.id = auth.uid ()), false);
$$;

-- ── ADMIN: üye listesi (auth.users + profiles) ──────────────────────────────
create or replace function public.admin_list_members ()
  returns table (
    id               uuid,
    email            text,
    username         text,
    first_name       text,
    last_name        text,
    display_name     text,
    is_admin         boolean,
    created_at       timestamptz,
    last_sign_in_at  timestamptz,
    banned_until     timestamptz
  )
  language plpgsql
  stable
  security definer
  set search_path = public, auth
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    u.id,
    u.email,
    p.username,
    p.first_name,
    p.last_name,
    p.display_name,
    coalesce(p.is_admin, false),
    u.created_at,
    u.last_sign_in_at,
    u.banned_until
  from auth.users u
  left join public.profiles p on p.id = u.id
  order by u.created_at desc;
end;
$$;

revoke all on function public.admin_list_members () from public, anon;
grant execute on function public.admin_list_members () to authenticated;

-- ── ADMIN: oyuncu sayısına göre başlatılan/biten oyun sayıları ─────────────
create or replace function public.admin_game_counts ()
  returns table (
    player_count integer,
    started      bigint,
    finished     bigint
  )
  language plpgsql
  stable
  security definer
  set search_path = public
  as $$
begin
  if not public.is_admin () then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select
    pc.player_count,
    coalesce(s.started, 0)  as started,
    coalesce(f.finished, 0) as finished
  from (
    select distinct player_count from public.game_starts
    union
    select distinct player_count from public.games
  ) pc
  left join (
    select player_count, count(*) as started
    from public.game_starts
    group by player_count
  ) s on s.player_count = pc.player_count
  left join (
    select player_count, count(*) as finished
    from public.games
    group by player_count
  ) f on f.player_count = pc.player_count
  order by pc.player_count;
end;
$$;

revoke all on function public.admin_game_counts () from public, anon;
grant execute on function public.admin_game_counts () to authenticated;
