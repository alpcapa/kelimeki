// `OnlineApi.submitMove`'un retry/idempotency döngüsü — mobilin ASIL
// güvenilirlik özelliği ve 13 Ağustos 2026 denetimine kadar SIFIR test
// kapsamı vardı.
//
// Neden ekran testleri yetmiyordu: `online_game_screen_test.dart`ın 15
// testi "hamle sunucuya gitti" davranışını `FakeOnlineGamesGateway`
// sınırının ÜSTÜNDE ölçüyor; döngü o sınırın ALTINDA (gateway → OnlineApi
// → supabase.rpc). Denetim bunu somut olarak gösterdi: `final id = moveId
// ?? uuidV4()` satırı döngünün İÇİNE taşınsa — her denemede YENİ uuid,
// yani idempotensi tamamen kırılır ve sunucuda çifte hamle riski geri
// gelir — 389 testin hiçbiri düşmüyordu. Parça 86'nın dersinin aynısı:
// bir sözleşmeyi enjekte edilebilir sınırın ÜSTÜNDE test etmek, o sınırın
// ALTINDAKİ iletimi kanıtlamaz.
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/online_api.dart';
import 'package:kelimeki/src/util/offline_notice.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

void main() {
  test('taşıma hatasında AYNI p_move_id ile yeniden denenir (idempotensi)',
      () async {
    final ids = <Object?>[];
    var calls = 0;
    final api = OnlineApi.withRpc((params) async {
      calls++;
      ids.add(params['p_move_id']);
      if (calls == 1) throw Exception('soket koptu');
    });

    await api.submitMove(gameId: 'g1', action: 'pass');

    expect(calls, 2);
    // ASIL SÖZLEŞME: iki denemenin id'si BİREBİR aynı olmalı. Farklı
    // olsaydı sunucudaki `(online_game_id, move_id)` unique index'i devreye
    // giremez, ilk denemesi aslında ulaşmış bir hamle ikinci kez işlenirdi.
    expect(ids, hasLength(2));
    expect(ids[0], isNotNull);
    expect(ids[1], ids[0]);
  });

  test(
      'sunucu reddi KESİN karar — retry YOK, ServerRejection olarak yüzeye '
      'çıkar ve toString() YALNIZCA mesajı verir', () async {
    var calls = 0;
    final api = OnlineApi.withRpc((_) async {
      calls++;
      throw PostgrestException(
          message: 'Sıra sende değil.', code: 'P0001', details: 'Bad Request');
    });

    await expectLater(
      api.submitMove(gameId: 'g1', action: 'pass'),
      throwsA(isA<ServerRejection>()),
    );
    // Kural reddini tekrar denemek anlamsız (ve sunucuyu boşuna yorar).
    expect(calls, 1);

    // ⚠ ASIL İDDİA (11 Eylül 2026 vakası): kullanıcının ekranında
    // `_errorText` bu nesnenin `toString()`ini gösteriyor. Ham
    // `PostgrestException.toString()` TÜM alanları basıyordu ve kullanıcı
    // iPhone'da *"PostgrestException(message: …, code: P0001, details: Bad
    // Request…)"* gördü. Burada hem mesajın DOĞRU hem de gürültünün YOK
    // olduğu ölçülüyor — ikincisi olmadan test düzeltmeye duyarsız kalırdı.
    Object? yakalanan;
    try {
      await api.submitMove(gameId: 'g1', action: 'pass');
    } catch (e) {
      yakalanan = e;
    }
    expect(yakalanan.toString(), 'Sıra sende değil.');
    expect(yakalanan.toString(), isNot(contains('PostgrestException')));
    expect(yakalanan.toString(), isNot(contains('P0001')));
    expect((yakalanan! as ServerRejection).code, 'P0001');
  });

  test('sunucu reddi AĞ hatası sanılmaz (isNetworkError false)', () {
    // `_errorText` önce `isNetworkError`a bakıyor; Türkçe bir iş kuralı
    // mesajı oraya takılsaydı kullanıcı "bağlantı yok" yazısı görürdü.
    expect(isNetworkError(const ServerRejection('Sıra sende değil.')), isFalse);
  });

  test('taşıma hatası maxAttempts boyunca sürerse hata yüzeye çıkar', () async {
    var calls = 0;
    final api = OnlineApi.withRpc((_) async {
      calls++;
      throw Exception('timeout');
    });

    await expectLater(
      api.submitMove(gameId: 'g1', action: 'pass', maxAttempts: 2),
      throwsA(isA<Exception>()),
    );
    expect(calls, 2); // sessizce başarı DÖNMEZ
  });

  test('moveId açıkça verilirse o kullanılır (çağıranın retry kancası)',
      () async {
    final ids = <Object?>[];
    final api = OnlineApi.withRpc((params) async {
      ids.add(params['p_move_id']);
    });

    await api.submitMove(gameId: 'g1', action: 'pass', moveId: 'sabit-move-id');

    expect(ids, ['sabit-move-id']);
  });
}
