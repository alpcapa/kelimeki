// Bir oyunun katılımcılarını yan yana (hafif üst üste binen) küçük
// avatarlar olarak gösterir — web `PlayerAvatarRow.tsx` portu.
//
// Kartlarda "N Kişilik Oyun" KALIN BAŞLIK SATIRININ yerine geçer; avatar
// sayısı zaten oyuncu sayısını verdiğinden çağıranlar oyuncuların TAMAMINI
// (kendileri dahil) geçer — yalnızca rakipleri göstermek 4 kişilik bir
// oyunda kaç kişilik olduğunu kaybettirirdi.
//
// ÜÇ çağrı yeri var ve girdileri FARKLI: Setup'ın devam eden oyun satırı
// canlı `Player` listesinden, Canlı sekmesinin "Devam Edenler" kartı
// (`live_games_tab`) canlı koltuklardan, "Son Oynananlar" ise dondurulmuş
// `games.players` anlık görüntüsünden besleniyor. Web'de de tek bileşen üç
// yeri besliyor; ortak biçim `AvatarRowPlayer`.
//
// ⚠ Bu satır 2 Eylül 2026'ya kadar "İki çağrı yeri var" diyordu ve BAYATTI —
// Canlı kartı sonradan eklenmiş, yorum güncellenmemişti. Boyut değiştirmeye
// gelen biri kapsamı eksik ölçerdi.
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import '../../util/score_line.dart';
import '../auth/k_avatar.dart';
import '../tokens.dart';

const _border = kBorder;
const _muted = kMuted;

/// Avatar çapı — `PlayerAvatarRow`un varsayılanı ve puan satırının dayanağı.
const double kAvatarRowSize = 26;

/// Komşu avatarların BİNİŞMESİ. 6 Eylül 2026'ya kadar `build`ın içinde yerel
/// bir `const`tı; puan satırı hizasını buradan türettiğinden dosya düzeyine
/// çıktı — iki yerde iki değer olsaydı hiza sessizce kayardı (web ikizinde
/// de `AVATAR_ROW_OVERLAP = 6`).
const double kAvatarRowOverlap = 6;

/// Web `bg-void` — robot avatarının zemini.
const _void = kVoid;

class AvatarRowPlayer {
  final String name;

  /// Yalnızca gerçek üyelerde dolu olabilir.
  ///
  /// ⚠ Burada "dondurulmuş snapshot BİLEREK avatar taşımadığından orada hep
  /// null → baş harf" yazılıydı; 2 Eylül 2026'da DEĞİŞTİ. Snapshot hâlâ
  /// avatar taşımıyor ama "Son Oynananlar" artık avatarı BAŞKA yoldan
  /// çözüyor (`games.online_game_id` → bitmiş oyunun canlı koltukları;
  /// yerel oyunlarda hesabın kendi avatarı). Kural:
  /// `util/recent_game_avatars.dart`.
  final String? avatarUrl;

  /// YZ koltuğu — baş harf yerine robot. "YZ" baş harfi üretmek onu gerçek
  /// bir üye gibi gösteriyordu (web'in aynı kararı).
  final bool isAi;

  /// Misafir koltuk (yalnızca yerel oyunlarda mümkün; Canlı'da herkes
  /// kayıtlı). `GameState`'e literal "Misafir" gömüldüğünden baş harf "MI"
  /// çıkıp misafiri üye gibi gösteriyordu — bu bayrak `KAvatar`'ın boş-isim
  /// yedeğini ("?") seçtirir, yeni bir görsel icat edilmedi.
  final bool isGuest;

  const AvatarRowPlayer({
    required this.name,
    this.avatarUrl,
    this.isAi = false,
    this.isGuest = false,
  });
}

class PlayerAvatarRow extends StatelessWidget {
  final List<AvatarRowPlayer> players;

