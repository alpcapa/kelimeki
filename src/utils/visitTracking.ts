// Kelimeki — misafir (girişsiz) ziyaretçi sayımı için istemci tarafı anonim kimlik.
//
// Hiçbir kişisel veri taşımaz: yalnızca cihazda üretilen rastgele bir uuid
// (localStorage'da saklanır) ve günde bir kez sunucuya "bugün buradaydım"
// pingi. Admin panelindeki Büyüme > Kullanıcı grafiğinde "Ziyaret" serisi
// bunların bucket başına DISTINCT sayısını gösterir — kayıt olmadan gelip
// oyun oynayan (ya da hiç oynamadan bakıp giden) benzersiz tarayıcı
// oturumlarının kabaca kaç farklı ziyaretçi olduğunu görmek için.
// localStorage cihaza/tarayıcıya özel olduğundan gerçek benzersiz insan
// sayısından çok "farklı tarayıcı" sayısına yakındır (biri gizli sekme
// kullanırsa ya da önbelleği temizlerse yeniden sayılır) — tam bir çözüm
// değil ama yönlü bir sinyal.
const ANON_ID_KEY = 'kelimeki:anon-id';
const LAST_VISIT_KEY = 'kelimeki:anon-visit-date';

/** Bu cihaz için kalıcı, rastgele bir kimlik döner — yoksa üretip saklar. */
export function getOrCreateAnonId(): string | null {
  try {
    const existing = localStorage.getItem(ANON_ID_KEY);
    if (existing) return existing;
    const id = crypto.randomUUID();
    localStorage.setItem(ANON_ID_KEY, id);
    return id;
  } catch {
    return null;
  }
}

/** Bugün (yerel tarih) için ziyaret zaten bildirildi mi? */
export function visitAlreadyLoggedToday(): boolean {
  try {
    const today = new Date().toISOString().slice(0, 10);
    return localStorage.getItem(LAST_VISIT_KEY) === today;
  } catch {
    return true; // localStorage okunamıyorsa tekrar denemeye gerek yok
  }
}

/** Bugünün (yerel tarih) ziyareti bildirildi olarak işaretler. */
export function markVisitLoggedToday(): void {
  try {
    const today = new Date().toISOString().slice(0, 10);
    localStorage.setItem(LAST_VISIT_KEY, today);
  } catch {
    // yoksay
  }
}
