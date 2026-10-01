// Canlı oyun sohbetinin okundu kararı — `util/chat_read.dart`.
//
// Vakalar web `scripts/verify-chat-read.ts`in BİREBİR aynısı (aynı sıra,
// aynı damgalar): iki platform aynı kararı vermek zorunda, derleyici bunu
// göremez. Biri değişirse öteki de (ROADMAP #34).
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/util/chat_read.dart';

const me = 'me';
const him = 'danyal';
const now = '2026-09-23T08:00:00.000Z';
const rows = [
  ChatReadRow(senderUserId: him, createdAt: '2026-09-22T10:00:00.123456+00:00'),
  ChatReadRow(senderUserId: me, createdAt: '2026-09-22T11:00:00.000000+00:00'),
  ChatReadRow(senderUserId: him, createdAt: '2026-09-23T07:00:00.000000+00:00'),
  ChatReadRow(senderUserId: him, createdAt: '2026-09-23T07:30:00.000000+00:00'),
];

ChatReadDecision decide(ServerChatRead? server, String? localAt) =>
    decideChatRead(
        server: server,
        localAt: localAt,
        rows: rows,
        myUserId: me,
        nowIso: now);

void main() {
  test('1 — kullanıcının vakası: yeni cihaz + sunucu damgası → 2 okunmamış',
      () {
    final d = decide((at: '2026-09-22T11:00:00+00:00'), null);
    expect(d.unread, 2);
    expect(d.writeLocal, '2026-09-22T11:00:00+00:00');
    expect(d.pushToServer, isNull);
  });

  test('2 — başka cihazda okunanlar burada yeni değil', () {
    final d = decide((at: '2026-09-23T07:30:00.000000+00:00'),
        '2026-09-22T10:00:00.123456+00:00');
    expect(d.unread, 0);
    expect(d.writeLocal, '2026-09-23T07:30:00.000000+00:00');
  });

  test('3 — cihaz ileride → sunucu yetişir', () {
    final d = decide((at: '2026-09-22T11:00:00+00:00'),
        '2026-09-23T07:00:00.000000+00:00');
    expect(d.unread, 1);
    expect(d.pushToServer, '2026-09-23T07:00:00.000000+00:00');
    expect(d.writeLocal, isNull);
  });

  test('4 — hiç damga yok, sunucu KESİN boş → tohum iki yere', () {
    final d = decide((at: null), null);
    expect(d.unread, 0);
    expect(d.writeLocal, '2026-09-23T07:30:00.000000+00:00');
    expect(d.pushToServer, '2026-09-23T07:30:00.000000+00:00');
  });

  test('5 — sunucu BİLİNMİYOR + cihazda damga yok → tohum sunucuya YAZILMAZ',
      () {
    final d = decide(null, null);
    expect(d.pushToServer, isNull);
    expect(d.writeLocal, isNotNull);
  });

  test('6 — sunucu bilinmiyor + cihaz damgası → yeniden denenir', () {
    final d = decide(null, '2026-09-23T07:00:00.000000+00:00');
    expect(d.unread, 1);
    expect(d.pushToServer, '2026-09-23T07:00:00.000000+00:00');
  });

  test('7 — eşit damgalar → yazma yok', () {
    const at = '2026-09-23T07:30:00.000000+00:00';
    final d = decide((at: at), at);
    expect(d.writeLocal, isNull);
    expect(d.pushToServer, isNull);
  });

  test('8 — kendi mesajım sayılmaz; laterOf biçimden bağımsız', () {
    final d = decide((at: '2026-09-22T09:00:00Z'), null);
    expect(d.unread, 3);
    expect(
        laterOf('2026-09-23T07:00:00Z', '2026-09-23T07:00:00.500000+00:00'),
        '2026-09-23T07:00:00.500000+00:00');
  });

  test('9 — mesajlar okunamadı → karar verilmez, hiçbir yazma yok', () {
    for (final (server, local) in <(ServerChatRead?, String?)>[
      ((at: null), null),
      (null, '2026-09-23T07:00:00Z'),
    ]) {
      final d = decideChatRead(
          server: server,
          localAt: local,
          rows: null,
          myUserId: me,
          nowIso: now);
      expect(d.unread, isNull);
      expect(d.writeLocal, isNull);
      expect(d.pushToServer, isNull);
    }
  });

  // ── Port'a özgü: cihaz damgası milisaniye (int) ─────────────────────────

  test(
      'cihazın milisaniyeye kırpılmış damgası = sunucunun mikro saniyelisi → '
      'her yüklemede boşuna yazma YOK', () {
    final localMs =
        DateTime.parse('2026-09-23T07:30:00.123456+00:00').millisecondsSinceEpoch;
    final d = decide((at: '2026-09-23T07:30:00.123456+00:00'),
        localStampIso(localMs));
    expect(d.writeLocal, isNull);
    expect(d.pushToServer, isNull);
  });

  test('port dönemi damgası (sunucuda satır yok) sunucuya taşınır', () {
    final localMs =
        DateTime.parse('2026-09-23T07:00:00Z').millisecondsSinceEpoch;
    final d = decide((at: null), localStampIso(localMs));
    expect(d.unread, 1);
    expect(DateTime.parse(d.pushToServer!).millisecondsSinceEpoch, localMs);
  });
}