  /// Web'le aynı **26px** (2 Eylül 2026, kullanıcı isteği: "avatarları biraz
  /// daha büyütelim"). Öncesi 20'ydi; 16px'te baş harfler okunamaz hâle
  /// geliyor, o taban hâlâ geçerli.
  ///
  /// ⚠ **ÜST SINIR ÖLÇÜLDÜ:** şerit `Expanded` bir alanın içinde ve yazı
  /// ölçeği tavanında o alan 320 px'lik ekranda **92,5 px**'e iniyor
  /// (`setup_screen_test`, CI ölçümü). 4 oyunculu bir oyunda şeridin eni
  /// `size + 3*(size - overlap)`; 26/6 ile **86 px** (6,5 px marj). Aynı
  /// boyut ESKİ 4 px bindirmeyle 92 px ederdi — yani 0,5 px marj, pratikte
  /// taşma. Bindirme bu yüzden 6'ya çıktı; boyutu büyütürken İKİSİNİ
  /// birlikte hesapla.
  final double size;

  const PlayerAvatarRow(
      {super.key, required this.players, this.size = kAvatarRowSize});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return SizedBox(height: size);
    // 4 → 6 (2 Eylül 2026): avatar 20 → 26 olurken şeridin toplam eni
    // sabit kalsın diye — gerekçe ve ölçüm `size` alanının yorumunda.
    final step = scoreCellWidth(size, kAvatarRowOverlap);
    return SizedBox(
      width: size + (players.length - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < players.length; i++)
            Positioned(
              left: i * step,
              child: _Avatar(player: players[i], size: size),
            ),
        ],
      ),
    );
  }
}

/// ⚠ APPLE COLOR EMOJI'NİN MÜREKKEBİ KENDİ KUTUSUNDA ORTALI DEĞİL
/// (15 Eylül 2026, kullanıcı iPhone'da bildirdi: *"YZ robot avatarı iPhone ve
/// iPad'de ortalı değil"*).
///
/// `Container(alignment: center)` metnin KUTUSUNU ortalar; kutu = glif'in
/// ilerleme genişliği (advance) ve satır kutusu. Apple Color Emoji'de ikisi de
/// mürekkebe göre asimetrik: advance ≈ 1,26 em ama mürekkep 1,0 em ve SOLA
/// yaslı; dikeyde de taban çizgisi mürekkebi kutunun altına itiyor.
///
/// **ÖLÇÜLDÜ — kullanıcının 1170×2532 iPhone ekran görüntüsünden**, daire
/// maskesiyle (mühür testinin yöntemi), iki ayrı kartta İKİ yalıtık robot,
/// dördü de birebir aynı: mürekkep 42×43 px (font 42 px = 14 pt), merkezi
/// daireye göre **yatayda −0,131 em, dikeyde +0,083 em**. Aşağıdaki değerler
/// bunun tersi, yani düzeltme.
///
/// ⚠ **YALNIZCA APPLE fontunda uygulanır.** Aynı ölçüm Linux/Noto Color
/// Emoji'de **0,00 em** verdi (300 px kutuda 1 px), yani Android'de sapma YOK
/// ve koşulsuz bir kaydırma orayı BOZARDI.
///
/// ⚠ Bu bir "boşluk ayarı" değil, ÖLÇÜLMÜŞ bir font metriği telafisi —
/// `RankSeal`in `sealBaselineEm`i ile aynı sınıf (orada da harfin mürekkebi
/// font metriğiyle ortalanmıyordu). Apple metriklerini değiştirirse bu sabit
/// bayatlar; doğrulaması cihazda (`mobile/TESTING.md` §29).
const double kAppleEmojiNudgeXEm = 0.131;
const double kAppleEmojiNudgeYEm = -0.083;

