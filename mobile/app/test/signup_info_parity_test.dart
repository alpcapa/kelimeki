// Kayıt sonrası kırmızı bilgi satırı — web `AuthModal.tsx` ↔ port
// `auth_modal.dart` METİN paritesi (26 Eylül 2026).
//
// NEDEN: kullanıcı "Hesap oluşturuldu." cümlesini kaldırttı (*"İnsanlar
// hesaplarının oluştuğunu düşünüyor olabilir"*); iki platform aynı cümleyi
// göstermek zorunda ve metin derleyicinin göremediği türden. Test iki kaynağı
// OKUR; biri değişip öteki unutulursa düşer.

import 'package:flutter_test/flutter_test.dart';

import 'support/web_source.dart';

const _metin = 'LÜTFEN E-POSTANIZI KONTROL EDİP DOĞRULAMA YAPIN.';

void main() {
  final web = readRepoFile('src/components/AuthModal.tsx');
  final port = readRepoFile('mobile/app/lib/src/ui/auth/auth_modal.dart');

  test('iki tarafta da AYNI eylem cümlesi', () {
    expect(web.contains(_metin), isTrue, reason: 'web metni değişmiş');
    expect(port.contains("'$_metin'"), isTrue, reason: 'port metni değişmiş');
  });

  test('"Hesap oluşturuldu." iki tarafta da YOK', () {
    // Yorumlar cümleyi tırnak içinde anıyor; aranan JSX/string hâli.
    expect(web.contains("Hesap oluşturuldu.{' '}"), isFalse);
    expect(web.contains(RegExp(r'^\s*Hesap oluşturuldu\.', multiLine: true)),
        isFalse);
    expect(port.contains("'Hesap oluşturuldu.'"), isFalse);
  });

  test('Türkçe büyük harf: noktalı İ (EDİP), ELDE yazılı', () {
    expect(_metin.contains('EDIP'), isFalse);
  });
}
