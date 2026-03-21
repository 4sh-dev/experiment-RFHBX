/**
 * Shared OIDC configuration factory.
 *
 * All values come from Vite env vars so they can be overridden per
 * environment without rebuilding.  The config is read lazily (at call
 * time rather than module load time) so that test stubs such as
 * `vi.stubEnv` are picked up correctly.
 */
export function getOidcConfig() {
  const authority = import.meta.env.VITE_OIDC_AUTHORITY ?? '';
  const clientId = import.meta.env.VITE_OIDC_CLIENT_ID ?? '';
  const redirectUri =
    import.meta.env.VITE_OIDC_REDIRECT_URI ?? `${window.location.origin}/auth/callback`;

  return { authority, clientId, redirectUri };
}
