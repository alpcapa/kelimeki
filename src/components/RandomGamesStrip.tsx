// Kelimeki — Rastgele Oyuncu (3 Ekim 2026): "Devam Edenler"in üstündeki yatay
// kayan ilan şeridi + benim bekleyen ilanım için "Bekliyor n/N" satırı.
// Tasarım ve gerekçeler: docs/decisions/random-opponent.md (§4, §11, §15).
// §15 (4 Ekim 2026): şerit BENİM bekleyen ilanımı da kart olarak gösterir.
// Saf kurallar (süzgeç, metinler, aralıklar): `utils/randomGames.ts`.
//
// ⚠ Şerit Realtime ile BESLENEMEZ: Realtime RLS'e uyar ve başkasının açtığı
// ilan bana olay olarak gelmez (§11). Bu yüzden sayfa GÖRÜNÜRKEN ve yalnızca
// bu bileşen takılıyken (Devam Edenler açıkken) yoklanır; öne dönüşte/odakta/
// çevrimiçine dönüşte de bir kez. Yalnızca ilk sayfa (20) — offset sayfalaması
// kayar, id ile tekilleştirilir.
//
// ⚠ Liste boşken şerit artık GİZLENMEZ (12 Ekim 2026, kullanıcı): sunucu
// BAŞARIYLA boş dediyse tek satır "Bekleyen oyun yok. Hemen aç." çıkar
// (`randomStripMode`); ilk çekim sürerken/ağ hatasında gizli kalır (yalan
// "yok" demesin). Bileşen her durumda BAĞLI (yoklama sürsün) — hook'lar erken
// `return`ün ÜSTÜNDE (verify-hook-order). Başlıktaki tek seferlik tanıtım
// balonu (`RANDOM_HINT_TEXT`) bu hep-görünür başlığa çapalı.
import { useEffect, useRef, useState } from 'react';
import { acceptRandomGame, fetchRandomGames } from '../lib/api';
import type { MyRandomGame, RandomGameResult, RandomListing } from '../lib/database.types';
import { friendlyErrorMessage } from '../utils/errorMessage';
import { hasSeenRandomHint, markRandomHintSeen } from '../utils/onboarding';
import {
  RANDOM_EMPTY_LINK,
  RANDOM_EMPTY_TEXT,
  RANDOM_HINT_MS,
  RANDOM_HINT_TEXT,
  RANDOM_STRIP_LIMIT,
  RANDOM_STRIP_MIN_GAP_MS,
  RANDOM_STRIP_POLL_MS,
  cardShowsWaiting,
  filledSeatCount,
  isOpenSeat,
  randomStripMode,
  seatsLeftLabel,
  stripListings,
} from '../utils/randomGames';
import { Avatar } from './Avatar';
import { HintBubble } from './HintBubble';
import { PlayerAvatarRow } from './PlayerAvatarRow';

/** `user.id` → son çekilen ilanlar. Sekme değişince yeniden mount'ta şerit boş başlamasın. */
const stripCache = new Map<string, RandomListing[]>();

/** Dolu koltuk = yeşil nokta; boş (açık / henüz yanıtlamamış davetli) = içi boş halka. */
function SeatDots({ seats }: { seats: RandomListing['seats'] }) {
  const dolu = seats.filter((s) => s === 'creator' || s === 'filled' || s === 'ai').length;
  return (
    <span className="flex gap-[2px]" role="img" aria-label={`${seats.length} koltuktan ${dolu} dolu`}>
      {seats.map((s, i) => (
        <span
          key={i}
          className={`w-2 h-2 rounded-full border-[1.5px] ${
            s === 'creator' || s === 'filled' || s === 'ai'
              ? 'bg-green border-green'
              : 'border-muted bg-transparent'
          }`}
        />
      ))}
    </span>
  );
}

