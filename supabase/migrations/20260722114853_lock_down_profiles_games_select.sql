-- profiles ve games tablolarının SELECT RLS politikaları `qual = true` idi,
-- yani herkes (girişsiz dahil) her kullanıcının ad/soyad/is_admin bilgisini
-- ve tüm oyun geçmişini doğrudan REST API'den okuyabiliyordu. Uygulamanın
-- kendisi zaten hep kendi satırına ya da (admin panelinde) is_admin()
-- kontrolüyle filtreliyor — bu genişlik hiçbir yerde kullanılmıyordu.
--
-- leaderboard view'ı ve my_leaderboard_rank() fonksiyonu sıralama hesabı
-- için tüm kullanıcıların games satırlarını görmesi gerektiğinden ayrıca
-- ele alınıyor: leaderboard'u security_invoker=false yapıp (view sahibi
-- postgres'in RLS'i bypass eden yetkisiyle çalışsın, davranışı hiç
-- değişmesin) my_leaderboard_rank()'i SECURITY DEFINER'a çeviriyoruz.

drop policy if exists profiles_select_all on public.profiles;
create policy profiles_select_own_or_admin on public.profiles
  for select
  using (auth.uid() = id or is_admin());

drop policy if exists games_select_all on public.games;
create policy games_select_own_or_admin on public.games
  for select
  using (auth.uid() = user_id or is_admin());

-- Lig tablosu (Leaderboard.tsx, UserMenu'deki "league" modalı) tüm
-- kullanıcıların top-10'unu göstermesi gerektiğinden yukarıdaki
-- kısıtlamadan etkilenmesin diye owner-context'e (RLS bypass) döndürülüyor.
alter view public.leaderboard set (security_invoker = false);

-- my_leaderboard_rank tüm oyuncular arasında sıralama hesapladığından
-- (RANK() OVER) artık kısıtlanmış games tablosunu göremez; SECURITY
-- DEFINER'a çevirip diğer admin_* fonksiyonlarındaki gibi bir yetki
-- kontrolü ekliyoruz (kendi rankını ya da admin başka birininkini
-- sorgulayabilir — AdminPlayerDetail.tsx zaten member.id ile çağırıyor).
create or replace function public.my_leaderboard_rank(p_user_id uuid)
returns table(rank bigint, total_score bigint)
language plpgsql
security definer
stable
set search_path to 'public'
as $$
begin
  if not (p_user_id = auth.uid() or is_admin()) then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  select ranked.rank, ranked.total_score
  from (
    select
      g.user_id,
      sum(
        case
          when g.surrendered then -2
          when g.rank = 1 then 2
          when g.rank = 2 and g.player_count <> 2 then 1
          else 0
        end
      ) as total_score,
      rank() over (
        order by sum(
          case
            when g.surrendered then -2
            when g.rank = 1 then 2
            when g.rank = 2 and g.player_count <> 2 then 1
            else 0
          end
        ) desc
      ) as rank
    from public.games g
    where g.user_id is not null
    group by g.user_id
  ) ranked
  where ranked.user_id = p_user_id;
end;
$$;
