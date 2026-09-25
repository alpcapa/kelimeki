-- ROADMAP #31, ikinci tur — İKİ YÖNLÜ satır belirsizliği kapatılıyor.
--
-- 20260918154109 tek satır okuyordu (`select fr.status into v_status ... for
-- update`). ⚠ Ama `friend_requests`'te aynı ikili için İKİ YÖNLÜ satır
-- olabiliyor: `sendFriendRequest` düz bir `insert` ve PK (user_id, friend_id)
-- ters yönü ENGELLEMEZ — canlıda bir örneği var (18 Eylül 2026'da sayıldı:
-- 1 ikili, ikisi de `accepted`, yani zararsız). Karışık bir durumda (biri
-- `accepted`, biri `pending`) hangi satırın okunacağı BELİRSİZDİ; eski kod
-- (`exists` + ikisini birden güncelle) bu yönden deterministikti.
--
-- Bu migration kararı `bool_or(status = 'accepted')`e bağlıyor: satırların
-- TAMAMI kilitlenir, "zaten arkadaş mı" sorusu tek ve kesin cevaplanır.
-- Zaten arkadaşlarsa sayaç yine ARTMAZ, ama kalıntı bir `pending` satırı
-- varsa normalize edilir (eski davranış korunur); `accepted` satırın
-- `responded_at`'i TAZELENMEZ.
--
-- Canlıda ölçülen yedi yol (hepsi uygulamadan SONRA, geri sarılan
-- alt-işlemlerde ya da gerçek çağrıyla):
--   A) `pending` ileri yön (davet eden → çağıran)  → kabul + sayaç +1
--   B) `pending` ters yön  (çağıran → davet eden)  → kabul + sayaç +1
--   C) karışık çift yön (accepted + pending)       → sayaç SABİT, kalıntı
--      normalize, accepted satırın damgası korunur
--   D) zaten arkadaş (gerçek çağrı)                → tam no-op
--   E) mutlu yol (hiç satır yok)                   → kabul + sayaç +1
--   F) üst üste İKİ çağrı (asıl vaka)              → ikisi de no-op
--   G) üç ret                                      → P0001, metinler birebir

create or replace function public.accept_friend_invite(p_token text)
returns table(inviter_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_inviter  uuid;
  v_accepted boolean;
  v_exists   boolean;
begin
  if v_uid is null then
    raise exception 'Oturum açık değil.';
  end if;

  select fil.inviter_id into v_inviter
  from public.friend_invite_links fil
  where fil.token = p_token;

  if v_inviter is null then
    raise exception 'Geçersiz davet linki.';
  end if;

  if v_inviter = v_uid then
    raise exception 'Kendi linkinle arkadaş olamazsın.';
  end if;

  -- Var olan ilişki satır(lar)ını KİLİTLE. ⚠ İkili için İKİ YÖNLÜ satır
  -- olabiliyor (`sendFriendRequest` düz insert, PK (user_id,friend_id) ters
  -- yönü engellemez; canlıda bir örneği var), o yüzden tek satır okumak
  -- BELİRSİZ olurdu — hepsi kilitlenir, karar `bool_or` ile verilir.
  perform 1 from public.friend_requests fr
  where (fr.user_id = v_inviter and fr.friend_id = v_uid)
     or (fr.user_id = v_uid and fr.friend_id = v_inviter)
  for update;

  select count(*) > 0, coalesce(bool_or(fr.status = 'accepted'), false)
    into v_exists, v_accepted
  from public.friend_requests fr
  where (fr.user_id = v_inviter and fr.friend_id = v_uid)
     or (fr.user_id = v_uid and fr.friend_id = v_inviter);

  if v_accepted then
    -- ZATEN ARKADAŞLAR → sayaç ARTMAZ, invited_by'a dokunulmaz.
    -- Yalnızca kalıntı bir `pending` satırı varsa normalize edilir (eski
    -- davranış korunsun diye); `accepted` satırın responded_at'i TAZELENMEZ.
    update public.friend_requests
      set status = 'accepted', responded_at = now()
      where ((user_id = v_inviter and friend_id = v_uid)
          or (user_id = v_uid and friend_id = v_inviter))
        and status <> 'accepted';

    return query
      select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
      from public.profiles p where p.id = v_inviter;
    return;
  end if;

  if not v_exists then
    insert into public.friend_requests (user_id, friend_id, status, responded_at)
    values (v_inviter, v_uid, 'accepted', now())
    on conflict (user_id, friend_id) do nothing;

    if not found then
      -- Yarış: aynı anda başka bir çağrı kurdu, sayaç ONUN çağrısına yazıldı.
      return query
        select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
        from public.profiles p where p.id = v_inviter;
      return;
    end if;
  else
    -- Yalnızca `pending` satır(lar) var (hangi yönde olursa olsun) → link
    -- tıklaması onları kabul eder. Bu GERÇEK bir kabul, sayılır.
    update public.friend_requests
      set status = 'accepted', responded_at = now()
      where (user_id = v_inviter and friend_id = v_uid)
         or (user_id = v_uid and friend_id = v_inviter);
  end if;

  update public.friend_invite_links set use_count = use_count + 1 where inviter_id = v_inviter;
  update public.profiles set invited_by = v_inviter where id = v_uid and invited_by is null;

  return query
    select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
    from public.profiles p where p.id = v_inviter;
end;
$$;
