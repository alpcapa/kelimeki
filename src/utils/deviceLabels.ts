// Kelimeki — `device_visits` satırlarını admin panelinde OKUNUR hâle getiren
// saf etiketleyiciler (marka · model · işletim sistemi).
//
// NEDEN GEREKLİ (11 Eylül 2026, kullanıcı isteği: *"Admin kurulu cihaz da
// görebiliyor muyuz? Iphone 17, 14, Samsung, vb."*): tabloda duran değer bir
// pazarlama adı DEĞİL, üreticinin iç model kodu — `SM-A176B`, `24116RACCG`,
// `CLT-L09`. Admin bunlara bakıp "Samsung mu Xiaomi mi" diyemez.
//
// ⚠ **Model KODUNU pazarlama adına çevirmiyoruz, yalnızca MARKAYI.** Kod →
// ad eşlemesi (ör. `SM-A176B` → "Galaxy A17 5G") elle bakımı gereken, her
// yeni cihazla bayatlayan bir tablo olurdu; marka ise önekten okunuyor ve
// önek kümesi yılda bir iki kez değişiyor. Model kodu ayrıca kendi
// tablosunda HAM hâliyle duruyor, yani hiçbir bilgi gizlenmiyor.
//
// ⚠ **Liste AÇIK UÇLU değil, GÖRÜLENE dayanıyor.** Tanınmayan her kod
// `Diğer`e düşer — uydurma bir marka atamaktansa sınıflandırmamak yeğdir.
// Canlıdan ölçüldü (11 Eylül 2026, son 90 gün, benzersiz ziyaretçi):
// Android modeli olan 546 cihazın 428'i Samsung (%78), 66'sı sayıyla
// başlayan Xiaomi kodu, 26'sı öteki bilinen önekler, ~26'sı `Diğer`
// (tamamı 1'er ziyaretçilik uzun kuyruk).
//
// Kapı: `npm run verify-device-labels` (canlıdan alınmış gerçek kodlarla).
import { trCompare } from './turkish';

/** Tabloda görünen marka etiketleri. `Diğer` = kod tanınmadı. */
export type DeviceBrand =
  | 'Apple'
  | 'Samsung'
  | 'Xiaomi'
  | 'Huawei'
  | 'Google'
  | 'Oppo'
  | 'realme'
  | 'vivo'
  | 'Motorola'
  | 'LG'
  | 'TECNO'
  | 'Infinix'
  | 'Nokia'
  | 'Diğer'
  | 'Bilinmiyor';

/**
 * Önek kuralları — SIRA ÖNEMLİ, ilk eşleşen kazanır.
 *
 * ⚠ Xiaomi'nin `^\d` kuralı bir SEZGİ: Xiaomi/Redmi/POCO model kodları
 * tarih benzeri sayılarla başlıyor (`24116RACCG`, `2312DRA50G`) ve
 * canlıdaki sayıyla başlayan 66 cihazın tamamı bu ailedendi. Başka bir
 * üretici aynı deseni kullanmaya başlarsa bu kural onu da Xiaomi sayar —
 * o yüzden en SONDA duruyor, adıyla eşleşen her şey önce sınıflanıyor.
 */
const KURALLAR: ReadonlyArray<readonly [RegExp, DeviceBrand]> = [
  [/^(SM-|GT-|SGH-|SCH-|SPH-)/i, 'Samsung'],
  [/^(Pixel|Nexus)/i, 'Google'],
  [/^(Redmi|POCO|Xiaomi|Mi\s)/i, 'Xiaomi'],
  [/^(HUAWEI|CLT-|JNY-|ANE-|STK-|SNE-|DBY2-|HEY3-|DNP-|CTR-|ELS-|VOG-|MAR-|POT-|LIO-|NOH-)/i, 'Huawei'],
  [/^(LG-|LM-)/i, 'LG'],
  [/^CPH/i, 'Oppo'],
  [/^RMX/i, 'realme'],
  [/^(vivo|V2\d{3})/i, 'vivo'],
  [/^(moto|XT\d)/i, 'Motorola'],
  [/^TECNO/i, 'TECNO'],
  [/^Infinix/i, 'Infinix'],
  [/^(Nokia|TA-\d)/i, 'Nokia'],
  // En sonda: adıyla eşleşmeyen sayı/`M####` kodları Xiaomi ailesi.
  [/^(\d|M[12]\d{3})/i, 'Xiaomi'],
];

/**
 * Bir `device_visits` satırının markası.
 *
 * `deviceType` ÖNCE bakılıyor çünkü iOS'ta model dizesi zaten markayı
 * söylüyor (`iPhone`/`iPad`) ve tarayıcı gerçek modeli hiç vermiyor —
 * yani Apple tarafında önek kuralına gerek yok, `device_type` yeter.
 * Masaüstünde model HER ZAMAN null (hiçbir tarayıcı vermiyor).
 */
export function deviceBrand(
  deviceType: string | null,
  deviceModel: string | null,
): DeviceBrand {
  if (deviceType === 'ios') return 'Apple';
  const m = deviceModel?.trim();
  if (!m) return 'Bilinmiyor';
  for (const [desen, marka] of KURALLAR) {
    if (desen.test(m)) return marka;
  }
  return 'Diğer';
}

