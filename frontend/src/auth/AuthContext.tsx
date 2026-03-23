import { type User, UserManager, WebStorageStateStore } from 'oidc-client-ts';
import {
  createContext,
  type ReactNode,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import { flushSync } from 'react-dom';
import { clearAuthTokenAccessor, setAuthTokenAccessor } from '../lib/api';
import { getOidcConfig } from './oidcConfig';

// ---------------------------------------------------------------------------
// Dev bypass types
// ---------------------------------------------------------------------------

export interface DevUser {
  sub: string;
  email: string;
  name: string;
}

// ---------------------------------------------------------------------------
// AuthContext public API
// ---------------------------------------------------------------------------
export interface AuthContextValue {
  /** The current OIDC user (null while loading, unauthenticated, or in dev-bypass mode). */
  user: User | null;
  /** Dev-bypass user info — populated only when DEV_AUTH_BYPASS is active. */
  devUser: DevUser | null;
  /** True once the initial silent-signin / session-restore has completed. */
  isLoading: boolean;
  /** True when a valid, non-expired user is present (OIDC or dev-bypass). */
  isAuthenticated: boolean;
  /** Redirect to the OIDC provider login page (PKCE). */
  login: (returnTo?: string) => Promise<void>;
  /** End the OIDC session and clear in-memory state. */
  logout: () => Promise<void>;
  /** Return the raw access token string, or null if not authenticated. */
  getAccessToken: () => string | null;
  /**
   * Dev-bypass login — only available when VITE_DEV_AUTH_BYPASS=true.
   * Calls POST /api/dev/auth, retrieves a signed bypass token, and sets
   * the auth state without going through an OIDC provider.
   */
  devLogin: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// ---------------------------------------------------------------------------
// Dev bypass flag — evaluated once at module load time.
// Vite replaces import.meta.env.VITE_* at build time; the VITE_ prefix is
// required for the value to be present in the browser bundle.
// ---------------------------------------------------------------------------
const DEV_AUTH_BYPASS = import.meta.env.VITE_DEV_AUTH_BYPASS === 'true';

// ---------------------------------------------------------------------------
// AuthProvider
// ---------------------------------------------------------------------------

/**
 * Wraps the application tree and manages the full OIDC token lifecycle:
 * - PKCE redirect flow
 * - In-memory token storage (never localStorage)
 * - Silent token renewal before expiry
 * - Dev bypass mode (VITE_DEV_AUTH_BYPASS=true, development only)
 * - Exposes login/logout helpers and user info via context
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const managerRef = useRef<UserManager | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Dev-bypass state — kept separately from OIDC user state.
  const [devToken, setDevToken] = useState<string | null>(null);
  const [devUser, setDevUser] = useState<DevUser | null>(null);

  // Lazily initialise the UserManager once.
  // getOidcConfig() reads env vars at call time so that test stubs (vi.stubEnv) apply.
  // Skip OIDC setup entirely when dev bypass is active.
  const { authority, clientId, redirectUri } = getOidcConfig();

  if (!DEV_AUTH_BYPASS && !managerRef.current && authority && clientId) {
    managerRef.current = new UserManager({
      authority,
      client_id: clientId,
      redirect_uri: redirectUri,
      response_type: 'code',
      scope: 'openid profile email',
      // Store OIDC metadata (not tokens) in sessionStorage so the state
      // survives the redirect round-trip but is cleared when the tab closes.
      // Access tokens are held only in the UserManager's in-memory store.
      stateStore: new WebStorageStateStore({ store: window.sessionStorage }),
      userStore: new WebStorageStateStore({ store: window.sessionStorage }),
      automaticSilentRenew: true,
      // Use an iframe for silent renewal when supported by the provider.
      silent_redirect_uri: `${window.location.origin}/auth/silent-callback`,
    });
  }

  const manager = managerRef.current;

  // Initialise auth state on mount.
  useEffect(() => {
    if (DEV_AUTH_BYPASS) {
      // Auto dev-bypass: authenticate immediately against the backend's dev
      // endpoint, without any user interaction or OIDC provider.
      // isLoading stays true until the request settles so the loading spinner
      // is shown for only as long as necessary.
      fetch('/api/dev/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      })
        .then(async (response) => {
          if (!response.ok) throw new Error(`Dev auth failed: ${response.status}`);
          const data = (await response.json()) as { token: string; user: DevUser };
          setDevToken(data.token);
          setDevUser(data.user);
          setAuthTokenAccessor(() => data.token);
        })
        .catch((err) => {
          // If the auto-bypass fails (e.g. backend not running yet), log the
          // error and fall through to unauthenticated state so the login page
          // is shown with the manual "Dev Login" button as a fallback.
          console.error('[DevAuth] Auto-bypass login failed:', err);
        })
        .finally(() => setIsLoading(false));
      return; // no OIDC event listeners needed
    }

    if (!manager) {
      setIsLoading(false);
      return;
    }

    const onUserLoaded = (u: User) => setUser(u);
    const onUserUnloaded = () => setUser(null);
    const onSilentRenewError = () => setUser(null);
    const onAccessTokenExpired = () => setUser(null);

    manager.events.addUserLoaded(onUserLoaded);
    manager.events.addUserUnloaded(onUserUnloaded);
    manager.events.addSilentRenewError(onSilentRenewError);
    manager.events.addAccessTokenExpired(onAccessTokenExpired);

    // Attempt to restore an existing session from the state store.
    manager
      .getUser()
      .then((existingUser) => {
        if (existingUser && !existingUser.expired) {
          setUser(existingUser);
        }
      })
      .catch(() => {
        // No valid session — that is fine; user will be prompted to login.
      })
      .finally(() => setIsLoading(false));

    return () => {
      manager.events.removeUserLoaded(onUserLoaded);
      manager.events.removeUserUnloaded(onUserUnloaded);
      manager.events.removeSilentRenewError(onSilentRenewError);
      manager.events.removeAccessTokenExpired(onAccessTokenExpired);
    };
  }, [manager]);

  // Keep the Axios interceptor accessor in sync with the current user.
  useEffect(() => {
    if (user && !user.expired) {
      setAuthTokenAccessor(() => user.access_token);
    } else if (devToken) {
      setAuthTokenAccessor(() => devToken);
    } else {
      clearAuthTokenAccessor();
    }
  }, [user, devToken]);

  const login = useCallback(
    async (returnTo?: string) => {
      if (!manager) return;
      await manager.signinRedirect({
        // Stash the intended route so the callback can restore it.
        state: returnTo ?? window.location.pathname + window.location.search,
      });
    },
    [manager],
  );

  const logout = useCallback(async () => {
    // Clear dev-bypass state.
    if (devToken) {
      flushSync(() => {
        setDevToken(null);
        setDevUser(null);
        clearAuthTokenAccessor();
      });
      return;
    }

    if (!manager) return;
    // Flush synchronously so the UI reflects the cleared user before the
    // redirect fires (also makes the state update observable in tests).
    flushSync(() => {
      setUser(null);
      clearAuthTokenAccessor();
    });
    await manager.signoutRedirect();
  }, [manager, devToken]);

  const getAccessToken = useCallback((): string | null => {
    if (devToken) return devToken;
    return user?.access_token ?? null;
  }, [user, devToken]);

  /**
   * Dev-bypass login.  Calls the backend's dev auth endpoint to obtain a
   * signed bypass token, then stores it in place of an OIDC access token.
   * Only available when VITE_DEV_AUTH_BYPASS=true; used as a manual fallback
   * if the auto-bypass on mount fails (e.g. backend not yet ready).
   */
  const devLogin = useCallback(async (): Promise<void> => {
    const response = await fetch('/api/dev/auth', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });

    if (!response.ok) {
      throw new Error(`Dev auth failed: ${response.status}`);
    }

    const data = (await response.json()) as { token: string; user: DevUser };
    setDevToken(data.token);
    setDevUser(data.user);
    setAuthTokenAccessor(() => data.token);
  }, []);

  const isAuthenticated = (!!user && !user.expired) || !!devToken;

  const value: AuthContextValue = {
    user,
    devUser,
    isLoading,
    isAuthenticated,
    login,
    logout,
    getAccessToken,
    devLogin,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// ---------------------------------------------------------------------------
// useAuth hook
// ---------------------------------------------------------------------------

/** Consume the AuthContext. Must be called inside <AuthProvider>. */
export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used inside <AuthProvider>');
  }
  return ctx;
}
