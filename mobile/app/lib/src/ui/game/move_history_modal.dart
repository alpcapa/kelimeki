// Oyundaki tüm oyuncuların hamle/puan geçmişi —
// src/components/MoveHistoryModal.tsx portu. Veri tamamen
// `GameState.moveHistory`'den gelir (motorla birlikte portlandı, golden
// vector'larla doğrulandı) — yeni bir asset/ağ çağrısı yok.
import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import 'modal_shell.dart';
import '../tokens.dart';

const Color _text = kText;
const Color _muted = kMuted;
const Color _accent = kAccent;
const Color _green = kGreen;
const Color _red = kRed;
const Color _gold = kGold;
const Color _border = kBorder;

/// [myIndex]: pencereyi açanın koltuğu — iki vergi kutusu ONUN rakamları;
/// bilinmiyorsa (`-1`) vergi kutuları çizilmez.
Future<void> showMoveHistoryModal(BuildContext context, GameState state,
    {int myIndex = -1}) {
  return showDialog<void>(
    context: context,
    builder: (context) => MoveHistoryModal(state: state, myIndex: myIndex),
  );
}

/// Pencereyi açanın kutusu: adı, skor tablosundaki puanı ve kaptırdığı /
/// topladığı vergi.
typedef MyHistoryStats = ({
  String name,
  int score,
  int taxPaid,
  int taxCollected,
});

/// Üstteki kutuların sayıları — web `moveHistoryStats`
/// (`MoveHistoryModal.tsx`) ile BİREBİR (28 Eylül 2026, kullanıcı isteği):
/// TOPLAM · (adın) · VERGİ (−) · VERGİ (+). Önceki "Bu oyunda kazanılan N
/// hamle… Toplam X puan" satırının yerine geldi: N yalnızca puanlı
/// hamleleri sayarken liste numarası (`turn + 1`) pas turlarını da
/// saydığından "44 hamle" yazıp 45. hamleyi listeliyordu — hamle sayısı bu
/// yüzden kutulardan da çıktı. Vergiler kişisel, çünkü oyun genelinde
/// ödenen = toplanan olurdu. Koltuk bilinmiyorsa `me` `null`.
typedef MoveHistoryStats = ({int total, MyHistoryStats? me});

MoveHistoryStats moveHistoryStats(GameState state, int myIndex) {
  var total = 0, taxPaid = 0, taxCollected = 0;
  for (final e in state.moveHistory) {
    total += e.points;
    if (e.player != myIndex) continue;
    if (e.invasionFrom != null) {
      taxCollected += e.points;
    } else {
      for (final s in e.lostShares ?? const <LostShare>[]) {
        taxPaid += s.amount;
      }
    }
  }
  final known = myIndex >= 0 && myIndex < state.players.length;
  if (!known) return (total: total, me: null);
  final p = state.players[myIndex];
  return (
    total: total,
    me: (
      name: p.name,
      score: p.score,
      taxPaid: taxPaid,
      taxCollected: taxCollected,
    ),
  );
}

class MoveHistoryModal extends StatelessWidget {
  final GameState state;
  final int myIndex;
  const MoveHistoryModal({super.key, required this.state, this.myIndex = -1});