interface RandomGamesStripProps {
  /** Oturumun kullanıcı kimliği (STRING — `user` nesnesi değil: effect bağımlılığı). */
  userId: string;
  /**
   * `list_my_random_games` sonucu (`null` = alınamadı). Bekleyen creator/random
   * ilanlarım şeride KART olarak eklenir (§15); kimlikleri başkaları listesinden
   * düşülür.
   */
  myRandom: readonly MyRandomGame[] | null;
  /** İptal/Ayrıl sürerken o ilanın id'si (düğme kilitli). */
  busyRandomId: string | null;
  /** Kartımdaki "İptal" (kurucu) / "Ayrıl" (kabul eden) — `LiveGamesTab.handleLeaveRandom`. */
  onLeaveMine: (game: MyRandomGame) => void;
  /** Başlıktaki "Rastgele oyun aç" — "Yeni Oyun Başlat" ile AYNI: kurulum ekranını açar. */
  onOpenCreate: () => void;
  /** Kabul başarılı: üst bileşen iletiyi gösterir, listeyi tazeler. */
  onAccepted: (result: RandomGameResult) => void;
  /** Kabul reddedildi (ör. "Bu oyun doldu."): sunucunun Türkçe metni. */
  onNotice: (text: string) => void;
  /**
   * Üst bileşen "şeridin kaynağı değişti" dediğinde artırdığı sayaç (ör.
   * `Ayrıl`/`İlanı iptal et` sonrası): şerit KENDİ listesini çeker (`myRandom`
   * "benim oyunlarım"dır, şerit ise herkesin ilanları), yoklamayı ya da sekme
   * değişimini beklemeden. 11 Ekim 2026, elle testte yakalandı: Ayrıl'a
   * basınca ilan şeride hemen dönmüyor, sekmeye gidip gelince dönüyordu.
   */
  refreshSignal?: number;
}

