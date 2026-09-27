// Kelimeki — Setup'ın turuncu ana eylem düğmesi (27 Eylül 2026, ROADMAP #41):
// girişli Yapay Zeka listesi ve Arkadaşınla listesindeki "Yeni Oyun Kur".
//
// ⚠ "Altta SABİT şerit" (`sticky bottom-0`) denendi ve geri alındı: iOS
// Safari'nin yüzen alt çubuğunda sayfa çubuğun ARKASINA kadar uzanıyor ve
// yapışkan şerit oraya, görünmez yere oturuyordu (kullanıcı ekran
// görüntüsüyle bildirdi; `env(safe-area-inset-bottom)` bu modda 0). Çubuğun
// yüksekliği sayfadan güvenilir ölçülemediği için düğmeler AKIŞTA duruyor.
export const PRIMARY_ACTION_BTN =
  'w-full btn-raised btn-raised-orange min-h-[52px] rounded-md font-sans text-base font-bold uppercase tracking-[1px] bg-orange text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed';
