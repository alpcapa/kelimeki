// Harfik — joker taş oynanırken hangi harfe dönüşeceğini seçme penceresi
import { Modal } from './Modal';
import { TILE_DATA } from '../data/tiles';

const LETTERS = Object.keys(TILE_DATA).filter((l) => l !== '?');

interface WildcardModalProps {
  onSelect: (letter: string) => void;
  onClose: () => void;
}

export function WildcardModal({ onSelect, onClose }: WildcardModalProps) {
  return (
    <Modal title="Joker Hangi Harf Olsun?" onClose={onClose}>
      <div className="grid grid-cols-6 gap-1.5">
        {LETTERS.map((letter) => (
          <button
            key={letter}
            onClick={() => onSelect(letter)}
            className="flex items-center justify-center h-11 rounded-md border border-tile-border bg-tile-bg font-tile font-extrabold text-[18px] text-tile-letter active:scale-90 transition-transform"
          >
            {letter}
          </button>
        ))}
      </div>
    </Modal>
  );
}
