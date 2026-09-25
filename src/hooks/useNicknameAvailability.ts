import { useEffect, useRef, useState } from 'react';
import { fetchNicknameStatus } from '../lib/api';

export type NicknameAvailabilityStatus = 'idle' | 'checking' | 'available' | 'taken' | 'blocked' | 'error';

/**
 * Girilen takma ismin (debounce'lu) uygunluğunu kontrol eder — RPC oturum
 * açıksa çağıranın kendi mevcut ismini otomatik hariç tuttuğundan
 * (`check_nickname_available`, `auth.uid()`), hem kayıt formu (AuthModal,
 * oturum yok) hem hesap ayarları (AccountSettingsModal, oturum var) aynı
 * hook'u kullanabilir. `currentValue` verilirse (hesap ayarlarında kişinin
 * hâlihazırda sahip olduğu isim) o değere eşitken kontrol atlanır.
 *
 * `blocked`: isim küfür/müstehcenlik süzgecine takıldı (ROADMAP #37) —
 * sunucu `profiles` trigger'ı zaten reddeder, bu yalnızca erken uyarı.
 */
export function useNicknameAvailability(
  nickname: string,
  enabled: boolean,
  currentValue?: string,
): NicknameAvailabilityStatus {
  const [status, setStatus] = useState<NicknameAvailabilityStatus>('idle');
  const seqRef = useRef(0);

  useEffect(() => {
    const trimmed = nickname.trim();
    if (!enabled || !trimmed || trimmed === currentValue) {
      setStatus('idle');
      return;
    }
    setStatus('checking');
    const mySeq = ++seqRef.current;
    const timer = setTimeout(async () => {
      try {
        const durum = await fetchNicknameStatus(trimmed);
        if (seqRef.current === mySeq) {
          setStatus(durum === 'ok' ? 'available' : durum);
        }
      } catch {
        if (seqRef.current === mySeq) setStatus('error');
      }
    }, 400);
    return () => clearTimeout(timer);
  }, [nickname, enabled, currentValue]);

  return status;
}
