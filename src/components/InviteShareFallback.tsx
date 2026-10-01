// Kelimeki — paylaşım sayfası OLMAYAN tarayıcıda (masaüstü) davet linkinin
// yedek penceresi: "WhatsApp'ta gönder" + "Linki kopyala". Telefonda sistem
// paylaşım sayfası zaten açılıyor (`useInviteShare`).
import { useState } from 'react';
import { createPortal } from 'react-dom';
import { useModalA11y } from '../hooks/useModalA11y';
import { INVITE_SHARE_TEXT, whatsappShareUrl } from '../utils/friendInvite';

export function InviteShareFallback({ url, onClose }: { url: string; onClose: () => void }) {
  const ref = useModalA11y(true, onClose);
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    if (!navigator.clipboard) return;
    await navigator.clipboard.writeText(`${INVITE_SHARE_TEXT}\n${url}`);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  };
  return createPortal(
    <div className="fixed inset-0 z-[220] flex items-center justify-center px-4">
      <div className="absolute inset-0 bg-[rgba(15,23,42,0.45)]" onClick={onClose} aria-hidden />
      <div
        ref={ref}
        role="dialog"
        aria-modal="true"
        aria-label="Arkadaşını davet et"
        tabIndex={-1}
        className="relative w-full max-w-sm bg-panel rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-5 flex flex-col gap-3 outline-none"
      >
        <p className="text-base font-bold text-text" style={{ margin: 0 }}>
          Arkadaşını davet et
        </p>
        <p className="text-sm text-muted leading-relaxed" style={{ margin: 0 }}>
          Linke dokunup üye olunca arkadaş listende belirir.
        </p>
        <a
          href={whatsappShareUrl(url)}
          target="_blank"
          rel="noopener"
          onClick={onClose}
          className="flex items-center justify-center min-h-[48px] rounded-md bg-[#25D366] text-white text-sm font-bold uppercase tracking-[1px] no-underline active:scale-[0.97] transition-transform"
        >
          WhatsApp'ta gönder
        </a>
        <button
          type="button"
          onClick={() => void copy()}
          className="min-h-[48px] rounded-md btn-raised-neutral bg-bg border border-border text-text text-sm font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
        >
          {copied ? 'Link kopyalandı!' : 'Linki kopyala'}
        </button>
      </div>
    </div>,
    document.body,
  );
}
