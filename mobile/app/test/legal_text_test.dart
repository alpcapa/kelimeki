// Hukuki metinlerin web ↔ port tazeliği.
//
// NEDEN VAR (13 Ağustos 2026 denetimi): `legal_modals.dart`ın başlığı
// "METİNLER WEB'DEN BİREBİR KOPYALANMIŞTIR … web metni değişirse buraya da
// aynen taşınmalı" diyor — ama bunu ZORLAYAN hiçbir şey yoktu ve gerçekten
// kaçtı: 10 Ağustos 2026'da `game_chat_archive_participants_only`
// migration'ı sohbet arşivini katılımcı+admin'e kilitledi, web'in Gizlilik
// Politikası buna göre düzeltildi ("YALNIZCA o oyunun katılımcılarına …"),
// port ise ESKİ ve artık YANLIŞ olan "tüm kayıtlı kullanıcılara açık"
// cümlesini taşımaya devam etti. Yani uygulama kullanıcıya kendi verisi
// hakkında gerçek olmayan bir şey söylüyordu.
//
// Tam metin karşılaştırması kırılgan olurdu (satır kaydırma/kaçış farkları),
// bu yüzden test web'in KENDİ "Son güncelleme" tarihini kaynak dosyadan
// okuyup portunkiyle karşılaştırıyor: web metni her değiştiğinde o tarih de
// değişiyor (projenin yerleşik disiplini), dolayısıyla bu tek alan
// "port bayat mı?" sorusunun güvenilir vekili. `color_tokens_test.dart`ın
// tailwind'i okuyan deseninin aynısı.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `Son güncelleme: 10 Ağustos 2026` → `10 Ağustos 2026`
String? _lastUpdated(String source) {
  final m = RegExp(r'Son güncelleme:\s*([0-9]{1,2}\s+\p{L}+\s+[0-9]{4})',
          unicode: true)
      .firstMatch(source);
  return m?.group(1);
}

/// Hukuki metinlerin web tarafındaki TEK KAYNAĞI.
///
/// 23 Ağustos 2026'da `PrivacyModal.tsx`/`TermsModal.tsx`ten buraya taşındı:
/// aynı metni artık statik sayfalar da (`/gizlilik/`, `/kullanim-kosullari/`)
/// tüketiyor, çünkü Play'in Data safety formu doğrudan açılan bir URL istiyor.
/// **Bu test o taşımada kırıldı ve merge öncesi yakalandı** — eski yolu okumaya
/// devam etseydi "Son güncelleme bulunamadı" diye düşerdi. Metin bir daha
/// taşınırsa burası da güncellenmeli; başka hiçbir şey bunu yakalamaz.
const _webKaynak = '../../src/legal/LegalContent.tsx';

/// `LegalContent.tsx` İKİ metni birden taşıyor: önce `PrivacyBody`, sonra
/// `TermsBody`. Portta ise sıra TERS (Koşullar önce, Gizlilik sonra) — bu
/// yüzden "ilk eşleşmeyi al" YANLIŞ olur. Metni fonksiyona göre böl.
String _bolum(String web, {required bool gizlilik}) {
  final i = web.indexOf('export function TermsBody');
  if (i < 0) {
    throw StateError(
        'LegalContent.tsx içinde TermsBody bulunamadı — dosya yeniden '
        'düzenlendiyse bu testin sınırı da güncellenmeli.');
  }
  return gizlilik ? web.substring(0, i) : web.substring(i);
}

