// Kelimeki — web ziyaretçi yolculuğu: ziyaretçi NEREDE ayrılıyor?
//
// 23 Eylül 2026, kullanıcı isteği: *"Bizim web tarafında bounce rate'leri
// görmemiz lazım. Ziyaretçiler hangi noktalarda bounce ediyor."* Sunucu
// tarafı ve gerekçenin tamamı: `supabase/migrations/20260923103044_web_sessions_journey.sql`.
//
// Sekme başına TEK bir oturum satırı (`web_sessions`). Her yeni adımda ve
// sekme gizlenirken aynı satır güncellenir; admin panelindeki "Ziyaretçi
// Yolculuğu" kartı her adımda kaç oturumun SON adımının o olduğunu sayar.
//
// ⚠ KİMLİK YOK (kullanıcı kararı: *"Gizlilik metnine dokunmadan başla"*):
// oturum kodu `sessionStorage`'da durur, sekme kapanınca silinir ve cihazdaki
// kalıcı anonim kodla (`getOrCreateAnonId`) hiçbir bağı yoktur. Buraya
// `anon_id` EKLEMEK gizlilik metnini (ve portun kopyasını) değiştirmeyi
// gerektirir — bkz. ROADMAP #33.
//
// ⚠ Yalnızca MİSAFİR oturumu yazılır. Girişli başlayan oturum hiç yazılmaz;
// misafir başlayıp giriş/kayıt yapan oturum `login`/`signup_done` ile kapanır.
//
// Dosya iki katmanlı: `reduceJourney` SAF (tarayıcıya dokunmaz, `npm run
// verify-web-journey` onu doğrudan koşar), altındaki `journey*` işlevleri onu
// `sessionStorage` + `fetch`'e bağlayan ince kabuk. Karşılama katmanı
// (`main.tsx`) da bunu import ettiği için Supabase SDK'sı KULLANILMIYOR —
// `misafirZiyaretiBildir` ile aynı bundle gerekçesi, düz `fetch`.

import { isBotUserAgent } from './visitTracking';
import { pageWasVisible, whenPageVisible } from './pageVisible';

/**
 * Adımlar, admin kartındaki SIRAYLA. ⚠ Sunucudaki iki fonksiyonun
 * (`record_web_session`, `admin_web_journey`) `v_steps` dizisiyle BİREBİR
 * aynı olmalı — `npm run verify-web-journey` karşılaştırır.
 */
export const JOURNEY_STEPS = [
  'landing', // karşılama sayfası göründü
  'landing_cta', // karşılamadan uygulamaya geçti (Oyna / Giriş / hukuki bağlantı)
  'app', // uygulama (kurulum ekranı) açıldı
  'tutorial_start', // "Oynayarak öğren" tanıtımı açıldı
  'tutorial_done', // tanıtım sonuna kadar oynandı (atlama SAYILMAZ; atlayanlar admin kartında
  //                  türetilmiş `tutorial_skip` satırı — sunucu hesaplar, istemci GÖNDERMEZ)
  'game_start', // YZ'ye karşı oyun başladı
  'first_move', // oyuncu ilk hamlesini yaptı
  'move_5', // oyuncu 5. hamlesini yaptı
  'game_finish', // oyun bitti
  'signup_form', // kayıt formu açıldı
  'signup_done', // hesap oluştu — oturum kapanır
  'login', // mevcut hesaba giriş yaptı — oturum kapanır
  // Mağaza rozetine / şeridine dokundu (28 Eylül 2026, Meta kampanyası:
  // reklam `kelimeki.com/?ref=…`e gidiyor, mağazaya buradan geçiliyor).
  // Oturumu KAPATMAZ — kişi dönüp tarayıcıda oynayabilir. SONA eklendi,
  // çünkü sıra admin kartının satır sırası; araya girse eski satırlar kayardı.
  'store',
] as const;

export type JourneyStep = (typeof JOURNEY_STEPS)[number];
export type JourneyEntry = 'landing' | 'app';

/** Oturum başına YALNIZCA bir kez gönderilen adımlar (yeniden yüklemede tekrar etmesin). */
const ONCE: ReadonlySet<JourneyStep> = new Set<JourneyStep>([
  'landing',
  'landing_cta',
  'app',
  'first_move',
  'move_5',
  'signup_done',
  'login',
  'store',
]);

/** Oturumu KAPATAN adımlar — misafir üye oldu, bundan sonrası bu soruyla ilgisiz. */
const TERMINAL: ReadonlySet<JourneyStep> = new Set<JourneyStep>(['signup_done', 'login']);

