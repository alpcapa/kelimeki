-- Hamle Avı (ROADMAP #51 ön adımı, 1.1.8): kişi başı ÇÖZÜLEN bulmaca kimlikleri.
-- Amaç: k-lig'e ileride gelecek Hamle Avı sekmesinde beraberlik ölçütü (birincil = rekor/en iyi seri,
-- ikincil = çözülen bulmaca SAYISI). Sayı = cardinality(solved_ids).
--
-- ⚠ Sayaç SAYI olarak değil KİMLİK KÜMESİ olarak tutulur: `hamle_avi_report` çevrimdışı kuyruktan
-- tekrar/sırasız çağrılabildiği için "+1" artışı kuyruk tekrarında şişerdi; küme birleşimi (seen_ids'in
-- deseni) her tekrarda aynı sonucu verir. Bulmaca bankası ~1000 kimlik, tavan seen_ids ile aynı (5000).
-- ⚠ Çözülenler HER ZAMAN görülenlerin alt kümesidir (sunucu bunu zorlar): rastgele büyük kimlik
-- yollayarak sayacı şişirmek bir kimlik uzayı sınırına (görülen kümesine) takılır.
-- ⚠ Geçmişe dönük KURTARILAMAZ: `seen_ids` çözülen+kaçırılanı ayırmıyordu; sayaç bu migration'dan sonra
-- çözülen bulmacalardan başlar.
--
-- ⚠ ESKİ İSTEMCİLER (1.1.7 ve öncesi, web önbelleği): `hamle_avi_report(integer, integer[])` çağrısı yeni
-- imzaya (üçüncü parametre `default`) düşer, ek dönüş sütunu `solved_ids` onlarca yok sayılır → KIRILMAZ.
-- Dönüş tipi değiştiği için `create or replace` YETMEZ: drop + create. Supabase yeni fonksiyona
-- varsayılan olarak `anon` execute de verdiğinden grant'ler ELLE kurulur (proacl okunup doğrulanacak).

alter table public.hamle_avi_stats
  add column if not exists solved_ids integer[] not null default '{}';

drop function if exists public.hamle_avi_get();
drop function if exists public.hamle_avi_report(integer, integer[]);

create function public.hamle_avi_get()
returns table (best_streak integer, seen_ids integer[], solved_ids integer[])
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(s.best_streak, 0), coalesce(s.seen_ids, '{}'::integer[]), coalesce(s.solved_ids, '{}'::integer[])
  from (select 1) d
  left join public.hamle_avi_stats s on s.user_id = auth.uid()
  where auth.uid() is not null;
$$;

create function public.hamle_avi_report(
  p_best_streak integer,
  p_seen_ids integer[],
  p_solved_ids integer[] default '{}'
)
returns table (best_streak integer, seen_ids integer[], solved_ids integer[])
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  uid uuid := auth.uid();
  v_best integer := greatest(0, least(coalesce(p_best_streak, 0), 5000));
  v_seen integer[] := coalesce(p_seen_ids, '{}'::integer[]);
  v_solved integer[] := coalesce(p_solved_ids, '{}'::integer[]);
begin
  if uid is null then
    raise exception 'Giriş gerekli' using errcode = '28000';
  end if;
  if coalesce(array_length(v_seen, 1), 0) > 5000 or coalesce(array_length(v_solved, 1), 0) > 5000 then
    raise exception 'Çok fazla kimlik' using errcode = 'P0001';
  end if;

  insert into public.hamle_avi_stats as s (user_id, best_streak, seen_ids, solved_ids)
  values (
    uid,
    v_best,
    (select coalesce(array_agg(distinct x order by x), '{}') from unnest(v_seen) x),
    -- Çözülen ⊆ görülen: yeni satırda gelen görülenlerle sınırla.
    (select coalesce(array_agg(distinct x order by x), '{}') from unnest(v_solved) x where x = any (v_seen))
  )
  on conflict (user_id) do update
    set best_streak = greatest(s.best_streak, excluded.best_streak),
        seen_ids = (
          select coalesce(array_agg(distinct x order by x), '{}')
          from unnest(s.seen_ids || excluded.seen_ids) x
        ),
        solved_ids = (
          -- Çözülen ⊆ (eski ∪ yeni görülen): eski çözülenler + gelenlerin görülenlerle kesişimi.
          select coalesce(array_agg(distinct x order by x), '{}')
          from unnest(s.solved_ids || v_solved) x
          where x = any (s.seen_ids || excluded.seen_ids)
        ),
        updated_at = now();

  return query
    select s.best_streak, s.seen_ids, s.solved_ids from public.hamle_avi_stats s where s.user_id = uid;
end;
$$;

revoke all on function public.hamle_avi_get() from public, anon;
revoke all on function public.hamle_avi_report(integer, integer[], integer[]) from public, anon;
grant execute on function public.hamle_avi_get() to authenticated;
grant execute on function public.hamle_avi_report(integer, integer[], integer[]) to authenticated;
