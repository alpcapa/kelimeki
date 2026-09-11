// Mağaza ekran görüntüsü üreticisi — App Store FAZ C 24.5.
//
// Kurulumun TAMAMI `store_frames.dart`'ta (fixture'lar, sahte uçlar, başlık
// şeridi, ekran kurucuları). Aynı kareleri Linux'ta çizen ÖNİZLEME testi de
// (`test/store_frames_preview_test.dart`) oradan besleniyor — iki yol
// sessizce ayrışamıyor.
//
// NASIL KOŞAR: `flutter drive` ile, `test_driver/integration_test.dart`
// sürücüsüne karşı. Komut CI'da: `.github/workflows/ios-screenshots.yml`.
//
// ⚠ FIXTURE DEPOYA GİRMEZ. Tahta, gerçek motorla ve tohumlu rastgelelikle
// KOŞMA ANINDA üretiliyor.
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kelimeki/src/data/dictionary_loader.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:kelimeki/src/ui/game/help_modal.dart';
import 'package:kelimeki/src/ui/game/board_widget.dart';
import 'package:kelimeki/src/ui/rank/league_rank.dart';
import 'package:kelimeki/src/ui/rank/rank_info_modal.dart';
import 'package:kelimeki/src/ui/score/leaderboard_modal.dart';
import 'package:kelimeki/src/ui/score/score_card_modal.dart';

