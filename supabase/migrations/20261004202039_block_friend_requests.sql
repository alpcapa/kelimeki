-- ENGEL, arkadaşlık yoluna da uzanıyor (4 Ekim 2026, kullanıcı kararı).
--
-- Kullanıcı: "sessize alan kişi bir daha onunla oyunda veya başka yerde
-- karşılaşmayacağı için 'Sessize al' yerine 'Engelle' demeliyiz". Engel =
-- `online_game_message_mutes` satırı YA DA geri çekilmemiş
-- `online_game_chat_reports` satırı (rastgele eşleşme `_random_blocked`te ve
-- oyun daveti `_assert_invite_allowed`te zaten böyle okuyordu). Bu migration:
--   1. Tek kaynak: `_is_blocked_by(blocker, blocked)` + `_assert_not_blocked(actor,
--      target)` ("<ad> kullanıcısı sizi engelledi."). `_assert_invite_allowed`
--      artık bunu çağırır (aynı kural iki yerde yaşamasın).
--   2. Arkadaşlık İSTEĞİ: `handle_friend_request_insert` (BEFORE INSERT) —
--      engelleyene istek gönderilemez.
--   3. Arkadaş DAVET LİNKİ: `accept_friend_invite` — linkin sahibi tıklayanı
--      engellemişse tıklayan arkadaş OLAMAZ (yoksa link, isteğin kapısını
--      aşardı). Fonksiyon içindeki `friend_requests` insert'i tetikleyiciyi
--      de çalıştırır; yönü terstir (user_id = link sahibi) → o insert için
--      tetikleyici yerel bayrakla (`kelimeki.friend_link`) atlanır.
--
-- ⚠ Daha ÖNCE açılmış bekleyen istekler iptal EDİLMEZ; kapı yalnızca yeni
-- gönderimi durdurur. ⚠ Engelleyen kendisi istek gönderirse engellemiş
-- olduğu kişiye de gönderebilir (kendi kararı; kapı yalnızca "karşı taraf
-- beni engelledi mi" diye bakar).
--
-- İmzalar DEĞİŞMEDİ (`create or replace`), grant'ler korunur; iki yeni
-- yardımcı yalnızca `service_role`.

create or replace function public._is_blocked_by(p_blocker uuid, p_blocked uuid)
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $function$
  select exists (
    select 1 from public.online_game_message_mutes m
    where m.muter_user_id = p_blocker and m.muted_user_id = p_blocked
  ) or exists (
    select 1 from public.online_game_chat_reports r
    where r.reporter_user_id = p_blocker
      and r.reported_user_id = p_blocked
      and r.withdrawn_at is null
  );
$function$;

revoke all on function public._is_blocked_by(uuid, uuid) from public, anon, authenticated;
grant execute on function public._is_blocked_by(uuid, uuid) to service_role;

create or replace function public._assert_not_blocked(p_actor uuid, p_target uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_name text;
begin
  if public._is_blocked_by(p_target, p_actor) then
    select display_name into v_name from public.profiles where id = p_target;
    raise exception '% kullanıcısı sizi engelledi.', coalesce(v_name, 'Bu');
  end if;
end;
$function$;

revoke all on function public._assert_not_blocked(uuid, uuid) from public, anon, authenticated;
grant execute on function public._assert_not_blocked(uuid, uuid) to service_role;

create or replace function public._assert_invite_allowed(p_uid uuid, p_invitee uuid, p_player_count integer)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  perform public._assert_not_blocked(p_uid, p_invitee);

  if exists (
    select 1
    from public.game_invites gi
    join public.online_games og on og.id = gi.online_game_id
    where og.created_by = p_uid
      and gi.invitee_id = p_invitee
      and gi.status = 'pending'
      and og.status = 'pending'
      and og.player_count = p_player_count
      and now() - og.created_at <= interval '7 days'
  ) then
    raise exception 'Bu arkadaşına zaten yanıtlanmamış bir % kişilik davetin var. Kabul edince yenisini gönderebilirsin.', p_player_count;
  end if;
end;
$function$;

create or replace function public.handle_friend_request_insert()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  -- Davet linki yolu (`accept_friend_invite`) kendi engel kontrolünü yapıp bu
  -- bayrağı kurar: o insert'in yönü terstir (user_id = link sahibi).
  if coalesce(current_setting('kelimeki.friend_link', true), '') <> 'on' then
    perform public._assert_not_blocked(new.user_id, new.friend_id);
  end if;

  if exists (
    select 1 from public.friend_requests
    where user_id = new.friend_id and friend_id = new.user_id and status = 'pending'
  ) then
    update public.friend_requests
      set status = 'accepted', responded_at = now()
      where user_id = new.friend_id and friend_id = new.user_id;
    new.status := 'accepted';
    new.responded_at := now();
  end if;
  return new;
end;
$function$;

create or replace function public.accept_friend_invite(p_token text)
returns table(inviter_name text)
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid      uuid := auth.uid();
  v_inviter  uuid;
  v_accepted boolean;
  v_exists   boolean;
  v_rows     integer;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select fil.inviter_id into v_inviter
  from public.friend_invite_links fil
  where fil.token = p_token;

  if v_inviter is null then
    raise exception 'Geçersiz davet linki.';
  end if;

  if v_inviter = v_uid then
    raise exception 'Kendi linkinle arkadaş olamazsın.';
  end if;

  -- Link sahibi tıklayanı ENGELLEMİŞSE arkadaş olunamaz.
  perform public._assert_not_blocked(v_uid, v_inviter);

  -- Var olan ilişki satır(lar)ını KİLİTLE. ⚠ İkili için İKİ YÖNLÜ satır
  -- olabiliyor (`sendFriendRequest` düz insert, PK (user_id,friend_id) ters
  -- yönü engellemez; canlıda bir örneği var), o yüzden tek satır okumak
  -- BELİRSİZ olurdu — hepsi kilitlenir, karar `bool_or` ile verilir.
  perform 1 from public.friend_requests fr
  where (fr.user_id = v_inviter and fr.friend_id = v_uid)
     or (fr.user_id = v_uid and fr.friend_id = v_inviter)
  for update;

  select count(*) > 0, coalesce(bool_or(fr.status = 'accepted'), false)
    into v_exists, v_accepted
  from public.friend_requests fr
  where (fr.user_id = v_inviter and fr.friend_id = v_uid)
     or (fr.user_id = v_uid and fr.friend_id = v_inviter);

  if v_accepted then
    -- ZATEN ARKADAŞLAR → sayaç ARTMAZ, invited_by'a dokunulmaz.
    -- Yalnızca kalıntı bir `pending` satırı varsa normalize edilir (eski
    -- davranış korunsun diye); `accepted` satırın responded_at'i TAZELENMEZ.
    update public.friend_requests
      set status = 'accepted', responded_at = now()
      where ((user_id = v_inviter and friend_id = v_uid)
          or (user_id = v_uid and friend_id = v_inviter))
        and status <> 'accepted';

    return query
      select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
      from public.profiles p where p.id = v_inviter;
    return;
  end if;

  if not v_exists then
    perform set_config('kelimeki.friend_link', 'on', true);
    insert into public.friend_requests (user_id, friend_id, status, responded_at)
    values (v_inviter, v_uid, 'accepted', now())
    on conflict (user_id, friend_id) do nothing;
    -- ⚠ FOUND'u PERFORM sıfırlar → satır sayısı insert'ten HEMEN sonra alınır.
    get diagnostics v_rows = row_count;
    perform set_config('kelimeki.friend_link', '', true);

    if v_rows = 0 then
      -- Yarış: aynı anda başka bir çağrı kurdu, sayaç ONUN çağrısına yazıldı.
      return query
        select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
        from public.profiles p where p.id = v_inviter;
      return;
    end if;
  else
    -- Yalnızca `pending` satır(lar) var (hangi yönde olursa olsun) → link
    -- tıklaması onları kabul eder. Bu GERÇEK bir kabul, sayılır.
    update public.friend_requests
      set status = 'accepted', responded_at = now()
      where (user_id = v_inviter and friend_id = v_uid)
         or (user_id = v_uid and friend_id = v_inviter);
  end if;

  update public.friend_invite_links set use_count = use_count + 1 where inviter_id = v_inviter;
  update public.profiles set invited_by = v_inviter where id = v_uid and invited_by is null;

  return query
    select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
    from public.profiles p where p.id = v_inviter;
end;
$function$;
