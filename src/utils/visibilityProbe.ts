/**
 * GEÇİCİ TEŞHİS (12 Ekim 2026) — 31-33. saniye yığılmasının kaynağı.
 * Bkz. docs/decisions/admin-panel.md → "Yığılmanın kaynağını bulma".
 *
 * #787'nin `visibilityState` kapısı Android + Meta yığılmasını gidermedi.
 * Bu modül sayfa başına BİR satır (`visibility_probe`) yazar: sayfa
 * yüklendiği andaki sinyaller (visibilityState, hasFocus, yükleme süresi,
 * uygulama-içi tarayıcı türü) ve sayfanın ömrü boyunca gerçek (`isTrusted`)
 * bir kullanıcı girdisi olup olmadığı. Hayalet (arka planda yüklenip atılan)
 * ile gerçek ziyareti hangi sinyalin ayırdığı canlıdan okunacak.
 *
 * ⚠ GEÇİCİ — ölçüm bitince bu dosya, `main.tsx`teki tek çağrı ve
 * `visibility_probe` tablosu/fonksiyonu SİLİNİR. Hiçbir kararı etkilemez;
 * hiçbir koşulda akışı bozmaz (hata yutulur). Ham user-agent SAKLANMAZ,
 * yalnızca türetilmiş `in_app` etiketi gider.
 */
import { isBotUserAgent } from './visitTracking';

export type InAppKind = 'instagram' | 'facebook' | 'other-wv' | 'none';

/** UA'dan yalnızca uygulama-içi tarayıcı TÜRÜ — ham metin dışarı çıkmaz. */
export function detectInApp(ua: string): InAppKind {
  if (/Instagram/i.test(ua)) return 'instagram';
  if (/FBAN|FBAV|FB_IAB|FBIOS/i.test(ua)) return 'facebook';
  if (/; wv\)/i.test(ua)) return 'other-wv';
  return 'none';
}

export interface ProbeState {
  visState: string;
  hasFocus: boolean;
  loadMs: number;
  inApp: InAppKind;
  becameVisibleMs: number | null;
  firstInputMs: number | null;
  inputCount: number;
  aliveMs: number;
}

/** Saf: gövdeyi kurar (test edilebilsin diye ağdan ayrı). */
export function buildProbeBody(
  id: string,
  deviceType: string,
  utmSource: string | null,
  s: ProbeState,
): Record<string, unknown> {
  return {
    p_id: id,
    p_device_type: deviceType,
    p_utm_source: utmSource,
    p_vis_state: s.visState,
    p_has_focus: s.hasFocus,
    p_load_ms: Math.round(s.loadMs),
    p_in_app: s.inApp,
    p_became_visible_ms: s.becameVisibleMs === null ? null : Math.round(s.becameVisibleMs),
    p_first_input_ms: s.firstInputMs === null ? null : Math.round(s.firstInputMs),
    p_input_count: s.inputCount,
    p_alive_ms: Math.round(s.aliveMs),
  };
}

const FINAL_PING_MS = 20_000;
const INPUT_EVENTS = ['pointerdown', 'touchstart', 'keydown', 'scroll', 'wheel'] as const;

function randomId(): string {
  try {
    return crypto.randomUUID();
  } catch {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
    });
  }
}

function endpoint(): { url: string; key: string } | null {
  const env = import.meta.env as Record<string, string | undefined> | undefined;
  const url = env?.VITE_SUPABASE_URL;
  const key = env?.VITE_SUPABASE_ANON_KEY;
  return url && key ? { url, key } : null;
}

function send(body: Record<string, unknown>): void {
  const ep = endpoint();
  if (!ep) return;
  void fetch(`${ep.url}/rest/v1/rpc/record_visibility_probe`, {
    method: 'POST',
    keepalive: true,
    headers: {
      apikey: ep.key,
      Authorization: `Bearer ${ep.key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  }).then(
    () => undefined,
    () => undefined,
  );
}

/** Karşılama açılışında BİR kez çağrılır. Yalnızca mobil (yığılma orada). */
export function startVisibilityProbe(deviceType: string, utmSource: string | null): void {
  try {
    if (typeof document === 'undefined') return;
    if (deviceType !== 'android' && deviceType !== 'ios') return;
    const ua = navigator.userAgent || '';
    if (navigator.webdriver === true || isBotUserAgent(ua)) return;

    const id = randomId();
    const inApp = detectInApp(ua);
    const state: ProbeState = {
      visState: document.visibilityState,
      hasFocus: document.hasFocus(),
      loadMs: performance.now(),
      inApp,
      becameVisibleMs: document.visibilityState === 'visible' ? performance.now() : null,
      firstInputMs: null,
      inputCount: 0,
      aliveMs: 0,
    };
    const ping = (): void => {
      state.aliveMs = performance.now();
      send(buildProbeBody(id, deviceType, utmSource, state));
    };
    ping();

    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible' && state.becameVisibleMs === null) {
        state.becameVisibleMs = performance.now();
      } else if (document.visibilityState === 'hidden') {
        ping();
      }
    });
    const onInput = (e: Event): void => {
      if (!e.isTrusted) return;
      if (state.firstInputMs === null) state.firstInputMs = performance.now();
      state.inputCount += 1;
    };
    for (const name of INPUT_EVENTS) {
      // Kaydırma karşılama kabında (`#karsilama`) olabilir: yakalama evresi.
      document.addEventListener(name, onInput, { capture: true, passive: true });
    }
    window.setTimeout(ping, FINAL_PING_MS);
    window.addEventListener('pagehide', ping);
  } catch {
    // Telemetri hiçbir koşulda akışı bozmaz.
  }
}
