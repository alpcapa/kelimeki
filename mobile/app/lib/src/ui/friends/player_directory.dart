// Oyuncu rehberi: sunucuda arama + "Tüm oyuncular" sayfalı listesi — web
// `hooks/usePlayerDirectory.ts` portu (27 Eylül 2026, ROADMAP #41).
//
// Canlı oyun formu kullanıyor (karar 20); Arkadaşlar penceresinin tek ekran
// hâli (karar 22) da aynı sınıfa geçecek.
//
// - `setQuery` ≥ 2 harfse `search_users_for_friend` (350 ms gecikmeli).
// - `open()` ilk kez çağrılınca `list_users_for_friend`in ilk sayfası;
//   sonrası `loadMore()` (çağıran, kaydırma sona yaklaşınca çağırır).
//   Türkçe harfler sunucu collation'ında sayfa sınırlarında yanlış
//   dağılabildiği için HER sayfada birikmiş listenin TAMAMI `trCompare`
//   ile yeniden sıralanır.
// - `patchRelation`: ekle/kabul/iptal sonrası iki listede de satırı yerinde
//   günceller (yeniden çekmeden).
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trCompare;

import '../../data/friends_api.dart';

const int kPlayerDirectoryPageSize = 20;

class PlayerDirectory extends ChangeNotifier {
  final FriendsRepo repo;
  PlayerDirectory(this.repo);

  List<FriendCandidate> results = const [];
  bool searching = false;
  List<FriendCandidate>? allUsers;
  bool hasMore = true;
  bool loadingMore = false;

  String _query = '';
  Timer? _debounce;
  int _searchGen = 0;
  bool _disposed = false;

  bool get searchActive => _query.trim().length >= 2;

  static int _sirala(FriendCandidate a, FriendCandidate b) =>
      trCompare(a.name, b.name);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    _debounce?.cancel();
    final aranan = q.trim();
    final gen = ++_searchGen;
    if (aranan.length < 2) {
      results = const [];
      searching = false;
      _notify();
      return;
    }
    searching = true;
    _notify();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final r = await repo.search(aranan);
      if (_disposed || gen != _searchGen) return;
      results = r ?? const [];
      searching = false;
      _notify();
    });
  }

  void open() {
    if (allUsers != null || loadingMore) return;
    loadingMore = true;
    repo.listUsers(0, kPlayerDirectoryPageSize).then((page) {
      if (_disposed) return;
      loadingMore = false;
      allUsers = [...?page]..sort(_sirala);
      hasMore = (page?.length ?? 0) == kPlayerDirectoryPageSize;
      _notify();
    });
  }

  void loadMore() {
    final cur = allUsers;
    if (cur == null || !hasMore || loadingMore) return;
    loadingMore = true;
    _notify();
    repo.listUsers(cur.length, kPlayerDirectoryPageSize).then((page) {
      if (_disposed) return;
      loadingMore = false;
      if (page == null) {
        // Ağ hatası: sayfalamayı durdur, elde olan kalır.
        hasMore = false;
      } else {
        allUsers = [...cur, ...page]..sort(_sirala);
        hasMore = page.length == kPlayerDirectoryPageSize;
      }
      _notify();
    });
  }

  void patchRelation(String id, FriendRelation? r) {
    FriendCandidate yama(FriendCandidate c) =>
        c.id == id ? c.withRelation(r) : c;
    results = [for (final c in results) yama(c)];
    final all = allUsers;
    if (all != null) allUsers = [for (final c in all) yama(c)];
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
