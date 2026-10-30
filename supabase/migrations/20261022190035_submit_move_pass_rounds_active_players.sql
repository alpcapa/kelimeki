-- submit_move: "üst üste pas ile oyun biter" eşiği yalnızca TESLİM OLMAMIŞ oyuncuları saymalı
-- (22 Ekim 2026). Web motoru (`gameReducer.ts` → `activePlayerCount(players) * MAX_PASS_ROUNDS`)
-- böyle yapıyor; sunucu `v_player_count * v_max_pass_rounds` ile TÜM koltukları sayıyordu, yani
-- teslimli bir oyunda pas yoluyla bitiş geç geliyordu (4 kişilik, 1 teslim: web 6 pasta, sunucu 8'de).
-- Önceki migration (submit_move_skip_surrendered) ile aynı yöntem: canlı gövdeyi okuyup tek ifadeyi
-- değiştirir; eşleşme yoksa HATA. create or replace → proacl DEĞİŞMEZ.
do $mig$
declare
  v_def text;
  v_old constant text := 'v_consecutive_passes >= v_player_count * v_max_pass_rounds';
  v_new constant text := 'v_consecutive_passes >= (select count(*) from jsonb_array_elements(v_new_players) e where not coalesce((e ->> ''surrendered'')::boolean, false)) * v_max_pass_rounds';
begin
  select pg_get_functiondef(p.oid) into v_def
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = 'submit_move';

  if v_def is null then
    raise exception 'submit_move bulunamadı.';
  end if;
  if position(v_new in v_def) > 0 then
    return; -- zaten uygulanmış
  end if;
  if position(v_old in v_def) = 0 then
    raise exception 'submit_move: değiştirilecek ifade bulunamadı (gövde değişmiş olabilir).';
  end if;

  execute replace(v_def, v_old, v_new);
end
$mig$;