  @override
  Widget build(BuildContext context) {
    final entries = state.moveHistory;
    final stats = moveHistoryStats(state, myIndex);
    final me = stats.me;
    // Vergi geliri satırları ayrı kart olarak gösterilmez (web'deki aynı
    // gerekçe: aynı hamle zaten oynayanın satırında anlatılıyor).
    final display = [
      for (final e in entries)
        if (e.invasionFrom == null) e
    ];

    Widget gap() => const SizedBox(width: 6);
    return KModal(
      title: 'Oyun Geçmişi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _StatBox(label: 'TOPLAM', value: '${stats.total}'),
              if (me != null) ...[
                gap(),
                // Web'de CSS `uppercase` (lang=tr); burada Türkçe kural.
                _StatBox(label: trUpper(me.name), value: '${me.score}'),
                gap(),
                _StatBox(
                  label: 'VERGİ (−)',
                  value: me.taxPaid > 0 ? '−${me.taxPaid}' : '0',
                  color: me.taxPaid > 0 ? _red : _text,
                ),
                gap(),
                _StatBox(
                  label: 'VERGİ (+)',
                  value: me.taxCollected > 0 ? '+${me.taxCollected}' : '0',
                  color: me.taxCollected > 0 ? _green : _text,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (display.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Henüz kazanılmış bir puan yok.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  color: _muted,
                ),
              ),
            )
          else
            // Web: max-h-72 overflow-y-auto — kabuğun kendi kaydırması zaten
            // var, burada yalnızca yükseklik sınırı korunur (en yeni üstte).
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 288),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = display.length - 1; i >= 0; i--) ...[
                      if (i < display.length - 1) const SizedBox(height: 6),
                      _EntryCard(entry: display[i], state: state),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Web `StatBox`: 8px büyük harf etiket + 15px kalın değer, satır kartıyla
/// aynı zemin/çerçeve.
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, this.color = _text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Oyuncu adı uzun olabilir — web `truncate` gibi üç nokta.
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 8,
                letterSpacing: 0.5,
                color: _muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final HistoryEntry entry;
  final GameState state;
  const _EntryCard({required this.entry, required this.state});

  String? get _plainLabel {
    switch (entry.action) {
      case 'pass':
        return 'Pas geçti';
      case 'exchange':
        return '${entry.tileCount} taş değiştirdi';
      case 'surrender':
        return 'Teslim oldu';
    }
    final ws = entry.wordScores;
    if (ws != null && ws.isNotEmpty) return null; // kelime rozetleriyle çizilir
    return entry.words.isNotEmpty ? entry.words.join(', ') : '—';
  }

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final playerName =
        e.player < state.players.length ? state.players[e.player].name : '?';
    final lost = e.lostShares ?? const <LostShare>[];
    final isInvasionLoss = lost.isNotEmpty;
    final jokerCount = e.finishJokerCount ?? 0;
    final label = _plainLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, // web bg-bg
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${e.turn + 1}. $playerName',
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (label != null)
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 12,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: _text,
                        ),
                      )
                    else
                      _WordScoreLine(scores: e.wordScores!),
                  ],
                ),
              ),
              if (e.action == null) ...[
                if (e.bingo) ...[
                  const _Badge(
                      label: 'Bingo', color: _gold), // +BINGO_BONUS rozeti
                  const SizedBox(width: 4),
                ],
                if (jokerCount > 0) ...[
                  // Yıldız glyph'i Space Mono'da yok (web'de tarayıcı yedek
                  // fontundan basar) — taş jokerindeki aynı çözüm: Material
                  // ikonu (bkz. tile_widget.dart).
                  _Badge(
                    color: _accent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < (jokerCount >= 2 ? 2 : 1); i++)
                          const Icon(Icons.star, size: 9, color: _accent),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (isInvasionLoss) ...[
                  const _Badge(label: 'Sınır İhlali', color: _red),
                  const SizedBox(width: 4),
                ],
                Text(
                  '+${e.points}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _green,
                  ),
                ),
              ],
            ],
          ),
          if (isInvasionLoss)
            _note(
              lost
                  .map((s) =>
                      '${s.amount} puanı ${s.to < state.players.length ? state.players[s.to].name : '?'} kaptı')
                  .join(', '),
              _red,
            ),
          if (jokerCount > 0)
            _note(
              '${jokerCount >= 2 ? 'Çift' : 'Tek'} yıldız ile biterek '
              '+${jokerFinishBonus(jokerCount)} puan kazandı.',
              _accent,
            ),
          if (e.bingo)
            _note(
              '7 harfi birden koyup +$bingoBonus puan Bingo Bonus kazandı.',
              _gold,
            ),
        ],
      ),
    );
  }

  Widget _note(String text, Color color) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 9,
            height: 1.3,
            color: color,
          ),
        ),
      );
}

/// Kelime kelime "SÖZCÜK (puan ×2)" satırı — puan çarpansız (ham) toplam,
/// rozet çarpanı gösterir (web'deki aynı ayrım).
class _WordScoreLine extends StatelessWidget {
  final List<WordScore> scores;
  const _WordScoreLine({required this.scores});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'SpaceMono',
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.bold,
      color: _text,
    );
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < scores.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${scores[i].word} (${scores[i].score}', style: style),
              if (scores[i].x3)
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: _MultiplierBadge(tier: 3),
                )
              else if (scores[i].x2)
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: _MultiplierBadge(tier: 2),
                ),
              Text(i < scores.length - 1 ? '),' : ')', style: style),
            ],
          ),
      ],
    );
  }
}

/// Web'deki küçük renkli rozet (Bingo / ★ / Sınır İhlali) — 8px mono,
/// rengin %10 zemini ve %40 çerçevesi.
class _Badge extends StatelessWidget {
  /// Metin rozeti (Bingo / Sınır İhlali) — `child` verilmişse yok sayılır.
  final String? label;
  final Widget? child;
  final Color color;
  const _Badge({this.label, this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child ??
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              height: 1.2,
              color: color,
            ),
          ),
    );
  }
}

/// ×2 / ×3 kelime çarpanı rozeti — tahtadaki bonus bölgesiyle aynı gradyan.
class _MultiplierBadge extends StatelessWidget {
  final int tier;
  const _MultiplierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      height: 12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tier == 3
              ? const [Color(0xFFFDBA74), Color(0xFFF97316)]
              : const [Color(0xFFFDE68A), Color(0xFFFBBF24)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '×$tier',
        style: const TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1,
          color: Color(0xFF7C2D12),
        ),
      ),
    );
  }
}
