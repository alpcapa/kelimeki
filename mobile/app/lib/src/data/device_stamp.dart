// Kelimeki app — cihaz damgası: `anon_id` + kaynak etiketi, TEK yerden.
//
// NEDEN VAR (22 Eylül 2026, kullanıcı isteği): admin panelinin Kaynak
// Hunisi'nde app görünmüyordu. Kullanıcının sözleri: *"kim nereden gelmiş,
// kaç üye getirmiş, kaçı oyun başlatmış, kaçı bitirmiş görmek… Kaynak
// belliyse onun altına girecek, değilse 'bilinmiyor'da yazacak (ki
// bilinmemesi mümkün olmamalı çünkü ya web'den direkt gelmiştir ya da
// app'den)"*.
//
// Ölçüm haklı çıkardı: huninin dört adımının (ziyaret · kayıt · oyun
// başlatma · oyun bitirme) HİÇBİRİNDE port damga yazmıyordu, dolayısıyla
// app'in tabloya kattığı tek şey `profiles.signup_utm_source is null` olan
// 20 kayıttı ve onlar `bilinmiyor` satırına düşüyordu. Panel bir gün
// **Üye %2000,0** yazdı (20 üye / 1 ziyaret) — sebebi bir hesap hatası
// değil, payla paydanın ayrı kitlelerden gelmesiydi.
//
// ⚠ ALTYAPI ZATEN VARDI AMA ÖLÜYDÜ: `FlagsStore` `anonId()`,
// `captureUtmSource`, `anonVisitDate` taşıyor ve HİÇBİR YER çağırmıyordu
// (22 Eylül 2026'da `grep` ile ölçüldü). Bu dosya o ölü altyapıyı tek bir
// anlamlı birime bağlıyor.
//
// ⚠ GİZLİLİK METNİ BU İŞİ ZATEN KAPSIYOR — değişiklik GEREKMEDİ.
// `src/legal/LegalContent.tsx`in "anonim kod şu durumlarda sunucuya
// iletilir" listesi platform-nötr yazılmış: (1) *"HER ziyarette — oturum
// açık olsun olmasın — işletim sistemi tipiyle (iOS/Android/masaüstü)…
// girişsiz (misafir) bir ziyaretteyseniz ayrıca varsa bir paylaşım
// linkindeki kaynak etiketi de eklenir"*, (2) oyun başlatma, (4) misafir
// oyun bitirme. Portun aynı üç kaydı yazması yeni bir durum AÇMIYOR.
// (`signup_events` migration'ındaki uyarı BEŞİNCİ bir durum — kayıt
// olayına `anon_id` — eklemekle ilgiliydi; burada öyle bir şey yok:
// kayıtta yalnızca KAYNAK etiketi gidiyor, anonim kod GİTMİYOR.)
import '../storage/flags_store.dart';

/// Kaynağı hiç bilinmeyen bir app teması için etiket.
///
/// ⚠ Bu bir PLATFORM değil, bir KAYNAK: mağazadan/uygulamadan gelen kişinin
/// ilk teması odur. Web `'direkt'` yazıyor (`?ref=` yokken bile), port
/// `'app'` yazıyor — ikisi bilerek ayrı, yoksa app kayıtları web'in gerçek
/// doğrudan trafiğini şişirirdi (web `signUp`ın kendi yazılı kararı).
///
/// Panelin karşılığı: `src/utils/adminGroups.ts` → `sourceChannel('app')` →
/// `'app'`, etiket **Uygulama**. ⚠ Eşleşme TAM, önek DEĞİL — `appstore` gibi
/// bir etiket uydurma bir kanala atanmaz (`verify-admin-groups` ölçüyor).
const String kAppSource = 'app';

/// `anon_id` + kaynak etiketini veren tek birim. Gateway'lere ENJEKTE
/// ediliyor, çağıranlardan parametre olarak İSTENMİYOR — `game_starts`in
/// `is_guest` bayrağıyla aynı gerekçe: birden çok çağrı yeri var (Setup +
/// oyun sonu "Tekrar Oyna" + …) ve biri atlarsa sayım SESSİZCE eksilir.
class DeviceStamp {
  final FlagsStore flags;
  const DeviceStamp(this.flags);

  /// Cihazın kalıcı anonim kodu — yoksa üretip saklar (`FlagsStore.anonId`).
  Future<String> anonId() => flags.anonId();

  /// Kaynak etiketi: deep link'ten GERÇEK bir `?ref=` yakalandıysa o,
  /// yoksa [kAppSource].
  ///
  /// ⚠ Sıra önemli: Instagram'dan gelip uygulamayı kuran kişi Instagram
  /// satırında KALMALI. `FlagsStore.captureUtmSource` first-touch yazıyor
  /// (bir kez, üzerine yazılmaz) — web `captureUtmSource`ın aynı ilkesi.
  ///
  /// ⚠ Bugün `captureUtmSource`ı çağıran bir yol YOK (deep link ayrıştırması
  /// portta hiç yazılmadı), yani pratikte her zaman `'app'` dönüyor. Yol
  /// eklendiğinde BURASI değişmez — yalnızca değer dolar.
  String get source => flags.utmSource ?? kAppSource;
}
