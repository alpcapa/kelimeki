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
  | 'uygulama'
  | 'direkt'
  | 'diger'
  | 'bilinmiyor';

export const SOURCE_CHANNEL_LABEL: Record<SourceChannel, string> = {
  instagram: 'Instagram',
  facebook: 'Facebook',
  linkedin: 'LinkedIn',
  arkadas: 'Arkadaş Daveti',
  uygulama: 'Mobil Uygulama',
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
  // `app` = mobil uygulamadan açılan hesap (`profiles.signup_utm_source`,
  // `backfill_app_source_history`). TAM eşleşme, önek DEĞİL: `apple`,
  // `app-store` gibi bir web etiketi yutulmasın.
  if (s === 'app') return 'uygulama';
  if (hasPrefix(s, 'ig') || hasPrefix(s, 'instagram')) return 'instagram';
  if (hasPrefix(s, 'fb') || hasPrefix(s, 'facebook')) return 'facebook';
  // ⚠ `li` iki harf — sınır kuralı burada daha da kritik: `link`, `lig`,
  // `liste` gibi bir etiket LinkedIn sayılmamalı. `hasPrefix` bunu zaten
  // yapıyor, kapı da ayrıca ölçüyor.
  if (hasPrefix(s, 'li') || hasPrefix(s, 'linkedin')) return 'linkedin';
  return 'diger';
}

/** Üye Kalitesi sayıları — alan adları `AdminMemberQualityRow` ile birebir. */
export interface MemberQualityTotals {
  members: number;
  players: number;
  players_7d: number;
  returning_players: number;
  games: number;
}

export interface MemberQualityChannelGroup extends MemberQualityTotals {
  channel: SourceChannel;
  label: string;
  /** Ham etiketler — satır açılınca gösterilir. */
  sources: (MemberQualityTotals & { source: string })[];
}

const MEMBER_QUALITY_KEYS = [
  'members',
  'players',
  'players_7d',
  'returning_players',
  'games',
] as const satisfies readonly (keyof MemberQualityTotals)[];

/**
 * Üye Kalitesi satırlarını kanal gruplarına toplar.
 *
 * Toplamak GÜVENLİ: her üyenin TEK bir kayıt etiketi var (kayıt anında bir
 * kez yazılır, sonra değişmez), yani bir üye iki etiket satırında birden
 * görünemez ve benzersiz sayılar toplanabilir.
 */
export function groupMemberQuality(
  rows: ReadonlyArray<MemberQualityTotals & { source: string }>,
): MemberQualityChannelGroup[] {
  const gruplar = new Map<SourceChannel, MemberQualityChannelGroup>();
  for (const r of rows) {
    const ch = sourceChannel(r.source);
    let g = gruplar.get(ch);
    if (!g) {
      g = { members: 0, players: 0, players_7d: 0, returning_players: 0, games: 0, channel: ch, label: SOURCE_CHANNEL_LABEL[ch], sources: [] };
      gruplar.set(ch, g);
    }
    for (const k of MEMBER_QUALITY_KEYS) g[k] += r[k];
    g.sources.push(r);
  }
  for (const g of gruplar.values()) {
    g.sources.sort((a, b) => b.members - a.members || trCompare(a.source, b.source));
  }
  return [...gruplar.values()].sort((a, b) => b.members - a.members || trCompare(a.label, b.label));
}

/* ─────────────────── Huni v2 (kohort, platform × kanal) ──────────────── */

/** Huni v2 sayıları — alan adları `AdminFunnelRow` ile birebir. */
export interface FunnelV2Totals {
  land: number;
  returned: number;
  signed_up: number;
  started: number;
  finished: number;
  games_started: number;
  games_finished: number;
}

export interface FunnelV2ChannelGroup extends FunnelV2Totals {
  channel: SourceChannel;
  label: string;
  /** Ham etiketler (`?ref=` değeri) — satır açılınca gösterilir. */
  sources: (FunnelV2Totals & { source: string })[];
}

export interface FunnelV2PlatformGroup extends FunnelV2Totals {
  platform: string;
  label: string;
  channels: FunnelV2ChannelGroup[];
}

export interface FunnelV2Grouped {
  platforms: FunnelV2PlatformGroup[];
  /** Kohort toplamı — `mevcut` HARİÇ. */
  total: FunnelV2Totals;
  /** Ölçüm v2'den önce de izi olan cihazlar: kohortun DIŞINDA, yalnızca bilgi. */
  existing: number;
}

const FUNNEL_V2_KEYS = [
  'land',
  'returned',
  'signed_up',
  'started',
  'finished',
  'games_started',
  'games_finished',
] as const satisfies readonly (keyof FunnelV2Totals)[];

function emptyFunnelV2(): FunnelV2Totals {
  return { land: 0, returned: 0, signed_up: 0, started: 0, finished: 0, games_started: 0, games_finished: 0 };
}

function addFunnelV2(into: FunnelV2Totals, r: FunnelV2Totals): void {
  for (const k of FUNNEL_V2_KEYS) into[k] += r[k];
}

const FUNNEL_V2_PLATFORM_ORDER = ['web', 'android', 'ios'];

/**
 * Huni v2 satırlarını platform → kanal → ham etiket ağacına toplar.
 *
 * Toplamak GÜVENLİ: sayılar benzersiz cihaz ama her cihazın TEK bir `land`
 * satırı var (sunucuda unique), yani bir cihaz tek bir (platform, kanal)
 * satırında görünür. `mevcut` kanalı kohorttan çıkarılır ve ayrıca sayılır.
 */
export function groupFunnelV2(
  rows: ReadonlyArray<FunnelV2Totals & { platform: string; channel: string }>,
  existingChannel: string,
): FunnelV2Grouped {
  const total = emptyFunnelV2();
  let existing = 0;
  const platforms = new Map<string, FunnelV2PlatformGroup>();
  for (const r of rows) {
    if (r.channel === existingChannel) {
      existing += r.land;
      continue;
    }
    addFunnelV2(total, r);
    const p =
      platforms.get(r.platform) ??
      ({ ...emptyFunnelV2(), platform: r.platform, label: clientPlatformLabel(r.platform), channels: [] } as FunnelV2PlatformGroup);
    addFunnelV2(p, r);
    const ch = sourceChannel(r.channel);
    let g = p.channels.find((x) => x.channel === ch);
    if (!g) {
      g = { ...emptyFunnelV2(), channel: ch, label: SOURCE_CHANNEL_LABEL[ch], sources: [] };
      p.channels.push(g);
    }
    addFunnelV2(g, r);
    const src = { ...emptyFunnelV2(), source: r.channel };
    addFunnelV2(src, r);
    g.sources.push(src);
    platforms.set(r.platform, p);
  }
  for (const p of platforms.values()) {
    for (const g of p.channels) {
      g.sources.sort((a, b) => b.land - a.land || trCompare(a.source, b.source));
    }
    p.channels.sort((a, b) => b.land - a.land || trCompare(a.label, b.label));
  }
  const order = (x: string) => {
    const i = FUNNEL_V2_PLATFORM_ORDER.indexOf(x);
    return i < 0 ? FUNNEL_V2_PLATFORM_ORDER.length : i;
  };
  return {
    platforms: [...platforms.values()].sort((a, b) => order(a.platform) - order(b.platform)),
    total,
    existing,
  };
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
