/**
 * Kapı: service worker güncellemesinin YENİDEN YÜKLEME DÖNGÜSÜ koruması
 * (`utils/swUpdate.ts` + `lib/pwa.ts`).
 *
 * 19 Eylül 2026: ana ekrandan açılan iOS PWA'sı sonsuz bir yeniden yükleme
 * döngüsüne giriyordu (saniyede ~2 tam açılış, ~20 istek/sn). Üç tur boyunca
 * auth katmanında arandı ve orada değildi.
 *
 * ⚠ Duman testiyle sınanamaz: tetiklemek için ETKİNLEŞEMEYEN bir bekleyen
 * service worker gerekiyor — Playwright'ta üretilemez. Bu yüzden kural saf
 * fonksiyon düzeyinde + kaynak taramasıyla kilitleniyor.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { shouldApplySwUpdate } from '../src/utils/swUpdate';

let dusen = 0;
const kontrol = (ad: string, kosul: boolean): void => {
  console.log(`  ${kosul ? '✓' : '✗'} ${ad}`);
  if (!kosul) dusen++;
};

console.log('\nService worker — yeniden yükleme döngüsü kapısı\n');

kontrol('kayıt YOK → uygulanır (ilk deneme engellenmemeli)', shouldApplySwUpdate(null, 'a1b2c3d'));
kontrol(
  'önceki yükleme derlemeyi DEĞİŞTİRDİ → uygulanır (yeni sürüm çıkmış)',
  shouldApplySwUpdate({ build: 'eski111', at: 1 }, 'yeni222'),
);
kontrol(
  'önceki yükleme derlemeyi DEĞİŞTİRMEDİ → UYGULANMAZ (döngü burada kırılır)',
  !shouldApplySwUpdate({ build: 'a1b2c3d', at: 1 }, 'a1b2c3d'),
);
kontrol(
  'karar ZAMANA bakmaz — eski bir kayıt da döngüyü keser',
  !shouldApplySwUpdate({ build: 'a1b2c3d', at: 0 }, 'a1b2c3d'),
);

// ── Kaynak taraması: `pwa.ts` kapıyı gerçekten çağırıyor mu ───────────────
// Saf fonksiyon doğru olsa bile çağrılmazsa hiçbir şey korumaz; bu proje bu
// hatayı daha önce yaşadı (kural yazıldı, çağrı yeri unutuldu).
console.log('\nÇağrı yeri\n');

const pwa = readFileSync(join(process.cwd(), 'src/lib/pwa.ts'), 'utf8');
kontrol('pwa.ts `shouldApplySwUpdate` çağırıyor', pwa.includes('shouldApplySwUpdate('));
kontrol('pwa.ts yeniden yüklemeden ÖNCE kaydı yazıyor', pwa.includes('writeSwUpdateKaydi('));
// `apply()` — gerçek reload — kayıt yazıldıktan SONRA gelmeli, aksi halde
// döngü sırasında kayıt hiç oluşmaz ve kapı işlevsizdir.
kontrol(
  '`apply()` çağrısı `writeSwUpdateKaydi` SONRASINDA',
  pwa.indexOf('writeSwUpdateKaydi(') < pwa.lastIndexOf('apply();'),
);

// ── Kaydın DEPOSU: `localStorage`, `sessionStorage` DEĞİL ─────────────────
// 19 Eylül 2026, ikinci ölçüm: `sessionStorage` sürümü sonsuz döngüyü kırdı
// ama her AÇILIŞ hâlâ bir boş yeniden yükleme harcıyordu (canlıda üç ayrı
// açılıştan üç `sw-update-loop` satırı). Kullanıcı bunu "her seferinde 2 kere
// refresh yapıyor" diye gördü. Deneme derleme başına BİR olmalı.
console.log('\nKaydın deposu\n');

const swUtil = readFileSync(join(process.cwd(), 'src/utils/swUpdate.ts'), 'utf8');
const kod = swUtil.split('\n').filter((r) => !r.trimStart().startsWith('*')).join('\n');
kontrol('kayıt `localStorage`da tutuluyor', kod.includes('localStorage.getItem(SW_UPDATE_KEY)'));
kontrol(
  '`sessionStorage` KULLANILMIYOR (açılış başına bir deneme = her açılışta bir boş reload)',
  !kod.includes('sessionStorage'),
);

console.log(dusen === 0 ? '\nTüm kontroller geçti.\n' : `\n${dusen} kontrol DÜŞTÜ\n`);
process.exit(dusen === 0 ? 0 : 1);
