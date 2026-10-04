// Kelimeki — Arkadaşlar penceresi: mevcut kullanıcıyı arayıp ekleme (e-postasız,
// uygulama içi istek/kabul) + kalıcı davet linkini WhatsApp/SMS/DM gibi
// kanallardan paylaşarak henüz üye olmayanları da davet etme (asıl büyüme
// mekanizması — bkz. `docs/decisions/friends.md`).
//
// 27 Eylül 2026 — SEKMESİZ tek ekrana yeniden yazıldı (kullanıcı: *"arkadaşlar
// modalı çok kötü ve kullanışsız. Onu da yeni konsepte göre elden geçir"*;
// tasarım: Claude Design tuvali → "Arkadaşlar penceresi — yeni konsept",
// karar kaydı `docs/decisions/friends.md` → "Tek ekran"). Üç sekme (Arkadaşlar
// · Davetler · Ara & Ekle) ve dört onay diyaloğu kalktı; yalnızca
// "Arkadaşlıktan çıkar" onay soruyor. İkonlar yerine YAZILI düğmeler.
import { useEffect, useState } from 'react';
import { LoadingNote } from './LoadingNote';
import { createPortal } from 'react-dom';
import { Modal } from './Modal';
import { Avatar } from './Avatar';
import { PlayerScoreCard, type PlayerSummary } from './PlayerScoreCard';
import { BlockedUsersModal } from './BlockedUsersModal';
import { BlockConfirmModal } from './BlockConfirmModal';
import { useModalA11y } from '../hooks/useModalA11y';
import {
  fetchFriendRelation,
  fetchFriends,
  fetchBlockedUsers,
  blockUser,
  fetchIncomingFriendRequests,
  fetchOutgoingFriendRequests,
  removeFriend,
  respondFriendRequest,
  sendFriendRequest,
} from '../lib/api';
import type {
  FriendRow,
  FriendSearchResult,
  IncomingFriendRequest,
  OutgoingFriendRequest,
} from '../lib/database.types';
import { useInviteShare } from '../hooks/useInviteShare';
import { InviteShareFallback } from './InviteShareFallback';
import { requestLiveGameWith } from '../utils/liveGameRequest';
import { FriendModerationModal, type FriendModerationTarget } from './FriendModerationModal';
import { RankSeal } from './RankSeal';
import { useRankScores } from '../hooks/useRankScores';
import { usePlayerDirectory } from '../hooks/usePlayerDirectory';
import { ScrollArea } from './ScrollArea';

/** Bir arkadaşı `PlayerScoreCard` açabilecek şekle çevirir — henüz canlı oyun
 * olmadığından arkadaş eklemenin somut faydası şu an bu: kişinin skor
 * kartına bakabilmek. */
/** Bu modaldeki ÜÇ listenin de (Arkadaşlar / Davetler / Ara & Ekle) satırı
 * aynı üç alanı taşıyor; `PlayerScoreCard` yalnızca bunları istiyor. Kısa
 * kimlik kuralı gereği ad/soyad hiç doldurulmuyor (`display_name` zaten
 * sunucuda o kuralla hesaplanmış görünen ad). */
function toPlayerSummary(
  id: string,
  name: string,
  avatarUrl: string | null,
): PlayerSummary {
  return {
    id,
    username: null,
    first_name: null,
    last_name: null,
    display_name: name,
    avatar_url: avatarUrl,
  };
}

