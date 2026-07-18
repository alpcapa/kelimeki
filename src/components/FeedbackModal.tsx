// Harfik — oyun bitiminde gösterilen "Görüş Bildir" formu
import { useState } from 'react';
import { Modal } from './Modal';
import { submitFeedback } from '../lib/api';
import { useAuth } from '../hooks/useAuth';

interface FeedbackModalProps {
  onClose: () => void;
}

export function FeedbackModal({ onClose }: FeedbackModalProps) {
  const { user } = useAuth();
  const [message, setMessage] = useState('');
  const [email, setEmail] = useState(user?.email ?? '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!message.trim()) {
      setError('Mesaj boş olamaz.');
      return;
    }
    setBusy(true);
    try {
      await submitFeedback(message, email);
      setSent(true);
    } catch (err) {
      const msg = err instanceof Error ? err.message : (err as { message?: string })?.message;
      setError(msg || 'Bir hata oluştu.');
    } finally {
      setBusy(false);
    }
  };

  const inputCls =
    'w-full bg-bg border border-border rounded-md px-3 py-2 text-sm text-text outline-none focus:border-accent transition-colors';

  return (
    <Modal title="Görüş Bildir" onClose={onClose}>
      {sent ? (
        <div className="flex flex-col items-center gap-3 py-4 text-center">
          <p className="text-sm text-text">Teşekkürler, mesajın bize ulaştı.</p>
          <button
            onClick={onClose}
            className="btn-raised bg-accent text-white rounded-md py-2.5 px-5 text-xs font-bold uppercase tracking-[1.5px] active:scale-[0.97] transition-transform"
          >
            Kapat
          </button>
        </div>
      ) : (
        <form onSubmit={submit} className="flex flex-col gap-3">
          <p className="text-xs text-muted font-mono">
            Öneri, hata bildirimi ya da her türlü görüşünü bize iletebilirsin.
          </p>
          <textarea
            className={`${inputCls} resize-none`}
            rows={4}
            placeholder="Mesajın"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            maxLength={2000}
            required
            autoFocus
          />
          {!user && (
            <input
              className={inputCls}
              type="email"
              placeholder="E-posta (yanıt alabilmen için, isteğe bağlı)"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
            />
          )}

          {error && <p className="text-red text-xs font-mono">{error}</p>}

          <button
            type="submit"
            disabled={busy}
            className="btn-raised bg-accent text-white rounded-md py-2.5 text-xs font-bold uppercase tracking-[1.5px] active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            {busy ? '...' : 'Gönder'}
          </button>
        </form>
      )}
    </Modal>
  );
}