export function RandomGamesStrip({
  userId,
  myRandom,
  busyRandomId,
  onLeaveMine,
  onOpenCreate,
  onAccepted,
  onNotice,
  refreshSignal = 0,
}: RandomGamesStripProps) {
  const [listings, setListings] = useState<RandomListing[]>(() => stripCache.get(userId) ?? []);
  const [busyId, setBusyId] = useState<string | null>(null);
  // Sunucu en az bir kez BAŞARIYLA yanıt verdi mi (önbellek de sayılır): boş
  // durum yalnızca o zaman "Bekleyen oyun yok" der.
  const [loaded, setLoaded] = useState(() => stripCache.has(userId));
  const [hintOn, setHintOn] = useState(false);
  const hintDecided = useRef(false);
  const refreshRef = useRef<(force: boolean) => void>(() => {});

  useEffect(() => {
    let cancelled = false;
    let inflight = false;
    let last = 0;
    const load = async (force: boolean) => {
      if (cancelled || inflight) return;
      if (typeof document !== 'undefined' && document.visibilityState !== 'visible') return;
      if (typeof navigator !== 'undefined' && navigator.onLine === false) return;
      const now = Date.now();
      if (!force && now - last < RANDOM_STRIP_MIN_GAP_MS) return;
      inflight = true;
      last = now;
      const rows = await fetchRandomGames(RANDOM_STRIP_LIMIT, 0);
      inflight = false;
      if (cancelled) return;
      // `null` = bilmiyoruz: ELDEKİ listeyi koru (boşla ezmek şeridi
      // sessizce kaldırırdı).
      if (rows !== null) {
        stripCache.set(userId, rows);
        setListings(rows);
        setLoaded(true);
      }
    };
    refreshRef.current = (force) => void load(force);
    void load(true);
    const timer = window.setInterval(() => void load(false), RANDOM_STRIP_POLL_MS);
    const onForeground = () => void load(false);
    document.addEventListener('visibilitychange', onForeground);
    window.addEventListener('focus', onForeground);
    window.addEventListener('online', onForeground);
    return () => {
      cancelled = true;
      window.clearInterval(timer);
      document.removeEventListener('visibilitychange', onForeground);
      window.removeEventListener('focus', onForeground);
      window.removeEventListener('online', onForeground);
    };
  }, [userId]);

  // İlk değer (0) mount'taki `load(true)` ile zaten karşılanıyor; yalnızca
  // SAYAÇ ARTINCA zorla tazele.
  useEffect(() => {
    if (refreshSignal > 0) refreshRef.current(true);
  }, [refreshSignal]);

  const visible = stripListings(listings, myRandom);
  const mode = randomStripMode(loaded, visible.length);

  // Tek seferlik tanıtım balonu: şerit görünür olduğu ilk anda KARAR verilir
  // (işaretlenir), 7 sn sonra kendiliğinden kapanır. Karar ile kapanış AYRI
  // effect: mod değişince (boş → kartlar) kapanış sayacı sıfırlanmasın.
  useEffect(() => {
    if (mode === 'hidden' || hintDecided.current) return;
    hintDecided.current = true;
    if (hasSeenRandomHint()) return;
    markRandomHintSeen();
    setHintOn(true);
  }, [mode]);
  useEffect(() => {
    if (!hintOn) return;
    const t = window.setTimeout(() => setHintOn(false), RANDOM_HINT_MS);
    return () => window.clearTimeout(t);
  }, [hintOn]);

  if (mode === 'hidden') return null;

  const accept = async (l: RandomListing) => {
    if (busyId) return;
    setBusyId(l.id);
    try {
      const sonuc = await acceptRandomGame(l.id);
      // Kabul edilen ilan şeritten hemen kalkar (yoklamayı beklemeden).
      setListings((cur) => cur.filter((x) => x.id !== l.id));
      onAccepted(sonuc);
    } catch (err) {
      onNotice(friendlyErrorMessage(err, { surface: 'rastgele-kabul', fallback: 'Kabul edilemedi.' }));
    } finally {
      setBusyId(null);
      // Başarıda da başarısızlıkta da (ör. "Bu oyun doldu.") şeridi tazele.
      refreshRef.current(true);
    }
  };

  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-baseline justify-between gap-2">
        {/* Balon bu başlığa çapalı: şerit artık hep görünür, yani çapa hep var. */}
        <span className="relative inline-block text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
          Rastgele Oyunlar{mode === 'cards' ? ` · ${visible.length}` : ''}
          {hintOn && <HintBubble text={RANDOM_HINT_TEXT} yon="ust" hiza="bas" />}
        </span>
        {mode === 'cards' && (
          <button
            type="button"
            onClick={onOpenCreate}
            className="shrink-0 min-h-[36px] pl-2.5 text-[10px] uppercase tracking-[1.5px] font-mono font-bold text-accent active:opacity-70"
          >
            Rastgele oyun aç
          </button>
        )}
      </div>
      {mode === 'empty' ? (
        // Boş durum: tek satır (kare kart DEĞİL — alttaki Devam Eden Oyunlar'ı
        // itmesin, 4 Ekim kararı). Tamamı düğme: "Hemen aç." başlıktaki
        // "Rastgele oyun aç" ile AYNI eylem (boşken o bağlantı gizli).
        <button
          type="button"
          onClick={onOpenCreate}
          className="w-full min-h-[44px] rounded-[10px] border border-border bg-panel shadow-raised px-3 py-2 text-center font-mono text-xs text-muted active:opacity-70"
        >
          {RANDOM_EMPTY_TEXT}{' '}
          <span className="font-bold text-accent underline underline-offset-[3px]">{RANDOM_EMPTY_LINK}</span>
        </button>
      ) : (
      <div
        className="no-scrollbar flex gap-2 overflow-x-auto pb-1 snap-x snap-proximity overscroll-x-contain"
        role="list"
        aria-label="Rastgele oyun ilanları"
      >
        {visible.map((l) => {
          const mine = l.mine;
          const myGame = mine ? (myRandom ?? []).find((g) => g.id === l.id) : undefined;
          return (
            <div
              key={l.id}
              role="listitem"
              // KARE kart (4 Ekim 2026, kullanıcı: dikey uzun kart alttaki asıl Devam Eden
              // Oyunlar'ı iter): 3 tam kart + 4.'nün ~1/4'ü görünür (devamı olduğu belli olsun).
              // eni = (şerit − 3 aralık) / 3.25, en çok 7rem (geniş ekranda daha çok kart sığar).
              className={`snap-start shrink-0 min-w-[84px] basis-[min(7rem,calc((100%-24px)/3.25))] aspect-square flex flex-col gap-1 rounded-[10px] border p-1.5 shadow-raised ${
                mine ? 'border-accent/30 bg-accent/5' : 'border-border bg-panel'
              }`}
            >
              <div className="flex items-center gap-1 min-w-0">
                <Avatar url={l.creator_avatar_url} name={l.creator_name} size={22} />
                <span className="min-w-0 flex-1 truncate text-[11px] font-bold text-text">
                  {l.creator_name ?? 'Oyuncu'}
                </span>
              </div>
              <div className="flex flex-wrap items-center justify-between gap-x-1 gap-y-0.5 min-w-0">
                <span
                  className={`shrink-0 rounded-full border px-1 py-[1px] font-mono text-[10px] font-bold leading-tight ${
                    l.player_count === 2
                      ? 'text-[#0A6076] bg-[#E7F6FA] border-[#A9E4EF]'
                      : 'text-[#4A1A90] bg-[#F3ECFE] border-[#DCC8FC]'
                  }`}
                >
                  {l.player_count} kişi
                </span>
                <SeatDots seats={l.seats} />
              </div>
              {cardShowsWaiting(l.open_seats, !!mine) ? (
                // Yalnızca benim kartımda ve açık koltuk KALMADIYSA (kalanlar arkadaş
                // davetlisi, yanıt bekleniyor): "0 koltuk kaldı" yanlış olurdu. Diğer her
                // durumda "N koltuk kaldı" (12 Ekim 2026, kullanıcı: "bekliyor yerine
                // x koltuk kaldı daha etkili").
                <span className="truncate text-center font-mono text-[9px] font-bold uppercase tracking-[0.5px] leading-tight text-muted">
                  Bekliyor
                </span>
              ) : (
                <span className="truncate text-center font-mono text-[9px] leading-tight text-muted">
                  {seatsLeftLabel(l.open_seats)}
                </span>
              )}
              {mine ? (
                // Benim ilanım (§15): "Kabul" YOK; küçük eylem (kurucu İptal, kabul eden Ayrıl).
                <button
                  type="button"
                  onClick={() => myGame && onLeaveMine(myGame)}
                  disabled={!myGame || busyRandomId === l.id}
                  aria-label={mine === 'creator' ? 'İlanı iptal et' : 'İlandan ayrıl'}
                  className="mt-auto w-full min-h-[32px] text-[11px] text-red underline underline-offset-[3px] active:opacity-70 disabled:opacity-50"
                >
                  {mine === 'creator' ? 'İptal' : 'Ayrıl'}
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => void accept(l)}
                  disabled={busyId !== null}
                  aria-label={`${l.creator_name ?? 'Oyuncu'} ilanını kabul et`}
                  className="mt-auto w-full min-h-[32px] btn-raised bg-accent text-white rounded-md text-[11px] font-bold uppercase tracking-[0.5px] active:scale-[0.97] transition-transform disabled:opacity-50"
                >
                  Kabul
                </button>
              )}
            </div>
          );
        })}
      </div>
      )}
    </div>
  );
}

