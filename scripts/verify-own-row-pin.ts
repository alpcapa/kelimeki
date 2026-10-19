// Sabit "senin sıran" satırı kararı (`utils/ownRowPin.ts`). 16 Ekim 2026:
// 10. sıradaki oyuncunun satırı yüklü ama iPad'de görünür alanın dışındaydı,
// sabit satır gizli kalıyordu.
import { shouldPinOwnRow } from '../src/utils/ownRowPin';

let failed = 0;
function eq(name: string, got: boolean, want: boolean) {
  if (got !== want) {
    failed++;
    console.error(`✗ ${name}: beklenen ${want}, gelen ${got}`);
  } else console.log(`✓ ${name}`);
}

eq('sırası yok → satır yok', shouldPinOwnRow({ hasRank: false, inList: false, inView: false }), false);
eq('sırası yok, listede (olmaz ama) → yok', shouldPinOwnRow({ hasRank: false, inList: true, inView: false }), false);
eq('yüklü değil → hep göster', shouldPinOwnRow({ hasRank: true, inList: false, inView: null }), true);
eq('yüklü değil, ölçüm var → göster', shouldPinOwnRow({ hasRank: true, inList: false, inView: true }), true);
eq('yüklü + GÖRÜNÜR → gizle', shouldPinOwnRow({ hasRank: true, inList: true, inView: true }), false);
eq('yüklü + GÖRÜNMEZ (10. sıra vakası) → göster', shouldPinOwnRow({ hasRank: true, inList: true, inView: false }), true);
eq('yüklü + henüz ölçülmedi → gizli (yanıp sönme yok)', shouldPinOwnRow({ hasRank: true, inList: true, inView: null }), false);

if (failed > 0) {
  console.error(`\n${failed} kontrol düştü.`);
  process.exit(1);
}
console.log('\nHepsi geçti.');
