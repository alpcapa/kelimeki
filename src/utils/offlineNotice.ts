// Canlı oyun çevrimdışıyken ne denir — TEK kaynak.
//
// NEDEN (14 Ağustos 2026, kullanıcı cihaz testinde bildirdi): Canlı oyun
// YAPISI GEREĞİ çevrimiçi — tahta/raf/torba sunucuda otoriter
// (`online_game_states`/`online_game_secrets`), offline dayanıklılık yalnızca
// yerel/YZ oyunları için var (localStorage + `cloudSaveMirror`). Ama kullanıcı
// bunu uçak modunda İKİ kez sessizce öğreniyordu: (1) listeden bir Canlı
// oyuna dokununca ekran beyaz "Yükleniyor…"da asılı kalıyordu (ilk yükleme
// başarısız olunca ekran "korunuyor", oysa korunacak bir şey yok), (2)
// hamle gönderince hiçbir şey olmuyordu. Kullanıcının isteği: "kişi bunları
// yaptığında 'Şu anda çevrimdışısınız. Canlı oyun için internete bağlı
// olmanız gerekir. Dilerseniz yapay zekayla oynayabilirsiniz' tarzında bir
// uyarı gerekir. (Hem web hem de app için)".
//
// **Metin İKİ PLATFORMDA AYNI OLMAK ZORUNDA** — Flutter portundaki eşi
// `mobile/app/lib/src/util/offline_notice.dart`; biri değişirse öteki de.

/** Oyun ekranı hiç açılamadığında gösterilen panelin başlığı. */
export const OFFLINE_LIVE_TITLE = 'Canlı oyun için internet gerekiyor';

/**
 * Panelin gövdesi. Bilerek "sunucuya ulaşılamıyor" diyor, "çevrimdışısın"
 * DEĞİL: aynı metin hem uçak modunda hem (nadir de olsa) sunucu erişilemez
 * olduğunda DOĞRU olmak zorunda — ikisini ayırt etmek için Flutter tarafında
 * bir bağlantı API'si yok (bkz. `mobile/CLAUDE.md`, "Sonraya Bırakılan
 * İşler"), ve iki platformun metninin ayrışması bu projede yasak.
 */
export const OFFLINE_LIVE_BODY =
  'Şu anda sunucuya ulaşılamıyor. Bağlantını kontrol edip tekrar dene. ' +
  'Dilersen Yapay Zeka’ya karşı çevrimdışı da oynayabilirsin.';

/** Mesaj satırına sığacak kısa hâli (tek satır, 11px mono). */
export const OFFLINE_MOVE_NOTICE =
  'Bağlantı yok — Canlı oyun için internet gerekiyor.';

/**
 * Panelin geri butonu. Bilerek HEDEF ADI TAŞIMIYOR ("Canlı Listesi" değil):
 * çevrimdışıyken o listeye dönünce Canlı sekmeleri zaten "bağlantı yok"
 * diyor, yani kullanıcıya var olmayan bir yere gidiyormuş izlenimi vermek
 * yanlıştı (14 Ağustos 2026, kullanıcı: "geri gitmek için yazan Canlı
 * listesi çok saçma").
 */
export const OFFLINE_BACK_LABEL = 'Geri Dön';

/** Canlı sekmelerinin (Devam Edenler/Oyun Davetleri/Son Oynananlar) hâli. */
export const OFFLINE_NO_CONNECTION = 'İnternet bağlantısı yok';

/**
 * Yapay Zeka sekmesi çevrimdışıyken FARKLI konuşur: orada gerçekten
 * oynanabilir bir şey var (yerel oyun tamamen çevrimdışı çalışır), o yüzden
 * kullanıcı bir çıkmaza değil bir seçeneğe yönlendiriliyor. [OFFLINE_AI_CTA]
 * ayrı bir sabit çünkü LİNK olarak render ediliyor — dokunuşu "+ Yeni Yapay
 * Zeka Oyunu" butonuyla aynı şeyi yapar.
 *
 * Yalnızca gösterilecek bir kayıt YOKKEN çıkar: devam eden YZ oyunları
 * çevrimdışıyken de listelenip oynanabiliyor (bkz. `cloudSaveMirror`), o
 * listeyi bir uyarıyla değiştirmek gerçek bir yeteneği gizlerdi.
 */
export const OFFLINE_AI_SUGGESTION =
  'İnternet bağlantısı yok ama sorun değil, yapay zeka ile çevrimdışı da oynayabilirsin.';
export const OFFLINE_AI_CTA = 'Hemen oyun aç.';

// ── "Çevrimdışı" DEĞİL, "yükleyemedik" ─────────────────────────────────────
//
// Bu üç metin bilerek İNTERNET TEŞHİSİ YAPMIYOR (21 Ağustos 2026, kullanıcı:
// *"Oraya 'İnternet bağlantısı yok' çıkartmak da doğru değil çünkü başka
// yerlere girince bunun doğru olmadığını görecekler"*). Çevrimiçiyken tek bir
// isteğin düşmesi ile gerçekten çevrimdışı olmak AYRI durumlar; ikisini aynı
// cümleye indirmek bu hatanın kökeniydi. `OFFLINE_NO_CONNECTION` yalnızca
// `navigator.onLine === false` iken kalır.

/** Elde hiç liste yokken yükleme düştü — tek çıkış yolu yeniden denemek. */
export const LOAD_FAILED_NOTICE = 'Oyunların şu an yüklenemedi.';

/** Liste ekranda duruyor ama tazelenemedi — veri bayat, ama YANLIŞ değil. */
export const STALE_DATA_NOTICE = 'Güncellenemedi';