/** Bir marka satırı ve altında açılacak model kırılımı. */
export interface BrandGroup {
  brand: DeviceBrand;
  visitors: number;
  /** O markanın model satırları, çoktan aza sıralı. */
  models: Array<{ deviceType: string | null; deviceModel: string | null; visitors: number }>;
}

/**
 * Satırları markaya göre gruplar; her grup KENDİ model kırılımını taşır.
 *
 * ⚠ **Neden tek bir ağaç, iki ayrı tablo değil (11 Eylül 2026, kullanıcı
 * isteği):** admin panelinde "Cihaz Markası" ve "Cihaz Modeli" ayrı ayrı
 * duruyordu; 174 farklı model kodu sayfayı gereksiz uzatıyordu. Kullanıcı:
 * *"Böyle çok uzun ve gereksiz detay oluyor. İstenirse bakılsın."* Artık
 * tek tablo: marka satırı, isteyen açıp modelleri görüyor.
 *
 * ⚠ **Toplama neden doğru:** satırlar (cihaz tipi × model) başına BENZERSİZ
 * ziyaretçi sayıyor, yani aynı cihaz iki satırda görünürse toplam şişer.
 * Canlıdan ölçüldü (11 Eylül 2026, 90 gün): model başına benzersizlerin
 * toplamı **788**, gerçek benzersiz ziyaretçi **788**, birden fazla model
 * dizesi taşıyan cihaz **0**. Yani bugün birebir doğru. Bir gün ayrışırsa
 * belirtisi görünür olur: bu tablonun toplamı "Cihaz" tablosununkini AŞAR.
 */
export function brandBreakdown(
  rows: ReadonlyArray<{ device_type: string | null; device_model: string | null; visitors: number }>,
): BrandGroup[] {
  const gruplar = new Map<DeviceBrand, BrandGroup>();
  for (const r of rows) {
    const b = deviceBrand(r.device_type, r.device_model);
    const g = gruplar.get(b) ?? { brand: b, visitors: 0, models: [] };
    g.visitors += r.visitors;
    g.models.push({
      deviceType: r.device_type,
      deviceModel: r.device_model,
      visitors: r.visitors,
    });
    gruplar.set(b, g);
  }
  for (const g of gruplar.values()) {
    g.models.sort(
      (a, b) =>
        b.visitors - a.visitors ||
        trCompare(a.deviceModel ?? '', b.deviceModel ?? ''),
    );
  }
  return [...gruplar.values()].sort(
    // ⚠ `trCompare` — düz `localeCompare` locale'siz çağrılırsa ş/ğ/ı
    // yanlış sıralanır (deponun her yerde geçerli Türkçe kuralı).
    (a, b) => b.visitors - a.visitors || trCompare(a.brand, b.brand),
  );
}

export function platformLabel(deviceType: string | null): string {
  switch (deviceType) {
    case 'ios':
      return 'iOS';
    case 'android':
      return 'Android';
    case 'desktop':
      return 'Masaüstü';
    default:
      return 'Bilinmiyor';
  }
}

/**
 * "Cihaz Modeli" tablosunun satır etiketi: `Samsung · SM-A176B`.
 *
 * Model kodu HAM bırakılıyor (bkz. dosya başlığı); markanın öne alınmasının
 * tek sebebi listenin göz taranabilir olması. Model yoksa satır yine de
 * çizilir — "modeli bilinmeyen kaç ziyaretçi var" da bir cevaptır.
 */
export function deviceModelLabel(
  deviceType: string | null,
  deviceModel: string | null,
): string {
  const m = deviceModel?.trim();
  if (!m) return `${platformLabel(deviceType)} · model bildirmiyor`;
  const marka = deviceBrand(deviceType, m);
  // iOS'ta model dizesi ZATEN "iPhone"/"iPad" — "Apple · iPhone" demek
  // gereksiz tekrar olurdu.
  return marka === 'Apple' || marka === 'Diğer' ? m : `${marka} · ${m}`;
}

/**
 * "İşletim Sistemi" tablosunun satır etiketi: `Android 16`, `iOS 18.7`.
 *
 * ⚠ Platform HER ZAMAN yazılıyor, çünkü sürüm dizesi tek başına yanıltıcı:
 * canlıda `ios` + `10.15.7` satırları var ve o bir iOS sürümü değil,
 * masaüstü User-Agent'ı veren bir cihazın macOS dizesi. Etiket platformu
 * gizleseydi tablo o karışıklığı da gizlerdi.
 */
export function osVersionLabel(
  deviceType: string | null,
  osVersion: string | null,
): string {
  const v = osVersion?.trim();
  return v ? `${platformLabel(deviceType)} ${v}` : `${platformLabel(deviceType)} · sürüm yok`;
}

