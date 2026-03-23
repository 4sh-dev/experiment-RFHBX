import { cleanup, render, renderHook, screen, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

// ---------------------------------------------------------------------------
// Mock oidc-client-ts so tests never hit a real OIDC server.
// ---------------------------------------------------------------------------
const mockGetUser = vi.fn();
const mockSigninRedirect = vi.fn();
const mockSignoutRedirect = vi.fn();
const mockEvents = {
  addUserLoaded: vi.fn(),
  addUserUnloaded: vi.fn(),
  addSilentRenewError: vi.fn(),
  addAccessTokenExpired: vi.fn(),
  removeUserLoaded: vi.fn(),
  removeUserUnloaded: vi.fn(),
  removeSilentRenewError: vi.fn(),
  removeAccessTokenExpired: vi.fn(),
};

vi.mock('oidc-client-ts', () => ({
  UserManager: vi.fn().mockImplementation(() => ({
    getUser: mockGetUser,
    signinRedirect: mockSigninRedirect,
    signoutRedirect: mockSignoutRedirect,
    events: mockEvents,
  })),
  WebStorageStateStore: vi.fn().mockImplementation(() => ({})),
  User: class {},
}));

// Provide dummy env vars so the UserManager constructor path is exercised.
vi.stubEnv('VITE_OIDC_AUTHORITY', 'https://auth.example.com');
vi.stubEnv('VITE_OIDC_CLIENT_ID', 'test-client');
vi.stubEnv('VITE_OIDC_REDIRECT_URI', 'http://localhost:5173/auth/callback');

import { AuthProvider, useAuth } from './AuthContext';

function wrapper({ children }: { children: ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>;
}

describe('AuthProvider — OIDC mode', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    cleanup();
  });

  it('starts in loading state then resolves to unauthenticated when no session', async () => {
    mockGetUser.mockResolvedValueOnce(null);

    const { result } = renderHook(() => useAuth(), { wrapper });

    // Initially loading.
    expect(result.current.isLoading).toBe(true);

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('becomes authenticated when UserManager returns a valid user', async () => {
    const fakeUser = {
      access_token: 'test-access-token',
      expired: false,
      profile: { sub: 'user-123', name: 'Frodo Baggins', email: 'frodo@shire.me' },
    };
    mockGetUser.mockResolvedValueOnce(fakeUser);

    const { result } = renderHook(() => useAuth(), { wrapper });

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).toEqual(fakeUser);
    expect(result.current.getAccessToken()).toBe('test-access-token');
  });

  it('renders children regardless of auth state', async () => {
    mockGetUser.mockResolvedValueOnce(null);

    render(
      <AuthProvider>
        <span data-testid="child">hello</span>
      </AuthProvider>,
    );

    expect(screen.getByTestId('child')).toBeInTheDocument();
  });

  it('calls signinRedirect when login() is invoked', async () => {
    mockGetUser.mockResolvedValueOnce(null);
    mockSigninRedirect.mockResolvedValueOnce(undefined);

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    await result.current.login('/dashboard');

    expect(mockSigninRedirect).toHaveBeenCalledWith(
      expect.objectContaining({ state: '/dashboard' }),
    );
  });

  it('calls signoutRedirect and clears user when logout() is invoked', async () => {
    const fakeUser = {
      access_token: 'tok',
      expired: false,
      profile: { sub: 'u1' },
    };
    mockGetUser.mockResolvedValueOnce(fakeUser);
    mockSignoutRedirect.mockResolvedValueOnce(undefined);

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isAuthenticated).toBe(true));

    await result.current.logout();

    expect(mockSignoutRedirect).toHaveBeenCalled();
    // User is cleared synchronously before the redirect.
    expect(result.current.user).toBeNull();
  });

  it('throws when useAuth is used outside <AuthProvider>', () => {
    // Suppress React's console.error for this expected throw.
    const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
    expect(() => renderHook(() => useAuth())).toThrow('useAuth must be used inside <AuthProvider>');
    spy.mockRestore();
  });
});

// ---------------------------------------------------------------------------
// Dev-bypass mode tests
// ---------------------------------------------------------------------------

describe('AuthProvider — DEV_AUTH_BYPASS mode', () => {
  const devAuthResponse = {
    token: 'dev-bypass-token-xyz',
    user: { sub: 'dev-user', email: 'dev@mordors-edge.local', name: 'Dev User' },
  };

  beforeEach(() => {
    vi.clearAllMocks();
    vi.stubEnv('VITE_DEV_AUTH_BYPASS', 'true');
  });

  afterEach(() => {
    cleanup();
    vi.unstubAllEnvs();
  });

  it('auto-authenticates on mount without user interaction when bypass is active', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValueOnce({
        ok: true,
        json: async () => devAuthResponse,
      }),
    );

    const { result } = renderHook(() => useAuth(), { wrapper });

    // Starts loading.
    expect(result.current.isLoading).toBe(true);

    // Resolves to authenticated without any user action.
    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.devUser).toEqual(devAuthResponse.user);
    expect(result.current.getAccessToken()).toBe('dev-bypass-token-xyz');
    expect(result.current.user).toBeNull(); // OIDC user is never set
  });

  it('calls POST /api/dev/auth automatically on mount', async () => {
    const fetchMock = vi.fn().mockResolvedValueOnce({
      ok: true,
      json: async () => devAuthResponse,
    });
    vi.stubGlobal('fetch', fetchMock);

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    expect(fetchMock).toHaveBeenCalledWith('/api/dev/auth', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });
  });

  it('does not initialise UserManager when bypass is active', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValueOnce({
        ok: true,
        json: async () => devAuthResponse,
      }),
    );

    const { UserManager } = await import('oidc-client-ts');
    const mockUserManagerCtor = vi.mocked(UserManager);
    mockUserManagerCtor.mockClear();

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    // UserManager should NOT have been constructed in bypass mode.
    expect(mockUserManagerCtor).not.toHaveBeenCalled();
  });

  it('falls through to unauthenticated if auto-bypass fetch fails', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValueOnce({
        ok: false,
        status: 503,
      }),
    );

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.devUser).toBeNull();
    consoleSpy.mockRestore();
  });

  it('clears dev session on logout without redirecting', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValueOnce({
        ok: true,
        json: async () => devAuthResponse,
      }),
    );

    const { result } = renderHook(() => useAuth(), { wrapper });
    await waitFor(() => expect(result.current.isAuthenticated).toBe(true));

    await result.current.logout();

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.devUser).toBeNull();
    expect(result.current.getAccessToken()).toBeNull();
    // No OIDC signout redirect should occur.
    expect(mockSignoutRedirect).not.toHaveBeenCalled();
  });
});
