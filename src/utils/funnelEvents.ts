// Kelimeki — Ölçüm v2 (Huni v2): cihaz başına anonim olaylar (`funnel_events`).
//
// 24 Eylül 2026, kullanıcı kararı: *"Kendi tablomuz … Ayrıca tabloda revisit
// de görmek istiyorum."* Plan ve kararlar: `docs/decisions/funnel-v2.md`.
// Sunucu tarafı: `supabase/migrations/20260924141953_funnel_events.sql`.
//
// Admin → Büyüme → Kullanıcı → "Huni v2" bir KOHORT tablosu: pencerede İLK KEZ
// gelen (`land`) cihazların kaçı başka bir gün döndü (`visit`), üye oldu
// (`signup`), oyun başlattı/bitirdi. Kimlik yalnızca cihazdaki anonim kod
// (`getOrCreateAnonId`); hesap kimliği ASLA gönderilmez.
//
// ⚠ GİZLİLİK METNİ SINIRI (24 Eylül 2026, kullanıcı kararı "ikiye böl"):
// metnin güncellenmesi port kopyasını (`legal_modals.dart`) da değiştirmeyi,
// yani mobil derlemeyi gerektiriyor → sürüm dondurması bitene kadar YAPILAMAZ.
// O güne kadar yalnızca metnin BUGÜN zaten saydığı olaylar yazılır:
// ziyaret (land/visit), YZ oyunu başlangıcı ve MİSAFİR oyun bitişi. `signup`
// ve üye oyun bitişi `FUNNEL_MEMBER_EVENTS_ENABLED` bayrağının arkasında;
// metin güncellenen PR'da bayrak da `true` olur.
//
// Dosya iki katmanlı: üstteki fonksiyonlar SAF (`npm run verify-funnel-events`
// doğrudan koşar), alttaki kabuk onları `localStorage` + `fetch`'e bağlar.
// Karşılama katmanı (`main.tsx`) da bunu import ettiği için Supabase SDK'sı
// KULLANILMIYOR — `webJourney.ts` ile aynı bundle gerekçesi, düz `fetch`.

import { getOrCreateAnonId, getStoredUtmSource, isBotUserAgent } from './visitTracking';

/**
 * Olay adları. ⚠ `log_funnel_event`in `v_events` dizisiyle BİREBİR aynı
 * olmalı (sıra dahil) — `npm run verify-funnel-events` karşılaştırır.
 * Port (PR 2) aynı adları bu dosyadan okuyarak test edecek.
 */
export const FUNNEL_EVENTS = ['land', 'visit', 'signup', 'game_start', 'game_finish'] as const;
export type FunnelEvent = (typeof FUNNEL_EVENTS)[number];

/** Platformlar — `v_platforms` ile birebir. Web her zaman `'web'` yazar. */
export const FUNNEL_PLATFORMS = ['web', 'ios', 'android'] as const;
export type FunnelPlatform = (typeof FUNNEL_PLATFORMS)[number];

/**
 * Ölçüm v2'den ÖNCE de bu cihazda iz vardı → eski kullanıcı. Yayından sonraki
 * ilk açılışta HER cihaz `land` yazar; bu kanal olmasaydı eski kullanıcılar
 * "yeni gelen" görünür ve ilk haftaların kohortunu şişirirdi. Rapor bu kanalı
 * kohort toplamına KATMAZ.
 */
export const FUNNEL_EXISTING_CHANNEL = 'mevcut';

/** `?ref=` olmadan gelen yeni cihaz — `logGameStart`/`signUp` ile aynı sözleşme. */
export const FUNNEL_DIRECT_CHANNEL = 'direkt';

/**
 * `signup` ve ÜYE oyun bitişi gizlilik metni güncellenene kadar KAPALI
 * (başlıktaki "GİZLİLİK METNİ SINIRI"). Metni güncelleyen PR bunu `true`
 * yapar; admin tablosu da "Üye" sütununu bu bayrağa göre "bekliyor" gösterir.
 */
export const FUNNEL_MEMBER_EVENTS_ENABLED: boolean = false;

