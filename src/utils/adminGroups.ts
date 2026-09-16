// Kelimeki — admin panelinin AÇILIR tablolarının gruplama kuralları
// (16 Eylül 2026, kullanıcı isteği: *"Kaynak hunisini expandible ana
// kategorilere getirip detayları altlarına topla"*, aynı istek "Sürüm
// Dağılımı" ve bildirim izni tablosu için de geçerli).
//
// Desen YENİ DEĞİL: "Cihaz" ve "Cihaz Markası" tabloları 11-12 Eylül
// 2026'dan beri aynı şeyi yapıyor (`src/utils/deviceLabels.ts` →
// `brandBreakdown`/`osBreakdown`). Bu dosya o iki fonksiyonun kardeşi ve
// AYNI kuralları paylaşıyor:
//
//   · Üst satır grubun TOPLAMI, alt satırlar detay.
//   · Sıralama büyükten küçüğe, eşitlikte `trCompare` (Türkçe harf kuralı).
//   · Tanınmayan bir değere UYDURMA kategori atanmaz — "Diğer"e düşer.
//
// ⚠ Yüzdeler bu dosyanın işi DEĞİL: onu tablolar hesaplıyor ve kural
// `DeviceBrandTable`inkiyle aynı — açılan satırlar da GENEL toplamın payını
// gösterir, grubun değil. Yoksa açık satırların yüzdesi kapalı satırlarınkiyle
// kıyaslanamaz olurdu.
import { trCompare } from './turkish';

/* ────────────────────────── Kaynak (Kaynak Hunisi) ───────────────────── */

/**
 * Bir `?ref=` etiketinin ait olduğu KANAL.
 *
 * ⚠ Etiketlerin merkezî bir kaydı YOK — pazarlama malzemesine elle yazılıyor
 * (`?ref=ig-bio`, `?ref=fb-reel`, …), yani liste "kapsamlı" olamaz, ancak
 * GÖRÜLENE dayanır. Bu yüzden kural önek-bazlı: `ig` ve `instagram` ile
 * başlayan her şey Instagram, `fb`/`facebook` ile başlayan her şey Facebook,
 * `li`/`linkedin` ile başlayan her şey LinkedIn (16 Eylül 2026'da eklendi:
 * lansman turu dört etiket birden üretti — `li-sayfa`, `li-profil`,
 * `li-hakkinda`, `li-buton` — ve dördü de `Diğer`de dağınık duruyordu).
 * Yeni bir kanal açılırsa (TikTok gibi) buraya bir önek eklenir; eklenmezse
 * etiket sessizce kaybolmaz, "Diğer" grubunda GÖRÜNÜR kalır.
 *
 * ⚠ Önek eşleşmesi sınır karakteri arar: `ig-bio` ve `ig` Instagram'dır ama
 * `ignore` DEĞİLDİR. Bu olmadan `fb` öneki `fbi` gibi ilgisiz bir etiketi
 * yutardı.
 *
 * `direkt` ve `bilinmiyor` AYNI ŞEY DEĞİL ve birleştirilmemeli: `direkt` =
 * web'e `?ref=` olmadan geliş, `bilinmiyor` = istemcinin hiç damgalamaması
 * (bugün Flutter portu). Bu ayrım huninin kendi karar kaydında (16 Ağustos
 * 2026) bilinçli olarak kurulmuştu.
 */
export type SourceChannel =
  | 'instagram'
  | 'facebook'
  | 'linkedin'
  | 'arkadas'
  | 'direkt'
  | 'diger'
  | 'bilinmiyor';

export const SOURCE_CHANNEL_LABEL: Record<SourceChannel, string> = {
  instagram: 'Instagram',
  facebook: 'Facebook',
  linkedin: 'LinkedIn',
  arkadas: 'Arkadaş Daveti',
  direkt: 'Direkt',
  diger: 'Diğer',
  bilinmiyor: 'Bilinmiyor',
};

/** `ig-bio` → `ig` önekiyle eşleşir, `ignore` eşleşmez. */
function hasPrefix(value: string, prefix: string): boolean {
  if (!value.startsWith(prefix)) return false;
  if (value.length === prefix.length) return true;
  const next = value[prefix.length];
  return next === '-' || next === '_' || next === '.';
}

export function sourceChannel(source: string | null): SourceChannel {
  // ⚠ `trLower` DEĞİL: etiketler ASCII ve sunucudan zaten küçük harfli
  // geliyor; Türkçe'ye özgü bir dönüşüm burada gereksiz bir tuzak olurdu
  // (`I` → `ı` ile `instagram` eşleşmesini bozmak gibi). Yine de gelen
  // değer güvenilmez sayılıp normalize ediliyor.
  const s = (source ?? '').trim().toLowerCase();
  if (s === '' || s === 'bilinmiyor' || s === '--sanitized--') return 'bilinmiyor';
  if (s === 'direkt') return 'direkt';
  if (s === 'arkadas') return 'arkadas';
  if (hasPrefix(s, 'ig') || hasPrefix(s, 'instagram')) return 'instagram';
  if (hasPrefix(s, 'fb') || hasPrefix(s, 'facebook')) return 'facebook';
  // ⚠ `li` iki harf — sınır kuralı burada daha da kritik: `link`, `lig`,
  // `liste` gibi bir etiket LinkedIn sayılmamalı. `hasPrefix` bunu zaten
  // yapıyor, kapı da ayrıca ölçüyor.
  if (hasPrefix(s, 'li') || hasPrefix(s, 'linkedin')) return 'linkedin';
  return 'diger';
}

