-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 1. Şema ────────────────────────────────────────────────────────────────

alter table public.online_games add column if not exists listing text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.online_games'::regclass
      and conname = 'online_games_listing_check'
  ) then
    alter table public.online_games
      add constraint online_games_listing_check
      check (listing is null or listing in ('random', 'team'));
  end if;
end $$;

comment on column public.online_games.listing is
  'Açık ilan türü: NULL = arkadaş daveti (bugünkü oyun), random = Rastgele Oyuncu '
  '(random-opponent.md), team = Takım Ligi (team-league.md). Açık koltuk: '
  'slots içinde {"type":"open"}; yalnızca create/accept/leave_random_game yazar.';

-- Şerit sorgusu (list_random_games) ve "önce var olan ilana katıl" araması.
create index if not exists online_games_open_listing_idx
  on public.online_games (listing, player_count, created_at desc)
  where status = 'pending' and listing is not null;
