-- Ret metni formlardaki terimle aynı olsun: "takma isim" (AuthModal /
-- AccountSettingsModal / port). Davranış değişmedi.
create or replace function public.reject_blocked_nickname()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.display_name is not null
     and (tg_op = 'INSERT' or new.display_name is distinct from old.display_name)
     and public._nickname_is_blocked(new.display_name) then
    raise exception 'Bu takma isim kullanılamaz.' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
revoke all on function public.reject_blocked_nickname() from public, anon, authenticated;
