// Harfik — paylaşılan modal kabuğu
import type { ReactNode } from 'react';
import { createPortal } from 'react-dom';

interface ModalProps {
  title: string;
  onClose: () => void;
  children: ReactNode;
}

export function Modal({ title, onClose, children }: ModalProps) {
  return createPortal(
    <div
      className="fixed inset-0 z-[150] flex items-center justify-center p-4 bg-[rgba(6,10,13,0.45)] backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[360px] bg-panel border border-border rounded-xl p-5 max-h-[85vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-mono text-sm font-bold tracking-[1.5px] uppercase text-accent">
            {title}
          </h2>
          <button
            onClick={onClose}
            aria-label="Kapat"
            className="text-muted hover:text-text text-lg leading-none w-7 h-7 flex items-center justify-center rounded active:scale-90 transition-transform"
          >
            ✕
          </button>
        </div>
        {children}
      </div>
    </div>,
    document.body,
  );
}