/** Kanal etiketini sunucunun beklediği biçime getirir; boşsa `null`. */
export function normalizeFunnelChannel(raw: string | null | undefined): string | null {
  if (raw == null) return null;
  // ⚠ `trLower` DEĞİL: etiketler ASCII (bkz. `sourceChannel`, adminGroups.ts).
  const s = raw.trim().toLowerCase().slice(0, 40);
  return s === '' ? null : s;
}

/**
 * `land` satırının kanalı. `hadPriorTrace` = bu sayfa yüklemesi HİÇBİR ŞEY
 * yazmadan önce cihazda Kelimeki izi var mıydı (bkz. `hasPriorTrace`).
 */
export function decideLandChannel(hadPriorTrace: boolean, storedUtm: string | null): string {
  if (hadPriorTrace) return FUNNEL_EXISTING_CHANNEL;
  return normalizeFunnelChannel(storedUtm) ?? FUNNEL_DIRECT_CHANNEL;
}

/**
 * Cihazda ölçüm v2'den önceki bir iz var mı. `keys` = `localStorage`
 * anahtarları, OKUMA HİÇBİR ŞEY YAZILMADAN yapılmalı (`?ref=` yakalama da
 * `kelimeki:` önekli bir anahtar yazar).
 *
 * İz: `kelimeki` ile başlayan her anahtar (anonim kod, `seen-intro`, yarım
 * oyun, kaynak etiketi …) ya da bir Supabase oturumu (`sb-<ref>-auth-token`,
 * karşılama kapısıyla aynı tarama). ⚠ Huni v2'nin KENDİ anahtarları bilerek
 * `kelimeki` önekli DEĞİL (`LAND_KEY`/`VISIT_KEY`) — iz sayılsalardı yarıda
 * kalan bir `land` gönderimi ikinci yüklemede "mevcut"a dönerdi.
 */
export function hasPriorTrace(keys: readonly string[]): boolean {
  return keys.some(
    (k) =>
      k.startsWith('kelimeki') ||
      (k.startsWith('sb-') && k.endsWith('-auth-token')),
  );
}

