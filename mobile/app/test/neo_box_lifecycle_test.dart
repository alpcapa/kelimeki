// Gölge raster önbelleği ↔ uygulama yaşam döngüsü (20 Ekim 2026).
//
// Kullanıcı iPhone'da Setup ekranında gölgeli düğmelerin gölge alanlarına
// denk gelen KOYU dikdörtgenler gördü; uygulama arkada açıkken bir e-posta
// linkiyle öne getirilmişti. Tahmin: `toImageSync` görüntüsü uygulama ön
// planda değilken üretildi ve önbellekte bozuk kaldı. Bu dosya iki önlemi
// kilitler (görüntünün GERÇEKTEN bozulmasını burada üretmek mümkün değil —
// o yalnızca cihaz GPU'sunda olur):
//   1. Ön planda değilken önbelleğe YENİ görüntü girmez.
//   2. `invalidateNeoBoxRasterCache` önbelleği boşaltır VE ekranı yeniden
//      boyatır (yalnızca boşaltmak ekrandaki eski görüntüyü değiştirmezdi).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelimeki/src/ui/game/neo_box.dart';

Widget _kutu() => const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 120,
          height: 48,
          child: NeoBox(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white,
            insetShadows: [
              InsetShadow(
                  color: Color(0x33000000), offset: Offset(2, 2), blur: 4),
            ],
            outerShadows: [
              BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 4),
                  blurRadius: 10),
            ],
          ),
        ),
      ),
    );

void main() {
  setUp(debugResetNeoBoxCacheForTests);
  tearDown(() {
    debugResetNeoBoxCacheForTests();
  });

  testWidgets('ön planda değilken önbelleğe görüntü GİRMEZ, öne dönünce girer',
      (tester) async {
    // `paused`/`hidden`da Flutter hiç kare çizmez (framesEnabled=false) —
    // ölçülebilir ara durum `inactive`: görünür ama ön planda DEĞİL, iOS'ta
    // arka plandan dönüşün geçtiği basamak.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    final blitOnce = debugCachedBlitCountForTests;
    final blurOnce = debugBlurPaintCountForTests;
    await tester.pumpWidget(_kutu());
    expect(debugCachedBlitCountForTests - blitOnce, 0,
        reason:
            'ön planda değilken önbellekten basıldı — yeni görüntü üretilmiş');
    expect(debugBlurPaintCountForTests - blurOnce, greaterThan(0),
        reason: 'kutu hiç çizilmedi; test bir şey ölçmüyor');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final blitResumed = debugCachedBlitCountForTests;
    invalidateNeoBoxRasterCache();
    await tester.pump();
    expect(debugCachedBlitCountForTests - blitResumed, greaterThan(0),
        reason: 'öne dönünce önbellek devreye girmedi — ya `toImageSync` bu '
            'ortamda yok ya da yeniden boyama tetiklenmedi');
  });

  testWidgets('invalidate önbelleği boşaltır VE ekranı yeniden boyatır',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(_kutu());
    await tester.pump();

    // Önbellek dolu: düz bir yeniden boyama blur ETMEMELİ.
    final blurDolu = debugBlurPaintCountForTests;
    tester.renderObject(find.byType(NeoBox)).markNeedsPaint();
    await tester.pump();
    expect(debugBlurPaintCountForTests - blurDolu, 0,
        reason: 'önbellek çalışmıyor; aşağıdaki iddia bir şey kanıtlamaz');

    // Hiçbir widget değişmeden invalidate → yeniden rasterleştirme (blur)
    // olmalı: bu hem boşaltmayı hem yeniden boyamayı kanıtlar.
    final blurOnce = debugBlurPaintCountForTests;
    invalidateNeoBoxRasterCache();
    await tester.pump();
    expect(debugBlurPaintCountForTests - blurOnce, greaterThan(0),
        reason: 'invalidate sonrası ekran yeniden boyanmadı ya da önbellek '
            'boşalmadı — eski (bozuk olabilecek) görüntü ekranda kalırdı');
  });
}
