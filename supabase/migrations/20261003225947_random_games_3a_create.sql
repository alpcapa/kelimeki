-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 4. create_random_game ─────────────────────────────────────────────────
-- p_slots: create_online_game ile aynı biçim + {"type":"open"}.
--   koltuk 0 : çağıranın kendisi (human)
--   2 kişilik: koltuk 1 = arkadaş | open
--   4 kişilik: koltuk 1,2 = arkadaş | open ; koltuk 3 = arkadaş | open | ai
--   En az bir koltuk open olmalı (yoksa create_online_game kullanılır).
-- Kadro YALNIZCA açık koltuklardan oluşuyorsa (arkadaş yok, YZ yok) ve aynı
-- oyuncu sayısında uygun bir başkası ilanı varsa, yeni ilan açmak yerine onu
-- atomik kabul eder (öneri §9.1). Seçim: EN ESKİ uygun ilan (en uzun bekleyen
-- önce dolar), kilitli olanlar atlanır (skip locked).
-- Dönüş: {"joined": bool, "game_id": uuid, "started": bool[, "seat": int]}
-- ⚠ Arkadaş koltuğu varsa istemci, mevcut notify-game-invite'ı çağırmalı
--   (kurucu çağırır, yalnızca pending davetlilere gider — bugünkü akış).

create or replace function public.create_random_game(p_player_count int, p_slots jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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

  -- Önce var olan ilana katıl (yalnızca saf rastgele kadroda).
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
$$;

revoke all on function public.create_random_game(int, jsonb) from public, anon;
grant execute on function public.create_random_game(int, jsonb) to authenticated;