/** İki durumun da eylem düğmesi (oyun ekranındaki panelle aynı sözcük). */
export const RETRY_LABEL = 'Tekrar Dene';

/**
 * Hata "sunucuya hiç ulaşamadık" mı, yoksa sunucunun kendi reddi mi?
 *
 * Ayrım şart: `submit_move`'un iş kuralı hataları ("Sıra sende değil.",
 * "Yalnızca arkadaşlarını davet edebilirsin.") OLDUĞU GİBİ gösterilmeli;
 * yalnızca ağ katmanı hataları yukarıdaki metne çevrilir. Eşleşmeyen bir
 * hata BİLEREK ham hâliyle geçer — bilinmeyen bir hatayı "çevrimdışısın"
 * diye maskelemek hata ayıklamayı imkânsız kılardı (aynı ilke:
 * `friendlyAuthMessage`, src/lib/api.ts).
 *
 * `navigator.onLine === false` kesin bir sinyal; metin eşlemesi ise sunucuya
 * ulaşılamayan ama tarayıcının "online" saydığı durumlar için.
 * **"load failed" Safari'nin `fetch` hata metnidir** — kullanıcı iPad
 * Safari'de test ettiğinden bu kalıbın listede olması şart.
 */
export function isNetworkError(err: unknown): boolean {
  if (typeof navigator !== 'undefined' && navigator.onLine === false) return true;
  const message = err instanceof Error ? err.message : String(err ?? '');
  return /failed to fetch|load failed|networkerror|network request failed|fetch failed/i.test(
    message,
  );
}

/**
 * Sunucudan GELEN ama GEÇİCİ olan hata — ağ geçidi cevabı zamanında
 * alamamış demektir, sunucu bir karar vermiş değildir.
 *
 * ⚠ **`isNetworkError`'dan neden ayrı:** o yüklem isteğin hiç gitmediği
 * durumu (taşıma istisnası) tanıyor ve mesaja bakıyor; bu ise sunucunun
 * DÖNDÜĞÜ bir durum kodunu tanıyor. Bir `PostgrestException(code: 504)`
 * ikisinin arasına düşüyordu: taşıma kalıplarına uymadığı için "sunucunun
 * kendi reddi" sayılıyor, yani ne yeniden deneniyor ne de kullanıcıdan
 * gizleniyordu.
 *
 * **Ölçüm (17 Eylül 2026):** `client_errors`taki 62 kaydın 11'i bu sınıftı
 * (`online_games_repo.load` → 504, android 9 · ios 2, 8 cihaz, 12-14
 * Eylül'de yoğunlaşmış). Sunucu tarafı elendi: `list_my_online_games` en
 * ağır kullanıcıda (97 oyun) **12,7 ms** sürüyor, planı indeksli — yani
 * 504 yavaş sorgudan değil, ağ geçidinden geliyor ve tam da yeniden
 * denenmesi gereken şey.
 *
 * ⚠ **Liste BİLEREK dar.** `500` YOK (gerçek bir sunucu kusuru olabilir,
 * tekrar onu maskeler) ve `429` YOK (hız sınırını hemen tekrar zorlamak
 * durumu kötüleştirir). Kalıcı ret (401/403/RLS/iş kuralı) zaten bir
 * KARAR — o asla tekrarlanmaz.
 *
 * Port ikizi: `isTransientServerError` (`util/offline_notice.dart`).
 */
const GECICI_DURUM_KODLARI = ['408', '502', '503', '504', '522', '524'];

export function isTransientServerError(err: unknown): boolean {
  const kod = (err as { code?: unknown } | null | undefined)?.code;
  if ((typeof kod === 'string' || typeof kod === 'number') &&
      GECICI_DURUM_KODLARI.includes(String(kod))) {
    return true;
  }
  const mesaj =
    err instanceof Error
      ? err.message
      : typeof err === 'string'
        ? err
        : String((err as { message?: unknown } | null | undefined)?.message ?? '');
  // Kalıplar İngilizce ağ geçidi metinleri; sunucunun Türkçe reddi
  // ("Sıra sende değil.") bunların hiçbirine denk gelmez.
  return /gateway time-?out|bad gateway|service unavailable|request time-?out/i.test(mesaj);
}

/**
 * Kelime anlamı penceresi — sözlük YÜKLENEMEDİĞİNDE ("kelime bulunamadı"dan
 * farklı). Web'de `meanings.json` 6.3 MB ve precache'e bilerek alınmıyor
 * (herkese 6 MB'lık ön indirme yüklemek bir oyun için orantısız).
 *
 * **DÜZELTME (aynı gün, cihaz testi):** bu yorum önce "YALNIZCA WEB, porta
 * TAŞINMAZ — orada sözlük pakette, çevrimdışı çalışıyor" diyordu. O iddia
 * NATIVE için doğru ama portun test ortamı olan **Flutter web derlemesi**
 * için YANLIŞTI: orada sözlük asset'i de HTTP ile çekiliyor
 * (`MeaningStore._openWeb` ilk açılışta 6 MB'ı IndexedDB'ye kopyalar) ve
 * uçak modunda o çekim düşüyor — kullanıcı app'te de "anlamı bulunamadı"
 * gördü. Metin artık `offline_notice.dart`'ta da var ve parite testine
 * dahil. **Ders: "asset pakette" demek her derleme hedefi için aynı şeyi
 * ifade etmiyor.**
 */
export const OFFLINE_MEANING_NOTICE =
  'Kelime anlamları için internet bağlantısı gerekiyor.';