/**
 * Benim bekleyen ilanım ("Devam Edenler" listesinde, oyun satırlarının
 * altında): koltuk avatarları (dolu = avatar, açık = kesik çerçeveli "?"),
 * "Bekliyor n/N", kurucu için "İlanı iptal et", kabul eden için "Ayrıl"
 * (ceza yok). Satıra dokunmak bir şey açmaz — oyun henüz başlamadı.
 */
export function RandomWaitingRow({
  game,
  busy,
  onLeave,
}: {
  game: MyRandomGame;
  busy: boolean;
  onLeave: () => void;
}) {
  const creator = game.my_role === 'creator';
  const dolu = filledSeatCount(game.slots);
  const acik = game.slots.filter(isOpenSeat).length;
  const bekleyenDavetli = game.slots.some((s) => s.type === 'human' && s.invite_status === 'pending');
  return (
    <div className="shadow-raised flex flex-col gap-1.5 rounded-md px-2.5 py-2 border border-border bg-panel">
      <div className="flex items-center gap-2.5">
        <span className="flex-1 min-w-0">
          <PlayerAvatarRow
            players={game.slots.map((s) =>
              s.type === 'human'
                ? { name: s.name ?? 'Oyuncu', avatarUrl: s.avatar_url }
                : isOpenSeat(s)
                  ? { name: 'Rastgele oyuncu bekleniyor', isOpen: true }
                  : { name: 'Yapay Zeka', isAi: true },
            )}
          />
        </span>
        <span className="shrink-0 font-mono text-[13px] font-bold uppercase tracking-[1px] text-orange">
          Bekliyor {dolu}/{game.player_count}
        </span>
      </div>
      <div className="flex items-center justify-between gap-2">
        <span className="min-w-0 truncate font-mono text-[11px] text-muted">
          {acik > 0
            ? 'Rastgele oyuncu bekleniyor'
            : bekleyenDavetli
              ? 'Arkadaş yanıtı bekleniyor'
              : 'Oyun başlıyor'}
        </span>
        <button
          type="button"
          onClick={onLeave}
          disabled={busy}
          className="shrink-0 min-h-[36px] pl-2 text-xs text-red underline underline-offset-[3px] active:opacity-70 disabled:opacity-50"
        >
          {creator ? 'İlanı iptal et' : 'Ayrıl'}
        </button>
      </div>
    </div>
  );
}
