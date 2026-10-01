-- "Sık oynadıkların" şeridi (canlı oyun kurma formu, 27 Eylül 2026, ROADMAP
-- #41): son 90 günde birlikte en çok CANLI oyun oynanan, HÂLÂ arkadaş olan
-- kişiler. Eşitlikte en son oynanan önde. Ad/avatar istemcide `list_friends`
-- satırından gelir — burada yalnızca sıra.
--
-- Sayılan oyunlar: `active` + `finished` (reddedilen/bekleyen/terk edilen
-- davet "birlikte oynamak" değil). Koltuklar `online_games.slots` jsonb'sinde
-- ({"type":"human","user_id":…}); `@>` ile çağıranın koltuğu olan oyunlar
-- süzülür. Karşılıklı iki `friend_requests` satırı olabileceği için
-- arkadaşlık `exists` ile sınanır (join ÇOĞALTIRDI — bkz.
-- 20260827153857_dedupe_friend_candidate_lists).
create or replace function public.my_frequent_opponents(p_limit int default 5)
returns table(friend_id uuid, games int, last_played timestamptz)
language sql
security definer
set search_path = public
stable
as $$
  select (s->>'user_id')::uuid as friend_id,
         count(*)::int as games,
         max(g.created_at) as last_played
  from public.online_games g
  cross join lateral jsonb_array_elements(g.slots) s
  where auth.uid() is not null
    and g.status in ('active', 'finished')
    and g.created_at > now() - interval '90 days'
    and g.slots @> jsonb_build_array(jsonb_build_object('type', 'human', 'user_id', auth.uid()))
    and s->>'type' = 'human'
    and (s->>'user_id')::uuid <> auth.uid()
    and exists (
      select 1 from public.friend_requests fr
      where fr.status = 'accepted'
        and ((fr.user_id = auth.uid() and fr.friend_id = (s->>'user_id')::uuid)
          or (fr.friend_id = auth.uid() and fr.user_id = (s->>'user_id')::uuid))
    )
  group by 1
  order by 2 desc, 3 desc
  limit least(greatest(coalesce(p_limit, 5), 1), 10);
$$;

revoke all on function public.my_frequent_opponents(int) from public, anon;
grant execute on function public.my_frequent_opponents(int) to authenticated;
