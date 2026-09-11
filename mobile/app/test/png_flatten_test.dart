// `test_driver/png_flatten.dart` kapısı — mağaza kareleri ALFASIZ çıkmalı.
//
// NEDEN BİR TEST (11 Eylül 2026): alfa arızası yalnızca App Store Connect
// yüklemesinde, yani zincirin EN SONUNDA görünüyordu; CI ölçümü de bir
// macOS koşusu (~14 dk) bekletiyor. Bu test aynı değişmezi Linux'ta
// saniyeler içinde kanıtlıyor. İş akışındaki `sips -g hasAlpha` kapısı
// DURUYOR — o gerçek çıktıyı ölçüyor, bu ise dönüşümün kendisini.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../test_driver/png_flatten.dart';

/// PNG başlığındaki renk tipi: 2 = RGB, 6 = RGBA. IHDR sabit konumda.
int _renkTipi(Uint8List png) => png[25];

void main() {
  test('RGBA kare RGB olarak yazılır ve renkler korunur', () {
    final kaynak = img.Image(width: 8, height: 4, numChannels: 4);
    img.fill(kaynak, color: img.ColorRgba8(18, 36, 48, 255));
    kaynak.setPixelRgba(3, 2, 220, 30, 30, 255); // jokerin kırmızı 0'ı gibi
    final girdi = img.encodePng(kaynak);
    expect(_renkTipi(girdi), 6, reason: 'fixture gerçekten RGBA olmalı');

    final cikti = duzlestirPng(girdi);

    expect(_renkTipi(cikti), 2, reason: 'çıktıda alfa kanalı KALMAMALI');
    final okunan = img.decodePng(cikti)!;
    expect(okunan.width, 8);
    expect(okunan.height, 4);
    final p = okunan.getPixel(3, 2);
    expect([p.r, p.g, p.b], [220, 30, 30]);
    final q = okunan.getPixel(0, 0);
    expect([q.r, q.g, q.b], [18, 36, 48]);
  });

  test('yarı saydam piksel BEYAZA birleştirilir, ham RGB sızmaz', () {
    final kaynak = img.Image(width: 2, height: 1, numChannels: 4);
    kaynak.setPixelRgba(0, 0, 0, 0, 0, 0); // tamamen saydam siyah
    kaynak.setPixelRgba(1, 0, 0, 0, 0, 255);
    final cikti = duzlestirPng(img.encodePng(kaynak));

    final okunan = img.decodePng(cikti)!;
    final saydam = okunan.getPixel(0, 0);
    expect([saydam.r, saydam.g, saydam.b], [255, 255, 255],
        reason: 'saydam piksel zeminin rengini almalı, siyah sızmamalı');
    final opak = okunan.getPixel(1, 0);
    expect([opak.r, opak.g, opak.b], [0, 0, 0]);
  });

  test('zaten alfasız kare YENİDEN KODLANMAZ — baytlar birebir döner', () {
    final kaynak = img.Image(width: 4, height: 4, numChannels: 3);
    img.fill(kaynak, color: img.ColorRgb8(9, 9, 9));
    final girdi = img.encodePng(kaynak);
    expect(_renkTipi(girdi), 2);

    expect(duzlestirPng(girdi), same(girdi));
  });
}
