-- Kelimeki — Hamle Avı ölçümü (`hamle_avi_events`, ROADMAP #48, 3 Kasım 2026)
--
-- NEDEN VAR: admin panelinde "kaç kişi oynadı, toplam oyun, bulma oranı, süre, seri"
-- kutuları isteniyor. `hamle_avi_stats` yalnızca ÜYENİN rekorunu ve görülen bulmaca
-- listesini tutar; bulundu/bulunamadı sonucu hiçbir yerde yoktu.
--
-- GİZLİLİK (tutorial_events/game_starts ile AYNI karar): `user_id` YOK ve bilerek
-- eklenmedi — `anon_id` (cihazda üretilen rastgele kod) ile hesap kimliği aynı satırda
-- ASLA bulunmaz (Gizlilik §6). `is_guest` yalnızca "girişli miydi" bayrağıdır, kimlik
-- değil. Metin: Gizlilik §6 "dokuz durum" (9) — web `LegalContent.tsx` ↔ port
-- `legal_modals.dart`.
--
-- `source`: 'prod' yalnızca kelimeki.com. Preview/yerel testler 'preview' yazar ve admin
-- RPC'si bunları SAYMAZ (kullanıcı preview'da deneme oynuyor; sayılara karışmasın).

create table if not exists public.hamle_avi_events (
  id          uuid primary key default gen_random_uuid (),
  anon_id     uuid,
  is_guest    boolean not null default (auth.uid() is null),
  puzzle_id   integer not null,
  -- 'found'  → doğru hamle bulundu
  -- 'missed' → süre bitti
  -- 'left'   → bulmaca sürerken çıkıldı (ÇIK/logo)
  result      text not null check (result in ('found', 'missed', 'left')),
  -- bulmacada geçen süre (sn), 0..180 (+ pay)
  seconds     integer not null check (seconds >= 0 and seconds <= 300),
  -- Sonuçtan ÖNCEKİ seri (bulununca yeni seri = streak_before + 1)
  streak_before integer not null check (streak_before >= 0 and streak_before <= 5000),
  source      text not null default 'prod' check (source in ('prod', 'preview')),
  platform    text,
  app_version text,
  created_at  timestamptz not null default now()
);

comment on table public.hamle_avi_events is 'Hamle Avı bulmaca sonuçlarının anonim ölçümü — admin "Hamle Avı" kartı için. anon_id istemcide üretilen rastgele bir uuid''dir, hiçbir hesapla ilişkilendirilmez; user_id kolonu YOKTUR (tutorial_events/game_starts ile aynı gizlilik kararı).';

create index if not exists hamle_avi_events_created_at_idx on public.hamle_avi_events (created_at desc);

alter table public.hamle_avi_events enable row level security;

-- Yazma iki istemci rolüne açık (misafir de girişli de oynar); OKUMA hiçbirine açık değil.
create policy hamle_avi_events_insert_anon on public.hamle_avi_events
  for insert to anon with check (true);
create policy hamle_avi_events_insert_authenticated on public.hamle_avi_events
  for insert to authenticated with check (true);

revoke all on public.hamle_avi_events from anon, authenticated;
grant insert on public.hamle_avi_events to anon, authenticated;
grant select, insert, update, delete on public.hamle_avi_events to service_role;

-- ── ADMIN: Hamle Avı kartı ──────────────────────────────────────────────────
-- Tek jsonb: kutular + günlük seri. Günler İSTANBUL günü (admin RPC'lerinin ortak kuralı).
-- Kişi sayıları BENZERSİZ CİHAZ (anon_id) sayar, null anon_id (depolama kapalı) adette
-- sayılır benzersizde sayılmaz. `members_*` ise `hamle_avi_stats`tan (hesaba bağlı rekor
-- tablosu) gelir — onlar zaman penceresinden bağımsız, tüm zamanlar.
create or replace function public.admin_hamle_avi_stats (p_days integer default 30, p_source text default 'prod')
  returns jsonb
  language plpgsql
  stable
  security definer
  set search_path to 'public'
  as $function$
declare
  v_since timestamptz := now() - (greatest(p_days, 1) || ' days')::interval;
  v_out jsonb;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  select jsonb_build_object(
    'players',          count(distinct e.anon_id),
    'players_members',  count(distinct e.anon_id) filter (where not e.is_guest),
    'players_guests',   count(distinct e.anon_id) filter (where e.is_guest),
    'plays',            count(*),
    'found',            count(*) filter (where e.result = 'found'),
    'missed',           count(*) filter (where e.result = 'missed'),
    'left',             count(*) filter (where e.result = 'left'),
    'avg_seconds_found', round(avg(e.seconds) filter (where e.result = 'found')::numeric, 1),
    'avg_streak_lost',  round(avg(e.streak_before) filter (where e.result <> 'found')::numeric, 2),
    'max_streak',       coalesce(max(e.streak_before + case when e.result = 'found' then 1 else 0 end), 0)
  ) into v_out
  from public.hamle_avi_events e
  where e.created_at >= v_since and e.source = p_source;

  v_out := v_out || jsonb_build_object(
    'members_with_record', (select count(*) from public.hamle_avi_stats s where s.best_streak > 0),
    'members_total',       (select count(*) from public.hamle_avi_stats s),
    'avg_record',          (select round(avg(s.best_streak)::numeric, 2) from public.hamle_avi_stats s where s.best_streak > 0),
    'max_record',          (select coalesce(max(s.best_streak), 0) from public.hamle_avi_stats s),
    'avg_seen_members',    (select round(avg(coalesce(array_length(s.seen_ids, 1), 0))::numeric, 1) from public.hamle_avi_stats s),
    'daily', coalesce((
      select jsonb_agg(jsonb_build_object('day', d.day, 'players', d.players, 'plays', d.plays, 'found', d.found) order by d.day)
      from (
        select (e.created_at at time zone 'Europe/Istanbul')::date as day,
               count(distinct e.anon_id) as players,
               count(*) as plays,
               count(*) filter (where e.result = 'found') as found
        from public.hamle_avi_events e
        where e.created_at >= v_since and e.source = p_source
        group by 1
      ) d
    ), '[]'::jsonb)
  );

  return v_out;
end;
$function$;

revoke all on function public.admin_hamle_avi_stats (integer, text) from public, anon;
grant execute on function public.admin_hamle_avi_stats (integer, text) to authenticated, service_role;
