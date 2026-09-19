/**
 * Kapı: oturum kullanıcısının KİMLİK SABİTLEYİCİSİ (`utils/authUser.ts`).
 *
 * 19 Eylül 2026'da canlıda ölçülen döngünün kapısı: bir auth olayı geldiğinde
 * `user` nesnesinin kimliği gereksiz yere değişirse, ona bağlı DOKUZ effect
 * birden yeniden koşuyor ve uygulama saniyede ~19 istek atıyordu.
 *
 * ⚠ Duman testiyle sınanamaz: tetiklemek için gerçek bir Supabase oturumu ve
 * arka arkaya gelen `onAuthStateChange` olayları gerekiyor — CI'da ikisi de
 * yok. Bu yüzden kural saf fonksiyon düzeyinde kilitleniyor.
 *
 * ⚠ İki yönü de korunmalı. Yalnızca "aynıysa true" sınanırsa fonksiyon
 * `() => true` yazılarak da geçer ve o zaman GERÇEK güncellemeler yutulur
 * (e-posta değişimi ekrana hiç yansımaz).
 */
import { sameAuthUser, shouldApplyAuthSession } from '../src/utils/authUser';

let dusen = 0;
const kontrol = (ad: string, kosul: boolean): void => {
  console.log(`  ${kosul ? '✓' : '✗'} ${ad}`);
  if (!kosul) dusen++;
};

const kullanici = (fazla: Record<string, unknown> = {}) =>
  ({ id: 'u1', email: 'a@b.c', email_confirmed_at: '2026-01-01', ...fazla }) as never;

console.log('\nOturum kullanıcısı kimlik sabitleyicisi\n');

// ── Kimlik KORUNMALI: içerik birebir aynı ───────────────────────────────────
kontrol('aynı içerik → aynı sayılır (effect fırtınası önlenir)', sameAuthUser(kullanici(), kullanici()));
kontrol('aynı referans → aynı sayılır', (() => { const u = kullanici(); return sameAuthUser(u, u); })());
kontrol('null ↔ null → aynı sayılır', sameAuthUser(null, null));

// ── Kimlik TAZELENMELİ: gerçek bir değişiklik var ───────────────────────────
kontrol('id değişti → FARKLI', !sameAuthUser(kullanici(), kullanici({ id: 'u2' })));
kontrol('e-posta değişti → FARKLI (ekran bayatlamasın)', !sameAuthUser(kullanici(), kullanici({ email: 'x@y.z' })));
kontrol(
  'e-posta doğrulandı → FARKLI',
  !sameAuthUser(kullanici({ email_confirmed_at: null }), kullanici()),
);
kontrol('yeni bir alan eklendi → FARKLI', !sameAuthUser(kullanici(), kullanici({ phone: '555' })));
kontrol('çıkış yapıldı (dolu → null) → FARKLI', !sameAuthUser(kullanici(), null));
kontrol('giriş yapıldı (null → dolu) → FARKLI', !sameAuthUser(null, kullanici()));


// ── Oturum titremesi: hangi olay oturumu GERÇEKTEN düşürür ─────────────────
// 19 Eylül 2026: oturum `kullanıcı → null → kullanıcı` diye titriyordu; her
// titreme hem effect turunu hem de UÇAN profil isteğinin çöpe atılmasını
// tetikliyordu (ekranda avatar/isim hiç gelmiyordu).
console.log('\nOturum titremesi kapısı\n');

kontrol('oturum VARSA her olay uygulanır (SIGNED_IN)', shouldApplyAuthSession('SIGNED_IN', true));
kontrol('oturum VARSA her olay uygulanır (TOKEN_REFRESHED)', shouldApplyAuthSession('TOKEN_REFRESHED', true));

kontrol('SIGNED_OUT + null → UYGULANIR (gerçek çıkış)', shouldApplyAuthSession('SIGNED_OUT', false));
kontrol(
  'INITIAL_SESSION + null → UYGULANIR (giriş yapılmamış)',
  shouldApplyAuthSession('INITIAL_SESSION', false),
);

kontrol(
  'TOKEN_REFRESHED + null → YOK SAYILIR (titreme)',
  !shouldApplyAuthSession('TOKEN_REFRESHED', false),
);
kontrol('SIGNED_IN + null → YOK SAYILIR (titreme)', !shouldApplyAuthSession('SIGNED_IN', false));
kontrol('USER_UPDATED + null → YOK SAYILIR (titreme)', !shouldApplyAuthSession('USER_UPDATED', false));
kontrol(
  'bilinmeyen bir olay + null → YOK SAYILIR (varsayılan güvenli taraf)',
  !shouldApplyAuthSession('YENI_BIR_OLAY', false),
);

console.log(dusen === 0 ? '\nTüm kontroller geçti.\n' : `\n${dusen} kontrol DÜŞTÜ\n`);
process.exit(dusen === 0 ? 0 : 1);
