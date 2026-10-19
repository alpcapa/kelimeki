-- Kelimeki — Yarım kalan oyun hatırlatmasının ölçümü (`reminder_events`)
--
-- NEDEN VAR (11 Ekim 2026, kullanıcı): hatırlatma 1.1.2'den beri uygulamada
-- ama cihazda gelmediği görüldü ve asıl sebep tasarımdı — izin kartı yalnızca
-- logoyla çıkışta çıkıyor, yeni gelenlerin çoğu oyunu telefonu bırakarak
-- yarım bırakıyor, yani izin hiç sorulmuyor. *"Kimse kabul etmez bence. Ama
-- kart gösterildi / kabul edildi / reddedildi olaylarını koymak lazım."*
-- Bu tablo tek soruyu cevaplıyor: hatırlatma gerçekte kaç kez kuruluyor, kart
-- kaç kez gösteriliyor, kaç kişi kabul ediyor, ayrılışların kaçı izin yok
-- diye sessizce düşüyor.
--
-- `funnel_events`e DEĞİL, ayrı tabloya: oraya yeni olay eklemek gizlilik
-- metnindeki "yedi durum" listesini değiştirir (bkz. `docs/decisions/
-- funnel-v2.md` → "Mağaza sütunu"). `signup_events` ile aynı desen: kimliksiz,
-- yalnızca yazma.
--
-- ⚠ KİMLİK YOK: istemci `anon_id` GÖNDERMEZ ve hiçbir zaman göndermeyecek
-- (gizlilik metni anonim kodun sunucuya gittiği durumları sayıyor; kimliksiz
-- kayıt yeni bir durum açmaz). `anon_id` KOLONU ilk sürümden kalma ve
-- KULLANILMIYOR — canlıda kaldırma denemesi (`drop column`) MCP zaman aşımına
-- takıldı, kullanılmayan bir kolon için üretimle uğraşılmadı. Bir gün
-- temizlenirse bu dosyaya DOKUNMA, yeni migration yaz.
--
-- ⚠ SAYIM, KİŞİ DEĞİL: aynı cihaz aynı oyun için birden fazla satır yazabilir
-- (uygulama her arka plana gidişte ayrılış sayılır). Oranlar okunur, mutlak
-- "kaç kişi" okunmaz.
--
-- ⚠ OLAY LİSTESİ İKİ YERDE: aşağıdaki check ↔ `mobile/app/lib/src/data/
-- reminder_events.dart` (`kReminderEvents`); `reminder_events_parity_test.dart`
-- ikisini karşılaştırır.
--
-- NOT: canlıya `create table` + RLS + grant olarak uygulandı (yorum/indeks
-- ikinci migrationda).

create table if not exists public.reminder_events (
  id          uuid primary key default gen_random_uuid (),
  anon_id     uuid,
  -- 'card_shown'          → izin / ayar kartı ekrana geldi
  -- 'card_accept'         → kart onaylandı (HATIRLAT / AYARLARI AÇ)
  -- 'card_decline'        → ŞİMDİ DEĞİL
  -- 'os_granted'          → HATIRLAT'tan sonra sistem diyaloğu: izin verildi
  -- 'os_denied'           → HATIRLAT'tan sonra sistem diyaloğu: reddedildi
  -- 'set'                 → hatırlatma gerçekten kuruldu (izin vardı)
  -- 'skip_no_permission'  → ayrılış hatırlatmaya UYGUN (≥2 tur, yarım oyun)
  --                         ama izin yok → hiçbir şey kurulmadı
  event       text not null check (event in ('card_shown','card_accept','card_decline','os_granted','os_denied','set','skip_no_permission')),
  -- 'izin' → "Oyunun yarım kaldı — hatırlatalım mı?" · 'ayar' → "Bildirimler
  -- kapalı". Yalnızca kart olaylarında dolu; 'set'/'skip_no_permission' null.
  card        text check (card is null or card in ('izin','ayar')),
  platform    text check (platform is null or char_length(platform) <= 16),
  app_version text check (app_version is null or char_length(app_version) <= 32),
  created_at  timestamptz not null default now()
);
alter table public.reminder_events enable row level security;
create policy reminder_events_insert_anon on public.reminder_events for insert to anon with check (true);
create policy reminder_events_insert_authenticated on public.reminder_events for insert to authenticated with check (true);
grant insert on public.reminder_events to anon;
grant insert on public.reminder_events to authenticated;
grant select, insert, update, delete on public.reminder_events to service_role;