export interface JourneySession {
  id: string;
  entry: JourneyEntry;
  /** Oturum misafirken başladı mı. `false` → hiçbir şey yazılmaz. */
  guest: boolean;
  /**
   * Uygulama bir oturum gördü (giriş yapıldı) → adım yazımı durur. AMA
   * `login`/`signup_done` yine geçer: auth olayı AuthModal'ın kendi adım
   * çağrısından ÖNCE gelebiliyor ve o yarışta kapanış adımı düşmemeli.
   */
  member: boolean;
  /** Kapanış adımı gönderildi — artık hiçbir şey yazılmaz. */
  closed: boolean;
  startMs: number;
  /**
   * GÖRÜNÜR süre birikimi (15 Ekim 2026). `seconds` artık duvar saati DEĞİL:
   * Android Meta uygulama-içi tarayıcıda reklama dokunup ~2 sn'de dönen kişinin
   * sayfası arka planda ~30 sn daha yaşıyor ve `pagehide` o ana kadarki duvar
   * saatini yazıyordu ("32 sn kaldı" yığılması; `visibility_probe` ölçümü,
   * `docs/decisions/admin-panel.md` → "Yığılmanın kaynağını bulma").
   * `visibleMs` kapanmış görünür aralıkların toplamı, `visibleSince` açık
   * aralığın başlangıcı (`null` = şu an gizli). ⚠ İKİSİ DE opsiyonel: bu alanlar
   * gelmeden önce `sessionStorage`a yazılmış bir oturum (sekme açıkken deploy)
   * eski anlamıyla sürer, bkz. `visibleState`.
   */
  visibleMs?: number;
  visibleSince?: number | null;
  moves: number;
  scrollPct: number | null;
  sent: JourneyStep[];
}

export interface JourneyPing {
  id: string;
  entry: JourneyEntry;
  /** `null` → adımsız güncelleme (sekme gizlendi): yalnızca sayılar. */
  step: JourneyStep | null;
  moves: number;
  seconds: number;
  scrollPct: number | null;
}

export type JourneyEvent =
  | { type: 'start'; entry: JourneyEntry; member: boolean }
  | { type: 'step'; step: JourneyStep }
  | { type: 'moves'; count: number }
  | { type: 'scroll'; pct: number }
  /** Sekme gizlendi / sayfa kapanıyor (`visibilitychange: hidden`, `pagehide`): görünür aralığı kapatır + adımsız ping. */
  | { type: 'hide' }
  /** Sekme yeniden göründü (`visibilitychange: visible`, bfcache dönüşü): yeni görünür aralık, ping YOK. */
  | { type: 'show' };

export interface JourneyResult {
  session: JourneySession | null;
  pings: JourneyPing[];
}

/**
 * Oturumun görünür-süre durumu. Alanları olmayan (eski sürümden kalma) oturum
 * eski anlamıyla sürer: o âna kadarki duvar saati birikmiş sayılır ve açık bir
 * aralık başlar — bir kerelik küçük sapma, bundan sonrası doğru.
 */
function visibleState(s: JourneySession, nowMs: number): { ms: number; since: number | null } {
  if (s.visibleMs === undefined) return { ms: Math.max(0, nowMs - s.startMs), since: nowMs };
  return { ms: s.visibleMs, since: s.visibleSince ?? null };
}

/** Şu ana kadar GÖRÜNÜR kalınan süre (ms). Gizliyken artmaz. */
function visibleTotalMs(s: JourneySession, nowMs: number): number {
  const { ms, since } = visibleState(s, nowMs);
  return ms + (since === null ? 0 : Math.max(0, nowMs - since));
}

function ping(s: JourneySession, step: JourneyStep | null, nowMs: number): JourneyPing {
  return {
    id: s.id,
    entry: s.entry,
    step,
    moves: s.moves,
    seconds: Math.max(0, Math.round(visibleTotalMs(s, nowMs) / 1000)),
    scrollPct: s.scrollPct,
  };
}

function withStep(s: JourneySession, step: JourneyStep, nowMs: number): JourneyResult {
  if (ONCE.has(step) && s.sent.includes(step)) return { session: s, pings: [] };
  const next: JourneySession = {
    ...s,
    sent: s.sent.includes(step) ? s.sent : [...s.sent, step],
    closed: s.closed || TERMINAL.has(step),
  };
  return { session: next, pings: [ping(next, step, nowMs)] };
}

/** Oturum hâlâ misafir adımı yazıyor mu. */
function writing(s: JourneySession | null): s is JourneySession {
  return !!s && s.guest && !s.member && !s.closed;
}

/**
 * SAF karar: mevcut oturum + olay → yeni oturum + gönderilecek pingler.
 * `newId` yalnızca yeni oturum açılırken çağrılır.
 */
