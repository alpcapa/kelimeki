// Kelimeki — Setup'taki "Hamle Avı" girişi (3 Kasım 2026, ROADMAP #48).
// Girişlide "Yeni Oyun"un, misafirde "Oyunu Başlat"ın yanında 1/3. 🎯 simgesi kullanıcı onaylı (görsel tur, 3 Kas); "YENİ" balonu Hamle Avı bir kez
// açılınca kalkar (`hamleAviStore.opened`, cihazda).
import { shouldShowNewBadge } from '../utils/hamleAviStore';

interface HamleAviButtonProps {
  onOpen: () => void;
}

export function HamleAviButton({ onOpen }: HamleAviButtonProps) {
  const yeni = shouldShowNewBadge();
  return (
    <button
      onClick={onOpen}
      data-hamle-avi-buton=""
      className={[
        'relative btn-raised-neutral bg-panel text-text border border-border min-h-[52px] rounded-md font-sans font-bold uppercase tracking-[0.5px] active:scale-[0.97] transition-transform',
        'flex flex-col items-center justify-center leading-tight flex-[1_1_0%]',
      ].join(' ')}
    >
      {yeni && (
        <span
          className="absolute -top-2 -right-1 bg-red text-white text-[9px] px-1.5 py-0.5 rounded-full tracking-[0.5px]"
          data-hamle-avi-yeni=""
        >
          YENİ
        </span>
      )}
      <span className="text-[15px]" aria-hidden>
        🎯
      </span>
      <span className="text-[10px]">Hamle Avı</span>
    </button>
  );
}
