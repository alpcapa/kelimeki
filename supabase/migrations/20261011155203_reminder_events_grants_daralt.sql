-- `reminder_events` — istemci yetkilerini DARALT + indeks + açıklama.
--
-- Önceki migration `grant insert ... to anon, authenticated` yazmıştı ama bu
-- projede Supabase varsayılan olarak anon/authenticated'a TÜM yetkileri de
-- veriyor (canlıda ölçüldü: SELECT/UPDATE/DELETE/TRUNCATE dahil). RLS'te yalnız
-- INSERT politikası olduğundan fiilen engelliydi ama niyet "yalnızca ekle":
-- `beyin_ligi_grant_daralt` ile aynı ders. Yeni bir tablo migrationında
-- `revoke all ... from anon, authenticated` + dar grant YAZ.
revoke all on public.reminder_events from anon, authenticated;
grant insert on public.reminder_events to anon, authenticated;
create index if not exists reminder_events_created_at_idx on public.reminder_events (created_at desc);
comment on table public.reminder_events is 'Yarım kalan oyun hatırlatmasının anonim ölçümü (kart gösterildi/kabul/ret, sistem izni, kuruldu, izinsiz düştü). Kimlik taşımaz: anon_id istemcide üretilen rastgele bir uuid, hiçbir hesapla ilişkilendirilmez (tutorial_events ile aynı gizlilik kararı).';
