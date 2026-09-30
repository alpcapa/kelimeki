-- Gönderdiğim, henüz cevaplanmamış arkadaşlık istekleri — Arkadaşlar
-- penceresinde gelen isteklerin ALTINDA "Gönderdiğin istekler" olarak
-- listelenir (27 Eylül 2026, ROADMAP #41; bkz. docs/decisions/friends.md →
-- "Tek ekran"). `list_incoming_friend_requests`in ayna ikizi: profiller
-- yalnızca sahibine açık (`profiles_select_own_or_admin`), karşı tarafın
-- adını/avatarını ancak security definer bir RPC verebilir.
create or replace function public.list_outgoing_friend_requests()
returns table(friend_id uuid, name text, avatar_url text, created_at timestamptz)
language sql
security definer
set search_path = public
stable
as $$
  select fr.friend_id,
         coalesce(p.display_name, p.first_name) as name,
         p.avatar_url,
         fr.created_at
  from public.friend_requests fr
  join public.profiles p on p.id = fr.friend_id
  where fr.user_id = auth.uid() and fr.status = 'pending'
  order by fr.created_at desc;
$$;

revoke all on function public.list_outgoing_friend_requests() from public, anon;
grant execute on function public.list_outgoing_friend_requests() to authenticated;
