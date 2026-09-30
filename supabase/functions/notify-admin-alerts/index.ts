// Kelimeki — kritik hata uyarısı: admine push + e-posta (30 Eylül 2026).
//
// Kullanıcı: *"ben bunlara bakmazsam sorunu zamanında görmek zor. Kritik bir
// sorun olduğunda bana email veya başka şekilde bir uyarı gelse iyi olur.
// Bana özel app push da olabilir."*
//
// İKİ MOD (gövde `{ "mode": ... }`, ikisi de pg_cron'dan):
//   scan  — 15 dakikada bir. KARAR SQL'de (`admin_alert_scan`): son 1 saatte
//           çökme/yakalanmamış ≥3 cihaz · herhangi bir hata ≥10 cihaz ·
//           oturum fırtınası (`auth-null-burst` / `depo=dolu`) tek cihazda
//           bile. Aynı imza 24 saatte BİR kez — iddia atomik, eşzamanlı iki
//           çağrı aynı uyarıyı iki kez göndermez.
//   daily — 09:00 İstanbul. Son 24 saatin özeti (`admin_alert_daily`),
//           İstanbul günü başına bir kez; hata yoksa "sessiz gün" yazar.
//
// ALICI: `profiles.is_admin` olan HER hesap — push onun cihazlarına
// (`sendPushToUser`, tercih kapalıysa atlanır), e-posta auth adresine.
// Adres koda GÖMÜLMEZ.
//
// ⚠ `verify_jwt:false` (cron JWT'siz çağırıyor) → uç herkese açık. Zarar
// sınırı: uç HİÇBİR veri döndürmez (yalnızca sayılar), yalnızca admine
// gönderir ve SQL tarafı her uyarıyı 24 saatte / günde bir kez iddia eder;
// yani dışarıdan tetiklemek en fazla ZATEN gidecek bir uyarıyı öne çeker.
// Bu fonksiyon `CLAUDE.md`'deki `verify_jwt:false` envanterinde.
import { createClient } from 'jsr:@supabase/supabase-js@2';
import {
  CORS_HEADERS,
  buildBrandedEmailHtml,
  buildNoReplyNoticeHtml,
  escapeHtml,
  sendBrevoEmail,
} from '../_shared/email.ts';
import { sendPushToUser } from '../_shared/push.ts';

const BREVO_API_KEY = Deno.env.get('BREVO_API_KEY');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const CRON_SECRET = Deno.env.get('CRON_SECRET');

const PANEL_URL = 'https://kelimeki.com/';

interface ScanRow {
  alert_key: string;
  category: 'crash' | 'spike' | 'auth';
  kind: string;
  signature: string;
  platforms: string | null;
  hits: number;
  devices: number;
}

interface DailyRow {
  signature: string | null;
  kind: string | null;
  platforms: string | null;
  hits: number | null;
  devices: number | null;
  total_hits: number;
  total_devices: number;
}

const BASLIK: Record<ScanRow['category'], string> = {
  crash: 'Çökme',
  spike: 'Ani hata artışı',
  auth: 'Oturum fırtınası',
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}

function kisalt(s: string, n: number): string {
  return s.length > n ? `${s.slice(0, n - 1)}…` : s;
}

function satirHtml(r: { signature: string | null; kind: string | null; platforms: string | null; hits: number | null; devices: number | null }): string {
  return `<tr>
    <td style="padding:8px 0;border-bottom:1px solid #DCE2EA;font-size:13px;line-height:1.5;color:#1B2430;font-family:Menlo,monospace;">${escapeHtml(r.signature ?? '')}</td>
  </tr>
  <tr>
    <td style="padding:2px 0 10px 0;font-size:12px;color:#8A93A2;">${escapeHtml(r.kind ?? '')} · ${escapeHtml(r.platforms ?? '')} · <b>${r.hits ?? 0}</b> kez · <b>${r.devices ?? 0}</b> cihaz</td>
  </tr>`;
}

async function adminler(db: ReturnType<typeof createClient>): Promise<{ id: string; email: string | null }[]> {
  const { data } = await db.from('profiles').select('id').eq('is_admin', true);
  const sonuc: { id: string; email: string | null }[] = [];
  for (const row of (data ?? []) as { id: string }[]) {
    const { data: u } = await db.auth.admin.getUserById(row.id);
    sonuc.push({ id: row.id, email: u?.user?.email ?? null });
  }
  return sonuc;
}

async function gonder(
  db: ReturnType<typeof createClient>,
  push: { title: string; body: string; tag: string },
  mail: { subject: string; html: string },
): Promise<{ push: number; mail: number }> {
  let pushSayisi = 0;
  let mailSayisi = 0;
  for (const a of await adminler(db)) {
    pushSayisi += await sendPushToUser(db, a.id, push);
    if (BREVO_API_KEY && a.email) {
      try {
        const res = await sendBrevoEmail(BREVO_API_KEY, {
          to: { email: a.email },
          subject: mail.subject,
          htmlContent: mail.html,
        });
        if (res.ok) mailSayisi += 1;
        else console.error('[admin-alert] e-posta düştü:', res.status, await res.text());
      } catch (err) {
        console.error('[admin-alert] e-posta düştü:', err);
      }
    }
  }
  return { push: pushSayisi, mail: mailSayisi };
}

