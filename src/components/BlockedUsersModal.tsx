// "Engellediklerim" — engellediğim / sohbette engellediğim / şikayet ettiğim
// HERKES, arkadaş olsun olmasın (4 Ekim 2026, kullanıcı kararı).
//
// NEDEN VAR: "Engelle" artık arkadaşlık isteği ve oyun daveti kartından da
// yapılabiliyor. İsteği gönderen genelde arkadaş DEĞİL; eski geri alma yolları
// (arkadaş listesindeki ⋯ menüsü, aktif oyunun sohbet ayarları) onu hiç
// göstermezdi — yani arkadaş olmayan birini engelleyince geri almanın yolu
// yoktu. Bu liste o boşluğu kapatır.
//
// KAPSAM — bilinçli olarak yalnızca GERİ ALMA (`FriendModerationModal`ın aynı
// kararı): yeni şikayet burada AÇILMAZ. Şikayet bir konuşmaya bağlıdır
// (`online_game_chat_reports.online_game_id`); admin şikayetle ilgisi olmayan
// bir yazışma okumasın diye şikayet YALNIZCA oyunun sohbetinden yapılır.
//
// İki ayrı adım (sohbet ayarlarındaki mevcut ayrımla aynı): "Engeli Kaldır"
// açık şikayete DOKUNMAZ; açık şikayet sürdükçe kişi ENGELLİ sayılır, bu
// yüzden şikayetli satırda "Şikayeti Geri Çek" de var. Port ikizi (19 Ekim
// treni): mobile/app/lib/src/ui/friends/blocked_users_sheet.dart.
import { useEffect, useState } from 'react';
import { Modal } from './Modal';
import { Avatar } from './Avatar';
import { ScrollArea } from './ScrollArea';
import { fetchBlockedUsers, unblockUser, withdrawChatReports, type BlockedUser } from '../lib/api';
import { friendlyErrorMessage } from '../utils/errorMessage';

type Pending = { user: BlockedUser; kind: 'unblock' | 'withdraw' } | null;

export function BlockedUsersModal({ onClose }: { onClose: (changed: boolean) => void }) {
  const [users, setUsers] = useState<BlockedUser[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [pending, setPending] = useState<Pending>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);
  const [changed, setChanged] = useState(false);

  const load = () => {
    setLoadError(null);
    fetchBlockedUsers()
      .then(setUsers)
      .catch((e) =>
        setLoadError(friendlyErrorMessage(e, { surface: 'engellediklerim', fallback: 'Liste yüklenemedi.' })),
      );
  };

  useEffect(load, []);

  async function confirm() {
    if (!pending) return;
    setBusy(true);
    setActionError(null);
    try {
      if (pending.kind === 'unblock') await unblockUser(pending.user.userId);
      else await withdrawChatReports(pending.user.userId);
      setChanged(true);
      setPending(null);
      load();
    } catch (e) {
      // Sessizce yutma YOK — gerçekleşmemiş bir sonuç "olmuş" sanılmasın.
      setActionError(friendlyErrorMessage(e, { surface: 'engellediklerim', fallback: 'İşlem başarısız oldu.' }));
    } finally {
      setBusy(false);
    }
  }

  const btnNeutral =
    'btn-raised-neutral rounded-md py-2 px-3 text-[11px] font-bold uppercase tracking-[0.5px] bg-void border border-border text-text active:scale-[0.97] transition-transform disabled:opacity-50';

  return (
    <Modal title="Engellediklerim" onClose={() => onClose(changed)}>
      <div className="flex flex-col gap-3">
        {pending ? (
          <>
            <div className="flex items-center gap-2">
              <Avatar url={pending.user.avatarUrl} name={pending.user.name} size={28} />
              <p className="text-sm font-bold text-text">{pending.user.name}</p>
            </div>
            <p className="text-sm text-text font-bold">Emin misiniz?</p>
            <p className="text-sm text-text leading-relaxed">
              {pending.kind === 'unblock'
                ? `${pending.user.name} için engeliniz kalkacak; size tekrar oyun daveti ve arkadaşlık isteği gönderebilir, rastgele eşleşmede karşınıza çıkabilir.`
                : `${pending.user.name} hakkındaki şikayetiniz geri çekilecek. Dilerseniz daha sonra tekrar şikayet edebilirsiniz.`}
            </p>
            {actionError && <p className="text-xs text-red font-bold">{actionError}</p>}
            <div className="flex gap-2">
              <button
                type="button"
                disabled={busy}
                className="btn-raised flex-1 rounded-md py-2 text-xs font-bold uppercase tracking-[1px] bg-accent text-white active:scale-[0.97] transition-transform disabled:opacity-50"
                onClick={() => void confirm()}
              >
                {busy ? '...' : pending.kind === 'unblock' ? 'Engeli Kaldır' : 'Geri Çek'}
              </button>
              <button
                type="button"
                disabled={busy}
                className={btnNeutral + ' flex-1'}
                onClick={() => {
                  setPending(null);
                  setActionError(null);
                }}
              >
                Vazgeç
              </button>
            </div>
          </>
        ) : loadError ? (
          <div className="flex flex-col gap-2">
            <p className="text-xs text-red font-bold">{loadError}</p>
            <button type="button" className={btnNeutral} onClick={load}>
              Tekrar dene
            </button>
          </div>
        ) : users === null ? (
          <p className="text-center text-xs text-muted font-mono py-6">Yükleniyor…</p>
        ) : users.length === 0 ? (
          <p className="text-center text-xs text-muted font-mono py-6">Kimseyi engellemedin.</p>
        ) : (
          <>
            <p className="text-xs text-muted leading-relaxed">
              Engellediğin kişiler sana oyun daveti ya da arkadaşlık isteği gönderemez ve rastgele eşleşmede karşına
              çıkmaz.
            </p>
            <ScrollArea className="flex flex-col gap-2 max-h-[55vh]">
              {users.map((u) => (
                <div key={u.userId} className="flex flex-col gap-2 p-2.5 rounded-md border border-border bg-panel">
                  <div className="flex items-center gap-2">
                    <Avatar url={u.avatarUrl} name={u.name} size={28} />
                    <p className="flex-1 min-w-0 truncate text-sm font-bold text-text">{u.name}</p>
                    {u.reported && (
                      <span className="shrink-0 text-xs" title="Şikayet edildi" aria-label="Şikayet edildi">
                        🚩
                      </span>
                    )}
                  </div>
                  <div className="flex gap-2">
                    {u.reported && (
                      <button
                        type="button"
                        className={btnNeutral + ' flex-1'}
                        onClick={() => setPending({ user: u, kind: 'withdraw' })}
                      >
                        Şikayeti Geri Çek
                      </button>
                    )}
                    <button
                      type="button"
                      className={btnNeutral + ' flex-1'}
                      onClick={() => setPending({ user: u, kind: 'unblock' })}
                    >
                      Engeli Kaldır
                    </button>
                  </div>
                  {u.reported && (
                    <p className="text-[10px] font-mono text-muted leading-relaxed">
                      Şikayetiniz açıkken kişi engelli kalır; tamamen serbest bırakmak için ikisini de uygulayın.
                    </p>
                  )}
                </div>
              ))}
            </ScrollArea>
          </>
        )}
      </div>
    </Modal>
  );
}
