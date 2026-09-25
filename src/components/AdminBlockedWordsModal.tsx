// Kelimeki — Admin: sohbet/takma ad süzgecinin kelime listesi (25 Eylül
// 2026, ROADMAP #37). "Şikayetler" alt sekmesindeki bağlantıdan açılır.
//
// Süzgeç SUNUCUDA (`chat_blocked_words` + `online_game_messages` BEFORE
// INSERT trigger'ı): eklenen/çıkarılan kelime bir sonraki mesajdan itibaren
// geçerli, istemci sürümü gerekmez. Eşleşme TAM KELİME (Türkçe küçük harfe
// göre) — "am" eklemek "ama"yı etkilemez. Kelime içinde arama BİLEREK yok:
// kuru ölçümde masum kelimeleri kesiyordu (bkz. ROADMAP #37).
//
// Tohum liste: ooguz/turkce-kufur-karaliste (CC BY-SA 4.0) + LDNOOBW `tr`
// (CC BY 4.0), elle ayıklanmış.
import { useEffect, useMemo, useState } from 'react';
import { Modal } from './Modal';
import {
  addAdminChatBlockedWord,
  fetchAdminChatBlockedWords,
  removeAdminChatBlockedWord,
} from '../lib/api';
import type { ChatBlockedWord } from '../lib/database.types';
import { trLower } from '../utils/turkish';

export function AdminBlockedWordsModal({ onClose }: { onClose: () => void }) {
  const [words, setWords] = useState<ChatBlockedWord[] | null>(null);
  const [query, setQuery] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [confirmRemove, setConfirmRemove] = useState<string | null>(null);

  const load = async () => {
    try {
      setWords(await fetchAdminChatBlockedWords());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Liste yüklenemedi.');
      setWords([]);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const q = trLower(query.trim());
  const filtered = useMemo(
    () => (words ?? []).filter((w) => !q || w.word.includes(q)),
    [words, q],
  );
  const alreadyThere = !!q && (words ?? []).some((w) => w.word === q);

  const handleAdd = async () => {
    if (q.length < 2 || busy) return;
    setBusy(true);
    setError(null);
    try {
      await addAdminChatBlockedWord(q);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Eklenemedi.');
    } finally {
      setBusy(false);
    }
  };

  const handleRemove = async (word: string) => {
    setBusy(true);
    setError(null);
    try {
      await removeAdminChatBlockedWord(word);
      setConfirmRemove(null);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Çıkarılamadı.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal title="Kelime Süzgeci" onClose={onClose}>
      <div className="flex flex-col gap-3">
        <p className="text-[11px] text-muted font-mono leading-relaxed">
          Sohbet mesajında eşleşen kelime <strong>*</strong> ile gizlenir (orijinal
          yalnızca Sohbet Dökümü'nde görünür); eşleşen takma isim reddedilir.
          Eşleşme TAM KELİME: "am" eklemek "ama"yı etkilemez. Değişiklik bir
          sonraki mesajdan itibaren geçerli.
        </p>
        <div className="flex gap-2">
          <input
            className="flex-1 bg-bg border border-border rounded-md px-3 py-2 text-sm text-text outline-none focus:border-accent"
            placeholder="Ara ya da yeni kelime"
            value={query}
            onChange={(e) => setQuery(e.target.value.slice(0, 60))}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !alreadyThere) void handleAdd();
            }}
          />
          <button
            onClick={() => void handleAdd()}
            disabled={busy || q.length < 2 || alreadyThere}
            className="btn-raised bg-accent text-white rounded-md px-3 text-[11px] font-bold uppercase tracking-[1px] disabled:opacity-40"
          >
            Ekle
          </button>
        </div>
        {error && <p className="text-[10px] font-mono text-red">{error}</p>}
        <p className="text-[10px] text-muted font-mono">
          {words === null ? 'Yükleniyor…' : `${filtered.length} / ${words.length} kelime`}
        </p>
        <ul className="max-h-72 overflow-y-auto flex flex-col divide-y divide-border">
          {filtered.map((w) => (
            <li key={w.word} className="flex items-center justify-between gap-2 py-1.5">
              <span className="text-xs font-mono text-text break-all">
                {w.word}
                {w.source === 'admin' && <span className="ml-2 text-[9px] text-accent">EKLENDİ</span>}
              </span>
              {confirmRemove === w.word ? (
                <span className="flex gap-2 shrink-0">
                  <button
                    onClick={() => void handleRemove(w.word)}
                    disabled={busy}
                    className="text-[10px] font-mono text-red hover:underline"
                  >
                    Çıkar
                  </button>
                  <button
                    onClick={() => setConfirmRemove(null)}
                    className="text-[10px] font-mono text-muted hover:underline"
                  >
                    Vazgeç
                  </button>
                </span>
              ) : (
                <button
                  onClick={() => setConfirmRemove(w.word)}
                  aria-label={`${w.word} kelimesini çıkar`}
                  className="text-muted hover:text-red text-sm tap-expand w-6 h-6 flex items-center justify-center shrink-0"
                >
                  ✕
                </button>
              )}
            </li>
          ))}
        </ul>
      </div>
    </Modal>
  );
}
