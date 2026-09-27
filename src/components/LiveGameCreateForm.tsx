// Kelimeki — Canlı oyun kurulumu: arkadaş seçip davet gönderme (Faz 2, 4. adım).
// Kural (bkz. CLAUDE.md / online_game_ai_slot_rule migration'ı): 2 kişilikte
// Yapay Zeka'ya hiç izin yok (iki koltuk da insan); 4 kişilikte yalnızca
// 4. koltuk Yapay Zeka olabilir, en az 2 arkadaş seçilmesi zorunlu.
//
// 27 Eylül 2026 (ROADMAP #41, kararlar 11-12): seçilen rakipler KOLTUK
// KARTLARI olarak oyuncu renginde görünür; 4 kişide 2 arkadaş seçiliyken boş
// 4. koltuk ekranda "Yapay Zeka" olarak durur. Bu yüzden eski "4. koltuk
// Yapay Zeka ile doldurulacak, tamam mı?" onay penceresi ve onun "Hayır"ından
// doğan kalıcı Yapay Zeka satırı KALKTI — koltuk zaten görünüyor. "Arkadaşını
// davet et" (davet linki) artık arama kutusunun hemen altında.
import { useEffect, useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { createOnlineGame, fetchFriends } from '../lib/api';
import type { FriendRow, OnlineGameSlot } from '../lib/database.types';
import { trLower } from '../utils/turkish';
import { Avatar } from './Avatar';
import { FriendsModal } from './FriendsModal';
import { RankSeal } from './RankSeal';
import { useRankScores } from '../hooks/useRankScores';
import { friendlyErrorMessage } from '../utils/errorMessage';
import { PLAYER_COLORS } from '../game/constants';

interface LiveGameCreateFormProps {
  onCancel: () => void;
  onCreated: () => void;
}

const toggleBtnCls = (active: boolean) =>
  [
    'flex-1 py-3 rounded-md font-sans text-sm font-bold uppercase tracking-[1px] border transition-transform active:scale-[0.97]',
    active
      ? 'btn-raised bg-accent text-white border-accent'
      : 'btn-raised-neutral bg-panel text-text border-border',
  ].join(' ');

function CheckMark({ checked }: { checked: boolean }) {
  return (
    <span
      className={[
        'w-4 h-4 rounded border-2 shrink-0 flex items-center justify-center text-[10px] leading-none',
        checked ? 'bg-accent border-accent text-white' : 'bg-bg border-muted text-transparent',
      ].join(' ')}
    >
      ✓
    </span>
  );
}

export function LiveGameCreateForm({ onCancel, onCreated }: LiveGameCreateFormProps) {
  const { user } = useAuth();
  const [playerCount, setPlayerCount] = useState<2 | 4>(2);
  const [friends, setFriends] = useState<FriendRow[] | null>(null);
  // Arkadaş seçicideki isimlerin rütbe mührü — tek toplu çekim.
  const rankTierOf = useRankScores((friends ?? []).map((f) => f.friend_id));
  const [selected, setSelected] = useState<string[]>([]);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showFriendsModal, setShowFriendsModal] = useState(false);
  const [query, setQuery] = useState('');
  // Davet gerçekten gönderildiğinde (3 Ağustos 2026, kullanıcı isteği) form
  // sessizce kapanıp listeye dönmek yerine önce bir onay ekranı gösterir —
  // `FriendSuggestModal`'ın "Arkadaşlık davetiniz iletilmiştir." ve
  // `ChatSettingsModal`'ın "Şikayetiniz iletildi." ekranlarıyla aynı desen.
  // Davet edilenlerin isimleri gönderim anında dondurulur: `onCreated` ile
  // listeye dönülene kadar `selected`/`friends` değişebilir.
  const [sentTo, setSentTo] = useState<{ names: string[]; withAi: boolean } | null>(null);

  const reloadFriends = () => {
    fetchFriends().then(setFriends);
  };

  // Hesap değişiminde YENİDEN çekilmeli: bu bileşen bir modal değil tam bir
  // görünüm ve `LiveGamesTab`'ın `creating` dalı `!user` kontrolünden ÖNCE
  // döndüğünden çıkış→giriş döngüsünü mount'ta kalarak atlatabiliyor — mount'a
  // bağlı bir çekim, yeni hesaba ÖNCEKİ hesabın arkadaş listesini gösteriyordu
  // (5 Ağustos 2026: T2 kendi listesinde kendini gördü). Bağımlılık `user`
  // REFERANSI değil `user?.id`: `useAuth` her onAuthStateChange olayında
  // (TOKEN_REFRESHED dahil) yeni bir User nesnesi set ediyor, referansa
  // bağlansa saatte bir gereksiz yere yeniden çekerdi.
  useEffect(() => {
    reloadFriends();
  }, [user?.id]);

  // 2↔4 arası kural tamamen farklı (YZ izni yok / var) — sekme değişince
  // seçimleri sıfırlıyoruz ki eski bir seçim yeni kuralda geçersiz kalmasın.
  useEffect(() => {
    setSelected([]);
  }, [playerCount]);

  const toggleFriend = (friendId: string) => {
    if (playerCount === 2) {
      setSelected((s) => (s.includes(friendId) ? [] : [friendId]));
      return;
    }
    setSelected((s) => {
      if (s.includes(friendId)) return s.filter((id) => id !== friendId);
      if (s.length >= 3) return s;
      return [...s, friendId];
    });
  };

  const canSubmit = playerCount === 2 ? selected.length === 1 : selected.length >= 2;

  const submit = async (withAiLastSlot: boolean) => {
    if (!user) return;
    setBusy(true);
    setError(null);
    try {
      const slots: OnlineGameSlot[] = [
        { type: 'human', user_id: user.id },
        ...selected.map((id) => ({ type: 'human' as const, user_id: id })),
        ...(withAiLastSlot ? [{ type: 'ai' as const }] : []),
      ];
      await createOnlineGame(playerCount, slots);
      setSentTo({
        names: selected.map(
          (id) => friends?.find((f) => f.friend_id === id)?.name ?? 'Bir arkadaşın',
        ),
        withAi: withAiLastSlot,
      });
    } catch (err) {
      setError(
        friendlyErrorMessage(err, { surface: 'canli-davet', fallback: 'Davet gönderilemedi.' }),
      );
    } finally {
      setBusy(false);
    }
  };

  // 4 kişide 2 arkadaş = 4. koltuk Yapay Zeka; ekrandaki koltuk kartı bunu
  // zaten gösteriyor, ayrıca sorulmaz (27 Eylül 2026, ROADMAP #41 karar 12).
  const handleSubmit = () => {
    void submit(playerCount === 4 && selected.length === 2);
  };

  if (sentTo) {
    return (
      <div className="w-full flex flex-col items-center gap-3 py-6 text-center">
        <span
          className="w-16 h-16 rounded-full bg-[#D6F3E1] border-2 border-[#16A34A] text-[#16A34A] flex items-center justify-center text-3xl font-bold leading-none"
          aria-hidden
        >
          ✓
        </span>
        <h2 className="text-2xl font-bold text-text leading-tight" style={{ margin: 0 }}>
          Davetin gönderildi
        </h2>
        <p className="text-sm text-muted leading-relaxed" style={{ margin: 0 }}>
          {sentTo.names.join(', ')} kabul edince oyun başlar ve ilk sıra sende olur.
          {sentTo.withAi && ' 4. koltuk Yapay Zeka.'}
        </p>
        <p className="text-xs text-muted font-mono leading-relaxed" style={{ margin: 0 }}>
          Davet 7 gün içinde kabul edilmezse iptal olur. Biri reddederse oyun kurulmaz.
        </p>
        <button
          onClick={onCreated}
          className="mt-2 btn-raised btn-raised-orange min-h-[52px] px-8 rounded-md bg-orange text-white text-sm font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
        >
          Oyunlarıma git
        </button>
      </div>
    );
  }

  const byId = (id: string) => friends?.find((f) => f.friend_id === id);
  const seatCount = playerCount - 1;

  return (
    <div className="w-full flex flex-col gap-5">
      {showFriendsModal && (
        <FriendsModal
          initialTab="search"
          onClose={() => {
            setShowFriendsModal(false);
            reloadFriends();
          }}
        />
      )}

      <div className="flex flex-col gap-2">
        <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono">
          Oyuncu Sayısı
        </div>
        <div className="flex gap-2">
          {([2, 4] as const).map((n) => (
            <button key={n} onClick={() => setPlayerCount(n)} className={toggleBtnCls(playerCount === n)}>
              {n} Kişi
            </button>
          ))}
        </div>
      </div>

      {/* Koltuklar (27 Eylül 2026, ROADMAP #41 karar 12): seçilen rakip,
          oyunda oturacağı köşenin renginde — `PLAYER_COLORS[i + 1]` (0 sensin).
          Avatar uygulamanın kendi `Avatar`ı (fotoğraf → iki harf). */}
      <div className="flex flex-col gap-2">
        <div className="flex items-baseline justify-between gap-2">
          <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono">
            {playerCount === 2 ? 'Rakibin' : `Rakiplerin · ${selected.length}/3`}
          </div>
          {playerCount === 4 && (
            <span className="text-[10px] text-muted font-mono">Boş 4. koltuk yapay zeka olur</span>
          )}
        </div>
        <div className={playerCount === 2 ? 'flex flex-col' : 'grid grid-cols-3 gap-2'}>
          {Array.from({ length: seatCount }, (_, i) => {
            const col = PLAYER_COLORS[i + 1];
            const f = selected[i] ? byId(selected[i]) : undefined;
            const ai = playerCount === 4 && i === 2 && selected.length === 2;
            const yatay = playerCount === 2;
            if (f) {
              return (
                <div
                  key={i}
                  className={[
                    'relative flex items-center rounded-xl border',
                    yatay ? 'gap-3 px-3 py-2.5' : 'flex-col gap-1.5 px-1.5 pt-3 pb-2.5',
                  ].join(' ')}
                  style={{ background: col.tint, borderColor: col.base }}
                >
                  <Avatar url={f.avatar_url} name={f.name} size={36} />
                  <span
                    className={['font-sans text-sm font-bold truncate max-w-full', yatay ? 'flex-1 min-w-0' : 'text-xs'].join(' ')}
                    style={{ color: col.text }}
                  >
                    {f.name}
                  </span>
                  <button
                    type="button"
                    onClick={() => toggleFriend(f.friend_id)}
                    aria-label={`${f.name} koltuğunu boşalt`}
                    className={[
                      'w-7 h-7 flex items-center justify-center text-sm tap-expand',
                      yatay ? 'relative' : 'absolute top-0.5 right-0.5',
                    ].join(' ')}
                    style={{ color: col.text }}
                  >
                    ✕
                  </button>
                </div>
              );
            }
            return (
              <div
                key={i}
                className={[
                  'flex items-center rounded-xl border-[1.5px] border-dashed border-[#C7D0DC] bg-bg',
                  yatay ? 'gap-3 px-3 py-2.5' : 'flex-col justify-center gap-1.5 px-1.5 pt-3 pb-2.5',
                ].join(' ')}
              >
                <span
                  className="w-9 h-9 rounded-full bg-void border border-border flex items-center justify-center text-lg shrink-0"
                  aria-hidden
                >
                  {ai ? '🤖' : '+'}
                </span>
                <span className="font-sans text-xs font-bold text-muted">
                  {ai ? 'Yapay Zeka' : yatay ? 'Aşağıdan bir arkadaşını seç' : 'Boş koltuk'}
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Gönder/Vazgeç koltukların HEMEN altında, akışta (27 Eylül 2026).
          Eskiden `createPortal` ile ekranın altına `position: fixed`
          sabitlenmiş bir şeritti; kullanıcının iPad ekran görüntüsünde
          tarayıcının yüzen alt çubuğunun arkasına YARI girmişti — Setup'ın
          yapışkan şeridiyle aynı sorun (`actionButton.ts`). Burada seçilen
          rakip kartı ile düğme aynı ekranda. */}
      <div className="flex flex-col gap-2">
        <div className="flex gap-2">
          <button
            onClick={handleSubmit}
            disabled={!canSubmit || busy}
            className="flex-[1.5] btn-raised btn-raised-orange min-h-[52px] rounded-md font-sans text-base font-bold uppercase tracking-[1px] bg-orange text-white active:scale-[0.97] transition-transform disabled:opacity-35 disabled:cursor-not-allowed"
          >
            {busy ? 'Gönderiliyor…' : 'Davet Gönder'}
          </button>
          <button
            onClick={onCancel}
            disabled={busy}
            className="flex-1 btn-raised-neutral min-h-[52px] rounded-md font-sans text-sm font-bold uppercase tracking-[1px] bg-void border border-border text-text active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            Vazgeç
          </button>
        </div>
        <p className="text-center text-[11px] text-muted font-mono" style={{ margin: 0 }}>
          {playerCount === 2 ? 'Arkadaşın' : 'Arkadaşların'} kabul edince oyun başlar · her hamle için 48 saat
        </p>
        {error && <p className="text-xs text-red font-mono text-center" style={{ margin: 0 }}>{error}</p>}
      </div>

      <div className="flex flex-col gap-2">
        <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono">
          Arkadaşların
        </div>
        {friends === null ? (
          <p className="text-muted text-xs font-mono py-4 text-center">Yükleniyor…</p>
        ) : friends.length === 0 ? (
          <div className="flex flex-col items-center gap-2.5 py-4">
            <p className="text-muted text-xs font-mono text-center">Henüz hiç arkadaşın yok.</p>
            <button
              type="button"
              onClick={() => setShowFriendsModal(true)}
              className="btn-raised bg-accent text-white rounded-md py-2 px-4 text-[11px] font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              Arkadaş Ekle / Davet Et
            </button>
          </div>
        ) : (
          <div className="flex flex-col gap-1.5">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="İsim ya da takma ad ara…"
              aria-label="Arkadaş ara"
              className="w-full bg-bg border border-border rounded-md px-3 py-2 text-sm text-text outline-none focus:border-accent transition-colors"
            />
            {/* Arama kutusunun HEMEN altında (27 Eylül 2026, kullanıcı:
                *"arkadaşlar listesinin üstüne arkadaşını davet et butonu
                olsun. Aramanın altına"*). Eskiden alttaki sabit şeritte
                "Arkadaş Ekle" satırıydı; açtığı pencere aynı (davet linki +
                üye arama). */}
            <button
              type="button"
              onClick={() => setShowFriendsModal(true)}
              className="flex items-center justify-center gap-2 min-h-[44px] rounded-md border-[1.5px] border-dashed border-accent bg-[#EEF4FF] text-accent text-[13px] font-bold uppercase tracking-[1px] active:scale-[0.99] transition-transform"
            >
              <span aria-hidden className="text-base leading-none">+</span> Arkadaşını davet et
            </button>
            <div className="flex flex-col gap-1.5 max-h-[280px] overflow-y-auto pr-0.5">
              {(() => {
                const filtered = friends.filter((f) => trLower(f.name).includes(trLower(query.trim())));
                if (filtered.length === 0) {
                  return (
                    <p className="text-muted text-xs font-mono py-4 text-center">Kimse bulunamadı.</p>
                  );
                }
                return filtered.map((f) => {
                  const isSelected = selected.includes(f.friend_id);
                  return (
                    <button
                      key={f.friend_id}
                      type="button"
                      onClick={() => toggleFriend(f.friend_id)}
                      aria-pressed={isSelected}
                      className="shadow-raised flex items-center gap-2.5 rounded-md px-2.5 py-2 border border-border bg-panel text-left transition-transform active:scale-[0.99] shrink-0"
                    >
                      <Avatar url={f.avatar_url} name={f.name} size={28} />
                      <span className="flex-1 min-w-0 flex items-center gap-1">
                        <span className="min-w-0 text-sm font-bold text-text truncate">{f.name}</span>
                        {rankTierOf(f.friend_id) && (
                          <RankSeal tier={rankTierOf(f.friend_id)!} size={18} className="shrink-0" />
                        )}
                      </span>
                      <CheckMark checked={isSelected} />
                    </button>
                  );
                });
              })()}
            </div>
          </div>
        )}
      </div>

    </div>
  );
}
