import { createFileRoute, useRouter } from '@tanstack/react-router';
import { UserManager } from 'oidc-client-ts';
import { useEffect } from 'react';
import { getOidcConfig } from '../auth/oidcConfig';

/**
 * Handles the OIDC redirect callback.
 *
 * After a successful login the OIDC provider redirects the browser here with
 * an authorisation code.  We complete the PKCE exchange, then navigate the
 * user to wherever they originally wanted to go (stored in the OIDC `state`
 * parameter by `login()`).
 */
function AuthCallbackPage() {
  const router = useRouter();

  useEffect(() => {
    const { authority, clientId, redirectUri } = getOidcConfig();

    if (!authority || !clientId) {
      router.navigate({ to: '/' });
      return;
    }

    const manager = new UserManager({
      authority,
      client_id: clientId,
      redirect_uri: redirectUri,
    });

    manager
      .signinRedirectCallback()
      .then((user) => {
        // The `state` parameter carries the original route the user tried to visit.
        const returnTo = typeof user.state === 'string' ? user.state : '/';
        router.navigate({ to: returnTo });
      })
      .catch(() => {
        router.navigate({ to: '/' });
      });
  }, [router]);

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
      }}
    >
      <p>Completing sign-in…</p>
    </div>
  );
}

export const Route = createFileRoute('/auth/callback')({ component: AuthCallbackPage });
