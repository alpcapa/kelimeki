-- ENGEL, oyundan BAĞIMSIZ bir depoya kavuşuyor (4 Ekim 2026, kullanıcı kararı:
-- "sessize alan kişi bir daha onunla oyunda veya başka yerde karşılaşmayacağı
-- için 'Sessize al' yerine 'Engelle' demeliyiz … İstek kartında sadece Engelle").
--
-- NEDEN YENİ TABLO: `online_game_message_mutes` bir OYUNA bağlı (online_game_id
-- NOT NULL, PK içinde, ON DELETE CASCADE) ve `mute_online_game_participant`
-- yalnızca KABUL ETMİŞ katılımcıları kabul ediyor. Arkadaşlık isteği kartından
-- ya da henüz yanıtlanmamış oyun davetinden engelleyen kişinin ortak oyunu YOK.
--
-- Engel artık ÜÇ kaynaktan okunur (tek yer: `_is_blocked_by`):
--   * `user_blocks`                 — doğrudan "Engelle" (bu migration)
--   * `online_game_message_mutes`   — sohbette engelleme (eski "sessize al")
--   * `online_game_chat_reports`    — geri çekilmemiş şikayet
-- `_random_blocked` (rastgele eşleşme) aynı kaynağa bağlandı — kural iki yerde
-- yaşamasın.
--
-- RPC'ler: `block_user` · `unblock_user` (engel + sohbet engellerini temizler; açık
-- şikayetlere DOKUNMAZ) · `list_blocked_users` ("Engellediklerim").
-- Tabloya istemciden DOĞRUDAN erişim yok (RLS açık, politika yok, anon/
-- authenticated'a grant yok).
--
-- `blocker_id`/`blocked_id` auth.users'a ON DELETE CASCADE bağlı: hesap silme
-- kaskadı (`delete_account_cascade`) bu tabloyu ayrıca temizlemek zorunda kalmaz.

create table if not exists public.user_blocks (
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint user_blocks_not_self check (blocker_id <> blocked_id)
);

create index if not exists user_blocks_blocked_idx on public.user_blocks (blocked_id);

alter table public.user_blocks enable row level security;
revoke all on table public.user_blocks from anon, authenticated;
grant select, insert, update, delete on table public.user_blocks to service_role;

comment on table public.user_blocks is 'Kullanıcı engeli (oyundan bağımsız). Okuma/yazma yalnızca block_user/unblock_user/list_blocked_users RPC''lerinden.';

create or replace function public._is_blocked_by(p_blocker uuid, p_blocked uuid)
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $function$
  select exists (
    select 1 from public.user_blocks b
    where b.blocker_id = p_blocker and b.blocked_id = p_blocked
  ) or exists (
    select 1 from public.online_game_message_mutes m
    where m.muter_user_id = p_blocker and m.muted_user_id = p_blocked
  ) or exists (
    select 1 from public.online_game_chat_reports r
    where r.reporter_user_id = p_blocker
      and r.reported_user_id = p_blocked
      and r.withdrawn_at is null
  );
$function$;

create or replace function public._random_blocked(p_uid uuid, p_slots jsonb)
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $function$
  select exists (
    select 1
    from jsonb_array_elements(p_slots) as e(slot)
    where e.slot ->> 'type' = 'human'
      and public._is_blocked_by(p_uid, (e.slot ->> 'user_id')::uuid)
  );
$function$;

create or replace function public.block_user(p_target uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if auth.uid() is null then
    raise exception 'Oturum açık değil.';
  end if;
  if p_target is null or p_target = auth.uid() then
    raise exception 'Kendinizi engelleyemezsiniz.';
  end if;
  if not exists (select 1 from public.profiles where id = p_target) then
    raise exception 'Kullanıcı bulunamadı.';
  end if;

  insert into public.user_blocks (blocker_id, blocked_id)
  values (auth.uid(), p_target)
  on conflict (blocker_id, blocked_id) do nothing;
end;
$function$;

-- ⚠ AŞAĞIDAKİ `unblock_user` CANLIYA ARAÇLA UYGULANAMADI: gövdesinde `DELETE`
-- geçtiği için Supabase MCP aracı onay bekleyip 60 sn'de zaman aşımına uğruyor
-- (sorgu HİÇ çalışmıyor — doğrulandı: tablo/RPC sayısı 0 kaldı). Migration'ın
-- geri kalanı bu fonksiyon OLMADAN uygulandı (`20261004203040`); bu fonksiyon
-- Supabase panelinde SQL Editor'den ELLE çalıştırılır (durum: ROADMAP E).
create or replace function public.unblock_user(p_target uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if auth.uid() is null then
    raise exception 'Oturum açık değil.';
  end if;

  delete from public.user_blocks
  where blocker_id = auth.uid() and blocked_id = p_target;

  delete from public.online_game_message_mutes
  where muter_user_id = auth.uid() and muted_user_id = p_target;

  -- ⚠ Açık ŞİKAYETLERE dokunmaz: şikayeti geri çekmek ayrı bir adım
  -- (`withdraw_online_game_chat_reports`) — sohbet ayarlarındaki mevcut
  -- ayrım korunuyor. Açık şikayet sürdükçe kişi ENGELLİ sayılır.
end;
$function$;

create or replace function public.list_blocked_users()
returns table (blocked_user_id uuid, blocked_name text, blocked_avatar_url text, is_reported boolean)
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  return query
  with b as (
    select ub.blocked_id as uid from public.user_blocks ub where ub.blocker_id = v_uid
    union
    select m.muted_user_id from public.online_game_message_mutes m where m.muter_user_id = v_uid
    union
    select r.reported_user_id from public.online_game_chat_reports r
    where r.reporter_user_id = v_uid and r.withdrawn_at is null
  )
  select b.uid,
         coalesce(p.display_name, 'Bir kullanıcı'),
         p.avatar_url,
         exists (
           select 1 from public.online_game_chat_reports r2
           where r2.reporter_user_id = v_uid
             and r2.reported_user_id = b.uid
             and r2.withdrawn_at is null
         )
  from b
  left join public.profiles p on p.id = b.uid;
end;
$function$;

revoke all on function public.block_user(uuid) from public, anon;
revoke all on function public.unblock_user(uuid) from public, anon;
revoke all on function public.list_blocked_users() from public, anon;
grant execute on function public.block_user(uuid) to authenticated, service_role;
grant execute on function public.unblock_user(uuid) to authenticated, service_role;
grant execute on function public.list_blocked_users() to authenticated, service_role;
