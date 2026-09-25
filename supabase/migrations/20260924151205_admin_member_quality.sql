-- Kelimeki — Kaynak Hunisi (v1) → "Kanal → Üye Kalitesi" (`admin_member_quality`)
--
-- NEDEN (24 Eylül 2026, kullanıcı: *"V1'i de farklı bir bakış açısı için
-- modifiye edip tutmak mümkün mü? Rakamların anlamlı olduğu başka bir
-- versiyon gibi."* → sütunlar onaylandı: *"Bunlar şimdilik iyi"*):
-- Kaynak Hunisi'nin güvenilmez olan yarısı MİSAFİR sütunlarıydı (Gelen /
-- Başlatan / Bitiren): üç ayrı anonim tablodan, farklı başlangıç
-- tarihleriyle, farklı "kişi" tanımlarıyla besleniyordu (ölçülen hatalar:
-- `docs/decisions/funnel-v2.md` → "Neden"). O soru artık Huni v2'nin
-- (`admin_funnel`). ÜYE yarısı ise sağlamdı: kaynak etiketi kayıt anında
-- hesaba TEK SEFER yazılıyor (`profiles.signup_utm_source`), oyunlar hesaba
-- bağlı (`games.user_id`). Bu RPC yalnızca o yarıyı, KOHORT olarak sunar:
-- "hangi kanal değerli üye getiriyor".
--
-- KOHORT: pencerede hesap açan üyeler. Oyunları pencere sonuna (bugüne)
-- kadar izlenir — 29 gün önce üye olup dün oynayan sayılır. Her oran
-- tanım gereği ≤ %100.
--   members           = pencerede o etiketle açılan hesap
--   players           = bunlardan en az bir oyun BİTİREN (`games` satırı)
--   players_7d        = kayıttan sonraki 7 gün içinde oyun bitiren (aktivasyon hızı)
--   returning_players = en az İKİ FARKLI İstanbul gününde oyun bitiren
--                       (Huni v2'deki "2+ gün"ün hesap karşılığı)
--   games             = bu üyelerin bitirdiği oyun adedi (üye başına oyun için)
--
-- `games` hem yerel (YZ) hem Canlı oyunu tutar ve YALNIZCA bitmiş oyun
-- satırıdır; misafir oyunları tanım gereği burada yoktur (hesap yok).
--
-- 'bilinmiyor' = etiketsiz hesap (16 Ağustos 2026 öncesi üyeler).
-- 'app' = mobil uygulamadan açılan hesap (`backfill_app_source_history`).
--
-- `admin_source_funnel` veritabanında DURUYOR ama artık çağrılmıyor
-- (geri dönüş yolu; Huni v2 emekliliğiyle birlikte düşürülebilir).

drop function if exists public.admin_member_quality (integer);

create function public.admin_member_quality (p_days integer default 30)
  returns table (
    source            text,
    members           bigint,
    players           bigint,
    players_7d        bigint,
    returning_players bigint,
    games             bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
#variable_conflict use_column
declare
  v_since constant timestamptz := now() - (greatest(coalesce(p_days, 30), 1) || ' days')::interval;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with m as (
    select p.id,
           p.created_at,
           coalesce(nullif(btrim(p.signup_utm_source), ''), 'bilinmiyor') as src
    from public.profiles p
    where p.created_at >= v_since
  ),
  o as (
    select m.id,
           count(gm.user_id)                                                          as n,
           count(gm.user_id) filter (where gm.created_at < m.created_at + interval '7 days') as n7,
           count(distinct (gm.created_at at time zone 'Europe/Istanbul')::date)       as days
    from m
    left join public.games gm on gm.user_id = m.id
    group by m.id
  )
  select m.src,
         count(*)::bigint,
         count(*) filter (where o.n > 0)::bigint,
         count(*) filter (where o.n7 > 0)::bigint,
         count(*) filter (where o.days >= 2)::bigint,
         coalesce(sum(o.n), 0)::bigint
  from m
  join o on o.id = m.id
  group by m.src
  order by count(*) desc, m.src;
end;
$function$;

revoke all on function public.admin_member_quality (integer) from public, anon;
grant execute on function public.admin_member_quality (integer) to authenticated, service_role;
