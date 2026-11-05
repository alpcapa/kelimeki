// Kelimeki core — Canlı oyunda TASLAK (deneme taşları) kararı.
//
// Web `src/utils/liveDraft.ts`'in SAF kısmının birebir portu (5 Kasım 2026).
// KURAL: taslak YALNIZCA (1) bir hücresine bir taş oturduysa ya da (2) taşları
// sunucudaki rafımda bulunamıyorsa atılır; GEÇERSİZ olması ya da puanının/
// vergisinin değişmesi atma sebebi DEĞİL (mesaj satırı canlı türetilir; sözlük
// tembel yüklendiğinden "geçerli mi" kararı güvenilmez).
import '../model/game_state.dart';
import '../model/tile.dart';
import '../rules/board.dart';

/// Taşın raftan düşen harf imzası — `_subtractPlacedFromRack` ile aynı anahtar.
String _tileKey(Tile t) => '${t.wild ? '?' : t.letter}:${t.pts}';

/// Taslaktaki hücrelerden şu an tahtada DOLU olanlar ("r,c" anahtarları).
List<String> draftConflicts(Placed placed, Board board) {
  final out = <String>[];
  for (final k in placed.keys) {
    final (r, c) = parseKey(k);
    final inBounds = r >= 0 && r < board.length && c >= 0 && c < board[r].length;
    if (inBounds && board[r][c] != null) out.add(k);
  }
  return out;
}

/// Taslaktaki her taş için raftan (çoklu küme olarak) bir karşılık var mı?
bool rackCoversDraft(List<Tile> rack, Placed placed) {
  final counts = <String, int>{};
  for (final t in rack) {
    counts[_tileKey(t)] = (counts[_tileKey(t)] ?? 0) + 1;
  }
  for (final t in placed.values) {
    final k = _tileKey(t);
    final n = counts[k] ?? 0;
    if (n <= 0) return false;
    counts[k] = n - 1;
  }
  return true;
}

/// Taslak (şu anki tahta + sunucudaki HAM raf'a karşı) korunmalı mı? Boş → true.
bool shouldKeepDraft(Placed placed, Board board, List<Tile> rack) {
  if (placed.isEmpty) return true;
  return draftConflicts(placed, board).isEmpty && rackCoversDraft(rack, placed);
}

/// Taslak ATILDIYSA kullanıcıya "neden" söylenmeli mi? Yalnızca bir HÜCREYE
/// RAKİBİN taşı oturduysa (`owner != mySlot`). Kendi hamlemin ardından ya da
/// raf uyuşmazlığında (başka cihaz) sessiz kalınır.
bool discardedByOpponent(Placed placed, Board board, int mySlot) {
  for (final k in draftConflicts(placed, board)) {
    final (r, c) = parseKey(k);
    final t = board[r][c];
    if (t != null && t.owner != mySlot) return true;
  }
  return false;
}
