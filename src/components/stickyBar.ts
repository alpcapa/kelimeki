// Kelimeki — Setup'ın altta sabit düğme şeridi (27 Eylül 2026, ROADMAP #41).
// Üç yerde AYNI: Yapay Zeka formu (OYUNU BAŞLAT), girişli Yapay Zeka listesi
// ve Arkadaşınla listesi ("Yeni Oyun Kur"). `sticky bottom-0`: kaydırma kabı
// `#root`; ekranın altına yapışır, sayfanın sonunda kendi yerine oturur
// (footer'ı örtmez). ⚠ Ata zincirinde `overflow: hidden` OLMAMALI — kabı
// kaydırma kabına çevirip şeridi ekran yerine o kaba yapıştırır (App.tsx'teki
// Setup sarmalayıcısı bu yüzden `overflow-x-clip`). `-mx-4 px-4`: şerit
// Setup kabının dolgusunu da kaplar.
export const STICKY_BAR =
  'sticky bottom-0 z-10 -mx-4 px-4 pt-3 pb-[max(12px,env(safe-area-inset-bottom))] bg-bg border-t border-border shadow-[0_-8px_20px_rgba(163,177,198,0.25)]';

/** Şeridin turuncu ana düğmesi. */
export const STICKY_PRIMARY_BTN =
  'w-full btn-raised btn-raised-orange min-h-[52px] rounded-md font-sans text-base font-bold uppercase tracking-[1px] bg-orange text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed';