import 'store_frames.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Cihazda sözlük asset'ten okunur — testlerdeki `File(...)` yolu burada
    // ÇALIŞMAZ, uygulama paketinin içindeyiz.
    words = await loadDictionary(rootBundle);
  });

  testWidgets('01 — oyun ekranı, oyunun ortası (2 kişilik)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '01-oyun-ekrani'));
    await settle(tester);

    await kareCek(binding, tester, '01-oyun-ekrani');
    controller.dispose();
  });

  // 2. kare 11 Eylül 2026'da KONU DEĞİŞTİRDİ: öncesinde 1. karenin neredeyse
  // aynısıydı. Kullanıcı: *"4 kişilik oyun bize özel ve başka hiçbir kelime
  // oyununda yok"*. Artık dört skor kutusu + tahtada dört bölge.
  testWidgets('02 — dört kişilik oyun (dört bölge + kurulmuş hamle)',
      (tester) async {
    final controller = oyunKontrolcusu(oyuncu: 4);
    stageBestMove(controller);
    await tester.pumpWidget(oyunEkrani(controller, '02-dort-kisilik'));
    await settle(tester);

    await kareCek(binding, tester, '02-dort-kisilik');
    controller.dispose();
  });

  testWidgets('03 — kurulum ekranı, "Arkadaşınla" sekmesi', (tester) async {
    await tester.pumpWidget(kurulumEkrani('03-arkadasinla'));
    await settle(tester);
    // Ekran "Yapay Zeka ile" sekmesiyle açılıyor; kare Canlı oyunu
    // anlatacak, o yüzden sekme DEĞİŞTİRİLİYOR (gerçek dokunuşla).
    await tester.tap(find.text('ARKADAŞINLA'));
    await settle(tester);

    await kareCek(binding, tester, '03-arkadasinla');
  });

  // ── Modal kareleri ────────────────────────────────────────────────────
  //
  // ⚠ DÖRDÜ DE OYUN EKRANININ ÜSTÜNDE AÇILIYOR (kullanıcı kararı, 11 Eylül
  // 2026): *"Tüm modal ekranları (skor kart, k-lig tablosu, vb) normal ekran
  // görüntüsünde olmalı. Yani arka planda oyun açıkken mesela. Böyle sadece
  // onları koymak çok iyi ve anlamlı değil."*
  //
  // Öncesinde 04/06/07 boş bir `Scaffold` üzerinde çiziliyordu — pencere
  // havada duruyordu, hangi uygulamaya ait olduğu görünmüyordu ve karenin
  // üst/alt yarısı bomboştu. Yalnızca 05 zaten doğru yapıyordu; şimdi dördü
  // de AYNI deseni izliyor.
  //
  // ⚠ Pencereler ÜRETİM yolundan açılıyor (`showScoreCard` vb.), elle
  // `Scaffold`a gömülerek değil — kare böylece uygulamanın gerçek
  // davranışını gösteriyor (karartma, kenar boşluğu, kapatma düğmesi dahil).

  testWidgets('04 — skor kartı (oyun ekranının üstünde)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '04-skor-karti'));
    await settle(tester);

    unawaited(showScoreCard(
      navKey.currentContext!,
      auth: screenshotAuth(),
      stats: StatsRepo(SahteStatsGateway()),
    ));
    await pencereyiBekle(tester, find.byType(ScoreCardModal), '04-skor-karti');

    await kareCek(binding, tester, '04-skor-karti');
    controller.dispose();
  });

  // ⚠ 11 Eylül 2026: bu kare iPad koşusunda pencere AÇILMADAN çekildi ve
  // 01'in aynısı oldu (iPhone'da sorunsuzdu). Sabit sayıda `pump` cihazdan
  // cihaza güvenilir değil — dördü de artık `pencereyiBekle` ile pencere
  // GÖRÜNENE KADAR bekliyor ve göremezse koşu DÜŞÜYOR.
  testWidgets('06 — nasıl oynanır (oyun ekranının üstünde)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '06-nasil-oynanir'));
    await settle(tester);

    unawaited(showHelpModal(navKey.currentContext!));
    await pencereyiBekle(tester, find.byType(HelpModal), '06-nasil-oynanir');

    await kareCek(binding, tester, '06-nasil-oynanir');
    controller.dispose();
  });

  // 7. kare çekim listesinde "opsiyonel" işaretliydi; 11 Eylül 2026'da
  // eklendi — k-lig oyunun ayırt edici tarafı ve öteki karelerde yarışmanın
  // kendisi hiç görünmüyor.
  testWidgets('07 — k-lig sıralaması (oyun ekranının üstünde)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '07-klig-siralamasi'));
    await settle(tester);

    unawaited(showLeaderboard(
      navKey.currentContext!,
      auth: screenshotAuth(),
      stats: StatsRepo(SahteStatsGateway()),
    ));
    await pencereyiBekle(
        tester, find.byType(LeaderboardModal), '07-klig-siralamasi');

    await kareCek(binding, tester, '07-klig-siralamasi');
    controller.dispose();
  });

  // 8. kare (11 Eylül 2026, kullanıcı: *"rütbelerden hiç bahsetmiyoruz"*).
  // 07 SIRALAMAYI gösteriyor, bu ÖDÜL MERDİVENİNİ — ikisi farklı vaat.
  //
  // ⚠ Sayılar 04 ve 07 ile TUTARLI: 57 puan → `Meraklı` (eşik 50), bir
  // sonraki `Oyuncu` 100'de, yani ilerleme çubuğu yarı dolu görünüyor —
  // "yükselecek yer var" mesajı karenin kendisinden çıkıyor. `bonusPoints`
  // 5 = Meraklı'nın ödülü, yani kazanılmış tek eşik ödülü.
  //
  // ⚠ 05 numarası KULLANILMADI (kelime anlamı karesinin geçmişine bağlı).
  testWidgets('08 — rütbeler (oyun ekranının üstünde)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '08-rutbeler'));
    await settle(tester);

    unawaited(showRankInfo(
      navKey.currentContext!,
      tier: tierFor(57),
      totalScore: 57,
      bonusPoints: 5,
    ));
    await pencereyiBekle(tester, find.byType(RankInfoModal), '08-rutbeler');

    await kareCek(binding, tester, '08-rutbeler');
    controller.dispose();
  });

  // 9. kare (11 Eylül 2026, kullanıcı: *"10 kare hakkımız varsa zoom'u da
  // koysaydık keşke"*). İlk turda elenmişti — zoom bir JEST ve tek kare
  // hareketi gösteremez. Çözüm jesti ANLATMAK değil SONUCUNU göstermek:
  // kare, gerçek çift dokunuşla 2× büyümüş tahtayı gösteriyor; harfler
  // iri ve okunaklı olduğundan 01 ile karışmıyor.
  //
  // ⚠ Bu karenin kapısı `pencereyiBekle` DEĞİL (aranacak pencere yok) —
  // `zoomKapisi` zoom matrisinin ölçeğini okuyor. Jest tutmazsa kare
  // sessizce 01'in kopyası olurdu; iPad'de 06'nın başına gelen şeyin
  // aynısı.
  testWidgets('09 — zoom (çift dokunuşla büyümüş tahta)', (tester) async {
    final controller = oyunKontrolcusu();
    await tester.pumpWidget(oyunEkrani(controller, '09-zoom'));
    await settle(tester);
    final tahta = tester.getRect(find.byType(BoardWidget));
    // ⚠ Nişan noktası bir hücrenin İÇİ DEĞİL, iki hücre ARASINDAKİ ızgara
    // sınırı (kBoardPad + k*adım). Sebep ölçüldü: hücre kutusuna inen
    // dokunuş, harf seçili olmadığı için ekrana *"Önce bir harf seç."*
    // yazdırıyor ve mağaza karesinde gerçek oyun mesajının ("Yapay Zeka
    // …oynadı") yerini alıyordu. Boşluğa/çerçeveye inen dokunuş ise
    // `_pointHitsCellBox` false döndüğünden hücre işleyicisine hiç
    // gitmiyor — çift yine sayılıyor (game_screen.dart: "boşluğa/çerçeveye
    // inen TAHTA dokunuşudur").
    final ic = tahta.width - 2 * kBoardPad;
    final adim = ic / 13;
    final nokta = Offset(
      tahta.left + kBoardPad + 5 * adim,
      tahta.top + kBoardPad + 8 * adim,
    );
    await tester.tapAt(nokta);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(nokta);
    await settle(tester);
    zoomKapisi(tester, '09-zoom');

    await kareCek(binding, tester, '09-zoom');
    controller.dispose();
  });
}
