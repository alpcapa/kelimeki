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
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import {
  AUTH_NULL_BURST_LIMIT,
  AUTH_NULL_BURST_MS,
  isAuthNullBurst,
  sameAuthUser,
  shouldApplyAuthSession,
} from '../src/utils/authUser';

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


// ── Oturum titremesi: bir `null` olay oturumu GERÇEKTEN düşürür mü ────────
// 19 Eylül 2026: oturum `kullanıcı → null → kullanıcı` diye titriyordu; her
// titreme hem effect turunu hem de UÇAN profil isteğinin çöpe atılmasını
// tetikliyordu (ekranda avatar/isim hiç gelmiyordu).
//
// ÜÇÜNCÜ tur: ilk kapı olayın ADINA bakıyordu ve canlıda YETMEDİ (derleme
// 7353b50 yayındayken aynı hesapta iki dakikada ~52 tur). Karar artık
// DEPODAKİ oturuma bakıyor — ölçülebilir olana.
console.log('\nOturum titremesi kapısı\n');

kontrol('oturum VARSA uygulanır (depoya hiç sorulmaz)', shouldApplyAuthSession(true));
kontrol(
  'oturum VARSA, depo boş görünse bile uygulanır',
  shouldApplyAuthSession(true, null),
);

kontrol(
  'null + depo HENÜZ okunmadı → UYGULANMAZ (karar ertelenir)',
  !shouldApplyAuthSession(false),
);
kontrol(
  'null + depo da BOŞ → UYGULANIR (gerçek çıkış)',
  shouldApplyAuthSession(false, null),
);
kontrol(
  'null + depoda oturum DURUYOR → YOK SAYILIR (titreme)',
  !shouldApplyAuthSession(false, 'u1'),
);

// ── Devre kesici: `null` FIRTINASI ────────────────────────────────────────
// DÖRDÜNCÜ tur. Üç düzeltme de kök sebebi bulamadı; ölçüm oturumun SANİYEDE
// İKİ KEZ null'a düştüğünü gösterdi. Gerçek bir çıkış saniyede iki kez olmaz,
// yani kısa pencerede tekrarlayan null tanım gereği gürültüdür.
console.log('\n`null` fırtınası devre kesicisi\n');

const t0 = 1_000_000;
kontrol('hiç olay yok → fırtına DEĞİL', !isAuthNullBurst([], t0));
kontrol(
  'tek bir çıkış → fırtına DEĞİL (gerçek çıkış BOZULMAMALI)',
  !isAuthNullBurst([t0], t0),
);
kontrol(
  `sınırın bir altı (${AUTH_NULL_BURST_LIMIT - 1}) → fırtına DEĞİL`,
  !isAuthNullBurst(Array.from({ length: AUTH_NULL_BURST_LIMIT - 1 }, () => t0), t0),
);
kontrol(
  `sınır kadar (${AUTH_NULL_BURST_LIMIT}) aynı anda → FIRTINA`,
  isAuthNullBurst(Array.from({ length: AUTH_NULL_BURST_LIMIT }, () => t0), t0),
);
kontrol(
  'pencere DIŞINDA kalan eski olaylar SAYILMAZ (gün boyu birikmez)',
  !isAuthNullBurst(
    Array.from({ length: AUTH_NULL_BURST_LIMIT * 3 }, () => t0),
    t0 + AUTH_NULL_BURST_MS + 1,
  ),
);
kontrol(
  'ölçülen gerçek hız (saniyede 2) pencerede FIRTINA üretir',
  isAuthNullBurst([t0, t0 + 500, t0 + 1000, t0 + 1500], t0 + 1500),
);

// ── Kaynak taraması: hiçbir effect `user` NESNESİNE bağlanmamalı ───────────
// Port'un değişmezi (PORT_BRIEF §7 / `auth/account_scope.dart`): oturuma bağlı
// karar auth NESNESİNE değil `user.id`'ye bakar. Web'de bu kural 20 effect'te
// ihlal ediliyordu ve döngünün YÜKSELTECİ buydu — bir tek auth olayı tam bir
// veri turuna dönüşüyordu. Derleyici görmez, bu yüzden kapı bir kaynak
// taraması.
console.log('\nEffect bağımlılıkları — `user` nesnesi YASAK\n');

// ⚠ `import.meta.url` KULLANMA: bu betik esbuild ile `node_modules/.cache/`
// altına paketlenip oradan koşuyor, yani modülün yolu kaynağın yolu DEĞİL
// (denendi, `ENOENT .../node_modules/.cache/src/`). Kök `process.cwd()`.
const KOK = join(process.cwd(), 'src');
const dosyalar: string[] = [];
const tara = (dizin: string): void => {
  for (const giris of readdirSync(dizin, { withFileTypes: true })) {
    const yol = join(dizin, giris.name);
    if (giris.isDirectory()) tara(yol);
    else if (giris.name.endsWith('.tsx') || giris.name.endsWith('.ts')) dosyalar.push(yol);
  }
};
tara(KOK);

const ihlaller: string[] = [];
for (const dosya of dosyalar) {
  if (dosya.endsWith('hooks/useAuth.tsx')) continue; // `user` state'inin KENDİ tanımı
  const satirlar = readFileSync(dosya, 'utf8').split('\n');
  satirlar.forEach((satir, i) => {
    const m = satir.match(/^\s*\}, \[(.*)\]\);\s*$/);
    if (!m) return;
    const bagimliliklar = m[1].split(',').map((s) => s.trim());
    if (bagimliliklar.includes('user')) {
      ihlaller.push(`${dosya.replace(process.cwd() + '/', '')}:${i + 1} → ${satir.trim()}`);
    }
  });
}
kontrol(
  `hiçbir effect bağımlılığı bare \`user\` DEĞİL (${dosyalar.length} dosya tarandı)`,
  ihlaller.length === 0,
);
for (const ihlal of ihlaller) console.log(`      ${ihlal}  →  \`user?.id\` kullan`);

console.log(dusen === 0 ? '\nTüm kontroller geçti.\n' : `\n${dusen} kontrol DÜŞTÜ\n`);
process.exit(dusen === 0 ? 0 : 1);
