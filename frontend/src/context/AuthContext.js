import { createContext, useContext, useEffect, useMemo, useState } from "react";
import * as authApi from "../api/authApi";
import { setAccessToken } from "../api/client";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null); const [loading, setLoading] = useState(true);
  useEffect(() => { authApi.restoreSession().then(data => setUser(data?.user || null)).finally(() => setLoading(false)); }, []);
  const authenticate = async (action, payload) => { const data = await action(payload); setAccessToken(data.accessToken); setUser(data.user); return data; };
  const value = useMemo(() => ({ user, loading, signup: p => authenticate(authApi.signup, p), login: p => authenticate(authApi.login, p),
    logout: async () => { try { await authApi.logout(); } finally { setAccessToken(null); setUser(null); } } }), [user, loading]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() { const context = useContext(AuthContext); if (!context) throw new Error("AuthProvider가 필요합니다."); return context; }