export function reduceJourney(
  s: JourneySession | null,
  ev: JourneyEvent,
  nowMs: number,
  newId: () => string,
): JourneyResult {
  switch (ev.type) {
    case 'start': {
      if (!s) {
        const fresh: JourneySession = {
          id: newId(),
          entry: ev.entry,
          guest: !ev.member,
          member: ev.member,
          closed: false,
          startMs: nowMs,
          visibleMs: 0,
          visibleSince: nowMs,
          moves: 0,
          scrollPct: null,
          sent: [],
        };
        if (ev.member) return { session: fresh, pings: [] };
        return withStep(fresh, ev.entry === 'landing' ? 'landing' : 'app', nowMs);
      }
      // Mevcut oturum: karşılamadan uygulamaya geçildi ya da sekme yeniden
      // yüklendi. Uygulama bir giriş görürse yazım durur (sessizce — kapanış
      // adımını AuthModal kendisi gönderir). Sayfa YENİ yüklendiği için yeni
      // bir görünür aralık başlar (önceki sayfa `pagehide`ta kapattı; kapatamadan
      // ölmüşse o aralığın süresi kaybolur — fazladan saymaktan iyi).
      const v = visibleState(s, nowMs);
      const resumed: JourneySession = { ...s, visibleMs: v.ms, visibleSince: nowMs };
      if (ev.member) return { session: { ...resumed, member: true }, pings: [] };
      if (!writing(resumed) || ev.entry !== 'app') return { session: resumed, pings: [] };
      return withStep(resumed, 'app', nowMs);
    }
    case 'step': {
      if (!s || !s.guest || s.closed) return { session: s, pings: [] };
      if (s.member && !TERMINAL.has(ev.step)) return { session: s, pings: [] };
      return withStep(s, ev.step, nowMs);
    }
    case 'moves': {
      if (!writing(s) || ev.count <= s.moves) return { session: s, pings: [] };
      let cur: JourneySession = { ...s, moves: ev.count };
      const pings: JourneyPing[] = [];
      for (const [esik, adim] of [
        [1, 'first_move'],
        [5, 'move_5'],
      ] as const) {
        if (ev.count >= esik) {
          const r = withStep(cur, adim, nowMs);
          cur = r.session as JourneySession;
          pings.push(...r.pings);
        }
      }
      return { session: cur, pings };
    }
    case 'scroll': {
      if (!writing(s)) return { session: s, pings: [] };
      const pct = Math.max(0, Math.min(100, Math.round(ev.pct)));
      if (s.scrollPct !== null && pct <= s.scrollPct) return { session: s, pings: [] };
      return { session: { ...s, scrollPct: pct }, pings: [] };
    }
    case 'hide': {
      if (!writing(s)) return { session: s, pings: [] };
      // Açık aralığı KAPAT; ikinci bir `hide` (gizlendikten sonra `pagehide`)
      // süreyi ARTIRMAZ — "32 sn" yığılmasının düzeltmesi tam burada.
      const v = visibleState(s, nowMs);
      const closed: JourneySession = {
        ...s,
        visibleMs: v.ms + (v.since === null ? 0 : Math.max(0, nowMs - v.since)),
        visibleSince: null,
      };
      return { session: closed, pings: [ping(closed, null, nowMs)] };
    }
    case 'show': {
      if (!writing(s)) return { session: s, pings: [] };
      const v = visibleState(s, nowMs);
      if (v.since !== null && s.visibleMs !== undefined) return { session: s, pings: [] };
      return { session: { ...s, visibleMs: v.ms, visibleSince: nowMs }, pings: [] };
    }
  }
}

// ── Tarayıcı kabuğu ─────────────────────────────────────────────────────────

const STORAGE_KEY = 'kelimeki_web_journey_v1';

let memorySession: JourneySession | null = null;

function load(): JourneySession | null {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as JourneySession) : null;
  } catch {
    // Depolama kapalı (gizli sekme / kısıtlı WebView): oturum sayfa ömrüyle sınırlı kalır.
    return memorySession;
  }
}

function save(s: JourneySession | null): void {
  memorySession = s;
  try {
    if (s) sessionStorage.setItem(STORAGE_KEY, JSON.stringify(s));
  } catch {
    // Yukarıdaki gibi: bellekteki kopya yeter.
  }
}

function randomId(): string {
  try {
    if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
      return crypto.randomUUID();
    }
  } catch {
    // Güvenli olmayan bağlam — aşağıdaki yedek.
  }
  // RFC 4122 v4 biçiminde yedek (Safari < 15.4). Kriptografik olması
  // gerekmiyor: kod yalnızca aynı satırı güncellemek için var.
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

/**
 * Otomasyon tarayıcıları (Playwright, `navigator.webdriver`) ve KENDİNİ bot
 * olarak tanıtan istemciler sayılmaz — `funnelEvents.ts` ile aynı kapı.
 * 30 Eylül 2026'ya kadar yalnızca `webdriver` bakılıyordu ve bir haftalık
 * dökümde bot ziyaretlerinin neredeyse hepsinin karşısında bir "karşılamada
 * ayrıldı" oturumu çıktı (Meta reklam inceleme botları dahil, kampanya
 * etiketleriyle). Kullanıcı kararı: *"botları sayımdan çıkar"*.
 */
