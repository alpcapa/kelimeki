-- Kaynak Hunisi: "Oynayan Üye" sütunu — `signup_players` (24 Eylül 2026).
--
-- Kullanıcı sorusu: "arkadaş davetinden gelen 31 kişinin 26'sı üye olmuş
-- fakat 4'ü oyun başlatıp hiçbiri bitirmemiş — bu mümkün mü?" Mümkün: huni
-- MİSAFİR hunisi, davetle gelen ise ÖNCE üye olup SONRA oynuyor, yani
-- oyunları misafir sütunlarına hiç düşmüyor. Ölçüldü (90 gün, `arkadas`):
-- 26 üyenin 17'si en az bir oyun bitirmiş, 1.348 oyun.
--
-- Mevcut `players` bu soruyu CEVAPLAYAMIYOR: pencere oyun tarihine uygulanıyor,
-- yani pencerede oynayan ESKİ üyeleri de sayıyor (30 gün, `arkadas`: 6 yeni
-- üye, 15 "oynayan" → %250). `signup_players` bir KOHORT: pencerede ÜYE
-- OLANLARDAN (aynı `signups` kümesi) bugüne kadar en az bir oyun bitirmiş
-- olan sayısı. Tanım gereği `signup_players <= signups`, oran %100'ü aşmaz.
--
-- Dönüş tipi değiştiği için `create or replace` YETMEZ → drop + create.
-- Merge öncesi proacl: {postgres=X, authenticated=X, service_role=X} —
-- aynısı aşağıda elle geri kuruluyor (Supabase yeni fonksiyona anon'a da
-- execute veriyor; `revoke ... from anon` bu yüzden açıkça yazılı).

drop function if exists public.admin_source_funnel (integer);

create function public.admin_source_funnel(p_days integer default 30)
returns table (
  source text,
  visitors bigint,
  starts bigint,
  starters bigint,
  signups bigint,
  finishes bigint,
  finishers bigint,
  member_games bigint,
  players bigint,
  signup_players bigint
)
language plpgsql
stable
security definer
set search_path = public, auth
as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with v as (
    select coalesce(gv.utm_source, 'direkt') as src,
           count(distinct gv.anon_id) as n
    from public.guest_visits gv
    where gv.created_at >= v_since
    group by 1
  ),
  st as (
    select coalesce(gs.utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gs.anon_id) as uniq
    from public.game_starts gs
    where gs.created_at >= v_since
      and gs.is_guest is true
    group by 1
  ),
  fi as (
    select coalesce(gf.utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gf.anon_id) as uniq
    from public.game_finishes gf
    where gf.created_at >= v_since
      and gf.user_id is null
    group by 1
  ),
  s as (
    select coalesce(p.signup_utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(*) filter (
             where exists (select 1 from public.games gm where gm.user_id = p.id)
           ) as pl
    from public.profiles p
    where p.created_at >= v_since
    group by 1
  ),
  g as (
    select coalesce(p.signup_utm_source, 'bilinmiyor') as src,
           count(*) as n,
           count(distinct gm.user_id) as pl
    from public.games gm
    join public.profiles p on p.id = gm.user_id
    where gm.created_at >= v_since
    group by 1
  ),
  k as (
    select src from v
    union select src from st
    union select src from fi
    union select src from s
    union select src from g
  )
  select k.src,
         coalesce(v.n, 0),
         coalesce(st.n, 0),
         coalesce(st.uniq, 0),
         coalesce(s.n, 0),
         coalesce(fi.n, 0),
         coalesce(fi.uniq, 0),
         coalesce(g.n, 0),
         coalesce(g.pl, 0),
         coalesce(s.pl, 0)
  from k
  left join v on v.src = k.src
  left join st on st.src = k.src
  left join fi on fi.src = k.src
  left join s on s.src = k.src
  left join g on g.src = k.src
  order by coalesce(v.n, 0) desc, coalesce(st.n, 0) desc, coalesce(s.n, 0) desc, k.src;
end;
$function$;

revoke all on function public.admin_source_funnel (integer) from public, anon;
grant execute on function public.admin_source_funnel (integer) to authenticated, service_role;
