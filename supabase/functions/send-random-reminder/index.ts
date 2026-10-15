// Kelimeki — BİR SEFERLİK hatırlatma e-postası (13 Ekim 2026, kullanıcı kararı):
// hiç oyun bitirmemiş, pazarlama izni veren üyelere "Rastgele Oyun" duyurusu.
// Düğme `kelimeki.com/?rastgele=1` (Rastgele Oyuncu seçili formu açar,
// docs/decisions/random-opponent.md §21).
//
// ⚠ KALICI BİR AKIŞ DEĞİL. Kullanıldıktan sonra aynı adla 410 dönen bir
// taslakla yeniden yayınlanır (MCP'de fonksiyon silme aracı yok).
// KENDİ İÇİNDE YETERLİ yazıldı (`_shared/email.ts` import edilmiyor): tek
// seferlik dosya için paylaşılan yardımcıyı kopyalamak yerine görünümü burada
// yinelemek, dağıtım dosya yerleşimi tuzağından (CLAUDE.md "Edge Function
// deploy") kaçınıyor. Marka kartı `_shared/email.ts` → buildBrandedEmailHtml'in kopyası.
//
// GÜVENLİK: verify_jwt AÇIK ama anon anahtarı herkese açık olduğundan tek başına
// yetmez → `x-reminder-key` başlığı KEY ile eşleşmeli. Repodaki KEY bir YER
// TUTUCU; gerçek değer yalnızca dağıtılan kopyada ve işten sonra o kopya
// 410 taslağıyla değişir. Alıcı kimlikleri istemciden gelir ama burada YENİDEN
// doğrulanır (pazarlama izni, onaylı e-posta, bildirim tercihi, hiç oyun yok).
// Varsayılan `dry_run: true` — hiçbir şey göndermez. Gönderen: noreply@.
import { createClient } from 'jsr:@supabase/supabase-js@2';

const KEY = 'KEY_PLACEHOLDER';
const BREVO_API_KEY = Deno.env.get('BREVO_API_KEY');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const MAX_RECIPIENTS = 50;
const SUBJECT = 'Kelimeki’de ilk oyununuzu açmaya ne dersiniz?';
const BUTTON_URL = 'https://kelimeki.com/?rastgele=1';
const SENDER = { name: 'Kelimeki', email: 'noreply@kelimeki.com' };
const SUPPORT_EMAIL = 'destek@kelimeki.com';

const HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-reminder-key',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json', ...HEADERS } });
}

function escapeHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// İlk harf Türkçe kurallarıyla büyür (i→İ, ı→I); gerisine DOKUNULMAZ ("McX" bozulmasın).
function capFirst(s: string | undefined): string | undefined {
  if (!s) return s;
  const [first, ...rest] = Array.from(s);
  return first.toLocaleUpperCase('tr-TR') + rest.join('');
}

function mask(email: string): string {
  const [local, domain] = email.split('@');
  return `${local.slice(0, 1)}***@${domain ?? '?'}`;
}

