// Kelimeki — "Arkadaşını davet et": DOĞRUDAN paylaşım (27 Eylül 2026,
// kullanıcı: *"direkt paylaşma modalı çıkmalı ve whatsapp'dan direkt
// paylaşmalı"*). İki yer kullanıyor: canlı oyun formu ve Arkadaşlar penceresi.
//
// Link ÖNCEDEN alınır: iOS Safari `navigator.share`i yalnızca dokunuşun hemen
// ardından açıyor, araya bir ağ isteği girerse izin düşebiliyor. Token
// kullanıcı başına kalıcı (`create_friend_invite_link` var olanı döner),
// önceden almak yeni bir şey yaratmıyor. Paylaşım sayfası olmayan tarayıcıda
// (masaüstü) ya da sayfa açılamazsa `InviteShareFallback` penceresi açılır.
import { useEffect, useState } from 'react';
import { useAuth } from './useAuth';
import { createFriendInviteLink } from '../lib/api';
import { buildInviteUrl, INVITE_SHARE_TEXT } from '../utils/friendInvite';

export function useInviteShare() {
  const { user } = useAuth();
  const [inviteUrl, setInviteUrl] = useState<string | null>(null);
  const [fallbackOpen, setFallbackOpen] = useState(false);

  useEffect(() => {
    if (!user?.id) return;
    let iptal = false;
    void createFriendInviteLink().then((token) => {
      if (!iptal && token) setInviteUrl(buildInviteUrl(token));
    });
    return () => {
      iptal = true;
    };
  }, [user?.id]);

  const share = async () => {
    let url = inviteUrl;
    if (!url) {
      const token = await createFriendInviteLink();
      if (!token) return;
      url = buildInviteUrl(token);
      setInviteUrl(url);
    }
    if (navigator.share) {
      try {
        await navigator.share({ title: 'Kelimeki', text: INVITE_SHARE_TEXT, url });
        return;
      } catch (err) {
        // Kullanıcı sayfayı kapattıysa sessiz geç; paylaşım AÇILAMADIYSA
        // (ör. iOS'ta dokunuş izni düştü) yedek pencereye in.
        if ((err as { name?: string })?.name === 'AbortError') return;
      }
    }
    setFallbackOpen(true);
  };

  return { inviteUrl, share, fallbackOpen, closeFallback: () => setFallbackOpen(false) };
}
