import { test } from 'node:test';
import assert from 'node:assert/strict';

import { oturumOlustur } from '../js/oturum.js';

function sahteDepo() {
  const veri = new Map();
  return {
    getItem: (k) => (veri.has(k) ? veri.get(k) : null),
    setItem: (k, v) => veri.set(k, String(v)),
    removeItem: (k) => veri.delete(k),
  };
}

const girisYaniti = {
  accessToken: 'erisim-1',
  refreshToken: 'yenileme-1',
  user: { userId: 'u-1', fullName: 'Ayşe Yılmaz', role: 'Staff' },
};

test('kayıt yokken giriş yapılmamış sayılır', () => {
  const oturum = oturumOlustur(sahteDepo());
  assert.equal(oturum.girisYapildiMi(), false);
  assert.equal(oturum.erisimBelirteci(), null);
  assert.equal(oturum.kullanici(), null);
});

test('giriş yanıtı kaydedilir ve geri okunur', () => {
  const oturum = oturumOlustur(sahteDepo());
  oturum.kaydet(girisYaniti);

  assert.equal(oturum.girisYapildiMi(), true);
  assert.equal(oturum.erisimBelirteci(), 'erisim-1');
  assert.equal(oturum.yenilemeBelirteci(), 'yenileme-1');
  assert.deepEqual(oturum.kullanici(), girisYaniti.user);
});

test('temizle sonrası oturum kalmaz', () => {
  const oturum = oturumOlustur(sahteDepo());
  oturum.kaydet(girisYaniti);
  oturum.temizle();

  assert.equal(oturum.girisYapildiMi(), false);
  assert.equal(oturum.yenilemeBelirteci(), null);
});

test('bozuk kayıt oturum yok sayılır', () => {
  const depo = sahteDepo();
  depo.setItem('campus.oturum', '{bozuk json');
  const oturum = oturumOlustur(depo);

  assert.equal(oturum.girisYapildiMi(), false);
});

test('eksik alanlı yanıt kaydedilmez', () => {
  const oturum = oturumOlustur(sahteDepo());
  oturum.kaydet({ accessToken: 'yalniz-erisim' });

  assert.equal(oturum.girisYapildiMi(), false);
});
