// "Bu arkadaşla oyun kur" isteği — web `utils/liveGameRequest.ts` portu
// (27 Eylül 2026, ROADMAP #41 karar 23: Arkadaşlar penceresinin OYNA'sı ve
// ⋯ menüsünün "2/4 kişilik oyun kur"u).
//
// Pencere uygulamanın birkaç yerinden açılabiliyor (Setup'taki ve oyun
// ekranlarındaki hesap menüsü); istek burada bekler, dinleyenler OKUYUP
// TÜKETİR:
// - `SetupScreen`: oyun ekranı açıksa Setup'a döner (oyun kayıtlı) ve
//   "Arkadaşınla" sekmesine geçer — `seq` değişimine bakar, tüketmez.
// - `LiveGamesTab`: formu o arkadaş seçili açar — hem açılışta (`take`) hem
//   dinleyerek; isteği TÜKETEN tek yer.
import 'package:flutter/foundation.dart';

class LiveGameRequest {
  final String friendId;
  final int playerCount;
  const LiveGameRequest({required this.friendId, required this.playerCount});
}

class LiveGameRequests extends ChangeNotifier {
  LiveGameRequest? _bekleyen;
  int _seq = 0;

  /// Her istekte artar — tüketmeden "yeni istek geldi mi" sorusu için.
  int get seq => _seq;
  bool get hasPending => _bekleyen != null;

  void request(LiveGameRequest r) {
    _bekleyen = r;
    _seq++;
    notifyListeners();
  }

  /// Bekleyen isteği döner ve kuyruğu boşaltır.
  LiveGameRequest? take() {
    final r = _bekleyen;
    _bekleyen = null;
    return r;
  }

  @visibleForTesting
  void reset() {
    _bekleyen = null;
  }
}

/// Uygulama genelinde TEK kuyruk (web modül değişkeninin karşılığı).
final LiveGameRequests liveGameRequests = LiveGameRequests();
