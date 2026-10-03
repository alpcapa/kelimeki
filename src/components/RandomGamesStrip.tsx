// Kelimeki — Rastgele Oyuncu (3 Ekim 2026): "Devam Edenler"in üstündeki yatay
// kayan ilan şeridi + benim bekleyen ilanım için "Bekliyor n/N" satırı.
// Tasarım ve gerekçeler: docs/decisions/random-opponent.md (§4, §11).
// Saf kurallar (süzgeç, metinler, aralıklar): `utils/randomGames.ts`.
//
// ⚠ Şerit Realtime ile BESLENEMEZ: Realtime RLS'e uyar ve başkasının açtığı
// ilan bana olay olarak gelmez (§11). Bu yüzden sayfa GÖRÜNÜRKEN ve yalnızca
// bu bileşen takılıyken (Devam Edenler açıkken) yoklanır; öne dönüşte/odakta/
// çevrimiçine dönüşte de bir kez. Yalnızca ilk sayfa (20) — offset sayfalaması
// kayar, id ile tekilleştirilir.
//
// ⚠ Liste boşken şerit TAMAMEN gizlenir ama bileşen BAĞLI kalır (yoklama
// sürsün, yeni ilan gelince şerit belirsin) — hook'lar erken `return`ün
// ÜSTÜNDE (verify-hook-order).
import { useEffect, useRef, useState } from 'react';
import { acceptRandomGame, fetchRandomGames } from '../lib/api';
import type { MyRandomGame, RandomGameResult, RandomListing } from '../lib/database.types';
import { friendlyErrorMessage } from '../utils/errorMessage';
import {
  RANDOM_STRIP_LIMIT,
  RANDOM_STRIP_MIN_GAP_MS,
  RANDOM_STRIP_POLL_MS,
  filledSeatCount,
  isOpenSeat,
  seatsLeftLabel,
  visibleListings,
} from '../utils/randomGames';
import { Avatar } from './Avatar';
import { PlayerAvatarRow } from './PlayerAvatarRow';

/** `user.id` → son çekilen ilanlar. Sekme değişince yeniden mount'ta şerit boş başlamasın. */
const stripCache = new Map<string, RandomListing[]>();

/** Dolu koltuk = yeşil nokta; boş (açık / henüz yanıtlamamış davetli) = içi boş halka. */
function SeatDots({ seats }: { seats: RandomListing['seats'] }) {
  const dolu = seats.filter((s) => s === 'creator' || s === 'filled' || s === 'ai').length;
  return (
    <span className="flex gap-[3px]" role="img" aria-label={`${seats.length} koltuktan ${dolu} dolu`}>
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
  /** Zaten içinde olduğum oyunların id'leri (şeritte tekrar gösterilmez). */
  myGameIds: readonly string[];
  /** Başlıktaki "Rastgele oyun aç" — "Yeni Oyun Başlat" ile AYNI: kurulum ekranını açar. */
  onOpenCreate: () => void;
  /** Kabul başarılı: üst bileşen iletiyi gösterir, listeyi tazeler. */
  onAccepted: (result: RandomGameResult) => void;
  /** Kabul reddedildi (ör. "Bu oyun doldu."): sunucunun Türkçe metni. */
  onNotice: (text: string) => void;
}

export function RandomGamesStrip({
  userId,
  myGameIds,
  onOpenCreate,
  onAccepted,
  onNotice,
}: RandomGamesStripProps) {
  const [listings, setListings] = useState<RandomListing[]>(() => stripCache.get(userId) ?? []);
  const [busyId, setBusyId] = useState<string | null>(null);
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

  const visible = visibleListings(listings, userId, new Set(myGameIds));
  if (visible.length === 0) return null;

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
        <span className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold">
          Rastgele Oyunlar · {visible.length}
        </span>
        <button
          type="button"
          onClick={onOpenCreate}
          className="shrink-0 min-h-[36px] pl-2.5 text-xs font-bold text-accent underline underline-offset-[3px] active:opacity-70"
        >
          Rastgele oyun aç
        </button>
      </div>
      <div
        className="no-scrollbar flex gap-2 overflow-x-auto pb-1 snap-x snap-proximity overscroll-x-contain"
        role="list"
        aria-label="Rastgele oyun ilanları"
      >
        {visible.map((l) => (
          <div
            key={l.id}
            role="listitem"
            className="snap-start shrink-0 min-w-[84px] basis-[calc((100%-16px)/3.4)] flex flex-col items-center gap-[5px] rounded-[10px] border border-border bg-panel p-2"
          >
            <Avatar url={l.creator_avatar_url} name={l.creator_name} size={30} />
            <span className="w-full truncate text-center text-xs font-bold text-text">
              {l.creator_name ?? 'Oyuncu'}
            </span>
            <span
              className={`rounded-full border px-1.5 py-[1px] font-mono text-[10px] font-bold ${
                l.player_count === 2
                  ? 'text-[#0A6076] bg-[#E7F6FA] border-[#A9E4EF]'
                  : 'text-[#4A1A90] bg-[#F3ECFE] border-[#DCC8FC]'
              }`}
            >
              {l.player_count} kişi
            </span>
            <SeatDots seats={l.seats} />
            <span className="text-center font-mono text-[10px] leading-tight text-muted">
              {seatsLeftLabel(l.open_seats)}
            </span>
            <button
              type="button"
              onClick={() => void accept(l)}
              disabled={busyId !== null}
              aria-label={`${l.creator_name ?? 'Oyuncu'} ilanını kabul et`}
              className="w-full min-h-[32px] btn-raised bg-accent text-white rounded-md text-[11px] font-bold uppercase tracking-[0.5px] active:scale-[0.97] transition-transform disabled:opacity-50"
            >
              Kabul
            </button>
          </div>
        ))}
      </div>
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
