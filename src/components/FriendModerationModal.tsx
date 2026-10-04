// Arkadaş listesinden moderasyon durumunu YÖNETME paneli.
//
// 5 Ekim 2026: "Sessizden Çıkar" → "Engeli Kaldır" (terim: Engelle) ve kaldırma
// artık `unblock_user` (oyundan bağımsız). Aşağıdaki gerekçe anlatısı o
// dönemin dilini ('sessize alma') korur.
//
// NEDEN VAR (14 Ağustos 2026, kullanıcı isteği): sessize alma/şikayet 3
// Ağustos'tan beri KİŞİ bazlı — kişiyle birlikte oyunlar arası taşınıyor.
// Ama geri almanın TEK giriş noktası, o kişiyle AKTİF bir oyunun sohbet
// ayarlarıydı (`ChatSettingsModal`, dişli ikonu). Oyun bitince
// `LiveGamesTab` onu artık listelemediğinden sohbet penceresi hiç
// açılamıyor; arşiv (`GameChatHistoryModal`) ise bilerek salt-görsel
// (rozet var, dişli/tıklama yok). Sonuç: bir oyun bittikten sonra
// şikayeti geri çekmek için raporladığın kişiyle YENİ BİR OYUN AÇMAK
// gerekiyordu — raporladığın biriyle yeniden oynamak tuhaf bir varsayım.
// Kullanıcı testi sırasında bizzat bu duvara çarpıldı.
//
// KAPSAM — bilinçli olarak yalnızca GERİ ALMA:
//  * "Sessizden Çıkar" ve "Şikayeti Geri Çek" burada var.
//  * YENİ bir şikayet açma burada YOK. Bir şikayet, hakkında olduğu
//    KONUŞMAYA bağlıdır (`online_game_chat_reports.online_game_id`) ve
//    admin panelindeki "Sohbeti Görüntüle" o dökümü açar. Arkadaş
//    listesinden açılan bir şikayet zorunlu olarak ESKİ bir oyuna
//    iliştirilirdi ve admin, şikayetle ilgisi olmayan bir yazışma okurdu —
//    yani yanlış bilgi. Şikayet etmek sohbetin kendisinde kalıyor.
//  * Sessize ALMA da yok (aynı gerekçenin daha zayıfı: mute zaten kişi
//    bazlı, ama onu da konuşma bağlamında vermek tutarlı).
//
// Bu yüzden ikon YALNIZCA durum VARKEN çizilir (bkz. FriendsModal) —
// panel bir "yönet/geri al" aracı, bir moderasyon menüsü değil.
import { useState } from 'react';
import { Modal } from './Modal';
import { Avatar } from './Avatar';
import { unblockUser, withdrawChatReports } from '../lib/api';
import { friendlyErrorMessage } from '../utils/errorMessage';

export interface FriendModerationTarget {
  userId: string;
  name: string;
  avatarUrl?: string | null;
  /** Engelliyse true (4 Ekim 2026'dan beri oyun id'si GEREKMİYOR: kaldırma
   *  `unblock_user` ile, engel oyundan bağımsız — bkz. `BlockedUsersModal`). */
  blocked: boolean;
  /** Aktif şikayet varsa true (geri çekme oyun id'si İSTEMİYOR). */
  reported: boolean;
}

type View = 'menu' | 'unmute-confirm' | 'withdraw-confirm' | 'done';

