/**
 * Kapı: davet kuyruğunun ÇİFT ÇAĞRI koruması (ROADMAP #31, istemci yarısı).
 *
 * Aynı davet token'ı İKİ yoldan işlenebiliyor ve bu BİLEREK böyle:
 *   1. `/davet/:token` sayfasının kendi otomatik kabulü (oturum açıksa)
 *   2. `App.tsx`'in `localStorage` kuyruğu (e-posta doğrulaması açıkken kayıt
 *      bu sayfada oturum AÇMAZ; doğrulama linki köke döner, kuyruk orada
 *      yakalar)
 *
 * ⚠ ÇİFT YOLU KALDIRMA — varlık sebebi gerçek. Çift ÇAĞRIYI kesen tek şey
 * SIRA: token, RPC'den ÖNCE kuyruktan alınmalı. Önceden temizlik `.then()`
 * içindeydi ve token uçuş boyunca kuyrukta duruyordu; canlıda ölçüldü
 * (`created_at` 15:17:51 ↔ `responded_at` 15:17:56 — tek davetli, iki çağrı).
 *
 * ⚠ Duman testiyle sınanamaz: iki ayrı route, gerçek bir Supabase oturumu ve
 * e-posta doğrulaması gerekiyor. Bu yüzden kural kaynak taramasıyla kilitli.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

let dusen = 0;
const kontrol = (ad: string, kosul: boolean): void => {
  console.log(`  ${kosul ? '✓' : '✗'} ${ad}`);
  if (!kosul) dusen++;
};

console.log('\nDavet kuyruğu — çift çağrı kapısı\n');

const sayfa = readFileSync(join(process.cwd(), 'src/components/FriendInvitePage.tsx'), 'utf8');
const app = readFileSync(join(process.cwd(), 'src/App.tsx'), 'utf8');

// ── 1. Davet sayfası: temizlik ÇAĞRIDAN ÖNCE ──────────────────────────────
const temizlik = sayfa.indexOf('takePendingInviteToken()');
const cagri = sayfa.indexOf('acceptFriendInvite(token)');
kontrol('davet sayfası kuyruğu temizliyor', temizlik !== -1);
kontrol('davet sayfası daveti kabul ediyor', cagri !== -1);
kontrol(
  'temizlik `acceptFriendInvite` ÇAĞRISINDAN ÖNCE (çift çağrı penceresi kapalı)',
  temizlik !== -1 && cagri !== -1 && temizlik < cagri,
);

// ── 2. Kurtarma yolu korunmuş mu ──────────────────────────────────────────
// Erken temizlik çift çağrıyı kesmeli, kurtarmayı DEĞİL: geçici arızada
// token kuyruğa geri konmalı, yoksa sayfadan ayrılan kullanıcının daveti
// sessizce kaybolur.
kontrol(
  'geçici arızada token kuyruğa GERİ konuyor (`storePendingInviteToken` catch içinde)',
  /catch\([\s\S]*?storePendingInviteToken\(token\)/.test(sayfa),
);

// ── 3. App.tsx kuyruğu: zaten "önce al, sonra çağır" ──────────────────────
const appTemizlik = app.indexOf('takePendingInviteToken()');
const appCagri = app.indexOf('acceptFriendInvite(token)');
kontrol(
  'App.tsx kuyruğu da ÖNCE alıp SONRA çağırıyor',
  appTemizlik !== -1 && appCagri !== -1 && appTemizlik < appCagri,
);

// ── 4. Çift yol DURUYOR (kaldırılmadı) ────────────────────────────────────
kontrol('davet sayfası token`ı kuyruğa yazıyor (çift yol duruyor)', sayfa.includes('storePendingInviteToken(token)'));
kontrol('App.tsx fallback`ı duruyor', appCagri !== -1);

console.log(dusen === 0 ? '\nTüm kontroller geçti.\n' : `\n${dusen} kontrol DÜŞTÜ\n`);
process.exit(dusen === 0 ? 0 : 1);
