// Canlı oyun sohbetinin "okundu" kararı (saf fonksiyon) — web
// `src/utils/chatRead.ts` portu (ROADMAP #34).
//
// 23 Eylül 2026'ya kadar okundu damgası YALNIZCA cihazdaydı ve bu iki arıza
// üretiyordu (kullanıcı bildirdi):
//   1. Oyun bir cihazda İLK kez açılınca damga yok → "eski mesajları yeni
//      sayma" tohumu mevcut HER ŞEYİ okunmuş sayıyordu, gerçekten yeni gelmiş
//      mesajlar dahil — rozet 0, içeride iki yeni mesaj.
//   2. Bir cihazda okumak ötekine hiç ulaşmıyordu.
// Damga artık sunucuda da (`online_game_chat_reads`, yalnızca İLERİ gider).
// Cihazdaki damga (`chat_read_store.dart`) YEDEK: sunucuya ulaşılamazsa
// davranış eskisinden kötü olmaz, port döneminin damgaları da kaybolmaz —
// cihaz ilerideyse sunucuya yetiştirilir.
//
// **KARAR İKİ PLATFORMDA AYNI OLMAK ZORUNDA.** `test/chat_read_test.dart`
// web'in `scripts/verify-chat-read.ts` vakalarının birebir aynısını koşar;
// biri değişirse öteki de.
//
// Tek bilinçli fark: web damgaları metin olarak saklıyor ve eşitliği metinle
// ölçüyor; port cihaz damgasını milisaniye (int) saklıyor. Karşılaştırma iki
// tarafta da milisaniye düzeyinde (web `Date.parse`), eşitlik de burada
// milisaniyeyle ölçülüyor — aksi halde sunucunun mikro saniyeli damgası ile
// cihazın milisaniyeye kırpılmış aynı damgası her yüklemede "farklı" sayılır
// ve boşuna bir yazma üretirdi.

class ChatReadRow {
  final String senderUserId;
  final String createdAt;
  const ChatReadRow({required this.senderUserId, required this.createdAt});
}

/// Sunucudaki damganın bilinen hâli. `at == null` = sunucuda satır YOK
/// (kesin). Değerin KENDİSİ `null` ise (bkz. [decideChatRead]) = BİLİNMİYOR
/// (istek düştü / çevrimdışı) — web'in `null` ↔ `undefined` ayrımı.
typedef ServerChatRead = ({String? at});

class ChatReadDecision {
  /// Okunmamış sayısı (kendi mesajlarım hariç).
  final int unread;

  /// Cihaza yazılacak damga, yazılmayacaksa `null`.
  final String? writeLocal;

  /// Sunucuya gönderilecek damga, gönderilmeyecekse `null`.
  final String? pushToServer;

  const ChatReadDecision({
    required this.unread,
    required this.writeLocal,
    required this.pushToServer,
  });
}

/// Geçersiz damga en küçük sayılır (web `-Infinity`).
int? _ms(String? iso) =>
    iso == null ? null : DateTime.tryParse(iso)?.millisecondsSinceEpoch;

bool _after(String b, String a) {
  final mb = _ms(b), ma = _ms(a);
  if (mb == null) return false;
  if (ma == null) return true;
  return mb > ma;
}

bool _sameInstant(String? a, String? b) {
  if (a == null || b == null) return a == b;
  return _ms(a) == _ms(b);
}

/// İki damgadan büyüğü (biri yoksa öteki; eşitse ilki).
String? laterOf(String? a, String? b) {
  if (a == null || a.isEmpty) return (b == null || b.isEmpty) ? null : b;
  if (b == null || b.isEmpty) return a;
  return _after(b, a) ? b : a;
}

/// Görülen en son mesajın `created_at`i, mesaj yoksa `null`.
String? latestMessageAt(Iterable<ChatReadRow> rows) {
  String? best;
  for (final r in rows) {
    best = laterOf(best, r.createdAt);
  }
  return best;
}

/// Cihazdaki milisaniye damgasının karara giren metin hâli.
String? localStampIso(int? ms) => ms == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();

/// [server] `null` = sunucu BİLİNMİYOR; `(at: null)` = sunucuda satır yok.
ChatReadDecision decideChatRead({
  required ServerChatRead? server,
  required String? localAt,
  required List<ChatReadRow> rows,
  required String myUserId,
  required String nowIso,
}) {
  final serverAt = server?.at;
  final known = laterOf(serverAt, localAt);

  // Hiçbir yerde damga yok → özellik yeni devreye girmiş sayılır: mevcut
  // geçmiş okunmuş kabul edilir (eski "ilk ziyaret" kuralı). Sunucuya
  // YALNIZCA sunucu da KESİN boşsa yazılır — bilinmiyorken yazmak, sunucudaki
  // gerçek (daha eski) damganın üstüne "hepsi okundu" basmak olurdu ve sunucu
  // yalnızca ileri gittiği için bu GERİ ALINAMAZ.
  if (known == null) {
    final seed = latestMessageAt(rows) ?? nowIso;
    return ChatReadDecision(
      unread: 0,
      writeLocal: seed,
      pushToServer: (server != null && serverAt == null) ? seed : null,
    );
  }

  final unread = rows
      .where((r) => r.senderUserId != myUserId && _after(r.createdAt, known))
      .length;

  final localIsKnown = localAt != null && _sameInstant(localAt, known);
  return ChatReadDecision(
    unread: unread,
    // Sunucu daha ilerideyse (başka cihazda okunmuş) cihaz yetişir.
    writeLocal: localIsKnown ? null : known,
    // Cihaz daha ilerideyse (çevrimdışı okunmuş / port dönemi damgası) sunucu
    // yetişir. Sunucu bilinmiyorken de denenir: sunucu yalnızca İLERİ
    // gittiğinden gerçek bir okumayı göndermek hiçbir durumda zarar vermez.
    pushToServer:
        localIsKnown && !_sameInstant(serverAt, known) ? localAt : null,
  );
}
