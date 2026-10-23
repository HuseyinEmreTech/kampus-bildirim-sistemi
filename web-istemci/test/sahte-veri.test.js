import { test } from 'node:test';
import assert from 'node:assert/strict';

import { sahteFetchOlustur, SAHTE_PAROLA, SAHTE_RAPORLAR } from '../js/sahte-veri.js';
import { raporOku } from '../js/rapor.js';

const fetchFn = sahteFetchOlustur({ gecikmeMs: 0 });

async function json(url, secenekler) {
  const y = await fetchFn(url, secenekler);
  return { durum: y.status, govde: JSON.parse(await y.text()) };
}

function giris(email, parola) {
  return json('http://x/api/auth/login', {
    method: 'POST',
    headers: {},
    body: JSON.stringify({ email, password: parola }),
  });
}

const yetkili = { headers: { Authorization: 'Bearer sahte-erisim-Staff' } };

test('sahte verinin tamamı istemcinin okuyabildiği biçimdedir', () => {
  assert.ok(SAHTE_RAPORLAR.length > 20);
  for (const r of SAHTE_RAPORLAR) assert.notEqual(raporOku(r), null, r.reportId);
});

test('sahte parolayla görevli girişi yapılır', async () => {
  const { durum, govde } = await giris('gorevli@ornek.edu', SAHTE_PAROLA);
  assert.equal(durum, 200);
  assert.equal(govde.user.role, 'Staff');
});

test('ogrenci ile başlayan e-posta öğrenci olarak girer', async () => {
  const { govde } = await giris('ogrenci@ornek.edu', SAHTE_PAROLA);
  assert.equal(govde.user.role, 'Student');
});

test('yanlış parola INVALID_CREDENTIALS döner', async () => {
  const { durum, govde } = await giris('gorevli@ornek.edu', 'yanlis');
  assert.equal(durum, 401);
  assert.equal(govde.error.code, 'INVALID_CREDENTIALS');
});

test('belirteç olmadan liste 401 döner', async () => {
  const { durum } = await json('http://x/api/reports', { headers: {} });
  assert.equal(durum, 401);
});

test('öğrenci belirteciyle liste 403 döner', async () => {
  const { durum } = await json('http://x/api/reports', {
    headers: { Authorization: 'Bearer sahte-erisim-Student' },
  });
  assert.equal(durum, 403);
});

test('liste filtrelenir ve sayfalanır', async () => {
  const { govde } = await json('http://x/api/reports?status=Yeni&page=1&pageSize=5', yetkili);
  const toplamYeni = SAHTE_RAPORLAR.filter((r) => r.status === 'Yeni').length;

  assert.equal(govde.total, toplamYeni);
  assert.equal(govde.items.length, Math.min(5, toplamYeni));
  assert.ok(govde.items.every((r) => r.status === 'Yeni'));
});

test('liste en yeni bildirim önce gelir', async () => {
  const { govde } = await json('http://x/api/reports?pageSize=100', yetkili);
  const tarihler = govde.items.map((r) => Date.parse(r.createdAt));
  assert.deepEqual(tarihler, [...tarihler].sort((a, b) => b - a));
});

test('eşleşme yoksa boş liste döner', async () => {
  const { govde } = await json('http://x/api/reports?status=Cozuldu&category=Guvenlik&page=99', yetkili);
  assert.deepEqual(govde.items, []);
});