export function FriendModerationModal({
  target,
  onClose,
}: {
  target: FriendModerationTarget;
  onClose: (changed: boolean) => void;
}) {
  const [view, setView] = useState<View>('menu');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [doneMsg, setDoneMsg] = useState('');
  const [changed, setChanged] = useState(false);

  const blocked = target.blocked;

  async function run(action: () => Promise<void>, msg: string) {
    setBusy(true);
    setError(null);
    try {
      await action();
      setChanged(true);
      setDoneMsg(msg);
      setView('done');
    } catch (e) {
      // Sessizce yutma YOK — kullanıcı gerçekleşmemiş bir sonucu
      // "olmuş" sanmamalı (bkz. FriendsModal'ın aynı dersi).
      setError(
        friendlyErrorMessage(e, { surface: 'arkadas-moderasyon', fallback: 'İşlem başarısız oldu.' }),
      );
    } finally {
      setBusy(false);
    }
  }

  const btnNeutral =
    'btn-raised-neutral rounded-md py-2 text-xs font-bold uppercase tracking-[1px] bg-void border border-border text-text active:scale-[0.97] transition-transform disabled:opacity-50';

  return (
    <Modal title="Kişi Ayarları" onClose={() => onClose(changed)}>
      <div className="flex flex-col gap-3">
        <div className="flex items-center gap-2">
          <Avatar url={target.avatarUrl} name={target.name} size={28} />
          <p className="text-sm font-bold text-text">{target.name}</p>
        </div>

        {view === 'menu' && (
          <>
            <p className="text-xs text-muted leading-relaxed">
              {target.reported && blocked
                ? 'Bu kişiyi şikayet ettiniz ve engellediniz.'
                : target.reported
                  ? 'Bu kişiyi şikayet ettiniz; şikayetiniz açıkken kişi engelli sayılır.'
                  : 'Bu kişiyi engellediniz.'}
            </p>

            {target.reported && (
              <button type="button" disabled={busy} className={btnNeutral} onClick={() => setView('withdraw-confirm')}>
                Şikayeti Geri Çek
              </button>
            )}
            {blocked && (
              <button type="button" disabled={busy} className={btnNeutral} onClick={() => setView('unmute-confirm')}>
                Engeli Kaldır
              </button>
            )}

            <p className="text-[10px] font-mono text-muted leading-relaxed">
              Şikayet etmek, o kişiyle oynadığın Canlı oyunun mesajlaşma
              ayarlarından yapılır. Arkadaş olmadığın kişiler için Arkadaşlar
              ekranındaki "Engellediklerim" listesine bak.
            </p>
          </>
        )}

        {(view === 'unmute-confirm' || view === 'withdraw-confirm') && (
          <>
            <p className="text-sm text-text font-bold">Emin misiniz?</p>
            <p className="text-sm text-text leading-relaxed">
              {view === 'unmute-confirm'
                ? `${target.name} için engeliniz kalkacak; size tekrar oyun daveti ve arkadaşlık isteği gönderebilir, rastgele eşleşmede karşınıza çıkabilir.`
                : `${target.name} hakkındaki şikayetiniz geri çekilecek. Dilerseniz daha sonra tekrar şikayet edebilirsiniz.`}
            </p>
            <div className="flex gap-2">
              <button
                type="button"
                disabled={busy}
                className="btn-raised flex-1 rounded-md py-2 text-xs font-bold uppercase tracking-[1px] bg-accent text-white active:scale-[0.97] transition-transform disabled:opacity-50"
                onClick={() =>
                  view === 'unmute-confirm'
                    ? run(
                        () => unblockUser(target.userId),
                        'Engel kaldırıldı.',
                      )
                    : run(() => withdrawChatReports(target.userId), 'Şikayetiniz geri çekildi.')
                }
              >
                {busy ? '...' : view === 'unmute-confirm' ? 'Engeli Kaldır' : 'Geri Çek'}
              </button>
              <button type="button" disabled={busy} className={btnNeutral + ' flex-1'} onClick={() => setView('menu')}>
                Vazgeç
              </button>
            </div>
          </>
        )}

        {view === 'done' && (
          <>
            <p className="text-sm text-text leading-relaxed">{doneMsg}</p>
            <button type="button" className={btnNeutral} onClick={() => onClose(true)}>
              Tamam
            </button>
          </>
        )}

        {error && <p className="text-red text-[10px] font-mono">{error}</p>}
      </div>
    </Modal>
  );
}
