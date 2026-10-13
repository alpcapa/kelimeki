// Sohbet/engel deposunun AĞAÇ GENELİNDE erişilebilir hâli.
//
// NEDEN VAR (13 Ekim 2026): oyun geçmişindeki "Tekrar Oyna" artık engellediğim
// rakibi denetliyor (`ChatRepo.rematchBlockedNames`) ve "Engel Ayarları"nı
// açıyor; `GameHistoryModal`a kadar böyle bir bağımlılık taşınmıyordu ve üç
// ayrı çağrı zinciri var. `OnlineGamesScope`un aynı kararı (parametreyle
// geçirmeyi ELE, kapsamı kökte bir kez kur) — gerekçe orada, tekrarlamıyorum.
//
// Bilinçli olarak `maybeOf`: testler ve izole widget'lar kapsamsız da
// çalışabilmeli; kapsam yoksa (ya da Supabase yapılandırılmamışsa `repo` null)
// engel denetimi ATLANIR ve rövanş eskisi gibi sunucu kapısına gider.
library;

import 'package:flutter/widgets.dart';

import '../data/chat_api.dart';

class ChatScope extends InheritedWidget {
  /// Supabase yapılandırılmamışsa null.
  final ChatRepo? repo;

  const ChatScope({super.key, required this.repo, required super.child});

  static ChatRepo? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatScope>()?.repo;

  @override
  bool updateShouldNotify(ChatScope oldWidget) =>
      !identical(oldWidget.repo, repo);
}
