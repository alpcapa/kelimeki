// Kelimeki — Setup'ın turuncu ana eylem düğmesi (27 Eylül 2026, ROADMAP #41):
// girişli Yapay Zeka listesi ve Arkadaşınla listesindeki "Yeni Oyun Başlat".
//
// ⚠ "Altta SABİT şerit" (`sticky bottom-0`) denendi ve geri alındı: iOS
// Safari'nin yüzen alt çubuğunda sayfa çubuğun ARKASINA kadar uzanıyor ve
// yapışkan şerit oraya, görünmez yere oturuyordu (kullanıcı ekran
// görüntüsüyle bildirdi; `env(safe-area-inset-bottom)` bu modda 0). Çubuğun
// yüksekliği sayfadan güvenilir ölçülemediği için düğmeler AKIŞTA duruyor.
// `position: fixed; bottom: 0` da çözüm DEĞİL: yeni oyun formunun eski
// "Davet Gönder" şeridi tam böyleydi ve kullanıcının iPad ekran görüntüsünde
// çubuğun arkasına yarı girmişti (27 Eylül 2026) — o da akışa alındı.
export const PRIMARY_ACTION_BTN =
  'w-full btn-raised btn-raised-orange min-h-[52px] rounded-md font-sans text-base font-bold uppercase tracking-[1px] bg-orange text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed';
