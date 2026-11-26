import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/store_review.dart';
import 'package:kelimeki/src/storage/flags_store.dart';
import 'package:kelimeki/src/util/review_prompt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Fake implements StoreReview {
  int calls = 0;
  @override
  Future<void> request() async => calls++;
}

ReviewPromptInput _in({
  bool won = true,
  int finished = 3,
  bool celebration = false,
  int asks = 0,
  int? last,
  int now = 1000000000000,
}) =>
    ReviewPromptInput(
        won: won,
        finishedGames: finished,
        celebrationShown: celebration,
        asksSoFar: asks,
        lastAskedAtMs: last,
        nowMs: now);

void main() {
  group('shouldRequestReview', () {
    test('galibiyet + 3 biten oyun → ister', () {
      expect(shouldRequestReview(_in()), isTrue);
    });
    test('kaybedilen oyunda İSTEMEZ', () {
      expect(shouldRequestReview(_in(won: false)), isFalse);
    });
    test('3. oyundan ÖNCE istemez (ilk oyunda asla)', () {
      expect(shouldRequestReview(_in(finished: 1)), isFalse);
      expect(shouldRequestReview(_in(finished: 2)), isFalse);
    });
    test('kutlama penceresiyle aynı gün istemez', () {
      expect(shouldRequestReview(_in(celebration: true)), isFalse);
    });
    test('en fazla $reviewMaxAsks kez', () {
      expect(shouldRequestReview(_in(asks: reviewMaxAsks)), isFalse);
    });
    test('120 günden önce tekrar istemez, sonra ister', () {
      const now = 1000000000000;
      final gun = const Duration(days: 1).inMilliseconds;
      expect(shouldRequestReview(_in(last: now - 119 * gun, asks: 1)), isFalse);
      expect(shouldRequestReview(_in(last: now - 120 * gun, asks: 1)), isTrue);
    });
  });

  group('maybeAskStoreReview', () {
    Future<FlagsStore> flags() async {
      SharedPreferences.setMockInitialValues({});
      return FlagsStore(await SharedPreferences.getInstance());
    }

    test('3. biten oyunda kazanınca bir kez ister, sonra susar', () async {
      final f = await flags();
      final fake = _Fake();
      for (var i = 0; i < 2; i++) {
        await maybeAskStoreReview(
            flags: f, won: true, celebrationShown: false, review: fake);
      }
      expect(fake.calls, 0);
      await maybeAskStoreReview(
          flags: f, won: true, celebrationShown: false, review: fake);
      expect(fake.calls, 1);
      await maybeAskStoreReview(
          flags: f, won: true, celebrationShown: false, review: fake);
      expect(fake.calls, 1);
      expect(f.reviewAskCount, 1);
    });

    test('kaybedilen oyunlar da sayılır ama istek yalnız galibiyette',
        () async {
      final f = await flags();
      final fake = _Fake();
      for (var i = 0; i < 3; i++) {
        await maybeAskStoreReview(
            flags: f, won: false, celebrationShown: false, review: fake);
      }
      expect(fake.calls, 0);
      await maybeAskStoreReview(
          flags: f, won: true, celebrationShown: false, review: fake);
      expect(fake.calls, 1);
    });

    test('OS çağrısı hata verse de oyun akışı bozulmaz', () async {
      final f = await flags();
      final bad = _Throws();
      for (var i = 0; i < 3; i++) {
        await maybeAskStoreReview(
            flags: f, won: true, celebrationShown: false, review: bad);
      }
    });
  });
}

class _Throws implements StoreReview {
  @override
  Future<void> request() async => throw StateError('os');
}
