import { test } from 'node:test';
import assert from 'node:assert/strict';

import { raporOku, sayfaliYanitOku, tarihBicimle, yerMetni } from '../js/rapor.js';

const ornek = {
  reportId: 'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
  category: 'Ariza',
  description: 'B blok 2. kat koridor lambası yanmıyor',
  status: 'Yeni',
  place: 'B Blok 2. kat',
  buildingName: null,
  photoUrl: '/files/lamba.jpg',
  assigneeId: null,
  createdAt: '2026-10-02T09:15:00Z',
};

test('geçerli bildirim okunur', () => {
  const r = raporOku(ornek);
  assert.equal(r.id, ornek.reportId);
  assert.equal(r.kategori, 'Ariza');
  assert.equal(r.durum, 'Yeni');
  assert.equal(r.aciklama, ornek.description);
  assert.equal(r.yer, 'B Blok 2. kat');
  assert.equal(r.fotografUrl, '/files/lamba.jpg');
  assert.equal(r.olusturma.toISOString(), '2026-10-02T09:15:00.000Z');
});

test('zorunlu alanı eksik veya geçersiz bildirim okunmaz', () => {
  assert.equal(raporOku({ ...ornek, reportId: undefined }), null);
  assert.equal(raporOku({ ...ornek, status: 'Silindi' }), null);
  assert.equal(raporOku({ ...ornek, category: 'Bilinmeyen' }), null);
  assert.equal(raporOku({ ...ornek, createdAt: 'dün' }), null);
  assert.equal(raporOku(null), null);
});

test('yer bilgisi yoksa bina adı, o da yoksa belirtilmedi yazılır', () => {
  assert.equal(yerMetni(raporOku({ ...ornek, place: null, buildingName: 'Kütüphane' })), 'Kütüphane');
  assert.equal(yerMetni(raporOku({ ...ornek, place: null })), 'Konum belirtilmedi');
});

test('domain örneğindeki iç içe konum da okunur', () => {
  const r = raporOku({ ...ornek, place: undefined, location: { place: 'A Blok' } });
  assert.equal(r.yer, 'A Blok');
});

test('sayfalı yanıt okunur, bozuk kayıtlar atlanır', () => {
  const y = sayfaliYanitOku({
    items: [ornek, { bozuk: true }],
    page: 1,
    pageSize: 20,
    total: 2,
  });
  assert.equal(y.items.length, 1);
  assert.equal(y.atlanan, 1);
  assert.equal(y.total, 2);
});

test('biçimi bozuk sayfalı yanıt okunmaz', () => {
  assert.equal(sayfaliYanitOku(null), null);
  assert.equal(sayfaliYanitOku({ items: 'x', page: 1, pageSize: 20, total: 0 }), null);
  assert.equal(sayfaliYanitOku({ items: [], page: 1, pageSize: 20 }), null);
});

test('tarih Türkiye saatiyle biçimlenir', () => {
  const metin = tarihBicimle(new Date('2026-10-02T09:15:00Z'));
  assert.match(metin, /2026/);
  assert.match(metin, /12:15/);
});
