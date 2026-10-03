// Beyin Ligi (2 Ekim 2026) — k-lig'in OHP'ye göre sıralanan alt ligi.
// Web ikizi `src/utils/beyinLigi.ts` + `src/components/BeyinLigiList.tsx`.
//
// ⚠ Eşik ÜÇ yerde: burası, web (`BEYIN_LIGI_MIN_GAMES`) ve sunucu
// (`beyin_ligi_siralama` view'ı, `ohp_games >= 5`). `npm run
// verify-beyin-ligi` üçünü kilitler; metinler `beyin_ligi_parity_test.dart`
// ile web kaynağına kilitli.

/// Beyin Ligi'ne girmek için gereken, hamle verisi olan en az oyun sayısı.
const int kBeyinLigiMinGames = 5;

/// Eşiğe kaç oyun kaldı (eşikteyse/üstündeyse 0).
int gamesUntilBeyinLigi(int ohpGames) {
  final g = ohpGames < 0 ? 0 : ohpGames;
  final r = kBeyinLigiMinGames - g;
  return r < 0 ? 0 : r;
}

/// Sekme açıklaması — web `BEYIN_LIGI_INTRO` ile BİREBİR.
const String kBeyinLigiIntro =
    "Beyin Ligi'nde puan yok, yalnızca hamle kalitesi var: oyuncular Ortalama Hamle Puanı'na (OHP) göre sıralanır. "
    'Listeye girmek için en az $kBeyinLigiMinGames oyun gerekir.';

/// Listenin altındaki not — web `BEYIN_LIGI_NOTE` ile BİREBİR.
const String kBeyinLigiNote =
    "YZ'ye karşı oynanan oyunlar da sayılır. OHP eşitse daha çok oyun oynayan üstte.";

/// Puan Ligi sekmesinin açıklaması — web `PUAN_LIGI_INTRO` ile BİREBİR.
const String kPuanLigiIntro =
    'k-lig, senin gibi kayıtlı kullanıcıların aldığı puanlara göre oluşan bir yarışmadır. '
    'Puanlar eşitse OHP yüksek olan üstte.';

/// Puan Ligi listesinin altındaki not — web `PUAN_LIGI_NOTE` ile BİREBİR.
const String kPuanLigiNote = "YZ'ye karşı oynanan oyunlar da sayılır.";

enum KLigTab { puan, beyin }

/// k-lig sekmeleri — web `KLIG_TABS` ile BİREBİR (sıra, ikon, etiket).
const List<({KLigTab id, String icon, String label})> kKLigTabs = [
  (id: KLigTab.puan, icon: '🏆', label: 'Puan Ligi'),
  (id: KLigTab.beyin, icon: '🧠', label: 'Beyin Ligi'),
];
