// Harfik — admin paneli: üyeler ve oyun istatistikleri
import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import {
  fetchAdminMembers,
  fetchAdminGameCounts,
  fetchAdminUserActivitySeries,
  fetchAdminGameActivitySeries,
  fetchAdminFeedback,
  markFeedbackHandled,
} from '../lib/api';
import type {
  AdminMember,
  AdminGameCounts,
  AdminUserActivityPoint,
  AdminGameActivityPoint,
  AdminGameActivityScope,
  AdminActivityGranularity,
  AdminFeedbackRow,
} from '../lib/database.types';
import { AdminPlayerDetail } from './AdminPlayerDetail';
import { GrowthChart } from './GrowthChart';
import { trLower } from '../utils/turkish';

interface AdminDashboardProps {
  onClose: () => void;
}

type Tab = 'members' | 'games' | 'growth' | 'feedback';
type GameSubTab = 'total' | 2 | 4;
type GrowthSubTab = 'users' | 'games';
type GameCountFilter = 'total' | 2 | 4;
type MemberSortKey =
  | 'name'
  | 'nickname'
  | 'email'
  | 'created_at'
  | 'last_sign_in_at'
  | 'is_admin'
  | 'signup_channel';
type SortDir = 'asc' | 'desc';

const PERIOD_OPTIONS: Record<AdminActivityGranularity, readonly number[]> = {
  day: [7, 30, 90],
  week: [4, 8, 26],
  month: [6, 12, 24],
  year: [1, 2, 3],
};

const GRANULARITY_LABEL: Record<AdminActivityGranularity, string> = {
  day: 'Günlük',
  week: 'Haftalık',
  month: 'Aylık',
  year: 'Yıllık',
};

const PERIOD_UNIT_LABEL: Record<AdminActivityGranularity, string> = {
  day: 'Gün',
  week: 'Hafta',
  month: 'Ay',
  year: 'Yıl',
};

const SCOPE_LABEL: Record<AdminGameActivityScope, string> = {
  total: 'Tümü',
  registered: 'Kayıtlı',
  guest: 'Misafir',
};

/** Saniyeyi "X dk Y sn" biçiminde döner; veri yoksa (null) "—". */
function fmtDuration(seconds: number | null): string {
  if (seconds == null || !Number.isFinite(seconds)) return '—';
  const s = Math.round(seconds);
  const m = Math.floor(s / 60);
  const r = s % 60;
  return m > 0 ? `${m} dk ${r} sn` : `${r} sn`;
}

/** Null olmayan değerlerin ortalaması; hiçbiri yoksa null. */
function avgOf(values: (number | null)[]): number | null {
  const nums = values.filter((v): v is number => v != null);
  if (nums.length === 0) return null;
  return nums.reduce((a, b) => a + b, 0) / nums.length;
}

function fmtDate(iso: string | null) {
  if (!iso) return '—';
  const d = new Date(iso);
  const date = d.toLocaleDateString('tr-TR');
  const time = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return `${date} ${time}`;
}

function memberName(m: AdminMember) {
  return [m.first_name, m.last_name].filter(Boolean).join(' ').trim() || m.username || '—';
}

function memberNickname(m: AdminMember) {
  return m.display_name || '—';
}

function memberChannelLabel(m: AdminMember) {
  return m.signup_channel === 'form' ? 'Form' : 'Direkt';
}

function memberSortValue(m: AdminMember, key: MemberSortKey): string | number {
  switch (key) {
    case 'name':
      return trLower(memberName(m));
    case 'nickname':
      return trLower(memberNickname(m));
    case 'email':
      return trLower(m.email ?? '');
    case 'created_at':
      return m.created_at ? new Date(m.created_at).getTime() : 0;
    case 'last_sign_in_at':
      return m.last_sign_in_at ? new Date(m.last_sign_in_at).getTime() : 0;
    case 'is_admin':
      return m.is_admin ? 1 : 0;
    case 'signup_channel':
      return trLower(memberChannelLabel(m));
  }
}

