-- Huni v2'ye "Mağaza" sütunu (29 Eylül 2026).
--
-- Kullanıcı: *"bizdeki rakamlara göre kare en fazla insan getiren
-- gözüküyor. Biz onu kapattık. Bu rakamlar doğru mu?"* → *"mağaza sütununu
-- ekle"*. Meta kampanyasının telefon ziyaretçisi sitede OYNAMIYOR, mağazaya
-- gidiyor; Huni v2'nin sütunları (2+ gün / üye / başlatan / bitiren) bu
-- trafik için hep 0 kalıyor, tablo yalnızca "kim çok kişi getirdi"yi
-- söylüyordu. `meta-kare` 43 telefon ziyaretinden 1'ini, `meta-karusel`
-- 28'den 9'unu mağazaya göndermişti; tablo bunu göstermiyordu.
--
-- KAYNAK: `web_sessions` (Ziyaretçi Yolculuğu, `store` adımı, 28 Eyl'den
-- beri), `funnel_events` DEĞİL. Bilerek: `funnel_events`e yeni bir olay
-- eklemek gizlilik metnindeki "yedi durum" listesini değiştirirdi (+ port
-- metni); `web_sessions` kimliksiz, zaten yazılıyor ve kampanyanın GEÇMİŞİNİ
-- de taşıyor.
-- ⚠ BİRİM FARKI: `store` = mağazaya giden web MİSAFİR OTURUMU, kohort
-- cihazı değil. Kanala `utm_source` (etiketsizse `direkt`) üzerinden
-- bağlanır; yalnızca `web` satırlarında dolu. Reklam ziyaretçisi için
-- oturum ≈ kişi; kart metni bunu söylüyor.
--
-- Dönüş tipi değişti → DROP + CREATE; grant'ler öncesiyle aynı
-- (authenticated + service_role, anon YOK).
drop function if exists public.admin_funnel (integer, text);

create function public.admin_funnel (p_days integer default 30, p_platform text default null)
  returns table (
    platform       text,
    channel        text,
    land           bigint,
    returned       bigint,
    signed_up      bigint,
    started        bigint,
    finished       bigint,
    games_started  bigint,
    games_finished bigint,
    store          bigint
  )
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
#variable_conflict use_column
declare
  v_since constant date :=
    (now() at time zone 'Europe/Istanbul')::date - (greatest(coalesce(p_days, 30), 1) - 1);
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  return query
  with c as (
    select l.anon_id, l.platform, l.channel, l.day
    from public.funnel_events l
    where l.event = 'land'
      and l.day >= v_since
      and (p_platform is null or l.platform = p_platform)
  ),
  e as (
    select c.anon_id,
           coalesce(bool_or(f.event = 'visit' and f.day > c.day), false) as ret,
           coalesce(bool_or(f.event = 'signup'), false)                    as su,
           count(f.anon_id) filter (where f.event = 'game_start')          as gs,
           count(f.anon_id) filter (where f.event = 'game_finish')         as gf
    from c
    left join public.funnel_events f
      on f.anon_id = c.anon_id and f.event <> 'land'
    group by c.anon_id
  ),
  m as (
    select coalesce(nullif(lower(btrim(ws.utm_source)), ''), 'direkt') as ch,
           count(*)::bigint as n
    from public.web_sessions ws
    where ws.created_at >= (v_since::timestamp at time zone 'Europe/Istanbul')
      and 'store' = any (ws.steps)
    group by 1
  )
  select c.platform,
         c.channel,
         count(*)::bigint,
         count(*) filter (where e.ret)::bigint,
         count(*) filter (where e.su)::bigint,
         count(*) filter (where e.gs > 0)::bigint,
         count(*) filter (where e.gf > 0)::bigint,
         coalesce(sum(e.gs), 0)::bigint,
         coalesce(sum(e.gf), 0)::bigint,
         coalesce(max(m.n), 0)::bigint
  from c
  join e on e.anon_id = c.anon_id
  left join m on c.platform = 'web' and m.ch = c.channel
  group by c.platform, c.channel
  order by count(*) desc, c.platform, c.channel;
end;
$function$;

revoke all on function public.admin_funnel (integer, text) from public, anon;
grant execute on function public.admin_funnel (integer, text) to authenticated, service_role;
