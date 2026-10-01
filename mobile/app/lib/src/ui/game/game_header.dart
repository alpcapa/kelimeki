// Oyun başlığı — src/components/GameHeader.tsx portu: solda logo (dokunuş =
// oyundan çık), sağda oyuncu skor kutuları + hesap kontrolü (AccountButton:
// GİRİŞ / avatar-menü — web UserMenu). Web'in akıcı clamp() sistemi
// (375px'te min → 465px'te max) burada fluidSize() ile birebir hesaplanır.
import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart';

import '../../data/auth_service.dart';
import '../../data/chat_api.dart';
import '../../data/feedback_api.dart';
import '../../data/friends_api.dart';
import '../../data/games_api.dart';
import '../../data/stats_api.dart';
import '../auth/account_button.dart';
import '../../util/onboarding.dart';
import 'hint_bubble.dart';
import '../tap_target.dart';
import '../tokens.dart';
import 'fluid.dart';
import 'logo_mark.dart';
import 'player_colors.dart';

/// "← Geri" etiketi — web `GameHeader.tsx`in BACK_FONT_SIZE/BACK_GAP'i.
/// İnce (normal ağırlık) ve KOYU (paletin ana metin rengi); kullanıcı
/// gri ve siyah varyantları yan yana görüp siyahı seçti (21 Ağustos 2026).
/// Web'le ELLE senkron — biri değişirse öteki de değişmeli.
const double kBackFontSize = 11;

/// Logo ile "← Geri" arası — web `BACK_GAP`. 1 Ekim 2026'ya kadar etiket
/// ayrı bir satırdı (`kBackBottomPad` = 13'lük dokunma payıyla) ve başlığı
/// web'den 25 px uzatıyordu; artık web'deki gibi logonun altına taşıyor.
const double kBackGap = 3;

class GameHeader extends StatelessWidget {
  final GameState state;
  final VoidCallback? onLogoTap;

  /// Hesap durumu — verilmezse ya da Supabase yapılandırılmamışsa hesap
  /// kontrolü hiç çizilmez (web'de UserMenu'nun `!configured → null`
  /// davranışı; testler/salt önizlemeler auth geçirmeyebilir).
  final AuthService? auth;

  /// Hesap menüsündeki k-lig/Skor Kartı satırları için (null ise
  /// gösterilmez — offline mod).
  final StatsRepo? stats;

  /// Hesap menüsünden açılan skor kartındaki geçmiş linki için.
  final Future<GamesRepo>? games;

  /// Hesap zincirindeki Terms/Privacy içi "Görüş Bildir formu" linki için
  /// (AccountButton → AuthModal'a iletilir).
  final FeedbackRepo? feedback;

  /// Hesap menüsündeki "Arkadaşlar" satırı + rozet için.
  final FriendsRepo? friends;
  final ChatRepo? chat;

  /// Verilirse insan koltuklarının kutuları tıklanabilir olur (Canlı oyunda
  /// skor kartı — web onPlayerClick'in eşleniği; yerel oyunda verilmez).
  final void Function(int index)? onPlayerTap;

  /// Avatarı işaret eden eğitim balonu (1 Ekim 2026) — web
  /// `GameHeader.menuHint`. Kararı ekran verir (`pickOnboardingHint`).
  final bool menuHint;

