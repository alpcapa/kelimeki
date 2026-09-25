// Sohbet Kuralları onayı — web `src/utils/chatRules.ts`in BİREBİR ikizi
// (25 Eylül 2026). İlk mesaj gönderilmeden önce BİR KEZ, HESABA bağlı
// (`accept_chat_rules` RPC'si → `profiles.chat_rules_version`); web'de
// kabul eden mobilde bir daha görmez, tersi de.
//
// ⚠ Metin ve sürüm web ile AYNI olmak zorunda: `chat_rules_parity_test.dart`
// web kaynağını okur, ayrışırsa web CI'ın `parite` işi düşer.

const int kChatRulesVersion = 1;

const String kChatRulesTitle = 'Sohbet Kuralları';
const String kChatRulesIntro = 'Mesajlaşmaya başlamadan önce:';
const List<String> kChatRulesItems = [
  'Gönderdiğin mesajlardan ve doğabilecek hukuki sonuçlardan sen sorumlusun.',
  'Cinsel içerik, hakaret, nefret söylemi, tehdit ve taciz yasaktır. Kurallara uymayan hesap uyarı yapılmadan kapatılabilir.',
  'Rahatsız olursan sohbet ayarlarından kişiyi sessize alabilir ve şikâyet edebilirsin.',
];
const String kChatRulesTermsLink = "Kullanım Koşulları'nın tamamı";
const String kChatRulesAccept = 'Kabul ediyorum';
const String kChatRulesCancel = 'Vazgeç';

/// Web `needsChatRulesConsent`. `acceptedVersion` sunucudaki
/// `chat_rules_version`; hiç kabul edilmemişse ya da okunamadıysa `null` →
/// pencere GÖSTERİLİR (fazladan bir onay hiçbir kaydı bozmaz, RPC yalnızca
/// ileri yazar).
bool needsChatRulesConsent(int? acceptedVersion) =>
    acceptedVersion == null || acceptedVersion < kChatRulesVersion;
