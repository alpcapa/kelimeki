// Kelimeki — kimlik doğrulama bağlamı (Supabase Auth)
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import type { User } from '@supabase/supabase-js';
import { supabase, isSupabaseConfigured } from '../lib/supabase';
import { isAuthNullBurst, sameAuthUser, shouldApplyAuthSession } from '../utils/authUser';
import { reportClientError } from '../utils/errorReporting';
import { fetchMyProfile } from '../lib/api';
import type { Profile } from '../lib/database.types';

interface AuthContextValue {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  /** user set ama profili henüz (ilk kez) çekilmedi — display_name/first_name
   *  henüz güvenilir değil, bu sırada e-posta gibi geçici yer tutuculara
   *  düşülmemeli (aksi halde profil gelene kadar bir anlık yanlış isim
   *  görünür). */
  profileLoading: boolean;
  /** Supabase anahtarları ayarlı mı? */
  configured: boolean;
  /** Şifre sıfırlama bağlantısı tıklanıp bu sekmede recovery oturumu açıldı mı? */
  passwordRecovery: boolean;
  /** "Yeni şifre belirle" akışı tamamlanınca/kapatılınca çağrılır. */
  clearPasswordRecovery: () => void;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  profile: null,
  loading: true,
  profileLoading: true,
  configured: false,
  passwordRecovery: false,
  clearPasswordRecovery: () => {},
  refreshProfile: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const [profileLoading, setProfileLoading] = useState(true);
  const [passwordRecovery, setPasswordRecovery] = useState(false);

