// Kelimeki — oyun kurulum ekranı: oyuncu sayısı (2/4) seçimi
import { useEffect, useState } from 'react';
import { PLAYER_COLORS } from '../game/constants';
import type { PlayerSetup } from '../game/gameReducer';
import { useAuth } from '../hooks/useAuth';
import { fetchPlayerStats } from '../lib/api';
import { hasSeenQuickStart, markQuickStartSeen } from '../utils/onboarding';
import { Avatar } from './Avatar';
import { AuthModal } from './AuthModal';
import { HelpModal } from './HelpModal';
import { PlayerBadge } from './PlayerBadge';
import { TermsModal } from './TermsModal';
import { PrivacyModal } from './PrivacyModal';

interface SetupProps {
  // showTutorial: oyun ekranı açıldığında Tutorial (HelpModal) daha önce
  // görülmediyse gösterilsin mi — App.tsx bunu oyun ekranı render'ında kullanır.
  onStart: (players: PlayerSetup[], showTutorial: boolean) => void;
}

export function Setup({ onStart }: SetupProps) {
  const { user, profile, loading } = useAuth();
  // Oturum açıldıysa 1. oyuncu her zaman hesap sahibidir.
  const accountName =
    profile?.display_name ||
    profile?.first_name ||
    (user?.email ? user.email.split('@')[0] : null);

  const [count, setCount] = useState<2 | 4>(2);

  const [showWarningPopup, setShowWarningPopup] = useState(false);
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [showHelp, setShowHelp] = useState(false);
  const [showTerms, setShowTerms] = useState(false);
  const [showPrivacy, setShowPrivacy] = useState(false);

  // "Nasıl oynanır?" linkinden elle açılırsa da Tutorial görülmüş sayılır —
  // oyun başlayınca tekrar otomatik açılmasın diye.
  const closeHelp = () => {
    markQuickStartSeen();
    setShowHelp(false);
  };

  // Toplam puan (isim yanında gösterilen) tüm oyun modlarının (2/4 kişilik)
  // toplamıdır — seçili sekmeye göre değişmez.
  const [accountTotalScore, setAccountTotalScore] = useState<number | undefined>(undefined);
  useEffect(() => {
    if (!user) {
      setAccountTotalScore(undefined);
      return;
    }
    let cancelled = false;
    Promise.all([fetchPlayerStats(2), fetchPlayerStats(4)]).then(([s2, s4]) => {
      if (cancelled) return;
      if (!s2 && !s4) {
        setAccountTotalScore(undefined);
        return;
      }
      setAccountTotalScore((s2?.total_score ?? 0) + (s4?.total_score ?? 0));
    });
    return () => {
      cancelled = true;
    };
  }, [user]);

  const doStart = () => {
    const list: PlayerSetup[] = Array.from({ length: count }, (_, i) => {
      // 1. oyuncu her zaman gerçek kişidir (giriş yapıldıysa hesap adıyla,
      // yapılmadıysa Misafir olarak). Aynı cihazda birden fazla kişi oynama
      // ihtimali göz ardı edilebilir olduğundan diğer tüm oyuncular her
      // zaman YZ'dir.
      if (i === 0) {
        return { name: accountName || 'Misafir', isAI: false };
      }
      return { name: `Yapay Zeka ${i + 1}`, isAI: true };
    });
    // Oyun ekranı açılınca Tutorial daha önce görülmediyse orada gösterilecek.
    onStart(list, !hasSeenQuickStart());
  };

  const handleStart = () => {
    if (!loading && !user) {
      setShowWarningPopup(true);
    } else {
      doStart();
    }
  };

  return (
    <>
    {showAuthModal && <AuthModal onClose={() => setShowAuthModal(false)} />}
    {showHelp && <HelpModal onClose={closeHelp} />}
    {showTerms && <TermsModal onClose={() => setShowTerms(false)} />}
    {showPrivacy && <PrivacyModal onClose={() => setShowPrivacy(false)} />}

    {showWarningPopup && (
      <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
        <div className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-4">
          <p className="text-sm text-text font-sans leading-relaxed">
            Oyunların istatistiklerini tutmak ve Sanal Lig puanları için lütfen giriş yapın.
          </p>
          <div className="flex gap-2 mt-1">
            <button
              onClick={() => { setShowWarningPopup(false); setShowAuthModal(true); }}
              className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              Giriş Yap
            </button>
            <button
              onClick={() => { setShowWarningPopup(false); doStart(); }}
              className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              Devam
            </button>
          </div>
        </div>
      </div>
    )}

    <div
      className="w-full max-w-[460px] px-4 py-6 flex flex-col gap-5"
      style={{
        backgroundImage: "url('/setup-bg-watermark.png')",
        backgroundSize: '480px auto',
        backgroundPosition: 'center 76px',
        backgroundRepeat: 'no-repeat',
      }}
    >
      <div className="text-center flex flex-col items-center gap-1 -mt-3">
        <h1 style={{ fontFamily: "'Caveat', cursive", fontSize: 52, fontWeight: 700, color: '#2563EB', letterSpacing: 4, lineHeight: 1, margin: 0 }}>
          kelimeki
        </h1>
        <svg width="100" height="8" viewBox="0 0 100 8" fill="none">
          <path d="M4 4 Q25 1 50 4 Q75 7 96 4" stroke="#2563EB" strokeWidth="2.5" strokeLinecap="round" fill="none" />
        </svg>
        <p className="text-muted text-xs font-mono mt-4">
          Kelimeler kurarak bölgeni genişlet, rakiplerini kuşat. Ama dikkat et:
          Hamlen rakibinin bölgesine temas ederse, kazandığın puanın bir
          kısmını onunla paylaşmak zorunda kalırsın. Her hamle bir strateji,
          her kelime bir mücadele.
        </p>
        <button
          onClick={() => setShowHelp(true)}
          className="mt-1 font-mono text-[11px] font-bold uppercase tracking-[1px] text-accent hover:underline active:opacity-70 transition-opacity"
        >
          Nasıl oynanır?
        </button>
      </div>

      <div className="flex flex-col gap-2">
        <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono">
          Oyuncu sayısı
        </div>
        <div className="flex gap-2">
          {([2, 4] as const).map((n) => (
            <button
              key={n}
              onClick={() => setCount(n)}
              className={[
                'flex-1 py-3 rounded-md font-sans text-sm font-bold uppercase tracking-[1px] border transition-transform active:scale-[0.97]',
                count === n
                  ? 'btn-raised bg-accent text-white border-accent'
                  : 'btn-raised-neutral bg-panel text-text border-border',
              ].join(' ')}
            >
              {n} Oyunculu
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-col gap-2.5">
        <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono">
          Oyuncular
        </div>
        {Array.from({ length: count }, (_, i) => {
          const col = PLAYER_COLORS[i];
          // 1. oyuncu giriş yapan hesaptır: kilitli isim + avatar, YZ olamaz.
          const isAccount = i === 0 && !!accountName;
          return (
            <div
              key={i}
              className="shadow-raised flex items-center gap-2.5 rounded-md px-2.5 py-2 border"
              style={{ background: col.zone, borderColor: `${col.base}55` }}
            >
              {isAccount ? (
                <Avatar
                  url={profile?.avatar_url}
                  name={accountName}
                  size={20}
                  className="shrink-0"
                />
              ) : (
                <PlayerBadge index={i} />
              )}

              {isAccount ? (
                <span className="flex-1 min-w-0 font-sans text-sm font-bold text-text truncate">
                  {accountName}
                  {accountTotalScore !== undefined && (
                    <span className="font-mono font-normal text-muted"> ({accountTotalScore})</span>
                  )}
                </span>
              ) : (
                <span className="flex-1 min-w-0 font-sans text-sm font-bold text-text truncate">
                  {i === 0 ? 'Misafir' : `Yapay Zeka ${i + 1}`}
                </span>
              )}

              <span
                className="text-[9px] font-mono uppercase tracking-[1px] shrink-0 px-1"
                style={{ color: col.base }}
              >
                {i === 0 ? 'Sen' : `YZ${i + 1}`}
              </span>
            </div>
          );
        })}
      </div>

      <button
        onClick={handleStart}
        className="btn-raised py-3.5 rounded-md font-sans text-sm font-bold uppercase tracking-[2px] bg-accent text-white active:scale-[0.97] transition-transform"
      >
        Oyunu Başlat
      </button>

      <div className="flex items-center justify-center gap-2 text-[10px] font-mono text-muted">
        <button onClick={() => setShowTerms(true)} className="hover:underline active:opacity-70 transition-opacity">
          Kullanım Koşulları
        </button>
        <span>·</span>
        <button onClick={() => setShowPrivacy(true)} className="hover:underline active:opacity-70 transition-opacity">
          Gizlilik Politikası
        </button>
      </div>
    </div>
    </>
  );
}
