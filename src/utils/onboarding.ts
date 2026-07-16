// Harfik — ilk açılışta Hızlı Başlangıç popup'ının yalnızca bir kez gösterilmesi için.
const STORAGE_KEY = 'harfik:seen-quickstart';

/** localStorage kapalı/erişilemez olabilir — bu durumda tekrar tekrar açılmasın diye "görüldü" varsayılır. */
export function hasSeenQuickStart(): boolean {
  try {
    return localStorage.getItem(STORAGE_KEY) === '1';
  } catch {
    return true;
  }
}

export function markQuickStartSeen(): void {
  try {
    localStorage.setItem(STORAGE_KEY, '1');
  } catch {
    // yoksay
  }
}
