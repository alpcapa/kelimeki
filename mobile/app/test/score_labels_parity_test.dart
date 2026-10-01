// Skor kartı sekme etiketleri ve "kişilik" metinleri ↔ web kaynağı.
//
// 1 Ekim 2026, 1.1.2 cihaz turu (kullanıcı): uygulama "2 OYUNCULU /
// 4 OYUNCULU" yazıyordu, web 27 Eylül'den beri "2 Kişi / 4 Kişi". Bu
// etiketleri web'le karşılaştıran bir kapı YOKTU, ayrışma sessiz kaldı.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/stats_api.dart';

import 'support/web_source.dart';

void main() {
  test('sekme etiketleri web SCORE_TABS ile BİREBİR', () {
    final web = readRepoFile('src/components/ScoreStatsSection.tsx');
    final labels = pickAll(web, RegExp(r"\{ key: [^,]+, label: '([^']+)' \}"),
        'SCORE_TABS etiketleri');
    expect(labels, StatsTab.values.map((t) => t.label).toList());
  });

  test('"kişilik" boş liste metinleri ve Tüm Oyunlar başlığı webde de aynı',
      () {
    expect(readRepoFile('src/components/ScoreCard.tsx'),
        contains(r'Henüz ${tab} kişilik oyun kaydın yok.'));
    expect(readRepoFile('src/components/PlayerScoreCard.tsx'),
        contains(r'Bu oyuncunun ${tab} kişilik oyun kaydı yok.'));
    expect(readRepoFile('src/components/GameHistoryModal.tsx'),
        contains(r'`Tüm Oyunlar · ${playerCount} Kişi`'));

    final port = [
      'lib/src/ui/score/score_card_modal.dart',
      'lib/src/ui/score/player_score_card_modal.dart',
      'lib/src/ui/score/game_history_modal.dart',
      'lib/src/data/stats_api.dart',
    ].map((p) => readRepoFile('mobile/app/$p')).join('\n');
    expect(port, isNot(contains('oyunculu oyun')));
    expect(port, isNot(contains("'2 Oyunculu'")));
    expect(port, contains(r'kişilik oyun kaydın yok.'));
    expect(port, contains(r'kişilik oyun kaydı yok.'));
    expect(port, contains(r"'Tüm Oyunlar · ${widget.playerCount} Kişi'"));
  });
}
