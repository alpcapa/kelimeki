// Kelimeki — günlük zaman serilerinde BOŞ günleri sıfırla doldurur (admin line grafikleri).
//
// Neden: `admin_hamle_avi_stats.daily` yalnızca olayı OLAN günleri döndürür; çizgi grafik
// aralıktaki günleri atlarsa 3 gün sessizlik ile 3 gün süren bir düşüş aynı eğimle çizilir.
// Günler İstanbul takvimiyle gelir (admin RPC'lerinin ortak kuralı), bu yüzden "bugün" de
// İstanbul gününe göre alınır — cihazın saat dilimi değil.

/** 'YYYY-MM-DD' gününe `n` gün ekler (UTC öğle vakti üzerinden: yaz saati kaymasından etkilenmez). */
export function addDays(day: string, n: number): string {
  const d = new Date(`${day}T12:00:00Z`);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

/** İstanbul takvimine göre bugün ('YYYY-MM-DD'). */
export function istanbulToday(now: Date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Istanbul' }).format(now);
}

/**
 * İlk günden `lastDay`e kadar HER günü döndürür; eksik günler `zero` değerleriyle dolar.
 * Çıktıdaki `bucket` alanı `GrowthChart`ın beklediği tarih anahtarıdır. Girdi sırasız olabilir.
 * `lastDay`, son olay gününden önceyse son olay günü esas alınır (veri kesilmez).
 */
export function fillDailyGaps<T extends { day: string }>(
  rows: readonly T[],
  zero: Omit<T, 'day'>,
  lastDay: string,
): (T & { bucket: string })[] {
  if (rows.length === 0) return [];
  const byDay = new Map(rows.map((r) => [r.day, r]));
  const days = [...byDay.keys()].sort();
  const first = days[0];
  const last = days[days.length - 1] > lastDay ? days[days.length - 1] : lastDay;
  const out: (T & { bucket: string })[] = [];
  for (let d = first; d <= last; d = addDays(d, 1)) {
    const row = byDay.get(d);
    out.push({ ...(row ?? ({ ...zero, day: d } as unknown as T)), bucket: d });
  }
  return out;
}
