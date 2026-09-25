// Sohbet Kuralları onayı: web `src/utils/chatRules.ts` ↔ port
// `util/chat_rules.dart` (25 Eylül 2026).
//
// Metin HUKUKİ bir beyan (kullanıcı "kabul ediyorum" diyor) ve sürüm
// numarası iki istemcinin aynı `profiles.chat_rules_version` satırını
// yorumlamasını belirliyor: web 2'ye geçip port 1'de kalırsa port her
// açılışta yeniden sorar, tersi olursa port yeni kuralları hiç sormaz.
// İkisi de sessiz arıza — bu test web kaynağını okuyup birebir karşılaştırır.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/util/chat_rules.dart';

import 'support/web_source.dart';

/// TS tek tırnaklı dize değişmezini çözer (yalnızca `\'` kaçışı kullanılıyor).
String _tsString(String src, String ad) {
  final m =
      RegExp("export const $ad = '((?:[^'\\\\]|\\\\.)*)';").firstMatch(src);
  expect(m, isNotNull, reason: 'chatRules.ts içinde $ad bulunamadı');
  return m!.group(1)!.replaceAll("\\'", "'");
}

void main() {
  final web = readRepoFile('src/utils/chatRules.ts');

  test('sürüm numarası aynı', () {
    final m =
        RegExp(r'export const CHAT_RULES_VERSION = (\d+);').firstMatch(web);
    expect(m, isNotNull);
    expect(kChatRulesVersion, int.parse(m!.group(1)!));
  });

  test('başlık/giriş/bağlantı/buton metinleri aynı', () {
    expect(kChatRulesTitle, _tsString(web, 'CHAT_RULES_TITLE'));
    expect(kChatRulesIntro, _tsString(web, 'CHAT_RULES_INTRO'));
    expect(kChatRulesTermsLink, _tsString(web, 'CHAT_RULES_TERMS_LINK'));
    expect(kChatRulesAccept, _tsString(web, 'CHAT_RULES_ACCEPT'));
    expect(kChatRulesCancel, _tsString(web, 'CHAT_RULES_CANCEL'));
  });

  test('kural maddeleri aynı ve aynı sırada', () {
    final blok =
        RegExp(r'CHAT_RULES_ITEMS: readonly string\[\] = \[([\s\S]*?)\];')
            .firstMatch(web);
    expect(blok, isNotNull, reason: 'CHAT_RULES_ITEMS bulunamadı');
    final maddeler = [
      for (final m
          in RegExp("'((?:[^'\\\\]|\\\\.)*)'").allMatches(blok!.group(1)!))
        m.group(1)!.replaceAll("\\'", "'"),
    ];
    expect(maddeler, isNotEmpty);
    expect(kChatRulesItems, maddeler);
  });

  test('needsChatRulesConsent: null/eski → göster, güncel → gösterme', () {
    expect(needsChatRulesConsent(null), isTrue);
    expect(needsChatRulesConsent(kChatRulesVersion - 1), isTrue);
    expect(needsChatRulesConsent(kChatRulesVersion), isFalse);
    expect(needsChatRulesConsent(kChatRulesVersion + 1), isFalse);
  });
}
