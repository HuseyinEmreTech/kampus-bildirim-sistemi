// Dart çekirdeğinin REST API'si için istemci (05-api-design).
// Proje kuralına uygun olarak hata fırlatmaz; her çağrı { ok, data } ya da { ok: false, error } döner.

const NETWORK_ERROR = { status: 0, code: 'NETWORK_ERROR', message: 'Sunucuya ulaşılamadı.' };
const UNAUTHORIZED = { status: 401, code: 'UNAUTHORIZED', message: 'Oturumun sona erdi, yeniden giriş yap.' };

export function createApiClient({ baseUrl, store, fetchFn = window.fetch.bind(window), onUnauthorized }) {
  async function send(path, { method = 'GET', body, auth = true } = {}) {
    const headers = {};
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    if (auth) headers.Authorization = `Bearer ${store.accessToken()}`;
    try {
      const response = await fetchFn(`${baseUrl}${path}`, {
        method,
        headers,
        body: body === undefined ? undefined : JSON.stringify(body),
      });
      return { response };
    } catch {
      return { networkError: true };
    }
  }

  async function toResult({ response, networkError }) {
    if (networkError) return { ok: false, error: NETWORK_ERROR };
    const json = await response.json().catch(() => null);
    if (response.ok) return { ok: true, data: json };
    const error = json?.error ?? {};
    return {
      ok: false,
      error: {
        status: response.status,
        code: error.code ?? 'UNKNOWN',
        message: error.message || `Beklenmeyen hata (${response.status}).`,
      },
    };
  }

  async function refreshSession() {
    const refreshToken = store.refreshToken();
    if (!refreshToken) return false;
    const result = await toResult(
      await send('/api/auth/refresh', { method: 'POST', body: { refreshToken }, auth: false }),
    );
    if (!result.ok) return false;
    store.save(result.data);
    return true;
  }

  function endSession() {
    store.clear();
    onUnauthorized?.();
    return { ok: false, error: UNAUTHORIZED };
  }

  /** Korumalı istek: 401 gelirse bir kez yeniler, olmazsa oturumu kapatıp girişe yönlendirir. */
  async function authorized(path, options = {}) {
    if (!store.hasSession()) return endSession();
    let sent = await send(path, options);
    if (sent.response?.status === 401) {
      if (!(await refreshSession())) return endSession();
      sent = await send(path, options);
      if (sent.response?.status === 401) return endSession();
    }
    return toResult(sent);
  }

  return {
    async login(email, password) {
      const result = await toResult(
        await send('/api/auth/login', { method: 'POST', body: { email, password }, auth: false }),
      );
      if (result.ok) store.save(result.data);
      return result;
    },
    listReports(filters) {
      return authorized(`/api/reports?${reportQuery(filters)}`);
    },
    listBuildings() {
      return authorized('/api/buildings');
    },
  };
}

/** Boş filtreleri atlayarak sorgu dizgesi üretir. */
export function reportQuery({ status, category, buildingId, page, pageSize }) {
  const params = new URLSearchParams();
  if (status) params.set('status', status);
  if (category) params.set('category', category);
  if (buildingId) params.set('buildingId', buildingId);
  params.set('page', String(page));
  params.set('pageSize', String(pageSize));
  return params.toString();
}
