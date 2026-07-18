-- Harfik — admin panelinde üyenin kayıt kanalını göstermek için
-- profiles.signup_channel: 'direct' (normal kayıt) ya da 'form' (oyun
-- bitiminde "Görüş Bildir" formuna e-posta bırakıp "üyeliğe devam et"
-- akışından gelen kayıt).

alter table public.profiles
  add column if not exists signup_channel text not null default 'direct'
    check (signup_channel in ('direct', 'form'));

comment on column public.profiles.signup_channel is 'Kayıt kanalı: direct (normal kayıt) ya da form (Görüş Bildir formundan üyeliğe devam).';

-- ── TRIGGER: signup_channel'i de metadata'dan oku ───────────────────────────
create or replace function public.handle_new_user ()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
  as $$
declare
  _first   text;
  _last    text;
  _display text;
  _channel text;
begin
  _first := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'firstName',
    ''
  );
  _last := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'lastName',
    ''
  );
  _display := coalesce(
    new.raw_user_meta_data ->> 'display_name',
    nullif(trim(_first || ' ' || _last), ''),
    split_part(new.email, '@', 1)
  );
  _channel := new.raw_user_meta_data ->> 'signup_channel';
  if _channel is null or _channel not in ('direct', 'form') then
    _channel := 'direct';
  end if;

  insert into public.profiles (id, username, first_name, last_name, display_name, signup_channel)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1)),
    _first,
    _last,
    _display,
    _channel
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- ── ADMIN: üye listesine signup_channel eklendi ─────────────────────────────
-- Dönüş tipi değiştiği için (yeni kolon) önce fonksiyon düşürülüyor.
drop function if exists public.admin_list_members ();

create function public.admin_list_members ()
  returns table (
    id               uuid,
    email            text,
    username         text,
    first_name       text,
    last_name        text,
    display_name     text,
    is_admin         boolean,
    signup_channel   text,
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
    coalesce(p.signup_channel, 'direct'),
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
