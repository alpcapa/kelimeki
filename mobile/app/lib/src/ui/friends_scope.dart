// Arkadaş deposunun (`FriendsRepo`) AĞAÇ GENELİNDE erişilebilir hâli.
//
// NEDEN VAR (13 Ekim 2026, S2): oyun geçmişindeki "Tekrar Oyna" artık rakiplerin
// arkadaş olup olmadığına göre plan kuruyor (`buildRematchPlan`); `GameHistoryModal`a
// kadar `FriendsRepo` taşınmıyordu ve üç ayrı çağrı zinciri var. `ChatScope` ve
// `OnlineGamesScope` ile AYNI karar (parametreyle geçirmeyi ELE, kapsamı kökte
// bir kez kur) — gerekçe `online_games_scope.dart` başlığında, tekrarlamıyorum.
//
// Bilinçli olarak `maybeOf`: kapsam yoksa (testler, Supabase'siz) arkadaş listesi
// OKUNAMADI sayılır ve rövanş bugünkü akışa (`create_online_game`) düşer.
library;

import 'package:flutter/widgets.dart';

import '../data/friends_api.dart';

class FriendsScope extends InheritedWidget {
  /// Supabase yapılandırılmamışsa null.
  final FriendsRepo? repo;

  const FriendsScope({super.key, required this.repo, required super.child});

  static FriendsRepo? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FriendsScope>()?.repo;

  @override
  bool updateShouldNotify(FriendsScope oldWidget) =>
      !identical(oldWidget.repo, repo);
}