  useEffect(() => {
    if (!supabase) {
      setLoading(false);
      setProfileLoading(false);
      return;
    }

    // `user` state'ini set eden yer ile profil çekimini başlatan yer ayrı
    // efektler olursa, arada `user` dolu ama `profileLoading` henüz eski
    // (false) değerinde olan bir render anı oluşur — tam o anda Setup vb.
    // ekranlar profil yokmuş gibi e-posta öneki gibi geçici bir isme düşer.
    // Bunu önlemek için ikisini burada, aynı callback içinde (aynı state
    // batch'inde) birlikte güncelliyoruz.
    let currentUserId: string | null = null;
    const applyUser = (u: User | null) => {
      // ⚠ `setUser(u)` DEĞİL: Supabase her auth olayında (token yenileme,
      // sekmeye dönüş, aynı oturumun yeniden okunması) alanları birebir aynı
      // AMA kimliği yeni bir `User` nesnesi üretir. Koşulsuz set edilince
      // `user` NESNESİNE bağlı dokuz effect birden yeniden koşuyordu ve
      // uygulama saniyede ~19 istek atan bir döngüye giriyordu (19 Eylül
      // 2026 canlı ölçümü; gerekçenin tamamı `utils/authUser.ts`te).
      //
      // İçerik değiştiyse yeni nesne AYNEN geçer — bu satır güncelleme
      // yutmaz, yalnızca gereksiz kimlik değişimini yutar.
      setUser((onceki) => (sameAuthUser(onceki, u) ? onceki : u));
      if (u?.id === currentUserId) return;
      currentUserId = u?.id ?? null;
      if (u) {
        setProfileLoading(true);
        fetchMyProfile(u.id)
          .then((p) => {
            if (currentUserId === u.id) {
              setProfile(p);
              setProfileLoading(false);
            }
          })
          .catch((err) => {
            // fetchMyProfile kendi Supabase sorgu hatasını yakalayıp `null`
            // döner, ama içindeki `supabase.auth.getUser()` çağrısı
            // beklenmedik şekilde reddederse bu `.catch` olmadan
            // `profileLoading` sonsuza dek `true` kalır — isim hiçbir zaman
            // belirmez (bkz. kod incelemesi).
            console.error('[Kelimeki] fetchMyProfile beklenmedik hata:', err);
            if (currentUserId === u.id) setProfileLoading(false);
          });
      } else {
        setProfile(null);
        setProfileLoading(false);
      }
    };

    supabase.auth
      .getSession()
      .then(({ data }) => {
        applyUser(data.session?.user ?? null);
        setLoading(false);
      })
      .catch((err) => {
        // Sandboxed sekme/depolama erişimi engelli gibi nadir durumlarda
        // reddedebilir — bu olmadan `loading` sonsuza dek `true` kalır ve
        // "Giriş" butonu dahil oturum durumuna bağlı hiçbir UI hiç belirmez.
        console.error('[Kelimeki] getSession beklenmedik hata:', err);
        setLoading(false);
      });
    // Devre kesicinin sayacı — SAYFA ÖMRÜ boyunca yaşar (effect `[]`e bağlı).
    const nullOlaylari: number[] = [];
    let nullKilitli = false;
    const { data: sub } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'PASSWORD_RECOVERY') setPasswordRecovery(true);
      // ⚠ Her `null` oturum bir ÇIKIŞ DEĞİLDİR. 19 Eylül 2026'da canlıda
      // ölçüldü: oturum `kullanıcı → null → kullanıcı` diye titriyordu ve her
      // titreme hem `user`e bağlı effect'leri yeniden koşturuyor hem de UÇAN
      // profil isteğini çöpe attırıyordu (aşağıdaki `currentUserId` koruması
      // sıfırlandığı için). Kullanıcı bunu "oyunlar geldi ama avatar/isim
      // gelmedi" diye gördü.
      //
      // İlk düzeltme olayın ADINA bakıyordu (`SIGNED_OUT`/`INITIAL_SESSION`
      // dışındakileri eler). Yayına çıktı ve YETMEDİ — titreme aynı hızda
      // sürdü, yani titreten olay o iki addan biriyle geliyor. Bu yüzden
      // karar artık ada değil, DEPODAKİ OTURUMA bakıyor: gerçek bir çıkışta
      // `supabase-js` kalıcı oturumu olaydan ÖNCE siler, dolayısıyla depo da
      // boşsa çıkış gerçektir. Kural `utils/authUser.ts`te, kapısı
      // `npm run verify-auth-user-identity`.
      if (shouldApplyAuthSession(!!session)) {
        applyUser(session?.user ?? null);
        return;
      }
      // ⚠ `setTimeout(…, 0)` ZORUNLU, süslemek için değil: bu geri çağrı
      // Supabase'in auth kilidini TUTARKEN çalışıyor ve kilit altında ikinci
      // bir auth çağrısı yapmak (burada `getSession`) kilitlenme üretir —
      // Supabase'in kendi dokümanındaki uyarı. Erteleme kilidi bırakır.
      window.setTimeout(() => {
        void supabase?.auth
          .getSession()
          .then(({ data }) => {
            const depodaki = data.session?.user ?? null;
            // ── TEŞHİS ────────────────────────────────────────────────────
            // Tetikleyici ÜÇ turdur bilinmiyor ve sunucu loglarından
            // GÖRÜLEMİYOR (istemci konsolu bizde yok, kullanıcı iPhone
            // Safari'de). Tek yol cihazdan kaydetmek: hangi olay adı geliyor
            // ve o anda kalıcı oturum duruyor mu? İkisi birlikte kök sebebi
            // ikiye indiriyor — "sahte olay" mı, "oturum gerçekten siliniyor"
            // mu. `reportClientError` fire-and-forget, imzaya göre tekilliyor
            // ve hız sınırlı; bir döngüde bile birkaç satır yazar.
            reportClientError(
              `auth null olayı: ${event} · depo=${depodaki ? 'dolu' : 'BOŞ'}`,
              'manual',
              'auth-null',
            );
            // Depoda oturum duruyorsa olay gürültüydü: DOKUNMA.
            if (!shouldApplyAuthSession(false, depodaki?.id ?? null)) return;
            // ── DEVRE KESİCİ ──────────────────────────────────────────────
            // Gerçek bir çıkış saniyede iki kez olmaz. Kök sebep ne olursa
            // olsun, kısa pencerede tekrarlayan `null` gürültüdür — kesici
            // sebebe değil FREKANSA bakıyor (bkz. utils/authUser.ts).
            if (nullKilitli) return;
            const simdi = Date.now();
            if (isAuthNullBurst(nullOlaylari, simdi)) {
              nullKilitli = true;
              reportClientError(
                `auth null fırtınası — oturum düşürme bu sayfa ömrü boyunca KAPATILDI (son olay: ${event})`,
                'manual',
                'auth-null-burst',
              );
              return;
            }
            nullOlaylari.push(simdi);
            applyUser(null);
          })
          .catch((err) => {
            // Depo okunamadıysa oturumu DÜŞÜRME — yanlış yönde hata yapmak
            // (girişli kullanıcıyı çıkmış saymak) tam da düzeltilen arıza.
            console.error('[Kelimeki] oturum doğrulaması başarısız:', err);
          });
      }, 0);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  // `refreshProfile` her render'da YENİDEN YAZILMAMALI: bağlam nesnesinin
  // içinde duruyor ve bağlam nesnesinin kimliği değişince `useAuth()` çağıran
  // her bileşen yeniden render oluyor. Oturumu `ref` üzerinden okuyor ki
  // bağımlılığı da olmasın (hesap değişse bile fonksiyon aynı kalır).
  const userRef = useRef<User | null>(user);
  userRef.current = user;
  const refreshProfile = useCallback(async () => {
    const u = userRef.current;
    if (u) setProfile(await fetchMyProfile(u.id));
  }, []);
  const clearPasswordRecovery = useCallback(() => setPasswordRecovery(false), []);

  // ⚠ Bağlam değeri MEMOIZE edilmeli. Süsleme değil: `AuthProvider` her
  // render'ında yeni bir nesne ürettiğinde `useAuth()` çağıran TÜM bileşenler
  // (Setup, UserMenu, ScoreCard, LiveGamesTab, App…) gereksiz yere yeniden
  // render oluyordu — 19 Eylül 2026'daki döngünün yükselteçlerinden biri.
  const value = useMemo(
    () => ({
      user,
      profile,
      loading,
      profileLoading,
      configured: isSupabaseConfigured,
      passwordRecovery,
      clearPasswordRecovery,
      refreshProfile,
    }),
    [user, profile, loading, profileLoading, passwordRecovery, clearPasswordRecovery, refreshProfile],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  return useContext(AuthContext);
}
