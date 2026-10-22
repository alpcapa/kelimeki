-- submit_move: sıra, TESLİM OLMUŞ oyuncuyu ATLAMALI (22 Ekim 2026, saha raporu).
--
-- Vaka: 4 kişilik Canlı oyun 4d4c07cc. 2. oyuncu süre aşımıyla teslim oldu (check_turn_timeout:
-- teslim + sırayı bir SONRAKİ AKTİF oyuncuya geçirme, doğru). Sonraki üç oyuncu normal oynadı;
-- ama submit_move sırayı `(v_current + 1) % v_player_count` ile ilerletiyordu — teslim bayrağına
-- hiç bakmadan. 0. oyuncunun hamlesi sırayı teslim olmuşa verdi ve oyun KİLİTLENDİ:
-- insan hamle yapamıyor ("Sıra sende değil"), check_turn_timeout da sıradaki teslim olmuşsa
-- erken dönüyor (`surrendered` kontrolü), yani süre dolsa da kimse sırayı ilerletmiyor.
-- check_turn_timeout'un kendi dalı (`v_next` döngüsü) zaten doğruydu; eksik olan yalnız buydu.
--
-- Düzeltme: submit_move'un canlı gövdesinde tek satır değişir. Gövdeyi yeniden yazmak yerine
-- mevcut tanımı okuyup o satırı değiştiriyoruz — migration'lar sıfırdan oynatıldığında da en
-- son tanımın üstüne biner. Eşleşme yoksa HATA verir (sessizce hiçbir şey yapmaz).
-- create or replace aynı imzayı korur → proacl (postgres/service_role/authenticated) DEĞİŞMEZ.
do $mig$
declare
  v_def text;
  v_old constant text := E'  v_next := (v_current + 1) % v_player_count;\n';
  v_new constant text := E'  -- Teslim olmuş oyuncu ATLANIR (check_turn_timeout ile aynı kural). Oyun bittiyse v_next anlamsız.\n'
    || E'  v_next := v_current;\n'
    || E'  for step in 1 .. v_player_count loop\n'
    || E'    v_next := (v_current + step) % v_player_count;\n'
    || E'    exit when not coalesce(((v_new_players -> v_next) ->> ''surrendered'')::boolean, false);\n'
    || E'  end loop;\n';
begin
  select pg_get_functiondef(p.oid) into v_def
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = 'submit_move';

  if v_def is null or position(v_old in v_def) = 0 then
    raise exception 'submit_move: değiştirilecek satır bulunamadı (gövde değişmiş olabilir).';
  end if;
  if position('step in 1 .. v_player_count' in v_def) > 0 then
    return; -- zaten uygulanmış
  end if;

  execute replace(v_def, v_old, v_new);
end
$mig$;
