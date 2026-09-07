// Kelimeki — YZ zorluk seviyesinin ÜRÜN yüzü (web `src/utils/aiLevel.ts`
// portu, ROADMAP #23 Faz 4).
//
// Motor tarafı (`AiLevel` enum'u, `aiLevelTopN`) `kelimeki_core`da; burası
// yalnızca ekranların ortak kullandığı etiket/seçenek/rozet sözlüğü.
// Terminoloji tek: **Zorluk: Kolay · Normal · Zor** (ROADMAP 23.4 — "kolay
// mod", "seviye" gibi üçüncü bir ifade ÜRETME; web Setup/HelpModal ↔ port
// aynı sözcükleri taşır). `ai_level_parity_test.dart` bu dosyayı web
// kaynağıyla karşılaştırıyor: etiketler, seçilebilir liste, hitap cümleleri
// ve altı açıklama bileşimi.
import 'package:kelimeki_core/kelimeki_core.dart';

/// Kullanıcıya görünen etiket — rozetler, seçici, kart satırları
/// (web `AI_LEVEL_LABEL`). Setup butonu bunu `trUpper` ile büyütür (web'de
/// CSS `uppercase`), rozet olduğu gibi (web `normal-case`) yazar.
const Map<AiLevel, String> aiLevelLabel = {
  AiLevel.kolay: 'Kolay',
  AiLevel.normal: 'Normal',
  AiLevel.zor: 'Zor',
};

/// Setup'ta SEÇİLEBİLİR seviyeler, ekran sırasıyla (web
/// `SELECTABLE_AI_LEVELS`; parite testi aynı küme + sırayı kilitler). `zor`
/// Faz 5'e (7 Eylül 2026) kadar YOKTU — motoru gelmeden "Zor" sunup Normal'i
/// oynatmak ürün yalanı olurdu; geniş arama motoru (`aiLevelSearch`) ile
/// web'le aynı PR'da açıldı.
const List<AiLevel> selectableAiLevels = [AiLevel.kolay, AiLevel.normal, AiLevel.zor];

/// Seçicinin altındaki açıklamanın İLK cümlesi — seviye kime göre,
/// kullanıcıya hitapla (web `AI_LEVEL_PITCH`, parite testi birebir
/// karşılaştırıyor). Kullanıcı kararı (6 Eylül 2026): YZ'nin nasıl
/// zayıflatıldığı ürün metnine GİRMEZ.
const Map<AiLevel, String> aiLevelPitch = {
  AiLevel.kolay:
      'Çok iyi değilim, daha yeni yeni alışıyorum, karşımda o kadar zor bir '
          'rakip istemiyorum diyorsanız doğru yerdesiniz.',
  AiLevel.normal:
      'Orta-iyi seviye bir oyuncuyum, sıradan oyunculardan biraz daha iyiyim '
          'diyorsanız burası size göre.',
  AiLevel.zor:
      'Çok iyi oyuncuyum, genelde %80+ kazanırım diyorsanız bunu '
          'denemelisiniz.',
};

/// Puan cümlesinin fiili — kullanıcının verdiği metinde Zor'unki farklı
/// (web `AI_LEVEL_VERB`).
const Map<AiLevel, String> _aiLevelVerb = {
  AiLevel.kolay: 'kazandırır',
  AiLevel.normal: 'kazandırır',
  AiLevel.zor: 'kazandırıyor',
};

/// Setup'ta seçili seviyenin altında çıkan açıklama: hitap cümlesi + o
/// seviyenin k-lig puanı. Sayılar core'un `leaguePoints`inden türetilir
/// (tablo TEK kaynak). 2 kişilikte yalnızca birincilik, 4 kişilikte
/// ikincilik de yazılır (ikincilik 0 ise "puan kazandırmaz"). Web
/// `aiLevelDescription` ile aynı şablon; parite testi altı bileşimi tam
/// metinle kilitler.
///
/// Her bileşimde birincilik VE ikincilik yazılır (7 Eylül 2026, kullanıcı
/// isteği; ikincilik 0 ise "puan kazandırmaz"), puanın adı "k-lig puanı".
/// Girişsizde ([signedIn] false) puan cümlesinin ARDINDAN, ayrı bir not
/// olarak "(Puan takibi üyelik gerektirir)" gelir; nokta CÜMLENİN sonunda,
/// parantezin önünde — web `aiLevelDescription(level, count, signedIn)`.
String aiLevelDescription(AiLevel level, int playerCount, {required bool signedIn}) {
  final birinci = leaguePoints(1, playerCount, aiLevel: level);
  final ikinci = leaguePoints(2, playerCount, aiLevel: level);
  final fiil = _aiLevelVerb[level]!;
  final puan = ikinci == 0
      ? 'birincilik $birinci k-lig puanı $fiil, ikincilik puan kazandırmaz'
      : 'birincilik $birinci, ikincilik $ikinci k-lig puanı $fiil';
  final uyelik = signedIn ? '' : ' (Puan takibi üyelik gerektirir)';
  final sans = level == AiLevel.zor ? ' Bol şans!' : '';
  return '${aiLevelPitch[level]} Bu seviyede $puan.$uyelik$sans';
}

/// Rozette gösterilecek seviye (6 Eylül 2026, kullanıcı kararı — Kolay
/// yeşil · Normal turuncu · Zor kırmızı, web `aiLevelForBadge`): YZ oyunuysa
/// ham değer, null = Normal (seviyesiz eski kayıtlar dahil); Canlı oyunsa
/// null → rozet YOK. "YZ oyunu mu" kararı çağıranda (`onlineGameId == null`,
/// GameScreen ↔ OnlineGameScreen).
AiLevel? aiLevelForBadge(AiLevel? raw, {required bool isAiGame}) =>
    isAiGame ? (raw ?? AiLevel.normal) : null;

/// Rozet metni — null seviye (Canlı oyun) → rozet yok (web `aiLevelBadgeLabel`).
String? aiLevelBadgeLabel(AiLevel? level) =>
    level == null ? null : aiLevelLabel[level];
