-- `reminder_events` — kullanılmayan `anon_id` kolonunu KALDIR + açıklamayı düzelt.
--
-- İstemci `anon_id` hiç göndermiyor (kimliksiz sayaç, bkz. ilk migration
-- başlığı). Canlıda `drop column` MCP `apply_migration` ile üç kez zaman
-- aşımına uğradı (kilit yok, sonuç belirsiz kalıyordu); bu yüzden kullanıcı
-- Supabase SQL düzenleyicisinde ELLE çalıştırdı. SQL düzenleyicisi
-- `schema_migrations`a kayıt YAZMAZ — dosya ile canlı geçmiş ayrışmasın diye
-- kayıt satırı AŞAĞIDA elle eklenir (CLI'ın yaptığıyla aynı).
alter table public.reminder_events drop column if exists anon_id;

comment on table public.reminder_events is 'Yarım kalan oyun hatırlatmasının anonim ölçümü (kart gösterildi/kabul/ret, sistem izni, kuruldu, izinsiz düştü). KİMLİK YOK: ne anon_id ne user_id (signup_events ile aynı gizlilik kararı: gizlilik metni anonim kodun sunucuya gittiği durumları sayıyor, kimliksiz kayıt yeni bir durum açmaz).';

insert into supabase_migrations.schema_migrations (version, name, statements)
select '20261011170500', 'reminder_events_drop_anon_id', array[
  'alter table public.reminder_events drop column if exists anon_id;'
]
where not exists (select 1 from supabase_migrations.schema_migrations where version = '20261011170500');
