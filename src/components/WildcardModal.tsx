// Harfik — joker taş oynanırken hangi harfe dönüşeceğini seçme penceresi
import { Modal } from './Modal';
import { TILE_DATA } from '../data/tiles';
import { Tile } from './Tile';

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
          <div key={letter} className="h-11">
            <Tile
              tile={{ letter, pts: TILE_DATA[letter].pts }}
              variant="rack"
              onClick={() => onSelect(letter)}
            />
          </div>
        ))}
      </div>
    </Modal>
  );
}
