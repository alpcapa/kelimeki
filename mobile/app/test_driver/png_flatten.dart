// App Store Connect ekran görüntüsünde ALFA KANALI kabul etmiyor —
// karelerin "flattened" olmasını istiyor. Bu dosya o düzleştirmeyi yapıyor.
//
// NEDEN GEREKLİ (ölçüldü, 11 Eylül 2026): Flutter'ın ekran görüntüsü yolu
// RGBA üretiyor. CI'a eklenen `sips -g hasAlpha` ölçümü yedi karenin
// yedisinde de **`yes`** dedi (koşu 34578979721). Yani kareler ölçü olarak
// doğru olmalarına rağmen yüklenemezdi; hata Console'da, yükleme anında
// çıkacaktı.
//
// NEDEN BURADA, `sips`te DEĞİL: `sips` alfa kanalını KALDIRAMIYOR (biçim
// çevirmeden başka yolu yok, JPEG'e gidip dönmek de metni bozar). Sürücü
// zaten PNG baytlarını elinde tutuyor, yani düzleştirmenin en ucuz yeri
// burası — CI'a yeni bir araç girmiyor.
//
// ⚠ Dosya BİLEREK sürücüden ayrı: `test_driver/integration_test.dart`
// `flutter_driver` çekiyor ve `flutter test` altında import edilemiyor.
// Ayrı durunca `test/png_flatten_test.dart` bunu Linux'ta ücretsiz
// doğruluyor (CI'da bir macOS koşusu beklemeden).
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// PNG baytlarını alfasız (RGB) PNG baytlarına çevirir.
///
/// Kare zaten alfasızsa baytlar OLDUĞU GİBİ döner — gereksiz bir yeniden
/// kodlama yok.
///
/// ⚠ Alfa "silinmiyor", BİRLEŞTİRİLİYOR: kare opak beyaz bir zemine
/// kompozit ediliyor. Kanalı düpedüz atmak yarı saydam bir pikselin ham
/// RGB'sini ortaya çıkarırdı; kareler pratikte tamamen opak olsa da bu
/// varsayıma yaslanmanın bir bedeli yok.
Uint8List duzlestirPng(List<int> bytes) {
  final girdi = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final kare = img.decodePng(girdi);
  if (kare == null) {
    throw StateError('PNG çözülemedi (${girdi.length} bayt)');
  }
  if (kare.numChannels == 3) return girdi;

  final zemin = img.Image(
    width: kare.width,
    height: kare.height,
    numChannels: 3,
  );
  img.fill(zemin, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(zemin, kare);
  return img.encodePng(zemin);
}
