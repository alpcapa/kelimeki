-- Arkadaş araması soyadı da tarıyor (2 Ekim 2026, kullanıcı isteği).
--
-- Kayıt formunda ad/soyad isteğe bağlı oldu ve altına "Aramalarda bulunmayı
-- kolaylaştırır." yazıldı; arama o gün yalnızca takma isim + ADI tarıyordu.
-- Artık soyadı ve "ad soyad" birleşimini de tarıyor (ör. "Alp Çapa").
-- Sonuçta yine yalnızca takma isim görünür (`name` sütunu DEĞİŞMEDİ) —
-- soyad aramaya girer, ekrana çıkmaz.
--
-- İmza ve dönüş tipi AYNI → `create or replace` yeter, grant'ler korunur
-- (authenticated + service_role; anon YOK — öncesi ve sonrası proacl okundu).
create or replace function public.search_users_for_friend(p_query text)
 returns table(id uuid, name text, avatar_url text, relation text)
 language plpgsql
 stable security definer
 set search_path to 'public'
as $function$
begin
  if auth.uid() is null then
    raise exception 'Oturum açık değil.';
  end if;
  if length(trim(p_query)) < 2 then
    return;
  end if;

  return query
    select d.id, d.name, d.avatar_url, d.relation
    from (
      select distinct on (p.id)
        p.id,
        coalesce(p.display_name, p.first_name) as name,
        p.avatar_url,
        case
          when fr.status = 'accepted' then 'accepted'
          when fr.user_id = auth.uid() then 'pending_outgoing'
          when fr.friend_id = auth.uid() then 'pending_incoming'
          else null
        end as relation
      from public.profiles p
      left join public.friend_requests fr
        on (fr.user_id = auth.uid() and fr.friend_id = p.id)
        or (fr.user_id = p.id and fr.friend_id = auth.uid())
      where p.id <> auth.uid()
        and (
          p.display_name ilike '%' || p_query || '%'
          or p.first_name ilike '%' || p_query || '%'
          or p.last_name ilike '%' || p_query || '%'
          or (p.first_name || ' ' || p.last_name) ilike '%' || trim(p_query) || '%'
        )
      order by p.id, (fr.status = 'accepted') desc nulls last, fr.created_at, fr.user_id
    ) d
    order by d.name, d.id
    limit 20;
end;
$function$;
