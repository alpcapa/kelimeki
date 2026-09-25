// Çalışan bir yerel (YZ) oyunun OTURUMA tepki veren kabuğu — web
// `App.tsx`teki İKİ effect'in port ikizi. Portta bu iki effect hiç yoktu ve
// ikisinin yokluğu 15 Eylül 2026'da tek bir cihaz turunda birden görüldü
// (TestFlight 1.1.0/665, `Derleme 9c62289`):
//
//   Kullanıcı misafir olarak 4 kişilik bir oyun başlattı, oyunun ORTASINDA
//   (oyun ekranındaki GİRİŞ düğmesinden) giriş yaptı, oyunu bitirdi. Oyun
//   sonu ekranı kazananın karşısında hâlâ "Misafir" yazıyordu; Setup'a
//   dönünce AYNI oyun "Devam Eden Oyunlar"da, girişin yapıldığı ANDAKİ
//   skorlarla (yani girişten sonrası hiç oynanmamış gibi) duruyordu.
//   Tekrar bitirince bu kez doğru isimle göründü ve listeden düştü.
//
// İki ayrı kusur, tek tetikleyici (oyun içinde giriş):
//
// 1. **İsim.** Oyun `Setup`ta `players[0].name: 'Misafir'` literal'iyle
//    kuruluyor ve motor state'ine gömülüyor. Web'de bunu düzelten bir effect
//    var (`App.tsx` → *"Oyun devam ederken giriş yapılırsa 1. oyuncunun
//    adını güncelle"* → `RENAME_PLAYER`); portta `RenamePlayerAction` motorda
//    VARDI ama `mobile/app` içinde onu dispatch eden TEK bir satır yoktu.
//
// 2. **Kayıt hedefi.** Web'in autosave effect'i `[state, savedGame, user]`e
//    bağlı: `user` dolduğu an hedef localStorage'dan `local_game_saves`e
//    GEÇİYOR ve misafir kaydı siliniyor (`if (user && isSupabaseConfigured)
//    clearGameState()`). Port ise hedefi oyun AÇILIRKEN bir kez seçiyordu
//    (`SetupScreen._openGame`): giriş sonrası oyun misafir slotuna yazmaya
//    devam ediyor, bu arada Setup'ın auth dinleyicisi `migrateGuestSave` ile
//    o slotun O ANKİ kopyasını buluta TAŞIYORDU. Sonuç: buluta bir kez
//    yazılıp bir daha GÜNCELLENMEYEN bayat bir satır. Oyun bitince misafir
//    slotu siliniyor ama bulut satırı kimsenin silmediği bir hayalete
//    dönüşüyor — kullanıcının gördüğü tam olarak buydu.
//
// Bu sınıf ikisini de TEK yerde toplar (web'de de ikisi App.tsx'te): oturum
// değişimini dinler, kayıt oturumunu (misafir ↔ bulut) devreder ve 1.
// oyuncunun adını hesap adıyla eşitler.
//
// ⚠ Devrin yarışsız olması için ikinci bir kural gerekiyor ve o kural
// `SetupScreen`'de: **oyun ekranı açıkken `migrateGuestSave` KOŞMAZ.**
// Misafir slotu o sırada çalışan oyunun kendi defteridir; devri bu sınıf
// yapar. Aksi halde iki dinleyici (Setup'ınki ve buradaki) aynı bildirimde
// aynı slota koşar ve sıralama garanti edilemez.
import 'package:kelimeki_core/kelimeki_core.dart';

import '../data/auth_service.dart';
import '../data/cloud_save_repo.dart';
import 'game_controller.dart';
import 'local_game_repo.dart';

class GameSessionHost {
  final GameController controller;
  final AuthService auth;

  /// Misafir slotunun sahibi. null → misafir kalıcılığı hiç yok (testler,
  /// depo açılamadıysa).
  final LocalGameRepo? guestRepo;

  /// Bulut kayıtları. null → Supabase yapılandırılmamış; web'in
  /// `isSupabaseConfigured` koşulunun eşleniği, giriş yapılsa bile misafir
  /// slotu kullanılmaya devam eder.
  final CloudSaveRepo? cloud;

  /// `CloudGameSession`'ın debounce süresi — testler `Duration.zero` geçip
  /// gerçek zaman kaybetmeden yazmayı gözler (motorun `aiThinkDelay`
  /// sözleşmesiyle aynı desen). Üretimde dokunulmaz.
  final Duration cloudDebounce;

  GameSession? _guest;
  CloudGameSession? _cloud;

  /// Devirde başlatılan misafir-slotu silmesi — `end()` onu da bekler ki
  /// ekrandan çıkışta iş gerçekten bitmiş olsun.
  Future<void>? _guestClear;

  /// O an kayıt yazan oturumun sahibi (null = misafir). Oturum TÜRÜNÜ buna
  /// göre değiştiririz; `auth.user` her bildirimde aynı kimlikle de gelebilir
  /// (profil yüklendi, token tazelendi) ve o durumda oturuma DOKUNULMAMALI —
  /// aksi halde her profil güncellemesi yeni bir bulut satırı açardı.
  String? _sessionUserId;
  bool _started = false;
  bool _ended = false;