void main() {
  final port = File('lib/src/ui/auth/legal_modals.dart').readAsStringSync();
  final web = File(_webKaynak).readAsStringSync();

  // Portta iki tarih var (Koşullar önce, Gizlilik sonra) — sırayla.
  final portDates = RegExp(r'Son güncelleme:\s*([0-9]{1,2}\s+\p{L}+\s+[0-9]{4})',
          unicode: true)
      .allMatches(port)
      .map((m) => m.group(1))
      .toList();

  test('Kullanım Koşulları: portun "Son güncelleme" tarihi web ile aynı', () {
    final webTarih = _lastUpdated(_bolum(web, gizlilik: false));
    expect(webTarih, isNotNull,
        reason: 'web LegalContent.tsx içinde "Son güncelleme" bulunamadı — '
            'metin yeniden düzenlendiyse bu testin regex\'i güncellenmeli');
    expect(portDates.first, webTarih,
        reason: 'Web Kullanım Koşulları güncellenmiş ama port almamış. '
            'legal_modals.dart web metnini BİREBİR taşımak zorunda.');
  });

  test('Gizlilik Politikası: portun "Son güncelleme" tarihi web ile aynı', () {
    final webTarih = _lastUpdated(_bolum(web, gizlilik: true));
    expect(webTarih, isNotNull);
    expect(portDates.last, webTarih,
        reason: 'Web Gizlilik Politikası güncellenmiş ama port almamış — '
            '10 Ağustos 2026\'da tam bu şekilde kaçtı (sohbet arşivi '
            'görünürlüğü katılımcıya kilitlendi, port eski cümleyi taşımaya '
            'devam etti).');
  });

  test('Rastgele Oyuncu ilan görünürlüğü + sohbet cümlesi: web ve port AYNI '
      'sözleri taşıyor (4 Ekim 2026)', () {
    // Tarih tek başına yetmez: tarih aynı kalıp bir cümle yalnızca bir
    // tarafta eksik olabilir. Ayraçlar (satır kaydırma, tırnak, noktalama)
    // atılıp yalnızca harf/rakam karşılaştırılır — JSX ile Dart dizesinin
    // satır bölme farkı testi kırmasın.
    String norm(String s) =>
        s.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
    final webN = norm(web);
    final portN = norm(port);
    const sozler = [
      // Gizlilik §2 maddesi
      'Rastgele Oyuncu ilanı açarsanız takma adınız ve profil fotoğrafınız, '
          'ilan yayındayken giriş yapmış TÜM üyelere görünür',
      'ilan dolunca ya da 7 gün sonunda kalkar',
      // Koşullar §1
      'Rastgele Oyuncu ilanı açtığınızda takma adınız ve profil fotoğrafınız '
          'giriş yapmış tüm üyelere görünür',
      'tanımadığınız kişilerle de 3. bölümdeki kurallar geçerlidir',
      // Koşullar §5 (sohbet cümlesi: "yalnızca arkadaşlar" ZATEN yanlıştı)
      'Oyun içi mesajlaşma, aynı Canlı oyunda oynayan kullanıcılar arasında '
          'açıktır',
      'oyuncuların birbiriyle arkadaş olması gerekmez',
      'Dilediğiniz kişiyi sessize alabilir ya da şikayet edebilirsiniz',
    ];
    for (final s in sozler) {
      expect(webN.contains(norm(s)), isTrue,
          reason: 'web LegalContent.tsx içinde bulunamadı: "$s"');
      expect(portN.contains(norm(s)), isTrue,
          reason: 'port legal_modals.dart içinde bulunamadı: "$s" — web '
              'metni değişti ama port almadı');
    }
    // Eski ve artık YANLIŞ olan cümle iki tarafta da yok.
    expect(norm(port).contains(norm('yalnızca birbirini arkadaş olarak')),
        isFalse);
    expect(webN.contains(norm('yalnızca birbirini arkadaş olarak')), isFalse);
  });

  test('sohbet arşivi görünürlüğü: port ARTIK YANLIŞ olan cümleyi taşımıyor',
      () {
    // Bu iddia tarihten bağımsız olarak da korunmalı: sunucu 10 Ağustos'tan
    // beri arşivi katılımcı+admin'e kilitliyor (`game_chat_archive`).
    expect(port, contains('YALNIZCA o oyunun'),
        reason: 'Gizlilik metni sohbet arşivinin yalnızca katılımcılara ve '
            'yönetici ekibine açık olduğunu söylemeli.');
    expect(port.contains('skor/tahta görünürlüğüyle aynı şekilde'), isFalse,
        reason: 'Eski (ve artık yanlış) "tüm kayıtlı kullanıcılara açık" '
            'ifadesi hâlâ portta.');
  });
}
