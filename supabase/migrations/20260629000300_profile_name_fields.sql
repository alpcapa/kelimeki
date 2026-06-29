-- Harfik — profil ad/soyad alanları
-- profiles tablosuna first_name ve last_name eklenir;
-- handle_new_user trigger'ı Harfik kayıt meta_data formatını okur;
-- leaderboard görünümüne first_name dahil edilir.

-- ── SÜTUNLAR ─────────────────────────────────────────────────────────────────
alter table public.profiles
  add column if not exists first_name text not null default '',
  add column if not exists last_name  text not null default '';

-- ── TRİGGER GÜNCELLEMESİ ────────────────────────────────────────────────────
-- Harfik signUp, meta_data içinde sharedxp_pending_profile: {firstName, lastName}
-- gönderir. Trigger artık bu alanları okur.
create or replace function public.handle_new_user ()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
  as $$
declare
  _first   text;
  _last    text;
  _display text;
begin
  _first := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'firstName',
    ''
  );
  _last := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'lastName',
    ''
  );
  _display := coalesce(
    new.raw_user_meta_data ->> 'display_name',
    nullif(trim(_first || ' ' || _last), ''),
    split_part(new.email, '@', 1)
  );

  insert into public.profiles (id, username, first_name, last_name, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1)),
    _first,
    _last,
    _display
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- ── LEADERBOARD GÖRÜNÜMÜ (first_name dahil) ─────────────────────────────────
drop view if exists public.leaderboard;
create view public.leaderboard
with (security_invoker = true) as
select
  g.user_id,
  p.username,
  p.first_name,
  p.display_name,
  p.avatar_url,
  max(g.player_score)                       as best_score,
  sum(g.player_score)                       as total_score,
  count(*)                                  as games_played,
  count(*) filter (where g.result = 'win')  as wins
from public.games g
inner join public.profiles p on p.id = g.user_id
group by g.user_id, p.username, p.first_name, p.display_name, p.avatar_url
order by total_score desc;