/// Apple Color Emoji kullanan platformlar — düzeltme yalnızca burada.
bool get _appleEmoji =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class _Avatar extends StatelessWidget {
  final AvatarRowPlayer player;
  final double size;
  const _Avatar({required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    if (player.isAi) {
      // Web `bg-void border-border` zemin + gerçek 🤖 emoji (Material
      // `Icons.smart_toy_outlined` ikonuyla İLK PORTTA yanlışlıkla
      // değiştirilmişti — tamamen farklı bir şekil; web'de font-fallback
      // gerektiren bir glyph değil, düz Unicode emoji, bu yüzden ★/✓
      // kararlarındaki gibi bir ikon ikamesine hiç gerek yoktu).
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _void,
          border: Border.all(color: _border),
          shape: BoxShape.circle,
        ),
        child: Builder(builder: (_) {
          final fs = (size * 0.55).roundToDouble();
          return Transform.translate(
            // Düzeltme LAYOUT'A DOKUNMAZ (Transform yalnızca boyar) — daire,
            // satır adımı ve puan sütunu bitine kadar aynı kalır.
            offset: _appleEmoji
                ? Offset(kAppleEmojiNudgeXEm * fs, kAppleEmojiNudgeYEm * fs)
                : Offset.zero,
            child: Text(
              '🤖',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fs,
                height: 1,
                fontFamilyFallback: const [
                  'Noto Color Emoji',
                  'Apple Color Emoji',
                ],
              ),
            ),
          );
        }),
      );
    }
    // Misafir koltuk (isGuest) da dahil — `KAvatar`'a boş isim geçirmek
    // onun zaten var olan "?" yedeğini (mavi zemin, web `Avatar.tsx`'in
    // fallback stiliyle BİREBİR) seçtiriyor; ayrı bir gri/nötr kopya
    // ARTIK YOK (KAvatar'ın kendi yedek rengi düzeltilince bu ikisinin
    // ayrışmaması için buraya delege edildi).
    return KAvatar(
      url: player.avatarUrl,
      name: player.isGuest ? '' : player.name,
      size: size,
    );
  }
}

/// Avatar şeridinin ALTINDAKİ puan satırı — her puan kendi avatarının tam
/// altında (6 Eylül 2026, kullanıcı kararı "C hizalı"; gerekçe ve formül
/// `util/score_line.dart`). Üç kart da bunu kullanıyor: Setup'ın YZ kaydı,
/// Canlı "Devam Edenler" ve "Son Oynadıklarım". Web ikizi `AvatarScoreRow`.
///
/// ⚠ Ayırıcı YOK. İlk sürüm `45 - 38` diye tek bir dizeydi; tire, "45 38"in
/// tek sayı gibi okunmasını engellemek içindi. Hizalı düzende o işi sütun
/// yapıyor.
///
/// ⚠ **`ScaledCell` DEĞİL, sabit en + `FittedBox`** — ve bu, kök
/// `CLAUDE.md`in "sabit genişlikli sütunda `ScaledCell` kullan" kuralının
/// BİLİNÇLİ istisnası: `ScaledCell` kutuyu yazı ölçeğiyle büyütür, oysa
/// üstteki AVATARLAR ölçekle büyümüyor (sabit 26 px). Hücre büyüseydi hiza
/// tam da tavanda (`kMaxTextScale`) kayardı — yani kuralın amacı (sarma/
/// taşma yok) burada `FittedBox(scaleDown)` ile karşılanıyor, kutuyu
/// büyüterek değil. Ölçüm: 8 px × 1,3 = 10,4 px, üç hane ≈ 18,8 px < 20 px,
/// yani tavanda bile küçültmeye gerek kalmıyor.
class AvatarScoreRow extends StatelessWidget {
  /// Koltuk sırasıyla puanlar — üstteki `PlayerAvatarRow`un dizisiyle AYNI
  /// sıra (sıralama/rank DEĞİL).
  final List<int> scores;
  final double size;

  const AvatarScoreRow(
      {super.key, required this.scores, this.size = kAvatarRowSize});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();
    final cell = scoreCellWidth(size, kAvatarRowOverlap);
    return Padding(
      padding: EdgeInsets.only(left: scoreRowOffset(kAvatarRowOverlap)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in scores)
            SizedBox(
              width: cell,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$s',
                    maxLines: 1,
                    softWrap: false,
                    // Harf aralığı YOK (kalan-süre satırının 0,5'i burada
                    // uygulanmıyor): 20 px'lik hücrede üç haneli puanlar
                    // komşusuna değmesin diye.
                    style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 8, color: _muted)),
              ),
            ),
        ],
      ),
    );
  }
}