// Aşağıdaki iki bileşen, bu dosyadaki dört neredeyse birebir aynı onay/sonuç
// modalını (Arkadaşlıktan Çıkar/İsteği Reddet/İsteği İptal Et + üçünün
// "Tamam" sonuç modalı) tek bir yerde toplar (kod incelemesi, dead-code/
// tekrar bulgusu). `dialogRef`, çağıranın kendi `useModalA11y` çağrısından
// (odak hapsi/Escape/dialog-yığını için, koşullu render edilen bir dialog
// içinde çağrılamaz — hep üst bileşende kalmalı) geldiğinden prop olarak alınır.
function ConfirmDialog({
  dialogRef,
  ariaLabel,
  title,
  message,
  confirmLabel,
  busy,
  onConfirm,
  onCancel,
}: {
  dialogRef: React.RefObject<HTMLDivElement>;
  ariaLabel: string;
  title: string;
  message: string;
  confirmLabel: string;
  busy: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return createPortal(
    <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-label={ariaLabel}
        tabIndex={-1}
        className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-4 outline-none"
      >
        <p className="text-base font-bold text-text font-sans">{title}</p>
        <p className="text-sm text-text font-sans leading-relaxed">{message}</p>
        <div className="flex gap-2 mt-1">
          <button
            onClick={onConfirm}
            disabled={busy}
            className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            {busy ? '...' : confirmLabel}
          </button>
          <button
            onClick={onCancel}
            disabled={busy}
            className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-50"
          >
            Vazgeç
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}


interface FriendsModalProps {
  onClose: () => void;
  /**
   * Eski sekmeli sürümden kalan imza — ÇAĞIRANLAR bozulmasın diye duruyor.
   * `'search'` artık arama kutusuna odaklanmak demek; öteki değerler yok
   * sayılır (gelen istekler zaten en üstte).
   */
  initialTab?: 'friends' | 'requests' | 'search';
}


const nameCls = 'min-w-0 text-[15px] text-text font-bold truncate';
const sectionCls = 'text-[10px] uppercase tracking-[1.5px] text-muted font-mono font-bold';
const listCls = 'flex flex-col border border-border rounded-xl overflow-hidden';
const rowCls = 'flex items-center gap-3 min-h-[60px] pl-3.5 pr-2 py-2 bg-bg border-b border-border last:border-b-0';

/**
 * `list_friends`in `since`i → "3 haftadır arkadaşsınız" (`kisa`: "3 haftadır").
 * Liste satırında KISA hâl: uzun metin OYNA + ⋯ yanında kesiliyordu (390px'te
 * ölçüldü). Saf; bilinmiyorsa null.
 */
export function friendSinceLabel(since: string | null, kisa = false, now = Date.now()): string | null {
  if (!since) return null;
  const t = Date.parse(since);
  if (!Number.isFinite(t)) return null;
  const gun = Math.floor((now - t) / 86_400_000);
  if (gun <= 0) return kisa ? 'Bugün eklendi' : 'Bugün arkadaş oldunuz';
  if (gun === 1) return kisa ? 'Dün eklendi' : 'Dün arkadaş oldunuz';
  const sure =
    gun < 7
      ? `${gun} gündür`
      : gun < 30
        ? `${Math.floor(gun / 7)} haftadır`
        : gun < 365
          ? `${Math.floor(gun / 30)} aydır`
          : `${Math.floor(gun / 365)} yıldır`;
  return kisa ? sure : `${sure} arkadaşsınız`;
}

type PillKind = 'oyna' | 'ekle' | 'gonderildi' | 'kabul' | 'geriAl';
const PILL: Record<PillKind, { label: string; cls: string }> = {
  oyna: { label: 'Oyna', cls: 'bg-accent border-accent text-white' },
  ekle: { label: 'Ekle', cls: 'bg-[#EEF4FF] border-accent text-accent' },
  gonderildi: { label: 'İstek gitti', cls: 'bg-panel border-border text-muted' },
  kabul: { label: 'Kabul et', cls: 'bg-orange border-orange text-white' },
  geriAl: { label: 'Geri al', cls: 'bg-panel border-border text-text' },
};

export function Pill({
  kind,
  onClick,
  disabled,
  ariaLabel,
}: {
  kind: PillKind;
  onClick: () => void;
  disabled?: boolean;
  ariaLabel: string;
}) {
  const p = PILL[kind];
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      aria-label={ariaLabel}
      // 29 Eylül 2026 (kullanıcı: *"çerçeveyi yazıya yakınlaştırıp genel boyu
      // biraz düşürebiliriz"*): görünen hap 36 → 26 px, yatay dolgu 14 → 10
      // px. Dokunma alanı KÜÇÜLMEDİ: `tap-expand-y` görünmez bir katmanla
      // dikeyde 41 px'e tamamlıyor (kalp/mesaj ikonlarındaki aynı desen).
      className={`tap-expand-y shrink-0 inline-flex items-center min-h-[26px] px-2.5 rounded-full border font-mono text-[11px] leading-none font-bold uppercase tracking-[0.5px] active:scale-[0.96] transition-transform disabled:opacity-40 ${p.cls}`}
    >
      {p.label}
    </button>
  );
}

export function FriendsModal({ onClose, initialTab = 'friends' }: FriendsModalProps) {
  const [friends, setFriends] = useState<FriendRow[] | null>(null);
  const [requests, setRequests] = useState<IncomingFriendRequest[] | null>(null);
  const [sent, setSent] = useState<OutgoingFriendRequest[]>([]);
  const [query, setQuery] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);
  const [selectedFriend, setSelectedFriend] = useState<PlayerSummary | null>(null);
  const [menuFor, setMenuFor] = useState<FriendRow | null>(null);
  const menuRef = useModalA11y(!!menuFor, () => setMenuFor(null));
  const [confirmRemove, setConfirmRemove] =
    useState<{ friend_id: string; name: string } | null>(null);
  const confirmRemoveRef = useModalA11y(!!confirmRemove, () => setConfirmRemove(null));
  const [showAll, setShowAll] = useState(false);
  const invite = useInviteShare();

  const {
    searchActive,
    results,
    searching,
    allUsers,
    hasMore: allUsersHasMore,
    loadingMore: allUsersLoadingMore,
    scrollRef: allUsersScrollRef,
    sentinelRef: allUsersSentinelRef,
    patchRelation: patchDirectory,
  } = usePlayerDirectory(query, showAll);
  const rankTierOf = useRankScores([
    ...(friends ?? []).map((f) => f.friend_id),
    ...(requests ?? []).map((r) => r.requester_id),
    ...sent.map((r) => r.friend_id),
    ...results.map((u) => u.id),
    ...(allUsers ?? []).map((u) => u.id),
  ]);

  const reloadFriends = () => void fetchFriends().then(setFriends);
  const reloadRequests = () => void fetchIncomingFriendRequests().then(setRequests);
  const reloadSent = () => void fetchOutgoingFriendRequests().then(setSent);

  // Engel durumu — engellenmiş/şikayet edilmiş arkadaşın adının yanında
  // 🚫/🚩, ⋯ menüsünde ayar girişi. 4 Ekim 2026'dan beri kaynak
  // `list_blocked_users` (engel + sohbet engeli + açık şikayet birleşimi);
  // eski `fetchMyChatModeration` yalnızca sohbet engelini görüyordu, kartlardan
  // yapılan "Engelle" (oyundan bağımsız) onda görünmezdi. Rozet süs olduğundan
  // hata sessizce boş kümeye düşer.
  const [moderation, setModeration] = useState<{
    blocked: Set<string>;
    reported: Set<string>;
  }>({ blocked: new Set(), reported: new Set() });
  const [moderationTarget, setModerationTarget] = useState<FriendModerationTarget | null>(null);
  const [blockTarget, setBlockTarget] = useState<{ id: string; name: string } | null>(null);
  const [blockedListOpen, setBlockedListOpen] = useState(false);
  const reloadModeration = () =>
    void fetchBlockedUsers()
      .then((list) =>
        setModeration({
          blocked: new Set(list.map((u) => u.userId)),
          reported: new Set(list.filter((u) => u.reported).map((u) => u.userId)),
        }),
      )
      .catch((err) => console.error('[Kelimeki] engel listesi hatası:', err));

  useEffect(() => {
    reloadFriends();
    reloadRequests();
    reloadSent();
    reloadModeration();
  }, []);

  const patchRelation = patchDirectory;

  // Ekle / kabul et / isteği iptal et TEK DOKUNUŞ (27 Eylül 2026, onaysız):
  // sonuç düğmenin kendisinde görünüyor ("İstek gitti", satırın "Arkadaşın"a
  // dönmesi), ayrı bir bilgi penceresi gerekmiyor. Yalnızca "Arkadaşlıktan
  // çıkar" onay soruyor — geri alınamaz tek eylem o.
  const handleSend = async (id: string) => {
    setBusyId(id);
    try {
      const status = await sendFriendRequest(id);
      // Karşı taraftan zaten bekleyen bir istek varsa sunucu ilişkiyi
      // doğrudan 'accepted'a çeviriyor.
      patchRelation(id, status === 'accepted' ? 'accepted' : 'pending_outgoing');
      if (status === 'accepted') reloadFriends();
      reloadSent();
    } catch (err) {
      console.error('[Kelimeki] arkadaşlık isteği hatası:', err);
    } finally {
      setBusyId(null);
    }
  };

  const handleRespond = async (requesterId: string, accept: boolean) => {
    setBusyId(requesterId);
    try {
      await respondFriendRequest(requesterId, accept);
      patchRelation(requesterId, accept ? 'accepted' : null);
      reloadRequests();
      if (accept) reloadFriends();
    } catch (err) {
      console.error('[Kelimeki] istek yanıtlama hatası:', err);
    } finally {
      setBusyId(null);
    }
  };

  const handleCancel = async (id: string) => {
    setBusyId(id);
    try {
      await removeFriend(id); // gönderilen isteği iptal et
      patchRelation(id, null);
      setSent((prev) => prev.filter((r) => r.friend_id !== id));
    } catch (err) {
      console.error('[Kelimeki] istek iptal hatası:', err);
    } finally {
      setBusyId(null);
    }
  };

  const handleConfirmRemove = async () => {
    if (!confirmRemove) return;
    const friendId = confirmRemove.friend_id;
    setBusyId(friendId);
    try {
      await removeFriend(friendId);
      reloadFriends();
      patchRelation(friendId, null);
    } catch (err) {
      console.error('[Kelimeki] arkadaş çıkarma hatası:', err);
    } finally {
      setBusyId(null);
      setConfirmRemove(null);
    }
  };

  // OYNA: bu arkadaşla Canlı oyun formu, o seçili. Pencere uygulamanın
  // neresinden açıldıysa App kurulum ekranına döner (`liveGameRequest.ts`).
  const play = (friendId: string, playerCount: 2 | 4) => {
    requestLiveGameWith({ friendId, playerCount });
    onClose();
  };

  /** Avatar+isim: dokununca skor kartı (her listede). Kart kapanınca ilişki
   * yeniden okunuyor: kart İÇİNDEN arkadaş eklenip çıkarılabiliyor. */
  const personButton = (id: string, name: string, avatarUrl: string | null, meta: string | null) => {
    const tier = rankTierOf(id);
    const mod = moderation.reported.has(id) ? '🚩' : moderation.blocked.has(id) ? '🚫' : null;
    return (
      <button
        type="button"
        onClick={() => setSelectedFriend(toPlayerSummary(id, name, avatarUrl))}
        className="flex-1 min-w-0 flex items-center gap-3 text-left active:opacity-70 transition-opacity"
      >
        <Avatar url={avatarUrl} name={name} size={40} />
        <span className="flex-1 min-w-0 flex flex-col gap-0.5">
          <span className="flex items-center gap-1.5 min-w-0">
            <span className={nameCls}>{name}</span>
            {tier && <RankSeal tier={tier} size={16} className="shrink-0" />}
            {mod && (
              <span className="shrink-0 text-xs" title={mod === '🚩' ? 'Şikayet edildi' : 'Engellendi'}>
                {mod}
              </span>
            )}
          </span>
          {meta && <span className="text-xs text-muted truncate">{meta}</span>}
        </span>
      </button>
    );
  };

  const closeSelectedFriend = () => {
    const id = selectedFriend?.id;
    setSelectedFriend(null);
    if (!id) return;
    void fetchFriendRelation(id).then((r) => patchRelation(id, r));
    reloadFriends();
    reloadRequests();
  };

  const moreButton = (f: FriendRow) => (
    <button
      type="button"
      aria-label={`${f.name} — diğer seçenekler`}
      onClick={() => setMenuFor(f)}
      className="shrink-0 w-10 h-10 flex items-center justify-center text-xl leading-none text-muted active:scale-90 transition-transform"
    >
      ⋯
    </button>
  );

  /** Arama / tüm üyeler satırı — ilişkiye göre TEK yazılı düğme. */
  const userRow = (u: FriendSearchResult) => {
    const busy = busyId === u.id;
    const friend = friends?.find((f) => f.friend_id === u.id);
    const meta =
      u.relation === 'accepted'
        ? 'Arkadaşın'
        : u.relation === 'pending_outgoing'
          ? 'Yanıt bekleniyor'
          : u.relation === 'pending_incoming'
            ? 'Seni eklemek istiyor'
            : null;
    return (
      <div key={u.id} className={rowCls}>
        {personButton(u.id, u.name, u.avatar_url, meta)}
        {u.relation === 'accepted' ? (
          <>
            <Pill kind="oyna" ariaLabel={`${u.name} ile oyna`} onClick={() => play(u.id, 2)} />
            {friend && moreButton(friend)}
          </>
        ) : u.relation === 'pending_outgoing' ? (
          <Pill kind="gonderildi" ariaLabel={`${u.name} — isteği iptal et`} disabled={busy} onClick={() => void handleCancel(u.id)} />
        ) : u.relation === 'pending_incoming' ? (
          <Pill kind="kabul" ariaLabel={`${u.name} — isteği kabul et`} disabled={busy} onClick={() => void handleRespond(u.id, true)} />
        ) : (
          <Pill kind="ekle" ariaLabel={`${u.name} — arkadaş ekle`} disabled={busy} onClick={() => void handleSend(u.id)} />
        )}
      </div>
    );
  };

  return (
    <Modal title="Arkadaşlar" onClose={onClose}>
      <div className="flex flex-col gap-4">
        {/* Doğrudan paylaşım — canlı oyun formundakiyle aynı (`useInviteShare`). */}
        <div className="flex flex-col gap-1.5">
          <button
            type="button"
            onClick={() => void invite.share()}
            className="btn-raised btn-raised-orange min-h-[52px] rounded-md bg-orange text-white font-sans text-[15px] font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform flex items-center justify-center gap-2"
          >
            <span aria-hidden className="text-lg leading-none">+</span> Arkadaşını davet et
          </button>
          <span className="text-center text-[11px] text-muted">
            WhatsApp ya da istediğin uygulamayla link gönder
          </span>
        </div>

        {/* Bekleyen istekler EN ÜSTTE, davet düğmesinin hemen altında
            (kullanıcı isteği, 27 Eylül 2026) — arama/"Tüm oyuncular"
            görünümünde de kaybolmaz. Gelenler yanıt beklediği için büyük
            kart; Reddet onaysız. */}
        {requests && requests.length > 0 && (
          <div className="flex flex-col gap-2">
            <span className={sectionCls}>İstekler · {requests.length}</span>
            {requests.map((r) => (
              <div
                key={r.requester_id}
                className="flex flex-col gap-2.5 p-3 rounded-xl bg-[#FFF7ED] border-[1.5px] border-orange"
              >
                {personButton(r.requester_id, r.name, r.avatar_url, 'Seni arkadaş olarak eklemek istiyor')}
                <div className="flex gap-2">
                  <button
                    type="button"
                    disabled={busyId === r.requester_id}
                    onClick={() => void handleRespond(r.requester_id, false)}
                    className="flex-1 min-h-[42px] rounded-md btn-raised-neutral bg-panel border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-40"
                  >
                    Reddet
                  </button>
                  <button
                    type="button"
                    disabled={busyId === r.requester_id}
                    onClick={() => void handleRespond(r.requester_id, true)}
                    className="flex-[1.5] min-h-[42px] rounded-md btn-raised btn-raised-orange bg-orange text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform disabled:opacity-40"
                  >
                    Kabul et
                  </button>
                </div>
                {/* Yalnızca "Engelle" (4 Ekim 2026, kullanıcı kararı): istek
                    kartında şikayet YOK — şikayet oyunun sohbetine özeldir. */}
                <button
                  type="button"
                  disabled={busyId === r.requester_id}
                  onClick={() => setBlockTarget({ id: r.requester_id, name: r.name })}
                  className="self-center text-[11px] font-bold uppercase tracking-[1px] text-muted underline underline-offset-2 active:opacity-70 disabled:opacity-40"
                >
                  Engelle
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Gönderdiğin, cevap bekleyen istekler — gelen isteklerin ALTINDA
            (kullanıcı isteği). Yanıt SENDEN beklenmediği için küçük satır;
            "Geri al" onaysız (tekrar eklemek tek dokunuş). */}
        {sent.length > 0 && (
          <div className="flex flex-col gap-2">
            <span className={sectionCls}>Gönderdiğin istekler · {sent.length}</span>
            <div className={listCls}>
              {sent.map((r) => (
                <div key={r.friend_id} className={rowCls}>
                  {personButton(r.friend_id, r.name, r.avatar_url, 'Cevap bekleniyor')}
                  <Pill
                    kind="geriAl"
                    ariaLabel={`${r.name} — isteği geri al`}
                    disabled={busyId === r.friend_id}
                    onClick={() => void handleCancel(r.friend_id)}
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Liste başlığı: sağda görünüm değiştirici. Arama hemen altında,
            listenin yakınında (kullanıcı isteği). "Tüm oyuncular"da sayı
            yazılmaz. */}
        <div className="flex flex-col gap-2">
          <div className="flex items-center justify-between gap-2">
            <span className={sectionCls}>
              {showAll
                ? 'Tüm oyuncular'
                : `Arkadaşların${friends && friends.length > 0 ? ` · ${friends.length}` : ''}`}
            </span>
            <button
              type="button"
              onClick={() => setShowAll((v) => !v)}
              className="shrink-0 min-h-[36px] text-[10px] uppercase tracking-[1.5px] font-mono font-bold text-accent active:opacity-70"
            >
              {showAll ? '← Arkadaşlar' : 'Tüm oyuncular →'}
            </button>
          </div>

          <input
            className="w-full min-h-[46px] bg-panel border border-border rounded-md px-3.5 text-text outline-none focus:border-accent transition-colors"
            type="search"
            aria-label="Oyuncu ara"
            placeholder="Oyuncu ara: isim ya da takma ad"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            autoFocus={initialTab === 'search'}
          />

          {searchActive ? (
            searching ? (
              <LoadingNote py="py-4" />
            ) : results.length === 0 ? (
              <p className="text-sm text-muted text-center leading-relaxed py-2" style={{ margin: 0 }}>
                Kimse bulunamadı. Kelimeki'de değilse yukarıdan davet linki gönder.
              </p>
            ) : (
              <>
                <span className="text-xs text-muted">"{query.trim()}" için {results.length} oyuncu</span>
                <div className={listCls}>
                  <ScrollArea className="max-h-[55vh]">{results.map(userRow)}</ScrollArea>
                </div>
              </>
            )
          ) : showAll ? (
            allUsers === null ? (
              <LoadingNote py="py-4" />
            ) : (
              <div className={listCls}>
                <ScrollArea scrollRef={allUsersScrollRef} className="max-h-[55vh]">
                  {allUsers.map(userRow)}
                  {allUsers.length === 0 && !allUsersHasMore && (
                    <p className="text-muted text-xs font-mono py-4 text-center">Başka oyuncu yok.</p>
                  )}
                  {allUsersHasMore && (
                    <div ref={allUsersSentinelRef} className="py-2 text-center">
                      <span className="text-muted text-[10px] font-mono">
                        {allUsersLoadingMore ? 'Yükleniyor…' : ''}
                      </span>
                    </div>
                  )}
                </ScrollArea>
              </div>
            )
          ) : friends === null ? (
            <LoadingNote py="py-4" />
          ) : friends.length === 0 ? (
            <div className="flex flex-col items-center gap-2 py-4 text-center">
              <p className="text-lg font-bold text-text" style={{ margin: 0 }}>
                Henüz arkadaşın yok
              </p>
              <p className="text-sm text-muted leading-relaxed" style={{ margin: 0 }}>
                Bir link gönder; arkadaşın linke dokunup üye olunca burada belirir ve hemen
                oyuna çağırırsın.
              </p>
            </div>
          ) : (
            <div className={listCls}>
              <ScrollArea className="max-h-[55vh]">
                {friends.map((f) => (
                  <div key={f.friend_id} className={rowCls}>
                    {personButton(f.friend_id, f.name, f.avatar_url, friendSinceLabel(f.since, true))}
                    <Pill kind="oyna" ariaLabel={`${f.name} ile oyna`} onClick={() => play(f.friend_id, 2)} />
                    {moreButton(f)}
                  </div>
                ))}
              </ScrollArea>
            </div>
          )}
        </div>

        <button
          type="button"
          onClick={() => setBlockedListOpen(true)}
          className="self-center text-[11px] font-bold uppercase tracking-[1px] text-muted underline underline-offset-2 active:opacity-70"
        >
          Engellediklerim
        </button>
      </div>

      {invite.fallbackOpen && invite.inviteUrl && (
        <InviteShareFallback url={invite.inviteUrl} onClose={invite.closeFallback} />
      )}

      {selectedFriend && <PlayerScoreCard member={selectedFriend} onClose={closeSelectedFriend} />}

      {/* ⋯ kişi menüsü — alttan açılır. */}
      {menuFor &&
        createPortal(
          <div className="fixed inset-0 z-[200] flex items-end justify-center">
            <div className="absolute inset-0 bg-[rgba(15,23,42,0.45)]" onClick={() => setMenuFor(null)} aria-hidden />
            <div
              ref={menuRef}
              role="dialog"
              aria-modal="true"
              aria-label={menuFor.name}
              tabIndex={-1}
              className="relative w-full max-w-[460px] bg-panel rounded-t-[22px] shadow-[0_-20px_45px_rgba(15,23,42,0.35)] px-5 pt-3 flex flex-col outline-none"
              style={{ paddingBottom: 'calc(1.5rem + env(safe-area-inset-bottom))' }}
            >
              <span className="self-center w-10 h-[5px] rounded-full bg-[#C7D0DC] mb-3" aria-hidden />
              <div className="flex items-center gap-3 pb-3 border-b border-border">
                <Avatar url={menuFor.avatar_url} name={menuFor.name} size={44} />
                <span className="flex flex-col gap-0.5 min-w-0">
                  <span className="text-[17px] font-bold text-text truncate">{menuFor.name}</span>
                  {friendSinceLabel(menuFor.since) && (
                    <span className="text-xs text-muted">{friendSinceLabel(menuFor.since)}</span>
                  )}
                </span>
              </div>
              {[
                {
                  label: 'Skor kartını gör',
                  act: () => setSelectedFriend(toPlayerSummary(menuFor.friend_id, menuFor.name, menuFor.avatar_url)),
                },
                // OYNA düğmesi 2 kişilik kurar; menü ikisini de açıkça sunar.
                { label: '2 kişilik oyun kur', act: () => play(menuFor.friend_id, 2) },
                { label: '4 kişilik oyun kur', act: () => play(menuFor.friend_id, 4) },
                // Moderasyon menüsü DEĞİL, "geri al" kısayolu — yalnızca bir
                // durum varsa (yeni şikayet sohbette açılır, bkz.
                // FriendModerationModal).
                ...(moderation.reported.has(menuFor.friend_id) || moderation.blocked.has(menuFor.friend_id)
                  ? [
                      {
                        label: 'Sessize alma / şikayet ayarları',
                        act: () =>
                          setModerationTarget({
                            userId: menuFor.friend_id,
                            name: menuFor.name,
                            avatarUrl: menuFor.avatar_url,
                            blocked: moderation.blocked.has(menuFor.friend_id),
                            reported: moderation.reported.has(menuFor.friend_id),
                          }),
                      },
                    ]
                  : []),
                { label: 'Arkadaşlıktan çıkar', danger: true, act: () => setConfirmRemove(menuFor) },
              ].map((it) => (
                <button
                  key={it.label}
                  type="button"
                  onClick={() => {
                    setMenuFor(null);
                    it.act();
                  }}
                  className={`min-h-[52px] text-left text-[15px] font-bold border-b border-[#EEF1F5] last:border-b-0 active:opacity-70 ${
                    'danger' in it && it.danger ? 'text-red' : 'text-text'
                  }`}
                >
                  {it.label}
                </button>
              ))}
            </div>
          </div>,
          document.body,
        )}

      {blockTarget && (
        <BlockConfirmModal
          name={blockTarget.name}
          onConfirm={async () => {
            // Önce engel, sonra isteği reddet: engel başarısızsa istek yerinde
            // kalır (kullanıcı "engelledim" sanmaz); ret başarısız olursa engel
            // kalır ve istek zaten engelli kişiden geldiğinden zararsızdır.
            await blockUser(blockTarget.id);
            await respondFriendRequest(blockTarget.id, false);
            patchRelation(blockTarget.id, null);
            reloadRequests();
            reloadModeration();
          }}
          onClose={() => setBlockTarget(null)}
        />
      )}

      {blockedListOpen && (
        <BlockedUsersModal
          onClose={(changed) => {
            setBlockedListOpen(false);
            if (changed) reloadModeration();
          }}
        />
      )}

      {moderationTarget && (
        <FriendModerationModal
          target={moderationTarget}
          onClose={(changed) => {
            setModerationTarget(null);
            if (changed) reloadModeration();
          }}
        />
      )}

      {confirmRemove && (
        <ConfirmDialog
          dialogRef={confirmRemoveRef}
          ariaLabel="Arkadaşlıktan Çıkar"
          title="Arkadaşlıktan Çıkar"
          message={`${confirmRemove.name} ile arkadaşsınız. Arkadaşlıktan çıkmak mı istiyorsunuz?`}
          confirmLabel="Çıkar"
          busy={busyId === confirmRemove.friend_id}
          onConfirm={handleConfirmRemove}
          onCancel={() => setConfirmRemove(null)}
        />
      )}
    </Modal>
  );
}