export function AdminDashboard({ onClose }: AdminDashboardProps) {
  const [tab, setTab] = useState<Tab>('members');
  const [members, setMembers] = useState<AdminMember[] | null>(null);
  const [gameCounts, setGameCounts] = useState<AdminGameCounts[] | null>(null);
  const [gameSubTab, setGameSubTab] = useState<GameSubTab>('total');
  const [error, setError] = useState<string | null>(null);
  const [selectedMember, setSelectedMember] = useState<AdminMember | null>(null);
  const [growthSubTab, setGrowthSubTab] = useState<GrowthSubTab>('users');
  const [userActivity, setUserActivity] = useState<AdminUserActivityPoint[] | null>(null);
  const [gameActivity, setGameActivity] = useState<AdminGameActivityPoint[] | null>(null);
  const [granularity, setGranularity] = useState<AdminActivityGranularity>('day');
  const [period, setPeriod] = useState<number>(30);
  const [gameScope, setGameScope] = useState<AdminGameActivityScope>('total');
  const [gamePlayerCount, setGamePlayerCount] = useState<GameCountFilter>('total');
  const [memberSearch, setMemberSearch] = useState('');
  const [sortKey, setSortKey] = useState<MemberSortKey>('created_at');
  const [sortDir, setSortDir] = useState<SortDir>('desc');
  const [feedback, setFeedback] = useState<AdminFeedbackRow[] | null>(null);

  useEffect(() => {
    fetchAdminMembers()
      .then(setMembers)
      .catch((e) => setError(String(e)));
    fetchAdminGameCounts()
      .then(setGameCounts)
      .catch((e) => setError(String(e)));
    fetchAdminFeedback()
      .then(setFeedback)
      .catch((e) => setError(String(e)));
  }, []);

  useEffect(() => {
    setUserActivity(null);
    fetchAdminUserActivitySeries(period, granularity)
      .then(setUserActivity)
      .catch((e) => setError(String(e)));
  }, [period, granularity]);

  useEffect(() => {
    setGameActivity(null);
    fetchAdminGameActivitySeries(
      period,
      granularity,
      gameScope,
      gamePlayerCount === 'total' ? undefined : gamePlayerCount,
    )
      .then(setGameActivity)
      .catch((e) => setError(String(e)));
  }, [period, granularity, gameScope, gamePlayerCount]);

  function selectGranularity(g: AdminActivityGranularity) {
    setGranularity(g);
    setPeriod(PERIOD_OPTIONS[g][1]);
  }

  function toggleSort(key: MemberSortKey) {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  }

  const filteredMembers = useMemo(() => {
    if (!members) return null;
    const q = trLower(memberSearch.trim());
    const filtered = q
      ? members.filter(
          (m) => trLower(memberName(m)).includes(q) || trLower(memberNickname(m)).includes(q),
        )
      : members;
    return [...filtered].sort((a, b) => {
      const av = memberSortValue(a, sortKey);
      const bv = memberSortValue(b, sortKey);
      const cmp =
        typeof av === 'string' ? av.localeCompare(bv as string, 'tr') : (av as number) - (bv as number);
      return sortDir === 'asc' ? cmp : -cmp;
    });
  }, [members, memberSearch, sortKey, sortDir]);

  function SortHeader({ label, sortKeyFor, className }: { label: string; sortKeyFor: MemberSortKey; className?: string }) {
    const active = sortKey === sortKeyFor;
    return (
      <th
        onClick={() => toggleSort(sortKeyFor)}
        className={`py-2 pr-3 font-bold cursor-pointer select-none hover:text-text transition-colors ${className ?? ''}`}
      >
        <span className="inline-flex items-center gap-1">
          {label}
          <span className={active ? 'text-accent' : 'text-border'}>{active && sortDir === 'desc' ? '▼' : '▲'}</span>
        </span>
      </th>
    );
  }

  const tabBtn = (active: boolean) =>
    `flex-1 py-2.5 rounded-md font-sans text-[11px] font-bold uppercase tracking-[1px] transition-colors ${
      active ? 'bg-accent text-white' : 'bg-panel text-muted border border-border'
    }`;

  const counts2 = gameCounts?.find((g) => g.player_count === 2) ?? { started: 0, finished: 0 };
  const counts4 = gameCounts?.find((g) => g.player_count === 4) ?? { started: 0, finished: 0 };
  const totals = {
    started: (gameCounts ?? []).reduce((s, g) => s + g.started, 0),
    finished: (gameCounts ?? []).reduce((s, g) => s + g.finished, 0),
  };
  const activeCounts =
    gameSubTab === 'total' ? totals : gameSubTab === 2 ? counts2 : counts4;
  const unhandledFeedbackCount = feedback?.filter((f) => !f.handled).length ?? 0;

  function toggleFeedbackHandled(f: AdminFeedbackRow) {
    const next = !f.handled;
    setFeedback((prev) => prev?.map((x) => (x.id === f.id ? { ...x, handled: next } : x)) ?? prev);
    void markFeedbackHandled(f.id, next);
  }

  return createPortal(
    <div
      className="fixed inset-0 z-[150] flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[640px] bg-panel border border-[#B8C2D1] rounded-xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] max-h-[85vh] flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="shrink-0 flex flex-col gap-3 px-5 pt-5 pb-4 border-b border-border">
          <div className="flex items-center justify-between">
            <h2 className="font-mono text-sm font-bold tracking-[1.5px] uppercase text-accent">
              Admin Paneli
            </h2>
            <button
              onClick={onClose}
              aria-label="Kapat"
              className="text-muted hover:text-text text-lg leading-none w-7 h-7 flex items-center justify-center rounded active:scale-90 transition-transform"
            >
              ✕
            </button>
          </div>
          <div className="flex gap-1.5">
            <button className={tabBtn(tab === 'members')} onClick={() => setTab('members')}>
              Üyeler
            </button>
            <button className={tabBtn(tab === 'games')} onClick={() => setTab('games')}>
              Oyunlar
            </button>
            <button className={tabBtn(tab === 'growth')} onClick={() => setTab('growth')}>
              Büyüme
            </button>
            <button className={tabBtn(tab === 'feedback')} onClick={() => setTab('feedback')}>
              Geri Bildirim{unhandledFeedbackCount > 0 ? ` (${unhandledFeedbackCount})` : ''}
            </button>
          </div>
        </div>

        <div className="overflow-y-auto px-5 pt-4 pb-5 flex flex-col gap-4">
          {error && <div className="text-xs font-mono text-red">{error}</div>}

          {tab === 'members' && (
            <>
              <input
                type="text"
                value={memberSearch}
                onChange={(e) => setMemberSearch(e.target.value)}
                placeholder="İsim ya da nickname ara…"
                className="w-full bg-bg border border-border rounded-md px-3 py-2 text-[11px] font-mono text-text outline-none focus:border-accent transition-colors"
              />

              {members === null ? (
                <div className="text-xs font-mono text-muted text-center py-6">Yükleniyor…</div>
              ) : members.length === 0 ? (
                <div className="text-xs font-mono text-muted text-center py-6">
                  Kayıtlı üye yok.
                </div>
              ) : filteredMembers && filteredMembers.length === 0 ? (
                <div className="text-xs font-mono text-muted text-center py-6">
                  Aramayla eşleşen üye yok.
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-[11px] font-mono border-collapse">
                    <thead>
                      <tr className="text-left text-muted border-b border-border">
                        <SortHeader label="İsim" sortKeyFor="name" />
                        <SortHeader label="Nickname" sortKeyFor="nickname" />
                        <SortHeader label="E-posta" sortKeyFor="email" />
                        <SortHeader label="Kanal" sortKeyFor="signup_channel" />
                        <SortHeader label="Katılma" sortKeyFor="created_at" />
                        <SortHeader label="Son Giriş" sortKeyFor="last_sign_in_at" />
                        <SortHeader label="Rol" sortKeyFor="is_admin" className="pr-0" />
                      </tr>
                    </thead>
                    <tbody>
                      {filteredMembers?.map((m) => (
                        <tr
                          key={m.id}
                          onClick={() => setSelectedMember(m)}
                          className="border-b border-border/50 cursor-pointer hover:bg-bg/60 active:opacity-70"
                        >
                          <td className="py-2 pr-3 text-text whitespace-nowrap">{memberName(m)}</td>
                          <td className="py-2 pr-3 text-text whitespace-nowrap">{memberNickname(m)}</td>
                          <td className="py-2 pr-3 text-text whitespace-nowrap">{m.email ?? '—'}</td>
                          <td className="py-2 pr-3 text-muted whitespace-nowrap">{memberChannelLabel(m)}</td>
                          <td className="py-2 pr-3 text-muted whitespace-nowrap">{fmtDate(m.created_at)}</td>
                          <td className="py-2 pr-3 text-muted whitespace-nowrap">{fmtDate(m.last_sign_in_at)}</td>
                          <td className="py-2 whitespace-nowrap">
                            {m.is_admin ? (
                              <span className="text-accent font-bold">Admin</span>
                            ) : (
                              <span className="text-muted">Üye</span>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
              <div className="text-[10px] font-mono text-muted text-right">
                {memberSearch.trim() && members
                  ? `${filteredMembers?.length ?? 0} / ${members.length} üye`
                  : `Toplam ${members?.length ?? 0} üye`}
              </div>
            </>
          )}

          {tab === 'games' && (
            <>
              <div className="flex gap-1.5">
                {(['total', 2, 4] as const).map((t) => (
                  <button
                    key={t}
                    className={tabBtn(gameSubTab === t)}
                    onClick={() => setGameSubTab(t)}
                  >
                    {t === 'total' ? 'Toplam' : `${t} Kişilik`}
                  </button>
                ))}
              </div>

              {gameCounts === null ? (
                <div className="text-xs font-mono text-muted text-center py-6">Yükleniyor…</div>
              ) : (
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-bg border border-border rounded-lg p-4 flex flex-col items-center gap-1">
                    <div className="text-[10px] font-mono uppercase tracking-[1px] text-muted">
                      Başlatılan
                    </div>
                    <div className="text-2xl font-bold font-mono text-text">
                      {activeCounts.started}
                    </div>
                  </div>
                  <div className="bg-bg border border-border rounded-lg p-4 flex flex-col items-center gap-1">
                    <div className="text-[10px] font-mono uppercase tracking-[1px] text-muted">
                      Bitirilen
                    </div>
                    <div className="text-2xl font-bold font-mono text-text">
                      {activeCounts.finished}
                    </div>
                  </div>
                </div>
              )}
            </>
          )}

          {tab === 'growth' && (
            <>
              <div className="flex gap-1.5">
                <button className={tabBtn(growthSubTab === 'users')} onClick={() => setGrowthSubTab('users')}>
                  Kullanıcılar
                </button>
                <button className={tabBtn(growthSubTab === 'games')} onClick={() => setGrowthSubTab('games')}>
                  Oyunlar
                </button>
              </div>

              <div className="flex gap-1.5">
                {(['day', 'week', 'month', 'year'] as const).map((g) => (
                  <button
                    key={g}
                    className={tabBtn(granularity === g)}
                    onClick={() => selectGranularity(g)}
                  >
                    {GRANULARITY_LABEL[g]}
                  </button>
                ))}
              </div>
              <div className="flex gap-1.5">
                {PERIOD_OPTIONS[granularity].map((p) => (
                  <button key={p} className={tabBtn(period === p)} onClick={() => setPeriod(p)}>
                    Son {p} {PERIOD_UNIT_LABEL[granularity]}
                  </button>
                ))}
              </div>

              {growthSubTab === 'users' ? (
                userActivity === null ? (
                  <div className="text-xs font-mono text-muted text-center py-6">Yükleniyor…</div>
                ) : (
                  <GrowthChart
                    data={userActivity}
                    granularity={granularity}
                    series={[{ key: 'signups', label: 'Yeni Kayıt', color: '#2a78d6' }]}
                  />
                )
              ) : (
                <>
                  <div className="flex gap-1.5">
                    {(['total', 'registered', 'guest'] as const).map((s) => (
                      <button key={s} className={tabBtn(gameScope === s)} onClick={() => setGameScope(s)}>
                        {SCOPE_LABEL[s]}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-1.5">
                    {(['total', 2, 4] as const).map((p) => (
                      <button key={p} className={tabBtn(gamePlayerCount === p)} onClick={() => setGamePlayerCount(p)}>
                        {p === 'total' ? 'Tüm Oyunlar' : `${p} Kişilik`}
                      </button>
                    ))}
                  </div>

                  {gameActivity === null ? (
                    <div className="text-xs font-mono text-muted text-center py-6">Yükleniyor…</div>
                  ) : (
                    <>
                      <GrowthChart
                        data={gameActivity}
                        granularity={granularity}
                        series={[
                          { key: 'game_starts', label: 'Başlatılan Oyun', color: '#eda100' },
                          { key: 'games_finished', label: 'Bitirilen Oyun', color: '#008300' },
                        ]}
                      />
                      <div className="grid grid-cols-3 gap-2">
                        <div className="bg-bg border border-border rounded-lg p-3 flex flex-col items-center gap-1">
                          <div className="text-[9px] font-mono uppercase tracking-[0.5px] text-muted text-center">
                            Ort. Süre
                          </div>
                          <div className="text-xs font-bold font-mono text-text">
                            {fmtDuration(avgOf(gameActivity.map((r) => r.avg_duration_seconds)))}
                          </div>
                        </div>
                        <div className="bg-bg border border-border rounded-lg p-3 flex flex-col items-center gap-1">
                          <div className="text-[9px] font-mono uppercase tracking-[0.5px] text-muted text-center">
                            Tek Oturum
                          </div>
                          <div className="text-xs font-bold font-mono text-text">
                            {fmtDuration(avgOf(gameActivity.map((r) => r.avg_duration_same_session_seconds)))}
                          </div>
                        </div>
                        <div className="bg-bg border border-border rounded-lg p-3 flex flex-col items-center gap-1">
                          <div className="text-[9px] font-mono uppercase tracking-[0.5px] text-muted text-center">
                            Çok Oturum
                          </div>
                          <div className="text-xs font-bold font-mono text-text">
                            {fmtDuration(avgOf(gameActivity.map((r) => r.avg_duration_multi_session_seconds)))}
                          </div>
                        </div>
                      </div>
                    </>
                  )}
                </>
              )}
            </>
          )}

          {tab === 'feedback' && (
            <>
              {feedback === null ? (
                <div className="text-xs font-mono text-muted text-center py-6">Yükleniyor…</div>
              ) : feedback.length === 0 ? (
                <div className="text-xs font-mono text-muted text-center py-6">
                  Henüz geri bildirim yok.
                </div>
              ) : (
                <div className="flex flex-col gap-2">
                  {feedback.map((f) => {
                    const sender = f.user_id ? members?.find((m) => m.id === f.user_id) : null;
                    const senderLabel = sender ? memberName(sender) : (f.email || 'Anonim');
                    return (
                      <div
                        key={f.id}
                        className={`bg-bg border border-border rounded-lg p-3 flex flex-col gap-1.5 ${
                          f.handled ? 'opacity-60' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between gap-2 text-[10px] font-mono text-muted">
                          <span className="truncate">
                            {senderLabel}
                            {sender && f.email ? ` · ${f.email}` : ''}
                          </span>
                          <span className="shrink-0">{fmtDate(f.created_at)}</span>
                        </div>
                        <p className="text-xs text-text whitespace-pre-wrap">{f.message}</p>
                        <button
                          onClick={() => toggleFeedbackHandled(f)}
                          className="self-start text-[10px] font-mono text-accent hover:underline"
                        >
                          {f.handled ? 'Okunmadı işaretle' : 'Okundu işaretle'}
                        </button>
                      </div>
                    );
                  })}
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {selectedMember && (
        <AdminPlayerDetail member={selectedMember} onClose={() => setSelectedMember(null)} />
      )}
    </div>,
    document.body,
  );
}
