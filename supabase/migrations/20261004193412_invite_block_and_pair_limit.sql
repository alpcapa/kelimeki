-- Davet kuralları v2 (4 Ekim 2026, kullanıcı kararı) — bir önceki migration'ın
-- (`20261004183426_invite_dedupe_and_quota`) YERİNE geçen kurallar:
--
--   1. ENGEL: davet edilen kişi, davet edeni SESSİZE ALMIŞSA ya da (geri
--      çekilmemiş) ŞİKAYET ETMİŞSE davet gönderilemez; gönderen açık mesaj
--      görür: "<takma ad> kullanıcısı sizi engelledi." (kullanıcı kararı —
--      sessiz ret önerilmişti, açık mesaj seçildi). Aynı iki kaynak
--      `_random_blocked`te zaten rastgele eşleşmeyi kapatıyor; şimdi
--      normal davet yolu da bakıyor.
--   2. ÇİFT BAŞINA SINIR: aynı kişiye, o kişi yanıtlamadan, en çok 1 adet
--      2 KİŞİLİK + 1 adet 4 KİŞİLİK bekleyen davet. Kabul edince yenisi
--      serbest. Genel tavan YOK (önceki "kurucu başına 5" kalktı): sınır
--      kişi başınadır, yani 10 arkadaşa en çok 20 davet.
--
-- ⚠ "Bekleyen" = status 'pending' VE 7 günden genç (süresi dolmuş davet
-- `check_invite_expiry` süpürmesi gelene kadar 'pending' kalıyor).
-- ⚠ Daha ÖNCE gönderilmiş bekleyen davetler engelden sonra İPTAL EDİLMEZ;
-- kapı yalnızca yeni gönderimi durdurur.
--
-- Yardımcının imzası DEĞİŞTİ (player_count eklendi) → eskisi (uuid, uuid)
-- düşürülür; yeni fonksiyon yeni olduğundan grant'ler elle kurulur.

create or replace function public._assert_invite_allowed(p_uid uuid, p_invitee uuid, p_player_count integer)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_name text;
begin
  if exists (
    select 1 from public.online_game_message_mutes m
    where m.muter_user_id = p_invitee and m.muted_user_id = p_uid
  ) or exists (
    select 1 from public.online_game_chat_reports r
    where r.reporter_user_id = p_invitee
      and r.reported_user_id = p_uid
      and r.withdrawn_at is null
  ) then
    select display_name into v_name from public.profiles where id = p_invitee;
    raise exception '% kullanıcısı sizi engelledi.', coalesce(v_name, 'Bu');
  end if;

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

revoke all on function public._assert_invite_allowed(uuid, uuid, integer) from public, anon, authenticated;
grant execute on function public._assert_invite_allowed(uuid, uuid, integer) to service_role;

create or replace function public.create_online_game(p_player_count integer, p_slots jsonb)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_game_id uuid;
  v_slot jsonb;
  v_slot_type text;
  v_slot_user uuid;
  v_seen_users uuid[] := array[]::uuid[];
  v_pending_invites int := 0;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;
  if p_player_count not in (2, 4) then
    raise exception 'Geçersiz oyuncu sayısı.';
  end if;
  if jsonb_array_length(p_slots) <> p_player_count then
    raise exception 'Koltuk sayısı oyuncu sayısıyla eşleşmiyor.';
  end if;

  v_slot := p_slots -> 0;
  if (v_slot ->> 'type') <> 'human' or (v_slot ->> 'user_id')::uuid <> v_uid then
    raise exception 'İlk koltuk oyunu kuran kişi olmalı.';
  end if;

  -- Aynı kullanıcının iki eşzamanlı çağrısı çift-davet kapısını birlikte aşmasın.
  perform pg_advisory_xact_lock(hashtextextended('kelimeki_invite:' || v_uid::text, 0));

  for i in 0 .. jsonb_array_length(p_slots) - 1 loop
    v_slot := p_slots -> i;
    v_slot_type := v_slot ->> 'type';
    if v_slot_type not in ('human', 'ai') then
      raise exception 'Geçersiz koltuk türü.';
    end if;

    if v_slot_type = 'human' then
      v_slot_user := (v_slot ->> 'user_id')::uuid;
      if v_slot_user is null then
        raise exception 'İnsan koltuğunda user_id eksik.';
      end if;
      if v_slot_user = any (v_seen_users) then
        raise exception 'Aynı kullanıcı birden fazla koltukta olamaz.';
      end if;
      v_seen_users := v_seen_users || v_slot_user;

      if v_slot_user <> v_uid and not exists (
        select 1 from public.friend_requests fr
        where fr.status = 'accepted'
          and ((fr.user_id = v_uid and fr.friend_id = v_slot_user)
            or (fr.user_id = v_slot_user and fr.friend_id = v_uid))
      ) then
        raise exception 'Yalnızca arkadaşlarını davet edebilirsin.';
      end if;

      if v_slot_user <> v_uid then
        perform public._assert_invite_allowed(v_uid, v_slot_user, p_player_count);
      end if;
    end if;
  end loop;

  insert into public.online_games (created_by, player_count, slots)
  values (v_uid, p_player_count, p_slots)
  returning id into v_game_id;

  for i in 0 .. jsonb_array_length(p_slots) - 1 loop
    v_slot := p_slots -> i;
    if (v_slot ->> 'type') = 'human' and (v_slot ->> 'user_id')::uuid <> v_uid then
      insert into public.game_invites (online_game_id, invitee_id)
      values (v_game_id, (v_slot ->> 'user_id')::uuid);
      v_pending_invites := v_pending_invites + 1;
    end if;
  end loop;

  if v_pending_invites = 0 then
    update public.online_games set status = 'active', updated_at = now() where id = v_game_id;
    perform public.init_online_game_state(v_game_id);
  end if;

  return v_game_id;