async function tara(db: ReturnType<typeof createClient>) {
  const { data, error } = await db.rpc('admin_alert_scan');
  if (error) throw error;
  const rows = (data ?? []) as ScanRow[];
  if (rows.length === 0) return { alerts: 0 };

  // En ağırı başa: fırtına > çökme > artış.
  const sira = { auth: 0, crash: 1, spike: 2 } as const;
  rows.sort((a, b) => sira[a.category] - sira[b.category] || b.devices - a.devices);
  const ilk = rows[0];
  const title = `⚠ Kelimeki: ${BASLIK[ilk.category]}${rows.length > 1 ? ` (+${rows.length - 1})` : ''}`;
  const body = `${ilk.devices} cihaz · ${ilk.hits} kez (son 1 sa) — ${kisalt(ilk.signature, 110)}`;
  const html = buildBrandedEmailHtml(
    'Kritik hata uyarısı',
    `<p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;color:#1B2430;">Son 1 saatte eşiği aşan ${rows.length} hata var. Ayrıntı: Admin Paneli → <b>Hatalar</b>.</p>
     ${rows.map((r) => `<p style="margin:16px 0 4px 0;font-size:13px;font-weight:700;color:#DC2626;">${BASLIK[r.category]}</p><table role="presentation" width="100%" cellspacing="0" cellpadding="0">${satirHtml(r)}</table>`).join('')}
     <p style="margin:24px 0 0 0;font-size:12px;color:#8A93A2;">Aynı hata için 24 saat içinde tekrar uyarı gönderilmez. <a href="${PANEL_URL}" style="color:#2563EB;">kelimeki.com</a></p>`,
    buildNoReplyNoticeHtml(),
  );
  const sent = await gonder(
    db,
    // Tek etiket: yeni uyarı paneldekinin YERİNE geçer (tür öneki `alarm:`).
    { title, body, tag: 'alarm:kritik' },
    { subject: title, html },
  );
  return { alerts: rows.length, ...sent };
}

async function ozet(db: ReturnType<typeof createClient>) {
  const { data, error } = await db.rpc('admin_alert_daily', { p_limit: 5 });
  if (error) throw error;
  const rows = (data ?? []) as DailyRow[];
  if (rows.length === 0) return { daily: 'bugün zaten gönderildi' };
  const top = rows.filter((r) => r.signature !== null);
  const th = rows[0].total_hits;
  const td = rows[0].total_devices;
  const title = th === 0 ? 'Kelimeki: sessiz gün — hata yok' : `Kelimeki günlük hata özeti: ${th} kez · ${td} cihaz`;
  const body = th === 0
    ? 'Son 24 saatte hiç istemci hatası kaydedilmedi.'
    : `En çok: ${kisalt(top[0]?.signature ?? '', 100)} (${top[0]?.devices ?? 0} cihaz)`;
  const html = buildBrandedEmailHtml(
    'Günlük hata özeti',
    th === 0
      ? `<p style="margin:0;font-size:15px;line-height:1.6;color:#1B2430;">Son 24 saatte hiç istemci hatası kaydedilmedi.</p>`
      : `<p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;color:#1B2430;">Son 24 saat: <b>${th}</b> kayıt, <b>${td}</b> cihaz. En çok cihazı etkileyen ${top.length} hata:</p>
         <table role="presentation" width="100%" cellspacing="0" cellpadding="0">${top.map(satirHtml).join('')}</table>
         <p style="margin:24px 0 0 0;font-size:12px;color:#8A93A2;">Ayrıntı: Admin Paneli → Hatalar · <a href="${PANEL_URL}" style="color:#2563EB;">kelimeki.com</a></p>`,
    buildNoReplyNoticeHtml(),
  );
  // Günlük özet PUSH GÖNDERMEZ — yalnızca e-posta. Telefonu her sabah
  // çaldırmak kritik uyarının değerini düşürürdü (push = acil, mail = kayıt).
  let mail = 0;
  for (const a of await adminler(db)) {
    if (!BREVO_API_KEY || !a.email) continue;
    const res = await sendBrevoEmail(BREVO_API_KEY, { to: { email: a.email }, subject: title, htmlContent: html });
    if (res.ok) mail += 1;
    else console.error('[admin-alert] özet düştü:', res.status, await res.text());
  }
  return { daily: 'gönderildi', mail, body };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS });
  if (CRON_SECRET && req.headers.get('Authorization') !== `Bearer ${CRON_SECRET}`) {
    return jsonResponse({ error: 'Yetkisiz.' }, 401);
  }
  let body: Record<string, unknown> = {};
  try { body = await req.json(); } catch { /* gövdesiz = scan */ }
  const db = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  try {
    const sonuc = body.mode === 'daily' ? await ozet(db) : await tara(db);
    // Yalnızca sayılar döner — hata metni/imza uca ASLA yazılmaz.
    return jsonResponse({ ok: true, ...('body' in sonuc ? { daily: sonuc.daily, mail: sonuc.mail } : sonuc) });
  } catch (err) {
    console.error('[admin-alert] düştü:', err);
    return jsonResponse({ ok: false }, 500);
  }
});
