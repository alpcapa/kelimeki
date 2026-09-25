// `util/error_message.dart` ↔ `src/utils/errorMessage.ts` paritesi + davranış.
//
// NEDEN BU TEST VAR (13 Eylül 2026): kullanıcı App Store ekran kaydı çekerken
// giriş penceresinde ham `{"message":"Gateway Timeout"}` gördü. Düzeltme iki
// platformda AYNI kalmak zorunda — metinler kullanıcıya görünüyor, kalıplar
// neyin gizleneceğini belirliyor ve ikisi de derleyicinin göremediği türden.
//
// Test web dosyasını OKUR; bulamazsa ya da ayrışırsa DÜŞER.

import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/util/error_message.dart';

import 'support/web_source.dart';

void main() {
  final web = readRepoFile('src/utils/errorMessage.ts');

  group('web ile parite', () {
    test('metinler BİREBİR aynı', () {
      final genel = pick(
        web,
        RegExp(r"GENERIC_ERROR_NOTICE = '([^']+)'"),
        'GENERIC_ERROR_NOTICE',
      );
      final gecici = pick(
        web,
        RegExp(r"TEMPORARY_ERROR_NOTICE =\s*'([^']+)'"),
        'TEMPORARY_ERROR_NOTICE',
      );
      expect(kGenericErrorNotice, genel);
      expect(kTemporaryErrorNotice, gecici);
    });

    test('P0001 ayrımı iki tarafta da yazılı', () {
      expect(web.contains("=== 'P0001'"), isTrue,
          reason: 'web tarafı P0001 kontrolünü kaybetmiş');
    });

    test('kalıp SAYILARI eşleşiyor', () {
      // Kalıpların METNİNİ karşılaştırmak iki dilin regex sözdizimi
      // farkları yüzünden yanlış alarm üretirdi (Dart ham string, JS literal).
      // Sayı eşitliği "biri eklenip öteki unutuldu"yu yakalar; DAVRANIŞ
      // eşitliğini aşağıdaki ortak vaka listesi kanıtlıyor.
      int say(String blok) => RegExp(r'^\s*/', multiLine: true)
          .allMatches(blok)
          .length;
      final geciciBlok = pick(
        web,
        RegExp(r'GECICI_KALIPLAR: RegExp\[\] = \[(.*?)\];', dotAll: true),
        'GECICI_KALIPLAR',
      );
      final makineBlok = pick(
        web,
        RegExp(r'MAKINE_KALIPLARI: RegExp\[\] = \[(.*?)\];', dotAll: true),
        'MAKINE_KALIPLARI',
      );
      expect(say(geciciBlok), 10,
          reason: 'web geçici kalıp sayısı değişti — Dart tarafını da güncelle');
      expect(say(makineBlok), 12,
          reason: 'web makine kalıp sayısı değişti — Dart tarafını da güncelle');
    });
  });

  group('vakanın kendisi', () {
    test('504 JSON gövdesi ekrana ÇIKMAZ', () {
      final ekran = friendlyErrorMessage(
        Exception('{"message":"Gateway Timeout"}'),
        report: false,
      );
      expect(ekran.contains('Gateway'), isFalse);
      expect(ekran, kTemporaryErrorNotice);
    });

    test('düz "Gateway Timeout" da yakalanır', () {
      // ⚠ Hiçbir MAKİNE kalıbına takılmaz; yakalayan tek şey geçici-arıza
      // testinin makine testinden ÖNCE koşması. Sıra bozulursa bu düşer.
      expect(
        friendlyErrorMessage(_Hata('Gateway Timeout'), report: false),
        kTemporaryErrorNotice,
      );
    });
  });

  group('sunucunun kendi reddi korunur', () {
    test('P0001 metni olduğu gibi gösterilir', () {
      expect(
        friendlyErrorMessage(_Hata('Sıra sende değil.', code: 'P0001'),
            report: false),
        'Sıra sende değil.',
      );
    });

    test('P0001 makine testini EZER', () {
      expect(
        friendlyErrorMessage(_Hata('{"message":"özel ret"}', code: 'P0001'),
            report: false),
        '{"message":"özel ret"}',
      );
    });

    test('başka bir SQLSTATE korunmaz', () {
      final ekran = friendlyErrorMessage(
        _Hata('duplicate key value violates unique constraint', code: '23505'),
        report: false,
      );
      expect(ekran, kGenericErrorNotice);
    });
  });

  group('kendi Türkçe mesajlarımız geçer', () {
    // Hepsi ASCII — "Türkçe karakter var mı" diye bakan bir beyaz liste
    // bunları elerdi; kara listenin sebebi bu.
    for (final msg in const [
      'Ad zorunludur.',
      'Oturum acik degil.',
      'Mesaj 1-200 karakter arasinda olmali.',
      'Bu takma isim zaten kullanılıyor. Farklı bir tane dene.',
    ]) {
      test('geçer: "$msg"', () {
        expect(friendlyErrorMessage(_Hata(msg), report: false), msg);
      });
    }
  });

  group('makine metinleri elenir', () {
    for (final msg in const [
      '{"code":"PGRST301","message":"JWT expired"}',
      '<!DOCTYPE html><html><body>504</body></html>',
      'PostgrestException(message: x, code: 42501, details: Bad Request)',
      'permission denied for table profiles',
      'column "foo" does not exist',
      'duplicate key value violates unique constraint "profiles_pkey"',
    ]) {
      test('elenir: "${msg.substring(0, msg.length.clamp(0, 32))}…"', () {
        expect(isMachineMessage(msg), isTrue);
        final ekran = friendlyErrorMessage(_Hata(msg), report: false);
        expect(
          ekran == kGenericErrorNotice || ekran == kTemporaryErrorNotice,
          isTrue,
          reason: 'ekrana düşen: $ekran',
        );
      });
    }
  });

  group('boş ve garip girdiler', () {
    test('boş mesaj → fallback', () {
      expect(friendlyErrorMessage(_Hata(''), report: false), kGenericErrorNotice);
    });

    test('null → fallback', () {
      expect(friendlyErrorMessage(null, report: false), kGenericErrorNotice);
    });

    test('çağırana özel fallback kullanılır', () {
      expect(
        friendlyErrorMessage(_Hata('{"x":1}'),
            fallback: 'Hamle gönderilemedi.', report: false),
        'Hamle gönderilemedi.',
      );
    });
  });

  group('telemetri', () {
    tearDown(() => setErrorMessageReporter(null));

    test('makine metni RAPORLANIR, kendi metnimiz raporlanmaz', () {
      final kayitlar = <String>[];
      setErrorMessageReporter((err, context) => kayitlar.add(context));

      friendlyErrorMessage(_Hata('{"message":"Gateway Timeout"}'),
          surface: 'giris');
      expect(kayitlar, ['hata-metni:giris'],
          reason: 'ham metin kaybolmamalı — ekrandan gizlemek ≠ kaydetmemek');

      friendlyErrorMessage(_Hata('Ad zorunludur.'), surface: 'giris');
      expect(kayitlar.length, 1, reason: 'kendi mesajımız telemetriye girmez');
    });
  });
}

/// `code` alanı taşıyan hata — `ServerRejection`/`PostgrestException`in
/// test karşılığı (üçünün ortak üst tipi yok, `dynamic` ile okunuyor).
class _Hata implements Exception {
  final String message;
  final String? code;
  const _Hata(this.message, {this.code});

  @override
  String toString() => message;
}
