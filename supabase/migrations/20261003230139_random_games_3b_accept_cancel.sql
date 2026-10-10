-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ── 5. accept_random_game ─────────────────────────────────────────────────
-- Şeritteki "Kabul". `for update` kilidi: iki eşzamanlı kabulde ikincisi
-- birincinin işlemi bitene dek bekler, sonra güncel satırı görür; son koltuk
-- gittiyse "Bu oyun doldu." alır.
-- Dönüş: {"joined": true, "game_id": uuid, "seat": int, "started": bool}

create or replace function public.accept_random_game(p_game_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  perform public._random_preflight(v_uid);

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.status = 'active' or v_game.status = 'finished' then
    raise exception 'Bu oyun doldu.';
  end if;
  if v_game.status <> 'pending' or now() - v_game.created_at > interval '7 days' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;
  if v_game.created_by = v_uid then
    raise exception 'Kendi ilanını kabul edemezsin.';
  end if;
  if public._random_is_party(p_game_id, v_game.slots, v_uid) then
    raise exception 'Bu oyuna zaten katıldın.';
  end if;
  if public._random_blocked(v_uid, v_game.slots) then
    raise exception 'Bu ilana katılamazsın.';
  end if;
  if public._slots_open_count(v_game.slots) = 0 then
    raise exception 'Bu oyun doldu.';
  end if;

  return public._random_take_seat(p_game_id, v_uid) || jsonb_build_object('joined', true);
end;
$$;

-- ── 7. cancel_random_game ─────────────────────────────────────────────────
-- Kurucu bekleyen ilanını iptal eder → 'abandoned' (check_invite_expiry ve
-- ret dalıyla AYNI son durum; davet satırları kayıt olarak kalır).

create or replace function public.cancel_random_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.created_by is distinct from v_uid then
    raise exception 'Yalnızca ilanı açan iptal edebilir.';
  end if;
  if v_game.status = 'active' then
    raise exception 'Oyun başladı; ilan iptal edilemez.';
  end if;
  if v_game.status <> 'pending' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;

  update public.online_games
     set status = 'abandoned', updated_at = now()
   where id = p_game_id and status = 'pending';
end;
$$;

revoke all on function public.accept_random_game(uuid) from public, anon;
revoke all on function public.cancel_random_game(uuid) from public, anon;
grant execute on function public.accept_random_game(uuid) to authenticated;
grant execute on function public.cancel_random_game(uuid) to authenticated;
