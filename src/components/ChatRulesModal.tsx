// Kelimeki — Sohbet Kuralları onay penceresi (25 Eylül 2026). İlk mesaj
// gönderilmeden önce BİR KEZ çıkar; kararı ve metni `utils/chatRules.ts`
// tutar, burada yalnızca çizim var. Portun eşi:
// `mobile/app/lib/src/ui/chat/chat_rules_modal.dart`.
import { useState } from 'react';
import { Modal } from './Modal';
import { TermsModal } from './TermsModal';
import {
  CHAT_RULES_ACCEPT,
  CHAT_RULES_CANCEL,
  CHAT_RULES_INTRO,
  CHAT_RULES_ITEMS,
  CHAT_RULES_TERMS_LINK,
  CHAT_RULES_TITLE,
} from '../utils/chatRules';

interface ChatRulesModalProps {
  /** "Kabul ediyorum" — kaydı yazmak ve mesajı göndermek çağıranın işi. */
  onAccept: () => void;
  onCancel: () => void;
  /** Kabul kaydı yazılırken butonlar kilitlenir. */
  busy: boolean;
  error: string | null;
}

export function ChatRulesModal({ onAccept, onCancel, busy, error }: ChatRulesModalProps) {
  const [showTerms, setShowTerms] = useState(false);
  return (
    <>
      <Modal title={CHAT_RULES_TITLE} onClose={onCancel}>
        <div className="flex flex-col gap-3">
          <p className="text-sm text-text font-sans">{CHAT_RULES_INTRO}</p>
          <ul className="text-sm font-sans text-text leading-relaxed list-disc pl-5 flex flex-col gap-1.5">
            {CHAT_RULES_ITEMS.map((madde) => (
              <li key={madde}>{madde}</li>
            ))}
          </ul>
          <button
            type="button"
            onClick={() => setShowTerms(true)}
            className="self-start text-xs text-accent font-mono hover:underline"
          >
            {CHAT_RULES_TERMS_LINK}
          </button>
          {error && <p className="text-[10px] font-mono text-red">{error}</p>}
          <div className="flex gap-2 mt-1">
            <button
              onClick={onAccept}
              disabled={busy}
              className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-40"
            >
              {CHAT_RULES_ACCEPT}
            </button>
            <button
              onClick={onCancel}
              disabled={busy}
              className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-40"
            >
              {CHAT_RULES_CANCEL}
            </button>
          </div>
        </div>
      </Modal>
      {showTerms && <TermsModal onClose={() => setShowTerms(false)} />}
    </>
  );
}
