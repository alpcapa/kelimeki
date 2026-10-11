// "Ben" satırının bulunması — BERABERLİK vakası (11 Ekim 2026).
//
// Canlı oyun 218-218 bitince iki oyuncunun da rank'ı 1 ve `games.players`
// koltuk sırasıyla yazılıyor. `rank - 1` herkes için 0. satırı gösterdiğinden
// 2. koltuktaki oyuncu geçmişinde rakibinin adı yerine kendi adını iki kez
// görüyordu (web `GameHistoryModal.findMeIndex` ile aynı düzeltme).
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/game_record.dart';
import 'package:kelimeki/src/data/games_api.dart';
import 'package:kelimeki/src/ui/score/game_history_modal.dart';

GamePlayerSnapshot p(String name, int score, {bool ai = false, int? seat}) =>
    GamePlayerSnapshot(
        name: name,
        score: score,
        isAi: ai,
        surrendered: false,
        colorIndex: seat);

GameHistoryEntry entry(
        {required int playerScore,
        required int aiScore,
        required int? rank,
        required List<GamePlayerSnapshot> players}) =>
    GameHistoryEntry(
      id: 'g',
      userId: 'u',
      createdAt: '2026-10-10T11:42:30Z',
      playerCount: players.length,
      playerScore: playerScore,
      aiScore: aiScore,
      rank: rank,
      surrendered: false,
      onlineGameId: 'o',
      players: players,
    );

void main() {
  test('berabere: 2. koltuktaki oyuncu KENDİ satırını bulur', () {
    final players = [p('Asnmzr', 218, seat: 0), p('Ironman', 218, seat: 1)];
    final e = entry(playerScore: 218, aiScore: 218, rank: 1, players: players);
    expect(findMeIndexForTest(e, players, 'Ironman'), 1);
    expect(findMeIndexForTest(e, players, 'Asnmzr'), 0);
    // Büyük/küçük harf (Türkçe) farkı eşleşmeyi bozmaz.
    expect(findMeIndexForTest(e, players, 'IRONMAN'), 1);
  });

  test('berabere + ad sonradan değişmiş: eski davranışa düşer (çökmez)', () {
    final players = [p('Asnmzr', 218), p('Ironman', 218)];
    final e = entry(playerScore: 218, aiScore: 218, rank: 1, players: players);
    expect(findMeIndexForTest(e, players, 'YeniAd'), 0);
    expect(findMeIndexForTest(e, players, null), 0);
  });

  test('beraberlik yok: rank hâlâ belirleyici', () {
    final players = [p('A', 200), p('B', 100)];
    final e = entry(playerScore: 100, aiScore: 200, rank: 2, players: players);
    expect(findMeIndexForTest(e, players, 'B'), 1);
    expect(findMeIndexForTest(e, players, null), 1);
  });

  test('4 kişi, ilk ikisi berabere: ikinci beraberlik sahibi doğru bulunur',
      () {
    final players = [
      p('Hasan', 135),
      p('Gynn', 135),
      p('Yapay Zeka 4', 68, ai: true),
      p('Asnmzr', 65),
    ];
    final e = entry(playerScore: 135, aiScore: 135, rank: 1, players: players);
    expect(findMeIndexForTest(e, players, 'Gynn'), 1);
    expect(findMeIndexForTest(e, players, 'Hasan'), 0);
  });
}
