// Kelimeki — Canlı oyun kurulumu: arkadaş seçip davet gönderme (Faz 2, 4. adım).
// Kural (bkz. CLAUDE.md / online_game_ai_slot_rule migration'ı): 2 kişilikte
// Yapay Zeka'ya hiç izin yok (iki koltuk da insan); 4 kişilikte yalnızca
// 4. koltuk Yapay Zeka olabilir, en az 2 arkadaş seçilmesi zorunlu.
//
// 3 Ekim 2026 — RASTGELE OYUNCU (docs/decisions/random-opponent.md §3): listenin
// en üstünde "?" avatarlı bir satır; her dokunuş bir boş koltuğu "?" yapar ve
// arkadaşlarla karışır (esnek kadro). En az bir "?" varsa `createRandomGame`
// (açık ilan), yoksa AŞAĞIDAKİ bugünkü `createOnlineGame` yolu AYNEN. Seçim
// kuralları saf fonksiyonda: `utils/randomGames.ts` (`verify-random-games`).
// 4 kişide tam 2 seçimde 4. koltuk Yapay Zeka (rastgele kadroda da).
//
// 27 Eylül 2026 (ROADMAP #41, kararlar 11-12): seçilen rakipler KOLTUK
// KARTLARI olarak oyuncu renginde görünür; 4 kişide 2 arkadaş seçiliyken boş
// 4. koltuk ekranda "Yapay Zeka" olarak durur. Bu yüzden eski "4. koltuk
// Yapay Zeka ile doldurulacak, tamam mı?" onay penceresi ve onun "Hayır"ından
// doğan kalıcı Yapay Zeka satırı KALKTI — koltuk zaten görünüyor. "Arkadaşını
// davet et" (davet linki) artık arama kutusunun hemen altında.
import { useEffect, useRef, useState } from 'react';
import { ScrollArea } from './ScrollArea';
import { useAuth } from '../hooks/useAuth';
import {
  createOnlineGame,
  createRandomGame,
  fetchFrequentOpponents,
  fetchFriendRelation,
  fetchFriends,
  removeFriend,
  respondFriendRequest,
  sendFriendRequest,
} from '../lib/api';
import { usePlayerDirectory } from '../hooks/usePlayerDirectory';
import { useInviteShare } from '../hooks/useInviteShare';
import { InviteShareFallback } from './InviteShareFallback';
import type { FriendRow, FriendSearchResult, OnlineGameSlot } from '../lib/database.types';
import { trLower } from '../utils/turkish';
import { Avatar } from './Avatar';
import { Pill } from './FriendsModal';
import { PlayerScoreCard, type PlayerSummary } from './PlayerScoreCard';
import { RankSeal } from './RankSeal';
import { useRankScores } from '../hooks/useRankScores';
import { friendlyErrorMessage } from '../utils/errorMessage';
import { PLAYER_COLORS } from '../game/constants';
import {
  RANDOM_SEAT,
  addRandomSeat,
  aiLastSeat,
  buildRandomSlots,
  canSubmitSeats,
  createdNotice,
  randomSeatCount,
  removeSeatAt,
  toggleFriendSeat,
  usesRandomSeat,
} from '../utils/randomGames';

