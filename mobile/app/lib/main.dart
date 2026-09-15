import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/bootstrap.dart';
import 'src/data/error_reporter.dart';
import 'src/util/error_message.dart';
import 'src/ui/app.dart';

Future<void> main() async {
  // Hata yakalayıcılar EN BAŞTA kurulur — `bootstrap()` sırasında doğan bir
  // hata da yakalansın diye. Rapor gönderimi Supabase bağlanana kadar
  // sessizce düşer (bkz. `ErrorReporter.configure`); yakalayıcının kendisi
  // yine de erken kurulmalı, aksi halde açılış hatası hiçbir yere düşmez.
  //
  // İKİ yakalayıcı gerekiyor ve ikisi FARKLI şeyleri görüyor:
  //   * `FlutterError.onError` — widget ağacındaki (build/layout/paint)
  //     hatalar. Web'deki `ErrorBoundary`nin karşılığı.
  //   * `runZonedGuarded` — zone dışına kaçan yakalanmamış async hatalar.
  // Yalnızca birini kurmak diğerinin gördüğü sınıfı sessizce kaçırır.
  // Ekrana Türkçe metin koyan kapının (util/error_message.dart) ham metni
  // telemetriye yazabilmesi için. Doğrudan import EDİLMİYOR — o dosya saf
  // kalsın diye enjeksiyon; gerekçe orada yazılı.
  setErrorMessageReporter((err, context) {
    if (err != null) errorReporter.report(err, context: context);
  });

  final onceki = FlutterError.onError;
  FlutterError.onError = (details) {
    errorReporter.report(
      details.exception,
      kind: ClientErrorKind.flutter,
      stack: details.stack,
    );
    // Varsayılan davranış KORUNUYOR: hata konsola da basılmalı, aksi halde
    // yerel geliştirmede kırmızı ekran/log kaybolur.
    onceki?.call(details);
  };

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Portre kilidi — web'deki LandscapeHint banner'ının yerini alan kesin
    // çözüm (mobile/CLAUDE.md, "yeniden yazılanlar": native API yalan söylemez).
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final services = await bootstrap(rootBundle);
    runApp(KelimekiApp(services: services));
  }, (error, stack) {
    errorReporter.report(error, kind: ClientErrorKind.zone, stack: stack);
    if (kDebugMode) debugPrint('Yakalanmamış hata: $error\n$stack');
  });
}
