// Kelimeki — Canlı oyun sohbetinin "okundu" kararı (saf fonksiyon).
//
// 23 Eylül 2026'ya kadar okundu damgası YALNIZCA cihazdaydı (localStorage)
// ve bu iki arıza üretiyordu (kullanıcı bildirdi):
//   1. Oyun bir cihazda İLK kez açılınca damga yok → "eski mesajları yeni
//      sayma" tohumu mevcut HER ŞEYİ okunmuş sayıyordu, gerçekten yeni gelmiş
//      mesajlar dahil — rozet 0, içeride iki yeni mesaj.
//   2. Bir cihazda okumak ötekine hiç ulaşmıyordu → okunmuş mesajlar başka
//      cihazda "yeni" görünüyordu.
// Damga artık sunucuda da (`online_game_chat_reads`, yalnızca İLERİ gider).
// Cihazdaki damga YEDEK olarak kalıyor: sunucuya ulaşılamazsa davranış
// bugünkünden kötü olmaz, ve port (henüz sunucuyu kullanmıyor) dönemindeki
// eski damgalar kaybolmaz.
//
// Karar burada, bileşende DEĞİL — `npm run verify-chat-read` bunu sınıyor.

export interface ChatReadRow {
  sender_user_id: string;
  created_at: string;
}

export interface ChatReadInput {
  /**
   * Sunucudaki damga. `null` = sunucuda satır YOK (kesin), `undefined` =
   * BİLİNMİYOR (istek düştü / çevrimdışı). Ayrım önemli: bilinmiyorken
   * tohumu sunucuya yazmak, sunucudaki gerçek (daha eski) damganın üstüne
   * "hepsi okundu" basmak olurdu.
   */
  serverAt: string | null | undefined;
  /** Bu cihazdaki damga (`localStorage`), yoksa `null`. */
  localAt: string | null;
  rows: readonly ChatReadRow[];
  myUserId: string;
  /** Tohum için "şimdi" — testte sabitlenebilsin diye dışarıdan. */
  nowIso: string;
}

export interface ChatReadDecision {
  /** Okunmamış sayısı (kendi mesajlarım hariç). */
  unread: number;
  /** Cihaza yazılacak damga, yazılmayacaksa `null`. */
  writeLocal: string | null;
  /** Sunucuya gönderilecek damga, gönderilmeyecekse `null`. */
  pushToServer: string | null;
}

function ms(iso: string): number {
  const t = Date.parse(iso);
  return Number.isNaN(t) ? -Infinity : t;
}

/** İki damgadan büyüğü (biri yoksa öteki). */
export function laterOf(a: string | null | undefined, b: string | null | undefined): string | null {
  if (!a) return b ?? null;
  if (!b) return a;
  return ms(b) > ms(a) ? b : a;
}

/** Görülen en son mesajın `created_at`i, mesaj yoksa `null`. */
export function latestMessageAt(rows: readonly ChatReadRow[]): string | null {
  let best: string | null = null;
  for (const r of rows) best = laterOf(best, r.created_at);
  return best;
}

export function decideChatRead(input: ChatReadInput): ChatReadDecision {
  const { serverAt, localAt, rows, myUserId, nowIso } = input;
  const known = laterOf(serverAt ?? null, localAt);

  // Hiçbir yerde damga yok → oyunu hiç açmamış sayılmaz, ÖZELLİK yeni
  // devreye girmiş sayılır: mevcut geçmiş okunmuş kabul edilir (eski
  // "ilk ziyaret" kuralı). Artık yalnızca sunucu da KESİN boşsa.
  if (known === null) {
    const seed = latestMessageAt(rows) ?? nowIso;
    return {
      unread: 0,
      writeLocal: seed,
      pushToServer: serverAt === null ? seed : null,
    };
  }

  const unread = rows.filter(
    (r) => r.sender_user_id !== myUserId && ms(r.created_at) > ms(known),
  ).length;

  return {
    unread,
    // Sunucu daha ilerideyse (başka cihazda okunmuş) cihaz yetişir.
    writeLocal: localAt === known ? null : known,
    // Cihaz daha ilerideyse (çevrimdışı okunmuş / eski damga) sunucu yetişir.
    // Sunucu bilinmiyorken de denenir: sunucu yalnızca İLERİ gittiğinden
    // gerçek bir okumayı göndermek hiçbir durumda zarar vermez.
    pushToServer: localAt !== null && localAt === known && serverAt !== known ? localAt : null,
  };
}
