import { test } from 'node:test';
import assert from 'node:assert/strict';

import { girisFormunuDogrula, girisHataMesaji, girisSonrasiHedef } from '../js/giris.js';

test('geçerli e-posta ve parola hata vermez', () => {
  assert.equal(girisFormunuDogrula('ayse@ornek.edu', 'parola'), null);
});

test('e-posta boşsa e-posta alanı için hata döner', () => {
  const hata = girisFormunuDogrula('   ', 'parola');
  assert.equal(hata.alan, 'email');
  assert.match(hata.mesaj, /E-posta/);
});

test('e-posta biçimi bozuksa hata döner', () => {
  const hata = girisFormunuDogrula('ayse.ornek.edu', 'parola');
  assert.equal(hata.alan, 'email');
});

test('parola boşsa parola alanı için hata döner', () => {
  const hata = girisFormunuDogrula('ayse@ornek.edu', '');
  assert.equal(hata.alan, 'parola');
});

test('hatalı kimlik bilgisi hangi alanın yanlış olduğunu söylemez', () => {
  const mesaj = girisHataMesaji({ durum: 401, kod: 'INVALID_CREDENTIALS', mesaj: '', detay: '' });
  assert.equal(mesaj, 'E-posta veya parola hatalı.');
});

test('ağ hatasında sunucuya ulaşılamadığı söylenir', () => {
  const mesaj = girisHataMesaji({ durum: 0, kod: 'AG_HATASI', mesaj: 'x', detay: '' });
  assert.match(mesaj, /Sunucuya ulaşılamadı/);
});

test('doğrulama hatasında sunucunun mesajı gösterilir', () => {
  const mesaj = girisHataMesaji({
    durum: 400,
    kod: 'VALIDATION_ERROR',
    mesaj: 'E-posta ve parola zorunlu.',
    detay: 'email,password',
  });
  assert.equal(mesaj, 'E-posta ve parola zorunlu.');
});

test('bilinmeyen hatada genel mesaj gösterilir', () => {
  const mesaj = girisHataMesaji({ durum: 500, kod: 'BILINMEYEN_HATA', mesaj: '', detay: '' });
  assert.match(mesaj, /tekrar deneyin/);
});

test('görevli giriş yapınca listeye yönlendirilir', () => {
  const hedef = girisSonrasiHedef({ userId: 'u', fullName: 'G', role: 'Staff' });
  assert.deepEqual(hedef, { tur: 'yonlendir', sayfa: 'raporlar.html' });
});

test('öğrenci giriş yapınca listeye değil uyarıya düşer', () => {
  const hedef = girisSonrasiHedef({ userId: 'u', fullName: 'Ö', role: 'Student' });
  assert.equal(hedef.tur, 'uyari');
  assert.match(hedef.mesaj, /görevli/);
});

test('rolü tanınmayan kullanıcı uyarıya düşer', () => {
  const hedef = girisSonrasiHedef({ userId: 'u', fullName: 'X', role: 'Admin' });
  assert.equal(hedef.tur, 'uyari');
});
