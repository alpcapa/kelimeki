-- ROADMAP #31 — `accept_friend_invite` idempotent hale getiriliyor.
--
-- SORUN (18 Eylül 2026, canlıdan ölçüldü): fonksiyon aynı kabul için birden
-- çok kez çağrılabiliyor (`/davet/:token` sayfasının kendi otomatik kabulü +
-- `App.tsx`'teki localStorage kuyruğu fallback'i; ikisi de BİLEREK var, bkz.
-- `docs/decisions/friends.md`) ve her çağrı `use_count`'u artırıyordu. Zaten
-- arkadaş olmuş biri linki yeniden açtığında da `exists` dalı çalışıp sayacı
-- artırıyor, üstelik `responded_at`'i tazeliyordu.
--
-- Ölçüm: beş kullanılmış linkin TOPLAM `use_count`'u 128, `profiles.invited_by`
-- ile atfedilen kişi 11 (en uçta 84/2).
--
-- ÇÖZÜM: ikinci ve sonraki çağrılar TAM no-op olur — arkadaşlık zaten
-- `accepted` ise sayaç artmaz, `responded_at` tazelenmez, `invited_by`ye
-- dokunulmaz. Dönen değer (`inviter_name`) ve üç `raise exception` (P0001)
-- AYNEN korunuyor: iki istemci de (web `acceptFriendInvite`, port
-- `FriendsApi.acceptInvite`) yalnızca bu ikisine bakıyor, davranışları
-- DEĞİŞMİYOR.
--
-- Ayrıca yarış sertleştirmesi: var olan satır `for update` ile kilitleniyor,
-- ekleme `on conflict do nothing` + `found` kontrolüyle yapılıyor — iki eşzamanlı
-- çağrıdan yalnızca biri sayacı artırır.
--
-- ⚠ GEÇMİŞ DEĞERLER DÜZELTİLMİYOR ve düzeltilemez: tıklama başına iz
-- tutulmadığından "kaçı gerçek kabuldü" geriye dönük çıkarılamaz. Bu yüzden
-- mevcut sayılar OLDUĞU GİBİ bırakıldı; kolon yorumu kesim tarihini yazıyor.
-- Geçmişi de kapsayan tek güvenilir taban `profiles.invited_by` sayımıdır.

create or replace function public.accept_friend_invite(p_token text)
returns table(inviter_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_inviter uuid;
  v_status  text;
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

  -- Var olan ilişki (her iki yön) — satır varsa KİLİTLE, eşzamanlı ikinci
  -- çağrı burada bekler ve sonra 'accepted' görüp no-op'a düşer.
  select fr.status into v_status
  from public.friend_requests fr
  where (fr.user_id = v_inviter and fr.friend_id = v_uid)
     or (fr.user_id = v_uid and fr.friend_id = v_inviter)
  for update;

  if v_status = 'accepted' then
    -- ZATEN ARKADAŞLAR → tam no-op. Sayaç artmaz, responded_at tazelenmez.
    return query
      select coalesce(p.display_name, p.first_name, 'Bir kullanıcı')
      from public.profiles p where p.id = v_inviter;
    return;
  end if;

  if v_status is null then
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
    -- 'pending' bir istek vardı (hangi yönde olursa olsun) → link tıklaması
    -- onu kabul eder. Bu GERÇEK bir kabul, sayılır.
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

comment on column public.friend_invite_links.use_count is
  'Bu linkle KURULAN arkadaşlık sayısı. ⚠ 18 Eylül 2026''dan ÖNCEki değerler bu anlamda DEĞİL: o tarihe kadar fonksiyon idempotent değildi ve her tıklamayı (zaten arkadaş olanın tekrar açmasını da) sayıyordu — canlıda toplam 128 iken gerçek davetli 11''di. Geçmişi de kapsayan güvenilir taban: profiles.invited_by sayımı.';
