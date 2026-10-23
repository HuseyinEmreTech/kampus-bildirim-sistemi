import { createApiClient } from '../js/api.js';
import { createTokenStore } from '../js/token-store.js';
import { test, assertEqual, assertTrue, fakeFetch, memoryStorage } from './harness.js';

const BASE = 'http://api.test';
const SESSION = {
  accessToken: 'erisim-1',
  refreshToken: 'yenileme-1',
  user: { userId: 'u1', fullName: 'Ayşe Yılmaz', role: 'Staff' },
};

function setup(responses, { loggedIn = true } = {}) {
  const store = createTokenStore(memoryStorage());
  if (loggedIn) store.save(SESSION);
  const fetchFn = fakeFetch(responses);
  let unauthorizedCount = 0;
  const api = createApiClient({
    baseUrl: BASE,
    store,
    fetchFn,
    onUnauthorized: () => {
      unauthorizedCount += 1;
    },
  });
  return { api, store, fetchFn, unauthorized: () => unauthorizedCount };
}

test('giriş başarılıysa belirteçler saklanır', async () => {
  const { api, store } = setup([{ status: 200, body: SESSION }], { loggedIn: false });
  const result = await api.login('ayse@ornek.edu', 'parola');
  assertTrue(result.ok, 'giriş başarılı olmalı');
  assertEqual(store.accessToken(), 'erisim-1');
  assertEqual(store.user().fullName, 'Ayşe Yılmaz');
});

test('hatalı parolada INVALID_CREDENTIALS döner, yönlendirme olmaz', async () => {
  const { api, store, unauthorized } = setup(
    [{ status: 401, body: { error: { code: 'INVALID_CREDENTIALS', message: 'Hatalı.', details: '' } } }],
    { loggedIn: false },
  );
  const result = await api.login('ayse@ornek.edu', 'yanlis');
  assertEqual(result.ok, false);
  assertEqual(result.error.code, 'INVALID_CREDENTIALS');
  assertEqual(store.hasSession(), false);
  assertEqual(unauthorized(), 0);
});

test('korumalı istekte Bearer belirteci gönderilir', async () => {
  const { api, fetchFn } = setup([{ status: 200, body: [] }]);
  await api.listBuildings();
  assertEqual(fetchFn.calls[0].url, `${BASE}/api/buildings`);
  assertEqual(fetchFn.calls[0].options.headers.Authorization, 'Bearer erisim-1');
});

test('401 gelirse belirteç yenilenir ve istek tekrarlanır', async () => {
  const { api, store, fetchFn, unauthorized } = setup([
    { status: 401, body: { error: { code: 'UNAUTHORIZED', message: '', details: '' } } },
    { status: 200, body: { ...SESSION, accessToken: 'erisim-2', refreshToken: 'yenileme-2' } },
    { status: 200, body: [] },
  ]);
  const result = await api.listBuildings();
  assertTrue(result.ok, 'yenilemeden sonra istek başarılı olmalı');
  assertEqual(fetchFn.calls[1].url, `${BASE}/api/auth/refresh`);
  assertEqual(JSON.parse(fetchFn.calls[1].options.body), { refreshToken: 'yenileme-1' });
  assertEqual(fetchFn.calls[2].options.headers.Authorization, 'Bearer erisim-2');
  assertEqual(store.refreshToken(), 'yenileme-2');
  assertEqual(unauthorized(), 0);
});

test('yenileme de başarısızsa oturum silinir ve girişe yönlendirilir', async () => {
  const { api, store, unauthorized } = setup([
    { status: 401, body: { error: { code: 'UNAUTHORIZED', message: '', details: '' } } },
    { status: 401, body: { error: { code: 'UNAUTHORIZED', message: '', details: '' } } },
  ]);
  const result = await api.listBuildings();
  assertEqual(result.ok, false);
  assertEqual(result.error.code, 'UNAUTHORIZED');
  assertEqual(store.hasSession(), false);
  assertEqual(unauthorized(), 1);
});

test('oturum yoksa istek atılmadan girişe yönlendirilir', async () => {
  const { api, fetchFn, unauthorized } = setup([], { loggedIn: false });
  const result = await api.listBuildings();
  assertEqual(result.ok, false);
  assertEqual(fetchFn.calls.length, 0);
  assertEqual(unauthorized(), 1);
});

test('ağ hatası NETWORK_ERROR olarak döner', async () => {
  const { api } = setup([new TypeError('Failed to fetch')]);
  const result = await api.listBuildings();
  assertEqual(result.error.code, 'NETWORK_ERROR');
});

test('bildirim listesi filtreleri sorgu dizgesine çevrilir', async () => {
  const { api, fetchFn } = setup([{ status: 200, body: { items: [], page: 2, pageSize: 20, total: 0 } }]);
  await api.listReports({ status: 'Yeni', category: '', buildingId: 'b1', page: 2, pageSize: 20 });
  assertEqual(fetchFn.calls[0].url, `${BASE}/api/reports?status=Yeni&buildingId=b1&page=2&pageSize=20`);
});
