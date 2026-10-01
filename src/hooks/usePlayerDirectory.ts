// Oyuncu rehberi: sunucuda arama + "Tüm oyuncular" sayfalı listesi.
//
// İki yüzey paylaşıyor (27 Eylül 2026): Arkadaşlar penceresi
// (`FriendsModal`) ve canlı oyun kurma formu (`LiveGameCreateForm`) —
// ikisinde de liste başlığının sağında "Tüm oyuncular →" / "← Arkadaşlar"
// dönüşümlü bağlantısı var ve tüm oyuncular görünümünde arkadaş olmayana
// istek gönderilebiliyor.
//
// - `query` ≥ 2 harfse `search_users_for_friend` (350 ms gecikmeli).
// - `listOpen` ilk kez açılınca `list_users_for_friend`in ilk sayfası;
//   sonrası `sentinelRef` görünür oldukça (`scrollRef` kökünde) yüklenir.
//   Türkçe harfler sunucu collation'ında sayfa sınırlarında yanlış
//   dağılabildiği için HER sayfada birikmiş listenin TAMAMI `trCompare`
//   ile yeniden sıralanır.
// - `patchRelation`: ekle/kabul/iptal sonrası iki listede de satırı yerinde
//   günceller (yeniden çekmeden).
import { useCallback, useEffect, useRef, useState } from 'react';
import { listUsersForFriend, searchUsersForFriend } from '../lib/api';
import type { FriendSearchResult } from '../lib/database.types';
import { trCompare } from '../utils/turkish';

const PAGE_SIZE = 20;

export function usePlayerDirectory(query: string, listOpen: boolean) {
  const [results, setResults] = useState<FriendSearchResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [allUsers, setAllUsers] = useState<FriendSearchResult[] | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const sentinelRef = useRef<HTMLDivElement | null>(null);
  const aranan = query.trim();

  useEffect(() => {
    if (aranan.length < 2) {
      setResults([]);
      setSearching(false);
      return;
    }
    setSearching(true);
    const t = setTimeout(() => {
      void searchUsersForFriend(aranan).then((r) => {
        setResults(r);
        setSearching(false);
      });
    }, 350);
    return () => clearTimeout(t);
  }, [aranan]);

  useEffect(() => {
    if (!listOpen || allUsers !== null) return;
    void listUsersForFriend(0, PAGE_SIZE).then((page) => {
      setAllUsers([...page].sort((a, b) => trCompare(a.name, b.name)));
      setHasMore(page.length === PAGE_SIZE);
    });
  }, [listOpen, allUsers]);

  const loadMore = useCallback(() => {
    if (allUsers === null) return;
    setLoadingMore((already) => {
      if (already) return already;
      void listUsersForFriend(allUsers.length, PAGE_SIZE).then((page) => {
        setAllUsers((cur) => [...(cur ?? []), ...page].sort((a, b) => trCompare(a.name, b.name)));
        setHasMore(page.length === PAGE_SIZE);
        setLoadingMore(false);
      });
      return true;
    });
  }, [allUsers]);

  useEffect(() => {
    if (!listOpen || aranan.length >= 2 || !hasMore || allUsers === null) return;
    const sentinel = sentinelRef.current;
    const root = scrollRef.current;
    if (!sentinel || !root) return;
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) loadMore();
      },
      { root, rootMargin: '80px' },
    );
    observer.observe(sentinel);
    return () => observer.disconnect();
  }, [listOpen, aranan, hasMore, allUsers, loadMore]);

  const patchRelation = useCallback((id: string, relation: FriendSearchResult['relation']) => {
    setResults((r) => r.map((u) => (u.id === id ? { ...u, relation } : u)));
    setAllUsers((r) => (r ? r.map((u) => (u.id === id ? { ...u, relation } : u)) : r));
  }, []);

  return {
    searchActive: aranan.length >= 2,
    results,
    searching,
    allUsers,
    hasMore,
    loadingMore,
    scrollRef,
    sentinelRef,
    patchRelation,
  };
}
