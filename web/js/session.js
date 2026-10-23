// Sayfaların paylaştığı oturum kurulumu: tek depo, tek API istemcisi, 401'de girişe yönlendirme.

import { API_BASE_URL, LOGIN_PAGE, REPORTS_PAGE } from './config.js';
import { createApiClient } from './api.js';
import { createTokenStore } from './token-store.js';

export const store = createTokenStore();

/** Girişe gider; giriş sonrası dönülecek sayfayı `next` ile taşır. */
export function redirectToLogin() {
  const next = `${location.pathname.split('/').pop()}${location.search}`;
  location.assign(`${LOGIN_PAGE}?next=${encodeURIComponent(next)}`);
}

/** Yalnızca uygulamanın kendi liste sayfasına dönülür (açık yönlendirme yok). */
export function safeNext(search) {
  const next = new URLSearchParams(search).get('next') ?? '';
  return next.startsWith(`${REPORTS_PAGE}`) ? next : REPORTS_PAGE;
}

export const api = createApiClient({ baseUrl: API_BASE_URL, store, onUnauthorized: redirectToLogin });
