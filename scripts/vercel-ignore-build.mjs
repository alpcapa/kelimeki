#!/usr/bin/env node
// Vercel "Ignored Build Step" (vercel.json → ignoreCommand).
//
// Çıkış 0 = derlemeyi ATLA, 1 = derle. Vercel Hobby günde 100 deployment
// veriyor; 2 Ekim 2026'da kota doldu ve bir web düzeltmesi (#785) bir gün
// yayına çıkamadı. O günün 100 deployment'ının 65'i önizleme, 35'i production
// idi ve büyük kısmı yalnızca doküman/mobil/pazarlama değiştiren push'lardı —
// siteyi hiç değiştirmeyen derlemeler (bkz. docs/decisions/supabase-ops.md →
// "Vercel günlük dağıtım kotası").
//
// Kural: değişen dosyaların HEPSİ aşağıdaki "siteye girmeyen" kümedeyse atla;
// tek bir dosya bile dışındaysa derle. Liste bilerek İZİN listesi değil ATLA
// listesi: yeni bir web dosyası/klasörü eklendiğinde kendiliğinden derlenir,
// unutulma hatası yalnızca fazladan bir derleme üretir, eksik yayın üretmez.
//
// ⚠ Şüphede DERLE: karşılaştırma tabanı yoksa, git hata verirse ya da diff
// boşsa (aynı commit'in yeniden deploy'u — elle "Redeploy" bunu ister) 1 döner.
// Bağımlılık YOK: `npm install`dan ÖNCE koşar.
import { execFileSync } from 'node:child_process';

const SKIP = [
  /\.md$/i,
  /^docs\//,
  /^mobile\//,
  /^marketing\//,
  /^supabase\//,
  /^tests\//,
  /^\.github\//,
  /^\.claude\//,
];

function git(args) {
  return execFileSync('git', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
}

function changedFiles() {
  // Son BAŞARILI deployment'ın sha'sı (yalnızca ignoreCommand tanımlıyken
  // verilir). Atlanan derlemeler onu ilerletmez, yani fark birikir — doğru.
  const prev = process.env.VERCEL_GIT_PREVIOUS_SHA;
  const bases = [prev, 'HEAD^'].filter(Boolean);
  for (const base of bases) {
    try {
      git(['cat-file', '-e', `${base}^{commit}`]);
      return git(['diff', '--name-only', base, 'HEAD']).split('\n').filter(Boolean);
    } catch {
      // sığ klonda taban yok → sıradaki taban
    }
  }
  return null;
}

const files = changedFiles();
if (!files || files.length === 0) {
  console.log('[ignore-build] karşılaştırma yapılamadı ya da fark yok → DERLE');
  process.exit(1);
}
const web = files.filter((f) => !SKIP.some((re) => re.test(f)));
if (web.length > 0) {
  console.log(`[ignore-build] siteyi etkileyen ${web.length} dosya → DERLE: ${web.slice(0, 5).join(', ')}`);
  process.exit(1);
}
console.log(`[ignore-build] ${files.length} dosyanın hiçbiri siteye girmiyor → ATLA`);
process.exit(0);
