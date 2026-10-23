import { test } from 'node:test';
import assert from 'node:assert/strict';

import { apiIstemcisiOlustur } from '../js/api.js';
import { oturumOlustur } from '../js/oturum.js';

function sahteDepo() {
  const veri = new Map();
  return {
    getItem: (k) => (veri.has(k) ? veri.get(k) : null),
    setItem: (k, v) => veri.set(k, String(v)),
    removeItem: (k) => veri.delete(k),
  };
}

function yanit(durum, govde) {
  return {
    status: durum,
    ok: durum >= 200 && durum < 300,
    text: async () => (govde === undefined ? '' : JSON.stringify(govde)),
  };
}

/** Sırayla yanıt veren sahte fetch; yapılan istekleri kaydeder. */
function sahteFetch(...yanitlar) {
  const istekler = [];
  const fn = async (url, secenekler = {}) => {
    istekler.push({ url, ...secenekler });
    const sonraki = yanitlar.shift();
    if (sonraki instanceof Error) throw sonraki;
    return sonraki;
  };
  fn.istekler = istekler;
  return fn;
}

const kullanici = { userId: 'u-1', fullName: 'Ayşe Yılmaz', role: 'Staff' };

function kurulum(fetchFn, { girisli = true } = {}) {
  const oturum = oturumOlustur(sahteDepo());
  if (girisli) {
    oturum.kaydet({ accessToken: 'eski-erisim', refreshToken: 'eski-yenileme', user: kullanici });
  }
  let yonlendirmeSayisi = 0;
  const api = apiIstemcisiOlustur({
    tabanUrl: 'http://sunucu',
    fetchFn,
    oturum,
    yetkisizde: () => {
      yonlendirmeSayisi += 1;
    },
  });
  return { api, oturum, yonlendirme: () => yonlendirmeSayisi };
}

test('giriş başarılıysa oturum kaydedilir', async () => {
  const fetchFn = sahteFetch(
    yanit(200, { accessToken: 'a', refreshToken: 'r', user: kullanici }),
  );
  const { api, oturum } = kurulum(fetchFn, { girisli: false });

  const sonuc = await api.giris('ayse@ornek.edu', 'parola');

  assert.equal(sonuc.ok, true);
  assert.equal(oturum.erisimBelirteci(), 'a');
  assert.equal(fetchFn.istekler[0].url, 'http://sunucu/api/auth/login');
  assert.equal(fetchFn.istekler[0].method, 'POST');
  assert.deepEqual(JSON.parse(fetchFn.istekler[0].body), {
    email: 'ayse@ornek.edu',
    password: 'parola',
  });
});

test('hatalı parolada sunucu hata kodu döner, yenileme denenmez', async () => {
  const fetchFn = sahteFetch(
    yanit(401, { error: { code: 'INVALID_CREDENTIALS', message: 'E-posta veya parola hatalı.', details: '' } }),
  );
  const { api, oturum, yonlendirme } = kurulum(fetchFn, { girisli: false });

  const sonuc = await api.giris('ayse@ornek.edu', 'yanlis');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.kod, 'INVALID_CREDENTIALS');
  assert.equal(sonuc.hata.mesaj, 'E-posta veya parola hatalı.');
  assert.equal(fetchFn.istekler.length, 1);
  assert.equal(oturum.girisYapildiMi(), false);
  assert.equal(yonlendirme(), 0);
});

test('korumalı istek Bearer başlığıyla gider', async () => {
  const fetchFn = sahteFetch(yanit(200, { items: [] }));
  const { api } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports?page=1');

  assert.equal(sonuc.ok, true);
  assert.deepEqual(sonuc.veri, { items: [] });
  assert.equal(fetchFn.istekler[0].url, 'http://sunucu/api/reports?page=1');
  assert.equal(fetchFn.istekler[0].headers.Authorization, 'Bearer eski-erisim');
});