  GameSessionHost({
    required this.controller,
    required this.auth,
    this.guestRepo,
    this.cloud,
    String? resumeCloudId,
    this.cloudDebounce = const Duration(milliseconds: 600),
  }) {
    final user = auth.user;
    if (user != null && cloud != null) {
      _cloud = CloudGameSession(controller, cloud!, user.id,
          resumeSaveId: resumeCloudId, debounce: cloudDebounce);
      _sessionUserId = user.id;
    } else {
      _guest = guestRepo?.attach(controller);
    }
    _started = true;
    auth.addListener(_onAuth);
    // Web'de effect gövdesi ilk render'da da koşar: buluttan devam edilen,
    // giriş öncesinde "Misafir" adıyla yazılmış bir kaydın adı daha ilk
    // karede düzelsin diye aynısı burada da bir kez elle koşturulur.
    _syncPlayerName();
  }

  /// Test/teşhis: o an bulut satırını yazan oturumun id'si (yoksa null).
  String? get cloudSaveId => _cloud?.saveId;

  /// Test/teşhis: misafir slotuna yazan bir oturum var mı.
  bool get isGuestSession => _guest != null;

  void _onAuth() {
    if (_ended || !_started) return;
    _syncSessionTarget();
    _syncPlayerName();
  }

  /// Web autosave effect'inin `user` dalının eşleniği — hedef, oturum
  /// durumuna göre CANLI olarak değişir.
  void _syncSessionTarget() {
    final user = auth.user;
    final c = cloud;
    final nextUserId = (user != null && c != null) ? user.id : null;
    if (nextUserId == _sessionUserId) return;

    if (nextUserId != null) {
      // Giriş (ya da hesap değişimi). SIRA ÖNEMLİ: önce bulut oturumu kurulur
      // — yapıcısı mevcut state'i hemen kuyruğa alır —, ANCAK ONDAN SONRA
      // misafir slotu silinir. Ters sırada, giriş ile ilk bulut yazması
      // arasındaki (debounce kadar) pencerede uygulama öldürülürse oyunun
      // TEK kopyası silinmiş olurdu. (Web de aynı pencereyi taşıyor:
      // `clearGameState()` hemen, bulut yazması 600 ms debounce'lu.)
      _guest?.detach();
      _guest = null;
      _cloud?.detach();
      _cloud = CloudGameSession(controller, c!, nextUserId,
          debounce: cloudDebounce);
      final repo = guestRepo;
      // ⚠ Slot YALNIZCA çalışan oyun onu gerçekten yazmışsa silinir
      // (`turnCount >= 2`, autosave'in kendi eşiği). Daha erken bir girişte
      // slotta teorik olarak ÖNCEKİ bir misafir oyunu durabilir ve onu
      // silmek gerçek bir kaydı yok etmek olurdu. Bugün buna ulaşmak zor:
      // kayıt varken Setup yeni oyun formunu hiç çizmiyor (anti-kaçış
      // kuralı), yani iki oyun aynı anda var olamıyor. Kapı yine de ucuz ve
      // o kuralın bir gün gevşemesine karşı slotu sahipsiz bırakmıyor:
      // ekrandan dönüşte `SetupScreen` migrasyon kapısını açar ve bekleyen
      // kayıt normal yoldan hesaba taşınır. (Web burada farklı: orada
      // `clearGameState()` koşulsuz çağrılıyor — aynı anti-kaçış kuralı
      // sayesinde pratikte fark üretmiyor.)
      if (repo != null && controller.state.turnCount >= 2) {
        _guestClear = repo.clearSave();
      }
    } else {
      // Çıkış: bulut satırına DOKUNULMAZ (web'de de autosave yalnızca yazmayı
      // bırakır; satır "Devam Eden Oyunlar"da kalır ve 7 günlük süpürmeye
      // tabidir), oyun misafir slotundan devam eder.
      _cloud?.detach();
      _cloud = null;
      _guest = guestRepo?.attach(controller);
    }
    _sessionUserId = nextUserId;
  }

  /// Web: *"Oyun devam ederken giriş yapılırsa 1. oyuncunun adını güncelle"*
  /// (`App.tsx`, `RENAME_PLAYER`). Koşullar birebir: yalnızca `play`
  /// fazında, yalnızca hesap adı KESİNLEŞMİŞSE (`accountName` profil
  /// yüklenene kadar null döner — erken koşulsa "Misafir" yerine e-posta
  /// öneki yazılabilirdi), yalnızca 1. oyuncu insan ve adı farklıysa.
  void _syncPlayerName() {
    if (controller.state.phase != GamePhase.play) return;
    final name = auth.accountName;
    if (name == null || name.isEmpty) return;
    final players = controller.state.players;
    if (players.isEmpty) return;
    final p0 = players[0];
    if (p0.isAI || p0.name == name) return;
    controller.dispatch(RenamePlayerAction(index: 0, name: name));
  }

  /// Ekrandan çıkış — aktif oturumun `end()`i (bekleyen yazmaların flush'ı
  /// dahil) ve devirde başlatılan silme beklenir.
  Future<void> end() async {
    if (_ended) return;
    _ended = true;
    auth.removeListener(_onAuth);
    await _guest?.end();
    await _cloud?.end();
    await _guestClear;
  }
}
