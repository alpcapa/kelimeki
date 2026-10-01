-- Sohbet Kuralları onayı (25 Eylül 2026, kullanıcı isteği): bir kişi Canlı
-- oyunda İLK mesajını göndermeden önce bir kez "Sohbet Kuralları"nı kabul
-- eder. Onay HESABA bağlı (web ↔ mobil aynı satırı okur) ve tek seferliktir;
-- kurallar esaslı biçimde değişirse istemcideki `CHAT_RULES_VERSION` artırılır
-- ve herkese bir kez daha sorulur.
--
-- Kayıt bir KANIT: "bu kişi kuralları şu tarihte kabul etti". O yüzden iki
-- kolon da istemcinin doğrudan yazabileceği bir alan DEĞİL — `profiles`'ta
-- tablo düzeyinde update izni var (`profiles_update_self`), yani korumasız
-- bırakılsa biri geçmiş bir tarih yazabilirdi. Yazmanın tek yolu aşağıdaki
-- `accept_chat_rules` RPC'si; zaman damgası sunucunun `now()`ı.
-- Desen `keep_signup_utm_source` ile aynı (BEFORE trigger eski değeri geri
-- koyar), RPC geçişi transaction'a özel bir ayarla işaretliyor.
--
-- ⚠ Sunucu mesaj gönderimini bu onaya BAĞLAMIYOR (bilerek): mağazadaki
-- 1.1.0/1.1.1 mobil paketleri onay ekranını bilmiyor, kapı sunucuda olsaydı
-- o kullanıcılar sohbet edemezdi. Kapı istemcide; sunucu yalnızca kaydı tutar.

alter table public.profiles
  add column if not exists chat_rules_version integer,
  add column if not exists chat_rules_accepted_at timestamptz;

comment on column public.profiles.chat_rules_version is 'Kabul edilen Sohbet Kuralları metninin sürümü (istemcide CHAT_RULES_VERSION) — hiç kabul etmediyse null. Yalnızca accept_chat_rules() yazar.';
comment on column public.profiles.chat_rules_accepted_at is 'Sohbet Kuralları''nın kabul edildiği andaki sunucu zaman damgası — hiç kabul etmediyse null. Yalnızca accept_chat_rules() yazar.';

create or replace function public.keep_chat_rules_consent()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(current_setting('kelimeki.chat_rules_accept', true), '') <> 'on' then
    if tg_op = 'INSERT' then
      new.chat_rules_version := null;
      new.chat_rules_accepted_at := null;
    else
      new.chat_rules_version := old.chat_rules_version;
      new.chat_rules_accepted_at := old.chat_rules_accepted_at;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_keep_chat_rules_consent on public.profiles;
create trigger trg_keep_chat_rules_consent
  before insert or update on public.profiles
  for each row execute function public.keep_chat_rules_consent();

create or replace function public.accept_chat_rules(p_version integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  _uid uuid := auth.uid();
begin
  if _uid is null then
    raise exception 'Oturum açık değil.';
  end if;
  if p_version is null or p_version < 1 then
    raise exception 'Geçersiz kural sürümü.';
  end if;
  perform set_config('kelimeki.chat_rules_accept', 'on', true);
  -- Yalnızca İLERİ: daha eski bir istemcinin eski sürümle çağırması yeni
  -- sürümün kaydını ezmesin.
  update public.profiles
     set chat_rules_version = p_version,
         chat_rules_accepted_at = now()
   where id = _uid
     and (chat_rules_version is null or chat_rules_version < p_version);
  perform set_config('kelimeki.chat_rules_accept', '', true);
end;
$$;

revoke all on function public.accept_chat_rules(integer) from public;
revoke all on function public.accept_chat_rules(integer) from anon;
grant execute on function public.accept_chat_rules(integer) to authenticated;
revoke all on function public.keep_chat_rules_consent() from public, anon, authenticated;
