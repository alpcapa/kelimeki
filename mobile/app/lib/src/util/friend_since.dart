// "3 haftadır arkadaşsınız" — web `FriendsModal.tsx` → `friendSinceLabel`
// portu (27 Eylül 2026, ROADMAP #41 karar 22). Liste satırında KISA hâl
// ("3 haftadır"): uzun metin OYNA + ⋯ yanında kesiliyordu (web 390 px'te
// ölçtü). Saf; bilinmiyorsa null. `friend_since_test.dart` web'le aynı
// eşikleri kilitler.
String? friendSinceLabel(String? since, {bool kisa = false, DateTime? now}) {
  if (since == null) return null;
  final t = DateTime.tryParse(since);
  if (t == null) return null;
  final simdi = now ?? DateTime.now();
  // Web `Math.floor((now - t) / 86_400_000)`.
  final gun =
      ((simdi.millisecondsSinceEpoch - t.millisecondsSinceEpoch) / 86400000)
          .floor();
  if (gun <= 0) return kisa ? 'Bugün eklendi' : 'Bugün arkadaş oldunuz';
  if (gun == 1) return kisa ? 'Dün eklendi' : 'Dün arkadaş oldunuz';
  final sure = gun < 7
      ? '$gun gündür'
      : gun < 30
          ? '${gun ~/ 7} haftadır'
          : gun < 365
              ? '${gun ~/ 30} aydır'
              : '${gun ~/ 365} yıldır';
  return kisa ? sure : '$sure arkadaşsınız';
}
