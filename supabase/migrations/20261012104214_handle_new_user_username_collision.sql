-- Kayıt hatası: "Database error saving new user" (12 Ekim 2026).
--
-- `handle_new_user` kullanıcı adını (`profiles.username`, UNIQUE) e-postanın
-- `@` ÖNCESİNDEN üretiyor ve iki istemci de `username` göndermiyor
-- (canlıda 106 profilin 105'i bu biçimde). `ahmet@gmail.com` kayıtlıyken
-- `ahmet@hotmail.com` ile kayıt olan biri `profiles_username_key`e çarpıyor;
-- trigger fırlatıyor, GoTrue işlemi geri alıp istemciye yalnızca genel
-- "Database error saving new user" (500) döndürüyor — kullanıcı nedenini
-- göremiyor, hata da `client_errors`ta "giris" etiketiyle yaşıyor.
-- (Android 1.1.3'te 11-12 Ekim'de 3 kayıt; çakışma ayrıca KANITLANAMADI —
-- başarısız denemeler işlemle birlikte geri alındığından e-posta kalmıyor —
-- ama kusur yapısal ve bu düzeltme çakışma sebep olmasa da zararsız.)
--
-- Düzeltme: çakışma yalnızca `profiles_username_key` ise kullanıcı adına
-- kullanıcı kimliğinden kısa bir ek konup bir kez yeniden denenir.
-- ⚠ BAŞKA bir benzersizlik çakışması (ör. takma ad `profiles_display_name_
-- tr_lower_key`) AYNEN fırlar: o, kullanıcıya "bu takma ad alınmış" demenin
-- doğru yolu ve istemcilerin `friendlyNicknameError`ı ona bağlı.
-- `username` hiçbir yerde anahtar/arama alanı değil: yalnızca sıralamalarda
-- ve menüde `display_name` boşken YEDEK görünen ad (grep'le doğrulandı).
--
-- `create or replace` aynı imzayla grant'leri korur (postgres + service_role);
-- ayrıca `security definer` + `search_path=public` yeniden yazıldı.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  _first     text;
  _last      text;
  _display   text;
  _channel   text;
  _gender    text;
  _birth     date;
  _marketing boolean;
  _terms     boolean;
  _utm       text;
  _username  text;
  _constraint text;
begin
  _first := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'firstName',
    ''
  );
  _last := coalesce(
    new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'lastName',
    ''
  );
  _display := coalesce(
    new.raw_user_meta_data ->> 'display_name',
    nullif(trim(_first || ' ' || _last), ''),
    split_part(new.email, '@', 1)
  );
  _channel := new.raw_user_meta_data ->> 'signup_channel';
  if _channel is null or _channel not in ('direct', 'form') then
    _channel := 'direct';
  end if;
  _gender := nullif(new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'gender', '');
  if _gender not in ('female', 'male', 'unspecified') then
    _gender := null;
  end if;
  begin
    _birth := nullif(new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'birthDate', '')::date;
  exception when others then
    _birth := null;
  end;
  _marketing := coalesce(
    (new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'marketingConsent')::boolean,
    false
  );
  -- Kullanım Koşulları onayı — iki istemci de gönderiyor, trigger bugüne
  -- kadar okumuyordu. Bozuk/eksik bir değerde `false`a düşer: onayı
  -- OLMADIĞI hâlde var göstermek, tersinden daha kötü.
  begin
    _terms := coalesce(
      (new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'agreedToTerms')::boolean,
      false
    );
  exception when others then
    _terms := false;
  end;
  -- Serbest metin (`?ref=` etiketi kullanıcı kontrolünde) — 32 karakterle
  -- sınırlanıyor ki funnel tablosunu uydurma uzun bir satır bozmasın.
  _utm := nullif(left(trim(
    coalesce(new.raw_user_meta_data -> 'sharedxp_pending_profile' ->> 'utmSource', '')
  ), 32), '');

  _username := coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1));

  -- İki deneme: ilkinde kullanıcı adı olduğu gibi; YALNIZCA `profiles_username_key`
  -- çakışırsa kimlikten türeyen kısa bir ekle ikinci kez (aynı e-posta öneki
  -- başka bir alan adıyla zaten kayıtlı). Başka her hata aynen fırlar.
  for _attempt in 1..2 loop
    begin
      insert into public.profiles (
        id, username, first_name, last_name, display_name, signup_channel,
        gender, birth_date, agreed_to_terms, marketing_consent,
        marketing_consent_at, signup_utm_source
      )
      values (
        new.id,
        _username,
        _first,
        _last,
        _display,
        _channel,
        _gender,
        _birth,
        _terms,
        _marketing,
        case when _marketing then now() else null end,
        _utm
      )
      on conflict (id) do nothing;
      exit;
    exception when unique_violation then
      get stacked diagnostics _constraint = constraint_name;
      if _attempt = 1 and _constraint = 'profiles_username_key' then
        _username := left(_username, 40) || '_' || left(replace(new.id::text, '-', ''), 6);
      else
        raise;
      end if;
    end;
  end loop;
  return new;
end;
$function$;
