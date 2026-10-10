-- Rastgele Oyuncu — 20261004065336_random_timeout_ends_game GERİ ALINDI (4 Ekim 2026, kullanıcı):
-- "Rastgele oyunda 4 kişilik oyunda olduğu gibi teslim olunca diğer oyuncular devam edebilmeli
-- (diğer oyunlar gibi). Sadece süresinde oynamayan -2 almalı. 2 kişi ise oyun biter, teslim -2
-- alır, diğeri +2 alır. 4 kişide oyun devam eder."  Yani rastgele oyunlar zaman aşımında NORMAL
-- Canlı oyunlarla BİREBİR aynı davranır; bu dosya check_turn_timeout'u 3 Ekim 2026 canlı
-- gövdesine (listing'e hiç bakmayan, `v_active_count <= 1` ile biten hâl) döndürür.
create or replace function public.check_turn_timeout(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_player_count int;
  v_slots jsonb;
  v_players jsonb;
  v_board jsonb;
  v_current int;
  v_turn_count int;
  v_is_game_over boolean;
  v_turn_deadline timestamptz;
  v_current_slot jsonb;
  v_bag jsonb;
  v_racks jsonb;
  v_bag_arr jsonb[];
  v_current_rack_arr jsonb[];
  v_new_racks jsonb;
  v_new_players jsonb;
  v_active_count int;
  v_next int;
  v_remaining int;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;
  if not public.is_online_game_participant(p_game_id, v_uid) then
    raise exception 'Bu oyunun katılımcısı değilsin.';
  end if;

  select og.player_count, og.slots into v_player_count, v_slots
  from public.online_games og
  where og.id = p_game_id
  for update;

  if v_player_count is null then
    return;
  end if;

  select s.players, s.board, s.current, s.turn_count, s.is_game_over, s.turn_deadline
    into v_players, v_board, v_current, v_turn_count, v_is_game_over, v_turn_deadline
  from public.online_game_states s
  where s.online_game_id = p_game_id
  for update;

  if v_players is null or v_is_game_over then
    return;
  end if;
  if v_turn_deadline is null or now() < v_turn_deadline then
    return;
  end if;

  v_current_slot := v_slots -> v_current;
  if (v_current_slot ->> 'type') <> 'human' then
    return;
  end if;
  if coalesce(((v_players -> v_current) ->> 'surrendered')::boolean, false) then
    return;
  end if;

  select sec.bag, sec.racks into v_bag, v_racks
  from public.online_game_secrets sec
  where sec.online_game_id = p_game_id
  for update;

  v_bag_arr := array(select jsonb_array_elements(v_bag));
  v_current_rack_arr := array(select jsonb_array_elements(v_racks -> v_current));
  if v_current_rack_arr is not null and array_length(v_current_rack_arr, 1) > 0 then
    v_bag_arr := array(select unnest(v_bag_arr || v_current_rack_arr) order by random());
  end if;

  v_new_racks := '[]'::jsonb;
  for i in 0 .. v_player_count - 1 loop
    if i = v_current then
      v_new_racks := v_new_racks || jsonb_build_array('[]'::jsonb);
    else
      v_new_racks := v_new_racks || jsonb_build_array(v_racks -> i);
    end if;
  end loop;

  v_new_players := jsonb_set(
    v_players, array[v_current::text],
    (v_players -> v_current) || jsonb_build_object('surrendered', true, 'score', 0, 'rackCount', 0)
  );

  v_active_count := 0;
  for i in 0 .. v_player_count - 1 loop
    if not coalesce(((v_new_players -> i) ->> 'surrendered')::boolean, false) then
      v_active_count := v_active_count + 1;
    end if;
  end loop;

  -- ÖNEMLİ: teslim satırı, arşiv (games.moves) üretilmeden ÖNCE yazılmak zorunda —
  -- _finish_online_game_records arşivi online_game_moves'tan üretiyor.
  insert into public.online_game_moves (
    online_game_id, turn, player_index, player_user_id, action,
    words, word_scores, points, lost_shares, tile_count, placements,
    finish_joker_count, bingo
  ) values (
    p_game_id, v_turn_count, v_current, (v_slots -> v_current ->> 'user_id')::uuid, 'surrender',
    '[]'::jsonb, null, 0, null, 0, null, 0, false
  );

  if v_active_count <= 1 then
    for i in 0 .. v_player_count - 1 loop
      v_remaining := 0;
      for k in 0 .. jsonb_array_length(v_new_racks -> i) - 1 loop
        v_remaining := v_remaining + ((v_new_racks -> i -> k) ->> 'pts')::int;
      end loop;
      v_new_players := jsonb_set(
        v_new_players,
        array[i::text, 'score'],
        to_jsonb(greatest(0, ((v_new_players -> i) ->> 'score')::int - v_remaining))
      );
    end loop;

    perform public._finish_online_game_records(
      p_game_id, v_board, v_new_players, v_slots, v_player_count, v_turn_count
    );

    update public.online_game_secrets
      set bag = to_jsonb(v_bag_arr), racks = v_new_racks, updated_at = now()
      where online_game_id = p_game_id;

    update public.online_game_states
      set players = v_new_players,
          is_game_over = true,
          end_reason = 'surrender',
          bag_count = coalesce(array_length(v_bag_arr, 1), 0),
          turn_deadline = null,
          deadline_warning_sent_at = null,
          updated_at = now()
      where online_game_id = p_game_id;

    update public.online_games set status = 'finished', updated_at = now() where id = p_game_id;

    -- Oyun GERÇEKTEN timeout'la bittiği an teslim olmuş insan koltuklarına uyarı e-postası
    -- (notify-turn-timeout-surrender Edge Function'ı).
    perform net.http_post(
      url := 'https://xvqlizifakkkoqahaxsg.supabase.co/functions/v1/notify-turn-timeout-surrender',
      headers := '{"Content-Type": "application/json"}'::jsonb,
      body := jsonb_build_object('online_game_id', p_game_id)
    );
  else
    v_next := v_current;
    for step in 1 .. v_player_count loop
      v_next := (v_current + step) % v_player_count;
      exit when not coalesce(((v_new_players -> v_next) ->> 'surrendered')::boolean, false);
    end loop;

    update public.online_game_secrets
      set bag = to_jsonb(v_bag_arr), racks = v_new_racks, updated_at = now()
      where online_game_id = p_game_id;

    update public.online_game_states
      set players = v_new_players,
          current = v_next,
          turn_count = v_turn_count + 1,
          bag_count = coalesce(array_length(v_bag_arr, 1), 0),
          turn_deadline = now() + interval '48 hours',
          deadline_warning_sent_at = null,
          updated_at = now()
      where online_game_id = p_game_id;
  end if;
end;
$$;
