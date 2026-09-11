// `flutter drive` sürücüsü — integration_test'in ürettiği kareleri diske
// yazar (FAZ C 24.5, bkz. integration_test/store_screenshots_test.dart).
//
// iOS'ta kare SÜRÜCÜ tarafından alınıyor; Android'in
// `convertFlutterSurfaceToImage()` adımına burada gerek yok. Çıktı
// `build/screenshots/` altına düşer (build/ zaten gitignore'da) ve CI onu
// artefakt olarak yükler — mağaza görüntüleri repoya COMMIT EDİLMEZ.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

import 'png_flatten.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('build/screenshots/$name.png');
      file.parent.createSync(recursive: true);
      // ⚠ ALFASIZ YAZILIYOR — App Store Connect saydamlık kabul etmiyor ve
      // Flutter'ın ekran görüntüsü yolu RGBA üretiyor (ölçüldü, bkz.
      // png_flatten.dart). İş akışı çıktının alfasız olduğunu ayrıca
      // doğruluyor.
      final duz = duzlestirPng(bytes);
      file.writeAsBytesSync(duz);
      stdout.writeln('kare yazıldı: ${file.path} '
          '(${bytes.length} → ${duz.length} bayt, alfasız)');
      return true;
    },
  );
}
