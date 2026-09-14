// Taş değiştirme SINIRI — web ↔ port ELLE SENKRON, web KANONİK kaynaktır
// (`ai_level_parity_test.dart` ile aynı desen).
//
// NEDEN VAR (14 Eylül 2026, kullanıcı raporu — Asnmzr): torbada 4 taş
// kalmışken 7 taş değiştirilebiliyordu. Kural artık DÖRT kopyada
// (src · kelimeki_core · submit_move SQL'i · play-ai-turn) ve
// kullanıcıya gösterilen cümle dördünde de aynı olmak zorunda.
//
// ⚠ Golden vector'lar bunu KANITLAYAMAZ ve bu bilinçli: fixture'lar web ile
// Dart'ı karşılaştırır, yani ikisinde BİRDEN var olan bir kuralsızlığa
// kördür — hata tam olarak öyleydi. Davranış kapısı ayrı:
// `kelimeki_core/test/run_all.dart` → `testSwapLimit`.
//
// ⚠ EN ÖNEMLİ KURAL: bir değer BULUNAMAZSA test DÜŞER, geçmez (`pick`
// bunu zorluyor) — "yeşil ama hiçbir şey kanıtlamayan" test olmasın diye.
import 'package:flutter_test/flutter_test.dart';

import 'support/web_source.dart';

void main() {
  final webSabitler = readRepoFile('src/game/constants.ts');
  final webReducer = readRepoFile('src/game/gameReducer.ts');
  final dartSabitler =
      readRepoFile('mobile/kelimeki_core/lib/src/constants.dart');
  final dartReducer =
      readRepoFile('mobile/kelimeki_core/lib/src/engine/reducer.dart');
  final edge = readRepoFile('supabase/functions/play-ai-turn/index.ts');

  test('uyarı metni web ile BİREBİR aynı', () {
    // TS `${bagCount}`, Dart `$bagCount` yazıyor — tek fark şablon sözdizimi.
    final web = pick(
      webSabitler,
      RegExp(r'return `(Torbada .+?)`;'),
      'constants.ts içinde swapLimitMessage gövdesi',
    ).replaceAll(r'${bagCount}', r'$bagCount');
    final port = pick(
      dartSabitler,
      RegExp(r"^\s*'(Torbada .+?)';", multiLine: true),
      'constants.dart içinde swapLimitMessage gövdesi',
    );
    expect(port, web,
        reason: 'sınır uyarısı iki platformda farklı okunuyor');
  });

  test('sınır TORBANIN KENDİSİ — iki tarafta da kimlik fonksiyonu', () {
    expect(
      RegExp(r'export function maxSwapCount\(bagCount: number\): number \{\s*return bagCount;')
          .hasMatch(webSabitler),
      isTrue,
      reason: 'web maxSwapCount artık torbayı doğrudan döndürmüyor — '
          'kural değiştiyse portu ve SQL aynasını da güncelle',
    );
    expect(
      RegExp(r'int maxSwapCount\(int bagCount\) => bagCount;')
          .hasMatch(dartSabitler),
      isTrue,
      reason: 'port maxSwapCount web ile ayrışmış',
    );
  });

  test('sınır İKİ kapıda birden: seçim anı + onay', () {
    // Seçim anı: kullanıcı sınırı reddedilince değil dokununca öğrenmeli.
    for (final (ad, kaynak) in [
      ('web', webReducer),
      ('port', dartReducer),
    ]) {
      expect(
        RegExp(r'swapSelection\.length >= limit').hasMatch(kaynak),
        isTrue,
        reason: '$ad: seçim anındaki sınır kapısı kayboldu',
      );
    }
    // Onay: kuralın sahibi UI değil reducer (swapSelection state'e başka
    // yollardan da girebiliyor — kayıttan devam, araya giren senkron).
    expect(
      RegExp(r'swapSelection\.length > limit').hasMatch(webReducer),
      isTrue,
      reason: 'web: CONFIRM_SWAP ikinci kapısı kayboldu',
    );
    expect(
      RegExp(r'swapSelection\.length > swapLimit').hasMatch(dartReducer),
      isTrue,
      reason: 'port: _confirmSwap ikinci kapısı kayboldu',
    );
  });

  test('YZ de dilimliyor — üç kopyada birden', () {
    expect(
      RegExp(r'\.slice\(0, maxSwapCount\(state\.bag\.length\)\)')
          .hasMatch(webReducer),
      isTrue,
      reason: 'web AI_PLAY yine rafın TAMAMINI değiştiriyor',
    );
    expect(
      RegExp(r'me\.rack\.take\(maxSwapCount\(state\.bag\.length\)\)')
          .hasMatch(dartReducer),
      isTrue,
      reason: 'port _aiPlay yine rafın TAMAMINI değiştiriyor',
    );
    // ⚠ Bu satır olmadan sunucu kapısı YZ'nin hamlesini reddeder ve
    // play-ai-turn'ün `catch`i sessizce pas geçmeye düşer.
    expect(
      RegExp(r'rack\.slice\(0, bagCount\)').hasMatch(edge),
      isTrue,
      reason: 'play-ai-turn yine rafın TAMAMINI gönderiyor — Canlı oyunda '
          'YZ tıkandığı turda SESSİZCE pas geçer',
    );
  });
}