/** Europe/Istanbul günü (YYYY-AA-GG). Türkiye 2016'dan beri sabit UTC+3, yaz saati YOK. */
export function istanbulDay(nowMs: number): string {
  return new Date(nowMs + 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

/** Saklanan `land` kararı: kanal bir kez verilir, gönderim başarılı olana kadar tekrar denenir. */
export interface LandState {
  channel: string;
  sent: boolean;
}

/**
 * Bu yüklemede `land` için ne yapılacak. Kanal İLK kararda donar: gönderim
 * düşerse sonraki yükleme AYNI kanalla tekrar dener (o arada anonim kod
 * üretilmiş olacağından yeniden karar verilseydi cihaz "mevcut"a dönerdi).
 */
export function planLand(
  stored: LandState | null,
  hadPriorTrace: boolean,
  storedUtm: string | null,
): { state: LandState; send: boolean } {
  if (stored) return { state: stored, send: !stored.sent };
  const state = { channel: decideLandChannel(hadPriorTrace, storedUtm), sent: false };
  return { state, send: true };
}

/** Bu Istanbul gününün `visit`i gönderilmeli mi (sunucu da günde bire kilitliyor). */
export function shouldSendVisit(lastSentDay: string | null, today: string): boolean {
  return lastSentDay !== today;
}

/**
 * Olayın bugünkü gizlilik metninin kapsamında olup olmadığı. `isGuest` yalnızca
 * `game_finish` için anlamlı: metin bitiş kaydını yalnızca MİSAFİR için sayıyor.
 */
export function funnelEventAllowed(
  event: FunnelEvent,
  isGuest: boolean,
  memberEventsEnabled: boolean = FUNNEL_MEMBER_EVENTS_ENABLED,
): boolean {
  if (event === 'signup') return memberEventsEnabled;
  if (event === 'game_finish' && !isGuest) return memberEventsEnabled;
  return true;
}

// ── Tarayıcı kabuğu ─────────────────────────────────────────────────────────

const LAND_KEY = 'funnel-v2:land';
const VISIT_KEY = 'funnel-v2:visit-day';

function endpoint(): { url: string; key: string } | null {
  const env = import.meta.env as Record<string, string | undefined> | undefined;
  const url = env?.VITE_SUPABASE_URL;
  const key = env?.VITE_SUPABASE_ANON_KEY;
  return url && key ? { url, key } : null;
}

/**
 * Otomasyon (Playwright, `navigator.webdriver`) ve KENDİNİ bot olarak
 * tanıtan istemciler sayılmaz. `guest_visits` botları `'bot'` damgasıyla
 * saklamaya devam ediyor (ölçüm için); bir kohort hunisinde ise bot hiçbir
 * zaman "gelen kişi" değil.
 */
function isExcluded(): boolean {
  try {
    return navigator.webdriver === true || isBotUserAgent(navigator.userAgent || '');
  } catch {
    return true;
  }
}

function send(
  anonId: string,
  event: FunnelEvent,
  channel: string | null = null,
): Promise<boolean> {
  const ep = endpoint();
  if (!ep) return Promise.resolve(false);
  return fetch(`${ep.url}/rest/v1/rpc/log_funnel_event`, {
    method: 'POST',
    keepalive: true,
    headers: {
      apikey: ep.key,
      Authorization: `Bearer ${ep.key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      p_anon_id: anonId,
      p_platform: 'web' satisfies FunnelPlatform,
      p_event: event,
      p_channel: channel,
      // Web'in sürümü yok: derleme sha'sıyla zaten tekil (`logGameStart` ile aynı).
      p_app_version: null,
    }),
  }).then(
    (r) => r.ok,
    () => false, // Telemetri hiçbir koşulda akışı bozmaz.
  );
}

function readLand(): LandState | null {
  try {
    const raw = localStorage.getItem(LAND_KEY);
    if (!raw) return null;
    const v = JSON.parse(raw) as Partial<LandState>;
    return typeof v.channel === 'string' ? { channel: v.channel, sent: v.sent === true } : null;
  } catch {
    return null;
  }
}

function writeLand(s: LandState): void {
  try {
    localStorage.setItem(LAND_KEY, JSON.stringify(s));
  } catch {
    // Depolama kapalı: bir sonraki yükleme yeniden dener (sunucu idempotent).
  }
}

function storageKeys(): string[] {
  try {
    const keys: string[] = [];
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (k) keys.push(k);
    }
    return keys;
  } catch {
    return [];
  }
}

/**
 * Sayfa açılışı: `land` (gerekirse) + günün `visit`i. `main.tsx` bunu kapı
 * kararından ÖNCE, HİÇBİR ŞEY yazılmadan çağırır — karşılama katmanı da SPA
 * da sayılsın ve "önceden iz var mı" okuması temiz kalsın diye.
 *
 * `captureUtm` = `?ref=` yakalayıcı (`captureUtmSource`); iz OKUNDUKTAN
 * SONRA çağrılmalı, çünkü kendisi de bir `kelimeki:` anahtarı yazar.
 */
export function funnelOpen(captureUtm: () => void): void {
  if (!endpoint() || isExcluded()) return;
  const trace = hasPriorTrace(storageKeys());
  captureUtm();
  const anonId = getOrCreateAnonId();
  if (!anonId) return; // depolama yoksa kimlik de yok — sayılamaz

  const plan = planLand(readLand(), trace, getStoredUtmSource());
  if (plan.send) {
    writeLand(plan.state);
    void send(anonId, 'land', plan.state.channel).then((ok) => {
      if (ok) writeLand({ ...plan.state, sent: true });
    });
  }

  const today = istanbulDay(Date.now());
  let last: string | null = null;
  try {
    last = localStorage.getItem(VISIT_KEY);
  } catch {
    // yukarıdaki gibi
  }
  if (shouldSendVisit(last, today)) {
    void send(anonId, 'visit').then((ok) => {
      if (!ok) return;
      try {
        localStorage.setItem(VISIT_KEY, today);
      } catch {
        // yoksay
      }
    });
  }
}

/**
 * Oyun/üyelik olayı. `isGuest` çağıranın o anki oturum durumu. Metnin
 * kapsamı dışındaki olay (`funnelEventAllowed`) SESSİZCE gönderilmez.
 */
export function funnelEvent(event: 'signup' | 'game_start' | 'game_finish', isGuest: boolean): void {
  if (!funnelEventAllowed(event, isGuest) || isExcluded()) return;
  const anonId = getOrCreateAnonId();
  if (!anonId) return;
  void send(anonId, event);
}
