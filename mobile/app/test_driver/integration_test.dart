// `flutter drive` sürücüsü — integration_test'in ürettiği kareleri diske
// yazar (FAZ C 24.5, bkz. integration_test/store_screenshots_test.dart).
//
// iOS'ta kare SÜRÜCÜ tarafından alınıyor; Android'in
// `convertFlutterSurfaceToImage()` adımına burada gerek yok. Çıktı
// `build/screenshots/` altına düşer (build/ zaten gitignore'da) ve CI onu
// artefakt olarak yükler — mağaza görüntüleri repoya COMMIT EDİLMEZ.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('build/screenshots/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      stdout.writeln('kare yazıldı: ${file.path} (${bytes.length} bayt)');
      return true;
    },
  );
}
