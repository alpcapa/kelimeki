-- Rastgele Oyuncu (ROADMAP #45) — tasarım: docs/decisions/random-opponent.md
-- 3 Ekim 2026: Supabase aracı tek parça migration'da 60 sn zaman aşımına uğradığı ve
-- `delete from` içeren gövdeyi onay beklerken kestiği için PARÇALARA bölündü.

-- ⚠ CANLIYA UYGULANMADI: içinde `delete from` var, Supabase aracı onay beklerken zaman aşımına
-- uğruyor → SQL Editor'a elle yapıştırılır. Uygulanınca `list_migrations`'taki gerçek versiyonla
-- dosyayı yeniden adlandır ve `_PENDING`i at.
-- ── 6. leave_random_game ──────────────────────────────────────────────────
-- Rastgele koltukla kabul eden, oyun dolmadan ayrılır: koltuk yeniden open,
-- davet satırı SİLİNİR (yoksa is_online_game_participant onu katılımcı sayar),
-- ceza yok. Kurucu ayrılamaz (cancel_random_game); arkadaş davetlisi
-- ayrılamaz (onun koltuğu kurucunun seçimi; bugünkü ret yolu geçerli).

create or replace function public.leave_random_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game record;
  v_idx int;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select * into v_game from public.online_games where id = p_game_id for update;
  if not found or v_game.listing is distinct from 'random' then
    raise exception 'İlan bulunamadı.';
  end if;
  if v_game.created_by = v_uid then
    raise exception 'İlanı açan ayrılamaz; ilanı iptal edebilirsin.';
  end if;
  if v_game.status = 'active' then
    raise exception 'Oyun başladı; artık ayrılamazsın.';
  end if;
  if v_game.status <> 'pending' then
    raise exception 'Bu ilan artık geçerli değil.';
  end if;

  select (e.ord - 1)::int into v_idx
  from jsonb_array_elements(v_game.slots) with ordinality as e(slot, ord)
  where e.slot ->> 'user_id' = v_uid::text
    and e.slot ->> 'via' = 'random'
  limit 1;

  if v_idx is null then
    raise exception 'Bu ilandan ayrılamazsın.';
  end if;

  perform set_config('kelimeki.random_rpc', 'on', true);
  update public.online_games
     set slots = jsonb_set(slots, array[v_idx::text], jsonb_build_object('type', 'open')),
         updated_at = now()
   where id = p_game_id;
  perform set_config('kelimeki.random_rpc', '', true);

  delete from public.game_invites
   where online_game_id = p_game_id and invitee_id = v_uid;
end;
$$;

revoke all on function public.leave_random_game(uuid) from public, anon;
grant execute on function public.leave_random_game(uuid) to authenticated;
