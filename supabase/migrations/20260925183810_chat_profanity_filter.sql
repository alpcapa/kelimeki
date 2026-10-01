-- Sohbet küfür / müstehcenlik süzgeci (25 Eylül 2026, ROADMAP #37).
--
-- Kullanıcı kararları: (1) MASKELE (mesaj gider, eşleşen kelime `*`),
-- (2) takma ad DAHİL (orada maskeleme yerine RET), (3) hazır liste,
-- + kanıt korunur (orijinal yalnız admin'in okuyabildiği tabloda) + geçmiş
-- mesajlara DOKUNULMAZ.
--
-- Süzgeç SUNUCUDA: mağazadaki eski paketler dahil herkese aynı anda işler,
-- istemci değişikliği gerekmez. Realtime maskeli satırı yayınlar; arşiv
-- (`games.messages`) canlıdan kopyalandığı için kendiliğinden maskeli olur.
--
-- Eşleştirme yalnızca TAM KELİME (kuru ölçüm: kelime başı eşleştirmesi
-- "am" ile 320 mesajın 22'sinde "ama/amaç" gibi masum kelimeleri kesiyordu;
-- tam kelimede ~%3, hepsi gerçek küfür). Sınır = Türkçe harf OLMAYAN her
-- karakter (rakam/alt çizgi/noktalama dahil).
--
-- LİSTE: `ooguz/turkce-kufur-karaliste` (CC BY-SA 4.0,
-- https://github.com/ooguz/turkce-kufur-karaliste) + LDNOOBW `tr`
-- (CC BY 4.0, https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words).
-- Birleşik 815 maddeden 130'u elle AYIKLANDI (masum/nötr kelimeler: ana,
-- mal, allah, meme, saksofon, sokarım, "sıkıcı"nın ç'siz yazımı "sikici",
-- etnik ad "çingene" …) → 685 madde. BY-SA gereği bu türev liste de
-- CC BY-SA 4.0'dır. Liste bundan sonra admin panelinden düzenlenir.

create table if not exists public.chat_blocked_words (
  word text primary key
    check (word = public.tr_lower(btrim(word)) and char_length(word) between 2 and 60),
  source text not null default 'admin',
  created_at timestamptz not null default now()
);
comment on table public.chat_blocked_words is 'Sohbet/takma ad süzgecinin kelime listesi (tam kelime eşleşir). Tohum: ooguz/turkce-kufur-karaliste (CC BY-SA 4.0) + LDNOOBW tr (CC BY 4.0), ayıklanmış. Yalnızca admin RPC''leriyle düzenlenir.';
alter table public.chat_blocked_words enable row level security;
-- Politika YOK: istemci tabloyu hiç okumaz; admin RPC'leri security definer.
grant select, insert, update, delete on public.chat_blocked_words to service_role;

insert into public.chat_blocked_words (word, source)
select w, 'ooguz+ldnoobw' from unnest(array[
  'a.q','a.q.','abazan','ahmak','am','am biti','amarım','ambiti',
  'amcik','amck','amckl','amcklama','amcklaryla','amckta','amcktan','amcuk',
  'amcık','amcık hoşafı','amcıklama','amcıklandı','amcıklar','amcıklara','amcıklarda','amcıklardan',
  'amcıkları','amcıkların','amcıkta','amcıktan','amcığa','amcığı','amcığın','amcığını',
  'amcığınızı','amin oglu','amina','amina g','amina k','amina koyarim','amina koyayim','amina koyayım',
  'aminako','aminakoyarim','aminakoyim','aminda','amindan','amindayken','amini','aminiyarraaniskiim',
  'aminoglu','amiyum','amk','amk çocuğu','amkafa','amlar','amlarnzn','amlı',
  'amm','ammak','ammna','amn','amna','amnda','amndaki','amngtn',
  'amnn','amona','amq','amsiz','amsz','amsız','amteri','amugaa',
  'amuna','amuğa','amı','amık','amın feryadı','amın oglu','amın oğlu','amına',
  'amına koy','amına koyarım','amına koyayım','amına koyyim','amına s','amına sikem','amına sokam','amınako',
  'amınakoyim','amınoğlu','amını','amını s','amısına','amısını','anani sikerim','anani sikeyim',
  'ananisikerim','ananisikeyim','ananı sikerim','ananı sikeyim','ananın am','ananın amı','ananın dölü','ananısikerim',
  'ananısikeyim','ananızın am','anası orospu','anasının am','angut','anuna','aptal','aq',
  'aq.','ass','atkafası','atmık','attrrm','auzlu','ayklarmalrmsikerim','azdırıcı',
  'ağzına sıçayım','babaannesi kaşar','babası pezevenk','bacağına sıçayım','bastard','beyinsiz','bitch','bok',
  'boka','bokbok','bokhu','bokkkumu','boklar','boktan','boku','bokubokuna',
  'bokum','bokça','bombok','boner','bosalmak','boşalmak','bızır','cenabet',
  'cibiliyetsiz','cibilliyetini','cibilliyetsiz','dallama','daltassak','dalyarak','dalyarrak','dangalak',
  'dassagi','dildo','dingil','dingilini','dkerim','domal','domalan','domaldı',
  'domaldın','domalmak','domalmış','domalsın','domalt','domaltarak','domaltip','domaltmak',
  'domaltıp','domaltır','domaltırım','domalık','domalıyor','dölü','ebeni','ebenin',
  'ebeninki','ebleh','embesil','fahise','fahişe','fuck','fucker','fuckin',
  'fucking','gavad','gavat','geber','geberik','gebermek','gebermiş','gebertir',
  'gerizekali','gerizekalı','gerzek','gerızekalı','giberim','giberler','gibis','gibiş',
  'gibmek','gibtiler','goddamn','godoş','godumun','gotelek','gotlalesi','gotlu',
  'gotten','gotundeki','gotunden','gotune','gotunu','gotveren','goyiim','goyum',
  'goyuyim','goyyim','gtelek','gtn','gtnde','gtnden','gtne','gtten',
  'gtveren','göt','göt deliği','göt herif','göt oğlanı','göt veren','göt verir','göte',
  'götelek','götlalesi','götlek','götler','götlerde','götlerden','götlere','götleri',
  'götlerin','götoğlanı','götoş','götte','götten','götveren','götverende','götverenden',
  'götverene','götvereni','götverenin','götverenler','götverenlerde','götverenlerden','götverenlere','götverenleri',
  'götverenlerin','götü','götün','götüne','götüne koyim','götünekoyim','götünü','has siktir',
  'hasiktir','hassikome','hassiktir','hassittir','haysiyetsiz','hayvan herif','hsktr','huur',
  'hödük','ibina','ibine','ibinenin','ibne','ibnedir','ibneleri','ibnelik',
  'ibnelri','ibneni','ibnenin','ibnerator','ibnesi','idiot','idiyot','ipne',
  'itoğlu it','kafam girsin','kafasiz','kafasız','kahpe','kahpenin','kahpenin feryadı','kaltak',
  'kaltaklar','kaltaklara','kaltaklarda','kaltaklardan','kaltakları','kaltakların','kaltakta','kaltaktan',
  'kaltağa','kaltağı','kaltağın','kancik','kancık','kappe','karhane','kavat',
  'kavatn','kerane','kerhane','kerhanelerde','kevase','kevaşe','kevvase','koca göt',
  'kodumun','kodumunun','koduumun','koduğmun','koduğmunun','koyiim','koyiiym','koyyim',
  'kukudaym','laciye boyadım','lavuk','liboş','madafaka','malafat','malak','mcik',
  'memelerini','minaamcık','mincikliyim','mna','monakkoluyum','motherfucker','mudik','o. çocuğu',
  'oc','ocuu','ocuun','orosbucocuu','orospu','orospu cocugu','orospu çoc','orospu çocukları',
  'orospu çocuğu','orospu çocuğudur','orospucocugu','orospuda','orospudan','orospudur','orospular','orospulara',
  'orospularda','orospulardan','orospuları','orospuların','orospunun','orospunun evladı','orospuya','orospuydu',
  'orospuyu','orospuyuz','orospuçocuğu','orostoban','orostopol','orrospu','oruspu','oruspu çocuğu',
  'oruspuçocuğu','osbir','ossurduum','ossurmak','ossuruk','osur','osurduu','osuruk',
  'osururum','otuz birci','otuz bircide','otuz birciden','otuz birciler','otuz bircilerde','otuz bircilerden','otuz bircilere',
  'otuz bircileri','otuz bircilerin','otuz bircinin','otuz birciye','otuz birciyi','oç','oğlancı','oğlu it',
  'patlak zar','penis','pezevek','pezeven','pezeveng','pezevengi','pezevengin evladı','pezevenk',
  'pezo','pici','picler','pisliktir','piç','piç kurusu','piçin oğlu','piçler',
  'porno','pussy','puşt','puşttur','s1kerim','s1kerm','s1krm','sakso',
  'saksocu','saksocuda','saksocudan','saksocular','saksoculara','saksocularda','saksoculardan','saksocuları',
  'saksocuların','saksocunun','saksocuya','saksocuyu','salaak','salak','serefsiz','sevgi koyarım',
  'sevişelim','sexs','sicarsin','sik','sikdi','sikdiğim','sike','sikecem',
  'sikem','siken','sikenin','siker','siker sikmez','sikerim','sikerler','sikersin',
  'sikertir','sikertmek','sikesen','sikesicenin','sikey','sikeydim','sikeyim','sikeym',
  'sikicem','sikien','sikienler','sikiiim','sikiiimmm','sikiim','sikiir','sikiirken',
  'sikik','sikilesice','sikilir sikilmez','sikim','sikimde','sikimden','sikime','sikimi',
  'sikimiin','sikimin','sikimle','sikimsonik','sikimtrak','sikin','sikinde','sikinden',
  'sikine','sikini','sikip','sikis','sikisek','sikisen','sikish','sikismis',
  'sikitiin','sikiyim','sikiym','sikiş','sikişen','sikişme','sikkim','sikko',
  'sikler','siklerde','siklerden','siklere','sikleri','sikleriii','siklerin','sikli',
  'sikm','sikmek','sikmem','sikmemek','sikmiler','sikmisligim','siksem','sikseydin',
  'sikseyidin','siksin','siksinbaya','siksinler','siksiz','siksok','siksz','sikt',
  'sikte','sikten','sikti','siktigimin','siktigiminin','siktii','siktiim','siktiimin',
  'siktiiminin','siktiler','siktim','siktimin','siktiminin','siktir','siktir et','siktir git',
  'siktir lan','siktir ol git','siktirgit','siktirir','siktirir siktirmez','siktiririm','siktiriyor','siktirolgit',
  'siktiğim','siktiğimin','siktiğiminin','sittimin','sittir','skcem','skecem','skem',
  'sker','skerim','skerm','skeyim','skiim','skik','skim','skime',
  'skmek','sksin','sksn','sksz','sktiimin','sktrr','skyim','sokarmkoduumun',
  'sokiim','soktuğumunun','sokuk','sokuyum','soxum','sürtük','sıecem','sıçarım',
  'sıçmak','sıçtığım','taaklarn','taaklarna','tarrakimin','tasak','tassak','taşak',
  'taşaklar','taşaklara','taşaklarda','taşaklardan','taşakları','taşakların','taşakta','taşaktan',
  'taşağa','taşağı','taşağın','taşşak','tipini s.k','tipinizi s.keyim','topsun','totoş',
  'vajina','vajinanı','veled i zina','veledizina','weledizina','whore','xikeyim','yaaraaa',
  'yalarun','yaraaam','yarak','yaraklar','yaraklara','yaraklarda','yaraklardan','yarakları',
  'yarakların','yaraksız','yarakta','yaraktan','yaraktr','yaraminbasi','yaramn','yararmorospunun',
  'yarağa','yarağı','yarağın','yarra','yarraaaa','yarraak','yarraam','yarraamı',
  'yarragi','yarragimi','yarragina','yarragindan','yarragm','yarraimin','yarrak','yarram',
  'yarramin','yarraminbaşı','yarramn','yarran','yarrana','yarrağ','yarrağım','yarrağımı',
  'yarrrak','yavak','yavuşak','yavş','yavşak','yavşaktır','yilisik','yogurtlayam',
  'yoğurtlayam','yrrak','yılışık','zibidi','zigsin','zikeyim','zikiiim','zikiim',
  'zikik','zikim','ziksiiin','ziksiin','zulliyetini','zviyetini','zıkkımım','çük',
  'öküz','öşex','ıbnelık','şerefsiz','şıllık'
]) as w
on conflict (word) do nothing;

-- Maskelenen mesajın ORİJİNALİ — şikâyeti inceleyen admin ne yazıldığını
-- görebilsin diye. Katılımcılar yalnızca maskeli metni görür.
create table if not exists public.online_game_message_originals (
  message_id uuid primary key
    references public.online_game_messages(id) on delete cascade
    deferrable initially deferred,
  online_game_id uuid not null,
  original text not null,
  created_at timestamptz not null
);
comment on table public.online_game_message_originals is 'Süzgecin maskelediği sohbet mesajlarının orijinali. Yalnızca admin okur (şikâyet incelemesi). FK deferred: satır BEFORE INSERT trigger''ında, mesajın kendisinden önce yazılıyor.';
create index if not exists online_game_message_originals_game_idx
  on public.online_game_message_originals (online_game_id);
alter table public.online_game_message_originals enable row level security;
create policy online_game_message_originals_select_admin
  on public.online_game_message_originals for select
  using (public.is_admin());
grant select on public.online_game_message_originals to authenticated;
grant select, insert, update, delete on public.online_game_message_originals to service_role;

-- Metindeki listelenmiş kelimeleri (tam kelime, Türkçe küçük harfe göre)
-- harf sayısı kadar `*` ile değiştirir; büyük/küçük harf ve geri kalan
-- metin aynen korunur. `tr_lower` uzunluğu koruyor (ölçüldü), bu yüzden
-- maske karakter karakter orijinale uygulanabiliyor.
create or replace function public._chat_profanity_mask(p_text text)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_low text;
  v_mask text;
  v_word text;
  v_out text := '';
  v_b constant text := '[^a-zçğıöşüâîû]';
begin
  if p_text is null or p_text = '' then
    return p_text;
  end if;
  v_low := public.tr_lower(p_text);
  v_mask := v_low;
  for v_word in select word from public.chat_blocked_words loop
    if strpos(v_low, v_word) > 0 then
      v_mask := regexp_replace(
        v_mask,
        '(^|' || v_b || ')'
          || regexp_replace(v_word, '([.\\+*?^$()\[\]{}|])', '\\\1', 'g')
          || '(?=$|' || v_b || ')',
        '\1' || repeat('*', char_length(v_word)),
        'g');
    end if;
  end loop;
  if v_mask = v_low then
    return p_text;
  end if;
  if char_length(v_low) <> char_length(p_text) then
    return v_mask;  -- güvenli taraf: hizalanamıyorsa küçük harfli maskeli metin
  end if;
  for i in 1 .. char_length(p_text) loop
    if substr(v_mask, i, 1) = '*' and substr(v_low, i, 1) <> '*' then
      v_out := v_out || '*';
    else
      v_out := v_out || substr(p_text, i, 1);
    end if;
  end loop;
  return v_out;
end;
$$;
revoke all on function public._chat_profanity_mask(text) from public, anon, authenticated;

create or replace function public._nickname_is_blocked(p_nickname text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_nickname is not null
     and public._chat_profanity_mask(p_nickname) is distinct from p_nickname;
$$;
revoke all on function public._nickname_is_blocked(text) from public, anon, authenticated;

-- Sohbet: BEFORE INSERT'te maskele, orijinali ayrı tabloya yaz.
create or replace function public.mask_online_game_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_masked text := public._chat_profanity_mask(new.message);
begin
  if v_masked is distinct from new.message then
    insert into public.online_game_message_originals
      (message_id, online_game_id, original, created_at)
    values (new.id, new.online_game_id, new.message, new.created_at);
    new.message := v_masked;
  end if;
  return new;
end;
$$;
revoke all on function public.mask_online_game_message() from public, anon, authenticated;

drop trigger if exists trg_mask_online_game_message on public.online_game_messages;
create trigger trg_mask_online_game_message
  before insert on public.online_game_messages
  for each row execute function public.mask_online_game_message();

-- Takma ad: maskelenmez, REDDEDİLİR (kayıt + değişiklik).
create or replace function public.reject_blocked_nickname()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.display_name is not null
     and (tg_op = 'INSERT' or new.display_name is distinct from old.display_name)
     and public._nickname_is_blocked(new.display_name) then
    raise exception 'Bu takma ad kullanılamaz.' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
revoke all on function public.reject_blocked_nickname() from public, anon, authenticated;

drop trigger if exists trg_reject_blocked_nickname on public.profiles;
create trigger trg_reject_blocked_nickname
  before insert or update of display_name on public.profiles
  for each row execute function public.reject_blocked_nickname();

-- Eski istemciler (mağazadaki paketler) takma adı bununla soruyor: süzgece
-- takılan ad "alınmış" gibi görünür ama en azından kayıt aşamasında durur.
create or replace function public.check_nickname_available(p_nickname text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select not exists (
    select 1 from public.profiles
    where public.tr_lower(display_name) = public.tr_lower(p_nickname)
      and (auth.uid() is null or id <> auth.uid())
  )
  and not public._nickname_is_blocked(p_nickname);
$$;

-- Yeni istemciler: "alınmış" ile "kullanılamaz"ı ayırt eden tek çağrı.
create or replace function public.nickname_status(p_nickname text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select case
    when public._nickname_is_blocked(p_nickname) then 'blocked'
    when exists (
      select 1 from public.profiles
      where public.tr_lower(display_name) = public.tr_lower(p_nickname)
        and (auth.uid() is null or id <> auth.uid())
    ) then 'taken'
    else 'ok'
  end;
$$;
revoke all on function public.nickname_status(text) from public;
grant execute on function public.nickname_status(text) to anon, authenticated;

-- Admin sohbet dökümü: maskelenmiş mesajların yerine ORİJİNAL + `filtered`.
create or replace function public.admin_get_finished_game_chat(p_online_game_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth
as $$
declare
  v_messages jsonb;
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;

  select g.messages into v_messages
  from public.games g
  where g.online_game_id = p_online_game_id
  limit 1;

  if v_messages is null or jsonb_typeof(v_messages) <> 'array' then
    return coalesce(v_messages, '[]'::jsonb);
  end if;

  select coalesce(jsonb_agg(
    case when o.original is not null
      then m.elem || jsonb_build_object('message', o.original, 'filtered', true)
      else m.elem
    end order by m.ord), '[]'::jsonb)
  into v_messages
  from jsonb_array_elements(v_messages) with ordinality as m(elem, ord)
  left join lateral (
    select x.original
    from public.online_game_message_originals x
    where x.online_game_id = p_online_game_id
      and x.created_at = (m.elem ->> 'created_at')::timestamptz
    limit 1
  ) o on true;

  return v_messages;
end;
$$;

-- Admin: kelime listesi.
create or replace function public.admin_list_chat_blocked_words()
returns table (word text, source text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;
  return query
    select w.word, w.source, w.created_at
    from public.chat_blocked_words w
    order by w.word;
end;
$$;

create or replace function public.admin_add_chat_blocked_word(p_word text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_word text := public.tr_lower(btrim(coalesce(p_word, '')));
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;
  if char_length(v_word) < 2 or char_length(v_word) > 60 then
    raise exception 'Kelime 2-60 karakter olmalı.';
  end if;
  insert into public.chat_blocked_words (word, source)
  values (v_word, 'admin')
  on conflict (word) do nothing;
end;
$$;

create or replace function public.admin_remove_chat_blocked_word(p_word text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Yetkisiz erişim.';
  end if;
  delete from public.chat_blocked_words
  where word = public.tr_lower(btrim(coalesce(p_word, '')));
end;
$$;

revoke all on function public.admin_list_chat_blocked_words() from public, anon;
revoke all on function public.admin_add_chat_blocked_word(text) from public, anon;
revoke all on function public.admin_remove_chat_blocked_word(text) from public, anon;
grant execute on function public.admin_list_chat_blocked_words() to authenticated;
grant execute on function public.admin_add_chat_blocked_word(text) to authenticated;
grant execute on function public.admin_remove_chat_blocked_word(text) to authenticated;
