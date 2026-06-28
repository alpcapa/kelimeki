-- Harfik — başlangıç şeması
-- Özellikler: kullanıcı profilleri (auth), oyun kayıtları (leaderboard + istatistik),
-- Türkçe kelime listesi. Tüm tablolarda RLS açıktır.

-- ── PROFILES ────────────────────────────────────────────────────────────────
-- auth.users'a 1-1 bağlı oyuncu profili.
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  username     text unique,
  display_name text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.profiles is 'Harfik oyuncu profilleri (auth.users ile 1-1).';

-- ── WORDS ───────────────────────────────────────────────────────────────────
-- Türkçe kelime listesi. Sözlük doğrulaması ve istatistik için.
create table if not exists public.words (
  word   text primary key,
  len    smallint not null,
  points smallint not null default 0
);

comment on table public.words is 'Geçerli Türkçe kelimeler (küçük harf), uzunluk ve taş puanıyla.';
create index if not exists words_len_idx on public.words (len);

-- ── GAMES ───────────────────────────────────────────────────────────────────
-- Tamamlanan her oyunun kaydı. Leaderboard ve istatistiklerin kaynağı.
create table if not exists public.games (
  id           uuid primary key default gen_random_uuid (),
  user_id      uuid references auth.users (id) on delete set null,
  player_score integer not null default 0,
  ai_score     integer not null default 0,
  result       text not null check (result in ('win', 'lose', 'tie')),
  turn_count   integer not null default 0,
  best_word    text,
  created_at   timestamptz not null default now()
);

comment on table public.games is 'Tamamlanan Harfik oyunlarının skor kayıtları.';
create index if not exists games_user_id_idx on public.games (user_id);
create index if not exists games_created_at_idx on public.games (created_at desc);
create index if not exists games_player_score_idx on public.games (player_score desc);

-- ── TRIGGERS ────────────────────────────────────────────────────────────────
-- Yeni auth kullanıcısı için otomatik profil oluştur.
create or replace function public.handle_new_user ()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
  as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user ();

-- profiles.updated_at otomatik güncellensin.
create or replace function public.set_updated_at ()
  returns trigger
  language plpgsql
  as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at ();

-- ── ROW LEVEL SECURITY ──────────────────────────────────────────────────────
alter table public.profiles enable row level security;
alter table public.games enable row level security;
alter table public.words enable row level security;

-- profiles: herkes okuyabilir (leaderboard'da isim göstermek için), kişi yalnızca kendini yazar.
drop policy if exists profiles_select_all on public.profiles;
create policy profiles_select_all on public.profiles
  for select using (true);

drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self on public.profiles
  for insert with check (auth.uid () = id);

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update using (auth.uid () = id) with check (auth.uid () = id);

-- games: herkes okuyabilir (leaderboard), kullanıcı yalnızca kendi kaydını ekler.
drop policy if exists games_select_all on public.games;
create policy games_select_all on public.games
  for select using (true);

drop policy if exists games_insert_self on public.games;
create policy games_insert_self on public.games
  for insert with check (auth.uid () = user_id);

-- words: herkes okuyabilir; yazma yalnızca service_role ile (politika yok = anon/auth yazamaz).
drop policy if exists words_select_all on public.words;
create policy words_select_all on public.words
  for select using (true);

-- ── VIEWS ───────────────────────────────────────────────────────────────────
-- security_invoker: view'lar sorgulayanın RLS'ine göre çalışır.

-- Leaderboard: kullanıcı başına en iyi skor.
create or replace view public.leaderboard
with (security_invoker = true) as
select
  g.user_id,
  p.username,
  p.display_name,
  max(g.player_score) as best_score,
  count(*) as games_played,
  count(*) filter (where g.result = 'win') as wins
from public.games g
left join public.profiles p on p.id = g.user_id
where g.user_id is not null
group by g.user_id, p.username, p.display_name
order by best_score desc;

-- Oyuncu istatistik özeti.
create or replace view public.player_stats
with (security_invoker = true) as
select
  g.user_id,
  count(*) as games_played,
  count(*) filter (where g.result = 'win') as wins,
  count(*) filter (where g.result = 'lose') as losses,
  count(*) filter (where g.result = 'tie') as ties,
  max(g.player_score) as best_score,
  round(avg(g.player_score))::int as avg_score
from public.games g
where g.user_id is not null
group by g.user_id;

-- ── RPC: sunucu tarafı kelime doğrulama ────────────────────────────────────
-- İstemci isterse kelimeyi DB üzerinden de doğrulayabilir.
create or replace function public.is_valid_word (p_word text)
  returns boolean
  language sql
  stable
  security invoker
  set search_path = public
  as $$
  select exists (
    select 1 from public.words where word = lower(p_word)
  );
$$;
