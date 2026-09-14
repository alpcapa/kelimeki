-- Kelimeki — taş değiştirmenin ÜST SINIRI: torbada kalan taş sayısı.
--
-- VAKA (14 Eylül 2026, kullanıcı raporu — Asnmzr): torbada 4 taş kalmışken
-- 7 taş değiştirilebiliyordu. `submit_move` "önce seçilenleri torbaya koy,
-- SONRA en fazla o kadar çek" sırasını uyguladığı için taş korunumu
-- bozulmuyordu (`v_draw_n := least(...)`) — arıza SESSİZDİ: torba 4'te
-- kalıyor, rafa 7 taze taş dönüyor, hata da uyarı da çıkmıyordu.
--
-- Kural artık dört kopyada da aynı (src/game/constants.ts `maxSwapCount` ·
-- Dart `constants.dart` · BURASI · play-ai-turn'ün YZ dilimi) ve cümle de
-- aynı: `swapLimitMessage`. `verify-sql-engine-parity` parçalarını kilitler.
--
-- ⚠ YZ SIRALAMASI: `play-ai-turn` bugüne kadar rafın TAMAMINI değiştirmeye
-- gönderiyordu; bu migration onu torba 7'nin altındayken REDDEDER. Edge
-- Function'ın dilimleyen sürümü BU MIGRATION'LA BİRLİKTE deploy edilmeli,
-- yoksa Canlı oyundaki YZ tıkandığı turda hata alır (play-ai-turn'ün
-- `catch`i pas geçmeye düşer — sessiz bir gerileme).
--
-- ⚠ GÖVDE ELLE YENİDEN YAZILMIYOR: 15 KB'lık fonksiyonu kopyalamak yerine
-- canlı tanım `pg_get_functiondef` ile okunup üzerine yamanıyor ve yamanın
-- TUTTUĞU iddia ediliyor (bkz. 20260905175117_submit_move_shadow_phase.sql).
do $do$
declare
  v_def text;
  v_old text;
  v_new text;
begin
  v_def := pg_get_functiondef(
    'public.submit_move(uuid,text,jsonb,jsonb,jsonb,jsonb,integer,jsonb,uuid)'::regprocedure);

  -- Çapa: raf sınırı kontrolü. Yeni kapı onun HEMEN ALTINA giriyor — böylece
  -- "rafında olmayan taş" hatası önceliğini koruyor (daha temel bir ihlal).
  v_old := E'    if v_tile_count > v_rack_size then\n'
        || E'      raise exception ''Rafta olmayan sayıda taş değiştirilmeye çalışıldı.'';\n'
        || E'    end if;';
  if position(v_old in v_def) = 0 then
    raise exception 'yama: çapa bulunamadı (exchange dalı değişmiş olabilir)';
  end if;

  v_new := v_old || E'\n'
        || E'    -- Torbada kalandan fazla taş değiştirilemez. Metin dört kopyada\n'
        || E'    -- birebir aynı: src/game/constants.ts `swapLimitMessage`.\n'
        || E'    if v_tile_count > coalesce(array_length(v_bag_arr, 1), 0) then\n'
        || E'      raise exception ''Torbada % taş var — en fazla % taş değiştirebilirsin.'',\n'
        || E'        coalesce(array_length(v_bag_arr, 1), 0),\n'
        || E'        coalesce(array_length(v_bag_arr, 1), 0);\n'
        || E'    end if;';
  v_def := replace(v_def, v_old, v_new);

  if position('en fazla % taş değiştirebilirsin.' in v_def) = 0 then
    raise exception 'yama uygulanmadı';
  end if;

  execute v_def;
end
$do$;
