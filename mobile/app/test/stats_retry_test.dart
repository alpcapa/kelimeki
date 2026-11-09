// StatsRepo'nun raporlanan okumaları: geçici ağ geçidi hatasında TEK sessiz
// yeniden deneme (3 Kasım 2026).
//
// `client_errors`: `stats_repo.my_rank` / `age_gender` →
// `PostgrestException(code: 522)` (2 Kasım, 24 saatte 5 kayıt, tek Android
// cihaz; sunucuda 5xx yok). Kural `OnlineGamesRepo._retrying`in dar kuralı:
// yalnızca cevabın GELMEDİĞİ durum tekrar denenir, sunucunun kendi reddi
// denenmez; ikinci deneme de düşerse eski davranış (null + rapor).
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/data/stats_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

class _Gateway implements StatsGateway {
  /// Sırayla fırlatılacak hatalar; tükenince başarılı cevap döner.
  final List<Object> hatalar;
  int cagri = 0;
  _Gateway(this.hatalar);

  Future<T> _cevap<T>(T deger) async {
    cagri++;
    if (hatalar.isNotEmpty) throw hatalar.removeAt(0);
    return deger;
  }

  @override
  Future<Map<String, Object?>?> myLeaderboardRank(String userId) =>
      _cevap({'rank': 7, 'total_score': 120, 'avg_move_score': 12.5});

  @override
  Future<Map<String, Object?>?> profileAgeGender(String userId) =>
      _cevap({'age': 30, 'gender': 'E'});

  @override
  Future<Map<String, Object?>?> myBeyinLigiRank(String userId) =>
      _cevap({'rank': 3, 'avg_move_score': 14.0, 'ohp_games': 12});

  @override
  Future<Map<String, Object?>?> playerStats(String u, int? p) async => null;
  @override
  Future<List<Map<String, Object?>>> leaderboard(int l, int o) async =>
      const [];
  @override
  Future<List<Map<String, Object?>>> beyinLigi(int l, int o) async => const [];
  @override
  Future<List<Map<String, Object?>>> rankScores(List<String> ids) async =>
      const [];
  @override
  Future<Map<String, Object?>?> headToHead(String o) async => null;
}

PostgrestException _p522() =>
    const PostgrestException(message: 'error code: 522', code: '522');

void main() {
  late List<Duration> beklemeler;
  StatsRepo repo(_Gateway g) =>
      StatsRepo(g, delay: (d) async => beklemeler.add(d));

  setUp(() => beklemeler = []);

  test('my_rank: 522 bir kez → sessizce yeniden dener, sırayı döndürür',
      () async {
    final g = _Gateway([_p522()]);
    final r = await repo(g).myRank('u');
    expect(r?.rank, 7);
    expect(g.cagri, 2);
    expect(beklemeler, [StatsRepo.retryDelay]);
  });

  test(
      'my_rank: 522 iki kez → null (eski davranış), yalnızca BİR yeniden deneme',
      () async {
    final g = _Gateway([_p522(), _p522()]);
    expect(await repo(g).myRank('u'), isNull);
    expect(g.cagri, 2);
  });

  test('sunucunun kendi reddi tekrar DENENMEZ', () async {
    final g = _Gateway([
      const PostgrestException(message: 'Yetkisiz erişim.', code: 'P0001'),
    ]);
    expect(await repo(g).myRank('u'), isNull);
    expect(g.cagri, 1);
    expect(beklemeler, isEmpty);
  });

  test('age_gender ve my_beyin_rank da aynı kuralla yeniden dener', () async {
    final g1 = _Gateway([_p522()]);
    expect(await repo(g1).ageGenderLabel('u'), isNotEmpty);
    expect(g1.cagri, 2);

    final g2 = _Gateway([_p522()]);
    expect((await repo(g2).myBeyinRank('u'))?.rank, 3);
    expect(g2.cagri, 2);
  });

  test('hatasız okuma tek çağrı, bekleme yok', () async {
    final g = _Gateway([]);
    expect((await repo(g).myRank('u'))?.rank, 7);
    expect(g.cagri, 1);
    expect(beklemeler, isEmpty);
  });
}