function buildHtml(name: string | undefined): string {
  const greeting = name ? `Merhaba ${escapeHtml(name)},` : 'Merhaba,';
  const p = 'margin:0 0 16px 0;font-size:15px;line-height:1.6;color:#1B2430;';
  const inner = `
    <p style="${p}">${greeting}</p>
    <p style="${p}">Kelimeki’ye üye oldunuz ama henüz bir oyunu bitirmediniz.</p>
    <p style="margin:0 0 24px 0;font-size:15px;line-height:1.6;color:#1B2430;"><strong>Yeni özellik:</strong> Rastgele Oyun ile arkadaşınız olmayan kişilerle de oynayabilirsiniz. Bir oyun açın, katılmak isteyen ilk kişiyle canlı oynayın.</p>
    <p style="margin:0 0 24px 0;">
      <a href="${BUTTON_URL}" style="display:inline-block;background-color:#2563EB;color:#FFFFFF;font-size:15px;font-weight:600;text-decoration:none;padding:12px 24px;border-radius:8px;">Rastgele Oyun Aç</a>
    </p>
    <p style="font-size:12px;line-height:1.5;color:#8A93A2;margin:0 0 16px 0;">Bu e-postayı Kelimeki’ye üye olduğunuz ve bilgilendirme e-postalarını kabul ettiğiniz için aldınız. Bu tek seferlik bir hatırlatmadır. Tercihlerinizi hesap ayarlarınızdan değiştirebilirsiniz.</p>
    <p style="font-size:13px;color:#8A93A2;margin-top:20px;">Saygılarımızla,<br/><span style="display: inline-block; margin-top: 4px;">Kelimeki Destek</span></p>
  `;
  const notice = `
    <p style="margin: 24px 0 0 0; padding-top: 12px; border-top: 1px solid #DCE2EA; font-size: 12px; color: #8A93A2; font-style: italic;">
      Bu otomatik bir bildirimdir; bu adrese gönderilen yanıtlar okunmaz. Bize ulaşmak için <a href="mailto:${SUPPORT_EMAIL}" style="color: #2563EB; text-decoration: underline;">${SUPPORT_EMAIL}</a> adresine yazabilirsin.
    </p>`;
  return `
<body style="margin:0;padding:0;background-color:#F5F7FA;font-family:-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#F5F7FA;padding:32px 16px;">
    <tr><td align="center">
      <table role="presentation" width="480" cellpadding="0" cellspacing="0" style="max-width:480px;width:100%;background-color:#FFFFFF;border:1px solid #DCE2EA;border-radius:16px;overflow:hidden;">
        <tr><td align="center" style="padding:32px 32px 8px 32px;">
          <img src="https://kelimeki.com/email-logo.png" width="140" height="56" alt="Kelimeki" style="display:block;border:0;outline:none;text-decoration:none;color:#2563EB;font-size:22px;font-weight:700;font-family:-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
        </td></tr>
        <tr><td style="padding:16px 32px 32px 32px;">
          <h1 style="margin:0 0 16px 0;font-size:20px;line-height:1.4;color:#1B2430;">Kelimeki’de Rastgele Oyun</h1>
          ${inner}
          ${notice}
        </td></tr>
      </table>
      <table role="presentation" width="480" cellpadding="0" cellspacing="0" style="max-width:480px;width:100%;">
        <tr><td align="center" style="padding:20px 32px;"><span style="font-size:12px;color:#8A93A2;">© Kelimeki · kelimeki.com</span></td></tr>
      </table>
    </td></tr>
  </table>
</body>`;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: HEADERS });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  if (req.headers.get('x-reminder-key') !== KEY) return json({ error: 'Yetkisiz.' }, 401);

  let body: { user_ids?: string[]; dry_run?: boolean };
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Geçersiz istek.' }, 400);
  }
  const ids = Array.from(new Set((body.user_ids ?? []).map((s) => String(s).trim()).filter(Boolean)));
  if (ids.length === 0 || ids.length > MAX_RECIPIENTS) {
    return json({ error: `user_ids 1-${MAX_RECIPIENTS} arası olmalı.` }, 400);
  }
  const dryRun = body.dry_run !== false; // yalnızca AÇIKÇA false ise gönderir
  if (!dryRun && !BREVO_API_KEY) return json({ error: 'BREVO_API_KEY yok.' }, 500);

  const db = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const eligible: { id: string; email: string; name?: string }[] = [];
  const skipped: { id: string; reason: string }[] = [];

  for (const id of ids) {
    const [{ data: au }, { data: profile }, { count }] = await Promise.all([
      db.auth.admin.getUserById(id),
      db.from('profiles').select('display_name, first_name, marketing_consent, email_notifications_enabled').eq('id', id).maybeSingle(),
      db.from('games').select('id', { count: 'exact', head: true }).eq('user_id', id),
    ]);
    const email = au?.user?.email;
    if (!email) skipped.push({ id, reason: 'no_email' });
    else if (!au?.user?.email_confirmed_at) skipped.push({ id, reason: 'not_confirmed' });
    else if (profile?.marketing_consent !== true) skipped.push({ id, reason: 'no_marketing_consent' });
    else if (profile?.email_notifications_enabled === false) skipped.push({ id, reason: 'opted_out' });
    else if ((count ?? 0) > 0) skipped.push({ id, reason: 'already_finished_a_game' });
    else eligible.push({ id, email, name: capFirst(profile?.first_name?.trim() || profile?.display_name || undefined) });
  }

  if (dryRun) {
    return json({ dry_run: true, eligible_count: eligible.length, eligible: eligible.map((e) => ({ id: e.id, email: mask(e.email), name: e.name ?? null })), skipped });
  }

  const results: { id: string; sent: boolean; status?: number }[] = [];
  for (const r of eligible) {
    const res = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: { 'api-key': BREVO_API_KEY!, 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify({ sender: SENDER, to: [{ email: r.email, name: r.name }], subject: SUBJECT, htmlContent: buildHtml(r.name) }),
    });
    if (!res.ok) console.error('[send-random-reminder] Brevo hatası:', res.status, await res.text());
    results.push({ id: r.id, sent: res.ok, status: res.status });
    await new Promise((ok) => setTimeout(ok, 150));
  }
  return json({ dry_run: false, attempted: results.length, sent: results.filter((x) => x.sent).length, skipped, results });
});