interface LiveGameCreateFormProps {
  onCancel: () => void;
  onCreated: () => void;
  /** Arkadaşlar penceresinin OYNA'sından gelince: o arkadaş seçili açılır
   * (`utils/liveGameRequest.ts`, 27 Eylül 2026). */
  initialFriendId?: string;
  initialPlayerCount?: 2 | 4;
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

export function LiveGameCreateForm({
  onCancel,
  onCreated,
  initialFriendId,
  initialPlayerCount,
}: LiveGameCreateFormProps) {
  const { user, profile } = useAuth();
  const [playerCount, setPlayerCount] = useState<2 | 4>(initialPlayerCount ?? 2);
  const [friends, setFriends] = useState<FriendRow[] | null>(null);
  const [selected, setSelected] = useState<string[]>(initialFriendId ? [initialFriendId] : []);
  // Sıfırlama yalnızca sayı GERÇEKTEN değişince — mount'ta (StrictMode'un
  // çift koşusu dahil) koşarsa OYNA'dan gelen ön seçim silinirdi.
  const oncekiSayiRef = useRef(playerCount);
  // Boş koltuğa (+) dokununca aşağıdaki arkadaş listesine kaydırılır
  // (27 Eylül 2026, kullanıcı isteği). Odak VERİLMEZ: arama kutusuna odak
  // telefonda klavyeyi açıp listeyi örterdi.
  const listeRef = useRef<HTMLDivElement>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  // "Tüm oyuncular" görünümü (arkadaş olmayana istek buradan) — arama bu
  // görünümde sunucuda, arkadaş görünümünde yerel süzgeç.
  const [showAll, setShowAll] = useState(false);
  const dir = usePlayerDirectory(showAll ? query : '', showAll);
  const [busyId, setBusyId] = useState<string | null>(null);
  // İsimlerin rütbe mührü — tek toplu çekim (tüm oyuncular dahil).
  const rankTierOf = useRankScores([
    ...(friends ?? []).map((f) => f.friend_id),
    ...(dir.allUsers ?? []).map((u) => u.id),
    ...dir.results.map((u) => u.id),
  ]);
  // Davet gerçekten gönderildiğinde (3 Ağustos 2026, kullanıcı isteği) form
  // sessizce kapanıp listeye dönmek yerine önce bir onay ekranı gösterir —
  // `FriendSuggestModal`'ın "Arkadaşlık davetiniz iletilmiştir." ve
  // `ChatSettingsModal`'ın "Şikayetiniz iletildi." ekranlarıyla aynı desen.
  // Davet edilenlerin isimleri gönderim anında dondurulur: `onCreated` ile
  // listeye dönülene kadar `selected`/`friends` değişebilir.
  const [sentTo, setSentTo] = useState<{
    names: string[];
    withAi: boolean;
    /** Rastgele kadro: sunucunun sonucuna göre başlık/metin (`createdNotice`). */
    random?: { title: string; body: string };
  } | null>(null);

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

  // "Sık oynadıkların" şeridi (27 Eylül 2026, ROADMAP #41) — yalnızca sıra;
  // ad/avatar arkadaş listesinden. Hesap değişince yeniden (`user?.id`).
  const [frequentIds, setFrequentIds] = useState<string[]>([]);
  // Az oynamış (ya da hiç oynamamış) kullanıcıda şeridin boş yerleri RASTGELE
  // arkadaşlarla dolar (kullanıcı isteği). Tohum form başına bir kez: her
  // render'da karışsa avatarlar dokunurken yer değiştirirdi.
  const karistirmaTohumu = useRef(Math.random());
  useEffect(() => {
    let iptal = false;
    void fetchFrequentOpponents(5).then((ids) => {
      if (!iptal) setFrequentIds(ids);
    });
    return () => {
      iptal = true;
    };
  }, [user?.id]);

  // "Arkadaşını davet et" → DOĞRUDAN paylaşım (`useInviteShare`).
  const invite = useInviteShare();

  // 2↔4 arası kural tamamen farklı (YZ izni yok / var) — sekme değişince
  // seçimleri sıfırlıyoruz ki eski bir seçim yeni kuralda geçersiz kalmasın.
  useEffect(() => {
    if (oncekiSayiRef.current === playerCount) return;
    oncekiSayiRef.current = playerCount;
    setSelected([]);
  }, [playerCount]);

  const toggleFriend = (friendId: string) => {
    setSelected((s) => toggleFriendSeat(s, friendId, playerCount));
  };
  // "Rastgele Oyuncu" satırı: her dokunuş bir boş koltuğu "?" yapar.
  const addRandom = () => setSelected((s) => addRandomSeat(s, playerCount));
  const randomCount = randomSeatCount(selected);

  // Arkadaşlık isteği — Arkadaşlar penceresindekiyle aynı, onaysız tek
  // dokunuş. Kabul edilen (ya da karşılıklı isteğe dönen) kişi arkadaş
  // listesine girer ve hemen seçilebilir.
  const iliskiIslemi = async (id: string, is: () => Promise<FriendSearchResult['relation']>) => {
    setBusyId(id);
    try {
      const yeni = await is();
      dir.patchRelation(id, yeni);
      if (yeni === 'accepted') reloadFriends();
    } catch (err) {
      console.error('[Kelimeki] arkadaşlık işlemi hatası:', err);
    } finally {
      setBusyId(null);
    }
  };
  const handleSend = (id: string) =>
    iliskiIslemi(id, async () => ((await sendFriendRequest(id)) === 'accepted' ? 'accepted' : 'pending_outgoing'));
  const handleAccept = (id: string) =>
    iliskiIslemi(id, async () => {
      await respondFriendRequest(id, true);
      return 'accepted';
    });
  const handleCancel = (id: string) =>
    iliskiIslemi(id, async () => {
      await removeFriend(id);
      return null;
    });

  // "Tüm oyuncular"da arkadaş OLMAYAN kişiye dokununca skor kartı açılır
  // (29 Eylül 2026, kullanıcı isteği) — arkadaş satırı dokununca oyuna
  // seçtiği için orada kart YOK. Kart kapanınca ilişki yeniden okunur:
  // kartın içinden "Ekle"/"Kabul et" yapılmış olabilir (Arkadaşlar
  // penceresindeki `closeSelectedFriend` ile aynı).
  const [kartKisi, setKartKisi] = useState<PlayerSummary | null>(null);
  const kartiKapat = () => {
    const id = kartKisi?.id;
    setKartKisi(null);
    if (!id) return;
    void fetchFriendRelation(id).then((r) => {
      dir.patchRelation(id, r);
      if (r === 'accepted') reloadFriends();
    });
  };

  const canSubmit = canSubmitSeats(selected, playerCount);

  const submit = async (withAiLastSlot: boolean) => {
    if (!user) return;
    setBusy(true);
    setError(null);
    try {
      const names = selected
        .filter((id) => id !== RANDOM_SEAT)
        .map((id) => friends?.find((f) => f.friend_id === id)?.name ?? 'Bir arkadaşın');
      if (usesRandomSeat(selected)) {
        // En az bir "?" → açık ilan (ya da uygun ilan varsa ona katılma; karar
        // sunucuda, dönüşteki `joined`).
        const sonuc = await createRandomGame(playerCount, buildRandomSlots(user.id, selected, playerCount));
        setSentTo({ names, withAi: withAiLastSlot, random: createdNotice(sonuc) });
        return;
      }
      const slots: OnlineGameSlot[] = [
        { type: 'human', user_id: user.id },
        ...selected.map((id) => ({ type: 'human' as const, user_id: id })),
        ...(withAiLastSlot ? [{ type: 'ai' as const }] : []),
      ];
      await createOnlineGame(playerCount, slots);
      setSentTo({ names, withAi: withAiLastSlot });
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
    void submit(aiLastSeat(selected, playerCount));
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
          {sentTo.random ? sentTo.random.title : 'Davetin gönderildi'}
        </h2>
        {sentTo.random ? (
          <>
            <p className="text-sm text-muted leading-relaxed" style={{ margin: 0 }}>
              {sentTo.random.body}
            </p>
            {(sentTo.names.length > 0 || sentTo.withAi) && (
              <p className="text-xs text-muted font-mono leading-relaxed" style={{ margin: 0 }}>
                {sentTo.names.length > 0 && `Davet gönderilen: ${sentTo.names.join(', ')}. `}
                {sentTo.withAi && '4. koltuk Yapay Zeka.'}
              </p>
            )}
          </>
        ) : (
          <>
            <p className="text-sm text-muted leading-relaxed" style={{ margin: 0 }}>
              {sentTo.names.join(', ')} kabul edince oyun başlar ve ilk sıra sende olur.
              {sentTo.withAi && ' 4. koltuk Yapay Zeka.'}
            </p>
            <p className="text-xs text-muted font-mono leading-relaxed" style={{ margin: 0 }}>
              Davet 7 gün içinde kabul edilmezse iptal olur. Biri reddederse oyun kurulmaz.
            </p>
          </>
        )}
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

  // RASTGELE OYUNCU (3-4 Ekim 2026, kullanıcı: "diğer arkadaşlar gibi listenin en
  // üstüne, ayrı bir bölümde değil"): arkadaş satırlarıyla AYNI listenin (ScrollArea)
  // İLK satırı — aramadan MUAF (süzgeç yalnızca arkadaşlara uygulanır), "Tüm
  // oyuncular" görünümünde ve hiç arkadaşı olmayanda da hep görünür. Her dokunuş
  // bir boş koltuğu "?" yapar; seçilen sayısı ×N.
  const randomRow = (
    <button
      type="button"
      onClick={addRandom}
      aria-label={`Rastgele Oyuncu — boş koltuğa ekle${randomCount > 0 ? ` (${randomCount} seçili)` : ''}`}
      className="shadow-raised flex items-center gap-2.5 rounded-md px-2.5 py-2 border border-border bg-panel text-left transition-transform active:scale-[0.99] shrink-0"
    >
      <span
        className="w-7 h-7 rounded-full bg-bg border-[1.5px] border-dashed border-muted text-muted font-bold flex items-center justify-center text-base shrink-0"
        aria-hidden
      >
        ?
      </span>
      <span className="flex-1 min-w-0 flex flex-col">
        <span className="text-sm font-bold text-text truncate">Rastgele Oyuncu</span>
        <span className="text-xs text-muted truncate">Bunu seçerseniz rasgele oyun açarsınız.</span>
      </span>
      {randomCount > 0 ? (
        <span className="font-mono text-xs font-bold text-accent min-w-[20px] text-right" aria-hidden>
          ×{randomCount}
        </span>
      ) : (
        <CheckMark checked={false} />
      )}
    </button>
  );

  return (
    <div className="w-full flex flex-col gap-5">
      <div className="flex flex-col gap-2">
        <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
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

      {/* Koltuklar (27 Eylül 2026, ROADMAP #41 karar 12; 2 Ekim 2026'da
          kullanıcı isteğiyle yeniden): 1. koltuk HER ZAMAN sensin, rakipler
          oyunda oturacakları köşenin renginde (`PLAYER_COLORS[koltuk]`).
          2 kişide alt alta, 4 kişide 2×2 (1-2 üstte, 3-4 altta).
          ⚠ Her kart aynı iskelet: avatar · isim (`truncate`, "…") · numara
          yuvası · ✕ yuvası. Numara ve ✕ AKIŞTA ve sabit genişlikte —
          ✕'i olmayan kartta (sen, boş, Yapay Zeka) yuva boş durur. Böylece
          (kullanıcı) "isim numaranın üzerine binmez" ve "numaralar her
          durumda hizalı". Port ikizi: `live_game_create_form.dart`. */}
      <div className="flex flex-col gap-2">
        <div className="flex items-baseline justify-between gap-2">
          <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
            {playerCount === 2 ? 'Oyuncular' : `Oyuncular · ${selected.length + 1}/4`}
          </div>
          {playerCount === 4 && (
            <span className="text-[10px] text-muted font-mono">Boş 4. koltuk yapay zeka olur</span>
          )}
        </div>
        <div className={playerCount === 2 ? 'flex flex-col gap-2' : 'grid grid-cols-2 gap-2'}>
          {Array.from({ length: playerCount }, (_, koltuk) => {
            const col = PLAYER_COLORS[koltuk];
            const yatay = playerCount === 2;
            const ben = koltuk === 0;
            const secim = ben ? undefined : selected[koltuk - 1];
            const rastgele = secim === RANDOM_SEAT;
            const f = ben || rastgele || !secim ? undefined : byId(secim);
            const ai = koltuk === 3 && aiLastSeat(selected, playerCount);
            const dolu = ben || rastgele || !!f;
            const ad = ben
              ? profile?.display_name || profile?.username || 'Sen'
              : rastgele
                ? (yatay ? 'Rastgele oyuncu' : 'Rastgele')
                : f?.name;
            const numara = (
              <span
                aria-hidden
                className={[
                  'shrink-0 flex items-center justify-center font-mono font-bold leading-none select-none pointer-events-none',
                  yatay ? 'w-10 h-9 -mr-2 text-[56px]' : 'w-[22px] h-[28px] -mr-1 text-[34px]',
                ].join(' ')}
                style={{ color: col.base, opacity: dolu ? 0.2 : 0.12 }}
              >
                {koltuk + 1}
              </span>
            );
            const carpiYuvasi = yatay ? 'w-6 h-7' : 'w-4 h-7';
            const iskelet = [
              'w-full flex items-center rounded-xl min-w-0',
              yatay ? 'gap-2.5 px-3 py-2.5' : 'gap-[5px] pl-2 pr-1.5 py-2',
            ].join(' ');
            if (rastgele) {
              // "?" koltuğu: kartın TAMAMI dokunulabilir, dokununca seçimi
              // kaldırır (kullanıcı kararı, docs/decisions/random-opponent.md §3).
              return (
                <button
                  key={koltuk}
                  type="button"
                  data-koltuk={koltuk + 1}
                  onClick={() => setSelected((s) => removeSeatAt(s, koltuk - 1))}
                  aria-label={`Rastgele oyuncu koltuğunu boşalt (koltuk ${koltuk + 1})`}
                  className={`${iskelet} border text-left active:scale-[0.98] transition-transform`}
                  style={{ background: col.tint, borderColor: col.base }}
                >
                  <span
                    className="rounded-full bg-bg border-[1.5px] border-dashed flex items-center justify-center shrink-0 font-bold"
                    style={{
                      width: yatay ? 36 : 28,
                      height: yatay ? 36 : 28,
                      borderColor: col.base,
                      color: col.text,
                      fontSize: yatay ? 20 : 16,
                    }}
                    aria-hidden
                  >
                    ?
                  </span>
                  <span
                    className={['flex-1 min-w-0 truncate font-sans font-bold', yatay ? 'text-sm' : 'text-[13px]'].join(' ')}
                    style={{ color: col.text }}
                  >
                    {ad}
                  </span>
                  {numara}
                  <span
                    className={`${carpiYuvasi} shrink-0 flex items-center justify-center ${yatay ? 'text-sm' : 'text-xs'}`}
                    style={{ color: col.text }}
                    aria-hidden
                  >
                    ✕
                  </span>
                </button>
              );
            }
            if (dolu) {
              return (
                <div
                  key={koltuk}
                  data-koltuk={koltuk + 1}
                  className={`${iskelet} border`}
                  style={{ background: col.tint, borderColor: col.base }}
                >
                  {ben ? (
                    <Avatar url={profile?.avatar_url} name={ad ?? 'Sen'} size={yatay ? 36 : 28} />
                  ) : (
                    <Avatar url={f!.avatar_url} name={f!.name} size={yatay ? 36 : 28} />
                  )}
                  <span
                    className={['flex-1 min-w-0 truncate font-sans font-bold', yatay ? 'text-sm' : 'text-[13px]'].join(' ')}
                    style={{ color: col.text }}
                  >
                    {ad}
                  </span>
                  {numara}
                  {ben ? (
                    <span className={`${carpiYuvasi} shrink-0`} aria-hidden />
                  ) : (
                    <button
                      type="button"
                      onClick={() => toggleFriend(f!.friend_id)}
                      aria-label={`${f!.name} koltuğunu boşalt`}
                      className={`${carpiYuvasi} shrink-0 flex items-center justify-center tap-expand ${yatay ? 'text-sm' : 'text-xs'}`}
                      style={{ color: col.text }}
                    >
                      ✕
                    </button>
                  )}
                </div>
              );
            }
            const etiket = ai ? 'Yapay Zeka' : yatay ? 'Aşağıdan bir arkadaşını seç' : 'Boş';
            const govde = (
              <>
                <span
                  className={[
                    'rounded-full bg-void border border-border flex items-center justify-center shrink-0',
                    yatay ? 'w-9 h-9 text-lg' : 'w-7 h-7 text-sm',
                  ].join(' ')}
                  aria-hidden
                >
                  {ai ? '🤖' : '+'}
                </span>
                <span
                  className={['flex-1 min-w-0 truncate font-sans font-bold text-muted', yatay ? 'text-[13px]' : 'text-xs'].join(' ')}
                >
                  {etiket}
                </span>
                {numara}
                <span className={`${carpiYuvasi} shrink-0`} aria-hidden />
              </>
            );
            const bosCls = `${iskelet} border-[1.5px] border-dashed border-[#C7D0DC] bg-bg`;
            return ai ? (
              <div key={koltuk} data-koltuk={koltuk + 1} className={bosCls}>
                {govde}
              </div>
            ) : (
              <button
                key={koltuk}
                type="button"
                data-koltuk={koltuk + 1}
                // Görünen yazı 4 kişide kısa ("Boş", 2 Ekim 2026 — dar kartta
                // "Boş koltuk" kesiliyordu); ekran okuyucu tam adı duyar.
                aria-label={yatay ? undefined : `Boş koltuk ${koltuk + 1}`}
                onClick={() => listeRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })}
                className={`${bosCls} text-left active:scale-[0.98] transition-transform`}
              >
                {govde}
              </button>
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
          {usesRandomSeat(selected) ? 'Biri' : playerCount === 2 ? 'Arkadaşın' : 'Arkadaşların'} kabul edince oyun başlar · her hamle için 48 saat
        </p>
        {error && <p className="text-xs text-red font-mono text-center" style={{ margin: 0 }}>{error}</p>}
      </div>

      <div ref={listeRef} className="flex flex-col gap-2 scroll-mt-3">
        {/* Başlığın sağında dönüşümlü bağlantı — Arkadaşlar penceresiyle aynı
            (27 Eylül 2026, kullanıcı isteği). Bağlantı başlıkla AYNI tipografi
            (10px mono, büyük harf, aralıklı) ama mavi + kalın (2 Ekim 2026,
            kullanıcı isteği; FriendsModal + port ikizleri de). "Tüm oyuncular"da arkadaş
            olmayana buradan istek gidilir; oyuna yalnızca ARKADAŞ çağrılır
            (`create_online_game`: "Yalnızca arkadaşlarını davet edebilirsin."). */}
        <div className="flex items-center justify-between gap-2">
          <span className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
            {showAll ? 'Tüm oyuncular' : 'Arkadaşların'}
          </span>
          <button
            type="button"
            onClick={() => {
              setShowAll((v) => !v);
              setQuery('');
            }}
            className="shrink-0 min-h-[36px] text-[10px] uppercase tracking-[1.5px] font-mono font-bold text-accent active:opacity-70"
          >
            {showAll ? '← Arkadaşlar' : 'Tüm oyuncular →'}
          </button>
        </div>
        {!showAll && friends === null ? (
          <div className="flex flex-col gap-1.5">
            {randomRow}
            <p className="text-muted text-xs font-mono py-4 text-center">Yükleniyor…</p>
          </div>
        ) : !showAll && friends!.length === 0 ? (
          <div className="flex flex-col gap-1.5">
            {randomRow}
            <div className="flex flex-col items-center gap-2.5 py-4">
            <p className="text-muted text-xs font-mono text-center">Henüz hiç arkadaşın yok.</p>
            <button
              type="button"
              onClick={() => void invite.share()}
              className="btn-raised bg-accent text-white rounded-md py-2 px-4 text-[11px] font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              Arkadaşını davet et
            </button>
            <button
              type="button"
              onClick={() => setShowAll(true)}
              className="min-h-[36px] text-[10px] uppercase tracking-[1.5px] font-mono font-bold text-accent active:opacity-70"
            >
              Tüm oyunculara göz at →
            </button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col gap-1.5">
            {/* "Sık oynadıkların" — sabit en fazla 5 avatar, KAYDIRMA YOK
                (390 px'e sığıyor; carousel "yana kaydır, daha var" dedirtirdi).
                Dokunmak listedeki satırla AYNI: seçer/bırakır; seçilenin
                halkası oturacağı koltuğun renginde. Sık oynanan 5'ten azsa
                boş yerler rastgele arkadaşlarla dolar ve başlık "Hızlı seç"
                olur. Arkadaş 2'den azsa (davet düğmesi zaten altta), arama
                yapılırken ve "Tüm oyuncular"da çizilmez. */}
            {(() => {
              if (showAll || query.trim() !== '') return null;
              if (!friends || friends.length < 2) return null;
              const sik = frequentIds
                .map((id) => friends.find((f) => f.friend_id === id))
                .filter((f): f is FriendRow => !!f);
              // Boş yerler: sık oynanmayan arkadaşlar, form başına sabit
              // rastgele sırayla (kimlik + tohum → kararlı sıra anahtarı).
              const anahtar = (id: string) => {
                let h = Math.floor(karistirmaTohumu.current * 2 ** 31);
                for (let k = 0; k < id.length; k++) h = (h * 31 + id.charCodeAt(k)) | 0;
                return h;
              };
              const dolgu = friends
                .filter((f) => !sik.includes(f))
                .sort((a, b) => anahtar(a.friend_id) - anahtar(b.friend_id))
                .slice(0, Math.max(0, 5 - sik.length));
              const serit = [...sik, ...dolgu];
              return (
                <div className="flex flex-col gap-1.5 pb-1">
                  <span className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
                    {dolgu.length === 0 ? 'Sık oynadıkların' : 'Hızlı seç'}
                  </span>
                  <div className="grid grid-cols-5 gap-1">
                    {serit.map((f) => {
                      const sira = selected.indexOf(f.friend_id);
                      const renk = sira >= 0 ? PLAYER_COLORS[sira + 1].base : null;
                      return (
                        <button
                          key={f.friend_id}
                          type="button"
                          onClick={() => toggleFriend(f.friend_id)}
                          aria-pressed={sira >= 0}
                          aria-label={`${f.name} — ${sira >= 0 ? 'seçimi kaldır' : 'seç'}`}
                          className="flex flex-col items-center gap-1 min-w-0 py-1 active:scale-[0.95] transition-transform"
                        >
                          <span
                            className="rounded-full transition-shadow"
                            style={{ boxShadow: renk ? `0 0 0 3px ${renk}` : undefined }}
                          >
                            <Avatar url={f.avatar_url} name={f.name} size={46} />
                          </span>
                          <span
                            className={`w-full truncate text-center text-[11px] font-bold ${renk ? 'text-text' : 'text-muted'}`}
                          >
                            {f.name}
                          </span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              );
            })()}
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="İsim ya da takma ad ara…"
              aria-label={showAll ? 'Oyuncu ara' : 'Arkadaş ara'}
              className="w-full bg-bg border border-border rounded-md px-3 py-2 text-sm text-text outline-none focus:border-accent transition-colors"
            />
            {/* Arama kutusunun HEMEN altında (27 Eylül 2026, kullanıcı:
                *"arkadaşlar listesinin üstüne arkadaşını davet et butonu
                olsun. Aramanın altına"*). Arkadaşlar penceresini DEĞİL,
                doğrudan paylaşımı açar (`useInviteShare`). */}
            <button
              type="button"
              onClick={() => void invite.share()}
              className="flex items-center justify-center gap-2 min-h-[44px] rounded-md border-[1.5px] border-dashed border-accent bg-[#EEF4FF] text-accent text-[13px] font-bold uppercase tracking-[1px] active:scale-[0.99] transition-transform"
            >
              <span aria-hidden className="text-base leading-none">+</span> Arkadaşını davet et
            </button>
            <ScrollArea scrollRef={dir.scrollRef} className="flex flex-col gap-1.5 max-h-[280px]">
              {randomRow}
              {(() => {
                const friendRow = (f: { friend_id: string; name: string; avatar_url: string | null }) => {
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
                };
                if (!showAll) {
                  const filtered = friends!.filter((f) => trLower(f.name).includes(trLower(query.trim())));
                  if (filtered.length === 0) {
                    return <p className="text-muted text-xs font-mono py-4 text-center">Kimse bulunamadı.</p>;
                  }
                  return filtered.map(friendRow);
                }
                const liste = dir.searchActive ? dir.results : dir.allUsers;
                if (liste === null || (dir.searchActive && dir.searching)) {
                  return <p className="text-muted text-xs font-mono py-4 text-center">Yükleniyor…</p>;
                }
                if (liste.length === 0 && !(!dir.searchActive && dir.hasMore)) {
                  return <p className="text-muted text-xs font-mono py-4 text-center">Kimse bulunamadı.</p>;
                }
                return (
                  <>
                    {liste.map((u) =>
                      u.relation === 'accepted' ? (
                        friendRow({ friend_id: u.id, name: u.name, avatar_url: u.avatar_url })
                      ) : (
                        <div
                          key={u.id}
                          className="flex items-center gap-2.5 rounded-md px-2.5 py-1.5 border border-border bg-bg shrink-0"
                        >
                          <button
                            type="button"
                            onClick={() =>
                              setKartKisi({
                                id: u.id,
                                username: null,
                                first_name: null,
                                last_name: null,
                                display_name: u.name,
                                avatar_url: u.avatar_url,
                              })
                            }
                            aria-label={`${u.name} — skor kartı`}
                            className="flex-1 min-w-0 flex items-center gap-2.5 text-left active:opacity-70 transition-opacity"
                          >
                            <Avatar url={u.avatar_url} name={u.name} size={28} />
                            <span className="flex-1 min-w-0 flex items-center gap-1">
                              <span className="min-w-0 text-sm font-bold text-text truncate">{u.name}</span>
                              {rankTierOf(u.id) && <RankSeal tier={rankTierOf(u.id)!} size={18} className="shrink-0" />}
                            </span>
                          </button>
                          {u.relation === 'pending_outgoing' ? (
                            <Pill kind="gonderildi" ariaLabel={`${u.name} — isteği iptal et`} disabled={busyId === u.id} onClick={() => void handleCancel(u.id)} />
                          ) : u.relation === 'pending_incoming' ? (
                            <Pill kind="kabul" ariaLabel={`${u.name} — isteği kabul et`} disabled={busyId === u.id} onClick={() => void handleAccept(u.id)} />
                          ) : (
                            <Pill kind="ekle" ariaLabel={`${u.name} — arkadaş ekle`} disabled={busyId === u.id} onClick={() => void handleSend(u.id)} />
                          )}
                        </div>
                      ),
                    )}
                    {!dir.searchActive && dir.hasMore && (
                      <div ref={dir.sentinelRef} className="py-2 text-center">
                        <span className="text-muted text-[10px] font-mono">{dir.loadingMore ? 'Yükleniyor…' : ''}</span>
                      </div>
                    )}
                  </>
                );
              })()}
            </ScrollArea>
          </div>
        )}
      </div>

      {kartKisi && <PlayerScoreCard member={kartKisi} onClose={kartiKapat} />}

      {invite.fallbackOpen && invite.inviteUrl && (
        <InviteShareFallback url={invite.inviteUrl} onClose={invite.closeFallback} />
      )}
    </div>
  );
}
