import { createFileRoute } from '@tanstack/react-router';
import { UserManager } from 'oidc-client-ts';
import { useEffect } from 'react';
import { getOidcConfig } from '../auth/oidcConfig';

/**
 * Handles the silent-renewal iframe callback.
 *
 * The UserManager opens this page inside a hidden iframe to obtain a fresh
 * access token via the OIDC provider's session cookie.  It must complete the
 * exchange and then signal the parent frame — `signinSilentCallback()` does
 * exactly that.
 */
function AuthSilentCallbackPage() {
  useEffect(() => {
    const { authority, clientId, redirectUri } = getOidcConfig();

    if (!authority || !clientId) return;

    const manager = new UserManager({
      authority,
      client_id: clientId,
      redirect_uri: redirectUri,
    });

    manager.signinSilentCallback().catch(() => {
      // Silent renewal failed — the parent frame's UserManager will emit
      // a silentRenewError event, which AuthProvider handles by clearing state.
    });
  }, []);

  return null;
}

export const Route = createFileRoute('/auth/silent-callback')({
  component: AuthSilentCallbackPage,
});
