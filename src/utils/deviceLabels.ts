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

/**
 * Bir satır kümesini markaya göre toplar; büyükten küçüğe sıralı döner.
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
): Array<{ brand: DeviceBrand; visitors: number }> {
  const toplam = new Map<DeviceBrand, number>();
  for (const r of rows) {
    const b = deviceBrand(r.device_type, r.device_model);
    toplam.set(b, (toplam.get(b) ?? 0) + r.visitors);
  }
  return [...toplam.entries()]
    .map(([brand, visitors]) => ({ brand, visitors }))
    // ⚠ `trCompare` — düz `localeCompare` locale'siz çağrılırsa ş/ğ/ı
    // yanlış sıralanır (deponun her yerde geçerli Türkçe kuralı).
    .sort((a, b) => b.visitors - a.visitors || trCompare(a.brand, b.brand));
}

/**
 * `device_visits.device_type` → ekranda görünen platform adı.
 *
 * ⚠ TEK KAYNAK: aynı eşleme 24 Ağustos 2026'dan beri "Cihaz" tablosunun
 * `getLabel`inde satır içi duruyordu; model/OS tabloları eklenince üç kopya
 * olacaktı. Yeni bir platform değeri (`app-web` gibi) buraya eklenir.
 */
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