test('401 gelirse bir kez yenilenir ve istek yeni belirteçle tekrarlanır', async () => {
  const fetchFn = sahteFetch(
    yanit(401, { error: { code: 'UNAUTHORIZED', message: 'Süre doldu.', details: '' } }),
    yanit(200, { accessToken: 'yeni-erisim', refreshToken: 'yeni-yenileme', user: kullanici }),
    yanit(200, { items: [1] }),
  );
  const { api, oturum, yonlendirme } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, true);
  assert.deepEqual(sonuc.veri, { items: [1] });
  assert.equal(fetchFn.istekler[1].url, 'http://sunucu/api/auth/refresh');
  assert.deepEqual(JSON.parse(fetchFn.istekler[1].body), { refreshToken: 'eski-yenileme' });
  assert.equal(fetchFn.istekler[2].headers.Authorization, 'Bearer yeni-erisim');
  assert.equal(oturum.yenilemeBelirteci(), 'yeni-yenileme');
  assert.equal(yonlendirme(), 0);
});

test('yenileme de başarısızsa oturum silinir ve girişe yönlendirilir', async () => {
  const fetchFn = sahteFetch(
    yanit(401, { error: { code: 'UNAUTHORIZED', message: 'Süre doldu.', details: '' } }),
    yanit(401, { error: { code: 'UNAUTHORIZED', message: 'Geçersiz.', details: '' } }),
  );
  const { api, oturum, yonlendirme } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.kod, 'UNAUTHORIZED');
  assert.equal(oturum.girisYapildiMi(), false);
  assert.equal(yonlendirme(), 1);
  assert.equal(fetchFn.istekler.length, 2);
});

test('yenilemeden sonra yine 401 gelirse sonsuz döngüye girilmez', async () => {
  const yetkisiz = () => yanit(401, { error: { code: 'UNAUTHORIZED', message: 'x', details: '' } });
  const fetchFn = sahteFetch(
    yetkisiz(),
    yanit(200, { accessToken: 'yeni', refreshToken: 'yeni-r', user: kullanici }),
    yetkisiz(),
  );
  const { api, oturum, yonlendirme } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(fetchFn.istekler.length, 3);
  assert.equal(oturum.girisYapildiMi(), false);
  assert.equal(yonlendirme(), 1);
});

test('eşzamanlı iki 401 tek yenileme isteği yapar', async () => {
  const yetkisiz = () => yanit(401, { error: { code: 'UNAUTHORIZED', message: 'x', details: '' } });
  const fetchFn = sahteFetch(
    yetkisiz(),
    yetkisiz(),
    yanit(200, { accessToken: 'yeni', refreshToken: 'yeni-r', user: kullanici }),
    yanit(200, { a: 1 }),
    yanit(200, { b: 2 }),
  );
  const { api } = kurulum(fetchFn);

  const [s1, s2] = await Promise.all([api.getir('/api/a'), api.getir('/api/b')]);

  assert.equal(s1.ok, true);
  assert.equal(s2.ok, true);
  const yenilemeler = fetchFn.istekler.filter((i) => i.url.endsWith('/api/auth/refresh'));
  assert.equal(yenilemeler.length, 1);
});

test('oturum yokken korumalı istek sunucuya gitmeden yönlendirir', async () => {
  const fetchFn = sahteFetch();
  const { api, yonlendirme } = kurulum(fetchFn, { girisli: false });

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.kod, 'UNAUTHORIZED');
  assert.equal(fetchFn.istekler.length, 0);
  assert.equal(yonlendirme(), 1);
});

test('403 rol hatası yönlendirme yapmadan döner', async () => {
  const fetchFn = sahteFetch(
    yanit(403, { error: { code: 'FORBIDDEN', message: 'Rol yetkisi yok.', details: '' } }),
  );
  const { api, oturum, yonlendirme } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.durum, 403);
  assert.equal(sonuc.hata.kod, 'FORBIDDEN');
  assert.equal(oturum.girisYapildiMi(), true);
  assert.equal(yonlendirme(), 0);
});

test('ağ hatası anlaşılır bir hataya çevrilir', async () => {
  const fetchFn = sahteFetch(new TypeError('Failed to fetch'));
  const { api } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.kod, 'AG_HATASI');
  assert.equal(sonuc.hata.durum, 0);
});

test('hata gövdesi beklenen biçimde değilse genel hata döner', async () => {
  const fetchFn = sahteFetch({ status: 500, ok: false, text: async () => 'Internal Server Error' });
  const { api } = kurulum(fetchFn);

  const sonuc = await api.getir('/api/reports');

  assert.equal(sonuc.ok, false);
  assert.equal(sonuc.hata.durum, 500);
  assert.equal(sonuc.hata.kod, 'BILINMEYEN_HATA');
});
