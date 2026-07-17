-- Harfik — admin_list_members düzeltmesi: auth.users.email varchar(255),
-- returns table'daki text ile tip uyuşmazlığı hatası veriyordu.
create or replace function public.admin_list_members ()
  returns table (
    id               uuid,
    email            text,
    username         text,
    first_name       text,
    last_name        text,
    display_name     text,
    is_admin         boolean,
    created_at       timestamptz,
    last_sign_in_at  timestamptz,
    banned_until     timestamptz
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
    u.id,
    u.email::text,
    p.username,
    p.first_name,
    p.last_name,
    p.display_name,
    coalesce(p.is_admin, false),
    u.created_at,
    u.last_sign_in_at,
    u.banned_until
  from auth.users u
  left join public.profiles p on p.id = u.id
  order by u.created_at desc;
end;
$$;

revoke all on function public.admin_list_members () from public, anon;
grant execute on function public.admin_list_members () to authenticated;
