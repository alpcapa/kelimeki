-- Oyun sonunda RAFTA KALAN joker puandan 10 düşer (24 Kasım 2026, kullanıcı kararı).
-- Eskiden joker 0 puandı → rafta bekletmek bedavaydı. Yeni kural: elde kalan joker "en değerli
-- harf" (J = 10) sayılır. TS: src/game/constants.ts → JOKER_END_PENALTY / rackEndTotal;
-- Dart: kelimeki_core constants.dart → jokerEndPenalty / rackEndTotal. J'nin puanı SABİT
-- (kullanıcı: "hiçbir zaman değişmeyecek"), bu yüzden 10 gömülü.
--
-- Oyun sonu raf düşümü canlıda İKİ fonksiyonda (doğrulandı, 24 Kasım 2026): submit_move ve
-- check_turn_timeout. Yöntem önceki migration'larla aynı: canlı gövdeyi okuyup tek ifadeyi
-- değiştirir; eşleşme yoksa HATA. create or replace → proacl DEĞİŞMEZ.
-- Rafta joker `wild` bayrağı olmadan yalnızca letter = '?' taşıyabilir → ikisi de tanınır.
do $mig$
declare
  r record;
  v_old constant text := $q$v_remaining := v_remaining + ((v_new_racks -> i -> k) ->> 'pts')::int;$q$;
  v_new constant text := $q$v_remaining := v_remaining + case when ((v_new_racks -> i -> k) ->> 'letter') = '?' or coalesce(((v_new_racks -> i -> k) ->> 'wild')::boolean, false) then 10 else ((v_new_racks -> i -> k) ->> 'pts')::int end;$q$;
  v_def text;
  v_fn text;
begin
  foreach v_fn in array array['submit_move', 'check_turn_timeout'] loop
    for r in
      select p.oid
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = v_fn and p.prokind = 'f'
    loop
      v_def := pg_get_functiondef(r.oid);
      if position(v_new in v_def) > 0 then
        continue; -- zaten uygulanmış
      end if;
      if position(v_old in v_def) = 0 then
        raise exception '%: değiştirilecek ifade bulunamadı (gövde değişmiş olabilir).', v_fn;
      end if;
      execute replace(v_def, v_old, v_new);
    end loop;
  end loop;
end
$mig$;
