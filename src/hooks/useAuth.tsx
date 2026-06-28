// Harfik — kimlik doğrulama bağlamı (Supabase Auth)
import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';
import type { User } from '@supabase/supabase-js';
import { supabase, isSupabaseConfigured } from '../lib/supabase';
import { fetchMyProfile } from '../lib/api';
import type { Profile } from '../lib/database.types';

interface AuthContextValue {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  /** Supabase anahtarları ayarlı mı? */
  configured: boolean;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  profile: null,
  loading: true,
  configured: false,
  refreshProfile: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!supabase) {
      setLoading(false);
      return;
    }
    supabase.auth.getSession().then(({ data }) => {
      setUser(data.session?.user ?? null);
      setLoading(false);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  // Kullanıcı değişince profilini çek.
  useEffect(() => {
    let active = true;
    if (user) {
      fetchMyProfile().then((p) => {
        if (active) setProfile(p);
      });
    } else {
      setProfile(null);
    }
    return () => {
      active = false;
    };
  }, [user]);

  const refreshProfile = async () => {
    if (user) setProfile(await fetchMyProfile());
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        loading,
        configured: isSupabaseConfigured,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  return useContext(AuthContext);
}
