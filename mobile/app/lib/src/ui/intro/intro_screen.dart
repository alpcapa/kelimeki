// Uygulamanın ilk açılış ekranı — web karşılamasının (`src/landing/
// Landing.tsx`) İLK EKRANININ portu.
//
// 1 Ekim 2026 — ROADMAP #41 karar 14 (kullanıcı kararı: *"Web'in yeni ilk
// ekranı gibi tek ekran"*). 19 Ağustos 2026'dan beri burada BEŞ slaytlık bir
// tanıtım vardı (kahraman + 2 kişilik tahta, rakamlar + 4 kişilik tahta,
// nasıl oynanır, neler var, k-lig). Web 27 Eylül'de ilk ekranını sadeleştirdi
// (karar 1: tek soru-başlık, bölge kuralını anlatan küçük kesit, tek düğme);
// uygulama da aynı ekrana geçti. Oyunun öğretilmesi artık 60 saniyelik
// raylı tanıtımın (`TutorialGame`) işi — kaydırılacak slayt yok, "insanlar
// tanıtımı kaydırmayı anlayamıyorlar" (26 Ağustos 2026) sorunu da kökten
// kalktı.
//
// Web'deki ilk ekranla BİREBİR (metinler `intro_screen_test` ile web
// kaynağına kilitli): logo · "TÜRKÇE KELİME OYUNU" · soru-başlık · tek
// cümlelik kural · 7×5 tahta kesiti (`bolge_kesiti.dart`) · HEMEN OYNA ·
// "Ücretsiz · Reklam yok · Üyelik gerekmez".
//
// BİLİNÇLİ FARKLAR (web'in sayfası SEO/paylaşım için de var, uygulamanınki
// değil):
// - Mağaza rozetleri YOK (zaten uygulamanın içindesin).
// - Web'in "Nasıl oynanır ↓"ı sayfanın altındaki bölüme kaydırıyor; burada
//   altta bölüm yok, aynı söz "NASIL OYNANIR?" olarak kural penceresini
//   (`HelpModal`) açıyor.
//
// SETUP BAŞLIĞINA GERİ OKU KONMADI (web'de var, portta YOK — bkz.
// mobile/CLAUDE.md "Karşılama Katmanı"). Bu ekrana dönüş Setup'ın logo
// altındaki "Tanıtım" linkinden (yalnız misafirde).
import 'package:flutter/material.dart';
import 'package:kelimeki_core/kelimeki_core.dart' show trUpper;

import '../../data/analytics.dart';
import '../game/fluid.dart';
import '../game/help_modal.dart';
import '../game/logo_mark.dart';
import '../game/neo_button.dart';
import '../tap_target.dart';
import '../tokens.dart';
import 'bolge_kesiti.dart';

// Web metinleri — `intro_screen_test` bunları `Landing.tsx`te arar.
const String kIntroUstBaslik = 'Türkçe kelime oyunu';
const String kIntroBaslik =
    'Kelimeyi bilmek yetmez. Nereye koyduğun kazandırır.';
const String kIntroKural =
    'Köşenden başla, bölgeni büyüt. Rakibinin bölgesine değersen puanını onunla paylaşırsın.';
const String kIntroDuz = 'Ücretsiz · Reklam yok · Üyelik gerekmez';
const String kIntroOyna = 'Hemen Oyna';

/// Metin sütununun genişliği — web `max-w-[460px] px-4`. Setup ile AYNI.
const double _kMetinGenisligi = 460;

/// Uzun ekranda düğme kesitten fazla kopmasın — web
/// `min-h-[min(calc(100dvh-72px),760px)]`in 760'ı.
const double _kEnFazlaYukseklik = 760;

class IntroScreen extends StatefulWidget {
  /// "HEMEN OYNA"ya basıldığında çağrılır — ekranın TEK çıkışı. İlk
  /// açılışta bayrağı yazıp Setup'a geçmek çağıranın işi; Setup'taki
  /// "Tanıtım" linkinden açıldığında yalnızca `Navigator.pop`.
  final VoidCallback onDone;

  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    // GA4 `intro_slide_viewed` — tek ekran olsa da olay korunuyor (index 0):
    // 19 Ağustos'tan beri biriken huni kesintisiz kalsın.
    analytics.log('intro_slide_viewed', {'index': 0});
  }

  @override
  Widget build(BuildContext context) {
    final genislik = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        // İlk ekranı doldurur, düğme parmağın altında kalır (web
        // `min-h-[min(calc(100dvh-72px),760px)]`); sığmazsa kayar.
        // `minHeight` + `spaceBetween`: `Spacer`/`IntrinsicHeight`/
        // `SliverFillRemaining` kesitteki `LayoutBuilder` ile ÇALIŞMAZ
        // (içsel boyut sorgusu fırlatır).
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: _kMetinGenisligi,
                    minHeight: k.maxHeight < _kEnFazlaYukseklik
                        ? k.maxHeight
                        : _kEnFazlaYukseklik),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: LogoMark(height: 40)),
                          const SizedBox(height: 14),
                          Text(trUpper(kIntroUstBaslik),
                              style: const TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: kAccent)),
                          const SizedBox(height: 8),
                          Text(kIntroBaslik,
                              style: TextStyle(
                                  // Web `text-[clamp(28px,8.7vw,36px)]`.
                                  fontSize: fluidSize(genislik, 28, 0, 8.7, 36),
                                  height: 1.12,
                                  letterSpacing: -0.8,
                                  fontWeight: FontWeight.bold,
                                  color: kText)),
                          const SizedBox(height: 8),
                          const Text(kIntroKural,
                              style: TextStyle(
                                  fontSize: 15, height: 1.45, color: kMuted)),
                          const SizedBox(height: 14),
                          // Etiketin `top: -14` taşması için üstte pay.
                          const Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: BolgeKesiti(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 54,
                            child: NeoButton(
                              key: const Key('intro-hemen-oyna'),
                              label: trUpper(kIntroOyna),
                              onPressed: widget.onDone,
                              variant: NeoButtonVariant.accent,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(kIntroDuz,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 10,
                                  color: kMuted)),
                          const SizedBox(height: 6),
                          Center(
                            child: TapTarget(
                              onTap: () => showHelpModal(context),
                              minHeight: 32,
                              child: const Text('NASIL OYNANIR?',
                                  style: TextStyle(
                                      fontFamily: 'SpaceMono',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: kMuted)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
