// Kelimeki — Sohbet Kuralları onayı (25 Eylül 2026, kullanıcı isteği).
//
// Bir kişi Canlı oyunda İLK mesajını göndermeye çalıştığında bir kez
// "Sohbet Kuralları" penceresi çıkar; "Kabul ediyorum" denince kayıt
// sunucuya (`accept_chat_rules` RPC'si → `profiles.chat_rules_version` +
// `chat_rules_accepted_at`) yazılır ve o HESABA bir daha sorulmaz — web'de de
// mobilde de. Kurallar esaslı biçimde değişirse `CHAT_RULES_VERSION` bir
// artırılır ve herkese bir kez daha sorulur; metindeki küçük düzeltmelerde
// sürüm AYNI kalır.
//
// Metin ve sürüm TEK KAYNAK burası. Portun ikizi
// `mobile/app/lib/src/util/chat_rules.dart`; `chat_rules_parity_test.dart`
// bu dosyayı OKUR, metin/sürüm ayrışırsa web CI'ın `parite` işi düşer.
//
// ⚠ Kapı yalnızca İSTEMCİDE: sunucu mesaj gönderimini bu onaya bağlamıyor,
// çünkü mağazadaki eski mobil paketler pencereyi bilmiyor (bkz. migration
// `chat_rules_consent`).

export const CHAT_RULES_VERSION = 1;

export const CHAT_RULES_TITLE = 'Sohbet Kuralları';
export const CHAT_RULES_INTRO = 'Mesajlaşmaya başlamadan önce:';
export const CHAT_RULES_ITEMS: readonly string[] = [
  'Gönderdiğin mesajlardan ve doğabilecek hukuki sonuçlardan sen sorumlusun.',
  'Cinsel içerik, hakaret, nefret söylemi, tehdit ve taciz yasaktır. Kurallara uymayan hesap uyarı yapılmadan kapatılabilir.',
  'Rahatsız olursan sohbet ayarlarından kişiyi sessize alabilir ve şikâyet edebilirsin.',
];
export const CHAT_RULES_TERMS_LINK = 'Kullanım Koşulları\'nın tamamı';
export const CHAT_RULES_ACCEPT = 'Kabul ediyorum';
export const CHAT_RULES_CANCEL = 'Vazgeç';

/**
 * Mesaj gönderilmeden önce pencere gösterilmeli mi? `acceptedVersion`
 * sunucudaki `chat_rules_version` — hiç kabul edilmemişse `null`, okunamadıysa
 * `undefined`. Okunamayan durum GÖSTERME değil GÖSTER tarafına düşer: pencere
 * zararsız, RPC yalnızca ileri yazıyor, yani fazladan bir onay hiçbir kaydı
 * bozmaz.
 */
export function needsChatRulesConsent(acceptedVersion: number | null | undefined): boolean {
  if (acceptedVersion === null || acceptedVersion === undefined) return true;
  return acceptedVersion < CHAT_RULES_VERSION;
}