function isAutomated(): boolean {
  try {
    return navigator.webdriver === true || isBotUserAgent(navigator.userAgent || '');
  } catch {
    return false;
  }
}

function endpoint(): { url: string; key: string } | null {
  const env = import.meta.env as Record<string, string | undefined> | undefined;
  const url = env?.VITE_SUPABASE_URL;
  const key = env?.VITE_SUPABASE_ANON_KEY;
  return url && key ? { url, key } : null;
}

function post(p: JourneyPing, deviceType: string, utmSource: string | null): Promise<void> {
  const ep = endpoint();
  if (!ep) return Promise.resolve();
  return fetch(`${ep.url}/rest/v1/rpc/record_web_session`, {
    method: 'POST',
    // Sekme kapanırken de istek tamamlansın diye.
    keepalive: true,
    headers: {
      apikey: ep.key,
      Authorization: `Bearer ${ep.key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      p_id: p.id,
      p_entry: p.entry,
      p_step: p.step,
      p_device_type: deviceType,
      p_utm_source: utmSource,
      p_moves: p.moves,
      p_seconds: p.seconds,
      p_scroll_pct: p.scrollPct,
    }),
  }).then(
    () => undefined,
    () => undefined, // Telemetri hiçbir koşulda akışı bozmaz.
  );
}

// Adımlı pingler SIRAYLA gider: `landing_cta` ile `app` milisaniyeler içinde
// ateşleniyor ve sunucu `last_step`i gelen sıraya göre yazıyor — paralel
// giderlerse ters sırada varıp ziyaretçiyi yanlış adımda "ayrılmış" gösterirdi.
// Adımsız pingler `last_step`e dokunmadığı için sırayı beklemez (sekme
// kapanırken kuyrukta beklemek pingi kaybettirirdi).
let chain: Promise<void> = Promise.resolve();

let context: { deviceType: string; utmSource: string | null } = {
  deviceType: 'desktop',
  utmSource: null,
};

function dispatch(ev: JourneyEvent): void {
  if (isAutomated()) return;
  // Arka planda yüklenip henüz görünmemiş sayfa (bkz. utils/pageVisible.ts):
  // olaylar sırasıyla bekletilir, sayfa görününce o anki saatle işlenir —
  // yani süre de GÖRÜNDÜĞÜ andan sayılır. Görünmeden kapanırsa hiçbiri
  // gitmez; `hide`/`show` bekletilmez (oturum yokken zaten bir şey üretmezler).
  if (!pageWasVisible()) {
    if (ev.type !== 'hide' && ev.type !== 'show') whenPageVisible(() => dispatch(ev));
    return;
  }
  const r = reduceJourney(load(), ev, Date.now(), randomId);
  save(r.session);
  const { deviceType, utmSource } = context;
  for (const p of r.pings) {
    if (p.step === null) {
      void post(p, deviceType, utmSource);
    } else {
      chain = chain.then(() => post(p, deviceType, utmSource));
    }
  }
}

let flushInstalled = false;

function installFlush(): void {
  if (flushInstalled || typeof document === 'undefined') return;
  flushInstalled = true;
  document.addEventListener('visibilitychange', () => {
    dispatch({ type: document.visibilityState === 'hidden' ? 'hide' : 'show' });
  });
  window.addEventListener('pagehide', () => dispatch({ type: 'hide' }));
  // bfcache'ten dönüş: sayfa yeniden göründü ama `visibilitychange` ateşlenmeyebilir.
  window.addEventListener('pageshow', (e) => {
    if (e.persisted) dispatch({ type: 'show' });
  });
}

/**
 * Oturumu başlatır ya da (karşılamadan uygulamaya geçişte / yeniden
 * yüklemede) sürdürür. `member` → oturum girişli: yazım durur.
 * `deviceType`/`utmSource` her pinge eklenir (sunucu yalnızca ilk satırda
 * saklıyor).
 */
export function journeyStart(
  entry: JourneyEntry,
  member: boolean,
  deviceType: string,
  utmSource: string | null,
): void {
  context = { deviceType, utmSource };
  installFlush();
  dispatch({ type: 'start', entry, member });
}

export function journeyStep(step: JourneyStep): void {
  dispatch({ type: 'step', step });
}

/** Bu oturumda başlatılan oyunda insan oyuncunun toplam hamle sayısı. */
export function journeyMoves(count: number): void {
  dispatch({ type: 'moves', count });
}

/** Karşılama sayfasında ulaşılan kaydırma derinliği (%). */
export function journeyScroll(pct: number): void {
  dispatch({ type: 'scroll', pct });
}
