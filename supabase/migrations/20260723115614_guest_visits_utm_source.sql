-- Kelimeki — misafir ziyaretlerine kaynak (UTM) etiketi ekleme
--
-- Sosyal medya tanıtım sprinti başladığından, hangi kanalın (TikTok,
-- Instagram, X, Facebook grubu...) gerçekten ziyaretçi getirdiğini görmek
-- gerekiyor. guest_visits şimdiye kadar hiçbir kaynak bilgisi tutmuyordu —
-- tüm ziyaretler tek bir havuzda toplanıyordu. Kaynak, bio/paylaşım
-- linklerine eklenecek ?ref=tiktok gibi bir parametreden istemci tarafında
-- (src/utils/visitTracking.ts) okunup cihazda ilk temas (first-touch) olarak
-- saklanıyor; ?ref= olmadan gelen ziyaretler "direkt" sayılıyor.

alter table public.guest_visits
  add column if not exists utm_source text;

comment on column public.guest_visits.utm_source is 'İstemci tarafında ?ref= parametresinden okunup cihazda ilk temas (first-touch) olarak saklanan pazarlama kaynağı etiketi (ör. tiktok, instagram, x, facebook) — hiçbir kişisel veri taşımaz. ?ref= ile hiç gelinmemişse null (admin RPC''sinde "direkt" olarak gösterilir).';

-- Admin panelinde Büyüme > Kullanıcı altında hangi kaynağın kaç benzersiz
-- ziyaretçi getirdiğini görmek için — mevcut admin_user_activity_series
-- zaman serisine kaynak kırılımı eklemek yerine, ayrı ve basit bir toplam
-- döküm RPC'si: son p_days gün içinde kaynak başına DISTINCT anon_id sayısı.
create or replace function public.admin_guest_source_breakdown (
  p_days integer default 30
)
  returns table (
    source    text,
    visitors  bigint
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
    coalesce(gv.utm_source, 'direkt') as source,
    count(distinct gv.anon_id) as visitors
  from public.guest_visits gv
  where gv.created_at >= now() - (greatest(p_days, 1) || ' days')::interval
  group by 1
  order by visitors desc;
end;
$$;

revoke all on function public.admin_guest_source_breakdown (integer) from public, anon;
grant execute on function public.admin_guest_source_breakdown (integer) to authenticated;