end;
$function$;

create or replace function public.create_random_game(p_player_count integer, p_slots jsonb)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_slot jsonb;
  v_type text;
  v_user uuid;
  v_seen uuid[] := array[]::uuid[];
  v_clean jsonb := '[]'::jsonb;
  v_open int := 0;
  v_friends int := 0;
  v_ai int := 0;
  v_target uuid;
  v_game_id uuid;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;
  if p_player_count is null or p_player_count not in (2, 4) then
    raise exception 'Geçersiz oyuncu sayısı.';
  end if;
  if p_slots is null or jsonb_typeof(p_slots) <> 'array'
     or jsonb_array_length(p_slots) <> p_player_count then
    raise exception 'Koltuk sayısı oyuncu sayısıyla eşleşmiyor.';
  end if;

  v_slot := p_slots -> 0;
  if (v_slot ->> 'type') is distinct from 'human'
     or (v_slot ->> 'user_id') is distinct from v_uid::text then
    raise exception 'İlk koltuk oyunu kuran kişi olmalı.';
  end if;
  v_seen := array[v_uid];
  v_clean := jsonb_build_array(jsonb_build_object('type', 'human', 'user_id', v_uid));

  perform pg_advisory_xact_lock(hashtextextended('kelimeki_invite:' || v_uid::text, 0));

  for i in 1 .. p_player_count - 1 loop
    v_slot := p_slots -> i;
    v_type := v_slot ->> 'type';

    if v_type = 'open' then
      v_open := v_open + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'open'));

    elsif v_type = 'ai' then
      if not (p_player_count = 4 and i = 3) then
        raise exception 'Yapay Zeka yalnızca 4 kişilik oyunun son koltuğunda olabilir.';
      end if;
      v_ai := v_ai + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'ai'));

    elsif v_type = 'human' then
      begin
        v_user := (v_slot ->> 'user_id')::uuid;
      exception when others then
        raise exception 'İnsan koltuğunda user_id eksik.';
      end;
      if v_user is null then
        raise exception 'İnsan koltuğunda user_id eksik.';
      end if;
      if v_user = any (v_seen) then
        raise exception 'Aynı kullanıcı birden fazla koltukta olamaz.';
      end if;
      if not exists (
        select 1 from public.friend_requests fr
        where fr.status = 'accepted'
          and ((fr.user_id = v_uid and fr.friend_id = v_user)
            or (fr.user_id = v_user and fr.friend_id = v_uid))
      ) then
        raise exception 'Yalnızca arkadaşlarını davet edebilirsin.';
      end if;
      perform public._assert_invite_allowed(v_uid, v_user, p_player_count);
      v_seen := v_seen || v_user;
      v_friends := v_friends + 1;
      v_clean := v_clean || jsonb_build_array(jsonb_build_object('type', 'human', 'user_id', v_user));

    else
      raise exception 'Geçersiz koltuk türü.';
    end if;
  end loop;

  if v_open = 0 then
    raise exception 'En az bir koltuk Rastgele Oyuncu olmalı.';
  end if;

  perform public._random_preflight(v_uid);

  if v_friends = 0 and v_ai = 0 then
    select og.id into v_target
    from public.online_games og
    where og.listing = 'random'
      and og.status = 'pending'
      and og.player_count = p_player_count
      and now() - og.created_at <= interval '7 days'
      and og.created_by is not null
      and og.created_by <> v_uid
      and public._slots_open_count(og.slots) > 0
      and not public._random_is_party(og.id, og.slots, v_uid)
      and not public._random_blocked(v_uid, og.slots)
    order by og.created_at asc, og.id asc
    limit 1
    for update skip locked;

    if v_target is not null then
      return public._random_take_seat(v_target, v_uid)
             || jsonb_build_object('joined', true);
    end if;
  end if;

  perform set_config('kelimeki.random_rpc', 'on', true);
  insert into public.online_games (created_by, player_count, slots, listing)
  values (v_uid, p_player_count, v_clean, 'random')
  returning id into v_game_id;
  perform set_config('kelimeki.random_rpc', '', true);

  for i in 1 .. p_player_count - 1 loop
    v_slot := v_clean -> i;
    if v_slot ->> 'type' = 'human' then
      insert into public.game_invites (online_game_id, invitee_id)
      values (v_game_id, (v_slot ->> 'user_id')::uuid);
    end if;
  end loop;

  return jsonb_build_object('joined', false, 'game_id', v_game_id, 'started', false);
end;
$function$;

-- TEMİZLİK (MCP aracı DROP'ta onay bekleyip zaman aşımına uğruyor → Supabase
-- panelinden ELLE çalıştırılır; eski 2 argümanlı yardımcı artık HİÇBİR
-- yerden çağrılmıyor, bırakılması zararsız):
--   drop function public._assert_invite_allowed(uuid, uuid);
