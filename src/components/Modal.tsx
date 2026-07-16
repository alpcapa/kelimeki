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
      className="fixed inset-0 z-[150] flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[360px] bg-panel border border-[#B8C2D1] rounded-xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] max-h-[85vh] flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="shrink-0 flex items-center justify-between px-5 pt-5 pb-4 border-b border-border">
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
        <div className="overflow-y-auto px-5 pt-4 pb-5">{children}</div>
      </div>
    </div>,
    document.body,
  );
}
