import { test } from 'node:test';
import assert from 'node:assert/strict';

import { bosListeMesaji, listeHataMesaji, sayacMetni } from '../js/raporlar.js';

const filtresiz = { status: '', category: '', page: 1, pageSize: 20 };

test('filtre yokken boş liste "henüz bildirim yok" der', () => {
  const m = bosListeMesaji(filtresiz);
  assert.match(m.baslik, /Henüz bildirim yok/);
  assert.equal(m.temizlenebilir, false);
});

test('filtre varken boş liste filtreyi temizlemeyi önerir', () => {
  const m = bosListeMesaji({ ...filtresiz, status: 'Cozuldu' });
  assert.match(m.baslik, /uyan bildirim yok/);
  assert.equal(m.temizlenebilir, true);
});

test('403 rol hatası görevli gerektiğini söyler', () => {
  const m = listeHataMesaji({ durum: 403, kod: 'FORBIDDEN', mesaj: '', detay: '' });
  assert.match(m.metin, /görevli/);
  assert.equal(m.tekrarDenenebilir, false);
});

test('ağ hatası tekrar denenebilir', () => {
  const m = listeHataMesaji({ durum: 0, kod: 'AG_HATASI', mesaj: 'x', detay: '' });
  assert.match(m.metin, /ulaşılamadı/);
  assert.equal(m.tekrarDenenebilir, true);
});

test('404 liste uç noktasının henüz olmadığını ve sahte modu söyler', () => {
  const m = listeHataMesaji({ durum: 404, kod: 'BILINMEYEN_HATA', mesaj: '', detay: '' });
  assert.match(m.metin, /mock=1/);
});

test('beklenmeyen yanıt biçimi için ayrı mesaj', () => {
  const m = listeHataMesaji({ durum: 200, kod: 'YANIT_BICIMI', mesaj: '', detay: '' });
  assert.match(m.metin, /anlaşılamadı/);
});

test('sunucu hatası tekrar denenebilir', () => {
  const m = listeHataMesaji({ durum: 500, kod: 'BILINMEYEN_HATA', mesaj: '', detay: '' });
  assert.equal(m.tekrarDenenebilir, true);
});

test('sayaç aralığı ve toplamı yazar', () => {
  assert.equal(sayacMetni({ page: 2, pageSize: 20, total: 45 }), '45 bildirimden 21–40 arası');
  assert.equal(sayacMetni({ page: 1, pageSize: 20, total: 0 }), '0 bildirim');
});
