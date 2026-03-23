import { TanStackRouterVite } from '@tanstack/router-plugin/vite';
import react from '@vitejs/plugin-react-swc';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  // Load ALL env vars (not just VITE_-prefixed ones) so we can forward
  // DEV_AUTH_BYPASS from the root .env into the browser bundle.
  const env = loadEnv(mode, process.cwd(), '');

  const apiTarget = env.VITE_API_BASE_URL || 'http://localhost:3000';

  // Resolve the bypass flag: honour whichever variable the developer has set.
  // DEV_AUTH_BYPASS (no prefix, root .env) takes precedence over the
  // VITE_-prefixed variant so that a single root .env entry is enough.
  const devAuthBypass = env.DEV_AUTH_BYPASS || env.VITE_DEV_AUTH_BYPASS || 'false';

  return {
    plugins: [
      TanStackRouterVite({
        routesDirectory: './src/routes',
        generatedRouteTree: './src/routeTree.gen.ts',
      }),
      react(),
    ],
    define: {
      // Forward DEV_AUTH_BYPASS (root .env, no VITE_ prefix) to the browser
      // bundle as import.meta.env.VITE_DEV_AUTH_BYPASS.  This means setting
      // DEV_AUTH_BYPASS=true in the root .env is sufficient to activate the
      // dev-bypass flow in both the backend and the frontend.
      'import.meta.env.VITE_DEV_AUTH_BYPASS': JSON.stringify(devAuthBypass),
    },
    server: {
      host: true,
      proxy: {
        '/api': {
          target: apiTarget,
          changeOrigin: true,
        },
      },
    },
  };
});
