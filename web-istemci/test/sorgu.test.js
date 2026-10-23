import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  adresSorgusu,
  apiYolu,
  filtreleriOku,
  sayfalamaBilgisi,
  tasanSayfaDuzeltmesi,
} from '../js/sorgu.js';

const oku = (metin) => filtreleriOku(new URLSearchParams(metin));

test('parametre yoksa varsayılanlar gelir', () => {
  assert.deepEqual(oku(''), { status: '', category: '', page: 1, pageSize: 20 });
});

test('geçerli filtreler okunur', () => {
  assert.deepEqual(oku('status=Ustlenildi&category=Temizlik&page=3&pageSize=50'), {
    status: 'Ustlenildi',
    category: 'Temizlik',
    page: 3,
    pageSize: 50,
  });
});

test('tanınmayan durum ve kategori yok sayılır', () => {
  const f = oku('status=Silindi&category=<script>');
  assert.equal(f.status, '');
  assert.equal(f.category, '');
});

test('geçersiz sayfa numarası 1 olur', () => {
  assert.equal(oku('page=0').page, 1);
  assert.equal(oku('page=-4').page, 1);
  assert.equal(oku('page=abc').page, 1);
  assert.equal(oku('page=2.5').page, 1);
});

test('sayfa boyutu 1 ile 100 arasına sıkıştırılır', () => {
  assert.equal(oku('pageSize=500').pageSize, 100);
  assert.equal(oku('pageSize=0').pageSize, 20);
  assert.equal(oku('pageSize=x').pageSize, 20);
});

test('API yolu yalnızca dolu filtreleri içerir', () => {
  assert.equal(
    apiYolu({ status: '', category: 'Ariza', page: 2, pageSize: 20 }),
    '/api/reports?category=Ariza&page=2&pageSize=20',
  );
});

test('adres sorgusu varsayılan değerleri yazmaz', () => {
  assert.equal(adresSorgusu({ status: '', category: '', page: 1, pageSize: 20 }), '');
  assert.equal(
    adresSorgusu({ status: 'Yeni', category: '', page: 2, pageSize: 20 }),
    '?status=Yeni&page=2',
  );
});

test('sayfalama bilgisi aralığı ve düğme durumlarını hesaplar', () => {
  assert.deepEqual(sayfalamaBilgisi({ page: 2, pageSize: 20, total: 45 }), {
    toplamSayfa: 3,
    ilk: 21,
    son: 40,
    oncekiVar: true,
    sonrakiVar: true,
  });
  assert.deepEqual(sayfalamaBilgisi({ page: 3, pageSize: 20, total: 45 }), {
    toplamSayfa: 3,
    ilk: 41,
    son: 45,
    oncekiVar: true,
    sonrakiVar: false,
  });
});

test('kayıt yoksa sayfalama tek boş sayfa gösterir', () => {
  assert.deepEqual(sayfalamaBilgisi({ page: 1, pageSize: 20, total: 0 }), {
    toplamSayfa: 1,
    ilk: 0,
    son: 0,
    oncekiVar: false,
    sonrakiVar: false,
  });
});

test('son sayfanın ötesine gidilmişse son sayfaya düzeltilir', () => {
  assert.equal(tasanSayfaDuzeltmesi({ page: 9, pageSize: 20, total: 45, items: [] }), 3);
});

test('sayfa geçerliyse düzeltme gerekmez', () => {
  assert.equal(tasanSayfaDuzeltmesi({ page: 2, pageSize: 20, total: 45, items: [{}] }), null);
  assert.equal(tasanSayfaDuzeltmesi({ page: 1, pageSize: 20, total: 0, items: [] }), null);
});