/** Gruplanmış huni satırı — alan adları `AdminSourceFunnelRow` ile birebir. */
export interface SourceFunnelTotals {
  visitors: number;
  starts: number;
  starters: number;
  signups: number;
  finishes: number;
  finishers: number;
  member_games: number;
  players: number;
}

export interface SourceChannelGroup extends SourceFunnelTotals {
  channel: SourceChannel;
  label: string;
  /** Ham etiketler — satır açılınca gösterilir. */
  sources: (SourceFunnelTotals & { source: string })[];
}

const EMPTY_TOTALS: SourceFunnelTotals = {
  visitors: 0,
  starts: 0,
  starters: 0,
  signups: 0,
  finishes: 0,
  finishers: 0,
  member_games: 0,
  players: 0,
};

const TOTAL_KEYS = Object.keys(EMPTY_TOTALS) as (keyof SourceFunnelTotals)[];

/**
 * Huni satırlarını kanal gruplarına toplar.
 *
 * ⚠ **Grubun sayısı alt satırların TOPLAMI** — cihaz tablolarındaki gibi
 * "benzersiz sayım" tuzağı burada YOK: `starters`/`finishers` benzersiz cihaz
 * sayar ama bir cihazın `utm_source`u ilk temasta DONDURULUYOR
 * (`captureUtmSource`), yani aynı cihaz iki kaynak satırında birden
 * görünemez. Bu bir varsayım değil, huninin veri modelinin kendisi;
 * değişirse (çok-temas attribution) bu toplama da bozulur.
 */
export function groupSourceFunnel(
  rows: ReadonlyArray<SourceFunnelTotals & { source: string }>,
): SourceChannelGroup[] {
  const gruplar = new Map<SourceChannel, SourceChannelGroup>();
  for (const r of rows) {
    const ch = sourceChannel(r.source);
    const g =
      gruplar.get(ch) ??
      ({ ...EMPTY_TOTALS, channel: ch, label: SOURCE_CHANNEL_LABEL[ch], sources: [] } as SourceChannelGroup);
    for (const k of TOTAL_KEYS) g[k] += r[k];
    g.sources.push(r);
    gruplar.set(ch, g);
  }
  for (const g of gruplar.values()) {
    g.sources.sort((a, b) => b.visitors - a.visitors || trCompare(a.source, b.source));
  }
  return [...gruplar.values()].sort(
    (a, b) => b.visitors - a.visitors || trCompare(a.label, b.label),
  );
}

/* ─────────────────── Platform + sürüm (iki sürüm tablosu) ─────────────── */

export interface PlatformVersionGroup {
  platform: string;
  label: string;
  value: number;
  versions: { app_version: string; value: number }[];
}

/**
 * `web` → "Web", `app-web` → "Uygulama (web)". Öteki değerler
 * `deviceLabels.platformLabel` ile AYNI kelimeleri kullanır — iki tablo yan
 * yana duruyor, "iOS" bir yerde "Ios" yazarsa okuyan ayrımın anlamlı
 * olduğunu sanır.
 */
export function clientPlatformLabel(platform: string): string {
  switch (platform) {
    case 'ios':
      return 'iOS';
    case 'android':
      return 'Android';
    case 'web':
      return 'Web';
    case 'app-web':
      return 'Uygulama (web)';
    default:
      return 'Bilinmiyor';
  }
}

/** Sürüm dizesini yeniden eskiye sıralar: `1.1.0` > `1.0.9` (metin sırası DEĞİL). */
export function compareVersionDesc(a: string, b: string): number {
  const bilinmiyorA = a === 'bilinmiyor';
  const bilinmiyorB = b === 'bilinmiyor';
  // "Sürümsüz" her zaman en sonda: web'in sürümü YOK, eksik veri değil.
  if (bilinmiyorA !== bilinmiyorB) return bilinmiyorA ? 1 : -1;
  if (bilinmiyorA) return 0;
  const pa = a.split('.').map((n) => Number.parseInt(n, 10) || 0);
  const pb = b.split('.').map((n) => Number.parseInt(n, 10) || 0);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const d = (pb[i] ?? 0) - (pa[i] ?? 0);
    if (d !== 0) return d;
  }
  return 0;
}

/**
 * (platform, sürüm) satırlarını platform gruplarına toplar — grubun sayısı
 * alt satırların TOPLAMIDIR.
 *
 * ⚠ Bu yüzden YALNIZCA toplanabilir bir ölçüyle çağrılabilir ("Sürüm
 * Dağılımı"nın oyun AÇILIŞI sayısı gibi). Bildirim izni tablosu benzersiz
 * KİŞİ sayıyor ve orada toplama YANLIŞ olurdu (iki telefonu olan biri iki kez
 * sayılır) — o tablonun platform/genel toplamlarını sunucu `grouping sets`
 * ile ayrı ayrı `distinct` hesaplıyor, bkz. `admin_push_version_breakdown`.
 */
export function groupPlatformVersions(
  rows: ReadonlyArray<{ platform: string; app_version: string; value: number }>,
): PlatformVersionGroup[] {
  const gruplar = new Map<string, PlatformVersionGroup>();
  for (const r of rows) {
    const g =
      gruplar.get(r.platform) ??
      ({
        platform: r.platform,
        label: clientPlatformLabel(r.platform),
        value: 0,
        versions: [],
      } as PlatformVersionGroup);
    g.value += r.value;
    g.versions.push({ app_version: r.app_version, value: r.value });
    gruplar.set(r.platform, g);
  }
  for (const g of gruplar.values()) {
    g.versions.sort((a, b) => compareVersionDesc(a.app_version, b.app_version));
  }
  return [...gruplar.values()].sort(
    (a, b) => b.value - a.value || trCompare(a.label, b.label),
  );
}
