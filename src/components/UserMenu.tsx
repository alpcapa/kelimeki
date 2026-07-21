// Kelimeki — sağ üst köşedeki hesap menüsü.
// Oturum yoksa "Giriş / Kayıt" düğmesi; oturum varsa profil küçük resmi ve
// açılır menü (Hesap Ayarları, Skor Kartı, Çıkış) gösterir.
// Yalnızca Supabase yapılandırıldığında görünür.
import { useEffect, useRef, useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { signOut, fetchMyLeaderboardRank } from '../lib/api';
import type { MyLeaderboardRank } from '../lib/database.types';
import { Avatar } from './Avatar';
import { AuthModal } from './AuthModal';
import { ScoreCard } from './ScoreCard';
import { AccountSettingsModal } from './AccountSettingsModal';
import { HelpModal } from './HelpModal';
import { Leaderboard } from './Leaderboard';
import { AdminDashboard } from './AdminDashboard';

type ActiveModal = 'auth' | 'account' | 'score' | 'help' | 'league' | 'admin' | null;

export function UserMenu() {
  const { user, profile, configured, loading, profileLoading } = useAuth();
  const [open, setOpen] = useState(false);
  const [modal, setModal] = useState<ActiveModal>(null);
  const [myRank, setMyRank] = useState<MyLeaderboardRank | null>(null);
  const wrapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!user) return;
    fetchMyLeaderboardRank(user.id).then(setMyRank);
  }, [user]);

  // Dışarı tıklayınca / Esc ile menüyü kapat.
  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target as Node))
        setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('mousedown', onDown);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('mousedown', onDown);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);

  if (!configured) return null;

  // Profil henüz (ilk kez) çekilmediyse e-postaya düşmüyoruz — aksi halde
  // profil gelene kadar bir anlık e-posta bazlı baş harflere (ör. "AC")
  // düşüp hemen gerçek takma adın baş harfleriyle (ör. "AL") değişiyordu.
  const name =
    profile?.display_name ||
    profile?.username ||
    [profile?.first_name, profile?.last_name].filter(Boolean).join(' ').trim() ||
    (user?.email && !profileLoading ? user.email : null) ||
    'Hesabım';
  const identityLoading = loading || (!!user && profileLoading);

  // ── Oturum yok: Giriş / Kayıt düğmesi ──────────────────────────────────────
  if (!loading && !user) {
    return (
      <>
        <button
          onClick={() => setModal('auth')}
          className="btn-raised font-mono text-[11px] uppercase tracking-[0.5px] px-2 py-3 rounded-md border bg-accent border-accent text-white font-bold leading-none active:scale-[0.97] transition-transform"
        >
          Giriş
        </button>
        {modal === 'auth' && <AuthModal onClose={() => setModal(null)} />}
      </>
    );
  }

  const item =
    'w-full flex items-center gap-2.5 px-3 py-2.5 text-left text-xs font-mono text-text hover:bg-bg transition-colors';

  return (
    <>
      <div className="relative" ref={wrapRef}>
        <button
          onClick={() => setOpen((v) => !v)}
          aria-label="Hesap menüsü"
          aria-expanded={open}
          className="rounded-full active:scale-95 transition-transform ring-offset-2 focus:outline-none"
        >
          {identityLoading ? (
            <span className="w-8 h-8 rounded-full bg-panel border border-border flex items-center justify-center text-muted text-[10px] font-mono">
              …
            </span>
          ) : (
            <Avatar url={profile?.avatar_url} name={name} size={32} />
          )}
        </button>

        {open && (
          <div className="absolute right-0 top-full mt-2 w-56 bg-panel border border-[#B8C2D1] rounded-xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] overflow-hidden z-[160]">
            <div className="flex items-center gap-2.5 px-3 py-3 border-b border-border">
              <Avatar url={profile?.avatar_url} name={name} size={36} />
              <div className="min-w-0">
                <div className="text-sm font-bold text-text truncate">{name}</div>
                <button
                  type="button"
                  onClick={() => {
                    setModal('league');
                    setOpen(false);
                  }}
                  className="flex items-center gap-1 text-[10px] font-mono text-left truncate active:opacity-70 transition-opacity"
                >
                  <span className="text-muted truncate">
                    {myRank
                      ? `#${myRank.rank} · ${myRank.total_score.toLocaleString('tr-TR')} puan`
                      : 'Sanal Lig'}
                  </span>
                  <span className="w-3 h-3 rounded-full border border-accent text-accent flex items-center justify-center text-[8px] leading-none font-bold shrink-0">
                    ?
                  </span>
                </button>
              </div>
            </div>

            <button
              className={item}
              onClick={() => {
                setModal('account');
                setOpen(false);
              }}
            >
              <span aria-hidden>⚙️</span> Hesap Ayarları
            </button>
            <button
              className={item}
              onClick={() => {
                setModal('score');
                setOpen(false);
              }}
            >
              <span aria-hidden>📊</span> Skor Kartı
            </button>
            <button
              className={item}
              onClick={() => {
                setModal('help');
                setOpen(false);
              }}
            >
              <span aria-hidden>❓</span> Nasıl Oynanır?
            </button>

            {profile?.is_admin && (
              <button
                className={`${item} border-t border-border`}
                onClick={() => {
                  setModal('admin');
                  setOpen(false);
                }}
              >
                <span aria-hidden>🛡️</span> Admin Paneli
              </button>
            )}

            <button
              className={`${item} border-t border-border hover:text-red`}
              onClick={async () => {
                setOpen(false);
                await signOut();
              }}
            >
              <span aria-hidden>↩</span> Çıkış Yap
            </button>
          </div>
        )}
      </div>

      {modal === 'account' && (
        <AccountSettingsModal onClose={() => setModal(null)} />
      )}
      {modal === 'score' && <ScoreCard onClose={() => setModal(null)} />}
      {modal === 'league' && <Leaderboard onClose={() => setModal(null)} />}
      {modal === 'help' && (
        <HelpModal onClose={() => setModal(null)} />
      )}
      {modal === 'admin' && <AdminDashboard onClose={() => setModal(null)} />}
    </>
  );
}