/** Bir cihaz satırı ve altında açılacak işletim sistemi kırılımı. */
export interface DeviceOsGroup {
  deviceType: string;
  /**
   * ⚠ "Cihaz" tablosunun KENDİ sayısı (`admin_device_breakdown`), alt
   * satırların toplamı DEĞİL — `osBreakdown`ın açıklamasına bak.
   */
  visitors: number;
  /** O cihaz tipindeki sürüm satırları, çoktan aza sıralı. */
  versions: Array<{ osVersion: string | null; visitors: number }>;
}

/**
 * Sürüm dizelerini SAYISAL ve YENİDEN ESKİYE sıralar — `9`, `18.7`den
 * SONRA gelmeli. Düz `trCompare` bunu ters yapardı ("1" < "9").
 *
 * Yalnızca eşit ziyaretçili satırlar arasında bir bozan (tiebreak):
 * asıl sıra her zaman ziyaretçi sayısı. Sayıya çevrilemeyen bir dize
 * gelirse (canlıda görülmedi ama `os_version` serbest metin) `trCompare`e
 * düşer — sıralamayı bozmaktansa alfabetik davranmak yeğdir.
 * Sürümsüz satır (null) HER ZAMAN en sonda.
 */
export function compareOsVersionDesc(a: string | null, b: string | null): number {
  if (a === b) return 0;
  if (a === null) return 1;
  if (b === null) return -1;
  const pa = a.split('.');
  const pb = b.split('.');
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const na = Number(pa[i] ?? '0');
    const nb = Number(pb[i] ?? '0');
    if (!Number.isFinite(na) || !Number.isFinite(nb)) return trCompare(a, b);
    if (na !== nb) return nb - na;
  }
  return 0;
}

/**
 * "Cihaz" tablosunun satırlarına işletim sistemi kırılımını İLİŞTİRİR.
 *
 * ⚠ **Neden ayrı bir "İşletim Sistemi" tablosu YOK (12 Eylül 2026,
 * kullanıcı isteği):** *"Admin ekranında işletim sistemi kırılımlarını da
 * cihaz altına alalım, ayrı tabloya gerek yok. Cihaz markasında yaptığımız
 * gibi Android oka basınca altında detayı görelim."* Yani `brandBreakdown`
 * ile aynı desen: üst satır kapalı durur, isteyen açar.
 *
 * ⚠ **Üst satırın sayısı alt satırların toplamı DEĞİL** — burası
 * `brandBreakdown`dan ayrılıyor. Üst sayı "Cihaz" tablosunun kendi
 * RPC'sinden (`admin_device_breakdown`) geliyor ve o tablonun toplamı
 * DEĞİŞMEDEN kalsın diye bilerek öyle: aynı ziyaretçi pencere içinde
 * işletim sistemini güncellerse İKİ sürüm satırında birden sayılır, yani
 * alt toplam üst satırı AŞABİLİR. Canlıdan ölçüldü (12 Eylül 2026, son 90
 * gün): android 568 ↔ 568, masaüstü 132 ↔ 132, **iOS 91 ↔ 92** — tek bir
 * cihaz pencere içinde `26.5.2` → `26.6.1` geçmiş. Alt toplamı üst satır
 * yapmak "Cihaz" tablosunun sayısını şişirirdi; tersi (alt satırları
 * kırpmak) veriyi gizlerdi. Fark ekranda görünür kalıyor, `?` popup'ı da
 * söylüyor.
 */
export function osBreakdown(
  devices: ReadonlyArray<{ device_type: string; visitors: number }>,
  osRows: ReadonlyArray<{ device_type: string; os_version: string | null; visitors: number }>,
): DeviceOsGroup[] {
  const gruplar = new Map<string, DeviceOsGroup>();
  for (const d of devices) {
    gruplar.set(d.device_type, { deviceType: d.device_type, visitors: d.visitors, versions: [] });
  }
  // İki RPC aynı tabloyu aynı pencereyle okuduğundan beklenmeyen durum;
  // yine de satırı DÜŞÜRMEK yerine kendi grubunu açıyoruz (üst sayı o
  // zaman alt toplam olur). Veriyi sessizce yutmak, tablonun toplamını
  // açıklanamaz biçimde küçültürdü.
  const ustSatiriOlmayan = new Set<string>();
  for (const r of osRows) {
    const g = gruplar.get(r.device_type) ?? {
      deviceType: r.device_type,
      visitors: 0,
      versions: [],
    };
    if (!gruplar.has(r.device_type)) {
      gruplar.set(r.device_type, g);
      ustSatiriOlmayan.add(r.device_type);
    }
    g.versions.push({ osVersion: r.os_version, visitors: r.visitors });
  }
  for (const g of gruplar.values()) {
    if (ustSatiriOlmayan.has(g.deviceType)) {
      g.visitors = g.versions.reduce((a, v) => a + v.visitors, 0);
    }
    g.versions.sort(
      (a, b) => b.visitors - a.visitors || compareOsVersionDesc(a.osVersion, b.osVersion),
    );
  }
  return [...gruplar.values()].sort(
    // ⚠ `trCompare` — locale'siz `localeCompare` ş/ğ/ı'yı yanlış sıralar.
    (a, b) =>
      b.visitors - a.visitors ||
      trCompare(platformLabel(a.deviceType), platformLabel(b.deviceType)),
  );
}
