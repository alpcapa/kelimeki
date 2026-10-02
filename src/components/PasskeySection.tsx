// Kelimeki — Hesap Ayarları'ndaki "Passkey'ler" bölümü (ROADMAP #43,
// 2 Ekim 2026). Kayıtlı passkey'leri listeler, yenisini ekler, siler.
//
// Neden ayrı bileşen: `AccountSettingsModal`ın formu "kaydet" akışıdır;
// passkey işlemleri anında sunucuya gider ve form kaydına KARIŞMAMALI
// (hesap silme bölümüyle aynı gerekçe — formun DIŞINDA durur).
//
// ⚠ Passkey kaydın yerine geçmez: hesap e-postayla açılır, passkey bu
// bölümden sonradan eklenir. RP ID `kelimeki.com` → Vercel önizlemelerinde
// tören başarısız olur, test yalnızca canlıda (`TESTING.md`).
import { useEffect, useState } from 'react';
import {
  deletePasskey,
  friendlyAuthMessage,
  listPasskeys,
  passkeySupported,
  registerPasskey,
  type PasskeyItem,
} from '../lib/api';
import { useAuth } from '../hooks/useAuth';
import { friendlyErrorMessage } from '../utils/errorMessage';

function tarih(iso: string): string {
  return new Date(iso).toLocaleDateString('tr-TR', { day: 'numeric', month: 'long', year: 'numeric' });
}

export function PasskeySection() {
  const { user } = useAuth();
  const [items, setItems] = useState<PasskeyItem[] | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const supported = passkeySupported();

  // Bağımlılık `user?.id` — nesne DEĞİL (CLAUDE.md, verify-auth-user-identity).
  useEffect(() => {
    if (!supported || !user?.id) return;
    let iptal = false;
    listPasskeys()
      .then((l) => {
        if (!iptal) setItems(l);
      })
      .catch(() => {
        if (!iptal) setItems([]);
      });
    return () => {
      iptal = true;
    };
  }, [supported, user?.id]);

  if (!supported || !user) return null;

  const hata = (err: unknown) =>
    setError(
      friendlyAuthMessage(err) ??
        friendlyErrorMessage(err, { surface: 'passkey-ayar', fallback: 'Passkey işlemi tamamlanamadı.' }),
    );

  const ekle = async () => {
    setError(null);
    setInfo(null);
    setBusy(true);
    try {
      const ok = await registerPasskey();
      if (!ok) return; // kullanıcı vazgeçti
      setInfo('Passkey eklendi. Artık şifresiz giriş yapabilirsin.');
      setItems(await listPasskeys());
    } catch (err) {
      hata(err);
    } finally {
      setBusy(false);
    }
  };

  const sil = async (id: string) => {
    setError(null);
    setInfo(null);
    setBusy(true);
    try {
      await deletePasskey(id);
      setItems((l) => (l ?? []).filter((p) => p.id !== id));
    } catch (err) {
      hata(err);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="mt-6 pt-4 border-t border-border flex flex-col gap-2">
      <span className="text-[9px] uppercase tracking-[1.5px] text-muted font-mono">Passkey'ler</span>
      <p className="text-[10px] text-muted font-mono">
        Yüz tanıma, parmak izi ya da cihaz kilidiyle şifresiz giriş.
      </p>
      {items && items.length > 0 && (
        <ul className="flex flex-col gap-1.5">
          {items.map((p) => (
            <li
              key={p.id}
              className="flex items-center justify-between gap-2 bg-bg border border-border rounded-md px-3 py-2"
            >
              <span className="min-w-0 flex flex-col">
                <span className="text-xs text-text truncate">{p.friendly_name || 'Passkey'}</span>
                <span className="text-[10px] text-muted font-mono">Eklendi: {tarih(p.created_at)}</span>
              </span>
              <button
                type="button"
                disabled={busy}
                onClick={() => void sil(p.id)}
                className="shrink-0 min-h-[32px] text-[10px] font-mono font-bold uppercase tracking-[1px] text-red active:opacity-70 disabled:opacity-50"
              >
                Sil
              </button>
            </li>
          ))}
        </ul>
      )}
      <button
        type="button"
        disabled={busy}
        onClick={() => void ekle()}
        className="self-start btn-raised bg-panel text-text border border-border rounded-md py-2 px-3 text-[11px] font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-50"
      >
        {busy ? '...' : 'Passkey ekle'}
      </button>
      {error && <p className="text-red text-xs font-mono">{error}</p>}
      {info && <p className="text-green text-xs font-mono">{info}</p>}
    </div>
  );
}