  const GameHeader({
    super.key,
    required this.state,
    this.onLogoTap,
    this.onPlayerTap,
    this.menuHint = false,
    this.auth,
    this.stats,
    this.games,
    this.feedback,
    this.friends,
    this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    // Web sabitleri (GameHeader.tsx) — aynı katsayılar.
    final playerBoxWidth = fluidSize(w, 43, -52.83, 25.56, 66);
    final yzBoxWidth = fluidSize(w, 28, -34.5, 16.67, 43);
    final labelFontSize = fluidSize(w, 6, -2.33, 2.22, 8);
    final scoreFontSize = fluidSize(w, 13, -7.83, 5.56, 18);
    final boxPaddingX = fluidSize(w, 1.5, -6.83, 2.22, 3.5);
    final boxGap = fluidSize(w, 4, -4.33, 2.22, 6);
    final boxPaddingY = fluidSize(w, 2.7, -0.63, 0.89, 3.5);
    final logoHeight = fluidSize(w, 28, -5.33, 8.89, 36);
    // UserMenu.tsx'in GIRIS_* sabitleri — Giriş butonu skor kutularıyla aynı
    // satırda/aynı akıcı sistemde büyür.
    final girisFontSize = fluidSize(w, 8, -4.5, 3.33, 11);
    final girisPaddingX = fluidSize(w, 6, -2.33, 2.22, 8);
    final girisPaddingY = fluidSize(w, 8.7, -5.05, 3.67, 12);

    // GEOMETRİ WEB'İN BİREBİR AYNISI (1 Ekim 2026, yatay iPad cihaz turu):
    // `px-3 py-2.5` + öğelerin DOĞAL boyu, "← Geri" logonun altına taşan
    // ve yer KAPLAMAYAN bir etiket (web `absolute top-full`, BACK_GAP 3).
    // Ölçüldü (1180×820): web başlığı 57, kartın üstü 63; port eskiden 88'di
    // (48'lik satır + ayrı "← Geri" satırı) ve alt düğmeler cihazda ekran
    // dışına taşıyordu (kullanıcı: *"Web'e baktın mı? Orada düzgün"*).
    //
    // Dokunma alanı 48'lik kutulardan DEĞİL satırın kendisinden geliyor:
    // `IntrinsicHeight` + `stretch` her öğeyi başlığın TAM boyuna (dolgu
    // dahil ~56-57) geriyor, görsel ortada kalıyor; `TapTargetScope` başlık
    // içindeki `TapTarget`lerin 48'lik asgari YÜKSEKLİĞİNİ kaldırıyor (yoksa
    // satırı yine uzatırlardı). Böylece logo, skor kutuları ve avatar
    // eskisinden DAHA uzun bir dokunma alanı alıyor (56 ≥ 48).
    //
    // "← Geri"nin geçmişi (24 Ağustos 2026, iki tur): Flutter'da bir
    // kutunun DIŞINA taşan çocuk dokunuş ALMAZ — ilk denemede etiket hiç
    // çalışmamıştı. Burada etiket logo öğesinin İÇİNDE ve o öğe başlığın
    // tam boyuna gerildiğinden etiketin üst ~3/4'ü dokunma alanında; alt
    // ~3,5 px'i (web'de de) başlığın altına, tahtanın 6 px'lik üst
    // dolgusuna taşıyor. Logonun kendisi aynı eylem için tam boy bir hedef.
    Widget dolgulu(Widget w) =>
        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: w);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TapTargetScope(
        minHeight: 0,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TapTarget(
                key: const ValueKey('header-logo'),
                onTap: onLogoTap,
                child: dolgulu(Stack(
                  clipBehavior: Clip.none,
                  children: [
                    LogoMark(height: logoHeight),
                    Positioned(
                      left: 0,
                      top: logoHeight + kBackGap,
                      child: const Text(
                        '← Geri',
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: kBackFontSize,
                          height: 1,
                          color: kText,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              const SizedBox(width: 8),
              // Web justify-between'in ikinci çocuğu tek bir SAĞ GRUP:
              // kutular + GİRİŞ/avatar birbirine bitişik (gap-2) ve sağa
              // yaslı — artan boşluk logo ile kutuların ARASINA düşer.
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Web güvenlik ağıyla aynı: sığmazsa şerit görünmez
                    // biçimde yatay kaydırılır, 0. kutu her zaman
                    // erişilebilir. GİRİŞ/avatar bu kaydırma kabının
                    // DIŞINDA (web'de dropdown kırpılıyordu).
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < state.players.length; i++) ...[
                              if (i > 0) SizedBox(width: boxGap),
                              _PlayerBox(
                                player: state.players[i],
                                index: i,
                                active: i == state.current,
                                width: state.players[i].isAI
                                    ? yzBoxWidth
                                    : playerBoxWidth,
                                paddingX: boxPaddingX,
                                paddingY: boxPaddingY,
                                labelFontSize: labelFontSize,
                                scoreFontSize: scoreFontSize,
                                onTap: (onPlayerTap != null &&
                                        !state.players[i].isAI)
                                    ? () => onPlayerTap!(i)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (auth != null && auth!.configured) ...[
                      const SizedBox(width: 8),
                      HintAnchor(
                        show: menuHint,
                        text: onboardingHintTexts[OnboardingHintId.menu]!,
                        yon: HintBubbleYon.alt,
                        hiza: HintBubbleHiza.son,
                        child: AccountButton(
                          auth: auth!,
                          stats: stats,
                          games: games,
                          feedback: feedback,
                          friends: friends,
                          chat: chat,
                          girisFontSize: girisFontSize,
                          girisPaddingX: girisPaddingX,
                          girisPaddingY: girisPaddingY,
                          avatarSize: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerBox extends StatelessWidget {
  final Player player;
  final int index;
  final bool active;
  final double width;
  final double paddingX;
  final double paddingY;
  final double labelFontSize;
  final double scoreFontSize;
  final VoidCallback? onTap;

  const _PlayerBox({
    required this.player,
    required this.index,
    required this.active,
    required this.width,
    required this.paddingX,
    required this.paddingY,
    required this.labelFontSize,
    required this.scoreFontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final col = playerColors[player.colorIndex % playerColors.length];
    final label = player.isAI ? 'YZ ${index + 1}' : trUpper(player.name);

    // Teslim gösterimi (kullanıcı kararı, 6 Ağustos 2026 — web'le BİRLİKTE
    // netleştirildi, iki taraf aynı): kutu diğerleriyle aynı boy/renk/
    // çerçevede kalır, puan alanında skor satırını dolduran boyutta TESLİM
    // yazar (yükseklik SizedBox'la skora sabit, metin FittedBox'la sığar)
    // ve kutunun tamamı %45 soluklaştırılır (aşağıdaki Opacity).
    final box = Container(
      key: ValueKey('player-box-$index'),
      width: width,
      padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: paddingY),
      decoration: BoxDecoration(
        color: col.tint,
        borderRadius: BorderRadius.circular(6),
      ),
      // Çerçeve foregroundDecoration'da: web'deki `outline` dersiyle aynı
      // sebep — aktif/pasif kalınlık farkı (2/0.5px) iç içerik genişliğini
      // değiştirirse dar YZ kutusunda 3 haneli skor kırpılır. Flutter'da
      // BoxDecoration.border da içeriden yer kapladığından çerçeve layout'a
      // hiç dokunmayan ön katmana çizilir.
      // 30 Ağustos 2026 — pasif kalınlık 0.5 → 1, web ikiziyle birlikte.
      // Sebep webde ölçüldü (kullanıcının iPhone ekran görüntüsü, DPR 3):
      // 0.5 px'lik çerçeve 1,5 CİHAZ pikseli demek ve kutu genişliği kesirli
      // olduğundan iki kenar farklı alt-piksel fazına düşüyor — biri çiziliyor,
      // öteki açık zeminde kayboluyor (ölçülen kontrast farkı 272 ↔ 14).
      // Flutter da 0.5'i yuvarlamaz, yani aynı kırılganlık burada da vardı;
      // uygulamada henüz görülmemiş olması fazın şanslı düşmesiydi.
      // Aktif/pasif ayrımı 2 ↔ 1 olarak korunuyor. Bkz. GameHeader.tsx.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: col.base, width: active ? 2 : 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontWeight: FontWeight.bold,
              fontSize: labelFontSize,
              letterSpacing: 1,
              color: col.base,
            ),
          ),
          SizedBox(
            height: scoreFontSize, // skor satırıyla (height:1) aynı boy
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player.surrendered ? 'TESLİM' : '${player.score}',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontWeight: FontWeight.bold,
                    fontSize: scoreFontSize,
                    height: 1,
                    // Skor SAYISI siyah (token `text`), 28 Ağustos 2026
                    // kullanıcı isteği: oyuncu renginde okunması zordu.
                    // Kutunun geri kalanı — etiket, çerçeve, zemin —
                    // oyuncu renginde KALIYOR; istek birebir "sadece sayı"
                    // diyordu. 'TESLİM' bir sayı değil, o da renkte kalır.
                    color: player.surrendered ? col.base : kText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final dimmed = player.surrendered
        ? Opacity(opacity: 0.45, child: box) // web'le aynı soluklaştırma
        : box;
    // Kutu doğal boyunda, başlığın dikey dolgusu (10/10) İÇİNDE ve ortada;
    // başlık `stretch` ile her öğeyi tam boya gerdiğinden dokunma alanı
    // kutunun değil SATIRIN boyu (~56) — 1 Ekim 2026'ya kadar 48'lik
    // `TapTarget` satırı uzatıyordu (bkz. `GameHeader.build`). `minWidth: 0`:
    // genişlik akıcı sistemden geliyor, 48 dayatmak web paritesini bozardı.
    final slot = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(widthFactor: 1, heightFactor: 1, child: dimmed),
    );
    return onTap == null
        ? slot
        : TapTarget(onTap: onTap, minWidth: 0, child: slot);
  }
}
