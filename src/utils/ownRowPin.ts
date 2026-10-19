// Kelimeki — k-lig listelerinde sabit "senin sıran" satırının kararı.
//
// Saf fonksiyon (bileşen içinde karar verme — `onboarding.ts` ile aynı ilke).
// Eskiden yalnızca "satır yüklenen satırlar arasında mı" diye bakılıyordu;
// ilk sayfa 10 satır, iPad'de pencere 8 satır gösterdiği için 9.-10.
// sıradaki oyuncunun satırı YÜKLÜ ama görünmez, sabit satır da gizli
// kalıyordu (16 Ekim 2026, kullanıcı bildirdi). Kural artık "ekranda mı".
// Port ikizi: `mobile/app/lib/src/ui/score/own_row_pin.dart`.

/** Satırın en az bu kadarı görünürken "görünür" sayılır (yarım kesik satır
 *  görünür DEĞİL — oyuncu kendi sırasını okuyamıyor). */
export const ROW_IN_VIEW_RATIO = 0.9;

/** `null` = henüz ölçülmedi (gözlemci ilk raporunu vermedi). */
export type RowInView = boolean | null;

/** Sabit "senin sıran" satırı gösterilsin mi?
 *  - sıran yoksa (listeye girmemiş) satır da yok;
 *  - listede YÜKLÜ değilse hep göster;
 *  - yüklüyse yalnızca satır görünür alanın DIŞINDAYKEN göster.
 *  `inView === null` iken eski davranış (yüklüyse gizli): ilk boyamada
 *  satır yanıp sönmesin. */
export function shouldPinOwnRow(opts: {
  hasRank: boolean;
  inList: boolean;
  inView: RowInView;
}): boolean {
  if (!opts.hasRank) return false;
  if (!opts.inList) return true;
  return opts.inView === false;
}
