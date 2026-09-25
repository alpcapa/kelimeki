-- Kelimeki — Canlı oyun sohbetinin "okundu" bilgisi SUNUCUDA (23 Eylül 2026).
--
-- Kullanıcı bildirdi: *"Android app'i açıp Danyal ile devam eden oyuna
-- girince mesajlaşma üstünde numara yoktu ama tıkladığımda yeni yazdığı 2
-- mesaj olduğunu gördüm. Bazen de okuduğum mesajları başka cihazdan açınca
-- yeniymiş gibi tekrar uyarı görüyorum."*
--
-- Sebep: okundu damgası CİHAZDAYDI (web `localStorage`, port
-- `chat_read_store.dart`). (1) Oyun bir cihazda İLK kez açılınca damga yok →
-- "eski mesajları yeni sayma" tohumu mevcut her şeyi okunmuş sayıyordu, yeni
-- gelmiş mesajlar dahil. (2) Bir cihazda okumak ötekine hiç ulaşmıyordu.
--
-- Tasarım:
--   * Kişi × oyun başına TEK satır, `last_read_at` = görülen en son mesajın
--     `created_at`i (mesajla AYNI saat kaynağı — istemci saatine güvenilmez).
--   * Yazma YALNIZCA `mark_online_game_chat_read` RPC'siyle ve yalnızca
--     İLERİ: `greatest(eski, yeni)`. Geç ulaşan eski bir istek (çevrimdışı
--     kuyruk, iki cihaz yarışı) başka cihazda okunmuş mesajları tekrar
--     "yeni" yapamaz. Gelecek bir zaman `now()`a kırpılır.
--   * Okuma doğrudan RLS ile, yalnızca KENDİ satırı. Ötekiler senin ne zaman
--     okuduğunu GÖREMEZ (bu bir "görüldü" özelliği değil).
--   * Oyun silinince / hesap silinince satır kendiliğinden gider (iki FK de
--     `on delete cascade` — `push_tokens` deseni, `delete-my-account`a ek iş
--     gerektirmez).
--
-- Port bu tabloyu HENÜZ kullanmıyor (inceleme dondurması, kullanıcı kararı
-- *"mobile dokunma"*) — o zamana kadar uygulama cihazdaki damgasıyla çalışır;
-- web her iki kaynağın büyüğünü alır.

create table public.online_game_chat_reads (
  online_game_id uuid not null references public.online_games (id) on delete cascade,
  user_id        uuid not null references auth.users (id) on delete cascade,
  last_read_at   timestamptz not null,
  updated_at     timestamptz not null default now(),
  primary key (online_game_id, user_id)
);

-- PK (online_game_id, user_id) oyun tarafını kapsıyor; hesap silme kaskadı
-- için user_id'nin kendi indeksi.
create index online_game_chat_reads_user_idx on public.online_game_chat_reads (user_id);

alter table public.online_game_chat_reads enable row level security;

create policy online_game_chat_reads_select_own on public.online_game_chat_reads
  for select using (user_id = (select auth.uid()));

revoke all on public.online_game_chat_reads from public, anon, authenticated;
grant select on public.online_game_chat_reads to authenticated;

create or replace function public.mark_online_game_chat_read(
  p_online_game_id uuid,
  p_read_at timestamptz
)
returns timestamptz
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_at  timestamptz := least(p_read_at, now());
  v_out timestamptz;
begin
  if v_uid is null then
    raise exception 'Oturum gerekli.' using errcode = '28000';
  end if;
  if p_read_at is null then
    raise exception 'Okunma zamanı eksik.' using errcode = '22004';
  end if;
  if not public.is_online_game_participant(p_online_game_id, v_uid) then
    raise exception 'Bu oyunun katılımcısı değilsiniz.' using errcode = '42501';
  end if;

  insert into public.online_game_chat_reads as r (online_game_id, user_id, last_read_at)
  values (p_online_game_id, v_uid, v_at)
  on conflict (online_game_id, user_id) do update
    set last_read_at = greatest(r.last_read_at, excluded.last_read_at),
        updated_at   = now()
  returning r.last_read_at into v_out;

  return v_out;
end;
$$;

revoke all on function public.mark_online_game_chat_read(uuid, timestamptz) from public, anon;
grant execute on function public.mark_online_game_chat_read(uuid, timestamptz) to authenticated;

comment on table public.online_game_chat_reads is
  'Canlı oyun sohbetinin kişi × oyun başına okundu damgası (görülen en son mesajın created_at''i). Yalnızca ileri gider — bkz. mark_online_game_chat_read.';
