// Kelimeki — bekleyen arkadaşlık davet token'ı için tek seferlik kuyruk.
// /davet/:token sayfası kayıt/giriş öncesi bu token'ı burada saklar; e-posta
// doğrulaması açıkken bir kayıt, doğrulama linkine tıklanana kadar oturum
// açmadığından (ve o link genelde uygulamanın köküne döner, /davet/:token'a
// değil) token'ı burada tutmak, App.tsx'in oturum açılınca (hangi sayfadan
// olursa olsun) daveti yine de işleyebilmesini sağlar — tıpkı
// gameStorage.ts'teki terk edilmiş oyun kuyruğu gibi read-then-clear.
const PENDING_INVITE_KEY = 'kelimeki:pending-friend-invite-token';

export function storePendingInviteToken(token: string): void {
  try {
    localStorage.setItem(PENDING_INVITE_KEY, token);
  } catch {
    // yoksay
  }
}

/** Bekleyen token'ı okur ve kuyruğu temizler (bir daha işlenmesin diye). */
export function takePendingInviteToken(): string | null {
  try {
    const token = localStorage.getItem(PENDING_INVITE_KEY);
    if (token) localStorage.removeItem(PENDING_INVITE_KEY);
    return token;
  } catch {
    return null;
  }
}

/**
 * Davet linki `?ref=arkadas` TAŞIMAK ZORUNDA (21 Ağustos 2026, ROADMAP #7) —
 * Setup'taki "Paylaş" linkiyle (`shareLink.ts`) AYNI etiket, çünkü ikisi de
 * aynı kanal: arkadaş daveti.
 *
 * NEDEN: admin panelindeki Kaynak Hunisi'nin iki ucu bu etiket olmadan AYNI
 * popülasyonu ölçmüyordu. Ziyaretçi ucu yalnızca Setup'ın paylaş linkiyle
 * gelenleri sayıyor, üye ucu ise ağırlıkla BU path'ten (`/davet/:token`)
 * gelenleri — o link etiketsiz olduğundan davetle gelip üye olan herkes
 * `direkt` satırına düşüyor, yani gerçek doğrudan trafiği şişiriyordu ve
 * `arkadas` satırının "%100 dönüşümü" bir ölçüm değil tesadüftü.
 *
 * ⚠ Tek başına yetmez: etiketi YAKALAYAN kod `boot.tsx`te, route'tan ÖNCE
 * olmak zorunda — bu route `App`'i hiç mount etmiyor (bkz. oradaki not).
 * Etiket first-touch olduğundan zaten `instagram` gibi bir kaynakla gelmiş
 * bir cihazın kaydını EZMEZ.
 */
export function buildInviteUrl(token: string): string {
  return `${window.location.origin}/davet/${token}?ref=arkadas`;
}

export const INVITE_SHARE_TEXT = "Kelimeki'de birlikte kelime oyunu oynayalım!";

/**
 * WhatsApp'ın paylaşım adresi — metin + link hazır açılır, kişiyi kullanıcı
 * seçer. `navigator.share`in OLMADIĞI yerde (masaüstü tarayıcı) yedek yol
 * (27 Eylül 2026, kullanıcı: *"whatsapp'dan direkt paylaşmalı"*); telefonda
 * sistem paylaşım sayfası zaten WhatsApp'ı gösteriyor.
 */
export function whatsappShareUrl(url: string): string {
  return `https://wa.me/?text=${encodeURIComponent(`${INVITE_SHARE_TEXT}\n${url}`)}`;
}
