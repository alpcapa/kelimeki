// "Engelle" onayı — arkadaşlık isteği kartı ve oyun daveti kartı AYNI pencereyi
// kullanır (4 Ekim 2026, kullanıcı kararı: istek/davet kartında yalnızca
// "Engelle"; şikayet YOK — şikayet yalnızca oyunun sohbetinden yapılır).
//
// Engelleme geri alınabilir ("Engellediklerim"), ama sonuçları büyük (davet,
// istek ve rastgele eşleşme kapanır) olduğundan tek dokunuşta YAPILMAZ.
// `onConfirm` hata fırlatırsa pencere AÇIK kalır ve hatayı gösterir; sessizce
// yutulup "engellendi" sanılması en kötü sonuç olurdu.
import { useState } from 'react';
import { Modal } from './Modal';
import { friendlyErrorMessage } from '../utils/errorMessage';

export function BlockConfirmModal({
  name,
  onConfirm,
  onClose,
}: {
  name: string;
  /** Başarıyla biterse pencere kapanır; fırlatırsa hata gösterilir. */
  onConfirm: () => Promise<void>;
  onClose: () => void;
}) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function run() {
    setBusy(true);
    setError(null);
    try {
      await onConfirm();
      onClose();
    } catch (e) {
      setError(friendlyErrorMessage(e, { surface: 'engelle', fallback: 'İşlem başarısız oldu.' }));
      setBusy(false);
    }
  }

  return (
    <Modal title="Kişiyi Engelle" onClose={onClose}>
      <div className="flex flex-col gap-3">
        <p className="text-sm text-text font-bold">Emin misiniz?</p>
        <p className="text-sm text-text leading-relaxed">
          <span className="font-bold">{name}</span> kullanıcısını engellemek istediğinize emin misiniz? Bu kişi size
          oyun daveti ya da arkadaşlık isteği gönderemez ve rastgele eşleşmede karşınıza çıkmaz. Engeli istediğiniz zaman
          Arkadaşlar ekranındaki "Engellediklerim" listesinden kaldırabilirsiniz.
        </p>
        {error && <p className="text-xs text-red font-bold">{error}</p>}
        <div className="flex gap-2">
          <button
            type="button"
            disabled={busy}
            onClick={() => void run()}
            className="btn-raised flex-1 rounded-md py-2 text-xs font-bold uppercase tracking-[1px] bg-accent text-white active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            {busy ? '...' : 'Engelle'}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={onClose}
            className="btn-raised-neutral flex-1 rounded-md py-2 text-xs font-bold uppercase tracking-[1px] bg-void border border-border text-text active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            Vazgeç
          </button>
        </div>
      </div>
    </Modal>
  );
}
